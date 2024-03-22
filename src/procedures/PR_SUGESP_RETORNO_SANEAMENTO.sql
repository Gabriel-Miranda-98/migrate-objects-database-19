
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_SUGESP_RETORNO_SANEAMENTO" (EMPRESA IN VARCHAR2, TIPO_CONTRATO IN VARCHAR2, BM IN VARCHAR2)  AS
--KELLYSSON 10/1/20
BEGIN-- 1Ã‚Âº BEGIN
--delete SUGESP_SANEAMENTO_SITFUNCPONT
--DROP TABLE SUGESP_SANEAMENTO_SITFUNCPONT
--KELLYSSON EM 23/10/19
DECLARE
vCONTADOR NUMBER;
vEMPRESA VARCHAR2(4);
vTIPO_CONTRATO VARCHAR2(4);
vBM VARCHAR2(15);
vDATA_CORTE DATE;

BEGIN
dbms_output.enable(null);
vCONTADOR :=0;

vEMPRESA := EMPRESA;
vTIPO_CONTRATO :=TIPO_CONTRATO ;
vBM := BM;


--novo EM 20/7/21 DATA_CORTE 
SELECT S.DATA_CORTE_SIT_FUNC_PONTO INTO vDATA_CORTE FROM  SUGESP_SANEAMENTO_CONTRATOS S WHERE S.DATA_INI_SIT_FUNC_PONTO IS NOT NULL AND S.DATA_FIM_SIT_FUNC_PONTO IS NULL
AND S.CODIGO_EMPRESA  = vEMPRESA--'0001'-- 
AND S.TIPO_CONTRATO =  vTIPO_CONTRATO--'0001'--
AND CODIGO_CONTRATO = vBM ;--'000000000170171';--


FOR C1 IN (

SELECT
(TO_DATE('01/01/1900','DD/MM/YYYY')+ SA.CONCEDIDO_ATE)-2 SA_CONCEDIDO_ATE,
(TO_DATE('01/01/1900','DD/MM/YYYY')+ SA.DATA_INICIO)-2 SA_DATA_INICIO,
(TO_DATE('01/01/1900','DD/MM/YYYY')+ SA.DATA_FIM)-2 SA_DATA_FIM,
(TO_DATE('01/01/1900','DD/MM/YYYY')+ SA.DATA_DOM)-2 SA_DATA_DOM,
--comentado em 6/5/22M.dt_alt_unid_custo, 
SF.c_livre_valor04 COD_MOVIMENTACAO,
SA.*,SP.TIPO_REFERENCIA
--comentado em 6/5/22,M.COD_LOTACAO_ATUAL1 , M.COD_LOTACAO_ATUAL2, M.COD_LOTACAO_ATUAL3, M.COD_LOTACAO_ATUAL4, M.COD_LOTACAO_ATUAL5, M.COD_LOTACAO_ATUAL6
--comentado em 6/5/22,M.COD_UNIDADE_ATUAL1, M.COD_UNIDADE_ATUAL2, M.COD_UNIDADE_ATUAL3, M.COD_UNIDADE_ATUAL4, M.COD_UNIDADE_ATUAL5, M.COD_UNIDADE_ATUAL6
--comentado em 6/5/22,M.COD_CCONTAB_ATUAL1, M.COD_CCONTAB_ATUAL2, M.COD_CCONTAB_ATUAL3, M.COD_CCONTAB_ATUAL4, M.COD_CCONTAB_ATUAL5, M.COD_CCONTAB_ATUAL6
--comentado em 6/5/22,M.COD_CGERENC_ATUAL1, M.COD_CGERENC_ATUAL2, M.COD_CGERENC_ATUAL3, M.COD_CGERENC_ATUAL4, M.COD_CGERENC_ATUAL5, M.COD_CGERENC_ATUAL6
,SF.CONTROLE_FOLHA, SF.e_afastamento, SF.SUSPENDE_REMUNERA
,SF.SITUACAO_PONTO SIT_PONTO_CAD_FUNC, TEG5.DADO_DESTINO SIT_PONTO_DIFERE_CESSAO
FROM SUGESP_SANEAMENTO_SITFUNCPONT SA
LEFT OUTER JOIN RHPARM_SIT_FUNC SF ON SA.COD_SIT_FUNC = SF.CODIGO
--comentado em 12/5/22--LEFT OUTER JOIN RHCGED_TRANSFERENC M ON LPAD(SA.CODIGO_EMPRESA, 4,0) = M.CODIGO_EMPRESA AND LPAD(SA.TIPO_CONTRATO, 4,0) = M.TIPO_CONTRATO AND LPAD(SA.CODIGO_CONTRATO, 15,0) = M.CODIGO
LEFT OUTER JOIN (SELECT * FROM RHINTE_ED_IT_CONV WHERE CODIGO_CONVERSAO = 'TEG5')TEG5 ON SUBSTR(TEG5.DADO_ORIGEM,15,4) = SA.COD_SIT_FUNC AND SUBSTR(TEG5.DADO_ORIGEM,1,14)= SUBSTR(SA.CNPJ_CESSIONARIO,2,15)
LEFT OUTER JOIN RHPONT_SITUACAO SP ON SP.CODIGO = LPAD(SA.COD_SIT_PONTO, 4,0)
where SA.status_processamento is null AND SA.DATA_PROCESSAMENTO IS NULL
--AND SA.REFERENCIA IS NOT NULL

and LPAD(sa.codigo_empresa,4,0) = vEMPRESA and LPAD(sa.tipo_contrato,4,0) = vTIPO_CONTRATO and LPAD(sa.codigo_contrato,15,0) = vBM
/* --comentado em 6/5/22
AND M.dt_alt_unid_custo = (SELECT MAX(AUX.dt_alt_unid_custo) FROM RHCGED_TRANSFERENC AUX WHERE AUX.CODIGO_EMPRESA = M.CODIGO_EMPRESA AND AUX.TIPO_CONTRATO = M.TIPO_CONTRATO AND AUX.CODIGO = M.CODIGO
      AND TRUNC(AUX.dt_alt_unid_custo) <= (TO_DATE('01/01/1900','DD/MM/YYYY')+ SA.DATA_INICIO)-2 -- TO_DATE('10/03/2010','DD/MM/YYYY')
      )
*/--comentado em 6/5/22
ORDER BY SA.CODIGO_EMPRESA, SA.TIPO_CONTRATO, SA.CODIGO_CONTRATO, SA.O_QUE_FAZER
, sa.origem desc --ADICIONADO EM 1/2/24 Re: [Virtual] Lançamento de estornos sem a ocorrência
, SA.DATA_INICIO


)

