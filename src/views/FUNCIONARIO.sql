
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."FUNCIONARIO" ("CODIGO", "DATA_ADMISSAO", "NOME", "DATA_NASCIMENTO") AS 
  select rhpess_contrato.codigo, rhpess_contrato.data_admissao,
rhpess_pessoa.nome,
rhpess_pessoa.data_nascimento
from rhpess_contrato, rhpess_pessoa
where (rhpess_contrato.codigo_empresa = rhpess_pessoa.codigo_empresa and
rhpess_contrato.codigo_pessoa = rhpess_pessoa.codigo) WITH READ ONLY
 