
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_ARTERH_SIGBASES_CONTRATO" ("EMPRESA", "DESCRICAO_EMPRESA", "ID_PROF", "ID_ESTAB", "MATRICULA", "CARGA_HORARIA", "COD_ESCALA", "DESC_ESCALA", "EXISTE_DUPLA_LOTACAO", "DATA_ADMISSAO", "DATA_DEMISSAO", "DESCR_DEMISSAO", "DATA_INICIO_AFAST", "DATA_FIM_AFAST", "DESC_AFAST", "DT_INI_DUPLA_LOTA", "DT_FIM_DUPLA_LOTA", "CRM_CONSELHO_CLAS_PROF", "INSC_CONSELHO_CLAS_PROF", "UF_CONSELHO_CLAS_PROF", "CARGO", "CATEG_PROFISSIONAL", "ESPECIALIDADE", "CBO_ESPECIALIDADE", "CBO_CARGO", "SITUACAO_FUCNIONAL", "VINCULO_PROFISSIONAL", "MOVIMENTACAO", "VALOR_FIXO", "LOTACAO", "UNIDADE", "CONTABIL", "GERENCIAL", "DUPLA_LOTACAO", "DATA_PREVISAO_ENCERRAMENTO_CONTRATO", "CNS", "CODIGO_CARGO_COMISSIONADO", "DESCRICAO_CARGO_COMISSIONADO", "CODIGO_FUNCAO_PUBLICA", "DESCRICAO_FUNCAO_PUBLICA", "ULTIMA_ALTERACAO_CONTRATO", "SUPERIOR_DUPLA_LOTACAO", "PRINCIPAL", "DATA_ULTIMA_ALTERCAO_DUPLA_LOTACAO") AS 
  SELECT 
    emp.codigo                             AS empresa,
    emp.razao_social                       AS descricao_empresa,
    c.codigo_pessoa                        AS id_prof,
    ' '                                    AS id_estab,
    c.codigo                               AS matricula,
    CASE
        WHEN ag_tf.codigo_escala IS NULL THEN
            substr(cec.horas_semana_rais, 1, 4)
        ELSE
            substr(ce.horas_semana_rais, 1, 4)
    END                                    AS carga_horaria,
    CASE
        WHEN ag_tf.codigo_escala IS NULL THEN
            cec.codigo
        ELSE
            ce.codigo
    END                                    AS cod_escala,
    CASE
        WHEN ag_tf.codigo_escala IS NULL THEN
            substr(cec.descricao, 1, 50)
        ELSE
            substr(ce.descricao, 1, 50)
    END                                    AS desc_escala,
    CASE
        WHEN ag_tf.codigo_escala IS NULL THEN
            'NÃO'
        ELSE
            'SIM'
    END                                    AS existe_dupla_lotacao,
    to_char(c.data_admissao, 'DD/MM/YYYY') AS data_admissao,
    CASE
        WHEN c.data_rescisao IS NULL THEN
            lpad(' ', 10, ' ')
        ELSE
            to_char(c.data_rescisao, 'DD/MM/YYYY')
    END                                    AS data_demissao,
    CASE
        WHEN c.data_rescisao IS NOT NULL
             AND sf.controle_folha = 'D' THEN
            sf.descricao
        ELSE
            ' '
    END                                    AS descr_demissao,
    CASE
        WHEN ( c.data_inic_afast IS NOT NULL
               AND c.data_fim_afast IS NULL
               OR c.data_inic_afast IS NOT NULL
               AND c.data_fim_afast >= c.ano_mes_referencia ) THEN
            to_char(c.data_inic_afast, 'DD/MM/YYYY')
        ELSE
            lpad(' ', 10, ' ')
    END                                    AS data_inicio_afast,
    CASE
        WHEN ( c.data_inic_afast IS NOT NULL
               AND c.data_fim_afast IS NULL
               OR c.data_inic_afast IS NOT NULL
               AND c.data_fim_afast >= c.ano_mes_referencia ) THEN
            to_char(c.data_fim_afast, 'DD/MM/YYYY')
        ELSE
            lpad(' ', 10, ' ')
    END                                    AS data_fim_afast,
    CASE
        WHEN c.data_inic_afast IS NOT NULL
             AND c.data_fim_afast IS NULL
             OR c.data_fim_afast >= c.ano_mes_referencia THEN
            sf.descricao
        ELSE
            ' '
    END                                    AS desc_afast,
    CASE
        WHEN ag_tf.dt_alt_unid_custo IS NULL THEN
            lpad(' ', 10, ' ')
        ELSE
            to_char(ag_tf.dt_alt_unid_custo, 'DD/MM/YYYY')
    END                                    AS dt_ini_dupla_lota,
    CASE
        WHEN ag_tf.dt_fim_temp IS NULL THEN
            lpad(' ', 10, ' ')
        ELSE
            to_char(ag_tf.dt_fim_temp, 'DD/MM/YYYY')
    END                                    AS dt_fim_dupla_lota,
    CASE
        WHEN cn.descricao IS NULL THEN
            lpad(' ', 30, ' ')
        ELSE
            substr(cn.descricao, 1, 30)
    END                                    AS crm_conselho_clas_prof,
    CASE
        WHEN c.inscricao_conselho IS NULL THEN
            lpad(' ', 20, ' ')
        ELSE
            substr(c.inscricao_conselho, 1, 20)
    END                                    AS insc_conselho_clas_prof,
    CASE
        WHEN uf1.descricao IS NULL THEN
            lpad(' ', 10, ' ')
        ELSE
            substr(uf1.codigo_rais, 1, 4)
            || '- '
            || substr(uf1.descricao, 1, 40)
    END                                    AS uf_conselho_clas_prof,
    CASE
        WHEN cg.descricao IS NULL THEN
            lpad(' ', 40, ' ')
        ELSE
            substr(cg.descricao, 1, 40)
    END                                    AS cargo,
    CASE
        WHEN cp.descricao IS NULL THEN
            lpad(' ', 35, ' ')
        ELSE
            substr(cp.descricao, 1, 35)
    END                                    AS categ_profissional,
    CASE
        WHEN esp.descricao IS NULL THEN
            lpad(' ', 35, ' ')
        ELSE
            substr(esp.descricao, 1, 35)
    END                                    AS especialidade,
    CASE
        WHEN esp.cbo2002 IS NULL THEN
            lpad(' ', 15, ' ')
        ELSE
            substr(esp.cbo2002, 1, 15)
    END                                    AS cbo_especialidade,



    CASE
        WHEN cg.cbo2002 IS NULL THEN
            lpad(' ', 15, ' ')
        ELSE
            substr(cg.cbo2002, 1, 15)
    END                                    AS cbo_cargo,
    CASE
        WHEN sf.descricao IS NULL THEN
            lpad(' ', 40, ' ')
        ELSE
            substr(sf.descricao, 1, 40)
    END                                    AS situacao_fucnional,
    CASE
        WHEN vm.descricao IS NULL THEN
            lpad(' ', 30, ' ')
        ELSE
            substr(vm.descricao, 1, 30)
    END                                    AS vinculo_profissional,
    CASE
        WHEN sf.descricao IS NULL THEN
            lpad(' ', 40, ' ')
        ELSE
            substr(sf.descricao, 1, 40)
    END                                    AS movimentacao,
    'IMPORTACAO ARTERH'                    AS valor_fixo,
    c.cod_local1
    || '.'
    || c.cod_local2
    || '.'
    || c.cod_local3
    || '.'
    || c.cod_local4
    || '.'
    || c.cod_local5
    || '.'
    || c.cod_local6
    || ' - '
    || ag_cont_lot.descricao               AS lotacao,
    c.cod_unidade1
    || '.'
    || c.cod_unidade2
    || '.'
    || c.cod_unidade3
    || '.'
    || c.cod_unidade4
    || '.'
    || c.cod_unidade5
    || '.'
    || c.cod_unidade6
    || ' - '
    || ag_cont_unid.descricao              AS unidade,
    c.cod_custo_contab1
    || '.'
    || c.cod_custo_contab2
    || '.'
    || c.cod_custo_contab3
    || '.'
    || c.cod_custo_contab4
    || '.'
    || c.cod_custo_contab5
    || '.'
    || c.cod_custo_contab6
    || ' - '
    || ag_cont_contab.descricao            AS contabil,
    c.cod_custo_gerenc1
    || '.'
    || c.cod_custo_gerenc2
    || '.'
    || c.cod_custo_gerenc3
    || '.'
    || c.cod_custo_gerenc4
    || '.'
    || c.cod_custo_gerenc5
    || '.'
    || c.cod_custo_gerenc6
    || ' - '
    || ag_cont_gerenc.descricao            AS gerencial,
    CASE
        WHEN ag_tf.dt_fim_temp IS NULL
             AND ag_tf.codigo_contrato IS NOT NULL THEN
            ag_tf.cod_agrup1
            || '.'
            || ag_tf.cod_agrup2
            || '.'
            || ag_tf.cod_agrup3
            || '.'
            || ag_tf.cod_agrup4
            || '.'
            || ag_tf.cod_agrup5
            || '.'
            || ag_tf.cod_agrup6
            || '-'
            || ag.descricao
        ELSE
            c.cod_custo_gerenc1
            || '.'
            || c.cod_custo_gerenc2
            || '.'
            || c.cod_custo_gerenc3
            || '.'
            || c.cod_custo_gerenc4
            || '.'
            || c.cod_custo_gerenc5
            || '.'
            || c.cod_custo_gerenc6
            || ' - '
            || ag_cont_gerenc.descricao
    END                                    AS dupla_lotacao,
    c.dt_fim_contr_deter                   AS data_previsao_encerramento_contrato,
    p.cartao_nacio_saude                   AS cns,
    cargo.codigo                           AS codigo_cargo_comissionado,
    cargo.descricao                        AS descricao_cargo_comissionado,
    funcao.codigo                          AS codigo_funcao_publica,
    funcao.descricao                       AS descricao_funcao_publica,
    c.dt_ult_alter_usua                    AS ultima_alteracao_CONTRATO,
    dupla_lotacao_superiro.cod_agrup1
    || '.'
    || dupla_lotacao_superiro.cod_agrup2
    || '.'
    || dupla_lotacao_superiro.cod_agrup3
    || '.'
    || dupla_lotacao_superiro.cod_agrup4
    || '.'
    || dupla_lotacao_superiro.cod_agrup5
    || '.'
    || dupla_lotacao_superiro.cod_agrup6
    || ' - '
    || dupla_lotacao_superiro.descricao AS SUPERIOR_DUPLA_LOTACAO,
    CASE WHEN 
    dupla_lotacao_superiro.cod_agrup1||dupla_lotacao_superiro.cod_agrup2||dupla_lotacao_superiro.cod_agrup3||dupla_lotacao_superiro.cod_agrup4||dupla_lotacao_superiro.cod_agrup5||dupla_lotacao_superiro.cod_agrup6
    = c.cod_custo_gerenc1||c.cod_custo_gerenc2|| c.cod_custo_gerenc3||c.cod_custo_gerenc4||c.cod_custo_gerenc5||c.cod_custo_gerenc6 THEN 'SIM' ELSE 'NAO' END AS PRINCIPAL,
    ag_tf.DT_ULT_ALTER_USUA AS DATA_ULTIMA_ALTERCAO_DUPLA_LOTACAO