LOOP
vCONTADOR :=vCONTADOR+1;
dbms_output.put_line('--'||vCONTADOR);

--atualizar o campo REFERENCIA TROCANDO A VIRGULA PELO PONTO
UPDATE SUGESP_SANEAMENTO_SITFUNCPONT SET REFERENCIA =  replace(REFERENCIA,',','.')
WHERE
LPAD(codigo_empresa,4,0) = vEMPRESA and LPAD(tipo_contrato,4,0) = vTIPO_CONTRATO and LPAD(codigo_contrato,15,0) = vBM
AND status_processamento is null AND DATA_PROCESSAMENTO IS NULL; COMMIT;

-------------------------------------------------------INICIO------------------- 1Âº IF PARA AS INCLUSÃ•ES E EXCLUSÃ•ES DE SITUAÃ‡AO FUNCIONAL E PONTO
--1Âª OPCAO - INCLUIR SITUACAO FUNCIONAL
IF c1.o_que_fazer = 'I' AND C1.COD_SIT_FUNC IS NOT NULL
AND C1.ORIGEM = 'SITUACAO FUNCIONAL'--NOVO 23/3/21
AND  TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY')) <= TRUNC(vDATA_CORTE)--novo em 20/7/21
AND ((C1.DATA_FIM IS NOT NULL AND TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO-2 <= TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_FIM -2 )OR C1.DATA_FIM IS NULL) --ajuste em 12/5 deixando tambem DATA FIM NULL--novo em 2/5/22 ajuste em 6/5/21 colocando sinal de igual
THEN
--inicio --erro no bm 868187 em 18/3/21 comentar o delete da sit ponto para ver se e isso
/*
IF C1.SIT_PONTO_CAD_FUNC IS NOT NULL THEN
--EXCLUIR SIT PONTO VINCULADA ATUALMENTE NO SIT FUNC A SER INSERIDA ANTES DE CRIA-LA
IF C1.SIT_PONTO_DIFERE_CESSAO IS NULL THEN
dbms_output.put_line('--EXCLUI SIT PONTO SIMPLES NA INCLUSAO SITUACAO FUNCIONAL');
dbms_output.put_line('DELETE RHPONT_RES_SIT_DIA WHERE TIPO_APURACAO  = ''F'' AND CODIGO_EMPRESA = '''|| LPAD(C1.CODIGO_EMPRESA, 4,0) || ''' AND TIPO_CONTRATO = '''|| LPAD(C1.TIPO_CONTRATO, 4,0) || ''' AND CODIGO_CONTRATO =''' || LPAD(C1.CODIGO_CONTRATO, 15,0) || ''' AND trunc(DATA) BETWEEN TO_DATE('''|| TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY') ||''',''DD/MM/YYYY'') AND TO_DATE('''|| TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_FIM)-2,'DD/MM/YYYY') ||''',''DD/MM/YYYY'') AND CODIGO_SITUACAO = '''|| LPAD(C1.SIT_PONTO_CAD_FUNC,4,0) ||'''; COMMIT;');
DELETE RHPONT_RES_SIT_DIA WHERE TIPO_APURACAO = 'F' AND CODIGO_EMPRESA = LPAD(C1.CODIGO_EMPRESA, 4,0) AND TIPO_CONTRATO = LPAD(C1.TIPO_CONTRATO, 4,0) AND CODIGO_CONTRATO = LPAD(C1.CODIGO_CONTRATO, 15,0) AND trunc(DATA) BETWEEN TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY', 'DD/MM/YYYY')) AND TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_FIM)-2,'DD/MM/YYYY', 'DD/MM/YYYY')) AND CODIGO_SITUACAO = C1.SIT_PONTO_CAD_FUNC; COMMIT;
ELSE
dbms_output.put_line('--EXCLUI SIT PONTO DIFERENCIADA CESSAO NA INCLUSAO SITUACAO FUNCIONAL');
dbms_output.put_line('DELETE RHPONT_RES_SIT_DIA WHERE TIPO_APURACAO  = ''F'' AND CODIGO_EMPRESA = '''|| LPAD(C1.CODIGO_EMPRESA, 4,0) || ''' AND TIPO_CONTRATO = '''|| LPAD(C1.TIPO_CONTRATO, 4,0) || ''' AND CODIGO_CONTRATO =''' || LPAD(C1.CODIGO_CONTRATO, 15,0) || ''' AND trunc(DATA) BETWEEN TO_DATE('''|| TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY') ||''',''DD/MM/YYYY'') AND TO_DATE('''|| TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_FIM)-2,'DD/MM/YYYY') ||''',''DD/MM/YYYY'') AND CODIGO_SITUACAO = '''|| LPAD(C1.SIT_PONTO_DIFERE_CESSAO,4,0) ||'''; COMMIT;');
DELETE RHPONT_RES_SIT_DIA WHERE TIPO_APURACAO = 'F' AND CODIGO_EMPRESA = LPAD(C1.CODIGO_EMPRESA, 4,0) AND TIPO_CONTRATO = LPAD(C1.TIPO_CONTRATO, 4,0) AND CODIGO_CONTRATO = LPAD(C1.CODIGO_CONTRATO, 15,0) AND trunc(DATA) BETWEEN TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY', 'DD/MM/YYYY')) AND TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_FIM)-2,'DD/MM/YYYY', 'DD/MM/YYYY')) AND CODIGO_SITUACAO = C1.SIT_PONTO_DIFERE_CESSAO; COMMIT;
END IF;
END IF;
*/
--fim --erro no bm 868187 em 18/3/21 comentar o delete da sit ponto para ver se e isso

