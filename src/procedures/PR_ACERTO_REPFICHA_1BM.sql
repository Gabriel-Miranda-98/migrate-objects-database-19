
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_ACERTO_REPFICHA_1BM" (EMPRESA IN VARCHAR2, TIPO_CONTRATO IN VARCHAR2, BM IN VARCHAR2, INICIO DATE, FIM DATE) AS 
--KELLYSSON 21/12/21
--baseado em PR_SUGESP_REPFICHAS_SANEAMENTO

BEGIN-- 1 BEGIN


DECLARE 
vEMPRESA VARCHAR2(4);
vTIPO_CONTRATO VARCHAR2(4);
vBM VARCHAR2(15);

vDATA_INICIAL date;
vDATA_FINAL date;
vCONTADOR NUMBER (10);
vCONTADOR2 NUMBER (10);
vQTD_SITUACAO NUMBER (10);
vSIT_ATUAL VARCHAR(4);
vID number(10);

vDATA_INICIO date;
vDATA_FIM date;

begin
dbms_output.enable(null);

vEMPRESA := EMPRESA;--'0001';-- EMPRESA;
vTIPO_CONTRATO := TIPO_CONTRATO;-- '0001';--TIPO_CONTRATO ;
vBM := BM;--'000000000489828';--BM; 

vDATA_INICIO := INICIO;--TO_DATE('30/03/2021','DD/MM/YYYY');-- INICIO;
vDATA_FIM := FIM; --TO_DATE('01/04/2021','DD/MM/YYYY');--FIM;

vCONTADOR :=0;
vCONTADOR2 :=0;
vQTD_SITUACAO :=0; 
vSIT_ATUAL := NULL;
vID :=0;

