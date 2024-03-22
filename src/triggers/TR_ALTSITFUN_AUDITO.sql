
  CREATE OR REPLACE EDITIONABLE TRIGGER "ARTERH"."TR_ALTSITFUN_AUDITO" 
BEFORE INSERT OR UPDATE OR DELETE ON "ARTERH"."RHCGED_ALT_SIT_FUN"
FOR EACH ROW
 DECLARE
v_DML SMARH_INT_PE_ALTSITFUN_AUDITO.TIPO_DML%TYPE;

    vCONTADOR NUMBER;

    vCODIGO_EMPRESA_NEW VARCHAR2(4);
    vCODIGO_EMPRESA_OLD VARCHAR2(4);
    vTIPO_CONTRATO_NEW VARCHAR2(4);
    vTIPO_CONTRATO_OLD VARCHAR2(4);
    vCODIGO_NEW VARCHAR2(15);
    vCODIGO_OLD VARCHAR2(15);
    vDATA_INIC_SITUACAO_NEW DATE;
    vDATA_INIC_SITUACAO_OLD DATE;

    vCOD_SIT_FUNCIONAL_NEW VARCHAR2(4);
    vCOD_SIT_FUNCIONAL_OLD VARCHAR2(4);
    vCONTROLE_FOLHA_NEW VARCHAR2(4);
    vCONTROLE_FOLHA_OLD VARCHAR2(4);
    vDATA_FIM_SITUACAO_NEW DATE;
    vDATA_FIM_SITUACAO_OLD DATE;

    vLOGIN_USUARIO_NEW VARCHAR2(40);
    vLOGIN_USUARIO_OLD VARCHAR2(40);
    vLOGIN_OS_NEW VARCHAR2(40);
    vLOGIN_OS_OLD VARCHAR2(40);
    vLOGIN_NEW VARCHAR2(40);
    vLOGIN_OLD VARCHAR2(40);

    vDATA_SISTEMA DATE;
    vANO_MES_REF_ULT_CONTRATO DATE;

vOLD_SALARIO_PAGTO VARCHAR2(1);
vOLD_COD_CARGO_PAGTO VARCHAR2(15);
vOLD_NIVEL_CARGO_PAGTO VARCHAR2(8);
vOLD_COD_CARGO_COMISS VARCHAR2(15);
vOLD_NIVEL_CARGO_COMISS VARCHAR2(8 );
vOLD_DT_ULT_CARGO_COM DATE;
vOLD_CODIGO_FUNCAO VARCHAR2(15);
vOLD_DT_ULT_FUNCAO DATE;

vULT_ID number;

vCODIGO_EMPRESA VARCHAR2(4);
vTIPO_CONTRATO VARCHAR2(4);
vCODIGO VARCHAR2(15);

--PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
--POPULA VARIAVEIS

vULT_ID := 0;

    vCODIGO_EMPRESA_NEW := :NEW.CODIGO_EMPRESA;
    vCODIGO_EMPRESA_OLD := :OLD.CODIGO_EMPRESA;
    vTIPO_CONTRATO_NEW := :NEW.TIPO_CONTRATO;
    vTIPO_CONTRATO_OLD := :OLD.TIPO_CONTRATO;
    vCODIGO_NEW := :NEW.CODIGO;
    vCODIGO_OLD := :OLD.CODIGO;
    vDATA_INIC_SITUACAO_NEW := :NEW.DATA_INIC_SITUACAO;
    vDATA_INIC_SITUACAO_OLD := :OLD.DATA_INIC_SITUACAO;
    vCOD_SIT_FUNCIONAL_NEW := :NEW.COD_SIT_FUNCIONAL;
    vCOD_SIT_FUNCIONAL_OLD := :OLD.COD_SIT_FUNCIONAL;
    vDATA_FIM_SITUACAO_NEW := :NEW.DATA_FIM_SITUACAO;
    vDATA_FIM_SITUACAO_OLD := :OLD.DATA_FIM_SITUACAO;
    vLOGIN_USUARIO_NEW := :NEW.LOGIN_USUARIO;
    vLOGIN_USUARIO_OLD := :OLD.LOGIN_USUARIO;
    vLOGIN_OS_NEW := SYS_CONTEXT ('USERENV', 'OS_USER');
    vLOGIN_OS_OLD := SYS_CONTEXT ('USERENV', 'OS_USER');

    vCONTROLE_FOLHA_NEW := NULL;
    vCONTROLE_FOLHA_OLD := NULL;

    vLOGIN_NEW := NULL;
    vLOGIN_OLD := NULL;
    vDATA_SISTEMA := NULL;
    vANO_MES_REF_ULT_CONTRATO := NULL;

