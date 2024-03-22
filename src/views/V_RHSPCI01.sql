
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."V_RHSPCI01" ("CODIGO", "EMPRESA", "NOME", "CPF", "DESC_SIT_FUNC", "DESC_CARGO", "DESC_CARGO_COMISS", "DATA_ADMISSAO") AS 
  SELECT DISTINCT
          rhpess_contrato.codigo,          rhpess_contrato.codigo_empresa,          rhpess_contrato.nome,          TRIM (rhpess_pessoa.cpf) cpf,
          situacao_func.descricao desc_sit_func,          efetivo.descricao desc_cargo,          comiss.descricao desc_cargo_comiss,
          TO_CHAR (rhpess_contrato.data_admissao, 'DD/MM/YYYY') data_admissao
     FROM rhpess_contrato,          rhpess_pessoa,          rhparm_sit_func situacao_func,          rhplcs_cargo efetivo,          rhplcs_cargo comiss
    WHERE     (rhpess_contrato.codigo_pessoa = rhpess_pessoa.codigo)
          /*AND   (rhpess_contrato.codigo     < '000000001500000')*/
          AND (rhpess_contrato.codigo_empresa = rhpess_pessoa.codigo_empresa)
          AND (rhpess_contrato.cod_cargo_efetivo = efetivo.codigo)
          AND (rhpess_contrato.codigo_empresa = efetivo.codigo_empresa)
          AND (rhpess_contrato.situacao_funcional = situacao_func.codigo)
          AND (rhpess_contrato.cod_cargo_comiss = comiss.codigo)
          AND (rhpess_contrato.codigo_empresa = comiss.codigo_empresa)
          AND (rhpess_contrato.codigo_empresa IN    ('0001',     '0002',     '0003',     '0005',     '0007',     '0009',     '0010',     '0013',     '0014'))
          /*AND   (rhpess_contrato.tipo_contrato      in ('0001','0002')) */
          AND situacao_func.DATA_FIM_VIGENCIA IS NULL --SITUAÇÕES FUNCIONAIS ATIVAS
          AND situacao_func.CONTROLE_FOLHA NOT IN ('S', 'D') --NÃƒO EMITE OS SERVIDORES APOSENTADOS E DESLIGADOS
          AND RHPESS_CONTRATO.VINCULO NOT IN ('0009')  --RETIRA OS ESTAGIARIOS
          /*AND   (rhpess_contrato.situacao_funcional not in
                  ('1711','1715','1800','1850','1890','1900','5000','5005','5006','5007','5008','5010','5011','5015','5400',
                   '5800','5901','6003','7000', '9000', '9001', '9002', '9003'))*/
          AND (   (rhpess_contrato.data_rescisao IS NULL)
               OR ( (rhpess_contrato.data_rescisao + 30) >= TRUNC (SYSDATE)))
          AND (rhpess_contrato.ano_mes_referencia =
                  (SELECT MAX (a.ano_mes_referencia)
                     FROM rhpess_contrato a
                    WHERE     a.codigo = rhpess_contrato.codigo
                          AND a.codigo_empresa =  rhpess_contrato.codigo_empresa
                          AND a.tipo_contrato = rhpess_contrato.tipo_contrato
                          AND a.ano_mes_referencia <= SYSDATE))
   UNION ALL
   SELECT DISTINCT
          rhpess_contrato.codigo,          rhpess_contrato.codigo_empresa,          rhpess_contrato.nome,          TRIM (rhpess_pessoa.cpf) cpf,
          situacao_func.descricao desc_sit_func,          efetivo.descricao desc_cargo,          comiss.descricao desc_cargo_comiss,
          TO_CHAR (rhpess_contrato.data_admissao, 'DD/MM/YYYY') data_admissao
     FROM rhpess_contrato,          rhpess_pessoa,          rhparm_sit_func situacao_func,          rhplcs_cargo efetivo,          rhplcs_cargo comiss
    WHERE     (rhpess_contrato.codigo_pessoa = rhpess_pessoa.codigo)
          /*AND (rhpess_contrato.codigo             < '000000001500000')*/
          AND (rhpess_contrato.codigo_empresa = rhpess_pessoa.codigo_empresa)
          AND (rhpess_contrato.cod_cargo_efetivo = efetivo.codigo)
          AND (rhpess_contrato.codigo_empresa = efetivo.codigo_empresa)
          AND (rhpess_contrato.situacao_funcional = situacao_func.codigo)
          AND (rhpess_contrato.cod_cargo_comiss = comiss.codigo)
          AND (rhpess_contrato.codigo_empresa = comiss.codigo_empresa)
          AND (rhpess_contrato.codigo_empresa IN    ('0001',     '0002',     '0003',     '0005',     '0007',     '0009',     '0010',     '0013',     '0014'))
          /*AND (rhpess_contrato.tipo_contrato      in ('0001','0002'))*/
          /* situacao de aposentados ma empresa PBH(cod.empresa 0001)*/
          /* SituaÃ§Ã£o funcional que possui o controle folha S - Aposentado e não
             possui data de rescisão, são os que estão aguardando aposentadoria*/
          AND ( (   (    situacao_func.CONTROLE_FOLHA = 'S'
                     AND RHPESS_CONTRATO.DATA_RESCISAO IS NULL)
                 OR /* Situação funcional que possui o controle folha S - Aposentado e
                       possui data de rescisão, são os que estão aposentados*/
                    (    situacao_func.CONTROLE_FOLHA = 'S'
                     AND RHPESS_CONTRATO.DATA_RESCISAO >= SYSDATE - 180
                     AND RHPESS_CONTRATO.DATA_RESCISAO <= SYSDATE)
                 OR    /*Servidores que não possuem vinculo com a prefeitura*/
                    (    situacao_func.CONTROLE_FOLHA = 'D'
                     AND RHPESS_CONTRATO.DATA_RESCISAO >= SYSDATE - 75
                     AND RHPESS_CONTRATO.DATA_RESCISAO <= SYSDATE)))
          AND (rhpess_contrato.ano_mes_referencia =
                  (SELECT MAX (a.ano_mes_referencia)
                     FROM rhpess_contrato a
                    WHERE     a.codigo = rhpess_contrato.codigo
                          AND a.codigo_empresa =   rhpess_contrato.codigo_empresa
                          AND a.tipo_contrato = rhpess_contrato.tipo_contrato
                          AND a.ano_mes_referencia <= SYSDATE))