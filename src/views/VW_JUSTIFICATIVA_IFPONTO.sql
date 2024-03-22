
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "PONTO_ELETRONICO"."VW_JUSTIFICATIVA_IFPONTO" ("CODIGO_EMPRESA", "NRO", "CODIGO_LEGADO", "DESCRICAO", "VISUALIZAR_NO_SUBMENU", "QTD_LIMITE", "PERIODO", "DATA_EXTINCAO", "DT_SAIU_ARTE", "DT_ENVIADO_IFPONTO_SURICATO", "CODIGO_INTEGRA_ARTE", "APENAS_ADMIN", "TIPO_REFERENCIA") AS 
  SELECT CODIGO_EMPRESA,
            NRO,
            CODIGO_LEGADO,
            DESCRICAO,
            VISUALIZAR_NO_SUBMENU,
            QTD_LIMITE,
            PERIODO,
            DATA_EXTINCAO,
            DT_SAIU_ARTE,
            DT_ENVIADO_IFPONTO_SURICATO
            ,CODIGO_INTEGRA_ARTE 
            ,APENAS_ADMIN
            ,TIPO_REFERENCIA
       FROM PONTO_ELETRONICO.SMARH_INT_PE_JUSTIFICATIVA_IF
      WHERE DT_ENVIADO_IFPONTO_SURICATO IS NULL
   GROUP BY CODIGO_EMPRESA,
            NRO,
            CODIGO_LEGADO,
            DESCRICAO,
            VISUALIZAR_NO_SUBMENU,
            QTD_LIMITE,
            PERIODO,
            DATA_EXTINCAO,
            DT_SAIU_ARTE,
            DT_ENVIADO_IFPONTO_SURICATO
            ,CODIGO_INTEGRA_ARTE 
            ,APENAS_ADMIN
            ,TIPO_REFERENCIA
   ORDER BY CODIGO_EMPRESA,
            NRO,
            CODIGO_LEGADO,
            DESCRICAO,
            VISUALIZAR_NO_SUBMENU,
            QTD_LIMITE,
            PERIODO,
            DATA_EXTINCAO,
            DT_SAIU_ARTE,
            DT_ENVIADO_IFPONTO_SURICATO