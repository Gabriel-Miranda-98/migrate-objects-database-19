
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."FU_VALIDAR_LINHA_ARQUIVO" (pIS_ARQUIVO INTERFACE_ARQUIVO, LinhaTexto IN VARCHAR2)
RETURN RETORNO_PROCESSAMENTO
 IS
  REG_LOG LOG_PROCESSAMENTO;
  vLISTA_LOG LISTA_LOG;
  vRETORNO RETORNO_PROCESSAMENTO;

  I_S INTERFACE_SOFTWARE;

  TIPO_ALFANUMERICO     CONSTANT NUMBER := 1;
  TIPO_NUMERICO         CONSTANT NUMBER := 2;
  TIPO_DATA             CONSTANT NUMBER := 3;
  TIPO_DATA_HORA        CONSTANT NUMBER := 4;
  TIPO_SIM_NAO          CONSTANT NUMBER := 5;
  TIPO_VALOR            CONSTANT NUMBER := 6;
  TIPO_VALOR_SEPARADOR_DECIMAL            CONSTANT NUMBER := 7;
  SIM                   CONSTANT NUMBER := 1;
  NAO                   CONSTANT NUMBER := 0;

  TIPO_LOG_SUCESSO      CONSTANT NUMBER := 0;
  TIPO_LOG_INFO         CONSTANT NUMBER := 2;
  TIPO_LOG_ALERTA       CONSTANT NUMBER := 2;
  TIPO_LOG_ERRO         CONSTANT NUMBER := 99;

  LOG_TAMANHO_LINHA_INVALIDO     CONSTANT CHAR(4) := 'L001';
  LOG_QUANTIDADE_CAMPOS_INVALIDA CONSTANT CHAR(4) := 'L002';
  LOG_TAMANHO_CAMPO_INVALIDO     CONSTANT CHAR(4) := 'L003';
  LOG_CAMPO_NULO                 CONSTANT CHAR(4) := 'L004';
  LOG_DATA_INVALIDA              CONSTANT CHAR(4) := 'L005';
  LOG_TEXTO_INVALIDO             CONSTANT CHAR(4) := 'L006';
  LOG_NUMERO_INVALIDO            CONSTANT CHAR(4) := 'L007';

  FORMATO_DATA          CONSTANT VARCHAR2(8)  := 'DDMMYYYY';
  FORMATO_DATA_HORA     CONSTANT VARCHAR2(16) := 'DDMMYYYYHH24MISS';
  DATA_ZERADA           CONSTANT VARCHAR2(8)  := '00000000';
  DATA_HORA_ZERADA      CONSTANT VARCHAR2(14) := '00000000000000';

  V_CONTEUDO VARCHAR2(1000);
  V_TEXTO VARCHAR2(1000);
  V_NUMERICO NUMBER;
  V_DATA DATE;
  vCARACTERE CHAR(1);

  TYPE LISTA_CAMPOS is RECORD (
    CONTEUDO    VARCHAR2(1000)
    );

  TYPE LISTA_CAMPOS_SERVIDOR IS VARRAY(10000) OF LISTA_CAMPOS;

  REG LISTA_CAMPOS_SERVIDOR;

  vCONTEUDO VARCHAR2(1000);
  vCAMPO VARCHAR2(1000);

   vCONTADOR NUMBER;
   vTAM_LINHA_PERCORRIDO NUMBER;
   vTAM_REGISTRO  NUMBER;
   vTAM_INTERFACE NUMBER;

   vTAM_LINHA     NUMBER;
   vTAM_CAMPO     NUMBER;

   vCAMPO_PODE_SER_NULO BOOLEAN;
   
   vPARTE_INTEIRA VARCHAR2(100);
   vPARTE_DECIMAL VARCHAR2(100);
   vSEPARADOR_DECIMAL CHAR(1);   

PROCEDURE GRAVA_LOG(TipoLog IN NUMBER, CodigoLog IN VARCHAR2, DetalheLog IN VARCHAR2) AS
BEGIN

