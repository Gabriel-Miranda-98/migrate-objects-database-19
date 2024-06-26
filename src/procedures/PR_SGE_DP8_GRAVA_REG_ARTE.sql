
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PR_SGE_DP8_GRAVA_REG_ARTE" (DATA_INICIO IN DATE)
AS 
BEGIN 

--Kellysson em 19/1/24 baseado (sql_gera_DE_PARA_EXTENSOES_2023_b2.sql)

--Kellysson em 5/9/23 b2 (sql_gera_DE_PARA_EXTENSOES_2023_b2.sql) para ajuste DATA_INICIO_U E DATA_FIM_U pARA INICIO_JORNADA_U e FIM_JORNADA_U
--Kellysson novo em 12/8/23
DECLARE 
vDATA_INICIO DATE;

vCONTADOR NUMBER;
vB BOOLEAN := TRUE;
vINI_SEG VARCHAR2 (30);
vINI_TER VARCHAR2 (30);
vINI_QUA VARCHAR2 (30);
vINI_QUI VARCHAR2 (30);
vINI_SEX VARCHAR2 (30);
vFIM_SEG VARCHAR2 (30);
vFIM_TER VARCHAR2 (30);
vFIM_QUA VARCHAR2 (30);
vFIM_QUI VARCHAR2 (30);
vFIM_SEX VARCHAR2 (30);

vID_JORNADA NUMBER; 
vID_HORARIO  NUMBER; 
vBM_SERVIDOR VARCHAR2 (15);
vCODIGO_ESCOLA VARCHAR2 (15);
vHORAS_SEMANAIS VARCHAR2 (5);
vTURNO VARCHAR2 (15);
vDT_INICIO DATE;
vDT_FIM  DATE;
vDT_CANCELAMENTO DATE;


BEGIN
dbms_output.enable(null);

vDATA_INICIO := DATA_INICIO;

vCONTADOR :=0;
vINI_SEG := NULL;
vINI_TER := NULL;
vINI_QUA := NULL;
vINI_QUI := NULL;
vINI_SEX := NULL;
vFIM_SEG := NULL;
vFIM_TER := NULL;
vFIM_QUA := NULL;
vFIM_QUI := NULL;
vFIM_SEX := NULL;

vID_JORNADA := 0; 
vID_HORARIO := 0;  
vBM_SERVIDOR := NULL ; 
vCODIGO_ESCOLA := NULL ; 
vHORAS_SEMANAIS := NULL ; 
vTURNO := NULL ; 
vDT_INICIO := NULL ; 
vDT_FIM  := NULL ; 
vDT_CANCELAMENTO := NULL ; 



