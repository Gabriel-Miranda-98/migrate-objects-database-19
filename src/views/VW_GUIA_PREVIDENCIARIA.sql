
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_GUIA_PREVIDENCIARIA" ("CPF", "BM", "NOME", "TIPO_LOGRADOURO", "ENDERECO", "BAIRRO", "NUMERO", "COMPLEMENTO", "CEP", "MUNICIPIO", "UF", "SITUACAO_FUNCIONAL", "DESC_SITUACAO_FUNCIONAL", "DATA_INIC_SITUACAO", "DATA_FIM_SITUACAO", "COD_UNIDADE1", "COD_UNIDADE2", "COD_UNIDADE3", "COD_UNIDADE4", "COD_UNIDADE5", "COD_UNIDADE6", "LOTACAO", "CNPJ", "TIPO_LOGRADOURO_UNIDADE", "ENDERECO_UNIDADE", "NUMERO_UNIDADE", "COMPLEMENTO_UNIDADE", "BAIRRO_UNIDADE", "CEP_UNIDADE", "CODIGO_PREVIDENCIA", "ANO_MES_REFERENCIA", "PATRONAL", "FUNCIONAL") AS 
  SELECT rhpess_pessoa.CPF, rhpess_contrato.CODIGO AS BM, rhpess_pessoa.NOME, 
         RHTABS_TP_LOGRAD.DESCRICAO AS TIPO_LOGRADOURO, RHPESS_ENDERECO_P.ENDERECO, RHPESS_ENDERECO_P.BAIRRO, 
         RHPESS_ENDERECO_P.NUMERO, RHPESS_ENDERECO_P.COMPLEMENTO, RHPESS_ENDERECO_P.CEP,
         RHTABS_MUNICIPIO.DESCRICAO as MUNICIPIO, RHTABS_MUNICIPIO.UF,
         rhpess_contrato.SITUACAO_FUNCIONAL, RHPARM_SIT_FUNC.DESCRICAO DESC_SITUACAO_FUNCIONAL,
         TO_CHAR(RHCGED_ALT_SIT_FUN.DATA_INIC_SITUACAO, 'DD/MM/YYYY') DATA_INIC_SITUACAO, 
         TO_CHAR(RHCGED_ALT_SIT_FUN.DATA_FIM_SITUACAO,'DD/MM/YYYY') DATA_FIM_SITUACAO,
         rhpess_contrato.COD_UNIDADE1, rhpess_contrato.COD_UNIDADE2, rhpess_contrato.COD_UNIDADE3, rhpess_contrato.COD_UNIDADE4,
         rhpess_contrato.COD_UNIDADE5, rhpess_contrato.COD_UNIDADE6, RHORGA_UNIDADE.texto_associado AS LOTACAO,
      CASE 
          WHEN rhpess_contrato.DATA_ADMISSAO < '30/12/2011' 
        THEN
         RHORGA_UNIDADE.CGC
 /*          'CNPJ_FUFIN' wagner 20/12/17  */       
      ELSE 
          RHORGA_UNIDADE.CGC
 /*          'CNPJ_BHPREV' wagner 20/12/17  */
     END CNPJ,
         RHTABS_TP_LOGRAD_UNIDADE.DESCRICAO AS TIPO_LOGRADOURO_UNIDADE,
         RHORGA_ENDERECO.ENDERECO ENDERECO_UNIDADE, RHORGA_ENDERECO.NUMERO NUMERO_UNIDADE, 
         RHORGA_ENDERECO.COMPLEMENTO COMPLEMENTO_UNIDADE, RHORGA_ENDERECO.BAIRRO BAIRRO_UNIDADE, 
         RHORGA_ENDERECO.CEP CEP_UNIDADE,
         
         CASE WHEN rhpess_contrato.DATA_ADMISSAO < '30/12/2011' 
           THEN 'FUFIN'
           ELSE 'BHPREV' 
         END CODIGO_PREVIDENCIA,      
         
         TO_CHAR(PATRONAL.ANO_MES_REFERENCIA, 'MM/YYYY') ANO_MES_REFERENCIA, 
         PATRONAL.VALOR_VERBA PATRONAL, FUNCIONAL.VALOR_VERBA FUNCIONAL
  FROM rhpess_contrato,
       rhpess_pessoa,
       RHCGED_ALT_SIT_FUN, 
       RHPESS_ENDERECO_P,
       RHTABS_MUNICIPIO, 
       RHTABS_TP_LOGRAD,
       RHORGA_UNIDADE,
       RHORGA_ENDERECO, 
       RHTABS_TP_LOGRAD RHTABS_TP_LOGRAD_UNIDADE, 
       RHPARM_SIT_FUNC,
       
       ( SELECT * FROM RHMOVI_MOVIMENTO 
         WHERE tipo_movimento = 'GU'
         AND FASE = '1' 
         AND CODIGO_VERBA IN ('3510'))PATRONAL,

       ( SELECT * FROM RHMOVI_MOVIMENTO 
         WHERE tipo_movimento = 'GU'
         AND FASE = '1' 
         AND CODIGO_VERBA IN ('2171'))FUNCIONAL

