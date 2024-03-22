
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."RESUMO_CONTR_FPMZB" ("ANO_MES_REFERENCIA", "COD_ORG", "MATRICULA", "TIPO_MOVIMENTO", "BASE_CALC_CONTRI", "VAL_CONT_BAS_SEG", "VAL_CONT_PATRO_NORM", "VAL_CONT_ADIC_SEG", "VAL_CONT_PATR_ADIC", "REMUNERACAO_TOTAL", "NOME", "COD_PLANO", "SITUACAO_FUNCIONAL", "DATA_PAGAMENTO", "DECIMO_TERCEIRO", "FERIAS", "RESCISAO") AS 
  SELECT 
		TO_CHAR (m.ano_mes_referencia, 'yyyymm') AS ANO_MES_REFERENCIA,
    C.CODIGO_EMPRESA AS COD_ORG,
    TO_NUMBER (SUBSTR (C.codigo, 5, 10)) || CASE WHEN SUBSTR (c.codigo, 15, 1) NOT IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9') THEN 7 ELSE TO_NUMBER (SUBSTR (c.codigo, 15, 1)) END AS MATRICULA,
		m.tipo_movimento,
    TO_CHAR (SUM(CASE m.codigo_verba WHEN '4436' THEN m.valor_verba ELSE 0 END), '0000000.00') AS BASE_CALC_CONTRI, 	 --BASE CONTRIB PREVIDENCIARIA GERAL - RPPS
		TO_CHAR (SUM(CASE m.codigo_verba WHEN '4437' THEN m.valor_verba ELSE 0 END), '0000000.00') AS VAL_CONT_BAS_SEG, 	 --CONTRIB PREVIDENCIARIA - RPPS
		TO_CHAR (SUM(CASE m.codigo_verba WHEN '4438' THEN m.valor_verba ELSE 0 END), '0000000.00') AS VAL_CONT_PATRO_NORM, --PATRONAL - RPPS
		TO_CHAR (SUM(CASE m.codigo_verba WHEN '4xx2' THEN m.valor_verba ELSE 0 END), '0000000.00') AS VAL_CONT_ADIC_SEG,   --Contribuição Adicional do Segurado
		TO_CHAR (SUM(CASE m.codigo_verba WHEN '4xx3' THEN m.valor_verba ELSE 0 END), '0000000.00') AS VAL_CONT_PATR_ADIC,  --PATRONAL adcional - RPPS
		TO_CHAR (SUM(CASE m.codigo_verba WHEN '4001' THEN m.valor_verba ELSE 0 END), '0000000.00') AS REMUNERACAO_TOTAL,   --já é a verba correta
    TRIM (p.nome) AS NOME,
    CASE WHEN c.data_admissao < TO_DATE ('30/12/2011', 'dd/mm/yyyy') THEN 1 ELSE 2 END AS COD_PLANO,
    c.situacao_funcional, 
		SUBSTR (TO_CHAR (m.ano_mes_referencia, 'YYYYMMDD'), 1, 6) || '30' AS DATA_PAGAMENTO,
	  CASE WHEN m.tipo_movimento = 'DE' THEN 'S' ELSE 'N' END AS DECIMO_TERCEIRO,
		'N' AS FERIAS,
		'N' AS RESCISAO /* não tem rescisão na PBH - verificar se a 4024 está sendo usada para outros fins */
	FROM RHPESS_CONTRATO c
		INNER JOIN RHPESS_PESSOA p ON p.CODIGO_EMPRESA = c.CODIGO_EMPRESA AND p.CODIGO = c.CODIGO_PESSOA
		INNER JOIN RHMOVI_MOVIMENTO m ON m.CODIGO_EMPRESA = c.CODIGO_EMPRESA
			AND m.TIPO_CONTRATO = c.TIPO_CONTRATO
			AND m.CODIGO_CONTRATO = c.CODIGO
		INNER JOIN RHPARM_VERBA v ON m.CODIGO_VERBA = v.CODIGO
	WHERE m.tipo_contrato = '0001'
		AND v.codigo IN ('4001', '4436','4437', '4438', '4xx2', '4xx3')
		AND m.modo_operacao = 'R'
		AND M.TIPO_MOVIMENTO IN ('ME', 'DE')
		AND c.codigo_empresa = '0014'
		AND m.ano_mes_referencia = ADD_MONTHS(TRUNC(SYSDATE, 'MONTH'), -1) 
		AND c.vinculo IN ('0000', '0002')
		AND m.VALOR_VERBA > 0
		AND c.ano_mes_referencia = (
			SELECT MAX (x.ano_mes_referencia)
				FROM rhpess_contrato x
			 WHERE x.codigo_empresa = c.codigo_empresa
				 AND x.tipo_contrato = c.tipo_contrato
				 AND x.codigo = c.codigo
				 AND x.ano_mes_referencia <= m.ano_mes_referencia)
	GROUP BY m.ano_mes_referencia, c.data_admissao, m.codigo_contrato, c.codigo, m.tipo_movimento, c.situacao_funcional, P.NOME, C.CODIGO_EMPRESA