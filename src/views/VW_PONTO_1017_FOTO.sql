
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_PONTO_1017_FOTO" ("CODIGO_EMPRESA", "TIPO_CONTRATO", "CODIGO_CONTRATO", "RETORNO_FOTO") AS 
  SELECT XX.codigo_empresa,xx.tipo_contrato,xx.codigo_contrato,
CASE WHEN XX.COD_SIT_FUNCIONAL='1017' AND XX.DADO_DESTINO_SEGUINTE='ATIVO' THEN 'ATIVO'
ELSE 'INATIVO' END AS RETORNO_FOTO
FROM (
  SELECT X.CODIGO_EMPRESA,
         X.TIPO_CONTRATO,
         X.CODIGO_CONTRATO,
         ROW_NUMBER()
         OVER(PARTITION BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO
              ORDER BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO,
                       X.ORDEM_SAIDA
         ) AS ORDEM,
         X.ORDEM_SAIDA,
         LEAD(X.ORDEM_SAIDA, 1, NULL)
         OVER(PARTITION BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO
              ORDER BY X.CODIGO_EMPRESA,
                       X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.ORDEM_SAIDA
         ) AS ORDEM_SAIDA_SEGUINTE,
         X.COD_SIT_FUNCIONAL,
         LEAD(X.COD_SIT_FUNCIONAL, 1, NULL)
         OVER(PARTITION BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO
              ORDER BY X.CODIGO_EMPRESA,
                       X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.ORDEM_SAIDA
         ) AS COD_SIT_FUNCIONAL_SEGUINTE,
         X.DADO_DESTINO,
         LEAD(X.DADO_DESTINO, 1, NULL)
         OVER(PARTITION BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO
              ORDER BY X.CODIGO_EMPRESA,
                       X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.ORDEM_SAIDA
         ) AS DADO_DESTINO_SEGUINTE
  FROM (
    SELECT 'PENULTIMA' AS ORDEM_SAIDA,
           A.CODIGO_EMPRESA,
           A.TIPO_CONTRATO,
           A.CODIGO    AS CODIGO_CONTRATO,
           A.COD_SIT_FUNCIONAL,
           CHAVE.DADO_DESTINO
    FROM ARTERH.RHCGED_ALT_SIT_FUN A
    INNER JOIN (
      SELECT *
      FROM RHINTE_ED_IT_CONV
      WHERE CODIGO_CONVERSAO = 'PONT'
    )                        PONT
    ON SUBSTR(PONT.DADO_ORIGEM, 20, 4) = A.CODIGO_EMPRESA
       AND SUBSTR(PONT.DADO_ORIGEM, 24, 4) = A.TIPO_CONTRATO
    LEFT OUTER JOIN ARTERH.RHINTE_ED_IT_CONV CHAVE
    ON SUBSTR(CHAVE.DADO_ORIGEM, 0, 4) = A.CODIGO_EMPRESA
       AND SUBSTR(CHAVE.DADO_ORIGEM, 5, 4) = A.COD_SIT_FUNCIONAL
       AND CHAVE.CODIGO_CONVERSAO = 'POST'
    WHERE DATA_INIC_SITUACAO = (
      SELECT MAX(AUX.DATA_INIC_SITUACAO)
      FROM ARTERH.RHCGED_ALT_SIT_FUN AUX
      WHERE AUX.TIPO_CONTRATO = A.TIPO_CONTRATO
            AND AUX.CODIGO_EMPRESA = A.CODIGO_EMPRESA
            AND AUX.CODIGO = A.CODIGO
            and AUX.DATA_INIC_SITUACAO<(select max(auxx.DATA_INIC_SITUACAO)  FROM ARTERH.RHCGED_ALT_SIT_FUN AUXx
            WHERE AUXx.TIPO_CONTRATO = Aux.TIPO_CONTRATO
            AND AUXx.CODIGO_EMPRESA = Aux.CODIGO_EMPRESA
            AND AUXx.CODIGO = Aux.CODIGO
            )
            AND AUX.COD_SIT_FUNCIONAL NOT IN (
        SELECT CODIGO
        FROM ARTERH.RHPARM_SIT_FUNC X
        WHERE ( ( CONTROLE_FOLHA = 'M'
                  AND E_AFASTAMENTO = 'S'
                  AND SUSPENDE_REMUNERA = 'N' )
                OR ( CONTROLE_FOLHA = 'L'
                     AND E_AFASTAMENTO = 'N'
                     AND SUSPENDE_REMUNERA = 'S' )
                OR ( CONTROLE_FOLHA = 'L'
                     AND E_AFASTAMENTO = 'S'
                     AND SUSPENDE_REMUNERA = 'N' )
                OR ( CONTROLE_FOLHA = 'L'
                     AND E_AFASTAMENTO = 'S'
                     AND SUSPENDE_REMUNERA = 'S' )
                OR ( CONTROLE_FOLHA = 'F'
                     AND E_AFASTAMENTO = 'N'
                     AND SUSPENDE_REMUNERA = 'N' ) )
              AND X.CODIGO = AUx.COD_SIT_FUNCIONAL
      
      )
    )
    UNION ALL
    SELECT 'ULTIMA' AS ORDEM_SAIDA,
           A.CODIGO_EMPRESA,
           A.TIPO_CONTRATO,
           A.CODIGO AS CODIGO_CONTRATO,
           A.COD_SIT_FUNCIONAL,
           CHAVE.DADO_DESTINO
    FROM ARTERH.RHCGED_ALT_SIT_FUN A
    INNER JOIN (
      SELECT *
      FROM RHINTE_ED_IT_CONV
      WHERE CODIGO_CONVERSAO = 'PONT'
    )                        PONT
    ON SUBSTR(PONT.DADO_ORIGEM, 20, 4) = A.CODIGO_EMPRESA
       AND SUBSTR(PONT.DADO_ORIGEM, 24, 4) = A.TIPO_CONTRATO
    LEFT OUTER JOIN ARTERH.RHINTE_ED_IT_CONV CHAVE
    ON SUBSTR(CHAVE.DADO_ORIGEM, 0, 4) = A.CODIGO_EMPRESA
       AND SUBSTR(CHAVE.DADO_ORIGEM, 5, 4) = A.COD_SIT_FUNCIONAL
       AND CHAVE.CODIGO_CONVERSAO = 'POST'
    WHERE DATA_INIC_SITUACAO = (
      SELECT MAX(AUX.DATA_INIC_SITUACAO)
      FROM ARTERH.RHCGED_ALT_SIT_FUN AUX
      WHERE AUX.TIPO_CONTRATO = A.TIPO_CONTRATO
            AND AUX.CODIGO_EMPRESA = A.CODIGO_EMPRESA
            AND AUX.CODIGO = A.CODIGO
            AND AUX.COD_SIT_FUNCIONAL NOT IN (
        SELECT CODIGO
        FROM ARTERH.RHPARM_SIT_FUNC X
        WHERE ( ( CONTROLE_FOLHA = 'M'
                  AND E_AFASTAMENTO = 'S'
                  AND SUSPENDE_REMUNERA = 'N' )
                OR ( CONTROLE_FOLHA = 'L'
                     AND E_AFASTAMENTO = 'N'
                     AND SUSPENDE_REMUNERA = 'S' )
                OR ( CONTROLE_FOLHA = 'L'
                     AND E_AFASTAMENTO = 'S'
                     AND SUSPENDE_REMUNERA = 'N' )
                OR ( CONTROLE_FOLHA = 'L'
                     AND E_AFASTAMENTO = 'S'
                     AND SUSPENDE_REMUNERA = 'S' )
                OR ( CONTROLE_FOLHA = 'F'
                     AND E_AFASTAMENTO = 'N'
                     AND SUSPENDE_REMUNERA = 'N' ) )
              AND X.CODIGO = AUX.COD_SIT_FUNCIONAL
      )
    )
  ) X
) XX
WHERE ORDEM = 1
AND COD_SIT_FUNCIONAL='1017'