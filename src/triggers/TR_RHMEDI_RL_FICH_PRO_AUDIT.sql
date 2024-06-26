
  CREATE OR REPLACE EDITIONABLE TRIGGER "ARTERH"."TR_RHMEDI_RL_FICH_PRO_AUDIT" 
AFTER UPDATE OR DELETE OR INSERT ON "ARTERH"."RHMEDI_RL_FICH_PRO" 
FOR EACH ROW
 DECLARE
v_DML RHPBH_RHMEDI_RL_FICH_PRO_AUDIT.TIPO_DML%TYPE;
BEGIN
IF INSERTING THEN
v_DML := 'I';
INSERT INTO RHPBH_RHMEDI_RL_FICH_PRO_AUDIT
(
TIPO_DML,
CODIGO_EMPRESA,
CODIGO_PESSOA,
DT_REG_OCORRENCIA,
OCORRENCIA,
CODIGO_PROC_MED,
TEXTO_ASSOCIADO,
LOGIN_USUARIO,
DT_ULT_ALTER_USUA,
OCOR_PROC_MED,
CODIGO_FORNECEDOR,
COD_EMPRESA_ATEND,
COD_PESSOA_ATEND,
QTDE_OCOR,
PERC_OPERAC_CALC,
PERC_HONORA_CALC,
VALOR_COBRADO,
VALOR_PAGO,
DATA_PAGTO,
DATA_GLOSA,
VALOR_GLOSA,
CODIGO_MOT_GLOSA,
TEXTO_GLOSA,
DATA_REVISAO_GLOSA,
TEXTO_REVIS_GLOSA,
DATA_PAGTO_GLOSA,
C_LIVRE_SELEC01,
C_LIVRE_SELEC02,
C_LIVRE_SELEC03,
C_LIVRE_VALOR01,
C_LIVRE_VALOR02,
C_LIVRE_VALOR03,
C_LIVRE_DATA01,
C_LIVRE_DATA02,
C_LIVRE_DATA03,
C_LIVRE_OPCAO01,
C_LIVRE_OPCAO02,
C_LIVRE_OPCAO03,
C_LIVRE_DESCR01,
C_LIVRE_DESCR02,
C_LIVRE_DESCR03,
NUM_DOCUMENTO,
TIPO_ATENDENTE,
FORNECEDOR_ATEND,
TIPO_DESCONTO,
PERC_DESCONTO,
VALOR_REVIS_GLOSA
)
VALUES
(
v_DML,
:NEW.CODIGO_EMPRESA,
:NEW.CODIGO_PESSOA,
:NEW.DT_REG_OCORRENCIA,
:NEW.OCORRENCIA,
:NEW.CODIGO_PROC_MED,
:NEW.TEXTO_ASSOCIADO,
USER,
SYSDATE,
:NEW.OCOR_PROC_MED,
:NEW.CODIGO_FORNECEDOR,
:NEW.COD_EMPRESA_ATEND,
:NEW.COD_PESSOA_ATEND,
:NEW.QTDE_OCOR,
:NEW.PERC_OPERAC_CALC,
:NEW.PERC_HONORA_CALC,
:NEW.VALOR_COBRADO,
:NEW.VALOR_PAGO,
:NEW.DATA_PAGTO,
:NEW.DATA_GLOSA,
:NEW.VALOR_GLOSA,
:NEW.CODIGO_MOT_GLOSA,
:NEW.TEXTO_GLOSA,
:NEW.DATA_REVISAO_GLOSA,
:NEW.TEXTO_REVIS_GLOSA,
:NEW.DATA_PAGTO_GLOSA,
:NEW.C_LIVRE_SELEC01,
:NEW.C_LIVRE_SELEC02,
:NEW.C_LIVRE_SELEC03,
:NEW.C_LIVRE_VALOR01,
:NEW.C_LIVRE_VALOR02,
:NEW.C_LIVRE_VALOR03,
:NEW.C_LIVRE_DATA01,
:NEW.C_LIVRE_DATA02,
:NEW.C_LIVRE_DATA03,
:NEW.C_LIVRE_OPCAO01,
:NEW.C_LIVRE_OPCAO02,
:NEW.C_LIVRE_OPCAO03,
:NEW.C_LIVRE_DESCR01,
:NEW.C_LIVRE_DESCR02,
:NEW.C_LIVRE_DESCR03,
:NEW.NUM_DOCUMENTO,
:NEW.TIPO_ATENDENTE,
:NEW.FORNECEDOR_ATEND,
:NEW.TIPO_DESCONTO,
:NEW.PERC_DESCONTO,
:NEW.VALOR_REVIS_GLOSA
);
END IF;