--INCLUIR A SIT FUNC PROpRIAMENTE
dbms_output.put_line('--INCLUIR SITUACAO FUNCIONAL');
dbms_output.put_line('INSERT INTO RHCGED_ALT_SIT_FUN (ind_ef_retro_esocial, TEXTO_ASSOCIADO, LOGIN_USUARIO, DT_ULT_ALTER_USUA, CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO, DATA_INIC_SITUACAO, COD_SIT_FUNCIONAL, DATA_FIM_SITUACAO, DATA_PUBLIC,  cnpj_cessionario, info_onus, dt_prev_retorno ) values (''N'', ''Alteracao realizada em virtude do Projeto Saneamento Aposentadoria. ''' || C1.TEXTO_ASSOCIADO|| ',''script_saneamento_aposentadoria'' ,sysdate,'''|| LPAD(C1.CODIGO_EMPRESA, 4,0) ||''','''|| LPAD(C1.TIPO_CONTRATO, 4,0) ||''','''|| LPAD(C1.CODIGO_CONTRATO, 15,0)
|| ''', TO_DATE(''' ||TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY')||
''',''dd/mm/yyyy''), '''||LPAD(C1.COD_SIT_FUNC,4,0) ||''', TO_DATE(''' ||TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_FIM)-2,'DD/MM/YYYY')||''',''dd/mm/yyyy''), TO_DATE('''||TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_DOM)-2,'DD/MM/YYYY')||''',''dd/mm/yyyy''), '''
||CASE WHEN C1.CNPJ_CESSIONARIO IS NULL THEN 'NULL' ELSE SUBSTR(C1.CNPJ_CESSIONARIO,2,14) END ||''','
||CASE WHEN C1.INFO_ONUS IS NULL THEN 'NULL' ELSE C1.INFO_ONUS END 
||''', TO_DATE(''' ||TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_FIM)-2,'DD/MM/YYYY')||''',''dd/mm/yyyy''));  COMMIT;'  );
--/*
delete RHCGED_ALT_SIT_FUN where 
CODIGO_EMPRESA = LPAD(C1.CODIGO_EMPRESA,4,0) and  TIPO_CONTRATO = LPAD(C1.TIPO_CONTRATO, 4,0) and  CODIGO = LPAD(C1.CODIGO_CONTRATO, 15,0) and trunc(DATA_INIC_SITUACAO) = TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY'),'dd/mm/yyyy')
and COD_SIT_FUNCIONAL = LPAD(C1.COD_SIT_FUNC,4,0);  COMMIT;

INSERT INTO RHCGED_ALT_SIT_FUN (ind_ef_retro_esocial, TEXTO_ASSOCIADO, LOGIN_USUARIO, DT_ULT_ALTER_USUA, CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO, DATA_INIC_SITUACAO, COD_SIT_FUNCIONAL, DATA_FIM_SITUACAO, DATA_PUBLIC,  cnpj_cessionario, info_onus, dt_prev_retorno )
values ('N', 'Alteracao realizada em virtude do Projeto Saneamento Aposentadoria. '|| C1.TEXTO_ASSOCIADO, 'script_saneamento_aposentadoria', sysdate, LPAD(C1.CODIGO_EMPRESA,4,0), LPAD(C1.TIPO_CONTRATO, 4,0),
LPAD(C1.CODIGO_CONTRATO, 15,0),
TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY'),'dd/mm/yyyy'),
LPAD(C1.COD_SIT_FUNC,4,0) ,
TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_FIM)-2,'DD/MM/YYYY'),'dd/mm/yyyy'),
TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_DOM)-2,'DD/MM/YYYY'),'dd/mm/yyyy'),
CASE WHEN C1.CNPJ_CESSIONARIO IS NULL THEN NULL ELSE SUBSTR(C1.CNPJ_CESSIONARIO,1,14) END , CASE WHEN C1.INFO_ONUS IS NULL THEN NULL ELSE C1.INFO_ONUS END
,TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.CONCEDIDO_ATE)-2,'DD/MM/YYYY'),'dd/mm/yyyy')
);  COMMIT;
--*/

