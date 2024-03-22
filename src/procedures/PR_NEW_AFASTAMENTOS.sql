
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PR_NEW_AFASTAMENTOS" (vDATA_INICIO in date,vDATA_FIM in date, vLISTA_CODIGO_EMPRESA LISTA_EMPRESAS) AS
	cont                NUMBER := 0;
	vfechamento_sistema DATE;
    vQTD_IFPONTO  NUMBER := 0; --NOVO EM 19/6/23
    vQTD_ARTE  NUMBER := 0;--NOVO EM 19/6/23

BEGIN
for i in 1..vLISTA_CODIGO_EMPRESA.count()
LOOP
BEGIN
select max(data) as ultimo_fechamento into vfechamento_sistema from (
SELECT  trunc(data) as data, lpad(EMPRESA,4,0) as empresa FROM PONTO_ELETRONICO.ifponto_espelho_historica where empresa is not null
)where empresa=vLISTA_CODIGO_EMPRESA(I);
 exception
       when NO_DATA_FOUND then
    SELECT
		MAX(TO_DATE(dado_origem, 'DD/MM/YYYY'))
	INTO vfechamento_sistema
	FROM
		arterh.rhinte_ed_it_conv cv
	WHERE
		codigo_conversao = 'FCPT';
END;
/*BUSCAR DADOS TODOS OS REGISTROS DO ARTE QUE ESTAO EM ESPELHO ABERTO E DEVERIAM ESTAR NO IFPONTO*/
	FOR c1 IN (
		SELECT
			dados_para_ifponto.*
		FROM
			(
				SELECT
					xx.*
				FROM
					(
						SELECT
							x.empresa,
							x.agrupamento_empresa,
							x.codigo_legado,
							x.codigo_empresa,
							x.tipo_contrato,
							x.codigo_contrato,
							x.tipo,
							x.situacao_ponto AS codigo_justificativa,
							CASE
							WHEN TO_DATE(x.dt_ini_gozo, 'DD/MM/YYYY') <= TO_DATE(x.fechamento_sistema, 'DD/MM/YYYY')
							     AND x.fechamento_sistema IS NOT NULL THEN
							to_char(TO_DATE(x.fechamento_sistema, 'DD/MM/YYYY') + 1,
							        'DD/MM/YYYY')
							WHEN TO_DATE(x.dt_ini_gozo, 'DD/MM/YYYY') > TO_DATE(x.fechamento_sistema, 'DD/MM/YYYY')
							     AND x.fechamento_sistema IS NOT NULL THEN
							dt_ini_gozo
							ELSE
							x.dt_ini_gozo
							END              AS data_inicio,
							x.dt_fim_gozo    AS data_fim,
							x.dt_saiu_arte,
							'FERIAS'         origem,
							x.descricao_justificativa,
							x.pk_arte
						FROM
							(
								SELECT
									x.*
								FROM
									     (
										SELECT
											tg.codigo_empresa || tg.tipo_contrato || ltrim(tg.codigo_contrato, 0) ||
											CASE
											WHEN tg.tipo_comando = 'D' THEN
												tg.old_dt_ini_aquisicao
											ELSE
											tg.new_dt_ini_aquisicao
											END-- DT_INI_AQUISICAO,
											||
											CASE
											WHEN tg.tipo_comando = 'D' THEN
												tg.old_tipo_ferias
											ELSE
											tg.new_tipo_ferias
											END --TIPO_FERIAS,
											||
											CASE
											WHEN tg.tipo_comando = 'D' THEN
												tg.old_periodo
											ELSE
											tg.new_periodo
											END
											AS codigo_legado,
											tg.codigo_empresa,
											CASE
											WHEN tg.codigo_empresa = '0001' THEN
											'PREF.MUN.BELO HORIZONTE'
                                            WHEN tg.codigo_empresa = '0002' THEN
											'PRODABEL'
											WHEN tg.codigo_empresa = '0003' THEN
											'SUDECAP'
											WHEN tg.codigo_empresa = '0006' THEN
											'HOB'
											WHEN tg.codigo_empresa = '0013' THEN
											'FMC'
											WHEN tg.codigo_empresa = '0014' THEN
											'FMPZB'
											WHEN tg.codigo_empresa = '0098' THEN
											'PREF.MUN.BH CONTRATOS'
											END                                        AS empresa,
											CASE WHEN tg.codigo_empresa IN ('0001','0098') 
                                            THEN 'ADM DIRETA'
                                            ELSE 'ADM INDIRETA'
                                            END AS agrupamento_empresa,
											pf.situacao_ponto,
											tg.tipo_contrato,
											tg.codigo_contrato,
											tg.new_dt_ini_aquisicao                    AS dt_ini_aquisicao,
											tg.new_tipo_ferias                         AS tipo_ferias,
											tg.new_periodo                             AS periodo,
											to_char(tg.new_dt_ini_gozo, 'dd/mm/yyyy')  AS dt_ini_gozo,
											CASE
											WHEN tg.new_status_confirmacao = '1' THEN
											tg.new_dt_fim_gozo
											WHEN tg.new_status_confirmacao IN ( '5', 'D' ) THEN
											(
												SELECT
													MAX(dt.data_dia)
												FROM
													ponto_eletronico.sugesp_bi_rhferi_ferias fe,
													arterh.rhtabs_datas                      dt
												WHERE
													fe.codigo_empresa = tg.codigo_empresa
													AND fe.tipo_contrato = tg.tipo_contrato
													AND fe.new_dt_ini_aquisicao = tg.new_dt_ini_aquisicao
													AND fe.new_dt_fim_aquisicao = tg.new_dt_fim_aquisicao
													AND fe.codigo_contrato = tg.codigo_contrato
													AND dt.data_dia BETWEEN tg.new_dt_ini_gozo AND tg.new_dt_retorno - 1
													AND fe.new_status_confirmacao = tg.new_status_confirmacao
													AND dt.data_dia NOT IN (
														SELECT
															f.data_dia
														FROM
															arterh.rhparm_calend_dt f
														WHERE
															f.codigo = '0001'
															AND dt.data_dia = f.data_dia
													)
											)
											ELSE
											tg.new_dt_fim_gozo
											END                                        dt_fim_gozo,
											sysdate                                    AS dt_saiu_arte,
											'INCLUIR'                                  AS tipo,
											tg.dt_ult_alter_usua                       AS dt_ult_alter_usua,
											TO_DATE(vfechamento_sistema, 'DD/MM/YYYY') fechamento_sistema,
											pf.descricao                               AS descricao_justificativa,
											tg.codigo_empresa || tg.tipo_contrato || tg.codigo_contrato ||
											CASE
											WHEN tg.tipo_comando = 'D' THEN
												tg.old_dt_ini_aquisicao
											ELSE
											tg.new_dt_ini_aquisicao
											END-- DT_INI_AQUISICAO,
											||
											CASE
											WHEN tg.tipo_comando = 'D' THEN
												tg.old_tipo_ferias
											ELSE
											tg.new_tipo_ferias
											END --TIPO_FERIAS,
											||
											CASE
											WHEN tg.tipo_comando = 'D' THEN
												tg.old_periodo
											ELSE
											tg.new_periodo
											END --PERIODO
											pk_arte
										FROM
											     ponto_eletronico.sugesp_bi_rhferi_ferias tg
											INNER JOIN arterh.rhinte_ed_it_conv pontr
											ON substr(pontr.dado_origem, 20, 4) = tg.codigo_empresa
											   AND substr(pontr.dado_origem, 24, 4) = tg.tipo_contrato
											   AND pontr.codigo_conversao = 'PONT'
											INNER JOIN arterh.rhparm_p_feri     pf
											ON pf.codigo = tg.new_tipo_ferias
											   AND pf.codigo_empresa = tg.codigo_empresa
											INNER JOIN arterh.rhferi_ferias     f
											ON f.codigo_contrato = tg.codigo_contrato
											   AND f.tipo_contrato = tg.tipo_contrato
											   AND f.codigo_empresa = tg.codigo_empresa
											   AND f.tipo_ferias = tg.new_tipo_ferias
											   AND f.periodo = tg.new_periodo
											   AND f.dt_ini_aquisicao = tg.new_dt_ini_aquisicao
											   AND f.dt_fim_aquisicao = tg.new_dt_fim_aquisicao
											   AND f.dt_ini_gozo = tg.new_dt_ini_gozo
											   AND f.dt_fim_gozo = tg.new_dt_fim_gozo
										WHERE tg.codigo_empresa=vLISTA_CODIGO_EMPRESA(I) 
                                        and
											f.dt_ini_gozo IS NOT NULL
AND F.DT_ULT_ALTER_USUA<TO_DATE(SYSDATE,'DD/MM/YYYY')

											AND f.dt_fim_gozo IS NOT NULL
											AND --novo em 21/11/22
											 tg.new_dt_ini_gozo IS NOT NULL
											AND tg.new_dt_fim_gozo IS NOT NULL
											AND tg.new_status_confirmacao IN ( '1', '5', 'D', 'G' ) 
/*Gabriel aqui regra para olhar registros do dia*/
--AND trunc(TG.DT_ULT_ALTER_USUA) BETWEEN vDATA_INICIO AND vDATA_FIM

											AND ( tg.new_dt_ini_gozo >= TO_DATE(vfechamento_sistema, 'DD/MM/YYYY')
											      OR tg.new_dt_fim_gozo >= TO_DATE(vfechamento_sistema, 'DD/MM/YYYY') )
											AND tg.tipo_comando IN ( 'I', 'U' )
											AND tg.id = (
												SELECT
													MAX(aux.id)
												FROM
													ponto_eletronico.sugesp_bi_rhferi_ferias aux
												WHERE
													aux.codigo_empresa = tg.codigo_empresa
													AND aux.codigo_contrato = tg.codigo_contrato
													AND aux.tipo_contrato = tg.tipo_contrato
													AND aux.new_tipo_ferias = tg.new_tipo_ferias
													AND aux.new_periodo = tg.new_periodo
													AND aux.new_dt_ini_aquisicao = tg.new_dt_ini_aquisicao
													AND aux.new_dt_fim_aquisicao = tg.new_dt_fim_aquisicao
											)
									) x
									INNER JOIN arterh.vw_sit_func_ponto_ativo              xx
									ON xx.codigo_contrato = x.codigo_contrato
									   AND xx.tipo_contrato = x.tipo_contrato
									   AND xx.codigo_empresa = x.codigo_empresa
									INNER JOIN arterh.rhparm_sit_func                      sf
									ON sf.codigo = xx.cod_sit_funcional
									INNER JOIN ponto_eletronico.smarh_int_chave_integracao chave
									ON chave.codigo_empresa = xx.codigo_empresa
									   AND chave.codigo_situacao_funcional = sf.codigo
								WHERE
									sf.controle_folha NOT IN ( 'D', 'S' )
									AND sf.codigo NOT IN ( '1017' --COMENTADO EM 1/8/22 CASO BM 3099618--, '1851' 
									 )
									AND chave.chave_ifponto = 'ATIVO'
							) x
						WHERE
							( ( TO_DATE(x.dt_ini_gozo) > CASE
							                             WHEN TO_DATE(x.fechamento_sistema, 'DD/MM/YYYY') IS NULL THEN
							                             TO_DATE('01/01/2020', 'DD/MM/YYYY')
							                             ELSE
							                             TO_DATE(x.fechamento_sistema, 'DD/MM/YYYY')
							                             END )
							  OR ( TO_DATE(x.dt_fim_gozo) > CASE
							                                WHEN TO_DATE(x.fechamento_sistema, 'DD/MM/YYYY') IS NULL THEN
							                                TO_DATE('01/01/2020', 'DD/MM/YYYY')
							                                ELSE
							                                TO_DATE(x.fechamento_sistema, 'DD/MM/YYYY')
							                                END ) )
					) xx
--Gabriel 03/04/2023 resolvido o problema da lentidao, retorno do monitoramento das empresas do ponto
		--		WHERE
				--	xx.codigo_empresa IN ( '0001', '0002' )

------ferias
				UNION ALL

/*24/03/2023 GABRIEL NOVA INTEGRAÇÃO AFASTAMENTOS SEM DATA FIM */
				SELECT
					xx.*
				FROM
					(
						SELECT
							x.empresa,
							x.agrupamento_empresa,
							x.codigo_legado,
							x.codigo_empresa,
							x.tipo_contrato,
							x.codigo_contrato,
							x.tipo,
							x.codigo_justificativa,
							x.data_inicio,
							TO_DATE(x.data_fim, 'dd/mm/yyyy') AS data_fim,
							x.dt_saiu_arte,
							'AFASTAMENTOS_SEM_DATA_FIM'       AS origem,
							x.descricao                       AS descricao_justificativa,
							x.pk_arte
						FROM
							(
								SELECT
									x3.*
								FROM
									(
										SELECT
											CASE
											WHEN xx.codigo_empresa = '0001' THEN
											'PREF.MUN.BELO HORIZONTE'
                                            WHEN xx.codigo_empresa = '0002' THEN
											'PRODABEL'
											WHEN xx.codigo_empresa = '0003' THEN
											'SUDECAP'
											WHEN xx.codigo_empresa = '0006' THEN
											'HOB'
											WHEN xx.codigo_empresa = '0013' THEN
											'FMC'
											WHEN xx.codigo_empresa = '0014' THEN
											'FMPZB'
											WHEN xx.codigo_empresa = '0098' THEN
											'PREF.MUN.BH CONTRATOS'
											END AS empresa,
											CASE
											WHEN xx.codigo_empresa IN ( '0001', '0098', '0015', '0021', '0032' ) THEN
											'ADM DIRETA'
											ELSE
											'ADM INDIRETA'
											END AS agrupamento_empresa,
											xx.*
										FROM
											(
												SELECT
													fim.codigo_legado,
													fim.tipo,
													fim.codigo_empresa,
													fim.tipo_contrato,
													fim.codigo_contrato,
													fim.codigo_justificativa,
													fim.descricao,
													sysdate                             AS dt_saiu_arte,
													NULL                                AS dt_enviado_ifponto_suricato,
													CASE
													WHEN TO_DATE(fim.data_inicio, 'DD/MM/YYYY') <= TO_DATE(fim.fechamento_sistema, 'DD/MM/YYYY')
													     AND fim.fechamento_sistema IS NOT NULL THEN
													to_char(TO_DATE(fim.fechamento_sistema, 'DD/MM/YYYY') + 1,
													        'DD/MM/YYYY')
													WHEN TO_DATE(fim.data_inicio, 'DD/MM/YYYY') > TO_DATE(fim.fechamento_sistema, 'DD/MM/YYYY')
													     AND fim.fechamento_sistema IS NOT NULL THEN
													data_inicio
													ELSE
													fim.data_inicio
													END                                 AS data_inicio,
													fim.data_inicio_real,
													TO_DATE(fim.data_fim, 'dd/mm/yyyy') AS data_fim,
													fim.simula_data,
													fim.data_simulada,
													fim.pk_arte
												FROM
													(
														SELECT
															x.*
														FROM
															(
																SELECT
																	lc.codigo_empresa || lc.tipo_contrato || ltrim(lc.codigo, 0) || lc.data_inic_situacao AS codigo_legado,
																	'INCLUIR'                                                                             AS tipo,
																	lc.id,
																	lc.codigo_empresa,
																	lc.tipo_contrato,
																	lc.codigo                                                                             AS codigo_contrato,
																	lc.new_cod_sit_funcional                                                              AS situacao_funcional,
																	pn.codigo                                                                             AS codigo_justificativa,
																	pn.descricao,
																	to_char(lc.data_inic_situacao, 'DD/MM/YYYY')                                          AS data_inicio,
																	to_char(lc.data_inic_situacao, 'DD/MM/YYYY')                                          AS data_inicio_real,
																	CASE
																	WHEN to_char(lc.new_data_fim_situacao, 'DD/MM/YYYY') IS NULL THEN
																	to_char(last_day(sysdate),
																	        'DD/MM/YYYY')
																	ELSE
																	to_char(lc.new_data_fim_situacao, 'DD/MM/YYYY')
																	END                                                                                   AS data_fim,
																	CASE
																	WHEN to_char(lc.new_data_fim_situacao, 'DD/MM/YYYY') IS NULL THEN
																	'SIM'
																	ELSE
																	'NAO'
																	END                                                                                   AS simula_data,
																	CASE
																	WHEN to_char(lc.new_data_fim_situacao, 'DD/MM/YYYY') IS NULL THEN
																	to_char(last_day(sysdate),
																	        'DD/MM/YYYY')
																	ELSE
																	NULL
																	END                                                                                   AS data_simulada,
																	TO_DATE(vfechamento_sistema, 'DD/MM/YYYY')                                            fechamento_sistema,
																	lc.codigo_empresa || lc.tipo_contrato || lc.codigo || lc.data_inic_situacao           AS pk_arte
																FROM
																	arterh.smarh_int_pe_altsitfun_audbkp        lc
																	LEFT OUTER JOIN arterh.rhparm_sit_func                      sf
																	ON lc.new_cod_sit_funcional = sf.codigo
																	LEFT OUTER JOIN arterh.rhpont_situacao                      pn
																	ON sf.situacao_ponto = pn.codigo
																	LEFT OUTER JOIN arterh.rhpess_contrato                      c
																	ON c.codigo_empresa = lc.codigo_empresa
																	   AND c.codigo = lc.codigo
																	   AND c.tipo_contrato = lc.tipo_contrato
																	LEFT OUTER JOIN (
																		SELECT
																			*
																		FROM
																			rhinte_ed_it_conv
																		WHERE
																			codigo_conversao = 'PONT'
																	)                                           pontr
																	ON substr(pontr.dado_origem, 20, 4) = lc.codigo_empresa
																	   AND substr(pontr.dado_origem, 24, 4) = lc.tipo_contrato
																	LEFT OUTER JOIN arterh.vw_sit_func_ponto_ativo              x
																	ON x.codigo_contrato = lc.codigo
																	   AND x.tipo_contrato = lc.tipo_contrato
																	   AND x.codigo_empresa = lc.codigo_empresa
																	LEFT OUTER JOIN arterh.rhparm_sit_func                      s
																	ON s.codigo = x.cod_sit_funcional
																	INNER JOIN ponto_eletronico.smarh_int_chave_integracao chave
																	ON chave.codigo_empresa = c.codigo_empresa
																	   AND chave.codigo_situacao_funcional = s.codigo
																WHERE lc.codigo_empresa=vLISTA_CODIGO_EMPRESA(I) 
                                        and
																	substr(pontr.dado_origem, 20, 4) IS NOT NULL
																	AND tipo_dml IN ( 'U', 'I' )
/*Gabriel aqui regra para olhar registros do dia*/
--AND trunc(lc.DT_ULT_ALTER_USUA) BETWEEN vDATA_INICIO AND vDATA_FIM
																	AND lc.id = (
																		SELECT
																			MAX(aux.id)
																		FROM
																			arterh.smarh_int_pe_altsitfun_audbkp aux
																		WHERE
																			aux.codigo = lc.codigo
																			AND aux.tipo_contrato = lc.tipo_contrato
																			AND aux.codigo_empresa = lc.codigo_empresa
																			AND trunc(aux.data_inic_situacao) = trunc(lc.data_inic_situacao)
																	)
																	AND pn.tipo_situacao IN ( 'P', 'I', 'F' )
																	AND ( s.controle_folha NOT IN ( 'D', 'S' ) )
																	AND s.codigo NOT IN ( '1017', '1851' )
																	AND chave.chave_ifponto = 'ATIVO'
																	AND pn.c_livre_valor01 = '1'
															) x
														WHERE
--Gabriel 03/04/2023 resolvido o problema da lentidao, retorno do monitoramento das empresas do ponto

								---							x.codigo_empresa IN ( '0001', '0002' )
															 EXISTS (
																SELECT
																	f.*
																FROM
																	arterh.rhcged_alt_sit_fun f
																WHERE
																	f.codigo = x.codigo_contrato
																	AND f.codigo_empresa = x.codigo_empresa
																	AND f.tipo_contrato = x.tipo_contrato
																	AND f.cod_sit_funcional = x.situacao_funcional
																	AND trunc(f.data_inic_situacao) = trunc(TO_DATE(x.data_inicio, 'DD/MM/YYYY'))
AND F.DT_ULT_ALTER_USUA<TO_DATE(SYSDATE,'DD/MM/YYYY')

															)
															AND x.simula_data = 'SIM'
													) fim
												WHERE
													TO_DATE(fim.data_fim, 'DD/MM/YYYY') > CASE
													                                      WHEN TO_DATE(fim.fechamento_sistema, 'DD/MM/YYYY') IS NULL THEN
													                                      TO_DATE('01/01/2020', 'DD/MM/YYYY')
													                                      ELSE
													                                      TO_DATE(fim.fechamento_sistema, 'DD/MM/YYYY')
													                                      END
											) xx
									) x3
								GROUP BY
									x3.empresa,
									x3.agrupamento_empresa,
									x3.codigo_legado,
									x3.tipo,
									x3.codigo_empresa,
									x3.tipo_contrato,
									x3.codigo_contrato,
									x3.codigo_justificativa,
									x3.descricao,
									x3.dt_saiu_arte,
									x3.dt_enviado_ifponto_suricato,
									x3.data_inicio,
									x3.data_inicio_real,
									x3.data_fim,
									x3.simula_data,
									x3.data_simulada,
									x3.pk_arte
							) x
					) xx
				UNION ALL
/*GABRIEL 24/03/2023 AFASTAMENTOS COM DATA FIM */
				SELECT
					xx.*
				FROM
					(
						SELECT
							CASE
							WHEN x.codigo_empresa = '0001' THEN
							'PREF.MUN.BELO HORIZONTE'
                            WHEN x.codigo_empresa = '0002' THEN
                            'PRODABEL'
                            WHEN x.codigo_empresa = '0003' THEN
                            'SUDECAP'
                            WHEN x.codigo_empresa = '0006' THEN
                            'HOB'
                            WHEN x.codigo_empresa = '0013' THEN
                            'FMC'
                            WHEN x.codigo_empresa = '0014' THEN
                            'FMPZB'
							WHEN x.codigo_empresa = '0098' THEN
							'PREF.MUN.BH CONTRATOS'
							END                               AS empresa,
							CASE WHEN x.codigo_empresa IN ('0001','0098') 
                            THEN 'ADM DIRETA'
                            ELSE 'ADM INDIRETA'
                            END                        AS agrupamento_empresa,
							x.codigo_legado,
							x.codigo_empresa,
							x.tipo_contrato,
							x.codigo_contrato,
							x.tipo,
							x.codigo_justificativa,
							  CASE
        WHEN TO_DATE(x.DATA_INICIO,'DD/MM/YYYY')<= TO_DATE(x.FECHAMENTO_SISTEMA,'DD/MM/YYYY')  and x.FECHAMENTO_SISTEMA IS NOT NULL
        THEN TO_CHAR(TO_DATE(x.FECHAMENTO_SISTEMA,'DD/MM/YYYY')+1,'DD/MM/YYYY')
        WHEN TO_DATE(x.DATA_INICIO,'DD/MM/YYYY')>TO_DATE(x.FECHAMENTO_SISTEMA,'DD/MM/YYYY') AND x.FECHAMENTO_SISTEMA IS NOT  NULL
        THEN DATA_INICIO
ELSE x.DATA_INICIO
      END AS DATA_INICIO,
							TO_DATE(x.data_fim, 'DD/MM/YYYY') AS data_fim,
							sysdate                           AS dt_saiu_arte,
							'AFASTAMENTOS_COM_DATA_FIM'       AS origem,
							x.descricao                       AS descricao_justificativa,
							x.pk_arte
						FROM
							(
								SELECT
									lc.codigo_empresa || lc.tipo_contrato || ltrim(lc.codigo) || lc.data_inic_situacao AS codigo_legado,
									'INCLUIR'                                                                          AS tipo,
									lc.id,
									lc.codigo_empresa,
									lc.tipo_contrato,
									lc.codigo                                                                          AS codigo_contrato,
									lc.new_cod_sit_funcional                                                           AS situacao_funcional,
									pn.codigo                                                                          AS codigo_justificativa,
									pn.descricao,
									to_char(lc.data_inic_situacao, 'DD/MM/YYYY')                                       AS data_inicio,
									to_char(lc.new_data_fim_situacao, 'DD/MM/YYYY')                                    AS data_fim,
									TO_DATE(vfechamento_sistema, 'DD/MM/YYYY')                                         AS fechamento_sistema,
									lc.codigo_empresa || lc.tipo_contrato || lc.codigo || lc.data_inic_situacao        AS pk_arte
								FROM
									arterh.smarh_int_pe_altsitfun_audbkp        lc
									LEFT OUTER JOIN arterh.rhparm_sit_func                      sf
									ON lc.new_cod_sit_funcional = sf.codigo
									LEFT OUTER JOIN arterh.rhpont_situacao                      pn
									ON sf.situacao_ponto = pn.codigo
									LEFT OUTER JOIN (
										SELECT
											*
										FROM
											rhinte_ed_it_conv
										WHERE
											codigo_conversao = 'PONT'
									)                                           pontr
									ON substr(pontr.dado_origem, 20, 4) = lc.codigo_empresa
									   AND substr(pontr.dado_origem, 24, 4) = lc.tipo_contrato
									LEFT OUTER JOIN arterh.vw_sit_func_ponto_ativo              x
									ON x.codigo_contrato = lc.codigo
									   AND x.tipo_contrato = lc.tipo_contrato
									   AND x.codigo_empresa = lc.codigo_empresa
									LEFT OUTER JOIN arterh.rhparm_sit_func                      s
									ON s.codigo = x.cod_sit_funcional
									INNER JOIN ponto_eletronico.smarh_int_chave_integracao chave
									ON chave.codigo_empresa = lc.codigo_empresa
									   AND chave.codigo_situacao_funcional = s.codigo
								WHERE lc.codigo_empresa=vLISTA_CODIGO_EMPRESA(I) 
                                        and
									substr(pontr.dado_origem, 20, 4) IS NOT NULL
									AND tipo_dml IN ( 'I','U' )
/*Gabriel aqui regra para olhar registros do dia*/
--AND trunc(lc.DT_ULT_ALTER_USUA) BETWEEN vDATA_INICIO AND vDATA_FIM
									AND lc.id = (
										SELECT
											MAX(aux.id)
										FROM
											arterh.smarh_int_pe_altsitfun_audbkp aux
										WHERE
											aux.codigo = lc.codigo
											AND aux.tipo_contrato = lc.tipo_contrato
											AND aux.codigo_empresa = lc.codigo_empresa
											AND trunc(aux.data_inic_situacao) = trunc(lc.data_inic_situacao)
									)
									AND pn.tipo_situacao IN ( 'P', 'I', 'F' )
									AND ( s.controle_folha NOT IN ( 'D', 'S' ) )
									AND s.codigo NOT IN ( '1017', '1851' )
									AND chave.chave_ifponto = 'ATIVO'
									AND pn.c_livre_valor01 = '1'
							)                         x
							LEFT OUTER JOIN arterh.rhcged_alt_sit_fun f
							ON f.codigo = x.codigo_contrato
							   AND f.codigo_empresa = x.codigo_empresa
							   AND f.tipo_contrato = x.tipo_contrato
							   AND f.cod_sit_funcional = x.situacao_funcional
							   AND trunc(f.data_inic_situacao) = trunc(TO_DATE(x.data_inicio, 'DD/MM/YYYY'))
						WHERE
							f.codigo_empresa IS NOT NULL
AND F.DT_ULT_ALTER_USUA<TO_DATE(SYSDATE,'DD/MM/YYYY')
AND X.DATA_FIM IS NOT NULL
							AND ( TO_DATE(x.data_inicio, 'DD/MM/YYYY') > TO_DATE(x.fechamento_sistema, 'DD/MM/YYYY')
							      OR TO_DATE(x.data_fim, 'DD/MM/YYYY') > TO_DATE(x.fechamento_sistema, 'DD/MM/YYYY') )
--Gabriel 03/04/2023 resolvido o problema da lentidao, retorno do monitoramento das empresas do ponto

				--			AND x.codigo_empresa IN ( '0001', '0002' )

					) xx
			) dados_para_ifponto
	) LOOP
		cont := cont + 1;
		INSERT INTO ponto_eletronico.sugesp_bi_afastamentos (
			empresa,
			agrupamento_empresa,
			codigo_legado,
			codigo_empresa,
			tipo_contrato,
			codigo_contrato,
			codigo_justificativa,
			descricao,
			data_inicio,
			data_fim,
			tipo,
			dt_saiu_arte,
			origem,
			pk_arte
		) VALUES (
			c1.empresa,
			c1.agrupamento_empresa,
			c1.codigo_legado,
			c1.codigo_empresa,
			c1.tipo_contrato,
			c1.codigo_contrato,
			c1.codigo_justificativa,
			c1.descricao_justificativa,
			c1.data_inicio,
			c1.data_fim,
			c1.tipo,
			c1.dt_saiu_arte,
			'ACERTO_BASE',
			c1.pk_arte
		);

		COMMIT;
	END LOOP;