vOLD_SALARIO_PAGTO := NULL;
vOLD_COD_CARGO_PAGTO := NULL;
vOLD_NIVEL_CARGO_PAGTO := NULL;
vOLD_COD_CARGO_COMISS := NULL;
vOLD_NIVEL_CARGO_COMISS := NULL;
vOLD_DT_ULT_CARGO_COM := NULL;
vOLD_CODIGO_FUNCAO := NULL;
vOLD_DT_ULT_FUNCAO := NULL;

vCODIGO_EMPRESA := NULL;
vTIPO_CONTRATO := NULL;
vCODIGO := NULL;

--definir login a usar NEW
    IF vLOGIN_USUARIO_NEW = 'ARTERH_UPBH' then 
    vLOGIN_NEW := vLOGIN_OS_NEW;
    ELSE 
    vLOGIN_NEW := vLOGIN_USUARIO_NEW;
    END IF;

--definir login a usar OLD
    IF vLOGIN_USUARIO_OLD = 'ARTERH_UPBH' then 
    vLOGIN_NEW := vLOGIN_OS_OLD;
    ELSE 
    vLOGIN_OLD := vLOGIN_USUARIO_OLD;
    END IF;



--pegar data atual sistema Arterh esta trabalhando    
SELECT DATA_DO_SISTEMA INTO vDATA_SISTEMA from rhparm_p_sist;


--pegar campo CONTROLE FOLHA das situaÃ§Ãµes funcionais envolvidas
--select controle_folha into  vCONTROLE_FOLHA_NEW from RHPARM_SIT_FUNC where codigo = :NEW.COD_SIT_FUNCIONAL;
--select controle_folha into  vCONTROLE_FOLHA_OLD from RHPARM_SIT_FUNC where codigo = :OLD.COD_SIT_FUNCIONAL;


--------------------------------------------------------------------------INSERT-------------------------------------------------------------------------------------------------------------------------------------------
IF INSERTING THEN 
v_DML := 'I';

vCODIGO_EMPRESA := :NEW.CODIGO_EMPRESA;
vTIPO_CONTRATO := :NEW.TIPO_CONTRATO;
vCODIGO := :NEW.CODIGO;

--pegar campo CONTROLE FOLHA das situaÃ§Ãµes funcionais envolvidas
--comentado em 2/8/22--select controle_folha into  vCONTROLE_FOLHA_NEW from RHPARM_SIT_FUNC where codigo = :NEW.COD_SIT_FUNCIONAL;
--select controle_folha into  vCONTROLE_FOLHA_OLD from RHPARM_SIT_FUNC where codigo = :OLD.COD_SIT_FUNCIONAL;

--pegar ano_mes_ref do ultimo contrato da pessoa    
   SELECT 
    C.SALARIO_PAGTO, C.COD_CARGO_PAGTO, C.NIVEL_CARGO_PAGTO, C.COD_CARGO_COMISS, C.NIVEL_CARGO_COMISS, C.DT_ULT_CARGO_COM, C.CODIGO_FUNCAO, C.DT_ULT_FUNCAO
    INTO 
    vOLD_SALARIO_PAGTO, vOLD_COD_CARGO_PAGTO, vOLD_NIVEL_CARGO_PAGTO, vOLD_COD_CARGO_COMISS, vOLD_NIVEL_CARGO_COMISS, vOLD_DT_ULT_CARGO_COM, vOLD_CODIGO_FUNCAO, vOLD_DT_ULT_FUNCAO
    from RHPESS_CONTRATO C WHERE C.CODIGO_EMPRESA = :NEW.CODIGO_EMPRESA AND C.TIPO_CONTRATO = :NEW.TIPO_CONTRATO AND C.CODIGO = :NEW.CODIGO AND
    C.ANO_MES_REFERENCIA = (select max(AUX.ano_mes_referencia) from rhpess_contrato AUX
    where AUX.codigo_empresa = c.codigo_empresa 
    and AUX.tipo_contrato = c.tipo_contrato 
    and AUX.codigo = c.codigo
    --and AUX.ano_mes_referencia <= vDATA_SISTEMA
   );   

