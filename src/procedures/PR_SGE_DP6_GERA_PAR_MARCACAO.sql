
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PR_SGE_DP6_GERA_PAR_MARCACAO" 
AS 
BEGIN 

--Kellysson em 19/1/24 baseado (sql_gera_par_marcacoes_b3.sql)


--Kellysson em 9/8/23 nova versao (sql_gera_par_marcacoes_b3.sql) baseada nas 2 anteriores, troquei a view tambem para uma nova VW_SGE_PAR_REGE_ARQ_DATAS_DE_PARA
--Kellysson novo em 7/8/23 nova versão (sql_gera_par_marcacoes_b2.sql) baseado sql_gera_par_marcacoes_b1.sql
--Kellysson em 27/7/23 retomado a ideia de gravar nesta tabela antes de montar o arquivo DE/PARA e UNIR EM DIAS PARA O IFPONTO, ESTAVA TENTANDO CRIAR HORAS EXTRACLASSE DIRETO REGRAS DENTRO DO SQL NO ARQUIVO (sql_4_regras_extraclasse_b1.sql)ANTES DE GRAVAR EM TABELA MAS IRIA FICAR COMPLEXO.
--Kellysson em 19/7/23 trocou o nome DE: (sql_gera_horas_extraclasse_b1.sql) PARA: (sql_gera_par_marcacoes_b1.sql)
--Kellysson em 14/7/23 basaedo no (sql_gera_marcacoes_por_local_b2.sql) mas com uma visao para as HORAS EXTRACLASSE
--Kellysson em 24/10/22 --gera MARCACOES POR LOCAL
DECLARE 
vCONTADOR NUMBER;
vTRUE BOOLEAN := TRUE;
vSALDO_EXTRA_R1 NUMBER;

BEGIN
dbms_output.enable(null);
vCONTADOR :=0;
vSALDO_EXTRA_R1 :=0;

