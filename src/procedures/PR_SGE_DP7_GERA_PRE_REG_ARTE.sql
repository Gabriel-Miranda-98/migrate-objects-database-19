
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PR_SGE_DP7_GERA_PRE_REG_ARTE" (DATA_INICIO IN DATE)
AS 
BEGIN 

--Kellysson em 19/1/24 baseado (sql_gera_pre_DE_PARA_EXTENSOES_2023_b2.sql)

--Kellysson em 5/9/23 b2 (sql_gera_pre_DE_PARA_EXTENSOES_2023_b2.sql) para ajuste DATA_INICIO_U E DATA_FIM_U pARA INICIO_JORNADA_U e FIM_JORNADA_U
--Kellysson novo em 11/8/23
DECLARE 
vCONTADOR NUMBER;
vINICIO_SEQUENCIA NUMBER;
vB BOOLEAN := TRUE;
vDATA_INICIO DATE;

BEGIN
dbms_output.enable(null);
vCONTADOR :=0;
vINICIO_SEQUENCIA :=0;
vDATA_INICIO := DATA_INICIO;

FOR C1 IN (

--SELECT ANTES_HORARIOS_SEQUENCIAIS, HORARIOS_SEQUENCIAIS, DEPOIS_HORARIOS_SEQUENCIAIS, COUNT(1) FROM (
--SELECT cpf, COUNT(1) FROM (
--SELECT id_horario, COUNT(1) FROM (
--SELECT COUNT(1) FROM (

SELECT X6.*
, CASE WHEN X6.PROXIMO_INICIO_MINUTOS < X6.FIM_MINUTOS THEN 'SIM' ELSE 'NAO' END CONCOMITA 
,CASE
WHEN X6.ANTES_HORARIOS_SEQUENCIAIS IS NULL AND X6.HORARIOS_SEQUENCIAIS = 'NAO' AND X6.DEPOIS_HORARIOS_SEQUENCIAIS IS NULL THEN '01-APENAS 1 REGISTRO NO turno, já INSERT com C1.INICIO_MINUTOS e C1.FIM_MINUTOS'
WHEN X6.ANTES_HORARIOS_SEQUENCIAIS IS NULL AND X6.HORARIOS_SEQUENCIAIS = 'NAO' AND X6.DEPOIS_HORARIOS_SEQUENCIAIS = 'NAO' THEN '12-1º reg turno, A PRINCIPIO CONCOMITA com o cenarhio 8 mas INSERT  com C1.INICIO_MINUTOS e C1.FIM_MINUTOS'
WHEN X6.ANTES_HORARIOS_SEQUENCIAIS IS NULL AND X6.HORARIOS_SEQUENCIAIS = 'NAO' AND X6.DEPOIS_HORARIOS_SEQUENCIAIS = 'SIM' THEN '09-1º reg turno, não sequencial já INSERT com C1.INICIO_MINUTOS e C1.FIM_MINUTOS'
WHEN X6.ANTES_HORARIOS_SEQUENCIAIS IS NULL AND X6.HORARIOS_SEQUENCIAIS = 'SIM' AND X6.DEPOIS_HORARIOS_SEQUENCIAIS = 'NAO' THEN '02-1º reg turno, seqeuencia mas já acaba a seq no reg seguinte, 1º PARA INSERT com C1.INICIO_MINUTOS e C1.PROXIMO_FIM_MINUTOS'
WHEN X6.ANTES_HORARIOS_SEQUENCIAIS IS NULL AND X6.HORARIOS_SEQUENCIAIS = 'SIM' AND X6.DEPOIS_HORARIOS_SEQUENCIAIS = 'SIM' THEN '04-1º reg turno, sequencia mas o proximo tambem segue a seq, guardar variavel vINICIO_MINUTOS'
WHEN X6.ANTES_HORARIOS_SEQUENCIAIS = 'SIM' AND X6.HORARIOS_SEQUENCIAIS = 'NAO' AND X6.DEPOIS_HORARIOS_SEQUENCIAIS = 'NAO' THEN '07-<> 1º reg turno, sendo o ultimo de uma sequencia, onde já finalizou a seq com o reg anterior, não inserir'
WHEN X6.ANTES_HORARIOS_SEQUENCIAIS = 'SIM' AND X6.HORARIOS_SEQUENCIAIS = 'NAO' AND X6.DEPOIS_HORARIOS_SEQUENCIAIS IS NULL THEN '03-<> 1º reg turno, sendo o ultimo de uma sequencia, onde já finalizou a seq com o reg anterior, não inserir'
WHEN X6.ANTES_HORARIOS_SEQUENCIAIS = 'SIM' AND X6.HORARIOS_SEQUENCIAIS = 'SIM' AND X6.DEPOIS_HORARIOS_SEQUENCIAIS = 'NAO' THEN '05-<> 1º reg turno, sendo o penultimo de uma sequencia, finalizar usando  vINICIO_MINUTOS e para o fim C1.PROXIMO_FIM_MINUTOS'
WHEN X6.ANTES_HORARIOS_SEQUENCIAIS = 'SIM' AND X6.HORARIOS_SEQUENCIAIS = 'SIM' AND X6.DEPOIS_HORARIOS_SEQUENCIAIS = 'SIM' THEN '06-reg meio de uma sequencia não fazer nada'
WHEN X6.ANTES_HORARIOS_SEQUENCIAIS = 'NAO' AND X6.HORARIOS_SEQUENCIAIS = 'NAO' AND X6.DEPOIS_HORARIOS_SEQUENCIAIS IS NULL THEN '08-ultimo reg do turno sendo um reg não sequencial, INSERT com C1.INICIO_MINUTOS e C1.FIM_MINUTOS'
WHEN X6.ANTES_HORARIOS_SEQUENCIAIS = 'NAO' AND X6.HORARIOS_SEQUENCIAIS = 'SIM' AND X6.DEPOIS_HORARIOS_SEQUENCIAIS = 'NAO' THEN '10-<> 1º reg turno, sendo o primeiro deuma sequencia que já se acaba, INSERT  com C1.INICIO_MINUTOS e C1.PROXIMO_FIM_MINUTOS'
END CENARIO
FROM (SELECT 
X5.ID_JORNADA_U, X5.JORNADA, X5.COORDENACAO_U, X5.TURNO_U, X5.DURACAO_AULA_U, X5.CARGA_HORARIA, X5.INICIO_JORNADA_U, X5.FIM_JORNADA_U, X5.DT_CANCELAMENTO_USAR_U, 
LAG(X5.HORARIOS_SEQUENCIAIS, 1, NULL) OVER(PARTITION BY X5.CPF, X5.ID_HORARIO, X5.NRO_DIA_SEMANA ORDER BY X5.CPF, X5.ID_HORARIO, X5.NRO_DIA_SEMANA, X5.INICIO_TURNO, X5.INICIO_MINUTOS )ANTES_HORARIOS_SEQUENCIAIS, 
X5.HORARIOS_SEQUENCIAIS,
LEAD(X5.HORARIOS_SEQUENCIAIS, 1, NULL) OVER(PARTITION BY X5.CPF, X5.ID_HORARIO, X5.NRO_DIA_SEMANA ORDER BY X5.CPF, X5.ID_HORARIO, X5.NRO_DIA_SEMANA, X5.INICIO_TURNO, X5.INICIO_MINUTOS )DEPOIS_HORARIOS_SEQUENCIAIS, 
X5.CPF, X5.ID_HORARIO, X5.NRO_DIA_SEMANA, X5.INICIO_TURNO, X5.INICIO_MINUTOS, X5.FIM_MINUTOS, X5.TOTAL_MINUTOS, X5.QTD_SEMANAS, X5.ORDEM_ID_HORARIO_GERAL, X5.ORDEM_ID_HORARIO_MESMO_DIA_SEMANA, X5.ORDEM_ID_HORARIO_MESMO_DIA_TURNO, 
X5.PROXIMO_ID_HORARIO, X5.PROXIMO_INICIO_MINUTOS, X5.PROXIMO_FIM_MINUTOS, X5.PROXIMO_ORDEM_ID_HORARIO_GERAL, X5.PROXIMO_ORDEM_ID_HORARIO_MESMO_DIA_TURNO 
FROM (
SELECT 
A.ID_JORNADA_U, A.JORNADA, A.COORDENACAO_U, A.TURNO_U, A.DURACAO_AULA_U, A.CARGA_HORARIA, A.INICIO_JORNADA_U, A.FIM_JORNADA_U, A.DT_CANCELAMENTO_USAR_U, 
CASE WHEN X4.FIM_MINUTOS = X4.PROXIMO_INICIO_MINUTOS THEN 'SIM' ELSE 'NAO' END HORARIOS_SEQUENCIAIS, 
X4.CPF, X4.ID_HORARIO, X4.NRO_DIA_SEMANA, X4.INICIO_TURNO, X4.INICIO_MINUTOS, X4.FIM_MINUTOS, X4.TOTAL_MINUTOS, 
X4.QTD_SEMANAS, 
                                                          X4.ORDEM_ID_HORARIO_GERAL, X4.ORDEM_ID_HORARIO_MESMO_DIA_SEMANA, X4.ORDEM_ID_HORARIO_MESMO_DIA_TURNO, 
X4.PROXIMO_ID_HORARIO, X4.PROXIMO_INICIO_MINUTOS, X4.PROXIMO_FIM_MINUTOS, X4.PROXIMO_ORDEM_ID_HORARIO_GERAL,                               X4.PROXIMO_ORDEM_ID_HORARIO_MESMO_DIA_TURNO
FROM(
SELECT 
LEAD(X3.ID_HORARIO, 1, NULL) OVER(PARTITION BY X3.CPF, X3.ID_HORARIO ORDER BY X3.CPF, X3.ID_HORARIO, X3.NRO_DIA_SEMANA, X3.INICIO_TURNO, X3.INICIO_MINUTOS ) PROXIMO_ID_HORARIO,
LEAD(X3.INICIO_MINUTOS, 1, NULL) OVER(PARTITION BY X3.CPF, X3.ID_HORARIO, X3.NRO_DIA_SEMANA, X3.INICIO_TURNO ORDER BY X3.CPF, X3.ID_HORARIO, X3.NRO_DIA_SEMANA, X3.INICIO_TURNO, X3.INICIO_MINUTOS ) PROXIMO_INICIO_MINUTOS,
LEAD(X3.FIM_MINUTOS, 1, NULL) OVER(PARTITION BY X3.CPF, X3.ID_HORARIO, X3.NRO_DIA_SEMANA, X3.INICIO_TURNO ORDER BY X3.CPF, X3.ID_HORARIO, X3.NRO_DIA_SEMANA, X3.INICIO_TURNO, X3.INICIO_MINUTOS ) PROXIMO_FIM_MINUTOS,
LEAD(X3.ORDEM_ID_HORARIO_GERAL, 1, NULL) OVER(PARTITION BY X3.CPF, X3.ID_HORARIO ORDER BY X3.CPF, X3.ID_HORARIO, X3.NRO_DIA_SEMANA, X3.INICIO_TURNO, X3.INICIO_MINUTOS ) PROXIMO_ORDEM_ID_HORARIO_GERAL,
LEAD(X3.ORDEM_ID_HORARIO_MESMO_DIA_TURNO, 1, NULL) OVER(PARTITION BY X3.CPF, X3.ID_HORARIO, X3.NRO_DIA_SEMANA, X3.INICIO_TURNO ORDER BY X3.CPF, X3.ID_HORARIO, X3.NRO_DIA_SEMANA, X3.INICIO_TURNO, X3.INICIO_MINUTOS ) PROXIMO_ORDEM_ID_HORARIO_MESMO_DIA_TURNO,
X3.* FROM (
SELECT 
ROW_NUMBER() OVER(PARTITION BY CPF, ID_HORARIO ORDER BY CPF, ID_HORARIO, NRO_DIA_SEMANA, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TOTAL_MINUTOS--, TIPO_MARCACAO, OBS_PROCESSAMENTO
) ORDEM_ID_HORARIO_GERAL,
ROW_NUMBER() OVER(PARTITION BY CPF, ID_HORARIO, NRO_DIA_SEMANA ORDER BY CPF, ID_HORARIO, NRO_DIA_SEMANA, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TOTAL_MINUTOS--, TIPO_MARCACAO, OBS_PROCESSAMENTO 
) ORDEM_ID_HORARIO_MESMO_DIA_SEMANA,
ROW_NUMBER() OVER(PARTITION BY CPF, ID_HORARIO, NRO_DIA_SEMANA, INICIO_TURNO ORDER BY CPF, ID_HORARIO, NRO_DIA_SEMANA, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TOTAL_MINUTOS--, TIPO_MARCACAO, OBS_PROCESSAMENTO
) ORDEM_ID_HORARIO_MESMO_DIA_TURNO,
CPF, ID_HORARIO, NRO_DIA_SEMANA, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TOTAL_MINUTOS, --TIPO_MARCACAO, OBS_PROCESSAMENTO,
COUNT(1)QTD_SEMANAS FROM (--MONTAR DE/PARA POR ID_JORNADA

--SELECT TIPO_MARCACAO, HORARIOS_SEQUENCIAIS, CONCOMITA, ANTES_INICIO_TURNO, DEPOIS_FIM_TURNO, FIM_MENOR_INICIO, COUNT(1)QTD FROM (--SINTETTICO
SELECT --ANALITICO
CASE WHEN X2.FIM_MINUTOS = X2.PROXIMO_INICIO_MINUTOS THEN 'SIM' ELSE 'NAO' END HORARIOS_SEQUENCIAIS,
X2.*, CASE WHEN X2.PROXIMO_INICIO_MINUTOS < X2.FIM_MINUTOS THEN 'SIM' ELSE 'NAO' END CONCOMITA FROM( 
SELECT 
ROW_NUMBER() OVER(PARTITION BY X.CPF, X.DATA, X.INICIO_TURNO ORDER BY X.CPF, X.DATA, X.INICIO_TURNO, X.INICIO_MINUTOS, X.FIM_MINUTOS ) ORDEM_NO_DIA_TURNO,
X.CPF, X.DATA, D.NRO_DIA_SEMANA, X.ID_HORARIO, X.INICIO_TURNO, 
X.INICIO_MINUTOS, 
--X.FIM_MINUTOS, 
CASE WHEN A.TURNO_U = 'INTEGRAL' AND X.INICIO_MINUTOS = X.INICIO_TURNO+270 AND X.TOTAL_MINUTOS = 90 THEN X.FIM_MINUTOS+45 ELSE X.FIM_MINUTOS END FIM_MINUTOS,  
--X.TOTAL_MINUTOS, 
CASE WHEN A.TURNO_U = 'INTEGRAL' AND X.INICIO_MINUTOS = X.INICIO_TURNO+270 AND X.TOTAL_MINUTOS = 90 THEN X.TOTAL_MINUTOS+45 ELSE X.TOTAL_MINUTOS END TOTAL_MINUTOS, 
X.TIPO_MARCACAO, X.OBS_PROCESSAMENTO,
LEAD(X.INICIO_MINUTOS, 1, NULL) OVER(PARTITION BY X.CPF, X.DATA, X.INICIO_TURNO ORDER BY X.CPF, X.DATA, X.INICIO_TURNO, X.INICIO_MINUTOS, X.FIM_MINUTOS ) PROXIMO_INICIO_MINUTOS,
LEAD(X.OBS_PROCESSAMENTO, 1, NULL) OVER(PARTITION BY X.CPF, X.DATA, X.INICIO_TURNO ORDER BY X.CPF, X.DATA, X.INICIO_TURNO, X.INICIO_MINUTOS, X.FIM_MINUTOS ) PROXIMO_OBS_PROCESSAMENTO,
CASE WHEN X.INICIO_MINUTOS < X.INICIO_TURNO OR  X.FIM_MINUTOS < X.INICIO_TURNO THEN 'SIM' ELSE 'NAO' END ANTES_INICIO_TURNO,
CASE WHEN X.INICIO_MINUTOS > X.INICIO_TURNO+270 OR  X.FIM_MINUTOS > X.INICIO_TURNO+270 THEN 'SIM' ELSE 'NAO' END DEPOIS_FIM_TURNO,
CASE WHEN X.FIM_MINUTOS < X.INICIO_MINUTOS THEN 'SIM' ELSE 'NAO' END FIM_MENOR_INICIO
FROM PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES X 
LEFT OUTER JOIN ARTERH.RHTABS_DATAS D ON TRUNC(D.DATA_DIA) = TRUNC(X.DATA)
--LEFT OUTER JOIN     (SELECT FROM PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES WHERE TRUNC(DATA_PROCESSAMENTO)= TRUNC(SYSDATE)    )TH

LEFT OUTER JOIN(
    SELECT P.CPF, A.* FROM(SELECT * FROM PONTO_ELETRONICO.SUGESP_SGE_JORNADAS_AJUSTES A WHERE TRUNC(A.DATA_PROCESSAMENTO) = (SELECT MAX(TRUNC(DATA_PROCESSAMENTO)) FROM PONTO_ELETRONICO.SUGESP_SGE_JORNADAS_AJUSTES WHERE TIPO_REGISTRO = 'DE/PARA_EXTENSOES_2023' 
    AND TO_DATE(DATA_INICIO_U,'DD/MM/YYYY')>=  TO_DATE(vDATA_INICIO,'DD/MM/YYYY')--NOVO A PARTIR DE 2024
    )
    )A LEFT OUTER JOIN (SELECT M.CODIGO_EMPRESA, M.TIPO_CONTRATO, M.CODIGO_CONTRATO, M.CODIGO_PESSOA, P.CPF FROM ARTERH.RHPESS_CONTR_MEST M LEFT OUTER JOIN ARTERH.RHPESS_PESSOA P ON P.CODIGO_EMPRESA = M.CODIGO_EMPRESA AND P.CODIGO = M.CODIGO_PESSOA)P
    ON P.CODIGO_EMPRESA = '0001' AND P.TIPO_CONTRATO = '0001' AND P.CODIGO_CONTRATO = A.BM_U
    )A ON A.ID_HORARIO = X.ID_HORARIO

WHERE TRUNC(X.DATA_PROCESSAMENTO)= TRUNC(SYSDATE) AND X.TIPO_MARCACAO IN('EXTRA_USADA','REGENCIA')
AND X.TOTAL_MINUTOS <> 0-----TIRAR REGISTROS ZERADOS DO PASSO 6
AND TRUNC(X.DATA) BETWEEN TO_DATE(A.INICIO_JORNADA_U,'DD/MM/YYYY') AND TO_DATE(A.FIM_JORNADA_U,'DD/MM/YYYY')----------TENTANDO TIRAR ERROS DA REGRA2
AND X.TIPO_REGISTRO = 'DE/PARA_EXTENSOES_2023'
ORDER BY X.CPF, X.DATA, X.INICIO_TURNO, X.INICIO_MINUTOS, X.FIM_MINUTOS 
)X2 --ANALITICO
--)GROUP BY TIPO_MARCACAO, HORARIOS_SEQUENCIAIS, CONCOMITA, ANTES_INICIO_TURNO, DEPOIS_FIM_TURNO, FIM_MENOR_INICIO ORDER BY TIPO_MARCACAO, HORARIOS_SEQUENCIAIS, CONCOMITA, ANTES_INICIO_TURNO, DEPOIS_FIM_TURNO, FIM_MENOR_INICIO --SINTETTICO

)GROUP BY CPF, ID_HORARIO, NRO_DIA_SEMANA, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TOTAL_MINUTOS--, TIPO_MARCACAO, OBS_PROCESSAMENTO 
 ORDER BY CPF, ID_HORARIO, NRO_DIA_SEMANA, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TOTAL_MINUTOS--, TIPO_MARCACAO, OBS_PROCESSAMENTO --MONTAR DE/PARA POR ID_JORNADA
)X3 ORDER BY X3.CPF, X3.ID_HORARIO, X3.NRO_DIA_SEMANA, X3.INICIO_TURNO, X3.INICIO_MINUTOS
)X4 
LEFT OUTER JOIN(
    SELECT P.CPF, A.* FROM(SELECT * FROM PONTO_ELETRONICO.SUGESP_SGE_JORNADAS_AJUSTES A WHERE TRUNC(A.DATA_PROCESSAMENTO) = (SELECT MAX(TRUNC(DATA_PROCESSAMENTO)) FROM PONTO_ELETRONICO.SUGESP_SGE_JORNADAS_AJUSTES WHERE TIPO_REGISTRO = 'DE/PARA_EXTENSOES_2023'
    AND TO_DATE(DATA_INICIO_U,'DD/MM/YYYY')>=  TO_DATE(vDATA_INICIO,'DD/MM/YYYY')--NOVO A PARTIR DE 2024
    )
    )A LEFT OUTER JOIN (SELECT M.CODIGO_EMPRESA, M.TIPO_CONTRATO, M.CODIGO_CONTRATO, M.CODIGO_PESSOA, P.CPF FROM ARTERH.RHPESS_CONTR_MEST M LEFT OUTER JOIN ARTERH.RHPESS_PESSOA P ON P.CODIGO_EMPRESA = M.CODIGO_EMPRESA AND P.CODIGO = M.CODIGO_PESSOA)P
    ON P.CODIGO_EMPRESA = '0001' AND P.TIPO_CONTRATO = '0001' AND P.CODIGO_CONTRATO = A.BM_U
    )A ON A.ID_HORARIO = X4.ID_HORARIO
ORDER BY X4.CPF, X4.ID_HORARIO, X4.NRO_DIA_SEMANA, X4.INICIO_TURNO, X4.INICIO_MINUTOS

)X5 ORDER BY X5.CPF, X5.ID_HORARIO, X5.NRO_DIA_SEMANA, X5.INICIO_TURNO, X5.INICIO_MINUTOS

)X6
--WHERE X6.TURNO_U = 'INTEGRAL' ---TESTES

--)--count-- SEM TOTAL_MINUTOS <> 0 11.797, COM TOTAL_MINUTOS <> 0 11.743, TENTANDO TIRAR ERROS DA REGRA2 > 11.547
--)group by id_horario
--)group by cpf
--)GROUP BY ANTES_HORARIOS_SEQUENCIAIS, HORARIOS_SEQUENCIAIS, DEPOIS_HORARIOS_SEQUENCIAIS ORDER BY HORARIOS_SEQUENCIAIS, ANTES_HORARIOS_SEQUENCIAIS, DEPOIS_HORARIOS_SEQUENCIAIS


)LOOP
vCONTADOR := vCONTADOR +1;
dbms_output.put_line('--vCONTADOR: '||vCONTADOR);

