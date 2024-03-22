
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_GIGPES_SUBSTITUIDO" ("CODIGO_USUARIO", "CODIGO_USUARIO_SUBSTITUTO", "ID_AGRUP", "CODIGO_CONTRATO", "CODIGO_EMPRESA", "TIPO_CONTRATO", "NOME", "NOME_COMPOSTO") AS 
  SELECT P_SIST.codigo_usuario AS CODIGO_USUARIO,
       P_SIST_SUBSTITUIDO.codigo_usuario AS CODIGO_USUARIO_SUBSTITUTO,
       AGRUP_SUBSEC.id_agrup AS ID_AGRUP,
       CONTRATO.codigo AS CODIGO_CONTRATO,
       CONTRATO.codigo_empresa AS CODIGO_EMPRESA,
       CONTRATO.tipo_contrato AS TIPO_CONTRATO,
       P_SIST_SUBSTITUIDO.nome_usuario AS NOME,
       (CONTRATO.codigo || ' - ' || CONTRATO.nome || ' - ' ||
          (SELECT descricao
           FROM rhpess_tp_contrato
           WHERE codigo = CONTRATO.tipo_contrato) || ' - ' || AGRUP_SUBSEC.descricao) AS 
       NOME_COMPOSTO
FROM rhpess_contrato CONTRATO_USUARIO,
     rhpess_contrato CONTRATO,
     rhuser_p_sist P_SIST,
     rhuser_p_sist P_SIST_SUBSTITUIDO,
     rhorga_agrupador AGRUP_SUBSEC,
     rhorga_agrupador AGRUP_USUA,
     rhorga_estrut_agr ESTRUT_AGR,
     rhorga_estrut_agr ESTRUT_SUBSEC
