
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PRSUGESP_SANEAMENTO_PLANIL_LOG" (EMPRESA IN VARCHAR2, TIPO_CONTRATO IN VARCHAR2, BM IN VARCHAR2)  AS 
--KELLYSSON 9/1/20
--EM 25/2/21 TROQUEI: data_efetivo_exerc PARA: data_admissao
BEGIN-- 1Ã‚Âº BEGIN

declare
data_inicial date;
data_final date;
num_dias number;
vDATA_DIA date;
vCONTADOR NUMBER (10);
vCONTADOR2 NUMBER (10);
vPRIMEIRA_DT_FUNC DATE;--NOVO EM 2/5/22

vEMPRESA VARCHAR2(4);
vTIPO_CONTRATO VARCHAR2(4);
vBM VARCHAR2(15);

vDATA_CORTE DATE;

begin
dbms_output.enable(null);
vCONTADOR :=0;
vCONTADOR2 :=0;

vEMPRESA := EMPRESA;--EMPRESA;--'0001';--
vTIPO_CONTRATO := TIPO_CONTRATO;--TIPO_CONTRATO ;--'0001';--
vBM := BM;--'000000000190830'; --BM;--'000000000170171'; -- 

vDATA_CORTE := TRUNC(SYSDATE);

/*--COMENTADO EM 20/7/21 FIXANDO A VARIAVEL vDATA_CORTE com SYSDATE
SELECT S.DATA_CORTE_SIT_FUNC_PONTO INTO vDATA_CORTE FROM  SUGESP_SANEAMENTO_CONTRATOS S WHERE S.DATA_INI_SIT_FUNC_PONTO IS NOT NULL AND S.DATA_FIM_SIT_FUNC_PONTO IS NULL
AND S.CODIGO_EMPRESA  = vEMPRESA--'0001'-- 
AND S.TIPO_CONTRATO =  vTIPO_CONTRATO--'0001'--
AND CODIGO_CONTRATO = vBM ;--'000000000170171';--
*/
----------------------------------------------------------------1Âº PARTE - limpa a tabela do lote anterior processado----------------------------------------------------------------------------------------------------------
delete SUGESP_SANEAMENTO_PLANILHA_LOG WHERE ID <> 1; commit;



----------------------------------------------------------------2Âº PARTE - popula tabela com o lote atual-----------------------------------------------------------------------------------------------------------------

--NOVO--INICIO---EM 2/5/22
SELECT  MIN(DATA_INIC_SITUACAO)
INTO vPRIMEIRA_DT_FUNC
FROM RHCGED_ALT_SIT_FUN
WHERE CODIGO_EMPRESA = vEMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO = vBM;

--NOVO--FIM---EM 2/5/22


