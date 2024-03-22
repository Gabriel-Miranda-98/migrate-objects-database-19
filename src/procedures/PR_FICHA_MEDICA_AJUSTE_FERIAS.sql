
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_FICHA_MEDICA_AJUSTE_FERIAS" (ID IN NUMBER) AS 
--KELLYSSON CRIANDO A PARTIR DE 13/7/20
--CONTINUANDO EM 9/12/20
BEGIN

DECLARE
VCONTADOR NUMBER;
VID NUMBER;
VCODIGO_EMPRESA VARCHAR2 (4 BYTE);
VTIPO_CONTRATO VARCHAR2 (4 BYTE);
VCODIGO_CONTRATO VARCHAR2 (15 BYTE);
VDATA_INICIO_DEFERIMENTO DATE;
VDATA_FIM_DEFERIMENTO DATE;
V_ULT_SIT_FUNC0_ATIVA VARCHAR2 (4 BYTE);

BEGIN

DBMS_OUTPUT.ENABLE(NULL);
VID := ID;--92200;--;
VCONTADOR :=0;
VCODIGO_EMPRESA := null;
VTIPO_CONTRATO := null;
VCODIGO_CONTRATO := null;
VDATA_INICIO_DEFERIMENTO := NULL;
VDATA_FIM_DEFERIMENTO := NULL;
V_ULT_SIT_FUNC0_ATIVA := NULL;

------------------- PEGAR AS DATAS DE DEFERIMENTO DO AFASTAMENTO EM QUESTAO ASSIM COMO CAMPOS DO CONTRATO 
/*SELECT 
X.NEW_DATA_INI_AFAST, X.NEW_DATA_FIM_AFAST, X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO 
INTO VDATA_INICIO_DEFERIMENTO, VDATA_FIM_DEFERIMENTO, VCODIGO_EMPRESA, VTIPO_CONTRATO, VCODIGO_CONTRATO
FROM SUGESP_FICHAS_MEDICAS X WHERE X.ID = VID;
*/

/* --INICIO COMENTADO EM 18/12/20
SELECT X3.NEW_DATA_INI_AFAST, X3.NEW_DATA_FIM_AFAST, X3.CODIGO_EMPRESA, X3.TIPO_CONTRATO, X3.CODIGO_CONTRATO 
INTO VDATA_INICIO_DEFERIMENTO, VDATA_FIM_DEFERIMENTO, VCODIGO_EMPRESA, VTIPO_CONTRATO, VCODIGO_CONTRATO
FROM (
SELECT MAX(X2.ID)ULT_ID, 
X2.NEW_DATA_INI_AFAST, X2.NEW_DATA_FIM_AFAST, X2.CODIGO_EMPRESA, X2.TIPO_CONTRATO, X2.CODIGO_CONTRATO 
FROM SUGESP_FICHAS_MEDICAS X2
WHERE EXISTS
(
SELECT X.* FROM SUGESP_FICHAS_MEDICAS X WHERE X.ID =  VID--203366
AND X.CODIGO_EMPRESA = X2.CODIGO_EMPRESA AND X.CODIGO_PESSOA = X2.CODIGO_PESSOA AND X.DT_REG_OCORRENCIA = X2.DT_REG_OCORRENCIA AND X.OCORRENCIA = X2.OCORRENCIA)
AND X2.TABELA = 'RHMEDI_FICHA_MED'
GROUP BY X2.NEW_DATA_INI_AFAST, X2.NEW_DATA_FIM_AFAST, X2.CODIGO_EMPRESA, X2.TIPO_CONTRATO, X2.CODIGO_CONTRATO
)X3;
*/ --FIM COMENTADO EM 18/12/20

