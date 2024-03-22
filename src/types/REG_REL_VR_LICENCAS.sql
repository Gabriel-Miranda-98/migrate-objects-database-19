
  CREATE OR REPLACE EDITIONABLE TYPE "ARTERH"."REG_REL_VR_LICENCAS" as object
(
  codigo_empresa CHAR(4),
  tipo_contrato CHAR(4),
  codigo_contrato CHAR(15),
  ano NUMBER(4),
  mes NUMBER(2),
  afastamentos NUMBER,
  valor_recebido NUMBER(15,2)
)

