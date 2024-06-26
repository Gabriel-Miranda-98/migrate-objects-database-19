
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_TAREFAS_DURANTE_MES" AS

--Kellysson em 30/12/22 -- para automatizar tarefas que ocorrem durante o mes
/*
DIA 1º DO MES
1-rodar simulador ifponto do mes
2-CRIAR REG APURACAO TIPO 2 PARA PBH 152123
3-enviar relatorio mensal TEG
4-rodar 3 sql para enviar relatorio GETED sobre 1017
5-relatorio pessoas SMED Ifractal
6-Re: Recesso Estagiário

DIA 20
1-limpa log ALT SIT FUNC

ULTIMO DIA MES
1-RODAR REMUNERACAO MES PARA TEG
*/


vDATA_INICIO DATE;
vDATA_FIM DATE;
vDIA_ATUAL NUMBER;
vULTIMO_DIA_MES NUMBER;
vQTD_REGS NUMBER;
vLOG VARCHAR2(4000 BYTE);

err_msg VARCHAR2(4000 BYTE);
vSTATUS VARCHAR2(10 BYTE);



---PROCEDURE PARA GRAVAR LOG DE ERRO
PROCEDURE GRAVA_ERRO(PROCEDURE_ERRO IN VARCHAR2,COD_ERRO IN VARCHAR2, SQL_ERRO IN VARCHAR2) AS
BEGIN
INSERT INTO PONTO_ELETRONICO.SMARH_INT_LOG_INTEGRA_DIARIA(ID,PROCEDURE_ERRO,CODIGO_ERRO,DESCRICAO_ERRO) VALUES(PONTO_ELETRONICO.ID_SEQ_LOG_PONTO.NEXTVAL,PROCEDURE_ERRO,COD_ERRO,SQL_ERRO);
COMMIT;
END;

---PROCEDURE PARA GRAVAR LOG DE SUCESSO
PROCEDURE GRAVA_SUCESSO(PROCEDURE_ERRO IN VARCHAR2,COD_ERRO IN VARCHAR2, SQL_ERRO IN VARCHAR2) AS
BEGIN
INSERT INTO PONTO_ELETRONICO.SMARH_INT_LOG_INTEGRA_DIARIA(ID,PROCEDURE_ERRO,CODIGO_ERRO,DESCRICAO_ERRO,VERIFICADO) VALUES(PONTO_ELETRONICO.ID_SEQ_LOG_PONTO.NEXTVAL,PROCEDURE_ERRO,COD_ERRO,SQL_ERRO,'S');
COMMIT;
END;



BEGIN --BEGIN GERAL

SELECT TO_DATE('01/'||EXTRACT(MONTH FROM SYSDATE)||'/'||EXTRACT(YEAR FROM SYSDATE), 'DD/MM/YYYY') PRIMEIRO_DIA INTO vDATA_INICIO FROM DUAL;

SELECT LAST_DAY(SYSDATE)ULTIMO_DIA INTO vDATA_FIM FROM DUAL;

---PARA SABER O DIA ATUAL QUE O JOB/PROCEDURE ESTA EXECUTANDO
SELECT EXTRACT(DAY FROM SYSDATE)DIA_ATUAL INTO vDIA_ATUAL FROM DUAL;

--PARA SABER ULTIMO DIA DO MES
SELECT EXTRACT(DAY FROM LAST_DAY(SYSDATE))ULTIMO_DIA_MES INTO vULTIMO_DIA_MES FROM DUAL;



IF vDIA_ATUAL = 1 THEN --------------------------------------------------------------------------------------------------------------------PRIMEIRO DIA MES
--TAREFA 1 --rodar simulador ifponto do mes
--1ª tarefa simulador_ifpontov4e5.sql>simulador_ifpontov4e5_v2.sql --_v2 em 24/8/21 para ajustes de cessoes e outros casos fora baseado email Lilian Rabelo (Conversão de Situações de ponto para contagem de tempo)-- criado em 31/5/21 para unir (simulador_ifpontov4.sql/simulador_ifpontov5.sql)com logicas semelhantes e corrigir erro nos locais de cessao
--ARTERH.PRG_SIT_PONTO_AFASTAMENTOS_ARTE
SELECT COUNT(1) INTO vQTD_REGS FROM ARTERH.RHPONT_RES_SIT_DIA where trunc(data) between to_date(sysdate)and to_date(sysdate)+31;
vLOG := 'TAREFA 1: GRAVAR SITUACAO DE PONTO PARA AFASTAMENTOS, vQTD_REGS *ANTES* DE RODAR PROCEDURE: ARTERH.PRG_SIT_PONTO_AFASTAMENTOS_ARTE, QUE GERA REGISTROS NA TABELA ARTERH.RHPONT_RES_SIT_DIA: '||vQTD_REGS;
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (CONSIDERACOES, DATA_DADOS, CAMPO_VALOR_1, CAMPO_VALOR_2)VALUES('LOG_PR_TAREFAS_DURANTE_MES', SYSDATE, vLOG, vQTD_REGS); COMMIT;
vLOG := NULL;

--/*
BEGIN 
ARTERH.PRG_SIT_PONTO_AFASTAMENTOS_ARTE(TO_DATE(vDATA_INICIO,'dd/mm/yyyy'), TO_DATE(vDATA_FIM,'dd/mm/yyyy'));
 err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('TAREFAS_DURANTE_MES PROCEDURE PRG_SIT_PONTO_AFASTAMENTOS_ARTE','000',err_msg);
exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('TAREFAS_DURANTE_MES PROCEDURE PRG_SIT_PONTO_AFASTAMENTOS_ARTE',SQLCODE,err_msg);
END;
--*/

SELECT COUNT(1) INTO vQTD_REGS FROM ARTERH.RHPONT_RES_SIT_DIA where trunc(data) between to_date(sysdate)and to_date(sysdate)+31;
vLOG := 'TAREFA 1: GRAVAR SITUACAO DE PONTO PARA AFASTAMENTOS, vQTD_REGS *APOS* DE RODAR PROCEDURE: ARTERH.PRG_SIT_PONTO_AFASTAMENTOS_ARTE, QUE GERA REGISTROS NA TABELA ARTERH.RHPONT_RES_SIT_DIA: '||vQTD_REGS;
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (CONSIDERACOES, DATA_DADOS, CAMPO_VALOR_1, CAMPO_VALOR_2)VALUES('LOG_PR_TAREFAS_DURANTE_MES', SYSDATE, vLOG, vQTD_REGS); COMMIT;
vLOG := NULL;



--TAREFA 2 --CRIAR REG APURACAO TIPO 2 PARA PBH 152123
SELECT MAX(OCORRENCIA) INTO vQTD_REGS FROM ARTERH.RHPONT_APUR_AGRUP X WHERE X.CODIGO_EMPRESA = '0001' AND X.TIPO_APUR = 'F' AND C_LIVRE_SELEC01 = 2 AND ID_AGRUP = 152123;
vLOG := 'TAREFA 5: CRIAR REG APURACAO TIPO 2 PARA PBH 152123, ULTIMA OCORRENCIA *ANTES* DE RODAR GRAVAR REGISTRO NA TABELA ARTERH.RHPONT_APUR_AGRUP: '||vQTD_REGS;
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (CONSIDERACOES, DATA_DADOS, CAMPO_VALOR_1, CAMPO_VALOR_2)VALUES('LOG_PR_TAREFAS_DURANTE_MES', SYSDATE, vLOG, vQTD_REGS); COMMIT;
vLOG := NULL;

INSERT INTO ARTERH.RHPONT_APUR_AGRUP (CODIGO_EMPRESA, TIPO_APUR, STATUS_APUR, C_LIVRE_SELEC01, C_LIVRE_DATA01, C_LIVRE_OPCAO01, LOGIN_USUARIO, DT_ULT_ALTER_USUA, TEXTO_ASSOCIADO, DATA_INI_FOLHA, DATA_FIM_FOLHA, OCORRENCIA, ID_AGRUP)
VALUES ('0001', 'F', 'C', 2, SYSDATE, 'N', 'IFPONTO', SYSDATE, 'CONTROLE DE DATA VIRADA DO MES GERADO PELA PROCEDURE ARTERH.PR_TAREFAS_DURANTE_MES', TO_DATE(vDATA_INICIO,'DD/MM/YYYY'), TO_DATE(vDATA_FIM,'DD/MM/YYYY'), (SELECT MAX(OCORRENCIA)+1 FROM ARTERH.RHPONT_APUR_AGRUP), 152123); COMMIT;

