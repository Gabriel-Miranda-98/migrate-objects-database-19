
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PR_SGE_GERA_MARCACOES_DIA_FORALL" AS 
BEGIN 

--Kellysson em 15/7/23 virou sql_gera_marcacoes_dia_b4.sql derivado do sql_novo_12-7-23_para sql_gera_marcacoes_dia_b3.sql
--Kellysson novo em 11/7/23 ---para criar os registros diarios por CPF para o DE/PARA 2023 DE EXTENSOES E 2024 PARA FRENTE
DECLARE 
vCONTADOR_C3 NUMBER;
vCONTADOR_C1 NUMBER;
vCONTADOR_C2 NUMBER;
vTOTAL_HORAS_REGENCIA_DIA NUMBER;
vTOTAL_HORAS_REGENCIA_SEMANA NUMBER;
vQTD_TURNOS_DIA NUMBER;
vTURNO_ATUAL VARCHAR2(10);

vQTD_TURNOS_SEM_REGENCIA NUMBER;
vTURNO_ATUAL_SEM_REGENCIA VARCHAR2(10);

vID_HORARIO_ATUAL NUMBER;
vINICIO_TURNO_ATUAL NUMBER;
vINICIO_REGENCIA_ATUAL NUMBER;
vFIM_REGENCIA_ATUAL NUMBER;
vMARCACOES VARCHAR2(4000);
vDADOS_TURNO_SEM_REGENCIA VARCHAR2(4000);
vOBS_REGISTRO VARCHAR2(4000);
vCPF VARCHAR2(11);
vBM VARCHAR2(15);
vDATA DATE;
vDOMINGO_ANTERIOR DATE;
vPROXIMO_DOMINGO DATE;
vQTD_PAR_DIA NUMBER;

--PARA O FORALL
t0 number := dbms_utility.get_time; 
v_idx number := 1;  
type t_rec is record(  
BM	VARCHAR2(15 BYTE), DATA	DATE, MARCACOES	VARCHAR2(4000 BYTE), DATA_PROCESSAMENTO	DATE, CPF	VARCHAR2(11 BYTE), DADOS_REGENCIA	VARCHAR2(4000 BYTE), DADOS_EXTRACLASSE	VARCHAR2(4000 BYTE), TURNO_SEM_REGENCIA	VARCHAR2(4000 BYTE)
);  
type t_rec_array is table of t_rec index by pls_integer; 
a_rec t_rec_array;    


BEGIN
dbms_output.enable(null);
vCONTADOR_C3 := 0;
vCONTADOR_C1 := 0;
vCONTADOR_C2 := 0;
vTOTAL_HORAS_REGENCIA_DIA := 0;
vTOTAL_HORAS_REGENCIA_SEMANA := 0;
vQTD_TURNOS_DIA := 0;
vTURNO_ATUAL := NULL;

vQTD_TURNOS_SEM_REGENCIA := 0;
vTURNO_ATUAL_SEM_REGENCIA := NULL;

vID_HORARIO_ATUAL := 0;
vINICIO_TURNO_ATUAL := 0;
vINICIO_REGENCIA_ATUAL := 0;
vFIM_REGENCIA_ATUAL := 0;
vMARCACOES :=  ';';
vDADOS_TURNO_SEM_REGENCIA := ';';
vOBS_REGISTRO := NULL;
vCPF := NULL;
vBM := NULL;
vDATA := NULL;
vPROXIMO_DOMINGO := NULL;
vDOMINGO_ANTERIOR := NULL;
vQTD_PAR_DIA :=0;

