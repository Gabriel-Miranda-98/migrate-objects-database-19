
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_CALENDARIO_ARTERH" ("ANO_MES_REFERENCIA", "CUR_DATE", "DIA", "MES", "ANO", "EH_SABADO_OU_DOMINGO", "CALENDARIO_MES", "EH_FERIADO", "EH_DIA_UTIL", "EH_DIA_UTIL_COMO_NUMERO", "QTDE_DIAS_MES", "QTDE_DIAS_UTEIS_MES") AS 
  select "ANO_MES_REFERENCIA","CUR_DATE","DIA","MES","ANO","EH_SABADO_OU_DOMINGO","CALENDARIO_MES","EH_FERIADO","EH_DIA_UTIL","EH_DIA_UTIL_COMO_NUMERO","QTDE_DIAS_MES","QTDE_DIAS_UTEIS_MES" from
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
SELECT ((select MIN(ANO_REFERENCIA) from RHPARM_CALENDARIO)) + level - 1 AS cur_date
  FROM dual
CONNECT BY level <= (select (ADD_MONTHS(MAX(ANO_REFERENCIA),12)-1) - MIN(ANO_REFERENCIA) from RHPARM_CALENDARIO)
)
) data_dia_a_dia
where TO_CHAR(rhparm_calendario.ano_referencia, 'YYYY') = TO_CHAR(data_dia_a_dia.cur_date, 'YYYY')
order by cur_date
) datas
order by cur_date
) datas_compiladas
)datas_rel
 