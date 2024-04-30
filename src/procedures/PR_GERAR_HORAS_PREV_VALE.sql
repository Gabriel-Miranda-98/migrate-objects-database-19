
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_GERAR_HORAS_PREV_VALE" (data_ini_frequencia IN DATE, DATA_FIM_FREQUECIA IN DATE) AS 
cont number:=0;
NRO_DIA_DIA_MES NUMBER:=to_date(DATA_FIM_FREQUECIA,'dd/mm/yyyy')-to_date(data_ini_frequencia,'dd/mm/yyyy');
V_REF_SIT_PONTO arterh.rhpont_res_sit_dia%rowtype;

PROCEDURE INSERT_VALUES_RHPONT_RES_SIT_DIA(VAR arterh.rhpont_res_sit_dia%rowtype)AS
BEGIN 
INSERT INTO  arterh.rhpont_res_sit_dia VALUES VAR;
COMMIT;
 exception
       when others then
         DBMS_Output.PUT_LINE('CODIGO ERRO: '||SQLCODE||' DESCRICAO ERRO: ' ||SUBSTR(SQLERRM, 1, 4000));
       end;


BEGIN
dbms_output.enable(buffer_size => NULL);
/* CAMPOS DEFAULT DO INSERT*/
V_REF_SIT_PONTO.REF_HORAS_NOVA_SIT:=0;
V_REF_SIT_PONTO.LOGIN_USUARIO:='PR_GERAR_HORAS_PREV_VALE';
V_REF_SIT_PONTO.TIPO_APURACAO:='V';
V_REF_SIT_PONTO.CODIGO_SITUACAO:='1036';
V_REF_SIT_PONTO.DT_ULT_ALTER_USUA:=sysdate;
/*--------------*/



for c1 in (
    SELECT 'IFPONTO' AS PUBLICO,REG.CODIGO_EMPRESA, REG.TIPO_CONTRATO,REG.CODIGO_CONTRATO
    FROM ARTERH.rhvale_rl_desl_lin REG
    INNER JOIN ARTERH.RHPESS_CONTRATO C
    ON REG.CODIGO_EMPRESA=C.CODIGO_EMPRESA
    AND REG.TIPO_CONTRATO=C.TIPO_CONTRATO
    AND reg.codigo_contrato=C.codigo
    WHERE CODIGO_LINHA='000000000000142'
    AND C.ANO_MES_REFERENCIA=(SELECT MAX(AUX.ANO_MES_REFERENCIA) FROM ARTERH.RHPESS_CONTRATO AUX
    WHERE AUX.CODIGO=C.CODIGO
    AND AUX.TIPO_CONTRATO=C.TIPO_CONTRATO
    AND AUX.CODIGO_EMPRESA=C.CODIGO_EMPRESA)
    AND c.registro_ponto NOT IN ('0110','0160')
    and c.codigo in ('00000000017679X', '000000000394746','000000000470361','000000000806033','000000000976273','000000001038700') 

    GROUP BY REG.CODIGO_EMPRESA,REG.TIPO_CONTRATO,REG.CODIGO_CONTRATO
    UNION ALL 
    SELECT 'MANUAL' AS PUBLICO,REG.CODIGO_EMPRESA, REG.TIPO_CONTRATO,REG.CODIGO_CONTRATO
    FROM ARTERH.rhvale_rl_desl_lin REG
    INNER JOIN ARTERH.RHPESS_CONTRATO C
    ON REG.CODIGO_EMPRESA=C.CODIGO_EMPRESA
    AND REG.TIPO_CONTRATO=C.TIPO_CONTRATO
    AND reg.codigo_contrato=C.codigo
    WHERE CODIGO_LINHA='000000000000142'
    AND C.ANO_MES_REFERENCIA=(SELECT MAX(AUX.ANO_MES_REFERENCIA) FROM ARTERH.RHPESS_CONTRATO AUX
    WHERE AUX.CODIGO=C.CODIGO
    AND AUX.TIPO_CONTRATO=C.TIPO_CONTRATO
    AND AUX.CODIGO_EMPRESA=C.CODIGO_EMPRESA)
    AND c.registro_ponto  IN ('0110','0160')
    and c.codigo in ('00000000017679X', '000000000394746','000000000470361','000000000806033','000000000976273','000000001038700') 

    GROUP BY REG.CODIGO_EMPRESA,REG.TIPO_CONTRATO,REG.CODIGO_CONTRATO
)loop
cont:=cont+1;