IF SUBSTR(C1.CENARIO,1,2) = '01' THEN
INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, NRO_DIA_SEMANA, ID_HORARIO, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TOTAL_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO, TIPO_REGISTRO)
VALUES(C1.CPF, C1.NRO_DIA_SEMANA, C1.ID_HORARIO, C1.INICIO_TURNO, C1.INICIO_MINUTOS, C1.FIM_MINUTOS, C1.FIM_MINUTOS-C1.INICIO_MINUTOS,'PRE_DE_PARA', SYSDATE, '01-APENAS 1 REGISTRO NO turno, ja INSERT com C1.INICIO_MINUTOS e C1.FIM_MINUTOS', 'DE/PARA_EXTENSOES_2023' );COMMIT;

ELSIF SUBSTR(C1.CENARIO,1,2) = '12' THEN
INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, NRO_DIA_SEMANA, ID_HORARIO, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TOTAL_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO, TIPO_REGISTRO)
VALUES(C1.CPF, C1.NRO_DIA_SEMANA, C1.ID_HORARIO, C1.INICIO_TURNO, C1.INICIO_MINUTOS, C1.FIM_MINUTOS, C1.FIM_MINUTOS-C1.INICIO_MINUTOS,'PRE_DE_PARA', SYSDATE, '12-1º reg turno, A PRINCIPIO CONCOMITA com o cenario 8 mas INSERT com C1.INICIO_MINUTOS e C1.FIM_MINUTOS', 'DE/PARA_EXTENSOES_2023' );COMMIT;

