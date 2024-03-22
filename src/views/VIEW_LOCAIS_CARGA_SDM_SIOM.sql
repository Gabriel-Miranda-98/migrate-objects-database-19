
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "PONTO_ELETRONICO"."VIEW_LOCAIS_CARGA_SDM_SIOM" ("STATUS_CODIGO_OPUS", "ID_ENDERECO_CORPORATIVO", "DESCRICAO_UNIDADE", "CODIGO_OPUS", "COD_UNIDADE1", "COD_UNIDADE2", "COD_UNIDADE3", "COD_UNIDADE4", "COD_UNIDADE5", "COD_UNIDADE6", "LATITUDE", "LONGITUDE", "DATA_CARGA", "DATA_DESATIVACAO", "LOGRADOURO", "TIPO_LOGRADOURO", "NUMERO", "BAIRRO", "DESCRICAO_MUNICIPIO", "CEP", "UF", "REDE") AS 
  SELECT
    case when data_desativacao is not null then 'EXCLUIDA' ELSE 'ATIVA' END AS STATUS_CODIGO_OPUS,
    id_endereco_corporativo,
    upper(ARTERH.NORMALIZAR(descricao_unidade))   AS descricao_unidade,
    codigo_opus,
    lpad(substr(codigo_opus, 1, 2),6,0)AS cod_unidade1,
    lpad(substr(codigo_opus, 3, 2),6,0)AS cod_unidade2,
    lpad(substr(codigo_opus, 5, 2),6,0)AS cod_unidade3,
    lpad(substr(codigo_opus, 7, 2),6,0)AS cod_unidade4,
    lpad(substr(codigo_opus, 9, 2),6,0)AS cod_unidade5,
    lpad(substr(codigo_opus, 11, 2),6,0)AS cod_unidade6,
    latitude,
    longitude,
    data_carga,
    data_desativacao,
    logradouro,
    tipo_logradouro,
    numero,
    upper(ARTERH.NORMALIZAR(bairro))             AS bairro,
    upper(ARTERH.NORMALIZAR(descricao_municipio)) AS descricao_municipio,
  
CEP,
UF,
  xx.rede

FROM PONTO_ELETRONICO.arterh_siom sm
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
              ON SM.ID_ENDERECO_CORPORATIVO=XX.ID_GEO


WHERE TRUNC(DATA_CARGA)= (
                SELECT
                    MAX(trunc(aux.data_carga))
                FROM
                    ponto_eletronico.arterh_siom aux
            )