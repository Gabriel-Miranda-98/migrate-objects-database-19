
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_SUGESP_TRANFERE_APOSENTADOS" --(DATA IN VARCHAR2)
AS
BEGIN
--Kellysson em 19/1/24 ajuste para atender email (Re: eSocial | Desligamentos que não migraram mo F5 correto)
--KELLYSSON EM 17/12/20 BASEADO SCRIPT processoAP02v2.5.sql

declare  
vCONTADOR NUMBER ;
 --   vDATA VARCHAR2(10);

vDATA_SISTEMA DATE;
vDATA_INI_VIGENCIA DATE;--NOVO EM 31/5/21

begin
dbms_output.enable(null);
vCONTADOR :=0;
--vDATA := DATA;

 vDATA_SISTEMA := null;

--PEGAR DATA DO SISTEMA ARTERH   
SELECT DATA_DO_SISTEMA INTO vDATA_SISTEMA from rhparm_p_sist;  --01/02/2024

--PEGAR DATA INICIO DO ULTIMO FECHAMENTO DO SISTEMA --NOVO EM 31/5/21
SELECT trunc(MAX(x.data_ini_vigencia)) INTO vDATA_INI_VIGENCIA  from RHPONT_APUR_AGRUP x where x.codigo_empresa = '0001' and x.tipo_apur = 'F' AND c_livre_selec01 = 3 AND id_agrup = 152123;

