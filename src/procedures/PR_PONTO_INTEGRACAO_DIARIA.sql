
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PR_PONTO_INTEGRACAO_DIARIA" 
AS


err_msg VARCHAR2(4000 BYTE);
DATA_COMPARA DATE;
DATA_SISTEMA DATE;
FECHAMENTO_SISTEMA CHAR(1 BYTE);
vCENARIO NUMBER;

vPRIMEIRO_DIA DATE;
vULTIMO_DIA DATE;
vDIA_ATUAL NUMBER;

vLOG VARCHAR2(4000 BYTE);
vQTD_REGS NUMBER;

--TESTE 18/5 20H42
PROCEDURE GRAVA_ERRO(PROCEDURE_ERRO IN VARCHAR2,COD_ERRO IN VARCHAR2, SQL_ERRO IN VARCHAR2) AS
BEGIN
INSERT INTO PONTO_ELETRONICO.SMARH_INT_LOG_INTEGRA_DIARIA(ID,PROCEDURE_ERRO,CODIGO_ERRO,DESCRICAO_ERRO) VALUES(PONTO_ELETRONICO.ID_SEQ_LOG_PONTO.NEXTVAL,PROCEDURE_ERRO,COD_ERRO,SQL_ERRO);
COMMIT;
END;
PROCEDURE GRAVA_SUCESSO(PROCEDURE_ERRO IN VARCHAR2,COD_ERRO IN VARCHAR2, SQL_ERRO IN VARCHAR2) AS
BEGIN
INSERT INTO PONTO_ELETRONICO.SMARH_INT_LOG_INTEGRA_DIARIA(ID,PROCEDURE_ERRO,CODIGO_ERRO,DESCRICAO_ERRO,VERIFICADO) VALUES(PONTO_ELETRONICO.ID_SEQ_LOG_PONTO.NEXTVAL,PROCEDURE_ERRO,COD_ERRO,SQL_ERRO,'S');
COMMIT;
END;



BEGIN                       ------PRIMEIRO BEGIN


BEGIN -----BEGIN PARA AJUSTES PRELIMIARES

/*
--inicio-comentado em 20/4/23
--INICIO--EM 29/11/22 --LIMPAR TABELAS DE REPROCESSAMENTO
--BEGIN
--reprocesso dados pessoa
--select  count(1) FROM PONTO_ELETRONICO.SUGESP_INT_PE_IFPONTO; --82814 --via php
DELETE PONTO_ELETRONICO.SUGESP_INT_PE_IFPONTO;COMMIT;
--reprocesso dados afastamentos
--select count(1) FROM PONTO_ELETRONICO.IFPONTO_AFASTAMENTOS; --lado ifponto --52106 geralmente 25 mil --via php
delete PONTO_ELETRONICO.IFPONTO_AFASTAMENTOS; COMMIT;
--select count(1) from PONTO_ELETRONICO.sugesp_bi_afastamentos; -- lado Arterh --via procedure PR_ACERTO_BASE_AFASTAMENTOS  23867 FERIAS
delete PONTO_ELETRONICO.sugesp_bi_afastamentos ;COMMIT;
--reprocessamento unidades
--select count(1) FROM PONTO_ELETRONICO.SUGES_BI_UNIDADE_IFPONTO; --3506 geralmente 1700 --via php
delete PONTO_ELETRONICO.SUGES_BI_UNIDADE_IFPONTO;COMMIT;
--END;
--FIM--EM 29/11/22 --LIMPAR TABELAS DE REPROCESSAMENTO
--fim-comentado em 20/4/23
*/

execute immediate 'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';
UPDATE PONTO_ELETRONICO.SMARH_INT_PE_JUSTIFICATIVA_IF SET DT_ENVIADO_IFPONTO_SURICATO=SYSDATE WHERE DT_ENVIADO_IFPONTO_SURICATO IS NULL;
COMMIT;
UPDATE PONTO_ELETRONICO.SMARH_INT_CAD_CERCA_DIGITAL SET DT_ENVIADO_IFPONTO_SURICATO=SYSDATE WHERE DT_ENVIADO_IFPONTO_SURICATO is null;
COMMIT;
UPDATE PONTO_ELETRONICO.SMARH_INT_PE_CARGO_V2 set DT_ENVIADO_IFPONTO_SURICATO = SYSDATE where DT_ENVIADO_IFPONTO_SURICATO is  null;
COMMIT;
UPDATE PONTO_ELETRONICO.smarh_int_pe_escala_v2 SET DT_ENVIADO_IFPONTO_SURICATO= SYSDATE WHERE DT_ENVIADO_IFPONTO_SURICATO is null;
COMMIT;
UPDATE PONTO_ELETRONICO.smarh_int_pe_jorn_escala_v2 SET DT_ENVIADO_IFPONTO_SURICATO= SYSDATE WHERE DT_ENVIADO_IFPONTO_SURICATO is null;
COMMIT;
UPDATE PONTO_ELETRONICO.SMARH_INT_PE_JORNADA_V2 SET DT_ENVIADO_IFPONTO_SURICATO= SYSDATE WHERE DT_ENVIADO_IFPONTO_SURICATO is null;
COMMIT;
update PONTO_ELETRONICO.smarh_int_pe_unidade_v2 set DT_ENVIADO_IFPONTO_SURICATO = SYSDATE   where DT_ENVIADO_IFPONTO_SURICATO is  null ;
COMMIT;
update PONTO_ELETRONICO.SMARH_INT_PONTO_DADOS_SERV_V10 set DT_ENVIADO_IFPONTO_SURICATO = SYSDATE   where DT_ENVIADO_IFPONTO_SURICATO is  null ;
COMMIT;
UPDATE PONTO_ELETRONICO.SMARH_INT_CAD_PESS_CERCA SET DT_ENVIADO_IFPONTO_SURICATO=SYSDATE WHERE DT_ENVIADO_IFPONTO_SURICATO is null;
COMMIT;
UPDATE PONTO_ELETRONICO.SMARH_INT_PE_AFASTAMENTOS_V1  SET DT_ENVIADO_IFPONTO_SURICATO = SYSDATE where DT_ENVIADO_IFPONTO_SURICATO is null;
COMMIT;

