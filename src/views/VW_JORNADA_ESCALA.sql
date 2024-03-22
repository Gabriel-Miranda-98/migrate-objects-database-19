
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "PONTO_ELETRONICO"."VW_JORNADA_ESCALA" ("CODIGO_EMPRESA", "COD_JORNADA", "COD_ESCALA", "POSICAO", "QTD_TRABALHO", "QTD_FOLGA", "DTULTIMA_ALTERACAO", "CODIGO_INTEGRA_ARTE") AS 
  (SELECT "CODIGO_EMPRESA",
           "COD_JORNADA",
           "COD_ESCALA",
           "POSICAO",
           "QTD_TRABALHO",
           "QTD_FOLGA",
           "DTULTIMA_ALTERACAO"
           ,CODIGO_INTEGRA_ARTE
      FROM smarh_int_pe_jorn_escala_v2
     WHERE                        -- 1=0--DT_ENVIADO_IFPONTO_SURICATO is  null
           --codigo_empresa = '0098'
           DT_ENVIADO_IFPONTO_SURICATO IS NULL     --  and cod_ESCALA = '0240'
                                              )