
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VIEW_RHPBH_ARQUIVO_DUPLA_LOTACAO" ("ID_ARQUIVO", "NUMERO_LINHA", "IDENTIFICADOR_ARQUIVO", "DATA_HORA_GERACAO_ARQUIVO", "TIPO_OPERACAO", "CODIGO_EMPRESA", "CODIGO_OPUS_PAI", "CODIGO_DUPLA_LOTACAO_DE", "DESCRICAO_DE", "ABREVICAO_DE", "CODIGO_DUPLA_LOTACAO_PARA", "DESCRICAO_PARA", "ABREVICAO_PARA", "OPUS_1", "OPUS_2", "OPUS_3", "OPUS_4", "OPUS_5", "OPUS_6", "CODIGO_DUPLA_LOTACAO_DE_1", "CODIGO_DUPLA_LOTACAO_DE_2", "CODIGO_DUPLA_LOTACAO_DE_3", "CODIGO_DUPLA_LOTACAO_DE_4", "CODIGO_DUPLA_LOTACAO_DE_5", "CODIGO_DUPLA_LOTACAO_DE_6", "CODIGO_DUPLA_LOTACAO_PARA_1", "CODIGO_DUPLA_LOTACAO_PARA_2", "CODIGO_DUPLA_LOTACAO_PARA_3", "CODIGO_DUPLA_LOTACAO_PARA_4", "CODIGO_DUPLA_LOTACAO_PARA_5", "CODIGO_DUPLA_LOTACAO_PARA_6") AS 
  SELECT ID_ARQUIVO,
                NUMERO_LINHA,
                IDENTIFICADOR_ARQUIVO,
                DATA_HORA_GERACAO_ARQUIVO,
                TIPO_OPERACAO,
                CODIGO_EMPRESA,
                CODIGO_OPUS_PAI ,
                CODIGO_DUPLA_LOTACAO_DE,
                DESCRICAO_DE ,
                ABREVICAO_DE,
                CODIGO_DUPLA_LOTACAO_PARA,
                DESCRICAO_PARA,
                ABREVICAO_PARA,
                regexp_substr(replace(CODIGO_OPUS_PAI, '..', '. .'),'[^.]+',1,1) AS OPUS_1,
                regexp_substr(replace(CODIGO_OPUS_PAI, '..', '. .'),'[^.]+',1,2) AS OPUS_2,
                regexp_substr(replace(CODIGO_OPUS_PAI, '..', '. .'),'[^.]+',1,3) AS OPUS_3,
                regexp_substr(replace(CODIGO_OPUS_PAI, '..', '. .'),'[^.]+',1,4) AS OPUS_4,
                regexp_substr(replace(CODIGO_OPUS_PAI, '..', '. .'),'[^.]+',1,5) AS OPUS_5,
                regexp_substr(replace(CODIGO_OPUS_PAI, '..', '. .'),'[^.]+',1,6) AS OPUS_6, 
                regexp_substr(replace(CODIGO_DUPLA_LOTACAO_DE, '..', '. .'),'[^.]+',1,1) AS CODIGO_DUPLA_LOTACAO_DE_1,
                regexp_substr(replace(CODIGO_DUPLA_LOTACAO_DE, '..', '. .'),'[^.]+',1,2) AS CODIGO_DUPLA_LOTACAO_DE_2,
                regexp_substr(replace(CODIGO_DUPLA_LOTACAO_DE, '..', '. .'),'[^.]+',1,3) AS CODIGO_DUPLA_LOTACAO_DE_3,
                regexp_substr(replace(CODIGO_DUPLA_LOTACAO_DE, '..', '. .'),'[^.]+',1,4) AS CODIGO_DUPLA_LOTACAO_DE_4,
                regexp_substr(replace(CODIGO_DUPLA_LOTACAO_DE, '..', '. .'),'[^.]+',1,5) AS CODIGO_DUPLA_LOTACAO_DE_5,
                regexp_substr(replace(CODIGO_DUPLA_LOTACAO_DE, '..', '. .'),'[^.]+',1,6) AS CODIGO_DUPLA_LOTACAO_DE_6,
                regexp_substr(replace(CODIGO_DUPLA_LOTACAO_PARA, '..', '. .'),'[^.]+',1,1) AS CODIGO_DUPLA_LOTACAO_PARA_1,
                regexp_substr(replace(CODIGO_DUPLA_LOTACAO_PARA, '..', '. .'),'[^.]+',1,2) AS CODIGO_DUPLA_LOTACAO_PARA_2,
                regexp_substr(replace(CODIGO_DUPLA_LOTACAO_PARA, '..', '. .'),'[^.]+',1,3) AS CODIGO_DUPLA_LOTACAO_PARA_3,
                regexp_substr(replace(CODIGO_DUPLA_LOTACAO_PARA, '..', '. .'),'[^.]+',1,4) AS CODIGO_DUPLA_LOTACAO_PARA_4,
                regexp_substr(replace(CODIGO_DUPLA_LOTACAO_PARA, '..', '. .'),'[^.]+',1,5) AS CODIGO_DUPLA_LOTACAO_PARA_5,
                regexp_substr(replace(CODIGO_DUPLA_LOTACAO_PARA, '..', '. .'),'[^.]+',1,6) AS CODIGO_DUPLA_LOTACAO_PARA_6
                FROM ARTERH.RHPBH_ARQUIVO_DUPLA_LOTACAO