--ALTERAR A SIT PONTO CRIADA PELA TRIGGER SEM AVALIAR A TABELA DE CONVERSAO TEG5 DE CESSOES DIFERENCIADAS
dbms_output.put_line('--ATUALIZA SIT PONTO SIMPLES CRIADA NA INCLUSAO SITUACAO FUNCIONAL PARA A DIFERENCIADA DE CESSAO TABELA CONVERSAO TEG5');
dbms_output.put_line('-- troca sit ponto de: ' || C1.SIT_PONTO_CAD_FUNC||' para SIT PONTO - '|| c1.SIT_PONTO_DIFERE_CESSAO);
--update RHPONT_RES_SIT_DIA set CODIGO_SITUACAO = c1.SIT_PONTO_DIFERE_CESSAO where codigo_empresa = LPAD(C1.CODIGO_EMPRESA, 4,0) and tipo_contrato = LPAD(C1.TIPO_CONTRATO, 4,0) and codigo_contrato = LPAD(C1.CODIGO_CONTRATO, 15,0) and codigo_situacao = c1.SIT_PONTO_CAD_FUNC and trunc(data)  BETWEEN TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY', 'DD/MM/YYYY')) AND TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_FIM)-2,'DD/MM/YYYY', 'DD/MM/YYYY')); COMMIT;
dbms_output.put_line('');
UPDATE SUGESP_SANEAMENTO_SITFUNCPONT SET status_processamento = 'OK' , data_processamento = sysdate where status_processamento is null AND data_processamento IS NULL and ID = C1.ID; COMMIT;--novo em 23/3/21




--2Âª OPCAO - EXCLUIR SITUACAO FUNCIONAL
ELSIF c1.o_que_fazer = 'D' AND C1.COD_SIT_FUNC IS NOT NULL
AND C1.ORIGEM = 'SITUACAO FUNCIONAL'--NOVO 23/3/21
AND  TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY')) <= TRUNC(vDATA_CORTE)--novo em 20/7/21
 THEN
dbms_output.put_line('--EXCLUIR SITUACAO FUNCIONAL');
dbms_output.put_line('DELETE RHCGED_ALT_SIT_FUN WHERE CODIGO_EMPRESA = ''' || LPAD(C1.CODIGO_EMPRESA, 4,0) || ''' AND TIPO_CONTRATO = '''|| LPAD(C1.TIPO_CONTRATO, 4,0) ||''' AND CODIGO = '''|| LPAD(C1.CODIGO_CONTRATO, 15,0) || ''' AND trunc(DATA_INIC_SITUACAO) =  TO_DATE('''|| TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY') || ''',''DD/MM/YYYY''); COMMIT;' );
DELETE RHCGED_ALT_SIT_FUN WHERE CODIGO_EMPRESA = LPAD(C1.CODIGO_EMPRESA, 4,0) AND TIPO_CONTRATO = LPAD(C1.TIPO_CONTRATO, 4,0) AND CODIGO = LPAD(C1.CODIGO_CONTRATO, 15,0) AND trunc(DATA_INIC_SITUACAO) = TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY'),'DD/MM/YYYY'); COMMIT;
dbms_output.put_line('');
UPDATE SUGESP_SANEAMENTO_SITFUNCPONT SET status_processamento = 'OK' , data_processamento = sysdate where status_processamento is null AND data_processamento IS NULL and ID = C1.ID; COMMIT;--novo em 23/3/21




