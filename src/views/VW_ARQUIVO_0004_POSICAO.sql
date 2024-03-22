
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_ARQUIVO_0004_POSICAO" ("ID_ARQUIVO", "CODIGO_EMPRESA_ARQUIVO", "SITUACAO_ARQUIVO", "DATA_CARGA", "NUMERO_LINHA", "SITUACAO_LINHA", "LINHA_ORIGINAL", "CODIGO_EMPRESA", "CODIGO_CONTRATO", "CODIGO_FORNECEDOR", "CODIGO_VERBA", "VALOR_VERBA", "CONTADOR", "REFERENCIA_VERBA", "DATA_AUTORIZA", "OPERACAO_IMPORTACAO", "CODIGO_CONSIG_ERRO", "NUMERO_GUIA_IPTU", "CPF", "DATA_HORA_LANCAMENTO", "NUMERO_CARTEIRA") AS 
  select
RHPBH_ARQUIVO.ID_ARQUIVO,
RHPBH_ARQUIVO.CODIGO_EMPRESA AS CODIGO_EMPRESA_ARQUIVO,
RHPBH_ARQUIVO.SITUACAO AS SITUACAO_ARQUIVO,
RHPBH_ARQUIVO.DATA_CARGA,
RHPBH_ARQUIVO_LINHA.NUMERO_LINHA,
RHPBH_ARQUIVO_LINHA.SITUACAO AS SITUACAO_LINHA,
RHPBH_ARQUIVO_LINHA.LINHA AS LINHA_ORIGINAL,
SUBSTR(RHPBH_ARQUIVO_LINHA.LINHA,	1	  ,	10	)	AS	CODIGO_EMPRESA,
SUBSTR(RHPBH_ARQUIVO_LINHA.LINHA,	11	,	10	)	AS	CODIGO_CONTRATO,
SUBSTR(RHPBH_ARQUIVO_LINHA.LINHA,	21	,	10	)	AS	CODIGO_FORNECEDOR,
SUBSTR(RHPBH_ARQUIVO_LINHA.LINHA,	31	,	10	)	AS	CODIGO_VERBA,
SUBSTR(RHPBH_ARQUIVO_LINHA.LINHA,	41	,	15	)	AS	VALOR_VERBA,
SUBSTR(RHPBH_ARQUIVO_LINHA.LINHA,	56	,	 5	)	AS	CONTADOR,
SUBSTR(RHPBH_ARQUIVO_LINHA.LINHA,	61	,	10	)	AS	REFERENCIA_VERBA,
SUBSTR(RHPBH_ARQUIVO_LINHA.LINHA,	71	,	14	)	AS	DATA_AUTORIZA,
SUBSTR(RHPBH_ARQUIVO_LINHA.LINHA,	85	,	 1	)	AS	OPERACAO_IMPORTACAO,
SUBSTR(RHPBH_ARQUIVO_LINHA.LINHA,	86	,	 2	)	AS	CODIGO_CONSIG_ERRO ,
SUBSTR(RHPBH_ARQUIVO_LINHA.LINHA,	88	,	13	)	AS	NUMERO_GUIA_IPTU,
SUBSTR(RHPBH_ARQUIVO_LINHA.LINHA,	101	,	11	)	AS	CPF,
SUBSTR(RHPBH_ARQUIVO_LINHA.LINHA,	112	,	14	)	AS	DATA_HORA_LANCAMENTO,
SUBSTR(RHPBH_ARQUIVO_LINHA.LINHA,	126	,	30	)	AS	NUMERO_CARTEIRA
  from RHPBH_ARQUIVO, RHPBH_ARQUIVO_LINHA
 where RHPBH_ARQUIVO.ID_ARQUIVO = RHPBH_ARQUIVO_LINHA.ID_ARQUIVO
   and RHPBH_ARQUIVO.TIPO_ARQUIVO = '0004'