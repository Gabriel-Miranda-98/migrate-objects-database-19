
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "PONTO_ELETRONICO"."VW_JORNADA" ("CODIGO_EMPRESA", "CODIGO", "HORARIO1", "HORARIO2", "HORARIO3", "HORARIO4", "HORARIO5", "HORARIO6", "HORARIO7", "HORARIO8", "HORARIO9", "HORARIO10", "HORARIO11", "HORARIO12", "DTULTIMA_ALTERACAO", "DATA_EXTINCAO", "TIPO", "INTERVALO_ALMOCO", "CODIGO_INTEGRA_ARTE") AS 
  (SELECT "CODIGO_EMPRESA",
    "CODIGO",
    "HORARIO1",
    "HORARIO2",
    "HORARIO3",
    "HORARIO4",
    "HORARIO5",
    "HORARIO6",
    "HORARIO7",
    "HORARIO8",
    "HORARIO9",
    "HORARIO10",
    "HORARIO11",
    "HORARIO12",
    "DTULTIMA_ALTERACAO",
    DATA_EXTINCAO,
    TIPO,
    INTERVALO_ALMOCO
    ,CODIGO_INTEGRA_ARTE
  FROM PONTO_ELETRONICO.SMARH_INT_PE_JORNADA_V2
  WHERE --1=0
    --codigo_empresa = '0098'
    DT_ENVIADO_IFPONTO_SURICATO IS NULL
    -- and codigo = '0240'
    -- and dt_saiu_arte>= trunc(sysdate)
  )