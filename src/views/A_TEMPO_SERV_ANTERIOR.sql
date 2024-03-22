
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."A_TEMPO_SERV_ANTERIOR" ("COD_ORG", "MATRICULA_SEGURADO", "DIGITO_MATRICULA", "CPF", "SEQUENCIAL_TEMPO_SERVICO", "DATA_ADMISSAO", "VINCULO", "REGIME_PREVIDENCIA", "DESCRICAO_CARGO", "DATA_DEMISSAO_EXONERACAO", "MAGISTERIO", "PROFISSIONAL_SAUDE", "MEDICO", "ATIVIDADE_INSALUBRE", "PROFISSAO_REGULAMENTADA", "RESP_CONTAGEM_TEMPO", "TEMPO_COMPROVADO", "NATUREZA_JURIDICA", "NUMERO_CTC", "COD_ORG_ANTERIOR", "MATRICULA_ANTERIOR", "EMPRESA") AS 
  select 
1 as COD_ORG, /* Admin direta */
  
substr(p.codigo,5,10) as MATRICULA_SEGURADO,
case when substr(p.codigo,15,1) not in ('0','1','2','3','4','5','6','7','8','9')
  then '7'
  else substr(c.codigo,15,1)
  end as DIGITO_MATRICULA,
p.cpf as CPF,

row_number() OVER (PARTITION BY p.cpf ORDER BY p.cpf, a.data_admissao) as SEQUENCIAL_TEMPO_SERVICO,  /* VERIFICAR */
TRIM(a.data_admissao) as DATA_ADMISSAO,

case a.vinculo 
  when '0000' then 2
  when '0002' then 2
  when '0001' then 1
  when '0010' then 4
  else 9 
  end as VINCULO,

case a.codigo_previdencia 
  when '0001' then 'G'
  when '0002' then 'P'
  when '0003' then 'P'
  when '0004' then 'P'
  when '0005' then 'G'
  /*when 'xxxx' then 'M'  /* verificar quais codigos aparecem no resultado */
  else 'G' 
  end as REGIME_PREVIDENCIA,
  
substr(trim(a.ultimo_cargo),1,80) as DESCRICAO_CARGO,
TRIM(a.data_demissao) as DATA_DEMISSAO_EXONERACAO,
TRIM(a.c_livre_opcao12) as MAGISTERIO,

case when/* c.area_atuacao = '0020' or*/ g.c_livre_descr08 = '02 - Saúde' 
     then 'S' else 'N'
     end as PROFISSIONAL_SAUDE, 

case when a.ultimo_cargo LIKE '%MÉDICO%' 
     then 'S' 
     else 'N' end as MEDICO, /*mudar*/

'N' as ATIVIDADE_INSALUBRE, /* verificar */

/*g.exige_registro*/ 'N' as PROFISSAO_REGULAMENTADA,

'E' as RESP_CONTAGEM_TEMPO, /* verificar *//*mudar*/

'S' as TEMPO_COMPROVADO, /* verificar */

case when a.natureza_empresa in ('0001','0002','0003','1003') then 'P'
  when a.natureza_empresa in ('0005','0006','0008','0009','1002','1004','1005') then 'G'
  when a.natureza_empresa = '0007' then 'A'
  when a.natureza_empresa = '0004' then 'M'
  else 'Z'
  end as NATUREZA_JURIDICA,

'0' as NUMERO_CTC,

case codigo_empresa_ant
  when '0001' then 1
  when '000X' then 3
  when '00XX' then 4
  else null
  end as COD_ORG_ANTERIOR, /* FMC, HOB etc. entram como no mesmo município? */

/*substr(a.matricula_anterior,1,10)*/NULL as  MATRICULA_ANTERIOR,

TRIM(a.empresa_anterior) AS EMPRESA   


from rhpess_contrato c
left outer join rhpess_pessoa p on  c.codigo_empresa = p.codigo_empresa and c.codigo_pessoa = p.codigo
left outer join rhtemp_empreg_ant a on c.codigo_empresa = a.codigo_empresa and c.codigo = a.codigo_pessoa and c.TIPO_CONTRATO = a.TIPO_CONTRATO--and a.codigo_cargo = c.cod_cargo_efetivo
left outer join rhorga_empresa e on e.codigo = c.codigo_empresa and e.codigo = p.codigo_empresa 
left outer join rhplcs_cargo g on g.codigo = c.cod_cargo_efetivo and a.codigo_cargo = g.codigo

where 
p.codigo_empresa ='0001'
AND C.TIPO_CONTRATO = '0001'
AND C.SITUACAO_FUNCIONAL NOT IN ('1715','1800','1850','1900','5000','5002','5003','5004','5005','5006','5008','5009','5011','5200','5700','5900','5901','6002','8000')
AND (C.CODIGO < '000000001530000' AND C.CODIGO NOT IN('000000000777777','000000000823701','000000000833014','000000000866265','000000000747428','000000000190072','000000000420534'))
and c.vinculo in ('0000','0002')
--AND C.CODIGO = '00000000049970X' 

AND C.CODIGO < '000000015000000'
and c.ano_mes_referencia = (
  select max(x.ano_mes_referencia) from rhpess_contrato x
  where x.codigo_empresa = c.codigo_empresa
  and x.tipo_contrato = c.tipo_contrato 
  and x.codigo = c.codigo
  and x.ano_mes_referencia <= add_months(sysdate,(-1))-0)
  
and lower(a.ultimo_cargo) not like '%estagi%'

order by p.codigo,a.data_admissao