--KELLYSSON novo INICIO-- em 20/5/22 para fazer backup diario da tabela de log da ALT SIT FUNC
INSERT INTO ARTERH.SMARH_INT_PE_ALTSITFUN_AUDBKP 
SELECT * FROM ARTERH.SMARH_INT_PE_ALTSITFUN_AUDITO WHERE TRUNC(DT_ULT_ALTER_USUA) BETWEEN TRUNC(SYSDATE)-1 AND TRUNC(SYSDATE)-1;commit;

END; -----BEGIN PARA AJUSTES PRELIMIARES



---INICIO --KELLYSSON --NOVO EM 3/7/23 PARA EVITAR ERRO NA INTEGRAÇÃO PROCEDURE SMARH_INT_PE_CONTRATOS_ARTE ERRO: ORA-01427: a subconsulta de uma única linha retorna mais de uma linha
--BEGIN
dbms_output.enable(null);
FOR C1 IN
(
select x.* from (
select rowid, row_number()over(partition by x.bm, trunc(x.data_dados) order by  data_dados desc,bm)ordem_bm_dia, x.bm, to_char(data_dados,'DD/MM/YYYY HH24:MI:SS') dt_dados_puro, trunc(x.data_dados)trunc_dt_dados from 
PONTO_ELETRONICO.SMSP_SICOOR_ESCALA_LOCAL_DIA x where trunc(x.data_dados)  = trunc(sysdate)-1 order by data_dados desc,bm
)x where ordem_bm_dia > 1
)
LOOP
--dbms_output.put_line('C1.ROWID: '||C1.ROWID);
DELETE PONTO_ELETRONICO.SMSP_SICOOR_ESCALA_LOCAL_DIA WHERE ROWID = C1.ROWID;COMMIT;
END LOOP;
--END;
---FIM--KELLYSSON --NOVO EM 3/7/23 PARA EVITAR ERRO NA INTEGRAÇÃO PROCEDURE SMARH_INT_PE_CONTRATOS_ARTE ERRO: ORA-01427: a subconsulta de uma única linha retorna mais de uma linha


----DATAS DO SISTEMA
Select trunc(sysdate,'MM') INTO DATA_COMPARA FROM DUAL;

select X.CENARIOS, CASE WHEN X.CENARIOS IN ('1','2') THEN 'S' ELSE 'N' END AS SISTEMA_FECHADO,F2 INTO vCENARIO, FECHAMENTO_SISTEMA, DATA_SISTEMA from (SELECT
CASE WHEN (X.F2 > X.FIM_FOLHA AND X.REF_CONTRATO > X.FIM_FOLHA) AND X.FIM_FECHAMENTO IS NULL THEN 1/*'1-SISTEMA_FECHADO_DATAS_OK'*/WHEN (X.F2 <= X.FIM_FOLHA OR X.REF_CONTRATO <= X.FIM_FOLHA)AND X.FIM_FECHAMENTO IS NULL THEN 2/*'2-SISTEMA_FECHADO_DATAS_ERRADAS'*/
WHEN (X.F2> X.FIM_FOLHA AND X.REF_CONTRATO > X.FIM_FOLHA)AND X.FIM_FECHAMENTO IS NOT NULL THEN 3/*'3-SISTEMA_ABERTO_DATAS_OK'*/ WHEN (X.F2<= X.FIM_FOLHA OR X.REF_CONTRATO <= X.FIM_FOLHA)AND X.FIM_FECHAMENTO IS NOT NULL THEN 4 /*'4-SISTEMA_ABERTO_DATAS_ERRADAS'*/ ELSE 0/*'FALTA MAPEAR'*/
END CENARIOS,  X.* FROM (SELECT(SELECT DATA_DO_SISTEMA FROM rhparm_p_sist) AS F2,(SELECT DT_REFER_CADASTRO FROM rhparm_p_sist) AS REF_CONTRATO, u.data_ini_vigencia INICIO_FECHAMENTO, u.data_fim_vigencia FIM_FECHAMENTO, u.data_ini_folha INICIO_FOLHA, u.data_fim_folha FIM_FOLHA FROM RHPONT_APUR_AGRUP u WHERE u.ocorrencia =(SELECT MAX(x.ocorrencia) FROM RHPONT_APUR_AGRUP x WHERE x.codigo_empresa = '0001' AND x.tipo_apur = 'F' AND c_livre_selec01 = 3 AND id_agrup = 152123) AND c_livre_selec01 = 3--novo em 19/3/21
)X)X;





