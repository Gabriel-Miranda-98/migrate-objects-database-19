
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_NEW_ATUALIZA_DELEGACAO" AS
CONT NUMBER:=0;

v_DADOS_GESTOR TYPE_FINALIZAR_DELEGACAO_GESTOR;


BEGIN 

	FOR c1 IN (
		SELECT
			fim.*
		FROM
			(
				SELECT
					x.*,
					/*CASE
					WHEN x.codigo_cargo_comiss <> x.codigo_cargo_comiss_seguinte THEN
					'ALTEROU_CARGO_COMISS'
					ELSE
					'CARGO_COMISS_IGUAL'
					END AS status_cargo_comiss,*/
					CASE
					WHEN ( x.cod_gerencial_1 <> x.cod_gerencial_1_seguinte
					       OR x.cod_gerencial_2 <> x.cod_gerencial_2_seguinte
					       OR x.cod_gerencial_3 <> x.cod_gerencial_3_seguinte
					       OR x.cod_gerencial_4 <> x.cod_gerencial_4_seguinte
					       OR x.cod_gerencial_5 <> x.cod_gerencial_5_seguinte
					       OR x.cod_gerencial_6 <> x.cod_gerencial_6_seguinte ) THEN
					'ALTEROU_LOTACAO'
					ELSE
					'LOTACAO_IGUAL'
					END AS status_lotacao,
					/*CASE
					WHEN x.codigo_funcao <> x.codigo_funcao_seguinte THEN
					'ALTEROU_FUNCAO'
					ELSE
					'FUNCAO_IGUAL'
					END AS status_funcao,*/
					CASE
					WHEN x.situcao_contrato <> x.situcao_contrato_seguinte THEN
					'ALTEROU_SITUACAO_FUNCIONAL'
					ELSE
					'SITUCAO_FUNCIONAL_IGUAL'
					END AS status_contrato
				FROM
					(
						SELECT
							x.*
						FROM
							(
								SELECT
									x.codigo_empresa,
									x.tipo_contrato,
									x.codigo_contrato,
									ROW_NUMBER()
									OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
									     ORDER BY
											    x.codigo_empresa, x.codigo_contrato, x.tipo_contrato,
											    x.dados
									) ordem_bm,
									x.data_log,
									LEAD(x.data_log, 1, NULL)
									OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
									     ORDER BY
											    x.codigo_empresa,
											    x.codigo_contrato, x.tipo_contrato, x.dados
									) data_log_seguinte,
									x.dados,
									LEAD(x.dados, 1, NULL)
									OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
									     ORDER BY
											    x.codigo_empresa,
											    x.codigo_contrato, x.tipo_contrato, x.dados
									) dados_seguinte,
									x.codigo_cargo_comiss,
									LEAD(x.codigo_cargo_comiss, 1, NULL)
									OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
									     ORDER BY
											    x.codigo_empresa,
											    x.codigo_contrato, x.tipo_contrato, x.dados
									) codigo_cargo_comiss_seguinte,
									x.descricao_cargo_comiss,
									LEAD(x.descricao_cargo_comiss, 1, NULL)
									OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
									     ORDER BY
											    x.codigo_empresa,
											    x.codigo_contrato, x.tipo_contrato, x.dados
									) descricao_cargo_comiss_seguinte,
									x.codigo_cargo_efetivo,
									LEAD(x.codigo_cargo_efetivo, 1, NULL)
									OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
									     ORDER BY
											    x.codigo_empresa,
											    x.codigo_contrato, x.tipo_contrato, x.dados
									) codigo_cargo_efetivo_seguinte,
									x.descricao_cargo_efetivo,
									LEAD(x.descricao_cargo_efetivo, 1, NULL)
									OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
									     ORDER BY
											    x.codigo_empresa,
											    x.codigo_contrato, x.tipo_contrato, x.dados
									) descricao_cargo_efetivo_seguinte,
									x.codigo_funcao,
									LEAD(x.codigo_funcao, 1, NULL)
									OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
									     ORDER BY
											    x.codigo_empresa,
											    x.codigo_contrato, x.tipo_contrato, x.dados
									) codigo_funcao_seguinte,
									x.descricao_funcao,
									LEAD(x.descricao_funcao, 1, NULL)
									OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
									     ORDER BY
											    x.codigo_empresa,
											    x.codigo_contrato, x.tipo_contrato, x.dados
									) descricao_funcao_seguinte,
									x.codigo_situcao_funcional,
									LEAD(x.codigo_situcao_funcional, 1, NULL)
									OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
									     ORDER BY
											    x.codigo_empresa,
											    x.codigo_contrato, x.tipo_contrato, x.dados
									) codigo_situcao_funcional_seguinte,
									x.descricao_situacao_funcional,
									LEAD(x.descricao_situacao_funcional, 1, NULL)
									OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
									     ORDER BY
											    x.codigo_empresa,
											    x.codigo_contrato, x.tipo_contrato, x.dados
									) descricao_situacao_funcional_seguinte,
									x.cod_gerencial_1,
									LEAD(x.cod_gerencial_1, 1, NULL)
									OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
									     ORDER BY
											    x.codigo_empresa,
											    x.codigo_contrato, x.tipo_contrato, x.dados
									) cod_gerencial_1_seguinte,
									x.cod_gerencial_2,
									LEAD(x.cod_gerencial_2, 1, NULL)
									OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
									     ORDER BY
											    x.codigo_empresa,
											    x.codigo_contrato, x.tipo_contrato, x.dados
									) cod_gerencial_2_seguinte,
									x.cod_gerencial_3,
									LEAD(x.cod_gerencial_3, 1, NULL)
									OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
									     ORDER BY
											    x.codigo_empresa,
											    x.codigo_contrato, x.tipo_contrato, x.dados
									) cod_gerencial_3_seguinte,
									x.cod_gerencial_4,
									LEAD(x.cod_gerencial_4, 1, NULL)
									OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
									     ORDER BY
											    x.codigo_empresa,
											    x.codigo_contrato, x.tipo_contrato, x.dados
									) cod_gerencial_4_seguinte,
									x.cod_gerencial_5,
									LEAD(x.cod_gerencial_5, 1, NULL)
									OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
									     ORDER BY
											    x.codigo_empresa,
											    x.codigo_contrato, x.tipo_contrato, x.dados
									) cod_gerencial_5_seguinte,
									x.cod_gerencial_6,
									LEAD(x.cod_gerencial_6, 1, NULL)
									OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
									     ORDER BY
											    x.codigo_empresa,
											    x.codigo_contrato, x.tipo_contrato, x.dados
									) cod_gerencial_6_seguinte,
									x.descricao_gerencial,
									LEAD(x.descricao_gerencial, 1, NULL)
									OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
									     ORDER BY
											    x.codigo_empresa,
											    x.codigo_contrato, x.tipo_contrato, x.dados
									) descricao_gerencial_seguinte,
									x.situcao_contrato,
									LEAD(x.situcao_contrato, 1, NULL)
									OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
									     ORDER BY
											    x.codigo_empresa,
											    x.codigo_contrato, x.tipo_contrato, x.dados
									) situcao_contrato_seguinte
								FROM
									(
										SELECT
											'ULTIMO' AS dados,
											x.*
										FROM
											arterh.smarh_foto_contrato_delegacao x
										WHERE
											x.data_log = (
												SELECT
													MAX(aux.data_log)
												FROM
													arterh.smarh_foto_contrato_delegacao aux
											)
										UNION ALL
										SELECT
											'PENULTIMO' AS dados,
											x.*
										FROM
											arterh.smarh_foto_contrato_delegacao x
										WHERE
											x.data_log = (
												SELECT
													MAX(aux.data_log)
												FROM
													arterh.smarh_foto_contrato_delegacao aux
												WHERE
													aux.data_log < (
														SELECT
															MAX(data_log)
														FROM
															arterh.smarh_foto_contrato_delegacao
													)
											)
									) x
							) x
						WHERE
							x.ordem_bm = 1
					) x
			) fim
		WHERE
			( /*fim.status_cargo_comiss = 'ALTEROU_CARGO_COMISS'
			  OR
               OR fim.status_funcao = 'ALTEROU_FUNCAO'
              */ fim.status_lotacao = 'ALTEROU_LOTACAO'
			 
			  OR fim.status_contrato = 'ALTEROU_SITUACAO_FUNCIONAL' )
	) LOOP
    		cont := cont + 1;
    
    
