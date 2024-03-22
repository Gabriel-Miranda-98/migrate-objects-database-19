
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."ARTERH_SIATU_ITBI" ("ANO_MES_REFERENCIA", "CODIGO_EMPRESA", "TIPO_CONTRATO", "CODIGO", "NOME", "COD_UNIDADE1", "COD_UNIDADE2", "COD_UNIDADE3", "COD_UNIDADE4", "COD_UNIDADE5", "COD_UNIDADE6", "DESC_UNIDADE", "ABREVIACAO", "DATA_ADMISSAO", "SITUACAO_FUNCIONAL", "DESC_SIT_FUNC", "DATA_RESCISAO") AS 
  SELECT
RHPESS_CONTRATO.ANO_MES_REFERENCIA,
RHPESS_CONTRATO.CODIGO_EMPRESA,
RHPESS_CONTRATO.TIPO_CONTRATO,
RHPESS_CONTRATO.CODIGO,
RHPESS_CONTRATO.NOME,
RHPESS_CONTRATO.COD_UNIDADE1,
RHPESS_CONTRATO.COD_UNIDADE2,
RHPESS_CONTRATO.COD_UNIDADE3,
RHPESS_CONTRATO.COD_UNIDADE4,
RHPESS_CONTRATO.COD_UNIDADE5,
RHPESS_CONTRATO.COD_UNIDADE6,
RHORGA_UNIDADE.DESCRICAO DESC_UNIDADE,
RHORGA_UNIDADE.ABREVIACAO,
RHPESS_CONTRATO.DATA_ADMISSAO,
RHPESS_CONTRATO.SITUACAO_FUNCIONAL,
RHPARM_SIT_FUNC.DESCRICAO DESC_SIT_FUNC,
RHPESS_CONTRATO.DATA_RESCISAO
FROM
RHPESS_CONTRATO,
RHORGA_UNIDADE,
RHPARM_SIT_FUNC
WHERE
( RHPESS_CONTRATO.CODIGO_EMPRESA = RHORGA_UNIDADE.CODIGO_EMPRESA ) and
( RHPESS_CONTRATO.COD_UNIDADE1 = RHORGA_UNIDADE.COD_UNIDADE1 ) and
( RHPESS_CONTRATO.COD_UNIDADE2 = RHORGA_UNIDADE.COD_UNIDADE2 ) and
( RHPESS_CONTRATO.COD_UNIDADE3 = RHORGA_UNIDADE.COD_UNIDADE3 ) and
( RHPESS_CONTRATO.COD_UNIDADE4 = RHORGA_UNIDADE.COD_UNIDADE4 ) and
( RHPESS_CONTRATO.COD_UNIDADE5 = RHORGA_UNIDADE.COD_UNIDADE5 ) and
( RHPESS_CONTRATO.COD_UNIDADE6 = RHORGA_UNIDADE.COD_UNIDADE6 ) and
( RHPESS_CONTRATO.SITUACAO_FUNCIONAL = RHPARM_SIT_FUNC.CODIGO ) and
( RHPESS_CONTRATO.CODIGO_EMPRESA = '0001' ) AND
 RHPESS_CONTRATO.ANO_MES_REFERENCIA = (select max (CONTRATO.ano_mes_referencia)
                           	       from rhpess_contrato CONTRATO where CONTRATO.codigo = RHPESS_CONTRATO.codigo and
                                       CONTRATO.codigo_empresa = RHPESS_CONTRATO.codigo_empresa and
                                       CONTRATO.tipo_contrato = RHPESS_CONTRATO.tipo_contrato) 
/*situaÃ§Ãies funcionais que possuem o controle folha N- Normal, F - FÃŠrias e A - admitido*/
AND RHPARM_SIT_FUNC.CONTROLE_FOLHA IN ('N','F','A') 
AND RHPESS_CONTRATO.DATA_RESCISAO IS NULL