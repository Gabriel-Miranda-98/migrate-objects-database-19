
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."VALIDA_ANO_BISEXTO" (vData IN DATE) return varchar2 is
  /*  Função para validar ano bisexto
      Banco de Dados: Oracle 12g
      Data: 01/01/2023
      Autor: Marcos Silva pb003529
  */
vStringReturn varchar2(5);
vAno_Inicial  VARCHAR2(4):='';
BEGIN
vAno_Inicial := TO_CHAR(EXTRACT(YEAR FROM(to_date(vData,'DD/MM/YYYY'))));

    IF ((MOD(vAno_Inicial,400) = 0) OR( (MOD(vAno_Inicial,4) = 0) AND (MOD(vAno_Inicial,100) <> 0) )) THEN
        vStringReturn :='TRUE';
     ELSE 
      vStringReturn :='FALSE';
  END IF;
    RETURN vStringReturn;
END VALIDA_ANO_BISEXTO;