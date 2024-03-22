
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."BUSCAR_GESTOR_SUPERIOR" (
        p_codigo_empresa   CHAR,
        p_cod_unidade_sup1 VARCHAR2,
        p_cod_unidade_sup2 VARCHAR2,
        p_cod_unidade_sup3 VARCHAR2,
        p_cod_unidade_sup4 VARCHAR2,
        p_cod_unidade_sup5 VARCHAR2,
        p_cod_unidade_sup6 VARCHAR2
    ) RETURN type_delegar_para_cima IS
        gestor type_delegar_para_cima;
    BEGIN
        gestor := type_delegar_para_cima(NULL, NULL, NULL, NULL, NULL,
                                        NULL);
        SELECT
            gestor_sup.cod_empresa_pess AS codigo_empresa_pessoa_gestor_sup,
            gestor_sup.cod_pessoa_resp  AS codigo_pessoa_gestor_sup,
            gestor_sup.tipo_cont_resp   AS tipo_contrato_gestor_sup,
            gestor_sup.contrato_resp    AS codigo_contrato_gestor_sup,
            gestor_sup.texto_associado  AS texto_associado,
            gestor_sup.descricao        AS descricao
        INTO
            gestor.codigo_empresa_pessoa,
            gestor.codigo_pessoa,
            gestor.tipo_contrato,
            gestor.codigo_contrato,
            gestor.texto_associado,
            gestor.descricao
        FROM
            arterh.rhorga_custo_geren gestor_sup
        WHERE
                gestor_sup.codigo_empresa = p_codigo_empresa
            AND gestor_sup.cod_cgerenc1 <> '000099'
            AND gestor_sup.cod_cgerenc1 IS NOT NULL
            AND gestor_sup.cod_pessoa_resp IS NOT NULL
            AND gestor_sup.cod_cgerenc1 = p_cod_unidade_sup1
            AND gestor_sup.cod_cgerenc2 = p_cod_unidade_sup2
            AND gestor_sup.cod_cgerenc3 = p_cod_unidade_sup3
            AND gestor_sup.cod_cgerenc4 = p_cod_unidade_sup4
            AND gestor_sup.cod_cgerenc5 = p_cod_unidade_sup5
            AND gestor_sup.cod_cgerenc6 = p_cod_unidade_sup6;

        RETURN gestor;
    END;