--INICIO -- NOVO EM 18/12/20
SELECT 
X3.NEW_DATA_INI_AFAST, X3.NEW_DATA_FIM_AFAST, X3.CODIGO_EMPRESA, X3.TIPO_CONTRATO, X3.CODIGO_CONTRATO 
INTO VDATA_INICIO_DEFERIMENTO, VDATA_FIM_DEFERIMENTO, VCODIGO_EMPRESA, VTIPO_CONTRATO, VCODIGO_CONTRATO
FROM  SUGESP_FICHAS_MEDICAS X3 WHERE X3.ID = (
SELECT MAX(X2.ID)ULT_ID
FROM SUGESP_FICHAS_MEDICAS X2
WHERE EXISTS
(
SELECT X.* FROM SUGESP_FICHAS_MEDICAS X WHERE X.ID =  VID--1039405--203366
AND X.CODIGO_EMPRESA = X2.CODIGO_EMPRESA AND X.CODIGO_PESSOA = X2.CODIGO_PESSOA AND X.DT_REG_OCORRENCIA = X2.DT_REG_OCORRENCIA AND X.OCORRENCIA = X2.OCORRENCIA)
AND X2.TABELA = 'RHMEDI_FICHA_MED'
);
--FIM-- NOVO EM 18/12/20


DBMS_OUTPUT.PUT_LINE('VDATA_INICIO_DEFERIMENTO: '|| VDATA_INICIO_DEFERIMENTO ||' VDATA_FIM_DEFERIMENTO: '||VDATA_FIM_DEFERIMENTO);


--INICIO C1----------------------------------------------------------- PEGAR AS FERIAS VALIDAS NO PERIODO DO AFASTAMENTO
FOR C1 IN (

SELECT  
F.CODIGO_EMPRESA, F.TIPO_CONTRATO, F.CODIGO_CONTRATO, F.TIPO_FERIAS, F.DT_INI_AQUISICAO, F.PERIODO,
'1_FERIAS' TIPO, '9999' COD_SIT_FUNC, 'FERIAS' SITUACAO_FUNCIONAL, 'F' CONTROLE_FOLHA, 'N' E_AFASTAMENTO, P.SITUACAO_PONTO COD_SIT_PONTO,
P.DESCRICAO SITUACAO_PONTO, 'P' TIPO_SITUACAO, F.DT_INI_GOZO DATA_INICIO_FERIAS, 

CASE
    WHEN F.STATUS_CONFIRMACAO in ('5','D')
    THEN
      (SELECT MAX(DT.DATA_DIA)
      FROM RHFERI_FERIAS FF,
        RHTABS_DATAS DT
      WHERE FF.CODIGO_EMPRESA = F.CODIGO_EMPRESA
      AND FF.TIPO_CONTRATO = F.TIPO_CONTRATO
      AND FF.DT_INI_AQUISICAO = F.DT_INI_AQUISICAO
      AND FF.DT_FIM_AQUISICAO = F.DT_FIM_AQUISICAO
      AND FF.CODIGO_CONTRATO = F.codigo_contrato
      AND DT.DATA_DIA BETWEEN F.DT_INI_GOZO AND F.DT_RETORNO-1
      AND FF.STATUS_CONFIRMACAO =F.STATUS_CONFIRMACAO
      AND DT.DATA_DIA NOT          IN
        (SELECT D.DATA_DIA
        FROM RHPARM_CALEND_DT D
        WHERE D.CODIGO  = '0001'
        AND DT.DATA_DIA = D.DATA_DIA))
        else F.DT_FIM_GOZO
  END
DATA_FIM_FERIAS,
NULL PROXIMA_SITUACAO, 0 QTDE_DIAS_PROXIMO, 'N' SUSPENDE_REMUNERA, 9 SO_GERA_SIT_PONTO
FROM RHFERI_FERIAS F
LEFT OUTER JOIN RHPARM_P_FERI P ON P.CODIGO_EMPRESA = F.CODIGO_EMPRESA AND P.CODIGO = F.TIPO_FERIAS
WHERE F.CODIGO_EMPRESA = VCODIGO_EMPRESA  
AND F.TIPO_CONTRATO = VTIPO_CONTRATO  
AND F.CODIGO_CONTRATO = VCODIGO_CONTRATO
AND F.STATUS_CONFIRMACAO in ('1','5','D','G')
AND
(
  (TRUNC(F.DT_INI_GOZO) >= TRUNC(VDATA_INICIO_DEFERIMENTO) AND TRUNC(F.DT_INI_GOZO) <= TRUNC(VDATA_FIM_DEFERIMENTO))
OR (TRUNC(F.DT_INI_GOZO)<  TRUNC(VDATA_INICIO_DEFERIMENTO) AND TRUNC(F.DT_FIM_GOZO) >= TRUNC(VDATA_INICIO_DEFERIMENTO))
)


)LOOP
DBMS_OUTPUT.PUT_LINE('DATA_INICIO_FERIAS: '|| C1.DATA_INICIO_FERIAS ||' DATA_FIM_FERIAS: '||C1.DATA_FIM_FERIAS);

