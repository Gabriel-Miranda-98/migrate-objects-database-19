
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."CARGOS_ATIVOS" ("COD_ORG", "MATRICULA", "CPF_SEGURADO", "COD_CARGO", "NOME_CARGO", "COD_CARGO_AMPARADO", "NOME_CARGO_AMPARADO", "NIVEL_CARGO_AMPARADO", "COD_FUNCAO", "NOME_FUNCAO", "VINCULO", "REGIME_PREVIDENCIA", "RESPON_CONTAGEM_TEMPO", "DATA_NOMEACAO", "ATO_NOMEACAO", "DATA_ADMISSAO_POSSE", "DATA_DEMISSAO_EXONERACAO", "ATO_EXONERACAO", "ATIVIDADE_INSALUBRE", "DEFICIENTE", "MAGISTERIO", "MEDICO", "AREA_SAUDE", "GRUPO_SALARIAL", "SUBGRUPO", "CLASSE", "NIVEL", "SEQUENCIAL_CARGO") AS 
  SELECT TABELA."COD_ORG",
TABELA."MATRICULA",
TABELA."CPF_SEGURADO",
TABELA."COD_CARGO",
TABELA."NOME_CARGO",
TABELA."COD_CARGO_AMPARADO",
TABELA."NOME_CARGO_AMPARADO",
TABELA."NIVEL_CARGO_AMPARADO",
TABELA."COD_FUNCAO",
TABELA."NOME_FUNCAO",
TABELA."VINCULO",
TABELA."REGIME_PREVIDENCIA",
TABELA."RESPON_CONTAGEM_TEMPO",
TABELA."DATA_NOMEACAO",
TABELA."ATO_NOMEACAO",
TABELA."DATA_ADMISSAO_POSSE",
TABELA."DATA_DEMISSAO_EXONERACAO",
TABELA."ATO_EXONERACAO",
TABELA."ATIVIDADE_INSALUBRE",
TABELA."DEFICIENTE",
TABELA."MAGISTERIO",
TABELA."MEDICO",
TABELA."AREA_SAUDE",
TABELA."GRUPO_SALARIAL",
TABELA."SUBGRUPO",
TABELA."CLASSE",
TABELA."NIVEL",
row_number() OVER (PARTITION BY TABELA.CPF_SEGURADO ORDER BY TABELA.DATA_ADMISSAO_POSSE) AS SEQUENCIAL_CARGO
FROM
(SELECT 
CO.CODIGO_EMPRESA AS COD_ORG,
	/*CO.NOME, CO.CODIGO_PESSOA,*/
	TO_NUMBER(SUBSTR(CO.CODIGO, 5,10)) ||
	CASE
	WHEN SUBSTR(CO.CODIGO, 15,1) = 'X'
	THEN 7
	ELSE to_number(SUBSTR(CO.CODIGO, 15,1))
	END                                     AS MATRICULA,
	SUBSTR(PE.CPF, 1,11)                    AS CPF_SEGURADO,
	SUBSTR(TRIM(CO.COD_CARGO_EFETIVO),12,4) AS COD_CARGO,
  SUBSTR(trim(CA.DESCRICAO),1,80)         AS NOME_CARGO,
  SUBSTR(TRIM(CO.COD_CARGO_AMPAR),12,4)   AS COD_CARGO_AMPARADO,
	SUBSTR(trim(CA2.DESCRICAO),1,80)        AS NOME_CARGO_AMPARADO,
  CO.NIVEL_CARGO_AMPAR                    AS NIVEL_CARGO_AMPARADO,
	SUBSTR(TRIM(CO.CODIGO_FUNCAO),12,4)     AS COD_FUNCAO,
	SUBSTR(trim(FU.DESCRICAO),1,20)         AS NOME_FUNCAO,
	CASE
	WHEN CO.VINCULO IN ('0000','0002')
	THEN '2'
	END                    AS VINCULO,
	'P'                    AS REGIME_PREVIDENCIA,
	'E'                    AS RESPON_CONTAGEM_TEMPO,
	TO_CHAR(CO.DATA_NOMEACAO,'YYYYMMDD') AS DATA_NOMEACAO,
	NULL                   AS ATO_NOMEACAO,
	CASE
	WHEN TO_CHAR(CO.DATA_EFETIVO_EXERC,'YYYYMMDD') IS NOT NULL
	THEN TO_CHAR(CO.DATA_EFETIVO_EXERC,'YYYYMMDD')
	ELSE TO_CHAR(CO.DATA_ADMISSAO,'YYYYMMDD')
	END                                  AS DATA_ADMISSAO_POSSE,
	TO_CHAR(CO.DATA_RESCISAO,'YYYYMMDD') AS DATA_DEMISSAO_EXONERACAO,
	NULL                                 AS ATO_EXONERACAO,
	'N'                                  AS ATIVIDADE_INSALUBRE,
	/*NOVOS CAMPOS ??? DE ONDE VAI PEGAR OS  NOVOS CAMPOS TEM QUE OLHAR COM A MARILANE */
	'N' AS DEFICIENTE,
	CASE
	WHEN SUBSTR(CO.COD_CARGO_EFETIVO,-4) IN('1502','1508','1512')
	THEN 'S'
	ELSE 'N'
	END AS MAGISTERIO,
	CASE
	WHEN SUBSTR(CO.COD_CARGO_EFETIVO,-4) IN('1422','1435','1434','1405','3300')
	THEN 'S'
	ELSE 'N'
	END AS MEDICO,
	CASE
	WHEN CA.c_livre_descr08 LIKE '02 - Saúde'
	THEN 'S'
	ELSE 'N'
	END AS AREA_SAUDE,
    -- row_number() OVER (PARTITION BY substr(PE.CPF,1,11) ORDER BY CO.CODIGO_PESSOA) AS SEQUENCIAL,
    TO_NUMBER(SUBSTR(TRIM(CO.COD_CARGO_EFETIVO),12,4)) AS GRUPO_SALARIAL,
    CA.TABELA_UTILIZADA                                AS SUBGRUPO,
    SAL.DESCRICAO                                      AS DESCRICAO_SUBGRUPO,
    ESC.CODIGO                                         AS CLASSE,
    ESC.DESCRICAO                                      AS CLASSE_DESCRICAO,
    SUBSTR(TRIM(CO.nivel_cargo_efetiv),-4)            AS NIVEL
    FROM RHPESS_CONTRATO CO
    LEFT OUTER JOIN RHPESS_PESSOA PE
    ON CO.CODIGO_EMPRESA = PE.CODIGO_EMPRESA
    AND CO.CODIGO_PESSOA = PE.CODIGO
    LEFT OUTER JOIN RHPLCS_FUNCAO FU
    ON CO.CODIGO_EMPRESA = FU.CODIGO_EMPRESA
    AND CO.CODIGO_FUNCAO = FU.CODIGO
    LEFT OUTER JOIN RHPLCS_CARGO CA
    ON CO.CODIGO_EMPRESA     = CA.CODIGO_EMPRESA
    AND CO.COD_CARGO_EFETIVO = CA.CODIGO
    LEFT OUTER JOIN RHPLCS_CARGO CA2
    ON CO.CODIGO_EMPRESA     = CA2.CODIGO_EMPRESA
    AND CO.COD_CARGO_AMPAR = CA2.CODIGO
    LEFT OUTER JOIN RHORGA_CUSTO_GEREN CG
    ON CO.CODIGO_EMPRESA     = CG.CODIGO_EMPRESA
    AND CO.COD_CUSTO_GERENC1 = CG.COD_CGERENC1
    AND CO.COD_CUSTO_GERENC2 = CG.COD_CGERENC2
    AND CO.COD_CUSTO_GERENC3 = CG.COD_CGERENC3
    AND CO.COD_CUSTO_GERENC4 = CG.COD_CGERENC4
    AND CO.COD_CUSTO_GERENC5 = CG.COD_CGERENC5
    AND CO.COD_CUSTO_GERENC6 = CG.COD_CGERENC6
    LEFT OUTER JOIN RHPARM_SIT_FUNC ST
    ON CO.SITUACAO_FUNCIONAL = ST.CODIGO
    LEFT OUTER JOIN RHPARM_CAUSA_RESC
    ON CO.CAUSA_RESCISAO = RHPARM_CAUSA_RESC.CODIGO
    LEFT OUTER JOIN RHTABS_VINCULO_EMP
    ON CO.VINCULO = RHTABS_VINCULO_EMP.CODIGO
    LEFT OUTER JOIN RHPLCS_TAB_SALARIO SAL
    ON CA.TABELA_UTILIZADA = SAL.CODIGO
    AND CA.CODIGO_EMPRESA  = SAL.CODIGO_EMPRESA
    LEFT OUTER JOIN RHPONT_ESCALA ESC
    ON CA.CODIGO_ESCALA            = ESC.CODIGO
    AND CA.CODIGO_EMPRESA          = ESC.CODIGO_EMPRESA
    WHERE  co.codigo_empresa IN ('0013','0014','0001')
    AND CO.TIPO_CONTRATO          IN ('0001', '0007')
    AND CO.SITUACAO_FUNCIONAL NOT IN ('1710', '1715', '1800', '1850', '1900', '5000', '5001', '5002', '5003', '5004', '5005', '5006',
                                      '5008', '5009', '5011', '5019', '5022', '5026', '5028', '5200', '5201', '5400', '5555', '5700', '5800',
                                      '5801', '5808', '5900', '5901', '6002', '6003', '8000')
    AND CO.VINCULO IN ('0000','0002')
    AND (CO.CODIGO                 < '000000099999999'
    --AND SUBSTR(CO.CODIGO, 5,10) = '0000043188'
    	AND CO.CODIGO NOT             IN('000000000777777','000000000823701','000000000833014','000000000866265','000000000747428','000000000190072','000000000420534'))
    /*FALECIDOS PIA*/
    AND CO.ANO_MES_REFERENCIA = (
      SELECT MAX(A.ANO_MES_REFERENCIA)
        FROM RHPESS_CONTRATO A
        WHERE A.CODIGO            = CO.CODIGO
        AND A.CODIGO_EMPRESA      = CO.CODIGO_EMPRESA
        AND A.TIPO_CONTRATO       = CO.TIPO_CONTRATO
        AND A.ANO_MES_REFERENCIA <= add_months(sysdate,(-1))-0
        )) TABELA
GROUP BY COD_ORG,MATRICULA,CPF_SEGURADO,COD_CARGO,NOME_CARGO,COD_CARGO_AMPARADO, NOME_CARGO_AMPARADO, NIVEL_CARGO_AMPARADO, COD_FUNCAO,NOME_FUNCAO,VINCULO,REGIME_PREVIDENCIA,RESPON_CONTAGEM_TEMPO,DATA_NOMEACAO,
ATO_NOMEACAO,DATA_ADMISSAO_POSSE,DATA_DEMISSAO_EXONERACAO,ATO_EXONERACAO,ATIVIDADE_INSALUBRE,DEFICIENTE,MAGISTERIO,MEDICO,AREA_SAUDE,/*SEQUENCIAL,*/
GRUPO_SALARIAL,SUBGRUPO,CLASSE,NIVEL