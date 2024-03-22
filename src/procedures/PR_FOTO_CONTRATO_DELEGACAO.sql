
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_FOTO_CONTRATO_DELEGACAO" (CODIGO_CONTRATO IN VARCHAR2) AS
	cont NUMBER := 0;
BEGIN
	FOR c1 IN (
	SELECT
			c.codigo_empresa,
			sysdate                             AS data_log,
			c.tipo_contrato,
			c.codigo                            AS codigo_contrato,
			cg.codigo                           AS codigo_cargo_comiss,
			cg.descricao                        AS descricao_cargo_comiss,
			efg.codigo                          AS codigo_cargo_efetivo,
			efg.descricao                       AS descricao_cargo_efetivo,
			fg.codigo                           AS codigo_funcao,
			fg.descricao                        AS descricao_funcao,
			sf.codigo                           AS codigo_situcao_funcional,
			sf.descricao                        AS descricao_situacao_funcional,
			g.cod_cgerenc1                      AS cod_gerencial_1,
			g.cod_cgerenc2                      AS cod_gerencial_2,
			g.cod_cgerenc3                      AS cod_gerencial_3,
			g.cod_cgerenc4                      AS cod_gerencial_4,
			g.cod_cgerenc5                      AS cod_gerencial_5,
			g.cod_cgerenc6                      AS cod_gerencial_6,
			nvl(g.descricao, g.texto_associado) AS descricao_gerencial,
DEPARASITFUNC.DADO_DESTINO as SITUCAO_CONTRATO
		FROM
			     arterh.rhpess_contrato c
			left outer join arterh.rhparm_sit_func    sf
			ON sf.codigo = c.situacao_funcional
			left outer join arterh.rhplcs_cargo       cg
			ON cg.codigo_empresa = c.codigo_empresa
			   AND cg.codigo = c.cod_cargo_comiss
			left outer join arterh.rhplcs_cargo       efg
			ON efg.codigo_empresa = c.codigo_empresa
			   AND efg.codigo = c.cod_cargo_efetivo
			left outer join  arterh.rhplcs_funcao      fg
			ON fg.codigo_empresa = c.codigo_empresa
			   AND fg.codigo = c.codigo_funcao
			left outer join arterh.rhorga_custo_geren g
			ON g.codigo_empresa = c.codigo_empresa
			   AND g.cod_cgerenc1 = c.cod_custo_gerenc1
			   AND g.cod_cgerenc2 = c.cod_custo_gerenc2
			   AND g.cod_cgerenc3 = c.cod_custo_gerenc3
			   AND g.cod_cgerenc4 = c.cod_custo_gerenc4
			   AND g.cod_cgerenc5 = c.cod_custo_gerenc5
			   AND g.cod_cgerenc6 = c.cod_custo_gerenc6
left outer join (SELECT SUBSTR(dado_origem,0,4)AS CODIGO_EMPRESA, SUBSTR(dado_origem,5,4) AS SITUACAO_FUNCIONAL,DADO_DESTINO FROM ARTERH.RHINTE_ED_IT_CONV WHERE codigo_conversao='STDE')DEPARASITFUNC
ON DEPARASITFUNC.CODIGO_EMPRESA=C.CODIGO_EMPRESA
AND DEPARASITFUNC.SITUACAO_FUNCIONAL=C.SITUACAO_FUNCIONAL
		WHERE
			c.codigo_empresa IN ( '0001', '0003', '0013', '0014' )
			AND c.ano_mes_referencia = (
				SELECT
					MAX(aux.ano_mes_referencia)
				FROM
					arterh.rhpess_contrato aux
				WHERE
					aux.codigo_empresa = c.codigo_empresa
					AND aux.tipo_contrato = c.tipo_contrato
					AND aux.codigo = c.codigo
			)
AND C.CODIGO=LPAD(CODIGO_CONTRATO,15,0)
	) LOOP
		cont := cont + 1;
		INSERT INTO arterh.smarh_foto_contrato_delegacao (
			codigo_empresa,
			data_log,
			tipo_contrato,
			codigo_contrato,
			codigo_cargo_comiss,
			descricao_cargo_comiss,
			codigo_cargo_efetivo,
			descricao_cargo_efetivo,
			codigo_funcao,
			descricao_funcao,
			codigo_situcao_funcional,
			descricao_situacao_funcional,
			cod_gerencial_1,
			cod_gerencial_2,
			cod_gerencial_3,
			cod_gerencial_4,
			cod_gerencial_5,
			cod_gerencial_6,
			descricao_gerencial,
SITUCAO_CONTRATO
		) VALUES (
			c1.codigo_empresa,
			c1.data_log,
			c1.tipo_contrato,
			c1.codigo_contrato,
			c1.codigo_cargo_comiss,
			c1.descricao_cargo_comiss,
			c1.codigo_cargo_efetivo,
			c1.descricao_cargo_efetivo,
			c1.codigo_funcao,
			c1.descricao_funcao,
			c1.codigo_situcao_funcional,
			c1.descricao_situacao_funcional,
			c1.cod_gerencial_1,
			c1.cod_gerencial_2,
			c1.cod_gerencial_3,
			c1.cod_gerencial_4,
			c1.cod_gerencial_5,
			c1.cod_gerencial_6,
			c1.descricao_gerencial,
c1.SITUCAO_CONTRATO
		);

		COMMIT;
	END LOOP;
END;