FOR C1 IN (

--SELECT ID_HORARIO, COUNT(1) FROM (
--SELECT CPF, COUNT(1) FROM (
--SELECT COUNT(1) FROM (

SELECT 
E.ID_JORNADA,
CASE 
WHEN X5.HORAS_TOTAIS_COM_EXTRA > 1350 THEN '22:30'
WHEN X5.HORAS_TOTAIS_COM_EXTRA <= 1350 AND INSTR(X5.HM_TOTAIS_COM_EXTRA/60,',') = 0 THEN LPAD(X5.HM_TOTAIS_COM_EXTRA/60,2,0)||':00'
ELSE LPAD(SUBSTR(X5.HM_TOTAIS_COM_EXTRA/60,1,INSTR(X5.HM_TOTAIS_COM_EXTRA/60,',')-1),2,0) ||':'||LPAD(MOD(X5.HM_TOTAIS_COM_EXTRA,60),2,0) END  HORAS_SEMANAIS_CERTA,
X5.* FROM(
SELECT 
((SUBSTR(X4.CARGA_HORARIA,1,2)+ (SUBSTR(X4.CARGA_HORARIA,1,2)/2)))*60 + (MOD((TRUNC((SUBSTR(X4.CARGA_HORARIA,1,2)+ (SUBSTR(X4.CARGA_HORARIA,1,2)/2))))*60,2)*60)*60 HORAS_TOTAIS_COM_EXTRA,
((SUBSTR(X4.CARGA_HORARIA,1,2)+ (SUBSTR(X4.CARGA_HORARIA,1,2)/2)))*60 + (MOD((TRUNC((SUBSTR(X4.CARGA_HORARIA,1,2)
+ (SUBSTR(X4.CARGA_HORARIA,1,2)/2))))*60,2)*60)*60 +CASE WHEN SUBSTR(X4.CARGA_HORARIA,4,2) = '00' THEN 0 ELSE SUBSTR(X4.CARGA_HORARIA,4,2)+ (SUBSTR(X4.CARGA_HORARIA,4,2)/2)END HM_TOTAIS_COM_EXTRA,
CG.DESCRICAO,
LEAD(X4.ORDEM_GERAR_REG, 1, NULL) OVER(PARTITION BY X4.CPF, X4.ID_HORARIO, X4.ORDEM_ID_DIA_TURNO ORDER BY X4.CPF, X4.ID_HORARIO, X4.ORDEM_ID_DIA_TURNO, X4.NRO_DIA_SEMANA, X4.INICIO_TURNO, X4.INICIO_MINUTOS)PROXIMO_ORDEM_GERAR_REG,
X4.* FROM (
SELECT 
ROW_NUMBER() OVER(PARTITION BY X3.CPF, X3.ID_HORARIO, X3.ORDEM_ID_DIA_TURNO ORDER BY X3.CPF, X3.ID_HORARIO, X3.ORDEM_ID_DIA_TURNO, X3.NRO_DIA_SEMANA, X3.INICIO_TURNO, X3.INICIO_MINUTOS)ORDEM_GERAR_REG,
X3.SOMA_TOTAL_MINUTOS_FINAL, X3.QTD_ID_DIA_TURNO_FINAL, X3.ORDEM_ID_DIA_TURNO, X3.CPF, X3.ID_HORARIO, X3.NRO_DIA_SEMANA, X3.INICIO_TURNO, 
X3.INICIO_MINUTOS, ROUND(X3.INICIO_MINUTOS/60, 2) HM_INICIO, LPAD(TRUNC(X3.INICIO_MINUTOS/60),2,0) H_INICIO, LPAD(MOD(X3.INICIO_MINUTOS,60),2,0) M_INICIO,
X3.FIM_MINUTOS, ROUND(X3.FIM_MINUTOS/60, 2) HM_FIM, LPAD(TRUNC(X3.FIM_MINUTOS/60),2,0) H_FIM, LPAD(MOD(X3.FIM_MINUTOS,60),2,0) M_FIM,
X3.TOTAL_MINUTOS, X3.SOMA_TOTAL_MINUTOS, X3.QTD_ID_DIA_TURNO, X3.TIPO_MARCACAO, X3.OBS_PROCESSAMENTO
,V.ID_JORNADA_U, V.STATUS_REGISTRO, V.BM_U, V.TIPO_JORNADA_U, V.TURNO_U, V.HORA_INI_TURNO_U, V.HORA_FIM_TURNO_U, V.DURACAO_AULA_U, V.COD_ORGAO_U, V.COORDENACAO_U, V.INICIO_JORNADA_U, V.FIM_JORNADA_U, V.DT_CANCELAMENTO_USAR_U, 
V.SEGUNDA_U, V.INTERVALO_SEGUNDA_U, V.TERCA_U, V.INTERVALO_TERCA_U, V.QUARTA_U, V.INTERVALO_QUARTA_U, V.QUINTA_U, V.INTERVALO_QUINTA_U, V.SEXTA_U, V.INTERVALO_SEXTA_U, V.CARGA_HORARIA
FROM(
SELECT TF.SOMA_TOTAL_MINUTOS_FINAL, TF.QTD_ID_DIA_TURNO_FINAL, X2.* FROM ( SELECT 
ROW_NUMBER() OVER(PARTITION BY X.CPF, X.ID_HORARIO, X.NRO_DIA_SEMANA, X.INICIO_TURNO ORDER BY X.CPF, X.ID_HORARIO, X.NRO_DIA_SEMANA, X.INICIO_TURNO, X.INICIO_MINUTOS, X.TOTAL_MINUTOS DESC)ORDEM_ID_DIA_TURNO,
X.CPF, X.ID_HORARIO, X.NRO_DIA_SEMANA, X.INICIO_TURNO, X.INICIO_MINUTOS, X.FIM_MINUTOS, X.TOTAL_MINUTOS,
T.SOMA_TOTAL_MINUTOS, T.QTD_ID_DIA_TURNO,
X.TIPO_MARCACAO, X.OBS_PROCESSAMENTO
FROM PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES X 
LEFT OUTER JOIN
    (SELECT X.CPF, X.ID_HORARIO, X.NRO_DIA_SEMANA, X.INICIO_TURNO, SUM(X.TOTAL_MINUTOS)SOMA_TOTAL_MINUTOS, COUNT(1)QTD_ID_DIA_TURNO
    FROM PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES X  WHERE X.TIPO_MARCACAO = 'PRE_DE_PARA' AND X.TIPO_REGISTRO = 'DE/PARA_EXTENSOES_2023'
    GROUP BY X.CPF, X.ID_HORARIO, X.NRO_DIA_SEMANA, X.INICIO_TURNO
    )T ON T.CPF = X.CPF AND T.ID_HORARIO = X.ID_HORARIO AND T.NRO_DIA_SEMANA = X.NRO_DIA_SEMANA AND T.INICIO_TURNO = X.INICIO_TURNO

WHERE X.TIPO_MARCACAO = 'PRE_DE_PARA'  
AND TRUNC(X.DATA_PROCESSAMENTO)= TRUNC(SYSDATE) --NOVO EM 5/9/23
AND X.TIPO_REGISTRO = 'DE/PARA_EXTENSOES_2023'
ORDER BY X.CPF, X.ID_HORARIO, X.NRO_DIA_SEMANA, X.INICIO_TURNO, X.INICIO_MINUTOS, X.TOTAL_MINUTOS DESC
)X2 
LEFT OUTER JOIN
    (SELECT X.CPF, X.ID_HORARIO, X.NRO_DIA_SEMANA, X.INICIO_TURNO, SUM(X.TOTAL_MINUTOS)SOMA_TOTAL_MINUTOS_FINAL, COUNT(1)QTD_ID_DIA_TURNO_FINAL
    FROM PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES X  WHERE X.TIPO_MARCACAO = 'PRE_DE_PARA' AND X.TIPO_REGISTRO = 'DE/PARA_EXTENSOES_2023'
    GROUP BY X.CPF, X.ID_HORARIO, X.NRO_DIA_SEMANA, X.INICIO_TURNO
    )TF ON TF.CPF = X2.CPF AND TF.ID_HORARIO = X2.ID_HORARIO AND TF.NRO_DIA_SEMANA = X2.NRO_DIA_SEMANA AND TF.INICIO_TURNO = X2.INICIO_TURNO

WHERE  X2.SOMA_TOTAL_MINUTOS <= 270 OR (X2.SOMA_TOTAL_MINUTOS > 270 AND X2.ORDEM_ID_DIA_TURNO = 1)--TIRAR AS DUPLICIDADES DA REGRA2 DEVIDO A PRIMEIRA E ULTIMA SEMANA DEIXANDO A DE MAIOR QUANTIDADE DE MINUTOS PARA AS SEMANAS CHEIAS OU COM MAIS HORAS DE REGENCIA
)X3
LEFT OUTER JOIN 
    (SELECT V.ID_HORARIO, V.ID_JORNADA_U, V.STATUS_REGISTRO, V.BM_U, V.TIPO_JORNADA_U, V.TURNO_U, V.HORA_INI_TURNO_U, V.HORA_FIM_TURNO_U, V.DURACAO_AULA_U, V.COD_ORGAO_U, V.COORDENACAO_U, V.INICIO_JORNADA_U, V.FIM_JORNADA_U, V.DT_CANCELAMENTO_USAR_U, 
    V.SEGUNDA_U, V.INTERVALO_SEGUNDA_U, V.TERCA_U, V.INTERVALO_TERCA_U, V.QUARTA_U, V.INTERVALO_QUARTA_U, V.QUINTA_U, V.INTERVALO_QUINTA_U, V.SEXTA_U, V.INTERVALO_SEXTA_U, V.CARGA_HORARIA 
    FROM 
    (SELECT A.* FROM PONTO_ELETRONICO.SUGESP_SGE_JORNADAS_AJUSTES A LEFT OUTER JOIN 
        (SELECT ID_HORARIO, MAX(TRUNC(DATA_PROCESSAMENTO))DATA_PROCESSAMENTO FROM PONTO_ELETRONICO.SUGESP_SGE_JORNADAS_AJUSTES WHERE TIPO_REGISTRO = 'DE/PARA_EXTENSOES_2023' 
        AND TO_DATE(DATA_INICIO_U,'DD/MM/YYYY')>=  TO_DATE(vDATA_INICIO,'DD/MM/YYYY')--NOVO A PARTIR DE 2024
        GROUP BY ID_HORARIO)U ON U.ID_HORARIO = A.ID_HORARIO AND TRUNC(A.DATA_PROCESSAMENTO) = TRUNC(U.DATA_PROCESSAMENTO)
        WHERE U.ID_HORARIO IS NOT NULL AND A.TIPO_REGISTRO = 'DE/PARA_EXTENSOES_2023')V
        LEFT OUTER JOIN 
        (SELECT M.CODIGO_EMPRESA, M.TIPO_CONTRATO, M.CODIGO_CONTRATO, M.CODIGO_PESSOA, P.CPF FROM ARTERH.RHPESS_CONTR_MEST M LEFT OUTER JOIN ARTERH.RHPESS_PESSOA P ON P.CODIGO_EMPRESA = M.CODIGO_EMPRESA AND P.CODIGO = M.CODIGO_PESSOA)P
        ON P.CODIGO_EMPRESA = '0001' AND P.TIPO_CONTRATO = '0001' AND P.CODIGO_CONTRATO = V.BM_U
    )V ON V.ID_HORARIO = X3.ID_HORARIO
--WHERE X3.ID_HORARIO  IN (7761, 7801)
--X3.CPF = '01498361633'--'67274820630' --X3.ID_HORARIO = 1628 --TESTE
ORDER BY X3.CPF, X3.ID_HORARIO, X3.ORDEM_ID_DIA_TURNO, X3.NRO_DIA_SEMANA, X3.INICIO_TURNO, X3.INICIO_MINUTOS
)X4 
--where X4.ID_HORARIO = 3882 --IN (2304, 18345)--TESTE

LEFT OUTER JOIN (SELECT * FROM ARTERH.RHORGA_CUSTO_GEREN WHERE DATA_EXTINCAO IS NULL )CG ON CG.CODIGO_EMPRESA = '0001' 
AND CG.COD_CGERENC1 = LPAD(SUBSTR(X4.COD_ORGAO_U,1,2),6,0) AND CG.COD_CGERENC2 = LPAD(SUBSTR(X4.COD_ORGAO_U,3,2),6,0) AND CG.COD_CGERENC3 = LPAD(SUBSTR(X4.COD_ORGAO_U,5,2),6,0) 
AND CG.COD_CGERENC4 = LPAD(SUBSTR(X4.COD_ORGAO_U,7,2),6,0) AND CG.COD_CGERENC5 = LPAD(SUBSTR(X4.COD_ORGAO_U,9,2),6,0) AND CG.COD_CGERENC6 = LPAD(SUBSTR(X4.COD_ORGAO_U,11,3),6,0)

ORDER BY X4.CPF, X4.ID_HORARIO, X4.ORDEM_ID_DIA_TURNO, X4.NRO_DIA_SEMANA, X4.INICIO_TURNO, X4.INICIO_MINUTOS
)X5
LEFT OUTER JOIN (SELECT * FROM SMARH_INT_PE_EXTENSOES_JORNAD WHERE TIPO_EXTENSAO LIKE 'EXTENSAO_SGE_DE_PARA_2023%') E ON E.ID_HORARIO = X5.ID_HORARIO ---PARE VER SE JÁ NÃO TEM A EXTENSAO CADASTRADA SE JÁ TIVER APENAS UPDATE NA DATA DE CANCELAMENTO

--)--COUNT
--)GROUP BY CPF ORDER BY COUNT(1)DESC
--)GROUP BY ID_HORARIO ORDER BY COUNT(1)DESC


)LOOP
vCONTADOR := vCONTADOR +1;
dbms_output.put_line('--vCONTADOR: '||vCONTADOR);