--INICIO--NOVO EM 15/12/22 ---PARA DISPARAR FECHAMENTO SEMI-AUTOMATICO DIA 11
SELECT EXTRACT(DAY FROM SYSDATE)DIA_ATUAL INTO vDIA_ATUAL FROM DUAL;

IF vDIA_ATUAL = 11 THEN
SELECT TO_DATE(MAX(TO_DATE(AUX.DADO_ORIGEM, 'DD/MM/YYYY')+1), 'DD/MM/YYYY')PRIMEIRO_DIA INTO vPRIMEIRO_DIA FROM ARTERH.RHINTE_ED_IT_CONV AUX  WHERE CODIGO_CONVERSAO = 'FCPT'; --PRIMEIRO DIA PARA FECHAR NO DIA 11
SELECT TO_DATE(LAST_DAY(MAX(TO_DATE(AUX.DADO_ORIGEM, 'DD/MM/YYYY')+1)), 'DD/MM/YYYY')ULTIMO_DIA  INTO vULTIMO_DIA FROM ARTERH.RHINTE_ED_IT_CONV AUX  WHERE CODIGO_CONVERSAO = 'FCPT'; --ULTIMO DIA PARA FECHAR NO DIA 11

INSERT INTO PONTO_ELETRONICO.IFPONTO_FECHAMENTO (TIPO, TIPO_FECHAMENTO,  EMPRESA, DESCRICAO, DATA_INICIO, DATA_FIM, INCLUIR_DEMITIDOS, ASSINATURA_ESPELHO, DT_SAIU_ARTE, CODIGO_INTEGRA_ARTE)
                                          VALUES('INCLUIR', 'EMPRESA', '0001', 'FECHAMENTO POR EMPRESA', TO_DATE(vPRIMEIRO_DIA,'DD/MM/YYYY'), TO_DATE(vULTIMO_DIA,'DD/MM/YYYY'),'SIM', 'SIM', SYSDATE, PONTO_ELETRONICO.SEQUENCE_INTEGRA_ARTE.NEXTVAL); COMMIT;
INSERT INTO PONTO_ELETRONICO.IFPONTO_FECHAMENTO_LOG_RELAT (CONSIDERACOES, DATA_DADOS, CAMPO_1)VALUES('LOG_PR_FECHAMENTO_MES', SYSDATE, 'GRAVOU FECHAMENTO EMPRESA 0001 NA TABELA PONTO_ELETRONICO.IFPONTO_FECHAMENTO');COMMIT;

INSERT INTO PONTO_ELETRONICO.IFPONTO_FECHAMENTO (TIPO, TIPO_FECHAMENTO,  EMPRESA, DESCRICAO, DATA_INICIO, DATA_FIM, INCLUIR_DEMITIDOS, ASSINATURA_ESPELHO, DT_SAIU_ARTE, CODIGO_INTEGRA_ARTE)
                                          VALUES('INCLUIR', 'EMPRESA', '0003', 'FECHAMENTO POR EMPRESA', TO_DATE(vPRIMEIRO_DIA,'DD/MM/YYYY'), TO_DATE(vULTIMO_DIA,'DD/MM/YYYY'),'SIM', 'SIM', SYSDATE, PONTO_ELETRONICO.SEQUENCE_INTEGRA_ARTE.NEXTVAL); COMMIT;
INSERT INTO PONTO_ELETRONICO.IFPONTO_FECHAMENTO_LOG_RELAT (CONSIDERACOES, DATA_DADOS, CAMPO_1)VALUES('LOG_PR_FECHAMENTO_MES', SYSDATE, 'GRAVOU FECHAMENTO EMPRESA 0003 NA TABELA PONTO_ELETRONICO.IFPONTO_FECHAMENTO');COMMIT;

--NOVO EM 8/5/23 primeiro mes simulado frequencia abril/23 em 11/5/23
INSERT INTO PONTO_ELETRONICO.IFPONTO_FECHAMENTO (TIPO, TIPO_FECHAMENTO,  EMPRESA, DESCRICAO, DATA_INICIO, DATA_FIM, INCLUIR_DEMITIDOS, ASSINATURA_ESPELHO, DT_SAIU_ARTE, CODIGO_INTEGRA_ARTE)
                                          VALUES('INCLUIR', 'EMPRESA', '0014', 'FECHAMENTO POR EMPRESA', TO_DATE(vPRIMEIRO_DIA,'DD/MM/YYYY'), TO_DATE(vULTIMO_DIA,'DD/MM/YYYY'),'SIM', 'SIM', SYSDATE, PONTO_ELETRONICO.SEQUENCE_INTEGRA_ARTE.NEXTVAL); COMMIT;
