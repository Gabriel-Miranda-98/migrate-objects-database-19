
  CREATE OR REPLACE EDITIONABLE TRIGGER "PONTO_ELETRONICO"."TR_ARTERH_SIOM_LOG" 
AFTER INSERT OR UPDATE OR DELETE ON  PONTO_ELETRONICO.ARTERH_SIOM_LOG
FOR EACH ROW
 DECLARE
v_DML PONTO_ELETRONICO.ARTERH_SIOM_LOG.TIPO_DML%TYPE;

BEGIN


----INICIO----------------------------------------------------------------INSERT
IF INSERTING THEN
v_DML := 'I';
INSERT INTO ARTERH_SIOM_LOG
(ID,
TIPO_DML,
ID_ENDERECO_CORPORATIVO,
DESCRICAO_UNIDADE,
CODIGO_OPUS,
LATITUDE,
LONGITUDE,
DATA_CARGA,
DATA_DESATIVACAO,
LOGRADOURO,
TIPO_LOGRADOURO,
NUMERO,
LETRA_IMOVEL,
BAIRRO,
CODIGO_MUNICIPIO,
DESCRICAO_MUNICIPIO,
CEP,
UF,
DT_ENVIADO_ARTE,
COORD_X,
COORD_Y,
CODIGO_EMPRESA,
INTEGRADO,
CODIGO_ARTE,
REGIONAL,
CODIGO_REGIONAL,
DATA_DML
)
VALUES
(
(SELECT MAX(ID)+1 FROM ARTERH_SDM_LOG),
v_DML,
:NEW.ID_ENDERECO_CORPORATIVO,
:NEW.DESCRICAO_UNIDADE,
:NEW.CODIGO_OPUS,
:NEW.LATITUDE,
:NEW.LONGITUDE,
:NEW.DATA_CARGA,
:NEW.DATA_DESATIVACAO,
:NEW.LOGRADOURO,
:NEW.TIPO_LOGRADOURO,
:NEW.NUMERO,
:NEW.LETRA_IMOVEL,
:NEW.BAIRRO,
:NEW.CODIGO_MUNICIPIO,
:NEW.DESCRICAO_MUNICIPIO,
:NEW.CEP,
:NEW.UF,
:NEW.DT_ENVIADO_ARTE,
:NEW.COORD_X,
:NEW.COORD_Y,
:NEW.CODIGO_EMPRESA,
:NEW.INTEGRADO,
:NEW.CODIGO_ARTE,
:NEW.REGIONAL,
:NEW.CODIGO_REGIONAL,
SYSDATE
);
----FIM-------------------------------------------------------------------INSERT




----INICIO---------------------------------------------------------------UPDATE
ELSIF (UPDATING)THEN 
v_DML := 'U';
INSERT INTO ARTERH_SIOM_LOG
(ID,
TIPO_DML,
ID_ENDERECO_CORPORATIVO,
DESCRICAO_UNIDADE,
CODIGO_OPUS,
LATITUDE,
LONGITUDE,
DATA_CARGA,
DATA_DESATIVACAO,
LOGRADOURO,
TIPO_LOGRADOURO,
NUMERO,
LETRA_IMOVEL,
BAIRRO,
CODIGO_MUNICIPIO,
DESCRICAO_MUNICIPIO,
CEP,
UF,
DT_ENVIADO_ARTE,
COORD_X,
COORD_Y,
CODIGO_EMPRESA,
INTEGRADO,
CODIGO_ARTE,
REGIONAL,
CODIGO_REGIONAL,
DATA_DML
)
VALUES
(
(SELECT MAX(ID)+1 FROM ARTERH_SDM_LOG),
v_DML,
:NEW.ID_ENDERECO_CORPORATIVO,
:NEW.DESCRICAO_UNIDADE,
:NEW.CODIGO_OPUS,
:NEW.LATITUDE,
:NEW.LONGITUDE,
:NEW.DATA_CARGA,
:NEW.DATA_DESATIVACAO,
:NEW.LOGRADOURO,
:NEW.TIPO_LOGRADOURO,
:NEW.NUMERO,
:NEW.LETRA_IMOVEL,
:NEW.BAIRRO,
:NEW.CODIGO_MUNICIPIO,
:NEW.DESCRICAO_MUNICIPIO,
:NEW.CEP,
:NEW.UF,
:NEW.DT_ENVIADO_ARTE,
:NEW.COORD_X,
:NEW.COORD_Y,
:NEW.CODIGO_EMPRESA,
:NEW.INTEGRADO,
:NEW.CODIGO_ARTE,
:NEW.REGIONAL,
:NEW.CODIGO_REGIONAL,
SYSDATE
);
-----FIM--  --------------------------------------------------------------UPDATE



---------INICIO-----------------------------------------------------------DELETE
ELSIF DELETING THEN
v_DML := 'D';
INSERT INTO ARTERH_SIOM_LOG
(ID,
TIPO_DML,
ID_ENDERECO_CORPORATIVO,
DESCRICAO_UNIDADE,
CODIGO_OPUS,
LATITUDE,
LONGITUDE,
DATA_CARGA,
DATA_DESATIVACAO,
LOGRADOURO,
TIPO_LOGRADOURO,
NUMERO,
LETRA_IMOVEL,
BAIRRO,
CODIGO_MUNICIPIO,
DESCRICAO_MUNICIPIO,
CEP,
UF,
DT_ENVIADO_ARTE,
COORD_X,
COORD_Y,
CODIGO_EMPRESA,
INTEGRADO,
CODIGO_ARTE,
REGIONAL,
CODIGO_REGIONAL,
DATA_DML
)
VALUES
(
(SELECT MAX(ID)+1 FROM ARTERH_SDM_LOG),
v_DML,
:OLD.ID_ENDERECO_CORPORATIVO,
:OLD.DESCRICAO_UNIDADE,
:OLD.CODIGO_OPUS,
:OLD.LATITUDE,
:OLD.LONGITUDE,
:OLD.DATA_CARGA,
:OLD.DATA_DESATIVACAO,
:OLD.LOGRADOURO,
:OLD.TIPO_LOGRADOURO,
:OLD.NUMERO,
:OLD.LETRA_IMOVEL,
:OLD.BAIRRO,
:OLD.CODIGO_MUNICIPIO,
:OLD.DESCRICAO_MUNICIPIO,
:OLD.CEP,
:OLD.UF,
:OLD.DT_ENVIADO_ARTE,
:OLD.COORD_X,
:OLD.COORD_Y,
:OLD.CODIGO_EMPRESA,
:OLD.INTEGRADO,
:OLD.CODIGO_ARTE,
:OLD.REGIONAL,
:OLD.CODIGO_REGIONAL,
SYSDATE
);
---------FIM--------------------------------------------------------------DELETE

END IF;


END;

--sinonimo
--CREATE OR REPLACE SYNONYM ARTERHUSR.TR_ARTERH_SIOM_LOG  FOR PONTO_ELETRONICO.TR_ARTERH_SIOM_LOG ;
--CREATE OR REPLACE SYNONYM INPR003374.TR_ARTERH_SIOM_LOG FOR PONTO_ELETRONICO.TR_ARTERH_SIOM_LOG ;
--CREATE OR REPLACE SYNONYM PB003553.TR_ARTERH_SIOM_LOG FOR PONTO_ELETRONICO.TR_ARTERH_SIOM_LOG ;


ALTER TRIGGER "PONTO_ELETRONICO"."TR_ARTERH_SIOM_LOG" ENABLE