v_DADOS_GESTOR:=BUSCAR_IDS_FINALIZAR(C1.CODIGO_EMPRESA, C1.TIPO_CONTRATO, C1.CODIGO_CONTRATO);


CASE WHEN v_DADOS_GESTOR.E_GESTOR ='S' THEN

UPDATE arterh.rhuser_pessoa_responsavel
			SET
				updated = sysdate,
				updatedby = 'PR_ATUALIZA_DELEGACAO',
                dt_fim_responsabilidade=sysdate
			WHERE
				to_char(id) MEMBER (v_DADOS_GESTOR.IDS) and dt_fim_responsabilidade is null;
                COMMIT;
                
         UPDATE ARTERH.rhuser_pessoa_resp_supervisao 
         SET  updatedby='PR_ATUALIZA_DELEGACAO',
         updated=sysdate,
         dt_fim_supervisao=sysdate  
         WHERE TO_CHAR(id_rhuser_pessoa_responsavel) MEMBER  (v_DADOS_GESTOR.IDS) AND dt_fim_supervisao IS NULL; 
         COMMIT;
                
ELSE

for r1 in (
SELECT * FROM ARTERH.rhuser_pessoa_resp_supervisao where codigo_empresa_ctr_subordinado=c1.codigo_empresa AND tipo_contrato_subordinado=c1.tipo_contrato AND codigo_contrato_subordinado=lpad(c1.codigo_contrato,15,0)AND dt_fim_supervisao IS NULL


)loop

 UPDATE ARTERH.rhuser_pessoa_resp_supervisao 
         SET  updatedby='PR_ATUALIZA_DELEGACAO',
         updated=sysdate,
         dt_fim_supervisao=sysdate  
         WHERE ID = R1.ID; 
         COMMIT;
end loop;


END CASE;



        END LOOP;


END;