INSERT INTO SMARH_INT_PE_ALTSITFUN_AUDITO
(
ID,
TIPO_DML,
CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO,
DATA_INIC_SITUACAO,
NEW_COD_SIT_FUNCIONAL,
NEW_DATA_FIM_SITUACAO,
LOGIN_USUARIO,
DT_ULT_ALTER_USUA,
LOGIN_OS,
--CONTROLE_FOLHA_NEW,OLD_SALARIO_PAGTO, OLD_COD_CARGO_PAGTO, OLD_NIVEL_CARGO_PAGTO, OLD_COD_CARGO_COMISS, OLD_NIVEL_CARGO_COMISS, OLD_DT_ULT_CARGO_COM, OLD_CODIGO_FUNCAO, OLD_DT_ULT_FUNCAO,
NEW_MOTIVO_AFAST, OLD_MOTIVO_AFAST,
ASSINATURA_01,
ASSINATURA_02,
ASSINATURA_03,
C_LIVRE_DATA01,
C_LIVRE_DATA02,
C_LIVRE_DATA03,
C_LIVRE_DATA04,
C_LIVRE_DESCR01,
C_LIVRE_DESCR02,
C_LIVRE_DESCR03,
C_LIVRE_OPCAO01,
C_LIVRE_OPCAO02,
C_LIVRE_OPCAO03,
C_LIVRE_SELEC01,
C_LIVRE_SELEC02,
C_LIVRE_SELEC03,
C_LIVRE_VALOR01,
C_LIVRE_VALOR02,
C_LIVRE_VALOR03,
CNPJ_CESSIONARIO,
COD_SIT_FUNC_ANT,
CODIGO_ATENDENTE,
CODIGO_DOENCA,
CODIGO_DOENCA_CORRELATA,
CONSELHO_REGIONAL,
DOCUMENTO_PUBLIC,
DT_ALTER_ESOCIAL,
DT_PREV_RETORNO,
DT_PROC_ESOCIAL,
DT_PRORROGA,
DT_REF_ALT_RETRO,
DT_VERIFICACAO,
EMPRESA_ATENDENTE,
ID_LEI,
IND_EF_RETRO_ESOCIAL,
INFO_MESMO_MOTIVO,
INFO_ONUS,
INSCRICAO_CONSELHO,
NOME_ATENDENTE,
OBSERVACAO_ESOCIAL,
PROXIMA_SITUACAO,
QTDE_DIAS_AFAST,
TEXTO_ASSOCIADO,
TP_ACID_TRANSITO_ESOCIAL,
UF_CONSELHO,
VALOR_BENEF_13SAL,
VALOR_BENEF_LIQ,
VALOR_BENEF_MENSAL,
DATA_PUBLIC
)
VALUES
(
SEQUENCE_SITFUNC.NEXTVAL,--(SELECT MAX(ID)+1 FROM SMARH_INT_PE_ALTSITFUN_AUDITO),
v_DML,
:NEW.CODIGO_EMPRESA,
:NEW.TIPO_CONTRATO,
:NEW.CODIGO,
:NEW.DATA_INIC_SITUACAO,
:NEW.COD_SIT_FUNCIONAL,
:NEW.DATA_FIM_SITUACAO,
:NEW.LOGIN_USUARIO,--USER,
SYSDATE,
SYS_CONTEXT ('USERENV', 'OS_USER')
--,vCONTROLE_FOLHA_NEW, vOLD_SALARIO_PAGTO, vOLD_COD_CARGO_PAGTO, vOLD_NIVEL_CARGO_PAGTO, vOLD_COD_CARGO_COMISS, vOLD_NIVEL_CARGO_COMISS, vOLD_DT_ULT_CARGO_COM, vOLD_CODIGO_FUNCAO, vOLD_DT_ULT_FUNCAO
, :NEW.MOTIVO_AFAST, NULL,
:NEW.ASSINATURA_01,
:NEW.ASSINATURA_02,
:NEW.ASSINATURA_03,
:NEW.C_LIVRE_DATA01,
:NEW.C_LIVRE_DATA02,
:NEW.C_LIVRE_DATA03,
:NEW.C_LIVRE_DATA04,
:NEW.C_LIVRE_DESCR01,
:NEW.C_LIVRE_DESCR02,
:NEW.C_LIVRE_DESCR03,
:NEW.C_LIVRE_OPCAO01,
:NEW.C_LIVRE_OPCAO02,
:NEW.C_LIVRE_OPCAO03,
:NEW.C_LIVRE_SELEC01,
:NEW.C_LIVRE_SELEC02,
:NEW.C_LIVRE_SELEC03,
:NEW.C_LIVRE_VALOR01,
:NEW.C_LIVRE_VALOR02,
:NEW.C_LIVRE_VALOR03,
:NEW.CNPJ_CESSIONARIO,
:NEW.COD_SIT_FUNC_ANT,
:NEW.CODIGO_ATENDENTE,
:NEW.CODIGO_DOENCA,
:NEW.CODIGO_DOENCA_CORRELATA,
:NEW.CONSELHO_REGIONAL,
:NEW.DOCUMENTO_PUBLIC,
:NEW.DT_ALTER_ESOCIAL,
:NEW.DT_PREV_RETORNO,
:NEW.DT_PROC_ESOCIAL,
:NEW.DT_PRORROGA,
:NEW.DT_REF_ALT_RETRO,
:NEW.DT_VERIFICACAO,
:NEW.EMPRESA_ATENDENTE,
:NEW.ID_LEI,
:NEW.IND_EF_RETRO_ESOCIAL,
:NEW.INFO_MESMO_MOTIVO,
:NEW.INFO_ONUS,
:NEW.INSCRICAO_CONSELHO,
:NEW.NOME_ATENDENTE,
:NEW.OBSERVACAO_ESOCIAL,
:NEW.PROXIMA_SITUACAO,
:NEW.QTDE_DIAS_AFAST,
:NEW.TEXTO_ASSOCIADO,
:NEW.TP_ACID_TRANSITO_ESOCIAL,
:NEW.UF_CONSELHO,
:NEW.VALOR_BENEF_13SAL,
:NEW.VALOR_BENEF_LIQ,
:NEW.VALOR_BENEF_MENSAL,
:NEW.DATA_PUBLIC
);
GRAVA_MODULO_APOSENT(:NEW.CODIGO,'RHCGED_ALT_SIT_FUN',:NEW.TIPO_CONTRATO, :NEW.CODIGO_EMPRESA, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL );
--COMMIT;--ORA-04092: cannot COMMIT in a trigger