FOR C1 IN (

--SELECT COUNT(1) FROM(

SELECT 
CASE WHEN X3.PROXIMO_INICIO_REGENCIA IS NULL THEN X3.INICIO_TURNO + 270 ELSE X3.PROXIMO_INICIO_REGENCIA END PROXIMA_PERIODO_USAR,
X3.* FROM(
SELECT 
X2.CPF, X2.BM_U, X2.TIPO_JORNADA_U, X2.TURNO_U, X2.DURACAO_AULA_U, X2.CARGA_HORARIA, X2.COORDENACAO_U, X2.INICIO_JORNADA_U, X2.FIM_JORNADA_U, X2.DT_CANCELAMENTO_USAR_U, X2.TIPO, X2.SEMANA_ANO, --X.ORDEM_DIA_CPF, X.ORDEM_TURNO,  X.ORDEM_ID_HORARIO_DIA, X.ORDEM_PAR_REG,
X2.ID_HORARIO, X2.DATA, X2.INICIO_TURNO, X2.INICIO_REGENCIA, X2.FIM_REGENCIA, X2.HORAS_REGENCIA, X2.PROXIMO_INICIO_TURNO, X2.INICIO_REGENCIA_ANTERIOR, X2.PROXIMO_INICIO_REGENCIA, X2.FIM_REGENCIA_ANTERIOR, X2.PROXIMO_FIM_REGENCIA, 
X2.TIPO_QTD_REG_MESMO_TURNO,  
X2.QTD_REG_MESMO_TURNO, 
X2.ORDEM_REG_NO_TURNO, X2.SOMA_REGENCIA_SEMANA, X2.SOMA_REGENCIA_DIA, X2.SOMA_REGENCIA_TURNO, 
X2.OBS_PROCESSAMENTO, X2.CONTROLE_MINUTOS_EXTRACLASSE, X2.SOMA_EXTRA_IGUAL_TURNO_E_DIA, X2.EXTRA_IGUAL_TURNO_E_DIA, X2.EXTRA_IGUAL_TURNO_DIA_DIFERE, X2.EXTRA_DIFERE_TURNO_DIA_IGUAL, X2.EXTRA_DIFERE_TURNO_E_DIA
FROM(
SELECT X.*, 
T.SOMA_REGENCIA_TURNO, T.QTD_REG_MESMO_TURNO, T.SOMA_EXTRA_IGUAL_TURNO_E_DIA, D.SOMA_REGENCIA_DIA, S.SOMA_REGENCIA_SEMANA,
ROW_NUMBER() OVER(PARTITION BY X.CPF, X.DATA, X.INICIO_TURNO ORDER BY X.CPF, X.SEMANA_ANO, X.TIPO, X.DATA, X.INICIO_TURNO, X.INICIO_REGENCIA)ORDEM_REG_NO_TURNO
FROM (
SELECT 
V.CPF, V.BM_U, V.TIPO_JORNADA_U, V.TURNO_U, V.DURACAO_AULA_U, V.CARGA_HORARIA, V.COORDENACAO_U, V.INICIO_JORNADA_U, V.FIM_JORNADA_U, V.DT_CANCELAMENTO_USAR_U, V.TIPO,
V.SEMANA_ANO, --V.ORDEM_DIA_CPF, V.ORDEM_TURNO, V.ORDEM_REG_NO_TURNO, V.ORDEM_ID_HORARIO_DIA, V.ORDEM_PAR_REG,  
V.ID_HORARIO, V.DATA,  V.INICIO_TURNO, V.INICIO_REGENCIA, V.FIM_REGENCIA,(V.FIM_REGENCIA-V.INICIO_REGENCIA)HORAS_REGENCIA,
LEAD(V.INICIO_TURNO, 1, NULL) OVER(PARTITION BY V.CPF,V.DATA, V.INICIO_TURNO ORDER BY  V.CPF, V.SEMANA_ANO, V.TIPO, V.DATA, V.INICIO_TURNO, V.INICIO_REGENCIA) PROXIMO_INICIO_TURNO,
LAG(V.INICIO_REGENCIA, 1, NULL) OVER(PARTITION BY V.CPF,V.DATA, V.INICIO_TURNO ORDER BY  V.CPF, V.SEMANA_ANO, V.TIPO, V.DATA, V.INICIO_TURNO, V.INICIO_REGENCIA) INICIO_REGENCIA_ANTERIOR,
LEAD(V.INICIO_REGENCIA, 1, NULL) OVER(PARTITION BY V.CPF,V.DATA, V.INICIO_TURNO ORDER BY  V.CPF, V.SEMANA_ANO, V.TIPO, V.DATA, V.INICIO_TURNO, V.INICIO_REGENCIA) PROXIMO_INICIO_REGENCIA,
LAG(V.FIM_REGENCIA, 1, NULL) OVER(PARTITION BY V.CPF,V.DATA, V.INICIO_TURNO ORDER BY  V.CPF, V.SEMANA_ANO, V.TIPO, V.DATA, V.INICIO_TURNO, V.INICIO_REGENCIA) FIM_REGENCIA_ANTERIOR,
LEAD(V.FIM_REGENCIA, 1, NULL) OVER(PARTITION BY V.CPF,V.DATA, V.INICIO_TURNO ORDER BY  V.CPF, V.SEMANA_ANO, V.TIPO, V.DATA, V.INICIO_TURNO, V.INICIO_REGENCIA) PROXIMO_FIM_REGENCIA,
V.OBS_PROCESSAMENTO, 
V.CONTROLE_MINUTOS_EXTRACLASSE, V.EXTRA_IGUAL_TURNO_E_DIA, V.EXTRA_IGUAL_TURNO_DIA_DIFERE, V.EXTRA_DIFERE_TURNO_DIA_IGUAL, V.EXTRA_DIFERE_TURNO_E_DIA
,CASE WHEN V.OBS_PROCESSAMENTO = 'ACUMULA' THEN 'REGENCIA' ELSE 'EXTRA' END TIPO_QTD_REG_MESMO_TURNO
FROM PONTO_ELETRONICO.VW_SGE_PAR_REGE_ARQ_DATAS_DE_PARA V WHERE V.OBS_PROCESSAMENTO IN ('ACUMULA','TOTALIZA')
--AND V.ID_HORARIO IN(6059,6062)---TESTES
ORDER BY V.CPF, V.SEMANA_ANO, V.TIPO, V.DATA, V.INICIO_TURNO, V.INICIO_REGENCIA
)X 

LEFT OUTER JOIN
(SELECT V.CPF, V.SEMANA_ANO, V.DATA, V.INICIO_TURNO, SUM(V.FIM_REGENCIA-V.INICIO_REGENCIA)SOMA_REGENCIA_TURNO, SUM(EXTRA_IGUAL_TURNO_E_DIA)SOMA_EXTRA_IGUAL_TURNO_E_DIA, COUNT(1)QTD_REG_MESMO_TURNO 
FROM PONTO_ELETRONICO.VW_SGE_PAR_REGE_ARQ_DATAS_DE_PARA V WHERE V.OBS_PROCESSAMENTO = 'ACUMULA' AND V.TIPO = 'DIA' 
GROUP BY V.CPF, V.SEMANA_ANO, V.DATA, V.INICIO_TURNO)T ON T.CPF = X.CPF AND T.SEMANA_ANO = X.SEMANA_ANO AND T.DATA = X.DATA AND T.INICIO_TURNO = X.INICIO_TURNO 
LEFT OUTER JOIN
(SELECT V.CPF, V.SEMANA_ANO, V.DATA, SUM(V.FIM_REGENCIA-V.INICIO_REGENCIA)SOMA_REGENCIA_DIA
FROM PONTO_ELETRONICO.VW_SGE_PAR_REGE_ARQ_DATAS_DE_PARA V WHERE V.OBS_PROCESSAMENTO = 'ACUMULA' AND V.TIPO = 'DIA' 
GROUP BY V.CPF, V.SEMANA_ANO, V.DATA )D ON D.CPF = X.CPF AND D.SEMANA_ANO = X.SEMANA_ANO AND D.DATA = X.DATA 
LEFT OUTER JOIN
(SELECT V.CPF, V.SEMANA_ANO, SUM(V.FIM_REGENCIA-V.INICIO_REGENCIA)SOMA_REGENCIA_SEMANA
FROM PONTO_ELETRONICO.VW_SGE_PAR_REGE_ARQ_DATAS_DE_PARA V WHERE V.OBS_PROCESSAMENTO = 'ACUMULA' AND V.TIPO = 'DIA' 
GROUP BY V.CPF, V.SEMANA_ANO )S  ON S.CPF = X.CPF AND S.SEMANA_ANO = X.SEMANA_ANO 

WHERE (X.OBS_PROCESSAMENTO = 'ACUMULA' OR (X.OBS_PROCESSAMENTO = 'TOTALIZA' AND X.PROXIMO_INICIO_TURNO IS NULL)) ---TIRANDO DUPLICIDADE EM DIAS QUE TEM MAIS DE 1 ID_HORARIO MESMO TURNO E ALGUM DELES NAO TEM HORAS DE REGENCIA
--AND X.ID_HORARIO IN(6059,6062) --TESTES
)X2
)X3
--WHERE X3.CPF = '00060331640'
--WHERE X3.ID_HORARIO IN(6059,6062) --TESETS
--WHERE ROWNUM < 100000
--where x3.CPF IN ('03620776652','55657540620','00651142644','02613598603','03232721699','04562777656','06546845610','56482396615','59375280691','84200626691')
--where x3.CPF IN ('00357614666')

--)--COUNT


)LOOP
--vCONTADOR := vCONTADOR +1;
--dbms_output.put_line('--vCONTADOR: '||vCONTADOR);
--dbms_output.put_line('C1.PROXIMA_PERIODO_USAR, C1.CPF, C1.TIPO, C1.DATA, C1.INICIO_TURNO, C1.INICIO_REGENCIA, C1.FIM_REGENCIA, C1.HORAS_REGENCIA, C1.EXTRA_IGUAL_TURNO_E_DIA, C1.EXTRA_IGUAL_TURNO_DIA_DIFERE');
dbms_output.put_line(C1.PROXIMA_PERIODO_USAR||'-'||C1.CPF||'-'||C1.TIPO||'-'||C1.DATA||'-'||C1.INICIO_TURNO||'-'||C1.INICIO_REGENCIA||'-'||C1.FIM_REGENCIA||'-'||C1.HORAS_REGENCIA||'-'||C1.EXTRA_IGUAL_TURNO_E_DIA||'-'||C1.EXTRA_IGUAL_TURNO_DIA_DIFERE);