for c1 in(


------INICIO------------------------------NOVA LOGICA
SELECT X5.* 
,CASE 
WHEN X5.DOENCA_GRAVE = 'FICHA_COM_DOENCA_GRAVE' THEN SUBSTR(X5.DADO_DESTINO_TC1,17,4) 
WHEN X5.DOENCA_GRAVE = 'FICHA_SEM_DOENCA_GRAVE' THEN SUBSTR(X5.DADO_DESTINO_TC1,1,4) 
END SITUACAO_FUNCIONAL
,CASE 
WHEN X5.DOENCA_GRAVE = 'FICHA_COM_DOENCA_GRAVE' THEN SUBSTR(X5.DADO_DESTINO_TC1,21,4) 
WHEN X5.DOENCA_GRAVE = 'FICHA_SEM_DOENCA_GRAVE' THEN SUBSTR(X5.DADO_DESTINO_TC1,9,4) 
END SITUACAO_PONTO
FROM (
SELECT 
X4.*
,CASE 
WHEN X4.SUM_CONDUTA < 1 THEN 'FICHA_IMCOMPLETA'
--WHEN X4.SUM_CONDUTA >= 1 AND X4.SUM_SIM < 1 AND X4.SUM_TEG2 < 1 AND X4.SUM_TEG3 < 1 THEN 'FICHA SEM DOENCA GRAVE'
WHEN X4.SUM_CONDUTA >= 1 AND ( (X4.SUM_SIM >= 1) OR ( X4.SUM_TEG2 >= 1 AND X4.SUM_TEG3 >= 1 ) ) THEN 'FICHA_COM_DOENCA_GRAVE'
ELSE 'FICHA_SEM_DOENCA_GRAVE'
END DOENCA_GRAVE
FROM(

SELECT 
X3.CODIGO_EMPRESA, X3.TIPO_CONTRATO, X3.CODIGO_CONTRATO, X3.CODIGO_PESSOA, X3.dt_reg_ocorrencia, X3.OCORRENCIA,  X3.DATA_INI_AFAST , X3.DATA_FIM_AFAST,
SUM(X3.CONDUTA) SUM_CONDUTA, SUM(X3.SIM) SUM_SIM, SUM(X3.TEG2) SUM_TEG2, SUM(X3.TEG3) SUM_TEG3, X3.DADO_ORIGEM_TC1, X3.DADO_DESTINO_TC1
FROM(


SELECT
X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.CODIGO_PESSOA, X.dt_reg_ocorrencia, X.OCORRENCIA, X.DATA_INI_AFAST , X.DATA_FIM_AFAST,
1 CONDUTA, 0 SIM, 0 TEG2 , 0 TEG3, COUNT(1)QUANT, 
'CONDUTA' TIPO,
X.DADO_ORIGEM_TC1, X.DADO_DESTINO_TC1
,NULL DADO_ORIGEM_TC2, NULL DADO_DESTINO_TC2, NULL DADO_ORIGEM_TC3, NULL DADO_DESTINO_TC3
FROM (
SELECT 
F.CODIGO_EMPRESA, F.TIPO_CONTRATO, F.CODIGO_CONTRATO, F.CODIGO_PESSOA, F.dt_reg_ocorrencia, F.OCORRENCIA, F.DATA_INI_AFAST , F.DATA_FIM_AFAST,
TC1.DADO_ORIGEM DADO_ORIGEM_TC1, TC1.DADO_DESTINO DADO_DESTINO_TC1,
C.OCOR_PROC_MED, C.CODIGO_PROC_MED, A.ANO_MES_REFERENCIA, A.VINCULO, V.tp_regime_trab_esocial, V.tp_regime_prev_esocial, V.cod_categ_esocial
FROM 
RHMEDI_FICHA_MED F 
FULL OUTER JOIN RHMEDI_RL_FICH_PRO C ON F.CODIGO_EMPRESA = C.CODIGO_EMPRESA AND F.CODIGO_PESSOA = C.CODIGO_PESSOA AND F.DT_REG_OCORRENCIA = C.DT_REG_OCORRENCIA AND F.OCORRENCIA = C.OCORRENCIA
LEFT OUTER JOIN (SELECT A.* FROM RHPESS_CONTRATO A WHERE A.ANO_MES_REFERENCIA = (select max(AUX.ano_mes_referencia) from rhpess_contrato AUX where AUX.codigo_empresa = A.codigo_empresa and AUX.tipo_contrato = A.tipo_contrato and AUX.codigo = A.codigo))A ON C.CODIGO_EMPRESA = F.CODIGO_EMPRESA AND A.TIPO_CONTRATO = F.TIPO_CONTRATO AND A.CODIGO = F.CODIGO_CONTRATO
LEFT OUTER JOIN RHTABS_VINCULO_EMP V ON V.CODIGO = A.VINCULO
LEFT OUTER JOIN(SELECT * FROM RHINTE_ED_IT_CONV where codigo_CONVERSAO ='TEG1')TC1 
--ATE 28/8/20--ON SUBSTR(TC1.DADO_ORIGEM,1,24) =  F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.TP_REGIME_TRAB_ESOCIAL|| V.TP_REGIME_PREV_ESOCIAL||V.COD_CATEG_ESOCIAL --PROCEDIMENTO
ON SUBSTR(TC1.DADO_ORIGEM,1,23) =  F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.CODIGO --novo em 28/8/20

WHERE 
F.CODIGO_EMPRESA = vEMPRESA 
AND F.CODIGO_PESSOA = (SELECT CODIGO_PESSOA FROM RHPESS_CONTR_MEST WHERE CODIGO_EMPRESA = vEMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vBM )

AND F.DATA_INI_AFAST IS NOT NULL AND F.DATA_FIM_AFAST IS NOT NULL
)X
WHERE X.DADO_ORIGEM_TC1 IS NOT NULL
GROUP BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.CODIGO_PESSOA, X.dt_reg_ocorrencia, X.OCORRENCIA,  X.DATA_INI_AFAST , X.DATA_FIM_AFAST, X.DADO_ORIGEM_TC1, X.DADO_DESTINO_TC1


union all
--------------------------------------------------------------------------------------------------------------------------doencas
select x2.* 
from(

SELECT 
X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.CODIGO_PESSOA, X.dt_reg_ocorrencia, X.OCORRENCIA, X.DATA_INI_AFAST , X.DATA_FIM_AFAST, 0 CONDUTA, 1 SIM, 0 TEG2 , 0 TEG3,
COUNT(1)QUANT_REG,
'SIM' TIPO, X.DADO_ORIGEM_TC1, X.DADO_DESTINO_TC1, X.DADO_ORIGEM_TC2, X.DADO_DESTINO_TC2, X.DADO_ORIGEM_TC3, X.DADO_DESTINO_TC3
FROM (
SELECT 
F.CODIGO_EMPRESA, F.TIPO_CONTRATO, F.CODIGO_CONTRATO, F.CODIGO_PESSOA, F.dt_reg_ocorrencia, F.OCORRENCIA, F.DATA_INI_AFAST , F.DATA_FIM_AFAST,
1 PONTOS, TC1.DADO_ORIGEM DADO_ORIGEM_TC1, TC1.DADO_DESTINO DADO_DESTINO_TC1,
NULL DADO_ORIGEM_TC2, NULL DADO_DESTINO_TC2,
NULL DADO_ORIGEM_TC3, NULL DADO_DESTINO_TC3,
C.OCOR_PROC_MED, C.CODIGO_PROC_MED, A.ANO_MES_REFERENCIA, A.VINCULO, V.tp_regime_trab_esocial, V.tp_regime_prev_esocial, V.cod_categ_esocial
,CASE when A.cod_cargo_efetivo IS NULL OR A.cod_cargo_efetivo = '000000000000000' THEN 'NAO' ELSE 'SIM' END TEM_CARGO_EFETIVO
,D.OCOR_DOENCA, D.COD_DOENCA,DOE.DESCRICAO, DOE.C_LIVRE_OPCAO01 DOENCA_C_LIVRE_OPCAO01, DOE.C_LIVRE_DESCR02 DOENCA_C_LIVRE_DESCR02
FROM 
RHMEDI_FICHA_MED F 
FULL OUTER JOIN RHMEDI_RL_FICH_PRO C ON F.CODIGO_EMPRESA = C.CODIGO_EMPRESA AND F.CODIGO_PESSOA = C.CODIGO_PESSOA AND F.DT_REG_OCORRENCIA = C.DT_REG_OCORRENCIA AND F.OCORRENCIA = C.OCORRENCIA
full OUTER JOIN RHMEDI_RL_FICH_DOE D ON F.CODIGO_EMPRESA = D.CODIGO_EMPRESA AND F.CODIGO_PESSOA = D.CODIGO_PESSOA AND F.DT_REG_OCORRENCIA = D.DT_REG_OCORRENCIA AND D.OCORRENCIA = C.OCORRENCIA
LEFT OUTER JOIN RHMEDI_DOENCA DOE ON DOE.CODIGO = D.COD_DOENCA
LEFT OUTER JOIN (SELECT A.* FROM RHPESS_CONTRATO A WHERE A.ANO_MES_REFERENCIA = (select max(AUX.ano_mes_referencia) from rhpess_contrato AUX where AUX.codigo_empresa = A.codigo_empresa and AUX.tipo_contrato = A.tipo_contrato and AUX.codigo = A.codigo))A 
        ON C.CODIGO_EMPRESA = F.CODIGO_EMPRESA AND A.TIPO_CONTRATO = F.TIPO_CONTRATO AND A.CODIGO = F.CODIGO_CONTRATO
LEFT OUTER JOIN RHTABS_VINCULO_EMP V ON V.CODIGO = A.VINCULO
LEFT OUTER JOIN(SELECT * FROM RHINTE_ED_IT_CONV where codigo_CONVERSAO ='TEG1')TC1 
--ATE 28/8/20--ON SUBSTR(TC1.DADO_ORIGEM,1,24) =  F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.TP_REGIME_TRAB_ESOCIAL|| V.TP_REGIME_PREV_ESOCIAL||V.COD_CATEG_ESOCIAL --PROCEDIMENTO
ON SUBSTR(TC1.DADO_ORIGEM,1,23) =  F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.CODIGO --novo em 28/8/20
WHERE 
F.CODIGO_EMPRESA = vEMPRESA 
AND F.CODIGO_PESSOA = (SELECT CODIGO_PESSOA FROM RHPESS_CONTR_MEST WHERE CODIGO_EMPRESA = vEMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vBM )

AND F.DATA_INI_AFAST IS NOT NULL AND F.DATA_FIM_AFAST IS NOT NULL
)X
WHERE X.DOENCA_C_LIVRE_OPCAO01 = 'S'
and X.DADO_ORIGEM_TC1 IS NOT NULL
GROUP BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.CODIGO_PESSOA, X.dt_reg_ocorrencia, X.OCORRENCIA, X.DATA_INI_AFAST , X.DATA_FIM_AFAST, X.DADO_ORIGEM_TC1, X.DADO_DESTINO_TC1 , X.DADO_ORIGEM_TC2, X.DADO_DESTINO_TC2, X.DADO_ORIGEM_TC3, X.DADO_DESTINO_TC3


UNION ALL

SELECT 
X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.CODIGO_PESSOA, X.dt_reg_ocorrencia, X.OCORRENCIA, X.DATA_INI_AFAST , X.DATA_FIM_AFAST, 0 CONDUTA, 0 SIM, 1 TEG2 , 0 TEG3,
COUNT(1)QUANT,
'TEG2' TIPO, X.DADO_ORIGEM_TC1, X.DADO_DESTINO_TC1, X.DADO_ORIGEM_TC2, X.DADO_DESTINO_TC2, X.DADO_ORIGEM_TC3, X.DADO_DESTINO_TC3
FROM (
SELECT 
F.CODIGO_EMPRESA, F.TIPO_CONTRATO, F.CODIGO_CONTRATO, F.CODIGO_PESSOA, F.dt_reg_ocorrencia, F.OCORRENCIA, F.DATA_INI_AFAST , F.DATA_FIM_AFAST,
0.5 PONTOS, TC1.DADO_ORIGEM DADO_ORIGEM_TC1, TC1.DADO_DESTINO DADO_DESTINO_TC1,
TC2.DADO_ORIGEM DADO_ORIGEM_TC2, TC2.DADO_DESTINO DADO_DESTINO_TC2,
NULL DADO_ORIGEM_TC3, NULL DADO_DESTINO_TC3,
C.OCOR_PROC_MED, C.CODIGO_PROC_MED, A.ANO_MES_REFERENCIA, A.VINCULO, V.tp_regime_trab_esocial, V.tp_regime_prev_esocial, V.cod_categ_esocial
,CASE when A.cod_cargo_efetivo IS NULL OR A.cod_cargo_efetivo = '000000000000000' THEN 'NAO' ELSE 'SIM' END TEM_CARGO_EFETIVO
,D.OCOR_DOENCA, D.COD_DOENCA, DOE.C_LIVRE_OPCAO01 DOENCA_C_LIVRE_OPCAO01, DOE.C_LIVRE_DESCR02 DOENCA_C_LIVRE_DESCR02
FROM 
RHMEDI_FICHA_MED F 
FULL OUTER JOIN RHMEDI_RL_FICH_PRO C ON F.CODIGO_EMPRESA = C.CODIGO_EMPRESA AND F.CODIGO_PESSOA = C.CODIGO_PESSOA AND F.DT_REG_OCORRENCIA = C.DT_REG_OCORRENCIA AND F.OCORRENCIA = C.OCORRENCIA
full OUTER JOIN RHMEDI_RL_FICH_DOE D ON F.CODIGO_EMPRESA = D.CODIGO_EMPRESA AND F.CODIGO_PESSOA = D.CODIGO_PESSOA AND F.DT_REG_OCORRENCIA = D.DT_REG_OCORRENCIA AND D.OCORRENCIA = C.OCORRENCIA
LEFT OUTER JOIN RHMEDI_DOENCA DOE ON DOE.CODIGO = D.COD_DOENCA
LEFT OUTER JOIN (SELECT A.* FROM RHPESS_CONTRATO A WHERE A.ANO_MES_REFERENCIA = (select max(AUX.ano_mes_referencia) from rhpess_contrato AUX where AUX.codigo_empresa = A.codigo_empresa and AUX.tipo_contrato = A.tipo_contrato and AUX.codigo = A.codigo))A 
        ON C.CODIGO_EMPRESA = F.CODIGO_EMPRESA AND A.TIPO_CONTRATO = F.TIPO_CONTRATO AND A.CODIGO = F.CODIGO_CONTRATO
LEFT OUTER JOIN RHTABS_VINCULO_EMP V ON V.CODIGO = A.VINCULO
LEFT OUTER JOIN(SELECT * FROM RHINTE_ED_IT_CONV where codigo_CONVERSAO ='TEG1')TC1 
--ATE 28/8/20--ON SUBSTR(TC1.DADO_ORIGEM,1,24) =  F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.TP_REGIME_TRAB_ESOCIAL|| V.TP_REGIME_PREV_ESOCIAL||V.COD_CATEG_ESOCIAL --PROCEDIMENTO
ON SUBSTR(TC1.DADO_ORIGEM,1,23) =  F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.CODIGO --novo em 28/8/20
LEFT OUTER JOIN(SELECT * FROM RHINTE_ED_IT_CONV where codigo_CONVERSAO ='TEG2')TC2 
--ON SUBSTR(TC2.DADO_ORIGEM,1,24) = F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.tp_regime_trab_esocial|| V.tp_regime_prev_esocial||V.cod_categ_esocial AND SUBSTR(TC2.DADO_ORIGEM,25,LENGTH(TC2.DADO_ORIGEM)) =  DOE.C_LIVRE_DESCR02 --1Ã‚Âª DOENCA 
ON SUBSTR(TC2.DADO_ORIGEM,1,23) = F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.CODIGO AND SUBSTR(TC2.DADO_ORIGEM,24,LENGTH(TC2.DADO_ORIGEM)) =  DOE.C_LIVRE_DESCR02
WHERE 
F.CODIGO_EMPRESA = vEMPRESA 
AND F.CODIGO_PESSOA = (SELECT CODIGO_PESSOA FROM RHPESS_CONTR_MEST WHERE CODIGO_EMPRESA = vEMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vBM )

AND F.DATA_INI_AFAST IS NOT NULL AND F.DATA_FIM_AFAST IS NOT NULL
)X
WHERE X.DADO_ORIGEM_TC1 IS NOT NULL
and X.DADO_ORIGEM_TC2 IS NOT NULL
GROUP BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.CODIGO_PESSOA, X.dt_reg_ocorrencia, X.OCORRENCIA, X.DATA_INI_AFAST , X.DATA_FIM_AFAST, X.DADO_ORIGEM_TC1, X.DADO_DESTINO_TC1
, X.DADO_ORIGEM_TC2, X.DADO_DESTINO_TC2, X.DADO_ORIGEM_TC3, X.DADO_DESTINO_TC3


UNION ALL

SELECT 
X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.CODIGO_PESSOA, X.dt_reg_ocorrencia, X.OCORRENCIA, X.DATA_INI_AFAST , X.DATA_FIM_AFAST,
0 CONDUTA, 0 SIM, 0 TEG2 , 1 TEG3,
COUNT(1)QUANT,
'TEG3' TIPO, X.DADO_ORIGEM_TC1, X.DADO_DESTINO_TC1
, X.DADO_ORIGEM_TC2, X.DADO_DESTINO_TC2, X.DADO_ORIGEM_TC3, X.DADO_DESTINO_TC3
FROM (
SELECT 
F.CODIGO_EMPRESA, F.TIPO_CONTRATO, F.CODIGO_CONTRATO, F.CODIGO_PESSOA, F.dt_reg_ocorrencia, F.OCORRENCIA, F.DATA_INI_AFAST , F.DATA_FIM_AFAST,
0.5 PONTOS,
TC1.DADO_ORIGEM DADO_ORIGEM_TC1, TC1.DADO_DESTINO DADO_DESTINO_TC1,
NULL DADO_ORIGEM_TC2, NULL DADO_DESTINO_TC2,
TC3.DADO_ORIGEM DADO_ORIGEM_TC3, TC3.DADO_DESTINO DADO_DESTINO_TC3,
C.OCOR_PROC_MED, C.CODIGO_PROC_MED, A.ANO_MES_REFERENCIA, A.VINCULO, V.tp_regime_trab_esocial, V.tp_regime_prev_esocial, V.cod_categ_esocial
,CASE when A.cod_cargo_efetivo IS NULL OR A.cod_cargo_efetivo = '000000000000000' THEN 'NAO' ELSE 'SIM' END TEM_CARGO_EFETIVO
,D.OCOR_DOENCA, D.COD_DOENCA, DOE.C_LIVRE_OPCAO01 DOENCA_C_LIVRE_OPCAO01, DOE.C_LIVRE_DESCR02 DOENCA_C_LIVRE_DESCR02
FROM 
RHMEDI_FICHA_MED F
FULL OUTER JOIN RHMEDI_RL_FICH_PRO C ON F.CODIGO_EMPRESA = C.CODIGO_EMPRESA AND F.CODIGO_PESSOA = C.CODIGO_PESSOA AND F.DT_REG_OCORRENCIA = C.DT_REG_OCORRENCIA AND F.OCORRENCIA = C.OCORRENCIA
full OUTER JOIN RHMEDI_RL_FICH_DOE D ON F.CODIGO_EMPRESA = D.CODIGO_EMPRESA AND F.CODIGO_PESSOA = D.CODIGO_PESSOA AND F.DT_REG_OCORRENCIA = D.DT_REG_OCORRENCIA AND D.OCORRENCIA = C.OCORRENCIA
LEFT OUTER JOIN RHMEDI_DOENCA DOE ON DOE.CODIGO = D.COD_DOENCA
LEFT OUTER JOIN (SELECT A.* FROM RHPESS_CONTRATO A WHERE A.ANO_MES_REFERENCIA = (select max(AUX.ano_mes_referencia) from rhpess_contrato AUX where AUX.codigo_empresa = A.codigo_empresa and AUX.tipo_contrato = A.tipo_contrato and AUX.codigo = A.codigo))A 
        ON C.CODIGO_EMPRESA = F.CODIGO_EMPRESA AND A.TIPO_CONTRATO = F.TIPO_CONTRATO AND A.CODIGO = F.CODIGO_CONTRATO
LEFT OUTER JOIN RHTABS_VINCULO_EMP V ON V.CODIGO = A.VINCULO
LEFT OUTER JOIN(SELECT * FROM RHINTE_ED_IT_CONV where codigo_CONVERSAO ='TEG1')TC1 
--ATE 28/8/20--ON SUBSTR(TC1.DADO_ORIGEM,1,24) =  F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.TP_REGIME_TRAB_ESOCIAL|| V.TP_REGIME_PREV_ESOCIAL||V.COD_CATEG_ESOCIAL --PROCEDIMENTO
ON SUBSTR(TC1.DADO_ORIGEM,1,23) =  F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.CODIGO --novo em 28/8/20
LEFT OUTER JOIN(SELECT * FROM RHINTE_ED_IT_CONV where codigo_CONVERSAO ='TEG3')TC3 
--ON SUBSTR(TC3.DADO_ORIGEM,1,24) = F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.tp_regime_trab_esocial|| V.tp_regime_prev_esocial||V.cod_categ_esocial AND SUBSTR(TC3.DADO_ORIGEM,25,LENGTH(TC3.DADO_ORIGEM)) =  DOE.C_LIVRE_DESCR02 --2Ã‚Âª DOENCA 
ON SUBSTR(TC3.DADO_ORIGEM,1,23) = F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.CODIGO AND SUBSTR(TC3.DADO_ORIGEM,24,LENGTH(TC3.DADO_ORIGEM)) =  DOE.C_LIVRE_DESCR02 --2Ã‚Âª DOENCA --NOVO EM 6/7/20

WHERE
F.CODIGO_EMPRESA = vEMPRESA 
AND F.CODIGO_PESSOA = (SELECT CODIGO_PESSOA FROM RHPESS_CONTR_MEST WHERE CODIGO_EMPRESA = vEMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vBM )

AND F.DATA_INI_AFAST IS NOT NULL AND F.DATA_FIM_AFAST IS NOT NULL
)X
WHERE X.DADO_ORIGEM_TC1 IS NOT NULL
and X.DADO_ORIGEM_TC3 IS NOT NULL
GROUP BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.CODIGO_PESSOA,  X.dt_reg_ocorrencia, X.OCORRENCIA, X.DATA_INI_AFAST , X.DATA_FIM_AFAST, X.DADO_ORIGEM_TC1, X.DADO_DESTINO_TC1
, X.DADO_ORIGEM_TC2, X.DADO_DESTINO_TC2, X.DADO_ORIGEM_TC3, X.DADO_DESTINO_TC3

--FIM DO UNION

)x2
)X3
GROUP BY X3.CODIGO_EMPRESA, X3.TIPO_CONTRATO, X3.CODIGO_CONTRATO, X3.CODIGO_PESSOA, X3.dt_reg_ocorrencia, X3.OCORRENCIA, X3.DATA_INI_AFAST , X3.DATA_FIM_AFAST, X3.DADO_ORIGEM_TC1, X3.DADO_DESTINO_TC1
)X4
)X5 

WHERE
(TRUNC(X5.DATA_INI_AFAST) BETWEEN TRUNC(vDATA_INICIO) AND TRUNC(vDATA_FIM)
--TO_DATE('30/03/2021','DD/MM/YYYY') AND TO_DATE('01/04/2021','DD/MM/YYYY')
OR
TRUNC(X5.DATA_FIM_AFAST) BETWEEN TRUNC(vDATA_INICIO) AND TRUNC(vDATA_FIM)
--TO_DATE('30/03/2021','DD/MM/YYYY') AND TO_DATE('01/04/2021','DD/MM/YYYY')
)

AND X5.CODIGO_EMPRESA = vEMPRESA AND X5.TIPO_CONTRATO = vTIPO_CONTRATO AND X5.CODIGO_CONTRATO = vBM --NOVO EM 21/7/22 

--WHERE trunc(X5.DATA_INI_AFAST ) <= to_date('01/02/20','dd/mm/yy') --------------------------DATA CORTE DO BM SANEADO----------------------------------------------------------------------------------------------------------------------------------


ORDER BY X5.CODIGO_EMPRESA, X5.TIPO_CONTRATO, X5.CODIGO_CONTRATO, X5.CODIGO_PESSOA,  X5.DATA_INI_AFAST 
------FIM------------------------------NOVA LOGICA

)
loop
vCONTADOR := vCONTADOR+1;
vCONTADOR2 := 1;
dbms_output.put_line('');
dbms_output.put_line('--contador: '|| vCONTADOR ||' pessoa: '|| c1.codigo_pessoa || ' dt_reg_ocorrencia: '|| c1.dt_reg_ocorrencia || ' ocorrencia: ' || c1.ocorrencia ||' data_ini_afast: ' || c1.data_ini_afast || ' data_fim_afast: ' || c1.data_fim_afast);