ELSIF SUBSTR(C1.CENARIO,1,2) = '09' THEN
INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, NRO_DIA_SEMANA, ID_HORARIO, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TOTAL_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO, TIPO_REGISTRO)
VALUES(C1.CPF, C1.NRO_DIA_SEMANA, C1.ID_HORARIO, C1.INICIO_TURNO, C1.INICIO_MINUTOS, C1.FIM_MINUTOS, C1.FIM_MINUTOS-C1.INICIO_MINUTOS,'PRE_DE_PARA', SYSDATE, '09-1º reg turno, não sequencial ja INSERT com C1.INICIO_MINUTOS e C1.FIM_MINUTOS', 'DE/PARA_EXTENSOES_2023' );COMMIT;

ELSIF SUBSTR(C1.CENARIO,1,2) = '02' THEN
INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, NRO_DIA_SEMANA, ID_HORARIO, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TOTAL_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO, TIPO_REGISTRO)
VALUES(C1.CPF, C1.NRO_DIA_SEMANA, C1.ID_HORARIO, C1.INICIO_TURNO, C1.INICIO_MINUTOS, C1.PROXIMO_FIM_MINUTOS, C1.PROXIMO_FIM_MINUTOS-C1.INICIO_MINUTOS, 'PRE_DE_PARA', SYSDATE, '02-1º reg turno, seqeuencia mas ja acaba a seq no reg seguinte, 1º PARA INSERT com C1.INICIO_MINUTOS e C1.PROXIMO_FIM_MINUTOS', 'DE/PARA_EXTENSOES_2023' );COMMIT;

