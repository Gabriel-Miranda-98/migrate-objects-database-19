
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "PONTO_ELETRONICO"."VW_ARTERH_SIGBASES_LOCAIS" ("ID", "TIPO_ADM", "ALTERACOES_REALIZADAS", "STATUS_REGISTRO", "STATUS_NOVO", "CODIGO_EMPRESA", "COD_AGRUP1", "COD_AGRUP2", "COD_AGRUP3", "COD_AGRUP4", "COD_AGRUP5", "COD_AGRUP6", "ABREVIACAO", "DESCRICAO", "MOTIVO_EXTINCAO", "ABREVIACAO_NOVA", "DESCRICAO_NOVA", "MOTIVO_NOVO", "DE", "PARA", "IND_CONCLUIDO") AS 
  SELECT ROWNUM AS ID,
          AA.TIPO_ADM,
          AA.ALTERACOES_REALIZADAS,
          AA.STATUS_REGISTRO,
          AA.STATUS_NOVO,
          AA.CODIGO_EMPRESA,
          AA.COD_AGRUP1,
          AA.COD_AGRUP2,
          AA.COD_AGRUP3,
          AA.COD_AGRUP4,
          AA.COD_AGRUP5,
          AA.COD_AGRUP6,
          AA.ABREVIACAO,
          AA.DESCRICAO,
          AA.MOTIVO_EXTINCAO,
          AA.ABREVIACAO_NOVA,
          AA.DESCRICAO_NOVA,
          AA.MOTIVO_NOVO,
          AT.DE,
          AT.PARA,
          CASE
            WHEN ((G.COD_AGRUP1 IS NOT NULL AND AA.ALTERACOES_REALIZADAS LIKE '%DESCRICAO%' AND AA.DESCRICAO_NOVA IS NOT NULL AND TRIM(AA.DESCRICAO_NOVA) <> TRIM(G.DESCRICAO)) OR
                 (G.COD_AGRUP1 IS NOT NULL AND AA.ALTERACOES_REALIZADAS LIKE '%ABREVIACAO%' AND AA.ABREVIACAO_NOVA IS NOT NULL AND TRIM(AA.ABREVIACAO_NOVA) <> TRIM(G.ABREVIACAO)) OR
                 (G.COD_AGRUP1 IS NOT NULL AND AA.ALTERACOES_REALIZADAS LIKE '%STATUS%' AND AA.MOTIVO_NOVO IS NOT NULL AND TRIM(AA.MOTIVO_NOVO) <> SUBSTR(G.MOTIVO_EXTINCAO,1,1)) OR
                 (G.COD_AGRUP1 IS NULL AND AA.ALTERACOES_REALIZADAS = 'LOCAL NOVO') )
            THEN '0'
            ELSE '1'
    END AS IND_CONCLUIDO
     FROM (SELECT CASE
                     WHEN TUDO.COD_AGRUP1 IN
                             ('32',
                              '34',
                              '35',
                              '36',
                              '37',
                              '39',
                              '61',
                              '62',
                              '65',
                              '66',
                              '68',
                              '70',
                              '90',
                              '91',
                              '94',
                              '95',
                              '97')
                     THEN
                        'ADM DIRETA'
                     WHEN TUDO.COD_AGRUP1 IN
                             ('43',
                              '44',
                              '60',
                              '85',
                              '89',
                              '87',
                              '88',
                              '83',
                              '92',
                              '93',
                              '81',
                              '86')
                     THEN
                        'ADM INDIRETA'
                     WHEN TUDO.COD_AGRUP1 = '99'
                     THEN
                        'FORA PBH'
                     ELSE
                        'LOCAL NÃO MAPEADO'
                  END
                     AS TIPO_ADM,
                  /*COMBINAÇÕES POSSIVEIS, NAS ALTERAÇÕES DAS INFORMAÇÕES DO ARQUIVO OPUS*/
                  CASE
                     WHEN QUANT = 1 AND TUDO.ARQUIVO = 'ULTIMO'
                     THEN
                        'LOCAL NOVO'
                     WHEN QUANT = 1 AND TUDO.ARQUIVO = 'PENULTIMO'
                     THEN
                        'LOCAL EXCLUIDO'
                     WHEN     QUANT = 2
                          AND TUDO.ABREVIACAO = TUDO.ABREVIACAO_NOVA
                          AND TUDO.DESCRICAO = TUDO.DESCRICAO_NOVA
                          AND TUDO.MOTIVO_EXTINCAO = TUDO.MOTIVO_NOVO
                     THEN
                        'NENHUMA ALTERAÇÃO REALIZADA' /* NENHUMA ALTERAÇÃO REALIZADA*/
                     WHEN     QUANT = 2
                          AND TUDO.ABREVIACAO <> TUDO.ABREVIACAO_NOVA
                          AND TUDO.DESCRICAO = TUDO.DESCRICAO_NOVA
                          AND TUDO.MOTIVO_EXTINCAO = TUDO.MOTIVO_NOVO
                     THEN
                        'ABREVIACAO ALTERADA' /* APENAS A ABREVIAÇÃO ALTERADA*/
                     WHEN     QUANT = 2
                          AND TUDO.ABREVIACAO <> TUDO.ABREVIACAO_NOVA
                          AND TUDO.DESCRICAO <> TUDO.DESCRICAO_NOVA
                          AND TUDO.MOTIVO_EXTINCAO = TUDO.MOTIVO_NOVO
                     THEN
                        'ABREVIACAO E DESCRICAO ALTERADAS' /* APENAS ABREVIAÇÃO E DESCRICAO ALTERADA*/
                     WHEN     QUANT = 2
                          AND TUDO.ABREVIACAO <> TUDO.ABREVIACAO_NOVA
                          AND TUDO.DESCRICAO = TUDO.DESCRICAO_NOVA
                          AND TUDO.MOTIVO_EXTINCAO <> TUDO.MOTIVO_NOVO
                     THEN
                        'ABREVIACAO E STATUS ALTERADOS' /* APENAS ABREVIAÇÃO E STATUS ALTERADOS*/
                     WHEN     QUANT = 2
                          AND TUDO.ABREVIACAO <> TUDO.ABREVIACAO_NOVA
                          AND TUDO.DESCRICAO <> TUDO.DESCRICAO_NOVA
                          AND TUDO.MOTIVO_EXTINCAO <> TUDO.MOTIVO_NOVO
                     THEN
                        'ABREVIACAO, DESCRICAO E STATUS ALTERADOS' /* ABREVIAÇÃO, DESCRICAO E STATUS ALTERADO*/
                     WHEN     QUANT = 2
                          AND TUDO.ABREVIACAO = TUDO.ABREVIACAO_NOVA
                          AND TUDO.DESCRICAO <> TUDO.DESCRICAO_NOVA
                          AND TUDO.MOTIVO_EXTINCAO = TUDO.MOTIVO_NOVO
                     THEN
                        'DESCRICAO ALTERADA'    /* APENAS DESCRICAO ALTERADA*/
                     WHEN     QUANT = 2
                          AND TUDO.ABREVIACAO = TUDO.ABREVIACAO_NOVA
                          AND TUDO.DESCRICAO <> TUDO.DESCRICAO_NOVA
                          AND TUDO.MOTIVO_EXTINCAO <> TUDO.MOTIVO_NOVO
                     THEN
                        'DESCRICAO E STATUS ALTERADOS' /* APENAS DESCRICAO E STATUS ALTERADOS*/
                     WHEN     QUANT = 2
                          AND TUDO.ABREVIACAO = TUDO.ABREVIACAO_NOVA
                          AND TUDO.DESCRICAO = TUDO.DESCRICAO_NOVA
                          AND TUDO.MOTIVO_EXTINCAO <> TUDO.MOTIVO_NOVO
                     THEN
                        'STATUS ALTERADO'          /* APENAS STATUS ALTERADO*/
                  END
                     ALTERACOES_REALIZADAS,
                  /*TRADUÇÃO DOS STATUS DE*/
                  CASE
                     WHEN TUDO.MOTIVO_EXTINCAO = 'A' THEN 'ATIVO'
                     WHEN TUDO.MOTIVO_EXTINCAO = 'B' THEN 'BLOQUEADO'
                     WHEN TUDO.MOTIVO_EXTINCAO = 'E' THEN 'EXCLUIDO'
                     WHEN TUDO.MOTIVO_EXTINCAO = 'R' THEN 'REATIVO'
                  END
                     STATUS_REGISTRO,
                  /*TRADUÇÃO DOS STATUS PARA*/
                  CASE
                     WHEN     TUDO.MOTIVO_NOVO IS NULL
                          AND TUDO.ARQUIVO = 'PENULTIMO'
                     THEN
                        'NÃO EXISTE MAIS'
                     WHEN     TUDO.MOTIVO_NOVO IS NULL
                          AND TUDO.ARQUIVO = 'ULTIMO'
                     THEN
                        'NÃO EXISTIA'
                     WHEN TUDO.MOTIVO_NOVO = 'A'
                     THEN
                        'ATIVO'
                     WHEN TUDO.MOTIVO_NOVO = 'B'
                     THEN
                        'BLOQUEADO'
                     WHEN TUDO.MOTIVO_NOVO = 'E'
                     THEN
                        'EXCLUIDO'
                     WHEN TUDO.MOTIVO_NOVO = 'R'
                     THEN
                        'REATIVO'
                  END
                     STATUS_NOVO,
                  TUDO."QUANT",
                  TUDO."ARQUIVO",
                  TUDO."CODIGO_EMPRESA",
                  TUDO."COD_AGRUP1",
                  TUDO."COD_AGRUP2",
                  TUDO."COD_AGRUP3",
                  TUDO."COD_AGRUP4",
                  TUDO."COD_AGRUP5",
                  TUDO."COD_AGRUP6",
                  TUDO."ABREVIACAO",
                  TUDO."DESCRICAO",
                  TUDO."MOTIVO_EXTINCAO",
                  TUDO."REGISTRO_ANDAMENTO",
                  TUDO."ARQUIV",
                  TUDO."ABREVIACAO_NOVA",
                  TUDO."DESCRICAO_NOVA",
                  TUDO."MOTIVO_NOVO",
                  TUDO."TIPO"
             FROM (SELECT P1.*,
                          NULL AS ABREVIACAO_NOVA,
                          NULL AS DESCRICAO_NOVA,
                          NULL AS MOTIVO_NOVO,
                          CASE
                             WHEN P1.ARQUIVO = 'ULTIMO'
                             THEN
                                'LOCAL NOVO QUE NÃO EXISTIA'
                             WHEN P1.ARQUIVO = 'PENULTIMO'
                             THEN
                                'LOCAL EXISTIA E NÃO VEIO NO ULTIMO ARQUIVO OPUS'
                             ELSE
                                'ERRO'
                          END
                             AS TIPO
                     FROM (  SELECT X.QUANT,
                                    X.ARQUIVO,
                                    X.CODIGO_EMPRESA,
                                    X.COD_AGRUP1,
                                    X.COD_AGRUP2,
                                    X.COD_AGRUP3,
                                    X.COD_AGRUP4,
                                    X.COD_AGRUP5,
                                    X.COD_AGRUP6,
                                    X.ABREVIACAO,
                                    X.DESCRICAO,
                                    X.MOTIVO_EXTINCAO,
                                    X.REGISTRO_ANDAMENTO,
                                    X.ARQUIV
                               FROM (SELECT 'ULTIMO' AS ARQUIVO, U.*
                                       FROM PONTO_ELETRONICO.SUGESP_OPUS_LOCAIS_OPUS_HISTO U
                                      WHERE     U.DATA_IMPORT_OPUS =
                                                   (SELECT MAX (
                                                              DATA_IMPORT_OPUS)
                                                      FROM PONTO_ELETRONICO.SUGESP_OPUS_LOCAIS_OPUS_HISTO) /*ULTIMO ARQUIVO*/
                                            AND NOT EXISTS
                                                       (SELECT 'PENULTIMO'
                                                                  AS ARQUIVO,
                                                               P.*
                                                          FROM PONTO_ELETRONICO.SUGESP_OPUS_LOCAIS_OPUS_HISTO P
                                                         WHERE     P.DATA_IMPORT_OPUS =
                                                                      (SELECT Z.DATA_IMPORT_OPUS
                                                                         FROM (  SELECT DATA_IMPORT_OPUS,
                                                                                        ROW_NUMBER ()
                                                                                        OVER (
                                                                                           ORDER BY
                                                                                              DATA_IMPORT_OPUS DESC)
                                                                                           NR_ARQ_ORDEM_CRESC
                                                                                   FROM PONTO_ELETRONICO.SUGESP_OPUS_LOCAIS_OPUS_HISTO
                                                                               GROUP BY DATA_IMPORT_OPUS) Z
                                                                        WHERE Z.NR_ARQ_ORDEM_CRESC =
                                                                                 2) /*DATA PENULTIMO ARQUIVO*/
                                                               AND U.CODIGO_EMPRESA =
                                                                      P.CODIGO_EMPRESA
                                                               AND U.COD_AGRUP1 =
                                                                      P.COD_AGRUP1
                                                               AND U.COD_AGRUP2 =
                                                                      P.COD_AGRUP2
                                                               AND U.COD_AGRUP3 =
                                                                      P.COD_AGRUP3
                                                               AND U.COD_AGRUP4 =
                                                                      P.COD_AGRUP4
                                                               AND U.COD_AGRUP5 =
                                                                      P.COD_AGRUP5
                                                               AND U.COD_AGRUP6 =
                                                                      P.COD_AGRUP6
                                                               AND U.ABREVIACAO =
                                                                      P.ABREVIACAO
                                                               AND U.DESCRICAO =
                                                                      P.DESCRICAO
                                                               AND U.MOTIVO_EXTINCAO =
                                                                      P.MOTIVO_EXTINCAO)
                                     UNION ALL
                                     SELECT 'PENULTIMO' AS ARQUIVO, P.*
                                       FROM PONTO_ELETRONICO.SUGESP_OPUS_LOCAIS_OPUS_HISTO P
                                      WHERE     P.DATA_IMPORT_OPUS =
                                                   (SELECT Z.DATA_IMPORT_OPUS
                                                      FROM (  SELECT DATA_IMPORT_OPUS,
                                                                     ROW_NUMBER ()
                                                                     OVER (
                                                                        ORDER BY
                                                                           DATA_IMPORT_OPUS DESC)
                                                                        NR_ARQ_ORDEM_CRESC
                                                                FROM PONTO_ELETRONICO.SUGESP_OPUS_LOCAIS_OPUS_HISTO
                                                            GROUP BY DATA_IMPORT_OPUS) Z
                                                     WHERE Z.NR_ARQ_ORDEM_CRESC =
                                                              2) /*DATA PENULTIMO ARQUIVO*/
                                            AND NOT EXISTS
                                                       (SELECT 'ULTIMO'
                                                                  AS ARQUIVO,
                                                               U.*
                                                          FROM PONTO_ELETRONICO.SUGESP_OPUS_LOCAIS_OPUS_HISTO U
                                                         WHERE     U.DATA_IMPORT_OPUS =
                                                                      (SELECT MAX (
                                                                                 DATA_IMPORT_OPUS)
                                                                         FROM PONTO_ELETRONICO.SUGESP_OPUS_LOCAIS_OPUS_HISTO) /*ULTIMO ARQUIVO*/
                                                               AND U.CODIGO_EMPRESA =
                                                                      P.CODIGO_EMPRESA
                                                               AND U.COD_AGRUP1 =
                                                                      P.COD_AGRUP1
                                                               AND U.COD_AGRUP2 =
                                                                      P.COD_AGRUP2
                                                               AND U.COD_AGRUP3 =
                                                                      P.COD_AGRUP3
                                                               AND U.COD_AGRUP4 =
                                                                      P.COD_AGRUP4
                                                               AND U.COD_AGRUP5 =
                                                                      P.COD_AGRUP5
                                                               AND U.COD_AGRUP6 =
                                                                      P.COD_AGRUP6
                                                               AND U.ABREVIACAO =
                                                                      P.ABREVIACAO
                                                               AND U.DESCRICAO =
                                                                      P.DESCRICAO
                                                               AND U.MOTIVO_EXTINCAO =
                                                                      P.MOTIVO_EXTINCAO)) X
                              WHERE X.QUANT = 1
                           /*GROUP BY X.CODIGO_EMPRESA, X.COD_AGRUP1, X.COD_AGRUP2, X.COD_AGRUP3, X.COD_AGRUP4, X.COD_AGRUP5, X.COD_AGRUP6*/
                           ORDER BY 3,
                                    4,
                                    5,
                                    6,
                                    7,
                                    8,
                                    9,
                                    2) P1
                   UNION ALL
                   SELECT P2.*,
                          CASE
                             WHEN P2.ARQUIVO = 'PENULTIMO'
                             THEN
                                LEAD (
                                   P2.ABREVIACAO)
                                OVER (
                                   PARTITION BY P2.CODIGO_EMPRESA,
                                                P2.COD_AGRUP1,
                                                P2.COD_AGRUP2,
                                                P2.COD_AGRUP3,
                                                P2.COD_AGRUP4,
                                                P2.COD_AGRUP5,
                                                P2.COD_AGRUP6
                                   ORDER BY
                                      P2.CODIGO_EMPRESA,
                                      P2.COD_AGRUP1,
                                      P2.COD_AGRUP2,
                                      P2.COD_AGRUP3,
                                      P2.COD_AGRUP4,
                                      P2.COD_AGRUP5,
                                      P2.COD_AGRUP6)
                             ELSE
                                NULL
                          END
                             AS ABREVIACAO_NOVA,
                          CASE
                             WHEN P2.ARQUIVO = 'PENULTIMO'
                             THEN
                                LEAD (
                                   P2.DESCRICAO)
                                OVER (
                                   PARTITION BY P2.CODIGO_EMPRESA,
                                                P2.COD_AGRUP1,
                                                P2.COD_AGRUP2,
                                                P2.COD_AGRUP3,
                                                P2.COD_AGRUP4,
                                                P2.COD_AGRUP5,
                                                P2.COD_AGRUP6
                                   ORDER BY
                                      P2.CODIGO_EMPRESA,
                                      P2.COD_AGRUP1,
                                      P2.COD_AGRUP2,
                                      P2.COD_AGRUP3,
                                      P2.COD_AGRUP4,
                                      P2.COD_AGRUP5,
                                      P2.COD_AGRUP6)
                             ELSE
                                NULL
                          END
                             AS DESCRICAO_NOVA,
                          CASE
                             WHEN P2.ARQUIVO = 'PENULTIMO'
                             THEN
                                LEAD (
                                   P2.MOTIVO_EXTINCAO)
                                OVER (
                                   PARTITION BY P2.CODIGO_EMPRESA,
                                                P2.COD_AGRUP1,
                                                P2.COD_AGRUP2,
                                                P2.COD_AGRUP3,
                                                P2.COD_AGRUP4,
                                                P2.COD_AGRUP5,
                                                P2.COD_AGRUP6
                                   ORDER BY
                                      P2.CODIGO_EMPRESA,
                                      P2.COD_AGRUP1,
                                      P2.COD_AGRUP2,
                                      P2.COD_AGRUP3,
                                      P2.COD_AGRUP4,
                                      P2.COD_AGRUP5,
                                      P2.COD_AGRUP6)
                             ELSE
                                NULL
                          END
                             AS MOTIVO_NOVO,
                          'A DESENVOLVER' AS TIPO
                     FROM (  SELECT X.QUANT,
                                    X.ARQUIVO,
                                    X.CODIGO_EMPRESA,
                                    X.COD_AGRUP1,
                                    X.COD_AGRUP2,
                                    X.COD_AGRUP3,
                                    X.COD_AGRUP4,
                                    X.COD_AGRUP5,
                                    X.COD_AGRUP6,
                                    X.ABREVIACAO,
                                    X.DESCRICAO,
                                    X.MOTIVO_EXTINCAO,
                                    X.REGISTRO_ANDAMENTO,
                                    X.ARQUIV
                               FROM (SELECT 'ULTIMO' AS ARQUIVO, U.*
                                       FROM PONTO_ELETRONICO.SUGESP_OPUS_LOCAIS_OPUS_HISTO U
                                      WHERE     U.DATA_IMPORT_OPUS =
                                                   (SELECT MAX (
                                                              DATA_IMPORT_OPUS)
                                                      FROM PONTO_ELETRONICO.SUGESP_OPUS_LOCAIS_OPUS_HISTO) /*ULTIMO ARQUIVO*/
                                            AND NOT EXISTS
                                                       (SELECT 'PENULTIMO'
                                                                  AS ARQUIVO,
                                                               P.*
                                                          FROM PONTO_ELETRONICO.SUGESP_OPUS_LOCAIS_OPUS_HISTO P
                                                         WHERE     P.DATA_IMPORT_OPUS =
                                                                      (SELECT Z.DATA_IMPORT_OPUS
                                                                         FROM (  SELECT DATA_IMPORT_OPUS,
                                                                                        ROW_NUMBER ()
                                                                                        OVER (
                                                                                           ORDER BY
                                                                                              DATA_IMPORT_OPUS DESC)
                                                                                           NR_ARQ_ORDEM_CRESC
                                                                                   FROM PONTO_ELETRONICO.SUGESP_OPUS_LOCAIS_OPUS_HISTO
                                                                               GROUP BY DATA_IMPORT_OPUS) Z
                                                                        WHERE Z.NR_ARQ_ORDEM_CRESC =
                                                                                 2) /*DATA PENULTIMO ARQUIVO*/
                                                               AND U.CODIGO_EMPRESA =
                                                                      P.CODIGO_EMPRESA
                                                               AND U.COD_AGRUP1 =
                                                                      P.COD_AGRUP1
                                                               AND U.COD_AGRUP2 =
                                                                      P.COD_AGRUP2
                                                               AND U.COD_AGRUP3 =
                                                                      P.COD_AGRUP3
                                                               AND U.COD_AGRUP4 =
                                                                      P.COD_AGRUP4
                                                               AND U.COD_AGRUP5 =
                                                                      P.COD_AGRUP5
                                                               AND U.COD_AGRUP6 =
                                                                      P.COD_AGRUP6
                                                               AND U.ABREVIACAO =
                                                                      P.ABREVIACAO
                                                               AND U.DESCRICAO =
                                                                      P.DESCRICAO
                                                               AND U.MOTIVO_EXTINCAO =
                                                                      P.MOTIVO_EXTINCAO)
                                     UNION ALL
                                     SELECT 'PENULTIMO' AS ARQUIVO, P.*
                                       FROM PONTO_ELETRONICO.SUGESP_OPUS_LOCAIS_OPUS_HISTO P
                                      WHERE     P.DATA_IMPORT_OPUS =
                                                   (SELECT Z.DATA_IMPORT_OPUS
                                                      FROM (  SELECT DATA_IMPORT_OPUS,
                                                                     ROW_NUMBER ()
                                                                     OVER (
                                                                        ORDER BY
                                                                           DATA_IMPORT_OPUS DESC)
                                                                        NR_ARQ_ORDEM_CRESC
                                                                FROM PONTO_ELETRONICO.SUGESP_OPUS_LOCAIS_OPUS_HISTO
                                                            GROUP BY DATA_IMPORT_OPUS) Z
                                                     WHERE Z.NR_ARQ_ORDEM_CRESC =
                                                              2) /*DATA PENULTIMO ARQUIVO*/
                                            AND NOT EXISTS
                                                       (SELECT 'ULTIMO'
                                                                  AS ARQUIVO,
                                                               U.*
                                                          FROM PONTO_ELETRONICO.SUGESP_OPUS_LOCAIS_OPUS_HISTO U
                                                         WHERE     U.DATA_IMPORT_OPUS =
                                                                      (SELECT MAX (
                                                                                 DATA_IMPORT_OPUS)
                                                                         FROM PONTO_ELETRONICO.SUGESP_OPUS_LOCAIS_OPUS_HISTO) /*ULTIMO ARQUIVO*/
                                                               AND U.CODIGO_EMPRESA =
                                                                      P.CODIGO_EMPRESA
                                                               AND U.COD_AGRUP1 =
                                                                      P.COD_AGRUP1
                                                               AND U.COD_AGRUP2 =
                                                                      P.COD_AGRUP2
                                                               AND U.COD_AGRUP3 =
                                                                      P.COD_AGRUP3
                                                               AND U.COD_AGRUP4 =
                                                                      P.COD_AGRUP4
                                                               AND U.COD_AGRUP5 =
                                                                      P.COD_AGRUP5
                                                               AND U.COD_AGRUP6 =
                                                                      P.COD_AGRUP6
                                                               AND U.ABREVIACAO =
                                                                      P.ABREVIACAO
                                                               AND U.DESCRICAO =
                                                                      P.DESCRICAO
                                                               AND U.MOTIVO_EXTINCAO =
                                                                      P.MOTIVO_EXTINCAO)) X
                              WHERE X.QUANT = 2
                           /*GROUP BY X.CODIGO_EMPRESA, X.COD_AGRUP1, X.COD_AGRUP2, X.COD_AGRUP3, X.COD_AGRUP4, X.COD_AGRUP5, X.COD_AGRUP6*/
                           ORDER BY 3,
                                    4,
                                    5,
                                    6,
                                    7,
                                    8,
                                    9,
                                    2) P2) TUDO
            WHERE    (TUDO.QUANT = 2 AND TUDO.ARQUIV = 'PENULTIMO')
                  OR TUDO.QUANT = 1) AA
          LEFT JOIN
          PONTO_ELETRONICO.SUGESP_OPUS_LOCAIS_ATUALIZA AT
             ON     AA.CODIGO_EMPRESA = AT.CODIGO_EMPRESA
                AND AA.COD_AGRUP1 = AT.COD_AGRUP1
                AND AA.COD_AGRUP2 = AT.COD_AGRUP2
                AND AA.COD_AGRUP3 = AT.COD_AGRUP3
                AND AA.COD_AGRUP4 = AT.COD_AGRUP4
                AND AA.COD_AGRUP5 = AT.COD_AGRUP5
                AND AA.COD_AGRUP6 = AT.COD_AGRUP6
          LEFT JOIN
          ARTERH.RHORGA_AGRUPADOR G
             ON     AA.CODIGO_EMPRESA = G.CODIGO_EMPRESA
                AND LPAD (AA.COD_AGRUP1, 6, 0) = G.COD_AGRUP1
                AND LPAD (AA.COD_AGRUP2, 6, 0) = G.COD_AGRUP2
                AND LPAD (AA.COD_AGRUP3, 6, 0) = G.COD_AGRUP3
                AND LPAD (AA.COD_AGRUP4, 6, 0) = G.COD_AGRUP4
                AND LPAD (AA.COD_AGRUP5, 6, 0) = G.COD_AGRUP5
                AND LPAD (AA.COD_AGRUP6, 6, 0) = G.COD_AGRUP6
                AND G.TIPO_AGRUP = 'G'