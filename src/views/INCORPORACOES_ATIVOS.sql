
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."INCORPORACOES_ATIVOS" ("ANO_MES_REFERENCIA", "COD_PLANO", "ORGANIZACAO", "MATRICULA", "CPF", "NOME_SERVIDOR", "VERBA", "VERBA_DESCRICAO", "VALOR", "BASE_CALC_VERBA", "QUANT_DIAS_PAGOS", "FATOR_CALCULO", "DATA_PAGAMENTO", "DECIMO_TERCEIRO", "FERIAS", "RESCISAO") AS 
  select 
to_char(m.ano_mes_referencia,'yyyymm') as ANO_MES_REFERENCIA,

case  when c.data_admissao < to_date('30/12/2011','dd/mm/yyyy') 
then 1 
else 2 
end as COD_PLANO,

1 as ORGANIZACAO, 


 SUBSTR(C.CODIGO, 5,10) ||CASE WHEN SUBSTR(C.CODIGO, 15,1) != 'X' THEN SUBSTR(C.CODIGO, 15,1) ELSE '7' END AS MATRICULA,

SUBSTR(TRIM(p.cpf),1,11) as CPF,

substr(TRIM(p.nome),1,80) as NOME_SERVIDOR,


m.codigo_verba as VERBA, 

substr(TRIM(v.descricao),1,80) as VERBA_DESCRICAO,

TRIM(m.valor_verba) as VALOR,  


0 as BASE_CALC_VERBA, 
30 as QUANT_DIAS_PAGOS, 


m.ref_verba as FATOR_CALCULO,
30||to_char(m.ano_mes_referencia,'mmyyyy') as DATA_PAGAMENTO,
'N' AS DECIMO_TERCEIRO,
'N' AS FERIAS,
'N' AS RESCISAO


from rhmovi_movimento m, rhpess_contrato c, rhpess_pessoa p, rhparm_verba v

where m.codigo_empresa = c.codigo_empresa 
and m.tipo_contrato = c.tipo_contrato
and m.codigo_contrato = c.codigo
and c.codigo_empresa = p.codigo_empresa
and c.codigo_pessoa = p.codigo
and m.codigo_verba = v.codigo
and v.inc50l = 'S'
and m.ctrl_demo = 'N'
and m.codigo_verba between '1000'  and  '1300' 
and m.codigo_empresa = '0001' 
and m.tipo_movimento = 'ME'
and m.modo_operacao = 'R'
and m.tipo_contrato = '0001'
AND M.ANO_MES_REFERENCIA <= add_months(sysdate,(-1))-0

and c.vinculo in ('0000','0002','0001')

and C.CODIGO in ('000000000483056')


and c.ano_mes_referencia = (
	select max(x.ano_mes_referencia) from rhpess_contrato x
	where x.codigo_empresa = c.codigo_empresa
	and x.tipo_contrato = c.tipo_contrato 
	and x.codigo = c.codigo
	and x.ano_mes_referencia <= M.ANO_MES_REFERENCIA) 

UNION

