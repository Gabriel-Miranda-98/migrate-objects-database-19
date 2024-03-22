
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."FU_REL_OBTER_PS_PARA_IRPF_APOS" (
pCODIGO_EMPRESA IN CHAR,
pTIPO_CONTRATO IN CHAR,
pCODIGO_CONTRATO IN CHAR,
pCNPJ IN CHAR,
pGRUPO_DIRF IN CHAR,
pDATA_REFERENCIA IN CHAR
) RETURN TABLE_LINHA
PIPELINED IS

  out_rec REG_LINHA := reg_LINHA(NULL,NULL,NULL,NULL);
  rel_tab Table_linha;

vTEXTO_RETORNO VARCHAR2(4000);
vcontador number;
vtexto varchar2(4000);
vtexto_salto_linha varchar2(4000);
begin

for c0 in (select * from rhorga_fornecedor
            where codigo in ('000000000008001','000000000008035','000000000008036'))
loop
vcontador := 0;

for c2 in(
select
co.codigo_empresa,
co.tipo_contrato,
co.codigo_contrato,
co.nome,
co.cpf_relac,
co.valor_anual,
case 	when co.informacao_compl = '03' then 'Cônjuge/Companheiro(a)'
	   	when co.informacao_compl = '04' then 'Filho(a)'
		when co.informacao_compl = '06' then 'Enteado(a)'
	  	when co.informacao_compl = '08' then 'Pai/Mãe'
	  	when co.informacao_compl = '10' then 'Agregado(a)'
	else
		'Titular'
	end relacao,
case when co.tipo_registro = 'TPSE' then substr(co.cnpj_cpf_benefic,4)
	else
		co.cpf_relac
	end cpf,
case when co.tipo_registro = 'TPSE' then (select max(data_nascimento) from rhpess_pessoa where codigo_empresa = co.codigo_empresa and cpf = substr(co.cnpj_cpf_benefic,4))
	else
		co.data_nascimento
	end data_nascimento,
f.razao_social,
f.cgc_cpf,
f.registro_ans
from
	rhdirf_consol_2011 co,
	rhorga_fornecedor f
where
co.codigo_empresa=pCODIGO_EMPRESA and
co.grupo_dirf=pGRUPO_DIRF and
co.ano_referencia=pDATA_REFERENCIA and
co.tipo_registro in ('TPSE','DTPSE') and
co.tipo_contrato=pTIPO_CONTRATO and
co.codigo_contrato=pCODIGO_CONTRATO and
co.codigo_fornecedor = f.codigo and
co.cnpj_declarante = pCNPJ and
co.codigo_retencao = '9999' and
co.ocorrencia > 0 and
co.codigo_fornecedor = c0.codigo

order by
co.codigo_contrato,
f.cgc_cpf,
co.tipo_registro desc,
co.nome)
loop
    vcontador := vcontador + 1;
    IF vcontador = 1 then
    vtexto := vtexto || rpad(c2.razao_social, 40, ' ') || CHR(10);
    vtexto := vtexto || rpad('CNPJ: ' ||c2.CGC_CPF, 29, ' ') || rpad('ANS: ' || c2.REGISTRO_ANS, 11, ' ')|| CHR(10);
    vtexto_salto_linha := vtexto_salto_linha || '10';
    end if;

    vtexto := vtexto || rpad(c2.nome, 40, ' ') || CHR(10);
    vtexto := vtexto || rpad('CPF: ' ||c2.Cpf, 20, ' ') || rpad('DT. NASC.:' || TO_CHAR(c2.Data_Nascimento,'DD/MM/YYYY'), 20, ' ')|| CHR(10);
    vtexto := vtexto || rpad(c2.relacao, 29, ' ') || LPAD(trim(TO_CHAR(C2.VALOR_ANUAL,'9G999G999G999G990D99','NLS_NUMERIC_CHARACTERS = '',.''')),11, ' ')|| CHR(10);
    vtexto_salto_linha := vtexto_salto_linha || '000';

end loop;

end loop;

vTEXTO_RETORNO := vtexto;
out_rec.CODIGO_EMPRESA := pCODIGO_EMPRESA;
out_rec.TIPO_CONTRATO := pTIPO_CONTRATO;
out_rec.CODIGO_CONTRATO := pCODIGO_CONTRATO;
out_rec.LINHA := vTEXTO_RETORNO;

rel_tab := TABLE_LINHA();
rel_tab.extend(1);
rel_tab(rel_tab.last) := out_rec;
PIPE ROW(rel_tab(1));
return;
end;

 