--INICIO C1-----------------------------------------------------------------------------PEGAR OS CPF E DIAS PARA PROCESSAR-----------------------------------------------------------------------------------------------------------
FOR C1 IN (

SELECT CPF, TO_NUMBER(TO_CHAR(TO_DATE(DATA),'WW')) SEMANA_ANO, COUNT(1)QTD_REG_DIA FROM 
(
SELECT V.* FROM PONTO_ELETRONICO.VW_SGE_PAR_REGE_ARQ_DIA V LEFT OUTER JOIN (
--SELECT X.CPF, TRUNC(X.MIN_DATA)-(SA.NRO_DIA_SEMANA-2)SEGUNDA_ANTERIOR, X.MIN_DATA, X.MAX_DATA, TRUNC(X.MAX_DATA)+(7-DS.NRO_DIA_SEMANA+1)DOMINGO_SEGUINTE FROM (---SEGUNDA_ANTERIOR E DOMINGO_SEGUINTE
SELECT X.CPF, MIN(DATA) MIN_DATA, MAX(DATA)MAX_DATA --PEGA TODO PERIODO ENVOLVIDO NO ULTIMO AJUSTE (DIFERENCA ENTRE ULTIMA E PENULTIMA CARGA)
FROM( SELECT * FROM PONTO_ELETRONICO.VW_SGE_PAR_REGE_ARQ_DIA --WHERE ID_HORARIO IN(2356, 2458,2401,2611,2634,2636,2790, 2787,2784,2783,2788)--TESTE --7552
)X WHERE X.ORDEM_ID_HORARIO_DIA < 3 --X PEGA TODAS AS DATAS ENVOLVIDAS DAS ULTIMAS 2 CARGAS (DATA_PROCESSAMENTO TABELA: SUGESP_SGE_PAR_REGE_ARQ_DATAS)
GROUP BY X.CPF --PEGA TODO PERIODO ENVOLVIDO NO ULTIMO AJUSTE (DIFERENCA ENTRE ULTIMA E PENULTIMA CARGA) --7
--)X LEFT OUTER JOIN ARTERH.RHTABS_DATAS SA ON TRUNC(SA.DATA_DIA) = TRUNC(X.MIN_DATA) LEFT OUTER JOIN ARTERH.RHTABS_DATAS DS ON TRUNC(DS.DATA_DIA) = TRUNC(X.MAX_DATA)---SEGUNDA_ANTERIOR E DOMINGO_SEGUINTE
)X ON X.CPF = V.CPF AND TRUNC(V.DATA) BETWEEN TRUNC(X.MIN_DATA) AND TRUNC(X.MAX_DATA)--TRUNC(X.SEGUNDA_ANTERIOR) AND TRUNC(X.DOMINGO_SEGUINTE)---SEGUNDA_ANTERIOR E DOMINGO_SEGUINTE--
WHERE X.CPF IS NOT NULL --7552 APENAS OS REGISTROS DO DIA
AND V.ORDEM_PAR_REG = 1 --APENAS O ULTIMO AJUSTE --2522
)--PONTO_ELETRONICO.VW_GERA_MARCACOES_DIA --1950
GROUP BY CPF, TO_NUMBER(TO_CHAR(TO_DATE(DATA),'WW')) ORDER BY CPF, SEMANA_ANO

)LOOP --INICIO C1
--vCONTADOR_C1 := vCONTADOR_C1 +1;
vTOTAL_HORAS_REGENCIA_SEMANA := 0;
--dbms_output.put_line('------------------------------------------INICIO DE UM CPF --------------------------');
--dbms_output.put_line('--vCONTADOR_C1: '||vCONTADOR_C1||' C1.CPF: '||C1.CPF||' SEMANA_ANO: '|| C1.SEMANA_ANO||' vTOTAL_HORAS_REGENCIA_SEMANA: '||vTOTAL_HORAS_REGENCIA_SEMANA);


