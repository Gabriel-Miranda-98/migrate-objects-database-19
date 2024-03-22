
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PRR_DATA_ESPECIAL_SMSA" (DATA_INICIO IN DATE, DATA_FIM IN DATE) AS
BEGIN
--em 4/1/22 criando para ja gerar os cenarios e passar mais traduzido para GETED encaminhar os casos negados para a SMSA
--/*
DECLARE               
vCONTADOR NUMBER; 
vDATA_INICIO DATE;
vDATA_FIM DATE;

BEGIN
dbms_output.enable(null);
vCONTADOR := 0;
vDATA_INICIO := DATA_INICIO;
vDATA_FIM := DATA_FIM;

FOR C1 IN(
--*/
--------------------------------------------------------------------TROCAR DATAS
SELECT 
'CENARIO|CODIGO_EMPRESA|TIPO_CONTRATO|CODIGO_CONTRATO|DATA|CODIGO_SITUACAO|SITUACAO_PONTO|REFERENCIA|LOGIN_USUARIO|DT_ULT_ALTER_USUA|TIPO_APURACAO|EMPRESA|TIPO_CONT|CONTRATO|DATA_LANC|RESULTADO_FINAL_PROCESSAMENTO|EMPRESA|TIPO_CONTRATO|CONTRATO|NOME|DATA|TIPO_DIA_CALENDARIO|COD_CARGO_COMISS|CARGO_COMISSIONADO|COD_CARGO_EFETIVO|CARGO_EFETIVO|CODIGO_FUNCAO|FUNCAO|COD_LOCAL1|COD_LOCAL2|COD_LOCAL3|COD_LOCAL4|COD_LOCAL5|COD_LOCAL6|LOCAL|CLASSIFICACAO_LOCAL|vCARGO_PODE_VERBA'
AS LINHA FROM DUAL UNION ALL

--SELECT X2.CENARIO, COUNT(1)QUANT FROM (  --SINTETICO
SELECT X2.CENARIO ||'|'||X2.CODIGO_EMPRESA||'|'||X2.TIPO_CONTRATO||'|'||X2.CODIGO_CONTRATO||'|'||X2.DATA||'|'|| X2.CODIGO_SITUACAO||'|'|| X2.SITUACAO_PONTO||'|'||X2.REFERENCIA||'|'||X2.LOGIN_USUARIO||'|'||X2.DT_ULT_ALTER_USUA||'|'||X2.TIPO_APURACAO||'|'||X2.EMPRESA||'|'|| X2.TIPO_CONTR||'|'|| X2.MATRICULA||'|'||TO_DATE(SUBSTR(X2.DATA_ESPELHO,1,10),'DD/MM/RRRR')||'|'||X2.CONSIDERACOES AS LINHA

FROM(
SELECT 
CASE
WHEN SP.CODIGO_EMPRESA IS NOT NULL THEN '1-GEROU SIT PONTO'
WHEN SP.CODIGO_EMPRESA IS NULL     THEN '2-NAO GEROU SIT PONTO'
ELSE 'NAO GEROU SIT PONTO, NAO_MAPEADO_AINDA'
END CENARIO,
SP.CODIGO_EMPRESA, SP.TIPO_CONTRATO, SP.CODIGO_CONTRATO, SP.DATA, SP.CODIGO_SITUACAO, SP.SITUACAO_PONTO, SP.REFERENCIA, SP.LOGIN_USUARIO, SP.DT_ULT_ALTER_USUA, SP.TIPO_APURACAO
--, X.CONSIDERACOES AS LINHA
,X.CODIGO_EMPRESA EMPRESA, X.TIPO_CONTRATO TIPO_CONTR, X.CODIGO_CONTRATO MATRICULA , TO_DATE(SUBSTR(X.CAMPO_2,1,10),'DD/MM/RRRR')DATA_ESPELHO
, X.CAMPO_3 PREVIA_PROCESSO, X.CAMPO_4 RESULTADO_FINAL_PROCESSAMENTO, X.CAMPO_5 vQTD_LOCAIS_PODE_VERBA, 
X.CAMPO_6 ORIGEM_MARCACAO_ENTRADA, X.CAMPO_7 EFETIVADO_ENTRADA, X.CAMPO_8 ORIGEM_MARCACAO_SAIDA, X.CAMPO_9 EFETIVADO_SAIDA
,X.CONSIDERACOES
FROM PONTO_ELETRONICO.IFPONTO_FECHAMENTO_LOG_RELAT X 
--/*
LEFT OUTER JOIN 
(

SELECT D.CODIGO_EMPRESA, D.TIPO_CONTRATO, D.CODIGO_CONTRATO, D.DATA, D.CODIGO_SITUACAO, SP.DESCRICAO SITUACAO_PONTO, D.REF_HORAS REFERENCIA, D.LOGIN_USUARIO, D.DT_ULT_ALTER_USUA, D.TIPO_APURACAO
FROM ARTERH.RHPONT_RES_SIT_DIA D
LEFT OUTER JOIN ARTERH.RHPONT_SITUACAO SP ON SP.CODIGO = D.CODIGO_SITUACAO
WHERE 
D.login_usuario = 'IFPONTO' AND 
TRUNC(D.DATA) BETWEEN TO_DATE(vDATA_INICIO,'DD/MM/YY') AND TO_DATE(vDATA_FIM,'DD/MM/YY')-------------------------------trocar datas
AND TRUNC(D.DT_ULT_ALTER_USUA) >= TRUNC(SYSDATE) --TO_DATE('11/10/2021','DD/MM/YYYY')--
and d.codigo_situacao IN ('1193')--17.391>18.344

)SP ON SP.CODIGO_EMPRESA = X.CODIGO_EMPRESA AND  SP.TIPO_CONTRATO = X.TIPO_CONTRATO AND SP.CODIGO_CONTRATO = X.CODIGO_CONTRATO
AND TO_DATE(SP.DATA,'DD/MM/RRRR') = TO_DATE(SUBSTR(X.CAMPO_2,1,10),'DD/MM/RRRR') 
--*/
WHERE TRUNC(DATA_DADOS) =  TRUNC(SYSDATE) --TO_DATE('11/12/2021','DD/MM/YYYY')
AND CAMPO_1 ='PRG6_DATA_ESPECIAL_SMSA'
AND X.CODIGO_EMPRESA IS NOT NULL


)X2 
--SINTETICO 
--GROUP BY X2.CENARIO ORDER BY X2.CENARIO--SINTETICO

--/*
)

LOOP

vCONTADOR :=vCONTADOR+1;
dbms_output.put_line('--vCONTADOR: '||vCONTADOR||' C1.LINHA: '||C1.LINHA);
INSERT INTO PONTO_ELETRONICO.IFPONTO_FECHAMENTO_LOG_RELAT (DATA_DADOS, CAMPO_1, CONSIDERACOES)VALUES(SYSDATE,'PRR_DATA_ESPECIAL_SMSA',C1.LINHA);COMMIT;

END LOOP;

END;
--*/

END;