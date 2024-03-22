
  CREATE OR REPLACE EDITIONABLE FUNCTION "PONTO_ELETRONICO"."FUNC_TRATA_CARACTER" (str_in VARCHAR2) RETURN VARCHAR2 IS
   pos           NUMBER(10);
   chars_special VARCHAR2(255);
   chars_normal  VARCHAR2(255);
   str           VARCHAR2(255) := UPPER(str_in);
BEGIN
   chars_special := 'ÁÀÃÂÉÊÍÓÔÕÚÜÇ.-';
   chars_normal  := 'AAAAEEIOOOUUC  ';
   str           := TRIM(upper(str));
   pos           := length(chars_normal);
   WHILE pos > 0
   LOOP
      str := REPLACE(str,
                     substr(chars_special, pos, 1),
                     substr(chars_normal, pos, 1));
      pos := pos - 1;
   END LOOP;
   str := TRIM(str);
   WHILE regexp_like(str, ' {2,}')
   LOOP
      str := REPLACE(str, '  ', ' ');
   END LOOP;
   pos := length(str);
   WHILE pos > 0
   LOOP
      IF regexp_like(substr(str, pos, 1), '[^A-Z0-9Ç@._ +-]+')
      THEN
         str := concat(substr(str, 1, pos - 1), substr(str, pos + 1));
      END IF;
      pos := pos - 1;
   END LOOP;
   RETURN str;
END;