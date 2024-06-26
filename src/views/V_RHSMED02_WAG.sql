
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."V_RHSMED02_WAG" ("CODIGO", "NOME", "ENDERECO", "NUMERO", "COMPLEMENTO", "BAIRRO", "NOME_MUNICIPIO", "UF", "CEP", "FAX", "ENDER_ELETRONICO", "COD_CARGO_EFETIVO", "DESC_CARGO", "COD_UNIDADE1", "COD_UNIDADE2", "COD_UNIDADE3", "COD_UNIDADE4", "COD_UNIDADE5", "COD_UNIDADE6", "DESC_UNIDADE", "ABREVIACAO", "DESC_JORNADA_TRAB", "JORNADA_DIARIA", "SITUACAO_FUNCIONAL", "DESC_SIT_FUNC") AS 
  SELECT RHPESS_CONTRATO.CODIGO,
          RHPESS_CONTRATO.NOME,
          RHPESS_ENDERECO_P.ENDERECO,
          RHPESS_ENDERECO_P.NUMERO,
          RHPESS_ENDERECO_P.COMPLEMENTO,
          RHPESS_ENDERECO_P.BAIRRO,
          RHPESS_ENDERECO_P.C_LIVRE_DESCR01 NOME_MUNICIPIO,
          RHPESS_ENDERECO_P.UF,
          RHPESS_ENDERECO_P.CEP,
          RHPESS_ENDERECO_P.FAX,
          RHPESS_ENDERECO_P.ENDER_ELETRONICO,
          RHPESS_CONTRATO.COD_CARGO_EFETIVO,
          RHPLCS_CARGO.DESCRICAO DESC_CARGO,
          RHPESS_CONTRATO.COD_UNIDADE1,
          RHPESS_CONTRATO.COD_UNIDADE2,
          RHPESS_CONTRATO.COD_UNIDADE3,
          RHPESS_CONTRATO.COD_UNIDADE4,
          RHPESS_CONTRATO.COD_UNIDADE5,
          RHPESS_CONTRATO.COD_UNIDADE6,
          RHORGA_UNIDADE.DESCRICAO DESC_UNIDADE,
          RHORGA_UNIDADE.ABREVIACAO,
          RHPONT_ESCALA.DESCRICAO DESC_JORNADA_TRAB,
          RHPONT_ESCALA.JORNADA_DIARIA,
          RHPESS_CONTRATO.SITUACAO_FUNCIONAL,
          RHPARM_SIT_FUNC.DESCRICAO DESC_SIT_FUNC
     FROM RHPESS_CONTRATO,
          RHPESS_PESSOA,
          RHPESS_ENDERECO_P,
          RHORGA_UNIDADE,
          RHPARM_SIT_FUNC,
          RHPLCS_CARGO,
          RHPONT_ESCALA,
          RHTABS_UF
    WHERE     (RHPESS_CONTRATO.CODIGO_PESSOA = RHPESS_PESSOA.CODIGO)
          AND (RHPESS_CONTRATO.CODIGO_EMPRESA = RHPESS_PESSOA.CODIGO_EMPRESA)
          AND (RHPESS_CONTRATO.CODIGO_EMPRESA =
                  RHPESS_ENDERECO_P.CODIGO_EMPRESA)
          AND (RHPESS_CONTRATO.CODIGO_PESSOA =
                  RHPESS_ENDERECO_P.CODIGO_PESSOA)
          AND (RHPESS_CONTRATO.CODIGO_EMPRESA = RHORGA_UNIDADE.CODIGO_EMPRESA)
          AND (RHPESS_CONTRATO.COD_UNIDADE1 = RHORGA_UNIDADE.COD_UNIDADE1)
          AND (RHPESS_CONTRATO.COD_UNIDADE2 = RHORGA_UNIDADE.COD_UNIDADE2)
          AND (RHPESS_CONTRATO.COD_UNIDADE3 = RHORGA_UNIDADE.COD_UNIDADE3)
          AND (RHPESS_CONTRATO.COD_UNIDADE4 = RHORGA_UNIDADE.COD_UNIDADE4)
          AND (RHPESS_CONTRATO.COD_UNIDADE5 = RHORGA_UNIDADE.COD_UNIDADE5)
          AND (RHPESS_CONTRATO.COD_UNIDADE6 = RHORGA_UNIDADE.COD_UNIDADE6)
          AND (RHPESS_CONTRATO.SITUACAO_FUNCIONAL = RHPARM_SIT_FUNC.CODIGO)
          AND (RHPESS_CONTRATO.COD_CARGO_EFETIVO = RHPLCS_CARGO.CODIGO)
          AND (RHPESS_CONTRATO.CODIGO_EMPRESA = RHPLCS_CARGO.CODIGO_EMPRESA)
          AND (RHPESS_CONTRATO.CODIGO_ESCALA = RHPONT_ESCALA.CODIGO)
          AND (RHPESS_PESSOA.UF_NATURALIDADE = RHTABS_UF.CODIGO)
          AND (RHPESS_CONTRATO.CODIGO_EMPRESA = '0001')
          AND (RHPESS_CONTRATO.TIPO_CONTRATO = '0001')
          AND (RHPESS_CONTRATO.SITUACAO_FUNCIONAL = '1800')
          AND (   (    RHPESS_CONTRATO.COD_UNIDADE1 = '000070'
                   AND RHPESS_CONTRATO.COD_UNIDADE2 = '000003')
               OR (    RHPESS_CONTRATO.COD_UNIDADE1 >= '000071'
                   AND RHPESS_CONTRATO.COD_UNIDADE1 <= '000079'
                   AND RHPESS_CONTRATO.COD_UNIDADE2 = '000002'
                   AND RHPESS_CONTRATO.COD_UNIDADE3 = '000001')
               OR (RHPESS_CONTRATO.COD_UNIDADE1 = '000094'))
          AND (RHPESS_CONTRATO.ANO_MES_REFERENCIA =
                  (SELECT MAX (A.ANO_MES_REFERENCIA)
                     FROM RHPESS_CONTRATO A
                    WHERE     A.CODIGO = RHPESS_CONTRATO.CODIGO
                          AND A.CODIGO_EMPRESA =
                                 RHPESS_CONTRATO.CODIGO_EMPRESA
                          AND A.TIPO_CONTRATO = RHPESS_CONTRATO.TIPO_CONTRATO
                          AND A.ANO_MES_REFERENCIA <= SYSDATE))