ELSIF SUBSTR(C1.CENARIO,1,2) = '04' THEN --'04-1º reg turno, sequencia mas o proximo tambem segue a seq, guardar variavel vINICIO_MINUTOS'
vINICIO_SEQUENCIA := C1.INICIO_MINUTOS;

ELSIF SUBSTR(C1.CENARIO,1,2) = '07' THEN --'07-<> 1º reg turno, sendo o ultimo de uma sequencia, onde ja finalizou a seq com o reg anterior, nao inserir'
vB := FALSE;

ELSIF SUBSTR(C1.CENARIO,1,2) = '03' THEN --'03-<> 1º reg turno, sendo o ultimo de uma sequencia, onde ja finalizou a seq com o reg anterior, nao inserir'
vB := FALSE;

ELSIF SUBSTR(C1.CENARIO,1,2) = '05' THEN --'05-<> 1º reg turno, sendo o penultimo de uma sequencia, finalizar usando  vINICIO_MINUTOS e para o fim C1.PROXIMO_FIM_MINUTOS' 
INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, NRO_DIA_SEMANA, ID_HORARIO, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TOTAL_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO, TIPO_REGISTRO)
VALUES(C1.CPF, C1.NRO_DIA_SEMANA, C1.ID_HORARIO, C1.INICIO_TURNO, vINICIO_SEQUENCIA, C1.PROXIMO_FIM_MINUTOS, C1.PROXIMO_FIM_MINUTOS-vINICIO_SEQUENCIA,'PRE_DE_PARA', SYSDATE, '05-<> 1º reg turno, sendo o penultimo de uma sequencia, finalizar usando vINICIO_MINUTOS e para o fim C1.PROXIMO_FIM_MINUTOS', 'DE/PARA_EXTENSOES_2023' );COMMIT;

