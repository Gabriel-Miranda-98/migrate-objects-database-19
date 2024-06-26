
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."RHPBH_TEG_1" (  DATA_1 IN DATE , DATA_2 IN DATE ) AS
vDATA_1 DATE:= DATA_1;
vDATA_2 DATE:= DATA_2;
vCONTADOR NUMBER;
BEGIN
dbms_output.enable(null);
vCONTADOR :=0;

/*1 DELETE PARA EXCLUIR AS SITUAÇÕES DE PONTO 0535 CONCOMITANTES AS LICENÇAS MÉDICAS */
DELETE FROM RHPONT_RES_SIT_DIA A WHERE EXISTS (
SELECT SIT_535.codigo_empresa, SIT_535.tipo_contrato, SIT_535.codigo_contrato, SIT_535.data, SIT_535.codigo_situacao,
SIT_535.tipo_apuracao
FROM (SELECT CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, Tipo_apuracao
FROM RHPONT_RES_SIT_DIA WHERE CODIGO_SITUACAO in
('0516', '0519', '0538', '0541', '0542', '0546', '0547', '0548', '0549', '0550', '0551')) SIT_516,
(SELECT CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, TIPO_APURACAO
FROM RHPONT_RES_SIT_DIA WHERE CODIGO_SITUACAO = '0535') SIT_535
WHERE SIT_516.CODIGO_EMPRESA = SIT_535.CODIGO_EMPRESA
AND SIT_516.TIPO_CONTRATO = SIT_535.TIPO_CONTRATO
AND SIT_516.CODIGO_CONTRATO = SIT_535.CODIGO_CONTRATO
AND SIT_516.DATA = SIT_535.DATA
AND SIT_516.DATA >= vDATA_1
AND A.CODIGO_EMPRESA = SIT_535.CODIGO_EMPRESA
AND A.TIPO_CONTRATO = SIT_535.TIPO_CONTRATO
AND A.CODIGO_CONTRATO = SIT_535.CODIGO_CONTRATO
AND A.DATA = SIT_535.DATA
AND A.CODIGO_SITUACAO = SIT_535.CODIGO_SITUACAO
AND A.TIPO_APURACAO = SIT_535.TIPO_APURACAO
);
COMMIT;
dbms_output.put_line('DELETE CONCLUÍDO COM SUCESSO');

/*2 UPDATE PARA ATUALIZAR OS CÓDIGOS 0535 - LICENÇA MÉDICA PENDENTE COM OS CÓDIGOS DE LICENÇAS MÉDICAS DEFERIDAS OU PARCIAL DEFERIDA */
FOR C1 IN (
    SELECT RHPONT_RES_SIT_DIA.*, RHMEDI_FICHA_MED.NATUREZA_EXAME
    FROM RHPONT_RES_SIT_DIA, RHMEDI_FICHA_MED, RHMEDI_RL_FICH_PRO
    WHERE RHPONT_RES_SIT_DIA.CODIGO_SITUACAO = '0535'
    AND  RHMEDI_FICHA_MED.CODIGO_EMPRESA = RHPONT_RES_SIT_DIA.CODIGO_EMPRESA
    AND  RHMEDI_FICHA_MED.TIPO_CONTRATO = RHPONT_RES_SIT_DIA.TIPO_CONTRATO
    AND  RHMEDI_FICHA_MED.CODIGO_CONTRATO = RHPONT_RES_SIT_DIA.CODIGO_CONTRATO
    AND ((RHMEDI_FICHA_MED.DATA_INI_AFAST IS NOT NULL AND RHMEDI_FICHA_MED.DATA_FIM_AFAST IS NOT NULL))
    AND RHPONT_RES_SIT_DIA.DATA >= RHMEDI_FICHA_MED.DATA_INI_AFAST
    AND RHPONT_RES_SIT_DIA.DATA <= RHMEDI_FICHA_MED.DATA_FIM_AFAST
    AND RHPONT_RES_SIT_DIA.DATA >= vDATA_1
    AND RHMEDI_FICHA_MED.CODIGO_EMPRESA = RHMEDI_RL_FICH_PRO.CODIGO_EMPRESA
    AND RHMEDI_FICHA_MED.CODIGO_PESSOA  = RHMEDI_RL_FICH_PRO.CODIGO_PESSOA
    AND RHMEDI_FICHA_MED.DT_REG_OCORRENCIA = RHMEDI_RL_FICH_PRO.DT_REG_OCORRENCIA
    AND RHMEDI_FICHA_MED.OCORRENCIA = RHMEDI_RL_FICH_PRO.OCORRENCIA
    AND RHMEDI_FICHA_MED.NATUREZA_EXAME in ('0104', '0105', '0107', '0108', '0113', '0114', '0116')
    AND RHMEDI_RL_FICH_PRO.CODIGO_PROC_MED IN
    /*concedidas/ parcial deferida/ profissional confirmada/ acidente concedida/ encaminhamento ao inss */
    ('000000000000001', '000000000000003', '000000000000017', '000000000000027', '000000000000038')
) LOOP
    vCONTADOR :=vCONTADOR+1;
    /*dbms_output.put_line('UPDATE :' || vCONTADOR);*/

    UPDATE RHPONT_RES_SIT_DIA  SET
    CODIGO_SITUACAO = CASE C1.NATUREZA_EXAME /*concedidas*/
      WHEN '0107' THEN '0519' /*DOENÇA EM PESSOA FAMILIA COM REMUNERAÇÃO*/
      WHEN '0113' THEN '0549' /* LICENÇA MEDICA DOENÇA OCUPACIONAL*/
      WHEN '0114' THEN '0548' /* LICENÇA MÉDICA  ACIDENTE TRABALHO*/
      ELSE '0516' /*104, 105, 108, 116 licença médica*/
    END,
    TEXTO_ASSOCIADO =  'PERICIA MEDICA - TEG',
    LOGIN_USUARIO =  'TEG-IMPORTACAO-UP',
    DT_ULT_ALTER_USUA = SYSDATE
    WHERE RHPONT_RES_SIT_DIA.CODIGO_EMPRESA = C1.CODIGO_EMPRESA
    AND RHPONT_RES_SIT_DIA.TIPO_CONTRATO = C1.TIPO_CONTRATO
    AND RHPONT_RES_SIT_DIA.CODIGO_CONTRATO = C1.CODIGO_CONTRATO
    AND RHPONT_RES_SIT_DIA.DATA = C1.DATA
    AND RHPONT_RES_SIT_DIA.CODIGO_SITUACAO = C1.CODIGO_SITUACAO
    AND RHPONT_RES_SIT_DIA.TIPO_APURACAO = C1.TIPO_APURACAO
    AND RHPONT_RES_SIT_DIA.CODIGO_EMPRESA = '0001';
