
  CREATE OR REPLACE EDITIONABLE TRIGGER "ARTERH"."TR_RHCGED_TRANSFERENC_AUDIT" 
AFTER UPDATE OR DELETE OR INSERT ON "ARTERH"."RHCGED_TRANSFERENC" 
FOR EACH ROW
 DECLARE
v_DML RHPBH_RHCGED_TRANSFERENC_AUDIT.TIPO_DML%TYPE;
BEGIN

IF INSERTING THEN 
v_DML := 'I';
INSERT INTO RHPBH_RHCGED_TRANSFERENC_AUDIT
(
TIPO_DML,
ID_ALT,
CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO,
DT_ALT_UNID_CUSTO,
COD_MOVIMENTACAO,
COD_LOTACAO_ATUAL1,
COD_LOTACAO_ATUAL2,
COD_LOTACAO_ATUAL3,
COD_LOTACAO_ATUAL4,
COD_LOTACAO_ATUAL5,
COD_LOTACAO_ATUAL6,
COD_UNIDADE_ATUAL1,
COD_UNIDADE_ATUAL2,
COD_UNIDADE_ATUAL3,
COD_UNIDADE_ATUAL4,
COD_UNIDADE_ATUAL5,
COD_UNIDADE_ATUAL6,
COD_CCONTAB_ATUAL1,
COD_CCONTAB_ATUAL2,
COD_CCONTAB_ATUAL3,
COD_CCONTAB_ATUAL4,
COD_CCONTAB_ATUAL5,
COD_CCONTAB_ATUAL6,
COD_CGERENC_ATUAL1,
COD_CGERENC_ATUAL2,
COD_CGERENC_ATUAL3,
COD_CGERENC_ATUAL4,
COD_CGERENC_ATUAL5,
COD_CGERENC_ATUAL6,
TEXTO_ASSOCIADO,
LOGIN_USUARIO,
DT_ULT_ALTER_USUA,
MOTIVO_ALTERACAO,
DT_FIM_TEMP,
C_LIVRE_DESCR01,
C_LIVRE_DATA01,
DOCUMENTO_PUBLIC,
ASSINATURA_01,
ASSINATURA_02,
ASSINATURA_03,
C_LIVRE_DESCR02,
C_LIVRE_SELEC01,
C_LIVRE_VALOR01,
DT_REF_ALT_RETRO,
C_LIVRE_DATA02,
C_LIVRE_SELEC02,
C_LIVRE_VALOR02,
C_LIVRE_OPCAO01,
C_LIVRE_OPCAO02,
ID_LEI,
DATA_PUBLIC,	
DT_PREV_RETORNO	
)
VALUES
(
v_DML,
NULL,
:NEW.CODIGO_EMPRESA,
:NEW.TIPO_CONTRATO,
:NEW.CODIGO,
:NEW.DT_ALT_UNID_CUSTO,
:NEW.COD_MOVIMENTACAO,
:NEW.COD_LOTACAO_ATUAL1,
:NEW.COD_LOTACAO_ATUAL2,
:NEW.COD_LOTACAO_ATUAL3,
:NEW.COD_LOTACAO_ATUAL4,
:NEW.COD_LOTACAO_ATUAL5,
:NEW.COD_LOTACAO_ATUAL6,
:NEW.COD_UNIDADE_ATUAL1,
:NEW.COD_UNIDADE_ATUAL2,
:NEW.COD_UNIDADE_ATUAL3,
:NEW.COD_UNIDADE_ATUAL4,
:NEW.COD_UNIDADE_ATUAL5,
:NEW.COD_UNIDADE_ATUAL6,
:NEW.COD_CCONTAB_ATUAL1,
:NEW.COD_CCONTAB_ATUAL2,
:NEW.COD_CCONTAB_ATUAL3,
:NEW.COD_CCONTAB_ATUAL4,
:NEW.COD_CCONTAB_ATUAL5,
:NEW.COD_CCONTAB_ATUAL6,
:NEW.COD_CGERENC_ATUAL1,
:NEW.COD_CGERENC_ATUAL2,
:NEW.COD_CGERENC_ATUAL3,
:NEW.COD_CGERENC_ATUAL4,
:NEW.COD_CGERENC_ATUAL5,
:NEW.COD_CGERENC_ATUAL6,
:NEW.TEXTO_ASSOCIADO,
USER,
SYSDATE,
:NEW.MOTIVO_ALTERACAO,
:NEW.DT_FIM_TEMP,
:NEW.C_LIVRE_DESCR01,
:NEW.C_LIVRE_DATA01,
:NEW.DOCUMENTO_PUBLIC,
:NEW.ASSINATURA_01,
:NEW.ASSINATURA_02,
:NEW.ASSINATURA_03,
:NEW.C_LIVRE_DESCR02,
:NEW.C_LIVRE_SELEC01,
:NEW.C_LIVRE_VALOR01,
:NEW.DT_REF_ALT_RETRO,
:NEW.C_LIVRE_DATA02,
:NEW.C_LIVRE_SELEC02,
:NEW.C_LIVRE_VALOR02,
:NEW.C_LIVRE_OPCAO01,
:NEW.C_LIVRE_OPCAO02,
:NEW.ID_LEI,
:NEW.DATA_PUBLIC,	
:NEW.DT_PREV_RETORNO	
);
GRAVA_MODULO_APOSENT(:NEW.CODIGO,'RHCGED_TRANSFERENC', :NEW.TIPO_CONTRATO, :NEW.CODIGO_EMPRESA, :NEW.COD_MOVIMENTACAO, :NEW.DT_ALT_UNID_CUSTO,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null  );

