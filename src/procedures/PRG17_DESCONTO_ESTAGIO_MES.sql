
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PRG17_DESCONTO_ESTAGIO_MES" (DATA_INICIO IN DATE, DATA_FIM IN DATE) AS
BEGIN


--Kellysson em 8/7/21 criando para gravar desconto que não é falta, as horas diferenciadas restantes do estagiario como 1013 no ultimo dia do mes
--Kellysson em 9/7/21 Tatila autorizou todos que são 
-----------------------------------------**************TROCAR DATAS
DECLARE

vCONTADOR NUMBER; 
vNUMERO NUMBER  ;
vSTRING VARCHAR2(100 BYTE);
vDATA_INICIO DATE;
vDATA_FIM DATE;

BEGIN 
dbms_output.enable(null);
vCONTADOR :=0;
vNUMERO := 0;
vSTRING := NULL;
vDATA_INICIO := TO_DATE(DATA_INICIO,'DD/MM/YYYY');--**************TROCAR DATAS
vDATA_FIM := TO_DATE(DATA_FIM,'DD/MM/YYYY');--**************TROCAR DATAS


FOR C1 IN (

SELECT X5.* FROM(--- NOVO EM 11/12/23 DEVIDO A ERRO RECORRENTE NOS ULTIMOS MESES ORA-02291: restrição de integridade (ARTERH.RHPONT_RE_SI_D_F01) violada - chave mãe não localizada

SELECT X4.* FROM(
--EM 21/5/21 AS 14H, ADICIONAR A LOGICA (analise_escala_semanal_toda_smsa.sql)
----------------------*****************************************mudar datas
SELECT
SUM(X3.DESCONTO_PROCESSAMENTO)-SUM(X3.DESCONTO_ARTERH)DESCONTO_1013,
X3.STATUS_DESCONTO,
SUM(X3.DESCONTO_PROCESSAMENTO)DESCONTO_PROCESSAMENTO, SUM(X3.DESCONTO_IFPONTO)DESCONTO_IFPONTO, SUM(X3.DESCONTO_ARTERH)DESCONTO_ARTERH, COUNT(X3.ORDEM_BM)ORDEM_BM, 
X3.PARTE_PROCESSAMENTO, X3.EMPRESA, X3.TIPO_CONTRATO, X3.MATRICULA, X3.CENARIO, X3.TIPO_FECHAMENTO, 
SUM(X3.QUANT_DIAS)QUANT_DIAS, 
SUM(X3.PREVISTO)PREVISTO, SUM(X3.TOTAL_HORAS_PREVISTAS)TOTAL_HORAS_PREVISTAS, SUM(X3.BH_DEBITO)BH_DEBITO, SUM(X3.DESCONTO)DESCONTO, 
X3.TIPO_ESCALA, X3.CARGA_HORARIA, X3.EMPRESA_ESCALA, X3.COMPRIMENTO_ESCALA, 
SUM(X3.QTD_REGISTROS)QTD_REGISTROS, 
X3.FOLHA_ESPECIAL, X3.REGISTRO_PONTO, X3.COD_VINCULO, 
SUM(X3.ACUMULADO_FALTAS)ACUMULADO_FALTAS, SUM(X3.ACUMULADO_PREVISTO)ACUMULADO_PREVISTO, SUM(X3.ACUMULADO_H_NORMAIS)ACUMULADO_H_NORMAIS, SUM(X3.ACUMULADO_H_DIFERENCIAS)ACUMULADO_H_DIFERENCIAS, SUM(X3.ACUMULADO_H_EXCEDIDAS)ACUMULADO_H_EXCEDIDAS, 
X3.DATA_PROCESSAMENTO, 
SUM(X3.TRABALHOU)TRABALHOU, SUM(X3.FOLGA)FOLGA, SUM(X3.NAO_TRABALHOU)NAO_TRABALHOU, SUM(X3.FERIAS_AFASTAMENTO)FERIAS_AFASTAMENTO,
SUM(X3.JUSTIFICATIVA_ABONADA)JUSTIFICATIVA_ABONADA, SUM(X3.JUSTIFICATIVA_NAO_AVALIADA)JUSTIFICATIVA_NAO_AVALIADA, SUM(X3.JUSTIFICATIVA_NAO_ABONADA)JUSTIFICATIVA_NAO_ABONADA, SUM(X3.ERROS_VERIFICAR)ERROS_VERIFICAR, SUM(X3.TOTAL_DIAS_PROCESSAMENTO)TOTAL_DIAS_PROCESSAMENTO, 
X3.TOTAL_IFPONTO, X3.COD_PESSOA, 
SUM(X3.SOMA_DESCONTO)SOMA_DESCONTO, SUM(X3.QTD_DIAS_DESCONTO)QTD_DIAS_DESCONTO,
X3.AGRUPADOR, X3.UNIDADE, X3.RESULTADOS_ARTERH, X3.CODIGO_EMPRESA, X3.TIPO_CONTRAT, X3.CODIGO_CONTRATO, X3.NOME, X3.COD_SIT_FUNC, X3.SITUACAO_FUNCIONAL, X3.COD_CARGO_EFETIVO, X3.CARGO_EFETIVO, X3.COD_CARGO_COMISSAO, X3.CARGO_COMISSAO, 
X3.COD_FUCNCAO, X3.FUNCAO, X3.COD_CGERENC1, X3.COD_CGERENC2, X3.COD_CGERENC3, X3.COD_CGERENC4, X3.COD_CGERENC5, X3.COD_CGERENC6, X3.CUSTO_GERENCIAL, X3.CODIGO_ESCALA, 
SUM(X3.QTD_TOTAL_MINUTOS_TIPO_JORNAD)QTD_TOTAL_MINUTOS_TIPO_JORNAD, SUM(X3.TOTAL_HORAS_TIPO_JORNADA)TOTAL_HORAS_TIPO_JORNADA, 
X3.CARGA_HORARIA_TIPO_JORNADA, 
SUM(X3.TOTAL_REF_FALTA_0020)TOTAL_REF_FALTA_0020, SUM(X3.QTD_DIAS_FALTA_0020)QTD_DIAS_FALTA_0020, SUM(X3.TOTAL_REF_ESTORNO_FALTA_1015)TOTAL_REF_ESTORNO_FALTA_1015, SUM(X3.QTD_DIAS_ESTORNO_FALTA_1015)QTD_DIAS_ESTORNO_FALTA_1015, SUM(X3.TOTAL_REF_TOT_H_DIF_PER_1013)TOTAL_REF_TOT_H_DIF_PER_1013, SUM(X3.QTD_DIAS_TOT_H_DIF_PER_1013)QTD_DIAS_TOT_H_DIF_PER_1013, 
SUM(X3.TOTAL_REF_EST_TOT_H_DIF_1204)TOTAL_REF_EST_TOT_H_DIF_1204, SUM(X3.QTD_DIAS_EST_TOT_H_DIF_1204)QTD_DIAS_EST_TOT_H_DIF_1204, SUM(X3.TOTAL_DIAS_DESCONTADO)TOTAL_DIAS_DESCONTADO, SUM(X3.TOTAL_HORAS_DESCONTADAS)TOTAL_HORAS_DESCONTADAS, SUM(X3.TOTAL_GERAL_DESCONTO_HORAS)TOTAL_GERAL_DESCONTO_HORAS, SUM(X3.TOTAL_REF_FALTA_COMPENS_1004)TOTAL_REF_FALTA_COMPENS_1004,
SUM(X3.QTD_DIAS_FALTA_COMPENS_1004)QTD_DIAS_FALTA_COMPENS_1004, SUM(X3.TOTAL_REF_AUSENC_ABONA_EM_DIA)TOTAL_REF_AUSENC_ABONA_EM_DIA, SUM(X3.QTD_DIAS_AUSENC_ABONA_EM_DIA)QTD_DIAS_AUSENC_ABONA_EM_DIA, SUM(X3.TOTAL_REF_CESSAO_TELETRABALHO)TOTAL_REF_CESSAO_TELETRABALHO, SUM(X3.QTD_DIAS_CESSAO_TELETRABALHO)QTD_DIAS_CESSAO_TELETRABALHO, 
SUM(X3.TOTAL_REF_HORA_NORMAL_EM_HORA)TOTAL_REF_HORA_NORMAL_EM_HORA, SUM(X3.QTD_DIAS_HORA_NORMAL_EM_HORA)QTD_DIAS_HORA_NORMAL_EM_HORA, SUM(X3.TOTAL_REF_AUSENC_ABONA_EM_HORA)TOTAL_REF_AUSENC_ABONA_EM_HORA, SUM(X3.QTD_DIAS_AUSENC_ABONA_EM_HORA)QTD_DIAS_AUSENC_ABONA_EM_HORA, SUM(X3.TOTAL_REF_FALTA_EM_HORAS)TOTAL_REF_FALTA_EM_HORAS, SUM(X3.QTD_DIAS_FALTA_EM_HORAS)QTD_DIAS_FALTA_EM_HORAS
FROM(
SELECT 
CASE WHEN ROUND(X2.DESCONTO,2) <> ROUND(X2.SOMA_DESCONTO,2) OR ROUND(X2.DESCONTO,2) <> ROUND(X2.TOTAL_GERAL_DESCONTO_HORAS,2) OR ROUND(X2.SOMA_DESCONTO,2) <> ROUND(X2.TOTAL_GERAL_DESCONTO_HORAS,2) THEN 'VERIFICAR' ELSE 'OK' END STATUS_DESCONTO,
ROUND(X2.DESCONTO,2) DESCONTO_PROCESSAMENTO, ROUND(X2.SOMA_DESCONTO,2) DESCONTO_IFPONTO, ROUND(X2.TOTAL_GERAL_DESCONTO_HORAS,2) DESCONTO_ARTERH,
X2.* FROM(
SELECT
ROW_NUMBER() OVER (PARTITION BY X.EMPRESA, X.TIPO_CONTRATO, X.MATRICULA ORDER BY X.EMPRESA, X.TIPO_CONTRATO, X.MATRICULA, X.CENARIO) AS ORDEM_BM,
X.* FROM(
--em 13/5/21 --falta agora juntar essas 3 fontes para soltar um relatorio já fazendo contas entre esses dados 3 apontando possiveis falhas
--CONTINUANDO EM 20/5/21 COM A SIMULACAO PBH TODA ABRIL/21
--TOTAIS DO PROCESSO (totais_periodo_comp_pbh_V8.sql)
SELECT 
'PARTE_PROCESSAMENTO' PARTE_PROCESSAMENTO, P.EMPRESA, P.TIPO_CONTRATO, P.MATRICULA, P.CENARIO, P.TIPO_FECHAMENTO, P.QUANT_DIAS, P.PREVISTO, 
 NVL(P.QUANT_DIAS,0)* NVL(P.PREVISTO,0) AS TOTAL_HORAS_PREVISTAS,
P.BH_DEBITO, NVL(P.DESCONTO,0) DESCONTO, 
P.TIPO_ESCALA, P.CARGA_HORARIA, EPA.CODIGO_LEGADO EMPRESA_ESCALA, EPA.COMPRIMENTO COMPRIMENTO_ESCALA, P.QUANT QTD_REGISTROS,  P.FOLHA_ESPECIAL, 
P.REGISTRO_PONTO, P.COD_VINCULO, P.ACUMULADO_FALTAS, P.ACUMULADO_PREVISTO, P.ACUMULADO_H_NORMAIS, P.ACUMULADO_H_DIFERENCIAS, P.ACUMULADO_H_EXCEDIDAS, P.DATA_PROCESSAMENTO
,P.TRABALHOU, P.FOLGA, P.NAO_TRABALHOU, P.FERIAS_AFASTAMENTO, P.JUSTIFICATIVA_ABONADA, P.JUSTIFICATIVA_NAO_AVALIADA, P.JUSTIFICATIVA_NAO_ABONADA, P.ERROS_VERIFICAR 
,NVL(P.TRABALHOU,0) + NVL(P.FOLGA,0) + NVL(P.NAO_TRABALHOU,0) + NVL(P.FERIAS_AFASTAMENTO,0) + NVL(P.JUSTIFICATIVA_ABONADA,0) + NVL(P.JUSTIFICATIVA_NAO_AVALIADA,0) + NVL(P.JUSTIFICATIVA_NAO_ABONADA,0) + NVL(P.ERROS_VERIFICAR,0) AS TOTAL_DIAS_PROCESSAMENTO

,'TOTAL_IFPONTO' TOTAL_IFPONTO,I.COD_PESSOA, NVL(I.SOMA_DESCONTO,0)SOMA_DESCONTO, I.QTD_DIAS_DESCONTO, I.AGRUPADOR, I.LOCAL UNIDADE

,'RESULTADOS_ARTERH' RESULTADOS_ARTERH
,A.CODIGO_EMPRESA, A.TIPO_CONTRATO TIPO_CONTRAT, A.CODIGO_CONTRATO, A.NOME, A.COD_SIT_FUNC, A.SITUACAO_FUNCIONAL, A.COD_CARGO_EFETIVO, A.CARGO_EFETIVO, A.COD_CARGO_COMISSAO, A.CARGO_COMISSAO, A.COD_FUCNCAO, A.FUNCAO,
A.COD_CGERENC1, A.COD_CGERENC2, A.COD_CGERENC3, A.COD_CGERENC4, A.COD_CGERENC5, A.COD_CGERENC6, A.CUSTO_GERENCIAL,
A.CODIGO_ESCALA, A.QTD_TOTAL_MINUTOS_TIPO_JORNAD, NVL(A.QTD_TOTAL_MINUTOS_TIPO_JORNAD,0)/60 AS TOTAL_HORAS_TIPO_JORNADA , A.CARGA_HORARIA_TIPO_JORNADA,

A.TOTAL_REF_FALTA_0020, A.QTD_DIAS_FALTA_0020, A.TOTAL_REF_ESTORNO_FALTA_1015, A.QTD_DIAS_ESTORNO_FALTA_1015, 
A.TOTAL_REF_TOT_H_DIF_PER_1013, A.QTD_DIAS_TOT_H_DIF_PER_1013, A.TOTAL_REF_EST_TOT_H_DIF_1204, A.QTD_DIAS_EST_TOT_H_DIF_1204,

NVL(A.TOTAL_REF_FALTA_0020,0)-NVL(A.TOTAL_REF_ESTORNO_FALTA_1015,0) AS TOTAL_DIAS_DESCONTADO, 
NVL(A.TOTAL_REF_TOT_H_DIF_PER_1013,0)-NVL(A.TOTAL_REF_EST_TOT_H_DIF_1204,0)AS TOTAL_HORAS_DESCONTADAS,
((NVL(A.TOTAL_REF_FALTA_0020,0)-NVL(A.TOTAL_REF_ESTORNO_FALTA_1015,0)) * NVL(P.PREVISTO,0))+(NVL(A.TOTAL_REF_TOT_H_DIF_PER_1013,0)-NVL(A.TOTAL_REF_EST_TOT_H_DIF_1204,0))AS TOTAL_GERAL_DESCONTO_HORAS,
A.TOTAL_REF_FALTA_COMPENS_1004, A.QTD_DIAS_FALTA_COMPENS_1004,
A.TOTAL_REF_AUSENC_ABONA_EM_DIA, A.QTD_DIAS_AUSENC_ABONA_EM_DIA, A.TOTAL_REF_CESSAO_TELETRABALHO, A.QTD_DIAS_CESSAO_TELETRABALHO,
A.TOTAL_REF_HORA_NORMAL_EM_HORA, A.QTD_DIAS_HORA_NORMAL_EM_HORA, A.TOTAL_REF_AUSENC_ABONA_EM_HORA, A.QTD_DIAS_AUSENC_ABONA_EM_HORA, A.TOTAL_REF_FALTA_EM_HORAS, A.QTD_DIAS_FALTA_EM_HORAS


FROM PONTO_ELETRONICO.TOTAIS_PERIODO_COMP_PBH P --39.448 EM 21/5/21
LEFT OUTER JOIN PONTO_ELETRONICO.IFPONTO_ESCALA_PESSOA EPE ON LPAD(EPE.EMPRESA,4,0) = LPAD(P.EMPRESA,4,0) AND LPAD(EPE.TIPO_CONTRATO,4,0) = LPAD(P.TIPO_CONTRATO,4,0) AND LPAD(EPE.MATRICULA,15,0) = LPAD(P.MATRICULA,15,0)
LEFT OUTER JOIN PONTO_ELETRONICO.IFPONTO_ESCALA_PADRAO EPA ON EPA.CODIGO = EPE.COD_ESCALA_PADRAO 

FULL OUTER JOIN(
---INICIO---------------------------------------------DADOS DE DESCONTO NO aRTERH
SELECT * FROM  ARTERH.TOTAIS_PERIODO_SIT_PONTO_ARTE WHERE TRUNC(DATA_PROCESSAMENTO) = TRUNC(SYSDATE)--to_date('11/06/2021','dd/mm/yyyy')-- TRUNC(SYSDATE)--40.756 EM 21/5/21
)A ON A.CODIGO_EMPRESA = P.EMPRESA AND A.TIPO_CONTRATO = P.TIPO_CONTRATO AND A.CODIGO_CONTRATO = P.MATRICULA
---FIM---------------------------------------------DADOS DE DESCONTO NO aRTERH

FULL OUTER JOIN(
--INICIO--------------------------------DESCONTO NO iFPONTO
select x.COD_PESSOA, X.EMPRESA, X.TIPO_CONTRATO, X.MATRICULA, X.TIPO_ESCALA, X.CARGA_HORARIA, X.AGRUPADOR, X.SOMA_DESCONTO, X.QTD_DIAS_DESCONTO, gn.descricao LOCAL 
from( 
select  
X.COD_PESSOA, x.empresa, x.tipo_contrato, x.matricula,  /* X.COD_ESCALA_PADRAO, x.data,*/ x.tipo_escala, x.carga_horaria, x.agrupador, sum(desconto)soma_desconto, count(1) QTD_DIAS_DESCONTO  
from PONTO_ELETRONICO.IFPONTO_ESPELHO_HISTORICA X 
where trunc(x.data) between to_date(vDATA_INICIO,'dd/mm/yyyy') and to_date(vDATA_FIM,'dd/mm/yyyy')--data_processamento is null  ----------------------*****************************************mudar datas
and x.desconto is not null and x.desconto > 0 -------------------------------------**************************************************************PEGA APENAS QUEM TEVE DESCONTO
and (x.bh_debito is null or x.bh_debito = 0)----não pegar os espelhos que usaram banco de horas --novo em 9/12/21
--and matricula like '%1138268%'--testes
--AND AGRUPADOR IN ('01.000095.000000.000015.000039.000000.000000','01.000095.000000.000021.000024.000000.000000','01.000095.000000.000016.000030.000000.000000','01.000095.000004.000002.000003.000000.000000','01.000095.000002.000002.000007.000000.000000','01.000095.000000.000020.000027.000000.000000')--NOVO 29/3/21 PARA OS TIPOS DE CONTRATO = 0001 DOS 6 LOCAIS DO PILOTO SMSA
group by X.COD_PESSOA, x.empresa, x.tipo_contrato, x.matricula, /*X.COD_ESCALA_PADRAO, x.data,*/ x.tipo_escala, x.carga_horaria, x.agrupador 
order by x.agrupador, x.empresa, x.tipo_contrato, x.matricula,  /*X.COD_ESCALA_PADRAO,x.data,*/ x.tipo_escala, x.carga_horaria 
)x 
LEFT OUTER JOIN ARTERH.RHORGA_CUSTO_GEREN GN ON x.EMPRESA = GN.CODIGO_EMPRESA AND substr(x.agrupador,4,6) = GN.cod_cgerenc1 AND substr(x.agrupador,11,6) = GN.cod_cgerenc2 AND substr(x.agrupador,18,6) = GN.cod_cgerenc3 
AND substr(x.agrupador,25,6) = GN.cod_cgerenc4 AND substr(x.agrupador,32,6) = GN.cod_cgerenc5 AND substr(x.agrupador,39,6) = GN.cod_cgerenc6 
--LEFT OUTER JOIN PONTO_ELETRONICO.IFPONTO_ESCALA_PESSOA EPE ON EPE.COD_PESSOA = X.COD_PESSOA
--LEFT OUTER JOIN PONTO_ELETRONICO.IFPONTO_ESCALA_PADRAO EPA ON EPA.CODIGO = X.COD_ESCALA_PADRAO 
where gn.data_extincao is null
order by x.agrupador
)I ON I.EMPRESA = P.EMPRESA AND I.TIPO_CONTRATO = P.TIPO_CONTRATO AND I.MATRICULA = P.MATRICULA 
--FIM--------------------------------DESCONTO NO iFPONTO
WHERE TRUNC(P.DATA_PROCESSAMENTO) = TRUNC(SYSDATE)--to_date('11/06/2021','dd/mm/yyyy')--TRUNC(SYSDATE)
)X
ORDER BY X.EMPRESA, X.TIPO_CONTRATO, X.MATRICULA , X.CODIGO_EMPRESA, X.TIPO_CONTRAT, X.CODIGO_CONTRATO
)X2
)X3
WHERE (X3.COD_VINCULO = '0009' OR X3.CARGA_HORARIA = 'Diária')AND X3.STATUS_DESCONTO = 'VERIFICAR'--*************************************************************************SOMENTE ESTAGIOS COM DIFERENCA NO DESCONTO ou CARGA_HORARIA = Diária
GROUP BY 
X3.STATUS_DESCONTO, X3.PARTE_PROCESSAMENTO, X3.EMPRESA, X3.TIPO_CONTRATO, X3.MATRICULA, X3.CENARIO, X3.TIPO_FECHAMENTO,
X3.TIPO_ESCALA, X3.CARGA_HORARIA, X3.EMPRESA_ESCALA, X3.COMPRIMENTO_ESCALA, 
X3.FOLHA_ESPECIAL, X3.REGISTRO_PONTO, X3.COD_VINCULO, 
X3.DATA_PROCESSAMENTO, 
X3.TOTAL_IFPONTO, X3.COD_PESSOA, 
X3.AGRUPADOR, X3.UNIDADE, X3.RESULTADOS_ARTERH, X3.CODIGO_EMPRESA, X3.TIPO_CONTRAT, X3.CODIGO_CONTRATO, X3.NOME, X3.COD_SIT_FUNC, X3.SITUACAO_FUNCIONAL, X3.COD_CARGO_EFETIVO, X3.CARGO_EFETIVO, X3.COD_CARGO_COMISSAO, X3.CARGO_COMISSAO, 
X3.COD_FUCNCAO, X3.FUNCAO, X3.COD_CGERENC1, X3.COD_CGERENC2, X3.COD_CGERENC3, X3.COD_CGERENC4, X3.COD_CGERENC5, X3.COD_CGERENC6, X3.CUSTO_GERENCIAL, X3.CODIGO_ESCALA, 
X3.CARGA_HORARIA_TIPO_JORNADA
ORDER BY
X3.EMPRESA, X3.TIPO_CONTRATO, X3.MATRICULA, X3.CENARIO, X3.TIPO_FECHAMENTO,
X3.TIPO_ESCALA, X3.CARGA_HORARIA, X3.EMPRESA_ESCALA, X3.COMPRIMENTO_ESCALA, 
X3.FOLHA_ESPECIAL, X3.REGISTRO_PONTO, X3.COD_VINCULO, 
X3.DATA_PROCESSAMENTO, 
X3.TOTAL_IFPONTO, X3.COD_PESSOA, 
X3.AGRUPADOR, X3.UNIDADE, X3.RESULTADOS_ARTERH, X3.CODIGO_EMPRESA, X3.TIPO_CONTRAT, X3.CODIGO_CONTRATO, X3.NOME, X3.COD_SIT_FUNC, X3.SITUACAO_FUNCIONAL, X3.COD_CARGO_EFETIVO, X3.CARGO_EFETIVO, X3.COD_CARGO_COMISSAO, X3.CARGO_COMISSAO, 
X3.COD_FUCNCAO, X3.FUNCAO, X3.COD_CGERENC1, X3.COD_CGERENC2, X3.COD_CGERENC3, X3.COD_CGERENC4, X3.COD_CGERENC5, X3.COD_CGERENC6, X3.CUSTO_GERENCIAL, X3.CODIGO_ESCALA, 
X3.CARGA_HORARIA_TIPO_JORNADA

--NOVO X4. DEVIDO AO FECHAMENTO COMPLEMENTAR PARA PEGAR APENAS O QUE AINDA ESTA NA select COUNT(1) from PONTO_ELETRONICO.IFPONTO_ESPELHO_HISTORICA WHERE DATA_PROCESSAMENTO IS NULL
)X4
LEFT OUTER JOIN (select EMPRESA, TIPO_CONTRATO, MATRICULA, COUNT(1)QTD_DIAS from PONTO_ELETRONICO.IFPONTO_ESPELHO_HISTORICA WHERE DATA_PROCESSAMENTO IS NULL GROUP BY EMPRESA, TIPO_CONTRATO, MATRICULA)H
ON H.EMPRESA = X4.EMPRESA AND H.TIPO_CONTRATO = X4.TIPO_CONTRATO AND H.MATRICULA = X4.MATRICULA
WHERE H.EMPRESA IS NOT NULL--APENAS O QUE ESTA NA HISTORICA

--INICIO---- NOVO EM 11/12/23 DEVIDO A ERRO RECORRENTE NOS ULTIMOS MESES ORA-02291: restrição de integridade (ARTERH.RHPONT_RE_SI_D_F01) violada - chave mãe não localizada
)X5
LEFT OUTER JOIN
ARTERH.rhpess_contr_mest C ON C.CODIGO_EMPRESA =X5.EMPRESA AND C.TIPO_CONTRATO = X5.TIPO_CONTRATO AND C.CODIGO_CONTRATO = LPAD(X5.MATRICULA,15,0) 
WHERE C.CODIGO_EMPRESA IS NOT NULL
--FIM---- NOVO EM 11/12/23 DEVIDO A ERRO RECORRENTE NOS ULTIMOS MESES ORA-02291: restrição de integridade (ARTERH.RHPONT_RE_SI_D_F01) violada - chave mãe não localizada

)

