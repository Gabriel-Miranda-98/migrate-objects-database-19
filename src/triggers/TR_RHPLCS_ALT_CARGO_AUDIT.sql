
  CREATE OR REPLACE EDITIONABLE TRIGGER "ARTERH"."TR_RHPLCS_ALT_CARGO_AUDIT" 
AFTER UPDATE OR DELETE OR INSERT ON "ARTERH"."RHPLCS_ALT_CARGO" 
FOR EACH ROW
 DECLARE
v_DML RHPBH_RHPLCS_ALT_CARGO_AUDIT.TIPO_DML%TYPE;
BEGIN
IF DELETING THEN
v_DML := 'D';
INSERT INTO RHPBH_RHPLCS_ALT_CARGO_AUDIT
(
TIPO_DML,
CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO_CONTRATO,
DT_ALTER_CARGO,
MOTIVO_ALTERACAO,
COD_CARGO_EFET_AT,
NIV_CARGO_EFET_AT,
COD_CARGO_COMIS_AT,
NIV_CARGO_COMIS_AT,
COD_CARGO_AMPAR_AT,
NIV_CARGO_AMPAR_AT,
OBSERVACAO,
LOGIN_USUARIO,
DT_ULT_ALTER_USUA,
DT_FIM_TEMP,
DOCUMENTO_PUBLIC,
ASSINATURA_01,
ASSINATURA_02,
ASSINATURA_03,
C_LIVRE_SELEC01,
C_LIVRE_SELEC02,
C_LIVRE_SELEC03,
C_LIVRE_VALOR01,
C_LIVRE_VALOR02,
C_LIVRE_VALOR03,
C_LIVRE_DESCR01,
C_LIVRE_DESCR02,
C_LIVRE_DESCR03,
C_LIVRE_DATA01,
C_LIVRE_DATA02,
C_LIVRE_DATA03,
C_LIVRE_OPCAO01,
C_LIVRE_OPCAO02,
C_LIVRE_OPCAO03,
OCORRENCIA,
SALARIO_PAGTO,
ID_LEI,
COD_CARGO_AVALIACAO,
DATA_PUBLIC
)
VALUES
(
v_DML,
:OLD.CODIGO_EMPRESA,
:OLD.TIPO_CONTRATO,
:OLD.CODIGO_CONTRATO,
:OLD.DT_ALTER_CARGO,
:OLD.MOTIVO_ALTERACAO,
:OLD.COD_CARGO_EFET_AT,
:OLD.NIV_CARGO_EFET_AT,
:OLD.COD_CARGO_COMIS_AT,
:OLD.NIV_CARGO_COMIS_AT,
:OLD.COD_CARGO_AMPAR_AT,
:OLD.NIV_CARGO_AMPAR_AT,
:OLD.OBSERVACAO,
USER,
SYSDATE,
:OLD.DT_FIM_TEMP,
:OLD.DOCUMENTO_PUBLIC,
:OLD.ASSINATURA_01,
:OLD.ASSINATURA_02,
:OLD.ASSINATURA_03,
:OLD.C_LIVRE_SELEC01,
:OLD.C_LIVRE_SELEC02,
:OLD.C_LIVRE_SELEC03,
:OLD.C_LIVRE_VALOR01,
:OLD.C_LIVRE_VALOR02,
:OLD.C_LIVRE_VALOR03,
:OLD.C_LIVRE_DESCR01,
:OLD.C_LIVRE_DESCR02,
:OLD.C_LIVRE_DESCR03,
:OLD.C_LIVRE_DATA01,
:OLD.C_LIVRE_DATA02,
:OLD.C_LIVRE_DATA03,
:OLD.C_LIVRE_OPCAO01,
:OLD.C_LIVRE_OPCAO02,
:OLD.C_LIVRE_OPCAO03,
:OLD.OCORRENCIA,
:OLD.SALARIO_PAGTO,
:OLD.ID_LEI,
:OLD.COD_CARGO_AVALIACAO,
:OLD.DATA_PUBLIC
);
GRAVA_MODULO_APOSENT(:OLD.CODIGO_CONTRATO,'RHPLCS_ALT_CARGO',:OLD.TIPO_CONTRATO, :OLD.CODIGO_EMPRESA,null,null, null,null, null, null , null, null , null, null, null,:OLD.DT_ALTER_CARGO );