IF DELETING THEN
v_DML := 'D';
INSERT INTO RHPBH_RHMEDI_RL_FICH_PRO_AUDIT
(
TIPO_DML,
CODIGO_EMPRESA,
CODIGO_PESSOA,
DT_REG_OCORRENCIA,
OCORRENCIA,
CODIGO_PROC_MED,
TEXTO_ASSOCIADO,
LOGIN_USUARIO,
DT_ULT_ALTER_USUA,
OCOR_PROC_MED,
CODIGO_FORNECEDOR,
COD_EMPRESA_ATEND,
COD_PESSOA_ATEND,
QTDE_OCOR,
PERC_OPERAC_CALC,
PERC_HONORA_CALC,
VALOR_COBRADO,
VALOR_PAGO,
DATA_PAGTO,
DATA_GLOSA,
VALOR_GLOSA,
CODIGO_MOT_GLOSA,
TEXTO_GLOSA,
DATA_REVISAO_GLOSA,
TEXTO_REVIS_GLOSA,
DATA_PAGTO_GLOSA,
C_LIVRE_SELEC01,
C_LIVRE_SELEC02,
C_LIVRE_SELEC03,
C_LIVRE_VALOR01,
C_LIVRE_VALOR02,
C_LIVRE_VALOR03,
C_LIVRE_DATA01,
C_LIVRE_DATA02,
C_LIVRE_DATA03,
C_LIVRE_OPCAO01,
C_LIVRE_OPCAO02,
C_LIVRE_OPCAO03,
C_LIVRE_DESCR01,
C_LIVRE_DESCR02,
C_LIVRE_DESCR03,
NUM_DOCUMENTO,
TIPO_ATENDENTE,
FORNECEDOR_ATEND,
TIPO_DESCONTO,
PERC_DESCONTO,
VALOR_REVIS_GLOSA
)
VALUES
(
v_DML,
:OLD.CODIGO_EMPRESA,
:OLD.CODIGO_PESSOA,
:OLD.DT_REG_OCORRENCIA,
:OLD.OCORRENCIA,
:OLD.CODIGO_PROC_MED,
:OLD.TEXTO_ASSOCIADO,
USER,
SYSDATE,
:OLD.OCOR_PROC_MED,
:OLD.CODIGO_FORNECEDOR,
:OLD.COD_EMPRESA_ATEND,
:OLD.COD_PESSOA_ATEND,
:OLD.QTDE_OCOR,
:OLD.PERC_OPERAC_CALC,
:OLD.PERC_HONORA_CALC,
:OLD.VALOR_COBRADO,
:OLD.VALOR_PAGO,
:OLD.DATA_PAGTO,
:OLD.DATA_GLOSA,
:OLD.VALOR_GLOSA,
:OLD.CODIGO_MOT_GLOSA,
:OLD.TEXTO_GLOSA,
:OLD.DATA_REVISAO_GLOSA,
:OLD.TEXTO_REVIS_GLOSA,
:OLD.DATA_PAGTO_GLOSA,
:OLD.C_LIVRE_SELEC01,
:OLD.C_LIVRE_SELEC02,
:OLD.C_LIVRE_SELEC03,
:OLD.C_LIVRE_VALOR01,
:OLD.C_LIVRE_VALOR02,
:OLD.C_LIVRE_VALOR03,
:OLD.C_LIVRE_DATA01,
:OLD.C_LIVRE_DATA02,
:OLD.C_LIVRE_DATA03,
:OLD.C_LIVRE_OPCAO01,
:OLD.C_LIVRE_OPCAO02,
:OLD.C_LIVRE_OPCAO03,
:OLD.C_LIVRE_DESCR01,
:OLD.C_LIVRE_DESCR02,
:OLD.C_LIVRE_DESCR03,
:OLD.NUM_DOCUMENTO,
:OLD.TIPO_ATENDENTE,
:OLD.FORNECEDOR_ATEND,
:OLD.TIPO_DESCONTO,
:OLD.PERC_DESCONTO,
:OLD.VALOR_REVIS_GLOSA
);
END IF;

