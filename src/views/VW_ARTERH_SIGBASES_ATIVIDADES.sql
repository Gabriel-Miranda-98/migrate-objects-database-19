
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_ARTERH_SIGBASES_ATIVIDADES" ("CODIGO_EMPRESA", "TIPO_CONTRATO", "MATRICULA", "DATA_INI_ATIVIDADE", "DATA_FIM_ATIVIDADE", "CBO_FUNCAO_EXERCIDA", "DESCR_CBO_FUNCAO_EXERCIDA", "CODIGO_ATIVIDADE", "ULTMA_ALTERACAO", "AGRUPADOR", "ID_AGRUP", "LOTACAO", "AGRUPADOR_SUPERIOR", "ID_AGRUP_SUPERIOR") AS 
  WITH maxanomes AS (
    SELECT
        aux.codigo,
        aux.tipo_contrato,
        aux.codigo_empresa,
        MAX(aux.ano_mes_referencia) AS max_ano_mes_referencia
    FROM
        arterh.rhpess_contrato aux
    GROUP BY
        aux.codigo,
        aux.tipo_contrato,
        aux.codigo_empresa
)
SELECT
    ae.codigo_empresa,
    ae.tipo_contrato,
    ae.codigo_contrato   AS matricula,
    ae.data_ini_atividade,
    ae.data_fim_atividade,
    CASE
        WHEN ae.cbo2002 IS NULL THEN
            lpad(' ', 15, ' ')
        ELSE
            substr(ae.cbo2002, 1, 15)
    END                  AS cbo_funcao_exercida,
    CASE
        WHEN ae.cbo2002 IS NULL THEN
            lpad(' ', 15, ' ')
        ELSE
            cbo_ae.descr_cbo2002
    END                  AS descr_cbo_funcao_exercida,
    CASE
        WHEN ae.codigo_atividade IS NULL THEN
            ''
        ELSE
            ativ.codigo_atividade
            || '-'
            || ativ.descr_atividade
    END                  AS codigo_atividade,
    ae.dt_ult_alter_usua AS ultma_alteracao,
    CASE
        WHEN ag.cod_agrup1 IS NULL THEN
            NULL
        ELSE
            ag.cod_agrup1
            || '.'
            || ag.cod_agrup2
            || '.'
            || ag.cod_agrup3
            || '.'
            || ag.cod_agrup4
            || '.'
            || ag.cod_agrup5
            || '.'
            || ag.cod_agrup6
            || '-'
            || nvl(ag.descricao, ag.texto_associado)
    END                  AS agrupador,
    ag.id_agrup,
    g.cod_cgerenc1||'.'||g.cod_cgerenc2||'.'||g.cod_cgerenc3||'.'||g.cod_cgerenc4||'.'||g.cod_cgerenc5||'.'||g.cod_cgerenc6||'-'||nvl(g.descricao, g.texto_associado) AS LOTACAO,
      CASE
        WHEN SUP.cod_agrup1 IS NULL THEN
            NULL
        ELSE
            SUP.cod_agrup1
            || '.'
            || SUP.cod_agrup2
            || '.'
            || SUP.cod_agrup3
            || '.'
            || SUP.cod_agrup4
            || '.'
            || SUP.cod_agrup5
            || '.'
            || SUP.cod_agrup6
            || '-'
            || nvl(SUP.descricao, SUP.texto_associado)
    END                  AS agrupador_SUPERIOR,
    SUP.ID_AGRUP AS ID_AGRUP_SUPERIOR
    
    
FROM
    arterh.rhplcs_atividade_exercida ae
    LEFT JOIN arterh.rhplcs_atividade          ativ ON ae.codigo_atividade = ativ.codigo_atividade
                                              AND ae.codigo_empresa = ativ.codigo_empresa
    LEFT JOIN arterh.rhplcs_cbo2002            cbo_ae ON ae.cbo2002 = cbo_ae.cbo2002
    LEFT OUTER JOIN arterh.rhorga_agrupador          ag
    ON ag.codigo_empresa = ae.codigo_empresa
                                           AND ag.id_agrup = ae.id_agrup
                                           AND ag.tipo_agrup = 'G'
    INNER JOIN arterh.rhpess_contrato           c 
    ON C.CODIGO=AE.CODIGO_CONTRATO
    AND C.CODIGO_EMPRESA=AE.CODIGO_EMPRESA
    AND C.TIPO_CONTRATO=AE.TIPO_CONTRATO
    JOIN maxanomes                        m ON m.codigo = c.codigo
                        AND m.tipo_contrato = c.tipo_contrato
                        AND m.codigo_empresa = c.codigo_empresa
                        AND m.max_ano_mes_referencia = c.ano_mes_referencia
    INNER JOIN ARTERH.rhorga_custo_geren G
    ON G.CODIGO_EMPRESA=C.CODIGO_EMPRESA
    AND g.cod_cgerenc1=c.cod_custo_gerenc1
    AND  g.cod_cgerenc2=c.cod_custo_gerenc2
    AND  g.cod_cgerenc3=c.cod_custo_gerenc3
    AND  g.cod_cgerenc4=c.cod_custo_gerenc4
    AND  g.cod_cgerenc5=c.cod_custo_gerenc5
    AND  g.cod_cgerenc6=c.cod_custo_gerenc6
     LEFT OUTER JOIN arterh.rhorga_agrupador          SUP
    ON SUP.codigo_empresa = AG.codigo_empresa
    AND SUP.cod_agrup1=ag.cod_agrup_sup1
     AND SUP.cod_agrup2=ag.cod_agrup_sup2
      AND SUP.cod_agrup3=ag.cod_agrup_sup3
       AND SUP.cod_agrup4=ag.cod_agrup_sup4
        AND SUP.cod_agrup5=ag.cod_agrup_sup5
         AND SUP.cod_agrup6=ag.cod_agrup_sup6
   AND SUP.tipo_agrup = 'G'