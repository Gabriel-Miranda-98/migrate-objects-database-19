
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."DIA_FALTA_TRABALHO" (
    pDT_INICIO IN DATE,
    pDT_FIM    IN DATE,
    pEMPRESA IN CHAR,
    pTP_CONTR IN CHAR,
    pCONT    IN VARCHAR2,
    pTP_ATT    IN VARCHAR2)
AS
  vCONTADOR                  NUMBER;
  data_inicial               DATE;
  data_final                 DATE;
  num_dias                   NUMBER;
  vDATA_DIA                  DATE;
  vDATA_INICIO_PERIODO       DATE;
  vDATA_FIM_PERIODO          DATE;
  vNRO_DIA_SEMANA            NUMBER;
  vDIA_SEMANA                VARCHAR2 (15 BYTE);
  vQTD_DIAS_NA_ESCALA        NUMBER;
  vQTD_DIAS_CICLO_ESCALA     NUMBER;
  vQTD_VEZES_CICLO_NA_ESCALA NUMBER;
  vDIA_DO_CICLO_ATUAL        NUMBER;
  vTIPO_DATA                 VARCHAR2 (100 BYTE);
  V_DIAS_TRABALHO_MES        NUMBER;
  COD_SIT_MES_VALE LISTA;
  COD_SIT_MES_FREQUE LISTA;