for c2 in (

select a.* from RHCGED_ALT_SIT_FUN A  where codigo_empresa = c1.codigo_empresa and tipo_contrato = c1.tipo_contrato and A.CODIGO = c1.codigo_contrato 
and 
trunc(A.DATA_INIC_SITUACAO) between to_date(c1.data_ini_afast,'dd/mm/yy') and to_date(c1.data_fim_afast,'dd/mm/yy')

AND A.cod_sit_funcional IN (SELECT X.SIT_DEF FROM(
SELECT SUBSTR(DADO_DESTINO,1,4)SIT_DEF FROM RHINTE_ED_IT_CONV WHERE CODIGO_CONVERSAO = 'TEG1'
UNION ALL
SELECT SUBSTR(DADO_DESTINO,17,4)ST_DEF FROM RHINTE_ED_IT_CONV WHERE CODIGO_CONVERSAO = 'TEG1'
)X GROUP BY X.SIT_DEF
)
ORDER BY A.DATA_INIC_SITUACAO

)
loop
vQTD_SITUACAO := 1;
vSIT_ATUAL :=  c2.cod_sit_funcional;

dbms_output.put_line('--bm: '||c2.codigo || ' situacao: '||c2.cod_sit_funcional ||' inicio: '|| c2.data_inic_situacao || ' fim: ' || c2.data_fim_situacao);

