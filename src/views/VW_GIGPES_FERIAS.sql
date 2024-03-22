
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_GIGPES_FERIAS" ("NOME", "CODIGO_EMPRESA", "TIPO_CONTRATO", "CODIGO_CONTRATO", "DT_INI_AQUISICAO", "PERIODO", "TIPO_FERIAS", "DT_FIM_AQUISICAO", "DT_INI_PROGRAMADA", "DT_FIM_PROGRAMADA", "DIAS_PROG_FERIAS", "DIAS_PROG_ABONO", "DT_INI_GOZO", "DT_FIM_GOZO", "DIAS_GOZO_FERIAS", "DIAS_ABONO", "DIAS_COMPENSACAO", "DT_RETORNO", "SALDO_AUXILIAR", "STATUS_CONFIRMACAO", "OBSERVACAO", "DT_FIM_GOZO_FORCA", "DIAS_GOZO_FORCA", "DIAS_ABONO_FORCA", "ACEITA_PREVISTO", "STATUS_CALCULO", "CODIGO_EMPRESA_SUBSTITUTO", "TIPO_CONTRATO_SUBSTITUTO", "CODIGO_CONTRATO_SUBSTITUTO", "COD_MOT_INTERRUPCAO", "PERIODO_AQUISITIVO", "PERIODO_AQUISITIVO_ALTERACAO", "LOGIN_USUARIO", "DT_ULT_ALTER_USUA", "C_LIVRE_VALOR01") AS 
  SELECT
(
	SELECT
		NOME
	FROM
		VW_GIGPES_CONTRATO_MESTRE
	WHERE
		CODIGO_CONTRATO = RHFERI_FERIAS.CODIGO_CONTRATO AND
		TIPO_CONTRATO = RHFERI_FERIAS.TIPO_CONTRATO AND
		CODIGO_EMPRESA = RHFERI_FERIAS.CODIGO_EMPRESA
) AS NOME,
CODIGO_EMPRESA,  TIPO_CONTRATO,   CODIGO_CONTRATO,   DT_INI_AQUISICAO,  PERIODO,  TIPO_FERIAS,  DT_FIM_AQUISICAO,
DT_INI_PROGRAMADA,  DT_FIM_PROGRAMADA,  DIAS_PROG_FERIAS,  DIAS_PROG_ABONO,  DT_INI_GOZO,  DT_FIM_GOZO,  DIAS_GOZO_FERIAS,
DIAS_ABONO,  DIAS_COMPENSACAO,  DT_RETORNO,  SALDO_AUXILIAR,  STATUS_CONFIRMACAO,  OBSERVACAO,  DT_FIM_GOZO_FORCA,  DIAS_GOZO_FORCA,
DIAS_ABONO_FORCA,  ACEITA_PREVISTO,  STATUS_CALCULO,  CODIGO_EMPRESA_SUBSTITUTO,   TIPO_CONTRATO_SUBSTITUTO,  CODIGO_CONTRATO_SUBSTITUTO,
COD_MOT_INTERRUPCAO,
(
	DT_INI_AQUISICAO || ' até ' || DT_FIM_AQUISICAO || ' - Período ' || PERIODO || ' - Dias de gozo ' || DIAS_GOZO_FERIAS || ' - ' ||
	(
		SELECT
			ABREVIACAO
		FROM
			VW_GIGPES_PARM_FERIAS
		WHERE
			CODIGO_EMPRESA = RHFERI_FERIAS.CODIGO_EMPRESA AND
			CODIGO = TIPO_FERIAS
	))
AS PERIODO_AQUISITIVO,
(
	DT_INI_AQUISICAO || ' até ' || DT_FIM_AQUISICAO || ' - ' ||
	(
		SELECT
			ABREVIACAO
		FROM
			VW_GIGPES_PARM_FERIAS
		WHERE
			CODIGO_EMPRESA = RHFERI_FERIAS.CODIGO_EMPRESA AND
			CODIGO = TIPO_FERIAS
	))
AS PERIODO_AQUISITIVO_ALTERACAO, LOGIN_USUARIO,  DT_ULT_ALTER_USUA, C_LIVRE_VALOR01
FROM RHFERI_FERIAS  ORDER BY CODIGO_CONTRATO, DT_INI_AQUISICAO, TIPO_CONTRATO