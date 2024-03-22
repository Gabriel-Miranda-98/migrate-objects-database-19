
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PR_SUGESP_ATUALIZACAO_ENDE" AS 
CONT NUMBER :=0;
log_json CLOB;
BEGIN 
 dbms_output.enable(NULL);
FOR C1 IN (SELECT X.* FROM (
SELECT  CASE WHEN END.CODIGO IS NULL THEN 'NOVO ENDERECO'
WHEN END.CODIGO IS NOT NULL AND (END.CAIXA_POSTAL IS NULL AND SIOM.LATITUDE IS NOT NULL OR END.CAIXA_POSTAL <>  SIOM.LATITUDE) THEN 'ATUALIZAR LATITUDE'
WHEN END.CODIGO IS NOT NULL AND (END.TELEX IS NULL AND SIOM.LONGITUDE IS NOT NULL OR END.TELEX <>  SIOM.LONGITUDE) THEN 'ATUALIZAR LONGITUDE'
WHEN END.CODIGO IS NOT NULL AND (END.texto_assoc IS NULL AND SIOM.REDE IS NOT NULL OR END.texto_assoc <>  SIOM.REDE) THEN 'ATUALIZAR REDE'
ELSE 'NAO MAPEADO' END AS ACAO ,
SIOM.*,
end.CAIXA_POSTAL as latitude_arte,
end.TELEX as LONGITUDE_arte,
end.texto_assoc as rede_arte
FROM(SELECT
    fim.*

FROM
    (
        SELECT
            ROW_NUMBER()
            OVER(PARTITION BY id_endereco_corporativo
                 ORDER BY
                     id_endereco_corporativo
            ) ordem_bm,
            x.*
        FROM
            (
                SELECT
                    x."ID_ENDERECO_CORPORATIVO",
                    x.descricao,
                    X.ENDERECO,
                    x."CODIGO_ARTE",
                    x."LATITUDE",
                    x."LONGITUDE",
                    x."LOGRADOURO",
                    x."TIPO_LOGRADOURO",
                    x."TIPO_LOGRADOURO_ARTE",
                    x."NUMERO",
                    x."LETRA_IMOVEL",
                    x."BAIRRO",
                    '000000000000010' "CODIGO_MUNICIPIO",
                    x."DESCRICAO_MUNICIPIO",
                    x."CEP",
                    x."UF",
                    x."REGIONAL",
                    x."CODIGO_REGIONAL",
                    x."REDE"
                FROM
                    (
                        SELECT
                            siom.id_endereco_corporativo,
                            substr(siom.tipo_logradouro
                                   || ' '
                                   || upper(arterh.normalizar(siom.logradouro))
                                   || ' '
                                   || siom.numero,
                                   0,
                                   40)                                        AS descricao,
                                   substr(siom.tipo_logradouro
                                   || ' '
                                   || upper(arterh.normalizar(siom.logradouro))
                                   || ' '
                                   || siom.numero,
                                   0,
                                   40) AS ENDERECO,
                            '00'
                            || siom.cep
                            || lpad(siom.numero||siom.letra_IMOVEL, 5, 0)                         AS codigo_arte,
                            siom.latitude,
                            siom.longitude,
                            siom.logradouro,
                            siom.tipo_logradouro,
                            CASE
                                WHEN siom.tipo_logradouro = 'RUA'        THEN
                                    '0001'
                                WHEN siom.tipo_logradouro = 'AVENIDA'    THEN
                                    '0002'
                                WHEN siom.tipo_logradouro = 'PRACA'      THEN
                                    '0003'
                                WHEN siom.tipo_logradouro = 'ALAMEDA'    THEN
                                    '0004'
                                WHEN siom.tipo_logradouro = 'ESTRADA'    THEN
                                    '0005'
                                WHEN siom.tipo_logradouro = 'BECO'       THEN
                                    '0008'
                                WHEN siom.tipo_logradouro = 'TRAVESSA'   THEN
                                    '0009'
                                WHEN siom.tipo_logradouro = 'RODOVIA'    THEN
                                    '0011'
                                WHEN siom.tipo_logradouro = 'QUADRA'     THEN
                                    '0012'
                                WHEN siom.tipo_logradouro = 'CONDOMINIO' THEN
                                    '0013'
                                WHEN siom.tipo_logradouro = 'SITIO'      THEN
                                    '0014'
                                WHEN siom.tipo_logradouro = 'FAZENDA'    THEN
                                    '0015'
                                WHEN siom.tipo_logradouro = 'VILA'       THEN
                                    '0016'
                                WHEN siom.tipo_logradouro = 'LARGO'      THEN
                                    '0017'
                                WHEN siom.tipo_logradouro = 'ESCADARIA'  THEN
                                    '0018'
                                WHEN siom.tipo_logradouro = 'LADEIRA'    THEN
                                    '0019'
                                WHEN siom.tipo_logradouro = 'PARQUE'     THEN
                                    '0020'
                                ELSE
                                    NULL
                            END                                                AS tipo_logradouro_arte,
                            siom.numero,
                            siom.letra_imovel,
                            upper(arterh.normalizar(siom.bairro))              AS bairro,
                            siom.codigo_municipio,
                            upper(arterh.normalizar(siom.descricao_municipio)) descricao_municipio,
                            siom.cep,
                            upper(arterh.normalizar(siom.uf))                  uf,
                            siom.regional,
                            CASE
                                WHEN siom.regional = 'BARREIRO'   THEN
                                    '000000000000001'
                                WHEN siom.regional = 'NOROESTE'   THEN
                                    '000000000000005'
                                WHEN siom.regional = 'NORDESTE'   THEN
                                    '000000000000004'
                                WHEN siom.regional = 'CENTRO-SUL' THEN
                                    '000000000000002'
                                WHEN siom.regional = 'VENDA NOVA' THEN
                                    '000000000000009'
                                WHEN siom.regional = 'LESTE'      THEN
                                    '000000000000003'
                                WHEN siom.regional = 'OESTE'      THEN
                                    '000000000000007'
                                WHEN siom.regional = 'NORTE'      THEN
                                    '000000000000006'
                                WHEN siom.regional = 'PAMPULHA'   THEN
                                    '000000000000008'
                                ELSE
                                    'REGIONAL NAO ENCONTRADA'
                            END                                                codigo_regional,
                            xx.rede
                        FROM
                            ponto_eletronico.arterh_siom siom
                            LEFT OUTER JOIN (
                                SELECT
                                    LISTAGG(replace(x.rede, ' ', ''),
                                            ',') WITHIN GROUP(
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
                            )                            xx ON siom.id_endereco_corporativo = xx.id_geo
                        WHERE
                                trunc(siom.data_carga) = (
                                    SELECT
                                        MAX(trunc(aux.data_carga))
                                    FROM
                                        ponto_eletronico.arterh_siom aux
                                )
                            AND siom.data_desativacao IS NULL
                            AND SIOM.CODIGO_OPUS IS NOT NULL
                    ) x
                GROUP BY
                    x.id_endereco_corporativo,
                    x.codigo_arte,
                    x.latitude,
                    x.longitude,
                    x.logradouro,
                    x.tipo_logradouro,
                    x.tipo_logradouro_arte,
                    x.numero,
                    x.letra_imovel,
                    x.bairro,
                    x.codigo_municipio,
                    x.descricao_municipio,
                    x.cep,
                    x.uf,
                    x.regional,
                    x.codigo_regional,
                    x.rede,
                    x.descricao,
                     X.ENDERECO
            ) x
    ) fim
WHERE
    fim.ordem_bm = 1
)SIOM
LEFT OUTER JOIN ARTERH.rhorga_endereco END 
ON TRIM(END.CEP)=TRIM(SIOM.CEP)
AND TO_CHAR(TRIM(END.NUMERO))=TO_CHAR(TRIM(SIOM.NUMERO||SIOM.LETRA_IMOVEL))
AND end.c_livre_data01 IS NOT NULL
)x
WHERE ACAO IN ('NOVO ENDERECO','ATUALIZAR LATITUDE','ATUALIZAR LONGITUDE','ATUALIZAR REDE'))LOOP
    CONT:=CONT+1;
    CASE c1.acao 
    when 'NOVO ENDERECO' then 
   /* INSERT INTO arterh.rhorga_endereco (codigo,descricao,tipo_logradouro,endereco,numero,bairro,municipio,uf,cep,caixa_postal,telex,login_usuario,dt_ult_alter_usua,texto_assoc,c_livre_data01,codigo_endereco01) 
    VALUES(''||C1.CODIGO_ARTE||'',''||C1.DESCRICAO||'',''||C1.TIPO_LOGRADOURO_ARTE||'',''||C1.ENDERECO||'',''||TRIM(C1.NUMERO||C1.LETRA_IMOVEL)||'',''||C1.BAIRRO||'',''||C1.CODIGO_MUNICIPIO||'',''||C1.UF||'',''||C1.CEP||'',''||c1.latitude||'', ''||c1.longitude||'', 'INTEGRACAO_SIOM', sysdate,''||c1.rede||'',sysdate,''||c1.codigo_regional||'' );
    commit;*/
    log_json := '{"DADOS_NOVOS": {' ||
                  '"CODIGO_ARTE": "' || C1.CODIGO_ARTE || '",' ||
                  '"DESCRICAO": "' || C1.DESCRICAO || '",' ||
                  '"TIPO_LOGRADOURO_ARTE": "' || C1.TIPO_LOGRADOURO_ARTE || '",' ||
                  '"ENDERECO": "' || C1.ENDERECO || '",' ||
                  '"NUMERO": "' || TRIM(C1.NUMERO || C1.LETRA_IMOVEL) || '",' ||
                  '"BAIRRO": "' || C1.BAIRRO || '",' ||
                  '"CODIGO_MUNICIPIO": "' || C1.CODIGO_MUNICIPIO || '",' ||
                  '"UF": "' || C1.UF || '",' ||
                  '"CEP": "' || C1.CEP || '",' ||
                  '"LATITUDE": "' || C1.LATITUDE || '",' ||
                  '"LONGITUDE": "' || C1.LONGITUDE || '",' ||
                  '"REDE": "' || C1.REDE || '"}}';
    insert into PONTO_ELETRONICO.RHPBH_LOG_AUDITORIA_ENDERECO(ACAO,CONTEUDO)VALUES(C1.ACAO,log_json);
    commit;

    when 'ATUALIZAR LATITUDE' then
    dbms_output.put_line('UPDATE arterh.rhorga_endereco SET caixa_postal='''||C1.latitude||''', dt_ult_alter_usua=SYSDATE,login_usuario=''INTEGRACAO_SIOM'' WHERE CODIGO='''||C1.codigo_arte||''';');
    log_json := '{"CODIGO_ARTE": "' || C1.CODIGO_ARTE || '", ' ||
             '"LATITUDE_ANTERIOR": "' || C1.LATITUDE_ARTE || '", ' ||
             '"LATITUDE_NOVA": "' || C1.LATITUDE || '"}';
     insert into PONTO_ELETRONICO.RHPBH_LOG_AUDITORIA_ENDERECO(ACAO,CONTEUDO)VALUES(C1.ACAO,log_json);
    commit;

    when 'ATUALIZAR LONGITUDE' then
    dbms_output.put_line('UPDATE arterh.rhorga_endereco SET telex='''||C1.longitude||''', dt_ult_alter_usua=SYSDATE,login_usuario=''INTEGRACAO_SIOM'' WHERE CODIGO='''||C1.codigo_arte||''';');
    log_json := '{"CODIGO_ARTE": "' || C1.CODIGO_ARTE || '", ' ||
             '"LONGITUDE_ANTERIOR": "' || C1.LONGITUDE_ARTE || '", ' ||
             '"LONGITUDE_NOVA": "' || C1.LONGITUDE || '"}';
     insert into PONTO_ELETRONICO.RHPBH_LOG_AUDITORIA_ENDERECO(ACAO,CONTEUDO)VALUES(C1.ACAO,log_json);
    commit;

    when 'ATUALIZAR REDE' then
    dbms_output.put_line('UPDATE arterh.rhorga_endereco SET texto_assoc='''||C1.REDE||''', dt_ult_alter_usua=SYSDATE,login_usuario=''INTEGRACAO_SIOM'' WHERE CODIGO='''||C1.codigo_arte||''';');
     log_json := '{"CODIGO_ARTE": "' || C1.CODIGO_ARTE || '", ' ||
             '"REDE_ANTERIOR": "' || C1.REDE_ARTE || '", ' ||
             '"REDE_NOVA": "' || C1.REDE || '"}';
     insert into PONTO_ELETRONICO.RHPBH_LOG_AUDITORIA_ENDERECO(ACAO,CONTEUDO)VALUES(C1.ACAO,log_json);
    commit;
    ELSE 
     dbms_output.put_line('NAO MAPEADO');
    END CASE;


    END LOOP;


FOR C1 IN (
SELECT X.* FROM (SELECT
 CASE WHEN END.CODIGO IS NULL 
 THEN 'ENDERECO NAO FOI CRIADO NO ARTE' 
 WHEN END.CODIGO IS NOT NULL AND (END.CODIGO<>G.COD_ENDERECO OR END.CODIGO IS NOT NULL AND G.COD_ENDERECO IS NULL ) THEN 'ATUALIZAR_ENDERECO_UNIDADE'
 ELSE 'NAO_MAPEADO' END AS ACAO,
 EMP.CODIGO AS CODIGO_EMPRESA,
 EMP.CGC,
 END.CODIGO AS CODIGO_ENDERECO_SIOM,
 G.COD_ENDERECO AS ENDERECO_ARTE,
 siom.*

FROM
    ponto_eletronico.view_locais_carga_sdm_siom SIOM 
    LEFT OUTER JOIN ARTERH.rhorga_endereco END 
    ON TRIM(END.CEP)=TRIM(SIOM.CEP)
    AND TO_CHAR(TRIM(END.NUMERO))=TO_CHAR(TRIM(SIOM.NUMERO))
    AND end.c_livre_data01 IS NOT NULL
    LEFT OUTER JOIN ARTERH.rhorga_custo_geren G
    ON g.cod_cgerenc1=siom.cod_unidade1
    AND g.cod_cgerenC2=siom.cod_unidade2
    AND g.cod_cgerenc3=siom.cod_unidade3
    AND g.cod_cgerenc4=siom.cod_unidade4
    AND g.cod_cgerenc5=siom.cod_unidade5
    AND g.cod_cgerenc6=siom.cod_unidade6
    LEFT OUTER JOIN  ARTERH.RHORGA_EMPRESA EMP
    ON G.CODIGO_EMPRESA=EMP.CODIGO
    AND EMP.data_extincao IS NULL
WHERE
    status_codigo_opus = 'ATIVA'
    AND TRIM(G.CGC)=TRIM(EMP.CGC)
)X
WHERE X.ACAO ='ATUALIZAR_ENDERECO_UNIDADE'
--AND X.ID_ENDERECO_CORPORATIVO='1143016'
)LOOP
CONT :=CONT+1;

     log_json := '{"DADOS": {' ||
             '"CODIGO_EMPRESA": "' || C1.CODIGO_EMPRESA || '",' ||
             '"COD_UNIDADE1": "' || C1.COD_UNIDADE1 || '",' ||
             '"COD_UNIDADE2": "' || C1.COD_UNIDADE2 || '",' ||
             '"COD_UNIDADE3": "' || C1.COD_UNIDADE3 || '",' ||
             '"COD_UNIDADE4": "' || C1.COD_UNIDADE4 || '",' ||
             '"COD_UNIDADE5": "' || C1.COD_UNIDADE5 || '",' ||
             '"COD_UNIDADE6": "' || C1.COD_UNIDADE6 || '",' ||
             '"CODIGO_ENDERECO_ANTERIOR": "' || C1.ENDERECO_ARTE || '",' ||
             '"CODIGO_ENDERECO_NOVO": "' || C1.CODIGO_ENDERECO_SIOM || '"}}';
              insert into PONTO_ELETRONICO.RHPBH_LOG_AUDITORIA_ENDERECO(ACAO,CONTEUDO)VALUES('ATUALIZAR_COD_ENDERECO_UNIDADES',log_json);
    commit;

UPDATE ARTERH.RHORGA_CUSTO_GEREN GN 
SET GN.COD_ENDERECO=C1.CODIGO_ENDERECO_SIOM,
GN.LOGIN_USUARIO='INTEGRACAO_SIOM',
GN.DT_ULT_ALTER_USUA=SYSDATE 
WHERE GN.COD_CGERENC1=C1.COD_UNIDADE1
AND GN.COD_CGERENC2=C1.COD_UNIDADE2
AND GN.COD_CGERENC3=C1.COD_UNIDADE3
AND GN.COD_CGERENC4=C1.COD_UNIDADE4
AND GN.COD_CGERENC5=C1.COD_UNIDADE5
AND GN.COD_CGERENC6=C1.COD_UNIDADE6
AND GN.CODIGO_EMPRESA =C1.CODIGO_EMPRESA
;
COMMIT;
----RHORGA_LOTACAO
UPDATE ARTERH.RHORGA_LOTACAO L SET L.COD_ENDERECO=C1.CODIGO_ENDERECO_SIOM,L.LOGIN_USUARIO='INTEGRACAO_SIOM',L.DT_ULT_ALTER_USUA=SYSDATE
WHERE L.COD_LOTACAO1=C1.COD_UNIDADE1
AND L.COD_LOTACAO2=C1.COD_UNIDADE2
AND L.COD_LOTACAO3=C1.COD_UNIDADE3
AND L.COD_LOTACAO4=C1.COD_UNIDADE4
AND L.COD_LOTACAO5=C1.COD_UNIDADE5
AND L.COD_LOTACAO6=C1.COD_UNIDADE6
AND L.CODIGO_EMPRESA=C1.CODIGO_EMPRESA;
COMMIT;
----- UNIDADE
UPDATE ARTERH.RHORGA_UNIDADE U SET U.COD_ENDERECO=C1.CODIGO_ENDERECO_SIOM,U.LOGIN_USUARIO='INTEGRACAO_SIOM',U.DT_ULT_ALTER_USUA=SYSDATE
WHERE U.COD_UNIDADE1=C1.COD_UNIDADE1
AND U.COD_UNIDADE2=C1.COD_UNIDADE2
AND U.COD_UNIDADE3=C1.COD_UNIDADE3
AND U.COD_UNIDADE4=C1.COD_UNIDADE4
AND U.COD_UNIDADE5=C1.COD_UNIDADE5
AND U.COD_UNIDADE6=C1.COD_UNIDADE6
AND U.CODIGO_EMPRESA=C1.CODIGO_EMPRESA;
COMMIT;
----- CUSTO_CONTABIL
UPDATE ARTERH.RHORGA_CUSTO_CONT CT SET CT.COD_ENDERECO=C1.CODIGO_ENDERECO_SIOM,CT.LOGIN_USUARIO='INTEGRACAO_SIOM',CT.DT_ULT_ALTER_USUA=SYSDATE
WHERE CT.COD_CCONTAB1=C1.COD_UNIDADE1
AND CT.COD_CCONTAB2=C1.COD_UNIDADE2
AND CT.COD_CCONTAB3=C1.COD_UNIDADE3
AND CT.COD_CCONTAB4=C1.COD_UNIDADE4
AND CT.COD_CCONTAB5=C1.COD_UNIDADE5
AND CT.COD_CCONTAB6=C1.COD_UNIDADE6
AND CT.CODIGO_EMPRESA=C1.CODIGO_EMPRESA;
COMMIT;
UPDATE RHORGA_AGRUPADOR AG SET AG.COD_ENDERECO=C1.CODIGO_ENDERECO_SIOM,AG.LOGIN_USUARIO='INTEGRACAO_SIOM',AG.DT_ULT_ALTER_USUA=SYSDATE WHERE AG.TIPO_AGRUP IN ('G','U','L','C')
AND AG.COD_AGRUP1=C1.COD_UNIDADE1
AND AG.COD_AGRUP2=C1.COD_UNIDADE2
AND AG.COD_AGRUP3=C1.COD_UNIDADE3
AND AG.COD_AGRUP4=C1.COD_UNIDADE4
AND AG.COD_AGRUP5=C1.COD_UNIDADE5
AND AG.COD_AGRUP6=C1.COD_UNIDADE6
AND AG.CODIGO_EMPRESA=C1.CODIGO_EMPRESA;
COMMIT;
UPDATE RHORGA_AGRUPADOR_H A SET A.COD_ENDERECO=C1.CODIGO_ENDERECO_SIOM,A.LOGIN_USUARIO='INTEGRACAO_SIOM',A.DT_ULT_ALTER_USUA=SYSDATE 
WHERE A.TIPO_AGRUP IN ('G','U','L','C')
AND A.COD_AGRUP1=C1.COD_UNIDADE1
AND A.COD_AGRUP2=C1.COD_UNIDADE2
AND A.COD_AGRUP3=C1.COD_UNIDADE3
AND A.COD_AGRUP4=C1.COD_UNIDADE4
AND A.COD_AGRUP5=C1.COD_UNIDADE5
AND A.COD_AGRUP6=C1.COD_UNIDADE6
AND A.CODIGO_EMPRESA=C1.CODIGO_EMPRESA
AND A.ANO_MES_REFERENCIA=(SELECT MAX(AUX.ANO_MES_REFERENCIA) FROM RHORGA_AGRUPADOR_H AUX
WHERE AUX.ID_AGRUP=A.ID_AGRUP
AND AUX.TIPO_AGRUP=A.TIPO_AGRUP
AND AUX.CODIGO_EMPRESA=A.CODIGO_EMPRESA);


END LOOP;







    END;