--3Âª OPCAO - INCLUIR SITUACAO PONTO
ELSIF c1.o_que_fazer = 'I' AND C1.COD_SIT_PONTO IS NOT NULL 
AND C1.ORIGEM = 'SITUACAO PONTO'--NOVO 23/3/21
AND  TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY')) <= TRUNC(vDATA_CORTE)--novo em 20/7/21
THEN
dbms_output.put_line('--INCLUIR SITUACAO PONTO');
IF C1.TIPO_REFERENCIA = 'D'  THEN
dbms_output.put_line('INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, TIPO_APURACAO, DT_ULT_ALTER_USUA, LOGIN_USUARIO, TEXTO_ASSOCIADO) VALUES ('''|| LPAD(C1.CODIGO_EMPRESA, 4,0) ||''','''|| LPAD(C1.TIPO_CONTRATO, 4,0) ||''','''|| LPAD(C1.CODIGO_CONTRATO, 15,0) ||''', TO_DATE('''|| TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY') ||''',''DD/MM/YYYY''),''' || LPAD(C1.COD_SIT_PONTO,4,0) ||''', 1, ''F'', SYSDATE, ''script_saneamento_aposentadoria'', ''Alteracao realizada em virtude do Projeto Saneamento Aposentadoria.'''|| C1.TEXTO_ASSOCIADO ||'); COMMIT;' );
delete RHPONT_RES_SIT_DIA where CODIGO_EMPRESA = LPAD(C1.CODIGO_EMPRESA, 4,0) and TIPO_CONTRATO = LPAD(C1.TIPO_CONTRATO, 4,0) and CODIGO_CONTRATO = LPAD(C1.CODIGO_CONTRATO, 15,0) and  trunc(DATA) = TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY'),'DD/MM/YYYY') and CODIGO_SITUACAO = LPAD(C1.COD_SIT_PONTO,4,0) and  TIPO_APURACAO = 'F'; COMMIT;
INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, TIPO_APURACAO, DT_ULT_ALTER_USUA, LOGIN_USUARIO, TEXTO_ASSOCIADO, FORCA_SITUACAO ) VALUES (LPAD(C1.CODIGO_EMPRESA, 4,0), LPAD(C1.TIPO_CONTRATO, 4,0), LPAD(C1.CODIGO_CONTRATO, 15,0), TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY'),'DD/MM/YYYY'), LPAD(C1.COD_SIT_PONTO,4,0), 1, 'F', SYSDATE, 'script_saneamento_aposentadoria', 'Alteracao realizada em virtude do Projeto Saneamento Aposentadoria.'|| C1.TEXTO_ASSOCIADO, 'N'); COMMIT;
dbms_output.put_line('');
ELSE
dbms_output.put_line('INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, TIPO_APURACAO, DT_ULT_ALTER_USUA, LOGIN_USUARIO, TEXTO_ASSOCIADO) VALUES ('''|| LPAD(C1.CODIGO_EMPRESA, 4,0) ||''','''|| LPAD(C1.TIPO_CONTRATO, 4,0) ||''','''|| LPAD(C1.CODIGO_CONTRATO, 15,0) ||''', TO_DATE('''|| TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY') ||''',''DD/MM/YYYY''),''' || LPAD(C1.COD_SIT_PONTO,4,0) ||''', '||C1.REFERENCIA||', ''F'', SYSDATE, ''script_saneamento_aposentadoria'', ''Alteracao realizada em virtude do Projeto Saneamento Aposentadoria.'''|| C1.TEXTO_ASSOCIADO ||'); COMMIT;' );
delete RHPONT_RES_SIT_DIA where CODIGO_EMPRESA = LPAD(C1.CODIGO_EMPRESA, 4,0) and TIPO_CONTRATO = LPAD(C1.TIPO_CONTRATO, 4,0) and CODIGO_CONTRATO = LPAD(C1.CODIGO_CONTRATO, 15,0) and  trunc(DATA) = TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY'),'DD/MM/YYYY') and CODIGO_SITUACAO = LPAD(C1.COD_SIT_PONTO,4,0) and  TIPO_APURACAO = 'F'; COMMIT;
INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, TIPO_APURACAO, DT_ULT_ALTER_USUA, LOGIN_USUARIO, TEXTO_ASSOCIADO, FORCA_SITUACAO ) VALUES (LPAD(C1.CODIGO_EMPRESA, 4,0), LPAD(C1.TIPO_CONTRATO, 4,0), LPAD(C1.CODIGO_CONTRATO, 15,0), TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY'),'DD/MM/YYYY'), LPAD(C1.COD_SIT_PONTO,4,0), C1.REFERENCIA, 'F', SYSDATE, 'script_saneamento_aposentadoria', 'Alteracao realizada em virtude do Projeto Saneamento Aposentadoria.'|| C1.TEXTO_ASSOCIADO, 'N'); COMMIT;
dbms_output.put_line('');
END IF;
UPDATE SUGESP_SANEAMENTO_SITFUNCPONT SET status_processamento = 'OK' , data_processamento = sysdate where status_processamento is null AND data_processamento IS NULL and ID = C1.ID; COMMIT;--novo em 23/3/21



--4Âª OPCAO - EXCLUIR SITUACAO PONTO
ELSIF c1.o_que_fazer = 'D' AND C1.COD_SIT_PONTO IS NOT NULL 
AND C1.ORIGEM = 'SITUACAO PONTO'--NOVO 23/3/21
AND  TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY')) <= TRUNC(vDATA_CORTE)--novo em 20/7/21
THEN
dbms_output.put_line('--EXCLUIR SITUACAO PONTO');
dbms_output.put_line('DELETE RHPONT_RES_SIT_DIA WHERE TIPO_APURACAO  = ''F'' AND CODIGO_EMPRESA = '''|| LPAD(C1.CODIGO_EMPRESA, 4,0) || ''' AND TIPO_CONTRATO = '''|| LPAD(C1.TIPO_CONTRATO, 4,0) || ''' AND CODIGO_CONTRATO =''' || LPAD(C1.CODIGO_CONTRATO, 15,0) || ''' AND trunc(DATA) = TO_DATE('''|| TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY') ||''',''DD/MM/YYYY'') AND CODIGO_SITUACAO = '''|| LPAD(C1.COD_SIT_PONTO,4,0) ||'''; COMMIT;');
DELETE RHPONT_RES_SIT_DIA WHERE TIPO_APURACAO = 'F' AND CODIGO_EMPRESA = LPAD(C1.CODIGO_EMPRESA, 4,0) AND TIPO_CONTRATO = LPAD(C1.TIPO_CONTRATO, 4,0) AND CODIGO_CONTRATO = LPAD(C1.CODIGO_CONTRATO, 15,0) AND trunc(DATA) = TO_DATE(TO_CHAR((TO_DATE('01/01/1900','DD/MM/YYYY')+ C1.DATA_INICIO)-2,'DD/MM/YYYY'), 'DD/MM/YYYY') AND CODIGO_SITUACAO = LPAD(C1.COD_SIT_PONTO,4,0); COMMIT;
dbms_output.put_line('');
UPDATE SUGESP_SANEAMENTO_SITFUNCPONT SET status_processamento = 'OK' , data_processamento = sysdate where status_processamento is null AND data_processamento IS NULL and ID = C1.ID; COMMIT;--novo em 23/3/21