select count(1) INTO vQTD_IFPONTO from ponto_eletronico.ifponto_afastamentos;

select count(1) INTO vQTD_ARTE from PONTO_ELETRONICO.sugesp_bi_afastamentos;


IF vQTD_IFPONTO <> 0 AND vQTD_ARTE <> 0 THEN --IF NOVO EM 19/6/23
dbms_output.put_line('--OK vQTD_IFPONTO: '||vQTD_IFPONTO||' vQTD_ARTE: '||vQTD_ARTE);  

/*POPULAR REGISTROS PARA VIEW DE INTEGRACAO*/
	BEGIN
		cont := 0;
		FOR c2 IN (SELECT CASE
						WHEN x.codigo_empresa = '0001' THEN
						'PREF.MUN.BELO HORIZONTE'
                        WHEN x.codigo_empresa = '0002' THEN
                        'PRODABEL'
                        WHEN x.codigo_empresa = '0003' THEN
                        'SUDECAP'
                        WHEN x.codigo_empresa = '0006' THEN
                        'HOB'
                        WHEN x.codigo_empresa = '0013' THEN
                        'FMC'
                        WHEN x.codigo_empresa = '0014' THEN
                        'FMPZB'
						WHEN x.codigo_empresa = '0098' THEN
						'PREF.MUN.BH CONTRATOS'
						END                  AS empresa,
						CASE WHEN x.codigo_empresa IN ('0001','0098') 
                        THEN 'ADM DIRETA'
                        ELSE 'ADM INDIRETA'
                        END AS agrupamento_empresa,
						'ACERTO_BASE'        AS origem,
						x.codigo_empresa,
						x.tipo_contrato,
						x.codigo_contrato,
						x.codigo_legado,
						x.codigo_justificativa,
						x.DESCRICAO AS descricao_justificativa,
						sysdate              AS dt_saiu_arte,
                        X.TIPO,
                      --  X.ORIGEM AS REGISTRO_ORIGEM,
                        x.data_inicio,
						x.data_fim,
						CASE WHEN x.pk_arte IS NULL THEN X.CODIGO_LEGADO ELSE x.pk_arte END AS PK_ARTE,
                        X.CHAVE_INTEGRACAO
                       FROM (select x.* from (SELECT
								'ATUALIZAR' AS TIPO,
								'ARTE'    AS origem,
								a.codigo_empresa,
								a.tipo_contrato,
								a.codigo_contrato,
								a.codigo_legado,
								a.codigo_justificativa,
								a.descricao,
								/*case when a.data_inicio < TO_DATE(vfechamento_sistema, 'DD/MM/YYYY') then TO_DATE(vfechamento_sistema, 'DD/MM/YYYY') else a.data_inicio end as data_inicio ,*/
                                a.data_inicio,
								case when a.data_fim > TO_DATE(vfechamento_sistema, 'DD/MM/YYYY') then a.data_fim else  TO_DATE(vfechamento_sistema, 'DD/MM/YYYY') end as data_fim ,
								a.pk_arte,
    CASE WHEN V.RETORNO_FOTO IS NOT NULL THEN V.RETORNO_FOTO ELSE CHAVE.DADO_DESTINO END AS CHAVE_INTEGRACAO

							FROM
								ponto_eletronico.sugesp_bi_afastamentos a
LEFT OUTER JOIN (SELECT * FROM ARTERH.RHPESS_CONTRATO C
WHERE C.ANO_MES_REFERENCIA=(SELECT MAX(AUX.ANO_MES_REFERENCIA) FROM ARTERH.RHPESS_CONTRATO AUX 
WHERE AUX.CODIGO=C.CODIGO
AND AUX.TIPO_CONTRATO=C.TIPO_CONTRATO
AND AUX.CODIGO_EMPRESA=C.CODIGO_EMPRESA)
and c.codigo_empresa=vLISTA_CODIGO_EMPRESA(I) 
                                        
)X
ON X.CODIGO=A.CODIGO_CONTRATO
AND X.TIPO_CONTRATO=A.TIPO_CONTRATO
AND X.CODIGO_EMPRESA=A.CODIGO_EMPRESA
LEFT OUTER JOIN  ARTERH.RHINTE_ED_IT_CONV CHAVE ON SUBSTR(CHAVE.DADO_ORIGEM,0,4)=X.CODIGO_EMPRESA AND SUBSTR(CHAVE.DADO_ORIGEM,5,4)=X.SITUACAO_FUNCIONAL AND CHAVE.CODIGO_CONVERSAO='POST'
LEFT OUTER JOIN ARTERH.VW_PONTO_1017_FOTO V ON V.CODIGO_EMPRESA=X.CODIGO_EMPRESA AND V.CODIGO_CONTRATO=X.CODIGO AND V.TIPO_CONTRATO=X.TIPO_CONTRATO
							WHERE
								a.origem = 'ACERTO_BASE'
								AND trunc(a.dt_saiu_arte) = trunc(sysdate)
and x.situacao_funcional not in ('1851')

								AND NOT EXISTS (
									SELECT
										*
									FROM
										ponto_eletronico.ifponto_afastamentos PONTO
									WHERE
										a.codigo_empresa = PONTO.codigo_empresa
										AND a.codigo_contrato = PONTO.codigo_contrato
										AND a.tipo_contrato = PONTO.tipo_contrato
										AND a.codigo_justificativa = PONTO.codigo_justificativa--AJUSTADO 16/11/22
                                        AND A.CODIGO_LEGADO=PONTO.CODIGO_LEGADO
										AND TRUNC(TO_DATE(PONTO.data_inicio, 'DD/MM/YYYY')) =  TRUNC(TO_DATE(A.data_inicio, 'DD/MM/YYYY'))
                                        AND  TRUNC(TO_DATE(PONTO.DATA_FIM, 'DD/MM/YYYY')) =  TRUNC(TO_DATE(A.DATA_FIM, 'DD/MM/YYYY'))
								)
                                  AND TO_DATE(A.data_inicio, 'DD/MM/YYYY') <= TO_DATE(vfechamento_sistema, 'DD/MM/YYYY')--MUDAR PARA V_SISTAMA
                                  AND TO_DATE(A.data_fim, 'DD/MM/YYYY') >= TO_DATE(vfechamento_sistema, 'DD/MM/YYYY')
                               --    AND A.codigo_contrato=lpad('868616',15,0) and A.tipo_contrato='0001' and A.codigo_empresa='0001'
                    union all
                    				SELECT
								'ATUALIZAR' AS TIPO,
								'IFPONTO'              AS origem,

								PONTO.codigo_empresa,
								PONTO.tipo_contrato,
								PONTO.codigo_contrato,
								PONTO.codigo_legado,
								PONTO.codigo_justificativa,
								PONTO.nome_justificativa,
								PONTO.data_inicio,
                                TO_DATE(vfechamento_sistema, 'DD/MM/YYYY')  data_fim ,
								PONTO.pk_arte,
    CASE WHEN V.RETORNO_FOTO IS NOT NULL THEN V.RETORNO_FOTO ELSE CHAVE.DADO_DESTINO END AS CHAVE_INTEGRACAO

							FROM
								ponto_eletronico.ifponto_afastamentos PONTO
LEFT OUTER JOIN (SELECT * FROM ARTERH.RHPESS_CONTRATO C
WHERE C.ANO_MES_REFERENCIA=(SELECT MAX(AUX.ANO_MES_REFERENCIA) FROM ARTERH.RHPESS_CONTRATO AUX 
WHERE AUX.CODIGO=C.CODIGO
AND AUX.TIPO_CONTRATO=C.TIPO_CONTRATO
AND AUX.CODIGO_EMPRESA=C.CODIGO_EMPRESA)
and  c.codigo_empresa=vLISTA_CODIGO_EMPRESA(I)
)X
ON X.CODIGO=PONTO.CODIGO_CONTRATO
AND X.TIPO_CONTRATO=PONTO.TIPO_CONTRATO
AND X.CODIGO_EMPRESA=PONTO.CODIGO_EMPRESA
LEFT OUTER JOIN  ARTERH.RHINTE_ED_IT_CONV CHAVE ON SUBSTR(CHAVE.DADO_ORIGEM,0,4)=X.CODIGO_EMPRESA AND SUBSTR(CHAVE.DADO_ORIGEM,5,4)=X.SITUACAO_FUNCIONAL AND CHAVE.CODIGO_CONVERSAO='POST'
LEFT OUTER JOIN ARTERH.VW_PONTO_1017_FOTO V ON V.CODIGO_EMPRESA=X.CODIGO_EMPRESA AND V.CODIGO_CONTRATO=X.CODIGO AND V.TIPO_CONTRATO=X.TIPO_CONTRATO

							WHERE
x.situacao_funcional not in ('1851')
and 
								NOT EXISTS (
									SELECT
										*
									FROM
										ponto_eletronico.sugesp_bi_afastamentos a
									WHERE
										a.codigo_empresa = PONTO.codigo_empresa
										AND a.codigo_contrato = PONTO.codigo_contrato
										AND a.tipo_contrato = PONTO.tipo_contrato
										AND a.codigo_justificativa = PONTO.codigo_justificativa
                                        AND A.CODIGO_LEGADO=PONTO.CODIGO_LEGADO
										AND a.origem = 'ACERTO_BASE'
										AND trunc(a.dt_saiu_arte) = trunc(sysdate)
                                        AND ( TRUNC(TO_DATE(PONTO.data_inicio, 'DD/MM/YYYY')) =  TRUNC(TO_DATE(A.data_inicio, 'DD/MM/YYYY'))
                                        AND  TRUNC(TO_DATE(PONTO.DATA_FIM, 'DD/MM/YYYY')) =  TRUNC(TO_DATE(A.DATA_FIM, 'DD/MM/YYYY')) 
                                        OR (TRUNC(TO_DATE(A.DATA_FIM, 'DD/MM/YYYY'))<>TRUNC(TO_DATE(PONTO.DATA_FIM, 'DD/MM/YYYY')) AND TRUNC(TO_DATE(A.DATA_FIM, 'DD/MM/YYYY')) > TO_DATE(vfechamento_sistema))
                                        )
										/*AND TRUNC(TO_DATE(PONTO.data_inicio, 'DD/MM/YYYY')) =  TRUNC(TO_DATE(A.data_inicio, 'DD/MM/YYYY'))
                                        AND  TRUNC(TO_DATE(PONTO.DATA_FIM, 'DD/MM/YYYY')) =  TRUNC(TO_DATE(A.DATA_FIM, 'DD/MM/YYYY'))*/

                                        )


                                    AND (TO_DATE(PONTO.data_inicio, 'DD/MM/YYYY') <=TO_DATE(vfechamento_sistema) AND to_date(PONTO.data_fim, 'DD/MM/YYYY') >= TO_DATE(vfechamento_sistema))
								    AND PONTO.codigo_justificativa NOT IN ( '0580' )
                                    -- AND PONTO.codigo_contrato=lpad('868616',15,0) and PONTO.tipo_contrato='0001' and PONTO.codigo_empresa='0001'



  )x    
  UNION ALL 

							SELECT
								'EXCLUIR' AS TIPO,
								'IFPONTO'              AS origem,

								PONTO.codigo_empresa,
								PONTO.tipo_contrato,
								PONTO.codigo_contrato,
								PONTO.codigo_legado,
								PONTO.codigo_justificativa,
								PONTO.nome_justificativa,
								PONTO.data_inicio,
								PONTO.data_fim,
								PONTO.pk_arte,
    CASE WHEN V.RETORNO_FOTO IS NOT NULL THEN V.RETORNO_FOTO ELSE CHAVE.DADO_DESTINO END AS CHAVE_INTEGRACAO

							FROM
								ponto_eletronico.ifponto_afastamentos PONTO
LEFT OUTER JOIN (SELECT * FROM ARTERH.RHPESS_CONTRATO C
WHERE C.ANO_MES_REFERENCIA=(SELECT MAX(AUX.ANO_MES_REFERENCIA) FROM ARTERH.RHPESS_CONTRATO AUX 
WHERE AUX.CODIGO=C.CODIGO
AND AUX.TIPO_CONTRATO=C.TIPO_CONTRATO
AND AUX.CODIGO_EMPRESA=C.CODIGO_EMPRESA)
and  c.codigo_empresa=vLISTA_CODIGO_EMPRESA(I)

)X
ON X.CODIGO=PONTO.CODIGO_CONTRATO
AND X.TIPO_CONTRATO=PONTO.TIPO_CONTRATO
AND X.CODIGO_EMPRESA=PONTO.CODIGO_EMPRESA
LEFT OUTER JOIN  ARTERH.RHINTE_ED_IT_CONV CHAVE ON SUBSTR(CHAVE.DADO_ORIGEM,0,4)=X.CODIGO_EMPRESA AND SUBSTR(CHAVE.DADO_ORIGEM,5,4)=X.SITUACAO_FUNCIONAL AND CHAVE.CODIGO_CONVERSAO='POST'
LEFT OUTER JOIN ARTERH.VW_PONTO_1017_FOTO V ON V.CODIGO_EMPRESA=X.CODIGO_EMPRESA AND V.CODIGO_CONTRATO=X.CODIGO AND V.TIPO_CONTRATO=X.TIPO_CONTRATO

							WHERE
x.situacao_funcional not in ('1851')
and 
								NOT EXISTS (
									SELECT
										*
									FROM
										ponto_eletronico.sugesp_bi_afastamentos a
									WHERE
										a.codigo_empresa = PONTO.codigo_empresa
										AND a.codigo_contrato = PONTO.codigo_contrato
										AND a.tipo_contrato = PONTO.tipo_contrato
										AND a.codigo_justificativa = PONTO.codigo_justificativa
                                        AND A.CODIGO_LEGADO=PONTO.CODIGO_LEGADO
										AND a.origem = 'ACERTO_BASE'
										AND trunc(a.dt_saiu_arte) = trunc(sysdate)
										AND TRUNC(TO_DATE(PONTO.data_inicio, 'DD/MM/YYYY')) =  TRUNC(TO_DATE(A.data_inicio, 'DD/MM/YYYY'))
                                        AND  TRUNC(TO_DATE(PONTO.DATA_FIM, 'DD/MM/YYYY')) =  TRUNC(TO_DATE(A.DATA_FIM, 'DD/MM/YYYY'))

                                        )


                                    AND TO_DATE(PONTO.data_inicio, 'DD/MM/YYYY') >TO_DATE(vfechamento_sistema, 'DD/MM/YYYY')--MUDAR PARA V_SISTAMA
								    AND PONTO.codigo_justificativa NOT IN ( '0580' )
                            --    AND PONTO.codigo_contrato=lpad('868616',15,0) and PONTO.tipo_contrato='0001' and PONTO.codigo_empresa='0001'


UNION ALL 
SELECT
								'INCLUIR' AS TIPO,
								'ARTE'    AS origem,
								a.codigo_empresa,
								a.tipo_contrato,
								a.codigo_contrato,
								a.codigo_legado,
								a.codigo_justificativa,
								a.descricao,
								a.data_inicio,
								a.data_fim,
								a.pk_arte,
    CASE WHEN V.RETORNO_FOTO IS NOT NULL THEN V.RETORNO_FOTO ELSE CHAVE.DADO_DESTINO END AS CHAVE_INTEGRACAO

							FROM
								ponto_eletronico.sugesp_bi_afastamentos a
LEFT OUTER JOIN (SELECT * FROM ARTERH.RHPESS_CONTRATO C
WHERE C.ANO_MES_REFERENCIA=(SELECT MAX(AUX.ANO_MES_REFERENCIA) FROM ARTERH.RHPESS_CONTRATO AUX 
WHERE AUX.CODIGO=C.CODIGO
AND AUX.TIPO_CONTRATO=C.TIPO_CONTRATO
AND AUX.CODIGO_EMPRESA=C.CODIGO_EMPRESA)
and  c.codigo_empresa=vLISTA_CODIGO_EMPRESA(I)

)X
ON X.CODIGO=A.CODIGO_CONTRATO
AND X.TIPO_CONTRATO=A.TIPO_CONTRATO
AND X.CODIGO_EMPRESA=A.CODIGO_EMPRESA
LEFT OUTER JOIN  ARTERH.RHINTE_ED_IT_CONV CHAVE ON SUBSTR(CHAVE.DADO_ORIGEM,0,4)=X.CODIGO_EMPRESA AND SUBSTR(CHAVE.DADO_ORIGEM,5,4)=X.SITUACAO_FUNCIONAL AND CHAVE.CODIGO_CONVERSAO='POST'
LEFT OUTER JOIN ARTERH.VW_PONTO_1017_FOTO V ON V.CODIGO_EMPRESA=X.CODIGO_EMPRESA AND V.CODIGO_CONTRATO=X.CODIGO AND V.TIPO_CONTRATO=X.TIPO_CONTRATO
							WHERE
								a.origem = 'ACERTO_BASE'
								AND trunc(a.dt_saiu_arte) = trunc(sysdate)
and x.situacao_funcional not in ('1851')

								AND NOT EXISTS (
									SELECT
										*
									FROM
										ponto_eletronico.ifponto_afastamentos PONTO
									WHERE
										a.codigo_empresa = PONTO.codigo_empresa
										AND a.codigo_contrato = PONTO.codigo_contrato
										AND a.tipo_contrato = PONTO.tipo_contrato
										AND a.codigo_justificativa = PONTO.codigo_justificativa--AJUSTADO 16/11/22
                                        AND A.CODIGO_LEGADO=PONTO.CODIGO_LEGADO
										AND TRUNC(TO_DATE(PONTO.data_inicio, 'DD/MM/YYYY')) =  TRUNC(TO_DATE(A.data_inicio, 'DD/MM/YYYY'))
                                        AND  TRUNC(TO_DATE(PONTO.DATA_FIM, 'DD/MM/YYYY')) =  TRUNC(TO_DATE(A.DATA_FIM, 'DD/MM/YYYY'))
								)
                                  AND TO_DATE(A.data_inicio, 'DD/MM/YYYY') >TO_DATE(vfechamento_sistema, 'DD/MM/YYYY')--MUDAR PARA V_SISTAMA
                               --    AND A.codigo_contrato=lpad('868616',15,0) and A.tipo_contrato='0001' and A.codigo_empresa='0001'

)X

where x.chave_integracao='ATIVO'
		) LOOP
			cont := cont + 1;
			INSERT INTO ponto_eletronico.smarh_int_pe_afastamentos_v1 (
				empresa,
				agrupamento_empresa,
				codigo_legado,
				tipo,
				codigo_empresa,
				tipo_contrato,
				codigo_contrato,
				codigo_justificativa,
				descricao,
				data_inicio,
				data_fim,
				dt_saiu_arte,
				origem,
				codigo_integra_arte,
				pk_arte
			) VALUES (
				c2.empresa,
				c2.agrupamento_empresa,
				c2.codigo_legado,
				c2.tipo,
				c2.codigo_empresa,
				c2.tipo_contrato,
				c2.codigo_contrato,
				c2.codigo_justificativa,
				c2.descricao_justificativa,
				c2.data_inicio,
				c2.data_fim,
				c2.dt_saiu_arte,
				c2.origem,
				ponto_eletronico.sequence_integra_arte.nextval,
				c2.pk_arte
			);

			COMMIT;
		END LOOP;



	END;

ELSE   --IF NOVO EM 19/6/23 
dbms_output.put_line('--ERRO vQTD_IFPONTO: '||vQTD_IFPONTO||' vQTD_ARTE: '||vQTD_ARTE);  
END IF;--IF NOVO EM 19/6/23




END LOOP;

END;