IF UPDATING THEN
v_DML := 'U';
INSERT INTO RHPBH_RHMEDI_RL_FICH_PRO_AUDIT
(
TIPO_DML,
CODIGO_EMPRESA,
CODIGO_PESSOA,
DT_REG_OCORRENCIA,
OCORRENCIA,
CODIGO_PROC_MED,
TEXTO_ASSOCIADO,
LOGIN_USUARIO,
DT_ULT_ALTER_USUA,
OCOR_PROC_MED,
CODIGO_FORNECEDOR,
COD_EMPRESA_ATEND,
COD_PESSOA_ATEND,
QTDE_OCOR,
PERC_OPERAC_CALC,
PERC_HONORA_CALC,
VALOR_COBRADO,
VALOR_PAGO,
DATA_PAGTO,
DATA_GLOSA,
VALOR_GLOSA,
CODIGO_MOT_GLOSA,
TEXTO_GLOSA,
DATA_REVISAO_GLOSA,
TEXTO_REVIS_GLOSA,
DATA_PAGTO_GLOSA,
C_LIVRE_SELEC01,
C_LIVRE_SELEC02,
C_LIVRE_SELEC03,
C_LIVRE_VALOR01,
C_LIVRE_VALOR02,
C_LIVRE_VALOR03,
C_LIVRE_DATA01,
C_LIVRE_DATA02,
C_LIVRE_DATA03,
C_LIVRE_OPCAO01,
C_LIVRE_OPCAO02,
C_LIVRE_OPCAO03,
C_LIVRE_DESCR01,
C_LIVRE_DESCR02,
C_LIVRE_DESCR03,
NUM_DOCUMENTO,
TIPO_ATENDENTE,
FORNECEDOR_ATEND,
TIPO_DESCONTO,
PERC_DESCONTO,
VALOR_REVIS_GLOSA
)
VALUES
(
v_DML,
:OLD.CODIGO_EMPRESA,
:OLD.CODIGO_PESSOA,
:OLD.DT_REG_OCORRENCIA,
:OLD.OCORRENCIA,
:OLD.CODIGO_PROC_MED,
:OLD.TEXTO_ASSOCIADO,
:NEW.LOGIN_USUARIO,
:NEW.DT_ULT_ALTER_USUA,
:OLD.OCOR_PROC_MED,
:OLD.CODIGO_FORNECEDOR,
:OLD.COD_EMPRESA_ATEND,
:OLD.COD_PESSOA_ATEND,
:OLD.QTDE_OCOR,
:OLD.PERC_OPERAC_CALC,
:OLD.PERC_HONORA_CALC,
:OLD.VALOR_COBRADO,
:OLD.VALOR_PAGO,
:OLD.DATA_PAGTO,
:OLD.DATA_GLOSA,
:OLD.VALOR_GLOSA,
:OLD.CODIGO_MOT_GLOSA,
:OLD.TEXTO_GLOSA,
:OLD.DATA_REVISAO_GLOSA,
:OLD.TEXTO_REVIS_GLOSA,
:OLD.DATA_PAGTO_GLOSA,
:OLD.C_LIVRE_SELEC01,
:OLD.C_LIVRE_SELEC02,
:OLD.C_LIVRE_SELEC03,
:OLD.C_LIVRE_VALOR01,
:OLD.C_LIVRE_VALOR02,
:OLD.C_LIVRE_VALOR03,
:OLD.C_LIVRE_DATA01,
:OLD.C_LIVRE_DATA02,
:OLD.C_LIVRE_DATA03,
:OLD.C_LIVRE_OPCAO01,
:OLD.C_LIVRE_OPCAO02,
:OLD.C_LIVRE_OPCAO03,
:OLD.C_LIVRE_DESCR01,
:OLD.C_LIVRE_DESCR02,
:OLD.C_LIVRE_DESCR03,
:OLD.NUM_DOCUMENTO,
:OLD.TIPO_ATENDENTE,
:OLD.FORNECEDOR_ATEND,
:OLD.TIPO_DESCONTO,
:OLD.PERC_DESCONTO,
:OLD.VALOR_REVIS_GLOSA
);

END IF;
END;




ALTER TRIGGER "ARTERH"."TR_RHMEDI_RL_FICH_PRO_AUDIT" ENABLE