IF C1.PUBLICO='IFPONTO' THEN 

    FOR C2 IN (
        select x.* from (select  
        lpad(trim(empresa),4,0) as codigo_empresa,
        tipo_contrato,
        lpad(matricula,15,0) as codigo_contrato,
        TO_DATE(TRUNC(X.DATA),'DD/MM/YYYY') AS DATA,
        'V' as TIPO_APURACAO,
        X.previsto
        from PONTO_ELETRONICO.IFPONTO_ESPELHO_historica x 
        where  X.SITUACAO=X.TIPO_FOLGA
        AND X.SITUACAO='TRABALHANDO'
        and lpad(trim(empresa),4,0)=c1.codigo_empresa
        and x.tipo_contrato=c1.tipo_contrato
        and lpad(matricula,15,0)=c1.codigo_contrato
        and TO_DATE(TRUNC(X.DATA),'DD/MM/YYYY') between to_date(data_ini_frequencia,'dd/mm/yyyy') and to_date(DATA_FIM_FREQUECIA,'dd/mm/yyyy')
        --and lpad(matricula,15,0) in ('00000000017679X', '000000000394746','000000000470361','000000000806033','000000000976273','000000001038700') 
        )x
        order by x.data desc
    )LOOP
    
        V_REF_SIT_PONTO.CODIGO_EMPRESA:=C2.CODIGO_EMPRESA;
        V_REF_SIT_PONTO.TIPO_CONTRATO:=C2.TIPO_CONTRATO;
        V_REF_SIT_PONTO.CODIGO_CONTRATO:=C2.CODIGO_CONTRATO;
        V_REF_SIT_PONTO.DATA:=C2.DATA;
        V_REF_SIT_PONTO.REF_HORAS:=C2.previsto;
        
        INSERT_VALUES_RHPONT_RES_SIT_DIA(V_REF_SIT_PONTO);
    
        dbms_output.put_line('dia: '||c2.data||' tipo_apuracao: '||c2.tipo_apuracao||' codigo sit ponto: ' ||'1036'||'horas: '||c2.previsto);
        END LOOP;

ELSE 

FOR I IN 0..NRO_DIA_DIA_MES
loop
V_REF_SIT_PONTO.DATA:=to_date(data_ini_frequencia+I,'dd/mm/yyyy');
dbms_output.put_line('dia: '||to_date(data_ini_frequencia+I,'dd/mm/yyyy'));
--dbms_output.put_line('dia: '||c2.data||' tipo_apuracao: '||c2.tipo_apuracao||' codigo sit ponto: ' ||'1036'||'horas: '||c2.previsto);
begin

SELECT FIM_MANUAL.CODIGO_EMPRESA,FIM_MANUAL.TIPO_CONTRATO,FIM_MANUAL.CODIGO_CONTRATO,FIM_MANUAL.HORAS_PREVISTAS
INTO V_REF_SIT_PONTO.CODIGO_EMPRESA,V_REF_SIT_PONTO.TIPO_CONTRATO,V_REF_SIT_PONTO.CODIGO_CONTRATO,V_REF_SIT_PONTO.REF_HORAS

FROM (select x.*,

h.codigo as codigo_horario,
h.tipo_horario,

case when substr(H.jornada_diaria,3,2) ='00' then LTRIM(substr(H.jornada_diaria,0,2),0) else LTRIM(substr(H.jornada_diaria,0,2),0)||'.'||substr(H.jornada_diaria,3,2) end as horas_previstas  from (SELECT alt.CODIGO_EMPRESA,
alt.TIPO_CONTRATO,
alt.CODIGO_CONTRATO, 
alt.COD_ESCALA,
alt.DT_INICIO_TROCA, 
alt.DT_FIM_TROCA,
el.data_base,
(select count(1)quant from arterh.RHPONT_RL_ESC_HOR el_hr where el_hr.codigo_empresa=alt.codigo_empresa and el_hr.codigo_escala=alt.COD_ESCALA) as total_escala_horario
FROM ARTERH.rhpont_alt_escala ALT
left outer join arterh.rhpont_escala el
on el.codigo_empresa=alt.codigo_empresa
and el.codigo=alt.COD_ESCALA
WHERE alt.CODIGO_EMPRESA=C1.CODIGO_EMPRESA
AND alt.TIPO_CONTRATO=C1.TIPO_CONTRATO
AND alt.CODIGO_CONTRATO=C1.CODIGO_CONTRATO
and (to_date(data_ini_frequencia+I,'dd/mm/yyyy') between alt.dt_inicio_troca and alt.dt_fim_troca 
or 
to_date(data_ini_frequencia+I,'dd/mm/yyyy') >=alt.dt_inicio_troca and alt.dt_fim_troca is null
)
ORDER BY alt.CODIGO_CONTRATO DESC
)x
left outer join arterh.RHPONT_RL_ESC_HOR hr
on hr.codigo_empresa=x.codigo_empresa
and hr.codigo_escala=x.COD_ESCALA
and hr.ocorrencia= mod(to_date('01/06/2023','dd/mm/yyyy')-data_base,total_escala_horario)
left outer join arterh.rhpont_horario h
on h.codigo_empresa=hr.codigo_empresa
and h.codigo=hr.codigo_HORARIO
where h.tipo_horario in ('T','N')
)FIM_MANUAL;
 exception
       when others then
         DBMS_Output.PUT_LINE('erro registro manual CODIGO ERRO: '||SQLCODE||' DESCRICAO ERRO: ' ||SUBSTR(SQLERRM, 1, 4000)||' codigo_empresa: '||V_REF_SIT_PONTO.CODIGO_EMPRESA||'tipo_contrato: '||V_REF_SIT_PONTO.TIPO_CONTRATO||'codigo_contrato: '||V_REF_SIT_PONTO.CODIGO_CONTRATO);
       end;
INSERT_VALUES_RHPONT_RES_SIT_DIA(V_REF_SIT_PONTO);
 END LOOP;
END if;
end loop;
end;