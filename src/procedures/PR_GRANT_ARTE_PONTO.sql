
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_GRANT_ARTE_PONTO" IS 
 CONT NUMBER;
vcomando varchar2(500 byte):=null;
BEGIN 
CONT :=0;
FOR C1 IN (
SELECT CASE WHEN X.OBJETO IN ('VIEW','SEQUENCE') THEN 'SELECT' 
WHEN  X.OBJETO IN ('PROCEDURE','FUNCTION','TYPE') THEN 'EXECUTE' ELSE 'SELECT' END AS PERMISSAO ,X.* FROM (
SELECT TAB.OWNER,TAB.TABLE_NAME, NULL AS OBJETO FROM DBA_TABLES TAB 
WHERE TAB.OWNER IN ('ARTERH','PONTO_ELETRONICO')
UNION ALL
SELECT OBJ.OWNER,OBJ.OBJECT_NAME,OBJ.OBJECT_TYPE as OBJETO FROM DBA_OBJECTS OBJ where OBJECT_TYPE IN('PROCEDURE','FUNCTION','VIEW','SEQUENCE','TYPE') AND OWNER IN ('ARTERH','PONTO_ELETRONICO')
)X
WHERE NOT EXISTS (
SELECT   * FROM  DBA_TAB_PRIVS WHERE GRANTEE ='ROLE_ASTIN_GESP_PBH' AND DBA_TAB_PRIVS.TABLE_NAME=X.TABLE_NAME)
)LOOP
CONT:=CONT+1;
vcomando:='GRANT '||' '||c1.permissao||' ON '||c1.OWNER||'.'||c1.table_name||' TO ROLE_ASTIN_GESP_PBH';
 DBMS_Output.PUT_LINE(vcomando);

Begin
 Execute Immediate vcomando;
  COMMIT;
  Exception
     When Others Then
          Null;
          end;
END LOOP;
END;