FROM
    arterh.rhpess_contrato           c
    LEFT OUTER JOIN arterh.rhpess_pessoa             p ON p.codigo = c.codigo_pessoa
                                              AND p.codigo_empresa = c.codigo_empresa
    LEFT OUTER JOIN arterh.rhplcs_cargo              cg ON cg.codigo = c.cod_cargo_pagto
                                              AND cg.codigo_empresa = c.codigo_empresa
    LEFT OUTER JOIN arterh.rhtabs_vinculo_emp        vm ON vm.codigo = c.vinculo
    LEFT OUTER JOIN arterh.rhtabs_cat_profis         cp ON cp.codigo = c.categ_profissional
                                                   AND cp.codigo_empresa = c.codigo_empresa
    LEFT OUTER JOIN arterh.rhtabs_c_regional         cn ON cn.codigo = c.conselho_regional
    LEFT OUTER JOIN arterh.rhtabs_uf                 uf1 ON uf1.codigo = c.uf_conselho
    LEFT OUTER JOIN arterh.rhtabs_nacionalid         tn ON tn.codigo = p.nacionalidade
    LEFT OUTER JOIN arterh.rhcged_transf_agr         ag_tf ON ag_tf.codigo_contrato = c.codigo
                                                      AND ag_tf.tipo_contrato = c.tipo_contrato
                                                      AND ag_tf.codigo_empresa = c.codigo_empresa
                                                      AND ag_tf.tipo_agrup = 'G'
    LEFT OUTER JOIN arterh.rhorga_agrupador          ag ON ag.cod_agrup1 = ag_tf.cod_agrup1
                                                  AND ag.cod_agrup2 = ag_tf.cod_agrup2
                                                  AND ag.cod_agrup3 = ag_tf.cod_agrup3
                                                  AND ag.cod_agrup4 = ag_tf.cod_agrup4
                                                  AND ag.cod_agrup5 = ag_tf.cod_agrup5
                                                  AND ag.cod_agrup6 = ag_tf.cod_agrup6
                                                  AND ag.codigo_empresa = ag_tf.cod_emp_agrup
                                                  AND ag.tipo_agrup = ag_tf.tipo_agrup
    LEFT OUTER JOIN arterh.rhorga_agrupador          dupla_lotacao_superiro ON ag.tipo_agrup = dupla_lotacao_superiro.tipo_agrup
                                                                      AND dupla_lotacao_superiro.cod_agrup1 = ag.cod_agrup_sup1
                                                                      AND dupla_lotacao_superiro.cod_agrup2 = ag.cod_agrup_sup2
                                                                      AND dupla_lotacao_superiro.cod_agrup3 = ag.cod_agrup_sup3
                                                                      AND dupla_lotacao_superiro.cod_agrup4 = ag.cod_agrup_sup4
                                                                      AND dupla_lotacao_superiro.cod_agrup5 = ag.cod_agrup_sup5
                                                                      AND dupla_lotacao_superiro.cod_agrup6 = ag.cod_agrup_sup6
                                                                      AND dupla_lotacao_superiro.codigo_empresa = ag.codigo_empresa
    LEFT OUTER JOIN arterh.rhorga_agrupador          ag_cont_lot ON ag_cont_lot.cod_agrup1 = c.cod_local1
                                                           AND ag_cont_lot.cod_agrup2 = c.cod_local2
                                                           AND ag_cont_lot.cod_agrup3 = c.cod_local3
                                                           AND ag_cont_lot.cod_agrup4 = c.cod_local4
                                                           AND ag_cont_lot.cod_agrup5 = c.cod_local5
                                                           AND ag_cont_lot.cod_agrup6 = c.cod_local6
                                                           AND ag_cont_lot.codigo_empresa = c.codigo_empresa
                                                           AND ag_cont_lot.tipo_agrup = 'L'
    LEFT OUTER JOIN arterh.rhorga_agrupador          ag_cont_unid ON ag_cont_unid.cod_agrup1 = c.cod_unidade1
                                                            AND ag_cont_unid.cod_agrup2 = c.cod_unidade2
                                                            AND ag_cont_unid.cod_agrup3 = c.cod_unidade3
                                                            AND ag_cont_unid.cod_agrup4 = c.cod_unidade4
                                                            AND ag_cont_unid.cod_agrup5 = c.cod_unidade5
                                                            AND ag_cont_unid.cod_agrup6 = c.cod_unidade6
                                                            AND ag_cont_unid.codigo_empresa = c.codigo_empresa
                                                            AND ag_cont_unid.tipo_agrup = 'U'
    LEFT OUTER JOIN arterh.rhorga_agrupador          ag_cont_contab ON ag_cont_contab.cod_agrup1 = c.cod_custo_contab1
                                                              AND ag_cont_contab.cod_agrup2 = c.cod_custo_contab2
                                                              AND ag_cont_contab.cod_agrup3 = c.cod_custo_contab3
                                                              AND ag_cont_contab.cod_agrup4 = c.cod_custo_contab4
                                                              AND ag_cont_contab.cod_agrup5 = c.cod_custo_contab5
                                                              AND ag_cont_contab.cod_agrup6 = c.cod_custo_contab6
                                                              AND ag_cont_contab.codigo_empresa = c.codigo_empresa
                                                              AND ag_cont_contab.tipo_agrup = 'C'
    LEFT OUTER JOIN arterh.rhorga_agrupador          ag_cont_gerenc ON ag_cont_gerenc.cod_agrup1 = c.cod_custo_gerenc1
                                                              AND ag_cont_gerenc.cod_agrup2 = c.cod_custo_gerenc2
                                                              AND ag_cont_gerenc.cod_agrup3 = c.cod_custo_gerenc3
                                                              AND ag_cont_gerenc.cod_agrup4 = c.cod_custo_gerenc4
                                                              AND ag_cont_gerenc.cod_agrup5 = c.cod_custo_gerenc5
                                                              AND ag_cont_gerenc.cod_agrup6 = c.cod_custo_gerenc6
                                                              AND ag_cont_gerenc.codigo_empresa = c.codigo_empresa
                                                              AND ag_cont_gerenc.tipo_agrup = 'G'
    LEFT OUTER JOIN arterh.rhpont_escala             ce ON ce.codigo_empresa = ag_tf.cod_emp_agrup
                                               AND ce.codigo = ag_tf.codigo_escala
    LEFT OUTER JOIN arterh.rhpont_escala             cec ON cec.codigo_empresa = c.codigo_empresa
                                                AND cec.codigo = c.codigo_escala
    LEFT OUTER JOIN arterh.rhpess_pess_tp_for        tp_forn ON tp_forn.cod_empresa = c.codigo_empresa
                                                         AND tp_forn.cod_pessoa = c.codigo_pessoa
                                                         AND tp_forn.tipo_contrato = c.tipo_contrato
                                                         AND tp_forn.codigo_contrato = c.codigo
                                                         AND tp_forn.cod_tipo_fornec = '0002'
    LEFT OUTER JOIN arterh.rhorga_fornecedor         forn ON forn.codigo = tp_forn.cod_fornecedor
    LEFT OUTER JOIN arterh.rhplcs_especialid         esp ON esp.codigo = c.cod_especialidade
                                                    AND esp.codigo_empresa = c.codigo_empresa


    LEFT OUTER JOIN arterh.rhparm_sit_func           sf ON sf.codigo = c.situacao_funcional
    LEFT OUTER JOIN arterh.rhorga_empresa            emp ON emp.codigo = c.codigo_empresa
    LEFT OUTER JOIN arterh.rhplcs_cargo              cargo ON cargo.codigo_empresa = c.codigo_empresa
                                                 AND cargo.codigo = c.cod_cargo_comiss
    LEFT OUTER JOIN arterh.rhplcs_funcao             funcao ON funcao.codigo_empresa = c.codigo_empresa
                                                   AND funcao.codigo = c.codigo_funcao
WHERE
        c.ano_mes_referencia = (
            SELECT
                MAX(aux.ano_mes_referencia)
            FROM
                arterh.rhpess_contrato aux
            WHERE
                    aux.codigo_empresa = c.codigo_empresa
                AND aux.tipo_contrato = c.tipo_contrato
                AND aux.codigo = c.codigo
        )
    AND c.codigo_empresa = '0001'
    AND c.tipo_contrato IN ( '0001', '0211', '0212', '0213', '0214',
                             '0215', '0015', '0007', '0216' )
    AND c.cod_custo_contab1 IN ( '000095' )