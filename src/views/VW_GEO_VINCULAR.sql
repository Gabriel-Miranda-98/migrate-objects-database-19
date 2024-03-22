
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "PONTO_ELETRONICO"."VW_GEO_VINCULAR" ("CODIGO_EMPRESA", "AGRUPAMENTO_EMPRESA", "TIPO_CONTRATO", "CODIGO_CONTRATO", "COD_UNIDADE", "DESCRICAO_UNIDADE", "TIPO", "COD_CARGO", "CODIGO_LEGADO", "DT_SAIU_ARTE", "DT_ENVIADO_IFPONTO_SURICATO", "CODIGO_INTEGRA_ARTE") AS 
  SELECT CODIGO_EMPRESA,
            AGRUPAMENTO_EMPRESA,
            TIPO_CONTRATO,
            CODIGO_CONTRATO,
            COD_UNIDADE,
            DESCRICAO_UNIDADE,
            TIPO,
            COD_CARGO,
            CODIGO_LEGADO,
            DT_SAIU_ARTE,
            DT_ENVIADO_IFPONTO_SURICATO
            ,CODIGO_INTEGRA_ARTE --NOVO 4/7/22
       FROM PONTO_ELETRONICO.SMARH_INT_CAD_PESS_CERCA
      WHERE DT_ENVIADO_IFPONTO_SURICATO IS NULL
   GROUP BY CODIGO_EMPRESA,
            AGRUPAMENTO_EMPRESA,
            TIPO_CONTRATO,
            CODIGO_CONTRATO,
            COD_UNIDADE,
            DESCRICAO_UNIDADE,
            TIPO,
            COD_CARGO,
            CODIGO_LEGADO,
            DT_SAIU_ARTE,
            DT_ENVIADO_IFPONTO_SURICATO
            ,CODIGO_INTEGRA_ARTE --NOVO 4/7/22
   ORDER BY CODIGO_EMPRESA,
            AGRUPAMENTO_EMPRESA,
            TIPO_CONTRATO,
            CODIGO_CONTRATO,
            COD_UNIDADE,
            DESCRICAO_UNIDADE,
            TIPO,
            COD_CARGO,
            CODIGO_LEGADO,
            DT_SAIU_ARTE,
            DT_ENVIADO_IFPONTO_SURICATO