--INICIO C2-------------------------------------------------------LOOP PARA PASSAR POR TODOS OS REGISTROS DA SEMANA EXISTENTES DE UM CPF-----------------------------------------------------------------------------------------
FOR C2 IN (
SELECT X.CPF, X.DATA, TO_NUMBER(TO_CHAR(TO_DATE(X.DATA),'WW')) SEMANA_ANO , COUNT(1)QTD_REG_DIA FROM 
(
SELECT V.* FROM PONTO_ELETRONICO.VW_SGE_PAR_REGE_ARQ_DIA V LEFT OUTER JOIN (
--SELECT X.CPF, TRUNC(X.MIN_DATA)-(SA.NRO_DIA_SEMANA-2)SEGUNDA_ANTERIOR, X.MIN_DATA, X.MAX_DATA, TRUNC(X.MAX_DATA)+(7-DS.NRO_DIA_SEMANA+1)DOMINGO_SEGUINTE FROM (---SEGUNDA_ANTERIOR E DOMINGO_SEGUINTE
SELECT X.CPF, MIN(DATA) MIN_DATA, MAX(DATA)MAX_DATA --PEGA TODO PERIODO ENVOLVIDO NO ULTIMO AJUSTE (DIFERENCA ENTRE ULTIMA E PENULTIMA CARGA)
FROM( SELECT * FROM PONTO_ELETRONICO.VW_SGE_PAR_REGE_ARQ_DIA --WHERE ID_HORARIO IN(2356, 2458,2401,2611,2634,2636,2790, 2787,2784,2783,2788)--TESTE --7552
)X WHERE X.ORDEM_ID_HORARIO_DIA < 3 --X PEGA TODAS AS DATAS ENVOLVIDAS DAS ULTIMAS 2 CARGAS (DATA_PROCESSAMENTO TABELA: SUGESP_SGE_PAR_REGE_ARQ_DATAS)
GROUP BY X.CPF --PEGA TODO PERIODO ENVOLVIDO NO ULTIMO AJUSTE (DIFERENCA ENTRE ULTIMA E PENULTIMA CARGA) --7
--)X LEFT OUTER JOIN ARTERH.RHTABS_DATAS SA ON TRUNC(SA.DATA_DIA) = TRUNC(X.MIN_DATA) LEFT OUTER JOIN ARTERH.RHTABS_DATAS DS ON TRUNC(DS.DATA_DIA) = TRUNC(X.MAX_DATA)---SEGUNDA_ANTERIOR E DOMINGO_SEGUINTE
)X ON X.CPF = V.CPF AND TRUNC(V.DATA) BETWEEN TRUNC(X.MIN_DATA) AND TRUNC(X.MAX_DATA) --TRUNC(X.SEGUNDA_ANTERIOR) AND TRUNC(X.DOMINGO_SEGUINTE)---SEGUNDA_ANTERIOR E DOMINGO_SEGUINTE--
WHERE X.CPF IS NOT NULL --7552 APENAS OS REGISTROS DO DIA
AND V.ORDEM_PAR_REG = 1 --APENAS O ULTIMO AJUSTE --2522
)X --PONTO_ELETRONICO.VW_GERA_MARCACOES_DIA X 
WHERE X.CPF = C1.CPF AND TO_NUMBER(TO_CHAR(TO_DATE(X.DATA),'WW')) = C1.SEMANA_ANO 
           GROUP BY X.CPF, X.DATA, TO_NUMBER(TO_CHAR(TO_DATE(X.DATA),'WW')) ORDER BY CPF, DATA, SEMANA_ANO

)LOOP

--vCONTADOR_C2 := vCONTADOR_C2 +1;
--dbms_output.put_line('--vCONTADOR_C2: '||vCONTADOR_C2||' C2.DATA: '||C2.DATA);

vTOTAL_HORAS_REGENCIA_DIA := 0;
vQTD_TURNOS_DIA := 0;
vQTD_TURNOS_SEM_REGENCIA  := 0;
vTURNO_ATUAL := 'X';
vTURNO_ATUAL_SEM_REGENCIA := 'X';
vID_HORARIO_ATUAL := 0;
vINICIO_TURNO_ATUAL := 0;
vINICIO_REGENCIA_ATUAL := 0;
vFIM_REGENCIA_ATUAL := 0;
vMARCACOES := NULL; --   ;2030,1,07:00-09:00-09:20-10:20;2038,3,14:00-15:00-15:20-17:20
vOBS_REGISTRO := NULL;
vDADOS_TURNO_SEM_REGENCIA := NULL;
vQTD_PAR_DIA :=0;