--inicio ------------------------------------FOR C2 PARA VERIFICAR SE NOS PERIODOS EXISTENTES DE FERIAS FOI GERADO SIT FUNC DA FICHA MEDICA
FOR C2 IN (

SELECT 
T.CODIGO_EMPRESA, T.TIPO_CONTRATO, T.CODIGO, T.COD_SIT_FUNC, T.SITUACAO_FUNCIONAL, T.COD_SIT_PONTO, T.SITUACAO_PONTO, 
T.DATA_INICIO_SIT, T.DATA_FIM_SIT--, T.LOGIN_USUARIO, A.DT_ULT_ALTER_USUA
 FROM (
SELECT   A.CODIGO_EMPRESA, A.TIPO_CONTRATO, A.CODIGO,
A.COD_SIT_FUNCIONAL COD_SIT_FUNC, S.DESCRICAO SITUACAO_FUNCIONAL, S.SITUACAO_PONTO COD_SIT_PONTO, P.DESCRICAO SITUACAO_PONTO, 
A.DATA_INIC_SITUACAO DATA_INICIO_SIT, A.DATA_FIM_SITUACAO DATA_FIM_SIT--, A.LOGIN_USUARIO, A.DT_ULT_ALTER_USUA
FROM RHCGED_ALT_SIT_FUN A 
LEFT OUTER JOIN RHPARM_SIT_FUNC S ON S.CODIGO = A.COD_SIT_FUNCIONAL
LEFT OUTER JOIN RHPONT_SITUACAO P ON P.CODIGO = S.SITUACAO_PONTO
WHERE A.CODIGO_EMPRESA = VCODIGO_EMPRESA  
AND A.TIPO_CONTRATO = VTIPO_CONTRATO 
AND A.CODIGO = VCODIGO_CONTRATO

AND S.C_LIVRE_SELEC02 = '2' --NOVO EM 18/12/19

AND A.COD_SIT_FUNCIONAL IN 
(
SELECT X.SIT_FUNC FROM(
SELECT SUBSTR(DADO_DESTINO,1,4) SIT_FUNC FROM RHINTE_ED_IT_CONV WHERE CODIGO_CONVERSAO ='TEG1' AND LENGTH(DADO_DESTINO)> 8 GROUP BY SUBSTR(DADO_DESTINO,1,4)
union all
SELECT SUBSTR(DADO_DESTINO,17,4) SIT_FUNC FROM RHINTE_ED_IT_CONV WHERE CODIGO_CONVERSAO ='TEG1' AND LENGTH(DADO_DESTINO)= 24 GROUP BY SUBSTR(DADO_DESTINO,17,4)
union all
SELECT SUBSTR(DADO_DESTINO,5,4) SIT_FUNC FROM RHINTE_ED_IT_CONV WHERE CODIGO_CONVERSAO ='TG10' GROUP BY SUBSTR(DADO_DESTINO,5,4)--NOVO EM 7/6/22
)X
)

AND
(
(TRUNC(A.DATA_INIC_SITUACAO) <= TRUNC(C1.DATA_INICIO_FERIAS) AND TRUNC(A.DATA_FIM_SITUACAO) >= TRUNC(C1.DATA_FIM_FERIAS))
OR
(TRUNC(A.DATA_FIM_SITUACAO) BETWEEN TRUNC(C1.DATA_INICIO_FERIAS) AND TRUNC(C1.DATA_FIM_FERIAS) AND A.DATA_FIM_SITUACAO IS NOT NULL)
OR
(TRUNC(A.DATA_INIC_SITUACAO) BETWEEN TRUNC(C1.DATA_INICIO_FERIAS) AND TRUNC(C1.DATA_FIM_FERIAS) AND A.DATA_FIM_SITUACAO IS NOT NULL)
OR
(A.DATA_INIC_SITUACAO = (SELECT MAX(AUX.DATA_INIC_SITUACAO)FROM RHCGED_ALT_SIT_FUN AUX
                                WHERE  A.CODIGO_EMPRESA = AUX.CODIGO_EMPRESA AND A.TIPO_CONTRATO = AUX.TIPO_CONTRATO AND A.CODIGO = AUX.CODIGO
                                AND TRUNC(AUX.DATA_INIC_SITUACAO) <= TRUNC(C1.DATA_FIM_FERIAS)
                                AND AUX.DATA_FIM_SITUACAO IS NULL))
) )T  

)LOOP
VCONTADOR := VCONTADOR+1;

