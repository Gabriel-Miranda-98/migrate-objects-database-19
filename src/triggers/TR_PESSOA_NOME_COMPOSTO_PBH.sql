
  CREATE OR REPLACE EDITIONABLE TRIGGER "ARTERH"."TR_PESSOA_NOME_COMPOSTO_PBH" 

FOR UPDATE OR INSERT OF NOME, CPF ON "ARTERH"."RHPESS_PESSOA"

COMPOUND TRIGGER

   TYPE id_pessoa IS RECORD (

      CODIGO_EMPRESA  RHPESS_PESSOA.CODIGO_EMPRESA%TYPE

    , CODIGO          RHPESS_PESSOA.CODIGO%TYPE

   );



   TYPE row_level_info_t IS TABLE OF id_pessoa  INDEX BY PLS_INTEGER;



   g_row_level_info  row_level_info_t;



   AFTER EACH ROW IS

   BEGIN

      g_row_level_info(g_row_level_info.COUNT + 1).CODIGO_EMPRESA := :NEW.CODIGO_EMPRESA;

      g_row_level_info(g_row_level_info.COUNT).CODIGO := :NEW.CODIGO;

   END AFTER EACH ROW;



   AFTER STATEMENT IS

   BEGIN

      FOR indx IN 1 .. g_row_level_info.COUNT

      LOOP

        update RHPESS_PESSOA

        set NOME_COMPOSTO = CPF||' - '||NOME

        where CODIGO_EMPRESA = g_row_level_info(indx).CODIGO_EMPRESA

          and CODIGO = g_row_level_info(indx).CODIGO;

      END LOOP;

  END AFTER STATEMENT;

END tr_pessoa_nome_composto_pbh;
ALTER TRIGGER "ARTERH"."TR_PESSOA_NOME_COMPOSTO_PBH" ENABLE