REG_LOG.TIPO_LOG := TipoLog;
REG_LOG.CODIGO_LOG := CodigoLog;
REG_LOG.DETALHE_LOG := DetalheLog;

vLISTA_LOG.Extend;
vLISTA_LOG(vLISTA_LOG.count) := REG_LOG;
END;

PROCEDURE IMPRIME_CAMPOS(I_S INTERFACE_SOFTWARE) AS
BEGIN
  dbms_output.put_line('*** IMPRESSÃO REGISTRO ***');
  dbms_output.put_line(RPAD('CAMPO', 30, ' ') || RPAD('VALOR', 1000, ' '));

  FOR i in 1..I_S.COUNT() LOOP
      dbms_output.put_line(RPAD(I_S(i).CAMPO, 30, ' ') || RPAD(I_S(i).VALOR, 1000, ' '));
  END LOOP;

END;

begin

    REG := LISTA_CAMPOS_SERVIDOR();
    vLISTA_LOG := LISTA_LOG();
    REG_LOG := LOG_PROCESSAMENTO(null, null, null,null);
    vRETORNO := RETORNO_PROCESSAMENTO(null,null,null);

    vCONTEUDO := LinhaTexto;
    vTAM_LINHA := LENGTH(vCONTEUDO);
    --dbms_output.put_line('LinhaTexto = ' || LinhaTexto);

    -- inicializando I_S, objeto com a interface em que a linha será validada
    I_S := pIS_ARQUIVO.INTERFACE;
    
    --dbms_output.put_line('pIS_ARQUIVO.CARACTERE_SEPARADOR = ' || pIS_ARQUIVO.CARACTERE_SEPARADOR);
    --dbms_output.put_line('pIS_ARQUIVO.TAMANHO_MAXIMO_LINHA = ' || pIS_ARQUIVO.TAMANHO_MAXIMO_LINHA);
    --dbms_output.put_line('pIS_ARQUIVO.QTDE_CAMPOS = ' || pIS_ARQUIVO.QTDE_CAMPOS);
    
    IF pIS_ARQUIVO.CARACTERE_SEPARADOR IS NOT NULL THEN
       BEGIN

       vCONTADOR := 1;
        FOR i in 1..vTAM_LINHA LOOP
        vCARACTERE := SUBSTR(vCONTEUDO,i,1);

        IF vCARACTERE = pIS_ARQUIVO.CARACTERE_SEPARADOR THEN
           REG.EXTEND(1);
           REG(vCONTADOR).CONTEUDO := vCAMPO;
           vCAMPO := '';
           vCONTADOR := vCONTADOR + 1;
        ELSE
            vCAMPO := vCAMPO || vCARACTERE;
        END IF;

        END LOOP;

        REG.EXTEND(1);
        REG(vCONTADOR).CONTEUDO := vCAMPO;
        vCAMPO := '';

        EXCEPTION
        WHEN OTHERS THEN
             raise_application_error (-20002,'ERRO AO TENTAR FAZER PARSER DE DETERMINADA LINHA DO ARQUIVO. ' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
        END;
    ELSE


    IF (vTAM_LINHA <> pIS_ARQUIVO.TAMANHO_MAXIMO_LINHA) THEN
       GRAVA_LOG(TIPO_LOG_ERRO, LOG_TAMANHO_LINHA_INVALIDO, 'VALOR_ESPERADO: ' || pIS_ARQUIVO.TAMANHO_MAXIMO_LINHA || ' VALOR_OBTIDO: ' || vTAM_LINHA);
    END IF;

    vCONTADOR := 1;
    vTAM_LINHA_PERCORRIDO := 1;
    FOR i in 1..vTAM_LINHA LOOP
        IF (vTAM_LINHA_PERCORRIDO >= vTAM_LINHA) OR (vTAM_LINHA_PERCORRIDO >= pIS_ARQUIVO.TAMANHO_MAXIMO_LINHA) THEN
           EXIT;
        END IF;

        vCAMPO := SUBSTR(vCONTEUDO,vTAM_LINHA_PERCORRIDO,I_S(vCONTADOR).TAMANHO_IS);

        REG.EXTEND(1);
        REG(vCONTADOR).CONTEUDO := vCAMPO;
        --dbms_output.put_line('POSICAO' || LPAD(vTAM_LINHA_PERCORRIDO, 3, '0') || ' - ' || LPAD((vTAM_LINHA_PERCORRIDO + I_S(vCONTADOR).TAMANHO_IS) - 1, 3, '0') || 'vCAMPO = ' || vCAMPO);

        vTAM_LINHA_PERCORRIDO := vTAM_LINHA_PERCORRIDO + I_S(vCONTADOR).TAMANHO_IS;
        vCAMPO := '';
        vCONTADOR := vCONTADOR + 1;

    END LOOP;
    END IF;

   vTAM_REGISTRO := REG.COUNT();
   vTAM_INTERFACE := I_S.COUNT();


   IF (vTAM_INTERFACE <> vTAM_REGISTRO) THEN
      GRAVA_LOG(TIPO_LOG_ERRO, LOG_QUANTIDADE_CAMPOS_INVALIDA, 'VALOR_ESPERADO: ' || vTAM_INTERFACE || ' VALOR_OBTIDO: ' || vTAM_REGISTRO);
   END IF;


   IF (vTAM_REGISTRO >= vTAM_INTERFACE) THEN
     FOR i in 1..vTAM_INTERFACE LOOP

         I_S(i).VALOR := REG(i).CONTEUDO;
     END LOOP;
   ELSE
     FOR i in 1..vTAM_REGISTRO LOOP

         I_S(i).VALOR := REG(i).CONTEUDO;
     END LOOP;
   END IF;

   --IMPRIME_CAMPOS(I_S);

FOR i in 1..vTAM_INTERFACE LOOP

      V_TEXTO := NULL;
      V_NUMERICO := NULL;
      V_DATA := NULL;

      --V_CONTEUDO := I_S(i).VALOR;
      V_CONTEUDO := TRIM(I_S(i).VALOR);
      vCAMPO_PODE_SER_NULO := I_S(i).NULO = 1;
      vTAM_CAMPO := LENGTH(TRIM(I_S(i).VALOR));

      IF (vTAM_CAMPO IS NULL AND NOT vCAMPO_PODE_SER_NULO) THEN
         GRAVA_LOG(TIPO_LOG_ERRO, LOG_CAMPO_NULO, I_S(i).CAMPO);
      ELSIF (vTAM_CAMPO IS NOT NULL) THEN

          IF (vTAM_CAMPO > (I_S(i).TAMANHO_IS)) THEN

          GRAVA_LOG(TIPO_LOG_ERRO, LOG_TAMANHO_CAMPO_INVALIDO, I_S(i).CAMPO  || ' VALOR_ESPERADO =  ' || I_S(i).TAMANHO_IS || ' VALOR_OBTIDO = ' || vTAM_CAMPO);

          END IF;

          IF (I_S(i).TIPO_IS = TIPO_NUMERICO) THEN

             BEGIN
             V_NUMERICO := TO_NUMBER(V_CONTEUDO);
             V_TEXTO := V_CONTEUDO;

             IF (I_S(i).TAMANHO_IS <> I_S(i).TAMANHO) THEN
                V_TEXTO := LPAD(V_NUMERICO, I_S(i).TAMANHO, '0');
                /*
                dbms_output.put_line('V_CONTEUDO = ' || V_CONTEUDO);
                dbms_output.put_line('V_NUMERICO = ' || V_NUMERICO);
                dbms_output.put_line('V_TEXTO    = ' || V_TEXTO);
                */
             END IF;
             --dbms_output.put_line('V_TEXTO    = ' || V_TEXTO);
             IF (I_S(i).TIPO_IS <> I_S(i).TIPO) THEN
                V_TEXTO := SUBSTR(V_TEXTO, 1, LENGTH(V_TEXTO)-2) || '.' || SUBSTR(V_TEXTO, LENGTH(V_TEXTO)-1);
                IF I_S(i).TIPO = TIPO_VALOR THEN
                   V_NUMERICO := TO_NUMBER(V_TEXTO);
                   V_TEXTO := LPAD(V_NUMERICO, I_S(i).TAMANHO, '0');
                END IF;
                /*
                dbms_output.put_line('@@@@@@@@');
                dbms_output.put_line('V_CONTEUDO = ' || V_CONTEUDO);
                dbms_output.put_line('V_NUMERICO = ' || V_NUMERICO);
                dbms_output.put_line('V_TEXTO    = ' || V_TEXTO);
                dbms_output.put_line('@@@@@@@@');
                */
             END IF;

             --ATRIBUI_DADO(i,V_TEXTO, V_NUMERICO, V_DATA);
             EXCEPTION
             WHEN OTHERS THEN

             GRAVA_LOG(TIPO_LOG_ERRO, LOG_NUMERO_INVALIDO, I_S(i).CAMPO || ' VALOR: ' || '|' || V_CONTEUDO  || '|');

             END;
          END IF;

          IF (I_S(i).TIPO_IS = TIPO_VALOR_SEPARADOR_DECIMAL) THEN

             vPARTE_INTEIRA := SUBSTR(V_CONTEUDO, 1, LENGTH(V_CONTEUDO)-3);     
             vPARTE_DECIMAL := SUBSTR(V_CONTEUDO, LENGTH(V_CONTEUDO)-1);
             vSEPARADOR_DECIMAL := SUBSTR(V_CONTEUDO, LENGTH(V_CONTEUDO)-2,1);      
             
             IF vSEPARADOR_DECIMAL IS NULL THEN
                GRAVA_LOG(TIPO_LOG_ERRO, LOG_NUMERO_INVALIDO, I_S(i).CAMPO || ' VALOR: ' || '|' || V_CONTEUDO  || '|' || 'NAO POSSUI SEPARADOR DE DECIMAL');                
             ELSE
                 IF vSEPARADOR_DECIMAL <> ',' THEN
                    GRAVA_LOG(TIPO_LOG_ERRO, LOG_NUMERO_INVALIDO, I_S(i).CAMPO || ' VALOR: ' || '|' || V_CONTEUDO  || '|' || 'SEPARADOR DE DECIMAL INVALIDO');                 
                 END IF;
             END IF;       
             
             BEGIN
             V_NUMERICO := TO_NUMBER(vPARTE_INTEIRA);
             V_NUMERICO := TO_NUMBER(vPARTE_DECIMAL);
             V_NUMERICO := TO_NUMBER(vPARTE_INTEIRA||'.'||vPARTE_DECIMAL);
             V_TEXTO := LPAD(V_NUMERICO, I_S(i).TAMANHO, '0');

             EXCEPTION
             WHEN OTHERS THEN

             GRAVA_LOG(TIPO_LOG_ERRO, LOG_NUMERO_INVALIDO, I_S(i).CAMPO || ' VALOR: ' || '|' || V_CONTEUDO  || '|');

             END;
          END IF;
          
          IF (I_S(i).TIPO_IS = TIPO_DATA) THEN

             BEGIN
             V_DATA := TO_DATE(V_CONTEUDO, FORMATO_DATA);
             --ATRIBUI_DADO(i,V_TEXTO, V_NUMERICO, V_DATA);
             EXCEPTION
             WHEN OTHERS THEN
                  IF (NOT vCAMPO_PODE_SER_NULO) THEN
                     GRAVA_LOG(TIPO_LOG_ERRO, LOG_DATA_INVALIDA, I_S(i).CAMPO || ' VALOR: ' || '|' || V_CONTEUDO  || '|');
                  ELSIF vCAMPO_PODE_SER_NULO AND V_CONTEUDO <> DATA_ZERADA THEN
                     GRAVA_LOG(TIPO_LOG_ERRO, LOG_DATA_INVALIDA, I_S(i).CAMPO || ' VALOR: ' || '|' || V_CONTEUDO  || '|');
                  END IF;
             END;


          END IF;

          IF (I_S(i).TIPO_IS = TIPO_DATA_HORA) THEN

             BEGIN
             V_DATA := TO_DATE(V_CONTEUDO, FORMATO_DATA_HORA);
             --ATRIBUI_DADO(i,V_TEXTO, V_NUMERICO, V_DATA);
             EXCEPTION
             WHEN OTHERS THEN

                  IF (NOT vCAMPO_PODE_SER_NULO) THEN
                     GRAVA_LOG(TIPO_LOG_ERRO, LOG_DATA_INVALIDA, I_S(i).CAMPO || ' VALOR: ' || '|' || V_CONTEUDO  || '|');
                  ELSIF vCAMPO_PODE_SER_NULO AND V_CONTEUDO <> DATA_HORA_ZERADA THEN
                     GRAVA_LOG(TIPO_LOG_ERRO, LOG_DATA_INVALIDA, I_S(i).CAMPO || ' VALOR: ' || '|' || V_CONTEUDO  || '|');
                  END IF;

             END;

         END IF;
         IF (I_S(i).TIPO_IS = TIPO_ALFANUMERICO) THEN

             BEGIN
             V_TEXTO := V_CONTEUDO;

             IF (I_S(i).TAMANHO_IS > I_S(i).TAMANHO) THEN
                V_TEXTO := SUBSTR(V_TEXTO, ((LENGTH(V_TEXTO) - I_S(i).TAMANHO)+1));
                /*
                dbms_output.put_line('V_CONTEUDO = ' || V_CONTEUDO);
                dbms_output.put_line('V_NUMERICO = ' || V_NUMERICO);
                dbms_output.put_line('V_TEXTO    = ' || V_TEXTO);
                */
             END IF;
             --dbms_output.put_line('INICIO - @@@@@@@@@@@@@V_CONTEUDO = ' || V_CONTEUDO);
             IF (I_S(i).TIPO_IS <> I_S(i).TIPO) THEN
                IF I_S(i).TIPO = TIPO_NUMERICO THEN

                V_TEXTO := LPAD(V_TEXTO, I_S(i).TAMANHO, '0');
                END IF;

                --dbms_output.put_line('V_CONTEUDO = ' || V_CONTEUDO);
                --dbms_output.put_line('V_NUMERICO = ' || V_NUMERICO);
                --dbms_output.put_line('V_TEXTO    = ' || V_TEXTO);

             END IF;
             --dbms_output.put_line('FIM - @@@@@@@@@@@@@V_CONTEUDO = ' || V_CONTEUDO);
             --ATRIBUI_DADO(i,V_TEXTO, V_NUMERICO, V_DATA);
             EXCEPTION
             WHEN OTHERS THEN

             GRAVA_LOG(TIPO_LOG_ERRO, LOG_TEXTO_INVALIDO, I_S(i).CAMPO || ' VALOR: ' || '|' || V_CONTEUDO  || '|');

             END;

         END IF;

         IF (I_S(i).TIPO_IS = TIPO_SIM_NAO) THEN

             BEGIN
               IF V_CONTEUDO IN ('S','N') THEN
                  V_TEXTO := V_CONTEUDO;
                       --ATRIBUI_DADO(i,V_TEXTO, V_NUMERICO, V_DATA);
               ELSE
                   GRAVA_LOG(TIPO_LOG_ERRO, LOG_TEXTO_INVALIDO, I_S(i).CAMPO || ' VALOR: ' || '|' || V_CONTEUDO  || '|');
               END IF;
             EXCEPTION
             WHEN OTHERS THEN

             GRAVA_LOG(TIPO_LOG_ERRO, LOG_TEXTO_INVALIDO, I_S(i).CAMPO || ' VALOR: ' || '|' || V_CONTEUDO  || '|');

             END;

         END IF;

      END IF;
    END LOOP;
    --IMPRIME_CAMPOS(I_S);
    --IMPRIME_REGISTRO(REGISTRO_MOVIMENTO);

        vRETORNO.CODIGO_RETORNO := 0;
        vRETORNO.DESCRICAO_RETORNO := 'PROCESSAMENTO OK';
        vRETORNO.LISTA_LOG_RETORNO := vLISTA_LOG;

  RETURN vRETORNO;
end;