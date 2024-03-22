
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."V_RHSMSA01" ("CODIGO", "NOME", "SITUACAO_FUNCIONAL", "DESC_SIT_FUNC", "COD_CARGO_EFETIVO", "DESC_CARGO", "COD_UNIDADE1", "COD_UNIDADE2", "COD_UNIDADE3", "COD_UNIDADE4", "COD_UNIDADE5", "COD_UNIDADE6", "DESC_LOTACAO", "SIGLA_SECAO", "DATA_MOVIMENTO", "ENDERECO", "NUMERO", "COMPLEMENTO", "BAIRRO", "NOME_MUNICIPIO", "UF", "CEP", "CODIGO_VERBA", "VALOR_VERBA", "DESC_VERBA", "DESC_VINCULO_EMP", "DESC_JORNADA_TRAB", "JORNADA_DIARIA") AS 
  SELECT "RHPESS_CONTRATO"."CODIGO",          "RHPESS_CONTRATO"."NOME",          "RHPESS_CONTRATO"."SITUACAO_FUNCIONAL",          "RHPARM_SIT_FUNC"."DESCRICAO" DESC_SIT_FUNC,         
"RHPESS_CONTRATO"."COD_CARGO_EFETIVO",          "RHPLCS_CARGO"."DESCRICAO" DESC_CARGO,          "RHPESS_CONTRATO"."COD_UNIDADE1",          "RHPESS_CONTRATO"."COD_UNIDADE2",          "RHPESS_CONTRATO"."COD_UNIDADE3",         
"RHPESS_CONTRATO"."COD_UNIDADE4",          "RHPESS_CONTRATO"."COD_UNIDADE5",          "RHPESS_CONTRATO"."COD_UNIDADE6",          "RHORGA_UNIDADE"."DESCRICAO" DESC_LOTACAO,          "RHORGA_UNIDADE"."ABREVIACAO" SIGLA_SECAO,
           "RHMOVI_MOVIMENTO"."ANO_MES_REFERENCIA" DATA_MOVIMENTO,         "RHPESS_ENDERECO_P"."ENDERECO",          "RHPESS_ENDERECO_P"."NUMERO",          "RHPESS_ENDERECO_P"."COMPLEMENTO",          "RHPESS_ENDERECO_P"."BAIRRO",        
"RHPESS_ENDERECO_P"."C_LIVRE_DESCR01" NOME_MUNICIPIO,
        "RHPESS_ENDERECO_P"."UF",
           "RHPESS_ENDERECO_P"."CEP",          "RHMOVI_MOVIMENTO"."CODIGO_VERBA",          "RHMOVI_MOVIMENTO"."VALOR_VERBA",          "RHPARM_VERBA"."DESCRICAO" DESC_VERBA,
        "RHTABS_VINCULO_EMP"."DESCRICAO" DESC_VINCULO_EMP,
        "RHPONT_ESCALA"."DESCRICAO" DESC_JORNADA_TRAB,
        "RHPONT_ESCALA"."JORNADA_DIARIA"     FROM "RHPESS_CONTRATO",          "RHPESS_ENDERECO_P",          "RHMOVI_MOVIMENTO",          "RHPARM_VERBA",          "RHORGA_UNIDADE",          "RHPARM_SIT_FUNC",          "RHPLCS_CARGO",         
