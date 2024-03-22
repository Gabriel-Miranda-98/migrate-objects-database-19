
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_GIGPES_PESSOAS" ("CODIGO_EMPRESA", "CODIGO_PESSOA", "NOME_PESSOA") AS 
  select codigo_empresa, codigo, nome from rhpess_pessoa
 