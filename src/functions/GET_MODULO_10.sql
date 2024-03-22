
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."GET_MODULO_10" (
 PValor IN VARCHAR2)
 RETURN INTEGER
IS
 ABase INTEGER := 10;
 ATotal INTEGER := 0;
 AMultiplicador INTEGER := 2;
 AResto INTEGER := 0;
 I INTEGER := LENGTH (PValor);
 VChar CHAR (1) := NULL;
 ASoma NUMBER := 0;
 AValor VARCHAR (50) := PValor;
BEGIN
 IF NVL (I, 0) = 0 THEN
  RETURN (248);
 END IF;
 AValor := RTRIM (AValor, ' ');
 AValor := RTRIM (AValor, '-');
 --Varre da direita para a esquerda
 WHILE I <> 0 LOOP
  -- Calcula o total
  VChar := SUBSTR (AValor, I, 1);
  IF AMultiplicador = 2 THEN
   ASoma := AMultiplicador * TO_NUMBER (VChar);
   IF LENGTH (ASoma) = 2 THEN
    ASoma := SUBSTR (ASoma, 1, 1) + SUBSTR (ASoma, 2, 1);
   END IF;
   ATotal := ATotal + ASoma;
   AMultiplicador := 1;
  ELSIF AMultiplicador = 1 THEN
   ASoma := AMultiplicador * TO_NUMBER (VChar);
   IF LENGTH (ASoma) = 2 THEN
    ASoma := SUBSTR (ASoma, 1, 1) + SUBSTR (ASoma, 2, 1);
   END IF;
   ATotal := ATotal + ASoma;
   AMultiplicador := 2;
  END IF;
  I := I - 1;
 END LOOP;
 -- Calcula e retorna DV
 AResto := (ATotal MOD ABase);
 IF AResto = 0 THEN
  RETURN (0);
 ELSE
  RETURN (ABase - AResto);
 END IF;
EXCEPTION
 WHEN OTHERS THEN
  RETURN (247);
END Get_Modulo_10;
 