--/*
---INICIO--------------------------------------------------PRIMEIRA PARTE----GERAR RELATORIO ANTES E TRANSFERE PARA A FUNCIONAL 1715-------------------------------------------------------------------------------------------------------------------------
dbms_output.put_line( '----*************************************************************INICIO PRIMEIRA PARTE----GERAR RELATORIO ANTES E TRANSFERE PARA A FUNCIONAL 1715');
for c1 in(

SELECT
CASE WHEN Y.COD_SIT_FUNCIONAL <> Y.SIT_FUNC_ULT_CONTRATO THEN 'ACERTAR SIT FUNC CONTRATO' ELSE 'OK' END COMPARACAO_SIT_FUNC,
CASE WHEN Y.CONTROLE_FOLHA = 'L' AND (Y.DATA_INICIO <> Y.DATA_INIC_AFAST OR Y.DATA_FIM <> Y.DATA_FIM_AFAST  ) THEN 'ACERTAR DATAS CONTRATO' ELSE 'OK' END COMPARACAO_DTS_AFAST,
Y.*
FROM(
SELECT 
K.CODIGO,
K.ORDEM_BM,  K.DATA_INICIO, K.DATA_FIM, K.DIAS_PERIODO,
K.CONTROLE_FOLHA, K.CONTR_FOLHA_CONTR,
K.COD_SIT_FUNCIONAL, K.PROXIMA_SITUACAO, K.SITUACAO_FUNCIONAL, K.ANO_MES_REFERENCIA,
K.CODIGO_EMPRESA, K.TIPO_CONTRATO
,K.login_usuario, K.dt_ult_alter_usua, 
K.RG_TRAB, K.RG_PREV, K.COD_CATEG, K.SIT_FUNC_ULT_CONTRATO
,k.data_inic_afast, k.data_fim_afast, k.codigo_escala, k.dt_ult_escala
FROM (
SELECT 
ROW_NUMBER() OVER (PARTITION BY Z.CODIGO_EMPRESA, Z.TIPO_CONTRATO, Z.CODIGO ORDER BY Z.DATA_INICIO DESC) AS ORDEM_BM, Z.* FROM(
SELECT 
W.* 
,RG_TRAB.CONTEUDO_INICIAL RG_TRAB, RG_PREV.CONTEUDO_INICIAL RG_PREV, COD_CATEG.CONTEUDO_INICIAL COD_CATEG
FROM (
SELECT 
A.CODIGO_EMPRESA, A.TIPO_CONTRATO, A.CODIGO, 
A.DATA_INIC_SITUACAO DATA_INICIO, A.DATA_FIM_SITUACAO DATA_FIM , (A.DATA_FIM_SITUACAO- A.DATA_INIC_SITUACAO)+1 DIAS_PERIODO
,A.COD_SIT_FUNCIONAL, SF.CONTROLE_FOLHA, A.PROXIMA_SITUACAO--, A.TEXTO_ASSOCIADO
,C.ANO_MES_REFERENCIA , C.SITUACAO_FUNCIONAL, SFC.CONTROLE_FOLHA CONTR_FOLHA_CONTR
,a.login_usuario, a.dt_ult_alter_usua , C.SITUACAO_FUNCIONAL SIT_FUNC_ULT_CONTRATO
,c.data_inic_afast, c.data_fim_afast, c.codigo_escala, c.dt_ult_escala
FROM RHCGED_ALT_SIT_FUN A 
LEFT OUTER JOIN RHPARM_SIT_FUNC SF ON SF.CODIGO = A.cod_sit_funcional
LEFT OUTER JOIN RHPESS_CONTRATO C ON C.CODIGO_EMPRESA = A.CODIGO_EMPRESA AND C.TIPO_CONTRATO = A.TIPO_CONTRATO AND C.CODIGO = A.CODIGO
LEFT OUTER JOIN RHPARM_SIT_FUNC SFC ON SFC.CODIGO = C.SITUACAO_FUNCIONAL
WHERE 
C.ANO_MES_REFERENCIA = (SELECT MAX(AUX.ANO_MES_REFERENCIA)
FROM RHPESS_CONTRATO AUX WHERE C.CODIGO_EMPRESA = AUX.CODIGO_EMPRESA AND C.TIPO_CONTRATO = AUX.TIPO_CONTRATO AND C.CODIGO = AUX.CODIGO)
and
a.DATA_INIC_SITUACAO = (SELECT MAX(AUX.DATA_INIC_SITUACAO)
FROM RHCGED_ALT_SIT_FUN AUX WHERE A.CODIGO_EMPRESA = AUX.CODIGO_EMPRESA AND A.TIPO_CONTRATO = AUX.TIPO_CONTRATO AND A.CODIGO = AUX.CODIGO)
AND
(--novo em 5/3/21

EXISTS
(-- INICIO exists
select contrato_0001.data_rescisao dt_res, contrato_0001.* from rhpess_contrato contrato_0001
where contrato_0001.codigo_empresa = '0001'
and contrato_0001.tipo_contrato = '0001'
and contrato_0001.situacao_funcional in (
--'1015', --adicionado em 22/9/20
'1002',--desativa em 22/9/20
'1700',--desativa em 22/9/20
'1701',
'1702',--desativa em 22/9/20
'1703', '1704', '1705', '1706', '1707'
,'1022', '1023', '1024', '1025'--desativa em 22/9/20
)
and contrato_0001.ano_mes_referencia = 
                  ADD_MONTHS(to_date(vDATA_SISTEMA,'dd/mm/yy'),-1)--ADD_MONTHS(to_date('01/03/21','dd/mm/yy'),-1)--
                  --to_date(vDATA,'dd/mm/yy')--:GLB_MES_ANO_SISTEMA -- 20 registros -------------------****************tem que trocar data do mes referencia
AND CONTRATO_0001.DATA_RESCISAO IS NULL

AND contrato_0001.CODIGO_EMPRESA = A.CODIGO_EMPRESA AND contrato_0001.TIPO_CONTRATO = A.TIPO_CONTRATO AND  contrato_0001.CODIGO = A.CODIGO
)--FIM EXISTS
OR --INICIO --novo em 5/3/21
EXISTS(
SELECT ASF.CODIGO_EMPRESA, ASF.TIPO_CONTRATO, ASF.CODIGO, ASF.DATA_INIC_SITUACAO, ASF.DATA_FIM_SITUACAO ,ASF.COD_SIT_FUNCIONAL
FROM RHCGED_ALT_SIT_FUN ASF
where ASF.codigo_empresa = '0001'
and ASF.tipo_contrato = '0001'
and ASF.COD_SIT_FUNCIONAL in (
--'1015', --adicionado em 22/9/20
'1002',--desativa em 22/9/20
'1700',--desativa em 22/9/20
'1701',
'1702',--desativa em 22/9/20
'1703', '1704', '1705', '1706', '1707'
,'1022', '1023', '1024', '1025'--desativa em 22/9/20
)
AND TRUNC(ASF.DATA_FIM_SITUACAO) BETWEEN ADD_MONTHS(to_date(vDATA_SISTEMA,'dd/mm/yy'),-1)AND LAST_DAY(vDATA_SISTEMA) -- TO_DATE('01/02/21','DD/MM/YY') AND TO_DATE('28/02/21','DD/MM/YY')
AND ASF.CODIGO_EMPRESA = A.CODIGO_EMPRESA AND ASF.TIPO_CONTRATO = A.TIPO_CONTRATO AND  ASF.CODIGO = A.CODIGO
)
)--fim --novo em 5/3/21
)W
LEFT OUTER JOIN rhpess_contrato c ON C.CODIGO_EMPRESA = W.CODIGO_EMPRESA AND C.TIPO_CONTRATO = W.TIPO_CONTRATO AND C.CODIGO = W.CODIGO
left outer join RHTABS_VINCULO_EMP V ON V.CODIGO = c.VINCULO
LEFT OUTER JOIN RHPARM_SIT_FUNC S ON S.CODIGO = c.situacao_funcional
LEFT OUTER JOIN (select * from rhtabs_itds_sist WHERE CODIGO_DOMINIO IN (select CODIGO_DOMINIO from RHTABS_COLS_SIST  where codigo_tabela = 'RHTABS_VINCULO_EMP' and codigo_coluna = 'TP_REGIME_TRAB_ESOCIAL'))RG_TRAB
ON RG_TRAB.CONTEUDO_INICIAL = V.TP_REGIME_TRAB_ESOCIAL
LEFT OUTER JOIN (select * from rhtabs_itds_sist WHERE CODIGO_DOMINIO IN (select CODIGO_DOMINIO from RHTABS_COLS_SIST  where codigo_tabela = 'RHTABS_VINCULO_EMP' and codigo_coluna = 'TP_REGIME_PREV_ESOCIAL'))RG_PREV
ON RG_PREV.CONTEUDO_INICIAL = V.TP_REGIME_PREV_ESOCIAL
LEFT OUTER JOIN (select * from rhtabs_itds_sist WHERE CODIGO_DOMINIO IN (select CODIGO_DOMINIO from RHTABS_COLS_SIST  where codigo_tabela = 'RHTABS_VINCULO_EMP' and codigo_coluna = 'COD_CATEG_ESOCIAL'))COD_CATEG
ON COD_CATEG.CONTEUDO_INICIAL = V.COD_CATEG_ESOCIAL
WHERE 
C.ANO_MES_REFERENCIA = (SELECT MAX(AUX.ANO_MES_REFERENCIA)FROM RHPESS_CONTRATO AUX WHERE C.CODIGO_EMPRESA = AUX.CODIGO_EMPRESA AND C.TIPO_CONTRATO = AUX.TIPO_CONTRATO AND C.CODIGO = AUX.CODIGO)
ORDER BY W.CODIGO_EMPRESA, W.TIPO_CONTRATO, W.CODIGO, W.DATA_INICIO DESC
)Z

)K
)Y
WHERE TRUNC(Y.DATA_INICIO) <= TRUNC(vDATA_INI_VIGENCIA)--novo em 31/5/21 --ajuste em 10/11/21 colocando o sinal de igual para pegar os lancamentos do dia do fechamento

--AND Y.CODIGO = '000000000170171'-- '000000000150634'--TESTES 18/1/24


)
loop
vCONTADOR :=vCONTADOR+1;
dbms_output.put_line( ' ');
dbms_output.put_line('--CONTADOR:'|| vCONTADOR||' - CODIGO EMPRESA: ' || c1.codigo_empresa ||' TIPO CONTRATO: '|| c1.tipo_contrato ||' CODIGO CONTRATO: '|| c1.codigo);

--INSERT NOVO 18/1/24---RELATORIO ANTES
INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, CONSIDERACOES, DATA_DADOS, CAMPO_VALOR_1, CAMPO_VALOR_2, CAMPO_VALOR_3, CAMPO_VALOR_4, CAMPO_VALOR_5, CAMPO_VALOR_6, CAMPO_VALOR_7, CAMPO_VALOR_8, CAMPO_VALOR_9, CAMPO_VALOR_10, CAMPO_VALOR_11, CAMPO_VALOR_12, CAMPO_VALOR_13, CAMPO_VALOR_14, CAMPO_VALOR_15, CAMPO_VALOR_16, CAMPO_VALOR_17, CAMPO_VALOR_18, CAMPO_VALOR_19, CAMPO_VALOR_20, CAMPO_VALOR_21, CAMPO_VALOR_22)
VALUES(C1.CODIGO_EMPRESA, C1.TIPO_CONTRATO,  C1.CODIGO, 'PR_SUGESP_TRANFERE_APOSENTADOS_DADOS_ANTES',SYSDATE, C1.COMPARACAO_SIT_FUNC, C1.COMPARACAO_DTS_AFAST, C1.ORDEM_BM, C1.DATA_INICIO, C1.DATA_FIM, C1.DIAS_PERIODO, C1.CONTROLE_FOLHA, C1.CONTR_FOLHA_CONTR, C1.COD_SIT_FUNCIONAL, C1.PROXIMA_SITUACAO, C1.SITUACAO_FUNCIONAL, C1.ANO_MES_REFERENCIA, C1.LOGIN_USUARIO, C1.DT_ULT_ALTER_USUA, C1.RG_TRAB, C1.RG_PREV, C1.COD_CATEG, C1.SIT_FUNC_ULT_CONTRATO, C1.DATA_INIC_AFAST, C1.DATA_FIM_AFAST, C1.CODIGO_ESCALA, C1.DT_ULT_ESCALA);COMMIT;

--empresa 1 rodar antes do PROCESSO ARTERH AP02
--comentado em 5/5/20--dbms_output.put_line('insert into rhpont_alt_escala (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DT_INICIO_TROCA, DT_FIM_TROCA, LOGIN_USUARIO, DT_ULT_ALTER_USUA, ALTER_DEFINITIVA, COD_ESCALA, texto_associado)values ('''||C1.CODIGO_EMPRESA ||''','''|| c1.tipo_contrato ||''','''|| c1.codigo ||''', trunc(SYSDATE), trunc(SYSDATE), ''procedure_aposentado'', sysdate, ''S'', '''|| C1.CODIGO_ESCALA||''',''via procedure - backup ultima escala do servidor no contrato''); COMMIT;');

IF C1.CONTROLE_FOLHA = 'S' THEN--novo if em 2/3/22 caso de volta ao trabalho email (Transferência dos Aposentados - 02/22)

IF C1.COD_SIT_FUNCIONAL <> '1025' 
OR C1.DATA_FIM IS NULL --NOVO EM 1/6/21
THEN-- NOVO EM 25/11/20 PARA CENARIO GESER SIT FUNC 1025 JA TER DATA FIM

--dbms_output.put_line('UPDATE RHCGED_ALT_SIT_FUN SET LOGIN_USUARIO = ''procedure_aposentado'' , DT_ULT_ALTER_USUA = SYSDATE, data_fim_situacao = TO_DATE('''||TRUNC(vDATA_SISTEMA)||''',''DD/MM/YY'')-1 where CODIGO_EMPRESA = '''||C1.CODIGO_EMPRESA ||''' AND TIPO_CONTRATO = '''||C1.TIPO_CONTRATO ||''' AND CODIGO = '''|| C1.CODIGO ||''' AND TRUNC(data_inic_situacao) = to_date('''||trunc(C1.DATA_INICIO) ||''',''dd/mm/yy'')'||'; COMMIT;' );
UPDATE RHCGED_ALT_SIT_FUN SET LOGIN_USUARIO = 'procedure_aposentado', DT_ULT_ALTER_USUA = SYSDATE, data_fim_situacao = TO_DATE(TRUNC(vDATA_SISTEMA),'DD/MM/YY')-1 where CODIGO_EMPRESA = C1.CODIGO_EMPRESA AND TIPO_CONTRATO = C1.TIPO_CONTRATO AND CODIGO = C1.CODIGO  AND TRUNC(data_inic_situacao) = to_date(trunc(C1.DATA_INICIO),'dd/mm/yy'); COMMIT;
--dbms_output.put_line('EXECUTE SUGESP_ALT_SIT_FUNC_ULT_CONTRA('''||C1.CODIGO_EMPRESA ||''','''|| C1.TIPO_CONTRATO ||''','''|| C1.CODIGO ||''',''procedure_aposentado'' );');
--COMENTADO 18/1/24--SUGESP_ALT_SIT_FUNC_ULT_CONTRA(C1.CODIGO_EMPRESA , C1.TIPO_CONTRATO , C1.CODIGO ,'procedure_aposentado'); --NOVO EM 29/12/23 EMAIL (Re: eSocial | Desligamentos que não migraram mo F5 correto)
--dbms_output.put_line('INSERT INTO RHCGED_ALT_SIT_FUN (ind_ef_retro_esocial, TEXTO_ASSOCIADO, LOGIN_USUARIO, DT_ULT_ALTER_USUA, CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO, DATA_INIC_SITUACAO, COD_SIT_FUNCIONAL )values (''N'', ''Registro criado automaticamente pela procedure_aposentado.'', ''procedure_aposentado'' ,sysdate,'''|| C1.CODIGO_EMPRESA ||''','''|| C1.TIPO_CONTRATO ||''','''|| C1.codigo|| ''', TO_DATE(''' || TRUNC(vDATA_SISTEMA) || ''',''dd/mm/yy''), ''1715''); COMMIT;' );
INSERT INTO RHCGED_ALT_SIT_FUN (ind_ef_retro_esocial, TEXTO_ASSOCIADO, LOGIN_USUARIO, DT_ULT_ALTER_USUA, CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO, DATA_INIC_SITUACAO, COD_SIT_FUNCIONAL )values ('N', 'Registro criado automaticamente pela procedure_aposentado.', 'procedure_aposentado' ,sysdate, C1.CODIGO_EMPRESA , C1.TIPO_CONTRATO , C1.codigo, TO_DATE(TRUNC(vDATA_SISTEMA) ,'dd/mm/yy'), '1715'); COMMIT;
--dbms_output.put_line('EXECUTE SUGESP_ALT_SIT_FUNC_ULT_CONTRA('''||C1.CODIGO_EMPRESA ||''','''|| C1.TIPO_CONTRATO ||''','''|| C1.CODIGO ||''',''procedure_aposentado'' );');
SUGESP_ALT_SIT_FUNC_ULT_CONTRA(C1.CODIGO_EMPRESA , C1.TIPO_CONTRATO , C1.CODIGO ,'procedure_aposentado');


ELSE
--delete novo em 8/3/21
DELETE RHCGED_ALT_SIT_FUN  WHERE CODIGO_EMPRESA = C1.CODIGO_EMPRESA AND TIPO_CONTRATO = C1.TIPO_CONTRATO AND CODIGO =  C1.CODIGO AND TRUNC(data_inic_situacao) > to_date(trunc(C1.DATA_INICIO) ,'dd/mm/yy'); COMMIT;
--dbms_output.put_line('UPDATE RHCGED_ALT_SIT_FUN SET LOGIN_USUARIO = ''procedure_aposentado'' , DT_ULT_ALTER_USUA = SYSDATE, proxima_situacao = null where CODIGO_EMPRESA = '''||C1.CODIGO_EMPRESA ||''' AND TIPO_CONTRATO = '''||C1.TIPO_CONTRATO ||''' AND CODIGO = '''|| C1.CODIGO ||''' AND TRUNC(data_inic_situacao) = to_date('''||trunc(C1.DATA_INICIO) ||''',''dd/mm/yy'')'||'; COMMIT;' );
UPDATE RHCGED_ALT_SIT_FUN SET LOGIN_USUARIO = 'procedure_aposentado' , DT_ULT_ALTER_USUA = SYSDATE, proxima_situacao = null , data_fim_situacao = TO_DATE(TRUNC(vDATA_SISTEMA),'DD/MM/YY')-1 where CODIGO_EMPRESA = C1.CODIGO_EMPRESA AND TIPO_CONTRATO = C1.TIPO_CONTRATO AND CODIGO =  C1.CODIGO AND TRUNC(data_inic_situacao) = to_date(trunc(C1.DATA_INICIO) ,'dd/mm/yy'); COMMIT;
--dbms_output.put_line('EXECUTE SUGESP_ALT_SIT_FUNC_ULT_CONTRA('''||C1.CODIGO_EMPRESA ||''','''|| C1.TIPO_CONTRATO ||''','''|| C1.CODIGO ||''',''procedure_aposentado'' );');
--COMENTADO 18/1/24--SUGESP_ALT_SIT_FUNC_ULT_CONTRA(C1.CODIGO_EMPRESA , C1.TIPO_CONTRATO , C1.CODIGO ,'procedure_aposentado'); --NOVO EM 29/12/23 EMAIL (Re: eSocial | Desligamentos que não migraram mo F5 correto)
--dbms_output.put_line('INSERT INTO RHCGED_ALT_SIT_FUN (ind_ef_retro_esocial, TEXTO_ASSOCIADO, LOGIN_USUARIO, DT_ULT_ALTER_USUA, CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO, DATA_INIC_SITUACAO, COD_SIT_FUNCIONAL )values (''N'', ''Registro criado automaticamente pela procedure_aposentado.'', ''procedure_aposentado'' ,sysdate,'''|| C1.CODIGO_EMPRESA ||''','''|| C1.TIPO_CONTRATO ||''','''|| C1.codigo|| ''', TO_DATE(''' || TRUNC(vDATA_SISTEMA) || ''',''dd/mm/yy''), ''1715''); COMMIT;' );
INSERT INTO RHCGED_ALT_SIT_FUN (ind_ef_retro_esocial, TEXTO_ASSOCIADO, LOGIN_USUARIO, DT_ULT_ALTER_USUA, CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO, DATA_INIC_SITUACAO, COD_SIT_FUNCIONAL )values ('N', 'Registro criado automaticamente pela procedure_aposentado.', 'procedure_aposentado' ,sysdate, C1.CODIGO_EMPRESA , C1.TIPO_CONTRATO , C1.codigo, TO_DATE(TRUNC(vDATA_SISTEMA),'dd/mm/yy'), '1715'); COMMIT;
--dbms_output.put_line('EXECUTE SUGESP_ALT_SIT_FUNC_ULT_CONTRA('''||C1.CODIGO_EMPRESA ||''','''|| C1.TIPO_CONTRATO ||''','''|| C1.CODIGO ||''',''procedure_aposentado'' );');
SUGESP_ALT_SIT_FUNC_ULT_CONTRA(C1.CODIGO_EMPRESA, C1.TIPO_CONTRATO, C1.CODIGO, 'procedure_aposentado' );


END IF; -- NOVO EM 25/11/20 PARA CENARIO GESER SIT FUNC 1025 JA TER DATA FIM

--FALTA EMPRESA 1
--PROCESSO AP02 - delete from rhmovi_movimento m where m.codigo_empresa = :glb_empresa and m.tipo_contrato = :glb_tipo_contrato and  m.ano_mes_referencia = :glb_mes_ano_sistema and  m.tipo_movimento = 'ME' and  m.modo_operacao = :glb_modo_operacao and...

--FALTA EMPRESA 1700
-- PROCESSO AP02 - CRIAR OS CONTRATOS
-- PROCESSO AP02 - INSERT INTO RHMOVI_MOVIMENTO select '1700', MODO_OPERACAO, ANO_MES_REFERENCIA, TIPO_MOVIMENTO, TIPO_CONTRATO, CODIGO_CONTRATO, CODIGO_VERBA, MES_INCIDENCIA, CTRL_DEMO, REF_VERBA, VALOR_VERBA, CTRL_LANCAMENTO, CONTADOR, 'usuarte', sysdate, FASE from RHMOVI_MOVIMENTO where CODIGO_EMPRESA = '0001' and TIPO_CONTRATO = '0001' and modo_operacao = 'R' and tipo_movimento = 'ME' and fase = '0' and RHMOVI_MOVIMENTO.ANO_MES_REFERENCIA = :glb_mes_ano_sistema and exists... 

END IF;--novo if em 2/3/22 caso de volta ao trabalho email (Transferência dos Aposentados - 02/22)

end loop;
dbms_output.put_line( 'FIM--PRIMEIRA PARTE----GERAR RELATORIO ANTES E TRANSFERE PARA A FUNCIONAL 1715');
---FIM--------------------------------------------------PRIMEIRA PARTE----GERAR RELATORIO ANTES E TRANSFERE PARA A FUNCIONAL 1715-------------------------------------------------------------------------------------------------------------------------
--*/