--BEGIN
--SUGESP_MANUTE_ALT_SIT_FUNC_V2 (:NEW.CODIGO_EMPRESA, :NEW.TIPO_CONTRATO, :NEW.CODIGO, :NEW.LOGIN_USUARIO, SYS_CONTEXT ('USERENV', 'OS_USER'));
--END;

--------------------------------------------------------------------------UPDATE-------------------------------------------------------------------------------------------------------------------------------------------
ELSIF UPDATING THEN
v_DML := 'U';

vCODIGO_EMPRESA := :NEW.CODIGO_EMPRESA;
vTIPO_CONTRATO := :NEW.TIPO_CONTRATO;
vCODIGO := :NEW.CODIGO;

--pegar campo CONTROLE FOLHA das situaÃ§Ãµes funcionais envolvidas
--comentado em 2/8/22--select controle_folha into  vCONTROLE_FOLHA_NEW from RHPARM_SIT_FUNC where codigo = :NEW.COD_SIT_FUNCIONAL;
--comentado em 2/8/22--select controle_folha into  vCONTROLE_FOLHA_OLD from RHPARM_SIT_FUNC where codigo = :OLD.COD_SIT_FUNCIONAL;

--pegar ano_mes_ref do ultimo contrato da pessoa    
   SELECT 
    C.SALARIO_PAGTO, C.COD_CARGO_PAGTO, C.NIVEL_CARGO_PAGTO, C.COD_CARGO_COMISS, C.NIVEL_CARGO_COMISS, C.DT_ULT_CARGO_COM, C.CODIGO_FUNCAO, C.DT_ULT_FUNCAO
    INTO 
    vOLD_SALARIO_PAGTO, vOLD_COD_CARGO_PAGTO, vOLD_NIVEL_CARGO_PAGTO, vOLD_COD_CARGO_COMISS, vOLD_NIVEL_CARGO_COMISS, vOLD_DT_ULT_CARGO_COM, vOLD_CODIGO_FUNCAO, vOLD_DT_ULT_FUNCAO
    from RHPESS_CONTRATO C WHERE C.CODIGO_EMPRESA = :NEW.CODIGO_EMPRESA AND C.TIPO_CONTRATO = :NEW.TIPO_CONTRATO AND C.CODIGO = :NEW.CODIGO AND
    C.ANO_MES_REFERENCIA = (select max(AUX.ano_mes_referencia) from rhpess_contrato AUX
    where AUX.codigo_empresa = c.codigo_empresa 
    and AUX.tipo_contrato = c.tipo_contrato 
    and AUX.codigo = c.codigo
    --and AUX.ano_mes_referencia <= vDATA_SISTEMA
   );   


