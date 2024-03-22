
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."RESUMO_CONTR_CEDIDOS" ("ANO_MES_REFERENCIA", "COD_ORG", "TIPO_MOVIMENTO", "MATRICULA", "BASE_CALC_CONTRI", "VAL_CONT_BAS_SEG", "VAL_CONT_PATRO_NORM", "VAL_CONT_ADIC_SEG", "VAL_CONT_PATR_ADIC", "REMUNERACAO_TOTAL", "NOME", "COD_PLANO", "SITUACAO_FUNCIONAL", "DATA_PAGAMENTO", "DECIMO_TERCEIRO", "FERIAS", "RESCISAO") AS 
  select   
		to_char(m.ano_mes_referencia,'yyyymm') as ANO_MES_REFERENCIA, 
    m.codigo_empresa as COD_ORG,
    m.tipo_movimento,
		to_number(substr(C.codigo,5,10)) || case when substr(c.codigo,15,1) not in ('0','1','2','3','4','5','6','7','8','9') then 7 else to_number(substr(c.codigo,15,1)) end as MATRICULA, 
		TO_CHAR(sum(case m.codigo_verba when '4431' then m.valor_verba else 0 end),'0000000.00') as BASE_CALC_CONTRI, /*BASE CONTRIB PREVIDENCIARIA GERAL - RPPS*/ 
		TO_CHAR(sum(case when m.codigo_verba = '2171' then m.valor_verba
                     when m.codigo_verba = '202I' then m.valor_verba else 0 end),'0000000.00') as VAL_CONT_BAS_SEG, /*CONTRIB PREVIDENCIARIA - RPPS*/ 
    TO_CHAR(sum(case when m.codigo_verba = '3509' then m.valor_verba
                     when m.codigo_verba = '3510' then m.valor_verba else 0 end),'0000000.00')  as VAL_CONT_PATRO_NORM, /*PATRONAL - RPPS*/ 
    TO_CHAR(sum(case m.codigo_verba when '4xx2' then m.valor_verba else 0 end),'0000000.00') as VAL_CONT_ADIC_SEG,/*Contribuição Adicional do Segurado*/ 
		TO_CHAR(sum(case m.codigo_verba when '4xx3' then m.valor_verba else 0 end),'0000000.00') as VAL_CONT_PATR_ADIC, /*PATRONAL adcional - RPPS*/ 
		TO_CHAR(sum(case m.codigo_verba when '4001' then m.valor_verba else 0 end),'0000000.00') as REMUNERACAO_TOTAL, /*já é a verba correta*/ 
    TRIM(p.nome) AS NOME,
    case when c.data_admissao < to_date('30/12/2011','dd/mm/yyyy') then 1 else 2 end as COD_PLANO, 
    c.situacao_funcional,
		SUBSTR(TO_CHAR(m.ano_mes_referencia,'YYYYMMDD'),1,6)||'30' as DATA_PAGAMENTO,
    case when m.tipo_movimento = 'GD' then 'S' else 'N' end as DECIMO_TERCEIRO,  
		'N' as FERIAS, 	
		'N' as RESCISAO /* não tem rescisão na PBH - verificar se a 4024 está sendo usada para outros fins */	 
	from RHPESS_CONTRATO c
       inner join RHPESS_PESSOA p on p.CODIGO_EMPRESA = c.CODIGO_EMPRESA and p.CODIGO = c.CODIGO_PESSOA
       inner join RHMOVI_MOVIMENTO m on m.CODIGO_EMPRESA = c.CODIGO_EMPRESA
             and m.TIPO_CONTRATO = c.TIPO_CONTRATO
             and m.CODIGO_CONTRATO = c.CODIGO   
       inner join RHPARM_VERBA v on m.CODIGO_VERBA = v.CODIGO
	where m.tipo_movimento IN('GU', 'GD') 
    and v.codigo IN('4431', '2171', '202I', '3509', '3510', '4xx2', '4xx3', '4001')
		and m.modo_operacao = 'R' 
		and m.ano_mes_referencia = ADD_MONTHS(TRUNC(SYSDATE, 'MONTH'), -1)
		and m.tipo_contrato = '0001'
    and c.situacao_funcional in ('5300','5303')
    and m.VALOR_VERBA > 0 
		and c.vinculo in ('0000','0002')
		and c.ano_mes_referencia = ( 
			select max(x.ano_mes_referencia) 
				from rhpess_contrato x 
			 where x.codigo_empresa = c.codigo_empresa 
				 and x.tipo_contrato = c.tipo_contrato  
				 and x.codigo = c.codigo 
				 and x.ano_mes_referencia <= m.ano_mes_referencia) 
	group by m.codigo_empresa, m.ano_mes_referencia, c.data_admissao, m.codigo_contrato, c.codigo, m.tipo_movimento, c.situacao_funcional, P.NOME