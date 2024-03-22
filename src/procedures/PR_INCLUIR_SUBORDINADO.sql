
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_INCLUIR_SUBORDINADO" (
        var arterh.rhuser_pessoa_resp_supervisao%rowtype
    ) IS
    BEGIN
        INSERT INTO arterh.rhuser_pessoa_resp_supervisao VALUES var;

    END;