END LOOP;
COMMIT;
dbms_output.put_line('UPDATE LICENÇAS CONCEDIDAS CONCLUÍDO COM SUCESSO');

/*3 UPDATE PARA ATUALIZAR OS CÓDIGOS 0535 - LICENÇA MÉDICA PENDENTE COM OS CÓDIGOS DE LICENÇAS MÉDICAS NEGADA OU PARCIAL NEGADA */
/*RETIRADO 11-01-2019*/

/*4 INSERÇÃO DAS SITUAÇÕES DE PONTO REFERENTE AS FICHAS MÉDICAS IMPORTADAS
PARA LICENÇAS DEFERIDAS*/
  insert into RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA,
  CODIGO_SITUACAO, REF_HORAS, REF_HORAS_NOVA_SIT, TIPO_APURACAO, LOGIN_USUARIO, DT_ULT_ALTER_USUA, TEXTO_ASSOCIADO)
  SELECT distinct RHMEDI_FICHA_MED.CODIGO_EMPRESA, '0001' as TIPO_CONTRATO, RHMEDI_FICHA_MED.CODIGO_CONTRATO,
  DATA_PONTO.CUR_DATE AS DATA,
  CASE RHMEDI_FICHA_MED.natureza_exame /*concedidas*/
      WHEN '0107' THEN '0519' /*DOENÇA EM PESSOA FAMILIA COM REMUNERAÇÃO*/
      WHEN '0113' THEN '0549' /* LICENÇA MEDICA DOENÇA OCUPACIONAL*/
      WHEN '0114' THEN '0548' /* LICENÇA MÉDICA  ACIDENTE TRABALHO*/
      ELSE '0516' /*licença médica CONCEDIDA*/
  END CODIGO_SITUACAO,
  '1' as REF_HORAS, '0' as REF_HORAS_NOVA_SIT, 'F' AS TIPO_APURACAO,
  'TEG-IMPORTACAO' AS LOGIN_USUARIO,  sysdate as dt_ult_alter_usua,
  'PERICIA MEDICA - TEG' AS TEXTO_ASSOCIADO
  FROM RHMEDI_FICHA_MED, RHMEDI_RL_FICH_PRO,(select trunc(vDATA_1)+rownum-1 cur_date
  from dual connect by level <= trunc(vDATA_2 - trunc(vDATA_1))) DATA_PONTO
  where RHMEDI_FICHA_MED.CODIGO_EMPRESA = RHMEDI_RL_FICH_PRO.CODIGO_EMPRESA
  AND RHMEDI_FICHA_MED.CODIGO_EMPRESA = '0001' /*SÓ PARA ATIVOS*/
  AND RHMEDI_FICHA_MED.CODIGO_PESSOA  = RHMEDI_RL_FICH_PRO.CODIGO_PESSOA
  AND RHMEDI_FICHA_MED.DT_REG_OCORRENCIA = RHMEDI_RL_FICH_PRO.DT_REG_OCORRENCIA
  AND RHMEDI_FICHA_MED.OCORRENCIA = RHMEDI_RL_FICH_PRO.OCORRENCIA
  AND RHMEDI_FICHA_MED.CODIGO_CONTRATO IS NOT NULL
  AND RHMEDI_FICHA_MED.NATUREZA_EXAME in ('0104', '0105', '0107', '0108', '0113', '0114', '0115', '0116')
  AND RHMEDI_RL_FICH_PRO.CODIGO_PROC_MED IN
  /*concedidas / parcial / profissional confirmada / acidente concedida*/
  ('000000000000001', '000000000000003', '000000000000017', '000000000000027')
  AND ((RHMEDI_FICHA_MED.DATA_INI_AFAST IS NOT NULL AND RHMEDI_FICHA_MED.DATA_FIM_AFAST IS NOT NULL))
  AND DATA_PONTO.CUR_DATE >= DATA_INI_AFAST
  AND DATA_PONTO.CUR_DATE <= DATA_FIM_AFAST
  AND NOT EXISTS (
    SELECT RHPONT_RES_SIT_DIA.CODIGO_EMPRESA, RHPONT_RES_SIT_DIA.TIPO_CONTRATO, RHPONT_RES_SIT_DIA.CODIGO_CONTRATO,
    RHPONT_RES_SIT_DIA.DATA, RHPONT_RES_SIT_DIA.CODIGO_SITUACAO, RHPONT_RES_SIT_DIA.REF_HORAS,
    RHPONT_RES_SIT_DIA.REF_HORAS_NOVA_SIT, RHPONT_RES_SIT_DIA.TIPO_APURACAO, RHPONT_RES_SIT_DIA.LOGIN_USUARIO,
    RHPONT_RES_SIT_DIA.DT_ULT_ALTER_USUA, RHPONT_RES_SIT_DIA.TEXTO_ASSOCIADO
    FROM RHPONT_RES_SIT_DIA, RHMEDI_FICHA_MED M, RHMEDI_RL_FICH_PRO P
    WHERE RHPONT_RES_SIT_DIA.CODIGO_SITUACAO in
   ('0516', '0519', '0538', '0541', '0542', '0546', '0547', '0548', '0549', '0550', '0551')
    AND  M.CODIGO_EMPRESA = RHPONT_RES_SIT_DIA.CODIGO_EMPRESA
    AND  M.TIPO_CONTRATO = RHPONT_RES_SIT_DIA.TIPO_CONTRATO
    AND  M.CODIGO_CONTRATO = RHPONT_RES_SIT_DIA.CODIGO_CONTRATO
    AND ((M.DATA_INI_AFAST IS NOT NULL AND M.DATA_FIM_AFAST IS NOT NULL))
    AND RHPONT_RES_SIT_DIA.DATA >= M.DATA_INI_AFAST
    AND RHPONT_RES_SIT_DIA.DATA <= M.DATA_FIM_AFAST
    AND RHPONT_RES_SIT_DIA.DATA >= vDATA_1
    AND RHPONT_RES_SIT_DIA.DATA = DATA_PONTO.CUR_DATE
    AND M.CODIGO_EMPRESA = P.CODIGO_EMPRESA
    AND M.CODIGO_PESSOA  = P.CODIGO_PESSOA
    AND M.DT_REG_OCORRENCIA = P.DT_REG_OCORRENCIA
    AND M.OCORRENCIA = P.OCORRENCIA
    AND P.CODIGO_PROC_MED IN
    /*concedidas / parcial / profissional confirmada / acidente concedida*/
    ('000000000000001', '000000000000003', '000000000000017', '000000000000027')
    AND RHMEDI_FICHA_MED.CODIGO_EMPRESA = RHPONT_RES_SIT_DIA.CODIGO_EMPRESA
    AND RHMEDI_FICHA_MED.CODIGO_EMPRESA = '0001'
    AND RHMEDI_FICHA_MED.TIPO_CONTRATO = RHPONT_RES_SIT_DIA.TIPO_CONTRATO
    AND RHMEDI_FICHA_MED.CODIGO_CONTRATO = RHPONT_RES_SIT_DIA.CODIGO_CONTRATO
  );