---INICIO--------------------------------------------------SEGUNDA PARTE----AJUSTA HISTORICO RHPESS_CONTRATO PARA ESOCIAL E RELATORIO APOS TRANSFERE PARA A FUNCIONAL 1715-------------------------------------------------------------------------------------------------------------------------
dbms_output.put_line( '----*************************************************************INICIO--SEGUNDA PARTE----AJUSTA HISTORICO RHPESS_CONTRATO PARA ESOCIAL E RELATORIO APOS TRANSFERE PARA A FUNCIONAL 1715');
vCONTADOR :=0;
for c1 in(

SELECT 'DADOS_ALT_SIT_FUNC' DADOS_ALT_SIT_FUNC, A.*, 
'DADOS_CONTRATO' DADOS_CONTRATO, C.ORDEM_CONTRATO, C.ANO_MES, C.ANO_MES_REFERENCIA, C.SITUACAO_FUNCIONAL, C.COD_MOVIMENTACAO, C.DATA_RESCISAO, C.CAUSA_RESCISAO,C.MOTIVO_DEMISSAO, C.DATA_INIC_AFAST,
c.data_admissao, c.DATA_EFETIVO_EXERC, c.DATA_BASE_FERIAS, C.LOGIN_USUARIO, C.DT_ULT_ALTER_USUA
FROM
(
SELECT x.* FROM( 
select
row_number() over (partition by c.codigo order by c.codigo, c.ANO_MES_REFERENCIA desc)ORDEM_CONTRATO,
C.CODIGO_EMPRESA, C.TIPO_CONTRATO, C.CODIGO, substr(c.ano_mes_referencia,3,8)ANO_MES,  c.ano_mes_referencia, c.situacao_funcional, c.cod_movimentacao, c.data_rescisao,CAUSA_RESCISAO,C.MOTIVO_DEMISSAO, c.DATA_INIC_AFAST,
c.data_admissao, c. DATA_EFETIVO_EXERC, c.DATA_BASE_FERIAS,
c.login_usuario, c.DT_ULT_ALTER_USUA
from rhpess_contrato c
WHERE c.situacao_funcional = '1715' and
c.codigo_empresa = '0001' and c.tipo_contrato = '0001'
and c.codigo in 
( SELECT CODIGO_CONTRATO FROM ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST WHERE CONSIDERACOES = 'PR_SUGESP_TRANFERE_APOSENTADOS_DADOS_ANTES' AND TRUNC(DATA_DADOS) = TRUNC(SYSDATE)
)
order by c.codigo, c.ANO_MES_REFERENCIA desc
)x WHERE x.ORDEM_CONTRATO <=1
)C
LEFT OUTER JOIN
(
SELECT A.* FROM(
SELECT 
row_number() over (partition by A.codigo order by A.codigo, A.DATA_INIC_SITUACAO desc)ORDEM_SITUACAO,
A.CODIGO_EMPRESA, A.TIPO_CONTRATO, A.CODIGO, 
A.DATA_INIC_SITUACAO DATA_INICIO, A.DATA_FIM_SITUACAO DATA_FIM , (A.DATA_FIM_SITUACAO- A.DATA_INIC_SITUACAO)+1 DIAS_PERIODO
,A.COD_SIT_FUNCIONAL, A.PROXIMA_SITUACAO--, A.TEXTO_ASSOCIADO
FROM RHCGED_ALT_SIT_FUN A 
where A.codigo_empresa = '0001' and A.tipo_contrato = '0001' AND a.codigo in 
(SELECT CODIGO_CONTRATO FROM ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST WHERE CONSIDERACOES = 'PR_SUGESP_TRANFERE_APOSENTADOS_DADOS_ANTES' AND TRUNC(DATA_DADOS) = TRUNC(SYSDATE)
)
order by A.codigo, A.DATA_INIC_SITUACAO desc
)A WHERE A.ORDEM_SITUACAO =2

)A
ON A.CODIGO_EMPRESA = C.CODIGO_EMPRESA AND A.TIPO_CONTRATO = C.TIPO_CONTRATO AND A.CODIGO = C.CODIGO

)loop

