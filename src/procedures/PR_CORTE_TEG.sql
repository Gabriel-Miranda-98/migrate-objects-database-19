
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_CORTE_TEG" --(ID NUMBER) 

AS
--KELLYSSON 20/9/19
BEGIN

DECLARE
--vID number;
vTC1_DADO_DESTINO VARCHAR2 (80);

vQTD_DOENCA_C_LIVRE_OPCAO01 number;
vQTD_TC2_DADO_ORIGEM number;
vQTD_TC3_DADO_ORIGEM number;

begin
dbms_output.enable(null);
--vID := ID; 


FOR C1 IN (

SELECT  
--x.id, x.new_NATUREZA_EXAME,
--C.codigo_empresa, C.tipo_contrato, C.codigo, 
c.nome, C.SITUACAO_FUNCIONAL cod_sit_func, C.ANO_MES_REFERENCIA,
V.CODIGO COD_VINCULO, V.DESCRICAO VINCULO
,RG_TRAB.CONTEUDO_INICIAL cod_TP_REGIME_TRAB_ESOCIAL, RG_TRAB.DESCR_IT_DOMINIO TP_REGIME_TRAB_ESOCIAL
,RG_PREV.CONTEUDO_INICIAL cod_TP_REGIME_PREV_ESOCIAL, RG_PREV.DESCR_IT_DOMINIO TP_REGIME_PREV_ESOCIAL
,COD_CATEG.CONTEUDO_INICIAL cod_COD_CATEG_ESOCIAL, COD_CATEG.DESCR_IT_DOMINIO  COD_CATEG_ESOCIAL , 
 c.data_admissao, c.data_posse, c.data_efetivo_exerc, c.data_base_ferias, c.data_rescisao, c.data_inic_afast, c.data_fim_afast

,ULT_ASF.data_inic_situacao ULT_ASF_data_inic_situacao, ULT_ASF.cod_sit_funcional ULT_ASF_cod_sit_funcional, ULT_ASF.data_fim_situacao ULT_ASF_data_fim_situacao, ULT_ASF.MOTIVO_AFAST ULT_ASF_MOTIVO_AFAST, ULT_ASF.c_livre_data01 ULT_ASF_DATA_DOM
,ULT_ASF_SF.CONTROLE_FOLHA ULT_ASF_SF_CONTROLE_FOLHA, ULT_ASF_SF.e_afastamento ULT_ASF_SF_e_afastamento, to_char(lpad(ULT_ASF_SF.c_livre_valor03,4,0)) ULT_ASF_SF_CAUSA_RESCISAO, to_char(lpad(ULT_ASF_SF.c_livre_valor04,4,0)) ULT_ASF_SF_COD_MOVIMENTACAO,

X.ID, 
X.TABELA, X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.CODIGO_PESSOA, X.DT_REG_OCORRENCIA, X.OCORRENCIA,  X.NEW_DATA_INI_AFAST, X.NEW_DATA_FIM_AFAST
,NULL ORDEM_PROCESSO
,X.LOGIN_USUARIO, X.LOGIN_OS
FROM SUGESP_FICHAS_MEDICAS X 
LEFT OUTER JOIN (SELECT C.* FROM RHPESS_CONTRATO C WHERE C.ANO_MES_REFERENCIA = (select max(AUX.ano_mes_referencia) from rhpess_contrato AUX where AUX.codigo_empresa = c.codigo_empresa and AUX.tipo_contrato = c.tipo_contrato and AUX.codigo = c.codigo))C ON C.CODIGO_EMPRESA = X.CODIGO_EMPRESA AND C.TIPO_CONTRATO = X.TIPO_CONTRATO AND C.CODIGO = X.CODIGO_CONTRATO
LEFT OUTER JOIN (SELECT ULT_ASF.* FROM RHCGED_ALT_SIT_FUN ULT_ASF WHERE ULT_ASF.DATA_INIC_SITUACAO = (SELECT MAX(AUX.data_inic_situacao) FROM RHCGED_ALT_SIT_FUN AUX WHERE AUX.CODIGO_EMPRESA =  ULT_ASF.CODIGO_EMPRESA AND AUX.TIPO_CONTRATO = ULT_ASF.TIPO_CONTRATO AND AUX.CODIGO = ULT_ASF.CODIGO))ULT_ASF ON X.CODIGO_EMPRESA = ULT_ASF.CODIGO_EMPRESA AND X.TIPO_CONTRATO = ULT_ASF.TIPO_CONTRATO AND X.CODIGO_CONTRATO = ULT_ASF.CODIGO 
LEFT OUTER JOIN RHPARM_SIT_FUNC ULT_ASF_SF ON ULT_ASF_SF.CODIGO = ULT_ASF.cod_sit_funcional
left outer join RHTABS_VINCULO_EMP V ON V.CODIGO = c.VINCULO
LEFT OUTER JOIN (select * from rhtabs_itds_sist WHERE CODIGO_DOMINIO IN (select CODIGO_DOMINIO from RHTABS_COLS_SIST  where codigo_tabela = 'RHTABS_VINCULO_EMP' and codigo_coluna = 'TP_REGIME_TRAB_ESOCIAL'))RG_TRAB
ON RG_TRAB.CONTEUDO_INICIAL = V.TP_REGIME_TRAB_ESOCIAL
LEFT OUTER JOIN (select * from rhtabs_itds_sist WHERE CODIGO_DOMINIO IN (select CODIGO_DOMINIO from RHTABS_COLS_SIST  where codigo_tabela = 'RHTABS_VINCULO_EMP' and codigo_coluna = 'TP_REGIME_PREV_ESOCIAL'))RG_PREV
ON RG_PREV.CONTEUDO_INICIAL = V.TP_REGIME_PREV_ESOCIAL
LEFT OUTER JOIN (select * from rhtabs_itds_sist WHERE CODIGO_DOMINIO IN (select CODIGO_DOMINIO from RHTABS_COLS_SIST  where codigo_tabela = 'RHTABS_VINCULO_EMP' and codigo_coluna = 'COD_CATEG_ESOCIAL'))COD_CATEG
ON COD_CATEG.CONTEUDO_INICIAL = V.COD_CATEG_ESOCIAL

WHERE X.processado is null AND X.TABELA ='RHMEDI_FICHA_MED' AND X.NEW_DATA_INI_AFAST IS NOT NULL AND X.NEW_DATA_FIM_AFAST IS NOT NULL
and (trunc(X.NEW_DATA_INI_AFAST) < to_date('01/10/19','dd/mm/yy') and trunc(X.NEW_DATA_FIM_AFAST)>= to_date('01/10/19','dd/mm/yy'))

and x.new_NATUREZA_EXAME in ('0104', '0105', '0107', '0108', '0113', '0114', '0115', '0116')
--and c.CODIGO_PROC_MED is not null
--and c.codigo_proc_med in   ('000000000000001', '000000000000003', '000000000000017', '000000000000027')

)

