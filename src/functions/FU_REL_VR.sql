
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."FU_REL_VR" (
pMES_AFASTAMENTO_INICIAL IN CHAR,
pMES_AFASTAMENTO_FINAL IN CHAR,
pMES_FOLHA IN CHAR,
pUNIDADE_INICIAL IN CHAR,
pUNIDADE_FINAL IN CHAR,
pCODIGO_EMPRESA IN CHAR,
pTIPO_CONTRATO IN CHAR,
pDETALHAR IN CHAR,
pVALOR_VALE IN CHAR
) RETURN Table_rel_vr
PIPELINED IS
  
  out_rec        reg_rel_vr := reg_rel_vr(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  out_rec_rel_vr reg_rel_vr := reg_rel_vr(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

  rel_tab Table_rel_vr;

  rel_tab_rel_vr Table_rel_vr;

  rel_tab_licencas_detalhadas table_rel_vr_licencas;
  out_rec_licencas_detalhadas reg_rel_vr_licencas := reg_rel_vr_licencas(NULL,NULL,NULL,NULL,NULL,NULL,NULL);


v_VALOR_VALE NUMBER(15,2);
v_QUANTIDADE_VALE_POR_DIA NUMBER(15,2);
v_VALOR_VALE_POR_DIA NUMBER(15,2);
v_VENCIMENTO NUMBER(15,2);
v_DESCONTO_CONTADOR NUMBER(15,2);
v_DESCONTO_VALOR NUMBER(15,2);
v_QTDE_TOTAL_LICENCAS NUMBER;
vCONTADOR_CONTRATO NUMBER;
vCONTADOR_LICENCAS NUMBER;
vMES_AFASTAMENTO_INICIAL VARCHAR2(10);
vMES_AFASTAMENTO_FINAL VARCHAR2(10);
vMES_FOLHA VARCHAR2(10);
vUNIDADE_INICIAL VARCHAR2(4000);
vUNIDADE_FINAL VARCHAR2(4000);
vCODIGO_EMPRESA CHAR(4);
vTIPO_CONTRATO CHAR(4);
vDATA_VALE_INICIAL DATE;
vDATA_VALE_FINAL DATE;
v_VALOR_VALE_RECEBIDO NUMBER(15,2);
vQUANTIDADE_LICENCAS NUMBER;
vQUANTIDADE_LICENCAS_DESCONTO NUMBER;
vDATA_AFASTAMENTO_INICIAL DATE;
vDATA_AFASTAMENTO_FINAL DATE;
vDATA_FOLHA DATE;
vMES_VALE_RECEBIDO_ANTE_AFAST DATE;
vDETALHAR CHAR;
BEGIN

/*
vCONTADOR_CONTRATO := 0;
vCONTADOR_LICENCAS := 0;
vMES_AFASTAMENTO_INICIAL := '01/02/2015';
vMES_AFASTAMENTO_FINAL := '01/02/2015';
vMES_FOLHA := '01/04/2015';
vUNIDADE_INICIAL := '71.00.00.00.00.000';
vUNIDADE_FINAL := '71.03.00.00.00.000';
vCODIGO_EMPRESA := '0001';
vTIPO_CONTRATO := '0001';
*/
vMES_AFASTAMENTO_INICIAL := pMES_AFASTAMENTO_INICIAL;
vMES_AFASTAMENTO_FINAL := pMES_AFASTAMENTO_FINAL;
vMES_FOLHA := pMES_FOLHA;
vUNIDADE_INICIAL := pUNIDADE_INICIAL;
vUNIDADE_FINAL := pUNIDADE_FINAL;
vCODIGO_EMPRESA := pCODIGO_EMPRESA;
vTIPO_CONTRATO := pTIPO_CONTRATO;

/* Valida parâmetro pDETALHAR */
IF upper(pDETALHAR) not in ('S','N') THEN
raise_application_error (-20001,'PARAMETRO pDETALHAR INVALIDO. VALORES VÁLIDOS SÃO S ou N.');
END IF;
vDETALHAR := upper(pDETALHAR);

/* Valida parâmetro pMES_AFASTAMENTO_INICIAL */
IF trim(pMES_AFASTAMENTO_INICIAL) is null THEN
    raise_application_error (-20001,'PARAMETRO pMES_AFASTAMENTO_INICIAL NÃO INFORMADO CORRETAMENTE. PREENCHIMENTO OBRIGATORIO.');
END IF;
     
BEGIN   
     vDATA_VALE_INICIAL := ADD_MONTHS(TO_DATE(pMES_AFASTAMENTO_INICIAL,'DD/MM/YYYY'),-1);
     vDATA_AFASTAMENTO_INICIAL := TO_DATE(pMES_AFASTAMENTO_INICIAL,'DD/MM/YYYY');
EXCEPTION
 WHEN OTHERS THEN
 raise_application_error (-20001,'PARAMETRO pMES_AFASTAMENTO_INICIAL INVALIDO. TEM QUE SER UMA DATA VÁLIDA.');
END;

/* Valida parâmetro pMES_AFASTAMENTO_FINAL */
IF trim(pMES_AFASTAMENTO_FINAL) is null THEN
    raise_application_error (-20001,'PARAMETRO pMES_AFASTAMENTO_FINAL NÃO INFORMADO CORRETAMENTE. PREENCHIMENTO OBRIGATORIO.');
END IF;

BEGIN
     vDATA_VALE_FINAL := ADD_MONTHS(TO_DATE(pMES_AFASTAMENTO_FINAL,'DD/MM/YYYY'),-1);
     vDATA_AFASTAMENTO_FINAL := TO_DATE(pMES_AFASTAMENTO_FINAL,'DD/MM/YYYY');
EXCEPTION
 WHEN OTHERS THEN
 raise_application_error (-20001,'PARAMETRO pMES_AFASTAMENTO_FINAL INVALIDO. TEM QUE SER UMA DATA VÁLIDA.');
END;

/* Valida parâmetro pMES_FOLHA */
IF trim(pMES_FOLHA) is null THEN
    raise_application_error (-20001,'PARAMETRO pMES_FOLHA_FINAL NÃO INFORMADO CORRETAMENTE. PREENCHIMENTO OBRIGATORIO.');
END IF;

BEGIN
     vDATA_FOLHA := TO_DATE(pMES_FOLHA,'DD/MM/YYYY');
EXCEPTION
 WHEN OTHERS THEN
 raise_application_error (-20001,'PARAMETRO pMES_FOLHA INVALIDO. TEM QUE SER UMA DATA VÁLIDA.');
END;

IF vDATA_AFASTAMENTO_INICIAL > vDATA_AFASTAMENTO_FINAL THEN
raise_application_error (-20001,'PARAMETRO pMES_AFASTAMENTO_FINAL INVALIDO. A DATA DE AFASTAMENTO FINAL TEM QUE SER MAIOR OU IGUAL A DATA DE AFASTAMENTO INICIAL.');
END IF;

IF vDATA_FOLHA <= vDATA_AFASTAMENTO_FINAL THEN
raise_application_error (-20001,'PARAMETRO pMES_AFASTAMENTO_FINAL INVALIDO. PERIODO DE AFASTAMENTOS DEVE SER MENOR QUE PERIODO FOLHA.');
END IF;

/* Valida parâmetro pVALOR_VALE */
BEGIN
     v_VALOR_VALE := TO_NUMBER(pVALOR_VALE);
     
     IF v_VALOR_VALE < 0 THEN
        raise_application_error (-20001,'PARAMETRO pVALOR_VALE INVALIDO. VALOR TEM QUE SER MAIOR OU IGUAL A ZERO.');
     END IF;
EXCEPTION
 WHEN OTHERS THEN
 raise_application_error (-20001,'PARAMETRO pVALOR_VALE INVALIDO. TEM QUE SER UM NUMERO VÁLIDO.');
END;

  rel_tab := TABLE_REL_VR();
  rel_tab_licencas_detalhadas := TABLE_REL_VR_LICENCAS();
  rel_tab_rel_vr := TABLE_REL_VR();

for c1 in (

select RHPESS_CONTRATO.CODIGO_EMPRESA, RHPESS_CONTRATO.TIPO_CONTRATO, RHPESS_CONTRATO.CODIGO, RHPESS_CONTRATO.NOME,
       (
       SUBSTR(RHPESS_CONTRATO.COD_UNIDADE1,5,2) || '.' ||
       SUBSTR(RHPESS_CONTRATO.COD_UNIDADE2,5,2) || '.' ||
       SUBSTR(RHPESS_CONTRATO.COD_UNIDADE3,5,2) || '.' ||
       SUBSTR(RHPESS_CONTRATO.COD_UNIDADE4,5,2) || '.' ||
       SUBSTR(RHPESS_CONTRATO.COD_UNIDADE5,5,2) || '.' ||
       SUBSTR(RHPESS_CONTRATO.COD_UNIDADE6,4,3)
       )  CODIGO_UNIDADE,
       NVL(RHORGA_AGRUPADOR.TEXTO_ASSOCIADO, RHORGA_AGRUPADOR.DESCRICAO) AS DESCRICAO_UNIDADE
  from RHPESS_CONTRATO, RHORGA_AGRUPADOR
 where RHPESS_CONTRATO.ANO_MES_REFERENCIA = (SELECT MAX(ANO_MES_REFERENCIA)
                                              FROM RHPESS_CONTRATO CONT
                                             WHERE CONT.CODIGO_EMPRESA = RHPESS_CONTRATO.CODIGO_EMPRESA
                                               AND CONT.TIPO_CONTRATO = RHPESS_CONTRATO.TIPO_CONTRATO
                                               AND CONT.CODIGO = RHPESS_CONTRATO.CODIGO
                                               AND CONT.ANO_MES_REFERENCIA <= to_date(vMES_FOLHA,'DD/MM/YYYY') )
   and RHPESS_CONTRATO.CODIGO_EMPRESA = vCODIGO_EMPRESA
   and RHPESS_CONTRATO.TIPO_CONTRATO = vTIPO_CONTRATO
   and RHPESS_CONTRATO.CODIGO between '000000000000000' and '999999999999999'
   and RHORGA_AGRUPADOR.TIPO_AGRUP = 'U'
   and RHPESS_CONTRATO.CODIGO_EMPRESA = RHORGA_AGRUPADOR.CODIGO_EMPRESA
   and RHPESS_CONTRATO.COD_UNIDADE1 = RHORGA_AGRUPADOR.COD_AGRUP1
   and RHPESS_CONTRATO.COD_UNIDADE2 = RHORGA_AGRUPADOR.COD_AGRUP2
   and RHPESS_CONTRATO.COD_UNIDADE3 = RHORGA_AGRUPADOR.COD_AGRUP3
   and RHPESS_CONTRATO.COD_UNIDADE4 = RHORGA_AGRUPADOR.COD_AGRUP4
   and RHPESS_CONTRATO.COD_UNIDADE5 = RHORGA_AGRUPADOR.COD_AGRUP5
   and RHPESS_CONTRATO.COD_UNIDADE6 = RHORGA_AGRUPADOR.COD_AGRUP6

   and (
       SUBSTR(RHPESS_CONTRATO.COD_UNIDADE1,5,2) || '.' ||
       SUBSTR(RHPESS_CONTRATO.COD_UNIDADE2,5,2) || '.' ||
       SUBSTR(RHPESS_CONTRATO.COD_UNIDADE3,5,2) || '.' ||
       SUBSTR(RHPESS_CONTRATO.COD_UNIDADE4,5,2) || '.' ||
       SUBSTR(RHPESS_CONTRATO.COD_UNIDADE5,5,2) || '.' ||
       SUBSTR(RHPESS_CONTRATO.COD_UNIDADE6,4,3)
       ) between vUNIDADE_INICIAL and vUNIDADE_FINAL

   --and RHPESS_CONTRATO.CODIGO = '00000000107085X'--'000000001090583'
   --and RHPESS_CONTRATO.CODIGO in ( '00000000096139X', '000000000897845', '000000000898574', '000000000917498', '00000000105840X')
   and RHPESS_CONTRATO.COD_CARGO_EFETIVO not in ('000000000001423','000000000001424', '000000000001425')
   and exists (

select rhmovi_movimento.codigo_verba
			from rhmovi_movimento
		 where rhmovi_movimento.tipo_movimento = 'ME' and
           rhmovi_movimento.MODO_OPERACAO = 'R' and
           rhmovi_movimento.fase = '0' and
		       rhmovi_movimento.ano_mes_referencia between vDATA_VALE_INICIAL and vDATA_VALE_FINAL and
           rhmovi_movimento.codigo_verba in ('1074') and
           rhmovi_movimento.CODIGO_EMPRESA = RHPESS_CONTRATO.CODIGO_EMPRESA and
           rhmovi_movimento.TIPO_CONTRATO = RHPESS_CONTRATO.TIPO_CONTRATO and
		       rhmovi_movimento.CODIGO_CONTRATO = RHPESS_CONTRATO.CODIGO and
		       rhmovi_movimento.valor_verba > 0
   )


)
loop
    vCONTADOR_CONTRATO := vCONTADOR_CONTRATO + 1;
  
    out_rec_rel_vr.data_referencia_folha           := vDATA_FOLHA;
    out_rec_rel_vr.data_inicial_afastamento        := vDATA_AFASTAMENTO_INICIAL;
    out_rec_rel_vr.data_final_afastamento          := vDATA_AFASTAMENTO_FINAL;
    out_rec_rel_vr.codigo_empresa                  := C1.CODIGO_EMPRESA;
    out_rec_rel_vr.tipo_contrato                   := C1.TIPO_CONTRATO;
    out_rec_rel_vr.codigo_contrato                 := C1.CODIGO;
    out_rec_rel_vr.nome                            := C1.NOME;
    out_rec_rel_vr.codigo_unidade                  := C1.CODIGO_UNIDADE;
    out_rec_rel_vr.descricao_unidade               := C1.DESCRICAO_UNIDADE;
    out_rec_rel_vr.qtde_afastamentos               := 0;
    out_rec_rel_vr.total_descontos_existentes      := 0;
    out_rec_rel_vr.total_vencimento                := 0;
    out_rec_rel_vr.quantidade_vales_por_dia        := 0;
    out_rec_rel_vr.valor_vales_por_dia             := 0;
    out_rec_rel_vr.ano                             := NULL;
    out_rec_rel_vr.mes                             := NULL;
    out_rec_rel_vr.total_valor_recebido_vale       := NULL;  

  rel_tab.extend(1);
  rel_tab(rel_tab.last) := out_rec_rel_vr;
  --dbms_output.put_line(out_rec.NOME);

end loop;
   --dbms_output.put_line(vCONTADOR_CONTRATO);

-----INICIO LICENCAS-----

   FOR i in 1..rel_tab.count LOOP

       out_rec := rel_tab(i);
       vCONTADOR_LICENCAS := 0;
       vQUANTIDADE_LICENCAS := 0;
       vQUANTIDADE_LICENCAS_DESCONTO := 0;
       vMES_VALE_RECEBIDO_ANTE_AFAST := NULL;
       v_DESCONTO_CONTADOR := 0;
       v_DESCONTO_VALOR := 0;
       v_VENCIMENTO := 0;
       v_QTDE_TOTAL_LICENCAS := 0;
       rel_tab_licencas_detalhadas.delete;

--BEGIN
--select SUM(NVL(DIASUTEISPERIODOMES,0)) into vQUANTIDADE_LICENCAS from(
for c3 in(
select CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO_CONTRATO,
ANO, MES,
DIASUTEISPERIODOMES,
QTDE_DIAS_UTEIS_MES,
SUM(DIASUTEISPERIODOMES) OVER (PARTITION BY CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO  ORDER BY CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO) AS TOTAL_DIAS_POR_CONTRATO
 from
/* INICIO DIAS_LICENCAS */
(
      SELECT CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO_CONTRATO,
ANO,MES,
SUM(NVL(DIASUTEISPERIODOMES, 0)) as DIASUTEISPERIODOMES,
MAX(NVL(QTDE_DIAS_UTEIS_MES, 0)) as QTDE_DIAS_UTEIS_MES

from (
SELECT DISTINCT 'LICENCAS_FALTAS_ETC' as TIPO_REGISTRO,
CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO_CONTRATO,
CODIGO_SITUACAO,
1 as SEQUENCIA,
ABREVIACAO_SITUACAO,
PERIODO_LICENCA,
DIASUTEISPERIODO,
DIASUTEISPERIODOMES,
DIASTOTALPERIODO,
DIASTOTALPERIODOMES,
QTDE_DIAS_MES,
QTDE_DIAS_UTEIS_MES,
dataInicialPeriodo,
dataFinalPeriodo,
ANO_MES_REFERENCIA,
MES,ANO
 FROM(

select
CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO_CONTRATO,
CODIGO_SITUACAO,
DESCRICAO_SITUACAO,
ABREVIACAO_SITUACAO,
DATA,
PERIODO_LICENCA,
DIASUTEISPERIODO,
diasUteisPeriodoMES,
DIASTOTALPERIODO,
DIASTOTALPERIODOMES,
AGRUPA, AGRUPA2,GRP,PERIODO,LINHA,
ANO_MES_REFERENCIA,
DIA,
MES,ANO, EH_SABADO_OU_DOMINGO, CALENDARIO_MES, EH_FERIADO, EH_DIA_UTIL, EH_DIA_UTIL_COMO_NUMERO, QTDE_DIAS_MES, QTDE_DIAS_UTEIS_MES, dataInicialPeriodo, dataFinalPeriodo
  from
(
select
       resumo.*,
       case when agrupa2 is not null then
       TO_CHAR(dataInicialUltimaAlter, 'DD/MM/YYYY HH:MI:SS')  || ' a ' || TO_CHAR(dataFinalUltimaAlter, 'DD/MM/YYYY HH:MI:SS')
       end as PERIODO_REGISTRO,
       case when agrupa is not null then
       TO_CHAR(dataInicialPeriodo, 'DD/MM/YYYY')  || ' a ' || TO_CHAR(dataFinalPeriodo, 'DD/MM/YYYY')
       end as PERIODO_LICENCA,
       resumo.diasUteisPeriodo as DIASUTEIS,
       (resumo.dataFinalPeriodo-resumo.dataInicialPeriodo+1) as DIASTOTALPERIODO,

       case when agrupa is not null then SUM(EH_DIA_UTIL_COMO_NUMERO) over (PARTITION BY AGRUPA, ANO, MES  ORDER BY AGRUPA) end as diasUteisPeriodoMES,

       case when (     (TO_CHAR(dataInicialPeriodo,'YYYYMM')  <> TO_CHAR(dataFinalPeriodo,'YYYYMM'))
                   and resumo.dataFinalPeriodo between ANO_MES_REFERENCIA  and (ADD_MONTHS(ANO_MES_REFERENCIA , 1)-1)
                 ) then
                   (resumo.dataFinalPeriodo-ANO_MES_REFERENCIA +1)
            when (     (TO_CHAR(dataInicialPeriodo,'YYYYMM')  <> TO_CHAR(dataFinalPeriodo,'YYYYMM'))
                   and resumo.dataInicialPeriodo between ANO_MES_REFERENCIA  and (ADD_MONTHS(ANO_MES_REFERENCIA , 1)-1)
                 ) then
                   ((ADD_MONTHS(ANO_MES_REFERENCIA , 1)-1) - resumo.dataInicialPeriodo + 1)
            when (     (TO_CHAR(dataInicialPeriodo,'YYYYMM')  <> TO_CHAR(dataFinalPeriodo,'YYYYMM'))
                   and resumo.dataInicialPeriodo not between ANO_MES_REFERENCIA  and (ADD_MONTHS(ANO_MES_REFERENCIA , 1)-1)
                   and resumo.dataFinalPeriodo not between ANO_MES_REFERENCIA  and (ADD_MONTHS(ANO_MES_REFERENCIA , 1)-1)
                 ) then
                   ((ADD_MONTHS(ANO_MES_REFERENCIA , 1)-1) - ANO_MES_REFERENCIA + 1)
            when (     (TO_CHAR(dataInicialPeriodo,'YYYYMM')  = TO_CHAR(dataFinalPeriodo,'YYYYMM'))
                 ) then
                   (resumo.dataFinalPeriodo - resumo.dataInicialPeriodo + 1)
       end as DIASTOTALPERIODOMES
from
(

select case when agrupa is not null then MIN(CUR_DATE) over (PARTITION BY AGRUPA  ORDER BY AGRUPA) end as dataInicialPeriodo,
       case when agrupa is not null then MAX(CUR_DATE) over (PARTITION BY AGRUPA  ORDER BY AGRUPA) end as dataFinalPeriodo,
       case when agrupa is not null then SUM(EH_DIA_UTIL_COMO_NUMERO) over (PARTITION BY AGRUPA  ORDER BY AGRUPA) end as diasUteisPeriodo,
       case when agrupa2 is not null then MIN(DT_ULT_ALTER_USUA) over (PARTITION BY AGRUPA2  ORDER BY AGRUPA2) end as dataInicialUltimaAlter,
       case when agrupa2 is not null then MAX(DT_ULT_ALTER_USUA) over (PARTITION BY AGRUPA2  ORDER BY AGRUPA2) end as dataFinalUltimaAlter,
       agrupamento_periodos.*
from
(
select case when periodo = 1 and LAG(periodo, 1, 0) OVER (ORDER BY CODIGO_CONTRATO, cur_date) in (0, 1) then CODIGO_CONTRATO || CODIGO_SITUACAO || TO_CHAR(cur_date-(grp+1), 'DD/MM/YYYY')
            when periodo = 0 then null
       end as AGRUPA,
       case when periodo = 1 and LAG(periodo, 1, 0) OVER (ORDER BY CODIGO_CONTRATO, cur_date, DT_ULT_ALTER_USUA) in (0, 1) then CODIGO_CONTRATO || CODIGO_SITUACAO || TO_CHAR(cur_date-(grp+1), 'DD/MM/YYYY')
            when periodo = 0 then null
       end as AGRUPA2,
       agrupamento.*
from(
select SUM(periodo) over (PARTITION BY CODIGO_SITUACAO, PERIODO  ORDER BY CODIGO_CONTRATO, cur_date) grp,
      teste.*
from
(
select case when data is not null then 1
            when data is null then 0
       end as periodo,
       rownum as linha,
       licencas_datas.*
  from
(
select * from
(
select datas_compiladas.*,
       (COUNT(datas_compiladas.DIA) over (PARTITION BY datas_compiladas.ANO, datas_compiladas.MES  ORDER BY datas_compiladas.ANO, datas_compiladas.MES)) QTDE_DIAS_MES,
       (SUM(datas_compiladas.EH_DIA_UTIL_COMO_NUMERO) over (PARTITION BY datas_compiladas.ANO, datas_compiladas.MES  ORDER BY datas_compiladas.ANO, datas_compiladas.MES )) QTDE_DIAS_UTEIS_MES
        from
(
select datas.*,
       case when SUBSTR(calendario_mes,TO_NUMBER(DIA),1) = 'F' then 'S' else 'N' end as eh_feriado,
       case when SUBSTR(calendario_mes,TO_NUMBER(DIA),1) = 'F' or eh_sabado_ou_domingo = 'S' then 'N' else 'S' end as eh_dia_util,
       case when SUBSTR(calendario_mes,TO_NUMBER(DIA),1) = 'F' or eh_sabado_ou_domingo = 'S' then '0' else '1' end as eh_dia_util_como_numero
 from
(select data_dia_a_dia.*,
       case when (TO_CHAR(data_dia_a_dia.cur_date, 'MM') = '01') then rhparm_calendario.janeiro
            when (TO_CHAR(data_dia_a_dia.cur_date, 'MM') = '02') then rhparm_calendario.fevereiro
            when (TO_CHAR(data_dia_a_dia.cur_date, 'MM') = '03') then rhparm_calendario.marco
            when (TO_CHAR(data_dia_a_dia.cur_date, 'MM') = '04') then rhparm_calendario.abril
            when (TO_CHAR(data_dia_a_dia.cur_date, 'MM') = '05') then rhparm_calendario.maio
            when (TO_CHAR(data_dia_a_dia.cur_date, 'MM') = '06') then rhparm_calendario.junho
            when (TO_CHAR(data_dia_a_dia.cur_date, 'MM') = '07') then rhparm_calendario.julho
            when (TO_CHAR(data_dia_a_dia.cur_date, 'MM') = '08') then rhparm_calendario.agosto
            when (TO_CHAR(data_dia_a_dia.cur_date, 'MM') = '09') then rhparm_calendario.setembro
            when (TO_CHAR(data_dia_a_dia.cur_date, 'MM') = '10') then rhparm_calendario.outubro
            when (TO_CHAR(data_dia_a_dia.cur_date, 'MM') = '11') then rhparm_calendario.novembro
            when (TO_CHAR(data_dia_a_dia.cur_date, 'MM') = '12') then rhparm_calendario.dezembro
       end as calendario_mes
from rhparm_calendario,
(SELECT TO_DATE('01' ||TO_CHAR(cur_date, 'MM') || TO_CHAR(cur_date, 'YYYY'),'DDMMYYYY') as ANO_MES_REFERENCIA, cur_date, TO_CHAR(cur_date, 'DD') as DIA, TO_CHAR(cur_date, 'MM') as MES, TO_CHAR(cur_date, 'YYYY') as ANO, case when TO_CHAR(cur_date, 'd') in (1,7) then 'S' else 'N' end as eh_sabado_ou_domingo
from(
--SELECT (ADD_MONTHS(to_date('01/12/2016','DD/MM/YYYY') , -12)) + level - 1 AS cur_date
--SELECT (ADD_MONTHS(to_date('17/03/2017','DD/MM/YYYY') , -1200)) + level - 1 AS cur_date
SELECT (ADD_MONTHS(vDATA_AFASTAMENTO_FINAL , -12)) + level - 1 AS cur_date
  FROM dual
  CONNECT BY level <= ( ADD_MONTHS(vDATA_AFASTAMENTO_FINAL , 13)) - ADD_MONTHS(vDATA_AFASTAMENTO_INICIAL , -12) + 1
--CONNECT BY level <= sysdate - to_date('01/01/1900','DD/MM/YYYY') + 1
--  CONNECT BY level <= ( ADD_MONTHS(to_date('01/12/2016','DD/MM/YYYY') , 13)) - ADD_MONTHS(to_date('01/12/2016','DD/MM/YYYY') , -12) + 1
)
) data_dia_a_dia
where TO_CHAR(rhparm_calendario.ano_referencia, 'YYYY') = TO_CHAR(data_dia_a_dia.cur_date, 'YYYY')
order by cur_date
) datas
order by cur_date
) datas_compiladas
)datas_rel,
(
select  rhpont_res_sit_dia.CODIGO_EMPRESA,
        rhpont_res_sit_dia.TIPO_CONTRATO,
        rhpont_res_sit_dia.CODIGO_CONTRATO,
        rhpont_res_sit_dia.DATA,
        rhpont_res_sit_dia.CODIGO_SITUACAO,
        rhpont_situacao.DESCRICAO as DESCRICAO_SITUACAO,
        rhpont_situacao.DESCRICAO as ABREVIACAO_SITUACAO,
        rhpont_res_sit_dia.DT_ULT_ALTER_USUA
  from rhpont_res_sit_dia, rhpont_situacao
where rhpont_res_sit_dia.tipo_apuracao = 'F'
  and rhpont_res_sit_dia.codigo_empresa = out_rec.CODIGO_EMPRESA
  and rhpont_res_sit_dia.tipo_contrato = out_rec.TIPO_CONTRATO
  and rhpont_res_sit_dia.CODIGO_CONTRATO = out_rec.CODIGO_CONTRATO
  --and rhpont_res_sit_dia.CODIGO_CONTRATO = '000000001090583'
  and rhpont_res_sit_dia.codigo_situacao in ('0020','0515','0516','0517','0518','0519','0522','0523',
                                             '0529','0531','0532','0533','0535','0538','0541','0542')
  and rhpont_res_sit_dia.CODIGO_SITUACAO = rhpont_situacao.CODIGO
  and rhpont_res_sit_dia.data >= vDATA_AFASTAMENTO_INICIAL
 order by rhpont_res_sit_dia.data
) licencas
where datas_rel.cur_date = licencas.data (+)
order by CODIGO_CONTRATO, cur_date
) licencas_datas
order by cur_date
) teste
order by cur_date
) agrupamento
order by cur_date
) agrupamento_periodos
order by cur_date
) resumo
where cur_date between vDATA_AFASTAMENTO_INICIAL  and (ADD_MONTHS(vDATA_AFASTAMENTO_FINAL, 1)-1)

order by periodo_licenca desc

) final
)
where CODIGO_SITUACAO IS NOT NULL
  and EH_FERIADO = 'N'
  and EH_SABADO_OU_DOMINGO = 'N'
  order by ANO, MES, DATAINICIALPERIODO
  )
  group by CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO_CONTRATO,
ANO,MES

)DIAS_LICENCAS /* FIM DIAS_LICENCAS */
  order by ANO, MES

)loop

     vCONTADOR_LICENCAS := vCONTADOR_LICENCAS + 1;

     IF vCONTADOR_LICENCAS = 1 and c3.TOTAL_DIAS_POR_CONTRATO > 0 THEN
        v_QTDE_TOTAL_LICENCAS := c3.TOTAL_DIAS_POR_CONTRATO;
     END IF;

          out_rec_licencas_detalhadas.codigo_empresa := c3.codigo_empresa;
          out_rec_licencas_detalhadas.tipo_contrato := c3.tipo_contrato;
          out_rec_licencas_detalhadas.codigo_contrato := c3.codigo_contrato;
          out_rec_licencas_detalhadas.ano := c3.ano;
          out_rec_licencas_detalhadas.mes := c3.mes;
          out_rec_licencas_detalhadas.afastamentos := c3.DIASUTEISPERIODOMES;
          out_rec_licencas_detalhadas.valor_recebido := 0;

          vMES_VALE_RECEBIDO_ANTE_AFAST := ADD_MONTHS(TO_DATE('01'||c3.mes||c3.ano,'DDMMYYYY'),-1);

       -- RECUPERA VALOR RECEBIDO PELO SERVIDOR REFERENTE À VALE REFEIÇÃO
        begin
    			select nvl(sum(rhmovi_movimento.valor_verba),0) valor
          into v_VALOR_VALE_RECEBIDO
    			from rhmovi_movimento
    		 where rhmovi_movimento.tipo_movimento = 'ME' and
               rhmovi_movimento.MODO_OPERACAO = 'R' and
               rhmovi_movimento.fase = '0' and
    		   rhmovi_movimento.ano_mes_referencia = vMES_VALE_RECEBIDO_ANTE_AFAST and
               rhmovi_movimento.codigo_verba = ('1074') and
               rhmovi_movimento.CODIGO_EMPRESA = out_rec.CODIGO_EMPRESA and
               rhmovi_movimento.TIPO_CONTRATO = out_rec.TIPO_CONTRATO and
    		   rhmovi_movimento.CODIGO_CONTRATO = out_rec.CODIGO_CONTRATO and
    		   rhmovi_movimento.valor_verba > 0
    			group by rhmovi_movimento.codigo_contrato,
    						rhmovi_movimento.codigo_empresa,
    						rhmovi_movimento.tipo_contrato;

          exception
          when others then
          v_VALOR_VALE_RECEBIDO := 0;
          end;

          out_rec_licencas_detalhadas.valor_recebido := v_VALOR_VALE_RECEBIDO;

          rel_tab_licencas_detalhadas.extend(1);
          rel_tab_licencas_detalhadas(rel_tab_licencas_detalhadas.last) := out_rec_licencas_detalhadas;

end loop;

      IF v_QTDE_TOTAL_LICENCAS > 0 THEN
       -- DESCONTO
    begin

			select nvl(max(decode(rhmovi_movimento.codigo_verba,'2374',rhmovi_movimento.contador,'0')),0) contador,
				   nvl(max(decode(rhmovi_movimento.codigo_verba,'2374',rhmovi_movimento.valor_verba,'0')),0) valor
      into v_DESCONTO_CONTADOR, v_DESCONTO_VALOR
			from rhmovi_movimento
		 where rhmovi_movimento.tipo_movimento = 'ME' and
           rhmovi_movimento.MODO_OPERACAO = 'R' and
           rhmovi_movimento.fase = '0' and
			rhmovi_movimento.ano_mes_referencia = to_date(vMES_FOLHA,'DD/MM/YYYY') and
           rhmovi_movimento.codigo_verba in ('2374') and
           rhmovi_movimento.CODIGO_EMPRESA = out_rec.CODIGO_EMPRESA and
           rhmovi_movimento.TIPO_CONTRATO = out_rec.TIPO_CONTRATO and
		   rhmovi_movimento.CODIGO_CONTRATO = out_rec.CODIGO_CONTRATO and
					 rhmovi_movimento.valor_verba > 0
			group by rhmovi_movimento.codigo_contrato,
						rhmovi_movimento.codigo_empresa,
						rhmovi_movimento.tipo_contrato;

/* AVALIAR QUESTAO 2G74
			select rhmovi_movimento.codigo_contrato,
				   rhmovi_movimento.codigo_empresa,
				   rhmovi_movimento.tipo_contrato,
                   CASE WHEN TO_CHAR(to_date('01/02/2017','DD/MM/YYYY'),'YYYY') > TO_CHAR(to_date('01/12/2016','DD/MM/YYYY'),'YYYY') THEN
                     nvl(max(decode(rhmovi_movimento.codigo_verba,'2G74',rhmovi_movimento.contador,'0')),0)
                   ELSE
                     nvl(max(decode(rhmovi_movimento.codigo_verba,'2374',rhmovi_movimento.contador,'0')),0)
                   END CONTADOR,
                   CASE WHEN TO_CHAR(to_date('01/02/2017','DD/MM/YYYY'),'YYYY') > TO_CHAR(to_date('01/12/2016','DD/MM/YYYY'),'YYYY') THEN
                     nvl(max(decode(rhmovi_movimento.codigo_verba,'2G74',rhmovi_movimento.valor_verba,'0')),0)
                   ELSE
                     nvl(max(decode(rhmovi_movimento.codigo_verba,'2374',rhmovi_movimento.valor_verba,'0')),0)
                   END VALOR
			from rhmovi_movimento
		 where rhmovi_movimento.tipo_movimento = 'ME' and
           rhmovi_movimento.MODO_OPERACAO = 'R' and
           rhmovi_movimento.fase = '0' and
			rhmovi_movimento.ano_mes_referencia = to_date('01/02/2017','DD/MM/YYYY') and
           rhmovi_movimento.codigo_verba in ('2374', '2G74') and
           rhmovi_movimento.CODIGO_EMPRESA = '0001' and
           rhmovi_movimento.TIPO_CONTRATO = '0001' and
		   rhmovi_movimento.CODIGO_CONTRATO = '00000000038855X' and
					 rhmovi_movimento.valor_verba > 0
			group by rhmovi_movimento.codigo_contrato,
						rhmovi_movimento.codigo_empresa,
						rhmovi_movimento.tipo_contrato
*/


      exception
      when others then
      v_DESCONTO_CONTADOR := 0;
      v_DESCONTO_VALOR := 0;

      end;

       -- VENCIMENTO
    begin
			select nvl(sum(rhmovi_movimento.valor_verba),0) valor
      into v_VENCIMENTO
			from rhmovi_movimento
		 where rhmovi_movimento.tipo_movimento = 'ME' and
           rhmovi_movimento.MODO_OPERACAO = 'R' and
           rhmovi_movimento.fase = '0' and
		   rhmovi_movimento.ano_mes_referencia = (select max(ANO_MES_REFERENCIA)
                                                   from RHMOVI_MOVIMENTO MOV
                                                  where MOV.CODIGO_EMPRESA = rhmovi_movimento.CODIGO_EMPRESA
                                                    and MOV.TIPO_CONTRATO = rhmovi_movimento.TIPO_CONTRATO
                                                    and MOV.CODIGO_CONTRATO = rhmovi_movimento.CODIGO_CONTRATO
                                                    and MOV.FASE = rhmovi_movimento.FASE
                                                    and MOV.TIPO_MOVIMENTO = rhmovi_movimento.TIPO_MOVIMENTO
                                                    and MOV.MODO_OPERACAO = rhmovi_movimento.MODO_OPERACAO
                                                    and MOV.CODIGO_VERBA = rhmovi_movimento.codigo_verba
                                                    and MOV.ANO_MES_REFERENCIA <= to_date(vMES_FOLHA,'DD/MM/YYYY')
                                                ) and
           rhmovi_movimento.codigo_verba in ('1001','100I','1015','101V','102G',
                                             '105G','1095','1200','1220','1225',
                                             '1229','1230','1255','1260','1270') and
           rhmovi_movimento.CODIGO_EMPRESA = out_rec.CODIGO_EMPRESA and
           rhmovi_movimento.TIPO_CONTRATO = out_rec.TIPO_CONTRATO and
		   rhmovi_movimento.CODIGO_CONTRATO = out_rec.CODIGO_CONTRATO and
		   rhmovi_movimento.valor_verba > 0
			group by rhmovi_movimento.codigo_contrato,
						rhmovi_movimento.codigo_empresa,
						rhmovi_movimento.tipo_contrato;

      exception
      when others then
      v_VENCIMENTO := 0;
      end;

      -- VALE
      begin
      SELECT /*CODIGO_EMPRESA,
TIPO_CONTRATO,
CODIGO_CONTRATO,
TIPO_VALE,
VALE1,
VALOR_TARIFA_VALE1,
QTDE_VALES_TARIFA_VALE1,
VALE2,
VALOR_TARIFA_VALE2,
QTDE_VALES_TARIFA_VALE2,
VALE3,
VALOR_TARIFA_VALE3,
QTDE_VALES_TARIFA_VALE3,
VALE4,
VALOR_TARIFA_VALE4,
QTDE_VALES_TARIFA_VALE4,
VALE_EXTRA1,
VALOR_TARIFA_VALE_EXTRA1,
QTDE_VALES_TARIFA_VALE_EXTRA1,
VALE_EXTRA2,
VALOR_TARIFA_VALE_EXTRA2,
QTDE_VALES_TARIFA_VALE_EXTRA2,
VALE_EXTRA3,
VALOR_TARIFA_VALE_EXTRA3,
QTDE_VALES_TARIFA_VALE_EXTRA3,
VALE_EXTRA4,
VALOR_TARIFA_VALE_EXTRA4,
QTDE_VALES_TARIFA_VALE_EXTRA4,
LISTA_VALES,
LISTA_VALES_EXTRAS,
QTDE_VALES_POR_DIA,*/
QTDE_VALES_POR_DIA,
VALOR_VALES_POR_DIA 
into v_QUANTIDADE_VALE_POR_DIA, 
     v_VALOR_VALE_POR_DIA
from
  /* INICIO VALES_1 */
(       
select VALES.*,
       case when (qtde_vales_tarifa_vale1 > 0) then (qtde_vales_tarifa_vale1 || ' X ' || vale1) end ||
       case when (qtde_vales_tarifa_vale2 > 0) then '  ;  ' || (qtde_vales_tarifa_vale2 || ' X ' || vale2) end || 
       case when (qtde_vales_tarifa_vale3 > 0) then '  ;  ' || (qtde_vales_tarifa_vale3 || ' X ' || vale3) end || 
       case when (qtde_vales_tarifa_vale4 > 0) then '  ;  ' || (qtde_vales_tarifa_vale4 || ' X ' || vale4) end
       as lista_vales, 
       case when (qtde_vales_tarifa_vale_extra1 > 0) then (qtde_vales_tarifa_vale_extra1 || ' X ' || vale_extra1) end ||
       case when (qtde_vales_tarifa_vale_extra2 > 0) then '  ;  ' || (qtde_vales_tarifa_vale_extra2 || ' X ' || vale_extra2) end || 
       case when (qtde_vales_tarifa_vale_extra3 > 0) then '  ;  ' || (qtde_vales_tarifa_vale_extra3 || ' X ' || vale_extra3) end || 
       case when (qtde_vales_tarifa_vale_extra4 > 0) then '  ;  ' || (qtde_vales_tarifa_vale_extra4 || ' X ' || vale_extra4) end
       as lista_vales_extras,  
       NVL(qtde_vales_tarifa_vale1,0) + 
       NVL(qtde_vales_tarifa_vale2,0) + 
       NVL(qtde_vales_tarifa_vale3,0) + 
       NVL(qtde_vales_tarifa_vale4,0) + 
       NVL(qtde_vales_tarifa_vale_extra1,0) + 
       NVL(qtde_vales_tarifa_vale_extra2,0) + 
       NVL(qtde_vales_tarifa_vale_extra3,0) + 
       NVL(qtde_vales_tarifa_vale_extra4,0) as QTDE_VALES_POR_DIA,
       NVL(qtde_vales_tarifa_vale1,0) * NVL(valor_tarifa_vale1,0) + 
       NVL(qtde_vales_tarifa_vale2,0) * NVL(valor_tarifa_vale2,0) + 
       NVL(qtde_vales_tarifa_vale3,0) * NVL(valor_tarifa_vale3,0) + 
       NVL(qtde_vales_tarifa_vale4,0) * NVL(valor_tarifa_vale4,0) + 
       NVL(qtde_vales_tarifa_vale_extra1,0) * NVL(valor_tarifa_vale_extra1,0) + 
       NVL(qtde_vales_tarifa_vale_extra2,0) * NVL(valor_tarifa_vale_extra2,0) + 
       NVL(qtde_vales_tarifa_vale_extra3,0) * NVL(valor_tarifa_vale_extra3,0) + 
       NVL(qtde_vales_tarifa_vale_extra4,0) * NVL(valor_tarifa_vale_extra4,0) as VALOR_VALES_POR_DIA
  from
/* INICIO VALES */
(
select 
     CODIGO_CONTRATO,
     TIPO_CONTRATO,
     CODIGO_EMPRESA,
     TIPO_VALE, 
     MAX(DECODE(tipo||sequencia,'NORMAL1',codigo_tarifa,0)) vale1,
     MAX(DECODE(tipo||sequencia,'NORMAL1',valor_total,0)) valor_tarifa_vale1,
     MAX(DECODE(tipo||sequencia,'NORMAL1',qtde_vales,0)) qtde_vales_tarifa_vale1,
     MAX(DECODE(tipo||sequencia,'NORMAL2',codigo_tarifa,0)) vale2,
     MAX(DECODE(tipo||sequencia,'NORMAL2',valor_total,0)) valor_tarifa_vale2,
     MAX(DECODE(tipo||sequencia,'NORMAL2',qtde_vales,0)) qtde_vales_tarifa_vale2,
     MAX(DECODE(tipo||sequencia,'NORMAL3',codigo_tarifa,0)) vale3,
     MAX(DECODE(tipo||sequencia,'NORMAL3',valor_total,0)) valor_tarifa_vale3,
     MAX(DECODE(tipo||sequencia,'NORMAL3',qtde_vales,0)) qtde_vales_tarifa_vale3,
     MAX(DECODE(tipo||sequencia,'NORMAL4',codigo_tarifa,0)) vale4,
     MAX(DECODE(tipo||sequencia,'NORMAL4',valor_total,0)) valor_tarifa_vale4,
     MAX(DECODE(tipo||sequencia,'NORMAL4',qtde_vales,0)) qtde_vales_tarifa_vale4,
     
     MAX(DECODE(tipo||sequencia,'EXTRA1',codigo_tarifa,0)) vale_extra1,
     MAX(DECODE(tipo||sequencia,'EXTRA1',valor_total,0)) valor_tarifa_vale_extra1,
     MAX(DECODE(tipo||sequencia,'EXTRA1',qtde_vales,0)) qtde_vales_tarifa_vale_extra1,
     MAX(DECODE(tipo||sequencia,'EXTRA2',codigo_tarifa,0)) vale_extra2,
     MAX(DECODE(tipo||sequencia,'EXTRA2',valor_total,0)) valor_tarifa_vale_extra2,
     MAX(DECODE(tipo||sequencia,'EXTRA2',qtde_vales,0)) qtde_vales_tarifa_vale_extra2,
     MAX(DECODE(tipo||sequencia,'EXTRA3',codigo_tarifa,0)) vale_extra3,
     MAX(DECODE(tipo||sequencia,'EXTRA3',valor_total,0)) valor_tarifa_vale_extra3,
     MAX(DECODE(tipo||sequencia,'EXTRA3',qtde_vales,0)) qtde_vales_tarifa_vale_extra3,
     MAX(DECODE(tipo||sequencia,'EXTRA4',codigo_tarifa,0)) vale_extra4,
     MAX(DECODE(tipo||sequencia,'EXTRA4',valor_total,0)) valor_tarifa_vale_extra4,
     MAX(DECODE(tipo||sequencia,'EXTRA4',qtde_vales,0)) qtde_vales_tarifa_vale_extra4                
from
(

select * from VW_VALES
 where CODIGO_EMPRESA = out_rec.CODIGO_EMPRESA
   and TIPO_CONTRATO = out_rec.TIPO_CONTRATO
   and CODIGO_CONTRATO = out_rec.CODIGO_CONTRATO
   and TIPO_VALE = '0002'
   and (
             (DATA_INI_VIGENCIA IS NULL OR DATA_INI_VIGENCIA <= to_date(vMES_FOLHA,'DD/MM/YYYY'))
         and (DATA_FIM_VIGENCIA IS NULL OR DATA_FIM_VIGENCIA >= to_date(vMES_FOLHA,'DD/MM/YYYY'))
       )
)
group by CODIGO_CONTRATO,
     TIPO_CONTRATO,
     CODIGO_EMPRESA,
     TIPO_VALE  
) VALES
);
      exception
      when others then
      v_VENCIMENTO := 0;
      end;
      
      IF v_VALOR_VALE IS NULL OR v_VALOR_VALE = 0 THEN
         v_VALOR_VALE_POR_DIA := v_VALOR_VALE_POR_DIA;
      ELSE
         v_VALOR_VALE_POR_DIA := v_VALOR_VALE;
      END IF;
      
      out_rec.qtde_afastamentos := v_QTDE_TOTAL_LICENCAS;
      out_rec.total_vencimento := v_VENCIMENTO;
      out_rec.total_descontos_existentes   := v_DESCONTO_VALOR * v_DESCONTO_CONTADOR;
      rel_tab(i) := out_rec_rel_vr;


   vQUANTIDADE_LICENCAS := 0;
   vQUANTIDADE_LICENCAS_DESCONTO := 0;
   FOR i in 1..rel_tab_licencas_detalhadas.count LOOP

       out_rec_licencas_detalhadas := rel_tab_licencas_detalhadas(i);

       vQUANTIDADE_LICENCAS := vQUANTIDADE_LICENCAS + out_rec_licencas_detalhadas.afastamentos;

       IF out_rec_licencas_detalhadas.afastamentos > 0 and out_rec_licencas_detalhadas.valor_recebido > 0 THEN
           vQUANTIDADE_LICENCAS_DESCONTO := vQUANTIDADE_LICENCAS_DESCONTO + out_rec_licencas_detalhadas.afastamentos;
       END IF;

       --dbms_output.put_line(out_rec_licencas_detalhadas.ano || out_rec_licencas_detalhadas.mes || out_rec_licencas_detalhadas.afastamentos|| 'VALOR = ' || out_rec_licencas_detalhadas.valor_recebido);

       IF vDETALHAR='S' THEN

          out_rec_rel_vr.data_referencia_folha           := vDATA_FOLHA;
          out_rec_rel_vr.data_inicial_afastamento        := vDATA_AFASTAMENTO_INICIAL;
          out_rec_rel_vr.data_final_afastamento          := vDATA_AFASTAMENTO_FINAL;
          out_rec_rel_vr.codigo_empresa                  := out_rec.codigo_empresa;
          out_rec_rel_vr.tipo_contrato                   := out_rec.tipo_contrato;
          out_rec_rel_vr.codigo_contrato                 := out_rec.codigo_contrato;
          out_rec_rel_vr.nome                            := out_rec.nome;
          out_rec_rel_vr.codigo_unidade                  := out_rec.codigo_unidade;
          out_rec_rel_vr.descricao_unidade               := out_rec.descricao_unidade;
          out_rec_rel_vr.qtde_afastamentos               := out_rec_licencas_detalhadas.afastamentos;
          out_rec_rel_vr.total_descontos_existentes      := v_DESCONTO_VALOR * v_DESCONTO_CONTADOR;
          out_rec_rel_vr.total_vencimento                := v_VENCIMENTO;
          out_rec_rel_vr.quantidade_vales_por_dia        := v_QUANTIDADE_VALE_POR_DIA;
          out_rec_rel_vr.valor_vales_por_dia             := v_VALOR_VALE_POR_DIA;
          out_rec_rel_vr.ano                             := out_rec_licencas_detalhadas.ano;
          out_rec_rel_vr.mes                             := out_rec_licencas_detalhadas.mes;
          out_rec_rel_vr.total_valor_recebido_vale       := out_rec_licencas_detalhadas.valor_recebido;

          rel_tab_rel_vr.extend(1);
          rel_tab_rel_vr(rel_tab_rel_vr.last) := out_rec_rel_vr;

        END IF;
   END LOOP;

   IF vDETALHAR='N' THEN

          out_rec_rel_vr.data_referencia_folha           := vDATA_FOLHA;
          out_rec_rel_vr.data_inicial_afastamento        := vDATA_AFASTAMENTO_INICIAL;
          out_rec_rel_vr.data_final_afastamento          := vDATA_AFASTAMENTO_FINAL;
          out_rec_rel_vr.codigo_empresa                  := out_rec.codigo_empresa;
          out_rec_rel_vr.tipo_contrato                   := out_rec.tipo_contrato;
          out_rec_rel_vr.codigo_contrato                 := out_rec.codigo_contrato;
          out_rec_rel_vr.nome                            := out_rec.nome;
          out_rec_rel_vr.codigo_unidade                  := out_rec.codigo_unidade;
          out_rec_rel_vr.descricao_unidade               := out_rec.descricao_unidade;
          out_rec_rel_vr.qtde_afastamentos               := vQUANTIDADE_LICENCAS_DESCONTO;
          out_rec_rel_vr.total_descontos_existentes      := v_DESCONTO_VALOR * v_DESCONTO_CONTADOR;
          out_rec_rel_vr.total_vencimento                := v_VENCIMENTO;
          out_rec_rel_vr.quantidade_vales_por_dia        := v_QUANTIDADE_VALE_POR_DIA;
          out_rec_rel_vr.valor_vales_por_dia             := v_VALOR_VALE_POR_DIA;          
          out_rec_rel_vr.ano                             := null;
          out_rec_rel_vr.mes                             := null;          
          out_rec_rel_vr.total_valor_recebido_vale       := null;

          rel_tab_rel_vr.extend(1);
          rel_tab_rel_vr(rel_tab_rel_vr.last) := out_rec_rel_vr;
   END IF;

      END IF;

   END LOOP;

  FOR i in 1..rel_tab_rel_vr.count LOOP
     PIPE ROW(rel_tab_rel_vr(i));
  END LOOP;

  RETURN;
END;
 