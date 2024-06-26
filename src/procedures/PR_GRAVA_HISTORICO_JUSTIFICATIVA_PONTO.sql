
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_GRAVA_HISTORICO_JUSTIFICATIVA_PONTO" (pCOD_EMPRESA IN VARCHAR2, pDATA_INI IN DATE, pDATA_FIM IN DATE)
-- *****************************************************************************
-- Descricao.....: PROCEDURE RESPONSÁVEL PELA GRAVAÇÃO DOS REGISTROS NA TABELA
--                 DO ARTERH -> RHPONT_PROG_OCOR

-- Autor................: MARCELO SOARES
-- Última alteração.....: 02/02/2024
-- Compilada em PRODUÇÃO: SIM

-- Parametros....: INFORMAR O CÓDIGO DE EMPRESA
-- Funcionamento.: EXECUÇÃO MANUAL
-- Periodicidade.: CONFORME A NECESSIDADE DO RH DA EMPRESA

--  PASSOS DE EXECUÇÃO PARA INTEGRAÇÃO DA PRODABEL:

--	1) CRIAR O FECHAMENTO DO ESPELHO NO SISTEMA
--	2) ENTRAR NO SISTEMA POWER CENTER E EXECUTAR O WORKFLOW:
--		2.1) INTEGRAÇÃO DO ESPELHO
--		2.1) INTEGRAÇÃO DE BANCO DE HORAS
--	3) ENTRAR  NO SISTEMA ARTERH NA OPÇÃO COMANDO SQL  E EXECUTAR OS SQL´S:
--		3.1) GERAR TOTALIZADORA DE ESPELHO
--		3.2) GERAR TOTALIZADORA DE BANCO DE HORAS
--		3.3) GRAVAR REGISTROS NA PLANILHA SITUAÇÃO PONTO
-- 	4) SE EXISTIR A NECESSIDADE DE REPROCESSAMENTO DA INTEGRAÇÃO 
-- 		4.1) EXECUTAR O SQL QUE APAGARÁ TODOS OS REGISTROS CRIADOS NA PLANILHA SITUAÇÃO PONTO E NAS TABELAS DE APOIO

-- *****************************************************************************
IS
	V_EXISTE 		 	INTEGER;
	V_JORNADA		 	NUMBER;
	V_HORAS_DIARIA	 	NUMBER;
	V_SITUACAO_PONTO 	VARCHAR(4);
	V_OCORRENCIA		INTEGER;
