
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."portal_rh_units" ("contractManger", "type", "idAgrup", "opusSecretary", "nameSecretary", "opusCode", "name", "address") AS 
  SELECT g.contrato_resp as "contractManger",  'PERMUTA' AS"type", G.ID_AGRUP "idAgrup", sec.cod_cgerenc1 as "opusSecretary", ARTERH.NORMALIZAR( nvl(sec.descricao,sec.texto_associado)) as "nameSecretary", g.cod_cgerenc1||'.'|| g.cod_cgerenc2||'.'|| g.cod_cgerenc3||'.'|| g.cod_cgerenc4||'.'|| g.cod_cgerenc5||'.'|| g.cod_cgerenc6 AS "opusCode", ARTERH.NORMALIZAR(nvl(g.descricao,g.texto_associado)) as "name",
UPPER(trim(tpl.descricao||' '||trim(trim(end.descricao)||','||trim(end.numero)||','||' bairro: '||trim(end.bairro)||' cep: '||trim(end.cep)))) as "address"
FROM ARTERH.rhorga_custo_geren G 
INNER JOIN ARTERH.RHORGA_EMPRESA EMP
ON EMP.CODIGO=G.CODIGO_EMPRESA
LEFT OUTER JOIN ARTERH.RHORGA_ENDERECO END
ON END.CODIGO=G.COD_ENDERECO
left outer join arterh.RHTABS_TP_LOGRAD tpl
on tpl.codigo= end.tipo_logradouro
left outer join arterh.rhorga_custo_geren sec
on g.codigo_empresa=sec.codigo_empresa
and g.cod_cgerenc1=sec.cod_cgerenc1
and sec.cod_cgerenc2='000000'
and sec.cod_cgerenc3='000000'
and sec.cod_cgerenc4='000000'
and sec.cod_cgerenc5='000000'
and sec.cod_cgerenc6='000000'

WHERE EMP.CGC=G.CGC
AND g.data_extincao IS NULL
and g.cod_cgerenc1||'.'|| g.cod_cgerenc2 not in ('000099.000095','000099.000098')
and g.cod_cgerenc1 not in ('000099')
and g.codigo_empresa='0001'
and g.nivel_agrup_estrut >1
union all 
  SELECT g.contrato_resp as "contractManger",'PERMANENTE' AS"type", G.ID_AGRUP "idAgrup", sec.cod_cgerenc1 as "opusSecretary", ARTERH.NORMALIZAR( nvl(sec.descricao,sec.texto_associado)) as "nameSecretary", g.cod_cgerenc1||'.'|| g.cod_cgerenc2||'.'|| g.cod_cgerenc3||'.'|| g.cod_cgerenc4||'.'|| g.cod_cgerenc5||'.'|| g.cod_cgerenc6 AS "opusCode", ARTERH.NORMALIZAR(nvl(g.descricao,g.texto_associado)) as "name",
UPPER(trim(tpl.descricao||' '||trim(trim(end.descricao)||','||trim(end.numero)||','||' bairro: '||trim(end.bairro)||' cep: '||trim(end.cep)))) as "address"
FROM ARTERH.rhorga_custo_geren G 
INNER JOIN ARTERH.RHORGA_EMPRESA EMP
ON EMP.CODIGO=G.CODIGO_EMPRESA
LEFT OUTER JOIN ARTERH.RHORGA_ENDERECO END
ON END.CODIGO=G.COD_ENDERECO
left outer join arterh.RHTABS_TP_LOGRAD tpl
on tpl.codigo= end.tipo_logradouro
left outer join arterh.rhorga_custo_geren sec
on g.codigo_empresa=sec.codigo_empresa
and g.cod_cgerenc1=sec.cod_cgerenc1
and sec.cod_cgerenc2='000000'
and sec.cod_cgerenc3='000000'
and sec.cod_cgerenc4='000000'
and sec.cod_cgerenc5='000000'
and sec.cod_cgerenc6='000000'

WHERE EMP.CGC=G.CGC
AND g.data_extincao IS NULL
and g.cod_cgerenc1||'.'|| g.cod_cgerenc2 not in ('000099.000095','000099.000098')
and g.cod_cgerenc1 not in ('000099')
and g.codigo_empresa='0001'
and g.nivel_agrup_estrut >1
and g.c_livre_selec19 >0