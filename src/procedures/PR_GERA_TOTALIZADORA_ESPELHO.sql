
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_GERA_TOTALIZADORA_ESPELHO" (pCOD_FECHAMENTO IN NUMBER, pCOD_EMPRESA IN VARCHAR2, pCOD_TABELA_CONVERSAO IN VARCHAR2)
-- *******************************************************************************************************************
-- Descricao.....: PROCEDURE RESPONSÁVEL PELA GRAVAÇÃO DOS REGISTROS DOS ESPELHOS NA TOTALIZADORA
--                 ESSES GERADOS PELA PROCEDURE PR_GRAVA_ESPELHO_NA_HISTORICA
--                 TABELA PRINCIPAL: PONTO_ELETRONICO.IFPONTO_ESPELHO_TOTALIZADORES 

-- Autor................: MARCELO SOARES
-- Última alteração.....: 30/28/2023
-- Compilada em PRODUÇÃO: SIM

-- Parametros....: INFORMAR O CÓDIGO DE FECHAMENTO CRIADO NO SISTEMA IFPONTO MAIS 
--                 O CÓDIGO DA EMPRESA 
-- Funcionamento.: EXECUÇÃO MANUAL
-- Periodicidade.: CONFORME A NECESSIDADE DO RH DA EMPRESA

--  PASSOS DE EXECUÇÃO PARA INTEGRAÇÃO DA PRODABEL:

--	1) CRIAR O FECHAMENTO DO ESPELHO NO SISTEMA
--	2) ENTRAR NO SISTEMA POWER CENTER E EXECUTAR O WORKFLOW:
--		2.1) INTEGRAÇÃO DO ESPELHO
--		2.1) INTEGRAÇÃO DE BANCO DE HORAS
--	3) ENTRAR  NO SISTEMA ARTERH NA OPÇÃO COMANDO SQL  E EXECUTAR OS SQL´S:
--		3.1) GRAVA REGISTROS DO ESPELHO NA HISTORICA
--		3.2) GERAR TOTALIZADORA DO ESPELHO DE PONTO
--		3.3) GERAR TOTALIZADORA DE BANCO DE HORAS
--		3.4) GRAVA PLANILHA DE SITUAÇÃO DE PONTO 
-- 		3.5) EXECUTAR O SQL QUE APAGARÁ TODOS OS REGISTROS CRIADOS NA PLANILHA SITUAÇÃO PONTO E NAS TABELAS DE APOIO

