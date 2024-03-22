
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PR_SMSP_CAD_CERCA_PONTO" AS 
CONT NUMBER;
BEGIN 
CONT:=0;
FOR C1 IN (SELECT 'DIRETA' AGRUPAMENTO_EMPRESA,'0001' as codigo_empresa,
c.COD_GUARDA_MUNICIPAL AS NRO,
c.COD_GUARDA_MUNICIPAL AS CODIGO_LEGADO,
case when c.novo='SIM' THEN C.NOME_CERCA 
WHEN C.NOVO='NAO' AND C.ALTEROU_NOME='MUDOU_NOME' OR  (C.ALTEROU_LAT='ALTEROU_LAT' OR C.ALTEROU_LONG='ALTEROU_LONG' OR  C.ALTEROU_REDE='ALTEROU_REDE' )THEN C.NOME_CERCA_SEGUINTE END AS nome,
case when c.novo='SIM' THEN C.NOME_CERCA 
WHEN C.NOVO='NAO' AND C.ALTEROU_NOME='MUDOU_NOME'  OR  (C.ALTEROU_LAT='ALTEROU_LAT' OR C.ALTEROU_LONG='ALTEROU_LONG' OR  C.ALTEROU_REDE='ALTEROU_REDE' ) THEN C.NOME_CERCA_SEGUINTE END AS DESCRICAO,
case when c.novo='SIM' THEN C.LATITUDE 
WHEN C.NOVO='NAO' AND C.ALTEROU_LAT='ALTEROU_LAT' OR  (C.ALTEROU_LAT='ALTEROU_LAT' OR C.ALTEROU_LONG='ALTEROU_LONG' OR  C.ALTEROU_REDE='ALTEROU_REDE' ) THEN C.LATITUDE_SEGUINTE END AS LATITUDE,
case when c.novo='SIM' THEN C.LONGITUDE 
WHEN C.NOVO='NAO' AND C.ALTEROU_LONG='ALTEROU_LONG' OR  (C.ALTEROU_LAT='ALTEROU_LAT' OR C.ALTEROU_LONG='ALTEROU_LONG' OR  C.ALTEROU_REDE='ALTEROU_REDE' ) THEN C.LONGITUDE_SEGUINTE END AS LONGITUDE,
case when c.novo='SIM' THEN C.FAIXA_REDE 
WHEN C.NOVO='NAO' AND C.ALTEROU_REDE='ALTEROU_REDE' OR  (C.ALTEROU_LAT='ALTEROU_LAT' OR C.ALTEROU_LONG='ALTEROU_LONG' OR  C.ALTEROU_REDE='ALTEROU_REDE' ) THEN C.FAIXA_REDE_SEGUINTE END AS IP,
'100'                                            AS raio,
 SYSDATE DATA_IMPLANTACAO,
    SYSDATE DT_SAIU_ARTE,
    'INCLUIR' AS TIPO,
     NULL           AS DT_ENVIADO_IFPONTO_SURICATO


 from (select CASE WHEN XX.DIA='ULTIMO' AND XX.DIA_SEGUINTE IS NULL THEN 'SIM' ELSE'NAO'  END AS NOVO,
CASE WHEN XX.ACAO<>XX.ACAO_SEGUINTE THEN 'ACAO_MUDOU' ELSE 'ACAO_IGUAL' END AS ALTEROU_ACAO,
CASE WHEN XX.NOME_CERCA <>XX.NOME_CERCA_SEGUINTE THEN' MUDOU_NOME ' ELSE 'NOME_IGUAL' END AS ALTEROU_NOME,
CASE WHEN XX.LATITUDE<>XX.LATITUDE_SEGUINTE THEN'ALTEROU_LAT' ELSE 'IGUAL' END AS ALTEROU_LAT,
CASE WHEN XX.LONGITUDE<>XX.LONGITUDE_SEGUINTE  THEN 'ALTEROU_LONG' ELSE 'IGUAL' END AS ALTEROU_LONG,
CASE WHEN XX.FAIXA_REDE<>XX.FAIXA_REDE_SEGUINTE THEN'ALTEROU_REDE' ELSE 'IGUAL' END AS ALTEROU_REDE,
XX.*

from (SELECT XX.COD_GUARDA_MUNICIPAL, 
            Row_Number () Over (Partition BY XX.COD_GUARDA_MUNICIPAL Order By XX.COD_GUARDA_MUNICIPAL, XX.DIA)ORDEM,
 XX.DIA,
            LEAD(XX.DIA, 1, NULL) OVER(Partition BY XX.COD_GUARDA_MUNICIPAL Order By XX.COD_GUARDA_MUNICIPAL, XX.DIA) DIA_SEGUINTE,
            XX.ACAO,
            LEAD(XX.ACAO, 1, NULL) OVER(Partition BY XX.COD_GUARDA_MUNICIPAL Order By XX.COD_GUARDA_MUNICIPAL, XX.DIA)ACAO_SEGUINTE,
            XX.CODIGO_ARTE,
            LEAD(XX.CODIGO_ARTE, 1, NULL) OVER(Partition BY XX.COD_GUARDA_MUNICIPAL Order By XX.COD_GUARDA_MUNICIPAL, XX.DIA)CODIGO_ARTE_SEGUINTE,
            XX.NOME_CERCA,
            LEAD(XX.NOME_CERCA, 1, NULL) OVER(Partition BY XX.COD_GUARDA_MUNICIPAL Order By XX.COD_GUARDA_MUNICIPAL, XX.DIA)NOME_CERCA_SEGUINTE,
            XX.LATITUDE,
            LEAD(XX.LATITUDE, 1, NULL) OVER(Partition BY XX.COD_GUARDA_MUNICIPAL Order By XX.COD_GUARDA_MUNICIPAL, XX.DIA)LATITUDE_SEGUINTE,
            XX.LONGITUDE,
            LEAD(XX.LONGITUDE, 1, NULL) OVER(Partition BY XX.COD_GUARDA_MUNICIPAL Order By XX.COD_GUARDA_MUNICIPAL, XX.DIA)LONGITUDE_SEGUINTE,
            XX.FAIXA_REDE,
            LEAD(XX.FAIXA_REDE, 1, NULL) OVER(Partition BY XX.COD_GUARDA_MUNICIPAL Order By XX.COD_GUARDA_MUNICIPAL, XX.DIA)FAIXA_REDE_SEGUINTE
            FROM (

select 'ULTIMO' AS DIA, x.* from (
SELECT case when sm.codigo_arte  is null then 'CRIAR CERGA DADOS GEO' ELSE 'CERCA SIOM ' END AS ACAO,
sm.codigo_arte,RD.COD_GUARDA_MUNICIPAL,rd.sigla_tipo_logradouro||' '||rd.nome_logradouro||' '||rd.numero_imovel as nome_cerca,
rd.latitude,
rd.longitude,
rd.faixa_rede FROM PONTO_ELETRONICO.smsp_carga_rede rd
left outer join  PONTO_ELETRONICO.arterh_siom SM 
on sm.id_endereco_corporativo=rd.cod_endereco_corporativo
AND TRUNC(SM.DATA_CARGA)=(SELECT MAX(trunc(AUX.DATA_CARGA)) FROM PONTO_ELETRONICO.arterh_siom AUX)
WHERE TRUNC(data_dados)=(SELECT MAX(trunc(AUX.data_dados)) FROM PONTO_ELETRONICO.smsp_carga_rede  AUX)

UNION ALL 
SELECT
case when sm.codigo_arte  is null then 'CRIAR CERGA DADOS GEO' ELSE 'CERCA SIOM ' END AS ACAO,
sm.codigo_arte,g.cod_guarda_municipal,rd.sigla_tipo_logradouro||' '||rd.nome_logradouro||' '||rd.numero_imovel as nome_cerca,
rd.latitude,
rd.longitude,
rd.faixa_rede    FROM PONTO_ELETRONICO.smsp_local_g_guarda g
left outer join PONTO_ELETRONICO.smsp_carga_rede rd
on g.cod_referencia_endereco=rd.COD_GUARDA_MUNICIPAL
and TRUNC(rd.data_dados)=(SELECT MAX(trunc(AUX.data_dados)) FROM PONTO_ELETRONICO.smsp_carga_rede  AUX)
left outer join  PONTO_ELETRONICO.arterh_siom SM 
on sm.id_endereco_corporativo=rd.cod_endereco_corporativo
AND TRUNC(SM.DATA_CARGA)=(SELECT MAX(trunc(AUX.DATA_CARGA)) FROM PONTO_ELETRONICO.arterh_siom AUX)
WHERE trunc(g.DATA_CARGA)=(SELECT MAX(trunc(AUX.DATA_CARGA)) FROM PONTO_ELETRONICO.smsp_local_g_guarda AUX) 

)x

UNION ALL 

SELECT 'PENULTIMO' AS DIA,X.* FROM (SELECT  case when sm.codigo_arte  is null then 'CRIAR CERGA DADOS GEO' ELSE 'CERCA SIOM ' END AS ACAO,
sm.codigo_arte,RD.COD_GUARDA_MUNICIPAL,rd.sigla_tipo_logradouro||' '||rd.nome_logradouro||' '||rd.numero_imovel as nome_cerca,
rd.latitude,
rd.longitude,
rd.faixa_rede FROM PONTO_ELETRONICO.smsp_carga_rede rd
left outer join  PONTO_ELETRONICO.arterh_siom SM 
on sm.id_endereco_corporativo=rd.cod_endereco_corporativo
AND TRUNC(SM.DATA_CARGA)=(SELECT MAX(TRUNC(AUX.DATA_CARGA))
                  FROM PONTO_ELETRONICO.arterh_siom AUX
                  WHERE TRUNC(AUX.DATA_CARGA) <
                    (SELECT MAX(TRUNC(AUXX.DATA_CARGA))
                    FROM PONTO_ELETRONICO.arterh_siom AUXX
             --      WHERE trunc(AUXX.DATA_DADOS)<='07/12/2021'
                    )
                  )
WHERE TRUNC(data_dados)=(SELECT MAX(TRUNC(AUX.DATA_DADOS))
                  FROM PONTO_ELETRONICO.smsp_carga_rede AUX
                  WHERE TRUNC(AUX.DATA_DADOS) <
                    (SELECT MAX(TRUNC(AUXX.DATA_DADOS))
                    FROM PONTO_ELETRONICO.smsp_carga_rede AUXX
             --      WHERE trunc(AUXX.DATA_DADOS)<='07/12/2021'
                    )
                  )

UNION ALL 
SELECT 
case when sm.codigo_arte  is null then 'CRIAR CERGA DADOS GEO' ELSE 'CERCA SIOM ' END AS ACAO,
sm.codigo_arte,g.cod_guarda_municipal,rd.sigla_tipo_logradouro||' '||rd.nome_logradouro||' '||rd.numero_imovel as nome_cerca,
rd.latitude,
rd.longitude,
rd.faixa_rede    FROM PONTO_ELETRONICO.smsp_local_g_guarda g
left outer join PONTO_ELETRONICO.smsp_carga_rede rd
on g.cod_referencia_endereco=rd.COD_GUARDA_MUNICIPAL
and TRUNC(rd.data_dados)=(SELECT MAX(TRUNC(AUX.DATA_DADOS))
                  FROM PONTO_ELETRONICO.smsp_carga_rede AUX
                  WHERE TRUNC(AUX.DATA_DADOS) <
                    (SELECT MAX(TRUNC(AUXX.DATA_DADOS))
                    FROM PONTO_ELETRONICO.smsp_carga_rede AUXX
             --      WHERE trunc(AUXX.DATA_DADOS)<='07/12/2021'
                    )
                  )
left outer join  PONTO_ELETRONICO.arterh_siom SM 
on sm.id_endereco_corporativo=rd.cod_endereco_corporativo
AND TRUNC(SM.DATA_CARGA)=(SELECT MAX(TRUNC(AUX.DATA_CARGA))
                  FROM PONTO_ELETRONICO.arterh_siom AUX
                  WHERE TRUNC(AUX.DATA_CARGA) <
                    (SELECT MAX(TRUNC(AUXX.DATA_CARGA))
                    FROM PONTO_ELETRONICO.arterh_siom AUXX
             --      WHERE trunc(AUXX.DATA_DADOS)<='07/12/2021'
                    )
                  )
WHERE trunc(g.DATA_CARGA)=(SELECT MAX(TRUNC(AUX.DATA_CARGA))
                  FROM PONTO_ELETRONICO.smsp_local_g_guarda AUX
                  WHERE TRUNC(AUX.DATA_CARGA) <
                    (SELECT MAX(TRUNC(AUXX.DATA_CARGA))
                    FROM PONTO_ELETRONICO.smsp_local_g_guarda AUXX
             --      WHERE trunc(AUXX.DATA_DADOS)<='07/12/2021'
                    )
                  ) 
)X
)XX
)xX
where xX.ordem=1
AND XX.ACAO='CRIAR CERGA DADOS GEO'
)C
WHERE ((C.NOVO='SIM')
OR (C.ALTEROU_NOME='NOME_MUDOU')
OR (ALTEROU_LAT='ALTEROU_LAT')
OR (ALTEROU_LONG='ALTEROU_LONG')
OR (ALTEROU_REDE='ALTEROU_REDE'))


    )LOOP
        --000303101902742
        --000319703304363
        CONT:=CONT+1;
        INSERT INTO PONTO_ELETRONICO.SMARH_INT_CAD_CERCA_DIGITAL
(
CODIGO_EMPRESA,
AGRUPAMENTO_EMPRESA,
TIPO,
CODIGO_LEGADO,
DESCRICAO,
NOME,
LATITUDE,
LONGITUDE,
IP,
NRO,
DATA_IMPLANTACAO,
DT_SAIU_ARTE,
DT_ENVIADO_IFPONTO_SURICATO,
RAIO
,CODIGO_INTEGRA_ARTE)
VALUES
(C1.CODIGO_EMPRESA,
C1.AGRUPAMENTO_EMPRESA,
C1.TIPO,
C1.CODIGO_LEGADO,
C1.DESCRICAO,
C1.NOME,
C1.LATITUDE,
C1.LONGITUDE,
C1.IP,
C1.NRO,
C1.DATA_IMPLANTACAO,
C1.DT_SAIU_ARTE,
C1.DT_ENVIADO_IFPONTO_SURICATO,
C1.RAIO
,PONTO_ELETRONICO.SEQUENCE_INTEGRA_ARTE.NEXTVAL);
COMMIT;
    END LOOP;
    END;
