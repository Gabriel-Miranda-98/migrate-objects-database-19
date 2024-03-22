
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."V_RH_BANCO_HORA" ("MATRICULA", "NOME", "CONTRATO", "GERENCIA", "SUPERINDENTENCIA", "DIRETORIA", "DATA_OCORRENCIA", "CODIGO_OCORRENCIA", "DESCRICAO_OCORRENCIA", "QTD_HORAS", "TIPO", "MES_OCORRENCIA", "ANO_OCORRENCIA", "CARGO", "NIVEL_CARGO") AS 
  SELECT  SUBSTR(CNT.CODIGO,7,8) || '-' ||SUBSTR(CNT.CODIGO,15,1) AS MATRICULA,
        CNT.NOME,
        CASE WHEN CNT.VINCULO = '0002' THEN 'RECRUTAMENTO' ELSE 'EFETIVO' END CONTRATO,
        GER.ABREVIACAO AS GERENCIA,
        SUP.ABREVIACAO AS SUPERINDENTENCIA,
        DIR.ABREVIACAO AS DIRETORIA,
		PSD.DATA AS DATA_OCORRENCIA,
		PSD.CODIGO_SITUACAO AS CODIGO_OCORRENCIA,
		PS.DESCRICAO AS DESCRICAO_OCORRENCIA,
        PSD.REF_HORAS AS QTD_HORAS,		
		DECODE(PSD.CODIGO_SITUACAO,'P112','A','A') TIPO,
        TO_CHAR(TO_DATE('01/'||TO_CHAR(ADD_MONTHS(SYSDATE,-1),'MM')||'/'||TO_CHAR(SYSDATE,'YYYY')),'MM') AS MES_OCORRENCIA,
        TO_CHAR(TO_DATE('01/'||TO_CHAR(ADD_MONTHS(SYSDATE,-1),'MM')||'/'||TO_CHAR(SYSDATE,'YYYY')),'YYYY') AS ANO_OCORRENCIA,
		CNT.COD_CARGO_PAGTO || ' - ' || CG.DESCRICAO AS CARGO,
		CNT.NIVEL_CARGO_PAGTO AS NIVEL_CARGO
FROM 	ARTERH.RHPESS_CONTRATO CNT 
        INNER JOIN ARTERH.RHORGA_UNIDADE GER  ON GER.COD_UNIDADE1 = CNT.COD_UNIDADE1
                                             AND GER.COD_UNIDADE2 = CNT.COD_UNIDADE2
                                             AND GER.COD_UNIDADE3 = CNT.COD_UNIDADE3
                                             AND GER.COD_UNIDADE4 = CNT.COD_UNIDADE4
                                             AND GER.COD_UNIDADE5 = CNT.COD_UNIDADE5
                                             AND GER.COD_UNIDADE6 = CNT.COD_UNIDADE6
                                             AND GER.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA
        INNER JOIN ARTERH.RHORGA_UNIDADE SUP  ON SUP.COD_UNIDADE1 = CNT.COD_UNIDADE1
                                             AND SUP.COD_UNIDADE2 = CNT.COD_UNIDADE2
                                             AND SUP.COD_UNIDADE3 = CNT.COD_UNIDADE3
                                             AND SUP.COD_UNIDADE4 = '000000'
                                             AND SUP.COD_UNIDADE5 = '000000'
                                             AND SUP.COD_UNIDADE6 = '000000'
                                             AND SUP.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA
        INNER JOIN ARTERH.RHORGA_UNIDADE DIR  ON DIR.COD_UNIDADE1 = CNT.COD_UNIDADE1
                                             AND DIR.COD_UNIDADE2 = CNT.COD_UNIDADE2
                                             AND DIR.COD_UNIDADE3 = '000000'
                                             AND DIR.COD_UNIDADE4 = '000000'
                                             AND DIR.COD_UNIDADE5 = '000000'
                                             AND DIR.COD_UNIDADE6 = '000000'
                                             AND DIR.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA
		INNER JOIN ARTERH.RHPONT_RES_SIT_DIA PSD ON PSD.CODIGO_CONTRATO = CNT.CODIGO
										        AND PSD.DATA = TO_DATE('01/'||TO_CHAR(ADD_MONTHS(SYSDATE,-1),'MM')||'/'||TO_CHAR(SYSDATE,'YYYY'))
							                    AND PSD.CODIGO_SITUACAO IN ('P098','P112')
							                    AND PSD.TIPO_APURACAO = 'F'
							                    AND PSD.TIPO_CONTRATO = CNT.TIPO_CONTRATO
							                    AND PSD.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA	  
	    INNER JOIN ARTERH.RHPONT_SITUACAO PS     ON PS.CODIGO = PSD.CODIGO_SITUACAO
        INNER JOIN ARTERH.RHPLCS_CARGO CG        ON CG.CODIGO = CNT.COD_CARGO_PAGTO
                                                AND CG.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA
WHERE CNT.ANO_MES_REFERENCIA = (SELECT MAX(AUX.ANO_MES_REFERENCIA)
                                FROM ARTERH.RHPESS_CONTRATO AUX
                                WHERE AUX.CODIGO              = CNT.CODIGO
                                AND   AUX.ANO_MES_REFERENCIA <= SYSDATE
                                AND   AUX.TIPO_CONTRATO       = CNT.TIPO_CONTRATO
                                AND   AUX.CODIGO_EMPRESA      = CNT.CODIGO_EMPRESA)
AND   CNT.TIPO_CONTRATO      = '0001'
AND   CNT.CODIGO_EMPRESA     = '0002'
AND   (   (CNT.SITUACAO_CONTRATO = 'N')
       OR (CNT.SITUACAO_CONTRATO = 'F')
	   OR (CNT.SITUACAO_CONTRATO = 'A')
	   OR (CNT.SITUACAO_CONTRATO = 'M')
	   OR (CNT.SITUACAO_CONTRATO = 'L')
	   OR (CNT.SITUACAO_CONTRATO = 'S')
	   OR (CNT.SITUACAO_CONTRATO = 'O')) 
AND   CNT.SITUACAO_FUNCIONAL <> '5000'
AND	  CNT.SITUACAO_FUNCIONAL <> '5002'
AND   CNT.SITUACAO_FUNCIONAL <> '1042'
AND   CNT.SITUACAO_FUNCIONAL <> '5005'
AND   CNT.SITUACAO_FUNCIONAL <> '5001'
AND   CNT.SITUACAO_FUNCIONAL <> '5003'
AND   CNT.SITUACAO_FUNCIONAL <> '5004'
AND   CNT.SITUACAO_FUNCIONAL <> '5005'
AND   CNT.SITUACAO_FUNCIONAL <> '5019'
AND   CNT.SITUACAO_FUNCIONAL <> '6116'
AND   CNT.SITUACAO_FUNCIONAL <> '6401'
AND   CNT.SITUACAO_FUNCIONAL <> '6704'
AND   CNT.SITUACAO_FUNCIONAL <> '5030'

UNION ALL
-- OCORRENCIA DIARIA
SELECT  SUBSTR(CNT.CODIGO,7,8) || '-' ||SUBSTR(CNT.CODIGO,15,1) AS MATRICULA,
        CNT.NOME,
        CASE WHEN CNT.VINCULO = '0002' THEN 'RECRUTAMENTO' ELSE 'EFETIVO' END CONTRATO,
        GER.ABREVIACAO AS GERENCIA,
        SUP.ABREVIACAO AS SUPERINDENTENCIA,
        DIR.ABREVIACAO AS DIRETORIA,
		PSD.DATA AS DATA_OCORRENCIA,
		PSD.CODIGO_SITUACAO AS CODIGO_OCORRENCIA,
		PS.DESCRICAO AS DESCRICAO_OCORRENCIA,
        PSD.REF_HORAS AS QTD_HORAS,				
		DECODE(PSD.CODIGO_SITUACAO,'P091','D','P092','D','P093','D','P094','D','P095','D','P096','D','P097','D','P031','B-','20 72','B-','C+') TIPO, 
        TO_CHAR(TO_DATE('01/'||TO_CHAR(ADD_MONTHS(SYSDATE,-1),'MM')||'/'||TO_CHAR(SYSDATE,'YYYY')),'MM') AS MES_OCORRENCIA,
        TO_CHAR(TO_DATE('01/'||TO_CHAR(ADD_MONTHS(SYSDATE,-1),'MM')||'/'||TO_CHAR(SYSDATE,'YYYY')),'YYYY') AS ANO_OCORRENCIA,
		CNT.COD_CARGO_PAGTO || ' - ' || CG.DESCRICAO AS CARGO,
		CNT.NIVEL_CARGO_PAGTO AS NIVEL_CARGO        