END IF;

IF DELETING THEN
v_DML := 'D';
INSERT INTO RHPBH_RHCGED_TRANSFERENC_AUDIT
(
TIPO_DML,
ID_ALT,
CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO,
DT_ALT_UNID_CUSTO,
COD_MOVIMENTACAO,
COD_LOTACAO_ATUAL1,
COD_LOTACAO_ATUAL2,
COD_LOTACAO_ATUAL3,
COD_LOTACAO_ATUAL4,
COD_LOTACAO_ATUAL5,
COD_LOTACAO_ATUAL6,
COD_UNIDADE_ATUAL1,
COD_UNIDADE_ATUAL2,
COD_UNIDADE_ATUAL3,
COD_UNIDADE_ATUAL4,
COD_UNIDADE_ATUAL5,
COD_UNIDADE_ATUAL6,
COD_CCONTAB_ATUAL1,
COD_CCONTAB_ATUAL2,
COD_CCONTAB_ATUAL3,
COD_CCONTAB_ATUAL4,
COD_CCONTAB_ATUAL5,
COD_CCONTAB_ATUAL6,
COD_CGERENC_ATUAL1,
COD_CGERENC_ATUAL2,
COD_CGERENC_ATUAL3,
COD_CGERENC_ATUAL4,
COD_CGERENC_ATUAL5,
COD_CGERENC_ATUAL6,
TEXTO_ASSOCIADO,
LOGIN_USUARIO,
DT_ULT_ALTER_USUA,
MOTIVO_ALTERACAO,
DT_FIM_TEMP,
C_LIVRE_DESCR01,
C_LIVRE_DATA01,
DOCUMENTO_PUBLIC,
ASSINATURA_01,
ASSINATURA_02,
ASSINATURA_03,
C_LIVRE_DESCR02,
C_LIVRE_SELEC01,
C_LIVRE_VALOR01,
DT_REF_ALT_RETRO,
C_LIVRE_DATA02,
C_LIVRE_SELEC02,
C_LIVRE_VALOR02,
C_LIVRE_OPCAO01,
C_LIVRE_OPCAO02,
ID_LEI,
DATA_PUBLIC,	
DT_PREV_RETORNO	
)
VALUES
(
v_DML,
NULL,
:OLD.CODIGO_EMPRESA,
:OLD.TIPO_CONTRATO,
:OLD.CODIGO,
:OLD.DT_ALT_UNID_CUSTO,
:OLD.COD_MOVIMENTACAO,
:OLD.COD_LOTACAO_ATUAL1,
:OLD.COD_LOTACAO_ATUAL2,
:OLD.COD_LOTACAO_ATUAL3,
:OLD.COD_LOTACAO_ATUAL4,
:OLD.COD_LOTACAO_ATUAL5,
:OLD.COD_LOTACAO_ATUAL6,
:OLD.COD_UNIDADE_ATUAL1,
:OLD.COD_UNIDADE_ATUAL2,
:OLD.COD_UNIDADE_ATUAL3,
:OLD.COD_UNIDADE_ATUAL4,
:OLD.COD_UNIDADE_ATUAL5,
:OLD.COD_UNIDADE_ATUAL6,
:OLD.COD_CCONTAB_ATUAL1,
:OLD.COD_CCONTAB_ATUAL2,
:OLD.COD_CCONTAB_ATUAL3,
:OLD.COD_CCONTAB_ATUAL4,
:OLD.COD_CCONTAB_ATUAL5,
:OLD.COD_CCONTAB_ATUAL6,
:OLD.COD_CGERENC_ATUAL1,
:OLD.COD_CGERENC_ATUAL2,
:OLD.COD_CGERENC_ATUAL3,
:OLD.COD_CGERENC_ATUAL4,
:OLD.COD_CGERENC_ATUAL5,
:OLD.COD_CGERENC_ATUAL6,
:OLD.TEXTO_ASSOCIADO,
USER,
SYSDATE,
:OLD.MOTIVO_ALTERACAO,
:OLD.DT_FIM_TEMP,
:OLD.C_LIVRE_DESCR01,
:OLD.C_LIVRE_DATA01,
:OLD.DOCUMENTO_PUBLIC,
:OLD.ASSINATURA_01,
:OLD.ASSINATURA_02,
:OLD.ASSINATURA_03,
:OLD.C_LIVRE_DESCR02,
:OLD.C_LIVRE_SELEC01,
:OLD.C_LIVRE_VALOR01,
:OLD.DT_REF_ALT_RETRO,
:OLD.C_LIVRE_DATA02,
:OLD.C_LIVRE_SELEC02,
:OLD.C_LIVRE_VALOR02,
:OLD.C_LIVRE_OPCAO01,
:OLD.C_LIVRE_OPCAO02,
:OLD.ID_LEI,
:OLD.DATA_PUBLIC,	
:OLD.DT_PREV_RETORNO	
);
GRAVA_MODULO_APOSENT(:OLD.CODIGO,'RHCGED_TRANSFERENC', :OLD.TIPO_CONTRATO, :OLD.CODIGO_EMPRESA, :OLD.COD_MOVIMENTACAO, :OLD.DT_ALT_UNID_CUSTO,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null  );

