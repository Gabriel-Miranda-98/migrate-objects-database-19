
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_PROFISSIONAL_CONTRATO_DBV" ("CODIGO_EMPRESA", "EMPRESA", "MATRICULA", "BM_MATRIC", "CPF", "NOME", "COD_CARGO", "CBO_CARGO", "CARGO", "COD_SECRETARIA", "SECRETARIA", "COD_UNIDADE", "UNIDADE", "DATA_ADMISSAO", "DATA_RESCISAO", "SITUACAO_FUNCIONAL", "DESCR_SIT_FUNCIONAL", "DATA_SIT_FUNCIONAL", "TELEFONE", "EMAIL", "FUNCAO_COMISSIONADA", "COD_LOTACAO_ADM", "COD_LOTACAO_PONTO", "TITULAR_UNIDADE", "LOGIN_GERENTE", "NOME_SOCIAL") AS 
  SELECT CNT.CODIGO_EMPRESA,AD.EMPRESA,AD.MATRICULA,AD.BM_MATRIC,PES.CPF,CNT.NOME,CG.CODIGO AS COD_CARGO, CG.CBO2002 AS CBO_CARGO,
       CG.DESCRICAO AS CARGO, SUBSTR(CNT.COD_UNIDADE1,5,2) || '-00-00-00-00-000'AS COD_SECRETARIA,AD.SECRETARIA,
       SUBSTR(CNT.COD_UNIDADE1,5,2) || '-' || SUBSTR(CNT.COD_UNIDADE2,5,2) || '-' || SUBSTR(CNT.COD_UNIDADE3,5,2) || '-' ||
       SUBSTR(CNT.COD_UNIDADE4,5,2) || '-' || SUBSTR(CNT.COD_UNIDADE5,5,2) || '-' || SUBSTR(CNT.COD_UNIDADE6,4,3) AS COD_UNIDADE, AD.UNIDADE,
       CNT.DATA_ADMISSAO,CNT.DATA_RESCISAO,CNT.SITUACAO_FUNCIONAL,AD.DESCR_SIT_FUNCIONAL,AD.DATA_SIT_FUNCIONAL,AD.TELEFONE, AD.EMAIL,
       AD.FUNCAO_COMISSIONADA, AD.COD_LOTACAO_ADM, AD.COD_LOTACAO_PONTO, AD.TITULAR_UNIDADE, AD.LOGIN_GERENTE, PES.NOME_SOCIAL
FROM ARTERH.RHPESS_CONTRATO CNT
     INNER JOIN ARTERH.RHPESS_PESSOA PES ON PES.CODIGO = CNT.CODIGO_PESSOA
                                        AND PES.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA
     INNER JOIN ARTERH.RHPBH_REGISTRO_AD AD ON LPAD(REPLACE(AD.MATRICULA,'-',''),15,0) = CNT.CODIGO
                                           AND AD.CPF = PES.CPF
                                           AND AD.EMPRESA = (CASE WHEN CNT.CODIGO_EMPRESA = '0001' AND CNT.TIPO_CONTRATO = '0001' THEN 'PBH'
                                                                  WHEN CNT.CODIGO_EMPRESA = '0001' AND CNT.TIPO_CONTRATO = '0098' THEN 'CONTRATOS PBH'
                                                                  WHEN CNT.CODIGO_EMPRESA = '0001' AND NVL(CNT.C_LIVRE_SELEC02,0) IN (21,0) AND CNT.TIPO_CONTRATO <> '0015' THEN 'CONTRATOS SA'
                                                                  WHEN CNT.CODIGO_EMPRESA = '0001' AND NVL(CNT.C_LIVRE_SELEC02,0) =  32     AND CNT.TIPO_CONTRATO <> '0015' THEN 'ZOONOZES'
                                                                  WHEN CNT.CODIGO_EMPRESA = '0001' AND NVL(CNT.C_LIVRE_SELEC02,0) =  0      AND CNT.TIPO_CONTRATO  = '0015' THEN 'SAUDE'
                                                                  WHEN CNT.CODIGO_EMPRESA = '0002'                                                                          THEN 'PRODABEL'
                                                                  WHEN CNT.CODIGO_EMPRESA = '0003'                                                                          THEN 'SUDECAP'
                                                                  WHEN CNT.CODIGO_EMPRESA = '0005'                                                                          THEN 'SUMOB'
                                                                  WHEN CNT.CODIGO_EMPRESA = '0007'                                                                          THEN 'SLU'
                                                                  WHEN CNT.CODIGO_EMPRESA = '0009'                                                                          THEN 'BELOTUR'
                                                                  WHEN CNT.CODIGO_EMPRESA = '0010'                                                                          THEN 'URBEL'
                                                                  WHEN CNT.CODIGO_EMPRESA = '0013'                                                                          THEN 'FMC'
                                                                  WHEN CNT.CODIGO_EMPRESA = '0014'                                                                          THEN 'FPM' END)
                                           AND AD.ID_RHPBH_REGISTRO_AD = (SELECT MAX(A.ID_RHPBH_REGISTRO_AD)
                                                                          FROM   ARTERH.RHPBH_REGISTRO_AD A
                                                                          WHERE  A.BM_MATRIC = AD.BM_MATRIC
                                                                          AND    A.EMPRESA   = AD.EMPRESA
                                                                          AND    A.CPF       = AD.CPF)
                                          AND AD.DATA_RESCISAO IS NULL
     INNER JOIN ARTERH.RHPLCS_CARGO CG ON CG.CODIGO  = CNT.COD_CARGO_PAGTO AND CG.CODIGO_EMPRESA  = CNT.CODIGO_EMPRESA										  
WHERE CNT.CODIGO_EMPRESA IN ('0001','0002','0003','0005','0007','0009','0010','0013','0014')
AND   CNT.ANO_MES_REFERENCIA  = ( SELECT MAX (CNT2.ANO_MES_REFERENCIA)
								  FROM ARTERH.RHPESS_CONTRATO CNT2
								  WHERE CNT2.CODIGO              = CNT.CODIGO											  
								  AND   TRUNC(CNT2.ANO_MES_REFERENCIA) <= (SELECT DT_MAX_DATAS FROM ARTERH.RHPARM_P_SIST)
								  AND   CNT2.TIPO_CONTRATO       = CNT.TIPO_CONTRATO
								  AND   CNT2.CODIGO_EMPRESA      = CNT.CODIGO_EMPRESA)
AND CNT.DATA_RESCISAO IS NULL