SELECT MAX(OCORRENCIA) INTO vQTD_REGS FROM ARTERH.RHPONT_APUR_AGRUP WHERE CODIGO_EMPRESA = '0001' AND TIPO_APUR = 'F' AND C_LIVRE_SELEC01 = 2 AND ID_AGRUP = 152123;
vLOG := 'TAREFA 2: CRIAR REG APURACAO TIPO 2 PARA PBH 152123, ULTIMA OCORRENCIA *APOS* DE RODAR GRAVAR REGISTRO NA TABELA ARTERH.RHPONT_APUR_AGRUP: '||vQTD_REGS;
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (CONSIDERACOES, DATA_DADOS, CAMPO_VALOR_1, CAMPO_VALOR_2)VALUES('LOG_PR_TAREFAS_DURANTE_MES', SYSDATE, vLOG, vQTD_REGS); COMMIT;
vLOG := NULL;



--TAREFA 3 correcao_sit_ponto_cessao_V3.sql 
-- TAREFA 22 FECHAMEMENTO MES
--12 passo - POR ENQUANTO ALEM DE RODAR NO SIMULADOR IFPONTO 1 VEZ POR MES RODAR NOS FECHAMENTOS TAMBEM DO IFPONTO 
-- PARA TIRAR DUPLICIDADES DE SITUAcaO DE PONTO DE CESSÃƒO devera comecar a rodar juntamente com o (simulador_ifpontov3.sql)
FOR C1 IN(
SELECT 
X2.* FROM( 
SELECT  
LEAD(X.ORDEM_PONTO_NO_DIA, 1, NULL) OVER (PARTITION BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.DATA ORDER BY X.CODIGO_SITUACAO) AS PROXIMA_ORDEM_PONTO_NO_DIA,
LEAD(X.CODIGO_SITUACAO, 1, NULL) OVER (PARTITION BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.DATA ORDER BY X.CODIGO_SITUACAO) AS PROXIMO_CODIGO_SITUACAO,
X.* FROM(
SELECT 
ROW_NUMBER() OVER (PARTITION BY D.CODIGO_EMPRESA, D.TIPO_CONTRATO, D.CODIGO_CONTRATO, D.DATA ORDER BY D.CODIGO_SITUACAO) AS ORDEM_PONTO_NO_DIA,
D.* FROM RHPONT_RES_SIT_DIA D WHERE TRUNC(D.DATA)>= TO_DATE('01/10/2019','DD/MM/YYYY') AND D.CODIGO_SITUACAO IN ('0510','0534','0552','0553')
ORDER BY D.CODIGO_EMPRESA, D.TIPO_CONTRATO, D.CODIGO_CONTRATO, D.DATA, D.CODIGO_SITUACAO DESC
)X 
)X2 WHERE X2.PROXIMA_ORDEM_PONTO_NO_DIA IS NOT NULL
) 
LOOP 
IF C1.PROXIMA_ORDEM_PONTO_NO_DIA = 2 AND C1.PROXIMO_CODIGO_SITUACAO IN ('0552','0553') AND C1.ORDEM_PONTO_NO_DIA = 1 AND C1.CODIGO_SITUACAO IN ('0510','0534') THEN   
DELETE ARTERH.RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = C1.CODIGO_EMPRESA AND TIPO_CONTRATO = C1.TIPO_CONTRATO AND CODIGO_CONTRATO = C1.CODIGO_CONTRATO AND TRUNC(DATA) = TO_DATE(C1.DATA,'DD/MM/YYYY') AND CODIGO_SITUACAO = C1.CODIGO_SITUACAO AND REF_HORAS = C1.REF_HORAS AND TIPO_APURACAO = C1.TIPO_APURACAO AND TRUNC(DT_ULT_ALTER_USUA) = TO_DATE(C1.DT_ULT_ALTER_USUA ,'DD/MM/YYYY') AND LOGIN_USUARIO = C1.LOGIN_USUARIO; COMMIT;
END IF;
END LOOP;

vLOG := 'TAREFA 3 EXECUTADA COM SUCESSO, PARA TIRAR DUPLICIDADES DE SITUACAO DE PONTO DE CESSAO.';
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (CONSIDERACOES, DATA_DADOS, CAMPO_VALOR_1, CAMPO_VALOR_2)VALUES('LOG_PR_TAREFAS_DURANTE_MES', SYSDATE, vLOG, vQTD_REGS); COMMIT;
vLOG := NULL;



--TAREFA 4
-- TAREFA 29 PR_PONTO_FECHAMENTO_MES_P1
--58ª tarefa --em 4/6/21 kellyson 
--para deixar de usar a view que esta causando possivel lentidão nas integrações diarias do Ifponto e outros processos como arquivo da TEG
--deve rodar toda fez que fazer o fechamento Ifponto no dia 11 dos meses e no primeiro dia do mes quando usar o simulador_ifponto
--sql_insert_tabela_SUGESP_DATA_APURACAO_FREQUENC.sql>sql_insert_tabela_SUGESP_DATA_APURACAO_FREQUENC_v2.sql --v2 novo em 26/8/21
SELECT count(1) INTO vQTD_REGS FROM ARTERH.SUGESP_DATA_APURACAO_FREQUENC;
vLOG := 'TAREFA 4 ANTES ATUALIZAR DATAS ' ||vQTD_REGS|| ' REGISTROS NA TABELA ARTERH.SUGESP_DATA_APURACAO_FREQUENC.';
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST  (CONSIDERACOES, DATA_DADOS, CAMPO_VALOR_1, CAMPO_VALOR_2)VALUES('LOG_PR_TAREFAS_DURANTE_MES', SYSDATE, vLOG, vQTD_REGS);COMMIT;
vLOG := NULL;

--1º LIMPA A TABELA PARA POPULAR LOGO EM SEGUIDA COM A LOGICA ABAIXO
DELETE ARTERH.SUGESP_DATA_APURACAO_FREQUENC; COMMIT;