vCONTADOR :=vCONTADOR+1;
dbms_output.put_line( ' ');
dbms_output.put_line('--CONTADOR:'|| vCONTADOR||' - CODIGO EMPRESA: ' || c1.codigo_empresa ||' TIPO CONTRATO: '|| c1.tipo_contrato ||' CODIGO CONTRATO: '|| c1.codigo);

--APENAS ERRO PASSIVO--
--UPDATE RHCGED_ALT_SIT_FUN SET LOGIN_USUARIO = 'procedure_aposentado' , DT_ULT_ALTER_USUA = SYSDATE, proxima_situacao = null , data_fim_situacao = TO_DATE(TRUNC(C1.ANO_MES_REFERENCIA),'DD/MM/YY')-1 where CODIGO_EMPRESA = C1.CODIGO_EMPRESA AND TIPO_CONTRATO = C1.TIPO_CONTRATO AND CODIGO = C1.CODIGO AND TRUNC(data_inic_situacao) = to_date(trunc(C1.DATA_INICIO) ,'dd/mm/yy'); COMMIT;
--dbms_output.put_line('--UPDATE RHCGED_ALT_SIT_FUN');


ARTERH.PR_INSERE_CONTRATO(C1.CODIGO_EMPRESA, C1.TIPO_CONTRATO, C1.CODIGO,to_date(C1.DATA_INICIO,'dd/mm/yyyy'));
dbms_output.put_line('--EXECUTE ARTERH.PR_INSERE_CONTRATO');