(
	select  
	to_char(m.ano_mes_referencia,'yyyymm') as ANO_MES_REFERENCIA,

	case  when c.data_admissao < to_date('30/12/2011','dd/mm/yyyy') 
	then 1 
	else 2 
	end as COD_PLANO,

	1 as ORGANIZACAO, 


  SUBSTR(C.CODIGO, 5,10) ||CASE WHEN SUBSTR(C.CODIGO, 15,1) != 'X' THEN SUBSTR(C.CODIGO, 15,1) ELSE '7' END AS MATRICULA,

	SUBSTR(TRIM(p.cpf),1,11) as CPF,

	substr(TRIM(p.nome),1,80) as NOME_SERVIDOR, 

	m.codigo_verba as VERBA, 

	substr(TRIM(v.descricao),1,80) as VERBA_DESCRICAO,

	TRIM(m.valor_verba) as VALOR, 


	0 as BASE_CALC_VERBA, 
	30 as QUANT_DIAS_PAGOS, 


	m.ref_verba as FATOR_CALCULO,
	30||to_char(m.ano_mes_referencia,'mmyyyy') as DATA_PAGAMENTO,
	'N' AS DECIMO_TERCEIRO,
	'N' AS FERIAS,
	'N' AS RESCISAO


	from rhmovi_movimento m, rhpess_contrato c, rhpess_pessoa p, rhparm_verba v

	where m.codigo_empresa = c.codigo_empresa 
	and m.tipo_contrato = c.tipo_contrato
	and m.codigo_contrato = c.codigo
	and c.codigo_empresa = p.codigo_empresa
	and c.codigo_pessoa = p.codigo
	and m.codigo_verba = v.codigo

	and 
	(
		m.codigo_verba in ('100C','100Y','101N','105A','105H','1082','1089','1098','1137','1139','1156','1159','1166','1167','1173','117A','117F','117G',
			'1196','1200','1217','1219','1230','130C','1335','1336','135A','137A','1382','1398','1437','1456','1459','1466',
			'1473','1517','1555','1556','1582','1589','177B','1782','1817','1889','1898','1937','1956','1959','1966','1973','197A','2157','2159',
			'230C','2335','2336','2357','2382','2533','2534','2541','2542','2589','2617','2682','2737','2756','2759','2766','2773','277A','2798','2817',
			'2857','2866','2899','290C','2937','2956','2959','2973','297A','1467','1496','1519','1819','1967','1996',
			'2619','2632','2767','2796','2819','2832','2940','2967','2996','11A7','12A7','130Y','131N','14A7','15A7','180Y',
			'181N','185A','18A7','18A7','195H','205A','230Y','231N','235H','26A7','27A7','280Y','281N','285A','285H','28AE','298A','29AZ') 
		or
		( 
			m.codigo_verba in ('1001','1102','1103','1117') and 
			c.cod_cargo_efetivo >= '000000000001501' and 
			c.cod_cargo_efetivo <= '000000000001515'
			) 
		or
		(
			( 	
				m.codigo_verba in ('1140','1232','1233','1440','1940','2940','2740','1532','1832','2832','2632','1533','1843','2843','2643','1165','1465','1965','2765','286A') and 
				m.ano_mes_referencia < to_date('01/02/2019','dd/mm/yyyy')
				)
			) 
		or
		(
			(m.codigo_verba in ('1001') and c.cod_cargo_efetivo >= '000000000001434' and c.cod_cargo_efetivo <= '000000000001436') and 
			m.ano_mes_referencia >= to_date('01/02/2019','dd/mm/yyyy')
			) 
		or
		(
			(
				m.codigo_verba in ('1178','1220','1257','1258') and 
				m.ano_mes_referencia >= to_date('01/01/2001','dd/mm/yyyy') and 
				m.ano_mes_referencia <= to_date('31/03/2010','dd/mm/yyyy')
				) 
			or
			( 
				m.codigo_verba in ('1178','1220','1257','1258') and 
				m.ano_mes_referencia >= to_date('01/09/2017','dd/mm/yyyy')
				)
			)
	)    	 
	and m.valor_verba > 0
	and m.codigo_empresa = '0001'  
	and m.tipo_movimento IN ('ME','PS')
	and m.modo_operacao = 'R'
	and m.ano_mes_referencia <= add_months(sysdate,(-1))-0 
	and m.tipo_contrato = '0001'
	and c.vinculo in ('0000','0002','0001')

and C.CODIGO in ('000000000483056')

	and c.ano_mes_referencia = (
		select max(x.ano_mes_referencia) from rhpess_contrato x
		where x.codigo_empresa = c.codigo_empresa
		and x.tipo_contrato = c.tipo_contrato 
		and x.codigo = c.codigo
		and x.ano_mes_referencia <= m.ano_mes_referencia)  
)