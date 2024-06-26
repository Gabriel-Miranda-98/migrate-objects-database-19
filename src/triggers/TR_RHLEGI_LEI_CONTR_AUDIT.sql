
  CREATE OR REPLACE EDITIONABLE TRIGGER "ARTERH"."TR_RHLEGI_LEI_CONTR_AUDIT" 
AFTER UPDATE OR DELETE OR INSERT ON "ARTERH"."RHLEGI_LEI_CONTR" 
FOR EACH ROW
 DECLARE
v_DML RHPBH_RHLEGI_LEI_CONTR_AUDIT.TIPO_DML%TYPE;
BEGIN
IF INSERTING THEN
v_DML := 'I';
INSERT INTO RHPBH_RHLEGI_LEI_CONTR_AUDIT
(
TIPO_DML,
ID_LEI_CONTR,
ID_LEI,
CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO_CONTRATO,
DATA_INI_VIGENCIA,
DATA_FIM_VIGENCIA,
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
LOGIN_USUARIO,
DT_ULT_ALTER_USUA
)
VALUES
(
v_DML,
:NEW.ID_LEI_CONTR,
:NEW.ID_LEI,
:NEW.CODIGO_EMPRESA,
:NEW.TIPO_CONTRATO,
:NEW.CODIGO_CONTRATO,
:NEW.DATA_INI_VIGENCIA,
:NEW.DATA_FIM_VIGENCIA,
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
user,
sysdate
);
GRAVA_MODULO_APOSENT(:NEW.CODIGO_CONTRATO,'RHLEGI_LEI_CONTR',:NEW.TIPO_CONTRATO, :NEW.CODIGO_EMPRESA,null,null, null,null, :NEW.ID_LEI_CONTR,null, null, null, null, null, null,null );

END IF;

IF DELETING THEN
v_DML := 'D';
INSERT INTO RHPBH_RHLEGI_LEI_CONTR_AUDIT
(
TIPO_DML,
ID_LEI_CONTR,
ID_LEI,
CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO_CONTRATO,
DATA_INI_VIGENCIA,
DATA_FIM_VIGENCIA,
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
LOGIN_USUARIO,
DT_ULT_ALTER_USUA
)
VALUES
(
v_DML,
:OLD.ID_LEI_CONTR,
:OLD.ID_LEI,
:OLD.CODIGO_EMPRESA,
:OLD.TIPO_CONTRATO,
:OLD.CODIGO_CONTRATO,
:OLD.DATA_INI_VIGENCIA,
:OLD.DATA_FIM_VIGENCIA,
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
user,
sysdate
);
GRAVA_MODULO_APOSENT(:OLD.CODIGO_CONTRATO,'RHLEGI_LEI_CONTR',:OLD.TIPO_CONTRATO, :OLD.CODIGO_EMPRESA,null,null, null,null, :OLD.ID_LEI_CONTR,null, null, null, null, null, null,null );
END IF;

IF UPDATING THEN
v_DML := 'U';
INSERT INTO RHPBH_RHLEGI_LEI_CONTR_AUDIT
(
TIPO_DML,
ID_LEI_CONTR,
ID_LEI,
CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO_CONTRATO,
DATA_INI_VIGENCIA,
DATA_FIM_VIGENCIA,
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
LOGIN_USUARIO,
DT_ULT_ALTER_USUA
)
VALUES
(
v_DML,
:OLD.ID_LEI_CONTR,
:OLD.ID_LEI,
:OLD.CODIGO_EMPRESA,
:OLD.TIPO_CONTRATO,
:OLD.CODIGO_CONTRATO,
:OLD.DATA_INI_VIGENCIA,
:OLD.DATA_FIM_VIGENCIA,
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
:NEW.LOGIN_USUARIO,
:NEW.DT_ULT_ALTER_USUA
);
GRAVA_MODULO_APOSENT(:OLD.CODIGO_CONTRATO,'RHLEGI_LEI_CONTR',:OLD.TIPO_CONTRATO, :OLD.CODIGO_EMPRESA,null,null, null,null, :OLD.ID_LEI_CONTR,null, null, null, null, null, null,null );
END IF;
END;




ALTER TRIGGER "ARTERH"."TR_RHLEGI_LEI_CONTR_AUDIT" ENABLE