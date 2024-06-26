
  CREATE OR REPLACE EDITIONABLE TRIGGER "ARTERH"."TR_RHLEGI_LEI_AUDIT" 
AFTER UPDATE OR DELETE OR INSERT ON "ARTERH"."RHLEGI_LEI" 
FOR EACH ROW
 DECLARE
v_DML RHPBH_RHLEGI_LEI_AUDIT.TIPO_DML%TYPE;
BEGIN

IF INSERTING THEN
v_DML := 'I';
INSERT INTO RHPBH_RHLEGI_LEI_AUDIT
(
TIPO_DML,
ID_LEI,
CODIGO_EMPRESA,
DESCR_LEI,
EMENTA_LEI,
TEMA_LEI,
TIPO_LEI,
PALAVRAS_CHAVE,
NUMERO_LEI,
ANO_LEI,
DATA_PROMULGACAO,
DATA_PUBLICACAO,
DATA_INI_VIGENCIA,
DATA_FIM_VIGENCIA,
AUTORIA_LEI,
ID_AGRUP_ORI_LEI,
ID_AGRUP_ADM_NORMA,
VEICULO_PUBLICACAO,
TEXTO_LEGAL,
COMENTARIO_LEI,
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
DT_ULT_ALTER_USUA,
CODIGO_STATUS,
COD_EMP_RESP_CAD,
COD_PESS_RESP_CAD,
DATA_APROVACAO,
DATA_REPROVACAO,
ASSINATURA_01,
ASSINATURA_02
)
VALUES
(
v_DML,
:NEW.ID_LEI,
:NEW.CODIGO_EMPRESA,
:NEW.DESCR_LEI,
:NEW.EMENTA_LEI,
:NEW.TEMA_LEI,
:NEW.TIPO_LEI,
:NEW.PALAVRAS_CHAVE,
:NEW.NUMERO_LEI,
:NEW.ANO_LEI,
:NEW.DATA_PROMULGACAO,
:NEW.DATA_PUBLICACAO,
:NEW.DATA_INI_VIGENCIA,
:NEW.DATA_FIM_VIGENCIA,
:NEW.AUTORIA_LEI,
:NEW.ID_AGRUP_ORI_LEI,
:NEW.ID_AGRUP_ADM_NORMA,
:NEW.VEICULO_PUBLICACAO,
:NEW.TEXTO_LEGAL,
:NEW.COMENTARIO_LEI,
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
USER,
SYSDATE,
:NEW.CODIGO_STATUS,
:NEW.COD_EMP_RESP_CAD,
:NEW.COD_PESS_RESP_CAD,
:NEW.DATA_APROVACAO,
:NEW.DATA_REPROVACAO,
:NEW.ASSINATURA_01,
:NEW.ASSINATURA_02
);
END IF;

IF DELETING THEN
v_DML := 'D';
INSERT INTO RHPBH_RHLEGI_LEI_AUDIT
(
TIPO_DML,
ID_LEI,
CODIGO_EMPRESA,
DESCR_LEI,
EMENTA_LEI,
TEMA_LEI,
TIPO_LEI,
PALAVRAS_CHAVE,
NUMERO_LEI,
ANO_LEI,
DATA_PROMULGACAO,
DATA_PUBLICACAO,
DATA_INI_VIGENCIA,
DATA_FIM_VIGENCIA,
AUTORIA_LEI,
ID_AGRUP_ORI_LEI,
ID_AGRUP_ADM_NORMA,
VEICULO_PUBLICACAO,
TEXTO_LEGAL,
COMENTARIO_LEI,
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
DT_ULT_ALTER_USUA,
CODIGO_STATUS,
COD_EMP_RESP_CAD,
COD_PESS_RESP_CAD,
DATA_APROVACAO,
DATA_REPROVACAO,
ASSINATURA_01,
ASSINATURA_02
)
VALUES
(
v_DML,
:OLD.ID_LEI,
:OLD.CODIGO_EMPRESA,
:OLD.DESCR_LEI,
:OLD.EMENTA_LEI,
:OLD.TEMA_LEI,
:OLD.TIPO_LEI,
:OLD.PALAVRAS_CHAVE,
:OLD.NUMERO_LEI,
:OLD.ANO_LEI,
:OLD.DATA_PROMULGACAO,
:OLD.DATA_PUBLICACAO,
:OLD.DATA_INI_VIGENCIA,
:OLD.DATA_FIM_VIGENCIA,
:OLD.AUTORIA_LEI,
:OLD.ID_AGRUP_ORI_LEI,
:OLD.ID_AGRUP_ADM_NORMA,
:OLD.VEICULO_PUBLICACAO,
:OLD.TEXTO_LEGAL,
:OLD.COMENTARIO_LEI,
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
USER,
SYSDATE,
:OLD.CODIGO_STATUS,
:OLD.COD_EMP_RESP_CAD,
:OLD.COD_PESS_RESP_CAD,
:OLD.DATA_APROVACAO,
:OLD.DATA_REPROVACAO,
:OLD.ASSINATURA_01,
:OLD.ASSINATURA_02
);
END IF;

IF UPDATING THEN
v_DML := 'U';
INSERT INTO RHPBH_RHLEGI_LEI_AUDIT
(
TIPO_DML,
ID_LEI,
CODIGO_EMPRESA,
DESCR_LEI,
EMENTA_LEI,
TEMA_LEI,
TIPO_LEI,
PALAVRAS_CHAVE,
NUMERO_LEI,
ANO_LEI,
DATA_PROMULGACAO,
DATA_PUBLICACAO,
DATA_INI_VIGENCIA,
DATA_FIM_VIGENCIA,
AUTORIA_LEI,
ID_AGRUP_ORI_LEI,
ID_AGRUP_ADM_NORMA,
VEICULO_PUBLICACAO,
TEXTO_LEGAL,
COMENTARIO_LEI,
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
DT_ULT_ALTER_USUA,
CODIGO_STATUS,
COD_EMP_RESP_CAD,
COD_PESS_RESP_CAD,
DATA_APROVACAO,
DATA_REPROVACAO,
ASSINATURA_01,
ASSINATURA_02
)
VALUES
(
v_DML,
:OLD.ID_LEI,
:OLD.CODIGO_EMPRESA,
:OLD.DESCR_LEI,
:OLD.EMENTA_LEI,
:OLD.TEMA_LEI,
:OLD.TIPO_LEI,
:OLD.PALAVRAS_CHAVE,
:OLD.NUMERO_LEI,
:OLD.ANO_LEI,
:OLD.DATA_PROMULGACAO,
:OLD.DATA_PUBLICACAO,
:OLD.DATA_INI_VIGENCIA,
:OLD.DATA_FIM_VIGENCIA,
:OLD.AUTORIA_LEI,
:OLD.ID_AGRUP_ORI_LEI,
:OLD.ID_AGRUP_ADM_NORMA,
:OLD.VEICULO_PUBLICACAO,
:OLD.TEXTO_LEGAL,
:OLD.COMENTARIO_LEI,
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
:NEW.DT_ULT_ALTER_USUA,
:OLD.CODIGO_STATUS,
:OLD.COD_EMP_RESP_CAD,
:OLD.COD_PESS_RESP_CAD,
:OLD.DATA_APROVACAO,
:OLD.DATA_REPROVACAO,
:OLD.ASSINATURA_01,
:OLD.ASSINATURA_02
);

END IF;
END;




ALTER TRIGGER "ARTERH"."TR_RHLEGI_LEI_AUDIT" ENABLE