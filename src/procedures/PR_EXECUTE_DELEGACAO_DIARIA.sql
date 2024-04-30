
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_EXECUTE_DELEGACAO_DIARIA" AS 
BEGIN

BEGIN
  ARTERH.PR_FOTO_CONTRATO_DELEGACAO ('');

  exception
              when others then
              NULL;

END;

BEGIN
  ARTERH.PR_NEW_ATUALIZA_DELEGACAO ();

  exception
              when others then
              NULL;

END;
END;