DBMS_OUTPUT.PUT_LINE('COD_SIT_FUNC: '|| C2.COD_SIT_FUNC || ' DATA_INICIO_SIT: '|| C2.DATA_INICIO_SIT ||' DATA_FIM_SIT: '||C2.DATA_FIM_SIT);

-- inicio ---------------------BUSCAR ULTIMA SITUAÇÃO FUNCIONAL TIPO ATIVA ANTES DO ATESTADO
select A.COD_SIT_FUNCIONAL
into V_ULT_SIT_FUNC0_ATIVA
--, A.DATA_FIM_SITUACAO, A.DATA_INIC_SITUACAO, S.DESCRICAO SITUACAO_FUNCIONAL, S.CONTROLE_FOLHA, S.E_AFASTAMENTO,s.suspende_remunera, s.c_livre_selec02 SO_GERA_SIT_PONTO,S.SITUACAO_PONTO COD_SIT_PONTO, P.DESCRICAO SITUACAO_PONTO, p.tipo_situacao
from RHCGED_ALT_SIT_FUN A
LEFT OUTER JOIN RHPARM_SIT_FUNC S ON S.CODIGO = A.COD_SIT_FUNCIONAL
LEFT OUTER JOIN RHPONT_SITUACAO P ON P.CODIGO = S.SITUACAO_PONTO
WHERE A.CODIGO_EMPRESA = C2.CODIGO_EMPRESA --'0001'--
AND A.TIPO_CONTRATO = C2.TIPO_CONTRATO--'0001'--
AND A.CODIGO = C2.CODIGO--'000000000913158'--
AND
A.DATA_INIC_SITUACAO = (SELECT MAX(AUX.DATA_INIC_SITUACAO)FROM RHCGED_ALT_SIT_FUN AUX
                                 LEFT OUTER JOIN RHPARM_SIT_FUNC SX ON SX.CODIGO = AUX.COD_SIT_FUNCIONAL
                                WHERE  A.CODIGO_EMPRESA = AUX.CODIGO_EMPRESA AND A.TIPO_CONTRATO = AUX.TIPO_CONTRATO AND A.CODIGO = AUX.CODIGO
                                AND trunc(AUX.DATA_INIC_SITUACAO) < TRUNC(C2.DATA_INICIO_SIT)--TO_DATE('02/06/2020','DD/MM/YYYY')-- -TRUNC(C1.OLD_DATA_INI_AFAST)
                                AND SX.CONTROLE_FOLHA = 'N' and SX.E_AFASTAMENTO = 'N' and SX.suspende_remunera = 'N' AND SX.C_LIVRE_SELEC02 = '2')
AND S.CONTROLE_FOLHA = 'N' and S.E_AFASTAMENTO = 'N' and S.suspende_remunera = 'N' AND S.C_LIVRE_SELEC02 = '2';
-- FIM ---------------------BUSCAR ULTIMA SITUAÇÃO FUNCIONAL TIPO ATIVA ANTES DO ATESTADO


