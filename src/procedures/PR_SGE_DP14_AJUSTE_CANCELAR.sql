
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PR_SGE_DP14_AJUSTE_CANCELAR" (ID_HORARIO IN VARCHAR2, DATA_INICIO IN DATE, CONSIDERACOES IN VARCHAR2)
AS BEGIN 

--Kellysson novo em 13/3/24
DECLARE 
vCONTADOR NUMBER;
vID_HORARIO VARCHAR2(20);
vDATA_INICIO DATE;
vCONSIDERACOES VARCHAR2(100);

BEGIN
dbms_output.enable(null);
vCONTADOR :=0;
vID_HORARIO := ID_HORARIO;
vDATA_INICIO := DATA_INICIO;
vCONSIDERACOES := CONSIDERACOES;

FOR C1 IN (


SELECT X2.* FROM(
SELECT 
CASE WHEN X.CANCELAMENTO_ANTECIPADO = 'SIM' AND X.DT_INICIO IS NOT NULL AND X.DT_CANCELAMENTO IS NULL THEN 'NAO' END CANCELAMENTO_EFETUADO, X.* FROM(
SELECT CASE 
WHEN DBL.DT_VALIDA_CANCELA IS NOT NULL AND TO_DATE(G.CANCELAMENTO,'DD/MM/RRRR') >= TO_DATE(G.INICIO,'DD/MM/RRRR') AND TO_DATE(G.CANCELAMENTO,'DD/MM/RRRR') <= TO_DATE(G.FIM,'DD/MM/RRRR') AND G.CANCELAMENTO IS NOT NULL THEN  'SIM'
END CANCELAMENTO_ANTECIPADO,
'ANALISE_ATUAL_PROCESSAMENTO' ANALISE_ATUAL_PROCESSAMENTO, P.*,
'DADOS_ARQUIVO_GEQPE' DADOS_ARQUIVO_GEQPE, G.INICIO, G.FIM, G.CANCELAMENTO,
'DADOS_DBLINK' DADOS_DBLINK, DBL.DATA_INICIO, DBL.DATA_FIM, DBL.DATA_CANCELAMENTO, DBL.DT_VALIDA_CANCELA, DBL.DT_CANCELAMENTO_USAR,
'DADOS_ARTERH' DADOS_ARTERH, ART.DT_INICIO, ART.DT_FIM, ART.DT_CANCELAMENTO, ART.DT_RECEBEU_CADASTRO, ART.DT_RECEBEU_CANCELAMENTO
FROM(
SELECT P.CAMPO_1 GRUPO_FINAL, P.CAMPO_2 ANALISE_SMED, P.CAMPO_3 ANALISE_ASTIN, P.CAMPO_4 CENARIO_FINAL_ID_JORNADA, P.CAMPO_5 CENARIO_FINAL_CANCELAMENTO, P.CAMPO_6 CENARIO_FINAL_TOTAL_SEMANA, P.CAMPO_7 CENARIO_GERAL, P.CAMPO_8 CENARIO_CANCELAMENTO, 
P.CAMPO_9 BM_USAR, P.CAMPO_10 CPF, P.CAMPO_11 ID_JORNADA, P.CAMPO_12 ID_HORARIO, P.CAMPO_13 ID_JORNADA_D, P.CAMPO_14 ID_HORARIO_D, P.CAMPO_15 RESPOSTA_ANTERIOR_SMED, P.CAMPO_16 CARGA_HORARIA_SGE, P.CAMPO_17 CARGA_HORARIA_CHEIA, P.CAMPO_18 QTD_CONCOMITA, P.CAMPO_19 STATUS_HORARIO, P.CAMPO_20 QTD_REG_PASSO_2, P.CAMPO_21 STATUS_REGISTRO_C, P.CAMPO_22 DATA_RECEBEU_ARTE_C,
P.CAMPO_23 HORAS_SEMANAIS_ARTE, P.CAMPO_24 TOTAL_SEMANA_5_DIAS_ARTE, P.CAMPO_25 COMPARA_HORAS_DIA_SEMANA_ARTE, P.DATA_DADOS
FROM PONTO_ELETRONICO.IFPONTO_FECHAMENTO_LOG_RELAT P WHERE P.CONSIDERACOES = vCONSIDERACOES AND TRUNC(P.DATA_DADOS) = TRUNC(SYSDATE)
)P --PROCEDURE
LEFT OUTER JOIN ( SELECT * FROM PONTO_ELETRONICO.SUGESP_SGE_JORNADAS_GERAL WHERE TRUNC(DATA_PROCESSAMENTO)= TRUNC(SYSDATE)
)DBL ON-- (DBL.ID_JORNADA = ART.ID_JORNADA AND TRUNC(ART.DT_RECEBEU_CADASTRO) = TRUNC(DBL.DATA_PROCESSAMENTO))---PEGAR APENAS O REGISTRO DO DIA QUE GRAVOU NO ARTERH
--    G.ID_JORNADA = DBL.ID_JORNADA AND TRUNC(P.DATA_DADOS) = TRUNC(DBL.DATA_PROCESSAMENTO)
P.ID_JORNADA_D = DBL.ID_JORNADA --AND TRUNC(DBL.DATA_PROCESSAMENTO)= TRUNC(SYSDATE)-1
LEFT OUTER JOIN 
(SELECT G.* FROM PONTO_ELETRONICO.SMARH_INT_PONTO_SGE_ARQUIVOS G WHERE G.id_horario = vID_HORARIO-------*********************TROCAR SEMPRE O CODIGO PARA A DATA DO DIA APOS IMPORTAR ARQUIVO DA SMED ENVIADO 
)G ON P.ID_JORNADA = G.ID_JORNADA
LEFT OUTER JOIN 
(SELECT CASE WHEN TIPO_EXTENSAO = 'EXTENSAO_SGE_PROFESSOR_SALA_DE_AULA' THEN 'ARQUIVO_ANTIGO' ELSE 'VIEW_NOVA' END ORIGEM, E.* FROM PONTO_ELETRONICO.SMARH_INT_PE_EXTENSOES_JORNAD E WHERE TRUNC(DT_INICIO) >= TO_DATE(vDATA_INICIO,'DD/MM/YYYY')---TROCAR CADA VIRADA DE ANO
)ART ON P.ID_JORNADA = ART.ID_JORNADA  
ORDER BY P.CENARIO_GERAL, P.CENARIO_CANCELAMENTO, P.ID_JORNADA
)X
)X2
WHERE X2.CANCELAMENTO_ANTECIPADO = 'SIM' AND X2.CANCELAMENTO_EFETUADO = 'NAO' --APENAS REGISTROS AINDA NAO CANCELADOS QUANDO EXTENSOES O FIM ANTECIPADO

)LOOP
vCONTADOR := vCONTADOR +1;
dbms_output.put_line('--vCONTADOR: '||vCONTADOR||' UPDATE INCLUIR A DATA CANCELAMENTO');
dbms_output.put_line('UPDATE PONTO_ELETRONICO.SMARH_INT_PE_EXTENSOES_JORNAD SET DT_CANCELAMENTO = TO_DATE('''||C1.CANCELAMENTO||''',''DD/MM/YYYY''), DT_RECEBEU_CANCELAMENTO = SYSDATE WHERE ID_JORNADA = ' 
||C1.ID_JORNADA
|| ';'
);

UPDATE PONTO_ELETRONICO.SMARH_INT_PE_EXTENSOES_JORNAD SET DT_CANCELAMENTO = TO_DATE(C1.CANCELAMENTO,'DD/MM/YYYY'), DT_RECEBEU_CANCELAMENTO = SYSDATE WHERE ID_JORNADA = C1.ID_JORNADA; COMMIT;


END LOOP;
END;

END;