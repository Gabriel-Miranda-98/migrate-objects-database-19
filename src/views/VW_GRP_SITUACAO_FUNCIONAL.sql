
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_GRP_SITUACAO_FUNCIONAL" ("RHORGA_EMPRESA_CODIGO", "RHORGA_EMPRESA_RAZAO_SOCIAL", "RHPESS_CONTRATO_CODIGO", "RHPESS_PESSOA_CODIGO", "PIS_PASEP", "RHPESS_CONTRATO_TIPO_CONTRATO", "RHPESS_TP_CONTRATO_DESCRICAO", "RHPESS_CONTRATO_NOME", "RHPESS_CONTRATO_DATA_ADMISSAO", "RHPESS_CONTRATO_SITUACAO_FUNCIONAL", "RHPARM_SIT_FUNC_DESCRICAO", "RHPESS_CONTRATO_COD_CARGO_EFETIVO", "RHPLCS_CARGO_DESCRICAO", "RHPESS_CONTRATO_COD_CARGO_COMISS", "COMISS_DESCRICAO", "RHPESS_CONTRATO_CODIGO_FUNCAO", "RHPLCS_FUNCAO_DESCRICAO", "RHPESS_CONTRATO_COD_UNIDADE1", "RHORGA_UNIDADE_DESCRICAO", "RHPESS_PESSOA_IDENTIDADE", "RHPESS_PESSOA_ORGAO_EXPEDIDOR", "RHPESS_ENDERECO_P_ENDER_ELETRONICO", "RHPESS_CONTRATO_E_MAIL") AS 
  SELECT DISTINCT
          rhorga_empresa.codigo,
          rhorga_empresa.razao_social,
          rhpess_contrato.codigo,
          rhpess_pessoa.codigo,
          rhpess_pessoa.pis_pasep,
          rhpess_contrato.tipo_contrato,
          rhpess_tp_contrato.descricao,
          rhpess_contrato.nome,
          rhpess_contrato.data_admissao,
          rhpess_contrato.situacao_funcional,
          rhparm_sit_func.descricao desc_sit_func,
          rhpess_contrato.cod_cargo_efetivo,
          rhplcs_cargo.descricao,
          rhpess_contrato.cod_cargo_comiss,
          comiss.descricao,
          rhpess_contrato.codigo_funcao,
          rhplcs_funcao.descricao,
             SUBSTR (rhpess_contrato.cod_unidade1, 5, 2)
          || '.'
          || SUBSTR (rhpess_contrato.cod_unidade2, 5, 2)
          || '.'
          || SUBSTR (rhpess_contrato.cod_unidade3, 5, 2)
          || '.'
          || SUBSTR (rhpess_contrato.cod_unidade4, 5, 2)
          || '.'
          || SUBSTR (rhpess_contrato.cod_unidade5, 5, 2)
          || '.'
          || SUBSTR (rhpess_contrato.cod_unidade6, 4, 3)
             AS pessoa_unidade,
          rhorga_unidade.descricao desc_unidade,
          rhpess_pessoa.identidade,
          rhpess_pessoa.orgao_expedidor,
          rhpess_endereco_p.ender_eletronico,
          RHPESS_CONTRATO.e_mail
     FROM rhorga_empresa,
          rhpess_contrato,
          rhpess_pessoa,
          rhorga_unidade,
          rhparm_sit_func,
          rhplcs_funcao,
          rhplcs_cargo,
          rhplcs_cargo comiss,
          rhtabs_vinculo_emp,
          RHPESS_TP_CONTRATO,
          rhpess_endereco_p
    WHERE     (rhorga_empresa.codigo = '0002')
          AND (    rhparm_sit_func.controle_folha NOT IN ('D', 'S')
               AND rhparm_sit_func.suspende_remunera = 'N')
          AND (rhpess_contrato.codigo_empresa = rhorga_empresa.codigo)
          AND (rhpess_contrato.tipo_contrato = '0001')
          AND (rhpess_contrato.tipo_contrato = rhpess_tp_contrato.codigo)
          AND (rhpess_contrato.codigo_pessoa = rhpess_pessoa.codigo)
          AND (rhpess_contrato.codigo_empresa = rhpess_pessoa.codigo_empresa)
          AND (rhpess_contrato.codigo_empresa = rhorga_unidade.codigo_empresa)
          AND (rhpess_contrato.cod_unidade1 = rhorga_unidade.cod_unidade1)
          AND (rhpess_contrato.cod_unidade2 = rhorga_unidade.cod_unidade2)
          AND (rhpess_contrato.cod_unidade3 = rhorga_unidade.cod_unidade3)
          AND (rhpess_contrato.cod_unidade4 = rhorga_unidade.cod_unidade4)
          AND (rhpess_contrato.cod_unidade5 = rhorga_unidade.cod_unidade5)
          AND (rhpess_contrato.cod_unidade6 = rhorga_unidade.cod_unidade6)
          AND (rhpess_contrato.situacao_funcional = rhparm_sit_func.codigo)
          AND (rhpess_contrato.codigo_funcao = rhplcs_funcao.codigo(+))
          AND (rhpess_contrato.codigo_empresa =
                  rhplcs_funcao.codigo_empresa(+))
          AND (rhpess_contrato.cod_cargo_comiss = comiss.codigo(+))
          AND (rhpess_contrato.codigo_empresa = comiss.codigo_empresa(+))
          AND (rhpess_contrato.cod_cargo_efetivo = rhplcs_cargo.codigo(+))
          AND (rhpess_contrato.codigo_empresa =
                  rhplcs_cargo.codigo_empresa(+))
          AND (rhpess_contrato.vinculo = rhtabs_vinculo_emp.codigo(+))
          AND (rhpess_contrato.codigo_empresa =
                  rhpess_endereco_p.codigo_empresa)
          AND (rhpess_contrato.codigo_pessoa =
                  rhpess_endereco_p.codigo_pessoa)
          AND rhpess_contrato.ano_mes_referencia =
                 (SELECT MAX (a.ano_mes_referencia)
                    FROM rhpess_contrato a
                   WHERE     a.codigo = rhpess_contrato.codigo
                         AND a.codigo_empresa =
                                rhpess_contrato.codigo_empresa
                         AND a.tipo_contrato = rhpess_contrato.tipo_contrato
                         AND a.ano_mes_referencia <= SYSDATE)