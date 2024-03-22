
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."TEMP_SERV_ANTERIOR_ATIVOS" ("COD_ORG", "MATRICULA", "CPF", "SEQUENCIAL_TEMPO_SERVICO", "DATA_ADMISSAO", "VINCULO", "REGIME_PREVIDENCIA", "DESCRICAO_CARGO", "DATA_DEMISSAO_EXONERACAO", "MAGISTERIO", "PROFISSIONAL_SAUDE", "MEDICO", "ATIVIDADE_INSALUBRE", "PROFISSAO_REGULAMENTADA", "RESP_CONTAGEM_TEMPO", "TEMPO_COMPROVADO", "NATUREZA_JURIDICA", "NUMERO_CTC", "COD_ORG_ANTERIOR", "MATRICULA_ANTERIOR", "EMPRESA") AS 
  SELECT
  '0001' AS COD_ORG,
	TO_NUMBER(SUBSTR(EMP_ANT.CODIGO_CONTRATO, 5,10)) ||	CASE WHEN SUBSTR(EMP_ANT.CODIGO_CONTRATO, 15,1) = 'X' THEN 7 ELSE TO_NUMBER(SUBSTR(EMP_ANT.CODIGO_CONTRATO, 15,1)) END AS MATRICULA, 
	'00000000000' AS CPF,
	CASE SUBSTR(EMP_ANT.OCORRENCIA, 4,1) WHEN ',' THEN 1 ELSE TO_NUMBER(TRIM(EMP_ANT.OCORRENCIA)) + 1 END AS SEQUENCIAL_TEMPO_SERVICO,  /* VERIFICAR */
	TO_CHAR(EMP_ANT.data_admissao,'YYYYMMDD') AS DATA_ADMISSAO,

	CASE 
		WHEN EMP_ANT.natureza_empresa  =  '1002' AND EMP_ANT.codigo_previdencia = '0001' THEN '6'
		WHEN EMP_ANT.natureza_empresa ='1002' AND EMP_ANT.codigo_previdencia = '0002' THEN '2'
		WHEN EMP_ANT.natureza_empresa ='1002' AND EMP_ANT.codigo_previdencia = '0003' THEN '2'
		WHEN EMP_ANT.natureza_empresa ='1002' AND EMP_ANT.codigo_previdencia = '0004' THEN '2'
		WHEN EMP_ANT.natureza_empresa ='1002' AND EMP_ANT.codigo_previdencia = '0005' THEN '6'

		WHEN EMP_ANT.natureza_empresa ='1003' AND EMP_ANT.codigo_previdencia = '0001' THEN '1' 
		WHEN EMP_ANT.natureza_empresa ='1003' AND EMP_ANT.codigo_previdencia = '0002' THEN '10'
		WHEN EMP_ANT.natureza_empresa ='1003' AND EMP_ANT.codigo_previdencia = '0003' THEN '10'
		WHEN EMP_ANT.natureza_empresa ='1003' AND EMP_ANT.codigo_previdencia = '0004' THEN '10'
		WHEN EMP_ANT.natureza_empresa ='1003' AND EMP_ANT.codigo_previdencia = '0005' THEN '1' 

		WHEN EMP_ANT.natureza_empresa ='1004' AND EMP_ANT.codigo_previdencia = '0001' THEN '6'
		WHEN EMP_ANT.natureza_empresa ='1004' AND EMP_ANT.codigo_previdencia = '0002' THEN '2'
		WHEN EMP_ANT.natureza_empresa ='1004' AND EMP_ANT.codigo_previdencia = '0003' THEN '2'
		WHEN EMP_ANT.natureza_empresa ='1004' AND EMP_ANT.codigo_previdencia = '0004' THEN '2'
		WHEN EMP_ANT.natureza_empresa ='1004' AND EMP_ANT.codigo_previdencia = '0005' THEN '6'

		WHEN EMP_ANT.natureza_empresa ='0005' AND EMP_ANT.codigo_previdencia = '0001' THEN '6' 
		WHEN EMP_ANT.natureza_empresa ='0005' AND EMP_ANT.codigo_previdencia = '0002' THEN '10'
		WHEN EMP_ANT.natureza_empresa ='0005' AND EMP_ANT.codigo_previdencia = '0003' THEN '10'
		WHEN EMP_ANT.natureza_empresa ='0005' AND EMP_ANT.codigo_previdencia = '0004' THEN '10'
		WHEN EMP_ANT.natureza_empresa ='0005' AND EMP_ANT.codigo_previdencia = '0005' THEN '6' 

		WHEN EMP_ANT.natureza_empresa ='0001' AND EMP_ANT.codigo_previdencia = '0001' THEN '1' 
		WHEN EMP_ANT.natureza_empresa ='0001' AND EMP_ANT.codigo_previdencia = '0002' THEN '10'
		WHEN EMP_ANT.natureza_empresa ='0001' AND EMP_ANT.codigo_previdencia = '0003' THEN '10'
		WHEN EMP_ANT.natureza_empresa ='0001' AND EMP_ANT.codigo_previdencia = '0004' THEN '10'
		WHEN EMP_ANT.natureza_empresa ='0001' AND EMP_ANT.codigo_previdencia = '0005' THEN '10'

		WHEN EMP_ANT.natureza_empresa ='0003' AND EMP_ANT.codigo_previdencia = '0001' THEN '1' 
		WHEN EMP_ANT.natureza_empresa ='0003' AND EMP_ANT.codigo_previdencia = '0002' THEN '10'
		WHEN EMP_ANT.natureza_empresa ='0003' AND EMP_ANT.codigo_previdencia = '0003' THEN '10'
		WHEN EMP_ANT.natureza_empresa ='0003' AND EMP_ANT.codigo_previdencia = '0004' THEN '10'
		WHEN EMP_ANT.natureza_empresa ='0003' AND EMP_ANT.codigo_previdencia = '0005' THEN '10'

		WHEN EMP_ANT.natureza_empresa ='0004' AND EMP_ANT.codigo_previdencia = '0001' THEN '1' 
		WHEN EMP_ANT.natureza_empresa ='0004' AND EMP_ANT.codigo_previdencia = '0002' THEN '10'
		WHEN EMP_ANT.natureza_empresa ='0004' AND EMP_ANT.codigo_previdencia = '0003' THEN '10'
		WHEN EMP_ANT.natureza_empresa ='0004' AND EMP_ANT.codigo_previdencia = '0004' THEN '10'
		WHEN EMP_ANT.natureza_empresa ='0004' AND EMP_ANT.codigo_previdencia = '0005' THEN '10'

		WHEN EMP_ANT.natureza_empresa ='0006' AND EMP_ANT.codigo_previdencia = '0001' THEN '6'
		WHEN EMP_ANT.natureza_empresa ='0006' AND EMP_ANT.codigo_previdencia = '0002' THEN '2'
		WHEN EMP_ANT.natureza_empresa ='0006' AND EMP_ANT.codigo_previdencia = '0003' THEN '2'
		WHEN EMP_ANT.natureza_empresa ='0006' AND EMP_ANT.codigo_previdencia = '0004' THEN '2'
		WHEN EMP_ANT.natureza_empresa ='0006' AND EMP_ANT.codigo_previdencia = '0005' THEN '6'

		WHEN EMP_ANT.natureza_empresa ='0008' AND EMP_ANT.codigo_previdencia = '0001' THEN '6'
		WHEN EMP_ANT.natureza_empresa ='0008' AND EMP_ANT.codigo_previdencia = '0002' THEN '2'
		WHEN EMP_ANT.natureza_empresa ='0008' AND EMP_ANT.codigo_previdencia = '0003' THEN '2'
		WHEN EMP_ANT.natureza_empresa ='0008' AND EMP_ANT.codigo_previdencia = '0004' THEN '2'
		WHEN EMP_ANT.natureza_empresa ='0008' AND EMP_ANT.codigo_previdencia = '0005' THEN '6'

		WHEN EMP_ANT.natureza_empresa ='0009' AND EMP_ANT.codigo_previdencia = '0001' THEN '6'
		WHEN EMP_ANT.natureza_empresa ='0009' AND EMP_ANT.codigo_previdencia = '0002' THEN '2'
		WHEN EMP_ANT.natureza_empresa ='0009' AND EMP_ANT.codigo_previdencia = '0003' THEN '2'
		WHEN EMP_ANT.natureza_empresa ='0009' AND EMP_ANT.codigo_previdencia = '0004' THEN '2'
		WHEN EMP_ANT.natureza_empresa ='0009' AND EMP_ANT.codigo_previdencia = '0005' THEN '6'

		WHEN EMP_ANT.natureza_empresa ='0002' AND EMP_ANT.codigo_previdencia = '0001' THEN '1' 
		WHEN EMP_ANT.natureza_empresa ='0002' AND EMP_ANT.codigo_previdencia = '0002' THEN '10'
		WHEN EMP_ANT.natureza_empresa ='0002' AND EMP_ANT.codigo_previdencia = '0003' THEN '10'
		WHEN EMP_ANT.natureza_empresa ='0002' AND EMP_ANT.codigo_previdencia = '0004' THEN '10'
		WHEN EMP_ANT.natureza_empresa ='0002' AND EMP_ANT.codigo_previdencia = '0005' THEN '10'

		WHEN EMP_ANT.natureza_empresa ='0007' AND EMP_ANT.codigo_previdencia = '0001'  THEN '6'
		WHEN EMP_ANT.natureza_empresa ='0007' AND EMP_ANT.codigo_previdencia = '0002'  THEN '2'
		WHEN EMP_ANT.natureza_empresa ='0007' AND EMP_ANT.codigo_previdencia = '0003'  THEN '2'
		WHEN EMP_ANT.natureza_empresa ='0007' AND EMP_ANT.codigo_previdencia = '0004'  THEN '2'
		WHEN EMP_ANT.natureza_empresa ='0007' AND EMP_ANT.codigo_previdencia = '0005'  THEN '6'
		ELSE '1' 
	END VINCULO,

	CASE EMP_ANT.codigo_previdencia 
		WHEN '0001' THEN 'G'
		WHEN '0002' THEN 'P'
		WHEN '0003' THEN 'P'
		WHEN '0004' THEN 'P'
		ELSE 'G' 
	END AS REGIME_PREVIDENCIA,

	SUBSTR(trim(EMP_ANT.ultimo_cargo),1,80) AS DESCRICAO_CARGO,
	TO_CHAR(EMP_ANT.data_demissao,'YYYYMMDD') AS DATA_DEMISSAO_EXONERACAO,
	TRIM(EMP_ANT.c_livre_opcao12) AS MAGISTERIO,
	'N' AS PROFISSIONAL_SAUDE, 

	CASE WHEN EMP_ANT.ultimo_cargo LIKE '%MÉDICO%' THEN 'S' ELSE 'N' END AS MEDICO, 
	'N' AS ATIVIDADE_INSALUBRE,
  'N' AS PROFISSAO_REGULAMENTADA,

	CASE 
		WHEN EMP_ANT.codigo_previdencia = '0001' THEN 'N'
		WHEN EMP_ANT.codigo_previdencia = '0002' THEN 'E'
		WHEN EMP_ANT.codigo_previdencia = '0003' THEN 'T'
		WHEN EMP_ANT.codigo_previdencia = '0004' THEN 'I'
		WHEN EMP_ANT.codigo_previdencia = '0005' THEN 'N'
		ELSE 'Z'
	END  AS RESP_CONTAGEM_TEMPO,

	'S' AS TEMPO_COMPROVADO, /* verificar */

	CASE
		WHEN EMP_ANT.natureza_empresa in ('0001','0002','0003','1003') THEN 'P'
		WHEN EMP_ANT.natureza_empresa in ('0005','0006','0008','0009','1002','1004','1005') THEN 'G'
		WHEN EMP_ANT.natureza_empresa = '0007' THEN 'A'
		WHEN EMP_ANT.natureza_empresa = '0004' THEN 'M'
		ELSE 'Z'
	END AS NATUREZA_JURIDICA,

	'0' AS NUMERO_CTC,

	CASE EMP_ANT.codigo_empresa_ant
		WHEN '0001' THEN 1
		WHEN '000X' THEN 3
		WHEN '00XX' THEN 4
		ELSE NULL
	END AS COD_ORG_ANTERIOR, 

	NULL AS  MATRICULA_ANTERIOR,
	TRIM(EMP_ANT.empresa_anterior) AS EMPRESA   