BEGIN
  V_DIAS_TRABALHO_MES:=0;
  dbms_output.enable(NULL);
  dbms_output.put_line('PARAMETROS'||pDT_INICIO||pDT_FIM||pEMPRESA||pTP_CONTR||pCONT);
  vCONTADOR                  :=0;
  vDATA_INICIO_PERIODO       := pDT_INICIO;------------------**************************alterar datas
  vDATA_FIM_PERIODO          := pDT_FIM;   ------------------**************************alterar datas
  vNRO_DIA_SEMANA            := 0;
  vDIA_SEMANA                := NULL;
  vQTD_DIAS_NA_ESCALA        :=0;
  vQTD_DIAS_CICLO_ESCALA     := 0;
  vQTD_VEZES_CICLO_NA_ESCALA := 0;
  vDIA_DO_CICLO_ATUAL        := 0;
  vTIPO_DATA                 := NULL;
  COD_SIT_MES_VALE           := LISTA('0029','0521','1003','1126','1156');
  COD_SIT_MES_FREQUE         :=LISTA('0020','0033','0034','0035','0040','0504','0508','0514','0515','0516','0519','0522','0523','0529','0531','0533','0534','0535','0538','0541','0542','0546','0547','0548','0549','0553','0556', '0557','0558',/*'1004,'*/'1006','1012','1100','1101','1102','1103','1107','1109','1110','1111','1113','1116','1120','1121','1122','1125','1128','1129','1130','1131','1134','1135','1136','1137','1138','1140','1142','1143','1144', '1145','1146','1147','1148','1149','1150','1151','1152','1157','1159','1160','1164','1165','1166','1167','1168','1169','1170','1171','1174','1175','1179','1183','1184','1185','1186','1188','1190','1191','1192','1194','1195', '0032', '0037', '0038', '0201', '0503', '0506', '0509', '0512', '0513', '0517', '0518', '0524', '0525', '0526', '0528', '0537', '0559', '0703', '1127', '1299', '5114' );
  --INICIO----------------------------------------------1º FOR PARA PEGAR O  PUBLICO E PERIODO DESEJADO
  FOR c1 IN
  (
  ---SELECT PARA BUSCAR OS BMS
  SELECT B.CODIGO_EMPRESA,
    B.TIPO_CONTRATO,
    B.CODIGO,
    B.CODIGO_ESCALA,
    b.dt_ult_escala,
    B.SITUACAO_FUNCIONAL COD_SIT_FUNC,
    SF.DESCRICAO SITUACAO_FUNCIONAL,
    b.ANO_MES_REFERENCIA,
    b.data_admissao,
    b.data_posse,
    b.data_efetivo_exerc,
    b.data_rescisao,
    b.cod_cargo_efetivo,
    E.DESCRICAO CARGO_EFETIVO,
    b.cod_cargo_comiss,
    C.DESCRICAO CARGO_COMISSIONADO,
    b.codigo_funcao,
    F.DESCRICAO FUNCAO,
    GN.cod_cgerenc1,
    GN.cod_cgerenc2,
    GN.cod_cgerenc3,
    GN.cod_cgerenc4,
    GN.cod_cgerenc5,
    GN.cod_cgerenc6,
    GN.DESCRICAO LOCAL
  FROM RHPESS_CONTRATO B
  LEFT OUTER JOIN RHPARM_SIT_FUNC SF
  ON SF.CODIGO = B.SITUACAO_FUNCIONAL
  LEFT OUTER JOIN RHPLCS_FUNCAO F
  ON F.CODIGO_EMPRESA = B.CODIGO_EMPRESA
  AND F.CODIGO        = b.codigo_funcao
  LEFT OUTER JOIN RHPLCS_CARGO C
  ON c.CODIGO_EMPRESA = B.CODIGO_EMPRESA
  AND c.CODIGO        = b.cod_cargo_comiss
  LEFT OUTER JOIN RHPLCS_CARGO E
  ON e.CODIGO_EMPRESA = B.CODIGO_EMPRESA
  AND e.CODIGO        = b.cod_cargo_efetivo
  LEFT OUTER JOIN RHORGA_CUSTO_GEREN GN
  ON B.CODIGO_EMPRESA     = GN.CODIGO_EMPRESA
  AND b.COD_CUSTO_GERENC1 = GN.cod_cgerenc1
  AND b.COD_CUSTO_GERENC2 = GN.cod_cgerenc2
  AND b.COD_CUSTO_GERENC3 = GN.cod_cgerenc3
  AND b.COD_CUSTO_GERENC4 = GN.cod_cgerenc4
  AND b.COD_CUSTO_GERENC5 = GN.cod_cgerenc5
  AND b.COD_CUSTO_GERENC6 = GN.cod_cgerenc6
  LEFT OUTER JOIN
    (SELECT E.*
    FROM RHPONT_ESCALA E
    WHERE E.CODIGO_EMPRESA = '0001'
    AND E.data_extincao   IS NULL
    AND EXISTS
      (SELECT EH.*
      FROM RHPONT_RL_ESC_HOR EH
      WHERE EH.CODIGO_EMPRESA = E.CODIGO_EMPRESA
      AND EH.CODIGO_ESCALA    = E.CODIGO
      )
    )EH
  ON EH.CODIGO_EMPRESA     = B.CODIGO_EMPRESA
  AND B.CODIGO_ESCALA      = EH.CODIGO
  WHERE EH.CODIGO         IS NOT NULL
  AND B.ANO_MES_REFERENCIA =
    (SELECT MAX(AUX.ANO_MES_REFERENCIA)
    FROM RHPESS_CONTRATO AUX
    WHERE B.CODIGO_EMPRESA = AUX.CODIGO_EMPRESA
    AND B.TIPO_CONTRATO    = AUX.TIPO_CONTRATO
    AND B.CODIGO           = AUX.CODIGO
    )
  AND ((B.data_rescisao IS NULL)
  OR ( B.data_rescisao  IS NOT NULL
  AND TRUNC(B.DATA_RESCISAO) BETWEEN vDATA_INICIO_PERIODO AND vDATA_FIM_PERIODO--TO_DATE('01/01/2020','DD/MM/YYYY') AND TO_DATE('31/01/2020','DD/MM/YYYY')------------------**************************alterar datas
    ))
  AND B.CODIGO_EMPRESA =LPAD(pEMPRESA,4,0)
  AND B.TIPO_CONTRATO  = LPAD(pTP_CONTR,4,0)
  AND B.CODIGO         =LPAD(pCONT,15,0)
--,'000000000751727','000000000883291','000000001152155','000000000362992','000000000951785', '000000001031560','000000000960784', '000000001154670')--('000000000774476','000000000746944','000000000365711','000000000766953','000000000844938','000000000499688','000000000351966')
    --and b.COD_CUSTO_GERENC1 = '000095'
    --and b.COD_CUSTO_GERENC2 = '000004'-- and b.COD_CUSTO_GERENC3 = '000023'
    --and b.COD_CUSTO_GERENC4 = '000000' and b.COD_CUSTO_GERENC5 = '000000' and b.COD_CUSTO_GERENC6 = '000000'
    --and B.CODIGO IN ('000000000878980','00000000087862X','00000000036815X','000000000293109','000000000296655')
    -- INICIO--ERRO DE NÃO TER CADASTRO DE ESCALA/HORARIO
    /*
    AND
    EXISTS
    (
    SELECT E.* FROM RHPONT_ESCALA E WHERE E.CODIGO_EMPRESA = '0001' AND E.data_extincao IS NULL
    AND
    EXISTS(
    SELECT EH.* FROM RHPONT_RL_ESC_HOR EH
    WHERE
    EH.CODIGO_EMPRESA = E.CODIGO_EMPRESA AND EH.CODIGO_ESCALA = E.CODIGO
    )
    AND E.CODIGO_EMPRESA = B.CODIGO_EMPRESA AND B.CODIGO_ESCALA = E.CODIGO
    )
    */
    -- FIM--ERRO DE NÃO TER CADASTRO DE ESCALA/HORARIO
  )
  LOOP
    vCONTADOR :=vCONTADOR+1;
    --dbms_output.put_line( '' );
    --dbms_output.put_line('--'||vCONTADOR||'-'|| C1.CODIGO_EMPRESA ||'-'|| C1.TIPO_CONTRATO ||'-'|| C1.codigo);
    --POPULAR VARIAVEIS
    data_inicial := to_date(vDATA_INICIO_PERIODO,'DD/MM/YYYY');
    data_final   := to_date(vDATA_FIM_PERIODO,'DD/MM/YYYY');
    --dbms_output.put_line( '--DATA INICIO ANALISE: ' || to_date(data_inicial,'DD/MM/YYYY'));
    --dbms_output.put_line( '--DATA FIM ANALISE: ' || to_date(data_final,'DD/MM/YYYY'));
    num_dias := (data_final - data_inicial)+1;
    --dbms_output.put_line( '--TOTAL DE DIAS: ' || num_dias);
    --INICIO------------------------------FOR PARA RODAR DIA A DIA PARA CADA BM-----------------------------------------------------------------------------------
    FOR i IN 1..num_dias
    LOOP
      vDATA_DIA := to_date(TO_CHAR((data_inicial-1)+i,'DD/MM/YYYY'),'DD/MM/YYYY');
      --DADOS DO DIA
      --SELECT D.NRO_DIA_SEMANA, D.DIA_SEMANA INTO vNRO_DIA_SEMANA , vDIA_SEMANA FROM RHTABS_DATAS D WHERE TRUNC(D.DATA_DIA) = TRUNC(vDATA_DIA);
      SELECT D.NRO_DIA_SEMANA,
        D.DIA_SEMANA ,
        CASE
          WHEN T.DESCRICAO IS NULL
          THEN 'DIA NORMAL'
          ELSE T.DESCRICAO
        END TIPO_DATA
      INTO vNRO_DIA_SEMANA,
        vDIA_SEMANA,
        vTIPO_DATA
      FROM RHTABS_DATAS D
      LEFT OUTER JOIN RHPARM_CALEND_DT C
      ON TRUNC(C.DATA_DIA)= TRUNC(D.DATA_DIA)
      AND c.codigo        = '0001'
      LEFT OUTER JOIN rhparm_p_calend T
      ON T.CTRL_PONTO       = C.CALEND
      AND T.CODIGO_P_CALEND = C.CODIGO
      WHERE --TRUNC(D.DATA_DIA) = TO_DATE('07/09/2020','DD/MM/YYYY')
        TRUNC(D.DATA_DIA) = TRUNC(vDATA_DIA);
      --dbms_output.put_line('---------------------------------------------------------------------------------------------------------');
      --dbms_output.put_line('--vDATA_DIA: '||vDATA_DIA||' vNRO_DIA_SEMANA: '|| vNRO_DIA_SEMANA || ' vDIA_SEMANA: '|| vDIA_SEMANA || ' vTIPO_DATA: ' ||vTIPO_DATA);
      --INICIO------------------------------FOR JUNTA ULTIMA SITUACAO DE PONTO DO DIA COM HISTORICO DE ALT ESCALA-----------------------------------------------------------------------------------
      FOR c2 IN
      (
      --SELECT PARA BUSCAR OS REGISTROS
      SELECT X2.*
      FROM
        (--INICIO X2
        SELECT LEAD(X.CODIGO, 1, NULL) OVER (PARTITION BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO ORDER BY X.TIPO)     AS PROXIMO_CODIGO,
          LEAD(X.DESCRICAO, 1, NULL) OVER (PARTITION BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO ORDER BY X.TIPO)       AS PROXIMO_DESCRICAO,
          LEAD(X.TIPO, 1, NULL) OVER (PARTITION BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO ORDER BY X.TIPO)            AS PROXIMO_TIPO,
          LEAD(X.TIPO_SITUACAO, 1, NULL) OVER (PARTITION BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO ORDER BY X.TIPO)   AS PROXIMO_TIPO_SITUACAO,
          LEAD(X.TIPO_REFERENCIA, 1, NULL) OVER (PARTITION BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO ORDER BY X.TIPO) AS PROXIMO_TIPO_REFERENCIA,
          ROW_NUMBER() OVER (PARTITION BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO ORDER BY X.DATA_INICIO)              AS ORDEM_BM,
          X.*
        FROM ----------------------inicio X
          (
          -------------------------------------------------------------------------------INICIO DO UNION------------------------------------------------------------------------------
          SELECT '1-ALT_ESCALA' TIPO,
            E.tipo_escala,
            A.CODIGO_EMPRESA,
            A.TIPO_CONTRATO,
            A.CODIGO_CONTRATO,
            A.COD_ESCALA CODIGO,
            E.DESCRICAO,
            A.DT_INICIO_TROCA DATA_INICIO,
            A.DT_FIM_TROCA DATA_FIM,
            A.LOGIN_USUARIO,
            A.DT_ULT_ALTER_USUA,
            NULL tipo_situacao,
            NULL TIPO_REFERENCIA
          FROM RHPONT_ALT_ESCALA A
          LEFT OUTER JOIN RHPONT_ESCALA E
          ON E.CODIGO_EMPRESA                               = A.CODIGO_EMPRESA
          AND E.CODIGO                                      = A.COD_ESCALA
          WHERE (( TO_DATE(A.DT_INICIO_TROCA,'DD/MM/YYYY') <= TO_DATE(vDATA_DIA,'DD/MM/YYYY')
          AND TO_DATE(A.DT_FIM_TROCA,'DD/MM/YYYY')         >=TO_DATE(vDATA_DIA,'DD/MM/YYYY'))
          OR (A.DT_INICIO_TROCA                             =
            (SELECT MAX(AUX.DT_INICIO_TROCA)
            FROM RHPONT_ALT_ESCALA AUX
            WHERE A.CODIGO_EMPRESA                         = AUX.CODIGO_EMPRESA
            AND A.TIPO_CONTRATO                            = AUX.TIPO_CONTRATO
            AND A.CODIGO_CONTRATO                          = AUX.CODIGO_CONTRATO
            AND TO_DATE(AUX.DT_INICIO_TROCA,'DD/MM/YYYY') <= TO_DATE(vDATA_DIA,'DD/MM/YYYY')
            AND AUX.DT_FIM_TROCA                          IS NULL
            )) )
          UNION ALL
          SELECT '3-SITUACAO_PONTO' TIPO,
            NULL tipo_escala,
            A.CODIGO_EMPRESA,
            A.TIPO_CONTRATO,
            A.CODIGO_CONTRATO,
            A.CODIGO_SITUACAO CODIGO,
            P.DESCRICAO,
            A.DATA DATA_INICIO,
            a.data DATA_FIM,
            A.LOGIN_USUARIO,
            A.DT_ULT_ALTER_USUA,
            P.tipo_situacao,
            P.TIPO_REFERENCIA
          FROM RHPONT_RES_SIT_DIA A
          LEFT OUTER JOIN RHPONT_SITUACAO P
          ON P.CODIGO             = A.CODIGO_SITUACAO
          WHERE TRUNC(A.DATA)     = TO_DATE(vDATA_DIA,'DD/MM/YYYY')
          AND A.TIPO_APURACAO = 'F'
          AND A.DT_ULT_ALTER_USUA =
          ( SELECT MAX(AUX.DT_ULT_ALTER_USUA)
            FROM RHPONT_RES_SIT_DIA AUX
            WHERE AUX.CODIGO_EMPRESA = A.CODIGO_EMPRESA
            AND AUX.TIPO_CONTRATO    = A.TIPO_CONTRATO
            AND AUX.CODIGO_CONTRATO  = A.CODIGO_CONTRATO
            AND TRUNC(AUX.DATA)      = TRUNC(a.DATA)
            AND AUX.CODIGO_SITUACAO NOT IN ('2000')
            -- LETICIA EM 16/02/2024 - INCLUIU OS NOT EXISTS PARA RETIRAR O ESTORNO E SUA SITUACAO QUE A ORIGINOU. EX: FALTA (0020) COM ESTORNO DE FALTA (1015) NO MESMO DIA.
            AND NOT EXISTS (SELECT AUX1.CODIGO_CONTRATO FROM RHPONT_RES_SIT_DIA AUX1
            WHERE AUX.CODIGO_CONTRATO = AUX1.CODIGO_CONTRATO
            AND AUX.TIPO_CONTRATO = AUX1.TIPO_CONTRATO
            AND AUX.CODIGO_EMPRESA = AUX1.CODIGO_EMPRESA
            AND TRUNC(AUX.DATA)      = TRUNC(AUX1.DATA)
            AND AUX1.CODIGO_SITUACAO IN (SELECT SITUACAO_ASSOC FROM RHPONT_SITUACAO WHERE CODIGO = AUX.CODIGO_SITUACAO)
            ) 

            AND NOT EXISTS (SELECT AUX1.CODIGO_CONTRATO FROM RHPONT_RES_SIT_DIA AUX1
            WHERE AUX.CODIGO_CONTRATO = AUX1.CODIGO_CONTRATO
            AND AUX.TIPO_CONTRATO = AUX1.TIPO_CONTRATO
            AND AUX.CODIGO_EMPRESA = AUX1.CODIGO_EMPRESA
            AND TRUNC(AUX.DATA)      = TRUNC(AUX1.DATA)
            AND AUX1.CODIGO_SITUACAO IN (SELECT CODIGO FROM RHPONT_SITUACAO WHERE SITUACAO_ASSOC = AUX.CODIGO_SITUACAO)
            ) 
            AND AUX.TIPO_APURACAO = 'F'
            )
          )X ----------------FIM X
          -------------------------------------------------------------------------------------------------FIM DO UNION------------------------------------------------------------------------------------------------------------------
        ORDER BY X.TIPO,
          x.codigo,
          X.CODIGO_EMPRESA,
          X.TIPO_CONTRATO,
          X.CODIGO_CONTRATO,
          X.DATA_INICIO,
          X.TIPO
        )X2
      WHERE X2.CODIGO_EMPRESA = C1.CODIGO_EMPRESA
      AND X2.TIPO_CONTRATO    = C1.TIPO_CONTRATO
      AND X2.CODIGO_CONTRATO  = C1.CODIGO
      )
      LOOP
        --CONTANDO DIAS NA ESCALA
        vQTD_DIAS_NA_ESCALA := vDATA_DIA - C2.DATA_INICIO+1;
        SELECT COUNT(1)QUANT
        INTO vQTD_DIAS_CICLO_ESCALA
        FROM RHPONT_RL_ESC_HOR
        WHERE CODIGO_EMPRESA     = C2.CODIGO_EMPRESA
        AND CODIGO_ESCALA        = C2.CODIGO
        AND C2.TIPO              = '1-ALT_ESCALA';
        IF vQTD_DIAS_CICLO_ESCALA=0 THEN
          vQTD_DIAS_CICLO_ESCALA:=1;
        END IF;
        IF C2.TIPO                                                                                                       = '1-ALT_ESCALA' AND vQTD_DIAS_NA_ESCALA >0 THEN
          vQTD_VEZES_CICLO_NA_ESCALA                                                                                    := TRUNC(vQTD_DIAS_NA_ESCALA/vQTD_DIAS_CICLO_ESCALA);
          IF vQTD_DIAS_NA_ESCALA                                 - (vQTD_VEZES_CICLO_NA_ESCALA * vQTD_DIAS_CICLO_ESCALA) = 0 THEN
            vDIA_DO_CICLO_ATUAL                                                                                         := vQTD_DIAS_CICLO_ESCALA;--erro?
          ELSE
            vDIA_DO_CICLO_ATUAL := vQTD_DIAS_NA_ESCALA - (vQTD_VEZES_CICLO_NA_ESCALA * vQTD_DIAS_CICLO_ESCALA);--erro?
          END IF;
        ELSIF C2.TIPO                                                                                                    = '1-ALT_ESCALA' AND vQTD_DIAS_NA_ESCALA =0 THEN
          vQTD_DIAS_NA_ESCALA                                                                                           :=1;
          vQTD_VEZES_CICLO_NA_ESCALA                                                                                    := TRUNC(vQTD_DIAS_NA_ESCALA/vQTD_DIAS_CICLO_ESCALA);
          IF vQTD_DIAS_NA_ESCALA                                 - (vQTD_VEZES_CICLO_NA_ESCALA * vQTD_DIAS_CICLO_ESCALA) = 0 THEN
            vDIA_DO_CICLO_ATUAL                                                                                         := vQTD_DIAS_CICLO_ESCALA;--erro?
          ELSE
            vDIA_DO_CICLO_ATUAL := vQTD_DIAS_NA_ESCALA - (vQTD_VEZES_CICLO_NA_ESCALA * vQTD_DIAS_CICLO_ESCALA);--erro?
          END IF;
          --dbms_output.put_line('vQTD_DIAS_CICLO_ESCALA: '||vQTD_DIAS_CICLO_ESCALA ||' vQTD_DIAS_NA_ESCALA: '|| vQTD_DIAS_NA_ESCALA||' vQTD_VEZES_CICLO_NA_ESCALA: '||vQTD_VEZES_CICLO_NA_ESCALA ||' vDIA_DO_CICLO_ATUAL: '|| vDIA_DO_CICLO_ATUAL );
        END IF;
        --dbms_output.put_line('TIPO: '|| C2.TIPO || ' TIPO_ESCALA: '|| C2.TIPO_ESCALA|| ' CODIGO: '|| C2.CODIGO || '-'||C2.DESCRICAO || ' DATA_INICIO: ' || C2.DATA_INICIO || ' DATA_FIM: ' || C2.DATA_FIM || ' DT_ULT_ALTER_USUA: '|| C2.DT_ULT_ALTER_USUA || ' LOGIN_USUARIO: '|| c2.LOGIN_USUARIO|| ' tipo_situacao: '|| c2.tipo_situacao);
        --INICIO----------------------------------------------------------------------------------- IF PARA O FOR C3 CRUZAR OS DADOS E AVALIAR FINAL----------------------------------
        IF C2.TIPO_ESCALA = '1' and trim(vTIPO_DATA)!='FERIADO'THEN
          --INICIO----------------------------------ESCALA SEMANAL
          FOR C3 IN
          (
          --TABELA ESCALA/HORARIO
          SELECT X.*
          FROM
            (SELECT
              CASE
                WHEN D.NRO_DIA_SEMANA = 2
                AND EH.OCORRENCIA    IN (1, 8,15,22,29,36,43,50,57,64,71)
                THEN 2
                WHEN D.NRO_DIA_SEMANA = 2
                AND EH.OCORRENCIA    IN (2, 9,16,23,30,37,44,51,58,65,72)
                THEN 3
                WHEN D.NRO_DIA_SEMANA = 2
                AND EH.OCORRENCIA    IN (3,10,17,24,31,38,45,52,59,66,73)
                THEN 4
                WHEN D.NRO_DIA_SEMANA = 2
                AND EH.OCORRENCIA    IN (4,11,18,25,32,39,46,53,60,67,74)
                THEN 5
                WHEN D.NRO_DIA_SEMANA = 2
                AND EH.OCORRENCIA    IN (5,12,19,26,33,40,47,54,61,68,75)
                THEN 6
                WHEN D.NRO_DIA_SEMANA = 2
                AND EH.OCORRENCIA    IN (6,13,20,27,34,41,48,55,62,69,76)
                THEN 7
                WHEN D.NRO_DIA_SEMANA = 2
                AND EH.OCORRENCIA    IN (7,14,21,28,35,42,49,56,63,70,77)
                THEN 1
                ELSE 0
              END NRO_DIA_SEMANA_TRATADO,
              EH.OCORRENCIA,
              EH.CODIGO_EMPRESA,
              E.TIPO_ESCALA,
              E.DATA_BASE,
              D.NRO_DIA_SEMANA,
              D.DIA_SEMANA,
              EH.CODIGO_ESCALA,
              E.DESCRICAO ESCALA,
              EH.CODIGO_HORARIO,
              H.DESCRICAO HORARIO,
              H.tipo_horario
            FROM RHPONT_RL_ESC_HOR EH
            LEFT OUTER JOIN RHPONT_ESCALA E
            ON E.CODIGO_EMPRESA = EH.CODIGO_EMPRESA
            AND E.CODIGO        = EH.CODIGO_ESCALA
            LEFT OUTER JOIN RHPONT_HORARIO H
            ON H.CODIGO_EMPRESA = EH.CODIGO_EMPRESA
            AND H.CODIGO        = EH.CODIGO_HORARIO
            LEFT OUTER JOIN RHTABS_DATAS D
            ON D.DATA_DIA = E.DATA_BASE
            )X
          WHERE X.CODIGO_EMPRESA       = C2.CODIGO_EMPRESA
          AND X.CODIGO_ESCALA          = C2.CODIGO
          AND C2.TIPO                  = '1-ALT_ESCALA'
          AND X.NRO_DIA_SEMANA_TRATADO = vNRO_DIA_SEMANA 

          )
          LOOP
            IF C3.TIPO_HORARIO    in ( 'N','T') THEN
              V_DIAS_TRABALHO_MES:=V_DIAS_TRABALHO_MES+1;
            END IF;
            IF pTP_ATT='MES_VALE' THEN
              UPDATE SMARH_INT_RECALCULO_VALE
              SET QTD_TRABLHO_MES_VALE               =V_DIAS_TRABALHO_MES
              WHERE CODIGO_CONTRATO                  =C1.CODIGO
              AND TIPO_CONTRATO                      =C1.TIPO_CONTRATO
              AND CODIGO_EMPRESA                     =C1.CODIGO_EMPRESA
              AND TO_DATE(DATA_INI_VALE,'DD/MM/YYYY')=TO_DATE(pDT_INICIO,'DD/MM/YYYY')
              AND TO_DATE(DATA_FIM_VALE,'DD/MM/YYYY')=TO_DATE(pDT_FIM,'DD/MM/YYYY');
              COMMIT;
              dbms_output.put_line('1---COD_SIT_PONTO: '|| C2.PROXIMO_CODIGO||'-'||'CODIGO_1'||C2.CODIGO|| ' SITUACAO_PONTO: '|| C2.PROXIMO_DESCRICAO||' DATA: ' || vDATA_DIA);
              IF C3.TIPO_HORARIO in ( 'N','T') AND C2.PROXIMO_TIPO = '3-SITUACAO_PONTO' AND C2.PROXIMO_CODIGO MEMBER COD_SIT_MES_VALE THEN
                INSERT
                INTO SMARH_INT_OCORRENCIA_FREQ
                  (
                    CODIGO_EMPRESA,
                    TIPO_CONTRATO,
                    CODIGO_CONTRATO,
                    DATA_OCORRENCIA,
                    CODIGO_SITUCAO_PONTO,
                    ORIGEM
                  )
                  VALUES
                  (
                    C1.CODIGO_EMPRESA,
                    C1.TIPO_CONTRATO,
                    C1.CODIGO,
                    vDATA_DIA,
                    C2.PROXIMO_CODIGO,
                    pTP_ATT
                  );
                COMMIT;
              END IF;
            ELSE
              UPDATE SMARH_INT_RECALCULO_VALE
              SET QTD_TRABLHO_MES_FREQUENCIA               =V_DIAS_TRABALHO_MES
              WHERE CODIGO_CONTRATO                        =C1.CODIGO
              AND TIPO_CONTRATO                            =C1.TIPO_CONTRATO
              AND CODIGO_EMPRESA                           =C1.CODIGO_EMPRESA
              AND TO_DATE(DATA_INI_FREQUENCIA,'DD/MM/YYYY')=TO_DATE(pDT_INICIO,'DD/MM/YYYY')
              AND TO_DATE(DATA_FIM_FREQUENCIA,'DD/MM/YYYY')=TO_DATE(pDT_FIM,'DD/MM/YYYY');
              COMMIT;
              --- dbms_output.put_line('2---COD_SIT_PONTO: '|| C2.PROXIMO_CODIGO||'-'||'CODIGO_1'||C2.CODIGO|| ' SITUACAO_PONTO: '|| C2.PROXIMO_DESCRICAO||' DATA: ' || vDATA_DIA);
              IF C3.TIPO_HORARIO in ( 'N','T') AND C2.PROXIMO_TIPO = '3-SITUACAO_PONTO' AND C2.PROXIMO_CODIGO MEMBER COD_SIT_MES_FREQUE THEN
                INSERT
                INTO SMARH_INT_OCORRENCIA_FREQ
                  (
                    CODIGO_EMPRESA,
                    TIPO_CONTRATO,
                    CODIGO_CONTRATO,
                    DATA_OCORRENCIA,
                    CODIGO_SITUCAO_PONTO,
                    ORIGEM
                  )
                  VALUES
                  (
                    C1.CODIGO_EMPRESA,
                    C1.TIPO_CONTRATO,
                    C1.CODIGO,
                    vDATA_DIA,
                    C2.PROXIMO_CODIGO,
                    pTP_ATT
                  );
                COMMIT;
              END IF;
            END IF;
            ---dbms_output.put_line('DIAS TRABALHO MES' ||V_DIAS_TRABALHO_MES);
            --dbms_output.put_line('NRO_DIA_SEMANA_TRATADO: '||C3. NRO_DIA_SEMANA_TRATADO|| ' OCORRENCIA: '|| C3.OCORRENCIA || ' DATA_BASE: ' || C3.DATA_BASE|| ' NRO_DIA_SEMANA: '|| C3.NRO_DIA_SEMANA || ' DIA_SEMANA: '|| C3.DIA_SEMANA || ' CODIGO_HORARIO: ' || C3.CODIGO_HORARIO || ' HORARIO: ' || C3.HORARIO|| ' TIPO_HORARIO: ' ||C3.TIPO_HORARIO);
            --dbms_output.put_line('COD_SIT_PONTO: '|| C2.PROXIMO_CODIGO|| ' SITUACAO_PONTO: '|| C2.PROXIMO_DESCRICAO||' DATA: ' || vDATA_DIA);
            --IF C3.TIPO_HORARIO = 'N' AND C2.PROXIMO_TIPO = '3-SITUACAO_PONTO'  AND /*AND C2.PROXIMO_TIPO_SITUACAO IN ('I','F') AND C2.PROXIMO_TIPO_REFERENCIA = 'D'*/ THEN
            --dbms_output.put_line('--'||vCONTADOR||'-'|| C1.CODIGO_EMPRESA ||'-'|| C1.TIPO_CONTRATO ||'-'|| C1.codigo);
            --dbms_output.put_line('ENTRA NO ABSENTEISMO - ESCALA SEMANAL');
            ---dbms_output.put_line('TIPO: '|| C2.TIPO || ' TIPO_ESCALA: '|| C2.TIPO_ESCALA|| ' CODIGO: '|| C2.CODIGO || '-'||C2.DESCRICAO || ' DATA_INICIO: ' || C2.DATA_INICIO || ' DATA_FIM: ' || C2.DATA_FIM || ' DT_ULT_ALTER_USUA: '|| C2.DT_ULT_ALTER_USUA || ' LOGIN_USUARIO: '|| c2.LOGIN_USUARIO|| ' tipo_situacao: '|| c2.tipo_situacao);
            --dbms_output.put_line('--'||vCONTADOR||'-'|| C1.CODIGO_EMPRESA ||'-'|| C1.TIPO_CONTRATO ||'-'|| C1.codigo);
            --dbms_output.put_line('COD_SIT_PONTO: '|| C2.PROXIMO_CODIGO|| ' SITUACAO_PONTO: '|| C2.PROXIMO_DESCRICAO||' DATA: ' || vDATA_DIA);
            --INSERT INTO SUGESP_GETED_ABSENTEISMO (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO)VALUES (C1.CODIGO_EMPRESA, C1.TIPO_CONTRATO, C1.CODIGO, vDATA_DIA, C2.PROXIMO_CODIGO); COMMIT;
            --dbms_output.put_line( 'DADOS DESCONTO-2'||C1.CODIGO_EMPRESA||C1.TIPO_CONTRATO||C1.CODIGO||vDATA_DIA ||C2.PROXIMO_CODIGO);
            --END IF;
          END LOOP;
          --FIM----------------------------------ESCALA SEMANAL
        ELSIF C2.TIPO_ESCALA = '2' THEN
          --INICIO----------------------------------ESCALA CICLICA
          FOR C3 IN
          (
            --TABELA ESCALA/HORARIO
            SELECT X.*
            FROM
              (SELECT
                CASE
                  WHEN D.NRO_DIA_SEMANA = 2
                  AND EH.OCORRENCIA    IN (1, 8,15,22,29,36,43,50,57,64,71)
                  THEN 2
                  WHEN D.NRO_DIA_SEMANA = 2
                  AND EH.OCORRENCIA    IN (2, 9,16,23,30,37,44,51,58,65,72)
                  THEN 3
                  WHEN D.NRO_DIA_SEMANA = 2
                  AND EH.OCORRENCIA    IN (3,10,17,24,31,38,45,52,59,66,73)
                  THEN 4
                  WHEN D.NRO_DIA_SEMANA = 2
                  AND EH.OCORRENCIA    IN (4,11,18,25,32,39,46,53,60,67,74)
                  THEN 5
                  WHEN D.NRO_DIA_SEMANA = 2
                  AND EH.OCORRENCIA    IN (5,12,19,26,33,40,47,54,61,68,75)
                  THEN 6
                  WHEN D.NRO_DIA_SEMANA = 2
                  AND EH.OCORRENCIA    IN (6,13,20,27,34,41,48,55,62,69,76)
                  THEN 7
                  WHEN D.NRO_DIA_SEMANA = 2
                  AND EH.OCORRENCIA    IN (7,14,21,28,35,42,49,56,63,70,77)
                  THEN 1
                  ELSE 0
                END NRO_DIA_SEMANA_TRATADO,
                EH.OCORRENCIA,
                EH.CODIGO_EMPRESA,
                E.TIPO_ESCALA,
                E.DATA_BASE,
                D.NRO_DIA_SEMANA,
                D.DIA_SEMANA,
                EH.CODIGO_ESCALA,
                E.DESCRICAO ESCALA,
                EH.CODIGO_HORARIO,
                H.DESCRICAO HORARIO,
                H.tipo_horario
              FROM RHPONT_RL_ESC_HOR EH
              LEFT OUTER JOIN RHPONT_ESCALA E
              ON E.CODIGO_EMPRESA = EH.CODIGO_EMPRESA
              AND E.CODIGO        = EH.CODIGO_ESCALA
              LEFT OUTER JOIN RHPONT_HORARIO H
              ON H.CODIGO_EMPRESA = EH.CODIGO_EMPRESA
              AND H.CODIGO        = EH.CODIGO_HORARIO
              LEFT OUTER JOIN RHTABS_DATAS D
              ON D.DATA_DIA = E.DATA_BASE
              )X
            WHERE X.CODIGO_EMPRESA = C2.CODIGO_EMPRESA
            AND X.CODIGO_ESCALA    = C2.CODIGO
            AND C2.TIPO            = '1-ALT_ESCALA'
              --AND X.NRO_DIA_SEMANA_TRATADO = vNRO_DIA_SEMANA --escala SEMANAL
            AND X.OCORRENCIA = vDIA_DO_CICLO_ATUAL--escala CICLICA
          )
          LOOP
            --dbms_output.put_line('NRO_DIA_SEMANA_TRATADO: '||C3. NRO_DIA_SEMANA_TRATADO|| ' OCORRENCIA: '|| C3.OCORRENCIA || ' DATA_BASE: ' || C3.DATA_BASE|| ' NRO_DIA_SEMANA: '|| C3.NRO_DIA_SEMANA || ' DIA_SEMANA: '|| C3.DIA_SEMANA || ' CODIGO_HORARIO: ' || C3.CODIGO_HORARIO || ' HORARIO: ' || C3.HORARIO|| ' TIPO_HORARIO: ' ||C3.TIPO_HORARIO);
            IF C3.TIPO_HORARIO    in ( 'N','T') THEN
              V_DIAS_TRABALHO_MES:=V_DIAS_TRABALHO_MES+1;
            END IF;
            IF pTP_ATT='MES_VALE' THEN
              UPDATE SMARH_INT_RECALCULO_VALE
              SET QTD_TRABLHO_MES_VALE               =V_DIAS_TRABALHO_MES
              WHERE CODIGO_CONTRATO                  =C1.CODIGO
              AND TIPO_CONTRATO                      =C1.TIPO_CONTRATO
              AND CODIGO_EMPRESA                     =C1.CODIGO_EMPRESA
              AND TO_DATE(DATA_INI_VALE,'DD/MM/YYYY')=TO_DATE(pDT_INICIO,'DD/MM/YYYY')
              AND TO_DATE(DATA_FIM_VALE,'DD/MM/YYYY')=TO_DATE(pDT_FIM,'DD/MM/YYYY');
              COMMIT;
              --  dbms_output.put_line('3--COD_SIT_PONTO: '|| C2.PROXIMO_CODIGO||'-'||'CODIGO_1'||C2.CODIGO|| ' SITUACAO_PONTO: '|| C2.PROXIMO_DESCRICAO||' DATA: ' || vDATA_DIA);
              IF C3.TIPO_HORARIO in ( 'N','T') AND C2.PROXIMO_TIPO = '3-SITUACAO_PONTO' AND C2.PROXIMO_CODIGO MEMBER COD_SIT_MES_VALE THEN
                INSERT
                INTO SMARH_INT_OCORRENCIA_FREQ
                  (
                    CODIGO_EMPRESA,
                    TIPO_CONTRATO,
                    CODIGO_CONTRATO,
                    DATA_OCORRENCIA,
                    CODIGO_SITUCAO_PONTO,
                    ORIGEM
                  )
                  VALUES
                  (
                    C1.CODIGO_EMPRESA,
                    C1.TIPO_CONTRATO,
                    C1.CODIGO,
                    vDATA_DIA,
                    C2.PROXIMO_CODIGO,
                    pTP_ATT
                  );
                COMMIT;
              END IF;
            ELSE
              UPDATE SMARH_INT_RECALCULO_VALE
              SET QTD_TRABLHO_MES_FREQUENCIA               =V_DIAS_TRABALHO_MES
              WHERE CODIGO_CONTRATO                        =C1.CODIGO
              AND TIPO_CONTRATO                            =C1.TIPO_CONTRATO
              AND CODIGO_EMPRESA                           =C1.CODIGO_EMPRESA
              AND TO_DATE(DATA_INI_FREQUENCIA,'DD/MM/YYYY')=TO_DATE(pDT_INICIO,'DD/MM/YYYY')
              AND TO_DATE(DATA_FIM_FREQUENCIA,'DD/MM/YYYY')=TO_DATE(pDT_FIM,'DD/MM/YYYY');
              COMMIT;
              dbms_output.put_line('4---COD_SIT_PONTO: '|| C2.PROXIMO_CODIGO||'-'||'CODIGO_1'||C2.CODIGO|| ' SITUACAO_PONTO: '|| C2.PROXIMO_DESCRICAO||' DATA: ' || vDATA_DIA);
              IF C3.TIPO_HORARIO in ( 'N','T') AND C2.PROXIMO_TIPO = '3-SITUACAO_PONTO' AND C2.PROXIMO_CODIGO MEMBER COD_SIT_MES_FREQUE THEN
                INSERT
                INTO SMARH_INT_OCORRENCIA_FREQ
                  (
                    CODIGO_EMPRESA,
                    TIPO_CONTRATO,
                    CODIGO_CONTRATO,
                    DATA_OCORRENCIA,
                    CODIGO_SITUCAO_PONTO,
                    ORIGEM
                  )
                  VALUES
                  (
                    C1.CODIGO_EMPRESA,
                    C1.TIPO_CONTRATO,
                    C1.CODIGO,
                    vDATA_DIA,
                    C2.PROXIMO_CODIGO,
                    pTP_ATT
                  );
                COMMIT;
              END IF;
            END IF;
            /*IF C3.TIPO_HORARIO = 'N' THEN
            V_DIAS_TRABALHO_MES:=V_DIAS_TRABALHO_MES+1;
            END IF;
            IF pTP_ATT='MES_VALE' THEN
            UPDATE SMARH_INT_RECALCULO_VALE SET QTD_TRABLHO_MES_VALE=V_DIAS_TRABALHO_MES WHERE CODIGO_CONTRATO=C1.CODIGO AND TIPO_CONTRATO=C1.TIPO_CONTRATO AND CODIGO_EMPRESA=C1.CODIGO_EMPRESA AND TO_DATE(DATA_INI_VALE,'DD/MM/YYYY')=TO_DATE(pDT_INICIO,'DD/MM/YYYY') AND TO_DATE(DATA_FIM_VALE,'DD/MM/YYYY')=TO_DATE(pDT_FIM,'DD/MM/YYYY'); COMMIT;
            ELSE
            UPDATE SMARH_INT_RECALCULO_VALE SET QTD_TRABLHO_MES_FREQUENCIA=V_DIAS_TRABALHO_MES WHERE CODIGO_CONTRATO=C1.CODIGO AND TIPO_CONTRATO=C1.TIPO_CONTRATO AND CODIGO_EMPRESA=C1.CODIGO_EMPRESA AND TO_DATE(DATA_INI_FREQUENCIA,'DD/MM/YYYY')=TO_DATE(pDT_INICIO,'DD/MM/YYYY') AND TO_DATE(DATA_FIM_FREQUENCIA,'DD/MM/YYYY')=TO_DATE(pDT_FIM,'DD/MM/YYYY'); COMMIT;
            END IF;
            IF C3.TIPO_HORARIO = 'N' AND C2.PROXIMO_TIPO = '3-SITUACAO_PONTO' /*AND C2.PROXIMO_TIPO_SITUACAO IN ('I','F') AND C2.PROXIMO_TIPO_REFERENCIA = 'D' THEN
            --dbms_output.put_line('--'||vCONTADOR||'-'|| C1.CODIGO_EMPRESA ||'-'|| C1.TIPO_CONTRATO ||'-'|| C1.codigo);
            --dbms_output.put_line('ENTRA NO ABSENTEISMO - ESCALA CICLICA');
            dbms_output.put_line('--'||vCONTADOR||'-'|| C1.CODIGO_EMPRESA ||'-'|| C1.TIPO_CONTRATO ||'-'|| C1.codigo);
            --dbms_output.put_line('COD_SIT_PONTO: '|| C2.PROXIMO_CODIGO|| ' SITUACAO_PONTO: '|| C2.PROXIMO_DESCRICAO||' DATA: ' || vDATA_DIA);
            --INSERT INTO SUGESP_GETED_ABSENTEISMO (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO)VALUES
            dbms_output.put_line( 'DADOS DESCONTO-1'||C1.CODIGO_EMPRESA||C1.TIPO_CONTRATO||C1.CODIGO||vDATA_DIA ||C2.PROXIMO_CODIGO); --COMMIT;
            INSERT INTO SMARH_INT_OCORRENCIA_FREQ (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA_OCORRENCIA, CODIGO_SITUCAO_PONTO)VALUES (C1.CODIGO_EMPRESA, C1.TIPO_CONTRATO, C1.CODIGO, vDATA_DIA, C2.PROXIMO_CODIGO); COMMIT;
            END IF;
            */
          END LOOP;
          --FIM----------------------------------ESCALA CICLICA
          --ELSE
          --dbms_output.put_line('--ERRO NO CADASTRO DA ESCALA CAMPO TIPO DE ESCALA');
        END IF;--C3
        --FIM----------------------------------------------------------------------------------- IF PARA O FOR C3----------------------------------
      END LOOP;
    END LOOP;
    --FIM------------------------------FOR JUNTA ULTIMA SITUACAO DE PONTO DO DIA COM HISTORICO DE ALT ESCALA-----------------------------------------------------------------------------------
    --FIM------------------------------FOR PARA RODAR DIA A DIA PARA CADA BM-----------------------------------------------------------------------------------
  END LOOP;
  --FIM----------------------------------------------1º FOR PARA PEGAR O  PUBLICO E PERIODO DESEJADO
END;