INSERT INTO PONTO_ELETRONICO.IFPONTO_FECHAMENTO_LOG_RELAT (CONSIDERACOES, DATA_DADOS, CAMPO_1)VALUES('LOG_PR_FECHAMENTO_MES', SYSDATE, 'GRAVOU FECHAMENTO EMPRESA 0014 NA TABELA PONTO_ELETRONICO.IFPONTO_FECHAMENTO');COMMIT;

--NOVO EM 3/7/23 primeiro mes simulado frequencia JUNHO/23 em 11/7/23
INSERT INTO PONTO_ELETRONICO.IFPONTO_FECHAMENTO (TIPO, TIPO_FECHAMENTO,  EMPRESA, DESCRICAO, DATA_INICIO, DATA_FIM, INCLUIR_DEMITIDOS, ASSINATURA_ESPELHO, DT_SAIU_ARTE, CODIGO_INTEGRA_ARTE)
                                          VALUES('INCLUIR', 'EMPRESA', '0013', 'FECHAMENTO POR EMPRESA', TO_DATE(vPRIMEIRO_DIA,'DD/MM/YYYY'), TO_DATE(vULTIMO_DIA,'DD/MM/YYYY'),'SIM', 'SIM', SYSDATE, PONTO_ELETRONICO.SEQUENCE_INTEGRA_ARTE.NEXTVAL); COMMIT;
INSERT INTO PONTO_ELETRONICO.IFPONTO_FECHAMENTO_LOG_RELAT (CONSIDERACOES, DATA_DADOS, CAMPO_1)VALUES('LOG_PR_FECHAMENTO_MES', SYSDATE, 'GRAVOU FECHAMENTO EMPRESA 0013 NA TABELA PONTO_ELETRONICO.IFPONTO_FECHAMENTO');COMMIT;



--novo em 8/3/23 --inicio
SELECT count(1) INTO vQTD_REGS FROM PONTO_ELETRONICO.IFPONTO_HORARIO;
vLOG := 'TAREFA 36 ANTES EXCLUIR ' ||vQTD_REGS|| ' REGISTROS NA TABELA PONTO_ELETRONICO.IFPONTO_HORARIO.';
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO PONTO_ELETRONICO.IFPONTO_FECHAMENTO_LOG_RELAT (CONSIDERACOES, DATA_DADOS, CAMPO_1, CAMPO_2)VALUES('LOG_PR_FECHAMENTO_MES_P1', SYSDATE, vLOG, vQTD_REGS);COMMIT;
vLOG := NULL;
DELETE PONTO_ELETRONICO.IFPONTO_HORARIO; COMMIT;

SELECT count(1) INTO vQTD_REGS FROM PONTO_ELETRONICO.IFPONTO_ESCALA_PADRAO;
vLOG := 'TAREFA 36 ANTES EXCLUIR ' ||vQTD_REGS|| ' REGISTROS NA TABELA PONTO_ELETRONICO.IFPONTO_ESCALA_PADRAO.';
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO PONTO_ELETRONICO.IFPONTO_FECHAMENTO_LOG_RELAT (CONSIDERACOES, DATA_DADOS, CAMPO_1, CAMPO_2)VALUES('LOG_PR_FECHAMENTO_MES_P1', SYSDATE, vLOG, vQTD_REGS);COMMIT;
vLOG := NULL;
DELETE PONTO_ELETRONICO.IFPONTO_ESCALA_PADRAO; COMMIT;

SELECT count(1) INTO vQTD_REGS FROM PONTO_ELETRONICO.IFPONTO_ESCALA_HORARIO;
vLOG := 'TAREFA 36 ANTES EXCLUIR ' ||vQTD_REGS|| ' REGISTROS NA TABELA PONTO_ELETRONICO.IFPONTO_ESCALA_HORARIO.';
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO PONTO_ELETRONICO.IFPONTO_FECHAMENTO_LOG_RELAT (CONSIDERACOES, DATA_DADOS, CAMPO_1, CAMPO_2)VALUES('LOG_PR_FECHAMENTO_MES_P1', SYSDATE, vLOG, vQTD_REGS);COMMIT;
vLOG := NULL;
DELETE PONTO_ELETRONICO.IFPONTO_ESCALA_HORARIO; COMMIT;

SELECT count(1) INTO vQTD_REGS FROM PONTO_ELETRONICO.IFPONTO_ESCALA_PESSOA;
vLOG := 'TAREFA 36 ANTES EXCLUIR ' ||vQTD_REGS|| ' REGISTROS NA TABELA PONTO_ELETRONICO.IFPONTO_ESCALA_PESSOA.';
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO PONTO_ELETRONICO.IFPONTO_FECHAMENTO_LOG_RELAT (CONSIDERACOES, DATA_DADOS, CAMPO_1, CAMPO_2)VALUES('LOG_PR_FECHAMENTO_MES_P1', SYSDATE, vLOG, vQTD_REGS);COMMIT;
vLOG := NULL;
DELETE PONTO_ELETRONICO.IFPONTO_ESCALA_PESSOA; COMMIT;

