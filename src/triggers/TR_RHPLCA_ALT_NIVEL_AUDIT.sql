
  CREATE OR REPLACE EDITIONABLE TRIGGER "ARTERH"."TR_RHPLCA_ALT_NIVEL_AUDIT" 
AFTER UPDATE OR DELETE OR INSERT ON "ARTERH"."RHPLCA_ALT_NIVEL" 
FOR EACH ROW
 DECLARE
v_DML RHPBH_RHPLCA_ALT_NIVEL_AUDIT.TIPO_DML%TYPE;
BEGIN
IF INSERTING THEN
v_DML := 'I';
INSERT INTO RHPBH_RHPLCA_ALT_NIVEL_AUDIT
(
TIPO_DML,
CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO_CONTRATO,
DT_ALTER_NIVEL,
OCORRENCIA,
CODIGO_HIST_CARREI,
ID_NIVEL,
OBSERVACAO,
DT_FIM_TEMP,
DOCUMENTO_PUBLIC,
ASSINATURA_01,
ASSINATURA_02,
LOGIN_USUARIO,
DT_ULT_ALTER_USUA,
C_LIVRE_SELEC01,
C_LIVRE_SELEC02,
C_LIVRE_VALOR01,
C_LIVRE_VALOR02,
C_LIVRE_DATA01,
C_LIVRE_DATA02,
C_LIVRE_OPCAO01,
C_LIVRE_OPCAO02,
C_LIVRE_DESCR01,
C_LIVRE_DESCR02,
TEXTO_ASSOCIADO,
NIVEL_CARREIRA
)
VALUES
(
v_DML,
:NEW.CODIGO_EMPRESA,
:NEW.TIPO_CONTRATO,
:NEW.CODIGO_CONTRATO,
:NEW.DT_ALTER_NIVEL,
:NEW.OCORRENCIA,
:NEW.CODIGO_HIST_CARREI,
:NEW.ID_NIVEL,
:NEW.OBSERVACAO,
:NEW.DT_FIM_TEMP,
:NEW.DOCUMENTO_PUBLIC,
:NEW.ASSINATURA_01,
:NEW.ASSINATURA_02,
USER,
SYSDATE,
:NEW.C_LIVRE_SELEC01,
:NEW.C_LIVRE_SELEC02,
:NEW.C_LIVRE_VALOR01,
:NEW.C_LIVRE_VALOR02,
:NEW.C_LIVRE_DATA01,
:NEW.C_LIVRE_DATA02,
:NEW.C_LIVRE_OPCAO01,
:NEW.C_LIVRE_OPCAO02,
:NEW.C_LIVRE_DESCR01,
:NEW.C_LIVRE_DESCR02,
:NEW.TEXTO_ASSOCIADO,
:NEW.NIVEL_CARREIRA
);
GRAVA_MODULO_APOSENT(:NEW.CODIGO_CONTRATO,'RHPLCA_ALT_NIVEL',:NEW.TIPO_CONTRATO, :NEW.CODIGO_EMPRESA,null,null, null,null, null, null, null, null, null, :NEW.DT_ALTER_NIVEL, null,null );

END IF;