--INICIO-----------------------------------------------------------PREPARA REGISTRO DURANTE DIAS DA SEMANA-------------------------------------------------------------------
IF C1.NRO_DIA_SEMANA = 2 THEN --SEGUNDA
vINI_SEG := TO_CHAR(TO_DATE('01/01/2001 ' ||C1.H_INICIO||':'|| C1.M_INICIO|| ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') ;
vFIM_SEG := TO_CHAR(TO_DATE('01/01/2001 ' ||C1.H_FIM||':'|| C1.M_FIM|| ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') ;

ELSIF C1.NRO_DIA_SEMANA = 3 THEN --TERCA
vINI_TER := TO_CHAR(TO_DATE('01/01/2001 ' ||C1.H_INICIO||':'|| C1.M_INICIO|| ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') ;
vFIM_TER := TO_CHAR(TO_DATE('01/01/2001 ' ||C1.H_FIM||':'|| C1.M_FIM|| ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') ;

ELSIF C1.NRO_DIA_SEMANA = 4 THEN --QUARTA
vINI_QUA := TO_CHAR(TO_DATE('01/01/2001 ' ||C1.H_INICIO||':'|| C1.M_INICIO|| ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') ;
vFIM_QUA := TO_CHAR(TO_DATE('01/01/2001 ' ||C1.H_FIM||':'|| C1.M_FIM|| ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') ;

ELSIF C1.NRO_DIA_SEMANA = 5 THEN --QUINTA
vINI_QUI := TO_CHAR(TO_DATE('01/01/2001 ' ||C1.H_INICIO||':'|| C1.M_INICIO|| ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') ;
vFIM_QUI := TO_CHAR(TO_DATE('01/01/2001 ' ||C1.H_FIM||':'|| C1.M_FIM|| ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') ;

ELSIF C1.NRO_DIA_SEMANA = 6 THEN --SEXTA
vINI_SEX := TO_CHAR(TO_DATE('01/01/2001 ' ||C1.H_INICIO||':'|| C1.M_INICIO|| ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') ;
vFIM_SEX := TO_CHAR(TO_DATE('01/01/2001 ' ||C1.H_FIM||':'|| C1.M_FIM|| ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS') ;
END IF;
--FIM-----------------------------------------------------------PREPARA REGISTRO DURANTE DIAS DA SEMANA-------------------------------------------------------------------

--vCONTADOR := vCONTADOR +1;
--dbms_output.put_line('--vCONTADOR: '||vCONTADOR);

--INICIO-----------------------------------------------------------SETA VARIAVEIS E GRAVA REGISTRO-------------------------------------------------------------------

IF C1.PROXIMO_ORDEM_GERAR_REG IS NOT NULL AND C1.ORDEM_GERAR_REG = 1 
AND C1.ID_JORNADA IS NULL ---NOVO EM 5/9/23
THEN
dbms_output.put_line('-1-ACUMULA VARIAVEIS: vID_JORNADA: '||vID_JORNADA);
vID_JORNADA := C1.ID_JORNADA_U; 
vID_HORARIO := C1.ID_HORARIO;  
vBM_SERVIDOR := C1.BM_U ; 
vCODIGO_ESCOLA := C1.COD_ORGAO_U ; 
vHORAS_SEMANAIS := C1.HORAS_SEMANAIS_CERTA; --C1.CARGA_HORARIA; --AJUSTADO EM 5/9/23
vTURNO := C1.TURNO_U ; 
vDT_INICIO := TO_CHAR(TO_DATE(C1.INICIO_JORNADA_U ,'DD/MM/YYYY'),'DD/MM/YYYY'); 
vDT_FIM  := TO_CHAR(TO_DATE(C1.FIM_JORNADA_U ,'DD/MM/YYYY'),'DD/MM/YYYY') ; 
vDT_CANCELAMENTO := TO_CHAR(TO_DATE(C1.DT_CANCELAMENTO_USAR_U,'DD/MM/YYYY'),'DD/MM/YYYY') ; 

ELSIF C1.PROXIMO_ORDEM_GERAR_REG IS NOT NULL AND C1.ORDEM_GERAR_REG <> 1 THEN
dbms_output.put_line('-2-JA ACUMULOU NO C1.ORDEM_GERAR_REG = 1'); 
vB := TRUE;

--IF C1.ORDEM_GERAR_REG = 1 AND vCONTADOR > 1 THEN
ELSIF C1.PROXIMO_ORDEM_GERAR_REG IS NULL AND C1.ORDEM_GERAR_REG = 1 
AND C1.ID_JORNADA IS NULL ---NOVO EM 5/9/23
THEN
dbms_output.put_line('-3-GRAVA REGISTRO ATUAL');
INSERT INTO PONTO_ELETRONICO.SMARH_INT_PE_EXTENSOES_JORNAD (ID_JORNADA, ID_HORARIO, TIPO_EXTENSAO, CODIGO_EMPRESA, ID_REGISTRO_ARQUIVO, BM_SERVIDOR, CODIGO_ESCOLA, COD_LOCAL1, COD_LOCAL2, COD_LOCAL3, COD_LOCAL4, COD_LOCAL5, COD_LOCAL6, HORAS_SEMANAIS, TURNO, DT_INICIO, DT_FIM, DT_CANCELAMENTO, DT_RECEBEU_CADASTRO, DT_RECEBEU_CANCELAMENTO, HORARIO_INICIO_SEGUNDA, HORARIO_FIM_SEGUNDA, HORARIO_INICIO_TERCA, HORARIO_FIM_TERCA, HORARIO_INICIO_QUARTA, HORARIO_FIM_QUARTA, HORARIO_INICIO_QUINTA, HORARIO_FIM_QUINTA, HORARIO_INICIO_SEXTA, HORARIO_FIM_SEXTA, NOME_ESCOLA)--10
VALUES(C1.ID_JORNADA_U,C1.ID_HORARIO,'EXTENSAO_SGE_DE_PARA_2023_PR_SGE_DP8', '0001', vCONTADOR, C1.BM_U, C1.COD_ORGAO_U, LPAD(SUBSTR(C1.COD_ORGAO_U,1,2),6,0), LPAD(SUBSTR(C1.COD_ORGAO_U,3,2),6,0), LPAD(SUBSTR(C1.COD_ORGAO_U,5,2),6,0), LPAD(SUBSTR(C1.COD_ORGAO_U,7,2),6,0), LPAD(SUBSTR(C1.COD_ORGAO_U,9,2),6,0), LPAD(SUBSTR(C1.COD_ORGAO_U,11,3),6,0), C1.HORAS_SEMANAIS_CERTA, C1.TURNO_U, TO_CHAR(TO_DATE(C1.INICIO_JORNADA_U,'DD/MM/YYYY'),'DD/MM/YYYY'), TO_CHAR(TO_DATE(C1.FIM_JORNADA_U,'DD/MM/YYYY'),'DD/MM/YYYY'), CASE WHEN C1.DT_CANCELAMENTO_USAR_U IS NOT NULL THEN TO_CHAR(TO_DATE(C1.DT_CANCELAMENTO_USAR_U,'DD/MM/YYYY'),'DD/MM/YYYY') ELSE NULL END, SYSDATE, CASE WHEN C1.DT_CANCELAMENTO_USAR_U IS NOT NULL THEN SYSDATE ELSE NULL END, vINI_SEG, vFIM_SEG, vINI_TER, vFIM_TER, vINI_QUA, vFIM_QUA, vINI_QUI, vFIM_QUI, vINI_SEX, vFIM_SEX, C1.DESCRICAO ); COMMIT;
dbms_output.put_line('INSERT INTO PONTO_ELETRONICO.SMARH_INT_PE_EXTENSOES_JORNAD (ID_JORNADA, ID_HORARIO, TIPO_EXTENSAO, CODIGO_EMPRESA, ID_REGISTRO_ARQUIVO, BM_SERVIDOR, CODIGO_ESCOLA, COD_LOCAL1, COD_LOCAL2, COD_LOCAL3, COD_LOCAL4, COD_LOCAL5, COD_LOCAL6, HORAS_SEMANAIS, TURNO, DT_INICIO, DT_FIM, DT_CANCELAMENTO, DT_RECEBEU_CADASTRO, DT_RECEBEU_CANCELAMENTO, HORARIO_INICIO_SEGUNDA, HORARIO_FIM_SEGUNDA, HORARIO_INICIO_TERCA, HORARIO_FIM_TERCA, HORARIO_INICIO_QUARTA, HORARIO_FIM_QUARTA, HORARIO_INICIO_QUINTA, HORARIO_FIM_QUINTA, HORARIO_INICIO_SEXTA, HORARIO_FIM_SEXTA');
dbms_output.put_line(C1.ID_JORNADA_U||'-'|| C1.ID_HORARIO||'-'||'EXTENSAO_SGE_DE_PARA_2023'||'-'|| '0001'||'-'|| vCONTADOR||'-'||C1.BM_U||'-'|| C1.COD_ORGAO_U||'-'|| LPAD(SUBSTR(C1.COD_ORGAO_U,1,2),6,0)||'-'||LPAD(SUBSTR(C1.COD_ORGAO_U,3,2),6,0)||'-'||LPAD(SUBSTR(C1.COD_ORGAO_U,5,2),6,0)||'-'||LPAD(SUBSTR(C1.COD_ORGAO_U,7,2),6,0)||'-'||LPAD(SUBSTR(C1.COD_ORGAO_U,9,2),6,0)||'-'||LPAD(SUBSTR(C1.COD_ORGAO_U,11,3),6,0)||'-'||C1.HORAS_SEMANAIS_CERTA||'-'||C1.TURNO_U||'-'||TO_CHAR(TO_DATE(C1.INICIO_JORNADA_U,'DD/MM/YYYY'),'DD/MM/YYYY')||'-'||TO_CHAR(TO_DATE(C1.FIM_JORNADA_U,'DD/MM/YYYY'),'DD/MM/YYYY')||'-'||CASE WHEN C1.DT_CANCELAMENTO_USAR_U IS NOT NULL THEN C1.DT_CANCELAMENTO_USAR_U ELSE NULL END||'-'||SYSDATE||'-'||CASE WHEN C1.DT_CANCELAMENTO_USAR_U IS NOT NULL THEN SYSDATE ELSE NULL END||'-'||vINI_SEG||'-'||vFIM_SEG||'-'||vINI_TER||'-'||vFIM_TER||'-'||vINI_QUA||'-'||vFIM_QUA||'-'||vINI_QUI||'-'||vFIM_QUI||'-'||vINI_SEX||'-'||vFIM_SEX );
--LIMPAR VARIAVEIS PARA PROXIMO REGISTRO
vINI_SEG := NULL; 
vINI_TER := NULL;
vINI_QUA := NULL;
vINI_QUI := NULL;
vINI_SEX := NULL;
vFIM_SEG := NULL;
vFIM_TER := NULL;
vFIM_QUA := NULL;
vFIM_QUI := NULL;
vFIM_SEX := NULL;
vID_JORNADA := 0; 
vID_HORARIO := 0;  
vBM_SERVIDOR := NULL ; 
vCODIGO_ESCOLA := NULL ; 
vHORAS_SEMANAIS := NULL ; 
vTURNO := NULL ; 
vDT_INICIO := NULL ; 
vDT_FIM  := NULL ; 
vDT_CANCELAMENTO := NULL ; 

ELSIF C1.PROXIMO_ORDEM_GERAR_REG IS NULL AND C1.ORDEM_GERAR_REG <> 1
AND C1.ID_JORNADA IS NULL ---NOVO EM 5/9/23
THEN
dbms_output.put_line('-4-GRAVA REGISTRO ANTERIOR');
INSERT INTO PONTO_ELETRONICO.SMARH_INT_PE_EXTENSOES_JORNAD (ID_JORNADA, ID_HORARIO, TIPO_EXTENSAO, CODIGO_EMPRESA, ID_REGISTRO_ARQUIVO, BM_SERVIDOR, CODIGO_ESCOLA, COD_LOCAL1, COD_LOCAL2, COD_LOCAL3, COD_LOCAL4, COD_LOCAL5, COD_LOCAL6, HORAS_SEMANAIS, TURNO, DT_INICIO, DT_FIM, DT_CANCELAMENTO, DT_RECEBEU_CADASTRO, DT_RECEBEU_CANCELAMENTO, HORARIO_INICIO_SEGUNDA, HORARIO_FIM_SEGUNDA, HORARIO_INICIO_TERCA, HORARIO_FIM_TERCA, HORARIO_INICIO_QUARTA, HORARIO_FIM_QUARTA, HORARIO_INICIO_QUINTA, HORARIO_FIM_QUINTA, HORARIO_INICIO_SEXTA, HORARIO_FIM_SEXTA, NOME_ESCOLA)--10
VALUES(vID_JORNADA, vID_HORARIO, 'EXTENSAO_SGE_DE_PARA_2023_PR_SGE_DP8', '0001', vCONTADOR, vBM_SERVIDOR, vCODIGO_ESCOLA, LPAD(SUBSTR(vCODIGO_ESCOLA,1,2),6,0), LPAD(SUBSTR(vCODIGO_ESCOLA,3,2),6,0), LPAD(SUBSTR(vCODIGO_ESCOLA,5,2),6,0), LPAD(SUBSTR(vCODIGO_ESCOLA,7,2),6,0), LPAD(SUBSTR(vCODIGO_ESCOLA,9,2),6,0), LPAD(SUBSTR(vCODIGO_ESCOLA,11,3),6,0), vHORAS_SEMANAIS, vTURNO, vDT_INICIO, vDT_FIM, CASE WHEN vDT_CANCELAMENTO IS NOT NULL THEN vDT_CANCELAMENTO ELSE NULL END, SYSDATE, CASE WHEN vDT_CANCELAMENTO IS NOT NULL THEN SYSDATE ELSE NULL END, vINI_SEG, vFIM_SEG, vINI_TER, vFIM_TER, vINI_QUA, vFIM_QUA, vINI_QUI, vFIM_QUI, vINI_SEX, vFIM_SEX, C1.DESCRICAO); COMMIT;

dbms_output.put_line('INSERT INTO PONTO_ELETRONICO.SMARH_INT_PE_EXTENSOES_JORNAD (ID_JORNADA, ID_HORARIO, TIPO_EXTENSAO, CODIGO_EMPRESA, ID_REGISTRO_ARQUIVO, BM_SERVIDOR, CODIGO_ESCOLA, COD_LOCAL1, COD_LOCAL2, COD_LOCAL3, COD_LOCAL4, COD_LOCAL5, COD_LOCAL6, HORAS_SEMANAIS, TURNO, DT_INICIO, DT_FIM, DT_CANCELAMENTO, DT_RECEBEU_CADASTRO, DT_RECEBEU_CANCELAMENTO, HORARIO_INICIO_SEGUNDA, HORARIO_FIM_SEGUNDA, HORARIO_INICIO_TERCA, HORARIO_FIM_TERCA, HORARIO_INICIO_QUARTA, HORARIO_FIM_QUARTA, HORARIO_INICIO_QUINTA, HORARIO_FIM_QUINTA, HORARIO_INICIO_SEXTA, HORARIO_FIM_SEXTA');
dbms_output.put_line(C1.ID_JORNADA_U||'-'|| vID_HORARIO||'-'||'EXTENSAO_SGE_DE_PARA_2023'||'-'|| '0001'||'-'|| vCONTADOR||'-'||vBM_SERVIDOR||'-'|| vBM_SERVIDOR||'-'|| LPAD(SUBSTR(vBM_SERVIDOR,1,2),6,0)||'-'||LPAD(SUBSTR(vBM_SERVIDOR,3,2),6,0)||'-'||LPAD(SUBSTR(vBM_SERVIDOR,5,2),6,0)||'-'||LPAD(SUBSTR(vBM_SERVIDOR,7,2),6,0)||'-'||LPAD(SUBSTR(vBM_SERVIDOR,9,2),6,0)||'-'||LPAD(SUBSTR(vBM_SERVIDOR,11,3),6,0)||'-'||vHORAS_SEMANAIS||'-'||vTURNO||'-'||TO_CHAR(TO_DATE(C1.INICIO_JORNADA_U,'DD/MM/YYYY'),'DD/MM/YYYY')||'-'||TO_CHAR(TO_DATE(C1.FIM_JORNADA_U,'DD/MM/YYYY'),'DD/MM/YYYY')||'-'||CASE WHEN C1.DT_CANCELAMENTO_USAR_U IS NOT NULL THEN C1.DT_CANCELAMENTO_USAR_U ELSE NULL END||'-'||SYSDATE||'-'||CASE WHEN C1.DT_CANCELAMENTO_USAR_U IS NOT NULL THEN SYSDATE ELSE NULL END||'-'||vINI_SEG||'-'||vFIM_SEG||'-'||vINI_TER||'-'||vFIM_TER||'-'||vINI_QUA||'-'||vFIM_QUA||'-'||vINI_QUI||'-'||vFIM_QUI||'-'||vINI_SEX||'-'||vFIM_SEX );
dbms_output.put_line('--LIMPAR VARIAVEIS PARA PROXIMO REGISTRO');
vINI_SEG := NULL; 
vINI_TER := NULL;
vINI_QUA := NULL;
vINI_QUI := NULL;
vINI_SEX := NULL;
vFIM_SEG := NULL;
vFIM_TER := NULL;
vFIM_QUA := NULL;
vFIM_QUI := NULL;
vFIM_SEX := NULL;
vID_JORNADA := 0; 
vID_HORARIO := 0;  
vBM_SERVIDOR := NULL ; 
vCODIGO_ESCOLA := NULL ; 
vHORAS_SEMANAIS := NULL ; 
vTURNO := NULL ; 
vDT_INICIO := NULL ; 
vDT_FIM  := NULL ; 
vDT_CANCELAMENTO := NULL ; 

ELSIF C1.ID_JORNADA IS NOT NULL AND C1.DT_CANCELAMENTO_USAR_U IS NOT NULL THEN ---NOVO EM 5/9/23
dbms_output.put_line('UPDATE PONTO_ELETRONICO.SMARH_INT_PE_EXTENSOES_JORNAD DT_CANCELAMENTO_USAR_U, C1.ID_JORNADA:'||C1.ID_JORNADA);
UPDATE PONTO_ELETRONICO.SMARH_INT_PE_EXTENSOES_JORNAD 
SET DT_CANCELAMENTO = C1.DT_CANCELAMENTO_USAR_U ,  DT_RECEBEU_CANCELAMENTO = SYSDATE, TIPO_EXTENSAO = 'EXTENSAO_SGE_DE_PARA_2023_CANCELADA'
WHERE ID_JORNADA = C1.ID_JORNADA AND ID_HORARIO = C1.ID_HORARIO AND TIPO_EXTENSAO LIKE 'EXTENSAO_SGE_DE_PARA_2023%' AND TRUNC(DT_RECEBEU_CADASTRO) <> TRUNC(SYSDATE) ; COMMIT;

ELSE
dbms_output.put_line('FAZER NADA CONFERIR: C1.ID_HORARIO'||C1.ID_HORARIO);

END IF;
--FIM-----------------------------------------------------------SETA VARIAVEIS E GRAVA REGISTRO-------------------------------------------------------------------


END LOOP;
END;
END;