
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_REPROCESSA_FICHA_PERICIA" (CODIGO_EMPRESA IN VARCHAR2, CODIGO_PESSOA IN VARCHAR2, DT_REG_OCORRENCIA DATE, OCORRENCIA IN NUMBER)AS

--create or replace PROCEDURE               PR_ACERTO_REPFICHA_1BM (EMPRESA IN VARCHAR2, TIPO_CONTRATO IN VARCHAR2, BM IN VARCHAR2, INICIO DATE, FIM DATE) AS 
--KELLYSSON 21/12/21
--baseado em PR_SUGESP_REPFICHAS_SANEAMENTO

BEGIN-- 1 BEGIN


DECLARE 
vCODIGO_EMPRESA VARCHAR2(4);
vCODIGO_PESSOA VARCHAR2(15);
vDT_REG_OCORRENCIA DATE;
vOCORRENCIA NUMBER;
vOCOR_PROC_MED NUMBER;
vCODIGO_PROC_MED VARCHAR2(15);
vLOGIN_USUARIO VARCHAR2(40);
vOCOR_DOENCA NUMBER;
vCOD_DOENCA VARCHAR2(15);

vTIPO_CONTRATO VARCHAR2(4);
vCODIGO_CONTRATO VARCHAR2(15);
vNATUREZA_EXAME VARCHAR2(4);
vDATA_INI_AFAST DATE;
vDATA_FIM_AFAST DATE;
vC_LIVRE_DATA01 DATE;
vC_LIVRE_DATA02 DATE;

vCONTADOR NUMBER (10);
vID NUMBER;

begin
dbms_output.enable(null);

vCODIGO_EMPRESA := CODIGO_EMPRESA;-- '0001';--
vCODIGO_PESSOA := CODIGO_PESSOA;--'000000001003508';-- 
vDT_REG_OCORRENCIA := DT_REG_OCORRENCIA;-- TO_DATE('15/12/2023','DD/MM/YYYY'); --
vOCORRENCIA := OCORRENCIA; --1;--
vOCOR_PROC_MED := NULL ;
vCODIGO_PROC_MED := NULL ;
vLOGIN_USUARIO := NULL ;
vOCOR_DOENCA := NULL ;
vCOD_DOENCA := NULL ;

vTIPO_CONTRATO := NULL ;
vCODIGO_CONTRATO := NULL ;
vNATUREZA_EXAME := NULL ;
vDATA_INI_AFAST := NULL ;
vDATA_FIM_AFAST := NULL ;
vC_LIVRE_DATA01 := NULL ;
vC_LIVRE_DATA02 := NULL ;


vCONTADOR :=0;
vID :=0;


for c1 in(
--*/

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

--------------------CONDUTA
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
F.CODIGO_EMPRESA = vCODIGO_EMPRESA
AND F.CODIGO_PESSOA = vCODIGO_PESSOA
AND F.DT_REG_OCORRENCIA = vDT_REG_OCORRENCIA
AND F.OCORRENCIA = vOCORRENCIA
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
F.CODIGO_EMPRESA = vCODIGO_EMPRESA
AND F.CODIGO_PESSOA = vCODIGO_PESSOA
AND F.DT_REG_OCORRENCIA = vDT_REG_OCORRENCIA
AND F.OCORRENCIA = vOCORRENCIA

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
F.CODIGO_EMPRESA = vCODIGO_EMPRESA
AND F.CODIGO_PESSOA = vCODIGO_PESSOA
AND F.DT_REG_OCORRENCIA = vDT_REG_OCORRENCIA
AND F.OCORRENCIA = vOCORRENCIA

AND F.DATA_INI_AFAST IS NOT NULL AND F.DATA_FIM_AFAST IS NOT NULL
)X
WHERE X.DADO_ORIGEM_TC1 IS NOT NULL
and X.DADO_ORIGEM_TC2 IS NOT NULL
GROUP BY X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.CODIGO_PESSOA, X.dt_reg_ocorrencia, X.OCORRENCIA, X.DATA_INI_AFAST , X.DATA_FIM_AFAST, X.DADO_ORIGEM_TC1, X.DADO_DESTINO_TC1
, X.DADO_ORIGEM_TC2, X.DADO_DESTINO_TC2, X.DADO_ORIGEM_TC3, X.DADO_DESTINO_TC3


UNION ALL

