
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VIEW_SIGBASES_CADASTRO_ESCALA" ("CODIGO_ESCALA", "DESCRICAO_ESCALA", "ABREVIACAO", "ULTIMA_ALTERACAO") AS 
  SELECT CODIGO AS CODIGO_ESCALA, DESCRICAO AS DESCRICAO_ESCALA, ABREVIACAO, DT_ULT_ALTER_USUA AS ULTIMA_ALTERACAO FROM ARTERH.RHPONT_ESCALA WHERE DATA_EXTINCAO IS NULL and codigo_empresa='0001'