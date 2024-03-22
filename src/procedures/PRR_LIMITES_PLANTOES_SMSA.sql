
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PRR_LIMITES_PLANTOES_SMSA" (DATA_INICIO IN DATE, DATA_FIM IN DATE) AS
BEGIN

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
SELECT 'X3.CENARIO|LIMITE_HORAS_MES|ORDEM_BM_DIA|TIPO|REFERENCIA|PROXIMO_TIPO|PROXIMA_REFERENCIA|CODIGO_EMPRESA|TIPO_CONTRATO|CODIGO_CONTRATO|NOME|CODIGO_ESCALA|TOTAL_MINUTOS|TIPO_CARGA_JORNADA|COD_CARGO_EFETIVO|CARGO_EFETIVO|COD_CARGO_COMISS|CODIGO_FUNCAO|TIPO_LOCAL_SMSA|COD_CGERENC1|COD_CGERENC2|COD_CGERENC3|COD_CGERENC4|COD_CGERENC5|COD_CGERENC6|LOCAL' 
AS LINHA FROM DUAL 
UNION ALL
SELECT 
X3.CENARIO||'|'|| X3.LIMITE_HORAS_MES||'|'|| X3.ORDEM_BM_DIA||'|'|| X3.TIPO||'|'|| X3.REFERENCIA||'|'|| X3.PROXIMO_TIPO||'|'|| X3.PROXIMA_REFERENCIA||'|'|| X3.CODIGO_EMPRESA||'|'|| X3.TIPO_CONTRATO||'|'|| X3.CODIGO_CONTRATO||'|'|| X3.NOME||'|'|| X3.CODIGO_ESCALA||'|'|| X3.TOTAL_MINUTOS||'|'|| X3.TIPO_CARGA_JORNADA||'|'|| X3.COD_CARGO_EFETIVO||'|'|| X3.CARGO_EFETIVO||'|'|| X3.COD_CARGO_COMISS||'|'|| X3.CODIGO_FUNCAO||'|'|| X3.TIPO_LOCAL_SMSA||'|'|| X3.COD_CGERENC1||'|'|| X3.COD_CGERENC2||'|'|| X3.COD_CGERENC3||'|'|| X3.COD_CGERENC4||'|'|| X3.COD_CGERENC5||'|'|| X3.COD_CGERENC6||'|'|| X3.LOCAL
AS LINHA
FROM(
--*************************************************trocar datas
SELECT 
CASE 
WHEN X2.TIPO = 'DIAS_PLANTOES' AND X2.REFERENCIA > 8 THEN 'LIMITE_DE_PLANTOES_ULTRAPASSOU_NO_MES'
WHEN X2.TIPO = 'SOMA_HORAS_EXTRAS' AND X2.REFERENCIA > X2.LIMITE_HORAS_MES THEN 'LIMITE_DE_HORAS_EXTRAS_ULTRAPASSOU_NO_MES'
WHEN X2.PROXIMO_TIPO = 'SOMA_HORAS_EXTRAS' AND X2.PROXIMA_REFERENCIA > X2.LIMITE_HORAS_MES THEN 'LIMITE_DE_HORAS_EXTRAS_ULTRAPASSOU_NO_MES'
ELSE 'LIMITES_OK'
END CENARIO,
X2.* FROM(
SELECT 
ROUND(TO_NUMBER(J.c_livre_selec01)/60/7*31/2,2) LIMITE_HORAS_MES,--------------MUDAR TOTAL DIAS DO MES SE SAO 31,30,29 OU 28 DIAS
ROW_NUMBER() OVER(PARTITION BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.TIPO) ORDEM_BM_DIA,
X.TIPO,
X.REFERENCIA,
LEAD(X.TIPO,1,NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.TIPO) PROXIMO_TIPO,
LEAD(X.REFERENCIA,1,NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.TIPO) PROXIMA_REFERENCIA,
X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO,
b.nome,
b.codigo_escala, J.c_livre_selec01 TOTAL_MINUTOS, J.c_livre_descr02 TIPO_CARGA_JORNADA,
b.cod_cargo_efetivo, ce.descricao cargo_efetivo,
b.cod_cargo_comiss, B.codigo_funcao, GN.c_livre_selec10 TIPO_LOCAL_SMSA, GN.COD_CGERENC1, GN.COD_CGERENC2, GN.COD_CGERENC3, GN.COD_CGERENC4, GN.COD_CGERENC5, GN.COD_CGERENC6, GN.DESCRICAO LOCAL
---INICIO---- SITUACOES PONTOS LANCADAS
FROM(
---inicio--parte dos plantoes de 12h
SELECT P.* FROM(
SELECT 'DIAS_PLANTOES' TIPO, D.CODIGO_EMPRESA, D.TIPO_CONTRATO, D.CODIGO_CONTRATO, count(1)REFERENCIA--D.DATA, D.CODIGO_SITUACAO, SP.DESCRICAO SITUACAO_PONTO, D.REF_HORAS REFERENCIA, D.LOGIN_USUARIO, D.DT_ULT_ALTER_USUA, D.TIPO_APURACAO
FROM ARTERH.RHPONT_RES_SIT_DIA D
LEFT OUTER JOIN ARTERH.RHPONT_SITUACAO SP ON SP.CODIGO = D.CODIGO_SITUACAO
WHERE 
--D.login_usuario = 'IFPONTO' AND
TRUNC(D.DATA) BETWEEN TO_DATE('01/11/22','DD/MM/YY') AND TO_DATE('30/11/22','DD/MM/YY')-------------------------------trocar datas
--AND TRUNC(D.DT_ULT_ALTER_USUA) >= TRUNC(SYSDATE)--TO_DATE('11/12/2021','DD/MM/YYYY')--TRUNC(SYSDATE)
and d.codigo_situacao IN ('1019','1020','1017','1021','1018')
group by  D.CODIGO_EMPRESA, D.TIPO_CONTRATO, D.CODIGO_CONTRATO
--order by count(1)desc, D.CODIGO_EMPRESA, D.TIPO_CONTRATO, D.CODIGO_CONTRATO
)P
---fim--parte dos plantoes de 12h
UNION ALL
---inicio--parte das horas extras menos que 11h30
SELECT H.* FROM(
SELECT 'SOMA_HORAS_EXTRAS' TIPO, D.CODIGO_EMPRESA, D.TIPO_CONTRATO, D.CODIGO_CONTRATO, sum(D.REF_HORAS)REFERENCIA--D.DATA, D.CODIGO_SITUACAO, SP.DESCRICAO SITUACAO_PONTO, D.REF_HORAS REFERENCIA, D.LOGIN_USUARIO, D.DT_ULT_ALTER_USUA, D.TIPO_APURACAO
FROM ARTERH.RHPONT_RES_SIT_DIA D
LEFT OUTER JOIN ARTERH.RHPONT_SITUACAO SP ON SP.CODIGO = D.CODIGO_SITUACAO
WHERE 
--D.login_usuario = 'IFPONTO' AND
TRUNC(D.DATA) BETWEEN TO_DATE('01/11/22','DD/MM/YY') AND TO_DATE('30/11/22','DD/MM/YY')-------------------------------trocar datas
--AND TRUNC(D.DT_ULT_ALTER_USUA) >= TRUNC(SYSDATE)--TO_DATE('11/12/2021','DD/MM/YYYY')--TRUNC(SYSDATE)
and d.codigo_situacao IN ('1026')
group by  D.CODIGO_EMPRESA, D.TIPO_CONTRATO, D.CODIGO_CONTRATO
--order by count(1)desc, D.CODIGO_EMPRESA, D.TIPO_CONTRATO, D.CODIGO_CONTRATO
)H
---fim--parte das horas extras menos que 11h30
)X 
---FIM---- SITUACOES PONTOS LANCADAS
LEFT OUTER JOIN ARTERH.RHPESS_CONTRATO B ON X.CODIGO_EMPRESA = B.CODIGO_EMPRESA AND X.TIPO_CONTRATO = B.TIPO_CONTRATO AND X.CODIGO_CONTRATO = B.CODIGO
LEFT OUTER JOIN ARTERH.RHORGA_CUSTO_GEREN GN ON B.CODIGO_EMPRESA = GN.CODIGO_EMPRESA AND B.COD_CUSTO_GERENC1 = GN.cod_cgerenc1 AND B.COD_CUSTO_GERENC2 = GN.cod_cgerenc2 AND B.COD_CUSTO_GERENC3 = GN.cod_cgerenc3
AND B.COD_CUSTO_GERENC4 = GN.cod_cgerenc4 AND B.COD_CUSTO_GERENC5 = GN.cod_cgerenc5 AND B.COD_CUSTO_GERENC6 = GN.cod_cgerenc6
left outer join ARTERH.RHPLCS_CARGO C ON c.CODIGO_EMPRESA = B.CODIGO_EMPRESA AND c.CODIGO = b.cod_cargo_comiss
left outer join ARTERH.RHPLCS_CARGO CE ON Ce.CODIGO_EMPRESA = B.CODIGO_EMPRESA AND Ce.CODIGO = b.cod_cargo_efetivo
LEFT OUTER JOIN ARTERH.RHPONT_ESCALA E ON E.CODIGO_EMPRESA = B.CODIGO_EMPRESA AND E.CODIGO = B.CODIGO_ESCALA
LEFT OUTER JOIN ARTERH.RHPONT_TP_JORNADA J ON J.CODIGO = E.TIPO_JORNADA
WHERE 
B.ANO_MES_REFERENCIA = (SELECT MAX(AUX.ANO_MES_REFERENCIA) FROM ARTERH.RHPESS_CONTRATO AUX WHERE AUX.CODIGO_EMPRESA = B.CODIGO_EMPRESA AND AUX.TIPO_CONTRATO = B.TIPO_CONTRATO AND AUX.CODIGO = B.CODIGO) 
ORDER BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.TIPO
)X2 
WHERE X2.ORDEM_BM_DIA = 1 --1228>1126

)X3


)LOOP

vCONTADOR :=vCONTADOR+1;
dbms_output.put_line('--vCONTADOR: '||vCONTADOR||' C1.LINHA: '||C1.LINHA);
INSERT INTO PONTO_ELETRONICO.IFPONTO_FECHAMENTO_LOG_RELAT (DATA_DADOS, CAMPO_1, CONSIDERACOES)VALUES(SYSDATE,'PRR_LIMITES_PLANTOES_SMSA',C1.LINHA);COMMIT;

END LOOP;

END;

END;