SELECT 
X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.CODIGO_PESSOA, X.dt_reg_ocorrencia, X.OCORRENCIA, X.DATA_INI_AFAST , X.DATA_FIM_AFAST, 0 CONDUTA, 0 SIM, 0 TEG2 , 1 TEG3,
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
F.CODIGO_EMPRESA = vCODIGO_EMPRESA
AND F.CODIGO_PESSOA = vCODIGO_PESSOA
AND F.DT_REG_OCORRENCIA = vDT_REG_OCORRENCIA
AND F.OCORRENCIA = vOCORRENCIA

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
X5.CODIGO_EMPRESA = vCODIGO_EMPRESA
AND X5.CODIGO_PESSOA = vCODIGO_PESSOA
AND X5.DT_REG_OCORRENCIA = vDT_REG_OCORRENCIA
AND X5.OCORRENCIA = vOCORRENCIA

--WHERE trunc(X5.DATA_INI_AFAST ) <= to_date('01/02/20','dd/mm/yy') --------------------------DATA CORTE DO BM SANEADO----------------------------------------------------------------------------------------------------------------------------------


ORDER BY X5.CODIGO_EMPRESA, X5.TIPO_CONTRATO, X5.CODIGO_CONTRATO, X5.CODIGO_PESSOA,  X5.DATA_INI_AFAST 
------FIM------------------------------NOVA LOGICA


