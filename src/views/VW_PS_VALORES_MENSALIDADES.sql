
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_PS_VALORES_MENSALIDADES" ("ANO_MES_REFERENCIA", "PLANO", "CODIGO_PLANO", "DESCRICAO_PLANO", "IDENTIFICADOR_FAIXA_ETARIA", "FAIXA_ETARIA", "LIMITE_INFERIOR_FAIXA_ETARIA", "LIMITE_SUPERIOR_FAIXA_ETARIA", "VALOR_MENSALIDADE") AS 
  select ANO_MES_REFERENCIA, PLANO, CODIGO_PLANO, DESCRICAO_PLANO,
       IDENTIFICADOR_FAIXA_ETARIA, FAIXA_ETARIA, LIMITE_INFERIOR_FAIXA_ETARIA, LIMITE_SUPERIOR_FAIXA_ETARIA,
       MAX(NVL(VALOR_MENSALIDADE,0.00)) AS VALOR_MENSALIDADE
  from VW_PS_VALORES group by ANO_MES_REFERENCIA, PLANO, CODIGO_PLANO, DESCRICAO_PLANO,
       IDENTIFICADOR_FAIXA_ETARIA, FAIXA_ETARIA, LIMITE_INFERIOR_FAIXA_ETARIA, LIMITE_SUPERIOR_FAIXA_ETARIA
       order by ANO_MES_REFERENCIA, PLANO, LIMITE_INFERIOR_FAIXA_ETARIA
