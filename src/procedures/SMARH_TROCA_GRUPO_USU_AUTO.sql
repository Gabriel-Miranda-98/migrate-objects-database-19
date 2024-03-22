
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."SMARH_TROCA_GRUPO_USU_AUTO" (P_EXCESSAO IN VARCHAR2) AS 

l_dados_usuarios lista:= lista ();
l_string VARCHAR2(4000);
delimitador CHAR(1):=',';
cont number;
VERF NUMBER := 0;

BEGIN

l_string := P_EXCESSAO || delimitador;

      LOOP EXIT WHEN l_string IS NULL;
           cont := INSTR (l_string, delimitador);
         dbms_output.put_line(LTRIM (RTRIM (SUBSTR (l_string, 1, cont - 1))));

          SELECT COUNT (1) INTO VERF from RHUSER_P_SIST where CODIGO_USUARIO = (LTRIM (RTRIM (SUBSTR (l_string, 1, cont - 1)))) AND STATUS_USUARIO = 'A';
           dbms_output.put_line(VERF);
           IF (VERF = 1 ) THEN
             l_dados_usuarios.EXTEND;
             l_dados_usuarios (l_dados_usuarios.COUNT) := LTRIM (RTRIM (SUBSTR (l_string, 1, cont - 1)));
             l_string := SUBSTR (l_string, cont + 1);
           ELSE
           l_string := SUBSTR (l_string, cont + 1);
           END IF;
      END LOOP;

 dbms_output.put_line(l_dados_usuarios(1));
  dbms_output.put_line(l_dados_usuarios(2));

   FOR C1 IN
  (
    SELECT RHINTE_ED_IT_CONV.DADO_ORIGEM AS LOGINS,
    RHINTE_ED_IT_CONV.DADO_DESTINO     AS GRUPOS
    FROM RHINTE_ED_CONV
    INNER JOIN RHINTE_ED_IT_CONV
    ON RHINTE_ED_CONV.CODIGO_CONVERSAO    = RHINTE_ED_IT_CONV.CODIGO_CONVERSAO
    WHERE RHINTE_ED_CONV.CODIGO_CONVERSAO = 'US20'
    AND RHINTE_ED_IT_CONV.DADO_ORIGEM not member (l_dados_usuarios) 
  ) LOOP

  dbms_output.put_line('LOGINS: '|| C1.LOGINS || ' GRUPOS:'|| C1.GRUPOS);
  SMARH_TROCA_GRUPO_USU(C1.LOGINS,C1.GRUPOS);

  END LOOP;


END SMARH_TROCA_GRUPO_USU_AUTO;