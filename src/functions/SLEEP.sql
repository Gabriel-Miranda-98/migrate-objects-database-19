
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."SLEEP" (
    seconds IN NUMBER
   ) RETURN NUMBER
   AS
   BEGIN
     SLEEPIMPL( seconds );
     RETURN seconds;
   END;