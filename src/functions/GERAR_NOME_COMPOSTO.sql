
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."GERAR_NOME_COMPOSTO" (
        p_codigo_empresa_pessoa VARCHAR2,
        p_tipo_contrato         VARCHAR2,
        p_codigo_contrato       VARCHAR2,
        p_texto_associado       VARCHAR2,
        p_descricao             VARCHAR2
    ) RETURN VARCHAR2 AS
        v_nome_composto VARCHAR2(255) := NULL;
    BEGIN
        SELECT
            c.codigo
            || ' - '
            || nvl(TRIM(p.nome_social),
                   TRIM(p.nome_acesso))
            || ' - '
            || c.tipo_contrato
            || ' - '
            || nvl(TRIM(p_texto_associado),
                   TRIM(p_descricao))
        INTO v_nome_composto
        FROM
            rhpess_contrato c
            LEFT OUTER JOIN rhpess_pessoa   p ON p.codigo_empresa = c.codigo_empresa
                                               AND p.codigo = c.codigo_pessoa
        WHERE
                c.ano_mes_referencia = (
                    SELECT
                        MAX(ano_mes_referencia)
                    FROM
                        rhpess_contrato aux
                    WHERE
                            aux.codigo_empresa = c.codigo_empresa
                        AND aux.tipo_contrato = c.tipo_contrato
                        AND aux.codigo = c.codigo
                )
            AND c.codigo_empresa = p_codigo_empresa_pessoa
            AND c.tipo_contrato = p_tipo_contrato
            AND c.codigo = p_codigo_contrato;
return v_nome_composto;
    END;