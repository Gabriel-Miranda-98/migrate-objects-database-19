
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."SMARH_DESFAZ_TROCA_GRUPO_AUTO" (SistemaFechadoLancamento IN CHAR DEFAULT 'S') AS 
BEGIN
  FOR C1 IN
  (
    SELECT RHINTE_ED_IT_CONV.DADO_ORIGEM AS LOGINS
    FROM RHINTE_ED_CONV
    INNER JOIN RHINTE_ED_IT_CONV
    ON RHINTE_ED_CONV.CODIGO_CONVERSAO    = RHINTE_ED_IT_CONV.CODIGO_CONVERSAO
    WHERE RHINTE_ED_CONV.CODIGO_CONVERSAO = 'US20'
  ) LOOP

  SMARH_DESFAZ_TROCA_GRUPO_USU(C1.LOGINS,SistemaFechadoLancamento);

  END LOOP;

END SMARH_DESFAZ_TROCA_GRUPO_AUTO;