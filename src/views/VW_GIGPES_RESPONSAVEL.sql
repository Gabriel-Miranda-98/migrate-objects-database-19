
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_GIGPES_RESPONSAVEL" ("CODIGO_USUARIO", "ID_AGRUP", "CODIGO_CONTRATO", "CODIGO_EMPRESA", "TIPO_CONTRATO", "NOME", "NOME_COMPOSTO") AS 
  SELECT P_SIST.codigo_usuario AS CODIGO_USUARIO,
       AGRUP_SUBSEC.id_agrup AS ID_AGRUP,
       CONTRATO.codigo AS CODIGO_CONTRATO,
       CONTRATO.codigo_empresa AS CODIGO_EMPRESA,
       CONTRATO.tipo_contrato AS TIPO_CONTRATO,
       CONTRATO.nome AS NOME,
       CONTRATO_MESTRE.NOME_COMPOSTO AS NOME_COMPOSTO
FROM rhpess_contrato CONTRATO_USUARIO,
     rhpess_contrato CONTRATO,
     rhpess_contr_mest CONTRATO_MESTRE,
     rhuser_p_sist P_SIST,
     rhorga_agrupador AGRUP_SUBSEC,
     rhorga_agrupador AGRUP_USUA,
     rhorga_estrut_agr ESTRUT_AGR,
     rhorga_estrut_agr ESTRUT_SUBSEC
WHERE
  CONTRATO_USUARIO.codigo_empresa = P_SIST.empresa_usuario
  AND CONTRATO_USUARIO.tipo_contrato = P_SIST.tp_contr_usuario
  AND CONTRATO_USUARIO.codigo = P_SIST.contrato_usuario
  AND CONTRATO.CODIGO=CONTRATO_MESTRE.CODIGO_CONTRATO
  AND CONTRATO.TIPO_CONTRATO=CONTRATO_MESTRE.TIPO_CONTRATO
  AND CONTRATO.CODIGO_EMPRESA=CONTRATO_MESTRE.CODIGO_EMPRESA
  AND ESTRUT_AGR.codigo_empresa = ESTRUT_SUBSEC.codigo_empresa
  AND ESTRUT_AGR.id_agrup_sup = ESTRUT_SUBSEC.id_agrup_sup
  AND ESTRUT_AGR.codigo_empresa = AGRUP_SUBSEC.codigo_empresa
  AND ESTRUT_AGR.id_agrup = AGRUP_SUBSEC.id_agrup
  AND ESTRUT_AGR.ano_mes_referencia =
    (SELECT Max( ESTRUT_AGR_MAX.ano_mes_referencia)
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
  AND ((AGRUP_USUA.tipo_agrup = 'G'
           AND AGRUP_USUA.tipo_agrup = CONTRATO_USUARIO.tipo_agrup_cger
           AND AGRUP_USUA.cod_agrup1 = CONTRATO_USUARIO.cod_custo_gerenc1
           AND AGRUP_USUA.cod_agrup2 = CONTRATO_USUARIO.cod_custo_gerenc2
           AND AGRUP_USUA.cod_agrup3 = CONTRATO_USUARIO.cod_custo_gerenc3
           AND AGRUP_USUA.cod_agrup4 = CONTRATO_USUARIO.cod_custo_gerenc4
           AND AGRUP_USUA.cod_agrup5 = CONTRATO_USUARIO.cod_custo_gerenc5
           AND AGRUP_USUA.cod_agrup6 = CONTRATO_USUARIO.cod_custo_gerenc6))
  AND ((AGRUP_SUBSEC.tipo_agrup = 'G'
           AND AGRUP_SUBSEC.tipo_agrup = CONTRATO.tipo_agrup_cger
           AND AGRUP_SUBSEC.cod_agrup1 = CONTRATO.cod_custo_gerenc1
           AND AGRUP_SUBSEC.cod_agrup2 = CONTRATO.cod_custo_gerenc2
           AND AGRUP_SUBSEC.cod_agrup3 = CONTRATO.cod_custo_gerenc3
           AND AGRUP_SUBSEC.cod_agrup4 = CONTRATO.cod_custo_gerenc4
           AND AGRUP_SUBSEC.cod_agrup5 = CONTRATO.cod_custo_gerenc5
           AND AGRUP_SUBSEC.cod_agrup6 = CONTRATO.cod_custo_gerenc6) )
  AND (CONTRATO.data_rescisao IS NULL
       OR CONTRATO.data_rescisao > SYSDATE)
  AND CONTRATO.ano_mes_referencia =
    (SELECT Max( MAX_CONTRATO.ano_mes_referencia)
     FROM rhpess_contrato MAX_CONTRATO
     WHERE MAX_CONTRATO.codigo_empresa = CONTRATO.codigo_empresa
       AND MAX_CONTRATO.tipo_contrato = CONTRATO.tipo_contrato
       AND MAX_CONTRATO.codigo = CONTRATO.codigo
       AND MAX_CONTRATO.ano_mes_referencia > Trunc(SYSDATE, 'yyyy'))
  AND (CONTRATO_USUARIO.data_rescisao IS NULL
       OR CONTRATO_USUARIO.data_rescisao > SYSDATE)
  AND CONTRATO_USUARIO.ano_mes_referencia =
    (SELECT Max( MAX_CONTRATO.ano_mes_referencia)
     FROM rhpess_contrato MAX_CONTRATO
     WHERE MAX_CONTRATO.codigo_empresa = CONTRATO_USUARIO.codigo_empresa
       AND MAX_CONTRATO.tipo_contrato = CONTRATO_USUARIO.tipo_contrato
       AND MAX_CONTRATO.codigo = CONTRATO_USUARIO.codigo
       AND MAX_CONTRATO.ano_mes_referencia > Trunc(SYSDATE, 'yyyy'))
ORDER BY CONTRATO.nome