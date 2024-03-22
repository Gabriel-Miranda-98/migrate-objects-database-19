
  CREATE OR REPLACE EDITIONABLE TRIGGER "ARTERH"."TR_SUGESP_RHPONT_SITUACAO" 
BEFORE INSERT OR UPDATE OR DELETE ON "ARTERH"."RHPONT_SITUACAO"
FOR EACH ROW
 DECLARE
v_DML SUGESP_RHPONT_SITUACAO.TIPO_DML%TYPE;



BEGIN




--------------------------------------------------------------------------INSERT-------------------------------------------------------------------------------------------------------------------------------------------
IF INSERTING THEN 
v_DML := 'I';


INSERT INTO SUGESP_RHPONT_SITUACAO
(
ID,
TIPO_DML,
CODIGO,
NEW_DESCRICAO,
NEW_ABREVIACAO,
NEW_VERBA_ASSOCIADA,
NEW_PERDE_D_S_R,
NEW_REF_DIFERE_ZERO,
NEW_GERA_VERBA_MES_INC,
NEW_PAD_GERA_OCOR,
NEW_TIPO_REFERENCIA,
NEW_TIPO_SITUACAO,
NEW_USO_INTERNO,
NEW_USO_INTERNO1,
NEW_USO_INTERNO2,
NEW_N_SIT_USO_INTERNO,
NEW_N_REF_USO_INTERNO,
NEW_MOTIV_USO_INTERNO,
NEW_USO_INTERNO3,
NEW_LOGIN_USUARIO,
NEW_DT_ULT_ALTER_USUA,
NEW_REFERENCIA,
NEW_OCORRS_PERDE_DSR,
NEW_QTDE_D_PERDE_DSR,
NEW_SIT_MEDIA_DSR,
NEW_FALTA_FERIAS,
NEW_MEDIA_FERIAS,
NEW_PERCENTUAL,
NEW_ABATE_AVERBACAO,
NEW_ABATE_APOSTILAMEN,
NEW_ABATE_QUINQUENIO,
NEW_ABATE_FERIAS_PREM,
NEW_ABATE_TEMP_SERV,
NEW_CODIGO_ARREDONDA,
NEW_USA_APURACAO,
NEW_USA_REFEICAO,
NEW_TEXTO_ASSOC,
NEW_SITUACAO_ASSOC,
NEW_C_LIVRE_OPCAO01,
NEW_C_LIVRE_OPCAO02,
NEW_C_LIVRE_OPCAO03,
NEW_C_LIVRE_SELEC01,
NEW_C_LIVRE_SELEC02,
NEW_C_LIVRE_SELEC03,
NEW_C_LIVRE_VALOR01,
NEW_C_LIVRE_VALOR02,
NEW_C_LIVRE_VALOR03,
NEW_C_LIVRE_DATA01,
NEW_C_LIVRE_DATA02,
NEW_C_LIVRE_DATA03,
NEW_C_LIVRE_DESCR01,
NEW_C_LIVRE_DESCR02,
NEW_FALTA_13SAL,
NEW_PERC_ACRES_HORA_CR,
NEW_DATA_CRIACAO,
NEW_DATA_EXTINCAO,
NEW_CODIGO_EMPRESA,
NEW_FALTA_VALE
)
VALUES
(
(SELECT MAX(ID)+1 FROM SUGESP_RHPONT_SITUACAO),
v_DML,
:NEW.CODIGO,
:NEW.DESCRICAO,
:NEW.ABREVIACAO,
:NEW.VERBA_ASSOCIADA,
:NEW.PERDE_D_S_R,
:NEW.REF_DIFERE_ZERO,
:NEW.GERA_VERBA_MES_INC,
:NEW.PAD_GERA_OCOR,
:NEW.TIPO_REFERENCIA,
:NEW.TIPO_SITUACAO,
:NEW.USO_INTERNO,
:NEW.USO_INTERNO1,
:NEW.USO_INTERNO2,
:NEW.N_SIT_USO_INTERNO,
:NEW.N_REF_USO_INTERNO,
:NEW.MOTIV_USO_INTERNO,
:NEW.USO_INTERNO3,
SYS_CONTEXT ('USERENV', 'OS_USER'),
SYSDATE,
:NEW.REFERENCIA,
:NEW.OCORRS_PERDE_DSR,
:NEW.QTDE_D_PERDE_DSR,
:NEW.SIT_MEDIA_DSR,
:NEW.FALTA_FERIAS,
:NEW.MEDIA_FERIAS,
:NEW.PERCENTUAL,
:NEW.ABATE_AVERBACAO,
:NEW.ABATE_APOSTILAMEN,
:NEW.ABATE_QUINQUENIO,
:NEW.ABATE_FERIAS_PREM,
:NEW.ABATE_TEMP_SERV,
:NEW.CODIGO_ARREDONDA,
:NEW.USA_APURACAO,
:NEW.USA_REFEICAO,
:NEW.TEXTO_ASSOC,
:NEW.SITUACAO_ASSOC,
:NEW.C_LIVRE_OPCAO01,
:NEW.C_LIVRE_OPCAO02,
:NEW.C_LIVRE_OPCAO03,
:NEW.C_LIVRE_SELEC01,
:NEW.C_LIVRE_SELEC02,
:NEW.C_LIVRE_SELEC03,
:NEW.C_LIVRE_VALOR01,
:NEW.C_LIVRE_VALOR02,
:NEW.C_LIVRE_VALOR03,
:NEW.C_LIVRE_DATA01,
:NEW.C_LIVRE_DATA02,
:NEW.C_LIVRE_DATA03,
:NEW.C_LIVRE_DESCR01,
:NEW.C_LIVRE_DESCR02,
:NEW.FALTA_13SAL,
:NEW.PERC_ACRES_HORA_CR,
:NEW.DATA_CRIACAO,
:NEW.DATA_EXTINCAO,
:NEW.CODIGO_EMPRESA,
:NEW.FALTA_VALE
);


