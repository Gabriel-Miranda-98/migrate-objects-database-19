
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_PS_VALORES_TABELA_VALORES" ("ANO_MES_REFERENCIA", "ANO_MES_REF_PLANO", "ANO_MES_REF_FAIXA_SALARIAL", "ANO_MES_REF_FAIXA_ETARIA", "FAIXA_SALARIAL", "LIMITE_INFERIOR_FAIXA_SALARIAL", "LIMITE_SUPERIOR_FAIXA_SALARIAL", "FAIXA_ETARIA", "LIMITE_INFERIOR_FAIXA_ETARIA", "LIMITE_SUPERIOR_FAIXA_ETARIA", "PLANO_1", "PLANO_2", "PLANO_3", "PLANO_4", "PLANO_5", "PLANO_6", "PLANO_7", "PLANO_8", "PLANO_1_SUBSIDIO", "PLANO_2_SUBSIDIO", "PLANO_3_SUBSIDIO", "PLANO_4_SUBSIDIO", "PLANO_5_SUBSIDIO", "PLANO_6_SUBSIDIO", "PLANO_7_SUBSIDIO", "PLANO_8_SUBSIDIO", "PLANO_1_SUBSIDIO_DEP", "PLANO_2_SUBSIDIO_DEP", "PLANO_3_SUBSIDIO_DEP", "PLANO_4_SUBSIDIO_DEP", "PLANO_5_SUBSIDIO_DEP", "PLANO_6_SUBSIDIO_DEP", "PLANO_7_SUBSIDIO_DEP", "PLANO_8_SUBSIDIO_DEP", "PLANO_1_DESCRICAO", "PLANO_2_DESCRICAO", "PLANO_3_DESCRICAO", "PLANO_4_DESCRICAO", "PLANO_5_DESCRICAO", "PLANO_6_DESCRICAO", "PLANO_7_DESCRICAO", "PLANO_8_DESCRICAO") AS 
  select ANO_MES_REFERENCIA, ANO_MES_REF_PLANO, ANO_MES_REF_FAIXA_SALARIAL, ANO_MES_REF_FAIXA_ETARIA,
       FAIXA_SALARIAL, LIMITE_INFERIOR_FAIXA_SALARIAL, LIMITE_SUPERIOR_FAIXA_SALARIAL,
       FAIXA_ETARIA, LIMITE_INFERIOR_FAIXA_ETARIA, LIMITE_SUPERIOR_FAIXA_ETARIA,
       MAX(DECODE(PLANO, 'plano_1', VALOR_MENSALIDADE, null)) AS PLANO_1,
       MAX(DECODE(PLANO, 'plano_2', VALOR_MENSALIDADE, null)) AS PLANO_2,
       MAX(DECODE(PLANO, 'plano_3', VALOR_MENSALIDADE, null)) AS PLANO_3,
       MAX(DECODE(PLANO, 'plano_4', VALOR_MENSALIDADE, null)) AS PLANO_4,
       MAX(DECODE(PLANO, 'plano_5', VALOR_MENSALIDADE, null)) AS PLANO_5,
       MAX(DECODE(PLANO, 'plano_6', VALOR_MENSALIDADE, null)) AS PLANO_6,
       MAX(DECODE(PLANO, 'plano_7', VALOR_MENSALIDADE, null)) AS PLANO_7,
       MAX(DECODE(PLANO, 'plano_8', VALOR_MENSALIDADE, null)) AS PLANO_8,

       MAX(DECODE(PLANO, 'plano_1', VALOR_SUBSIDIO, null)) AS PLANO_1_SUBSIDIO,
       MAX(DECODE(PLANO, 'plano_2', VALOR_SUBSIDIO, null)) AS PLANO_2_SUBSIDIO,
       MAX(DECODE(PLANO, 'plano_3', VALOR_SUBSIDIO, null)) AS PLANO_3_SUBSIDIO,
       MAX(DECODE(PLANO, 'plano_4', VALOR_SUBSIDIO, null)) AS PLANO_4_SUBSIDIO,
       MAX(DECODE(PLANO, 'plano_5', VALOR_SUBSIDIO, null)) AS PLANO_5_SUBSIDIO,
       MAX(DECODE(PLANO, 'plano_6', VALOR_SUBSIDIO, null)) AS PLANO_6_SUBSIDIO,
       MAX(DECODE(PLANO, 'plano_7', VALOR_SUBSIDIO, null)) AS PLANO_7_SUBSIDIO,
       MAX(DECODE(PLANO, 'plano_8', VALOR_SUBSIDIO, null)) AS PLANO_8_SUBSIDIO,

       MAX(DECODE(PLANO, 'plano_1', VALOR_SUBSIDIO_DEP, null)) AS PLANO_1_SUBSIDIO_DEP,
       MAX(DECODE(PLANO, 'plano_2', VALOR_SUBSIDIO_DEP, null)) AS PLANO_2_SUBSIDIO_DEP,
       MAX(DECODE(PLANO, 'plano_3', VALOR_SUBSIDIO_DEP, null)) AS PLANO_3_SUBSIDIO_DEP,
       MAX(DECODE(PLANO, 'plano_4', VALOR_SUBSIDIO_DEP, null)) AS PLANO_4_SUBSIDIO_DEP,
       MAX(DECODE(PLANO, 'plano_5', VALOR_SUBSIDIO_DEP, null)) AS PLANO_5_SUBSIDIO_DEP,
       MAX(DECODE(PLANO, 'plano_6', VALOR_SUBSIDIO_DEP, null)) AS PLANO_6_SUBSIDIO_DEP,
       MAX(DECODE(PLANO, 'plano_7', VALOR_SUBSIDIO_DEP, null)) AS PLANO_7_SUBSIDIO_DEP,
       MAX(DECODE(PLANO, 'plano_8', VALOR_SUBSIDIO_DEP, null)) AS PLANO_8_SUBSIDIO_DEP,

       MAX(DECODE(PLANO, 'plano_1', DESCRICAO_PLANO, null)) AS PLANO_1_DESCRICAO,
       MAX(DECODE(PLANO, 'plano_2', DESCRICAO_PLANO, null)) AS PLANO_2_DESCRICAO,
       MAX(DECODE(PLANO, 'plano_3', DESCRICAO_PLANO, null)) AS PLANO_3_DESCRICAO,
       MAX(DECODE(PLANO, 'plano_4', DESCRICAO_PLANO, null)) AS PLANO_4_DESCRICAO,
       MAX(DECODE(PLANO, 'plano_5', DESCRICAO_PLANO, null)) AS PLANO_5_DESCRICAO,
       MAX(DECODE(PLANO, 'plano_6', DESCRICAO_PLANO, null)) AS PLANO_6_DESCRICAO,
       MAX(DECODE(PLANO, 'plano_7', DESCRICAO_PLANO, null)) AS PLANO_7_DESCRICAO,
       MAX(DECODE(PLANO, 'plano_8', DESCRICAO_PLANO, null)) AS PLANO_8_DESCRICAO
