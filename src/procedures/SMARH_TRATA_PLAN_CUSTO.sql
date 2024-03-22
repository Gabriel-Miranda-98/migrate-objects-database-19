
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."SMARH_TRATA_PLAN_CUSTO" 
as
vCodigoVinculo Varchar2(4);
vCodigoCargoEfetivo Varchar2(15);
vDescricaoVinculo Varchar2(4000);
vDescricaoCarreira Varchar2(4000);
vComplementoCarreira Varchar2(4000);
vComando_update varchar2(4000);
vNome_coluna varchar2(30); 
begin
  execute immediate 'TRUNCATE table SMARH_PLANILHA_CUSTO';
  insert into SMARH_PLANILHA_CUSTO (select * from SMARH_QUADRO_CUSTO);
  commit;
  execute immediate 'TRUNCATE table SMARH_PLANILHA_CUSTO_TRATADA';
  commit;
  insert into SMARH_PLANILHA_CUSTO_TRATADA (select * from SMARH_PLANILHA_CUSTO);
/*
for c1 in (select cod_cargo_efetivo, CODIGO_VINCULO, complemento_carreira  from SMARH_PLANILHA_CUSTO_TRATADA where EMPRESA = 'ADMINISTRAÇÃO DIRETA')
loop
  vCodigoVinculo := C1.CODIGO_VINCULO;
  vComplementoCarreira := C1.COMPLEMENTO_CARREIRA;

  IF (C1.cod_cargo_efetivo IS NOT NULL) THEN
    vCodigoCargoEfetivo := C1.cod_cargo_efetivo;
  ELSE
    vCodigoCargoEfetivo := '000000000000000';
  END IF;

  -- Carreira
  case
  when vCodigoCargoEfetivo <> '000000000000000' and vCodigoVinculo <> '0013' then
    vDescricaoCarreira := CONCAT('DIRETA',SUBSTR(UPPER(TRIM(REPLACE(vComplementoCarreira,'Menores','ESTAGIÁRIO'))),3));
    --vDescricaoCarreira := 'DIRETA - ESTAGIÁRIO';
  when vCodigoCargoEfetivo <> '000000000000000' and vCodigoVinculo = '0013' then
    vDescricaoCarreira := 'DIRETA - CONTRATO ADMINISTRATIVO';
  else
    vDescricaoCarreira := 'DIRETA - RECRUTAMENTO AMPLO';
  end case;

  -- Vinculo
  case
  when vCodigoVinculo in ('0000','0002') then
    vDescricaoVinculo := 'EFETIVO ESTATUTÁRIO';
  when vCodigoVinculo = '0001' then
    vDescricaoVinculo := 'EFETIVO CELETISTA';
  when vCodigoVinculo in ('0010','0011','0012') or (vCodigoVinculo = '0009' and vCodigoCargoEfetivo not in ('000000000002003','000000000002004')) then
    vDescricaoVinculo := 'RECRUTAMENTO AMPLO';
  when vCodigoVinculo = '0013' then
    vDescricaoVinculo := 'CONTRATO ADMINISTRATIVO';
  when vCodigoVinculo = '0009' and vCodigoCargoEfetivo in ('000000000002003','000000000002004') then
    vDescricaoVinculo := 'ESTAGIÁRIO';
  else
    vDescricaoVinculo := 'OUTRO';
  end case;

  --dbms_output.put_line('Carreira = ' || vDescricaoCarreira || ' - ' || 'Vinculo = ' || vDescricaoVinculo);
end loop;

*/
  begin
  -- Grau de instrução
  update SMARH_PLANILHA_CUSTO_TRATADA set
  GRAU_INSTRUCAO = (select LPAD(CODIGO, 4, 0) from SMARH_GRAU_INSTRUCAO where FONTE_DADOS = EMPRESA and CODIGO_GRAU_INSTRUCAO = GRAU_INSTRUCAO),
  DESCRICAO_INSTRUCAO = (select DESCRICAO_PADRAO from SMARH_GRAU_INSTRUCAO where FONTE_DADOS = EMPRESA and CODIGO_GRAU_INSTRUCAO = GRAU_INSTRUCAO);
  update SMARH_PLANILHA_CUSTO_TRATADA set
  GRAU_INSTRUCAO = '0012',
  DESCRICAO_INSTRUCAO = 'NÃO INFORMADO'
  where GRAU_INSTRUCAO is null;
  -- Idade
  update SMARH_PLANILHA_CUSTO_TRATADA set idade = trunc(months_between(to_date(data_referencia,'DD/MM/YYYY'),
         to_date(data_nascimento,'DD/MM/YYYY'))/12)
   where idade is null
     and data_nascimento is not null
     and data_referencia is not null;
  commit;
  --Formatação
  --  Maiusculas
  --  sem acento
  --  sem excesso de espaços em branco
  update SMARH_PLANILHA_CUSTO_TRATADA set cargo = upper(trim(translate(cargo,'âàãáÁÂÀÃéêÉÊíÍóôõÓÔÕüúÜÚÇç','AAAAAAAAEEEEIIOOOOOOUUUUCC'))),
  descricao_situacao_funcional = upper(translate(descricao_situacao_funcional,'âàãáÁÂÀÃéêÉÊíÍóôõÓÔÕüúÜÚÇç','AAAAAAAAEEEEIIOOOOOOUUUUCC')),
  descricao_instrucao = upper(translate(descricao_instrucao,'âàãáÁÂÀÃéêÉÊíÍóôõÓÔÕüúÜÚÇç','AAAAAAAAEEEEIIOOOOOOUUUUCC')),
  descricao_raca_cor = upper(translate(descricao_raca_cor,'âàãáÁÂÀÃéêÉÊíÍóôõÓÔÕüúÜÚÇç','AAAAAAAAEEEEIIOOOOOOUUUUCC'));
  commit;
  end;
  --HOB
  begin
    for c1 in (select column_name from all_tab_columns where table_name = 'SMARH_PLANILHA_CUSTO')
    loop
      vNome_coluna := c1.column_name;
      vComando_update := 'update SMARH_PLANILHA_CUSTO_TRATADA set ' || vNome_coluna || '= ''HOB'' where ' || vNome_coluna || ' = ''HOSPITAL MUNICIPAL ODILON BEHRENS'' and CODIGO_EMPRESA = ''53''';
      execute immediate vComando_update;
      --dbms_output.put_line(vComando_update);
      commit;
    end loop;
  end;
  begin
    for c1 in (select column_name from all_tab_columns where table_name = 'SMARH_PLANILHA_CUSTO')
    loop
      vNome_coluna := c1.column_name;
      vComando_update := 'update SMARH_PLANILHA_CUSTO_TRATADA set ' || vNome_coluna || '= UPPER( ' || vNome_coluna || ' )';
      execute immediate vComando_update;
      --dbms_output.put_line(vComando_update);
      commit;
    end loop;
  end;
  update SMARH_PLANILHA_CUSTO_TRATADA set nivel_hierarquico_4 = 'GERÊNCIA DE DISTRITO SANITÁRIO' where nivel_hierarquico_4 is null;
  commit;
  update SMARH_PLANILHA_CUSTO_TRATADA set nivel_hierarquico_5 = 'GERÊNCIA DE DISTRITO SANITÁRIO' where nivel_hierarquico_4 is null;
  commit;
 update SMARH_PLANILHA_CUSTO_TRATADA set RACA_COR = '0000' where DESCRICAO_RACA_COR = 'INDIGENA';
  update SMARH_PLANILHA_CUSTO_TRATADA set RACA_COR = '0002' where DESCRICAO_RACA_COR = 'BRANCA';
  update SMARH_PLANILHA_CUSTO_TRATADA set RACA_COR = '0004' where DESCRICAO_RACA_COR = 'PRETA';
  update SMARH_PLANILHA_CUSTO_TRATADA set RACA_COR = '0006' where DESCRICAO_RACA_COR = 'AMARELA';
  update SMARH_PLANILHA_CUSTO_TRATADA set RACA_COR = '0008' where DESCRICAO_RACA_COR = 'PARDA';
  update SMARH_PLANILHA_CUSTO_TRATADA set RACA_COR = '0009', DESCRICAO_RACA_COR ='NÃO INFORMADA' where DESCRICAO_RACA_COR is null;
  update SMARH_PLANILHA_CUSTO_TRATADA set RACA_COR = '0009', DESCRICAO_RACA_COR ='NÃO INFORMADA' where DESCRICAO_RACA_COR not in ('INDIGENA','BRANCA','PRETA','AMARELA','PARDA');
  commit;
  update SMARH_PLANILHA_CUSTO_TRATADA set VINCULO = 'ESTAGIÁRIO' where VINCULO = 'ESTAGIARIO';
  commit;
  update SMARH_PLANILHA_CUSTO_TRATADA set CUSTO_TOTAL = TOTAL_REMUNERACAO
   where EMPRESA in ('CAIXA ESCOLAR','AMAS') and CUSTO_TOTAL is null;
  commit;
  /*
0000 INDIGENA
0002 BRANCA
0004 PRETA
0006 AMARELA
0008 PARDA
0009 NÃO INFORMADA
  */
/*
select * from "ARTERH"."SMARH_QUADRO_CUSTO" where codigo_unidade_2 = '9991' and nivel_hierarquico_1 = 'PESSOAL';

select * from "ARTERH"."SMARH_QUADRO_CUSTO" where nivel_hierarquico_4 is null;
select * from "ARTERH"."SMARH_QUADRO_CUSTO" where nivel_hierarquico_5 is null;

select * from "ARTERH"."SMARH_QUADRO_CUSTO" where EMPRESA = 'AMAS' and nivel_hierarquico_2 = 'Órgãos Externos';

select * from "ARTERH"."SMARH_QUADRO_CUSTO" where EMPRESA = 'HOB' and nivel_hierarquico_2 = 'Órgãos Externos';
  */
end;