WHERE 
  ((CONTRATO.codigo_empresa = P_SIST.empresa_usuario
        AND CONTRATO.tipo_contrato = P_SIST.tp_contr_usuario
        AND CONTRATO.codigo = P_SIST.contrato_usuario)
       OR (CONTRATO.codigo_empresa ||CONTRATO.tipo_contrato ||CONTRATO.codigo IN
             (SELECT PESSOA_RESPONSAVEL.codigo_empresa_pessoa_resp ||PESSOA_RESPONSAVEL.tipo_contrato_resp ||PESSOA_RESPONSAVEL.codigo_contrato_resp
              FROM rhuser_pessoa_responsavel PESSOA_RESPONSAVEL
              WHERE PESSOA_RESPONSAVEL.codigo_usuario = P_SIST.codigo_usuario
                AND PESSOA_RESPONSAVEL.dt_inicio_responsabilidade <= sysdate
                AND (PESSOA_RESPONSAVEL.dt_fim_responsabilidade >= sysdate
                     OR PESSOA_RESPONSAVEL.dt_fim_responsabilidade IS NULL) )))
  AND CONTRATO.codigo = P_SIST_SUBSTITUIDO.contrato_usuario
  AND CONTRATO.tipo_contrato = P_SIST_SUBSTITUIDO.tp_contr_usuario
  AND CONTRATO.codigo_empresa = P_SIST_SUBSTITUIDO.empresa_usuario
  AND P_SIST_SUBSTITUIDO.status_usuario = 'A'
  AND CONTRATO_USUARIO.codigo = P_SIST.contrato_usuario
  AND CONTRATO_USUARIO.tipo_contrato = P_SIST.tp_contr_usuario
  AND CONTRATO_USUARIO.codigo_empresa = P_SIST.empresa_usuario
  AND ESTRUT_AGR.codigo_empresa = ESTRUT_SUBSEC.codigo_empresa
  AND ESTRUT_AGR.id_agrup_sup = ESTRUT_SUBSEC.id_agrup_sup
  AND ESTRUT_AGR.codigo_empresa = AGRUP_SUBSEC.codigo_empresa
  AND ESTRUT_AGR.id_agrup = AGRUP_SUBSEC.id_agrup
  AND ESTRUT_AGR.ano_mes_referencia =
    (SELECT Max(ESTRUT_AGR_MAX.ano_mes_referencia)
     FROM rhorga_estrut_agr ESTRUT_AGR_MAX
     WHERE ESTRUT_AGR_MAX.codigo_empresa = ESTRUT_AGR.codigo_empresa
       AND ESTRUT_AGR_MAX.id_agrup_sup = ESTRUT_AGR.id_agrup_sup
       AND ESTRUT_AGR_MAX.id_agrup = ESTRUT_AGR.id_agrup
       AND ESTRUT_AGR_MAX.ano_mes_referencia < SYSDATE)
  AND ESTRUT_SUBSEC.codigo_empresa = AGRUP_USUA.codigo_empresa
  AND ESTRUT_SUBSEC.id_agrup = AGRUP_USUA.id_agrup
  AND ESTRUT_SUBSEC.nivel_sup_agr_est = 3
  AND ESTRUT_SUBSEC.ano_mes_referencia =
    (SELECT Max(ESTRUT_AGR_MAX.ano_mes_referencia)
     FROM rhorga_estrut_agr ESTRUT_AGR_MAX
     WHERE ESTRUT_AGR_MAX.codigo_empresa = ESTRUT_SUBSEC.codigo_empresa
       AND ESTRUT_AGR_MAX.id_agrup_sup = ESTRUT_SUBSEC.id_agrup_sup
       AND ESTRUT_AGR_MAX.id_agrup = ESTRUT_SUBSEC.id_agrup
       AND ESTRUT_AGR_MAX.ano_mes_referencia < SYSDATE)
  AND AGRUP_USUA.tipo_agrup = P_SIST.tipo_agrup_usuario
  AND AGRUP_SUBSEC.tipo_agrup = P_SIST.tipo_agrup_usuario
  AND AGRUP_SUBSEC.data_extincao IS NULL
  AND ((AGRUP_USUA.tipo_agrup = 'U'
        AND AGRUP_USUA.tipo_agrup = CONTRATO_USUARIO.tipo_agrup_unid
        AND AGRUP_USUA.cod_agrup1 = CONTRATO_USUARIO.cod_unidade1
        AND AGRUP_USUA.cod_agrup2 = CONTRATO_USUARIO.cod_unidade2
        AND AGRUP_USUA.cod_agrup3 = CONTRATO_USUARIO.cod_unidade3
        AND AGRUP_USUA.cod_agrup4 = CONTRATO_USUARIO.cod_unidade4
        AND AGRUP_USUA.cod_agrup5 = CONTRATO_USUARIO.cod_unidade5
        AND AGRUP_USUA.cod_agrup6 = CONTRATO_USUARIO.cod_unidade6)
       OR (AGRUP_USUA.tipo_agrup = 'L'
           AND AGRUP_USUA.tipo_agrup = CONTRATO_USUARIO.tipo_agrup_lota
           AND AGRUP_USUA.cod_agrup1 = CONTRATO_USUARIO.cod_local1
           AND AGRUP_USUA.cod_agrup2 = CONTRATO_USUARIO.cod_local2
           AND AGRUP_USUA.cod_agrup3 = CONTRATO_USUARIO.cod_local3
           AND AGRUP_USUA.cod_agrup4 = CONTRATO_USUARIO.cod_local4
           AND AGRUP_USUA.cod_agrup5 = CONTRATO_USUARIO.cod_local5
           AND AGRUP_USUA.cod_agrup6 = CONTRATO_USUARIO.cod_local6)
       OR (AGRUP_USUA.tipo_agrup = 'C'
           AND AGRUP_USUA.tipo_agrup = CONTRATO_USUARIO.tipo_agrup_cont
           AND AGRUP_USUA.cod_agrup1 = CONTRATO_USUARIO.cod_custo_contab1
           AND AGRUP_USUA.cod_agrup2 = CONTRATO_USUARIO.cod_custo_contab2
           AND AGRUP_USUA.cod_agrup3 = CONTRATO_USUARIO.cod_custo_contab3
           AND AGRUP_USUA.cod_agrup4 = CONTRATO_USUARIO.cod_custo_contab4
           AND AGRUP_USUA.cod_agrup5 = CONTRATO_USUARIO.cod_custo_contab5
           AND AGRUP_USUA.cod_agrup6 = CONTRATO_USUARIO.cod_custo_contab6)
       OR (AGRUP_USUA.tipo_agrup = 'G'
           AND AGRUP_USUA.tipo_agrup = CONTRATO_USUARIO.tipo_agrup_cger
           AND AGRUP_USUA.cod_agrup1 = CONTRATO_USUARIO.cod_custo_gerenc1
           AND AGRUP_USUA.cod_agrup2 = CONTRATO_USUARIO.cod_custo_gerenc2
           AND AGRUP_USUA.cod_agrup3 = CONTRATO_USUARIO.cod_custo_gerenc3
           AND AGRUP_USUA.cod_agrup4 = CONTRATO_USUARIO.cod_custo_gerenc4
           AND AGRUP_USUA.cod_agrup5 = CONTRATO_USUARIO.cod_custo_gerenc5
           AND AGRUP_USUA.cod_agrup6 = CONTRATO_USUARIO.cod_custo_gerenc6))
  AND ((AGRUP_SUBSEC.tipo_agrup = 'U'
        AND AGRUP_SUBSEC.tipo_agrup = CONTRATO.tipo_agrup_unid
        AND AGRUP_SUBSEC.cod_agrup1 = CONTRATO.cod_unidade1
        AND AGRUP_SUBSEC.cod_agrup2 = CONTRATO.cod_unidade2
        AND AGRUP_SUBSEC.cod_agrup3 = CONTRATO.cod_unidade3
        AND AGRUP_SUBSEC.cod_agrup4 = CONTRATO.cod_unidade4
        AND AGRUP_SUBSEC.cod_agrup5 = CONTRATO.cod_unidade5
        AND AGRUP_SUBSEC.cod_agrup6 = CONTRATO.cod_unidade6)
       OR (AGRUP_SUBSEC.tipo_agrup = 'L'
           AND AGRUP_SUBSEC.tipo_agrup = CONTRATO.tipo_agrup_lota
           AND AGRUP_SUBSEC.cod_agrup1 = CONTRATO.cod_local1
           AND AGRUP_SUBSEC.cod_agrup2 = CONTRATO.cod_local2
           AND AGRUP_SUBSEC.cod_agrup3 = CONTRATO.cod_local3
           AND AGRUP_SUBSEC.cod_agrup4 = CONTRATO.cod_local4
           AND AGRUP_SUBSEC.cod_agrup5 = CONTRATO.cod_local5
           AND AGRUP_SUBSEC.cod_agrup6 = CONTRATO.cod_local6)
       OR (AGRUP_SUBSEC.tipo_agrup = 'C'
           AND AGRUP_SUBSEC.tipo_agrup = CONTRATO.tipo_agrup_cont
           AND AGRUP_SUBSEC.cod_agrup1 = CONTRATO.cod_custo_contab1
           AND AGRUP_SUBSEC.cod_agrup2 = CONTRATO.cod_custo_contab2
           AND AGRUP_SUBSEC.cod_agrup3 = CONTRATO.cod_custo_contab3
           AND AGRUP_SUBSEC.cod_agrup4 = CONTRATO.cod_custo_contab4
           AND AGRUP_SUBSEC.cod_agrup5 = CONTRATO.cod_custo_contab5
           AND AGRUP_SUBSEC.cod_agrup6 = CONTRATO.cod_custo_contab6)
       OR (AGRUP_SUBSEC.tipo_agrup = 'G'
           AND AGRUP_SUBSEC.tipo_agrup = CONTRATO.tipo_agrup_cger
           AND AGRUP_SUBSEC.cod_agrup1 = CONTRATO.cod_custo_gerenc1
           AND AGRUP_SUBSEC.cod_agrup2 = CONTRATO.cod_custo_gerenc2
           AND AGRUP_SUBSEC.cod_agrup3 = CONTRATO.cod_custo_gerenc3
           AND AGRUP_SUBSEC.cod_agrup4 = CONTRATO.cod_custo_gerenc4
           AND AGRUP_SUBSEC.cod_agrup5 = CONTRATO.cod_custo_gerenc5
           AND AGRUP_SUBSEC.cod_agrup6 = CONTRATO.cod_custo_gerenc6))
  AND (CONTRATO.data_rescisao IS NULL
       OR CONTRATO.data_rescisao > SYSDATE)
  AND CONTRATO.ano_mes_referencia =
    (SELECT Max(MAX_CONTRATO.ano_mes_referencia)
     FROM rhpess_contrato MAX_CONTRATO
     WHERE MAX_CONTRATO.codigo_empresa = CONTRATO.codigo_empresa
       AND MAX_CONTRATO.tipo_contrato = CONTRATO.tipo_contrato
       AND MAX_CONTRATO.codigo = CONTRATO.codigo
       AND MAX_CONTRATO.ano_mes_referencia > Trunc(SYSDATE, 'yyyy'))
  AND (CONTRATO_USUARIO.data_rescisao IS NULL
       OR CONTRATO_USUARIO.data_rescisao > SYSDATE)
  AND CONTRATO_USUARIO.ano_mes_referencia =
    (SELECT Max(MAX_CONTRATO.ano_mes_referencia)
     FROM rhpess_contrato MAX_CONTRATO
     WHERE MAX_CONTRATO.codigo_empresa = CONTRATO_USUARIO.codigo_empresa
       AND MAX_CONTRATO.tipo_contrato = CONTRATO_USUARIO.tipo_contrato
       AND MAX_CONTRATO.codigo = CONTRATO_USUARIO.codigo
       AND MAX_CONTRATO.ano_mes_referencia > Trunc(SYSDATE, 'yyyy'))
ORDER BY CONTRATO.nome