--------------------------------------------------------------------------UPDATE-------------------------------------------------------------------------------------------------------------------------------------------
ELSIF UPDATING THEN
v_DML := 'U';



INSERT INTO SUGESP_RHPONT_SITUACAO
(
ID,
TIPO_DML,
CODIGO,
NEW_DESCRICAO,
NEW_ABREVIACAO,
NEW_VERBA_ASSOCIADA,
NEW_PERDE_D_S_R,
NEW_REF_DIFERE_ZERO,
NEW_GERA_VERBA_MES_INC,
NEW_PAD_GERA_OCOR,
NEW_TIPO_REFERENCIA,
NEW_TIPO_SITUACAO,
NEW_USO_INTERNO,
NEW_USO_INTERNO1,
NEW_USO_INTERNO2,
NEW_N_SIT_USO_INTERNO,
NEW_N_REF_USO_INTERNO,
NEW_MOTIV_USO_INTERNO,
NEW_USO_INTERNO3,
NEW_LOGIN_USUARIO,
NEW_DT_ULT_ALTER_USUA,
NEW_REFERENCIA,
NEW_OCORRS_PERDE_DSR,
NEW_QTDE_D_PERDE_DSR,
NEW_SIT_MEDIA_DSR,
NEW_FALTA_FERIAS,
NEW_MEDIA_FERIAS,
NEW_PERCENTUAL,
NEW_ABATE_AVERBACAO,
NEW_ABATE_APOSTILAMEN,
NEW_ABATE_QUINQUENIO,
NEW_ABATE_FERIAS_PREM,
NEW_ABATE_TEMP_SERV,
NEW_CODIGO_ARREDONDA,
NEW_USA_APURACAO,
NEW_USA_REFEICAO,
NEW_TEXTO_ASSOC,
NEW_SITUACAO_ASSOC,
NEW_C_LIVRE_OPCAO01,
NEW_C_LIVRE_OPCAO02,
NEW_C_LIVRE_OPCAO03,
NEW_C_LIVRE_SELEC01,
NEW_C_LIVRE_SELEC02,
NEW_C_LIVRE_SELEC03,
NEW_C_LIVRE_VALOR01,
NEW_C_LIVRE_VALOR02,
NEW_C_LIVRE_VALOR03,
NEW_C_LIVRE_DATA01,
NEW_C_LIVRE_DATA02,
NEW_C_LIVRE_DATA03,
NEW_C_LIVRE_DESCR01,
NEW_C_LIVRE_DESCR02,
NEW_FALTA_13SAL,
NEW_PERC_ACRES_HORA_CR,
NEW_DATA_CRIACAO,
NEW_DATA_EXTINCAO,
NEW_CODIGO_EMPRESA,
NEW_FALTA_VALE,
OLD_DESCRICAO,
OLD_ABREVIACAO,
OLD_VERBA_ASSOCIADA,
OLD_PERDE_D_S_R,
OLD_REF_DIFERE_ZERO,
OLD_GERA_VERBA_MES_INC,
OLD_PAD_GERA_OCOR,
OLD_TIPO_REFERENCIA,
OLD_TIPO_SITUACAO,
OLD_USO_INTERNO,
OLD_USO_INTERNO1,
OLD_USO_INTERNO2,
OLD_N_SIT_USO_INTERNO,
OLD_N_REF_USO_INTERNO,
OLD_MOTIV_USO_INTERNO,
OLD_USO_INTERNO3,
OLD_LOGIN_USUARIO,
OLD_DT_ULT_ALTER_USUA,
OLD_REFERENCIA,
OLD_OCORRS_PERDE_DSR,
OLD_QTDE_D_PERDE_DSR,
OLD_SIT_MEDIA_DSR,
OLD_FALTA_FERIAS,
OLD_MEDIA_FERIAS,
OLD_PERCENTUAL,
OLD_ABATE_AVERBACAO,
OLD_ABATE_APOSTILAMEN,
OLD_ABATE_QUINQUENIO,
OLD_ABATE_FERIAS_PREM,
OLD_ABATE_TEMP_SERV,
OLD_CODIGO_ARREDONDA,
OLD_USA_APURACAO,
OLD_USA_REFEICAO,
OLD_TEXTO_ASSOC,
OLD_SITUACAO_ASSOC,
OLD_C_LIVRE_OPCAO01,
OLD_C_LIVRE_OPCAO02,
OLD_C_LIVRE_OPCAO03,
OLD_C_LIVRE_SELEC01,
OLD_C_LIVRE_SELEC02,
OLD_C_LIVRE_SELEC03,
OLD_C_LIVRE_VALOR01,
OLD_C_LIVRE_VALOR02,
OLD_C_LIVRE_VALOR03,
OLD_C_LIVRE_DATA01,
OLD_C_LIVRE_DATA02,
OLD_C_LIVRE_DATA03,
OLD_C_LIVRE_DESCR01,
OLD_C_LIVRE_DESCR02,
OLD_FALTA_13SAL,
OLD_PERC_ACRES_HORA_CR,
OLD_DATA_CRIACAO,
OLD_DATA_EXTINCAO,
OLD_CODIGO_EMPRESA,
OLD_FALTA_VALE
)
VALUES
(
(SELECT MAX(ID)+1 FROM SUGESP_RHPONT_SITUACAO),
v_DML,
:NEW.CODIGO,
:NEW.DESCRICAO,
:NEW.ABREVIACAO,
:NEW.VERBA_ASSOCIADA,
:NEW.PERDE_D_S_R,
:NEW.REF_DIFERE_ZERO,
:NEW.GERA_VERBA_MES_INC,
:NEW.PAD_GERA_OCOR,
:NEW.TIPO_REFERENCIA,
:NEW.TIPO_SITUACAO,
:NEW.USO_INTERNO,
:NEW.USO_INTERNO1,
:NEW.USO_INTERNO2,
:NEW.N_SIT_USO_INTERNO,
:NEW.N_REF_USO_INTERNO,
:NEW.MOTIV_USO_INTERNO,
:NEW.USO_INTERNO3,
SYS_CONTEXT ('USERENV', 'OS_USER'),
SYSDATE,
:NEW.REFERENCIA,
:NEW.OCORRS_PERDE_DSR,
:NEW.QTDE_D_PERDE_DSR,
:NEW.SIT_MEDIA_DSR,
:NEW.FALTA_FERIAS,
:NEW.MEDIA_FERIAS,
:NEW.PERCENTUAL,
:NEW.ABATE_AVERBACAO,
:NEW.ABATE_APOSTILAMEN,
:NEW.ABATE_QUINQUENIO,
:NEW.ABATE_FERIAS_PREM,
:NEW.ABATE_TEMP_SERV,
:NEW.CODIGO_ARREDONDA,
:NEW.USA_APURACAO,
:NEW.USA_REFEICAO,
:NEW.TEXTO_ASSOC,
:NEW.SITUACAO_ASSOC,
:NEW.C_LIVRE_OPCAO01,
:NEW.C_LIVRE_OPCAO02,
:NEW.C_LIVRE_OPCAO03,
:NEW.C_LIVRE_SELEC01,
:NEW.C_LIVRE_SELEC02,
:NEW.C_LIVRE_SELEC03,
:NEW.C_LIVRE_VALOR01,
:NEW.C_LIVRE_VALOR02,
:NEW.C_LIVRE_VALOR03,
:NEW.C_LIVRE_DATA01,
:NEW.C_LIVRE_DATA02,
:NEW.C_LIVRE_DATA03,
:NEW.C_LIVRE_DESCR01,
:NEW.C_LIVRE_DESCR02,
:NEW.FALTA_13SAL,
:NEW.PERC_ACRES_HORA_CR,
:NEW.DATA_CRIACAO,
:NEW.DATA_EXTINCAO,
:NEW.CODIGO_EMPRESA,
:NEW.FALTA_VALE,
:OLD.DESCRICAO,
:OLD.ABREVIACAO,
:OLD.VERBA_ASSOCIADA,
:OLD.PERDE_D_S_R,
:OLD.REF_DIFERE_ZERO,
:OLD.GERA_VERBA_MES_INC,
:OLD.PAD_GERA_OCOR,
:OLD.TIPO_REFERENCIA,
:OLD.TIPO_SITUACAO,
:OLD.USO_INTERNO,
:OLD.USO_INTERNO1,
:OLD.USO_INTERNO2,
:OLD.N_SIT_USO_INTERNO,
:OLD.N_REF_USO_INTERNO,
:OLD.MOTIV_USO_INTERNO,
:OLD.USO_INTERNO3,
SYS_CONTEXT ('USERENV', 'OS_USER'),
SYSDATE,
:OLD.REFERENCIA,
:OLD.OCORRS_PERDE_DSR,
:OLD.QTDE_D_PERDE_DSR,
:OLD.SIT_MEDIA_DSR,
:OLD.FALTA_FERIAS,
:OLD.MEDIA_FERIAS,
:OLD.PERCENTUAL,
:OLD.ABATE_AVERBACAO,
:OLD.ABATE_APOSTILAMEN,
:OLD.ABATE_QUINQUENIO,
:OLD.ABATE_FERIAS_PREM,
:OLD.ABATE_TEMP_SERV,
:OLD.CODIGO_ARREDONDA,
:OLD.USA_APURACAO,
:OLD.USA_REFEICAO,
:OLD.TEXTO_ASSOC,
:OLD.SITUACAO_ASSOC,
:OLD.C_LIVRE_OPCAO01,
:OLD.C_LIVRE_OPCAO02,
:OLD.C_LIVRE_OPCAO03,
:OLD.C_LIVRE_SELEC01,
:OLD.C_LIVRE_SELEC02,
:OLD.C_LIVRE_SELEC03,
:OLD.C_LIVRE_VALOR01,
:OLD.C_LIVRE_VALOR02,
:OLD.C_LIVRE_VALOR03,
:OLD.C_LIVRE_DATA01,
:OLD.C_LIVRE_DATA02,
:OLD.C_LIVRE_DATA03,
:OLD.C_LIVRE_DESCR01,
:OLD.C_LIVRE_DESCR02,
:OLD.FALTA_13SAL,
:OLD.PERC_ACRES_HORA_CR,
:OLD.DATA_CRIACAO,
:OLD.DATA_EXTINCAO,
:OLD.CODIGO_EMPRESA,
:OLD.FALTA_VALE
);