--IF GERAL
IF C1.TIPO = 'TOTAL' THEN ---DOMINGO
--dbms_output.put_line('INSERT_TOTAIS NO DOMINGO');
vTRUE := TRUE;
--INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, TOTAL_MINUTOS, CONTROLE_MINUTOS_EXTRACLASSE, TIPO_MARCACAO, INICIO_TURNO, DATA_PROCESSAMENTO)VALUES(C1.CPF, C1.DATA,0, 0, 'TOTAIS', C1.INICIO_TURNO, SYSDATE );COMMIT;

ELSIF C1.TIPO = 'DIA' AND C1.TIPO_QTD_REG_MESMO_TURNO = 'EXTRA' AND C1.EXTRA_IGUAL_TURNO_DIA_DIFERE <> 0 THEN ---TURNO COM REGENCIA NA REGRA 2
--dbms_output.put_line('INSERT_MARCACOES_EXTRACLASSE_DIA_TODO');  
INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, C1.EXTRA_IGUAL_TURNO_DIA_DIFERE, C1.INICIO_TURNO, C1.INICIO_TURNO, C1.INICIO_TURNO+C1.EXTRA_IGUAL_TURNO_DIA_DIFERE, 'EXTRA_USADA', SYSDATE, 'REGRA2', 'DE/PARA_EXTENSOES_2023');COMMIT; --validado 10/8/23