FOR C1 IN(
SELECT IFP.DT_ULT_FECHAMENTO_IFPONTO, (SELECT MAX(x.data_fim_folha)from RHPONT_APUR_AGRUP x where x.codigo_empresa = '0001' and x.tipo_apur = 'F' AND c_livre_selec01 = 2 AND id_agrup = 152123)FECHAMENTO_GERAL,
A.ID_AGRUP, A.nivel_agrup_estrut, A.CODIGO_EMPRESA, 'G' TIPO_AGRUP,  A.COD_CGERENC1 COD_AGRUP1, A.COD_CGERENC2 COD_AGRUP2, A.COD_CGERENC3 COD_AGRUP3, A.COD_CGERENC4 COD_AGRUP4, A.COD_CGERENC5 COD_AGRUP5, A.COD_CGERENC6 COD_AGRUP6,
A.DESCRICAO, A.ABREVIACAO, A.CGC, A.RAZAO_SOCIAL, A.DATA_EXTINCAO
FROM ARTERH.RHORGA_CUSTO_GEREN A LEFT OUTER JOIN
(SELECT LPAD(SUBSTR(CODIGO,1,2),4,0)EMPRESA, LPAD(SUBSTR(CODIGO,4,6),6,0)COD1, LPAD(SUBSTR(CODIGO,11,6),6,0)COD2, LPAD(SUBSTR(CODIGO,18,6),6,0)COD3, LPAD(SUBSTR(CODIGO,25,6),6,0)COD4, LPAD(SUBSTR(CODIGO,32,6),6,0)COD5, LPAD(SUBSTR(CODIGO,39,6),6,0)COD6
,(SELECT MAX(TRUNC(DATA_FIM)) FROM PONTO_ELETRONICO.IFPONTO_FECHAMENTO)DT_ULT_FECHAMENTO_IFPONTO
,(SELECT MAX(x.data_fim_folha)from RHPONT_APUR_AGRUP x where x.codigo_empresa = '0001' and x.tipo_apur = 'F' AND c_livre_selec01 = 2 AND id_agrup = 152123)FECHAMENTO_GERAL
FROM PONTO_ELETRONICO.IFPONTO_FECHAMENTO WHERE TRUNC(DT_SAIU_ARTE) = (SELECT MAX(TRUNC(DT_SAIU_ARTE)) FROM PONTO_ELETRONICO.IFPONTO_FECHAMENTO) )IFP
ON IFP.EMPRESA = A.CODIGO_EMPRESA AND IFP.COD1 =A.COD_CGERENC1 AND IFP.COD2 = A.COD_CGERENC2 AND IFP.COD3 = A.COD_CGERENC3 AND IFP.COD4 = A.COD_CGERENC4 AND IFP.COD5 = A.COD_CGERENC5 AND IFP.COD6 = A.COD_CGERENC6
ORDER BY A.CODIGO_EMPRESA, A.COD_CGERENC1, A.COD_CGERENC2, A.COD_CGERENC3, A.COD_CGERENC4, A.COD_CGERENC5, A.COD_CGERENC6
)LOOP
IF C1.DT_ULT_FECHAMENTO_IFPONTO IS NOT NULL THEN
INSERT INTO ARTERH.SUGESP_DATA_APURACAO_FREQUENC
(FECHAMENTO_AGRUPADOR, FECHAMENTO_GERAL, ID_AGRUP,  ORDEM_ESTRUT, CODIGO_EMPRESA, TIPO_AGRUP, COD_AGRUP1, COD_AGRUP2, COD_AGRUP3, COD_AGRUP4, COD_AGRUP5, COD_AGRUP6, DESCRICAO, ABREVIACAO, CGC, RAZAO_SOCIAL, DATA_EXTINCAO)
VALUES(C1.DT_ULT_FECHAMENTO_IFPONTO, C1.FECHAMENTO_GERAL, C1.ID_AGRUP, C1.nivel_agrup_estrut, C1.CODIGO_EMPRESA, C1.TIPO_AGRUP, C1.COD_AGRUP1, C1.COD_AGRUP2, C1.COD_AGRUP3, C1.COD_AGRUP4, C1.COD_AGRUP5, C1.COD_AGRUP6, C1.DESCRICAO, C1.ABREVIACAO, C1.CGC, C1.RAZAO_SOCIAL, C1.DATA_EXTINCAO);COMMIT;
ELSE
INSERT INTO ARTERH.SUGESP_DATA_APURACAO_FREQUENC
(FECHAMENTO_AGRUPADOR, FECHAMENTO_GERAL, ID_AGRUP,  ORDEM_ESTRUT, CODIGO_EMPRESA, TIPO_AGRUP, COD_AGRUP1, COD_AGRUP2, COD_AGRUP3, COD_AGRUP4, COD_AGRUP5, COD_AGRUP6, DESCRICAO, ABREVIACAO, CGC, RAZAO_SOCIAL, DATA_EXTINCAO)
VALUES(NULL, C1.FECHAMENTO_GERAL, C1.ID_AGRUP, C1.nivel_agrup_estrut, C1.CODIGO_EMPRESA, C1.TIPO_AGRUP, C1.COD_AGRUP1, C1.COD_AGRUP2, C1.COD_AGRUP3, C1.COD_AGRUP4, C1.COD_AGRUP5, C1.COD_AGRUP6, C1.DESCRICAO, C1.ABREVIACAO, C1.CGC, C1.RAZAO_SOCIAL, C1.DATA_EXTINCAO);COMMIT;
END IF;
END LOOP;