FROM 	ARTERH.RHPESS_CONTRATO CNT 
        INNER JOIN ARTERH.RHORGA_UNIDADE GER  ON GER.COD_UNIDADE1 = CNT.COD_UNIDADE1
                                             AND GER.COD_UNIDADE2 = CNT.COD_UNIDADE2
                                             AND GER.COD_UNIDADE3 = CNT.COD_UNIDADE3
                                             AND GER.COD_UNIDADE4 = CNT.COD_UNIDADE4
                                             AND GER.COD_UNIDADE5 = CNT.COD_UNIDADE5
                                             AND GER.COD_UNIDADE6 = CNT.COD_UNIDADE6
                                             AND GER.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA
        INNER JOIN ARTERH.RHORGA_UNIDADE SUP  ON SUP.COD_UNIDADE1 = CNT.COD_UNIDADE1
                                             AND SUP.COD_UNIDADE2 = CNT.COD_UNIDADE2
                                             AND SUP.COD_UNIDADE3 = CNT.COD_UNIDADE3
                                             AND SUP.COD_UNIDADE4 = '000000'
                                             AND SUP.COD_UNIDADE5 = '000000'
                                             AND SUP.COD_UNIDADE6 = '000000'
                                             AND SUP.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA
        INNER JOIN ARTERH.RHORGA_UNIDADE DIR  ON DIR.COD_UNIDADE1 = CNT.COD_UNIDADE1
                                             AND DIR.COD_UNIDADE2 = CNT.COD_UNIDADE2
                                             AND DIR.COD_UNIDADE3 = '000000'
                                             AND DIR.COD_UNIDADE4 = '000000'
                                             AND DIR.COD_UNIDADE5 = '000000'
                                             AND DIR.COD_UNIDADE6 = '000000'
                                             AND DIR.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA
		INNER JOIN ARTERH.RHPONT_RES_SIT_DIA PSD ON PSD.CODIGO_CONTRATO = CNT.CODIGO							             
						          			    AND PSD.DATA BETWEEN TO_DATE('01/'||TO_CHAR(ADD_MONTHS(SYSDATE,-1),'MM')||'/'||TO_CHAR(SYSDATE,'YYYY'))
										                         AND LAST_DAY(TO_DATE(ADD_MONTHS(SYSDATE,-1),'DD/MM/YYYY')) 
							                   AND PSD.CODIGO_SITUACAO IN ('P030','P031','P091','P092','P093','P094','P095','P096','P097')
							                   AND PSD.TIPO_APURACAO = 'F'
							                   AND PSD.TIPO_CONTRATO = CNT.TIPO_CONTRATO
							                   AND PSD.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA	  
	    INNER JOIN ARTERH.RHPONT_SITUACAO PS    ON PS.CODIGO = PSD.CODIGO_SITUACAO
        INNER JOIN ARTERH.RHPLCS_CARGO CG        ON CG.CODIGO = CNT.COD_CARGO_PAGTO
                                                AND CG.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA
WHERE CNT.ANO_MES_REFERENCIA = (SELECT MAX(AUX.ANO_MES_REFERENCIA)
                                FROM ARTERH.RHPESS_CONTRATO AUX
                                WHERE AUX.CODIGO              = CNT.CODIGO
                                AND   AUX.ANO_MES_REFERENCIA <= SYSDATE
                                AND   AUX.TIPO_CONTRATO       = CNT.TIPO_CONTRATO
                                AND   AUX.CODIGO_EMPRESA      = CNT.CODIGO_EMPRESA)
