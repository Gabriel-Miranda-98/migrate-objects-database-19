
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."FU_VALIDA_DIA_TRABALHADO" (
    tp_cont   CHAR,
    vempresa  CHAR,
    vcontrato VARCHAR2,
    DIA       DATE)
  RETURN NUMBER
AS
  QTD_DIAS          NUMBER;
  qtd_dias_ciclo    NUMBER;
  FERIADOS          NUMBER;
  PONTO_FACULTATIVO NUMBER;
  V_MOD             NUMBER;
  V_SITUACAO        VARCHAR2(20 BYTE);
  V_GERA_TRAB       VARCHAR2(20 BYTE);
  v_OCORRENCIA      NUMBER;
  V_HORARIO         CHAR (4 BYTE);
BEGIN
  QTD_DIAS:=0;
  FOR C1 IN
  (SELECT AE.CODIGO_EMPRESA,
    AE.CODIGO_CONTRATO,
    AE.DT_INICIO_TROCA,
    AE.DT_FIM_TROCA,
    COD_ESCALA AS CODIGO_ESCALA,
    EL.DATA_BASE
  FROM ARTERH.RHPONT_ALT_ESCALA AE
  LEFT OUTER JOIN ARTERH.RHPONT_ESCALA EL
  ON EL.CODIGO             =AE.COD_ESCALA
  AND EL.CODIGO_EMPRESA    =AE.CODIGO_EMPRESA
  WHERE AE.CODIGO_CONTRATO =vcontrato
  AND ae.tipo_contrato     =tp_cont
  AND ae.codigo_empresa    =vempresa
  AND ((AE.DT_FIM_TROCA   IS NULL)
  OR (AE.DT_FIM_TROCA     >=DIA))
  )
  LOOP
    ----RHPONT_ESCALA
    --turno_fer_g_trab = 'S' GERAR TRABALHO 'N' NÃO HÁ CARGA DE TRABALHO
    
    SELECT COUNT(1)QUANT
    INTO qtd_dias_ciclo
    FROM ARTERH.RHPONT_RL_ESC_HOR AUX
    WHERE AUX.CODIGO_EMPRESA=c1.codigo_empresa
    AND aux.codigo_escala   =c1.codigo_escala;
    V_MOD                  :=MOD(DIA-C1.DATA_BASE,qtd_dias_ciclo)+1;
   
   BEGIN
    SELECT X.OCORRENCIA,
      X.HORARIO,
      X.SITUACAO,
      X.VALID_CARGA_FERI_FACUL
    INTO v_OCORRENCIA,
      V_HORARIO,
      V_SITUACAO,
      V_GERA_TRAB
    FROM
      (SELECT E.DATA_BASE,
        EH.CODIGO_ESCALA,
        EH.OCORRENCIA,
        H.CODIGO AS HORARIO,
        E.turno_fer_g_trab,
        CASE
          WHEN E.turno_fer_g_trab = 'N'
          THEN 'N_GERAR_CARGA'
          ELSE 'GERAR_CARGA'
        END AS VALID_CARGA_FERI_FACUL,
        CASE
          WHEN H.TIPO_HORARIO IN ('T','N')
          THEN'TRABALHO'
          ELSE 'FOLGA'
        END AS SITUACAO
      FROM ARTERH.RHPONT_RL_ESC_HOR EH
      LEFT OUTER JOIN ARTERH.RHPONT_HORARIO H
      ON H.CODIGO_EMPRESA=EH.CODIGO_EMPRESA
      AND H.CODIGO       =EH.CODIGO_HORARIO
      LEFT OUTER JOIN ARTERH.RHPONT_ESCALA E
      ON E.CODIGO            =EH.CODIGO_ESCALA
      AND E.CODIGO_EMPRESA   =EH.CODIGO_EMPRESA
      WHERE EH.CODIGO_EMPRESA=C1.CODIGO_EMPRESA
      AND e.codIGO           =C1.CODIGO_ESCALA
      )X
    WHERE X.OCORRENCIA=V_MOD;
  EXCEPTION
 WHEN NO_DATA_FOUND THEN
  QTD_DIAS:=99;
 END;
 
    IF V_SITUACAO     ='TRABALHO' THEN
      SELECT COUNT(1)QUANT
      INTO FERIADOS
      FROM
        (SELECT D.NRO_DIA_SEMANA,
          D.DIA_SEMANA ,
          CASE
            WHEN T.DESCRICAO IS NULL
            THEN 'DIA NORMAL'
            ELSE T.DESCRICAO
          END TIPO_DATA
          /*INTO vNRO_DIA_SEMANA,
          vDIA_SEMANA,
          vTIPO_DATA*/
        FROM ARTERH.RHTABS_DATAS D
        LEFT OUTER JOIN ARTERH.RHPARM_CALEND_DT C
        ON TRUNC(C.DATA_DIA)= TRUNC(D.DATA_DIA)
        AND c.codigo       IN ('0001')
        LEFT OUTER JOIN ARTERH.rhparm_p_calend T
        ON T.CTRL_PONTO         = C.CALEND
        AND T.CODIGO_P_CALEND   = C.CODIGO
        WHERE TRUNC(D.DATA_DIA) = TRUNC(DIA)
        )X
      WHERE TRIM(TIPO_DATA) IN('FERIADO');
     
      
      SELECT COUNT(1)QUANT
      INTO PONTO_FACULTATIVO
      FROM
        (SELECT D.NRO_DIA_SEMANA,
          D.DIA_SEMANA ,
          CASE
            WHEN T.DESCRICAO IS NULL
            THEN 'DIA NORMAL'
            ELSE T.DESCRICAO
          END TIPO_DATA
          /*INTO vNRO_DIA_SEMANA,
          vDIA_SEMANA,
          vTIPO_DATA*/
        FROM ARTERH.RHTABS_DATAS D
        LEFT OUTER JOIN ARTERH.RHPARM_CALEND_DT C
        ON TRUNC(C.DATA_DIA)= TRUNC(D.DATA_DIA)
        AND c.codigo       IN ('0004')
        LEFT OUTER JOIN ARTERH.rhparm_p_calend T
        ON T.CODIGO_P_CALEND  = C.CODIGO
        WHERE C.calend       IN('O')
        AND TRUNC(D.DATA_DIA) = TRUNC(DIA)
        )X ;
        
      IF (FERIADOS > 0) THEN
        QTD_DIAS  :=0;
      ELSE
       IF (PONTO_FACULTATIVO > 0)THEN
          QTD_DIAS  :=0;
       ELSE
          QTD_DIAS :=1;
        END IF; 
      END IF;
    ELSE
      QTD_DIAS :=1;
    END IF;
  END LOOP;
RETURN QTD_DIAS;
END;