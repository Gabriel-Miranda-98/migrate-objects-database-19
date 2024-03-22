
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "PONTO_ELETRONICO"."VW_BIOMETRIA" ("CODIGO_EMPRESA", "TIPO_CONTRATO", "CODIGO_CONTRATO", "NOME", "PIS", "CPF", "TEMPL_TIT1", "TEMPL_TIT2", "TEMPL_TIT3", "TEMPL_TIT4", "TEMPL_TIT5", "TEMPL_ALT1", "TEMPL_ALT2", "TEMPL_ALT3", "TEMPL_ALT4", "TEMPL_ALT5") AS 
  (SELECT CODIGO_EMPRESA,
      TIPO_CONTRATO,
      CODIGO_CONTRATO,
      NOME,
      PIS,
      CPF,
      TEMPL_TIT1,
      TEMPL_TIT2,
      TEMPL_TIT3,
      TEMPL_TIT4,
      TEMPL_TIT5,
      TEMPL_ALT1,
      TEMPL_ALT2,
      TEMPL_ALT3,
      TEMPL_ALT4,
      TEMPL_ALT5 FROM BIOMETRIA_SURICATO WHERE DT_ENVIADO_IFPONTO_SURICATO IS NULL)