AND   CNT.TIPO_CONTRATO      = '0001'
AND   CNT.CODIGO_EMPRESA     = '0002'
AND   (   (CNT.SITUACAO_CONTRATO = 'N')
       OR (CNT.SITUACAO_CONTRATO = 'F')
	   OR (CNT.SITUACAO_CONTRATO = 'A')
	   OR (CNT.SITUACAO_CONTRATO = 'M')
	   OR (CNT.SITUACAO_CONTRATO = 'L')
	   OR (CNT.SITUACAO_CONTRATO = 'S')
	   OR (CNT.SITUACAO_CONTRATO = 'O')) 
AND   CNT.SITUACAO_FUNCIONAL <> '5000'
AND	  CNT.SITUACAO_FUNCIONAL <> '5002'
AND   CNT.SITUACAO_FUNCIONAL <> '1042'
AND   CNT.SITUACAO_FUNCIONAL <> '5005'
AND   CNT.SITUACAO_FUNCIONAL <> '5001'
AND   CNT.SITUACAO_FUNCIONAL <> '5003'
AND   CNT.SITUACAO_FUNCIONAL <> '5004'
AND   CNT.SITUACAO_FUNCIONAL <> '5005'
AND   CNT.SITUACAO_FUNCIONAL <> '5019'
AND   CNT.SITUACAO_FUNCIONAL <> '6116'
AND   CNT.SITUACAO_FUNCIONAL <> '6401'
AND   CNT.SITUACAO_FUNCIONAL <> '6704'
AND   CNT.SITUACAO_FUNCIONAL <> '5030'

UNION ALL
-- OCORRENCIA FINAL

SELECT  SUBSTR(CNT.CODIGO,7,8) || '-' ||SUBSTR(CNT.CODIGO,15,1) AS MATRICULA,
        CNT.NOME,
        CASE WHEN CNT.VINCULO = '0002' THEN 'RECRUTAMENTO' ELSE 'EFETIVO' END CONTRATO,
        GER.ABREVIACAO AS GERENCIA,
        SUP.ABREVIACAO AS SUPERINDENTENCIA,
        DIR.ABREVIACAO AS DIRETORIA,
		PSD.DATA AS DATA_OCORRENCIA,
		PSD.CODIGO_SITUACAO AS CODIGO_OCORRENCIA,
		PS.DESCRICAO AS DESCRICAO_OCORRENCIA,
        PSD.REF_HORAS AS QTD_HORAS,		
		DECODE(PSD.CODIGO_SITUACAO,'P112','E','E') TIPO,
        TO_CHAR(TO_DATE('01/'||TO_CHAR(ADD_MONTHS(SYSDATE,-1),'MM')||'/'||TO_CHAR(SYSDATE,'YYYY')),'MM') AS MES_OCORRENCIA,
        TO_CHAR(TO_DATE('01/'||TO_CHAR(ADD_MONTHS(SYSDATE,-1),'MM')||'/'||TO_CHAR(SYSDATE,'YYYY')),'YYYY') AS ANO_OCORRENCIA,
		CNT.COD_CARGO_PAGTO || ' - ' || CG.DESCRICAO AS CARGO,
		CNT.NIVEL_CARGO_PAGTO AS NIVEL_CARGO
