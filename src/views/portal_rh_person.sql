
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."portal_rh_person" ("manager", "loginAd", "contractCode", "name", "socialName", "homeSecretary", "workPlace", "birthDate", "noteUltimaEvaluation", "currentPosition", "scale", "functionalSituation", "email", "absence", "effectiveDate") AS 
  SELECT 
case when gestor."contractCode" is not null then 'sim' else 'nao' end "manager",
--EMP.CODIGO||'-'||emp.razao_social AS empresa,
u.codigo_usuario as "loginAd",
--TP.CODIGO||'-'||TP.DESCRICAO AS TIPO_CONTRATO,
C.CODIGO AS "contractCode",
TRIM(P.nome_acesso) AS "name",
TRIM(P.NOME_SOCIAL)  as "socialName",
g.cod_cgerenc1||'-'||NVL(sec.DESCRICAO,sec.texto_associado) AS "homeSecretary",
G.cod_cgerenc1||'.'||G.cod_cgerenc2||'.'||G.cod_cgerenc3||'.'||G.cod_cgerenc4||'.'||G.cod_cgerenc5||'.'||G.cod_cgerenc6||'-'||NVL(G.DESCRICAO,G.texto_associado) AS "workPlace",
p.data_nascimento "birthDate",
--FLOOR(MONTHS_BETWEEN(SYSDATE, p.data_nascimento) / 12) AS anos,
--FLOOR(MOD(MONTHS_BETWEEN(SYSDATE, p.data_nascimento), 12)) AS meses,
--TRUNC(SYSDATE - ADD_MONTHS(p.data_nascimento, FLOOR(MONTHS_BETWEEN(SYSDATE, p.data_nascimento) / 12) * 12 + FLOOR(MOD(MONTHS_BETWEEN(SYSDATE, p.data_nascimento), 12)))) AS dias,
x.PONTUAC_TOTAL as "noteUltimaEvaluation",
CG.DESCRICAO AS "currentPosition",
EL.CODIGO||'-'||EL.DESCRICAO AS "scale",
SF.DESCRICAO AS "functionalSituation",
C.e_mail "email",
CASE WHEN FALTAS.FALTAS IS NULL THEN 0  ELSE FALTAS.FALTAS END  AS "absence",
c.data_efetivo_exerc AS "effectiveDate"
FROM ARTERH.RHUSER_P_SIST U
INNER JOIN ARTERH.RHPESS_CONTRATO C
ON C.CODIGO_EMPRESA=U.EMPRESA_USUARIO
AND C.TIPO_CONTRATO=U.TP_CONTR_USUARIO
AND C.CODIGO=U.CONTRATO_USUARIO
INNER JOIN ARTERH.RHPESS_PESSOA P 
ON P.CODIGO=C.CODIGO_PESSOA
AND P.CODIGO_EMPRESA=C.CODIGO_EMPRESA
INNER JOIN ARTERH.RHORGA_CUSTO_GEREN G
ON G.CODIGO_EMPRESA=C.CODIGO_EMPRESA
AND g.cod_cgerenc1=c.cod_custo_gerenc1
AND g.cod_cgerenc2=c.cod_custo_gerenc2
AND g.cod_cgerenc3=c.cod_custo_gerenc3
AND g.cod_cgerenc4=c.cod_custo_gerenc4
AND g.cod_cgerenc5=c.cod_custo_gerenc5
AND g.cod_cgerenc6=c.cod_custo_gerenc6
INNER JOIN ARTERH.RHORGA_CUSTO_GEREN sec
ON sec.CODIGO_EMPRESA=C.CODIGO_EMPRESA
AND sec.cod_cgerenc1=c.cod_custo_gerenc1
AND sec.cod_cgerenc2='000000'
AND sec.cod_cgerenc3='000000'
AND sec.cod_cgerenc4='000000'
AND sec.cod_cgerenc5='000000'
AND sec.cod_cgerenc6='000000'
INNER JOIN ARTERH.RHPLCS_CARGO CG 
ON CG.CODIGO_EMPRESA=C.CODIGO_EMPRESA
AND CG.CODIGO=C.COD_CARGO_EFETIVO
LEFT OUTER JOIN (
SELECT VL.CODIGO_EMPRESA,VL.TIPO_CONTRATO,VL.CODIGO_CONTRATO,VL.PONTUAC_TOTAL FROM ARTERH.RHCOMP_AVALIACAO VL
WHERE  VL.STATUS_AVALIACAO=10
AND VL.ID_AVALIACAO=(SELECT MAX(AUX.ID_AVALIACAO) FROM ARTERH.RHCOMP_AVALIACAO AUX 
WHERE AUX.CODIGO_EMPRESA=VL.CODIGO_EMPRESA
AND AUX.TIPO_CONTRATO=VL.TIPO_CONTRATO
AND AUX.CODIGO_CONTRATO=VL.CODIGO_CONTRATO
AND AUX.STATUS_AVALIACAO=VL.STATUS_AVALIACAO)
)X
ON X.CODIGO_EMPRESA=C.CODIGO_EMPRESA
AND X.TIPO_CONTRATO=C.TIPO_CONTRATO
AND X.CODIGO_CONTRATO=C.CODIGO
INNER JOIN ARTERH.RHORGA_EMPRESA EMP
ON EMP.CODIGO=C.CODIGO_EMPRESA
INNER JOIN ARTERH.RHPESS_TP_CONTRATO TP
ON TP.CODIGO=C.TIPO_CONTRATO
INNER JOIN ARTERH.RHPONT_ESCALA EL
ON EL.CODIGO_EMPRESA=C.CODIGO_EMPRESA
AND EL.CODIGO=C.CODIGO_ESCALA
INNER JOIN ARTERH.RHPARM_SIT_FUNC SF
ON SF.CODIGO=C.SITUACAO_FUNCIONAL
LEFT OUTER JOIN "ARTERH"."portal_rh_gestor" GESTOR
ON GESTOR."contractCode"=c.codigo
and GESTOR."contractType"=c.tipo_contrato
LEFT OUTER JOIN(SELECT COUNT(1) as faltas,DIA.CODIGO_EMPRESA,DIA.TIPO_CONTRATO,DIA.CODIGO_CONTRATO FROM ARTERH.rhpont_res_sit_dia DIA
INNER JOIN ARTERH.RHPONT_SITUACAO SITUACAO 
ON SITUACAO.CODIGO=DIA.CODIGO_SITUACAO 
WHERE DIA.CODIGO_EMPRESA='0001'
AND DIA.DATA between trunc(ADD_MONTHS(SYSDATE,-14),'MM') AND LAST_DAY(ADD_MONTHS(SYSDATE,-2))
AND DIA.CODIGO_SITUACAO IN ('0020','0120','0529','1099','1100','1101')
AND  NOT EXISTS (
SELECT * FROM ARTERH.rhpont_res_sit_dia AUX 
WHERE AUX.CODIGO_EMPRESA=DIA.CODIGO_EMPRESA
AND AUX.TIPO_CONTRATO=DIA.TIPO_CONTRATO
AND AUX.CODIGO_CONTRATO=DIA.CODIGO_CONTRATO
AND AUX.DATA=DIA.DATA
AND AUX.CODIGO_SITUACAO=SITUACAO.SITUACAO_ASSOC
)
group by DIA.CODIGO_EMPRESA, DIA.TIPO_CONTRATO, DIA.CODIGO_CONTRATO
)FALTAS
ON FALTAS.CODIGO_CONTRATO=C.CODIGO
AND FALTAS.TIPO_CONTRATO=C.TIPO_CONTRATO
AND FALTAS.CODIGO_EMPRESA=C.CODIGO_EMPRESA
WHERE C.ANO_MES_REFERENCIA=(SELECT MAX(AUX.ANO_MES_REFERENCIA) FROM ARTERH.RHPESS_CONTRATO AUX 
WHERE AUX.CODIGO=C.CODIGO
AND AUX.TIPO_CONTRATO=C.TIPO_CONTRATO
AND AUX.CODIGO_EMPRESA=C.CODIGO_EMPRESA)
AND C.DATA_RESCISAO IS NULL
and c.situacao_funcional not in (SELECT sit.situacao_funcional FROM arterh.RHPARM_SITFUN_GRUPO sit where sit.id_grupo_sit_func='1' and sit.codigo_empresa=c.codigo_empresa and sit.situacao_funcional=c.situacao_funcional)
AND NOT  (C.nivel_cargo_efetiv=1 AND CG.CODIGO IN ('000000000001417',
 '000000000001420',
 '000000000001421',
 '000000000001433',
 '000000000001440',
 '000000000001443',
 '000000000001513',
 '000000000001515',
 '000000000001735',
 '000000000001772',
 '000000000001783',
 '000000000001788',
 '000000000001789',
 '000000000001794',
 '000000000001616',
 '000000000001617',
 '000000000001618',
 '000000000001619',
 '000000000001620',
 '000000000001621',
 '000000000001734',
 '000000000001763',
 '000000000001434',
 '000000000001435',
 '000000000001818',
 '000000000001819' ))
AND NOT (C.nivel_cargo_efetiv=5 AND CG.CODIGO IN ('000000000001928', '000000000001924', '000000000001925'))
AND NOT (C.nivel_cargo_efetiv=12 AND CG.CODIGO IN ('000000000001508', '000000000001512'))

AND (
(CG.CODIGO IN ('000000000001772',
 '000000000001773',
 '000000000001774',
 '000000000001789',
 '000000000001790',
 '000000000001794',
 '000000000001795') and c.codigo_empresa='0001') OR (u.codigo_usuario IN ('pb003542' , 'pb003583'
 , 'pr00319906','pr114532','prcp3142599')))