
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."SMARH_INT_CAD_BIO_IFPONTO" (DATA_INICIO IN VARCHAR2,DATA_FIM    IN VARCHAR2) AS
BEGIN
DECLARE
vCONTADOR NUMBER;
vDATA_INICIO Varchar2(10);
vDATA_FIM Varchar2(10);
BEGIN
dbms_output.enable(null);
vCONTADOR :=0;
vDATA_INICIO := DATA_INICIO;
vDATA_FIM := DATA_FIM;
FOR C1 IN (
SELECT X2.CODIGO_EMPRESA,X2.TIPO_CONTRATO,X2.CODIGO_CONTRATO,X2.CPF,X2.NOME,X2.PIS,X2.CRACHA,X2.TEMPL_TIT1,
  X2.TEMPL_TIT2,
  X2.TEMPL_TIT3,
  X2.TEMPL_TIT4,
  X2.TEMPL_TIT5,
  X2.TEMPL_ALT1,
  X2.TEMPL_ALT2,
  X2.TEMPL_ALT3,
  X2.TEMPL_ALT4,
  X2.TEMPL_ALT5 FROM (SELECT LPAD(P.CODIEMPR,4,0)   AS CODIGO_EMPRESA ,
  LPAD(P.TIPOCONT,4,0)        AS TIPO_CONTRATO,
  LPAD(P.INTEGRACODIMATR,15,0) AS CODIGO_CONTRATO,
  P.NUMECPF         AS CPF,
  P.APELCOLA        AS NOME,
  P.NUMEPIS         AS PIS,
  A.ICARD           AS CRACHA,
  A.TEMPL_TIT1,
  A.TEMPL_TIT2,
  A.TEMPL_TIT3,
  A.TEMPL_TIT4,
  A.TEMPL_TIT5,
  A.TEMPL_ALT1,
  A.TEMPL_ALT2,
  A.TEMPL_ALT3,
  A.TEMPL_ALT4,
  A.TEMPL_ALT5,
  SYSDATE AS DT_SAIU_ARTE,
  NULL AS DT_ENVIADO_IFPONTO_SURICATO
FROM TELESSVR.contdig_tsi1@LK_PROD_SUR.PBH A
LEFT OUTER JOIN SURICATO.TBCOLAB@LK_PROD_SUR.PBH P
ON lpad(P.CODIEMPR
  ||P.codimatr,12,0)= A.ICARD
  LEFT OUTER JOIN SURICATO.TBBIOMEAUTOM@LK_PROD_SUR.PBH B
  ON B.IDCOLAB = P.IDCOLAB
  WHERE TRUNC(B.INCLUSAO) BETWEEN  vDATA_INICIO AND vDATA_FIM
)X2
GROUP BY X2.CODIGO_EMPRESA,X2.TIPO_CONTRATO,X2.CODIGO_CONTRATO,X2.CPF,X2.NOME,X2.PIS,X2.CRACHA,X2.TEMPL_TIT1,
  X2.TEMPL_TIT2,
  X2.TEMPL_TIT3,
  X2.TEMPL_TIT4,
  X2.TEMPL_TIT5,
  X2.TEMPL_ALT1,
  X2.TEMPL_ALT2,
  X2.TEMPL_ALT3,
  X2.TEMPL_ALT4,
  X2.TEMPL_ALT5
)LOOP
vCONTADOR:=vCONTADOR+1;
INSERT INTO PONTO_ELETRONICO.BIOMETRIA_SURICATO
(CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO_CONTRATO,
CPF,
NOME,
PIS,
CRACHA,
TEMPL_TIT1,
TEMPL_TIT2,
TEMPL_TIT3,
TEMPL_TIT4,
TEMPL_TIT5,
TEMPL_ALT1,
TEMPL_ALT2,
TEMPL_ALT3,
TEMPL_ALT4,
TEMPL_ALT5,
DT_SAIU_ARTE,
DT_ENVIADO_IFPONTO_SURICATO
)
VALUES
(C1.CODIGO_EMPRESA,
C1.TIPO_CONTRATO,
C1.CODIGO_CONTRATO,
C1.CPF,
C1.NOME,
C1.PIS,
C1.CRACHA,
C1.TEMPL_TIT1,
C1.TEMPL_TIT2,
C1.TEMPL_TIT3,
C1.TEMPL_TIT4,
C1.TEMPL_TIT5,
C1.TEMPL_ALT1,
C1.TEMPL_ALT2,
C1.TEMPL_ALT3,
C1.TEMPL_ALT4,
C1.TEMPL_ALT5,
SYSDATE,
NULL);
COMMIT;
END LOOP;
END;
END;