ELSIF C1.TIPO = 'DIA' AND C1.TIPO_QTD_REG_MESMO_TURNO = 'REGENCIA' AND TO_DATE(C1.DATA,'DD/MM/YYYY') NOT BETWEEN TO_DATE(C1.INICIO_JORNADA_U,'DD/MM/YYYY') AND TO_DATE(C1.FIM_JORNADA_U,'DD/MM/YYYY')
AND C1.QTD_REG_MESMO_TURNO = 1 AND C1.ORDEM_REG_NO_TURNO = 1 THEN ---NOVO EM 29/7/23 --TURNO SEM REGENCIA ANTES DO INICIO E FIM MAS QUE COMPLETA A PRIMEIRA OU ULTIMA SEMANA PARA CONTAS NA SEMANA
INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, 270, C1.INICIO_TURNO, C1.INICIO_TURNO, C1.INICIO_TURNO+270, 'EXTRA_DISPONIVEL', SYSDATE, 'DIA_FORA', 'DE/PARA_EXTENSOES_2023' );COMMIT;

ELSIF C1.TIPO = 'DIA' AND C1.TIPO_QTD_REG_MESMO_TURNO = 'REGENCIA' AND TO_DATE(C1.DATA,'DD/MM/YYYY') BETWEEN TO_DATE(C1.INICIO_JORNADA_U,'DD/MM/YYYY') AND TO_DATE(C1.FIM_JORNADA_U,'DD/MM/YYYY') THEN ---TURNO COM REGENCIA AJUSTADO EM 29/7/23
--dbms_output.put_line('TURNO COM REGENCIA');
    ---TURNO COM REGENCIA
    INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, CONTROLE_MINUTOS_EXTRACLASSE, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
    VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, C1.FIM_REGENCIA-C1.INICIO_REGENCIA, C1.FIM_REGENCIA-C1.INICIO_REGENCIA, C1.INICIO_TURNO, C1.INICIO_REGENCIA, C1.FIM_REGENCIA, 'REGENCIA', SYSDATE, NULL, 'DE/PARA_EXTENSOES_2023' );COMMIT; --validado 10/8/23

    --INICIO---NOVO EM 7/8/23 PARA CRIAR AS HORAS EXTRACLASSE REGRA 1
    --POPULAR VARIAVEL SALDO TURNO
    IF C1.ORDEM_REG_NO_TURNO = 1 THEN
    vSALDO_EXTRA_R1 := C1.SOMA_EXTRA_IGUAL_TURNO_E_DIA;
    dbms_output.put_line('INICIO vSALDO_EXTRA_R1: '||vSALDO_EXTRA_R1);
    END IF;

   --INICIO EM 9/8/23 ---PEGO DA b1----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 IF vSALDO_EXTRA_R1 > 0 THEN --NOVO IF GERAL EM 9/8/23 PARA CONFERIR VARIAVEL vSALDO_EXTRA_R1 SE TEM SALDO  
    IF
    C1.QTD_REG_MESMO_TURNO = 1 AND C1.ORDEM_REG_NO_TURNO = 1 AND C1.INICIO_REGENCIA = C1.INICIO_TURNO AND C1.FIM_REGENCIA =  C1.INICIO_TURNO+270 THEN --'1_R'
    vTRUE := TRUE;
    --dbms_output.put_line('*');
    --dbms_output.put_line('INSERT_MARCACOES_REGENCIA 1_R');

    ELSIF
    C1.QTD_REG_MESMO_TURNO = 1 AND C1.ORDEM_REG_NO_TURNO = 1 AND C1.INICIO_REGENCIA = C1.INICIO_TURNO AND C1.FIM_REGENCIA < C1.INICIO_TURNO+270 THEN --'1_RE'
        IF vSALDO_EXTRA_R1 <= (C1.INICIO_TURNO+270) - C1.FIM_REGENCIA THEN --IF NOVO 9/8/23
        --dbms_output.put_line('INSERT_MARCACOES_REGENCIA 1_RE');
        INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
        VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, vSALDO_EXTRA_R1, C1.INICIO_TURNO, C1.FIM_REGENCIA, C1.FIM_REGENCIA+vSALDO_EXTRA_R1, 'EXTRA_USADA', SYSDATE, '1_RE_SALDO<=' , 'DE/PARA_EXTENSOES_2023');COMMIT;--validado 10/8/23
        vSALDO_EXTRA_R1 := vSALDO_EXTRA_R1 - vSALDO_EXTRA_R1;
        ELSIF vSALDO_EXTRA_R1 > (C1.INICIO_TURNO+270)-C1.FIM_REGENCIA THEN 
        INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
        VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, (C1.INICIO_TURNO+270)-C1.FIM_REGENCIA, C1.INICIO_TURNO, C1.FIM_REGENCIA, C1.INICIO_TURNO+270, 'EXTRA_USADA', SYSDATE, '1_RE_SALDO>' , 'DE/PARA_EXTENSOES_2023');COMMIT;
        vSALDO_EXTRA_R1 := vSALDO_EXTRA_R1 - ((C1.INICIO_TURNO+270)-C1.FIM_REGENCIA);
        END IF;

    ELSIF
    C1.QTD_REG_MESMO_TURNO = 1 AND C1.ORDEM_REG_NO_TURNO = 1 AND C1.INICIO_REGENCIA <> C1.INICIO_TURNO AND C1.FIM_REGENCIA = C1.INICIO_TURNO+270 THEN --'1_ER'
    --dbms_output.put_line('INSERT_MARCACOES_EXTRACLASSE 1_ER');  
        IF vSALDO_EXTRA_R1 <= C1.INICIO_REGENCIA - C1.INICIO_TURNO THEN --IF NOVO 9/8/23
        INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
        VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, vSALDO_EXTRA_R1, C1.INICIO_TURNO,  C1.INICIO_REGENCIA-vSALDO_EXTRA_R1, C1.INICIO_REGENCIA, 'EXTRA_USADA', SYSDATE, '1_ER_SALDO<=' , 'DE/PARA_EXTENSOES_2023');COMMIT;--validado 10/8/23
        vSALDO_EXTRA_R1 := vSALDO_EXTRA_R1 - vSALDO_EXTRA_R1;
        ELSIF vSALDO_EXTRA_R1 > C1.INICIO_REGENCIA - C1.INICIO_TURNO THEN
        INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
        VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, C1.INICIO_REGENCIA - C1.INICIO_TURNO, C1.INICIO_TURNO,  C1.INICIO_REGENCIA+vSALDO_EXTRA_R1, C1.INICIO_REGENCIA, 'EXTRA_USADA', SYSDATE, '1_ER_SALDO>' , 'DE/PARA_EXTENSOES_2023');COMMIT;
        vSALDO_EXTRA_R1 := vSALDO_EXTRA_R1 - (C1.INICIO_REGENCIA - C1.INICIO_TURNO);
        END IF;

    ELSIF
    C1.QTD_REG_MESMO_TURNO = 1 AND C1.ORDEM_REG_NO_TURNO = 1 AND C1.INICIO_REGENCIA <> C1.INICIO_TURNO AND C1.FIM_REGENCIA < C1.INICIO_TURNO+270 THEN --'1_ERE'
    --dbms_output.put_line('INSERT_MARCACOES_REGENCIA 1_ERE_E1');
        IF vSALDO_EXTRA_R1 <= C1.INICIO_REGENCIA - C1.INICIO_TURNO THEN --IF NOVO 9/8/23
        INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
        VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, vSALDO_EXTRA_R1, C1.INICIO_TURNO, C1.INICIO_REGENCIA-vSALDO_EXTRA_R1, C1.INICIO_REGENCIA, 'EXTRA_USADA', SYSDATE, '1_ERE_E1_SALDO<=' , 'DE/PARA_EXTENSOES_2023');COMMIT;--validado 10/8/23
        vSALDO_EXTRA_R1 := vSALDO_EXTRA_R1 - vSALDO_EXTRA_R1;
        ELSIF vSALDO_EXTRA_R1 > C1.INICIO_REGENCIA - C1.INICIO_TURNO THEN --IF NOVO 9/8/23
        INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
        VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, C1.INICIO_REGENCIA-C1.INICIO_TURNO, C1.INICIO_TURNO, C1.INICIO_TURNO, C1.INICIO_REGENCIA, 'EXTRA_USADA', SYSDATE, '1_ERE_E1_SALDO>', 'DE/PARA_EXTENSOES_2023' );COMMIT;--validado 10/8/23
        vSALDO_EXTRA_R1 := vSALDO_EXTRA_R1 - (C1.INICIO_REGENCIA-C1.INICIO_TURNO);
        END IF;

        IF vSALDO_EXTRA_R1 <= (C1.INICIO_TURNO+270) - C1.FIM_REGENCIA THEN --IF NOVO 9/8/23
        --dbms_output.put_line('INSERT_MARCACOES_REGENCIA 1_ERE_E2');
        INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
        VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, vSALDO_EXTRA_R1, C1.INICIO_TURNO, C1.FIM_REGENCIA, C1.FIM_REGENCIA+vSALDO_EXTRA_R1, 'EXTRA_USADA', SYSDATE, '1_ERE_E2_SALDO<=', 'DE/PARA_EXTENSOES_2023' );COMMIT;--validado 10/8/23
        vSALDO_EXTRA_R1 := vSALDO_EXTRA_R1 - vSALDO_EXTRA_R1;
        ELSIF vSALDO_EXTRA_R1 > (C1.INICIO_TURNO+270) - C1.FIM_REGENCIA THEN 
        INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
        VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, (C1.INICIO_TURNO+270)-C1.FIM_REGENCIA, C1.INICIO_TURNO, C1.FIM_REGENCIA, C1.INICIO_TURNO+270, 'EXTRA_USADA', SYSDATE, '1_ERE_E2_SALDO>', 'DE/PARA_EXTENSOES_2023' );COMMIT;
        vSALDO_EXTRA_R1 := vSALDO_EXTRA_R1 - ((C1.INICIO_TURNO+270)-C1.FIM_REGENCIA);
        END IF;
    --FIM-APENAS 1 REGENCIA NO TURNO

 --/*  


    --INICIO-MAIS 1 REGENCIA NO TURNO - PRIMEIRO REGISTRO
    ELSIF 
    C1.QTD_REG_MESMO_TURNO <> 1 AND C1.ORDEM_REG_NO_TURNO = 1 AND C1.INICIO_REGENCIA > C1.INICIO_TURNO THEN
    --dbms_output.put_line('INSERT_MARCACOES_EXTRACLASSE PRIMEIRO REGISTRO MAIS DE 1 R 1_ER');  
        IF vSALDO_EXTRA_R1 <= C1.INICIO_REGENCIA-C1.INICIO_TURNO THEN --IF NOVO 9/8/23
        INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
        VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, vSALDO_EXTRA_R1, C1.INICIO_TURNO, C1.INICIO_REGENCIA - vSALDO_EXTRA_R1, C1.INICIO_REGENCIA, 'EXTRA_USADA', SYSDATE, '1º_REG_MAIS_DE_1R_ER_SALDO<=', 'DE/PARA_EXTENSOES_2023' );COMMIT;--validado 10/8/23
        vSALDO_EXTRA_R1 := vSALDO_EXTRA_R1 - vSALDO_EXTRA_R1;
        ELSIF vSALDO_EXTRA_R1 > C1.INICIO_REGENCIA-C1.INICIO_TURNO THEN 
        INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
        VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, C1.INICIO_REGENCIA-C1.INICIO_TURNO, C1.INICIO_TURNO, C1.INICIO_TURNO, C1.INICIO_REGENCIA, 'EXTRA_USADA', SYSDATE, '1º_REG_MAIS_DE_1R_ER_SALDO>', 'DE/PARA_EXTENSOES_2023' );COMMIT;--validado 10/8/23
        vSALDO_EXTRA_R1 := vSALDO_EXTRA_R1 - (C1.INICIO_REGENCIA-C1.INICIO_TURNO); 
        END IF;
    --FIM-MAIS 1 REGENCIA NO TURNO - PRIMEIRO REGISTRO

    --INICIO-MAIS 1 REGENCIA NO TURNO - REGISTROS MEIO TURNO OU ULTIMO
    ELSIF 
    C1.QTD_REG_MESMO_TURNO <> 1 AND C1.ORDEM_REG_NO_TURNO > 1 AND C1.ORDEM_REG_NO_TURNO < C1.QTD_REG_MESMO_TURNO AND C1.FIM_REGENCIA_ANTERIOR <> C1.INICIO_REGENCIA THEN
    --dbms_output.put_line('INSERT_MARCACOES_EXTRACLASSE REGISTRO MEIO OU ULTIMO MAIS DE 1 R 1_ER');  
        IF vSALDO_EXTRA_R1 <= C1.INICIO_REGENCIA-C1.FIM_REGENCIA_ANTERIOR THEN --IF NOVO 9/8/23
        INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
        VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, vSALDO_EXTRA_R1, C1.INICIO_TURNO, C1.INICIO_REGENCIA - vSALDO_EXTRA_R1, C1.INICIO_REGENCIA, 'EXTRA_USADA', SYSDATE, 'REG_MEIO_OU_ULT_MAIS_DE_1R_ER<=', 'DE/PARA_EXTENSOES_2023' );COMMIT;
        vSALDO_EXTRA_R1 := vSALDO_EXTRA_R1 - vSALDO_EXTRA_R1;
        ELSIF vSALDO_EXTRA_R1 > C1.INICIO_REGENCIA-C1.FIM_REGENCIA_ANTERIOR THEN 
        INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
        VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, C1.INICIO_REGENCIA-C1.FIM_REGENCIA_ANTERIOR, C1.INICIO_TURNO, C1.FIM_REGENCIA_ANTERIOR, C1.INICIO_REGENCIA, 'EXTRA_USADA', SYSDATE, 'REG_MEIO_OU_ULT_MAIS_DE_1R_ER>', 'DE/PARA_EXTENSOES_2023' );COMMIT; --validado 10/8/23
        vSALDO_EXTRA_R1 := vSALDO_EXTRA_R1 - (C1.INICIO_REGENCIA-C1.FIM_REGENCIA_ANTERIOR);
        END IF;
    --FIM-MAIS 1 REGENCIA NO TURNO - REGISTROS MEIO TURNO OU ULTIMO


    --INICIO-MAIS 1 REGENCIA NO TURNO - ULTIMO REGISTRO SE ATENDER CONDICAO
    ELSIF 
    C1.QTD_REG_MESMO_TURNO <> 1 AND C1.ORDEM_REG_NO_TURNO > 1 AND C1.ORDEM_REG_NO_TURNO = C1.QTD_REG_MESMO_TURNO THEN
        IF C1.FIM_REGENCIA_ANTERIOR <> C1.INICIO_REGENCIA AND C1.FIM_REGENCIA = C1.INICIO_TURNO+270 THEN
        --dbms_output.put_line('INSERT_MARCACOES_EXTRACLASSE REGISTRO ULTIMO MAIS DE 1 R 1_ER');  
            IF vSALDO_EXTRA_R1 <= C1.INICIO_REGENCIA-C1.FIM_REGENCIA_ANTERIOR THEN --IF NOVO 9/8/23
            INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
            VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, vSALDO_EXTRA_R1, C1.INICIO_TURNO, C1.INICIO_REGENCIA - vSALDO_EXTRA_R1, C1.INICIO_REGENCIA, 'EXTRA_USADA', SYSDATE, 'REG_ULTIMO_MAIS_DE_1R_ER<=', 'DE/PARA_EXTENSOES_2023' );COMMIT;--validado 10/8/23
            vSALDO_EXTRA_R1 := vSALDO_EXTRA_R1 - vSALDO_EXTRA_R1;
            ELSIF vSALDO_EXTRA_R1 > C1.INICIO_REGENCIA-C1.FIM_REGENCIA_ANTERIOR THEN 
            INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
            VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, C1.INICIO_REGENCIA-C1.FIM_REGENCIA_ANTERIOR, C1.INICIO_TURNO, C1.FIM_REGENCIA_ANTERIOR, C1.INICIO_REGENCIA, 'EXTRA_USADA', SYSDATE, 'REG_ULTIMO_MAIS_DE_1R_ER>', 'DE/PARA_EXTENSOES_2023' );COMMIT;
            vSALDO_EXTRA_R1 := vSALDO_EXTRA_R1 - (C1.INICIO_REGENCIA-C1.FIM_REGENCIA_ANTERIOR);
            END IF;

        ELSIF C1.FIM_REGENCIA_ANTERIOR = C1.INICIO_REGENCIA AND C1.FIM_REGENCIA < C1.INICIO_TURNO+270 THEN
        --dbms_output.put_line('INSERT_MARCACOES_EXTRACLASSE REGISTRO ULTIMO MAIS DE 1 R 1_RE');  
            IF vSALDO_EXTRA_R1 <= (C1.INICIO_TURNO+270)-C1.FIM_REGENCIA THEN --IF NOVO 9/8/23
            INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
            VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, vSALDO_EXTRA_R1, C1.INICIO_TURNO, (C1.INICIO_TURNO+270) - vSALDO_EXTRA_R1, C1.INICIO_TURNO+270, 'EXTRA_USADA', SYSDATE, 'REG_ULTIMO_MAIS_DE_1R_RE<=', 'DE/PARA_EXTENSOES_2023' );COMMIT;--validado 10/8/23
            vSALDO_EXTRA_R1 := vSALDO_EXTRA_R1 - vSALDO_EXTRA_R1;
            ELSIF vSALDO_EXTRA_R1 > (C1.INICIO_TURNO+270)-C1.FIM_REGENCIA THEN 
            INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
            VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, (C1.INICIO_TURNO+270)-C1.FIM_REGENCIA, C1.INICIO_TURNO, C1.FIM_REGENCIA, C1.INICIO_TURNO+270, 'EXTRA_USADA', SYSDATE, 'REG_ULTIMO_MAIS_DE_1R_RE>', 'DE/PARA_EXTENSOES_2023' );COMMIT;
            vSALDO_EXTRA_R1 := vSALDO_EXTRA_R1 - ((C1.INICIO_TURNO+270)-C1.FIM_REGENCIA);
            END IF;

        ELSIF C1.FIM_REGENCIA_ANTERIOR <> C1.INICIO_REGENCIA AND C1.FIM_REGENCIA < C1.INICIO_TURNO+270 THEN
        --dbms_output.put_line('2/1-INSERT_MARCACOES_EXTRACLASSE REGISTRO ULTIMO MAIS DE 1 R 1_ER');  
            IF vSALDO_EXTRA_R1 <= C1.INICIO_REGENCIA-C1.FIM_REGENCIA_ANTERIOR THEN --IF NOVO 9/8/23
            INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
            VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, vSALDO_EXTRA_R1, C1.INICIO_TURNO, C1.INICIO_REGENCIA - vSALDO_EXTRA_R1, C1.INICIO_REGENCIA, 'EXTRA_USADA', SYSDATE, '2/1-REG_ULT_MAIS_DE_1R_ER<=', 'DE/PARA_EXTENSOES_2023' );COMMIT;--validado 10/8/23
            vSALDO_EXTRA_R1 := vSALDO_EXTRA_R1 - vSALDO_EXTRA_R1;
            ELSIF vSALDO_EXTRA_R1 > C1.INICIO_REGENCIA-C1.FIM_REGENCIA_ANTERIOR THEN 
            INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
            VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, C1.INICIO_REGENCIA-C1.FIM_REGENCIA_ANTERIOR, C1.INICIO_TURNO, C1.FIM_REGENCIA_ANTERIOR, C1.INICIO_REGENCIA, 'EXTRA_USADA', SYSDATE, '2/1-REG_ULT_MAIS_DE_1R_ER>', 'DE/PARA_EXTENSOES_2023' );COMMIT;--validado 10/8/23
            vSALDO_EXTRA_R1 := vSALDO_EXTRA_R1 - (C1.INICIO_REGENCIA-C1.FIM_REGENCIA_ANTERIOR);
            END IF;
        --dbms_output.put_line('2/2-INSERT_MARCACOES_EXTRACLASSE REGISTRO ULTIMO MAIS DE 1 R 1_RE');  
            IF vSALDO_EXTRA_R1 <= (C1.INICIO_TURNO+270)-C1.FIM_REGENCIA THEN --IF NOVO 9/8/23
            INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
            VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, vSALDO_EXTRA_R1, C1.INICIO_TURNO, (C1.INICIO_TURNO+270)-vSALDO_EXTRA_R1, C1.INICIO_TURNO+270, 'EXTRA_USADA', SYSDATE, '2/2-REG_ULT_MAIS_DE_1R_RE<=', 'DE/PARA_EXTENSOES_2023' );COMMIT;--validado 10/8/23
            vSALDO_EXTRA_R1 := vSALDO_EXTRA_R1 - vSALDO_EXTRA_R1;
            ELSIF vSALDO_EXTRA_R1 > (C1.INICIO_TURNO+270)-C1.FIM_REGENCIA THEN 
            INSERT INTO PONTO_ELETRONICO.SUGESP_SGE_PAR_MARCACOES (CPF, DATA, ID_HORARIO, TOTAL_MINUTOS, INICIO_TURNO, INICIO_MINUTOS, FIM_MINUTOS, TIPO_MARCACAO, DATA_PROCESSAMENTO, OBS_PROCESSAMENTO ,TIPO_REGISTRO)
            VALUES(C1.CPF, C1.DATA, C1.ID_HORARIO, (C1.INICIO_TURNO+270)-C1.FIM_REGENCIA, C1.INICIO_TURNO, C1.FIM_REGENCIA, C1.INICIO_TURNO+270, 'EXTRA_USADA', SYSDATE, '2/2-REG_ULT_MAIS_DE_1R_RE>', 'DE/PARA_EXTENSOES_2023' );COMMIT;            
            vSALDO_EXTRA_R1 := vSALDO_EXTRA_R1 - ((C1.INICIO_TURNO+270)-C1.FIM_REGENCIA);
             END IF;
         END IF;   
    --FIM-MAIS 1 REGENCIA NO TURNO - ULTIMO REGISTRO SE ATENDER CONDICAO

 -- */ 
    END IF;---TURNO COM REGENCIA


 END IF;--NOVO IF GERAL EM 9/8/23 PARA CONFERIR VARIAVEL vSALDO_EXTRA_R1 SE TEM SALDO     
   --FIM EM 9/8/23 ---PEGO DA b1-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


END IF;--FIM IF GERAL
END LOOP;


END;
END;