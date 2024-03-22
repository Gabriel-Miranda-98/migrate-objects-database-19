
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "PONTO_ELETRONICO"."VW_CARGO" ("CODIGO_EMPRESA", "EMPRESA", "AGRUPAMENTO_EMPRESA", "CODIGO", "DESCRICAO", "ISENTO_MARCACAO_FREQUENCIA", "UTILIZA_BANCO_HORAS", "DATA_IMPLAN_CARGO", "DATA_EXTINC_CARGO", "DESCRICAO_ALTERNATIVA", "DT_SAIU_ARTE", "DT_ENVIADO_IFPONTO_SURICATO", "CODIGO_INTEGRA_ARTE") AS 
  (SELECT "CODIGO_EMPRESA",
           "EMPRESA",
           "AGRUPAMENTO_EMPRESA",
           "CODIGO",
           "DESCRICAO",
           "ISENTO_MARCACAO_FREQUENCIA",
           "UTILIZA_BANCO_HORAS",
           "DATA_IMPLAN_CARGO",
           "DATA_EXTINC_CARGO",
           "DESCRICAO_ALTERNATIVA",
           "DT_SAIU_ARTE",
           "DT_ENVIADO_IFPONTO_SURICATO"
           ,"CODIGO_INTEGRA_ARTE"
      FROM SMARH_INT_PE_CARGO_V2
     WHERE DT_ENVIADO_IFPONTO_SURICATO IS NULL /* --ATE 06/12/2016
                                               select
                                               CODIGO_EMPRESA,
                                               CASE WHEN CODIGO_EMPRESA = '0001' THEN 'PREF.MUN.BELO HORIZONTE' WHEN CODIGO_EMPRESA = '0098' THEN 'PREF.MUN.BH CONTRATOS' END AS EMPRESA,
                                               'ADM DIRETA' AS AGRUPAMENTO_EMPRESA,
                                               CODIGO,
                                               DESCRICAO,
                                               NULL AS ISENTO_MARCACAO_FREQUENCIA,
                                               CASE WHEN CODIGO in ( '000000000002003','000000000002004','000000000002010',--ESTE 3 PRIMEIROS ESTAGIARIOS OS DEMAIS CARGOS COMISSIONADOS DE GERENCIA ALTO NIVEL
                                                      '000000000001003', '000000000001005', '000000000001007', '000000000001009', '000000000001012',
                                                      '000000000001013',
                                                      '000000000001038', '000000000001039', '000000000001047', '000000000001048', '000000000001049',
                                                      '000000000001050', '000000000001051', '000000000001052', '000000000001055', '000000000001059',
                                                      '000000000001064', '000000000001067', '000000000001068',
                                                      '000000000001069', '000000000001070', '000000000001071', '000000000001073', '000000000001074',
                                                      '000000000001077', '000000000001078', '000000000001080',
                                                      '000000000001082', '000000000001084', '000000000001220', '000000000001222', '000000000001223',
                                                      '000000000001224', '000000000001225', '000000000001226',  '000000000002006','000000000002007'
                                                     ) THEN 'N' ELSE 'S' END AS UTILIZA_BANCO_HORAS,
                                               DATA_IMPLAN_CARGO,
                                               DATA_EXTINC_CARGO,
                                               C_LIVRE_DESCR08 AS DESCRICAO_ALTERNATIVA--,--erro 28/11/16
                                               --TO_CHAR(DT_ULT_ALTER_USUA,'DD/MM/YYYY hh24:mi:ss')DT_ULT_ALTER_USUA
                                               --DT_ULT_ALTER_USUA
                                               FROM RHPLCS_CARGO
                                               WHERE CODIGO_EMPRESA IN ('0001','0098')
                                               --AND DT_ULT_ALTER_USUA >= TO_DATE('24/10/2016','DD/MM/YYYY')--PRIMEIRA CARGA
                                               --AND DT_ULT_ALTER_USUA >= TO_CHAR(sysdate,'DD/MM/YYYY')--PARA RODAR DIARIAMENTE
                                               AND DT_ULT_ALTER_USUA >= TRUNC(sysdate)--PARA RODAR DIARIAMENTE
                                               */
                                              )