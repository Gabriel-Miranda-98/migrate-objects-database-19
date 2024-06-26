
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_ARTERH_SITUACAO_FUNCIONAL" ("CODIGO", "DESCRICAO", "CONTROLE_FOLHA", "E_AFASTAMENTO", "SUSPENDE_REMUNERA", "ABATE_TEMPO_FERIAS", "ABATE_TEMPO_13_SAL", "SUSPENDE_VALE", "DATA_INI_VIGENCIA", "DATA_FIM_VIGENCIA") AS 
  SELECT
        SF.CODIGO,
        SF.DESCRICAO,
        case when sf.CONTROLE_FOLHA = 'N' THEN 'N - NORMAL'
             when sf.CONTROLE_FOLHA = 'F' THEN 'F - FERIAS'
             when sf.CONTROLE_FOLHA = 'D' THEN 'D - DESLIGADO'
             when sf.CONTROLE_FOLHA = 'A' THEN 'A - ADMITIDO'
             when sf.CONTROLE_FOLHA = 'P' THEN 'P - AVISO PREVIO'
             when sf.CONTROLE_FOLHA = 'L' THEN 'L - LICENCA'
             when sf.CONTROLE_FOLHA = 'M' THEN 'M - MATERNIDADE'
             when sf.CONTROLE_FOLHA = 'S' THEN 'S - APOSENTADO'
             when sf.CONTROLE_FOLHA = 'O' THEN 'O - OUTRO' END AS CONTROLE_FOLHA,
        SF.E_AFASTAMENTO,
        SF.SUSPENDE_REMUNERA,
        SF.ABATE_TEMPO_FERIAS,
        SF.ABATE_TEMPO_13_SAL,
        SF.SUSPENDE_VALE,
        SF.DATA_INI_VIGENCIA,
        SF.DATA_FIM_VIGENCIA
      FROM
        ARTERH.RHPARM_SIT_FUNC SF
     WHERE
        SF.DATA_FIM_VIGENCIA IS NULL
     ORDER BY
        SF.CODIGO