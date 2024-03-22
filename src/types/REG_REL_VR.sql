
  CREATE OR REPLACE EDITIONABLE TYPE "ARTERH"."REG_REL_VR" as object
(
  data_referencia_folha DATE,
  data_inicial_afastamento DATE,
  data_final_afastamento DATE,
  codigo_empresa CHAR(4),
  tipo_contrato CHAR(4),
  codigo_contrato CHAR(15),
  nome CHAR(60),
  codigo_unidade VARCHAR2(1000),
  descricao_unidade VARCHAR2(1000),
  qtde_afastamentos NUMBER,
  total_descontos_existentes NUMBER(15,2),
  total_vencimento NUMBER(15,2),
  quantidade_vales_por_dia NUMBER,
  valor_vales_por_dia NUMBER(15,2),
  ano NUMBER,
  mes NUMBER,
  total_valor_recebido_vale NUMBER(15,2)
)

