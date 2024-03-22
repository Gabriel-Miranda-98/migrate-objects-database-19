
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_INCLUIR_RESPONSAVEL" (
        var arterh.rhuser_pessoa_responsavel%rowtype
    ) IS
    BEGIN
        INSERT INTO arterh.rhuser_pessoa_responsavel VALUES var;

    END;