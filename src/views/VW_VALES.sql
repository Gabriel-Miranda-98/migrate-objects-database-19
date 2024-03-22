
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_VALES" ("TIPO", "CODIGO_EMPRESA", "TIPO_CONTRATO", "CODIGO_CONTRATO", "DATA_INI_VIGENCIA", "DATA_FIM_VIGENCIA", "TIPO_VALE", "CODIGO_TARIFA", "VALOR_TOTAL", "QTDE_VALES", "SEQUENCIA") AS 
  select 'EXTRA' as TIPO,
           rhvale_rl_desl_lin.codigo_empresa,
					 rhvale_rl_desl_lin.tipo_contrato,
					 rhvale_rl_desl_lin.codigo_contrato,
           rhvale_rl_desl_lin.data_inicio as data_ini_vigencia,
           rhvale_rl_desl_lin.data_fim as data_fim_vigencia,
           rhvale_clas_tarifa.tipo_vale,
					 rhvale_clas_tarifa.codigo codigo_tarifa,
           rhvale_it_clas_tar.valor_total,
					 rhvale_rl_desl_lin.qtde_vales,
					 row_number() over (partition by rhvale_rl_desl_lin.codigo_contrato order by rhvale_rl_desl_lin.codigo_contrato) sequencia
			from rhvale_rl_desl_lin,
				   rhvale_rl_lin_itin,
				   rhvale_clas_tarifa,
				   rhvale_it_clas_tar
			where	rhvale_rl_desl_lin.codigo_linha = rhvale_rl_lin_itin.codigo_linha and
					  rhvale_rl_desl_lin.codigo_itinerario = rhvale_rl_lin_itin.codigo_itinerario and
					  rhvale_rl_lin_itin.cod_classe_tarifa = rhvale_clas_tarifa.codigo and
				    rhvale_clas_tarifa.codigo = rhvale_it_clas_tar.codigo and
					  rhvale_rl_desl_lin.data_inicio = (select max(a.data_inicio)
													 			 from rhvale_rl_desl_lin a
													 			 where rhvale_rl_desl_lin.codigo_contrato = a.codigo_contrato and
															 			 rhvale_rl_desl_lin.codigo_empresa = a.codigo_empresa and
															 			 rhvale_rl_desl_lin.tipo_contrato = a.tipo_contrato and
																		 rhvale_rl_desl_lin.codigo_linha = a.codigo_linha and
																		 rhvale_rl_desl_lin.codigo_itinerario = a.codigo_itinerario)
union
			select 'NORMAL' as TIPO,
           rhvale_transporte.codigo_empresa,
					 rhvale_transporte.tipo_contrato,
					 rhvale_transporte.codigo_contrato,
           rhvale_transporte.data_ini_vigencia,
           rhvale_transporte.data_fim_vigencia,
           rhvale_clas_tarifa.tipo_vale,
					 rhvale_clas_tarifa.codigo codigo_tarifa,
           rhvale_it_clas_tar.valor_total,
					 rhvale_transporte.qtde_vales,
					 row_number() over (partition by rhvale_transporte.codigo_contrato order by rhvale_transporte.codigo_contrato) sequencia
			from rhvale_transporte,
				   rhvale_rl_lin_itin,
				   rhvale_clas_tarifa,
				   rhvale_it_clas_tar
			where rhvale_transporte.codigo_linha = rhvale_rl_lin_itin.codigo_linha and
					  rhvale_transporte.codigo_itinerario = rhvale_rl_lin_itin.codigo_itinerario and
					  rhvale_rl_lin_itin.cod_classe_tarifa = rhvale_clas_tarifa.codigo and
				    rhvale_clas_tarifa.codigo = rhvale_it_clas_tar.codigo and
					  rhvale_transporte.codigo_itinerario not in ('1000')
 