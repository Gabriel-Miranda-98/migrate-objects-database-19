
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_PS_ARQUIVO_CONCESSAO" ("TIPO_ARQUIVO", "DATA_IMPORTACAO", "NUMERO_LINHA", "LINHA_ARQUIVO", "TIPO_OPERACAO", "CODIGO_EMPRESA", "CODIGO_CONTRATO", "CPF", "REGISTRO_ANS", "CODIGO_BENEFICIO", "CATEGORIA_BENEFICIARIO", "ORDEM_DEPENDENCIA", "MOTIVO_CONCESSAO", "DATA_CONCESSAO", "MOTIVO_CANCELAMENTO", "DATA_CANCELAMENTO", "OBSERVACAO", "NUMERO_CARTEIRA", "NUMERO_PROTOCOLO", "DATA_FIM_EXCECAO_DEPENDENCIA", "EXCECAO_DEPENDENCIA", "DATA_CADASTRAMENTO") AS 
  select RHPBH_PS_IMPORTACAO_ARQUIVO.TIPO_ARQUIVO,
       RHPBH_PS_IMPORTACAO_ARQUIVO.DATA_IMPORTACAO,
       RHPBH_PS_IMPORTACAO_ARQUIVO.NUMERO_LINHA,
       LINHA_ARQUIVO,
       SUBSTR(LINHA_ARQUIVO, 001,01)  AS TIPO_OPERACAO,
       SUBSTR(LINHA_ARQUIVO, 003,04)  AS CODIGO_EMPRESA,
       LPAD(TRIM(SUBSTR(LINHA_ARQUIVO, 008,15)), 15,'0')  AS CODIGO_CONTRATO,
       SUBSTR(LINHA_ARQUIVO, 024,11)  AS CPF,
       SUBSTR(LINHA_ARQUIVO, 036,15)  AS REGISTRO_ANS,
       SUBSTR(LINHA_ARQUIVO, 052,15)  AS CODIGO_BENEFICIO,
       SUBSTR(LINHA_ARQUIVO, 068,04)  AS CATEGORIA_BENEFICIARIO,
       SUBSTR(LINHA_ARQUIVO, 073,02)  AS ORDEM_DEPENDENCIA,
       SUBSTR(LINHA_ARQUIVO, 076,04)  AS MOTIVO_CONCESSAO,
       SUBSTR(LINHA_ARQUIVO, 081,08)  AS DATA_CONCESSAO,
       SUBSTR(LINHA_ARQUIVO, 090,04)  AS MOTIVO_CANCELAMENTO,
       SUBSTR(LINHA_ARQUIVO, 095,08)  AS DATA_CANCELAMENTO,
       SUBSTR(LINHA_ARQUIVO, 104,60)  AS OBSERVACAO,
       TRIM(SUBSTR(LINHA_ARQUIVO, 165,30))  AS NUMERO_CARTEIRA,
       SUBSTR(LINHA_ARQUIVO, 196,30)  AS NUMERO_PROTOCOLO,
       SUBSTR(LINHA_ARQUIVO, 227,08)  AS DATA_FIM_EXCECAO_DEPENDENCIA,
       SUBSTR(LINHA_ARQUIVO, 236,01)  AS EXCECAO_DEPENDENCIA,
       SUBSTR(LINHA_ARQUIVO, 238,14)  AS DATA_CADASTRAMENTO
  from RHPBH_PS_IMPORTACAO_ARQUIVO
 where TIPO_ARQUIVO = '0001'

 