
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."portal_rh_units" ("idAgrup", "opusCode", "name", "address") AS 
  SELECT G.ID_AGRUP "idAgrup", g.cod_cgerenc1||'.'|| g.cod_cgerenc2||'.'|| g.cod_cgerenc3||'.'|| g.cod_cgerenc4||'.'|| g.cod_cgerenc5||'.'|| g.cod_cgerenc6 AS "opusCode", nvl(g.descricao,g.texto_associado) as "name",
trim(trim(end.descricao)||' bairro: '||trim(end.bairro)||' cep: '||trim(end.cep)) as "address"
FROM ARTERH.rhorga_custo_geren G 
INNER JOIN ARTERH.RHORGA_EMPRESA EMP
ON EMP.CODIGO=G.CODIGO_EMPRESA
LEFT OUTER JOIN ARTERH.RHORGA_ENDERECO END
ON END.CODIGO=G.COD_ENDERECO
WHERE EMP.CGC=G.CGC
AND g.data_extincao IS NULL
and g.cod_cgerenc1||'.'|| g.cod_cgerenc2 not in ('000099.000095','000099.000098')
and g.cod_cgerenc1 not in ('000099')