FROM 	ARTERH.RHPESS_CONTRATO CNT 
        INNER JOIN ARTERH.RHORGA_UNIDADE GER  ON GER.COD_UNIDADE1 = CNT.COD_UNIDADE1
                                             AND GER.COD_UNIDADE2 = CNT.COD_UNIDADE2
                                             AND GER.COD_UNIDADE3 = CNT.COD_UNIDADE3
                                             AND GER.COD_UNIDADE4 = CNT.COD_UNIDADE4
                                             AND GER.COD_UNIDADE5 = CNT.COD_UNIDADE5
                                             AND GER.COD_UNIDADE6 = CNT.COD_UNIDADE6
                                             AND GER.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA
        INNER JOIN ARTERH.RHORGA_UNIDADE SUP  ON SUP.COD_UNIDADE1 = CNT.COD_UNIDADE1
                                             AND SUP.COD_UNIDADE2 = CNT.COD_UNIDADE2
                                             AND SUP.COD_UNIDADE3 = CNT.COD_UNIDADE3
                                             AND SUP.COD_UNIDADE4 = '000000'
                                             AND SUP.COD_UNIDADE5 = '000000'
                                             AND SUP.COD_UNIDADE6 = '000000'
                                             AND SUP.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA
        INNER JOIN ARTERH.RHORGA_UNIDADE DIR  ON DIR.COD_UNIDADE1 = CNT.COD_UNIDADE1
                                             AND DIR.COD_UNIDADE2 = CNT.COD_UNIDADE2
                                             AND DIR.COD_UNIDADE3 = '000000'
                                             AND DIR.COD_UNIDADE4 = '000000'
                                             AND DIR.COD_UNIDADE5 = '000000'
                                             AND DIR.COD_UNIDADE6 = '000000'
                                             AND DIR.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA
		INNER JOIN ARTERH.RHPONT_RES_SIT_DIA PSD ON PSD.CODIGO_CONTRATO = CNT.CODIGO
						     	                AND PSD.DATA = LAST_DAY(TO_DATE(ADD_MONTHS(SYSDATE,-1),'DD/MM/YYYY')) 										 
							                    AND PSD.CODIGO_SITUACAO IN ('P098','P112')
							                    AND PSD.TIPO_APURACAO = 'F'
							                    AND PSD.TIPO_CONTRATO = CNT.TIPO_CONTRATO
							                    AND PSD.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA	  
	    INNER JOIN ARTERH.RHPONT_SITUACAO PS     ON PS.CODIGO = PSD.CODIGO_SITUACAO
        INNER JOIN ARTERH.RHPLCS_CARGO CG        ON CG.CODIGO = CNT.COD_CARGO_PAGTO
                                                AND CG.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA
WHERE CNT.ANO_MES_REFERENCIA = (SELECT MAX(AUX.ANO_MES_REFERENCIA)
                                FROM ARTERH.RHPESS_CONTRATO AUX
                                WHERE AUX.CODIGO              = CNT.CODIGO
                                AND   AUX.ANO_MES_REFERENCIA <= SYSDATE
                                AND   AUX.TIPO_CONTRATO       = CNT.TIPO_CONTRATO
                                AND   AUX.CODIGO_EMPRESA      = CNT.CODIGO_EMPRESA)
AND   CNT.TIPO_CONTRATO      = '0001'
AND   CNT.CODIGO_EMPRESA     = '0002'
AND   (   (CNT.SITUACAO_CONTRATO = 'N')
       OR (CNT.SITUACAO_CONTRATO = 'F')
	   OR (CNT.SITUACAO_CONTRATO = 'A')
	   OR (CNT.SITUACAO_CONTRATO = 'M')
	   OR (CNT.SITUACAO_CONTRATO = 'L')
	   OR (CNT.SITUACAO_CONTRATO = 'S')
	   OR (CNT.SITUACAO_CONTRATO = 'O')) 
AND   CNT.SITUACAO_FUNCIONAL <> '5000'
AND	  CNT.SITUACAO_FUNCIONAL <> '5002'
AND   CNT.SITUACAO_FUNCIONAL <> '1042'
AND   CNT.SITUACAO_FUNCIONAL <> '5005'
AND   CNT.SITUACAO_FUNCIONAL <> '5001'
AND   CNT.SITUACAO_FUNCIONAL <> '5003'
AND   CNT.SITUACAO_FUNCIONAL <> '5004'
AND   CNT.SITUACAO_FUNCIONAL <> '5005'
AND   CNT.SITUACAO_FUNCIONAL <> '5019'
AND   CNT.SITUACAO_FUNCIONAL <> '6116'
AND   CNT.SITUACAO_FUNCIONAL <> '6401'
AND   CNT.SITUACAO_FUNCIONAL <> '6704'
AND   CNT.SITUACAO_FUNCIONAL <> '5030'
ORDER BY 1,7,11,8