for c1 in(


select 
case when to_date(data_admissao_to_char,'dd/mm/yyyy') <= to_date('30/12/1999','dd/mm/yyyy') then 'antes 2000' else 'depois 2000' end to_char_milenio,
case when to_date(data_admissao_to_date,'dd/mm/yyyy') <= to_date('30/12/1999','dd/mm/yyyy') then 'antes 2000' else 'depois 2000' end to_date_milenio,
x.* from(
select a.codigo_empresa, a.tipo_contrato, a.CODIGO, a.nome
,to_char(a.data_admissao,'DD/MM/yyYY')data_admissao_to_char
,to_date(a.data_admissao,'DD/MM/yyYY')data_admissao_to_date

from 
RHPESS_CONTRATO A 
WHERE 
A.ANO_MES_REFERENCIA = (select max(AUX.ano_mes_referencia) from rhpess_contrato AUX 
where AUX.codigo_empresa = A.codigo_empresa and AUX.tipo_contrato = A.tipo_contrato and AUX.codigo = A.codigo) 

and
--/* --------------------------------INICIO ---------------------PARA TESTES DE BMS
EXISTS
(
select S.* from SUGESP_SANEAMENTO_CONTRATOS S WHERE S.DATA_INI_SIT_FUNC_PONTO IS NOT NULL AND S.DATA_FIM_SIT_FUNC_PONTO IS NULL
AND S.CODIGO_EMPRESA = a.CODIGO_EMPRESA AND S.TIPO_CONTRATO = a.TIPO_CONTRATO AND S.CODIGO_CONTRATO = a.CODIGO

AND S.CODIGO_EMPRESA  =  vEMPRESA --'0001'-- vEMPRESA --'0001'--
AND S.TIPO_CONTRATO =  vTIPO_CONTRATO--'0001'-- vTIPO_CONTRATO--'0001'-- 
AND CODIGO_CONTRATO = vBM --'000000000190830' -- vBM -- '000000000170171' --
)
--*/--------------------------------FIM--------------------- PARA TESTES DE BMS

order by codigo
)x


)
loop
--dbms_output.put_line('O_QUE_FAZER | CODIGO_EMPRESA | TIPO_CONTRATO | CODIGO_CONTRATO | ORIGEM | COD_SIT_FUNC | SITUACAO_FUNCIONAL | COD_SIT_PONTO | SITUACAO_PONTO | DATA_INICIO | DATA_FIM | DATA_DOM | INFO_ONUS | CNPJ_CESSIONARIO | DT_AFAST_DESLIG | CONCEDIDO_ATE | USUARIO | DATA_SANEAMENTO | TEXTO_ASSOCIADO');
--INSERT INTO SUGESP_SANEAMENTO_PLANILHA_LOG VALUES ((SELECT MAX(ID)+1 FROM SUGESP_SANEAMENTO_PLANILHA_LOG),'O_QUE_FAZER|CODIGO_EMPRESA|TIPO_CONTRATO|CODIGO_CONTRATO|ORIGEM|COD_SIT_FUNC|SITUACAO_FUNCIONAL|COD_SIT_PONTO|SITUACAO_PONTO|DATA_INICIO|DATA_FIM|DATA_DOM|INFO_ONUS|CNPJ_CESSIONARIO|DT_AFAST_DESLIG|CONCEDIDO_ATE|TEXTO_ASSOCIADO|USUARIO|DATA_SANEAMENTO');COMMIT;

--dbms_output.put_line( 'DADOS DA PESSOA');
INSERT INTO SUGESP_SANEAMENTO_PLANILHA_LOG VALUES ((SELECT MAX(ID)+1 FROM SUGESP_SANEAMENTO_PLANILHA_LOG),'DADOS DA PESSOA');COMMIT;
dbms_output.put_line( 'CODIGO EMPRESA: ' || c1.codigo_empresa ||' TIPO CONTRATO: '|| c1.tipo_contrato ||' CODIGO CONTRATO: '|| c1.codigo||' NOME: '||C1.NOME||' DATA ADMISSAO: '|| c1.data_admissao_to_char ||' DATA CORTE: '|| vDATA_CORTE);
INSERT INTO SUGESP_SANEAMENTO_PLANILHA_LOG VALUES ((SELECT MAX(ID)+1 FROM SUGESP_SANEAMENTO_PLANILHA_LOG),'CODIGO EMPRESA: ' || c1.codigo_empresa ||' TIPO CONTRATO: '|| c1.tipo_contrato ||' CODIGO CONTRATO: '|| c1.codigo||' NOME: '||C1.NOME||' DATA ADMISSAO: '|| c1.data_admissao_to_char ||' DATA CORTE: '|| vDATA_CORTE
);COMMIT;


--POPULAR VARIAVEIS
--INICIO --NOVO EM 2/5/22 
IF to_date(c1.data_admissao_to_char,'DD/MM/YYYY') < TO_DATE(vPRIMEIRA_DT_FUNC,'DD/MM/YYYY') THEN
data_inicial := to_date(c1.data_admissao_to_char,'DD/MM/YYYY');
ELSE
data_inicial :=TO_DATE(vPRIMEIRA_DT_FUNC,'DD/MM/YYYY');
END IF;
--FIM --NOVO EM 2/5/22

--COMENTADO EM 2/5/22--data_inicial := to_date(c1.data_admissao_to_char,'DD/MM/YYYY');
data_final := to_date(vDATA_CORTE,'DD/MM/YYYY');
dbms_output.put_line( 'DATA INICIO ANALISE: ' || to_date(data_inicial,'DD/MM/YYYY'));
dbms_output.put_line( 'DATA FIM ANALISE: ' || to_date(data_final,'DD/MM/YYYY'));
num_dias := (TO_DATE(data_final,'DD/MM/YYYY') - TO_DATE(data_inicial,'DD/MM/YYYY')  )+1;
dbms_output.put_line( 'TOTAL DE DIAS: ' || num_dias);
dbms_output.put_line( '' );



                                                                                     dbms_output.put_line('O_QUE_FAZER|CODIGO_EMPRESA|TIPO_CONTRATO|CODIGO_CONTRATO|ORIGEM|COD_ORIGEM|DESCRICAO_ORIGEM|COD_SIT_PONTO|SITUACAO_PONTO|DATA_INICIO|DATA_FIM|DATA_DOM|INFO_ONUS|CNPJ_CESSIONARIO|DT_AFAST_DESLIG|CONCEDIDO_ATE|TEXTO_ASSOCIADO|REFERENCIA|USUARIO|DATA_SANEAMENTO|DIAS');