IF DELETING THEN
v_DML := 'D';
INSERT INTO RHPBH_RHPLCA_ALT_NIVEL_AUDIT
(
TIPO_DML,
CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO_CONTRATO,
DT_ALTER_NIVEL,
OCORRENCIA,
CODIGO_HIST_CARREI,
ID_NIVEL,
OBSERVACAO,
DT_FIM_TEMP,
DOCUMENTO_PUBLIC,
ASSINATURA_01,
ASSINATURA_02,
LOGIN_USUARIO,
DT_ULT_ALTER_USUA,
C_LIVRE_SELEC01,
C_LIVRE_SELEC02,
C_LIVRE_VALOR01,
C_LIVRE_VALOR02,
C_LIVRE_DATA01,
C_LIVRE_DATA02,
C_LIVRE_OPCAO01,
C_LIVRE_OPCAO02,
C_LIVRE_DESCR01,
C_LIVRE_DESCR02,
TEXTO_ASSOCIADO,
NIVEL_CARREIRA
)
VALUES
(
v_DML,
:OLD.CODIGO_EMPRESA,
:OLD.TIPO_CONTRATO,
:OLD.CODIGO_CONTRATO,
:OLD.DT_ALTER_NIVEL,
:OLD.OCORRENCIA,
:OLD.CODIGO_HIST_CARREI,
:OLD.ID_NIVEL,
:OLD.OBSERVACAO,
:OLD.DT_FIM_TEMP,
:OLD.DOCUMENTO_PUBLIC,
:OLD.ASSINATURA_01,
:OLD.ASSINATURA_02,
USER,
SYSDATE,
:OLD.C_LIVRE_SELEC01,
:OLD.C_LIVRE_SELEC02,
:OLD.C_LIVRE_VALOR01,
:OLD.C_LIVRE_VALOR02,
:OLD.C_LIVRE_DATA01,
:OLD.C_LIVRE_DATA02,
:OLD.C_LIVRE_OPCAO01,
:OLD.C_LIVRE_OPCAO02,
:OLD.C_LIVRE_DESCR01,
:OLD.C_LIVRE_DESCR02,
:OLD.TEXTO_ASSOCIADO,
:OLD.NIVEL_CARREIRA
);
GRAVA_MODULO_APOSENT(:OLD.CODIGO_CONTRATO,'RHPLCA_ALT_NIVEL',:OLD.TIPO_CONTRATO, :OLD.CODIGO_EMPRESA,null,null, null,null, null, null, null, null, null, :OLD.DT_ALTER_NIVEL, null,null );
END IF;

IF UPDATING THEN
v_DML := 'U';
INSERT INTO RHPBH_RHPLCA_ALT_NIVEL_AUDIT
(
TIPO_DML,
CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO_CONTRATO,
DT_ALTER_NIVEL,
OCORRENCIA,
CODIGO_HIST_CARREI,
ID_NIVEL,
OBSERVACAO,
DT_FIM_TEMP,
DOCUMENTO_PUBLIC,
ASSINATURA_01,
ASSINATURA_02,
LOGIN_USUARIO,
DT_ULT_ALTER_USUA,
C_LIVRE_SELEC01,
C_LIVRE_SELEC02,
C_LIVRE_VALOR01,
C_LIVRE_VALOR02,
C_LIVRE_DATA01,
C_LIVRE_DATA02,
C_LIVRE_OPCAO01,
C_LIVRE_OPCAO02,
C_LIVRE_DESCR01,
C_LIVRE_DESCR02,
TEXTO_ASSOCIADO,
NIVEL_CARREIRA
)
VALUES
(
v_DML,
:OLD.CODIGO_EMPRESA,
:OLD.TIPO_CONTRATO,
:OLD.CODIGO_CONTRATO,
:OLD.DT_ALTER_NIVEL,
:OLD.OCORRENCIA,
:OLD.CODIGO_HIST_CARREI,
:OLD.ID_NIVEL,
:OLD.OBSERVACAO,
:OLD.DT_FIM_TEMP,
:OLD.DOCUMENTO_PUBLIC,
:OLD.ASSINATURA_01,
:OLD.ASSINATURA_02,
:NEW.LOGIN_USUARIO,
:NEW.DT_ULT_ALTER_USUA,
:OLD.C_LIVRE_SELEC01,
:OLD.C_LIVRE_SELEC02,
:OLD.C_LIVRE_VALOR01,
:OLD.C_LIVRE_VALOR02,
:OLD.C_LIVRE_DATA01,
:OLD.C_LIVRE_DATA02,
:OLD.C_LIVRE_OPCAO01,
:OLD.C_LIVRE_OPCAO02,
:OLD.C_LIVRE_DESCR01,
:OLD.C_LIVRE_DESCR02,
:OLD.TEXTO_ASSOCIADO,
:OLD.NIVEL_CARREIRA
);
GRAVA_MODULO_APOSENT(:OLD.CODIGO_CONTRATO,'RHPLCA_ALT_NIVEL',:OLD.TIPO_CONTRATO, :OLD.CODIGO_EMPRESA,null,null, null,null, null, null, null, null, null, :OLD.DT_ALTER_NIVEL, null,null );
END IF;

END;




ALTER TRIGGER "ARTERH"."TR_RHPLCA_ALT_NIVEL_AUDIT" ENABLE