LOOP
vCONTADOR :=vCONTADOR+1;
dbms_output.put_line('--'||vCONTADOR|| ' - CODIGO_EMPRESA: '|| C1.EMPRESA ||' TIPO_CONTRATO: ' || C1.TIPO_CONTRATO ||' MATRICULA: '|| C1.MATRICULA ||' DESCONTO_1013: '|| C1.DESCONTO_1013);


IF C1.DESCONTO_1013 > 0 THEN
vNUMERO := ROUND(C1.DESCONTO_1013,2) ;
vSTRING := CASE WHEN INSTR(vNUMERO,',',1,1) = 0 THEN TO_CHAR(vNUMERO) WHEN INSTR(vNUMERO,',',1,1) <> 0 THEN TO_CHAR(SUBSTR(vNUMERO,1,INSTR(vNUMERO,',',1,1)-1) ||'.'||SUBSTR(vNUMERO,INSTR(vNUMERO,',' ,1,1)+1, LENGTH(vNUMERO))) end ;
dbms_output.put_line('INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, TIPO_APURACAO, DT_ULT_ALTER_USUA, LOGIN_USUARIO, FORCA_SITUACAO, TEXTO_ASSOCIADO) VALUES ('''||LPAD(C1.EMPRESA,4,0) ||''','''|| LPAD(C1.TIPO_CONTRATO,4,0) ||''','''|| LPAD(C1.MATRICULA,15,0) ||''', TO_DATE('''|| trunc(vDATA_FIM) ||''',''DD/MM/YYYY''),''1013'',ROUND('|| vSTRING||',2), ''F'', SYSDATE, ''IFPONTO'',''N'',''SCRIPT FECHAMENTO IFPONTO(desconto_mes_estagio_apenas_sit_func_1013_v1.sql)''); COMMIT;' );  
dbms_output.put_line('INSERT INTO SUGESP_AJUSTE_LOTE_CAMPO_HIST (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA_DADOS, CAMPO_VALOR_1, CONSIDERACOES)VALUES('''||LPAD(C1.EMPRESA,4,0) ||''','''|| LPAD(C1.TIPO_CONTRATO,4,0) ||''','''||LPAD(C1.MATRICULA,15,0) ||''', SYSDATE,'''|| vSTRING||''',''desconto_mes_estagio_apenas_sit_func_1013_v1.sql'');COMMIT;');
dbms_output.put_line('DELETE ARTERH.TOTAIS_PERIODO_SIT_PONTO_ARTE WHERE TRUNC(DATA_PROCESSAMENTO) = TRUNC(SYSDATE) AND CODIGO_EMPRESA = '''||LPAD(C1.EMPRESA,4,0) ||''' AND TIPO_CONTRATO = '''|| LPAD(C1.TIPO_CONTRATO,4,0) ||''' AND CODIGO_CONTRATO = '''||LPAD(C1.MATRICULA,15,0)||''';COMMIT;');
DELETE ARTERH.RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = LPAD(C1.EMPRESA,4,0) AND TIPO_CONTRATO = LPAD(C1.TIPO_CONTRATO,4,0) AND CODIGO_CONTRATO = LPAD(C1.MATRICULA,15,0) AND TRUNC(DATA) = vDATA_FIM AND CODIGO_SITUACAO = '1013' ; COMMIT; 

INSERT INTO ARTERH.RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, TIPO_APURACAO, DT_ULT_ALTER_USUA, LOGIN_USUARIO, FORCA_SITUACAO, TEXTO_ASSOCIADO) VALUES (LPAD(C1.EMPRESA,4,0) , LPAD(C1.TIPO_CONTRATO,4,0) , LPAD(C1.MATRICULA,15,0) , vDATA_FIM ,'1013',ROUND(vNUMERO,2), 'F', SYSDATE, 'IFPONTO','N','PRG17_DESCONTO_ESTAGIO_MES'); COMMIT; 
INSERT INTO PONTO_ELETRONICO.IFPONTO_FECHAMENTO_LOG_RELAT (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA_DADOS, CAMPO_1, CONSIDERACOES)VALUES(LPAD(C1.EMPRESA,4,0) , LPAD(C1.TIPO_CONTRATO,4,0) ,LPAD(C1.MATRICULA,15,0) , SYSDATE, vSTRING,'PRG17_DESCONTO_ESTAGIO_MES');COMMIT;
DELETE ARTERH.TOTAIS_PERIODO_SIT_PONTO_ARTE WHERE TRUNC(DATA_PROCESSAMENTO) = TRUNC(SYSDATE) AND CODIGO_EMPRESA = LPAD(C1.EMPRESA,4,0)  AND TIPO_CONTRATO =  LPAD(C1.TIPO_CONTRATO,4,0)  AND CODIGO_CONTRATO = LPAD(C1.MATRICULA,15,0);COMMIT;
ELSE
dbms_output.put_line('--*************VALOR ZERADO OU NEGATIVO VERIFICAR');
END IF;


END LOOP;

END;

END;