--INICIO C3-------------------------------------------------------LOOP PARA PASSAR POR TODOS OS REGISTROS DE 1 DIA DE 1 SEMANA EXISTENTES DE UM CPF-----------------------------------------------------------------------------------------
FOR C3 IN (
SELECT
CASE WHEN D.NRO_DIA_SEMANA = 1 THEN D.DATA_DIA ELSE TRUNC(TO_DATE(X2.DATA,'DD/MM/YYYY'))-(D.NRO_DIA_SEMANA-1)END DOMINGO_ANTERIOR,
CASE WHEN D.NRO_DIA_SEMANA = 1 THEN TRUNC(D.DATA_DIA)+1 ELSE TRUNC(TO_DATE(X2.DATA,'DD/MM/YYYY'))-(D.NRO_DIA_SEMANA-2)END SEGUNDA_ANTERIOR, 
CASE WHEN D.NRO_DIA_SEMANA = 6 THEN X2.DATA WHEN D.NRO_DIA_SEMANA = 7 THEN TRUNC(X2.DATA)-1 WHEN D.NRO_DIA_SEMANA = 1 THEN TRUNC(X2.DATA)-2 ELSE TRUNC(TO_DATE(X2.DATA,'DD/MM/YYYY'))+(6-D.NRO_DIA_SEMANA)END SEXTA_SEGUINTE,
CASE WHEN D.NRO_DIA_SEMANA = 1 THEN D.DATA_DIA WHEN D.NRO_DIA_SEMANA = 7 THEN TRUNC(D.DATA_DIA)+1 ELSE TRUNC(TO_DATE(X2.DATA,'DD/MM/YYYY'))+(7-D.NRO_DIA_SEMANA+1)END DOMINGO_SEGUINTE,
X2.* FROM(    
SELECT  CASE
WHEN X.DATA_CANCELAMENTO_U IS NULL THEN '1_CRIAR_MARCACOES_DIA_CPF'
WHEN X.DATA_CANCELAMENTO_U IS NOT NULL AND TO_DATE(X.DATA_CANCELAMENTO_U,'DD/MM/YYYY') > TO_DATE(X.DATA_FIM_U,'DD/MM/YYYY') THEN '2_CRIAR_MARCACOES_DIA_CPF_DATA_APOS_CANCELAMENTO'
WHEN X.DATA_CANCELAMENTO_U IS NOT NULL AND TO_DATE(X.DATA_CANCELAMENTO_U,'DD/MM/YYYY')<= TO_DATE(X.DATA_FIM_U,'DD/MM/YYYY') AND TO_DATE(X.DATA,'DD/MM/YYYY') <  TO_DATE(X.DATA_CANCELAMENTO_U,'DD/MM/YYYY') THEN '3_CRIAR_MARCACOES_DIA_CPF_DATA_ANTES_CANCELAMENTO'
WHEN X.DATA_CANCELAMENTO_U IS NOT NULL AND TO_DATE(X.DATA_CANCELAMENTO_U,'DD/MM/YYYY')<= TO_DATE(X.DATA_FIM_U,'DD/MM/YYYY') AND TO_DATE(X.DATA,'DD/MM/YYYY') >= TO_DATE(X.DATA_CANCELAMENTO_U,'DD/MM/YYYY') THEN '4_NAO_CRIAR_MARCACOES_DIA_CPF_DATA_NO_DIA_OU_APOS_CANCELAMENTO'
ELSE 'NAO_MAPEADO_AINDA' END CENARIO_ACAO,
CASE
WHEN X.DATA_CANCELAMENTO_U IS NULL THEN 'INCLUI'
WHEN X.DATA_CANCELAMENTO_U IS NOT NULL AND TO_DATE(X.DATA_CANCELAMENTO_U,'DD/MM/YYYY') > TO_DATE(X.DATA_FIM_U,'DD/MM/YYYY') THEN 'INCLUI'
WHEN X.DATA_CANCELAMENTO_U IS NOT NULL AND TO_DATE(X.DATA_CANCELAMENTO_U,'DD/MM/YYYY')<= TO_DATE(X.DATA_FIM_U,'DD/MM/YYYY') AND TO_DATE(X.DATA,'DD/MM/YYYY') <  TO_DATE(X.DATA_CANCELAMENTO_U,'DD/MM/YYYY') THEN 'INCLUI'
WHEN X.DATA_CANCELAMENTO_U IS NOT NULL AND TO_DATE(X.DATA_CANCELAMENTO_U,'DD/MM/YYYY')<= TO_DATE(X.DATA_FIM_U,'DD/MM/YYYY') AND TO_DATE(X.DATA,'DD/MM/YYYY') >= TO_DATE(X.DATA_CANCELAMENTO_U,'DD/MM/YYYY') THEN 'EXCLUI'
ELSE NULL END ACAO,
TO_NUMBER(TO_CHAR(TO_DATE(X.DATA),'WW')) SEMANA_ANO , X.*
,X.CPF||'-'||X.BM_U||'-'||X.TIPO_JORNADA_U||'-'||X.TURNO_U||'-'||X.DATA_INICIO_U||'-'||X.DATA_FIM_U||'-'||X.DATA_CANCELAMENTO_U||'-'||X.ORDEM_TURNO||'-'||X.ORDEM_ID_HORARIO_DIA||'-'||X.ORDEM_PAR_REG||'-'||X.ORDEM_DIA_CPF||'-'||X.ID_HORARIO||'-'||X.DATA||'-'||X.INICIO_TURNO||'-'||X.INICIO_REGENCIA||'-'||X.FIM_REGENCIA||'-'||X.DATA_PROCESSAMENTO||'-'||X.OBS_PROCESSAMENTO
AS DADOS
FROM 
(
SELECT V.* FROM PONTO_ELETRONICO.VW_SGE_PAR_REGE_ARQ_DIA V LEFT OUTER JOIN (
--SELECT X.CPF, TRUNC(X.MIN_DATA)-(SA.NRO_DIA_SEMANA-2)SEGUNDA_ANTERIOR, X.MIN_DATA, X.MAX_DATA, TRUNC(X.MAX_DATA)+(7-DS.NRO_DIA_SEMANA+1)DOMINGO_SEGUINTE FROM (---SEGUNDA_ANTERIOR E DOMINGO_SEGUINTE
SELECT X.CPF, MIN(DATA) MIN_DATA, MAX(DATA)MAX_DATA --PEGA TODO PERIODO ENVOLVIDO NO ULTIMO AJUSTE (DIFERENCA ENTRE ULTIMA E PENULTIMA CARGA)
FROM( SELECT * FROM PONTO_ELETRONICO.VW_SGE_PAR_REGE_ARQ_DIA --WHERE ID_HORARIO IN(2356, 2458,2401,2611,2634,2636,2790, 2787,2784,2783,2788)--TESTE --7552
)X WHERE X.ORDEM_ID_HORARIO_DIA < 3 --X PEGA TODAS AS DATAS ENVOLVIDAS DAS ULTIMAS 2 CARGAS (DATA_PROCESSAMENTO TABELA: SUGESP_SGE_PAR_REGE_ARQ_DATAS)
GROUP BY X.CPF --PEGA TODO PERIODO ENVOLVIDO NO ULTIMO AJUSTE (DIFERENCA ENTRE ULTIMA E PENULTIMA CARGA) --7
--)X LEFT OUTER JOIN ARTERH.RHTABS_DATAS SA ON TRUNC(SA.DATA_DIA) = TRUNC(X.MIN_DATA) LEFT OUTER JOIN ARTERH.RHTABS_DATAS DS ON TRUNC(DS.DATA_DIA) = TRUNC(X.MAX_DATA)---SEGUNDA_ANTERIOR E DOMINGO_SEGUINTE
)X ON X.CPF = V.CPF AND TRUNC(V.DATA) BETWEEN TRUNC(X.MIN_DATA) AND TRUNC(X.MAX_DATA) --TRUNC(X.SEGUNDA_ANTERIOR) AND TRUNC(X.DOMINGO_SEGUINTE)---SEGUNDA_ANTERIOR E DOMINGO_SEGUINTE--
WHERE X.CPF IS NOT NULL --7552 APENAS OS REGISTROS DO DIA
AND V.ORDEM_PAR_REG = 1 --APENAS O ULTIMO AJUSTE --2522
)X --PONTO_ELETRONICO.VW_GERA_MARCACOES_DIA X 
WHERE X.CPF = C2.CPF AND TO_NUMBER(TO_CHAR(TO_DATE(X.DATA),'WW')) = C2.SEMANA_ANO AND X.DATA = C2.DATA ORDER BY CPF, DATA
)X2
LEFT OUTER JOIN ARTERH.RHTABS_DATAS D ON TRUNC(D.DATA_DIA) = TO_DATE(X2.DATA,'DD/MM/YYYY') 

)LOOP