END IF;

IF UPDATING THEN
v_DML := 'U';
INSERT INTO RHPBH_RHPLCS_ALT_CARGO_AUDIT
(
TIPO_DML,
CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO_CONTRATO,
DT_ALTER_CARGO,
MOTIVO_ALTERACAO,
COD_CARGO_EFET_AT,
NIV_CARGO_EFET_AT,
COD_CARGO_COMIS_AT,
NIV_CARGO_COMIS_AT,
COD_CARGO_AMPAR_AT,
NIV_CARGO_AMPAR_AT,
OBSERVACAO,
LOGIN_USUARIO,
DT_ULT_ALTER_USUA,
DT_FIM_TEMP,
DOCUMENTO_PUBLIC,
ASSINATURA_01,
ASSINATURA_02,
ASSINATURA_03,
C_LIVRE_SELEC01,
C_LIVRE_SELEC02,
C_LIVRE_SELEC03,
C_LIVRE_VALOR01,
C_LIVRE_VALOR02,
C_LIVRE_VALOR03,
C_LIVRE_DESCR01,
C_LIVRE_DESCR02,
C_LIVRE_DESCR03,
C_LIVRE_DATA01,
C_LIVRE_DATA02,
C_LIVRE_DATA03,
C_LIVRE_OPCAO01,
C_LIVRE_OPCAO02,
C_LIVRE_OPCAO03,
OCORRENCIA,
SALARIO_PAGTO,
ID_LEI,
COD_CARGO_AVALIACAO,
DATA_PUBLIC
)
VALUES
(
v_DML,
:OLD.CODIGO_EMPRESA,
:OLD.TIPO_CONTRATO,
:OLD.CODIGO_CONTRATO,
:OLD.DT_ALTER_CARGO,
:OLD.MOTIVO_ALTERACAO,
:OLD.COD_CARGO_EFET_AT,
:OLD.NIV_CARGO_EFET_AT,
:OLD.COD_CARGO_COMIS_AT,
:OLD.NIV_CARGO_COMIS_AT,
:OLD.COD_CARGO_AMPAR_AT,
:OLD.NIV_CARGO_AMPAR_AT,
:OLD.OBSERVACAO,
:NEW.LOGIN_USUARIO,
:NEW.DT_ULT_ALTER_USUA,
:OLD.DT_FIM_TEMP,
:OLD.DOCUMENTO_PUBLIC,
:OLD.ASSINATURA_01,
:OLD.ASSINATURA_02,
:OLD.ASSINATURA_03,
:OLD.C_LIVRE_SELEC01,
:OLD.C_LIVRE_SELEC02,
:OLD.C_LIVRE_SELEC03,
:OLD.C_LIVRE_VALOR01,
:OLD.C_LIVRE_VALOR02,
:OLD.C_LIVRE_VALOR03,
:OLD.C_LIVRE_DESCR01,
:OLD.C_LIVRE_DESCR02,
:OLD.C_LIVRE_DESCR03,
:OLD.C_LIVRE_DATA01,
:OLD.C_LIVRE_DATA02,
:OLD.C_LIVRE_DATA03,
:OLD.C_LIVRE_OPCAO01,
:OLD.C_LIVRE_OPCAO02,
:OLD.C_LIVRE_OPCAO03,
:OLD.OCORRENCIA,
:OLD.SALARIO_PAGTO,
:OLD.ID_LEI,
:OLD.COD_CARGO_AVALIACAO,
:OLD.DATA_PUBLIC
);
GRAVA_MODULO_APOSENT(:OLD.CODIGO_CONTRATO,'RHPLCS_ALT_CARGO',:OLD.TIPO_CONTRATO, :OLD.CODIGO_EMPRESA,null,null, null,null, null, null , null, null , null, null, null,:OLD.DT_ALTER_CARGO );
END IF;