--------------------------------------------------------------------------DELETE-------------------------------------------------------------------------------------------------------------------------------------------
ELSIF DELETING THEN
v_DML := 'D';


INSERT INTO SUGESP_RHPONT_SITUACAO
(
ID,
TIPO_DML,
CODIGO,
OLD_DESCRICAO,
OLD_ABREVIACAO,
OLD_VERBA_ASSOCIADA,
OLD_PERDE_D_S_R,
OLD_REF_DIFERE_ZERO,
OLD_GERA_VERBA_MES_INC,
OLD_PAD_GERA_OCOR,
OLD_TIPO_REFERENCIA,
OLD_TIPO_SITUACAO,
OLD_USO_INTERNO,
OLD_USO_INTERNO1,
OLD_USO_INTERNO2,
OLD_N_SIT_USO_INTERNO,
OLD_N_REF_USO_INTERNO,
OLD_MOTIV_USO_INTERNO,
OLD_USO_INTERNO3,
OLD_LOGIN_USUARIO,
OLD_DT_ULT_ALTER_USUA,
OLD_REFERENCIA,
OLD_OCORRS_PERDE_DSR,
OLD_QTDE_D_PERDE_DSR,
OLD_SIT_MEDIA_DSR,
OLD_FALTA_FERIAS,
OLD_MEDIA_FERIAS,
OLD_PERCENTUAL,
OLD_ABATE_AVERBACAO,
OLD_ABATE_APOSTILAMEN,
OLD_ABATE_QUINQUENIO,
OLD_ABATE_FERIAS_PREM,
OLD_ABATE_TEMP_SERV,
OLD_CODIGO_ARREDONDA,
OLD_USA_APURACAO,
OLD_USA_REFEICAO,
OLD_TEXTO_ASSOC,
OLD_SITUACAO_ASSOC,
OLD_C_LIVRE_OPCAO01,
OLD_C_LIVRE_OPCAO02,
OLD_C_LIVRE_OPCAO03,
OLD_C_LIVRE_SELEC01,
OLD_C_LIVRE_SELEC02,
OLD_C_LIVRE_SELEC03,
OLD_C_LIVRE_VALOR01,
OLD_C_LIVRE_VALOR02,
OLD_C_LIVRE_VALOR03,
OLD_C_LIVRE_DATA01,
OLD_C_LIVRE_DATA02,
OLD_C_LIVRE_DATA03,
OLD_C_LIVRE_DESCR01,
OLD_C_LIVRE_DESCR02,
OLD_FALTA_13SAL,
OLD_PERC_ACRES_HORA_CR,
OLD_DATA_CRIACAO,
OLD_DATA_EXTINCAO,
OLD_CODIGO_EMPRESA,
OLD_FALTA_VALE
)
VALUES
(
(SELECT MAX(ID)+1 FROM SUGESP_RHPONT_SITUACAO),
v_DML,
:OLD.CODIGO,
:OLD.DESCRICAO,
:OLD.ABREVIACAO,
:OLD.VERBA_ASSOCIADA,
:OLD.PERDE_D_S_R,
:OLD.REF_DIFERE_ZERO,
:OLD.GERA_VERBA_MES_INC,
:OLD.PAD_GERA_OCOR,
:OLD.TIPO_REFERENCIA,
:OLD.TIPO_SITUACAO,
:OLD.USO_INTERNO,
:OLD.USO_INTERNO1,
:OLD.USO_INTERNO2,
:OLD.N_SIT_USO_INTERNO,
:OLD.N_REF_USO_INTERNO,
:OLD.MOTIV_USO_INTERNO,
:OLD.USO_INTERNO3,
SYS_CONTEXT ('USERENV', 'OS_USER'),
SYSDATE,
:OLD.REFERENCIA,
:OLD.OCORRS_PERDE_DSR,
:OLD.QTDE_D_PERDE_DSR,
:OLD.SIT_MEDIA_DSR,
:OLD.FALTA_FERIAS,
:OLD.MEDIA_FERIAS,
:OLD.PERCENTUAL,
:OLD.ABATE_AVERBACAO,
:OLD.ABATE_APOSTILAMEN,
:OLD.ABATE_QUINQUENIO,
:OLD.ABATE_FERIAS_PREM,
:OLD.ABATE_TEMP_SERV,
:OLD.CODIGO_ARREDONDA,
:OLD.USA_APURACAO,
:OLD.USA_REFEICAO,
:OLD.TEXTO_ASSOC,
:OLD.SITUACAO_ASSOC,
:OLD.C_LIVRE_OPCAO01,
:OLD.C_LIVRE_OPCAO02,
:OLD.C_LIVRE_OPCAO03,
:OLD.C_LIVRE_SELEC01,
:OLD.C_LIVRE_SELEC02,
:OLD.C_LIVRE_SELEC03,
:OLD.C_LIVRE_VALOR01,
:OLD.C_LIVRE_VALOR02,
:OLD.C_LIVRE_VALOR03,
:OLD.C_LIVRE_DATA01,
:OLD.C_LIVRE_DATA02,
:OLD.C_LIVRE_DATA03,
:OLD.C_LIVRE_DESCR01,
:OLD.C_LIVRE_DESCR02,
:OLD.FALTA_13SAL,
:OLD.PERC_ACRES_HORA_CR,
:OLD.DATA_CRIACAO,
:OLD.DATA_EXTINCAO,
:OLD.CODIGO_EMPRESA,
:OLD.FALTA_VALE
);

END IF; --FIM IF PARA SABER SE É INSERT, UPDATE ou DELETE


END; --FIM TRIGGER




ALTER TRIGGER "ARTERH"."TR_SUGESP_RHPONT_SITUACAO" ENABLE