-------------------------------------------------------FIM----------------------- 1Âº IF PARA AS INCLUSÃ•ES E EXCLUSÃ•ES DE SITUAÃ‡AO FUNCIONAL E PONTO
ELSE--novo em 23/3/21

--MARCAR COMO IMPORTADO OS REGISTROS QUE ESTAVAM PENDENTES
dbms_output.put_line('---------------------------------***********************************---------------------------------------');
dbms_output.put_line('--MARCAR COMO IMPORTADO OS REGISTROS QUE ESTAVAM PENDENTES');
dbms_output.put_line('UPDATE SUGESP_SANEAMENTO_SITFUNCPONT SET status_processamento = ''ER'' , data_processamento = sysdate where status_processamento is null AND data_processamento IS NULL and ID = '||C1.ID||'; COMMIT;' );
UPDATE SUGESP_SANEAMENTO_SITFUNCPONT SET status_processamento = 'ER' , data_processamento = sysdate where status_processamento is null AND data_processamento IS NULL and ID = C1.ID; COMMIT;
END IF;

/*CANCELADO
-------------------------------------------------------INICIO 1Âº IF PARA AS INCLUSÃ•ES E EXCLUSÃ•ES DE MOVIMENTAÃ‡Ã•ES
IF C1.COD_MOVIMENTACAO IS NOT NULL AND C1.COD_MOVIMENTACAO NOT IN (11,12) THEN
dbms_output.put_line('');
dbms_output.put_line('--GRAVA com os 4 agrupadores iguais' );
dbms_output.put_line('INSERT INTO RHCGED_TRANSFERENC (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO, DT_ALT_UNID_CUSTO, COD_MOVIMENTACAO, dt_fim_temp, TEXTO_ASSOCIADO, LOGIN_USUARIO, DT_ULT_ALTER_USUA, C_LIVRE_DATA01, COD_LOTACAO_ATUAL1, COD_LOTACAO_ATUAL2, COD_LOTACAO_ATUAL3, COD_LOTACAO_ATUAL4, COD_LOTACAO_ATUAL5, COD_LOTACAO_ATUAL6,COD_UNIDADE_ATUAL1, COD_UNIDADE_ATUAL2, COD_UNIDADE_ATUAL3, COD_UNIDADE_ATUAL4, COD_UNIDADE_ATUAL5, COD_UNIDADE_ATUAL6,COD_CCONTAB_ATUAL1, COD_CCONTAB_ATUAL2, COD_CCONTAB_ATUAL3, COD_CCONTAB_ATUAL4, COD_CCONTAB_ATUAL5, COD_CCONTAB_ATUAL6,COD_CGERENC_ATUAL1, COD_CGERENC_ATUAL2, COD_CGERENC_ATUAL3, COD_CGERENC_ATUAL4, COD_CGERENC_ATUAL5, COD_CGERENC_ATUAL6)VALUES(LPAD('''||C1.CODIGO_EMPRESA ||''', 4,0), LPAD(''' || C1.TIPO_CONTRATO ||''',4,0), LPAD(''' || C1.CODIGO_CONTRATO ||''',15,0), TO_DATE(TO_CHAR((TO_DATE(''01/01/1900'',''DD/MM/YYYY'')+ '||C1.DATA_INICIO||')-2,''DD/MM/YYYY'')), LPAD(''' || C1.COD_MOVIMENTACAO ||''',4,0), TO_DATE(TO_CHAR((TO_DATE(''01/01/1900'',''DD/MM/YYYY'')+ '||C
1.DATA_FIM||')-2,''DD/MM/YYYY'')), ''GERADA PELO SANEAMENTO DE SITUACAO FUNCIONAL'', ''script_saneamento_aposentadoria'', sysdate, TO_DATE(TO_CHAR((TO_DATE(''01/01/1900'',''DD/MM/YYYY'')+ '||C1.DATA_DOM||')-2,''DD/MM/YYYY'')),'''|| C1.COD_LOTACAO_ATUAL1 || ''','''|| C1.COD_LOTACAO_ATUAL2 || ''','''|| C1.COD_LOTACAO_ATUAL3 || ''','''|| C1.COD_LOTACAO_ATUAL4 || ''','''|| C1.COD_LOTACAO_ATUAL5 || ''','''|| C1.COD_LOTACAO_ATUAL6|| ''','''|| C1.COD_UNIDADE_ATUAL1 || ''','''|| C1.COD_UNIDADE_ATUAL2 || ''','''|| C1.COD_UNIDADE_ATUAL3 || ''','''|| C1.COD_UNIDADE_ATUAL4 || ''','''|| C1.COD_UNIDADE_ATUAL5 || ''','''|| C1.COD_UNIDADE_ATUAL6 || ''','''|| C1.COD_CCONTAB_ATUAL1 || ''','''|| C1.COD_CCONTAB_ATUAL2 || ''','''|| C1.COD_CCONTAB_ATUAL3 || ''','''|| C1.COD_CCONTAB_ATUAL4 || ''','''|| C1.COD_CCONTAB_ATUAL5 || ''','''|| C1.COD_CCONTAB_ATUAL6 || ''','''|| C1.COD_CGERENC_ATUAL1 || ''','''|| C1.COD_CGERENC_ATUAL2 || ''','''|| C1.COD_CGERENC_ATUAL3 || ''','''|| C1.COD_CGERENC_ATUAL4 || ''','''|| C1.COD_CGERENC_ATUAL5
|| ''','''|| C1.COD_CGERENC_ATUAL6 ||''');COMMIT;');

ELSIF C1.COD_MOVIMENTACAO IS NOT NULL AND C1.COD_MOVIMENTACAO = 11 THEN
dbms_output.put_line('');
dbms_output.put_line('--COD_MOV = 11 - ALTERA os 3 agrupadores  = 99.98.04.00.00.002' );
dbms_output.put_line('INSERT INTO RHCGED_TRANSFERENC (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO, DT_ALT_UNID_CUSTO, COD_MOVIMENTACAO, dt_fim_temp, TEXTO_ASSOCIADO, LOGIN_USUARIO, DT_ULT_ALTER_USUA, C_LIVRE_DATA01, COD_LOTACAO_ATUAL1, COD_LOTACAO_ATUAL2, COD_LOTACAO_ATUAL3, COD_LOTACAO_ATUAL4, COD_LOTACAO_ATUAL5, COD_LOTACAO_ATUAL6,COD_UNIDADE_ATUAL1, COD_UNIDADE_ATUAL2, COD_UNIDADE_ATUAL3, COD_UNIDADE_ATUAL4, COD_UNIDADE_ATUAL5, COD_UNIDADE_ATUAL6,COD_CCONTAB_ATUAL1, COD_CCONTAB_ATUAL2, COD_CCONTAB_ATUAL3, COD_CCONTAB_ATUAL4, COD_CCONTAB_ATUAL5, COD_CCONTAB_ATUAL6,COD_CGERENC_ATUAL1, COD_CGERENC_ATUAL2, COD_CGERENC_ATUAL3, COD_CGERENC_ATUAL4, COD_CGERENC_ATUAL5, COD_CGERENC_ATUAL6)VALUES(LPAD('''||C1.CODIGO_EMPRESA ||''', 4,0), LPAD(''' || C1.TIPO_CONTRATO ||''',4,0), LPAD(''' || C1.CODIGO_CONTRATO ||''',15,0), TO_DATE(TO_CHAR((TO_DATE(''01/01/1900'',''DD/MM/YYYY'')+ '||C1.DATA_INICIO||')-2,''DD/MM/YYYY'')), LPAD(''' || C1.COD_MOVIMENTACAO ||''',4,0), TO_DATE(TO_CHAR((TO_DATE(''01/01/1900'',''DD/MM/YYYY'')+ '||C
1.DATA_FIM||')-2,''DD/MM/YYYY'')), ''GERADA PELO SANEAMENTO DE SITUACAO FUNCIONAL'', ''script_saneamento_aposentadoria'', sysdate, TO_DATE(TO_CHAR((TO_DATE(''01/01/1900'',''DD/MM/YYYY'')+ '||C1.DATA_DOM||')-2,''DD/MM/YYYY'')),'|| '''000099'',''000098'',''000004'',''000000'',''000000'',''000002'',''000099'',''000098'',''000004'',''000000'',''000000'',''000002'','''||C1.COD_CCONTAB_ATUAL1 || ''','''|| C1.COD_CCONTAB_ATUAL2 || ''','''|| C1.COD_CCONTAB_ATUAL3 || ''','''|| C1.COD_CCONTAB_ATUAL4 || ''','''|| C1.COD_CCONTAB_ATUAL5 || ''','''|| C1.COD_CCONTAB_ATUAL6 || ''','|| '''000099'',''000098'',''000004'',''000000'',''000000'',''000002'');COMMIT;');

ELSIF C1.COD_MOVIMENTACAO IS NOT NULL AND C1.COD_MOVIMENTACAO = 12 THEN
dbms_output.put_line('');
dbms_output.put_line('--COD_MOV = 12 - ALTERA os 3 agrupadores  = 99.98.04.00.00.001' );
dbms_output.put_line('INSERT INTO RHCGED_TRANSFERENC (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO, DT_ALT_UNID_CUSTO, COD_MOVIMENTACAO, dt_fim_temp, TEXTO_ASSOCIADO, LOGIN_USUARIO, DT_ULT_ALTER_USUA, C_LIVRE_DATA01, COD_LOTACAO_ATUAL1, COD_LOTACAO_ATUAL2, COD_LOTACAO_ATUAL3, COD_LOTACAO_ATUAL4, COD_LOTACAO_ATUAL5, COD_LOTACAO_ATUAL6,COD_UNIDADE_ATUAL1, COD_UNIDADE_ATUAL2, COD_UNIDADE_ATUAL3, COD_UNIDADE_ATUAL4, COD_UNIDADE_ATUAL5, COD_UNIDADE_ATUAL6,COD_CCONTAB_ATUAL1, COD_CCONTAB_ATUAL2, COD_CCONTAB_ATUAL3, COD_CCONTAB_ATUAL4, COD_CCONTAB_ATUAL5, COD_CCONTAB_ATUAL6,COD_CGERENC_ATUAL1, COD_CGERENC_ATUAL2, COD_CGERENC_ATUAL3, COD_CGERENC_ATUAL4, COD_CGERENC_ATUAL5, COD_CGERENC_ATUAL6)VALUES(LPAD('''||C1.CODIGO_EMPRESA ||''', 4,0), LPAD(''' || C1.TIPO_CONTRATO ||''',4,0), LPAD(''' || C1.CODIGO_CONTRATO ||''',15,0), TO_DATE(TO_CHAR((TO_DATE(''01/01/1900'',''DD/MM/YYYY'')+ '||C1.DATA_INICIO||')-2,''DD/MM/YYYY'')), LPAD(''' || C1.COD_MOVIMENTACAO ||''',4,0), TO_DATE(TO_CHAR((TO_DATE(''01/01/1900'',''DD/MM/YYYY'')+ '||C
1.DATA_FIM||')-2,''DD/MM/YYYY'')), ''GERADA PELO SANEAMENTO DE SITUACAO FUNCIONAL'', ''script_saneamento_aposentadoria'', sysdate, TO_DATE(TO_CHAR((TO_DATE(''01/01/1900'',''DD/MM/YYYY'')+ '||C1.DATA_DOM||')-2,''DD/MM/YYYY'')),'|| '''000099'',''000098'',''000004'',''000000'',''000000'',''000001'',''000099'',''000098'',''000004'',''000000'',''000000'',''000001'','''||C1.COD_CCONTAB_ATUAL1 || ''','''|| C1.COD_CCONTAB_ATUAL2 || ''','''|| C1.COD_CCONTAB_ATUAL3 || ''','''|| C1.COD_CCONTAB_ATUAL4 || ''','''|| C1.COD_CCONTAB_ATUAL5 || ''','''|| C1.COD_CCONTAB_ATUAL6 || ''','|| '''000099'',''000098'',''000004'',''000000'',''000000'',''000001'');COMMIT;');

END IF;

------------------------------------------------------FIM 1Âº IF PARA AS INCLUSÃ•ES E EXCLUSÃ•ES DE MOVIMENTAÃ‡Ã•ES
*/
END LOOP;
--UPDATE SUGESP_SANEAMENTO_SITFUNCPONT SET status_processamento = 'OK', data_processamento = sysdate where status_processamento is null; COMMIT;