IF INSERTING THEN 
v_DML := 'I';

INSERT INTO RHPBH_RHPLCS_ALT_CARGO_AUDIT
(
TIPO_DML,
CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO_CONTRATO,
DT_ALTER_CARGO,
MOTIVO_ALTERACAO,
COD_CARGO_EFET_AT,
NIV_CARGO_EFET_AT,
COD_CARGO_COMIS_AT,
NIV_CARGO_COMIS_AT,
COD_CARGO_AMPAR_AT,
NIV_CARGO_AMPAR_AT,
OBSERVACAO,
LOGIN_USUARIO,
DT_ULT_ALTER_USUA,
DT_FIM_TEMP,
DOCUMENTO_PUBLIC,
ASSINATURA_01,
ASSINATURA_02,
ASSINATURA_03,
C_LIVRE_SELEC01,
C_LIVRE_SELEC02,
C_LIVRE_SELEC03,
C_LIVRE_VALOR01,
C_LIVRE_VALOR02,
C_LIVRE_VALOR03,
C_LIVRE_DESCR01,
C_LIVRE_DESCR02,
C_LIVRE_DESCR03,
C_LIVRE_DATA01,
C_LIVRE_DATA02,
C_LIVRE_DATA03,
C_LIVRE_OPCAO01,
C_LIVRE_OPCAO02,
C_LIVRE_OPCAO03,
OCORRENCIA,
SALARIO_PAGTO,
ID_LEI,
COD_CARGO_AVALIACAO,
DATA_PUBLIC
)
VALUES
(
v_DML,
:NEW.CODIGO_EMPRESA,
:NEW.TIPO_CONTRATO,
:NEW.CODIGO_CONTRATO,
:NEW.DT_ALTER_CARGO,
:NEW.MOTIVO_ALTERACAO,
:NEW.COD_CARGO_EFET_AT,
:NEW.NIV_CARGO_EFET_AT,
:NEW.COD_CARGO_COMIS_AT,
:NEW.NIV_CARGO_COMIS_AT,
:NEW.COD_CARGO_AMPAR_AT,
:NEW.NIV_CARGO_AMPAR_AT,
:NEW.OBSERVACAO,
USER,
SYSDATE,
:NEW.DT_FIM_TEMP,
:NEW.DOCUMENTO_PUBLIC,
:NEW.ASSINATURA_01,
:NEW.ASSINATURA_02,
:NEW.ASSINATURA_03,
:NEW.C_LIVRE_SELEC01,
:NEW.C_LIVRE_SELEC02,
:NEW.C_LIVRE_SELEC03,
:NEW.C_LIVRE_VALOR01,
:NEW.C_LIVRE_VALOR02,
:NEW.C_LIVRE_VALOR03,
:NEW.C_LIVRE_DESCR01,
:NEW.C_LIVRE_DESCR02,
:NEW.C_LIVRE_DESCR03,
:NEW.C_LIVRE_DATA01,
:NEW.C_LIVRE_DATA02,
:NEW.C_LIVRE_DATA03,
:NEW.C_LIVRE_OPCAO01,
:NEW.C_LIVRE_OPCAO02,
:NEW.C_LIVRE_OPCAO03,
:NEW.OCORRENCIA,
:NEW.SALARIO_PAGTO,
:NEW.ID_LEI,
:NEW.COD_CARGO_AVALIACAO,
:NEW.DATA_PUBLIC
);
GRAVA_MODULO_APOSENT(:NEW.CODIGO_CONTRATO,'RHPLCS_ALT_CARGO',:NEW.TIPO_CONTRATO, :NEW.CODIGO_EMPRESA,null,null, null,null, null, null , null, null , null, null, null,:NEW.DT_ALTER_CARGO );
END IF;

END;




ALTER TRIGGER "ARTERH"."TR_RHPLCS_ALT_CARGO_AUDIT" ENABLE