COMMIT;
dbms_output.put_line('INSERT LICENÇAS CONCEDIDAS CONCLUÍDO COM SUCESSO');


/*5 INSERÇÃO DAS SITUAÇÕES DE PONTO REFERENTE AS FICHAS MÉDICAS IMPORTADAS
PARA LICENÇAS INDEFERIDAS*/
/*RETIRADO 11-01-2019*/

/*6 UPDATE PARA ATUALIZAR OS CÓDIGOS 0516 - LICENÇA MÉDICA PELA 0549 - LICENÇA MEDICA DOENÇA OCUPACIONAL ANEXO 1*/
FOR C1 IN (
SELECT  RHPONT_RES_SIT_DIA.*
    FROM RHMEDI_FICHA_MED, RHMEDI_RL_FICH_DOE FICHA_DOE1, RHMEDI_DOENCA DOE1,RHPONT_RES_SIT_DIA
    WHERE (RHMEDI_FICHA_MED.DATA_INI_AFAST IS NOT NULL AND RHMEDI_FICHA_MED.DATA_FIM_AFAST IS NOT NULL)
    AND RHMEDI_FICHA_MED.CODIGO_EMPRESA = FICHA_DOE1.CODIGO_EMPRESA
    AND RHMEDI_FICHA_MED.CODIGO_PESSOA = FICHA_DOE1.CODIGO_PESSOA
    AND RHMEDI_FICHA_MED.DT_REG_OCORRENCIA = FICHA_DOE1.DT_REG_OCORRENCIA
    AND RHMEDI_FICHA_MED.OCORRENCIA = FICHA_DOE1.OCORRENCIA
    AND FICHA_DOE1.COD_DOENCA = DOE1.CODIGO
    AND DOE1.C_LIVRE_OPCAO01 = 'S'
    AND RHPONT_RES_SIT_DIA.CODIGO_SITUACAO IN ('0516', '0519')
    AND RHMEDI_FICHA_MED.CODIGO_EMPRESA = RHPONT_RES_SIT_DIA.CODIGO_EMPRESA
    AND RHMEDI_FICHA_MED.CODIGO_EMPRESA = '0001'
    AND RHMEDI_FICHA_MED.TIPO_CONTRATO = RHPONT_RES_SIT_DIA.TIPO_CONTRATO
    AND RHMEDI_FICHA_MED.CODIGO_CONTRATO = RHPONT_RES_SIT_DIA.CODIGO_CONTRATO
    AND RHPONT_RES_SIT_DIA.DATA >= to_date('01/12/2017', 'dd/mm/yyyy')
    AND RHPONT_RES_SIT_DIA.DATA BETWEEN RHMEDI_FICHA_MED.DATA_INI_AFAST AND RHMEDI_FICHA_MED.DATA_FIM_AFAST
    ORDER BY RHPONT_RES_SIT_DIA.CODIGO_CONTRATO, RHPONT_RES_SIT_DIA.DATA

) LOOP
    vCONTADOR :=vCONTADOR+1;
    /*dbms_output.put_line('UPDATE :' || vCONTADOR || 'DOENÇAS. ');*/

    UPDATE RHPONT_RES_SIT_DIA  SET
    CODIGO_SITUACAO = '0547',
    TEXTO_ASSOCIADO = 'PERICIA MEDICA - TEG',
    LOGIN_USUARIO =  'TEG-IMPORTACAO',
    DT_ULT_ALTER_USUA = SYSDATE
    WHERE RHPONT_RES_SIT_DIA.CODIGO_EMPRESA = C1.CODIGO_EMPRESA
    AND RHPONT_RES_SIT_DIA.TIPO_CONTRATO = C1.TIPO_CONTRATO
    AND RHPONT_RES_SIT_DIA.CODIGO_CONTRATO = C1.CODIGO_CONTRATO
    AND RHPONT_RES_SIT_DIA.DATA = C1.DATA
    AND RHPONT_RES_SIT_DIA.CODIGO_SITUACAO = C1.CODIGO_SITUACAO
    AND RHPONT_RES_SIT_DIA.TIPO_APURACAO = C1.TIPO_APURACAO;