/*CANCELADO
--AJUSTES NAS DATAS DA MOVIMENTACAO DEVIDO A VIRADA DE MILENIO
dbms_output.put_line('');
dbms_output.put_line('--AJUSTES NAS DATAS DA MOVIMENTACAO DEVIDO A VIRADA DE MILENIO');
dbms_output.put_line('update RHCGED_TRANSFERENC set DT_ALT_UNID_CUSTO = ADD_MONTHS(DT_ALT_UNID_CUSTO, -1200)  where trunc(DT_ALT_UNID_CUSTO)> trunc(sysdate) AND TRUNC(DT_ULT_ALTER_USUA) = TRUNC(SYSDATE); COMMIT;');
dbms_output.put_line('update RHCGED_TRANSFERENC set dt_fim_temp = ADD_MONTHS(dt_fim_temp, -1200)  where trunc(dt_fim_temp)> trunc(sysdate) AND TRUNC(DT_ULT_ALTER_USUA) = TRUNC(SYSDATE); COMMIT;');
dbms_output
.put_line('update RHCGED_TRANSFERENC set c_livre_data01 = ADD_MONTHS(c_livre_data01, -1200)  where trunc(c_livre_data01)> trunc(sysdate) AND TRUNC(DT_ULT_ALTER_USUA) = TRUNC(SYSDATE); COMMIT;');
*/
END;
END;-- END 1Ã‚Âº BEGIN