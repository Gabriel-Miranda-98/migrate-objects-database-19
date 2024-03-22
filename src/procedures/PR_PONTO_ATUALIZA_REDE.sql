
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PR_PONTO_ATUALIZA_REDE" AS 
BEGIN 
DECLARE
CONT NUMBER;
BEGIN 
CONT:=0;
FOR C1 IN (
SELECT
    em.codigo                              AS codigo_empresa,
    em.razao_social                        AS nome_empresa,
    g.cod_cgerenc1
    || '.'
    || g.cod_cgerenc2
    || '.'
    || g.cod_cgerenc3
    || '.'
    || g.cod_cgerenc4
    || '.'
    || g.cod_cgerenc5
    || '.'
    || g.cod_cgerenc6
    || '-'
    || nvl(g.texto_associado, g.descricao) AS nome_unidade,
    E.CODIGO,
    fim.*,
    trim(e.texto_assoc)                         AS rede_arte
FROM
    (
        SELECT
            x.codigo_arte,
            LISTAGG(x.rede, ',') WITHIN GROUP(
            ORDER BY
                x.codigo_arte
            ) AS rede
        FROM
            (
                SELECT
                    x.codigo_arte,
                    xx.rede
                FROM
                    (
                        SELECT
                            x.codigo_arte,
                            x.id_endereco_corporativo
                        FROM
                            ponto_eletronico.arterh_siom x
                        WHERE
                                trunc(x.data_carga) = (
                                    SELECT
                                        MAX(trunc(aux.data_carga))
                                    FROM
                                        ponto_eletronico.arterh_siom aux
                                )
                            AND x.data_desativacao IS NULL
                    ) x
                    LEFT OUTER JOIN (
                        SELECT
                            LISTAGG(replace(x.rede, ' ', ''), ',') WITHIN GROUP(
                            ORDER BY
                                id_geo
                            ) AS rede,
                            x.id_geo
                        FROM
                            (
                                SELECT DISTINCT
                                    ( rede ) AS rede,
                                    id_geo
                                FROM
                                    ponto_eletronico.arterh_sdm sd
                                WHERE
                                    trunc(sd.data_carga) = (
                                        SELECT
                                            MAX(trunc(aux.data_carga))
                                        FROM
                                            ponto_eletronico.arterh_sdm aux
                                        WHERE
                                            aux.id_geo = sd.id_geo
                                    )
                            ) x
                        GROUP BY
                            x.id_geo
                    ) xx ON xx.id_geo = x.id_endereco_corporativo
                GROUP BY
                    x.codigo_arte,
                    xx.rede
            ) x
        GROUP BY
            x.codigo_arte
    )                         fim
    LEFT OUTER JOIN arterh.rhorga_endereco    e ON e.codigo = fim.codigo_arte
    LEFT OUTER JOIN arterh.rhorga_custo_geren g ON g.cod_endereco = e.codigo
                                                   AND g.data_extincao IS NULL
    LEFT OUTER JOIN arterh.rhorga_empresa     em ON g.codigo_empresa = em.codigo
WHERE
    e.c_livre_data01 IS NOT NULL
    AND ( ( e.texto_assoc IS NULL )
          OR ( TRIM(e.texto_assoc) <> TRIM(fim.rede) ) )
----GABRIEL ANTIGA LOGICA MELHROADA PARA VERSÃO 2.0 EM 19/08/2021
/*SELECT X.*, E.TEXTO_ASSOC ,G.CODIGO_EMPRESA,G.COD_CGERENC1,
    G.COD_CGERENC2,
    G.COD_CGERENC3,
    G.COD_CGERENC4,
    G.COD_CGERENC5,
    G.COD_CGERENC6, G.DESCRICAO FROM ( SELECT X.cgc,x.codigo,X.REDE FROM (SELECT EM.CGC,E.CODIGO,XX.REDE
  FROM ARTERH.RHORGA_CUSTO_GEREN G
  LEFT OUTER JOIN ARTERH.RHORGA_ENDERECO E
  ON E.CODIGO=G.COD_ENDERECO
  LEFT OUTER JOIN ARTERH.RHORGA_EMPRESA EM
  ON G.CODIGO_EMPRESA=EM.CODIGO
  LEFT OUTER JOIN PONTO_ELETRONICO.ARTERH_SIOM X
  ON LPAD (SUBSTR(X.CODIGO_OPUS,1,2),6,'0')  =G.COD_CGERENC1
  AND LPAD (SUBSTR(X.CODIGO_OPUS,3,2),6,'0') =G.COD_CGERENC2
  AND LPAD (SUBSTR(X.CODIGO_OPUS,5,2),6,'0') =G.COD_CGERENC3
  AND LPAD (SUBSTR(X.CODIGO_OPUS,7,2),6,'0') =G.COD_CGERENC4
  AND LPAD (SUBSTR(X.CODIGO_OPUS,9,2),6,'0') =G.COD_CGERENC5
  AND LPAD (SUBSTR(X.CODIGO_OPUS,12,2),6,'0')=G.COD_CGERENC6
  LEFT OUTER JOIN
                (SELECT LISTAGG(REPLACE(X.REDE,' ',''),',') WITHIN GROUP(ORDER BY ID_GEO) as REDE,
                X.ID_GEO
                FROM
                  (SELECT DISTINCT (REDE) AS REDE,
                  ID_GEO
                  FROM PONTO_ELETRONICO.ARTERH_SDM SD
                  WHERE TRUNC(SD.DATA_CARGA)=
                    (SELECT MAX(TRUNC(AUX.DATA_CARGA))
                    FROM PONTO_ELETRONICO.ARTERH_SDM AUX
                    WHERE AUX.ID_GEO=SD.ID_GEO
                    )
                  )X
                  GROUP BY X.ID_GEO
                )XX
  ON XX.ID_GEO            =X.ID_ENDERECO_CORPORATIVO
  WHERE E.C_LIVRE_DATA01 IS NOT NULL
  AND G.COD_CGERENC1 NOT IN ('000099','000098')
  AND G.COD_CGERENC2 NOT IN ('000095')
  AND TRIM(G.CGC)         =TRIM(EM.CGC)
  AND G.DATA_EXTINCAO    IS NULL
  AND X.DATA_CARGA        =
    (SELECT MAX(AUX.DATA_CARGA)
    FROM PONTO_ELETRONICO.ARTERH_SIOM AUX
    WHERE LPAD (SUBSTR(AUX.CODIGO_OPUS,1,2),6,'0')=LPAD (SUBSTR(X.CODIGO_OPUS,1,2),6,'0')
    AND LPAD (SUBSTR(AUX.CODIGO_OPUS,3,2),6,'0')  =LPAD (SUBSTR(X.CODIGO_OPUS,3,2),6,'0')
    AND LPAD (SUBSTR(AUX.CODIGO_OPUS,5,2),6,'0')  =LPAD (SUBSTR(X.CODIGO_OPUS,5,2),6,'0')
    AND LPAD (SUBSTR(AUX.CODIGO_OPUS,7,2),6,'0')  =LPAD (SUBSTR(X.CODIGO_OPUS,7,2),6,'0')
    AND LPAD (SUBSTR(AUX.CODIGO_OPUS,9,2),6,'0')  =LPAD (SUBSTR(X.CODIGO_OPUS,9,2),6,'0')
    AND LPAD (SUBSTR(AUX.CODIGO_OPUS,12,2),6,'0') =LPAD (SUBSTR(X.CODIGO_OPUS,12,2),6,'0')
    )
 GROUP BY EM.CGC, XX.REDE,  E.CODIGO
  )X group by X.cgc, x.codigo,X.REDE 
  )x
  LEFT OUTER JOIN ARTERH.RHORGA_CUSTO_GEREN G
ON TRIM(G.CGC)=TRIM(X.CGC)
AND X.CODIGO=G.COD_ENDERECO
LEFT OUTER JOIN ARTERH.RHORGA_EMPRESA EM
ON G.CODIGO_EMPRESA=EM.CODIGO
LEFT OUTER JOIN ARTERH.RHORGA_ENDERECO E
ON E.CODIGO=G.COD_ENDERECO
WHERE  TRIM(G.CGC)         =TRIM(EM.CGC)
AND ((E.texto_assoc  IS NULL)
OR (trim(E.texto_assoc)<>trim(x.rede)))
AND G.COD_CGERENC1 NOT IN ('000099','000098')
  AND G.COD_CGERENC2 NOT IN ('000095')
   AND G.DATA_EXTINCAO    IS NULL*/

)LOOP
CONT:=CONT+1;
IF C1.REDE IS NOT NULL AND C1.REDE!='0.0.0.0/0' THEN 
 UPDATE ARTERH.RHORGA_ENDERECO SET TEXTO_ASSOC=C1.REDE,LOGIN_USUARIO='INTEGRACAO_SIOM' ,DT_ULT_ALTER_USUA=SYSDATE WHERE CODIGO=''||C1.CODIGO||'';
 END IF;
END LOOP;
END;
END;