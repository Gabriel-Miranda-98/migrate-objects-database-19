
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VIEW_RHPBH_VALE_TRANSPORTE_OTIMO" ("NRO_LINHA", "MATRICULA", "CARTAO", "STATUS_USUARIO", "STATUS_TIPO", "STATUS_CARTAO") AS 
  SELECT
NRO_LINHA,
LPAD(regexp_substr(REPLACE(CONTEUDO,';;','; ;'), '[^;]+', 1, 1),15,0)	AS	MATRICULA,
regexp_substr(REPLACE(CONTEUDO,';;','; ;'), '[^;]+', 1, 2)	AS	CARTAO,
UPPER(regexp_substr(REPLACE(CONTEUDO,';;','; ;'), '[^;]+', 1, 3))	AS	status_usuario,
UPPER(regexp_substr(REPLACE(CONTEUDO,';;','; ;'), '[^;]+', 1, 4))	AS	STATUS_TIPO,
DECODE(UPPER(regexp_substr(REPLACE(CONTEUDO,';;','; ;'), '[^;]+', 1, 5)),'ATIVO',1 ,'APAGADO',0)	AS	STATUS_CARTAO
FROM
    ARTERH.RHPBH_APOIO_IMPORTACAO_ARQUIVO_VALE
ORDER BY NRO_LINHA,MATRICULA