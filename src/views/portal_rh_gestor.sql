
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."portal_rh_gestor" ("contractCode", "contractType", "name", "opusCode", "workPlace") AS 
  SELECT x."contractCode",x."contractType",x."name",x."opusCode",x."workPlace" from (SELECT C.CODIGO as "contractCode", C.TIPO_CONTRATO as "contractType", c.nome_acesso as "name",G.cod_cgerenc1||'.'||G.cod_cgerenc2||'.'||G.cod_cgerenc3||'.'||G.cod_cgerenc4||'.'||G.cod_cgerenc5||'.'||G.cod_cgerenc6 AS "opusCode",
G.cod_cgerenc1||'.'||G.cod_cgerenc2||'.'||G.cod_cgerenc3||'.'||G.cod_cgerenc4||'.'||G.cod_cgerenc5||'.'||G.cod_cgerenc6||'-'||NVL(G.DESCRICAO,G.texto_associado) AS "workPlace"
FROM (SELECT P.CODIGO,P.CODIGO_EMPRESA FROM ARTERH.RHPESS_CONTRATO C
INNER JOIN ARTERH.RHPESS_PESSOA P
ON C.CODIGO_EMPRESA=P.CODIGO_EMPRESA
AND C.COD_PROCURADOR=P.CODIGO
WHERE C.COD_PROCURADOR IS NOT NULL
AND c.ano_mes_referencia=(SELECT MAX(AUX.ano_mes_referencia) FROM ARTERH.RHPESS_CONTRATO AUX 
WHERE AUX.CODIGO=C.CODIGO
AND AUX.TIPO_CONTRATO=C.TIPO_CONTRATO
AND AUX.CODIGO_EMPRESA=C.CODIGO_EMPRESA)
AND c.data_rescisao IS NULL 
and c.situacao_funcional not in (SELECT sit.situacao_funcional FROM arterh.RHPARM_SITFUN_GRUPO sit where sit.id_grupo_sit_func='1' and sit.codigo_empresa=c.codigo_empresa and sit.situacao_funcional=c.situacao_funcional)
GROUP BY P.CODIGO,P.CODIGO_EMPRESA
)PESSOA_GESTOR
INNER JOIN ARTERH.RHPESS_CONTRATO C
ON C.CODIGO_PESSOA = PESSOA_GESTOR.CODIGO
AND C.CODIGO_EMPRESA=PESSOA_GESTOR.CODIGO_EMPRESA
INNER JOIN ARTERH.RHORGA_CUSTO_GEREN G
ON G.CODIGO_EMPRESA=C.CODIGO_EMPRESA
AND g.cod_cgerenc1=c.cod_custo_gerenc1
AND g.cod_cgerenc2=c.cod_custo_gerenc2
AND g.cod_cgerenc3=c.cod_custo_gerenc3
AND g.cod_cgerenc4=c.cod_custo_gerenc4
AND g.cod_cgerenc5=c.cod_custo_gerenc5
AND g.cod_cgerenc6=c.cod_custo_gerenc6
WHERE  c.ano_mes_referencia=(SELECT MAX(AUX.ano_mes_referencia) FROM ARTERH.RHPESS_CONTRATO AUX 
WHERE AUX.CODIGO=C.CODIGO
AND AUX.TIPO_CONTRATO=C.TIPO_CONTRATO
AND AUX.CODIGO_EMPRESA=C.CODIGO_EMPRESA)
AND c.data_rescisao IS NULL 
and c.situacao_funcional not in (SELECT sit.situacao_funcional FROM arterh.RHPARM_SITFUN_GRUPO sit where sit.id_grupo_sit_func='1' and sit.codigo_empresa=c.codigo_empresa and sit.situacao_funcional=c.situacao_funcional)
and c.codigo<> g.contrato_resp
)x
union all 
SELECT C.CODIGO as "contractCode", C.TIPO_CONTRATO as "contractType", c.nome_acesso as "name",G.cod_cgerenc1||'.'||G.cod_cgerenc2||'.'||G.cod_cgerenc3||'.'||G.cod_cgerenc4||'.'||G.cod_cgerenc5||'.'||G.cod_cgerenc6 AS "opusCode",
G.cod_cgerenc1||'.'||G.cod_cgerenc2||'.'||G.cod_cgerenc3||'.'||G.cod_cgerenc4||'.'||G.cod_cgerenc5||'.'||G.cod_cgerenc6||'-'||NVL(G.DESCRICAO,G.texto_associado) AS "workPlace" FROM ARTERH.RHORGA_CUSTO_GEREN G
LEFT OUTER JOIN ARTERH.RHORGA_EMPRESA EMP
ON EMP.CODIGO=G.CODIGO_EMPRESA
inner join arterh.rhpess_contrato c
on c.codigo=g.contrato_resp
and c.tipo_contrato=g.tipo_cont_resp
and c.codigo_empresa=g.codigo_empresa
WHERE G.data_extincao  IS NULL
AND EMP.CGC=G.CGC
AND EMP.CODIGO='0001'
and g.contrato_resp is not null
and  c.ano_mes_referencia=(SELECT MAX(AUX.ano_mes_referencia) FROM ARTERH.RHPESS_CONTRATO AUX 
WHERE AUX.CODIGO=C.CODIGO
AND AUX.TIPO_CONTRATO=C.TIPO_CONTRATO
AND AUX.CODIGO_EMPRESA=C.CODIGO_EMPRESA)
AND c.data_rescisao IS NULL 
and c.situacao_funcional not in (SELECT sit.situacao_funcional FROM arterh.RHPARM_SITFUN_GRUPO sit where sit.id_grupo_sit_func='1' and sit.codigo_empresa=c.codigo_empresa and sit.situacao_funcional=c.situacao_funcional)