vCPF := C3.CPF;
vBM := C3.BM_U;
vDATA := C3.DATA;
vDOMINGO_ANTERIOR := C3.DOMINGO_ANTERIOR;
vPROXIMO_DOMINGO := C3.DOMINGO_SEGUINTE;


--vCONTADOR_C3 := vCONTADOR_C3 +1;
--dbms_output.put_line('--vCONTADOR_C3: '||vCONTADOR_C3||' C3.DATA: '||C3.DATA||' C3.ID_HORARIO: '||C3.ID_HORARIO||' C3.INICIO_TURNO: '||C3.INICIO_TURNO||' C3.INICIO_REGENCIA: '||C3.INICIO_REGENCIA||' C3.FIM_REGENCIA: '||C3.FIM_REGENCIA);
--dbms_output.put_line(C3.DADOS);
--dbms_output.put_line(C3.ACAO||'-'||C3.CENARIO_ACAO);

IF C3.ACAO = 'EXCLUI' THEN
dbms_output.put_line('EXCLUI');
ELSE
--dbms_output.put_line('INCLUI'); ---PARTE VALIDAR CONCOMITANCIA ENTRE PARES DE MARCACOES
    IF C3.INICIO_REGENCIA > 0 AND vFIM_REGENCIA_ATUAL - 1 < C3.INICIO_REGENCIA THEN ----SEMPRE IRA PASSAR PELA PRIMEIRA VEZ DEVIDO vFIM_REGENCIA_ATUAL INICIAR ZERADA COMO SE FOSSE UM WHILE
   -- dbms_output.put_line('ACUMULA NO DIA PAR MARCACAO DO ID_HORARIO ATUAL');
    vOBS_REGISTRO := 'S';--vOBS_REGISTRO := 'ACUMULA NO DIA PAR MARCACAO DO ID_HORARIO ATUAL';
    --PARTE CONTROLE DAS HORAS DE REGENCIA
    vTOTAL_HORAS_REGENCIA_DIA := vTOTAL_HORAS_REGENCIA_DIA + (C3.FIM_REGENCIA - C3.INICIO_REGENCIA );
    vQTD_PAR_DIA := vQTD_PAR_DIA +1 ;
    --vTOTAL_HORAS_REGENCIA_SEMANA := vTOTAL_HORAS_REGENCIA_SEMANA + vTOTAL_HORAS_REGENCIA_DIA;
    vINICIO_TURNO_ATUAL := C3.INICIO_TURNO;
    vINICIO_REGENCIA_ATUAL := C3.INICIO_REGENCIA;
    vFIM_REGENCIA_ATUAL := C3.FIM_REGENCIA;

        IF vTURNO_ATUAL <> C3.TURNO_U THEN ---PARA CONTROLAR QUANTIDADE DE TURNOS NO DIA E VALORES POR TURNO
        vQTD_TURNOS_DIA := vQTD_TURNOS_DIA +1;
        vMARCACOES := vMARCACOES||'t'||vQTD_TURNOS_DIA||'i'||vINICIO_TURNO_ATUAL;----PARA MONTAR MARCACOES VALIDAS
        END IF;
        vTURNO_ATUAL := C3.TURNO_U;


        IF vID_HORARIO_ATUAL <> C3.ID_HORARIO THEN ----PARA MONTAR MARCACOES VALIDAS
        vMARCACOES := vMARCACOES||'h'||C3.ID_HORARIO||'j'||C3.TIPO_JORNADA_U||',e'||C3.INICIO_REGENCIA||'s'||C3.FIM_REGENCIA; --   ;2030,1,07:00-09:00-09:20-10:20;2038,3,14:00-15:00-15:20-17:20
        ELSE
        vMARCACOES := vMARCACOES||',e'||C3.INICIO_REGENCIA||'s'||C3.FIM_REGENCIA; --   ;2030,1,07:00-09:00-09:20-10:20;2038,3,14:00-15:00-15:20-17:20
        END IF;
        vID_HORARIO_ATUAL := C3.ID_HORARIO;


    ELSE
    --dbms_output.put_line('DESCONSIDERA NO DIA PAR MARCACAO DO ID_HORARIO ATUAL');
    vOBS_REGISTRO := 'N';--vOBS_REGISTRO := 'DESCONSIDERA NO DIA PAR MARCACAO DO ID_HORARIO ATUAL';
        IF vTURNO_ATUAL_SEM_REGENCIA <> C3.TURNO_U THEN ---PARA CONTROLAR QUANTIDADE DE TURNOS NO DIA E VALORES POR TURNO
        vQTD_TURNOS_SEM_REGENCIA := vQTD_TURNOS_SEM_REGENCIA +1;
        vDADOS_TURNO_SEM_REGENCIA := vDADOS_TURNO_SEM_REGENCIA||'t'||vQTD_TURNOS_SEM_REGENCIA||'i'||C3.INICIO_TURNO;
        END IF;
        vTURNO_ATUAL_SEM_REGENCIA := C3.TURNO_U;
        vDADOS_TURNO_SEM_REGENCIA := vDADOS_TURNO_SEM_REGENCIA||'h'||C3.ID_HORARIO||'j'||C3.TIPO_JORNADA_U||'e'||C3.INICIO_REGENCIA||'s'||C3.FIM_REGENCIA; --   ;2030,1,07:00-09:00-09:20-10:20;2038,3,14:00-15:00-15:20-17:20

    END IF;