INSERT INTO SMARH_INT_PE_ALTSITFUN_AUDITO
(
ID,
TIPO_DML,
CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO,
DATA_INIC_SITUACAO,
OLD_COD_SIT_FUNCIONAL,
OLD_DATA_FIM_SITUACAO,
NEW_COD_SIT_FUNCIONAL,
NEW_DATA_FIM_SITUACAO,
LOGIN_USUARIO,
DT_ULT_ALTER_USUA,
LOGIN_OS,
--CONTROLE_FOLHA_NEW, CONTROLE_FOLHA_OLD, OLD_SALARIO_PAGTO, OLD_COD_CARGO_PAGTO, OLD_NIVEL_CARGO_PAGTO, OLD_COD_CARGO_COMISS, OLD_NIVEL_CARGO_COMISS, OLD_DT_ULT_CARGO_COM, OLD_CODIGO_FUNCAO, OLD_DT_ULT_FUNCAO,
NEW_MOTIVO_AFAST, OLD_MOTIVO_AFAST,
ASSINATURA_01,
ASSINATURA_02,
ASSINATURA_03,
C_LIVRE_DATA01,
C_LIVRE_DATA02,
C_LIVRE_DATA03,
C_LIVRE_DATA04,
C_LIVRE_DESCR01,
C_LIVRE_DESCR02,
C_LIVRE_DESCR03,
C_LIVRE_OPCAO01,
C_LIVRE_OPCAO02,
C_LIVRE_OPCAO03,
C_LIVRE_SELEC01,
C_LIVRE_SELEC02,
C_LIVRE_SELEC03,
C_LIVRE_VALOR01,
C_LIVRE_VALOR02,
C_LIVRE_VALOR03,
CNPJ_CESSIONARIO,
COD_SIT_FUNC_ANT,
CODIGO_ATENDENTE,
CODIGO_DOENCA,
CODIGO_DOENCA_CORRELATA,
CONSELHO_REGIONAL,
DOCUMENTO_PUBLIC,
DT_ALTER_ESOCIAL,
DT_PREV_RETORNO,
DT_PROC_ESOCIAL,
DT_PRORROGA,
DT_REF_ALT_RETRO,
DT_VERIFICACAO,
EMPRESA_ATENDENTE,
ID_LEI,
IND_EF_RETRO_ESOCIAL,
INFO_MESMO_MOTIVO,
INFO_ONUS,
INSCRICAO_CONSELHO,
NOME_ATENDENTE,
OBSERVACAO_ESOCIAL,
PROXIMA_SITUACAO,
QTDE_DIAS_AFAST,
TEXTO_ASSOCIADO,
TP_ACID_TRANSITO_ESOCIAL,
UF_CONSELHO,
VALOR_BENEF_13SAL,
VALOR_BENEF_LIQ,
VALOR_BENEF_MENSAL,
DATA_PUBLIC
)
VALUES
(
SEQUENCE_SITFUNC.NEXTVAL,--(SELECT MAX(ID)+1 FROM SMARH_INT_PE_ALTSITFUN_AUDITO),
v_DML,
:OLD.CODIGO_EMPRESA,
:OLD.TIPO_CONTRATO,
:OLD.CODIGO,
:OLD.DATA_INIC_SITUACAO,
:OLD.COD_SIT_FUNCIONAL,
:OLD.DATA_FIM_SITUACAO,
:NEW.COD_SIT_FUNCIONAL,
:NEW.DATA_FIM_SITUACAO,
:NEW.LOGIN_USUARIO,-- ATE 26/4/19 :OLD.LOGIN_USUARIO,
SYSDATE,
SYS_CONTEXT ('USERENV', 'OS_USER'),
--vCONTROLE_FOLHA_NEW, vCONTROLE_FOLHA_OLD, vOLD_SALARIO_PAGTO, vOLD_COD_CARGO_PAGTO, vOLD_NIVEL_CARGO_PAGTO, vOLD_COD_CARGO_COMISS, vOLD_NIVEL_CARGO_COMISS, vOLD_DT_ULT_CARGO_COM, vOLD_CODIGO_FUNCAO, vOLD_DT_ULT_FUNCAO,
:NEW.MOTIVO_AFAST, :OLD.MOTIVO_AFAST,
:OLD.ASSINATURA_01,
:OLD.ASSINATURA_02,
:OLD.ASSINATURA_03,
:OLD.C_LIVRE_DATA01,
:OLD.C_LIVRE_DATA02,
:OLD.C_LIVRE_DATA03,
:OLD.C_LIVRE_DATA04,
:OLD.C_LIVRE_DESCR01,
:OLD.C_LIVRE_DESCR02,
:OLD.C_LIVRE_DESCR03,
:OLD.C_LIVRE_OPCAO01,
:OLD.C_LIVRE_OPCAO02,
:OLD.C_LIVRE_OPCAO03,
:OLD.C_LIVRE_SELEC01,
:OLD.C_LIVRE_SELEC02,
:OLD.C_LIVRE_SELEC03,
:OLD.C_LIVRE_VALOR01,
:OLD.C_LIVRE_VALOR02,
:OLD.C_LIVRE_VALOR03,
:OLD.CNPJ_CESSIONARIO,
:OLD.COD_SIT_FUNC_ANT,
:OLD.CODIGO_ATENDENTE,
:OLD.CODIGO_DOENCA,
:OLD.CODIGO_DOENCA_CORRELATA,
:OLD.CONSELHO_REGIONAL,
:OLD.DOCUMENTO_PUBLIC,
:OLD.DT_ALTER_ESOCIAL,
:OLD.DT_PREV_RETORNO,
:OLD.DT_PROC_ESOCIAL,
:OLD.DT_PRORROGA,
:OLD.DT_REF_ALT_RETRO,
:OLD.DT_VERIFICACAO,
:OLD.EMPRESA_ATENDENTE,
:OLD.ID_LEI,
:OLD.IND_EF_RETRO_ESOCIAL,
:OLD.INFO_MESMO_MOTIVO,
:OLD.INFO_ONUS,
:OLD.INSCRICAO_CONSELHO,
:OLD.NOME_ATENDENTE,
:OLD.OBSERVACAO_ESOCIAL,
:OLD.PROXIMA_SITUACAO,
:OLD.QTDE_DIAS_AFAST,
:OLD.TEXTO_ASSOCIADO,
:OLD.TP_ACID_TRANSITO_ESOCIAL,
:OLD.UF_CONSELHO,
:OLD.VALOR_BENEF_13SAL,
:OLD.VALOR_BENEF_LIQ,
:OLD.VALOR_BENEF_MENSAL,
:OLD.DATA_PUBLIC
);
GRAVA_MODULO_APOSENT(:NEW.CODIGO,'RHCGED_ALT_SIT_FUN',:NEW.TIPO_CONTRATO, :NEW.CODIGO_EMPRESA, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL );
--COMMIT;--ORA-04092: cannot COMMIT in a trigger

