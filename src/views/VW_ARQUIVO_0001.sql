
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_ARQUIVO_0001" ("ID_ARQUIVO", "CODIGO_EMPRESA_ARQUIVO", "SITUACAO_ARQUIVO", "DATA_CARGA", "NUMERO_LINHA", "SITUACAO_LINHA", "LINHA_ORIGINAL", "IDENTIFICADOR_ARQUIVO", "DATA_HORA_GERACAO_ARQUIVO", "SEQUENCIAL_REGISTRO", "TIPO_OPERACAO", "CODIGO_EMPRESA", "CODIGO_CONTRATO", "CPF", "REGISTRO_ANS", "CODIGO_BENEFICIO", "CATEGORIA_BENEFICIARIO", "ORDEM_DEPENDENCIA", "MOTIVO_CONCESSAO", "DATA_CONCESSAO", "MOTIVO_CANCELAMENTO", "DATA_CANCELAMENTO", "OBSERVACAO", "NUMERO_CARTEIRA", "NUMERO_PROTOCOLO", "DATA_FIM_EXCECAO_DEPENDENCIA", "EXCECAO_DEPENDENCIA", "DATA_CADASTRAMENTO") AS 
  select
RHPBH_ARQUIVO.ID_ARQUIVO,
RHPBH_ARQUIVO.CODIGO_EMPRESA AS CODIGO_EMPRESA_ARQUIVO,
RHPBH_ARQUIVO.SITUACAO AS SITUACAO_ARQUIVO,
RHPBH_ARQUIVO.DATA_CARGA,
RHPBH_ARQUIVO_LINHA.NUMERO_LINHA,
RHPBH_ARQUIVO_LINHA.SITUACAO AS SITUACAO_LINHA,
RHPBH_ARQUIVO_LINHA.LINHA AS LINHA_ORIGINAL,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 1)	AS	IDENTIFICADOR_ARQUIVO,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 2)	AS	DATA_HORA_GERACAO_ARQUIVO,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 3)	AS	SEQUENCIAL_REGISTRO,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 4)	AS	TIPO_OPERACAO,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 5)	AS	CODIGO_EMPRESA,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 6)	AS	CODIGO_CONTRATO,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 7)	AS	CPF,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 8)	AS	REGISTRO_ANS,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 9)	AS	CODIGO_BENEFICIO,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 10)	AS	CATEGORIA_BENEFICIARIO,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 11)	AS	ORDEM_DEPENDENCIA,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 12)	AS	MOTIVO_CONCESSAO,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 13)	AS	DATA_CONCESSAO,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 14)	AS	MOTIVO_CANCELAMENTO,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 15)	AS	DATA_CANCELAMENTO,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 16)	AS	OBSERVACAO,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 17)	AS	NUMERO_CARTEIRA,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 18)	AS	NUMERO_PROTOCOLO,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 19)	AS	DATA_FIM_EXCECAO_DEPENDENCIA,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 20)	AS	EXCECAO_DEPENDENCIA,
regexp_substr(REPLACE(RHPBH_ARQUIVO_LINHA.LINHA,';;','; ;'), '[^;]+', 1, 21)	AS	DATA_CADASTRAMENTO
  from RHPBH_ARQUIVO, RHPBH_ARQUIVO_LINHA
 where RHPBH_ARQUIVO.ID_ARQUIVO = RHPBH_ARQUIVO_LINHA.ID_ARQUIVO
   and RHPBH_ARQUIVO.TIPO_ARQUIVO = '0001'