END IF;--IF C3.ACAO = 'EXCLUI' THEN

--dbms_output.put_line('--vID_HORARIO_ATUAL: '||vID_HORARIO_ATUAL||' vTOTAL_HORAS_REGENCIA_DIA: '||vTOTAL_HORAS_REGENCIA_DIA||' vINICIO_TURNO_ATUAL: '||vINICIO_TURNO_ATUAL||' vINICIO_REGENCIA_ATUAL: '||vINICIO_REGENCIA_ATUAL||' vFIM_REGENCIA_ATUAL: '||vFIM_REGENCIA_ATUAL||' vMARCACOES: '||vMARCACOES||' vDADOS_TURNO_SEM_REGENCIA: '||vDADOS_TURNO_SEM_REGENCIA);
--dbms_output.put_line('--vTURNO_ATUAL: '||vTURNO_ATUAL||' vQTD_TURNOS_DIA: '||vQTD_TURNOS_DIA||' vTOTAL_HORAS_REGENCIA_SEMANA: '||vTOTAL_HORAS_REGENCIA_SEMANA||' vTURNO_ATUAL_SEM_REGENCIA: '||vTURNO_ATUAL_SEM_REGENCIA||' vQTD_TURNOS_SEM_REGENCIA: '||vQTD_TURNOS_SEM_REGENCIA);
--dbms_output.put_line('--******FIM DE CADA REGISTRO C3 NO DIA*******UPDATE SUGESP_SGE_PAR_REGE_ARQ_DATAS--');
--UPDATE PONTO_ELETRONICO.SUGESP_SGE_PAR_REGE_ARQ_DATAS SET OBS_PROCESSAMENTO = vOBS_REGISTRO WHERE ID_HORARIO = C3.ID_HORARIO AND DATA = C3.DATA AND	INICIO_TURNO = C3.INICIO_TURNO AND INICIO_REGENCIA = C3.INICIO_REGENCIA; COMMIT;
END LOOP; --FIM C3
--FIM C3-------------------------------------------------------LOOP PARA PASSAR POR TODOS OS REGISTROS DE 1 DIA DE 1 SEMANA EXISTENTES DE UM CPF-----------------------------------------------------------------------------------------
--dbms_output.put_line('--******---------****ENCERRA 1 DIA DE UMA SEMANA DE UM CPF*****--INSERT C3 SUGESP_SGE_MARCACOES_DIA-----******');
--dbms_output.put_line('--vCPF: '||vCPF||' vBM: '||vBM||' vDATA: '||vDATA||'vQTD_PAR_DIA: '||vQTD_PAR_DIA||' vMARCACOES: '||vMARCACOES||' vDADOS_TURNO_SEM_REGENCIA: '||vDADOS_TURNO_SEM_REGENCIA||' vTOTAL_HORAS_REGENCIA_DIA: '||vTOTAL_HORAS_REGENCIA_DIA);
--INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_MARCACOES_DIA (DATA_PROCESSAMENTO, CPF, BM, DATA, MARCACOES, TURNO_SEM_REGENCIA, DADOS_REGENCIA, DADOS_EXTRACLASSE)VALUES(SYSDATE, vCPF, vBM, vDATA, vQTD_PAR_DIA||vMARCACOES, vDADOS_TURNO_SEM_REGENCIA, vTOTAL_HORAS_REGENCIA_DIA, vTOTAL_HORAS_REGENCIA_DIA/2);COMMIT;

      --a_rec(v_idx).DATA_PROCESSAMENTO := SYSDATE; 
      a_rec(v_idx).CPF := vCPF; 
      a_rec(v_idx).BM := vBM; 
      a_rec(v_idx).DATA := vDATA;
      a_rec(v_idx).MARCACOES := vQTD_PAR_DIA||vMARCACOES;
      a_rec(v_idx).TURNO_SEM_REGENCIA := vDADOS_TURNO_SEM_REGENCIA;
      a_rec(v_idx).DADOS_REGENCIA := vTOTAL_HORAS_REGENCIA_DIA;
      a_rec(v_idx).DADOS_EXTRACLASSE := vTOTAL_HORAS_REGENCIA_DIA/2;
      v_idx := v_idx + 1;   

    if (mod(v_idx, 100) = 0) then  
          forall i in a_rec.first .. a_rec.last  
          --insert into u values a_rec(i);  
          INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_MARCACOES_DIA (DATA_PROCESSAMENTO, CPF, BM, DATA, MARCACOES, TURNO_SEM_REGENCIA, DADOS_REGENCIA, DADOS_EXTRACLASSE) VALUES(SYSDATE, a_rec(i).CPF, a_rec(i).BM , a_rec(i).DATA, a_rec(i).MARCACOES, a_rec(i).TURNO_SEM_REGENCIA, a_rec(i).DADOS_REGENCIA, a_rec(i).DADOS_EXTRACLASSE);
          a_rec.delete;  
          v_idx := 1;  
       end if;  

