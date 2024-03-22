
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."SMARH_INT_PE_ATUALIZA_ARTE_V1" AS
BEGIN
    DECLARE
        vcontador NUMBER;
    BEGIN
        dbms_output.enable(NULL);
        vcontador := 0;
        FOR c1 IN--- INICIO DO FOR
         (
            SELECT
                *
            FROM
                ponto_eletronico.view_select_base_for_atualiza_ifponto_arte
        )  -----FIM DO FOR
         LOOP---- 1 LOOP;
            vcontador := vcontador + 1;


-------------------------------------------------------------------------------------------------------------------------COMECO_ARTERH-------------------------------------------------------------------------------------------

--ACAO 1 NO ARTERH --MARCADO 07/12/22
   -----------------------------------------------------------------MARACA SIM NO CAMPO INTEGRAGO NO CONTRATO DOS  NOVOS CADASTROS-------------------------------------------------------------
            IF ( c1.tipo_vw_dados_servidor = 'DIARIA_NOVOS' ) THEN
                UPDATE arterh.rhpess_contrato x
                SET
                    x.usa_assoc_cont_esc = 'S',
                    x.login_usuario = 'integracao_ifponto_acao1',
                    x.dt_ult_alter_usua = sysdate
                WHERE
                        x.ano_mes_referencia = (
                            SELECT
                                MAX(ano_mes_referencia)
                            FROM
                                arterh.rhpess_contrato aux2
                            WHERE
                                    aux2.codigo_empresa = x.codigo_empresa
                                AND aux2.tipo_contrato = x.tipo_contrato
                                AND aux2.codigo = x.codigo
                        )
                    AND x.codigo_empresa = ''
                                           || c1.codigo_empresa
                                           || ''
                    AND x.tipo_contrato = ''
                                          || c1.tipo_contrato
                                          || ''
                    AND x.codigo = ''
                                   || c1.codigo_contrato
                                   || '';

                COMMIT;
            END IF;
      ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      ---DESLIGADOS,
      ---MOVIMENTADOS
      ---ALTERADO CARGO COMISSSIONADO/FUNCAO

--ACAO 2 NO ARTERH --MARCADO 07/12/22
      -----------------------------------------------------------------------------------------PARA PESSOAS GESTORAS------------------------------------------------------------------------------
            IF (
                c1.tipo_vw_dados_servidor = 'DESLIGAMENTO'
                AND c1.e_gestor = 'S'
            ) ---- DESLIGOU E ERA GESTOR
             OR (
                c1.alterou_local = 'LOCAL_MUDOU'
                AND c1.alterou_cpf_gestor = 'CPF_GESTOR_IGUAL'
                AND c1.e_gestor = 'S'
            )--- MUDOU LOCAL E PERMANECEU COM MESMO GESTOR
             OR (
                c1.alterou_cod_cargo_comiss = 'COD_CARGO_COMISS_MUDOU'
                AND c1.cod_cargo_comiss_seguinte NOT IN ( '000000000000000' )
                AND c1.cod_cargo_comiss_seguinte IS NOT NULL
                AND c1.e_gestor = 'S'
                AND c1.alterou_local = 'LOCAL_MUDOU'
            ) ---- MUDOU O CARGO CONTINOU COMO GESTOR E LOCAL MUDOU
             OR (
                c1.alterou_codigo_funcao = 'CODIGO_FUNCAO_MUDOU'
                AND c1.codigo_funcao_seguinte NOT IN ( '000000000000000' )
                AND c1.codigo_funcao_seguinte IS NOT NULL
                AND c1.e_gestor = 'S'
                AND c1.alterou_local = 'LOCAL_MUDOU'
            ) ---- MUDOU O FUNCAO CONTINOU COMO GESTOR E LOCAL MUDOU
             OR (
                c1.alterou_cod_cargo_comiss = 'COD_CARGO_COMISS_MUDOU'
                AND (
                    c1.cod_cargo_comiss_seguinte IN ( '000000000000000' )
                    AND c1.e_gestor = 'S'
                OR c1.cod_cargo_comiss_seguinte IS NULL )
            )---- PERDEU CARGO
             OR (
                c1.alterou_codigo_funcao = 'CODIGO_FUNCAO_MUDOU'
                AND (
                    c1.codigo_funcao_seguinte IN ( '000000000000000' )
                    AND c1.e_gestor = 'S'
                OR c1.codigo_funcao_seguinte IS NULL )
            )
            OR(
            c1.alterou_local = 'LOCAL_MUDOU' AND c1.e_gestor = 'S'
            )
            
            
            THEN --PERDEU FUNCAO
        -----------------------------------------------------------------------------------PARA RESPONSAVEL NO CUSTO GERENCIAL-------------------------------------------------------------------
        --------------------------------------------------------------------------------------------------------AQUI RETIRA GESTOR FORMAL--------------------------------------------------------------------------------------
                dbms_output.put_line('GESTOR' || c1.codigo_contrato);
                UPDATE arterh.rhorga_custo_geren
                SET
                    cod_empresa_pess = NULL,
                    cod_pessoa_resp = NULL,
                    tipo_cont_resp = NULL,
                    contrato_resp = '000000000000000',
                    login_usuario = 'integracao_ifponto_acao2',
                    dt_ult_alter_usua = sysdate
                WHERE
                        contrato_resp = ''
                                        || c1.codigo_contrato
                                        || ''
                    AND cod_cgerenc1 = ''
                                       || c1.COD_UNIDADE_ANTERIOR1
                                       || ''
                    AND cod_cgerenc2 = ''
                                       || c1.COD_UNIDADE_ANTERIOR2
                                       || ''
                    AND cod_cgerenc3 = ''
                                       || c1.COD_UNIDADE_ANTERIOR3
                                       || ''
                    AND cod_cgerenc4 = ''
                                       || c1.COD_UNIDADE_ANTERIOR4
                                       || ''
                    AND cod_cgerenc5 = ''
                                       || c1.COD_UNIDADE_ANTERIOR5
                                       || ''
                    AND cod_cgerenc6 = ''
                                       || c1.COD_UNIDADE_ANTERIOR6
                                       || ''
                    AND CODIGO_EMPRESA=''||C1.CODIGO_EMPRESA||'';

                COMMIT;
        -----------------------------------------------------------------------DA AGRUPADOR------------------------------------------------------------------------------------------------
                UPDATE arterh.rhorga_agrupador
                SET
                    cod_empresa_pess = NULL,
                    cod_pessoa_resp = NULL,
                    tipo_cont_resp = NULL,
                    contrato_resp = '000000000000000',
                    login_usuario = 'integracao_ifponto_acao2',
                    dt_ult_alter_usua = sysdate
                WHERE
                        contrato_resp = ''
                                        || c1.codigo_contrato
                                        || ''
                    AND cod_agrup1 = ''
                                     || c1.COD_UNIDADE_ANTERIOR1
                                     || ''
                    AND cod_agrup2 = ''
                                     || c1.COD_UNIDADE_ANTERIOR2
                                     || ''
                    AND cod_agrup3 = ''
                                     || c1.COD_UNIDADE_ANTERIOR3
                                     || ''
                    AND cod_agrup4 = ''
                                     || c1.COD_UNIDADE_ANTERIOR4
                                     || ''
                    AND cod_agrup5 = ''
                                     || c1.COD_UNIDADE_ANTERIOR5
                                     || ''
                    AND cod_agrup6 = ''
                                     || c1.COD_UNIDADE_ANTERIOR6
                                     || ''
                                       AND CODIGO_EMPRESA=''||C1.CODIGO_EMPRESA||'';

                COMMIT;
        --------------------------------------------------------------------AGRUADOR_H-------------------------------------------------------------------------------------
                UPDATE arterh.rhorga_agrupador_h
                SET
                    cod_empresa_pess = NULL,
                    cod_pessoa_resp = NULL,
                    tipo_cont_resp = NULL,
                    contrato_resp = '000000000000000',
                    login_usuario = 'integracao_ifponto_acao2',
                    dt_ult_alter_usua = sysdate
                WHERE
                        ano_mes_referencia = (
                            SELECT
                                MAX(aux.ano_mes_referencia)
                            FROM
                                arterh.rhorga_agrupador_h aux
                            WHERE
                                    aux.codigo_empresa = rhorga_agrupador_h.codigo_empresa
                                AND aux.id_agrup = rhorga_agrupador_h.id_agrup
                        )
                    AND contrato_resp = ''
                                        || c1.codigo_contrato
                                        || ''
                    AND cod_agrup1 = ''
                                     || c1.COD_UNIDADE_ANTERIOR1
                                     || ''
                    AND cod_agrup2 = ''
                                     || c1.COD_UNIDADE_ANTERIOR2
                                     || ''
                    AND cod_agrup3 = ''
                                     || c1.COD_UNIDADE_ANTERIOR3
                                     || ''
                    AND cod_agrup4 = ''
                                     || c1.COD_UNIDADE_ANTERIOR4
                                     || ''
                    AND cod_agrup5 = ''
                                     || c1.COD_UNIDADE_ANTERIOR5
                                     || ''
                    AND cod_agrup6 = ''
                                     || c1.COD_UNIDADE_ANTERIOR6
                                     || ''
                                      AND CODIGO_EMPRESA=''||C1.CODIGO_EMPRESA||'';

                COMMIT;