ARTERH.PR_INSERE_CONTRATO_AUX(C1.CODIGO_EMPRESA, C1.TIPO_CONTRATO, C1.CODIGO,to_date(C1.DATA_INICIO,'dd/mm/yyyy') ,'procedure_aposentado'); 
dbms_output.put_line('--EXECUTE ARTERH.PR_INSERE_CONTRATO_AUX');

     FOR c2 IN
        (
          SELECT C.codigo_empresa, C.tipo_contrato, C.CODIGO, c.ano_mes_referencia, c.situacao_funcional, c.SITUACAO_CONTRATO, c.cod_movimentacao, c.data_rescisao, c.CAUSA_RESCISAO, c.MOTIVO_DEMISSAO, c.DATA_INIC_AFAST, c.login_usuario, c.DT_ULT_ALTER_USUA
          FROM rhpess_contrato C 
          where C.codigo_empresa = C1.CODIGO_EMPRESA and C.tipo_contrato = C1.TIPO_CONTRATO And C.CODIGO = C1.CODIGO 
          AND TO_DATE('01'||SUBSTR(ANO_MES_REFERENCIA,3,8),'DD/MM/YyyY') >= TO_DATE('01'||SUBSTR(C1.DATA_INICIO,3,8),'DD/MM/YyyY') 
          AND SITUACAO_FUNCIONAL <> '1715'
          ORDER BY C.codigo_empresa, C.tipo_contrato, C.CODIGO, C.ano_mes_referencia
        )LOOP                                      

        ARTERH.PR_INSERE_RHPESS_ALT_CONTRAT (C2.CODIGO_EMPRESA,C2.TIPO_CONTRATO,C2.CODIGO, 'procedure_aposentado',C2.ano_mes_referencia, lista('LOGIN_USUARIO','SITUACAO_FUNCIONAL','SITUACAO_CONTRATO','DATA_INIC_AFAST','DATA_RESCISAO','CAUSA_RESCISAO','MOTIVO_DEMISSAO','COD_MOVIMENTACAO')
        ,LISTA(C2.LOGIN_USUARIO,C2.SITUACAO_FUNCIONAL, C2.SITUACAO_CONTRATO, C2.DATA_INIC_AFAST, C2.DATA_RESCISAO, C2.CAUSA_RESCISAO, C2.MOTIVO_DEMISSAO, C2.COD_MOVIMENTACAO)
        ,LISTA('procedure_aposentado',C1.COD_SIT_FUNCIONAL, 'S',to_date(C1.DATA_INICIO,'dd/mm/yyyy'),to_date(C1.DATA_INICIO,'dd/mm/yyyy'), C1.CAUSA_RESCISAO, C1.MOTIVO_DEMISSAO, C1.cod_movimentacao)) ;   
        dbms_output.put_line('--EXECUTE ARTERH.PR_INSERE_CONTRATO C2.ano_mes_referencia:'||C2.ano_mes_referencia);

     UPDATE RHPESS_CONTRATO SET login_usuario = 'procedure_aposentado', dt_ult_alter_usua = sysdate, DATA_INIC_AFAST = to_date(C1.DATA_INICIO,'dd/mm/yyyy'), DATA_RESCISAO = to_date(C1.DATA_INICIO,'dd/mm/yyyy'), CAUSA_RESCISAO = C1.CAUSA_RESCISAO
    ,MOTIVO_DEMISSAO = C1.MOTIVO_DEMISSAO, cod_movimentacao = C1.cod_movimentacao, SITUACAO_FUNCIONAL = C1.COD_SIT_FUNCIONAL, situacao_contrato = 'S' 
    WHERE CODIGO_EMPRESA = C1.CODIGO_EMPRESA AND TIPO_CONTRATO = C1.TIPO_CONTRATO AND CODIGO = C1.CODIGO
    AND TO_DATE('01'||SUBSTR(ANO_MES_REFERENCIA,3,8),'DD/MM/YyyY') >= TO_DATE('01'||SUBSTR(C1.DATA_INICIO,3,8),'DD/MM/YyyY') 
    AND SITUACAO_FUNCIONAL <> '1715';COMMIT;
    dbms_output.put_line('--UPDATES MESES RHPESS_CONTRATO C2.ano_mes_referencia:'||C2.ano_mes_referencia);

    end loop; --c2