-------------AQUI ZERAR VARIAVEIS DE 1 DIA DE 1 SEAMANA
vTOTAL_HORAS_REGENCIA_SEMANA := vTOTAL_HORAS_REGENCIA_SEMANA + vTOTAL_HORAS_REGENCIA_DIA;
--dbms_output.put_line('--vID_HORARIO_ATUAL: '||vID_HORARIO_ATUAL||' vTOTAL_HORAS_REGENCIA_DIA: '||vTOTAL_HORAS_REGENCIA_DIA||' vINICIO_TURNO_ATUAL: '||vINICIO_TURNO_ATUAL||' vINICIO_REGENCIA_ATUAL: '||vINICIO_REGENCIA_ATUAL||' vFIM_REGENCIA_ATUAL: '||vFIM_REGENCIA_ATUAL||' vMARCACOES: '||vMARCACOES||' vDADOS_TURNO_SEM_REGENCIA: '||vDADOS_TURNO_SEM_REGENCIA);
--dbms_output.put_line('--vTURNO_ATUAL: '||vTURNO_ATUAL||' vQTD_TURNOS_DIA: '||vQTD_TURNOS_DIA||' vTOTAL_HORAS_REGENCIA_SEMANA: '||vTOTAL_HORAS_REGENCIA_SEMANA);

