
  CREATE OR REPLACE EDITIONABLE TRIGGER "ARTERH"."TR_RHINTE_ED_IT_CONV_LOG" 
BEFORE INSERT OR UPDATE OR DELETE ON ARTERH.RHINTE_ED_IT_CONV
FOR EACH ROW
 DECLARE
vULT_ID number;
v_DML ARTERH.SUGESP_RHINTE_ED_IT_CONV_LOG.TIPO_DML%TYPE;

    vLOGIN_USUARIO_NEW VARCHAR2(40);
    vLOGIN_USUARIO_OLD VARCHAR2(40);
    vLOGIN_OS_NEW VARCHAR2(40);
    vLOGIN_OS_OLD VARCHAR2(40);
    vLOGIN_NEW VARCHAR2(40);
    vLOGIN_OLD VARCHAR2(40);
--PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
--POPULA VARIAVEIS
vULT_ID := 0;
    vLOGIN_USUARIO_NEW := :NEW.LOGIN_USUARIO;
    vLOGIN_USUARIO_OLD := :OLD.LOGIN_USUARIO;
    vLOGIN_OS_NEW := SYS_CONTEXT ('USERENV', 'OS_USER');
    vLOGIN_OS_OLD := SYS_CONTEXT ('USERENV', 'OS_USER');
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
--------------------------------------------------------------------------INSERT-------------------------------------------------------------------------------------------------------------------------------------------
IF INSERTING THEN
v_DML := 'I';
INSERT INTO ARTERH.SUGESP_RHINTE_ED_IT_CONV_LOG
(
ID,
TIPO_DML,
NEW_CODIGO_CONVERSAO,
NEW_DADO_ORIGEM,
NEW_DADO_DESTINO,
NEW_LOGIN_USUARIO,
DT_ULT_ALTER_USUA
)
VALUES
(
(SELECT MAX(ID)+1 FROM ARTERH.SUGESP_RHINTE_ED_IT_CONV_LOG),
v_DML,
:NEW.CODIGO_CONVERSAO,
:NEW.DADO_ORIGEM,
:NEW.DADO_DESTINO,
vLOGIN_NEW,
SYSDATE
);
--COMMIT;--ORA-04092: cannot COMMIT in a trigger
-------------------------------------------------------------------------UPDATE-------------------------------------------------------------------------------------------------------------------------------------------
ELSIF UPDATING THEN
v_DML := 'U';
INSERT INTO ARTERH.SUGESP_RHINTE_ED_IT_CONV_LOG
(
ID,
TIPO_DML,
NEW_CODIGO_CONVERSAO,
OLD_CODIGO_CONVERSAO,
NEW_DADO_ORIGEM,
OLD_DADO_ORIGEM,
NEW_DADO_DESTINO,
OLD_DADO_DESTINO,
NEW_LOGIN_USUARIO,
OLD_LOGIN_USUARIO,
DT_ULT_ALTER_USUA
)
VALUES
(
(SELECT MAX(ID)+1 FROM ARTERH.SUGESP_RHINTE_ED_IT_CONV_LOG),
v_DML,
:NEW.CODIGO_CONVERSAO,
:OLD.CODIGO_CONVERSAO,
:NEW.DADO_ORIGEM,
:OLD.DADO_ORIGEM,
:NEW.DADO_DESTINO,
:OLD.DADO_DESTINO,
vLOGIN_NEW,
vLOGIN_OLD,
SYSDATE
);
--COMMIT;--ORA-04092: cannot COMMIT in a trigger
--------------------------------------------------------------------------DELETE-------------------------------------------------------------------------------------------------------------------------------------------
ELSIF DELETING THEN
v_DML := 'D';
INSERT INTO ARTERH.SUGESP_RHINTE_ED_IT_CONV_LOG
(
ID,
TIPO_DML,
OLD_CODIGO_CONVERSAO,
OLD_DADO_ORIGEM,
OLD_DADO_DESTINO,
OLD_LOGIN_USUARIO,
DT_ULT_ALTER_USUA
)
VALUES
(
(SELECT MAX(ID)+1 FROM ARTERH.SUGESP_RHINTE_ED_IT_CONV_LOG),
v_DML,
:OLD.CODIGO_CONVERSAO,
:OLD.DADO_ORIGEM,
:OLD.DADO_DESTINO,
vLOGIN_OLD,
SYSDATE
);
--COMMIT;--ORA-04092: cannot COMMIT in a trigger
END IF; --FIM IF PARA SABER SE Ã‰ INSERT, UPDATE ou DELETE
END; --FIM TRIGGER

ALTER TRIGGER "ARTERH"."TR_RHINTE_ED_IT_CONV_LOG" ENABLE