--BEGIN
--SUGESP_MANUTE_ALT_SIT_FUNC_V2 (:NEW.CODIGO_EMPRESA, :NEW.TIPO_CONTRATO, :NEW.CODIGO, :NEW.LOGIN_USUARIO, SYS_CONTEXT ('USERENV', 'OS_USER'));
--END;

--------------------------------------------------------------------------DELETE-------------------------------------------------------------------------------------------------------------------------------------------
ELSIF DELETING THEN
v_DML := 'D';

vCODIGO_EMPRESA := :OLD.CODIGO_EMPRESA;
vTIPO_CONTRATO := :OLD.TIPO_CONTRATO;
vCODIGO := :OLD.CODIGO;

--pegar campo CONTROLE FOLHA das situaÃ§Ãµes funcionais envolvidas
--select controle_folha into  vCONTROLE_FOLHA_NEW from RHPARM_SIT_FUNC where codigo = :NEW.COD_SIT_FUNCIONAL;
--comentado em 2/8/22--select controle_folha into  vCONTROLE_FOLHA_OLD from RHPARM_SIT_FUNC where codigo = :OLD.COD_SIT_FUNCIONAL;

--pegar ano_mes_ref do ultimo contrato da pessoa    
   SELECT 
    C.SALARIO_PAGTO, C.COD_CARGO_PAGTO, C.NIVEL_CARGO_PAGTO, C.COD_CARGO_COMISS, C.NIVEL_CARGO_COMISS, C.DT_ULT_CARGO_COM, C.CODIGO_FUNCAO, C.DT_ULT_FUNCAO
    INTO 
    vOLD_SALARIO_PAGTO, vOLD_COD_CARGO_PAGTO, vOLD_NIVEL_CARGO_PAGTO, vOLD_COD_CARGO_COMISS, vOLD_NIVEL_CARGO_COMISS, vOLD_DT_ULT_CARGO_COM, vOLD_CODIGO_FUNCAO, vOLD_DT_ULT_FUNCAO
    from RHPESS_CONTRATO C WHERE C.CODIGO_EMPRESA = :OLD.CODIGO_EMPRESA AND C.TIPO_CONTRATO = :OLD.TIPO_CONTRATO AND C.CODIGO = :OLD.CODIGO AND
    C.ANO_MES_REFERENCIA = (select max(AUX.ano_mes_referencia) from rhpess_contrato AUX
    where AUX.codigo_empresa = c.codigo_empresa 
    and AUX.tipo_contrato = c.tipo_contrato 
    and AUX.codigo = c.codigo
    --and AUX.ano_mes_referencia <= vDATA_SISTEMA
   );   