LOOP
dbms_output.put_line('loop 1 - '||C1.CODIGO_CONTRATO);

vQTD_DOENCA_C_LIVRE_OPCAO01 := 0;
vQTD_TC2_DADO_ORIGEM := 0;
vQTD_TC3_DADO_ORIGEM := 0;

FOR C2 IN (

SELECT 
COUNT(1)QUANT, X2.TC1_DADO_ORIGEM, X2.TC1_DADO_DESTINO, X2.TC2_DADO_ORIGEM, X2.TC2_DADO_DESTINO, X2.TC3_DADO_ORIGEM, X2.TC3_DADO_DESTINO,
X2.CODIGO_EMPRESA, X2.TIPO_CONTRATO, X2.CODIGO_CONTRATO, X2.CODIGO_PESSOA, X2.DT_REG_OCORRENCIA, X2.OCORRENCIA, X2.DATA_INI_AFAST, X2.DATA_FIM_AFAST
,X2.ULT_ASF_data_inic_situacao, X2.ULT_ASF_cod_sit_funcional, X2.ULT_ASF_data_fim_situacao, X2.ULT_ASF_SF_CONTROLE_FOLHA, X2.ULT_ASF_SF_e_afastamento
--,X2.cod_TP_REGIME_TRAB_ESOCIAL, X2.cod_TP_REGIME_PREV_ESOCIAL, X2.cod_COD_CATEG_ESOCIAL
,X2.DOENCA_C_LIVRE_OPCAO01 --,X2.DOENCA_C_LIVRE_DESCR02
FROM(
SELECT 
TC1.DADO_ORIGEM TC1_DADO_ORIGEM, TC1.DADO_DESTINO TC1_DADO_DESTINO,
TC2.DADO_ORIGEM TC2_DADO_ORIGEM, TC2.DADO_DESTINO TC2_DADO_DESTINO,
TC3.DADO_ORIGEM TC3_DADO_ORIGEM, TC3.DADO_DESTINO TC3_DADO_DESTINO,
F.CODIGO_EMPRESA, F.TIPO_CONTRATO, F.CODIGO_CONTRATO, F.CODIGO_PESSOA, F.DT_REG_OCORRENCIA, F.OCORRENCIA, 
--F.NATUREZA_EXAME, n.descricao PROCEDIMENTO,
F.DATA_INI_AFAST, F.DATA_FIM_AFAST --,F.C_LIVRE_DATA01 DATA_INICIAL_INDEFERIMENTO, F.C_LIVRE_DATA02 DATA_FINAL_INDEFERIMENTO,
--C.CODIGO_PROC_MED, P.DESCRICAO CONDUTA,
--D.COD_DOENCA, DOE.DESCRICAO DOENCA
,DOE.C_LIVRE_OPCAO01 DOENCA_C_LIVRE_OPCAO01, DOE.C_LIVRE_DESCR02 DOENCA_C_LIVRE_DESCR02--,

,ULT_ASF.data_inic_situacao ULT_ASF_data_inic_situacao, ULT_ASF.cod_sit_funcional ULT_ASF_cod_sit_funcional, ULT_ASF.data_fim_situacao ULT_ASF_data_fim_situacao
--,ULT_ASF.MOTIVO_AFAST ULT_ASF_MOTIVO_AFAST, ULT_ASF.c_livre_data01 ULT_ASF_DATA_DOM
,ULT_ASF_SF.CONTROLE_FOLHA ULT_ASF_SF_CONTROLE_FOLHA, ULT_ASF_SF.e_afastamento ULT_ASF_SF_e_afastamento
--,to_char(lpad(ULT_ASF_SF.c_livre_valor03,4,0)) ULT_ASF_SF_CAUSA_RESCISAO, to_char(lpad(ULT_ASF_SF.c_livre_valor04,4,0)) ULT_ASF_SF_COD_MOVIMENTACAO

--C.codigo_empresa, C.tipo_contrato, C.codigo, c.nome, C.SITUACAO_FUNCIONAL cod_sit_func, C.ANO_MES_REFERENCIA,
--V.CODIGO COD_VINCULO, V.DESCRICAO VINCULO
--,RG_TRAB.CONTEUDO_INICIAL cod_TP_REGIME_TRAB_ESOCIAL--, RG_TRAB.DESCR_IT_DOMINIO TP_REGIME_TRAB_ESOCIAL
--,RG_PREV.CONTEUDO_INICIAL cod_TP_REGIME_PREV_ESOCIAL--, RG_PREV.DESCR_IT_DOMINIO TP_REGIME_PREV_ESOCIAL
--,COD_CATEG.CONTEUDO_INICIAL cod_COD_CATEG_ESOCIAL--, COD_CATEG.DESCR_IT_DOMINIO  COD_CATEG_ESOCIAL  
-- ,c.data_admissao, c.data_posse, c.data_efetivo_exerc, c.data_base_ferias, c.data_rescisao, c.data_inic_afast, c.data_fim_afast

FROM 
RHMEDI_FICHA_MED F 
full outer join RHMEDI_NATUREZA_EX n on F.natureza_exame = n.codigo and F.codigo_empresa = n.codigo_empresa
FULL OUTER JOIN RHMEDI_RL_FICH_PRO C ON F.CODIGO_EMPRESA = C.CODIGO_EMPRESA AND F.CODIGO_PESSOA = C.CODIGO_PESSOA AND F.DT_REG_OCORRENCIA = C.DT_REG_OCORRENCIA AND F.OCORRENCIA = C.OCORRENCIA
left outer join RHMEDI_PROC_MED P ON P.CODIGO_PROC_MED = C.codigo_proc_med
full OUTER JOIN RHMEDI_RL_FICH_DOE D ON F.CODIGO_EMPRESA = D.CODIGO_EMPRESA AND F.CODIGO_PESSOA = D.CODIGO_PESSOA AND F.DT_REG_OCORRENCIA = D.DT_REG_OCORRENCIA AND D.OCORRENCIA = C.OCORRENCIA
full OUTER JOIN RHMEDI_DOENCA DOE ON DOE.CODIGO = D.COD_DOENCA

LEFT OUTER JOIN (SELECT C.* FROM RHPESS_CONTRATO C WHERE C.ANO_MES_REFERENCIA = (select max(AUX.ano_mes_referencia) from rhpess_contrato AUX where AUX.codigo_empresa = c.codigo_empresa and AUX.tipo_contrato = c.tipo_contrato and AUX.codigo = c.codigo))C ON C.CODIGO_EMPRESA = F.CODIGO_EMPRESA AND C.TIPO_CONTRATO = F.TIPO_CONTRATO AND C.CODIGO = F.CODIGO_CONTRATO
LEFT OUTER JOIN (SELECT ULT_ASF.* FROM RHCGED_ALT_SIT_FUN ULT_ASF WHERE ULT_ASF.DATA_INIC_SITUACAO = (SELECT MAX(AUX.data_inic_situacao) FROM RHCGED_ALT_SIT_FUN AUX WHERE AUX.CODIGO_EMPRESA =  ULT_ASF.CODIGO_EMPRESA AND AUX.TIPO_CONTRATO = ULT_ASF.TIPO_CONTRATO AND AUX.CODIGO = ULT_ASF.CODIGO))ULT_ASF ON F.CODIGO_EMPRESA = ULT_ASF.CODIGO_EMPRESA AND F.TIPO_CONTRATO = ULT_ASF.TIPO_CONTRATO AND F.CODIGO_CONTRATO = ULT_ASF.CODIGO 
LEFT OUTER JOIN RHPARM_SIT_FUNC ULT_ASF_SF ON ULT_ASF_SF.CODIGO = ULT_ASF.cod_sit_funcional
left outer join RHTABS_VINCULO_EMP V ON V.CODIGO = c.VINCULO
LEFT OUTER JOIN (select * from rhtabs_itds_sist WHERE CODIGO_DOMINIO IN (select CODIGO_DOMINIO from RHTABS_COLS_SIST  where codigo_tabela = 'RHTABS_VINCULO_EMP' and codigo_coluna = 'TP_REGIME_TRAB_ESOCIAL'))RG_TRAB
ON RG_TRAB.CONTEUDO_INICIAL = V.TP_REGIME_TRAB_ESOCIAL
LEFT OUTER JOIN (select * from rhtabs_itds_sist WHERE CODIGO_DOMINIO IN (select CODIGO_DOMINIO from RHTABS_COLS_SIST  where codigo_tabela = 'RHTABS_VINCULO_EMP' and codigo_coluna = 'TP_REGIME_PREV_ESOCIAL'))RG_PREV
ON RG_PREV.CONTEUDO_INICIAL = V.TP_REGIME_PREV_ESOCIAL
LEFT OUTER JOIN (select * from rhtabs_itds_sist WHERE CODIGO_DOMINIO IN (select CODIGO_DOMINIO from RHTABS_COLS_SIST  where codigo_tabela = 'RHTABS_VINCULO_EMP' and codigo_coluna = 'COD_CATEG_ESOCIAL'))COD_CATEG
ON COD_CATEG.CONTEUDO_INICIAL = V.COD_CATEG_ESOCIAL

LEFT OUTER JOIN(SELECT * FROM RHINTE_ED_IT_CONV where codigo_CONVERSAO ='TEG1')TC1 ON SUBSTR(TC1.DADO_ORIGEM,1,24) = F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.tp_regime_trab_esocial|| V.tp_regime_prev_esocial||V.cod_categ_esocial --PROCEDIMENTO

LEFT OUTER JOIN(SELECT * FROM RHINTE_ED_IT_CONV where codigo_CONVERSAO ='TEG2')TC2 ON SUBSTR(TC2.DADO_ORIGEM,1,24) = F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.tp_regime_trab_esocial|| V.tp_regime_prev_esocial||V.cod_categ_esocial 
                                                                                AND SUBSTR(TC2.DADO_ORIGEM,25,LENGTH(TC2.DADO_ORIGEM)) =  DOE.C_LIVRE_DESCR02 --1Âª DOENCA 

LEFT OUTER JOIN(SELECT * FROM RHINTE_ED_IT_CONV where codigo_CONVERSAO ='TEG3')TC3 ON SUBSTR(TC3.DADO_ORIGEM,1,24) = F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.tp_regime_trab_esocial|| V.tp_regime_prev_esocial||V.cod_categ_esocial 
                                                                                AND SUBSTR(TC3.DADO_ORIGEM,25,LENGTH(TC3.DADO_ORIGEM)) =  DOE.C_LIVRE_DESCR02 --2Âª DOENCA 

WHERE EXISTS (
SELECT X.* FROM SUGESP_FICHAS_MEDICAS X WHERE X.ID = 2185
AND  F.CODIGO_EMPRESA = X.CODIGO_EMPRESA AND F.CODIGO_PESSOA = X.CODIGO_PESSOA AND F.DT_REG_OCORRENCIA = X.DT_REG_OCORRENCIA AND F.OCORRENCIA = X.OCORRENCIA)
--AND (DOE.C_LIVRE_OPCAO01  = 'S' OR DOE.C_LIVRE_DESCR02 IS NOT NULL)
)X2

GROUP BY X2.TC1_DADO_ORIGEM, X2.TC1_DADO_DESTINO,
X2.TC2_DADO_ORIGEM, X2.TC2_DADO_DESTINO, X2.TC3_DADO_ORIGEM, X2.TC3_DADO_DESTINO,
X2.CODIGO_EMPRESA, X2.TIPO_CONTRATO, X2.CODIGO_CONTRATO, X2.CODIGO_PESSOA, X2.DT_REG_OCORRENCIA, X2.OCORRENCIA, X2.DATA_INI_AFAST, X2.DATA_FIM_AFAST
,X2.ULT_ASF_data_inic_situacao, X2.ULT_ASF_cod_sit_funcional, X2.ULT_ASF_data_fim_situacao, X2.ULT_ASF_SF_CONTROLE_FOLHA, X2.ULT_ASF_SF_e_afastamento
,X2.DOENCA_C_LIVRE_OPCAO01 --,X2.DOENCA_C_LIVRE_DESCR02
--,X2.cod_TP_REGIME_TRAB_ESOCIAL, X2.cod_TP_REGIME_PREV_ESOCIAL, X2.cod_COD_CATEG_ESOCIAL
ORDER BY
X2.TC1_DADO_ORIGEM, X2.TC1_DADO_DESTINO,
X2.TC2_DADO_ORIGEM, X2.TC2_DADO_DESTINO, X2.TC3_DADO_ORIGEM, X2.TC3_DADO_DESTINO,
X2.CODIGO_EMPRESA, X2.TIPO_CONTRATO, X2.CODIGO_CONTRATO, X2.CODIGO_PESSOA, X2.DT_REG_OCORRENCIA, X2.OCORRENCIA, X2.DATA_INI_AFAST, X2.DATA_FIM_AFAST
,X2.ULT_ASF_data_inic_situacao, X2.ULT_ASF_cod_sit_funcional, X2.ULT_ASF_data_fim_situacao, X2.ULT_ASF_SF_CONTROLE_FOLHA, X2.ULT_ASF_SF_e_afastamento
,X2.DOENCA_C_LIVRE_OPCAO01 --,X2.DOENCA_C_LIVRE_DESCR02 DESC

)
LOOP
dbms_output.put_line('loop 2 - '||C1.CODIGO_CONTRATO);