WHERE rhpess_contrato.codigo_empresa = '0001' 
AND rhpess_contrato.tipo_contrato = '0001' 
AND rhpess_contrato.ano_mes_referencia = (SELECT MAX(a.ano_mes_referencia)
                                          From rhpess_contrato a
                                          where a.codigo         = rhpess_contrato.codigo 
                                          and   a.codigo_empresa = rhpess_contrato.codigo_empresa 
                                          and   a.tipo_contrato  = rhpess_contrato.tipo_contrato 
                                          and   a.ano_mes_referencia <= sysdate) 
and (rhpess_contrato.SITUACAO_FUNCIONAL in ('5300', '6101') or 
    (rhpess_contrato.SITUACAO_FUNCIONAL >= '5100' and rhpess_contrato.SITUACAO_FUNCIONAL <= '5108'))
and rhpess_contrato.CODIGO_PESSOA = rhpess_pessoa.codigo
and rhpess_contrato.CODIGO_EMPRESA = rhpess_pessoa.CODIGO_EMPRESA
and RHCGED_ALT_SIT_FUN.CODIGO = rhpess_contrato.CODIGO
and RHCGED_ALT_SIT_FUN.codigo_empresa = rhpess_contrato.CODIGO_EMPRESA
and RHCGED_ALT_SIT_FUN.TIPO_CONTRATO = rhpess_contrato.TIPO_CONTRATO
and RHCGED_ALT_SIT_FUN.DATA_INIC_SITUACAO = (select max (b.DATA_INIC_SITUACAO) 
                                             from RHCGED_ALT_SIT_FUN b
                                             where b.codigo   = RHCGED_ALT_SIT_FUN.codigo 
                                             and   b.codigo_empresa = RHCGED_ALT_SIT_FUN.codigo_empresa 
                                             and   b.tipo_contrato  = RHCGED_ALT_SIT_FUN.tipo_contrato 
                                             and   b.DATA_INIC_SITUACAO <= sysdate) 
and RHPESS_ENDERECO_P.CODIGO_EMPRESA = rhpess_pessoa.CODIGO_EMPRESA
and RHPESS_ENDERECO_P.CODIGO_PESSOA =  rhpess_pessoa.CODIGO
AND RHPESS_ENDERECO_P.CODIGO_PESSOA = rhpess_pessoa.CODIGO 
AND RHPESS_ENDERECO_P.CODIGO_EMPRESA =rhpess_pessoa.CODIGO_EMPRESA
AND RHPESS_ENDERECO_P.MUNICIPIO = RHTABS_MUNICIPIO.CODIGO
AND RHPESS_ENDERECO_P.TIPO_LOGRADOURO = RHTABS_TP_LOGRAD.CODIGO
AND rhpess_contrato.COD_UNIDADE1 = RHORGA_UNIDADE.COD_UNIDADE1
AND rhpess_contrato.COD_UNIDADE2 = RHORGA_UNIDADE.COD_UNIDADE2
AND rhpess_contrato.COD_UNIDADE3 = RHORGA_UNIDADE.COD_UNIDADE3
AND rhpess_contrato.COD_UNIDADE4 = RHORGA_UNIDADE.COD_UNIDADE4
AND rhpess_contrato.COD_UNIDADE5 = RHORGA_UNIDADE.COD_UNIDADE5
AND rhpess_contrato.COD_UNIDADE6 = RHORGA_UNIDADE.COD_UNIDADE6
AND rhpess_contrato.CODIGO_EMPRESA = RHORGA_UNIDADE.CODIGO_EMPRESA
AND RHORGA_UNIDADE.cod_endereco = RHORGA_ENDERECO.CODIGO
AND RHORGA_ENDERECO.TIPO_LOGRADOURO =  RHTABS_TP_LOGRAD_UNIDADE.CODIGO
AND PATRONAL.ANO_MES_REFERENCIA = FUNCIONAL.ANO_MES_REFERENCIA
AND PATRONAL.CODIGO_EMPRESA = FUNCIONAL.CODIGO_EMPRESA
AND PATRONAL.CODIGO_CONTRATO = FUNCIONAL.CODIGO_CONTRATO
AND PATRONAL.CODIGO_EMPRESA = rhpess_contrato.CODIGO_EMPRESA
AND PATRONAL.CODIGO_CONTRATO = rhpess_contrato.codigo
AND FUNCIONAL.CODIGO_EMPRESA = rhpess_contrato.CODIGO_EMPRESA
AND FUNCIONAL.CODIGO_CONTRATO = rhpess_contrato.codigo
AND RHPARM_SIT_FUNC.CODIGO = rhpess_contrato.SITUACAO_FUNCIONAL