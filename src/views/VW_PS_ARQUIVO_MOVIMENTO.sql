
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_PS_ARQUIVO_MOVIMENTO" ("TIPO_ARQUIVO", "DATA_IMPORTACAO", "NUMERO_LINHA", "LINHA_ARQUIVO", "CODIGO_EMPRESA", "CODIGO_CONTRATO", "CODIGO_FORNECEDOR", "CODIGO_VERBA", "VALOR_VERBA", "CONTADOR", "REFERENCIA_VERBA", "DATA_AUTORIZA", "OPERACAO_IMPORTACAO", "CODIGO_CONSIG_ERRO", "NUMERO_GUIA_IPTU", "CPF", "DATA_HORA_SOLICITACAO", "NUMERO_CARTEIRA") AS 
  select RHPBH_PS_IMPORTACAO_ARQUIVO.TIPO_ARQUIVO,
       RHPBH_PS_IMPORTACAO_ARQUIVO.DATA_IMPORTACAO,
       RHPBH_PS_IMPORTACAO_ARQUIVO.NUMERO_LINHA,
       LINHA_ARQUIVO,
       SUBSTR(LINHA_ARQUIVO, 07,04)  AS CODIGO_EMPRESA,
       LPAD(TRIM(SUBSTR(LINHA_ARQUIVO, 011,10)), 15,'0')  AS CODIGO_CONTRATO,
       LPAD(TRIM(SUBSTR(LINHA_ARQUIVO, 021,10)), 15,'0')  AS CODIGO_FORNECEDOR,
       SUBSTR(LINHA_ARQUIVO, 37,04)  AS CODIGO_VERBA,
       SUBSTR(LINHA_ARQUIVO, 41,15)  AS VALOR_VERBA,
       SUBSTR(LINHA_ARQUIVO, 56,05)  AS CONTADOR,
       SUBSTR(LINHA_ARQUIVO, 61,10)  AS REFERENCIA_VERBA,
       SUBSTR(LINHA_ARQUIVO, 71,14)  AS DATA_AUTORIZA,
       SUBSTR(LINHA_ARQUIVO, 85,01)  AS OPERACAO_IMPORTACAO,
       SUBSTR(LINHA_ARQUIVO, 86,02)  AS CODIGO_CONSIG_ERRO ,
       SUBSTR(LINHA_ARQUIVO, 88,13)  AS NUMERO_GUIA_IPTU,
       SUBSTR(LINHA_ARQUIVO, 101,11)  AS CPF,
       SUBSTR(LINHA_ARQUIVO, 112,14)  AS DATA_HORA_SOLICITACAO,
       TRIM(SUBSTR(LINHA_ARQUIVO, 126,30))  AS NUMERO_CARTEIRA
  from RHPBH_PS_IMPORTACAO_ARQUIVO
 where TIPO_ARQUIVO = '0003'

 