--------------------------------------------------------------INICIO--IF PARA O QUE FAZER
/*IF VCONTADOR = 1 AND TRUNC(C1.DATA_INICIO_FERIAS) < TRUNC(C2.DATA_INICIO_SIT) AND TRUNC(C1.DATA_FIM_FERIAS) >= TRUNC(C2.DATA_FIM_SIT) THEN
DBMS_OUTPUT.PUT_LINE('--1.1-FERIAS COMECOU ANTES DO INICIO AFASTAMENTO E TERMINOU AS FERIAS DEPOIS DO FIM DO AFASTAMENTO');
DBMS_OUTPUT.PUT_LINE('--ENTAO: TROCA O CODIGO DA SIT FUNC GRAVADA DE AFASTAMENTO PARA ATIVO, CODIGO:' ||V_ULT_SIT_FUNC0_ATIVA);
ELSIF VCONTADOR <> 1 AND TRUNC(C1.DATA_INICIO_FERIAS) < TRUNC(C2.DATA_INICIO_SIT) AND TRUNC(C1.DATA_FIM_FERIAS) >= TRUNC(C2.DATA_FIM_SIT) THEN
DBMS_OUTPUT.PUT_LINE('--1.2-FERIAS COMECOU ANTES DO INICIO AFASTAMENTO E TERMINOU AS FERIAS DEPOIS DO FIM DO AFASTAMENTO');
DBMS_OUTPUT.PUT_LINE('--ENTAO: TROCA O CODIGO DA SIT FUNC GRAVADA DE AFASTAMENTO PARA ATIVO, CODIGO:' ||V_ULT_SIT_FUNC0_ATIVA);
*/
--VDATA_INICIO_DEFERIMENTO: 02/06/2020 VDATA_FIM_DEFERIMENTO: 08/06/2020
--DATA_INICIO_FERIAS: 02/06/2020 DATA_FIM_FERIAS: 05/06/2020

IF TRUNC(C1.DATA_INICIO_FERIAS) < (VDATA_INICIO_DEFERIMENTO)
AND TRUNC(C1.DATA_INICIO_FERIAS) < TRUNC(C2.DATA_INICIO_SIT) AND TRUNC(C1.DATA_FIM_FERIAS) >= TRUNC(C2.DATA_FIM_SIT) THEN
DBMS_OUTPUT.PUT_LINE('--1-FERIAS COMECOU ANTES DO INICIO AFASTAMENTO E TERMINOU AS FERIAS DEPOIS DO FIM DO AFASTAMENTO');
DBMS_OUTPUT.PUT_LINE('--ENTAO: TROCA O CODIGO DA SIT FUNC GRAVADA DE AFASTAMENTO PARA ATIVO, CODIGO:' ||V_ULT_SIT_FUNC0_ATIVA);
UPDATE RHCGED_ALT_SIT_FUN SET COD_SIT_FUNCIONAL = V_ULT_SIT_FUNC0_ATIVA WHERE CODIGO_EMPRESA = C2.CODIGO_EMPRESA AND TIPO_CONTRATO = C2.TIPO_CONTRATO AND CODIGO = C2.CODIGO AND TRUNC(DATA_INIC_SITUACAO) = TRUNC(C2.DATA_INICIO_SIT);  COMMIT;
SUGESP_ALT_SIT_FUNC_ULT_CONTRA(C2.CODIGO_EMPRESA ,C2.TIPO_CONTRATO , C2.CODIGO ,'PR_FICHA_MEDICA_AJUSTE_FERIAS');