END LOOP;
COMMIT;
dbms_output.put_line('UPDATE ENFERMIDADES ANEXO 1 CONCLUÍDO COM SUCESSO');


/*7 UPDATE PARA ATUALIZAR OS CÓDIGOS 0516 - LICENÇA MÉDICA PELA 0549 - LICENÇA MEDICA DOENÇA OCUPACIONAL ANEXO 2*/
FOR C1 IN (
  SELECT RHPONT_RES_SIT_DIA.*
  FROM RHMEDI_FICHA_MED, RHMEDI_RL_FICH_DOE FICHA_DOE1, RHMEDI_DOENCA DOE1,
  RHMEDI_RL_FICH_DOE FICHA_DOE2, RHMEDI_DOENCA DOE2,
  RHPONT_RES_SIT_DIA
  WHERE (RHMEDI_FICHA_MED.DATA_INI_AFAST IS NOT NULL AND RHMEDI_FICHA_MED.DATA_FIM_AFAST IS NOT NULL)
  AND RHMEDI_FICHA_MED.CODIGO_EMPRESA = FICHA_DOE1.CODIGO_EMPRESA
  AND RHMEDI_FICHA_MED.CODIGO_PESSOA = FICHA_DOE1.CODIGO_PESSOA
  AND RHMEDI_FICHA_MED.DT_REG_OCORRENCIA = FICHA_DOE1.DT_REG_OCORRENCIA
  AND RHMEDI_FICHA_MED.OCORRENCIA = FICHA_DOE1.OCORRENCIA
  AND FICHA_DOE1.COD_DOENCA = DOE1.CODIGO
  AND RHMEDI_FICHA_MED.CODIGO_EMPRESA = FICHA_DOE2.CODIGO_EMPRESA
  AND RHMEDI_FICHA_MED.CODIGO_PESSOA = FICHA_DOE2.CODIGO_PESSOA
  AND RHMEDI_FICHA_MED.DT_REG_OCORRENCIA = FICHA_DOE2.DT_REG_OCORRENCIA
  AND RHMEDI_FICHA_MED.OCORRENCIA = FICHA_DOE2.OCORRENCIA
  AND FICHA_DOE2.COD_DOENCA = DOE2.CODIGO
  AND (DOE1.C_LIVRE_DESCR02 IN ('A', 'B', 'G', 'I', 'J', 'K70-77', 'N00-29') AND
       DOE2.C_LIVRE_DESCR02 IN ('Z548', 'Z549'))
  AND RHPONT_RES_SIT_DIA.CODIGO_SITUACAO IN ('0516', '0519')
  AND RHMEDI_FICHA_MED.CODIGO_EMPRESA = RHPONT_RES_SIT_DIA.CODIGO_EMPRESA
  AND RHMEDI_FICHA_MED.CODIGO_EMPRESA = '0001'
  AND RHMEDI_FICHA_MED.TIPO_CONTRATO = RHPONT_RES_SIT_DIA.TIPO_CONTRATO
  AND RHMEDI_FICHA_MED.CODIGO_CONTRATO = RHPONT_RES_SIT_DIA.CODIGO_CONTRATO
  AND RHPONT_RES_SIT_DIA.DATA >= to_date('01/12/2017', 'dd/mm/yyyy')
  AND RHPONT_RES_SIT_DIA.DATA BETWEEN RHMEDI_FICHA_MED.DATA_INI_AFAST AND RHMEDI_FICHA_MED.DATA_FIM_AFAST
  ORDER BY RHPONT_RES_SIT_DIA.CODIGO_CONTRATO, RHPONT_RES_SIT_DIA.DATA

) LOOP
    vCONTADOR :=vCONTADOR+1;
    /*dbms_output.put_line('UPDATE :' || vCONTADOR);*/

    UPDATE RHPONT_RES_SIT_DIA  SET
    CODIGO_SITUACAO = '0547',
    TEXTO_ASSOCIADO = 'PERICIA MEDICA - TEG',
    LOGIN_USUARIO =  'TEG-IMPORTACAO',
    DT_ULT_ALTER_USUA = SYSDATE
    WHERE RHPONT_RES_SIT_DIA.CODIGO_EMPRESA = C1.CODIGO_EMPRESA
    AND RHPONT_RES_SIT_DIA.TIPO_CONTRATO = C1.TIPO_CONTRATO
    AND RHPONT_RES_SIT_DIA.CODIGO_CONTRATO = C1.CODIGO_CONTRATO
    AND RHPONT_RES_SIT_DIA.DATA = C1.DATA
    AND RHPONT_RES_SIT_DIA.CODIGO_SITUACAO = C1.CODIGO_SITUACAO
    AND RHPONT_RES_SIT_DIA.TIPO_APURACAO = C1.TIPO_APURACAO;
END LOOP;
COMMIT;
dbms_output.put_line('UPDATE ENFERMIDADES ANEXO 2 CONCLUÍDO COM SUCESSO');

END;