END LOOP; --FIM C2


--FIM C2-------------------------------------------------------LOOP PARA PASSAR POR TODOS OS REGISTROS DA SEMANA EXISTENTES DE UM CPF-----------------------------------------------------------------------------------------
--dbms_output.put_line('--*****************************************************************ENCERRA UMA SEMANA DE UM CPF******UPDATE C2 DOMINGO SUGESP_SGE_MARCACOES_DIA*********************************************');
-------------AQUI ZERAR VARIAVEIS DE 1 SEAMANA
--dbms_output.put_line('--vTOTAL_HORAS_REGENCIA_SEMANA: '||vTOTAL_HORAS_REGENCIA_SEMANA);
--dbms_output.put_line('--vCPF: '||vCPF||' vPROXIMO_DOMINGO: '||vPROXIMO_DOMINGO||' vDOMINGO_ANTERIOR: '||vDOMINGO_ANTERIOR);
--UPDATE PONTO_ELETRONICO.SUGESP_SGE_MARCACOES_DIA SET DADOS_REGENCIA = vTOTAL_HORAS_REGENCIA_SEMANA, DADOS_EXTRACLASSE = vTOTAL_HORAS_REGENCIA_SEMANA/2  WHERE TRUNC(DATA_PROCESSAMENTO) = TRUNC(SYSDATE) AND CPF = vCPF and DATA = vDOMINGO_ANTERIOR ;COMMIT;

  /*     if (mod(v_idx, 100) = 0) then  
          forall i in a_rec.first .. a_rec.last  
          --insert into u values a_rec(i);  
          INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_MARCACOES_DIA (DATA_PROCESSAMENTO, CPF, BM, DATA, MARCACOES, TURNO_SEM_REGENCIA, DADOS_REGENCIA, DADOS_EXTRACLASSE) VALUES(SYSDATE, a_rec(i).CPF, a_rec(i).BM , a_rec(i).DATA, a_rec(i).MARCACOES, a_rec(i).TURNO_SEM_REGENCIA, a_rec(i).DADOS_REGENCIA, a_rec(i).DADOS_EXTRACLASSE);
          a_rec.delete;  
          v_idx := 1;  
       end if;  
*/

END LOOP; --FIM C1
--FIM C1-----------------------------------------------------------------------------PEGAR OS CPF E DIAS PARA PROCESSAR-----------------------------------------------------------------------------------------------------------


 /*    if a_rec.first is not null then  
       forall i in a_rec.first .. a_rec.last  
       --insert into u values a_rec(i);  
    INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_MARCACOES_DIA (DATA_PROCESSAMENTO, CPF, BM, DATA, MARCACOES, TURNO_SEM_REGENCIA, DADOS_REGENCIA, DADOS_EXTRACLASSE) VALUES(SYSDATE, a_rec(i).CPF, a_rec(i).BM , a_rec(i).DATA, a_rec(i).MARCACOES, a_rec(i).TURNO_SEM_REGENCIA, a_rec(i).DADOS_REGENCIA, a_rec(i).DADOS_EXTRACLASSE);
    end if; 
    commit;      */
     
    dbms_output.put_line('Tempo: ' || ((dbms_utility.get_time - t0) / 100) || ' segundos');  

END;
END;