INSERT INTO SMARH_INT_PE_ALTSITFUN_AUDITO
(
ID,
TIPO_DML,
CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO,
DATA_INIC_SITUACAO,
OLD_COD_SIT_FUNCIONAL,
OLD_DATA_FIM_SITUACAO,
LOGIN_USUARIO,
DT_ULT_ALTER_USUA,
LOGIN_OS,
--CONTROLE_FOLHA_NEW, CONTROLE_FOLHA_OLD, OLD_SALARIO_PAGTO, OLD_COD_CARGO_PAGTO, OLD_NIVEL_CARGO_PAGTO, OLD_COD_CARGO_COMISS, OLD_NIVEL_CARGO_COMISS, OLD_DT_ULT_CARGO_COM, OLD_CODIGO_FUNCAO, OLD_DT_ULT_FUNCAO,
NEW_MOTIVO_AFAST, OLD_MOTIVO_AFAST,
ASSINATURA_01,
ASSINATURA_02,
ASSINATURA_03,
C_LIVRE_DATA01,
C_LIVRE_DATA02,
C_LIVRE_DATA03,
C_LIVRE_DATA04,
C_LIVRE_DESCR01,
C_LIVRE_DESCR02,
C_LIVRE_DESCR03,
C_LIVRE_OPCAO01,
C_LIVRE_OPCAO02,
C_LIVRE_OPCAO03,
C_LIVRE_SELEC01,
C_LIVRE_SELEC02,
C_LIVRE_SELEC03,
C_LIVRE_VALOR01,
C_LIVRE_VALOR02,
C_LIVRE_VALOR03,
CNPJ_CESSIONARIO,
COD_SIT_FUNC_ANT,
CODIGO_ATENDENTE,
CODIGO_DOENCA,
CODIGO_DOENCA_CORRELATA,
CONSELHO_REGIONAL,
DOCUMENTO_PUBLIC,
DT_ALTER_ESOCIAL,
DT_PREV_RETORNO,
DT_PROC_ESOCIAL,
DT_PRORROGA,
DT_REF_ALT_RETRO,
DT_VERIFICACAO,
EMPRESA_ATENDENTE,
ID_LEI,
IND_EF_RETRO_ESOCIAL,
INFO_MESMO_MOTIVO,
INFO_ONUS,
INSCRICAO_CONSELHO,
NOME_ATENDENTE,
OBSERVACAO_ESOCIAL,
PROXIMA_SITUACAO,
QTDE_DIAS_AFAST,
TEXTO_ASSOCIADO,
TP_ACID_TRANSITO_ESOCIAL,
UF_CONSELHO,
VALOR_BENEF_13SAL,
VALOR_BENEF_LIQ,
VALOR_BENEF_MENSAL,
DATA_PUBLIC
)
VALUES
(
SEQUENCE_SITFUNC.NEXTVAL,--(SELECT MAX(ID)+1 FROM SMARH_INT_PE_ALTSITFUN_AUDITO),
v_DML,
:OLD.CODIGO_EMPRESA,
:OLD.TIPO_CONTRATO,
:OLD.CODIGO,
:OLD.DATA_INIC_SITUACAO,
:OLD.COD_SIT_FUNCIONAL,
:OLD.DATA_FIM_SITUACAO,
USER,
SYSDATE,
SYS_CONTEXT ('USERENV', 'OS_USER'),
--vCONTROLE_FOLHA_NEW, vCONTROLE_FOLHA_OLD, vOLD_SALARIO_PAGTO, vOLD_COD_CARGO_PAGTO, vOLD_NIVEL_CARGO_PAGTO, vOLD_COD_CARGO_COMISS, vOLD_NIVEL_CARGO_COMISS, vOLD_DT_ULT_CARGO_COM, vOLD_CODIGO_FUNCAO, vOLD_DT_ULT_FUNCAO,
NULL, :OLD.MOTIVO_AFAST,
:OLD.ASSINATURA_01,
:OLD.ASSINATURA_02,
:OLD.ASSINATURA_03,
:OLD.C_LIVRE_DATA01,
:OLD.C_LIVRE_DATA02,
:OLD.C_LIVRE_DATA03,
:OLD.C_LIVRE_DATA04,
:OLD.C_LIVRE_DESCR01,
:OLD.C_LIVRE_DESCR02,
:OLD.C_LIVRE_DESCR03,
:OLD.C_LIVRE_OPCAO01,
:OLD.C_LIVRE_OPCAO02,
:OLD.C_LIVRE_OPCAO03,
:OLD.C_LIVRE_SELEC01,
:OLD.C_LIVRE_SELEC02,
:OLD.C_LIVRE_SELEC03,
:OLD.C_LIVRE_VALOR01,
:OLD.C_LIVRE_VALOR02,
:OLD.C_LIVRE_VALOR03,
:OLD.CNPJ_CESSIONARIO,
:OLD.COD_SIT_FUNC_ANT,
:OLD.CODIGO_ATENDENTE,
:OLD.CODIGO_DOENCA,
:OLD.CODIGO_DOENCA_CORRELATA,
:OLD.CONSELHO_REGIONAL,
:OLD.DOCUMENTO_PUBLIC,
:OLD.DT_ALTER_ESOCIAL,
:OLD.DT_PREV_RETORNO,
:OLD.DT_PROC_ESOCIAL,
:OLD.DT_PRORROGA,
:OLD.DT_REF_ALT_RETRO,
:OLD.DT_VERIFICACAO,
:OLD.EMPRESA_ATENDENTE,
:OLD.ID_LEI,
:OLD.IND_EF_RETRO_ESOCIAL,
:OLD.INFO_MESMO_MOTIVO,
:OLD.INFO_ONUS,
:OLD.INSCRICAO_CONSELHO,
:OLD.NOME_ATENDENTE,
:OLD.OBSERVACAO_ESOCIAL,
:OLD.PROXIMA_SITUACAO,
:OLD.QTDE_DIAS_AFAST,
:OLD.TEXTO_ASSOCIADO,
:OLD.TP_ACID_TRANSITO_ESOCIAL,
:OLD.UF_CONSELHO,
:OLD.VALOR_BENEF_13SAL,
:OLD.VALOR_BENEF_LIQ,
:OLD.VALOR_BENEF_MENSAL,
:OLD.DATA_PUBLIC
);
GRAVA_MODULO_APOSENT(:NEW.CODIGO,'RHCGED_ALT_SIT_FUN',:NEW.TIPO_CONTRATO, :NEW.CODIGO_EMPRESA, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL );
--COMMIT;--ORA-04092: cannot COMMIT in a trigger