ELSIF SUBSTR(C1.CENARIO,1,2) = '06' THEN --'06-reg meio de uma sequencia não fazer nada'
vB := FALSE;

ELSIF SUBSTR(C1.CENARIO,1,2) = '08' THEN --'08-ultimo reg do turno sendo um reg não sequencial, INSERT com C1.INICIO_MINUTOS e C1.FIM_MINUTOS'
INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, NRO_DIA_SEMANA, ID_HORARIO, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TOTAL_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO, TIPO_REGISTRO)
VALUES(C1.CPF, C1.NRO_DIA_SEMANA, C1.ID_HORARIO, C1.INICIO_TURNO, C1.INICIO_MINUTOS, C1.FIM_MINUTOS,  C1.FIM_MINUTOS-C1.INICIO_MINUTOS, 'PRE_DE_PARA', SYSDATE, '08-ultimo reg do turno sendo um reg não sequencial, INSERT com C1.INICIO_MINUTOS e C1.FIM_MINUTOS', 'DE/PARA_EXTENSOES_2023' );COMMIT;

ELSIF SUBSTR(C1.CENARIO,1,2) = '10' THEN --'10-<> 1º reg turno, sendo o primeiro deuma sequencia que ja se acaba, INSERT  com C1.INICIO_MINUTOS e C1.PROXIMO_FIM_MINUTOS'
INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, NRO_DIA_SEMANA, ID_HORARIO, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TOTAL_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO, TIPO_REGISTRO)
VALUES(C1.CPF, C1.NRO_DIA_SEMANA, C1.ID_HORARIO, C1.INICIO_TURNO, C1.INICIO_MINUTOS, C1.PROXIMO_FIM_MINUTOS, C1.PROXIMO_FIM_MINUTOS-C1.INICIO_MINUTOS, 'PRE_DE_PARA', SYSDATE, '10-<> 1º reg turno, sendo o primeiro deuma sequencia que ja se acaba, INSERT  com C1.INICIO_MINUTOS e C1.PROXIMO_FIM_MINUTOS', 'DE/PARA_EXTENSOES_2023' );COMMIT;


END IF; --GERAL
END LOOP;
END;

END;