"RHTABS_VINCULO_EMP",
        "RHPONT_ESCALA"
  WHERE ( "RHPESS_CONTRATO"."CODIGO_EMPRESA" = "RHPESS_ENDERECO_P"."CODIGO_EMPRESA" ) and         ( "RHPESS_CONTRATO"."CODIGO_PESSOA" = "RHPESS_ENDERECO_P"."CODIGO_PESSOA" ) and         ( "RHPESS_CONTRATO"."CODIGO_EMPRESA" =
"RHMOVI_MOVIMENTO"."CODIGO_EMPRESA" ) and         ( "RHPESS_CONTRATO"."TIPO_CONTRATO" = "RHMOVI_MOVIMENTO"."TIPO_CONTRATO" ) and         ( "RHPESS_CONTRATO"."CODIGO" = "RHMOVI_MOVIMENTO"."CODIGO_CONTRATO" ) and         (
"RHMOVI_MOVIMENTO"."CODIGO_VERBA" = "RHPARM_VERBA"."CODIGO" ) and         ( "RHPESS_CONTRATO"."CODIGO_EMPRESA" = "RHORGA_UNIDADE"."CODIGO_EMPRESA" ) and         ( "RHPESS_CONTRATO"."COD_UNIDADE1" = "RHORGA_UNIDADE"."COD_UNIDADE1" ) and         (
"RHPESS_CONTRATO"."COD_UNIDADE2" = "RHORGA_UNIDADE"."COD_UNIDADE2" ) and         ( "RHPESS_CONTRATO"."COD_UNIDADE3" = "RHORGA_UNIDADE"."COD_UNIDADE3" ) and         ( "RHPESS_CONTRATO"."COD_UNIDADE4" = "RHORGA_UNIDADE"."COD_UNIDADE4" ) and         (
"RHPESS_CONTRATO"."COD_UNIDADE5" = "RHORGA_UNIDADE"."COD_UNIDADE5" ) and         ( "RHPESS_CONTRATO"."COD_UNIDADE6" = "RHORGA_UNIDADE"."COD_UNIDADE6" ) and
        ( "RHPESS_CONTRATO"."CODIGO_EMPRESA" = '0001' )   AND         ( "RHPESS_CONTRATO"."TIPO_CONTRATO"  = '0001' )   AND        
        ( "RHPESS_CONTRATO"."SITUACAO_FUNCIONAL" = "RHPARM_SIT_FUNC"."CODIGO" ) and         ( "RHPESS_CONTRATO"."COD_CARGO_EFETIVO" = "RHPLCS_CARGO"."CODIGO" ) and         ( "RHPESS_CONTRATO"."VINCULO" = "RHTABS_VINCULO_EMP"."CODIGO" ) and
           ( "RHPESS_CONTRATO"."CODIGO_ESCALA" = "RHPONT_ESCALA"."CODIGO" ) and
         (( "RHMOVI_MOVIMENTO"."CODIGO_VERBA" >= '1000' AND           "RHMOVI_MOVIMENTO"."CODIGO_VERBA" <= '2999' ) OR         ( "RHMOVI_MOVIMENTO"."CODIGO_VERBA" = '4001' OR           "RHMOVI_MOVIMENTO"."CODIGO_VERBA" = '4002' OR          
"RHMOVI_MOVIMENTO"."CODIGO_VERBA" = '4003' )) AND

       (( "RHPESS_CONTRATO"."SITUACAO_FUNCIONAL" < '1700' ) AND        (( "RHPESS_CONTRATO"."COD_UNIDADE1" = '000070' AND           "RHPESS_CONTRATO"."COD_UNIDADE2" = '000002') OR         ( "RHPESS_CONTRATO"."COD_UNIDADE1" >= '000071' AND          
"RHPESS_CONTRATO"."COD_UNIDADE1" <= '000079' AND           "RHPESS_CONTRATO"."COD_UNIDADE2" = '000002' AND           "RHPESS_CONTRATO"."COD_UNIDADE3" = '000002'))) AND                 ( TO_CHAR( "RHMOVI_MOVIMENTO"."ANO_MES_REFERENCIA",'MMYYYY' ) =
        ( TO_CHAR( ADD_MONTHS(SYSDATE,-1), 'MMYYYY' )))   AND
                            ( "RHMOVI_MOVIMENTO"."CTRL_DEMO" = 'N' ) AND
        ( "RHMOVI_MOVIMENTO"."TIPO_MOVIMENTO" = 'ME' ) AND         ( "RHMOVI_MOVIMENTO"."MODO_OPERACAO" = 'R' )  AND

        ( "RHPESS_CONTRATO"."ANO_MES_REFERENCIA" = (SELECT MAX(A."ANO_MES_REFERENCIA" )
                          FROM "RHPESS_CONTRATO" A
                          WHERE A."CODIGO" = "RHPESS_CONTRATO"."CODIGO" AND
                                A."CODIGO_EMPRESA" = "RHPESS_CONTRATO"."CODIGO_EMPRESA" AND
                                A."TIPO_CONTRATO" = "RHPESS_CONTRATO"."TIPO_CONTRATO" AND
                                A."ANO_MES_REFERENCIA" <= SYSDATE ))    



 