--BEGIN
--SUGESP_MANUTE_ALT_SIT_FUNC_V2 (:OLD.CODIGO_EMPRESA, :OLD.TIPO_CONTRATO, :OLD.CODIGO, :OLD.LOGIN_USUARIO, SYS_CONTEXT ('USERENV', 'OS_USER'));
--END;

END IF; --FIM IF PARA SABER SE Ã‰ INSERT, UPDATE ou DELETE


-------------INICIO-------1Âº - CORRIGIR A DATA FIM PARA ULTIMO REGISTRO SE O MESMO FOR UMA SITUAÃ‡ÃƒO COM controle_folha = 'N'Z
/*
SELECT 
S.CONTROLE_FOLHA, X.data_fim_situacao INTO vCONTROLE_FOLHA_OLD, vDATA_FIM_SITUACAO_OLD
FROM RHCGED_ALT_SIT_FUN X 
LEFT OUTER JOIN RHPARM_SIT_FUNC S ON S.CODIGO = X.cod_sit_funcional
WHERE X.CODIGO_EMPRESA = :OLD.CODIGO_EMPRESA
AND X.TIPO_CONTRATO = :OLD.TIPO_CONTRATO
AND X.CODIGO = :OLD.CODIGO
AND X.DATA_INIC_SITUACAO = --TO_DATE (DATA_INIC_SITUACAO,'DD/MM/YY') > = TO_DATE ('01/01/19','DD/MM/YY') 
(SELECT MAX(A.data_inic_situacao) FROM RHCGED_ALT_SIT_FUN A WHERE A.CODIGO_EMPRESA =  X.CODIGO_EMPRESA AND A.TIPO_CONTRATO = X.TIPO_CONTRATO AND A.CODIGO = X.CODIGO)
ORDER BY DATA_INIC_SITUACAO;

IF vCONTROLE_FOLHA_OLD = 'N' AND vDATA_FIM_SITUACAO_OLD IS NOT NULL THEN
      dbms_output.put_line('LIMPAR DATA FIM'); 
      UPDATE RHCGED_ALT_SIT_FUN SET DATA_FIM_SITUACAO = NULL WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA_OLD  AND TIPO_CONTRATO = vTIPO_CONTRATO_OLD AND CODIGO = vCODIGO_OLD AND DATA_INIC_SITUACAO = vDATA_INIC_SITUACAO_OLD  ;
      COMMIT;
END IF;
*/
-------------FIM-------1Âº - CORRIGIR A DATA FIM PARA ULTIMO REGISTRO SE O MESMO FOR UMA SITUAÃ‡ÃƒO COM controle_folha = 'N'

--------------------------------------------------------------------------------CHAMAR PROCEDURE PARA TODA LOGICA NO NOVO CENARIO TABELA RHPONT_RES_SIT_DIA
--DESATIVADA EM 30/9/19 ATE RESOLVER O PROBLEMA DE NÃO GRAVAR CORRETAMENTE NO CONTRATO
--REATIVADA 4/10/19
select ID into vULT_ID FROM SMARH_INT_PE_ALTSITFUN_AUDITO WHERE ID = (SELECT MAX(ID) FROM SMARH_INT_PE_ALTSITFUN_AUDITO WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO = vCODIGO );
SUGESP_RES_SIT_DIA_V4('ALT_SIT_FUNC', vULT_ID);
--------------------------------------------------------------------------------CHAMAR PROCEDURE PARA TODA LOGICA NO NOVO CENARIO TABELA RHPONT_RES_SIT_DIA

END; --FIM TRIGGER


ALTER TRIGGER "ARTERH"."TR_ALTSITFUN_AUDITO" ENABLE