SELECT count(1) INTO vQTD_REGS FROM PONTO_ELETRONICO.IFPONTO_RL_ESC_HOR;
vLOG := 'TAREFA 36 ANTES EXCLUIR ' ||vQTD_REGS|| ' REGISTROS NA TABELA PONTO_ELETRONICO.IFPONTO_RL_ESC_HOR.';
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO PONTO_ELETRONICO.IFPONTO_FECHAMENTO_LOG_RELAT (CONSIDERACOES, DATA_DADOS, CAMPO_1, CAMPO_2)VALUES('LOG_PR_FECHAMENTO_MES_P1', SYSDATE, vLOG, vQTD_REGS);COMMIT;
vLOG := NULL;
DELETE PONTO_ELETRONICO.IFPONTO_RL_ESC_HOR; COMMIT;
--novo em 8/3/23 --fim




END IF;
--FIM--NOVO EM 15/12/22 ---PARA DISPARAR FECHAMENTO SEMI-AUTOMATICO DIA 11


/****---------------------------------------------------------------------------------------INTEGRACAO DIARIA -----------------------------------------------------------------------------------***/

IF vCENARIO IN (1,3) THEN --NOVO IF EM 30/11/22

BEGIN
  ARTERH.PR_PROXIMA_SITUACAO_FUNCIONAL (to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));
    err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_PROXIMA_SITUACAO_FUNCIONAL','000',err_msg);
  exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_PROXIMA_SITUACAO_FUNCIONAL',SQLCODE,err_msg);
END;