END IF;

IF UPDATING THEN
v_DML := 'U';
INSERT INTO RHPBH_RHCGED_TRANSFERENC_AUDIT
(
TIPO_DML,
ID_ALT,
CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO,
DT_ALT_UNID_CUSTO,
COD_MOVIMENTACAO,
COD_LOTACAO_ATUAL1,
COD_LOTACAO_ATUAL2,
COD_LOTACAO_ATUAL3,
COD_LOTACAO_ATUAL4,
COD_LOTACAO_ATUAL5,
COD_LOTACAO_ATUAL6,
COD_UNIDADE_ATUAL1,
COD_UNIDADE_ATUAL2,
COD_UNIDADE_ATUAL3,
COD_UNIDADE_ATUAL4,
COD_UNIDADE_ATUAL5,
COD_UNIDADE_ATUAL6,
COD_CCONTAB_ATUAL1,
COD_CCONTAB_ATUAL2,
COD_CCONTAB_ATUAL3,
COD_CCONTAB_ATUAL4,
COD_CCONTAB_ATUAL5,
COD_CCONTAB_ATUAL6,
COD_CGERENC_ATUAL1,
COD_CGERENC_ATUAL2,
COD_CGERENC_ATUAL3,
COD_CGERENC_ATUAL4,
COD_CGERENC_ATUAL5,
COD_CGERENC_ATUAL6,
TEXTO_ASSOCIADO,
LOGIN_USUARIO,
DT_ULT_ALTER_USUA,
MOTIVO_ALTERACAO,
DT_FIM_TEMP,
C_LIVRE_DESCR01,
C_LIVRE_DATA01,
DOCUMENTO_PUBLIC,
ASSINATURA_01,
ASSINATURA_02,
ASSINATURA_03,
C_LIVRE_DESCR02,
C_LIVRE_SELEC01,
C_LIVRE_VALOR01,
DT_REF_ALT_RETRO,
C_LIVRE_DATA02,
C_LIVRE_SELEC02,
C_LIVRE_VALOR02,
C_LIVRE_OPCAO01,
C_LIVRE_OPCAO02,
ID_LEI,
DATA_PUBLIC,	
DT_PREV_RETORNO	
)
VALUES
(
v_DML,
NULL,
:OLD.CODIGO_EMPRESA,
:OLD.TIPO_CONTRATO,
:OLD.CODIGO,
:OLD.DT_ALT_UNID_CUSTO,
:OLD.COD_MOVIMENTACAO,
:OLD.COD_LOTACAO_ATUAL1,
:OLD.COD_LOTACAO_ATUAL2,
:OLD.COD_LOTACAO_ATUAL3,
:OLD.COD_LOTACAO_ATUAL4,
:OLD.COD_LOTACAO_ATUAL5,
:OLD.COD_LOTACAO_ATUAL6,
:OLD.COD_UNIDADE_ATUAL1,
:OLD.COD_UNIDADE_ATUAL2,
:OLD.COD_UNIDADE_ATUAL3,
:OLD.COD_UNIDADE_ATUAL4,
:OLD.COD_UNIDADE_ATUAL5,
:OLD.COD_UNIDADE_ATUAL6,
:OLD.COD_CCONTAB_ATUAL1,
:OLD.COD_CCONTAB_ATUAL2,
:OLD.COD_CCONTAB_ATUAL3,
:OLD.COD_CCONTAB_ATUAL4,
:OLD.COD_CCONTAB_ATUAL5,
:OLD.COD_CCONTAB_ATUAL6,
:OLD.COD_CGERENC_ATUAL1,
:OLD.COD_CGERENC_ATUAL2,
:OLD.COD_CGERENC_ATUAL3,
:OLD.COD_CGERENC_ATUAL4,
:OLD.COD_CGERENC_ATUAL5,
:OLD.COD_CGERENC_ATUAL6,
:OLD.TEXTO_ASSOCIADO,
:NEW.LOGIN_USUARIO,
sysdate,
:OLD.MOTIVO_ALTERACAO,
:OLD.DT_FIM_TEMP,
:OLD.C_LIVRE_DESCR01,
:OLD.C_LIVRE_DATA01,
:OLD.DOCUMENTO_PUBLIC,
:OLD.ASSINATURA_01,
:OLD.ASSINATURA_02,
:OLD.ASSINATURA_03,
:OLD.C_LIVRE_DESCR02,
:OLD.C_LIVRE_SELEC01,
:OLD.C_LIVRE_VALOR01,
:OLD.DT_REF_ALT_RETRO,
:OLD.C_LIVRE_DATA02,
:OLD.C_LIVRE_SELEC02,
:OLD.C_LIVRE_VALOR02,
:OLD.C_LIVRE_OPCAO01,
:OLD.C_LIVRE_OPCAO02,
:OLD.ID_LEI,
:OLD.DATA_PUBLIC,	
:OLD.DT_PREV_RETORNO	
);
GRAVA_MODULO_APOSENT(:OLD.CODIGO,'RHCGED_TRANSFERENC', :OLD.TIPO_CONTRATO, :OLD.CODIGO_EMPRESA, :OLD.COD_MOVIMENTACAO, :OLD.DT_ALT_UNID_CUSTO,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null  );


END IF;
END;




ALTER TRIGGER "ARTERH"."TR_RHCGED_TRANSFERENC_AUDIT" ENABLE