if vCONTADOR2 = 1 then
vDATA_INICIAL := c2.data_inic_situacao;
end if;

if vSIT_ATUAL <> c2.cod_sit_funcional then
vQTD_SITUACAO := vQTD_SITUACAO+1;
end if;

vDATA_FINAL := c2.data_fim_situacao;

vCONTADOR2:= vCONTADOR2+1;
end loop;--fim 2Âº for 

dbms_output.put_line('--vQTD_SITUACAO: ' || vQTD_SITUACAO|| ' vDATA_INICIAL: '||vDATA_INICIAL ||' vDATA_FINAL: '|| vDATA_FINAL);

--RESULTADO
IF C1.DOENCA_GRAVE = 'FICHA_SEM_DOENCA_GRAVE' then

--comentado 23/12/21--IF vQTD_SITUACAO = 1 AND vDATA_INICIAL = c1.data_ini_afast AND vDATA_FINAL = c1.data_FIM_afast THEN
--comentado 23/12/21--dbms_output.put_line('---------------------------RESULTADO: OK');


--comentado 23/12/21--ELSIF
IF vQTD_SITUACAO = 1 --comentado 23/12/21--AND (vDATA_INICIAL <> c1.data_ini_afast OR vDATA_FINAL <> c1.data_FIM_afast) 
THEN
dbms_output.put_line('---------------------------RESULTADO: RE PROCESSAR FICHA SEM_DOENCA_GRAVE ---VERIFICAR HISTORICO ANTES');
--ficha
dbms_output.put_line('update RHMEDI_FICHA_MED set ocorrencia = ocorrencia where CODIGO_PESSOA = '''|| c1.codigo_pessoa ||''' AND TRUNC(DT_REG_OCORRENCIA) = TO_DATE('''||C1.DT_REG_OCORRENCIA ||''',''DD/MM/YY'') AND OCORRENCIA = '||C1.OCORRENCIA ||' ; COMMIT;');
update RHMEDI_FICHA_MED set ocorrencia = ocorrencia where CODIGO_PESSOA = c1.codigo_pessoa AND TRUNC(DT_REG_OCORRENCIA) = TO_DATE(C1.DT_REG_OCORRENCIA,'DD/MM/YY') AND OCORRENCIA = C1.OCORRENCIA ; COMMIT;
dbms_output.put_line('UPDATE SUGESP_FICHAS_MEDICAS SET PROCESSADO = ''S'', TIPO_DML = ''I'' WHERE ID = (SELECT MAX(ID) FROM SUGESP_FICHAS_MEDICAS); COMMIT;');
UPDATE SUGESP_FICHAS_MEDICAS SET PROCESSADO = 'S', TIPO_DML = 'I' WHERE ID = (SELECT MAX(ID) FROM SUGESP_FICHAS_MEDICAS); COMMIT;

--conduta
dbms_output.put_line('update RHMEDI_RL_FICH_PRO set ocorrencia = ocorrencia where CODIGO_PESSOA = '''|| c1.codigo_pessoa ||''' AND TRUNC(DT_REG_OCORRENCIA) = TO_DATE('''||C1.DT_REG_OCORRENCIA ||''',''DD/MM/YY'') AND OCORRENCIA = '||C1.OCORRENCIA ||' ; COMMIT;');
update RHMEDI_RL_FICH_PRO set ocorrencia = ocorrencia where CODIGO_PESSOA = c1.codigo_pessoa AND TRUNC(DT_REG_OCORRENCIA) = TO_DATE(C1.DT_REG_OCORRENCIA,'DD/MM/YY') AND OCORRENCIA = C1.OCORRENCIA; COMMIT;
dbms_output.put_line('UPDATE SUGESP_FICHAS_MEDICAS SET PROCESSADO = ''S'', TIPO_DML = ''I'' WHERE ID = (SELECT MAX(ID) FROM SUGESP_FICHAS_MEDICAS); COMMIT;');
UPDATE SUGESP_FICHAS_MEDICAS SET PROCESSADO = 'S', TIPO_DML = 'I' WHERE ID = (SELECT MAX(ID) FROM SUGESP_FICHAS_MEDICAS); COMMIT;
SELECT MAX(ID) max_id into vID FROM SUGESP_FICHAS_MEDICAS;
--dbms_output.put_line(' EXECUTE PR_FICHA_MEDICA_SIT_FUNC_PONT('''|| C1.CODIGO_EMPRESA ||''','''|| C1.CODIGO_PESSOA ||''','''|| TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD') ||''', '|| C1.OCORRENCIA ||','|| vID ||', ''RHMEDI_RL_FICH_PRO'', ''I-INCLUIU_CONDUTA'', '''|| C1.DADO_ORIGEM_TC1|| ''','''|| C1.DADO_DESTINO_TC1|| ''',NULL,NULL,NULL,NULL,NULL , ''M'','''|| vID ||''' );');
--PR_FICHA_MEDICA_SIT_FUNC_PONT(C1.CODIGO_EMPRESA, C1.CODIGO_PESSOA, TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD'),C1.OCORRENCIA, vID, 'RHMEDI_RL_FICH_PRO', 'I-INCLUIU_CONDUTA', C1.DADO_ORIGEM_TC1, C1.DADO_DESTINO_TC1,NULL,NULL,NULL,NULL,NULL, 'M', TO_CHAR(vID));
dbms_output.put_line(' EXECUTE PR_RHMEDI_FICHA_MED_MANUAL(''RHMEDI_RL_FICH_PRO'','''|| C1.CODIGO_EMPRESA ||''','''||C1.CODIGO_PESSOA ||''','''||TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD') ||''', '|| C1.OCORRENCIA ||',''M'','''|| vID ||''' );');
PR_RHMEDI_FICHA_MED_MANUAL('RHMEDI_RL_FICH_PRO', C1.CODIGO_EMPRESA, C1.CODIGO_PESSOA, TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD'),C1.OCORRENCIA, 'M', TO_CHAR(vID));


ELSE
dbms_output.put_line('---------------------------RESULTADO: RE PROCESSAR FICHA SEM_DOENCA_GRAVE');
--ficha
dbms_output.put_line('update RHMEDI_FICHA_MED set ocorrencia = ocorrencia where CODIGO_PESSOA = '''|| c1.codigo_pessoa ||''' AND TRUNC(DT_REG_OCORRENCIA) = TO_DATE('''||C1.DT_REG_OCORRENCIA ||''',''DD/MM/YY'') AND OCORRENCIA = '||C1.OCORRENCIA ||' ; COMMIT;');
update RHMEDI_FICHA_MED set ocorrencia = ocorrencia where CODIGO_PESSOA = c1.codigo_pessoa AND TRUNC(DT_REG_OCORRENCIA) = TO_DATE(C1.DT_REG_OCORRENCIA,'DD/MM/YY') AND OCORRENCIA = C1.OCORRENCIA; COMMIT;
dbms_output.put_line('UPDATE SUGESP_FICHAS_MEDICAS SET PROCESSADO = ''S'', TIPO_DML = ''I'' WHERE ID = (SELECT MAX(ID) FROM SUGESP_FICHAS_MEDICAS); COMMIT;');
UPDATE SUGESP_FICHAS_MEDICAS SET PROCESSADO = 'S', TIPO_DML = 'I' WHERE ID = (SELECT MAX(ID) FROM SUGESP_FICHAS_MEDICAS); COMMIT;

--conduta
dbms_output.put_line('update RHMEDI_RL_FICH_PRO set ocorrencia = ocorrencia where CODIGO_PESSOA = '''|| c1.codigo_pessoa ||''' AND TRUNC(DT_REG_OCORRENCIA) = TO_DATE('''||C1.DT_REG_OCORRENCIA ||''',''DD/MM/YY'') AND OCORRENCIA = '||C1.OCORRENCIA ||' ; COMMIT;');
update RHMEDI_RL_FICH_PRO set ocorrencia = ocorrencia where CODIGO_PESSOA = c1.codigo_pessoa AND TRUNC(DT_REG_OCORRENCIA) = TO_DATE(C1.DT_REG_OCORRENCIA,'DD/MM/YY') AND OCORRENCIA = C1.OCORRENCIA; COMMIT;
dbms_output.put_line('UPDATE SUGESP_FICHAS_MEDICAS SET PROCESSADO = ''S'', TIPO_DML = ''I'' WHERE ID = (SELECT MAX(ID) FROM SUGESP_FICHAS_MEDICAS); COMMIT;');
UPDATE SUGESP_FICHAS_MEDICAS SET PROCESSADO = 'S', TIPO_DML = 'I' WHERE ID = (SELECT MAX(ID) FROM SUGESP_FICHAS_MEDICAS); COMMIT;
SELECT MAX(ID) max_id into vID FROM SUGESP_FICHAS_MEDICAS;
--dbms_output.put_line(' EXECUTE PR_FICHA_MEDICA_SIT_FUNC_PONT('''|| C1.CODIGO_EMPRESA ||''','''|| C1.CODIGO_PESSOA ||''', '''|| TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD') ||''',' || C1.OCORRENCIA ||','||vID ||', ''RHMEDI_RL_FICH_PRO'', ''I-INCLUIU_CONDUTA'', '''|| C1.DADO_ORIGEM_TC1|| ''','''|| C1.DADO_DESTINO_TC1|| ''',NULL,NULL,NULL,NULL,NULL , ''M'','''|| vID ||''' );');
--PR_FICHA_MEDICA_SIT_FUNC_PONT(C1.CODIGO_EMPRESA, C1.CODIGO_PESSOA, TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD'), C1.OCORRENCIA, vID, 'RHMEDI_RL_FICH_PRO', 'I-INCLUIU_CONDUTA', C1.DADO_ORIGEM_TC1, C1.DADO_DESTINO_TC1,NULL,NULL,NULL,NULL,NULL , 'M', TO_CHAR(vID));
dbms_output.put_line(' EXECUTE PR_RHMEDI_FICHA_MED_MANUAL(''RHMEDI_RL_FICH_PRO'','''|| C1.CODIGO_EMPRESA ||''','''||C1.CODIGO_PESSOA ||''','''||TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD') ||''', '|| C1.OCORRENCIA ||',''M'','''|| vID ||''' );');
PR_RHMEDI_FICHA_MED_MANUAL('RHMEDI_RL_FICH_PRO', C1.CODIGO_EMPRESA, C1.CODIGO_PESSOA, TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD'),C1.OCORRENCIA, 'M', TO_CHAR(vID));


END IF;

elsif C1.DOENCA_GRAVE = 'FICHA_COM_DOENCA_GRAVE' then

--comentado 23/12/21--IF vQTD_SITUACAO = 1 AND vDATA_INICIAL = c1.data_ini_afast AND vDATA_FINAL = c1.data_FIM_afast THEN
--comentado 23/12/21--dbms_output.put_line('---------------------------RESULTADO: OK');


--comentado 23/12/21--ELSIF
IF vQTD_SITUACAO = 1 --comentado 23/12/21-- AND (vDATA_INICIAL <> c1.data_ini_afast OR vDATA_FINAL <> c1.data_FIM_afast) 
THEN
dbms_output.put_line('---------------------------RESULTADO: RE PROCESSAR FICHA COM_DOENCA_GRAVE---VERIFICAR HISTORICO ANTES');
--ficha
dbms_output.put_line('update RHMEDI_FICHA_MED set ocorrencia = ocorrencia where CODIGO_PESSOA = '''|| c1.codigo_pessoa ||''' AND TRUNC(DT_REG_OCORRENCIA) = TO_DATE('''||C1.DT_REG_OCORRENCIA ||''',''DD/MM/YY'') AND OCORRENCIA = '||C1.OCORRENCIA ||' ; COMMIT;');
update RHMEDI_FICHA_MED set ocorrencia = ocorrencia where CODIGO_PESSOA = c1.codigo_pessoa AND TRUNC(DT_REG_OCORRENCIA) = TO_DATE(C1.DT_REG_OCORRENCIA,'DD/MM/YY') AND OCORRENCIA = C1.OCORRENCIA ; COMMIT;
dbms_output.put_line('UPDATE SUGESP_FICHAS_MEDICAS SET PROCESSADO = ''S'', TIPO_DML = ''I'' WHERE ID = (SELECT MAX(ID) FROM SUGESP_FICHAS_MEDICAS); COMMIT;');
UPDATE SUGESP_FICHAS_MEDICAS SET PROCESSADO = 'S', TIPO_DML = 'I' WHERE ID = (SELECT MAX(ID) FROM SUGESP_FICHAS_MEDICAS); COMMIT;

--conduta
dbms_output.put_line('update RHMEDI_RL_FICH_PRO set ocorrencia = ocorrencia where CODIGO_PESSOA = '''|| c1.codigo_pessoa ||''' AND TRUNC(DT_REG_OCORRENCIA) = TO_DATE('''||C1.DT_REG_OCORRENCIA ||''',''DD/MM/YY'') AND OCORRENCIA = '||C1.OCORRENCIA ||' ; COMMIT;');
update RHMEDI_RL_FICH_PRO set ocorrencia = ocorrencia where CODIGO_PESSOA = c1.codigo_pessoa AND TRUNC(DT_REG_OCORRENCIA) = TO_DATE(C1.DT_REG_OCORRENCIA,'DD/MM/YY') AND OCORRENCIA = C1.OCORRENCIA; COMMIT;
dbms_output.put_line('UPDATE SUGESP_FICHAS_MEDICAS SET PROCESSADO = ''S'', TIPO_DML = ''I'' WHERE ID = (SELECT MAX(ID) FROM SUGESP_FICHAS_MEDICAS); COMMIT;');
UPDATE SUGESP_FICHAS_MEDICAS SET PROCESSADO = 'S', TIPO_DML = 'I' WHERE ID = (SELECT MAX(ID) FROM SUGESP_FICHAS_MEDICAS); COMMIT;
SELECT MAX(ID) max_id into vID FROM SUGESP_FICHAS_MEDICAS;
--dbms_output.put_line(' EXECUTE PR_FICHA_MEDICA_SIT_FUNC_PONT('''|| C1.CODIGO_EMPRESA ||''','''|| C1.CODIGO_PESSOA ||''','''|| TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD')||''', '|| C1.OCORRENCIA ||','||vID ||', ''RHMEDI_RL_FICH_PRO'', ''I-INCLUIU_CONDUTA'', '''|| C1.DADO_ORIGEM_TC1|| ''','''|| C1.DADO_DESTINO_TC1|| ''',NULL,NULL,NULL,NULL,NULL , ''M'','''|| vID ||''' );');
--PR_FICHA_MEDICA_SIT_FUNC_PONT(C1.CODIGO_EMPRESA, C1.CODIGO_PESSOA, TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD'), C1.OCORRENCIA, vID, 'RHMEDI_RL_FICH_PRO', 'I-INCLUIU_CONDUTA', C1.DADO_ORIGEM_TC1, C1.DADO_DESTINO_TC1,NULL,NULL,NULL,NULL,NULL , 'M',TO_CHAR(vID));
dbms_output.put_line(' EXECUTE PR_RHMEDI_FICHA_MED_MANUAL(''RHMEDI_RL_FICH_PRO'','''|| C1.CODIGO_EMPRESA ||''','''||C1.CODIGO_PESSOA ||''','''||TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD') ||''', '|| C1.OCORRENCIA ||',''M'','''|| vID ||''' );');
PR_RHMEDI_FICHA_MED_MANUAL('RHMEDI_RL_FICH_PRO', C1.CODIGO_EMPRESA, C1.CODIGO_PESSOA, TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD'),C1.OCORRENCIA, 'M', TO_CHAR(vID));


--doenca
dbms_output.put_line('update RHMEDI_RL_FICH_DOE set ocorrencia = ocorrencia where CODIGO_PESSOA = '''|| c1.codigo_pessoa ||''' AND TRUNC(DT_REG_OCORRENCIA) = TO_DATE('''||C1.DT_REG_OCORRENCIA ||''',''DD/MM/YY'') AND OCORRENCIA = '||C1.OCORRENCIA ||' ; COMMIT;');
update RHMEDI_RL_FICH_DOE set ocorrencia = ocorrencia where CODIGO_PESSOA = c1.codigo_pessoa AND TRUNC(DT_REG_OCORRENCIA) = TO_DATE(C1.DT_REG_OCORRENCIA,'DD/MM/YY') AND OCORRENCIA = C1.OCORRENCIA ; COMMIT;
dbms_output.put_line('UPDATE SUGESP_FICHAS_MEDICAS SET PROCESSADO = ''S'', TIPO_DML = ''I'' WHERE ID = (SELECT MAX(ID) FROM SUGESP_FICHAS_MEDICAS); COMMIT;');
UPDATE SUGESP_FICHAS_MEDICAS SET PROCESSADO = 'S', TIPO_DML = 'I' WHERE ID = (SELECT MAX(ID) FROM SUGESP_FICHAS_MEDICAS); COMMIT;
--dbms_output.put_line(' EXECUTE PR_FICHA_MEDICA_ORIGEM_TEG;');
SELECT MAX(ID) max_id into vID FROM SUGESP_FICHAS_MEDICAS;
--dbms_output.put_line(' EXECUTE PR_FICHA_MEDICA_SIT_FUNC_PONT('''|| C1.CODIGO_EMPRESA ||''','''|| C1.CODIGO_PESSOA ||''','''|| TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD')||''', '|| C1.OCORRENCIA ||','|| vID|| ',''RHMEDI_RL_FICH_DOE'', ''I-0-CRIA_DOENCA_GRAVE'', '''|| C1.DADO_ORIGEM_TC1|| ''','''|| C1.DADO_DESTINO_TC1|| ''',NULL,NULL,NULL,NULL,NULL , ''M'','''|| vID||''' );');
--PR_FICHA_MEDICA_SIT_FUNC_PONT(C1.CODIGO_EMPRESA, C1.CODIGO_PESSOA, TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD'), C1.OCORRENCIA , vID,'RHMEDI_RL_FICH_DOE','I-0-CRIA_DOENCA_GRAVE', C1.DADO_ORIGEM_TC1, C1.DADO_DESTINO_TC1,NULL,NULL,NULL,NULL,NULL , 'M', TO_CHAR(vID));
dbms_output.put_line(' EXECUTE PR_RHMEDI_FICHA_MED_MANUAL(''RHMEDI_RL_FICH_DOE'','''|| C1.CODIGO_EMPRESA ||''','''||C1.CODIGO_PESSOA ||''','''||TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD') ||''', '|| C1.OCORRENCIA ||',''M'','''|| vID ||''' );');
PR_RHMEDI_FICHA_MED_MANUAL('RHMEDI_RL_FICH_DOE', C1.CODIGO_EMPRESA, C1.CODIGO_PESSOA, TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD'),C1.OCORRENCIA, 'M', TO_CHAR(vID));


ELSE
dbms_output.put_line('---------------------------RESULTADO: RE PROCESSAR FICHA COM_DOENCA_GRAVE');
--ficha
dbms_output.put_line('update RHMEDI_FICHA_MED set ocorrencia = ocorrencia where CODIGO_PESSOA = '''|| c1.codigo_pessoa ||''' AND TRUNC(DT_REG_OCORRENCIA) = TO_DATE('''||C1.DT_REG_OCORRENCIA ||''',''DD/MM/YY'') AND OCORRENCIA = '||C1.OCORRENCIA ||' ; COMMIT;');
update RHMEDI_FICHA_MED set ocorrencia = ocorrencia where CODIGO_PESSOA = c1.codigo_pessoa AND TRUNC(DT_REG_OCORRENCIA) = TO_DATE(C1.DT_REG_OCORRENCIA,'DD/MM/YY') AND OCORRENCIA = C1.OCORRENCIA ; COMMIT;
dbms_output.put_line('UPDATE SUGESP_FICHAS_MEDICAS SET PROCESSADO = ''S'', TIPO_DML = ''I'' WHERE ID = (SELECT MAX(ID) FROM SUGESP_FICHAS_MEDICAS); COMMIT;');
UPDATE SUGESP_FICHAS_MEDICAS SET PROCESSADO = 'S', TIPO_DML = 'I' WHERE ID = (SELECT MAX(ID) FROM SUGESP_FICHAS_MEDICAS); COMMIT;

--conduta
dbms_output.put_line('update RHMEDI_RL_FICH_PRO set ocorrencia = ocorrencia where CODIGO_PESSOA = '''|| c1.codigo_pessoa ||''' AND TRUNC(DT_REG_OCORRENCIA) = TO_DATE('''||C1.DT_REG_OCORRENCIA ||''',''DD/MM/YY'') AND OCORRENCIA = '||C1.OCORRENCIA ||' ; COMMIT;');
update RHMEDI_RL_FICH_PRO set ocorrencia = ocorrencia where CODIGO_PESSOA = c1.codigo_pessoa AND TRUNC(DT_REG_OCORRENCIA) = TO_DATE(C1.DT_REG_OCORRENCIA,'DD/MM/YY') AND OCORRENCIA = C1.OCORRENCIA; COMMIT;
dbms_output.put_line('UPDATE SUGESP_FICHAS_MEDICAS SET PROCESSADO = ''S'', TIPO_DML = ''I'' WHERE ID = (SELECT MAX(ID) FROM SUGESP_FICHAS_MEDICAS); COMMIT;');
UPDATE SUGESP_FICHAS_MEDICAS SET PROCESSADO = 'S', TIPO_DML = 'I' WHERE ID = (SELECT MAX(ID) FROM SUGESP_FICHAS_MEDICAS); COMMIT;
SELECT MAX(ID) max_id into vID FROM SUGESP_FICHAS_MEDICAS;
--dbms_output.put_line(' EXECUTE PR_FICHA_MEDICA_SIT_FUNC_PONT('''|| C1.CODIGO_EMPRESA ||''','''|| C1.CODIGO_PESSOA ||''','''|| TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD')||''', '|| C1.OCORRENCIA ||','||vID ||', ''RHMEDI_RL_FICH_PRO'', ''I-INCLUIU_CONDUTA'', '''|| C1.DADO_ORIGEM_TC1|| ''','''|| C1.DADO_DESTINO_TC1|| ''',NULL,NULL,NULL,NULL,NULL , ''M'','''|| vID ||''' );');
--PR_FICHA_MEDICA_SIT_FUNC_PONT(C1.CODIGO_EMPRESA, C1.CODIGO_PESSOA, TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD'), C1.OCORRENCIA, vID, 'RHMEDI_RL_FICH_PRO', 'I-INCLUIU_CONDUTA', C1.DADO_ORIGEM_TC1, C1.DADO_DESTINO_TC1,NULL,NULL,NULL,NULL,NULL , 'M',TO_CHAR(vID));
dbms_output.put_line(' EXECUTE PR_RHMEDI_FICHA_MED_MANUAL(''RHMEDI_RL_FICH_PRO'','''|| C1.CODIGO_EMPRESA ||''','''||C1.CODIGO_PESSOA ||''','''||TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD') ||''', '|| C1.OCORRENCIA ||',''M'','''|| vID ||''' );');
PR_RHMEDI_FICHA_MED_MANUAL('RHMEDI_RL_FICH_PRO', C1.CODIGO_EMPRESA, C1.CODIGO_PESSOA, TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD'),C1.OCORRENCIA, 'M', TO_CHAR(vID));

--doenca
dbms_output.put_line('update RHMEDI_RL_FICH_DOE set ocorrencia = ocorrencia where CODIGO_PESSOA = '''|| c1.codigo_pessoa ||''' AND TRUNC(DT_REG_OCORRENCIA) = TO_DATE('''||C1.DT_REG_OCORRENCIA ||''',''DD/MM/YY'') AND OCORRENCIA = '||C1.OCORRENCIA ||' ; COMMIT;');
update RHMEDI_RL_FICH_DOE set ocorrencia = ocorrencia where CODIGO_PESSOA = c1.codigo_pessoa AND TRUNC(DT_REG_OCORRENCIA) = TO_DATE(C1.DT_REG_OCORRENCIA,'DD/MM/YY') AND OCORRENCIA = C1.OCORRENCIA ; COMMIT;
dbms_output.put_line('UPDATE SUGESP_FICHAS_MEDICAS SET PROCESSADO = ''S'', TIPO_DML = ''I'' WHERE ID = (SELECT MAX(ID) FROM SUGESP_FICHAS_MEDICAS); COMMIT;');
UPDATE SUGESP_FICHAS_MEDICAS SET PROCESSADO = 'S', TIPO_DML = 'I' WHERE ID = (SELECT MAX(ID) FROM SUGESP_FICHAS_MEDICAS); COMMIT;
--dbms_output.put_line(' EXECUTE PR_FICHA_MEDICA_ORIGEM_TEG;');
SELECT MAX(ID) max_id into vID FROM SUGESP_FICHAS_MEDICAS;
--dbms_output.put_line(' EXECUTE PR_FICHA_MEDICA_SIT_FUNC_PONT('''|| C1.CODIGO_EMPRESA ||''','''|| C1.CODIGO_PESSOA ||''','''|| TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD')||''', '|| C1.OCORRENCIA ||','|| vID|| ',''RHMEDI_RL_FICH_DOE'', ''I-0-CRIA_DOENCA_GRAVE'', '''|| C1.DADO_ORIGEM_TC1|| ''','''|| C1.DADO_DESTINO_TC1|| ''',NULL,NULL,NULL,NULL,NULL , ''M'','''|| vID||''' );');
--PR_FICHA_MEDICA_SIT_FUNC_PONT(C1.CODIGO_EMPRESA, C1.CODIGO_PESSOA, TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD'), C1.OCORRENCIA , vID,'RHMEDI_RL_FICH_DOE','I-0-CRIA_DOENCA_GRAVE', C1.DADO_ORIGEM_TC1, C1.DADO_DESTINO_TC1,NULL,NULL,NULL,NULL,NULL , 'M', TO_CHAR(vID));
dbms_output.put_line(' EXECUTE PR_RHMEDI_FICHA_MED_MANUAL(''RHMEDI_RL_FICH_PRO'','''|| C1.CODIGO_EMPRESA ||''','''||C1.CODIGO_PESSOA ||''','''||TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD') ||''', '|| C1.OCORRENCIA ||',''M'','''|| vID ||''' );');
PR_RHMEDI_FICHA_MED_MANUAL('RHMEDI_RL_FICH_DOE', C1.CODIGO_EMPRESA, C1.CODIGO_PESSOA, TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD'),C1.OCORRENCIA, 'M', TO_CHAR(vID));


END IF;

end if;

--LIMPA VARIAVEIS
vDATA_INICIAL := NULL;
vDATA_FINAL := NULL;

end loop;--fim 1 for

end;

END; --1 BEGIN