BEGIN 
ARTERH.PR_FICHA_FUTURA_GRAVA_SIT_FUNC(to_char(sysdate,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy'));
 err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_FICHA_FUTURA_GRAVA_SIT_FUNC','000',err_msg);
exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_FICHA_FUTURA_GRAVA_SIT_FUNC',SQLCODE,err_msg);
END;


BEGIN
ARTERH.PR_AJUSTES_ALT_SIT_FUNC_2022(to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy')); 
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_AJUSTES_ALT_SIT_FUNC_2022','000',err_msg);
exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_AJUSTES_ALT_SIT_FUNC_2022',SQLCODE,err_msg);
END;


BEGIN
 ARTERH.PR_ACERTOS_ALT_SIT_FUNC_2022; 
 err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_ACERTOS_ALT_SIT_FUNC_2022','000',err_msg);
exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_ACERTOS_ALT_SIT_FUNC_2022',SQLCODE,err_msg);
END;


BEGIN
 ARTERH.PR_ACERTOS_HIST_ESCALA_CONTR;
     err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_ACERTOS_HIST_ESCALA_CONTR','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_ACERTOS_HIST_ESCALA_CONTR',SQLCODE,err_msg);
END;


BEGIN
 ARTERH.PR_ACERTOS_LACUNAS_HIST_ESCALA;
      err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_ACERTOS_LACUNAS_HIST_ESCALA','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_ACERTOS_LACUNAS_HIST_ESCALA',SQLCODE,err_msg);
END;

END IF;
--FIM IF vCENARIO IN (1,3) THEN --NOVO IF EM 30/11/22



BEGIN
    ARTERH.PR_LOTE_FIC_MED_AJUSTE_ATENDEN(to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));
    err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_LOTE_FIC_MED_AJUSTE_ATENDEN','000',err_msg);
  exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_LOTE_FIC_MED_AJUSTE_ATENDEN',SQLCODE,err_msg);
END;


BEGIN
 ARTERH.PR_LOTE_FIC_MED_AJUSTE_DOENCA(to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));
       err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_LOTE_FIC_MED_AJUSTE_DOENCA','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_LOTE_FIC_MED_AJUSTE_DOENCA',SQLCODE,err_msg);
END;


--------------------------------------------------------------------------------COMECO DAS INTEGRACOES  DIARIAS COM PONTO ELETRONIOC ---------------------------------------------------------------------------------------------------------------------------

BEGIN
DELETE FROM PONTO_ELETRONICO.ARTERH_SIOM SM WHERE SM.CODIGO_OPUS= (SELECT XX.CODIGO_OPUS FROM (SELECT COUNT(1)QUANT,X.CODIGO_OPUS,X.DATA_CARGA FROM (SELECT CODIGO_OPUS,trunc(DATA_CARGA)as data_carga FROM PONTO_ELETRONICO.ARTERH_SIOM )X
WHERE TRUNC(X.DATA_CARGA)=TRUNC(sysdate)
group by X.CODIGO_OPUS, X.DATA_CARGA)XX
WHERE XX.QUANT=2
AND SM.CODIGO_OPUS=XX.CODIGO_OPUS
AND TRUNC(SM.DATA_CARGA)=TRUNC(XX.DATA_CARGA))
AND SM.DATA_DESATIVACAO IS NOT NULL;
COMMIT;


DELETE  FROM PONTO_ELETRONICO.SMSP_SICOOR_ESCALA_LOCAL_DIA D WHERE LPAD(replace(D.BM,'-',''),15,0) =(SELECT X.CODIGO_CONTRATO FROM (SELECT COUNT(1) QUANT,
                CN.CODIGO_EMPRESA,
                CN.TIPO_CONTRATO,
                X.CODIGO_CONTRATO,
                X.CODIGO_PROPRIO
              FROM
                (SELECT 'ULTIMO'      AS DIA,
                  LPAD(replace(CARGA.BM,'-',''),15,0) AS CODIGO_CONTRATO,
                  CARGA.CODPROPRIO    AS CODIGO_PROPRIO,
                  CARGA.ESCALA ,
                  CARGA.HORAINIC AS HORA_INICIO,
                  CARGA.HORAFIM  AS HORA_FIM,
                  CARGA.DATA_DADOS
                FROM PONTO_ELETRONICO.SMSP_SICOOR_ESCALA_LOCAL_DIA carga
                WHERE TRUNC(CARGA.DATA_DADOS)=
                  (SELECT MAX(TRUNC(AUX.DATA_DADOS))
                  FROM PONTO_ELETRONICO.SMSP_SICOOR_ESCALA_LOCAL_DIA AUX
                --  WHERE AUX.DATA_DADOS<='05/05/2021'
                  )
                )X
              LEFT OUTER JOIN
                (SELECT *
                FROM ARTERH.RHPESS_CONTRATO CN
                WHERE CN.ANO_MES_REFERENCIA=
                  (SELECT MAX(AUX.ANO_MES_REFERENCIA)
                  FROM ARTERH.RHPESS_CONTRATO AUX
                  WHERE AUX.CODIGO      =CN.CODIGO
                  AND AUX.CODIGO_EMPRESA=CN.CODIGO_EMPRESA
                  AND AUX.TIPO_CONTRATO =CN.TIPO_CONTRATO
                  )
                )CN
              ON CN.CODIGO         =X.CODIGO_CONTRATO
              AND CN.CODIGO_EMPRESA='0001'
              AND CN.TIPO_CONTRATO ='0001'
              LEFT OUTER JOIN ARTERH.RHINTE_ED_IT_CONV CHAVE
              ON SUBSTR(CHAVE.DADO_ORIGEM,0,4) =CN.CODIGO_EMPRESA
              AND SUBSTR(CHAVE.DADO_ORIGEM,5,4)=CN.SITUACAO_FUNCIONAL
              AND CHAVE.CODIGO_CONVERSAO       ='POST' 
              HAVING COUNT(1)>1
              group by CN.CODIGO_EMPRESA, CN.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.CODIGO_PROPRIO
             )X
             WHERE X.CODIGO_CONTRATO=LPAD(replace(D.BM,'-',''),15,0)
             )

            AND TRUNC(D.DATA_DADOS)=
                  (SELECT MAX(TRUNC(AUX.DATA_DADOS))
                  FROM PONTO_ELETRONICO.SMSP_SICOOR_ESCALA_LOCAL_DIA AUX
                --  WHERE AUX.DATA_DADOS<='05/05/2021'
                  )
                  AND ROWNUM=1;
                  COMMIT;
end;


/*NOVA INTEGRACAO COM A GUARDA*/
begin
 PONTO_ELETRONICO.PR_SMSP_CARGA_PROPRIOS();
 err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_SMSP_CARGA_PROPRIOS','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_SMSP_CARGA_PROPRIOS',SQLCODE,err_msg);
END;


begin
 PONTO_ELETRONICO.PR_SMSP_CAD_CERCA_PONTO();
 err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_SMSP_CAD_CERCA_PONTO','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_SMSP_CAD_CERCA_PONTO',SQLCODE,err_msg);
END;


begin
 PONTO_ELETRONICO.PR_SMSP_ESCALA_CERCA_CONTRATO();
 err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_SMSP_ESCALA_CERCA_CONTRATO','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_SMSP_ESCALA_CERCA_CONTRATO',SQLCODE,err_msg);
END;
/*FIM PARTE DA GUARDA*/





/*Gabriel aqui em 05/10/2023 desativado devido aos problemas com os enderecos

begin
 PONTO_ELETRONICO.SMARH_INT_ATT_ENDERECOS;
        err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_ATT_ENDERECOS','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_ATT_ENDERECOS',SQLCODE,err_msg);
END;


begin
 PONTO_ELETRONICO.SMARH_INT_CAR_ARTE_END;
         err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_CAR_ARTE_END','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_CAR_ARTE_END',SQLCODE,err_msg);
END;
*/



/*Gabriel aqui em 06/11/2023 16:20 inclusão de nova procedure de endereços*/

--PR_SUGESP_ATUALIZACAO_ENDE
begin
 PONTO_ELETRONICO.PR_SUGESP_ATUALIZACAO_ENDE;
         err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_SUGESP_ATUALIZACAO_ENDE','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_SUGESP_ATUALIZACAO_ENDE',SQLCODE,err_msg);
END;
/*-----*/
begin
 PONTO_ELETRONICO.SMARH_INT_PE_CONTRATOS_ARTE;
          err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_CONTRATOS_ARTE','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_CONTRATOS_ARTE',SQLCODE,err_msg);
END;


begin
 PONTO_ELETRONICO.SMARH_INT_PE_CAD_JUSTIFICATIVA(to_char(sysdate-1 ,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));
           err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_CAD_JUSTIFICATIVA','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_CAD_JUSTIFICATIVA',SQLCODE,err_msg);
END;


begin
 PONTO_ELETRONICO.SMARH_INT_CAD_CERCAS(to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));
            err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_CAD_CERCAS','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_CAD_CERCAS',SQLCODE,err_msg);