-- *******************************************************************************************************************
IS
BEGIN
    FOR SP IN ( SELECT DISTINCT TRIM(DADO_ORIGEM) AS DADO_ORIGEM, TRIM(DADO_DESTINO) AS DADO_DESTINO
				FROM ARTERH.RHINTE_ED_IT_CONV 
				WHERE CODIGO_CONVERSAO = pCOD_TABELA_CONVERSAO
				AND TRIM(DADO_ORIGEM) <> 'BANCO_HORAS'
				ORDER BY DADO_ORIGEM
			  )
	LOOP
		CASE SP.DADO_ORIGEM
			WHEN 'ADICIONAL_NOTURNO' THEN
			-- BUSCA DA COLUNA NOTURNO_PRODABEL
				INSERT INTO PONTO_ELETRONICO.IFPONTO_ESPELHO_TOTALIZADORES
				(CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, SITUACAO, VALOR, DATA_SAIU_IFPONTO ) 

				SELECT LPAD(H.EMPRESA,4,0), LPAD(H.TIPO_CONTRATO,4,0), LPAD(H.MATRICULA,15,0), H.DATA, SP.DADO_DESTINO,
				       H.NOTURNO_PRODABEL, H.DATA_PROCESSAMENTO
				FROM PONTO_ELETRONICO.IFPONTO_ESPELHO_HISTORICA H 
				WHERE H.COD_PONTO_FECHAMENTO = pCOD_FECHAMENTO
				AND H.COD_TIPO_PESSA IN (357,360)
				AND H.NOTURNO_PRODABEL > 0
				AND H.DATA_PROCESSAMENTO IS NULL;
				COMMIT;

			WHEN 'ATRASOS' THEN  
			-- BUSCA DA COLUNA HORAS_DIFERENCIADAS E MAIS FALTA = 0			
				INSERT INTO PONTO_ELETRONICO.IFPONTO_ESPELHO_TOTALIZADORES
				(CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, SITUACAO, VALOR, DATA_SAIU_IFPONTO) 

				SELECT LPAD(H.EMPRESA,4,0), LPAD(H.TIPO_CONTRATO,4,0), LPAD(H.MATRICULA,15,0), H.DATA, SP.DADO_DESTINO,
				       H.DESCONTO, H.DATA_PROCESSAMENTO
				FROM PONTO_ELETRONICO.IFPONTO_ESPELHO_HISTORICA H 
				WHERE H.COD_PONTO_FECHAMENTO = pCOD_FECHAMENTO
				AND H.COD_TIPO_PESSA IN (357,360)
				AND  H.DESCONTO > 0
				AND UPPER(TRIM(FALTA)) = '0'
				AND H.DATA_PROCESSAMENTO IS NULL;
				COMMIT;				

			WHEN 'DSR_DESCONTADO' THEN 
			-- BUSCA DA COLUNA DSR_REAL
				INSERT INTO PONTO_ELETRONICO.IFPONTO_ESPELHO_TOTALIZADORES
				(CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, SITUACAO, VALOR, DATA_SAIU_IFPONTO) 

				SELECT LPAD(H.EMPRESA,4,0), LPAD(H.TIPO_CONTRATO,4,0), LPAD(H.MATRICULA,15,0), H.DATA, SP.DADO_DESTINO,
				       (H.DSR_REAL * (EC.HORAS_SEMANA_RAIS / EC.DIAS_TRAB_SEMANA)) AS DSR_REAL, H.DATA_PROCESSAMENTO
				FROM PONTO_ELETRONICO.IFPONTO_ESPELHO_HISTORICA H 
					 INNER JOIN ARTERH.RHPESS_CONTRATO CNT ON CNT.CODIGO = LPAD(H.MATRICULA,15,0)
                                                          AND CNT.ANO_MES_REFERENCIA = ( SELECT MAX (CNT2.ANO_MES_REFERENCIA)
                                                                                         FROM ARTERH.RHPESS_CONTRATO CNT2
                                                                                         WHERE CNT2.CODIGO = CNT.CODIGO											  
                                                                                         AND TRUNC(CNT2.ANO_MES_REFERENCIA) <= (SELECT DT_MAX_DATAS FROM ARTERH.RHPARM_P_SIST)
                                                                                         AND CNT2.TIPO_CONTRATO = CNT.TIPO_CONTRATO
                                                                                         AND CNT2.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA)
                                                          AND CNT.TIPO_CONTRATO  = LPAD(H.TIPO_CONTRATO,4,0)
														  AND CNT.CODIGO_EMPRESA = LPAD(H.EMPRESA,4,0)
                     INNER JOIN ARTERH.RHPONT_ESCALA EC ON  EC.CODIGO = CNT.CODIGO_ESCALA
                                                        AND EC.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA
				WHERE H.COD_PONTO_FECHAMENTO = pCOD_FECHAMENTO
				AND H.COD_TIPO_PESSA IN (357,360)
				AND H.DSR_REAL > 0
				AND H.DATA_PROCESSAMENTO IS NULL;				
				COMMIT;

			WHEN 'FALTAS' THEN 
			-- BUSCA DA COLUNA PREVISTO E FALTA = 1
				INSERT INTO PONTO_ELETRONICO.IFPONTO_ESPELHO_TOTALIZADORES
				(CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, SITUACAO, VALOR, DATA_SAIU_IFPONTO) 

				SELECT LPAD(H.EMPRESA,4,0), LPAD(H.TIPO_CONTRATO,4,0), LPAD(H.MATRICULA,15,0), H.DATA, SP.DADO_DESTINO,
				       H.PREVISTO, H.DATA_PROCESSAMENTO
				FROM PONTO_ELETRONICO.IFPONTO_ESPELHO_HISTORICA H 
				WHERE H.COD_PONTO_FECHAMENTO = pCOD_FECHAMENTO
				AND H.COD_TIPO_PESSA IN (357,360)
				AND H.PREVISTO > 0
				AND UPPER(TRIM(FALTA)) = '1'
				AND H.DATA_PROCESSAMENTO IS NULL;
				COMMIT;				

			WHEN 'H_BIP' THEN 
			-- BUSCA DA COLUNA SOBREAVISO_MENOS_TRABALHADO
				INSERT INTO PONTO_ELETRONICO.IFPONTO_ESPELHO_TOTALIZADORES
				(CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, SITUACAO, VALOR, DATA_SAIU_IFPONTO) 

				SELECT LPAD(H.EMPRESA,4,0), LPAD(H.TIPO_CONTRATO,4,0), LPAD(H.MATRICULA,15,0), H.DATA, SP.DADO_DESTINO,
				       H.SOBREAVISO_MENOS_TRABALHADO, H.DATA_PROCESSAMENTO
				FROM PONTO_ELETRONICO.IFPONTO_ESPELHO_HISTORICA H 
				WHERE H.COD_PONTO_FECHAMENTO = pCOD_FECHAMENTO
				AND H.COD_TIPO_PESSA IN (357,360)
				AND H.SOBREAVISO_MENOS_TRABALHADO > 0
				AND H.DATA_PROCESSAMENTO IS NULL;
				COMMIT;				

			WHEN 'HEI' THEN  
			-- BUSCA DA COLUNA HORA_EXTRA_I
				INSERT INTO PONTO_ELETRONICO.IFPONTO_ESPELHO_TOTALIZADORES
				(CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, SITUACAO, VALOR, DATA_SAIU_IFPONTO) 

				SELECT LPAD(H.EMPRESA,4,0), LPAD(H.TIPO_CONTRATO,4,0), LPAD(H.MATRICULA,15,0), H.DATA, SP.DADO_DESTINO,
				       H.H_EXTRA_I, H.DATA_PROCESSAMENTO
				FROM PONTO_ELETRONICO.IFPONTO_ESPELHO_HISTORICA H 
				WHERE H.COD_PONTO_FECHAMENTO = pCOD_FECHAMENTO
				AND H.COD_TIPO_PESSA IN (357,360)
				AND H.H_EXTRA_I > 0
				AND H.DATA_PROCESSAMENTO IS NULL;
				COMMIT;

			WHEN 'HEII' THEN
			-- BUSCA DA COLUNA HORA_EXTRA_II
				INSERT INTO PONTO_ELETRONICO.IFPONTO_ESPELHO_TOTALIZADORES
				(CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, SITUACAO, VALOR, DATA_SAIU_IFPONTO) 

				SELECT LPAD(H.EMPRESA,4,0), LPAD(H.TIPO_CONTRATO,4,0), LPAD(H.MATRICULA,15,0), H.DATA, SP.DADO_DESTINO,
				       H.H_EXTRA_II, H.DATA_PROCESSAMENTO
				FROM PONTO_ELETRONICO.IFPONTO_ESPELHO_HISTORICA H 
				WHERE H.COD_PONTO_FECHAMENTO = pCOD_FECHAMENTO
				AND H.COD_TIPO_PESSA IN (357,360)
				AND H.H_EXTRA_II > 0
				AND H.DATA_PROCESSAMENTO IS NULL;
				COMMIT;

			WHEN 'HENI' THEN  
			-- BUSCA DA COLUNA HORA_EXTRA_NOTURNA_I
				INSERT INTO PONTO_ELETRONICO.IFPONTO_ESPELHO_TOTALIZADORES
				(CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, SITUACAO, VALOR, DATA_SAIU_IFPONTO) 

				SELECT LPAD(H.EMPRESA,4,0), LPAD(H.TIPO_CONTRATO,4,0), LPAD(H.MATRICULA,15,0), H.DATA, SP.DADO_DESTINO,
				       H.H_EXTRA_NOTURNA_I, H.DATA_PROCESSAMENTO
				FROM PONTO_ELETRONICO.IFPONTO_ESPELHO_HISTORICA H 
				WHERE H.COD_PONTO_FECHAMENTO = pCOD_FECHAMENTO
				AND H.COD_TIPO_PESSA IN (357,360)
				AND H.H_EXTRA_NOTURNA_I > 0
				AND H.DATA_PROCESSAMENTO IS NULL;
				COMMIT;			

			WHEN 'HENII' THEN
			-- BUSCA DA COLUNA HORA_EXTRA_NOTURNA_II
				INSERT INTO PONTO_ELETRONICO.IFPONTO_ESPELHO_TOTALIZADORES
				(CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, SITUACAO, VALOR, DATA_SAIU_IFPONTO) 

				SELECT LPAD(H.EMPRESA,4,0), LPAD(H.TIPO_CONTRATO,4,0), LPAD(H.MATRICULA,15,0), H.DATA, SP.DADO_DESTINO,
				       H.H_EXTRA_NOTURNA_II, H.DATA_PROCESSAMENTO
				FROM PONTO_ELETRONICO.IFPONTO_ESPELHO_HISTORICA H 
				WHERE H.COD_PONTO_FECHAMENTO = pCOD_FECHAMENTO
				AND H.COD_TIPO_PESSA IN (357,360)
				AND H.H_EXTRA_NOTURNA_II > 0
				AND H.DATA_PROCESSAMENTO IS NULL;
				COMMIT;			

			WHEN 'H_NORMAIS' THEN
			-- BUSCA DA COLUNA H_NORMAIS
				INSERT INTO PONTO_ELETRONICO.IFPONTO_ESPELHO_TOTALIZADORES
				(CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, SITUACAO, VALOR, DATA_SAIU_IFPONTO) 

				SELECT LPAD(H.EMPRESA,4,0), LPAD(H.TIPO_CONTRATO,4,0), LPAD(H.MATRICULA,15,0), H.DATA, SP.DADO_DESTINO,
				       H.H_NORMAIS, H.DATA_PROCESSAMENTO
				FROM PONTO_ELETRONICO.IFPONTO_ESPELHO_HISTORICA H 
				WHERE H.COD_PONTO_FECHAMENTO = pCOD_FECHAMENTO
				AND H.COD_TIPO_PESSA IN (357,360)
				AND H.H_NORMAIS > 0
				AND H.DATA_PROCESSAMENTO IS NULL;
				COMMIT;

            ELSE DBMS_OUTPUT.PUT_LINE('AINDA NÃO FOI VALIDADO');
		END CASE;
	END LOOP;	-- **************************************************************************************************************

	-- GRAVA AS SITUAÇÕES PREENCHIDAS NO IFPONTO UTILIZANDO O MESMO CÓDIGO. VALOR UTILIZADO SERÁ DESCONTO_ABONADA - H_EXTRA
	INSERT INTO PONTO_ELETRONICO.IFPONTO_ESPELHO_TOTALIZADORES
	(CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, SITUACAO, VALOR, DATA_SAIU_IFPONTO) 

	SELECT 	LPAD(H.EMPRESA,4,0), LPAD(H.TIPO_CONTRATO,4,0), LPAD(H.MATRICULA,15,0), H.DATA, H.SIT_PONTO,
			CASE WHEN H.DESCONTO_ABONADO > 0 AND H.DESCONTO_ABONADO > H.H_EXTRA
				 THEN ROUND(H.DESCONTO_ABONADO - H.H_EXTRA,2)

				 WHEN H.H_EXTRA > 0 AND H.H_EXTRA > H.DESCONTO_ABONADO
				 THEN ROUND(H.H_EXTRA - H.DESCONTO_ABONADO,2)					 

				 ELSE ROUND(H.DESCONTO_ABONADO,2)
			END VALOR_NOVO,
			H.DATA_PROCESSAMENTO
	FROM PONTO_ELETRONICO.IFPONTO_ESPELHO_HISTORICA H 
	WHERE H.COD_PONTO_FECHAMENTO = pCOD_FECHAMENTO
	AND H.COD_TIPO_PESSA IN (357,360)
	AND H.SIT_PONTO IS NOT NULL
	AND H.DATA_PROCESSAMENTO IS NULL;
	COMMIT;	

    -- PREENCHE A DATA_PROCESSAMENTO DA TABELA IFPONTO_ESPELHO_HISTORICA
    UPDATE PONTO_ELETRONICO.IFPONTO_ESPELHO_HISTORICA EH SET EH.DATA_PROCESSAMENTO = TO_DATE(SYSDATE,'DD/MM/YYYY')
    WHERE EH.COD_EMPRESA = TO_NUMBER(pCOD_EMPRESA)
    AND EH.COD_PONTO_FECHAMENTO = pCOD_FECHAMENTO
    AND EH.COD_TIPO_PESSA IN (357,360)
	AND EH.DATA_PROCESSAMENTO IS NULL
    AND EH.MATRICULA IN (SELECT DISTINCT ET.CODIGO_CONTRATO FROM PONTO_ELETRONICO.IFPONTO_ESPELHO_TOTALIZADORES ET
                         WHERE ET.CODIGO_EMPRESA = pCOD_EMPRESA                         
                         AND ET.CODIGO_CONTRATO = EH.MATRICULA
						 AND ET.TIPO_CONTRATO = EH.TIPO_CONTRATO
                         AND ET.DATA = EH.DATA);		
	COMMIT;

END PR_GERA_TOTALIZADORA_ESPELHO;