INSERT INTO SUGESP_SANEAMENTO_PLANILHA_LOG VALUES ((SELECT MAX(ID)+1 FROM SUGESP_SANEAMENTO_PLANILHA_LOG),'O_QUE_FAZER|CODIGO_EMPRESA|TIPO_CONTRATO|CODIGO_CONTRATO|ORIGEM|COD_ORIGEM|DESCRICAO_ORIGEM|COD_SIT_PONTO|SITUACAO_PONTO|DATA_INICIO|DATA_FIM|DATA_DOM|INFO_ONUS|CNPJ_CESSIONARIO|DT_AFAST_DESLIG|CONCEDIDO_ATE|TEXTO_ASSOCIADO|REFERENCIA|USUARIO|DATA_SANEAMENTO|DIAS');COMMIT;
--/*


for i in 1..num_dias loop
vCONTADOR :=vCONTADOR+1;
--  dbms_output.put_line( '| DIA: ' || i|| ' DATA: ' || to_char((data_inicial-1)+i,'DD/MM/YYYY')||'|'|| c1.codigo_empresa  ||'|'|| c1.tipo_contrato ||'|'||c1.codigo );
  vDATA_DIA :=  to_date(to_char((data_inicial-1)+i,'DD/MM/YYYY'),'DD/MM/YYYY');
  dbms_output.put_line(TO_DATE(vDATA_DIA,'DD/MM/YY'));

--/*
----------------------------------------------------------------------------------------------------INICIO -- LOGICA DO NEGOCIO----------------------------------------------------------------------------------------------------------------------  
FOR C3 IN(

SELECT X.* FROM(

--inicio novo em 28/4/22
select 2 NUM, 'SITUACAO FUNCIONAL' TIPO, A.COD_SIT_FUNCIONAL COD_SIT_FUNC, S.DESCRICAO SITUACAO_FUNCIONAL, S.SITUACAO_PONTO COD_SIT_PONTO, P.DESCRICAO SITUACAO_PONTO, 'D' TIPO_REFERENCIA, 1 REFERENCIA, A.DATA_INIC_SITUACAO DATA_INICIO, A.DATA_FIM_SITUACAO DATA_FIM
,A.DATA_PUBLIC DATA_DOM, -- EM 28/4/22--,A.c_livre_data01 DATA_DOM, 
A.TEXTO_ASSOCIADO, A.info_onus, A.cnpj_cessionario, a.c_livre_data04 Dt_Afast_Deslig, A.dt_prev_retorno CONCEDIDO_ATE 
,trunc(A.DATA_FIM_SITUACAO) - trunc(A.DATA_INIC_SITUACAO) + 1 DIAS
from RHCGED_ALT_SIT_FUN A 
LEFT OUTER JOIN RHPARM_SIT_FUNC S ON S.CODIGO = A.COD_SIT_FUNCIONAL
LEFT OUTER JOIN RHPONT_SITUACAO P ON P.CODIGO = S.SITUACAO_PONTO
WHERE A.CODIGO_EMPRESA = c1.CODIGO_EMPRESA  
AND A.TIPO_CONTRATO = c1.TIPO_CONTRATO 
AND A.CODIGO = c1.CODIGO
AND 

 trunc(A.DATA_INIC_SITUACAO) > trunc(A.DATA_FIM_SITUACAO) 


UNION ALL--fim novo em 28/4/22

select 2 NUM, 'SITUACAO FUNCIONAL' TIPO, A.COD_SIT_FUNCIONAL COD_SIT_FUNC, S.DESCRICAO SITUACAO_FUNCIONAL, S.SITUACAO_PONTO COD_SIT_PONTO, P.DESCRICAO SITUACAO_PONTO, 'D' TIPO_REFERENCIA, 1 REFERENCIA, A.DATA_INIC_SITUACAO DATA_INICIO, A.DATA_FIM_SITUACAO DATA_FIM
,A.DATA_PUBLIC DATA_DOM, -- EM 28/4/22--,,A.c_livre_data01 DATA_DOM,
A.TEXTO_ASSOCIADO, A.info_onus, A.cnpj_cessionario, a.c_livre_data04 Dt_Afast_Deslig, A.dt_prev_retorno CONCEDIDO_ATE 
,trunc(A.DATA_FIM_SITUACAO) - trunc(A.DATA_INIC_SITUACAO) + 1 DIAS
from RHCGED_ALT_SIT_FUN A 
LEFT OUTER JOIN RHPARM_SIT_FUNC S ON S.CODIGO = A.COD_SIT_FUNCIONAL
LEFT OUTER JOIN RHPONT_SITUACAO P ON P.CODIGO = S.SITUACAO_PONTO
WHERE A.CODIGO_EMPRESA = c1.CODIGO_EMPRESA  
AND A.TIPO_CONTRATO = c1.TIPO_CONTRATO 
AND A.CODIGO = c1.CODIGO
AND 
(
( trunc(A.DATA_INIC_SITUACAO) <= trunc(vDATA_DIA) AND trunc(A.DATA_FIM_SITUACAO) >= trunc(vDATA_DIA))
OR
(A.DATA_INIC_SITUACAO = (SELECT MAX(AUX.DATA_INIC_SITUACAO)FROM RHCGED_ALT_SIT_FUN AUX
                                WHERE  A.CODIGO_EMPRESA = AUX.CODIGO_EMPRESA AND A.TIPO_CONTRATO = AUX.TIPO_CONTRATO AND A.CODIGO = AUX.CODIGO
                                AND trunc(AUX.DATA_INIC_SITUACAO) <= trunc(vDATA_DIA) and Aux.DATA_FIM_SITUACAO is null))
)

UNION ALL
--SELECT  'FERIAS' TIPO, NULL COD_SIT_FUNC,NULL SITUACAO_FUNCIONAL, P.SITUACAO_PONTO COD_SIT_PONTO, P.DESCRICAO SITUACAO_PONTO, f.dt_ini_gozo DATA_INICIO, f.dt_fim_gozo DATA_FIM
SELECT 2 NUM, 'FERIAS' TIPO, P.CODIGO COD_SIT_FUNC, P.DESCRICAO SITUACAO_FUNCIONAL, SP.CODIGO COD_SIT_PONTO, SP.DESCRICAO SITUACAO_PONTO, 'D' TIPO_REFERENCIA,1 REFERENCIA, f.dt_ini_gozo DATA_INICIO, f.dt_fim_gozo DATA_FIM
, NULL DATA_DOM, observacao TEXTO_ASSOCIADO, NULL info_onus, NULL cnpj_cessionario, NULL Dt_Afast_Deslig, NULL CONCEDIDO_ATE
,trunc(f.dt_ini_gozo) - trunc(f.dt_ini_gozo) + 1 DIAS
FROM RHFERI_FERIAS F
LEFT OUTER JOIN RHPARM_P_FERI P ON P.CODIGO_EMPRESA = F.CODIGO_EMPRESA AND P.CODIGO = F.TIPO_FERIAS
LEFT OUTER JOIN RHPONT_SITUACAO SP ON SP.CODIGO = P.SITUACAO_PONTO
WHERE F.CODIGO_EMPRESA = c1.CODIGO_EMPRESA  AND F.TIPO_CONTRATO = c1.TIPO_CONTRATO  AND F.CODIGO_CONTRATO = c1.CODIGO
AND 
(trunc(F.DT_INI_GOZO) <= trunc(vDATA_DIA) AND trunc(F.DT_FIM_GOZO) >= trunc(vDATA_DIA)) 

UNION ALL
select 1 NUM, 'FICHA MEDICA DEFERIDA' TIPO, F.NATUREZA_EXAME COD_SIT_FUNC, TP.DESCRICAO SITUACAO_FUNCIONAL,  S.SITUACAO_PONTO COD_SIT_PONTO, P.DESCRICAO SITUACAO_PONTO, 'D' TIPO_REFERENCIA, 1 REFERENCIA, F.DATA_INI_AFAST DATA_INICIO, F.DATA_FIM_AFAST DATA_FIM
, NULL DATA_DOM, F.TEXTO_ASSOCIADO, NULL info_onus, NULL cnpj_cessionario, NULL Dt_Afast_Deslig, NULL CONCEDIDO_ATE
,trunc(F.DATA_FIM_AFAST) - trunc(F.DATA_INI_AFAST) + 1 DIAS
FROM RHMEDI_FICHA_MED F
LEFT OUTER JOIN RHPARM_SIT_FUNC S ON S.CODIGO = F.SITUACAO_FUNCIONAL
LEFT OUTER JOIN RHPONT_SITUACAO P ON P.CODIGO = S.SITUACAO_PONTO
LEFT OUTER JOIN rhpess_contrato c ON C.CODIGO_EMPRESA = F.CODIGO_EMPRESA AND C.TIPO_CONTRATO = F.TIPO_CONTRATO AND C.CODIGO = F.CODIGO_CONTRATO
LEFT OUTER JOIN RHTABS_VINCULO_EMP V ON V.CODIGO = C.VINCULO
LEFT OUTER JOIN RHMEDI_NATUREZA_EX TP ON TP.CODIGO_EMPRESA = F.CODIGO_EMPRESA AND TP.CODIGO = F.NATUREZA_EXAME
FULL OUTER JOIN RHMEDI_RL_FICH_PRO CD ON F.CODIGO_EMPRESA = CD.CODIGO_EMPRESA AND F.CODIGO_PESSOA = CD.CODIGO_PESSOA AND F.DT_REG_OCORRENCIA = CD.DT_REG_OCORRENCIA AND F.OCORRENCIA = CD.OCORRENCIA
LEFT OUTER JOIN(SELECT * FROM RHINTE_ED_IT_CONV where codigo_CONVERSAO ='TEG1')TC1 
ON SUBSTR(TC1.DADO_ORIGEM,1,23) =  F.NATUREZA_EXAME||CD.CODIGO_PROC_MED||V.CODIGO --novo em 28/8/20
WHERE F.CODIGO_EMPRESA = c1.CODIGO_EMPRESA AND F.TIPO_CONTRATO = c1.TIPO_CONTRATO  AND F.CODIGO_CONTRATO = c1.CODIGO 
AND TC1.DADO_ORIGEM IS NOT NULL--novo em 28/8/20
AND (trunc(F.DATA_INI_AFAST) <= trunc(vDATA_DIA) AND trunc(F.DATA_FIM_AFAST) >= trunc(vDATA_DIA))
AND C.ANO_MES_REFERENCIA = (SELECT MAX(AUX.ANO_MES_REFERENCIA)
FROM RHPESS_CONTRATO AUX WHERE C.CODIGO_EMPRESA = AUX.CODIGO_EMPRESA AND C.TIPO_CONTRATO = AUX.TIPO_CONTRATO AND C.CODIGO = AUX.CODIGO)


UNION ALL
select 3 NUM, 'SITUACAO PONTO' TIPO, NULL COD_SIT_FUNC, NULL SITUACAO_FUNCIONAL,  D.CODIGO_SITUACAO COD_SIT_PONTO, P.DESCRICAO SITUACAO_PONTO, P.TIPO_REFERENCIA, D.REF_HORAS REFERENCIA,  DATA DATA_INICIO,  NULL DATA_FIM
, NULL DATA_DOM, D.TEXTO_ASSOCIADO, NULL info_onus, NULL cnpj_cessionario, NULL Dt_Afast_Deslig, NULL CONCEDIDO_ATE
,1 DIAS
from RHPONT_RES_SIT_DIA D 
LEFT OUTER JOIN RHPONT_SITUACAO P ON P.CODIGO = D.CODIGO_SITUACAO
WHERE D.CODIGO_EMPRESA = c1.CODIGO_EMPRESA  AND D.TIPO_CONTRATO = c1.TIPO_CONTRATO AND D.CODIGO_CONTRATO = c1.CODIGO
AND trunc(D.DATA) = trunc(vDATA_DIA)
and d.tipo_apuracao = 'F'

)X ORDER BY X.DATA_INICIO, X.NUM, X.TIPO

)
LOOP
vCONTADOR2 :=vCONTADOR2+1;
--dbms_output.put_line(vDATA_DIA);
--dbms_output.put_line(' '||'|'|| i ||'-'||vDATA_DIA ||'|'||c1.codigo_empresa ||'|'|| c1.tipo_contrato ||'|'|| c1.CODIGO||'|'|| C3.TIPO||'|'||C3.COD_SIT_FUNC ||'|'||C3.SITUACAO_FUNCIONAL ||'|'||C3.COD_SIT_PONTO ||'|'||C3.SITUACAO_PONTO ||'|'|| C3.DATA_INICIO ||'|'|| C3.DATA_FIM||'|'|| C3.DATA_DOM ||'|'|| C3.TEXTO_ASSOCIADO ||'|'|| C3.info_onus ||'|'|| C3.cnpj_cessionario ||'|'|| C3.DT_AFAST_DESLIG ||'|'|| C3.CONCEDIDO_ATE ||'|'|| c3.SIT_FUNC_DEFERIDA_NAT_EXAME ||'|'|| C3.FIC_MED_ALTERA_SIT_FUNC||'|'|| C3.SIT_PONTO_DEFERIDA_NAT_EXAME); 

if  (c3.TIPO = 'SITUACAO PONTO')or (vDATA_DIA = C3.DATA_INICIO) --(vDATA_DIA = C3.DATA_INICIO) or vCONTADOR2 <> 1 
then

                                                                                     dbms_output.put_line(' '||'|'|| c1.codigo_empresa ||'|'|| c1.tipo_contrato ||'|'|| c1.CODIGO||'|'|| C3.TIPO||'|'||C3.COD_SIT_FUNC ||'|'||C3.SITUACAO_FUNCIONAL ||'|'||C3.COD_SIT_PONTO ||'|'||C3.SITUACAO_PONTO ||'|'|| C3.DATA_INICIO ||'|'|| C3.DATA_FIM||'|'|| C3.DATA_DOM ||'|'|| C3.info_onus ||'|'|| C3.cnpj_cessionario ||'|'|| C3.DT_AFAST_DESLIG ||'|'|| C3.CONCEDIDO_ATE ||'|'|| C3.TEXTO_ASSOCIADO||'|'|| C3.REFERENCIA ||'|'|| C3.DIAS ); 
INSERT INTO SUGESP_SANEAMENTO_PLANILHA_LOG VALUES ((SELECT MAX(ID)+1 FROM SUGESP_SANEAMENTO_PLANILHA_LOG),' '||'|'|| c1.codigo_empresa ||'|'|| c1.tipo_contrato ||'|'|| c1.CODIGO||'|'|| C3.TIPO||'|'||C3.COD_SIT_FUNC ||'|'||C3.SITUACAO_FUNCIONAL ||'|'||C3.COD_SIT_PONTO ||'|'||C3.SITUACAO_PONTO||'|'|| C3.DATA_INICIO ||'|'|| C3.DATA_FIM||'|'|| C3.DATA_DOM ||'|'|| C3.info_onus ||'|'|| C3.cnpj_cessionario ||'|'|| C3.DT_AFAST_DESLIG ||'|'|| C3.CONCEDIDO_ATE ||'|'|| C3.TEXTO_ASSOCIADO||'|'|| C3.REFERENCIA ||'|'|| C3.DIAS );COMMIT;
--INSERT INTO SUGESP_SANEAMENTO_PLANILHA_LOG VALUES ((SELECT MAX(ID)+1 FROM SUGESP_SANEAMENTO_PLANILHA_LOG),'O_QUE_FAZER|CODIGO_EMPRESA         |TIPO_CONTRATO|       CODIGO_CONTRATO|    ORIGEM|       COD_ORIGEM|           DESCRICAO_ORIGEM|             COD_SIT_PONTO|            SITUACAO_PONTO|       DATA_INICIO|             DATA_FIM|            DATA_DOM|          INFO_ONUS|         CNPJ_CESSIONARIO|              DT_AFAST_DESLIG|          CONCEDIDO_ATE|          TEXTO_ASSOCIADO|USUARIO|DATA_SANEAMENTO|REFERENCIA');COMMIT;

end if;

end loop;--3Âº loop
----------------------------------------------------------------------------------------------------FIM -- LOGICA DO NEGOCIO----------------------------------------------------------------------------------------------------------------------  
--*/
vCONTADOR2:= 0;
end loop;


vCONTADOR:= 0;

end loop;
end;





END;-- END 1Ã‚Âº BEGIN