END;


begin
PONTO_ELETRONICO.SMARH_INT_PE_CAD_CARGO_FUNCAO (to_char(sysdate-1 ,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_CAD_CARGO_FUNCAO','000',err_msg);
exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_CAD_CARGO_FUNCAO',SQLCODE,err_msg);
END;


begin
PONTO_ELETRONICO.SMARH_INT_PE_CAD_DEPTO_HIERAR  (to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_CAD_DEPTO_HIERAR','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_CAD_DEPTO_HIERAR',SQLCODE,err_msg);
END;


begin
PONTO_ELETRONICO.SMARH_INT_PE_CAD_HORARIO (to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_CAD_HORARIO','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_CAD_HORARIO',SQLCODE,err_msg);
END;


begin
PONTO_ELETRONICO.SMARH_INT_PE_CAD_ESCALA (to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_CAD_ESCALA','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_CAD_ESCALA',SQLCODE,err_msg);
END;


begin
PONTO_ELETRONICO.SMARH_INT_PE_CAD_JORN_HOR (to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_CAD_JORN_HOR','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_CAD_JORN_HOR',SQLCODE,err_msg);
END;


begin
PONTO_ELETRONICO.SMARH_INT_PE_ATUALIZA_IFPONTO;
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_ATUALIZA_IFPONTO','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_ATUALIZA_IFPONTO',SQLCODE,err_msg);
END;

/*--comentado 14/12/23 Kellysson desativado servidores da Telematica
begin
suricato.sp_integra@LK_PROD_SUR.PBH;
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SURICATO','000',err_msg);

 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SURICATO',SQLCODE,err_msg);
END;
*/

begin
PONTO_ELETRONICO.SMARH_INT_CAD_PESSOA(to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_CAD_PESSOA','000',err_msg);

 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_CAD_PESSOA',SQLCODE,err_msg);


END;

/* --INICIO--DESATIVADO EM 12/4/23
begin
PONTO_ELETRONICO.SMARH_INT_PE_CAD_FERIAS_EXCLUI (to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_CAD_FERIAS_EXCLUI','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_CAD_FERIAS_EXCLUI',SQLCODE,err_msg);
END;


begin
PONTO_ELETRONICO.SMARH_INT_AFASTAMENTOS_EXC (to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_AFASTAMENTOS_EXC','000',err_msg);

 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_AFASTAMENTOS_EXC',SQLCODE,err_msg);
END;


begin
PONTO_ELETRONICO.SMARH_INT_PE_CAD_FERIAS_INCLUI (to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_CAD_FERIAS_INCLUI','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_CAD_FERIAS_INCLUI',SQLCODE,err_msg);


END;
begin
PONTO_ELETRONICO.SMARH_INT_AFASTAMENTOS_INC (to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_AFASTAMENTOS_INC','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_AFASTAMENTOS_INC',SQLCODE,err_msg);
END;

*/-- INICIO--DESATIVADO EM 12/4/23

--INICIO--NOVO EM 12/4/23 erro ajustado em 14/4/23
begin
PONTO_ELETRONICO.PR_NEW_AFASTAMENTOS (to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_NEW_AFASTAMENTOS','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_NEW_AFASTAMENTOS',SQLCODE,err_msg);
END;
--FIM--NOVO EM 12/4/23


--INICIO---------------------------------TEMPORARIO EM 18/11/22
--EM 7/11/22 ---TIRAR REGISTROS REPETIDOS AFASTAMENTO ATE AJUSTAR PROCEDURE DE REPROCESSAMENTO
FOR C1 IN (
select CASE WHEN I.TIPO IS NOT NULL AND E.TIPO IS NOT NULL THEN 'UPDATE PONTO_ELETRONICO.SMARH_INT_PE_AFASTAMENTOS_V1 SET DT_ENVIADO_IFPONTO_SURICATO = SYSDATE WHERE CODIGO_INTEGRA_ARTE IN('||E.CODIGO_INTEGRA_ARTE||','||I.CODIGO_INTEGRA_ARTE||');COMMIT;'END COMANDO,
CASE WHEN I.TIPO IS NOT NULL AND E.TIPO IS NOT NULL THEN 'EXCLUI_INCLUI' WHEN I.TIPO IS NULL AND E.TIPO IS NOT NULL THEN 'SO_EXCLUI' WHEN I.TIPO IS NOT NULL AND E.TIPO IS NULL THEN 'SO_INCLUI' END CENARIO,
I.TIPO I_TIPO, I.CODIGO_INTEGRA_ARTE I_CODIGO_INTEGRA_ARTE, E.TIPO E_TIPO, E.CODIGO_INTEGRA_ARTE E_CODIGO_INTEGRA_ARTE
--,I.*, E.*
FROM(SELECT * from PONTO_ELETRONICO.SMARH_INT_PE_AFASTAMENTOS_V1  where trunc(dt_saiu_arte) >= trunc(sysdate) and DT_ENVIADO_IFPONTO_SURICATO is null and tipo = 'INCLUIR' )I
FULL OUTER JOIN (select * from PONTO_ELETRONICO.SMARH_INT_PE_AFASTAMENTOS_V1  where trunc(dt_saiu_arte) >= trunc(sysdate) and DT_ENVIADO_IFPONTO_SURICATO is null and tipo = 'EXCLUIR' )E
ON I.CODIGO_EMPRESA = E.CODIGO_EMPRESA AND I.TIPO_CONTRATO = E.TIPO_CONTRATO AND I.CODIGO_CONTRATO = E.CODIGO_CONTRATO AND TRUNC(I.DATA_INICIO) = TRUNC(E.DATA_INICIO) AND TRUNC(I.DATA_FIM) = TRUNC(E.DATA_FIM)
)LOOP
IF C1.I_TIPO IS NOT NULL AND C1.E_TIPO IS NOT NULL THEN 
UPDATE PONTO_ELETRONICO.SMARH_INT_PE_AFASTAMENTOS_V1 SET DT_ENVIADO_IFPONTO_SURICATO = SYSDATE WHERE CODIGO_INTEGRA_ARTE IN(C1.E_CODIGO_INTEGRA_ARTE,C1.I_CODIGO_INTEGRA_ARTE);COMMIT;
END IF;
END LOOP;
--FIM-----------------------------TEMPORARIO EM 18/11/22



begin
 ARTERH.PR_SUGESP_NOME_COMPOSTO_AZC;
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_SUGESP_NOME_COMPOSTO_AZC','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_SUGESP_NOME_COMPOSTO_AZC',SQLCODE,err_msg);
END;


begin
UPDATE ARTERH.SMARH_INT_ATUALIZA_AD AD  SET AD.INTEGRADO='S' WHERE TRUNC(AD.DATA_CARGA)=TRUNC(sysdate) AND EXISTS (SELECT * FROM ARTERH.SMARH_INT_ATUALIZA_AD AUX WHERE TRUNC(AUX.DATA_CARGA)<=TRUNC(sysdate-2) AND AUX.LOGIN_USUARIO=AD.LOGIN_USUARIO) ;
COMMIT;
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('ATUALIZA_TABELA_AD','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('ATUALIZA_TABELA_AD',SQLCODE,err_msg);
END;


begin
ARTERH.PR_SMARH_ATUALIZA_AD_EMAIL;
COMMIT;
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_SMARH_ATUALIZA_AD_EMAIL','000',err_msg);

 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_SMARH_ATUALIZA_AD_EMAIL',SQLCODE,err_msg);
END;


begin
PONTO_ELETRONICO.SMARH_INT_PE_ATUALIZA_ARTE_V1;
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_ATUALIZA_ARTE_V1','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_ATUALIZA_ARTE_V1',SQLCODE,err_msg);
END;





IF vCENARIO IN (1,3) THEN --NOVO EM 30/11/22
begin
ARTERH.PR_ACERTO_TEG_SIT_FUNC(to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));

err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_ACERTO_TEG_SIT_FUNC','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_ACERTO_TEG_SIT_FUNC',SQLCODE,err_msg);
END;
END IF;
--FIM --NOVO IF EM 30/11/22

begin
PONTO_ELETRONICO.PR_ATUALIZA_USUARIO;

err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_ATUALIZA_USUARIO','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_ATUALIZA_USUARIO',SQLCODE,err_msg);
END;


begin
ARTERH.PR_ANALISE_POS_FICHAS_TEG(to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));

err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_ANALISE_POS_FICHAS_TEG','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_ANALISE_POS_FICHAS_TEG',SQLCODE,err_msg);
END;

------------------------------------------------------------------------------------FIM ------------------IF --------------------------------------------------------------------------------




--INICIO--TESTES EM 11/11/22
/*
begin
PONTO_ELETRONICO.SMARH_INT_PE_CONTRATOS_A_BK;

err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_CONTRATOS_A_BK','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_CONTRATOS_A_BK',SQLCODE,err_msg);
END;
*/
--FIM--TESTES EM 11/11/22

END; ------PRIMEIRO BEGIN