BEGIN
	-- GRAVA OS REGISTROS NA RHPONT_PROG_OCOR COM OS VALORES CONVERTIDOS EM HORA:MINUTO
	FOR I IN (	SELECT HJ.MATRICULA AS CODIGO_CONTRATO,TRUNC(HJ.DATA) AS DT_INICIO,TRUNC(HJ.DATA) AS DT_FIM,HJ.TIPO_CONTRATO,
					HJ.EMPRESA AS CODIGO_EMPRESA,'X' AS CTRL_PROGRAMACAO,HJ.SIT_PONTO AS COD_SITUACAO_APUR,0 AS REF_MINIMA,
					ROUND((TRUNC(HJ.HORAS_ABONADA)+((HJ.HORAS_ABONADA-TRUNC(HJ.HORAS_ABONADA))*0.60)),2) AS REF_MAXIMA,
					'IFPONTO' AS LOGIN_USUARIO,TRUNC(SYSDATE) AS DT_ULT_ALTER_USUA,'S' AS C_LIVRE_OPCAO02,HJ.OBS AS COMENTARIOS
				FROM PONTO_ELETRONICO.IFPONTO_JUSTIFICATIVA_HISTORICA HJ
				WHERE HJ.EMPRESA = pCOD_EMPRESA 
				AND TRUNC(HJ.DATA) BETWEEN TRUNC(pDATA_INI) AND TRUNC(pDATA_FIM)
				AND HJ.MATRICULA IN (	SELECT DISTINCT CNT.CODIGO 
										FROM ARTERH.RHPESS_CONTRATO CNT 
										WHERE CNT.ANO_MES_REFERENCIA  = ( 	SELECT MAX (CNT2.ANO_MES_REFERENCIA)
																			FROM ARTERH.RHPESS_CONTRATO CNT2
																			WHERE CNT2.CODIGO              = CNT.CODIGO											  
																			AND   TRUNC(CNT2.ANO_MES_REFERENCIA) <= (SELECT DT_MAX_DATAS FROM ARTERH.RHPARM_P_SIST)
																			AND   CNT2.TIPO_CONTRATO       = CNT.TIPO_CONTRATO
																			AND   CNT2.CODIGO_EMPRESA      = CNT.CODIGO_EMPRESA)
										AND CNT.CODIGO_EMPRESA = HJ.EMPRESA)                        
				AND HJ.DATA_PROCESSAMENTO IS NULL)
	LOOP
		V_EXISTE	 := 0;
		V_OCORRENCIA := 0;

		-- VERIFICA SE JÁ EXISTE A OCORENCIA COM A MESMA DATA GRAVADA NA RHPONT_PROG_OCOR
		SELECT NVL(COUNT(*),0)  INTO V_EXISTE
		FROM ARTERH.RHPONT_PROG_OCOR 
		WHERE CODIGO_CONTRATO = I.CODIGO_CONTRATO 
		AND TRUNC(DT_INICIO) = TRUNC(I.DT_INICIO)
		AND TIPO_CONTRATO = I.TIPO_CONTRATO
		AND CODIGO_EMPRESA = I.CODIGO_EMPRESA
		AND COD_SITUACAO_APUR = I.COD_SITUACAO_APUR;

		IF V_EXISTE = 0 THEN
			-- VALIDA SEQUNCIAL DA OCORRENCIA
			SELECT NVL(COUNT(*),0)  INTO V_OCORRENCIA
			FROM ARTERH.RHPONT_PROG_OCOR 
			WHERE CODIGO_CONTRATO = I.CODIGO_CONTRATO 
			AND TRUNC(DT_INICIO) = TRUNC(I.DT_INICIO)
			AND TIPO_CONTRATO = I.TIPO_CONTRATO
			AND CODIGO_EMPRESA = I.CODIGO_EMPRESA;

			V_OCORRENCIA := (V_OCORRENCIA + 1);

			-- VALIDA SITUAÇÃO DE PONTO SOMENTE PARA ABONO INTEGRAL E ABONO PARCIAL
			SELECT DISTINCT JORNADA_MENSAL INTO V_JORNADA
			FROM ARTERH.RHPONT_ESCALA 
			WHERE CODIGO = (SELECT DISTINCT EC.CODIGO_ESCALA 
							 FROM ARTERH.RHPESS_CONTRATO EC 
							 WHERE EC.CODIGO = I.CODIGO_CONTRATO  
							 AND   TRUNC(EC.ANO_MES_REFERENCIA) = (SELECT MAX (CNT2.ANO_MES_REFERENCIA)
																   FROM ARTERH.RHPESS_CONTRATO CNT2
																   WHERE CNT2.CODIGO = EC.CODIGO											  
																   AND   TRUNC(CNT2.ANO_MES_REFERENCIA) <= (SELECT DT_MAX_DATAS FROM ARTERH.RHPARM_P_SIST)
																   AND   CNT2.TIPO_CONTRATO       = EC.TIPO_CONTRATO
																   AND   CNT2.CODIGO_EMPRESA      = EC.CODIGO_EMPRESA)
							 AND DATA_RESCISAO IS NULL);

			CASE
				WHEN V_JORNADA = 100 THEN V_HORAS_DIARIA := 4;
				WHEN V_JORNADA = 180 THEN V_HORAS_DIARIA := 6;
				WHEN V_JORNADA = 200 THEN V_HORAS_DIARIA := 8;
				WHEN V_JORNADA = 210 THEN V_HORAS_DIARIA := 12;
				ELSE V_HORAS_DIARIA := 0; 
			END CASE;

			IF V_HORAS_DIARIA > 0 THEN
				CASE
					WHEN I.REF_MAXIMA >  (V_HORAS_DIARIA/2) THEN V_SITUACAO_PONTO := 'P115'; -- ABONO SOCIAL
					WHEN I.REF_MAXIMA <= (V_HORAS_DIARIA/2) THEN V_SITUACAO_PONTO := 'P137'; -- ABONO SOCIAL PARCIAL
					ELSE V_SITUACAO_PONTO := I.COD_SITUACAO_APUR; -- SITUAÇÃO DE PONTO INTEGRADA DO IFPONTO
				END CASE;
			ELSE
				V_SITUACAO_PONTO := I.COD_SITUACAO_APUR;
			END IF;

			-- GRAVA A OCORENCIA
			INSERT INTO ARTERH.RHPONT_PROG_OCOR (CODIGO_CONTRATO,
												 DT_INICIO,
												 OCORRENCIA,
												 DT_FIM,
												 TIPO_CONTRATO,
												 CODIGO_EMPRESA,
												 CTRL_PROGRAMACAO,
												 COD_SITUACAO_APUR,
												 REF_MINIMA,
												 REF_MAXIMA,
												 LOGIN_USUARIO,
												 DT_ULT_ALTER_USUA,
												 C_LIVRE_OPCAO02,
												 COMENTARIOS) 
										 VALUES (I.CODIGO_CONTRATO,
										         TRUNC(I.DT_INICIO),
										         V_OCORRENCIA,
										         TRUNC(I.DT_FIM),
										         I.TIPO_CONTRATO,
										         I.CODIGO_EMPRESA,
										         I.CTRL_PROGRAMACAO,
										         V_SITUACAO_PONTO, 
										         I.REF_MINIMA,
										         I.REF_MAXIMA,
										         I.LOGIN_USUARIO,
										         TRUNC(I.DT_ULT_ALTER_USUA),
										         I.C_LIVRE_OPCAO02,
										         I.COMENTARIOS); 

			-- PREENCHE A DATA_PROCESSAMENTO DA TABELA IFPONTO_ESPELHO_TOTALIZADORES
			UPDATE PONTO_ELETRONICO.IFPONTO_JUSTIFICATIVA_HISTORICA H SET H.DATA_PROCESSAMENTO = SYSDATE
			WHERE H.EMPRESA = pCOD_EMPRESA
			AND   H.DATA_PROCESSAMENTO IS NULL
			AND   H.MATRICULA = I.CODIGO_CONTRATO
			AND   TRUNC(H.DATA) = TRUNC(I.DT_INICIO);

		END IF;
	END LOOP;
	COMMIT;
END PR_GRAVA_HISTORICO_JUSTIFICATIVA_PONTO;