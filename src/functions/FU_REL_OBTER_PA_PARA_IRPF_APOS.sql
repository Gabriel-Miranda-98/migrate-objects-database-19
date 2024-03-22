
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."FU_REL_OBTER_PA_PARA_IRPF_APOS" (
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

for c2 in(
select
co.codigo_empresa,
co.tipo_contrato,
co.codigo_contrato,
co.nome,
co.cpf_relac as CPF,
co.data_nascimento,
(VALOR_01 + VALOR_02 + VALOR_03 + VALOR_04 + VALOR_05 + VALOR_06 +
VALOR_07 + VALOR_08 + VALOR_09 + VALOR_10 + VALOR_11 + VALOR_12) AS VALOR,
VALOR_13 AS VALOR_DECIMO_TERCEIRO
from
	rhdirf_consol_2011 co
where
co.codigo_empresa=pCODIGO_EMPRESA and
co.grupo_dirf=pGRUPO_DIRF and
co.ano_referencia=pDATA_REFERENCIA and
co.tipo_registro = 'RTPA' and
co.tipo_contrato=pTIPO_CONTRATO and
co.codigo_contrato=pCODIGO_CONTRATO and
co.cnpj_declarante = pCNPJ and
co.codigo_retencao in ('3533','1889') and
co.ocorrencia > 0
order by
co.codigo_contrato,
co.nome
)
loop
    vtexto := vtexto || rpad(c2.nome, 40, ' ') || CHR(10);
    vtexto := vtexto || rpad('CPF: ' ||c2.Cpf, 20, ' ') || rpad('DT. NASC.:' || TO_CHAR(c2.Data_Nascimento,'DD/MM/YYYY'),
20, ' ')|| CHR(10);
    vtexto := vtexto || rpad('VALOR: ', 7,' ') || RPAD(trim(TO_CHAR
(c2.VALOR,'9G999G999G999G990D99','NLS_NUMERIC_CHARACTERS = '',.''')),10, ' ') || rpad(' VALOR 13o: ', 12,' ') || LPAD
(trim(TO_CHAR(c2.VALOR_DECIMO_TERCEIRO,'9G999G999G999G990D99','NLS_NUMERIC_CHARACTERS = '',.''')),11, ' ') || CHR(10);
    vtexto_salto_linha := vtexto_salto_linha || '000';

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
 