
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_COMPILAR_OBJETOS_INVALIDOS" as
Cursor Procedures_Invalidas Is
Select OWNER||'.'||Object_Name AS Object_Name
  From All_Objects
 Where Owner = 'ARTERH'
   and Object_Type = 'PROCEDURE'
   and Status = 'INVALID';
Cursor Functions_Invalidas Is
Select OWNER||'.'||Object_Name AS Object_Name
  From All_Objects
 Where Owner = 'ARTERH'
   and Object_Type = 'FUNCTION'
   and Status = 'INVALID';
Cursor Procedures_Invalidas_PONTO Is
Select OWNER||'.'||Object_Name AS Object_Name
  From All_Objects
 Where Owner = 'PONTO_ELETRONICO'
   and Object_Type = 'PROCEDURE'
   and Status = 'INVALID';

Cursor Functions_Invalidas_PONTO Is
Select OWNER||'.'||Object_Name AS Object_Name
  From All_Objects
 Where Owner = 'PONTO_ELETRONICO'
   and Object_Type = 'FUNCTION'
   and Status = 'INVALID';

Comando Varchar2(200);
Begin
For i In Procedures_Invalidas_PONTO
Loop
     Comando := 'ALTER PROCEDURE ' || i.Object_Name || ' COMPILE';
     Begin
           Execute Immediate Comando;
     Exception
     When Others Then
          Null;
     End;
End Loop;
For i In Functions_Invalidas_PONTO
Loop
     Comando := 'ALTER FUNCTION ' || i.Object_Name || ' COMPILE';
     Begin
           Execute Immediate Comando;
     Exception
     When Others Then
          Null;
     End;
End Loop;
For i In Procedures_Invalidas
Loop
     Comando := 'ALTER PROCEDURE ' || i.Object_Name || ' COMPILE';
     Begin
           Execute Immediate Comando;
     Exception
     When Others Then
          Null;
     End;
End Loop;
For i In Functions_Invalidas
Loop
     Comando := 'ALTER FUNCTION ' || i.Object_Name || ' COMPILE';
     Begin
           Execute Immediate Comando;
     Exception
     When Others Then
          Null;
     End;
End Loop;
END;