--/*
)
loop
vCONTADOR := vCONTADOR+1;

dbms_output.put_line('');
dbms_output.put_line('--contador: '|| vCONTADOR ||' pessoa: '|| c1.codigo_pessoa || ' dt_reg_ocorrencia: '|| c1.dt_reg_ocorrencia || ' ocorrencia: ' || c1.ocorrencia ||' data_ini_afast: ' || c1.data_ini_afast || ' data_fim_afast: ' || c1.data_fim_afast||' SUM_SIM: '||C1.SUM_SIM||' SUM_TEG2: '||C1.SUM_TEG2||' SUM_TEG3: '||C1.SUM_TEG3||' DADO_ORIGEM_TC1: '||C1.DADO_ORIGEM_TC1||' DADO_DESTINO_TC1: '||C1.DADO_DESTINO_TC1||' DOENCA_GRAVE: '||C1.DOENCA_GRAVE||' SITUACAO_FUNCIONAL: '||C1.SITUACAO_FUNCIONAL||' SITUACAO_PONTO: '||C1.SITUACAO_PONTO);



--RESULTADO
IF C1.DOENCA_GRAVE IN( 'FICHA_SEM_DOENCA_GRAVE', 'FICHA_COM_DOENCA_GRAVE' ) then
dbms_output.put_line('---------------------------RESULTADO: RE PROCESSAR FICHA SEM_DOENCA_GRAVE OU FICHA_COM_DOENCA_GRAVE PARTE DA CAPA E CONDUTA DA FICHA');
--CAPA
SELECT LOGIN_USUARIO, TIPO_CONTRATO, CODIGO_CONTRATO, NATUREZA_EXAME, DATA_INI_AFAST, DATA_FIM_AFAST, C_LIVRE_DATA01, C_LIVRE_DATA02
INTO vLOGIN_USUARIO, vTIPO_CONTRATO, vCODIGO_CONTRATO, vNATUREZA_EXAME, vDATA_INI_AFAST, vDATA_FIM_AFAST, vC_LIVRE_DATA01, vC_LIVRE_DATA02
FROM RHMEDI_FICHA_MED WHERE  CODIGO_EMPRESA = vCODIGO_EMPRESA AND CODIGO_PESSOA = vCODIGO_PESSOA AND TRUNC(DT_REG_OCORRENCIA) = TRUNC(vDT_REG_OCORRENCIA) AND OCORRENCIA = vOCORRENCIA ; 
--/*
INSERT INTO SUGESP_FICHAS_MEDICAS(ID, TIPO_DML, TABELA, CODIGO_EMPRESA, CODIGO_PESSOA, DT_REG_OCORRENCIA, OCORRENCIA, DT_ULT_ALTER_USUA, LOGIN_USUARIO, LOGIN_OS, PROCESSADO
,TIPO_CONTRATO, CODIGO_CONTRATO, NEW_NATUREZA_EXAME, NEW_DATA_INI_AFAST, NEW_DATA_FIM_AFAST, NEW_DATA_INICIAL_INDEFERIMENTO,NEW_DATA_FINAL_INDEFERIMENTO)
VALUES(ARTERH.SEQUENCE_SUGESP_FICHAS_MEDICAS.NEXTVAL, 'U', 'RHMEDI_FICHA_MED', vCODIGO_EMPRESA, vCODIGO_PESSOA, vDT_REG_OCORRENCIA, vOCORRENCIA, SYSDATE, vLOGIN_USUARIO, SYS_CONTEXT('USERENV', 'OS_USER'), 'S'
,vTIPO_CONTRATO, vCODIGO_CONTRATO, vNATUREZA_EXAME, vDATA_INI_AFAST, vDATA_FIM_AFAST, vC_LIVRE_DATA01, vC_LIVRE_DATA02);COMMIT;
dbms_output.put_line('INSERT SUGESP_FICHAS_MEDICAS TABELA ''RHMEDI_FICHA_MED''');
PR_RHMEDI_FICHA_MED_MANUAL('RHMEDI_FICHA_MED', C1.CODIGO_EMPRESA, C1.CODIGO_PESSOA, TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD'),C1.OCORRENCIA, 'M', TO_CHAR(vID));
dbms_output.put_line(' EXECUTE PR_RHMEDI_FICHA_MED_MANUAL(''RHMEDI_FICHA_MED'','''|| C1.CODIGO_EMPRESA ||''','''||C1.CODIGO_PESSOA ||''','''||TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD') ||''', '|| C1.OCORRENCIA ||',''M'','''|| vID ||''' );');

--conduta
SELECT ocor_proc_med, codigo_proc_med, LOGIN_USUARIO INTO vOCOR_PROC_MED, vCODIGO_PROC_MED, vLOGIN_USUARIO 
FROM RHMEDI_RL_FICH_PRO WHERE  CODIGO_EMPRESA = vCODIGO_EMPRESA AND CODIGO_PESSOA = vCODIGO_PESSOA AND TRUNC(DT_REG_OCORRENCIA) = TRUNC(vDT_REG_OCORRENCIA) AND OCORRENCIA = vOCORRENCIA AND ocor_proc_med = 1 ; 
--/*
INSERT INTO SUGESP_FICHAS_MEDICAS(ID, TIPO_DML, TABELA, CODIGO_EMPRESA, CODIGO_PESSOA, DT_REG_OCORRENCIA, OCORRENCIA, NEW_OCOR_PROC_MED, NEW_CODIGO_PROC_MED, DT_ULT_ALTER_USUA, LOGIN_USUARIO, LOGIN_OS, PROCESSADO)
VALUES(ARTERH.SEQUENCE_SUGESP_FICHAS_MEDICAS.NEXTVAL, 'I', 'RHMEDI_RL_FICH_PRO', vCODIGO_EMPRESA, vCODIGO_PESSOA, vDT_REG_OCORRENCIA, vOCORRENCIA, vOCOR_PROC_MED, vCODIGO_PROC_MED, SYSDATE, vLOGIN_USUARIO, SYS_CONTEXT('USERENV', 'OS_USER'), 'S');COMMIT;
dbms_output.put_line('INSERT SUGESP_FICHAS_MEDICAS TABELA ''RHMEDI_RL_FICH_PRO''');
PR_RHMEDI_FICHA_MED_MANUAL('RHMEDI_RL_FICH_PRO', C1.CODIGO_EMPRESA, C1.CODIGO_PESSOA, TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD'),C1.OCORRENCIA, 'M', TO_CHAR(vID));
dbms_output.put_line(' EXECUTE PR_RHMEDI_FICHA_MED_MANUAL(''RHMEDI_RL_FICH_PRO'','''|| C1.CODIGO_EMPRESA ||''','''||C1.CODIGO_PESSOA ||''','''||TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD') ||''', '|| C1.OCORRENCIA ||',''M'','''|| vID ||''' );');

END IF;

IF C1.DOENCA_GRAVE = 'FICHA_COM_DOENCA_GRAVE' then
dbms_output.put_line('---------------------------RESULTADO: RE PROCESSAR FICHA COM_DOENCA_GRAVE PARTE DAS DOENCAS');

    IF C1.SUM_SIM >= 1 THEN---TIPO DE DOENCA GRAVE
    dbms_output.put_line('--doenca APENAS 1');
    SELECT D.OCOR_DOENCA, D.COD_DOENCA, D.LOGIN_USUARIO INTO vOCOR_DOENCA, vCOD_DOENCA, vLOGIN_USUARIO 
    FROM RHMEDI_RL_FICH_DOE D
    LEFT OUTER JOIN RHMEDI_DOENCA DOE ON DOE.CODIGO = D.COD_DOENCA
    WHERE D.CODIGO_EMPRESA = vCODIGO_EMPRESA AND D.CODIGO_PESSOA = vCODIGO_PESSOA AND TRUNC(D.DT_REG_OCORRENCIA) = TRUNC(vDT_REG_OCORRENCIA) AND D.OCORRENCIA = vOCORRENCIA  
    AND DOE.C_LIVRE_OPCAO01 = 'S' AND ROWNUM = 1;

    INSERT INTO SUGESP_FICHAS_MEDICAS(ID, TIPO_DML, TABELA, CODIGO_EMPRESA, CODIGO_PESSOA, DT_REG_OCORRENCIA, OCORRENCIA, NEW_OCOR_DOENCA, NEW_COD_DOENCA, DT_ULT_ALTER_USUA, LOGIN_USUARIO, LOGIN_OS, PROCESSADO)
    VALUES(ARTERH.SEQUENCE_SUGESP_FICHAS_MEDICAS.NEXTVAL, 'I', 'RHMEDI_RL_FICH_DOE', vCODIGO_EMPRESA, vCODIGO_PESSOA, vDT_REG_OCORRENCIA, vOCORRENCIA, vOCOR_DOENCA, vCOD_DOENCA, SYSDATE, vLOGIN_USUARIO, SYS_CONTEXT('USERENV', 'OS_USER'), 'S');COMMIT;
    dbms_output.put_line('INSERT SUGESP_FICHAS_MEDICAS TABELA ''RHMEDI_RL_FICH_DOE''');

    PR_RHMEDI_FICHA_MED_MANUAL('RHMEDI_RL_FICH_DOE', C1.CODIGO_EMPRESA, C1.CODIGO_PESSOA, TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD'),C1.OCORRENCIA, 'M', TO_CHAR(vID));
    dbms_output.put_line(' EXECUTE PR_RHMEDI_FICHA_MED_MANUAL(''RHMEDI_RL_FICH_DOE'','''|| C1.CODIGO_EMPRESA ||''','''||C1.CODIGO_PESSOA ||''','''||TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD') ||''', '|| C1.OCORRENCIA ||',''M'','''|| vID ||''' );');

    ELSIF C1.SUM_TEG2 >= 1 AND C1.SUM_TEG3 >= 1 THEN--
    dbms_output.put_line('--doenca 2 DOENCAS TEG2 E TEG3');
    dbms_output.put_line('--DOENCA 1 TEG2');
    SELECT D.OCOR_DOENCA, D.COD_DOENCA, D.LOGIN_USUARIO INTO vOCOR_DOENCA, vCOD_DOENCA, vLOGIN_USUARIO 
    FROM RHMEDI_FICHA_MED F 
    FULL OUTER JOIN RHMEDI_RL_FICH_PRO C ON F.CODIGO_EMPRESA = C.CODIGO_EMPRESA AND F.CODIGO_PESSOA = C.CODIGO_PESSOA AND F.DT_REG_OCORRENCIA = C.DT_REG_OCORRENCIA AND F.OCORRENCIA = C.OCORRENCIA
    full OUTER JOIN RHMEDI_RL_FICH_DOE D ON F.CODIGO_EMPRESA = D.CODIGO_EMPRESA AND F.CODIGO_PESSOA = D.CODIGO_PESSOA AND F.DT_REG_OCORRENCIA = D.DT_REG_OCORRENCIA AND D.OCORRENCIA = C.OCORRENCIA
    LEFT OUTER JOIN RHMEDI_DOENCA DOE ON DOE.CODIGO = D.COD_DOENCA
    LEFT OUTER JOIN (SELECT A.* FROM RHPESS_CONTRATO A WHERE A.ANO_MES_REFERENCIA = (select max(AUX.ano_mes_referencia) from rhpess_contrato AUX where AUX.codigo_empresa = A.codigo_empresa and AUX.tipo_contrato = A.tipo_contrato and AUX.codigo = A.codigo))A 
        ON C.CODIGO_EMPRESA = F.CODIGO_EMPRESA AND A.TIPO_CONTRATO = F.TIPO_CONTRATO AND A.CODIGO = F.CODIGO_CONTRATO
    LEFT OUTER JOIN RHTABS_VINCULO_EMP V ON V.CODIGO = A.VINCULO
    LEFT OUTER JOIN(SELECT * FROM RHINTE_ED_IT_CONV where codigo_CONVERSAO ='TEG1')TC1 
    ON SUBSTR(TC1.DADO_ORIGEM,1,23) =  F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.CODIGO --novo em 28/8/20
    LEFT OUTER JOIN(SELECT * FROM RHINTE_ED_IT_CONV where codigo_CONVERSAO ='TEG2')TC2 
    ON SUBSTR(TC2.DADO_ORIGEM,1,23) = F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.CODIGO AND SUBSTR(TC2.DADO_ORIGEM,24,LENGTH(TC2.DADO_ORIGEM)) =  DOE.C_LIVRE_DESCR02
    WHERE D.CODIGO_EMPRESA = vCODIGO_EMPRESA AND D.CODIGO_PESSOA = vCODIGO_PESSOA AND TRUNC(D.DT_REG_OCORRENCIA) = TRUNC(vDT_REG_OCORRENCIA) AND D.OCORRENCIA = vOCORRENCIA 
    AND DOE.C_LIVRE_DESCR02 = SUBSTR(TC2.DADO_ORIGEM,24,LENGTH(TC2.DADO_ORIGEM)) AND SUBSTR(TC2.DADO_ORIGEM,1,23) = F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.CODIGO
    AND ROWNUM = 1  ;
    
    INSERT INTO SUGESP_FICHAS_MEDICAS(ID, TIPO_DML, TABELA, CODIGO_EMPRESA, CODIGO_PESSOA, DT_REG_OCORRENCIA, OCORRENCIA, NEW_OCOR_DOENCA, NEW_COD_DOENCA, DT_ULT_ALTER_USUA, LOGIN_USUARIO, LOGIN_OS, PROCESSADO)
    VALUES(ARTERH.SEQUENCE_SUGESP_FICHAS_MEDICAS.NEXTVAL, 'I', 'RHMEDI_RL_FICH_DOE', vCODIGO_EMPRESA, vCODIGO_PESSOA, vDT_REG_OCORRENCIA, vOCORRENCIA, vOCOR_DOENCA, vCOD_DOENCA, SYSDATE, vLOGIN_USUARIO, SYS_CONTEXT('USERENV', 'OS_USER'), 'S');COMMIT;
    dbms_output.put_line('INSERT SUGESP_FICHAS_MEDICAS TABELA ''RHMEDI_RL_FICH_DOE''');
    PR_RHMEDI_FICHA_MED_MANUAL('RHMEDI_RL_FICH_DOE', C1.CODIGO_EMPRESA, C1.CODIGO_PESSOA, TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD'),C1.OCORRENCIA, 'M', TO_CHAR(vID));
    dbms_output.put_line(' EXECUTE PR_RHMEDI_FICHA_MED_MANUAL(''RHMEDI_RL_FICH_DOE'','''|| C1.CODIGO_EMPRESA ||''','''||C1.CODIGO_PESSOA ||''','''||TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD') ||''', '|| C1.OCORRENCIA ||',''M'','''|| vID ||''' );');


    dbms_output.put_line('--DOENCA 2 TEG3');
    SELECT D.OCOR_DOENCA, D.COD_DOENCA, D.LOGIN_USUARIO INTO vOCOR_DOENCA, vCOD_DOENCA, vLOGIN_USUARIO 
    FROM   RHMEDI_FICHA_MED F
    FULL OUTER JOIN RHMEDI_RL_FICH_PRO C ON F.CODIGO_EMPRESA = C.CODIGO_EMPRESA AND F.CODIGO_PESSOA = C.CODIGO_PESSOA AND F.DT_REG_OCORRENCIA = C.DT_REG_OCORRENCIA AND F.OCORRENCIA = C.OCORRENCIA
    full OUTER JOIN RHMEDI_RL_FICH_DOE D ON F.CODIGO_EMPRESA = D.CODIGO_EMPRESA AND F.CODIGO_PESSOA = D.CODIGO_PESSOA AND F.DT_REG_OCORRENCIA = D.DT_REG_OCORRENCIA AND D.OCORRENCIA = C.OCORRENCIA
    LEFT OUTER JOIN RHMEDI_DOENCA DOE ON DOE.CODIGO = D.COD_DOENCA
    LEFT OUTER JOIN (SELECT A.* FROM RHPESS_CONTRATO A WHERE A.ANO_MES_REFERENCIA = (select max(AUX.ano_mes_referencia) from rhpess_contrato AUX where AUX.codigo_empresa = A.codigo_empresa and AUX.tipo_contrato = A.tipo_contrato and AUX.codigo = A.codigo))A 
        ON C.CODIGO_EMPRESA = F.CODIGO_EMPRESA AND A.TIPO_CONTRATO = F.TIPO_CONTRATO AND A.CODIGO = F.CODIGO_CONTRATO
    LEFT OUTER JOIN RHTABS_VINCULO_EMP V ON V.CODIGO = A.VINCULO
    LEFT OUTER JOIN(SELECT * FROM RHINTE_ED_IT_CONV where codigo_CONVERSAO ='TEG1')TC1 
        ON SUBSTR(TC1.DADO_ORIGEM,1,23) =  F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.CODIGO --novo em 28/8/20
    LEFT OUTER JOIN(SELECT * FROM RHINTE_ED_IT_CONV where codigo_CONVERSAO ='TEG3')TC3 
    ON SUBSTR(TC3.DADO_ORIGEM,1,23) = F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.CODIGO AND SUBSTR(TC3.DADO_ORIGEM,24,LENGTH(TC3.DADO_ORIGEM)) =  DOE.C_LIVRE_DESCR02 --2Ã‚Âª DOENCA --NOVO EM 6/7/20
    WHERE D.CODIGO_EMPRESA = vCODIGO_EMPRESA AND D.CODIGO_PESSOA = vCODIGO_PESSOA AND TRUNC(D.DT_REG_OCORRENCIA) = TRUNC(vDT_REG_OCORRENCIA) AND D.OCORRENCIA = vOCORRENCIA 
    AND DOE.C_LIVRE_DESCR02 = SUBSTR(TC3.DADO_ORIGEM,24,LENGTH(TC3.DADO_ORIGEM)) AND SUBSTR(TC3.DADO_ORIGEM,1,23) = F.NATUREZA_EXAME||C.CODIGO_PROC_MED||V.CODIGO
    AND ROWNUM = 1;
  
    INSERT INTO SUGESP_FICHAS_MEDICAS(ID, TIPO_DML, TABELA, CODIGO_EMPRESA, CODIGO_PESSOA, DT_REG_OCORRENCIA, OCORRENCIA, NEW_OCOR_DOENCA, NEW_COD_DOENCA, DT_ULT_ALTER_USUA, LOGIN_USUARIO, LOGIN_OS, PROCESSADO)
    VALUES(ARTERH.SEQUENCE_SUGESP_FICHAS_MEDICAS.NEXTVAL, 'I', 'RHMEDI_RL_FICH_DOE', vCODIGO_EMPRESA, vCODIGO_PESSOA, vDT_REG_OCORRENCIA, vOCORRENCIA, vOCOR_DOENCA, vCOD_DOENCA, SYSDATE, vLOGIN_USUARIO, SYS_CONTEXT('USERENV', 'OS_USER'), 'S');COMMIT;
    dbms_output.put_line('INSERT SUGESP_FICHAS_MEDICAS TABELA ''RHMEDI_RL_FICH_DOE''');
    PR_RHMEDI_FICHA_MED_MANUAL('RHMEDI_RL_FICH_DOE', C1.CODIGO_EMPRESA, C1.CODIGO_PESSOA, TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD'),C1.OCORRENCIA, 'M', TO_CHAR(vID));
    dbms_output.put_line(' EXECUTE PR_RHMEDI_FICHA_MED_MANUAL(''RHMEDI_RL_FICH_DOE'','''|| C1.CODIGO_EMPRESA ||''','''||C1.CODIGO_PESSOA ||''','''||TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD') ||''', '|| C1.OCORRENCIA ||',''M'','''|| vID ||''' );');

    END IF; ---TIPO DE DOENCA GRAVE

END IF;

--*/
end loop;--fim 1 for

END;
END; --1 BEGIN
--*/