FROM  rhtemp_empreg_ant EMP_ANT
WHERE SUBSTR(EMP_ANT.codigo_contrato,5,10) <> '5110000626'
  AND EMP_ANT.CODIGO_PESSOA = EMP_ANT.CODIGO_CONTRATO

UNION (
SELECT 
	'0001' AS COD_ORG, 
	TO_NUMBER(SUBSTR(A.CODIGO_PESSOA, 5,10)) ||
	CASE WHEN SUBSTR(A.CODIGO_PESSOA, 15,1) = 'X' THEN 7 ELSE TO_NUMBER(SUBSTR(A.CODIGO_PESSOA, 15,1)) END AS MATRICULA,
	'00000000000' AS CPF,
	CASE SUBSTR(A.OCORRENCIA, 4,1) WHEN ',' THEN 1 ELSE TO_NUMBER(TRIM(A.OCORRENCIA)) + 1 END AS SEQUENCIAL_TEMPO_SERVICO,  /* VERIFICAR */
	TO_CHAR(a.data_inicio,'YYYYMMDD') AS DATA_ADMISSAO,

	CASE 
		WHEN A.codigo_previdencia = '0001' THEN '6'
		WHEN A.codigo_previdencia = '0002' THEN '2'
		WHEN A.codigo_previdencia = '0003' THEN '2'
		WHEN A.codigo_previdencia = '0004' THEN '2'
		WHEN A.codigo_previdencia = '0005' THEN '6'
		ELSE '1' 
	END AS VINCULO,

	CASE a.codigo_previdencia 
		WHEN '0001' THEN 'G'
		WHEN '0002' THEN 'P'
		WHEN '0003' THEN 'P'
		WHEN '0004' THEN 'P'
		WHEN '0005' THEN 'G'
		ELSE 'G' 
	END AS REGIME_PREVIDENCIA,

	NULL AS DESCRICAO_CARGO,
	TO_CHAR(a.DATA_FIM,'YYYYMMDD') AS DATA_DEMISSAO_EXONERACAO,
	'N' AS MAGISTERIO,
	'N' AS PROFISSIONAL_SAUDE, 
	'N' AS MEDICO,
	'N' AS ATIVIDADE_INSALUBRE,
	'N' AS PROFISSAO_REGULAMENTADA,

	CASE 
		WHEN A.codigo_previdencia = '0001' THEN 'N'
		WHEN A.codigo_previdencia = '0002' THEN 'E'
		WHEN A.codigo_previdencia = '0003' THEN 'T'
		WHEN A.codigo_previdencia = '0004' THEN 'I'
		WHEN A.codigo_previdencia = '0005' THEN 'N'
		ELSE 'Z'
	END AS RESP_CONTAGEM_TEMPO, 

	'S' AS TEMPO_COMPROVADO, 
	'G' AS NATUREZA_JURIDICA,
	'0' AS NUMERO_CTC,

	NULL AS COD_ORG_ANTERIOR, 
	NULL AS  MATRICULA_ANTERIOR,
	NULL AS EMPRESA   
FROM  RHTEMP_COMPUTO A 
WHERE SUBSTR(a.codigo_pessoa,5,10) <> '5110000626'
  AND A.CODIGO_PESSOA = A.CODIGO_CONTRATO)