FOR C1 IN (
--EM 2/9/21 TIRAR DUPLICIDADES, tem que rodar o script abaixo 
select 
'delete SUGESP_DATA_APURACAO_FREQUENC where rowid = '''||x3.rowid||''';' comando,
x3.* from (
select 
rowid, row_number () over(partition by d.id_agrup order by d.id_agrup) ordem_id,
d.* FROM ARTERH.SUGESP_DATA_APURACAO_FREQUENC d where exists (
select x2.* from (SELECT x.CODIGO_EMPRESA, x.COD_AGRUP1, x.COD_AGRUP2, x.COD_AGRUP3, x.COD_AGRUP4, x.COD_AGRUP5, x.COD_AGRUP6, COUNT(1)QUANT FROM ARTERH.SUGESP_DATA_APURACAO_FREQUENC X 
group by  x.CODIGO_EMPRESA, x.COD_AGRUP1, x.COD_AGRUP2, x.COD_AGRUP3, x.COD_AGRUP4, x.COD_AGRUP5, x.COD_AGRUP6 HAVING COUNT(1)>1
)x2 where x2.CODIGO_EMPRESA = d.CODIGO_EMPRESA and x2.COD_AGRUP1 = d.COD_AGRUP1 and x2.COD_AGRUP2 = d.COD_AGRUP2 and x2.COD_AGRUP3 = d.COD_AGRUP3 and x2.COD_AGRUP4 = d.COD_AGRUP4 and x2.COD_AGRUP5 = d.COD_AGRUP5 and x2.COD_AGRUP6 = d.COD_AGRUP6
)order by d.id_agrup
)x3 where x3.ordem_id >1
) LOOP
DELETE ARTERH.SUGESP_DATA_APURACAO_FREQUENC where rowid = C1.rowid;COMMIT;
END LOOP;

SELECT count(1) INTO vQTD_REGS FROM ARTERH.SUGESP_DATA_APURACAO_FREQUENC;
vLOG := 'TAREFA 4 DEPOIS ATUALIZAR DATAS ' ||vQTD_REGS|| ' REGISTROS NA TABELA ARTERH.SUGESP_DATA_APURACAO_FREQUENC.';
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (CONSIDERACOES, DATA_DADOS, CAMPO_VALOR_1, CAMPO_VALOR_2)VALUES('LOG_PR_TAREFAS_DURANTE_MES', SYSDATE, vLOG, vQTD_REGS);COMMIT;
vLOG := NULL;



--TAREFA 5-- enviar relatorio mensal TEG
--publico atendimento pericia PROCEDURE_FOTO_MENSAL_antigo.sql --ARTERH.PRR_PUBLICO_TEG_MENSAL
--/*
BEGIN 
ARTERH.PRR_PUBLICO_TEG_MENSAL;
 err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('TAREFAS_DURANTE_MES PROCEDURE ARTERH.PRR_PUBLICO_TEG_MENSAL','000',err_msg);
exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('TAREFAS_DURANTE_MES PROCEDURE ARTERH.PRR_PUBLICO_TEG_MENSALL',SQLCODE,err_msg);
END;
--*/
SELECT count(1) INTO vQTD_REGS FROM ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST  WHERE TRUNC(DATA_DADOS) = TRUNC(SYSDATE) AND CAMPO_VALOR_1 = 'PRR_PUBLICO_TEG_MENSAL';
vLOG := 'TAREFA 5 EXECUTADA COM SUCESSO RELATORIO PROCEDURE ARTERH.PRR_PUBLICO_TEG_MENSAL, GERANDO '||vQTD_REGS|| ' REGISTROS.';
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (CONSIDERACOES, DATA_DADOS, CAMPO_VALOR_1, CAMPO_VALOR_2)VALUES('LOG_PR_TAREFAS_DURANTE_MES', SYSDATE, vLOG, vQTD_REGS); COMMIT;
vLOG := NULL;



-- TAREFA 6 --rodar 3 sql para enviar relatorio GETED sobre 1017
--sql_log_ferias_1017v3.sql -- NAO FAZER
--sql_par_bms_1017v3.sql
FOR C1 IN (
--insert para gravar tabela ---
SELECT 
'INSERT INTO SUGESP_AJUSTE_LOTE_CAMPO_HIST (DATA_DADOS, CONSIDERACOES, CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, CAMPO_VALOR_1, CAMPO_VALOR_2, CAMPO_VALOR_3, CAMPO_VALOR_4) VALUES (SYSDATE,''sql_par_bms_1017v3.sql'',''' || X3.CODIGO_EMPRESA ||''','''|| X3.TIPO_CONTRATO ||''','''|| X3.CODIGO ||''','''|| X3.CODIGO_PESSOA ||''','''|| X3.NOME ||''','''|| X3.COD_SIT_FUNCIONAL ||''','''|| X3.DATA_INIC_SITUACAO||''');'  AS COMANDO,
X3.* FROM(
SELECT  
USF.COD_SIT_FUNCIONAL,USF.DATA_INIC_SITUACAO, 
X2.* FROM( 
--INICIO REVISANDO EM 11/8/22
SELECT  
ROW_NUMBER() OVER(PARTITION BY X.CODIGO_EMPRESA,X.CODIGO_PESSOA ORDER BY X.TIPO_CONTRATO, X.CODIGO)ORDEM_PESSOA, 
X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO, X.CODIGO_PESSOA, X.NOME, X.SITUACAO_FUNCIONAL, X.DATA_ADMISSAO, X.cod_cargo_efetivo, CE.DESCRICAO CARGO_EFETIVO, X.cod_cargo_comiss, C.DESCRICAO CARGO_COMISSIONADO 
,GN.COD_CGERENC1, GN.COD_CGERENC2, GN.COD_CGERENC3, GN.COD_CGERENC4, GN.COD_CGERENC5, GN.COD_CGERENC6, GN.DESCRICAO LOCAL 
FROM  RHPESS_CONTRATO X 
LEFT OUTER JOIN RHORGA_CUSTO_GEREN GN ON X.CODIGO_EMPRESA = GN.CODIGO_EMPRESA AND X.COD_CUSTO_GERENC1 = GN.cod_cgerenc1 AND X.COD_CUSTO_GERENC2 = GN.cod_cgerenc2 AND X.COD_CUSTO_GERENC3 = GN.cod_cgerenc3 
AND X.COD_CUSTO_GERENC4 = GN.cod_cgerenc4 AND X.COD_CUSTO_GERENC5 = GN.cod_cgerenc5 AND X.COD_CUSTO_GERENC6 = GN.cod_cgerenc6 
left outer join RHPLCS_CARGO C ON c.CODIGO_EMPRESA = X.CODIGO_EMPRESA AND c.CODIGO = X.cod_cargo_comiss 
left outer join RHPLCS_CARGO CE ON Ce.CODIGO_EMPRESA = X.CODIGO_EMPRESA AND Ce.CODIGO = X.cod_cargo_efetivo 
WHERE X.ANO_MES_REFERENCIA = (SELECT MAX(AUX.ANO_MES_REFERENCIA) FROM RHPESS_CONTRATO AUX  WHERE AUX.CODIGO_EMPRESA = X.CODIGO_EMPRESA AND AUX.TIPO_CONTRATO = X.TIPO_CONTRATO AND AUX.CODIGO = X.CODIGO)  
 AND X.DATA_RESCISAO IS NULL 
AND EXISTS 
( 
--INICIO NOVO EM 11/8/22
SELECT A.CODIGO_EMPRESA, A.TIPO_CONTRATO, A.CODIGO, A.CODIGO_PESSOA, COUNT(1)QTD_REG_BM FROM(
SELECT 
ROW_NUMBER() OVER(PARTITION BY A.CODIGO_EMPRESA, A.TIPO_CONTRATO, A.CODIGO ORDER BY A.CODIGO_EMPRESA, A.TIPO_CONTRATO, A.CODIGO, A.DATA_INIC_SITUACAO)ORDEM_BM,
M.CODIGO_PESSOA, A.*
FROM RHCGED_ALT_SIT_FUN A 
LEFT OUTER JOIN RHPESS_CONTR_MEST M ON M.CODIGO_EMPRESA = A.CODIGO_EMPRESA AND M.TIPO_CONTRATO = A.TIPO_CONTRATO AND M.CODIGO_CONTRATO = A.CODIGO
WHERE A.CODIGO_EMPRESA = '0001' AND A.COD_SIT_FUNCIONAL = '1017' 
AND(
    TRUNC(A.DATA_INIC_SITUACAO)BETWEEN TO_DATE('01/10/2019','DD/MM/YYYY')AND TO_DATE(vDATA_INICIO,'DD/MM/YYYY')-1 -------------------------------------------trocar data, SEMPRE AUMENTAR A DATA FIM PARA O ULTIMO DIA DO MES SEGUINTE AO QUE FOI GERADO ANTERIORMENTE
    OR TRUNC(A.DATA_FIM_SITUACAO)BETWEEN TO_DATE('01/10/2019','DD/MM/YYYY')AND TO_DATE(vDATA_INICIO,'DD/MM/YYYY')-1-------------------------------------------trocar data, SEMPRE AUMENTAR A DATA FIM PARA O ULTIMO DIA DO MES SEGUINTE AO QUE FOI GERADO ANTERIORMENTE
    OR A.DATA_FIM_SITUACAO IS NULL
    )
ORDER BY A.CODIGO_EMPRESA, A.TIPO_CONTRATO, A.CODIGO, A.DATA_INIC_SITUACAO   
)A 
WHERE A.CODIGO_EMPRESA = X.CODIGO_EMPRESA AND A.CODIGO_PESSOA = X.CODIGO_PESSOA 
GROUP BY A.CODIGO_EMPRESA, A.TIPO_CONTRATO, A.CODIGO, A.CODIGO_PESSOA --ORDER BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO
--FIM NOVO EM 11/8/22
 --AND A.CODIGO_EMPRESA = X.CODIGO_EMPRESA AND A.CODIGO_PESSOA = X.CODIGO_PESSOA 
 ) 
ORDER BY X.CODIGO_EMPRESA, X.CODIGO_PESSOA, X.TIPO_CONTRATO, X.CODIGO 
--FIM REVISANDO EM 11/8/22
)X2 
LEFT OUTER JOIN  
(    SELECT A.* FROM RHCGED_ALT_SIT_FUN A 
    WHERE  A.DATA_INIC_SITUACAO = (SELECT MAX(AUX.DATA_INIC_SITUACAO)FROM RHCGED_ALT_SIT_FUN AUX 
                                WHERE  A.CODIGO_EMPRESA = AUX.CODIGO_EMPRESA AND A.TIPO_CONTRATO = AUX.TIPO_CONTRATO AND A.CODIGO = AUX.CODIGO) 
)USF ON USF.CODIGO_EMPRESA = X2.CODIGO_EMPRESA AND USF.TIPO_CONTRATO = X2.TIPO_CONTRATO AND USF.CODIGO = X2.CODIGO
)X3

)LOOP
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (DATA_DADOS, CONSIDERACOES, CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, CAMPO_VALOR_1, CAMPO_VALOR_2, CAMPO_VALOR_3, CAMPO_VALOR_4)
VALUES (SYSDATE,'sql_par_bms_1017v3.sql', C1.CODIGO_EMPRESA, C1.TIPO_CONTRATO, C1.CODIGO, C1.CODIGO_PESSOA, C1.NOME, C1.COD_SIT_FUNCIONAL, C1.DATA_INIC_SITUACAO);COMMIT;
END LOOP;

--para saber quais sao os bms, registros gravados com o comando abaixo
SELECT COUNT(1) INTO vQTD_REGS FROM ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST WHERE CONSIDERACOES = 'sql_par_bms_1017v3.sql' AND TRUNC(DATA_DADOS) =TRUNC(SYSDATE);
vLOG := 'TAREFA 6: PARA ENVIAR RELATORIO GETED SOBRE 1017, QUANTIDADE DE BMS NA SITUACAO FUNCIONAL 1017: '||vQTD_REGS;
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (CONSIDERACOES, DATA_DADOS, CAMPO_VALOR_1, CAMPO_VALOR_2)VALUES('LOG_PR_TAREFAS_DURANTE_MES', SYSDATE, vLOG, vQTD_REGS); COMMIT;
vLOG := NULL;

--sql_log_alt_sit_func_1017v3.sql
FOR C1 IN (
SELECT 'CPF|NO_PERIODO_DA_1017|CODIGO_EMPRESA|CODIGO_PESSOA|NOME|CONTRATO_1017|INICIO_1017|BM_DIF_1017|COD_SIT_FUNCIONAL|SIT_FUNCIONAL|DATA_INIC_SITUACAO|DATA_FIM_SITUACAO|QTD_REG' 
AS LINHA FROM DUAL 
UNION ALL
SELECT P.CPF||'|'||X3.LINHA AS LINHA FROM (
SELECT 
X2.NO_PERIODO_DA_1017||'|'||X2.CODIGO_EMPRESA||'|'||X2.CODIGO_PESSOA||'|'||X2.NOME||'|'||X2.CONTRATO_1017||'|'||X2.INICIO_1017||'|'||X2.BM_DIF_1017||'|'||X2.COD_SIT_FUNCIONAL||'|'||X2.SIT_FUNCIONAL||'|'||X2.DATA_INIC_SITUACAO||'|'||X2.DATA_FIM_SITUACAO||'|'||X2.QTD_REG
AS LINHA
,X2.*
FROM (
SELECT X.NO_PERIODO_DA_1017, X.CODIGO_EMPRESA, X.CODIGO_PESSOA, X.NOME, X.CONTRATO_1017, X.INICIO_1017, X.BM_DIF_1017,  X.COD_SIT_FUNCIONAL, X.SIT_FUNCIONAL, X.DATA_INIC_SITUACAO, X.DATA_FIM_SITUACAO, COUNT(1)QTD_REG FROM(
SELECT 
CASE WHEN H.DATA_INIC_SITUACAO >= BM1017.DATA_INIC_SITUACAO THEN 'SIM' ELSE 'NAO' END NO_PERIODO_DA_1017,
BM1017.CODIGO_EMPRESA, BM1017.CODIGO_PESSOA, BM1017.NOME, BM1017.CODIGO_CONTRATO CONTRATO_1017, BM1017.DATA_INIC_SITUACAO INICIO_1017, DIF1017.CODIGO_CONTRATO BM_DIF_1017, H.CODIGO, H.COD_SIT_FUNCIONAL, H.SIT_FUNCIONAL, H.DATA_INIC_SITUACAO, H.DATA_FIM_SITUACAO
FROM(
SELECT 
MX.CODIGO_PESSOA, -- MX.NOME_COMPOSTO, 
AX.CODIGO_EMPRESA, AX.TIPO_CONTRATO, AX.CODIGO, AX.COD_SIT_FUNCIONAL, S.DESCRICAO SIT_FUNCIONAL, AX.DATA_INIC_SITUACAO,  AX.DATA_FIM_SITUACAO--, AX.LOGIN_USUARIO, AX.DT_ULT_ALTER_USUA 
FROM RHCGED_ALT_SIT_FUN AX 
LEFT OUTER JOIN RHPARM_SIT_FUNC S ON S.CODIGO = AX.COD_SIT_FUNCIONAL
LEFT OUTER JOIN RHPESS_CONTR_MEST MX ON MX.CODIGO_EMPRESA = AX.CODIGO_EMPRESA AND MX.TIPO_CONTRATO = AX.TIPO_CONTRATO AND MX.CODIGO_CONTRATO = AX.CODIGO
WHERE 
S.CONTROLE_FOLHA = 'L' AND
AX.CODIGO_EMPRESA = '0001' AND MX.CODIGO_PESSOA IN 
--INICIO-- ACHAR OS REGISTROS ALTERADOS NA ALT SIT FUNC EM UM PERIODO ENTRE OS 2 BMS DA 1017
(
SELECT A2.CODIGO_PESSOA FROM(
SELECT A.CODIGO_EMPRESA, A.TIPO_CONTRATO, A.CODIGO, M.CODIGO_PESSOA, COUNT(1)QTD FROM RHCGED_ALT_SIT_FUN A 
LEFT OUTER JOIN RHPESS_CONTR_MEST M ON M.CODIGO_EMPRESA = A.CODIGO_EMPRESA AND M.TIPO_CONTRATO = A.TIPO_CONTRATO AND M.CODIGO_CONTRATO = A.CODIGO
WHERE A.CODIGO_EMPRESA = '0001' AND A.TIPO_CONTRATO = '0001' 
AND A.CODIGO IN 
    (SELECT CODIGO_CONTRATO FROM SUGESP_AJUSTE_LOTE_CAMPO_HIST WHERE CONSIDERACOES = 'sql_par_bms_1017v3.sql' AND TRUNC(DATA_DADOS) = TRUNC(SYSDATE) ) -------------------------------------------trocar data
                        AND TRUNC(A.DT_ULT_ALTER_USUA) BETWEEN TO_DATE(vDATA_INICIO,'DD/MM/YYYY')-32 AND TO_DATE(vDATA_INICIO,'DD/MM/YYYY')-1 -------------------------------------------trocar data
GROUP BY A.CODIGO_EMPRESA, A.TIPO_CONTRATO, A.CODIGO, M.CODIGO_PESSOA --ORDER BY COUNT(1)DESC
)A2
)--FIM--ACHAR OS REGISTROS ALTERADOS NA ALT SIT FUNC EM UM PERIODO ENTRE OS 2 BMS DA 1017
ORDER BY MX.CODIGO_PESSOA, AX.DATA_INIC_SITUACAO, AX.CODIGO
)H
LEFT OUTER JOIN(
--para saber quais sao os bms, registros gravados com o comando abaixo
SELECT DATA_DADOS, CONSIDERACOES, CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, CAMPO_VALOR_1 CODIGO_PESSOA , CAMPO_VALOR_2 NOME , CAMPO_VALOR_3 COD_SIT_FUNCIONAL , CAMPO_VALOR_4 DATA_INIC_SITUACAO FROM SUGESP_AJUSTE_LOTE_CAMPO_HIST 
                                    WHERE CONSIDERACOES = 'sql_par_bms_1017v3.sql' AND TRUNC(DATA_DADOS) = TRUNC(SYSDATE)-------------------------------------------trocar data
)BM1017 ON BM1017.CODIGO_EMPRESA = H.CODIGO_EMPRESA AND BM1017.TIPO_CONTRATO = H.TIPO_CONTRATO AND BM1017.CODIGO_PESSOA = H.CODIGO_PESSOA AND BM1017.COD_SIT_FUNCIONAL = '1017'--AND BM1017.CODIGO_CONTRATO = H.CODIGO
--WHERE (H.DATA_INIC_SITUACAO >= BM1017.DATA_INIC_SITUACAO OR (H.DATA_INIC_SITUACAO < BM1017.DATA_INIC_SITUACAO AND H.DATA_FIM_SITUACAO IS NULL))
LEFT OUTER JOIN(
SELECT DATA_DADOS, CONSIDERACOES, CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, CAMPO_VALOR_1 CODIGO_PESSOA , CAMPO_VALOR_2 NOME , CAMPO_VALOR_3 COD_SIT_FUNCIONAL , CAMPO_VALOR_4 DATA_INIC_SITUACAO FROM SUGESP_AJUSTE_LOTE_CAMPO_HIST 
                                    WHERE CONSIDERACOES = 'sql_par_bms_1017v3.sql' AND TRUNC(DATA_DADOS) = TRUNC(SYSDATE)-------------------------------------------trocar data
)DIF1017 ON DIF1017.CODIGO_EMPRESA = H.CODIGO_EMPRESA AND DIF1017.TIPO_CONTRATO = H.TIPO_CONTRATO AND DIF1017.CODIGO_PESSOA = H.CODIGO_PESSOA AND DIF1017.COD_SIT_FUNCIONAL <> '1017'--AND DIF1017.CODIGO_CONTRATO = H.CODIGO
)X 
WHERE X.NO_PERIODO_DA_1017 = 'SIM'
GROUP BY X.NO_PERIODO_DA_1017, X.CODIGO_EMPRESA, X.CODIGO_PESSOA, X.NOME, X.CONTRATO_1017, X.INICIO_1017, X.BM_DIF_1017, X.COD_SIT_FUNCIONAL, X.SIT_FUNCIONAL, X.DATA_INIC_SITUACAO, X.DATA_FIM_SITUACAO
ORDER BY X.NO_PERIODO_DA_1017, X.CODIGO_EMPRESA, X.CODIGO_PESSOA, X.NOME, X.CONTRATO_1017, X.INICIO_1017, X.BM_DIF_1017, X.COD_SIT_FUNCIONAL, X.SIT_FUNCIONAL, X.DATA_INIC_SITUACAO, X.DATA_FIM_SITUACAO
)X2
)X3 LEFT OUTER JOIN RHPESS_PESSOA P ON P.CODIGO_EMPRESA = X3.CODIGO_EMPRESA AND P.CODIGO = X3.CODIGO_PESSOA

)LOOP
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (DATA_DADOS, CAMPO_VALOR_1, CONSIDERACOES)VALUES(SYSDATE,'sql_log_alt_sit_func_1017v3.sql',C1.LINHA);COMMIT;
END LOOP;

SELECT COUNT(1) INTO vQTD_REGS FROM ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST WHERE CAMPO_VALOR_1 = 'sql_log_alt_sit_func_1017v3.sql' AND TRUNC(DATA_DADOS) =TRUNC(SYSDATE);
vLOG := 'TAREFA 6: PARA ENVIAR RELATORIO GETED SOBRE 1017, QUANTIDADE DE REGISTROS GERADOS PARA CONFERIR NA SITUACAO FUNCIONAL 1017: '||vQTD_REGS;
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (CONSIDERACOES, DATA_DADOS, CAMPO_VALOR_1, CAMPO_VALOR_2)VALUES('LOG_PR_TAREFAS_DURANTE_MES', SYSDATE, vLOG, vQTD_REGS); COMMIT;
vLOG := NULL;



--TAREFA 7 --relatorio pessoas SMED Ifractal
--analitico
FOR C1 IN (
SELECT 'NOME|CODIGO_EMPRESA|CODIGO_CONTRATO|PIS_PASEP|CPF|IDENTIDADE|COD_UNIDADE1|COD_UNIDADE2|COD_UNIDADE3|COD_UNIDADE4|COD_UNIDADE5|COD_UNIDADE6|DESCRICAO_UNIDADE|TIPO_USUARIO|REGISTRO_PONTO|SITUACAO_FUNCIONAL|DATA_ADMISSAO|DATA_RESCISAO|CODIGO_ESCALA|DT_ULT_ESCALA|CODIGO_EMPRESA_GESTOR|CONTRATO_GESTOR|TIPO|DT_SAIU_ARTE|INTEGRADO|CPF_GESTOR|TIPO_PESSOA|COD_CARGO_EFETIVO|COD_CARGO_COMISS|CODIGO_FUNCAO|E_GESTOR|ENTIDADE|CARGO_EFETIVO|CARGO_COMISSIONADO|FUNCAO_PUBLICA|APELIDO|TIPO_CONTRATO|TIPO_CONTRATO_GESTOR|NOME_SIT_FUNC|CONTROLE_FOLHA|VINCULO|CODIGO_PESSOA|CODIGO_LEGADO|E_AFASTAMENTO|SUSPENDE_REMUNERA|TEM_CARGO_EFETIVO|CHAVE_INTEGRACAO|EMPRESA_HIERARQUIA|DIA_COMECO_CICLO|EXCECAO_FUNCIONAL' 
AS LINHA FROM DUAL 
UNION ALL
SELECT 
X.NOME||'|'||X.CODIGO_EMPRESA||'|'||X.CODIGO_CONTRATO||'|'||X.PIS_PASEP||'|'||X.CPF||'|'||X.IDENTIDADE||'|'||X.COD_UNIDADE1||'|'||X.COD_UNIDADE2||'|'||X.COD_UNIDADE3||'|'||X.COD_UNIDADE4||'|'||X.COD_UNIDADE5||'|'||X.COD_UNIDADE6||'|'||X.DESCRICAO_UNIDADE||'|'||X.TIPO_USUARIO||'|'||X.REGISTRO_PONTO||'|'||X.SITUACAO_FUNCIONAL||'|'||X.DATA_ADMISSAO||'|'||X.DATA_RESCISAO||'|'||X.CODIGO_ESCALA||'|'||X.DT_ULT_ESCALA||'|'||X.CODIGO_EMPRESA_GESTOR||'|'||X.CONTRATO_GESTOR||'|'||X.TIPO||'|'||X.DT_SAIU_ARTE||'|'||X.INTEGRADO||'|'||X.CPF_GESTOR||'|'||X.TIPO_PESSOA||'|'||X.COD_CARGO_EFETIVO||'|'||X.COD_CARGO_COMISS||'|'||X.CODIGO_FUNCAO||'|'||X.E_GESTOR||'|'||X.ENTIDADE||'|'||X.CARGO_EFETIVO||'|'||X.CARGO_COMISSIONADO||'|'||X.FUNCAO_PUBLICA||'|'||X.APELIDO||'|'||X.TIPO_CONTRATO||'|'||X.TIPO_CONTRATO_GESTOR||'|'||X.NOME_SIT_FUNC||'|'||X.CONTROLE_FOLHA||'|'||X.VINCULO||'|'||X.CODIGO_PESSOA||'|'||X.CODIGO_LEGADO||'|'||X.E_AFASTAMENTO||'|'||X.SUSPENDE_REMUNERA||'|'||X.TEM_CARGO_EFETIVO||'|'||X.CHAVE_INTEGRACAO||'|'||X.EMPRESA_HIERARQUIA||'|'||X.DIA_COMECO_CICLO||'|'||X.EXCECAO_FUNCIONAL
AS LINHA
FROM(
SELECT 
*
--COUNT(1)qtd, codigo_empresa,cod_unidade1||'.'||cod_unidade2||'.'||cod_unidade3||'.'||cod_unidade4|| '.'||cod_unidade5||'.'||cod_unidade6||'-'||descricao_unidade AS unidade --sintetico
FROM
ponto_eletronico.sugesp_bi_1contrat_intif_arte
WHERE trunc(dt_saiu_arte)= trunc(sysdate)---------------------------------------------trocar data
AND CODIGO_EMPRESA='0001'
and  cod_unidade1 = '000094'
and (data_rescisao is null or trunc(data_rescisao) > to_date(vDATA_INICIO,'dd/mm/yyyy')---------------------------------------------trocar data
)
--GROUP BY codigo_empresa,cod_unidade1||'.'||cod_unidade2||'.'||cod_unidade3||'.'||cod_unidade4||'.'||cod_unidade5||'.'||cod_unidade6||'-'||descricao_unidade --sintetico
order by codigo_empresa,cod_unidade1||'.'||cod_unidade2||'.'||cod_unidade3||'.'||cod_unidade4||'.'||cod_unidade5||'.'||cod_unidade6||'-'||descricao_unidade
)X

)LOOP
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (DATA_DADOS, CAMPO_VALOR_1, CONSIDERACOES)VALUES(SYSDATE,'IFPONTO_PESSOAS_SMED_ANALITICO',C1.LINHA);COMMIT;
END LOOP;

SELECT COUNT(1) INTO vQTD_REGS FROM ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST WHERE CAMPO_VALOR_1 = 'IFPONTO_PESSOAS_SMED_ANALITICO' AND TRUNC(DATA_DADOS) =TRUNC(SYSDATE);
vLOG := 'TAREFA 7: PARA ENVIAR RELATORIO IFPONTO_PESSOAS_SMED_ANALITICO, QUANTIDADE DE REGISTROS GERADOS: '||vQTD_REGS;
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (CONSIDERACOES, DATA_DADOS, CAMPO_VALOR_1, CAMPO_VALOR_2)VALUES('LOG_PR_TAREFAS_DURANTE_MES', SYSDATE, vLOG, vQTD_REGS); COMMIT;
vLOG := NULL;

--sintetico
FOR C1 IN (
SELECT 'QTD|UNIDADE' 
AS LINHA FROM DUAL 
UNION ALL
SELECT 
X.QTD||'|'||X.UNIDADE
AS LINHA
FROM(
SELECT 
COUNT(1)qtd, codigo_empresa,cod_unidade1||'.'||cod_unidade2||'.'||cod_unidade3||'.'||cod_unidade4|| '.'||cod_unidade5||'.'||cod_unidade6||'-'||descricao_unidade AS unidade --sintetico
FROM
ponto_eletronico.sugesp_bi_1contrat_intif_arte
WHERE trunc(dt_saiu_arte)= trunc(sysdate)---------------------------------------------trocar data
AND CODIGO_EMPRESA='0001'
and  cod_unidade1 = '000094'
and (data_rescisao is null or trunc(data_rescisao) > to_date(vDATA_INICIO,'dd/mm/yyyy')---------------------------------------------trocar data
)
GROUP BY codigo_empresa,cod_unidade1||'.'||cod_unidade2||'.'||cod_unidade3||'.'||cod_unidade4||'.'||cod_unidade5||'.'||cod_unidade6||'-'||descricao_unidade --sintetico
order by codigo_empresa,cod_unidade1||'.'||cod_unidade2||'.'||cod_unidade3||'.'||cod_unidade4||'.'||cod_unidade5||'.'||cod_unidade6||'-'||descricao_unidade
)X

)LOOP
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (DATA_DADOS, CAMPO_VALOR_1, CONSIDERACOES)VALUES(SYSDATE,'IFPONTO_PESSOAS_SMED_SINTETICO',C1.LINHA);COMMIT;
END LOOP;

SELECT COUNT(1) INTO vQTD_REGS FROM ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST WHERE CAMPO_VALOR_1 = 'IFPONTO_PESSOAS_SMED_SINTETICO' AND TRUNC(DATA_DADOS) =TRUNC(SYSDATE);
vLOG := 'TAREFA 7: PARA ENVIAR RELATORIO IFPONTO_PESSOAS_SMED_SINTETICO, QUANTIDADE DE REGISTROS GERADOS: '||vQTD_REGS;
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (CONSIDERACOES, DATA_DADOS, CAMPO_VALOR_1, CAMPO_VALOR_2)VALUES('LOG_PR_TAREFAS_DURANTE_MES', SYSDATE, vLOG, vQTD_REGS); COMMIT;
vLOG := NULL;



-- TAREFA 8 --Re: Recesso Estagiário
--em 1/12/22 rodar mensalmente no dia 1
--em 27/10/22 --atualizar passivo devido email (Re: Recesso Estagiário)
--executar 1_ajuste_hist_recesso_estagio_2022.sql > PR_GERA_RECESSO_ESTAGIO
SELECT COUNT(1) INTO vQTD_REGS FROM ARTERH.RHPESS_CONTRATO C LEFT OUTER JOIN rhpess_info_estagio I ON C.CODIGO_EMPRESA = I.CODIGO_EMPRESA AND C.TIPO_CONTRATO = I.TIPO_CONTRATO AND C.CODIGO = I.CODIGO_CONTRATO LEFT JOIN RHFERI_FERIAS F ON C.CODIGO_EMPRESA = F.CODIGO_EMPRESA AND C.TIPO_CONTRATO = F.TIPO_CONTRATO AND C.CODIGO = F.CODIGO_CONTRATO WHERE C.VINCULO = '0009' AND C.DATA_RESCISAO IS NULL AND C.CODIGO_EMPRESA = '0001' AND C.ANO_MES_REFERENCIA = (SELECT MAX(A.ANO_MES_REFERENCIA) FROM RHPESS_CONTRATO A WHERE A.CODIGO_EMPRESA = C.CODIGO_EMPRESA AND A.TIPO_CONTRATO = C.TIPO_CONTRATO AND A.CODIGO = C.CODIGO) AND (I.DT_INI_VIGENCIA IS NOT NULL AND I.DT_FIM_VIGENCIA IS NOT NULL) AND F.CODIGO_EMPRESA IS NULL;
vLOG := 'TAREFA 8: *ANTES* DE EXECUTAR PROCEDURE ARTERH.PR_GERA_RECESSO_ESTAGIO, QUANTIDADE DE ESTAGIARIOS SEM RECESSOS CRIADOS: '||vQTD_REGS;
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (CONSIDERACOES, DATA_DADOS, CAMPO_VALOR_1, CAMPO_VALOR_2)VALUES('LOG_PR_TAREFAS_DURANTE_MES', SYSDATE, vLOG, vQTD_REGS); COMMIT;
vLOG := NULL;

--/*
BEGIN 
ARTERH.PR_GERA_RECESSO_ESTAGIO;
 err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('TAREFAS_DURANTE_MES PROCEDURE ARTERH.PR_GERA_RECESSO_ESTAGIO','000',err_msg);
exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('TAREFAS_DURANTE_MES PROCEDURE ARTERH.PR_GERA_RECESSO_ESTAGIO',SQLCODE,err_msg);
END;
--*/

SELECT COUNT(1) INTO vQTD_REGS FROM ARTERH.RHFERI_FERIAS WHERE TRUNC(DT_ULT_ALTER_USUA) = TRUNC(SYSDATE) AND LOGIN_USUARIO = 'PR_GERA_RECESSO_ESTAGIO';
vLOG := 'TAREFA 8: *APOS* DE EXECUTAR PROCEDURE ARTERH.PR_GERA_RECESSO_ESTAGIO, QUANTIDADE DE ESTAGIARIOS SEM RECESSOS CRIADOS: '||vQTD_REGS;
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (CONSIDERACOES, DATA_DADOS, CAMPO_VALOR_1, CAMPO_VALOR_2)VALUES('LOG_PR_TAREFAS_DURANTE_MES', SYSDATE, vLOG, vQTD_REGS); COMMIT;
vLOG := NULL;

FOR C1 IN(
SELECT 'ORDEM_BM|CODIGO_EMPRESA|TIPO_CONTRATO|CODIGO_CONTRATO|DT_INI_AQUISICAO|PERIODO|DT_FIM_AQUISICAO|DT_INI_PROGRAMADA|DT_FIM_PROGRAMADA|DIAS_PROG_FERIAS|DIAS_PROG_ABONO|DT_INI_GOZO|DT_FIM_GOZO|DIAS_GOZO_FERIAS|DIAS_ABONO|DIAS_COMPENSACAO|NRO_MESES_AFAST|ADIANT_13_SALARIO|DT_RETORNO|SALDO_AUXILIAR|STATUS_CONFIRMACAO|OBSERVACAO|LOGIN_USUARIO|DT_ULT_ALTER_USUA|FALTAS_PERIODO|TIPO_FERIAS|C_LIVRE_SELEC01|C_LIVRE_SELEC02|C_LIVRE_SELEC03|C_LIVRE_VALOR01|C_LIVRE_VALOR02|C_LIVRE_VALOR03|C_LIVRE_DATA01|C_LIVRE_DATA02|C_LIVRE_DATA03|C_LIVRE_DESCR01|C_LIVRE_DESCR02|DOCUMENTO_PUBLIC|DATA_PUBLIC|ORDEM|DT_FIM_GOZO_FORCA|DIAS_GOZO_FORCA|RECEBE_ADIANT|DIAS_ABONO_FORCA|ACEITA_PREVISTO|COD_MOT_PERDA|STATUS_CALCULO|MES_ANO_CALCULO|ASSINATURA_01|ASSINATURA_02|PROCESSO|DATA_PAGTO_FERIAS|CODIGO_EMPRESA_SUBSTITUTO|TIPO_CONTRATO_SUBSTITUTO|CODIGO_CONTRATO_SUBSTITUTO|COD_MOT_INTERRUPCAO|DIAS_GOZO_ACRESCIMO|DATA_INDEFERIMENTO|DATA_INTERRUPCAO|PERIODO_NOTIFICADO|TIPO_MOVIMENTO|DT_EMISSAO_AVISO_FERIAS' 
AS LINHA FROM DUAL 
UNION ALL
SELECT 
X.ORDEM_BM||'|'||X.CODIGO_EMPRESA||'|'||X.TIPO_CONTRATO||'|'||X.CODIGO_CONTRATO||'|'||X.DT_INI_AQUISICAO||'|'||X.PERIODO||'|'||X.DT_FIM_AQUISICAO||'|'||X.DT_INI_PROGRAMADA||'|'||X.DT_FIM_PROGRAMADA||'|'||X.DIAS_PROG_FERIAS||'|'||X.DIAS_PROG_ABONO||'|'||X.DT_INI_GOZO||'|'||X.DT_FIM_GOZO||'|'||X.DIAS_GOZO_FERIAS||'|'||X.DIAS_ABONO||'|'||X.DIAS_COMPENSACAO||'|'||X.NRO_MESES_AFAST||'|'||X.ADIANT_13_SALARIO||'|'||X.DT_RETORNO||'|'||X.SALDO_AUXILIAR||'|'||X.STATUS_CONFIRMACAO||'|'||X.OBSERVACAO||'|'||X.LOGIN_USUARIO||'|'||X.DT_ULT_ALTER_USUA||'|'||X.FALTAS_PERIODO||'|'||X.TIPO_FERIAS||'|'||X.C_LIVRE_SELEC01||'|'||X.C_LIVRE_SELEC02||'|'||X.C_LIVRE_SELEC03||'|'||X.C_LIVRE_VALOR01||'|'||X.C_LIVRE_VALOR02||'|'||X.C_LIVRE_VALOR03||'|'||X.C_LIVRE_DATA01||'|'||X.C_LIVRE_DATA02||'|'||X.C_LIVRE_DATA03||'|'||X.C_LIVRE_DESCR01||'|'||X.C_LIVRE_DESCR02||'|'||X.DOCUMENTO_PUBLIC||'|'||X.DATA_PUBLIC||'|'||X.ORDEM||'|'||X.DT_FIM_GOZO_FORCA||'|'||X.DIAS_GOZO_FORCA||'|'||X.RECEBE_ADIANT||'|'||X.DIAS_ABONO_FORCA||'|'||X.ACEITA_PREVISTO||'|'||X.COD_MOT_PERDA||'|'||X.STATUS_CALCULO||'|'||X.MES_ANO_CALCULO||'|'||X.ASSINATURA_01||'|'||X.ASSINATURA_02||'|'||X.PROCESSO||'|'||X.DATA_PAGTO_FERIAS||'|'||X.CODIGO_EMPRESA_SUBSTITUTO||'|'||X.TIPO_CONTRATO_SUBSTITUTO||'|'||X.CODIGO_CONTRATO_SUBSTITUTO||'|'||X.COD_MOT_INTERRUPCAO||'|'||X.DIAS_GOZO_ACRESCIMO||'|'||X.DATA_INDEFERIMENTO||'|'||X.DATA_INTERRUPCAO||'|'||X.PERIODO_NOTIFICADO||'|'||X.TIPO_MOVIMENTO||'|'||X.DT_EMISSAO_AVISO_FERIAS
AS LINHA
FROM(
SELECT ROW_NUMBER () OVER (PARTITION BY CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO ORDER BY CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO,  DT_INI_AQUISICAO)ORDEM_BM, X.* 
FROM RHFERI_FERIAS X WHERE TRUNC(DT_ULT_ALTER_USUA) = TRUNC(SYSDATE) AND LOGIN_USUARIO = 'PR_GERA_RECESSO_ESTAGIO' ORDER BY CODIGO_CONTRATO, DT_INI_AQUISICAO 
)X

)LOOP
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (DATA_DADOS, CAMPO_VALOR_1, CONSIDERACOES)VALUES(SYSDATE,'PR_GERA_RECESSO_ESTAGIO',C1.LINHA);COMMIT;
END LOOP;



ELSIF vDIA_ATUAL = 20 THEN   --------------------------------------------------------------------------------------------------------------------DIA 20
--TAREFA 9 --limpa log ALT SIT FUNC
SELECT COUNT(1)QTD_DIAS INTO vQTD_REGS FROM(SELECT TRUNC(DT_ULT_ALTER_USUA), COUNT(1)QTD FROM ARTERH.SMARH_INT_PE_ALTSITFUN_AUDITO  GROUP BY TRUNC(DT_ULT_ALTER_USUA)); 
vLOG := 'TAREFA 9: *ANTES* DE LIMPAR TABELA ARTERH.SMARH_INT_PE_ALTSITFUN_AUDITO COM DIAS MAIS ANTIGOS, QUANTIDADE DE DIAS NA TABELA: '||vQTD_REGS;
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (CONSIDERACOES, DATA_DADOS, CAMPO_VALOR_1, CAMPO_VALOR_2)VALUES('LOG_PR_TAREFAS_DURANTE_MES', SYSDATE, vLOG, vQTD_REGS); COMMIT;
vLOG := NULL;

DELETE ARTERH.SMARH_INT_PE_ALTSITFUN_AUDITO WHERE TRUNC(DT_ULT_ALTER_USUA) <= TRUNC(SYSDATE)-90;COMMIT;

SELECT COUNT(1)QTD_DIAS INTO vQTD_REGS FROM(SELECT TRUNC(DT_ULT_ALTER_USUA), COUNT(1)QTD FROM ARTERH.SMARH_INT_PE_ALTSITFUN_AUDITO  GROUP BY TRUNC(DT_ULT_ALTER_USUA)); 
vLOG := 'TAREFA 9: *DEPOIS* DE LIMPAR TABELA ARTERH.SMARH_INT_PE_ALTSITFUN_AUDITO COM DIAS MAIS ANTIGOS, QUANTIDADE DE DIAS NA TABELA: '||vQTD_REGS;
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (CONSIDERACOES, DATA_DADOS, CAMPO_VALOR_1, CAMPO_VALOR_2)VALUES('LOG_PR_TAREFAS_DURANTE_MES', SYSDATE, vLOG, vQTD_REGS); COMMIT;
vLOG := NULL;


ELSIF vDIA_ATUAL = vULTIMO_DIA_MES THEN --------------------------------------------------------------------------------------------------------------------ULTIMO DIA MES
-- TAREFA 10 --RODAR REMUNERACAO MES PARA TEG
----------------************1 VEZ POR MES****************** APOS PROCESSAMENTO DA FOLHA
SELECT COUNT(1)QTD_DIAS INTO vQTD_REGS FROM ARTERH.SUGESP_FOTO_PARA_TEG_REM ; 
vLOG := 'TAREFA 10: *ANTES* DE LIMPAR TABELA ARTERH.SUGESP_FOTO_PARA_TEG_REM, QUANTIDADE DE REGISTROS: '||vQTD_REGS;
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (CONSIDERACOES, DATA_DADOS, CAMPO_VALOR_1, CAMPO_VALOR_2)VALUES('LOG_PR_TAREFAS_DURANTE_MES', SYSDATE, vLOG, vQTD_REGS); COMMIT;
vLOG := NULL;

--1º passo - limpar tabela temporaria 
DELETE ARTERH.SUGESP_FOTO_PARA_TEG_REM; COMMIT; 

--2º passo - bater foto DO VALOR DA VERBA '34P1' DE TODOS OS CONTRATOS no ultimo processamento da foha no ARTERH
--entrar e rodar no Pentaho TRANSFORMATION (03-2020 TEG) STEP (IN SUGESP_FOTO_PARA_TEG_REM)
FOR C1 IN (
SELECT CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, ANO_MES_REFERENCIA ANO_MES_VERBA, VALOR_VERBA  FROM ARTERH.RHMOVI_MOVIMENTO 
WHERE --codigo_empresa = '0001' and tipo_contrato = '0001' and 
codigo_verba = '34P1' 
AND TRUNC(ANO_MES_REFERENCIA) = (SELECT trunc(MAX(x.data_ini_folha)) from RHPONT_APUR_AGRUP x where x.codigo_empresa = '0001' and x.tipo_apur = 'F' AND c_livre_selec01 = 3 AND id_agrup = 152123)
)LOOP
INSERT INTO ARTERH.SUGESP_FOTO_PARA_TEG_REM(CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, ANO_MES_VERBA, VALOR_VERBA)VALUES(C1.CODIGO_EMPRESA, C1.TIPO_CONTRATO, C1.CODIGO_CONTRATO, C1.ANO_MES_VERBA, C1.VALOR_VERBA);COMMIT;
END LOOP;

SELECT COUNT(1)QTD_DIAS INTO vQTD_REGS FROM ARTERH.SUGESP_FOTO_PARA_TEG_REM ; 
vLOG := 'TAREFA 10: *DEPOIS* DE LIMPAR TABELA ARTERH.SUGESP_FOTO_PARA_TEG_REM, QUANTIDADE DE REGISTROS: '||vQTD_REGS;
DBMS_OUTPUT.PUT_LINE(vLOG);
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (CONSIDERACOES, DATA_DADOS, CAMPO_VALOR_1, CAMPO_VALOR_2)VALUES('LOG_PR_TAREFAS_DURANTE_MES', SYSDATE, vLOG, vQTD_REGS); COMMIT;
vLOG := NULL;


END IF;---IF GERAL DOS DIAS NO MES


END;-- END GERAL
