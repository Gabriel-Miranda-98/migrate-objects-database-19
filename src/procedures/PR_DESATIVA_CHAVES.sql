
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_DESATIVA_CHAVES" (
    ACAO IN VARCHAR2,
    ID_PK LISTA)
AS
BEGIN
  DECLARE
    vACAO VARCHAR2(10 BYTE);
    vID LISTA;
    CONT NUMBER;
  BEGIN
    vACAO:=ACAO;
    vID  :=ID_PK;
    CONT :=0;
    dbms_output.enable(NULL);
    FOR C1 IN
    (SELECT X.*
    FROM
      (SELECT CNT.CONSTRAINT_NAME                                   AS NOME_FK,
        CNT.OWNER                                                   AS OWNER_FK,
        SUBSTR(CNT.CONSTRAINT_NAME,LENGTH(CNT.CONSTRAINT_NAME)-1,2) AS ORDEM_FK,
        CNT.TABLE_NAME                                              AS NOME_TABELA,
        LISTAGG(REPLACE(CN.COLUMN_NAME,' ',''),',') WITHIN GROUP(
      ORDER BY CN.POSITION)AS ORDERM_COLUNAS
      FROM ALL_CONSTRAINTS CNT
      LEFT OUTER JOIN ALL_CONS_COLUMNS CN
      ON CN.OWNER            =CNT.OWNER
      AND CN.CONSTRAINT_NAME =CNT.CONSTRAINT_NAME
      ---- trocar a tabela  SER for executar em outra tabela
      WHERE CNT.TABLE_NAME   ='RHPARM_VERBA'
      AND CNT.CONSTRAINT_TYPE='R'
      ---- trocar o OWNER POR ARTERH SER for executar em producao
      AND CNT.OWNER          ='ARTERH'
      GROUP BY CNT.CONSTRAINT_NAME,
        CNT.OWNER,
        CNT.TABLE_NAME
      )X
    )
    LOOP

      IF vID IS NULL THEN

        DBMS_OUTPUT.PUT_LINE('ALTER TABLE '||C1.OWNER_FK||'.'||C1.NOME_TABELA||' MODIFY CONSTRAINT '||C1.NOME_FK||' '||vACAO||';' );
   --     execute immediate 'ALTER TABLE '||C1.OWNER_FK||'.'||C1.NOME_TABELA||' MODIFY CONSTRAINT '||C1.NOME_FK||' '||vACAO||'';
        END IF;






      --- execute immediate 'ALTER TABLE '||C1.OWNER_FK||'.'||C1.NOME_TABELA||' MODIFY CONSTRAINT '||C1.NOME_FK||' DISABLE ';
    END LOOP;

    FOR C2 IN
        (SELECT X.*
        FROM
          (SELECT CNT.CONSTRAINT_NAME                                   AS NOME_FK,
            CNT.OWNER                                                   AS OWNER_FK,
            SUBSTR(CNT.CONSTRAINT_NAME,LENGTH(CNT.CONSTRAINT_NAME)-1,2) AS ORDEM_FK,
            CNT.TABLE_NAME                                              AS NOME_TABELA,
            LISTAGG(REPLACE(CN.COLUMN_NAME,' ',''),',') WITHIN GROUP(
          ORDER BY CN.POSITION)AS ORDERM_COLUNAS
          FROM ALL_CONSTRAINTS CNT
          LEFT OUTER JOIN ALL_CONS_COLUMNS CN
          ON CN.OWNER            =CNT.OWNER
          AND CN.CONSTRAINT_NAME =CNT.CONSTRAINT_NAME
          ---- trocar a tabela  SER for executar em outra tabela
          WHERE CNT.TABLE_NAME   ='RHPARM_VERBA'
          AND CNT.CONSTRAINT_TYPE='R'
          ---- trocar o OWNER POR ARTERH SER for executar em producao
          AND CNT.OWNER          ='ARTERH'
          GROUP BY CNT.CONSTRAINT_NAME,
            CNT.OWNER,
            CNT.TABLE_NAME
          )X
        WHERE ORDEM_FK MEMBER (vID)

        )
        LOOP
       IF vID IS NOT NULL THEN
     --     execute immediate 'ALTER TABLE '||C2.OWNER_FK||'.'||C2.NOME_TABELA||' MODIFY CONSTRAINT '||C2.NOME_FK||' '||vACAO||'';
          DBMS_OUTPUT.PUT_LINE('ALTER TABLE '||C2.OWNER_FK||'.'||C2.NOME_TABELA||' MODIFY CONSTRAINT '||C2.NOME_FK||' '||vACAO||';' );
          END IF;
        END LOOP;
  END;
END;