from(
select ANO_MES_REFERENCIA, ANO_MES_REF_PLANO, ANO_MES_REF_FAIXA_SALARIAL, ANO_MES_REF_FAIXA_ETARIA,
       PLANO,
       IDENTIFICADOR_FAIXA_SALARIAL, FAIXA_SALARIAL, LIMITE_INFERIOR_FAIXA_SALARIAL, LIMITE_SUPERIOR_FAIXA_SALARIAL,
       IDENTIFICADOR_FAIXA_ETARIA, FAIXA_ETARIA, LIMITE_INFERIOR_FAIXA_ETARIA, LIMITE_SUPERIOR_FAIXA_ETARIA,
       NVL(VALOR_MENSALIDADE,0.00) AS VALOR_MENSALIDADE,
       NVL(VALOR_SUBSIDIO,0.00) AS VALOR_SUBSIDIO,
       NVL(VALOR_SUBSIDIO_DEP,0.00) AS VALOR_SUBSIDIO_DEP,
       DESCRICAO_PLANO
from(
select RHPBH_PS_VALORES_PLANO_SAUDE.ANO_MES_REFERENCIA,
       RHPBH_PS_VALORES_PLANO_SAUDE.ANO_MES_REF_PLANO,
       RHPBH_PS_VALORES_PLANO_SAUDE.ANO_MES_REF_FAIXA_SALARIAL,
       RHPBH_PS_VALORES_PLANO_SAUDE.ANO_MES_REF_FAIXA_ETARIA,
       RHPBH_PS_PLANOS.IDENTIFICADOR AS PLANO,
       RHPBH_PS_FAIXA_SALARIAL.IDENTIFICADOR AS IDENTIFICADOR_FAIXA_SALARIAL,
       RHPBH_PS_FAIXA_SALARIAL.DESCRICAO AS FAIXA_SALARIAL,
       RHPBH_PS_FAIXA_SALARIAL.LIMITE_INFERIOR AS LIMITE_INFERIOR_FAIXA_SALARIAL,
       RHPBH_PS_FAIXA_SALARIAL.LIMITE_SUPERIOR AS LIMITE_SUPERIOR_FAIXA_SALARIAL,
       RHPBH_PS_FAIXA_ETARIA.IDENTIFICADOR AS IDENTIFICADOR_FAIXA_ETARIA,
       RHPBH_PS_FAIXA_ETARIA.DESCRICAO AS FAIXA_ETARIA,
       RHPBH_PS_FAIXA_ETARIA.LIMITE_INFERIOR AS LIMITE_INFERIOR_FAIXA_ETARIA,
       RHPBH_PS_FAIXA_ETARIA.LIMITE_SUPERIOR AS LIMITE_SUPERIOR_FAIXA_ETARIA,
       RHPBH_PS_VALORES_PLANO_SAUDE.VALOR_MENSALIDADE,
       RHPBH_PS_VALORES_PLANO_SAUDE.VALOR_SUBSIDIO,
       RHPBH_PS_VALORES_PLANO_SAUDE.VALOR_SUBSIDIO_DEP,
       RHBENF_BENEFICIO.DESCRICAO AS DESCRICAO_PLANO
  from RHPBH_PS_VALORES_PLANO_SAUDE, RHPBH_PS_PLANOS, RHPBH_PS_FAIXA_ETARIA, RHPBH_PS_FAIXA_SALARIAL, RHBENF_BENEFICIO
 where RHPBH_PS_VALORES_PLANO_SAUDE.ANO_MES_REF_PLANO = RHPBH_PS_PLANOS.ANO_MES_REFERENCIA
   and RHPBH_PS_VALORES_PLANO_SAUDE.IDENTIFICADOR_PLANO = RHPBH_PS_PLANOS.IDENTIFICADOR
   and RHPBH_PS_VALORES_PLANO_SAUDE.ANO_MES_REF_FAIXA_ETARIA = RHPBH_PS_FAIXA_ETARIA.ANO_MES_REFERENCIA
   and RHPBH_PS_VALORES_PLANO_SAUDE.IDENTIFICADOR_FAIXA_ETARIA = RHPBH_PS_FAIXA_ETARIA.IDENTIFICADOR
   and RHPBH_PS_VALORES_PLANO_SAUDE.ANO_MES_REF_FAIXA_SALARIAL = RHPBH_PS_FAIXA_SALARIAL.ANO_MES_REFERENCIA
   and RHPBH_PS_VALORES_PLANO_SAUDE.IDENTIFICADOR_FAIXA_SALARIAL = RHPBH_PS_FAIXA_SALARIAL.IDENTIFICADOR
   and RHPBH_PS_PLANOS.CODIGO = RHBENF_BENEFICIO.CODIGO
)
) group by ANO_MES_REFERENCIA, ANO_MES_REF_PLANO, ANO_MES_REF_FAIXA_SALARIAL, ANO_MES_REF_FAIXA_ETARIA,
       IDENTIFICADOR_FAIXA_SALARIAL, FAIXA_SALARIAL, LIMITE_INFERIOR_FAIXA_SALARIAL, LIMITE_SUPERIOR_FAIXA_SALARIAL,
       IDENTIFICADOR_FAIXA_ETARIA, FAIXA_ETARIA, LIMITE_INFERIOR_FAIXA_ETARIA, LIMITE_SUPERIOR_FAIXA_ETARIA
order by ANO_MES_REFERENCIA, FAIXA_SALARIAL, FAIXA_ETARIA