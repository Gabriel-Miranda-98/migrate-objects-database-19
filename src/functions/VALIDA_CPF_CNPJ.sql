
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."VALIDA_CPF_CNPJ" (V_CPF_CNPJ VARCHAR2) RETURN BOOLEAN IS
  /*  Função para validar CPF/CNPJ
      Banco de Dados: Oracle 10g
      Data: 11/02/2008
      Autor: Rogério Alcântara Valente
  */
  TYPE ARRAY_DV IS VARRAY(2) OF PLS_INTEGER;
  V_ARRAY_DV ARRAY_DV := ARRAY_DV(0, 0);
  CPF_DIGIT  CONSTANT PLS_INTEGER := 11;
  CNPJ_DIGIT CONSTANT PLS_INTEGER := 14;
  IS_CPF       BOOLEAN;
  IS_CNPJ      BOOLEAN;
  V_CPF_NUMBER VARCHAR2(20);
  TOTAL        NUMBER := 0;
  COEFICIENTE  NUMBER := 0;
  DV1    NUMBER := 0;
  DV2    NUMBER := 0;
  DIGITO NUMBER := 0;
  J      INTEGER;
  I      INTEGER;
BEGIN
  IF V_CPF_CNPJ IS NULL THEN
    RETURN FALSE;
  END IF;
  /*
    Retira os caracteres não numéricos do CPF/CNPJ
    caso seja enviado para validação um valor com
    a máscara.
  */
  V_CPF_NUMBER := REGEXP_REPLACE(V_CPF_CNPJ, '[^0-9]');
  /*
    Verifica se o valor passado é um CPF através do
    número de dígitos informados. CPF = 11
  */
  IS_CPF := (LENGTH(V_CPF_NUMBER) = CPF_DIGIT);
  /*
    Verifica se o valor passado é um CNPJ através do
    número de dígitos informados. CNPJ = 14
  */
  IS_CNPJ := (LENGTH(V_CPF_NUMBER) = CNPJ_DIGIT);
  IF (IS_CPF OR IS_CNPJ) THEN
    TOTAL := 0;
  ELSE
    RETURN FALSE;
  END IF;
   /*
    Armazena os valores de dígitos informados para
    posterior comparação com os dígitos verificadores calculados.
  */
  DV1 := TO_NUMBER(SUBSTR(V_CPF_NUMBER, LENGTH(V_CPF_NUMBER) - 1, 1));
  DV2 := TO_NUMBER(SUBSTR(V_CPF_NUMBER, LENGTH(V_CPF_NUMBER), 1));
  V_ARRAY_DV(1) := 0;
  V_ARRAY_DV(2) := 0;
  /*
    Laço para cálculo dos dígitos verificadores.
    É utilizado módulo 11 conforme norma da Receita Federal.
  */
  FOR J IN 1 .. 2
  LOOP
    TOTAL := 0;
    COEFICIENTE := 2;
    FOR I IN REVERSE 1 .. ((LENGTH(V_CPF_NUMBER) - 3) + J)
    LOOP
      DIGITO := TO_NUMBER(SUBSTR(V_CPF_NUMBER, I, 1));
      TOTAL := TOTAL + (DIGITO * COEFICIENTE);
      COEFICIENTE := COEFICIENTE + 1;
      IF (COEFICIENTE > 9) AND IS_CNPJ THEN
        COEFICIENTE := 2;
      END IF;
    END LOOP; --for i
    V_ARRAY_DV(J) := 11 - MOD(TOTAL, 11);
    IF (V_ARRAY_DV(J) >= 10) THEN
      V_ARRAY_DV(J) := 0;
    END IF;
  END LOOP; --for j in 1..2
  /*
    Compara os dígitos calculados com os informados para informar resultado.
  */

  RETURN(DV1 = V_ARRAY_DV(1)) AND(DV2 = V_ARRAY_DV(2));
END VALIDA_CPF_CNPJ;