ELSIF TRUNC(C1.DATA_INICIO_FERIAS) < (VDATA_INICIO_DEFERIMENTO)
AND TRUNC(C1.DATA_INICIO_FERIAS) < TRUNC(C2.DATA_INICIO_SIT) AND TRUNC(C1.DATA_FIM_FERIAS) < TRUNC(C2.DATA_FIM_SIT) THEN
DBMS_OUTPUT.PUT_LINE('--2-FERIAS COMECOU ANTES DO INICIO AFASTAMENTO E TERMINOU ANTES DO FIM DO AFASTAMENTO');
DBMS_OUTPUT.PUT_LINE('--ENTAO 1: TROCA O CODIGO DA SIT FUNC GRAVADA DE AFASTAMENTO PARA ATIVO, V_ULT_SIT_FUNC0_ATIVA:' ||V_ULT_SIT_FUNC0_ATIVA|| ' E DIMINUO A DATA FIM DA SIT FUNC ATIVA ATE O FIM DAS FERIAS: '|| C1.DATA_FIM_FERIAS);
UPDATE RHCGED_ALT_SIT_FUN SET COD_SIT_FUNCIONAL = V_ULT_SIT_FUNC0_ATIVA, DATA_FIM_SITUACAO = TRUNC(C1.DATA_FIM_FERIAS) WHERE CODIGO_EMPRESA = C2.CODIGO_EMPRESA AND TIPO_CONTRATO = C2.TIPO_CONTRATO AND CODIGO = C2.CODIGO AND TRUNC(DATA_INIC_SITUACAO) = TRUNC(C2.DATA_INICIO_SIT);  COMMIT;
--COMENTADO EM 27/8/21 para ver se resolve os casos como o do email da Lilian Rabelo (Situação funcional 1000 sem data fim gerada pela ficha médica)--SUGESP_ALT_SIT_FUNC_ULT_CONTRA(C2.CODIGO_EMPRESA ,C2.TIPO_CONTRATO , C2.CODIGO ,'PR_FICHA_MEDICA_AJUSTE_FERIAS');
DBMS_OUTPUT.PUT_LINE('--ENTAO 2: CRIO SIT FUNC GRAVADA DE AFASTAMENTO, C2.COD_SIT_FUNC:' ||C2.COD_SIT_FUNC|| ' 1 DIA DEPOIS DO FIM DAS FERIAS, C1.DATA_FIM_FERIAS '|| C1.DATA_FIM_FERIAS||' COM A DATA FIM DO AFASTAMENTO VDATA_FIM_DEFERIMENTO:'||VDATA_FIM_DEFERIMENTO);
DELETE RHCGED_ALT_SIT_FUN WHERE CODIGO_EMPRESA = C2.CODIGO_EMPRESA AND  TIPO_CONTRATO = C2.TIPO_CONTRATO AND CODIGO = C2.CODIGO 
AND TRUNC(DATA_INIC_SITUACAO) = TRUNC(C1.DATA_FIM_FERIAS)+1 AND COD_SIT_FUNCIONAL = C2.COD_SIT_FUNC; COMMIT;
INSERT INTO RHCGED_ALT_SIT_FUN (IND_EF_RETRO_ESOCIAL,CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO, DATA_INIC_SITUACAO, DATA_FIM_SITUACAO, COD_SIT_FUNCIONAL, LOGIN_USUARIO, DT_ULT_ALTER_USUA
,PROXIMA_SITUACAO --NOVO EM 17/12/21
)
VALUES ('N', C2.CODIGO_EMPRESA, C2.TIPO_CONTRATO, C2.CODIGO, TRUNC(C1.DATA_FIM_FERIAS)+1, VDATA_FIM_DEFERIMENTO, C2.COD_SIT_FUNC, 'PR_FICHA_MEDICA_AJUSTE_FERIAS', SYSDATE
,V_ULT_SIT_FUNC0_ATIVA --NOVO EM 17/12/21
);COMMIT;
SUGESP_ALT_SIT_FUNC_ULT_CONTRA(C2.CODIGO_EMPRESA ,C2.TIPO_CONTRATO , C2.CODIGO ,'PR_FICHA_MEDICA_AJUSTE_FERIAS');

ELSIF TRUNC(C1.DATA_INICIO_FERIAS) >= (VDATA_INICIO_DEFERIMENTO) 
AND TRUNC(C1.DATA_INICIO_FERIAS) >= TRUNC(C2.DATA_INICIO_SIT) THEN
DBMS_OUTPUT.PUT_LINE('--3-FERIAS COMECOU NO MESMO DIA OU DURANTE O AFASTAMENTO');
DBMS_OUTPUT.PUT_LINE('--ENTAO: TROCO O STATUS DAS FERIAS PARA ''Q''');
UPDATE RHFERI_FERIAS SET STATUS_CONFIRMACAO = 'Q', DT_ULT_ALTER_USUA = SYSDATE, LOGIN_USUARIO = 'PR_FICHA_MEDICA_AJUSTE_FERIAS' 
WHERE CODIGO_EMPRESA = C1.CODIGO_EMPRESA AND TIPO_CONTRATO = C1.TIPO_CONTRATO AND CODIGO_CONTRATO = C1.CODIGO_CONTRATO AND TIPO_FERIAS = C1.TIPO_FERIAS AND DT_INI_AQUISICAO = C1.DT_INI_AQUISICAO AND  PERIODO = C1.PERIODO; COMMIT;

END IF;


END LOOP;
--FIM ------------------------------------FOR C2 PARA VERIFICAR SE NOS PERIODOS EXISTENTES DE FERIAS FOI GERADO SIT FUNC DA FICHA MEDICA

END LOOP;
--FIM C1 ------------------------------------------------------------- PEGAR AS FERIAS VALIDAS NO PERIODO DO AFASTAMENTO

END;

END;