end loop;


--RELATORIO APOS
FOR C3 IN 
(
select 
row_number() over(partition by codigo_empresa, tipo_contrato, codigo order by codigo_empresa, tipo_contrato, codigo, ano_mes_referencia desc)ordem_bm,
to_char(DT_ULT_ALTER_USUA,'DD/MM/YYYY HH24:MI:SS')DT_ALT , codigo_empresa, tipo_contrato, codigo, ano_mes_referencia, situacao_funcional, situacao_contrato, cod_movimentacao, data_rescisao, CAUSA_RESCISAO, MOTIVO_DEMISSAO, DATA_INIC_AFAST,
data_admissao, DATA_EFETIVO_EXERC, DATA_BASE_FERIAS, login_usuario, DT_ULT_ALTER_USUA from rhpess_contrato 
where 
login_usuario in ('procedure_aposentado', 'pb003374') and trunc(DT_ULT_ALTER_USUA) = trunc(sysdate) and situacao_contrato = 'S'
order by codigo_empresa, tipo_contrato, codigo, ano_mes_referencia desc

)LOOP

INSERT INTO ARTERH.SUGESP_AJUSTE_LOTE_CAMPO_HIST (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, CONSIDERACOES, DATA_DADOS, CAMPO_VALOR_1, CAMPO_VALOR_2, CAMPO_VALOR_3, CAMPO_VALOR_4, CAMPO_VALOR_5, CAMPO_VALOR_6, CAMPO_VALOR_7, CAMPO_VALOR_8, CAMPO_VALOR_9, CAMPO_VALOR_10, CAMPO_VALOR_11, CAMPO_VALOR_12, CAMPO_VALOR_13, CAMPO_VALOR_14, CAMPO_VALOR_15)
VALUES(C3.CODIGO_EMPRESA, C3.TIPO_CONTRATO, C3.CODIGO, 'PR_SUGESP_TRANFERE_APOSENTADOS_DADOS_DEPOIS',SYSDATE, C3.ORDEM_BM, C3.DT_ALT, C3.ANO_MES_REFERENCIA, C3.SITUACAO_FUNCIONAL, C3.SITUACAO_CONTRATO, C3.COD_MOVIMENTACAO, C3.DATA_RESCISAO, C3.CAUSA_RESCISAO, C3.MOTIVO_DEMISSAO, C3.DATA_INIC_AFAST, C3.DATA_ADMISSAO, C3.DATA_EFETIVO_EXERC, C3.DATA_BASE_FERIAS, C3.LOGIN_USUARIO, C3.DT_ULT_ALTER_USUA);COMMIT;

END LOOP;


dbms_output.put_line( '----*************************************************************FIM--SEGUNDA PARTE----AJUSTA HISTORICO RHPESS_CONTRATO PARA ESOCIAL E RELATORIO APOS TRANSFERE PARA A FUNCIONAL 1715');
---FIM--------------------------------------------------SEGUNDA PARTE----AJUSTA HISTORICO RHPESS_CONTRATO PARA ESOCIAL E RELATORIO APOS TRANSFERE PARA A FUNCIONAL 1715-------------------------------------------------------------------------------------------------------------------------


END;
END;