--ACAO 3 NO ARTERH --MARCADO 07/12/22
        -----------------------------------------------------------------------------------------------------------------------------------AQUI ATENDE A TELA DE DELEGACAO FECHANDO OS GESTORES FORMAIS APARTI DE 12/12/2019---------------------------------------
        ---------------------------------------------------------------------------PARTE DE GESTORES FORMAIS ---------------------------------------------------------------------------------
                BEGIN
                    DECLARE
                        vcont NUMBER;
                    BEGIN
                        vcont := 0;
                        dbms_output.put_line('EM FASES DE TESTE');
                        FOR c2 IN (
                            SELECT
                                l.*
                            FROM
                                (
                                    SELECT
                                        capa.id,
                                        gestor.id_agrup,
                                        gestor.id                    AS id_tela,
                                        capa.codigo_empresa_contrato AS codigo_empresa,
                                        capa.tipo_contrato_resp      AS tipo_contrato,
                                        capa.codigo_contrato_resp    AS contrato_gestor,
                                        capa.codigo_pessoa_resp      AS pessoa_gestor
                                    FROM
                                        arterh.rhuser_pessoa_responsavel    capa
                                        LEFT OUTER JOIN arterh.rhuser_pessoa_resp_agrupador gestor ON capa.id = gestor.id_rhuser_pessoa_responsavel
                                                                                                      AND capa.codigo_empresa = gestor.codigo_empresa
                                    WHERE
                                        capa.motivo_delegacao IN ( 'D', 'F' )
                                        AND capa.id_processo = '2'
                                        AND capa.dt_fim_responsabilidade IS NULL
                                        AND gestor.dt_fim_responsavel IS NULL
                                )                         l
                                LEFT OUTER JOIN arterh.rhorga_agrupador_h agr ON l.id_agrup = agr.id_agrup
                                                                                 AND l.codigo_empresa = agr.codigo_empresa
                                LEFT OUTER JOIN arterh.rhorga_agrupador   ag ON ag.id_agrup = agr.id_agrup
                                                                              AND ag.codigo_empresa = agr.codigo_empresa
                                LEFT OUTER JOIN arterh.rhorga_custo_geren gx ON ag.codigo_empresa = gx.codigo_empresa
                                                                                AND gx.cod_cgerenc1 = ag.cod_agrup1
                                                                                AND gx.cod_cgerenc2 = ag.cod_agrup2
                                                                                AND gx.cod_cgerenc3 = ag.cod_agrup3
                                                                                AND gx.cod_cgerenc4 = ag.cod_agrup4
                                                                                AND gx.cod_cgerenc5 = ag.cod_agrup5
                                                                                AND gx.cod_cgerenc6 = ag.cod_agrup6
                            WHERE
                                    agr.ano_mes_referencia = (
                                        SELECT
                                            MAX(aux.ano_mes_referencia)
                                        FROM
                                            arterh.rhorga_agrupador_h aux
                                        WHERE
                                                aux.codigo_empresa = agr.codigo_empresa
                                            AND aux.id_agrup = agr.id_agrup
                                    )
                                AND gx.cod_cgerenc1 = ''
                                                      || c1.COD_UNIDADE_ANTERIOR1
                                                      || ''
                                AND gx.cod_cgerenc2 = ''
                                                      || c1.COD_UNIDADE_ANTERIOR2
                                                      || ''
                                AND gx.cod_cgerenc3 = ''
                                                      || c1.COD_UNIDADE_ANTERIOR3
                                                      || ''
                                AND gx.cod_cgerenc4 = ''
                                                      || c1.COD_UNIDADE_ANTERIOR4
                                                      || ''
                                AND gx.cod_cgerenc5 = ''
                                                      || c1.COD_UNIDADE_ANTERIOR5
                                                      || ''
                                AND gx.cod_cgerenc6 = ''
                                                      || c1.COD_UNIDADE_ANTERIOR6
                                                      || ''
                                AND agr.tipo_agrup = 'G'
                                AND gx.codigo_empresa = ''
                                                        || c1.codigo_empresa
                                                        || ''
                                AND l.codigo_empresa = gx.codigo_empresa
                                AND l.contrato_gestor = ''
                                                        || c1.codigo_contrato
                                                        || ''
                                AND l.tipo_contrato = ''
                                                      || c1.tipo_contrato
                                                      || ''
                        ) LOOP
                            vcont := vcont + 1;
                            UPDATE arterh.rhuser_pessoa_resp_agrupador
                            SET
                                dt_fim_responsavel = sysdate,
                                updated = sysdate,
                                updatedby = 'INTEGRACAO_IFPONTO_ACAO3'
                            WHERE
                                id = ''
                                     || c2.id_tela
                                     || '';

                            UPDATE arterh.rhuser_pessoa_responsavel
                            SET
                                dt_fim_responsabilidade = sysdate,
                                updated = sysdate,
                                updatedby = 'INTEGRACAO_IFPONTO_ACAO3'
                            WHERE
                                id = ''
                                     || c2.id
                                     || '';

                            COMMIT;
                        END LOOP;

                    END;
                END;
        --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                BEGIN
                    DECLARE
                        vcont1 NUMBER;
                    BEGIN
                        FOR c2 IN (
                            SELECT
                                x.*
                            FROM
                                (
                                    SELECT
                                        capa.id                         AS id_capa,
                                        sub.id                          AS id_subordinado,
                                        capa.codigo_empresa_pessoa_resp AS codigo_empresa,
                                        capa.tipo_contrato_resp         AS tipo_contrato_gestor,
                                        codigo_pessoa_resp              AS pessoa_gestor,
                                        codigo_contrato_resp            AS contrato_gestor,
                                        sub.codigo_contrato_subordinado
                                    FROM
                                        arterh.rhuser_pessoa_resp_supervisao sub
                                        LEFT OUTER JOIN arterh.rhuser_pessoa_responsavel     capa ON capa.id = sub.id_rhuser_pessoa_responsavel
                                                                                                 AND capa.codigo_empresa = sub.codigo_empresa
                                    WHERE
                                        capa.motivo_delegacao IN ( 'D', 'F' )
                                        AND capa.id_processo = '2'
                                        AND capa.dt_fim_responsabilidade IS NULL
                                        AND sub.dt_fim_supervisao IS NULL
                                ) x
                            WHERE
                                    x.contrato_gestor = ''
                                                        || c1.codigo_contrato
                                                        || ''
                                AND x.codigo_empresa = ''
                                                       || c1.codigo_empresa
                                                       || ''
                                AND x.tipo_contrato_gestor = ''
                                                             || c1.tipo_contrato
                                                             || ''
                        ) LOOP
                            vcont1 := vcont1 + 1;
              --dbms_output.put_line('UPDATE ARTERH.RHUSER_PESSOA_RESP_SUPERVISAO SET DT_FIM_SUPERVISAO=SYSDATE  WHERE ID='''||C2.ID_SUBORDINADO||''';');
              --dbms_output.put_line('UPDATE ARTERH.RHUSER_PESSOA_RESPONSAVEL SET DT_FIM_RESPONSABILIDADE=SYSDATE  WHERE ID='''||C2.ID_CAPA||''';');
                            COMMIT;
                        END LOOP;

                    END;
                END;
        ----------------------------------------------------------------------FIM GESTOR FORMAL ------------------------------------------------------------------------------------------------

--ACAO 4 NO ARTERH --MARCADO 07/12/22
        --------------------------------------------------------------------------------------INICIO GESTOR INFORMAL-------------------------------------------------------------------
        ---------------------------------------------------------CUSTO GEREN RESPONSAVEL INFORMAL------------------------------------------------------------------------------------
                UPDATE arterh.rhorga_custo_geren
                SET
                    cod_empr_pess_inf = NULL,
                    cod_pess_informal = NULL,
                    tipo_cont_resp_inf = NULL,
                    contrato_resp_inf = '000000000000000',
                    login_usuario = 'integracao_ifponto_acao4',
                    dt_ult_alter_usua = sysdate
                WHERE
                        contrato_resp_inf = ''
                                            || c1.codigo_contrato
                                            || ''
                    AND cod_cgerenc1 = ''
                                       || c1.COD_UNIDADE_ANTERIOR1
                                       || ''
                    AND cod_cgerenc2 = ''
                                       || c1.COD_UNIDADE_ANTERIOR2
                                       || ''
                    AND cod_cgerenc3 = ''
                                       || c1.COD_UNIDADE_ANTERIOR3
                                       || ''
                    AND cod_cgerenc4 = ''
                                       || c1.COD_UNIDADE_ANTERIOR4
                                       || ''
                    AND cod_cgerenc5 = ''
                                       || c1.COD_UNIDADE_ANTERIOR5
                                       || ''
                    AND cod_cgerenc6 = ''
                                       || c1.COD_UNIDADE_ANTERIOR6
                                       || ''
                                       AND CODIGO_EMPRESA=C1.CODIGO_EMPRESA;

                COMMIT;
        ---------------------------------------------------------------------------AGRUPADOR----------------------------------------------------------------------------------------------------------------
                UPDATE arterh.rhorga_agrupador
                SET
                    cod_empr_pess_inf = NULL,
                    cod_pess_informal = NULL,
                    tipo_cont_resp_inf = NULL,
                    contrato_resp_inf = '000000000000000',
                    login_usuario = 'integracao_ifponto_acao4',
                    dt_ult_alter_usua = sysdate
                WHERE
                        contrato_resp_inf = ''
                                            || c1.codigo_contrato
                                            || ''
                    AND cod_agrup1 = ''
                                     || c1.COD_UNIDADE_ANTERIOR1
                                     || ''
                    AND cod_agrup2 = ''
                                     || c1.COD_UNIDADE_ANTERIOR2
                                     || ''
                    AND cod_agrup3 = ''
                                     || c1.COD_UNIDADE_ANTERIOR3
                                     || ''
                    AND cod_agrup4 = ''
                                     || c1.COD_UNIDADE_ANTERIOR4
                                     || ''
                    AND cod_agrup5 = ''
                                     || c1.COD_UNIDADE_ANTERIOR5
                                     || ''
                    AND cod_agrup6 = ''
                                     || c1.COD_UNIDADE_ANTERIOR6
                                     || ''
                                     AND CODIGO_EMPRESA=C1.CODIGO_EMPRESA;

                COMMIT;
        -------------------------------------------------------------------------------AGRUPADOR H----------------------------------------------------------------------------------------------
                UPDATE arterh.rhorga_agrupador_h
                SET
                    cod_empr_pess_inf = NULL,
                    cod_pess_informal = NULL,
                    tipo_cont_resp_inf = NULL,
                    contrato_resp_inf = '000000000000000',
                    login_usuario = 'integracao_ifponto_acao4',
                    dt_ult_alter_usua = sysdate
                WHERE
                        ano_mes_referencia = (
                            SELECT
                                MAX(aux.ano_mes_referencia)
                            FROM
                                arterh.rhorga_agrupador_h aux
                            WHERE
                                    aux.codigo_empresa = rhorga_agrupador_h.codigo_empresa
                                AND aux.id_agrup = rhorga_agrupador_h.id_agrup
                        )
                    AND contrato_resp_inf = ''
                                            || c1.codigo_contrato
                                            || ''
                    AND cod_agrup1 = ''
                                     || c1.COD_UNIDADE_ANTERIOR1
                                     || ''
                    AND cod_agrup2 = ''
                                     || c1.COD_UNIDADE_ANTERIOR2
                                     || ''
                    AND cod_agrup3 = ''
                                     || c1.COD_UNIDADE_ANTERIOR3
                                     || ''
                    AND cod_agrup4 = ''
                                     || c1.COD_UNIDADE_ANTERIOR4
                                     || ''
                    AND cod_agrup5 = ''
                                     || c1.COD_UNIDADE_ANTERIOR5
                                     || ''
                    AND cod_agrup6 = ''
                                     || c1.COD_UNIDADE_ANTERIOR6
                                     || ''
                                     AND CODIGO_EMPRESA=C1.CODIGO_EMPRESA;

                COMMIT;
            END IF;
      ----------------------------------------------------------------------------------------FIM ------------------------------------------------------------------------------------------------

--ACAO 5 NO ARTERH --MARCADO 07/12/22
      ---------------------------------------------------*************PARA LIMPAR HIERARQUIA POR PESSOA*****************-----------------------------------------------------------------------
      -------------LIMPAR APENAS OS contratos QUANDO GESTOR sEr MOVIMENTADO E MANTEVE O MESMO CONTRATO DE SUBoRDINADO DO DIA ANTERIOR PARA O DIA SEGUINTE----------------------------------------------
            IF (
                c1.tipo_vw_dados_servidor = 'DESLIGAMENTO'
                AND c1.e_gestor= 'S'
            ) OR (
                c1.alterou_local = 'LOCAL_MUDOU'
                AND c1.e_gestor = 'S'
            ) OR (
                c1.alterou_cod_cargo_comiss = 'COD_CARGO_COMISS_MUDOU'
                AND c1.e_gestor = 'S'
                AND c1.alterou_local = 'LOCAL_MUDOU'
            ) OR (
                c1.alterou_codigo_funcao = 'CODIGO_FUNCAO_MUDOU'
                AND c1.e_gestor= 'S'
                AND c1.alterou_local = 'LOCAL_MUDOU'
            ) THEN
                BEGIN
                    DECLARE
                        vcontador NUMBER;
                    BEGIN
                        FOR c2 IN (
                            SELECT
                                x3.codigo_contrato
                            FROM
                                (
                                    SELECT
                                        CASE
                                            WHEN xxx.cpf_gestor = xxx.cpf_gestor_seguinte THEN
                                                'LIMPAR_CONTRATO'
                                            ELSE
                                                'ERRO'
                                        END alterou_cpf_gestor,
                                        xxx.*
                                    FROM
                                        (
                                            SELECT
                                                xx.*
                                            FROM
                                                (
                                                    SELECT
                                                        x.tipo_pessoa,
                                                        x.apelido,
                                                        x.codigo_empresa,
                                                        x.tipo_contrato,
                                                        x.codigo_contrato,
                                                        x.vinculo,
                                                        ROW_NUMBER()
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa, x.codigo_contrato, x.tipo_contrato,
                                                                 x.dia
                                                        ) ordem_bm,
                                                        x.nome,
                                                        LEAD(x.nome, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) nome_seguinte,
                                                        x.dia,
                                                        LEAD(x.dia, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) dia_seguinte,
                                                        x.tipo,
                                                        LEAD(x.tipo, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) tipo_seguinte,
                                                        x.integrado,
                                                        LEAD(x.integrado, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) integrado_seguinte,
                                                        x.data_admissao,
                                                        x.pis_pasep,
                                                        LEAD(x.pis_pasep, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) pis_pasep_seguinte,
                                                        x.cpf,
                                                        LEAD(x.cpf, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) cpf_seguinte,
                                                        x.cnpj,
                                                        LEAD(x.cnpj, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) cnpj_seguinte,
                                                        x.identidade,
                                                        LEAD(x.identidade, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) identidade_seguinte,
                                                        x.cod_unidade1,
                                                        LEAD(x.cod_unidade1, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.tipo_contrato, x.dia
                                                        ) cod_unidade1_seguinte,
                                                        x.cod_unidade2,
                                                        LEAD(x.cod_unidade2, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.tipo_contrato, x.dia
                                                        ) cod_unidade2_seguinte,
                                                        x.cod_unidade3,
                                                        LEAD(x.cod_unidade3, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) cod_unidade3_seguinte,
                                                        x.cod_unidade4,
                                                        LEAD(x.cod_unidade4, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) cod_unidade4_seguinte,
                                                        x.cod_unidade5,
                                                        LEAD(x.cod_unidade5, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) cod_unidade5_seguinte,
                                                        x.cod_unidade6,
                                                        LEAD(x.cod_unidade6, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) cod_unidade6_seguinte,
                                                        x.descricao_unidade,
                                                        LEAD(x.descricao_unidade, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) descricao_unidade_seguinte,
                                                        x.registro_ponto,
                                                        LEAD(x.registro_ponto, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) registro_ponto_seguinte,
                                                        x.situacao_funcional,
                                                        LEAD(x.situacao_funcional, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) situacao_funcional_seguinte,
                                                        x.nome_sit_func,
                                                        LEAD(x.nome_sit_func, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) nome_sit_func_seguinte,
                                                        x.controle_folha,
                                                        LEAD(x.controle_folha, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) controle_folha_seguinte,
                                                        x.data_rescisao,
                                                        LEAD(x.data_rescisao, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) data_rescisao_seguinte,
                                                        x.codigo_escala,
                                                        LEAD(x.codigo_escala, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) codigo_escala_seguinte,
                                                        x.dt_ult_escala,
                                                        LEAD(x.dt_ult_escala, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) dt_ult_escala_seguinte,
                                                        x.cod_cargo_efetivo,
                                                        LEAD(x.cod_cargo_efetivo, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) cod_cargo_efetivo_seguinte,
                                                        x.cargo_efetivo,
                                                        LEAD(x.cargo_efetivo, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) cargo_efetivo_seguinte,
                                                        x.cod_cargo_comiss,
                                                        LEAD(x.cod_cargo_comiss, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) cod_cargo_comiss_seguinte,
                                                        x.cargo_comissionado,
                                                        LEAD(x.cargo_comissionado, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) cargo_comissionado_seguinte,
                                                        x.codigo_funcao,
                                                        LEAD(x.codigo_funcao, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) codigo_funcao_seguinte,
                                                        x.funcao_publica,
                                                        LEAD(x.funcao_publica, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) funcao_publica_seguinte,
                                                        x.codigo_empresa_gestor,
                                                        LEAD(x.codigo_empresa_gestor, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) codigo_empresa_gestor_seguinte,
                                                        x.tipo_contrato_gestor,
                                                        LEAD(x.tipo_contrato_gestor, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) tipo_contrato_gestor_seguinte,
                                                        x.contrato_gestor,
                                                        LEAD(x.contrato_gestor, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) contrato_gestor_seguinte,
                                                        x.cpf_gestor,
                                                        LEAD(x.cpf_gestor, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) cpf_gestor_seguinte,
                                                        x.e_gestor,
                                                        LEAD(x.e_gestor, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) e_gestor_seguinte,
                                                        x.tipo_usuario,
                                                        LEAD(x.tipo_usuario, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) tipo_usuario_seguinte,
                                                        x.dt_saiu_arte,
                                                        x.codigo_legado,
                                                        LEAD(x.codigo_legado, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) codigo_legado_seguinte,
                                                        x.tem_cargo_efetivo,
                                                        x.chave_integracao,
                                                        LEAD(x.chave_integracao, 1, NULL)
                                                        OVER(PARTITION BY x.codigo_empresa, x.codigo_contrato, x.tipo_contrato
                                                             ORDER BY
                                                                 x.codigo_empresa,
                                                                 x.codigo_contrato, x.tipo_contrato, x.dia
                                                        ) chave_integracao_seguinte
                                                    FROM
                                                        (
                                                            SELECT
                                                                'ULTIMO' AS dia,
                                                                u.*,
                                                                gn.cgc   AS cnpj
                                                            FROM
                                                                ponto_eletronico.sugesp_bi_1contrat_intif_arte u
                                                                LEFT OUTER JOIN arterh.rhorga_custo_geren                      gn ON u.codigo_empresa = gn.codigo_empresa
                                                                                                                AND u.cod_unidade1 = gn.cod_cgerenc1
                                                                                                                AND u.cod_unidade2 = gn.cod_cgerenc2
                                                                                                                AND u.cod_unidade3 = gn.cod_cgerenc3
                                                                                                                AND u.cod_unidade4 = gn.cod_cgerenc4
                                                                                                                AND u.cod_unidade5 = gn.cod_cgerenc5
                                                                                                                AND u.cod_unidade6 = gn.cod_cgerenc6
                                                            WHERE
                                                                trunc(u.dt_saiu_arte) = trunc(sysdate)-- (SELECT MAX(dt_saiu_arte)FROM PONTO_ELETRONICO.SUGESP_BI_1CONTRAT_INTIF_ARTE)
                                                            UNION ALL
          --PENULTIMO DIA
                                                            SELECT
                                                                'PENULTIMO' AS dia,
                                                                p.*,
                                                                gn.cgc      AS cnpj
                                                            FROM
                                                                ponto_eletronico.sugesp_bi_1contrat_intif_arte p
                                                                LEFT OUTER JOIN arterh.rhorga_custo_geren                      gn ON p.codigo_empresa = gn.codigo_empresa
                                                                                                                AND p.cod_unidade1 = gn.cod_cgerenc1
                                                                                                                AND p.cod_unidade2 = gn.cod_cgerenc2
                                                                                                                AND p.cod_unidade3 = gn.cod_cgerenc3
                                                                                                                AND p.cod_unidade4 = gn.cod_cgerenc4
                                                                                                                AND p.cod_unidade5 = gn.cod_cgerenc5
                                                                                                                AND p.cod_unidade6 = gn.cod_cgerenc6
                                                            WHERE
                                                                trunc(p.dt_saiu_arte) = trunc(sysdate) - 1
         /*(SELECT X.DT_SAIU_ARTE FROM(SELECT K.DT_SAIU_ARTE,ROWNUM ORDEM_DATA FROM(SELECT Z.*FROM(SELECT x.dt_saiu_arte
          FROM PONTO_ELETRONICO.SUGESP_BI_1CONTRAT_INTIF_ARTE x
          GROUP BY x.dt_saiu_arte
          ORDER BY x.dt_saiu_arte DESC)Z)K)X
            WHERE X.ORDEM_DATA = 2)*/
                                                        ) x
                                                    ORDER BY
                                                        x.codigo_empresa,
                                                        x.codigo_contrato,
                                                        x.dia
                                                ) xx
                                            WHERE
                                                ( xx.ordem_bm = 1 )
                                        ) xxx
                                ) x3
                            WHERE
                                ( x3.alterou_cpf_gestor = 'LIMPAR_CONTRATO'
                                  AND x3.integrado = 'S' )
                                AND x3.contrato_gestor = ''
                                                         || c1.codigo_contrato
                                                         || ''
                                AND x3.tipo_contrato_gestor = ''
                                                              || c1.tipo_contrato
                                                              || ''
                                AND x3.codigo_empresa_gestor = ''
                                                               || c1.codigo_empresa
                                                               || ''
                                AND x3.tipo_seguinte = 'HIERARQUIA POR PESSOA'
                        ) LOOP
                            vcontador := vcontador + 1;
                            dbms_output.put_line('gestor por pessoa ' || c1.codigo_contrato);
                            UPDATE arterh.rhpess_contrato
                            SET
                                cod_procurador = NULL,
                                login_usuario = 'integracao_ifponto_acao5',
                                dt_ult_alter_usua = sysdate
                            WHERE
                                    cod_procurador = ''
                                                     || c1.codigo_pessoa
                                                     || ''
                                AND ano_mes_referencia = (
                                    SELECT
                                        MAX(ano_mes_referencia)
                                    FROM
                                        arterh.rhpess_contrato aux
                                    WHERE
                                            arterh.rhpess_contrato.codigo_empresa = aux.codigo_empresa
                                        AND arterh.rhpess_contrato.codigo = aux.codigo
                                        AND arterh.rhpess_contrato.tipo_contrato = aux.tipo_contrato
                                )
                                AND codigo = ''
                                             || c2.codigo_contrato
                                             || '';

                        END LOOP;

                    END;

                END;
            END IF;
      ---------------------------------------------------------------------------------------------FIM ------------------------------------------------------------------------------------

--ACAO 6 NO ARTERH --MARCADO 07/12/22
            IF (
                c1.tipo_vw_dados_servidor = 'DESLIGAMENTO'
                AND c1.e_gestor_seguinte = 'N'
            ) OR (
                c1.alterou_local = 'LOCAL_MUDOU'
                AND c1.alterou_cpf_gestor = 'CPF_GESTOR_IGUAL'
                AND c1.e_gestor_seguinte = 'N'
            ) THEN
        --*************PARA LIMPAR O GESTOR IFPONTO (COD_PROCURADOR) HIERARQUIA POR PESSOA

                UPDATE arterh.rhpess_contrato
                SET
                    cod_procurador = NULL,
                    login_usuario = 'integracao_ifponto_acao6',
                    dt_ult_alter_usua = sysdate
                WHERE
                        cod_procurador = ''
                                         || c1.pessoa_gestor
                                         || ''
                    AND ano_mes_referencia = (
                        SELECT
                            MAX(aux.ano_mes_referencia)
                        FROM
                            arterh.rhpess_contrato aux
                        WHERE
                                aux.codigo = arterh.rhpess_contrato.codigo
                            AND aux.codigo_empresa = arterh.rhpess_contrato.codigo_empresa
                            AND aux.tipo_contrato = arterh.rhpess_contrato.tipo_contrato
                            AND aux.ano_mes_referencia <= (
                                SELECT
                                    data_do_sistema
                                FROM
                                    rhparm_p_sist
                            )
                    )
                    AND codigo = ''
                                 || c1.codigo_contrato
                                 || '';

                COMMIT;
                DECLARE
                    vcont NUMBER;
                BEGIN
                    vcont := 0;
                    FOR c2 IN (
                        SELECT
                            x.*
                        FROM
                            (
                                SELECT
                                    capa.id                         AS id_capa,
                                    sub.id                          AS id_subordinado,
                                    capa.codigo_empresa_pessoa_resp AS codigo_emrpesa,
                                    capa.tipo_contrato_resp         AS tipo_contrato_gestor,
                                    codigo_pessoa_resp              AS pessoa_gestor,
                                    codigo_contrato_resp            AS contrato_gestor,
                                    sub.codigo_contrato_subordinado AS contrato_subordinado,
                                    sub.tipo_contrato_subordinado,
                                    codigo_empresa_ctr_subordinado  AS codigo_empresa_subordinado
                                FROM
                                    arterh.rhuser_pessoa_resp_supervisao sub
                                    LEFT OUTER JOIN arterh.rhuser_pessoa_responsavel     capa ON capa.id = sub.id_rhuser_pessoa_responsavel
                                                                                             AND capa.codigo_empresa = sub.codigo_empresa
                                WHERE
                                    capa.motivo_delegacao IN ( 'D', 'F' )
                                    AND capa.id_processo = '2'
                                    AND capa.dt_fim_responsabilidade IS NULL
                                    AND sub.dt_fim_supervisao IS NULL
                            ) x
                        WHERE
                                x.contrato_subordinado = ''
                                                         || c1.codigo_contrato
                                                         || ''
                            AND x.tipo_contrato_subordinado = ''
                                                              || c1.tipo_contrato
                                                              || ''
                            AND x.codigo_empresa_subordinado = ''
                                                               || c1.codigo_empresa
                                                               || ''
                    ) LOOP
                        vcont := vcont + 1;
          --  dbms_output.put_line('UPDATE ARTERH.RHUSER_PESSOA_RESP_SUPERVISAO SET DT_FIM_SUPERVISAO=SYSDATE  WHERE ID='''||C2.ID_SUBORDINADO||''';');
                        COMMIT;
                        FOR c3 IN (
                            SELECT
                                COUNT(1) quant
                            FROM
                                (
                                    SELECT
                                        capa.id                         AS id_capa,
                                        sub.id                          AS id_subordinado,
                                        capa.codigo_empresa_pessoa_resp AS codigo_empresa,
                                        capa.tipo_contrato_resp         AS tipo_contrato_gestor,
                                        codigo_pessoa_resp              AS pessoa_gestor,
                                        codigo_contrato_resp            AS contrato_gestor,
                                        sub.codigo_contrato_subordinado
                                    FROM
                                        arterh.rhuser_pessoa_resp_supervisao sub
                                        LEFT OUTER JOIN arterh.rhuser_pessoa_responsavel     capa ON capa.id = sub.id_rhuser_pessoa_responsavel
                                                                                                 AND capa.codigo_empresa = sub.codigo_empresa
                                    WHERE
                                        capa.motivo_delegacao IN ( 'D', 'F' )
                                        AND capa.id_processo = '2'
                                        AND capa.dt_fim_responsabilidade IS NULL
                                        AND sub.dt_fim_supervisao IS NULL
                                ) x
                            WHERE
                                    x.contrato_gestor = ''
                                                        || c2.contrato_gestor
                                                        || ''
                                AND x.codigo_empresa = ''
                                                       || c2.codigo_emrpesa
                                                       || ''
                                AND x.tipo_contrato_gestor = ''
                                                             || c2.tipo_contrato_gestor
                                                             || ''
                        ) LOOP
                            IF c3.quant = 1 THEN
                                dbms_output.put_line('/*UPDATE ARTERH.RHUSER_PESSOA_RESPONSAVEL SET DT_FIM_RESPONSABILIDADE=SYSDATE  WHERE ID='''
                                                     || c2.id_capa
                                                     || ''';*/');
                            END IF;

                            COMMIT;
                        END LOOP;

                    END LOOP;

                END;

            ELSE
                dbms_output.put_line('-TRATAR AINDA' || c1.codigo_contrato);
            END IF;
      -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        END LOOP;

--ACAO 7 NO ARTERH --MARCADO COM REVISAO LOCAIS FORMAIS E UNINDO TODOS OS NIVEIS EM UM FOR E IF ONDE HAVIAM 5 FOR/IF 07/12/22
    --------------------------------------------------------------------------------------------------------parte que atualiza os custos geren no arte
        BEGIN
            DECLARE
                vcontador2 NUMBER;
            BEGIN
                dbms_output.enable(NULL);
--dbms_output.put_line('TESTE DE PCD');
                vcontador2 := 0;
                FOR c2 IN (
                    SELECT
                        xx.*,
                        LAG(xx.cod_empresa_gestor_superior, 1, NULL)
                        OVER(PARTITION BY xx.id_agrup
                             ORDER BY
                                 xx.id_agrup, xx.nivel_sup_agr_est
                        ) cod_empr_gestor_nivel_acima,
                        LAG(xx.cod_pessoa_gestor_superior, 1, NULL)
                        OVER(PARTITION BY xx.id_agrup
                             ORDER BY
                                 xx.id_agrup, xx.nivel_sup_agr_est
                        ) cod_pess_gestor_nivel_acima,
                        LAG(xx.tipo_cont_gestor_superior, 1, NULL)
                        OVER(PARTITION BY xx.id_agrup
                             ORDER BY
                                 xx.id_agrup, xx.nivel_sup_agr_est
                        ) tipo_cont_gestor_nivel_acima,
                        LAG(xx.contrato_gestor_superior, 1, NULL)
                        OVER(PARTITION BY xx.id_agrup
                             ORDER BY
                                 xx.id_agrup, xx.nivel_sup_agr_est
                        ) contrato_gestor_nivel_acima
                    FROM
                        (
                            SELECT
                                x.codigo_empresa,
                                x.cod_cgerenc1,
                                x.cod_cgerenc2,
                                x.cod_cgerenc3,
                                x.cod_cgerenc4,
                                x.cod_cgerenc5,
                                x.cod_cgerenc6,
                                x.cod_empresa_pess,
                                x.cod_pessoa_resp,
                                x.tipo_cont_resp,
                                x.contrato_resp,
                                x.cod_empr_pess_inf,
                                x.cod_pess_informal,
                                x.tipo_cont_resp_inf,
                                x.contrato_resp_inf,
                                CASE
                                    WHEN x.contrato_resp_inf IS NULL THEN
                                        x.contrato_resp
                                    ELSE
                                        x.contrato_resp_inf
                                END                  gestor,
                                e.id_agrup,
                                e.nivel_agrup_estrut,
                                e.id_agrup_sup,
                                e.nivel_sup_agr_est,
                                xs.id_agrup          id_agrup_supes,
                                xs.contrato_resp     contrato_resp_sup,
                                xs.contrato_resp_inf contrato_resp_inf_sup,
                                ROW_NUMBER()
                                OVER(PARTITION BY e.id_agrup, xs.contrato_resp
                                     ORDER BY
                                         e.id_agrup, xs.contrato_resp DESC
                                )                    AS ordem_bm,
                                CASE
                                    WHEN xs.contrato_resp_inf IS NULL THEN
                                        xs.cod_empresa_pess
                                    ELSE
                                        xs.cod_empr_pess_inf
                                END                  cod_empresa_gestor_superior,
                                CASE
                                    WHEN xs.contrato_resp_inf IS NULL THEN
                                        xs.cod_pessoa_resp
                                    ELSE
                                        xs.cod_pess_informal
                                END                  cod_pessoa_gestor_superior,
                                CASE
                                    WHEN xs.contrato_resp_inf IS NULL THEN
                                        xs.tipo_cont_resp
                                    ELSE
                                        xs.tipo_cont_resp_inf
                                END                  tipo_cont_gestor_superior,
                                CASE
                                    WHEN xs.contrato_resp_inf IS NULL THEN
                                        xs.contrato_resp
                                    ELSE
                                        xs.contrato_resp_inf
                                END                  contrato_gestor_superior
                            FROM
                                arterh.rhorga_custo_geren x
                                LEFT OUTER JOIN arterh.rhorga_agrupador   a ON x.codigo_empresa = a.codigo_empresa
                                                                             AND x.cod_cgerenc1 = a.cod_agrup1
                                                                             AND x.cod_cgerenc2 = a.cod_agrup2
                                                                             AND x.cod_cgerenc3 = a.cod_agrup3
                                                                             AND x.cod_cgerenc4 = a.cod_agrup4
                                                                             AND x.cod_cgerenc5 = a.cod_agrup5
                                                                             AND x.cod_cgerenc6 = a.cod_agrup6
                                LEFT OUTER JOIN rhorga_estrut_agr         e ON e.id_agrup = a.id_agrup
                                                                       AND e.codigo_empresa = a.codigo_empresa
                                LEFT OUTER JOIN arterh.rhorga_custo_geren xs ON e.id_agrup_sup = xs.id_agrup
                                                                                AND e.codigo_empresa = xs.codigo_empresa
                                LEFT OUTER JOIN arterh.rhorga_empresa     em ON x.codigo_empresa = em.codigo
                            WHERE
                                    x.codigo_empresa = (
                                        SELECT
                                            pont.*
                                        FROM
                                            (
                                                SELECT
                                                    substr(pont.dado_origem, 20, 4) empresa
                                                FROM
                                                    rhinte_ed_it_conv pont
                                                WHERE
                                                    codigo_conversao = 'PONT'
                                                GROUP BY
                                                    substr(pont.dado_origem, 20, 4)
                                            ) pont
                                        WHERE
                                            pont.empresa = x.codigo_empresa
                                    )
                                AND x.data_extincao IS NULL -- COMENTADO EM 31/10/17 KELLYSSON, TENHO QUE SEMPRE VERIFICAR O QUE VEIO DO OPUS ATIVANDO, DESATIVANDO E REATIVANDO.
                                AND a.tipo_agrup = 'G'
                                AND a.codigo_empresa = (
                                    SELECT
                                        ep.codigo
                                    FROM
                                        arterh.rhorga_empresa ep
                                    WHERE
                                            a.codigo_empresa = ep.codigo
                                        AND ep.c_livre_selec02 = '1'
                                )
                                AND e.ano_mes_referencia = (
                                    SELECT
                                        MAX(ano_mes_referencia)
                                    FROM
                                        rhorga_estrut_agr aux
                                    WHERE
                                        aux.id_agrup = e.id_agrup
                                )
--AND E.NIVEL_AGRUP_ESTRUT = E.NIVEL_SUP_AGR_EST
                                AND TRIM(x.cgc) = TRIM(em.cgc) --TRIM NOVO EM 07/12/22
---------      AND X.LOGIN_USUARIO   <> 'integracao_ifponto' --KELLYSSON INCLUIDO EM 12/4/18 AS 15H
                                AND ( x.contrato_resp = '000000000000000'
                                      OR x.contrato_resp IS NULL )
                            ORDER BY
                                1,
                                2,
                                3,
                                4,
                                5,
                                6,
                                12
                        )                                      xx
                        LEFT OUTER JOIN ponto_eletronico.sugesp_locais_formais f ON xx.id_agrup = f.id_agrup
                    WHERE
                        f.id_agrup IS NOT NULL --NOVO EM 07/12/22 PARA AJUSTAR APEANAS LOCAIS FORMAIS

        -------------------------------------------------------------------------05/08/2019 AQUI PARA COLOCAR O GESTOR DO NIVEL SUPERIOR NO CAMPO GESTOR FORMAL-------------------------------------
                ) LOOP
                    vcontador2 := vcontador2 + 1;
                    dbms_output.put_line(vcontador2 || '4 TRATAR ');
---FORMAL
                    IF (
                        ( (
                            c2.nivel_agrup_estrut = 2
                            AND c2.nivel_sup_agr_est = 2
                        ) OR (
                            c2.nivel_agrup_estrut = 3
                            AND c2.nivel_sup_agr_est = 3
                        ) OR (
                            c2.nivel_agrup_estrut = 4
                            AND c2.nivel_sup_agr_est = 4
                        ) OR (
                            c2.nivel_agrup_estrut = 5
                            AND c2.nivel_sup_agr_est = 5
                        ) OR (
                            c2.nivel_agrup_estrut = 6
                            AND c2.nivel_sup_agr_est = 6
                        ) OR (
                            c2.nivel_agrup_estrut = 7
                            AND c2.nivel_sup_agr_est = 7
                        ) )
                        AND ( c2.contrato_resp = '000000000000000' OR c2.contrato_resp IS NULL )
                    ) THEN
--dbms_output.put_line(vCONTADOR2||'4- para trocar gestor FORMAL local nivel 2- '||C2.ID_AGRUP ||'-'||C2.CONTRATO_GESTOR_NIVEL_ACIMA);
                        dbms_output.put_line(vcontador2
                                             || '4- para trocar gestor FORMAL local niveIS DE 2 A 7 - '
                                             || c2.id_agrup
                                             || '-'
                                             || c2.contrato_gestor_nivel_acima);

                        UPDATE arterh.rhorga_custo_geren
                        SET
                            cod_empresa_pess = c2.cod_empr_gestor_nivel_acima,
                            cod_pessoa_resp = c2.cod_pess_gestor_nivel_acima,
                            tipo_cont_resp = c2.tipo_cont_gestor_nivel_acima,
                            contrato_resp = c2.contrato_gestor_nivel_acima,
                            login_usuario = 'integracao_ifponto_acao7',
                            dt_ult_alter_usua = sysdate
                        WHERE
                                codigo_empresa = c2.codigo_empresa
                            AND cod_cgerenc1 = c2.cod_cgerenc1
                            AND cod_cgerenc2 = c2.cod_cgerenc2
                            AND cod_cgerenc3 = c2.cod_cgerenc3
                            AND cod_cgerenc4 = c2.cod_cgerenc4
                            AND cod_cgerenc5 = c2.cod_cgerenc5
                            AND cod_cgerenc6 = c2.cod_cgerenc6;

                        COMMIT;
                        UPDATE arterh.rhorga_agrupador
                        SET
                            cod_empresa_pess = c2.cod_empr_gestor_nivel_acima,
                            cod_pessoa_resp = c2.cod_pess_gestor_nivel_acima,
                            tipo_cont_resp = c2.tipo_cont_gestor_nivel_acima,
                            contrato_resp = c2.contrato_gestor_nivel_acima,
                            login_usuario = 'integracao_ifponto_acao7',
                            dt_ult_alter_usua = sysdate
                        WHERE
                                id_agrup = c2.id_agrup
                            AND tipo_agrup = 'G'
                            AND codigo_empresa = c2.codigo_empresa;

                        COMMIT;
                        UPDATE arterh.rhorga_agrupador_h
                        SET
                            cod_empresa_pess = c2.cod_empr_gestor_nivel_acima,
                            cod_pessoa_resp = c2.cod_pess_gestor_nivel_acima,
                            tipo_cont_resp = c2.tipo_cont_gestor_nivel_acima,
                            contrato_resp = c2.contrato_gestor_nivel_acima,
                            login_usuario = 'integracao_ifponto_acao7',
                            dt_ult_alter_usua = sysdate
                        WHERE
                                ano_mes_referencia = (
                                    SELECT
                                        MAX(aux.ano_mes_referencia)
                                    FROM
                                        arterh.rhorga_agrupador_h aux
                                    WHERE
                                            aux.codigo_empresa = rhorga_agrupador_h.codigo_empresa
                                        AND aux.id_agrup = rhorga_agrupador_h.id_agrup
                                )
                            AND id_agrup = c2.id_agrup
                            AND tipo_agrup = 'G'
                            AND codigo_empresa = c2.codigo_empresa;

                        COMMIT;
                    END IF;

                END LOOP;

            END;
        END;

    END;
END;