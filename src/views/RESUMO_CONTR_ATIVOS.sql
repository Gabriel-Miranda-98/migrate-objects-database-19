
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."RESUMO_CONTR_ATIVOS" ("ANO_MES_REFERENCIA", "DATA_PAGAMENTO", "COD_PLANO", "NOME", "COD_ORG", "MATRICULA", "BASE_CALC_CONTRI", "VAL_CONT_BAS_SEG", "VAL_CONT_PATRO_NORM", "VAL_CONT_ADIC_SEG", "VAL_CONT_PATR_ADIC", "REMUNERACAO_TOTAL", "DECIMO_TERCEIRO", "FERIAS", "RESCISAO") AS 
  select    
 to_char(m.ano_mes_referencia,'yyyymm') as ANO_MES_REFERENCIA,  
   
SUBSTR(TO_CHAR(m.ano_mes_referencia),1,6)||'30' as DATA_PAGAMENTO,   
  
case  when c.data_admissao < to_date('30/12/2011','dd/mm/yyyy')   
		then 1 /*fufin*/  
		else 2 /*bhprev*/  
		end as COD_PLANO,  
  TRIM(P.NOME) AS NOME,
1 as COD_ORG, /* Admin direta */  

to_number(substr(C.codigo,5,10))|| case when substr(c.codigo,15,1) not in ('0','1','2','3','4','5','6','7','8','9')  
	then 7  
	else to_number(substr(c.codigo,15,1))  
	end as MATRICULA,  

TO_CHAR(sum(case m.codigo_verba when '4436' then m.valor_verba else 0 end),'0000000.00') as BASE_CALC_CONTRI, /*BASE CONTRIB PREVIDENCIARIA GERAL - RPPS*/  
TO_CHAR(sum(case m.codigo_verba when '4437' then m.valor_verba else 0 end),'0000000.00') as VAL_CONT_BAS_SEG, /*CONTRIB PREVIDENCIARIA - RPPS*/  
TO_CHAR(sum(case m.codigo_verba when '4438' then m.valor_verba else 0 end),'0000000.00') as VAL_CONT_PATRO_NORM, /*PATRONAL - RPPS*/  
TO_CHAR(sum(case m.codigo_verba when '4xx2' then m.valor_verba else 0 end),'0000000.00') as VAL_CONT_ADIC_SEG,/*Contribuição Adicional do Segurado*/  
TO_CHAR(sum(case m.codigo_verba when '4xx3' then m.valor_verba else 0 end),'0000000.00') as VAL_CONT_PATR_ADIC, /*PATRONAL adcional - RPPS*/  

TO_CHAR(sum(case m.codigo_verba when '4001' then m.valor_verba else 0 end),'0000000.00') as REMUNERACAO_TOTAL, /*já é a verba correta*/  

case when m.tipo_movimento = 'DE' then 'S' else 'N' end as DECIMO_TERCEIRO,  

'N' as FERIAS,  

/* não tem rescisão na PBH - verificar se a 4024 está sendo usada para outros fins */	  
'N' as RESCISAO  


 from
      RHPESS_CONTRATO c

      inner join RHPESS_PESSOA p on
        p.CODIGO_EMPRESA = c.CODIGO_EMPRESA
        and p.CODIGO = c.CODIGO_PESSOA

      inner join RHMOVI_MOVIMENTO m on
        m.CODIGO_EMPRESA = c.CODIGO_EMPRESA
        and m.TIPO_CONTRATO = c.TIPO_CONTRATO
        and m.CODIGO_CONTRATO = c.CODIGO

      inner join RHPARM_VERBA v on
        m.CODIGO_VERBA = v.CODIGO

WHERE  v.codigo in ('4001','4436', '4437', '4438')  
  and c.ano_mes_referencia = (  
	select max(x.ano_mes_referencia) from rhpess_contrato x  
	where x.codigo_empresa = c.codigo_empresa  
	and x.tipo_contrato = c.tipo_contrato   
	and x.codigo = c.codigo  
	and x.ano_mes_referencia <= m.ano_mes_referencia)  
and m.tipo_movimento in ('ME','DE')  
and m.modo_operacao = 'R'  
and m.ano_mes_referencia >= TO_dATE ('20191201','YYYYMMDD') 
and m.tipo_contrato = '0001'  
and c.situacao_funcional <> '1900'  
and c.codigo_empresa = '0001'
and c.codigo <= '000000099999999'
and c.vinculo in ('0000','0002')  /* verificar */  



/* fim*/  


group by m.ano_mes_referencia,  
         c.data_admissao,  
         m.codigo_contrato,  
         c.codigo,  
         m.tipo_movimento
         ,
         P.NOME