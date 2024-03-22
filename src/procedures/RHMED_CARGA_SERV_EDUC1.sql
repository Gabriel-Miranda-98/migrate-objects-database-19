
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."RHMED_CARGA_SERV_EDUC1" 
as
  i integer;
BEGIN
--execute immediate('truncate table servidor_educacao');
--execute immediate('insert into servidor_educacao select * from V_RHSMED01');
--execute immediate('commit');
execute immediate('analyze table servidor_educacao estimate statistics');
SELECT count(*) INTO i FROM servidor_educacao;
INSERT INTO controle_replica_educacao values ( sysdate,i );
COMMIT;

END;
 