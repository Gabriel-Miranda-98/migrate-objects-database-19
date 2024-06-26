
  CREATE OR REPLACE EDITIONABLE TRIGGER "ARTERH"."TR_RHPESS_ENDERECO_P_AUDIT" 
AFTER UPDATE OR DELETE OR INSERT ON "ARTERH"."RHPESS_ENDERECO_P" 
FOR EACH ROW
 DECLARE
v_DML RHPBH_RHPESS_ENDERECO_P_AUDIT.TIPO_DML%TYPE;
BEGIN
IF INSERTING THEN
v_DML := 'I';
INSERT INTO RHPBH_RHPESS_ENDERECO_P_AUDIT
(
TIPO_DML,
CODIGO_EMPRESA,
CODIGO_PESSOA,
TIPO_LOGRADOURO,
ENDERECO,
NUMERO,
COMPLEMENTO,
BAIRRO,
MUNICIPIO,
AREA,
DISTRITO,
UF,
PROVINCIA,
ZONA,
PAIS,
CEP,
CAIXA_POSTAL,
TELEFONE,
FAX,
TELEX,
ENDER_ELETRONICO,
C_LIVRE_DESCR01,
C_LIVRE_DESCR02,
LOGIN_USUARIO,
DT_ULT_ALTER_USUA,
TEXTO_ASSOCIADO,
C_LIVRE_DATA01,
C_LIVRE_DATA02,
C_LIVRE_SELEC01,
C_LIVRE_SELEC02,
C_LIVRE_OPCAO01,
C_LIVRE_OPCAO02
)
VALUES
(
v_DML,
:NEW.CODIGO_EMPRESA,
:NEW.CODIGO_PESSOA,
:NEW.TIPO_LOGRADOURO,
:NEW.ENDERECO,
:NEW.NUMERO,
:NEW.COMPLEMENTO,
:NEW.BAIRRO,
:NEW.MUNICIPIO,
:NEW.AREA,
:NEW.DISTRITO,
:NEW.UF,
:NEW.PROVINCIA,
:NEW.ZONA,
:NEW.PAIS,
:NEW.CEP,
:NEW.CAIXA_POSTAL,
:NEW.TELEFONE,
:NEW.FAX,
:NEW.TELEX,
:NEW.ENDER_ELETRONICO,
:NEW.C_LIVRE_DESCR01,
:NEW.C_LIVRE_DESCR02,
USER,
SYSDATE,
:NEW.TEXTO_ASSOCIADO,
:NEW.C_LIVRE_DATA01,
:NEW.C_LIVRE_DATA02,
:NEW.C_LIVRE_SELEC01,
:NEW.C_LIVRE_SELEC02,
:NEW.C_LIVRE_OPCAO01,
:NEW.C_LIVRE_OPCAO02
);
END IF;

IF DELETING THEN
v_DML := 'D';
INSERT INTO RHPBH_RHPESS_ENDERECO_P_AUDIT
(
TIPO_DML,
CODIGO_EMPRESA,
CODIGO_PESSOA,
TIPO_LOGRADOURO,
ENDERECO,
NUMERO,
COMPLEMENTO,
BAIRRO,
MUNICIPIO,
AREA,
DISTRITO,
UF,
PROVINCIA,
ZONA,
PAIS,
CEP,
CAIXA_POSTAL,
TELEFONE,
FAX,
TELEX,
ENDER_ELETRONICO,
C_LIVRE_DESCR01,
C_LIVRE_DESCR02,
LOGIN_USUARIO,
DT_ULT_ALTER_USUA,
TEXTO_ASSOCIADO,
C_LIVRE_DATA01,
C_LIVRE_DATA02,
C_LIVRE_SELEC01,
C_LIVRE_SELEC02,
C_LIVRE_OPCAO01,
C_LIVRE_OPCAO02
)
VALUES
(
v_DML,
:OLD.CODIGO_EMPRESA,
:OLD.CODIGO_PESSOA,
:OLD.TIPO_LOGRADOURO,
:OLD.ENDERECO,
:OLD.NUMERO,
:OLD.COMPLEMENTO,
:OLD.BAIRRO,
:OLD.MUNICIPIO,
:OLD.AREA,
:OLD.DISTRITO,
:OLD.UF,
:OLD.PROVINCIA,
:OLD.ZONA,
:OLD.PAIS,
:OLD.CEP,
:OLD.CAIXA_POSTAL,
:OLD.TELEFONE,
:OLD.FAX,
:OLD.TELEX,
:OLD.ENDER_ELETRONICO,
:OLD.C_LIVRE_DESCR01,
:OLD.C_LIVRE_DESCR02,
USER,
SYSDATE,
:OLD.TEXTO_ASSOCIADO,
:OLD.C_LIVRE_DATA01,
:OLD.C_LIVRE_DATA02,
:OLD.C_LIVRE_SELEC01,
:OLD.C_LIVRE_SELEC02,
:OLD.C_LIVRE_OPCAO01,
:OLD.C_LIVRE_OPCAO02
);
END IF;

IF UPDATING THEN
v_DML := 'U';
INSERT INTO RHPBH_RHPESS_ENDERECO_P_AUDIT
(
TIPO_DML,
CODIGO_EMPRESA,
CODIGO_PESSOA,
TIPO_LOGRADOURO,
ENDERECO,
NUMERO,
COMPLEMENTO,
BAIRRO,
MUNICIPIO,
AREA,
DISTRITO,
UF,
PROVINCIA,
ZONA,
PAIS,
CEP,
CAIXA_POSTAL,
TELEFONE,
FAX,
TELEX,
ENDER_ELETRONICO,
C_LIVRE_DESCR01,
C_LIVRE_DESCR02,
LOGIN_USUARIO,
DT_ULT_ALTER_USUA,
TEXTO_ASSOCIADO,
C_LIVRE_DATA01,
C_LIVRE_DATA02,
C_LIVRE_SELEC01,
C_LIVRE_SELEC02,
C_LIVRE_OPCAO01,
C_LIVRE_OPCAO02
)
VALUES
(
v_DML,
:OLD.CODIGO_EMPRESA,
:OLD.CODIGO_PESSOA,
:OLD.TIPO_LOGRADOURO,
:OLD.ENDERECO,
:OLD.NUMERO,
:OLD.COMPLEMENTO,
:OLD.BAIRRO,
:OLD.MUNICIPIO,
:OLD.AREA,
:OLD.DISTRITO,
:OLD.UF,
:OLD.PROVINCIA,
:OLD.ZONA,
:OLD.PAIS,
:OLD.CEP,
:OLD.CAIXA_POSTAL,
:OLD.TELEFONE,
:OLD.FAX,
:OLD.TELEX,
:OLD.ENDER_ELETRONICO,
:OLD.C_LIVRE_DESCR01,
:OLD.C_LIVRE_DESCR02,
:NEW.LOGIN_USUARIO,
:NEW.DT_ULT_ALTER_USUA,
:OLD.TEXTO_ASSOCIADO,
:OLD.C_LIVRE_DATA01,
:OLD.C_LIVRE_DATA02,
:OLD.C_LIVRE_SELEC01,
:OLD.C_LIVRE_SELEC02,
:OLD.C_LIVRE_OPCAO01,
:OLD.C_LIVRE_OPCAO02
);

END IF;
END;




ALTER TRIGGER "ARTERH"."TR_RHPESS_ENDERECO_P_AUDIT" ENABLE