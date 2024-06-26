
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_PS_ARQUIVO_BENEFICIARIO" ("TIPO_ARQUIVO", "DATA_IMPORTACAO", "NUMERO_LINHA", "LINHA_ARQUIVO", "TIPO_OPERACAO", "CODIGO_EMPRESA", "CODIGO_CONTRATO", "CPF", "NOME", "DATA_NASCIMENTO", "CODIGO_SEXO", "CODIGO_TIPO_RELACIONAMENTO", "CODIGO_ESTADO_CIVIL", "IDENTIDADE", "NOME_DA_MAE", "CODIGO_TIPO_LOGRADOURO", "ENDERECO", "NUMERO", "COMPLEMENTO", "BAIRRO", "CODIGO_MUNICIPIO", "UF", "CEP", "TELEFONE_FIXO", "TELEFONE_CELULAR", "DATA_CADASTRAMENTO") AS 
  select RHPBH_PS_IMPORTACAO_ARQUIVO.TIPO_ARQUIVO,
       RHPBH_PS_IMPORTACAO_ARQUIVO.DATA_IMPORTACAO,
       RHPBH_PS_IMPORTACAO_ARQUIVO.NUMERO_LINHA,
       LINHA_ARQUIVO,
       SUBSTR(LINHA_ARQUIVO, 001,01)  AS TIPO_OPERACAO,
       SUBSTR(LINHA_ARQUIVO, 003,04)  AS CODIGO_EMPRESA,
       LPAD(TRIM(SUBSTR(LINHA_ARQUIVO, 008,15)), 15,'0')  AS CODIGO_CONTRATO,
       SUBSTR(LINHA_ARQUIVO, 024,11)  AS CPF,
       SUBSTR(LINHA_ARQUIVO, 036,60)  AS NOME,
       SUBSTR(LINHA_ARQUIVO, 097,08)  AS DATA_NASCIMENTO,
       SUBSTR(LINHA_ARQUIVO, 106,04)  AS CODIGO_SEXO,
       SUBSTR(LINHA_ARQUIVO, 111,04)  AS CODIGO_TIPO_RELACIONAMENTO,
       SUBSTR(LINHA_ARQUIVO, 116,04)  AS CODIGO_ESTADO_CIVIL,
       SUBSTR(LINHA_ARQUIVO, 121,20)  AS IDENTIDADE,
       SUBSTR(LINHA_ARQUIVO, 142,60)  AS NOME_DA_MAE,
       SUBSTR(LINHA_ARQUIVO, 203,04)  AS CODIGO_TIPO_LOGRADOURO,
       SUBSTR(LINHA_ARQUIVO, 208,40)  AS ENDERECO,
       SUBSTR(LINHA_ARQUIVO, 249,10)  AS NUMERO,
       SUBSTR(LINHA_ARQUIVO, 260,40)  AS COMPLEMENTO,
       SUBSTR(LINHA_ARQUIVO, 301,40)  AS BAIRRO,
       SUBSTR(LINHA_ARQUIVO, 342,07)  AS CODIGO_MUNICIPIO,
       SUBSTR(LINHA_ARQUIVO, 350,02)  AS UF,
       SUBSTR(LINHA_ARQUIVO, 353,08)  AS CEP,
       SUBSTR(LINHA_ARQUIVO, 362,10)  AS TELEFONE_FIXO,
       SUBSTR(LINHA_ARQUIVO, 373,11)  AS TELEFONE_CELULAR,
       SUBSTR(LINHA_ARQUIVO, 385,14)  AS DATA_CADASTRAMENTO
  from RHPBH_PS_IMPORTACAO_ARQUIVO
 where TIPO_ARQUIVO = '0002'

 