vTC1_DADO_DESTINO := C2.TC1_DADO_DESTINO ;

IF C2.DOENCA_C_LIVRE_OPCAO01 = 'S' THEN
vQTD_DOENCA_C_LIVRE_OPCAO01 := vQTD_DOENCA_C_LIVRE_OPCAO01 + 1;
END IF;

IF C2.TC2_DADO_ORIGEM IS NOT NULL THEN
vQTD_TC2_DADO_ORIGEM := vQTD_TC2_DADO_ORIGEM + 1;
END IF;

IF C2.TC3_DADO_ORIGEM IS NOT NULL THEN
vQTD_TC3_DADO_ORIGEM := vQTD_TC3_DADO_ORIGEM + 1;
END IF;

END LOOP; --LOOP 2

--AQUI TAMBEM EU CRIO O QUE TIVER QUE CRIAR NA SITUAÃ‡ÃƒO FUNCIONAL PONTO QUE ESTA PASSANDO POR 1/10/19
IF vQTD_DOENCA_C_LIVRE_OPCAO01 = 0 AND vQTD_TC2_DADO_ORIGEM = 0 AND vQTD_TC3_DADO_ORIGEM = 0 THEN
dbms_output.put_line('GRAVA SIT FUNC - '||SUBSTR(vTC1_DADO_DESTINO, 1, 4));
ELSE
dbms_output.put_line('GRAVA SIT FUNC - '||SUBSTR(vTC1_DADO_DESTINO, 17, 4));

END IF;

--PARA MARCAR COMO PROCESSADO TODOS OS REGISTROS DAS 3 TABELAS REFERENTE A FICHA MEDICA EM QUESTÃƒO. 
--update SUGESP_FICHAS_MEDICAS set PROCESSADO = 'S' where PROCESSADO IS NULL AND  CODIGO_EMPRESA = C1.CODIGO_EMPRESA AND CODIGO_PESSOA = C1.CODIGO_PESSOA AND DT_REG_OCORRENCIA = C1.DT_REG_OCORRENCIA AND OCORRENCIA = C1.OCORRENCIA;


END LOOP;--LOOP 1




end;

END;

