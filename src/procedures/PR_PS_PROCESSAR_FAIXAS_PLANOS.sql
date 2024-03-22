
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_PS_PROCESSAR_FAIXAS_PLANOS" (POPERACAO IN CHAR, PANO_MES_REFERENCIA IN DATE, pTIPO_REGISTRO IN VARCHAR2, PLISTA_VALORES IN VARCHAR2, PLISTA_VALORES_COMPLEMENTAR IN VARCHAR2 DEFAULT NULL)
as

l_string VARCHAR2(4000);
delimitador CHAR(1):=';';
cont number;
VALIDA_LISTA NUMBER;
NOME_VALIDO NUMBER;
VALIDADOR NUMBER;
i_NOME NUMBER;
l_lista_faixas_planos lista:= lista ();
/*l_dados_usuarios lista:= lista ();*/
l_dados_grupos lista:= lista ();

ListaDeFaixasPlanos VARCHAR2(4000);
/*
ListaDeGrupos VARCHAR2(4000);
vposicao_atual INTEGER;
vposicao_proximo INTEGER;
vcont_i NUMBER;
vcont_j NUMBER;
v_expressao VARCHAR2(4000);
*/

vlimite_inferior NUMBER(15,2);
vlimite_superior NUMBER(15,2);
vlimite_superior_anterior NUMBER(15,2);

REG_FAIXA_ETARIA RHPBH_PS_FAIXA_ETARIA%ROWTYPE;
REG_FAIXA_SALARIAL RHPBH_PS_FAIXA_SALARIAL%ROWTYPE;
REG_PLANO RHPBH_PS_PLANOS%ROWTYPE;
vQTDE_LINHAS_AFETADAS NUMBER;
vANO_MES_REFERENCIA DATE;
vCONTADOR NUMBER;
vCONTADOR_PLANOS NUMBER;
vCONTADOR_FAIXAS_SALARIAIS NUMBER;
vCONTADOR_FAIXAS_ETARIAS NUMBER;

vCARACTERE CHAR(1);
vOPERACAO CHAR(1);
vTIPO_REGISTRO VARCHAR2(30);

C_OPERACAO_INCLUSAO CHAR(1) := 'I';
C_OPERACAO_EXCLUSAO CHAR(1) := 'E';
C_TIPO_REGISTRO_PLANO VARCHAR2(30) := 'PLANO';
C_TIPO_REGISTRO_FAIXA_SALARIAL VARCHAR2(30) := 'FAIXA_SALARIAL';
C_TIPO_REGISTRO_FAIXA_ETARIA VARCHAR2(30) := 'FAIXA_ETARIA';


FUNCTION ORDENA_LISTA(plista LISTA) return LISTA as
j INTEGER;
aux NUMBER(15,2);
listaRetorno LISTA;
BEGIN
  listaRetorno := pLISTA;

  FOR i IN 2..listaRetorno.count
      LOOP
        aux := TO_NUMBER(listaRetorno(i));
        j := i-1;
        WHILE ((j >= 1) AND (aux < TO_NUMBER(listaRetorno(j))))
             loop
               listaRetorno(j + 1) := listaRetorno(j);
               j:=j-1;
             end loop;
             listaRetorno(j + 1) := aux;
      END LOOP;

      return listaRetorno;

END;

FUNCTION VALIDA_LISTA_INTEIRO(plista LISTA) return LISTA as
j INTEGER;
aux INTEGER;
listaRetorno LISTA;
vREGISTRO_EXISTENTE BOOLEAN;
BEGIN
  listaRetorno := LISTA();

  FOR i IN 1..plista.count
  LOOP

      IF plista(i) IS NOT NULL THEN
          vREGISTRO_EXISTENTE := FALSE;
          for j in 1..listaRetorno.count
          loop

               IF plista(i) = listaRetorno(j) THEN
                  vREGISTRO_EXISTENTE := TRUE;
                  EXIT;
               END IF;

          end loop;

          IF NOT vREGISTRO_EXISTENTE THEN
             BEGIN
             /*
               aux := TO_NUMBER(plista(i));

               listaRetorno.Extend;
               listaRetorno(listaRetorno.count) := plista(i);
               */
                   aux := TO_NUMBER(REPLACE(plista(i),',','.'));

                   listaRetorno.Extend;
                   listaRetorno(listaRetorno.count) := REPLACE(plista(i),',','.');

             EXCEPTION
             WHEN INVALID_NUMBER THEN

                 BEGIN
                   aux := TO_NUMBER(REPLACE(plista(i),',','.'));

                   listaRetorno.Extend;
                   listaRetorno(listaRetorno.count) := REPLACE(plista(i),',','.');

                 EXCEPTION
                 WHEN OTHERS THEN
                   --dbms_output.put_line('ERRO SEGUNDA TENTATIVA = ' || plista(i) || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
                   raise_application_error (-20002,'[VALIDACAO_REGRAS] - OCORREU UMA EXCECAO AO TENTAR PROCESSAR A LISTA DE FAIXAS E PLANOS. ENTRE EM CONTATO COM A EQUIPE DE SUPORTE DA PBH.' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
                 END;

             WHEN OTHERS THEN
               --dbms_output.put_line('ERRO PRIMEIRA TENTATIVA = ' || plista(i) || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
               raise_application_error (-20002,'[VALIDACAO_REGRAS] - OCORREU UMA EXCECAO AO TENTAR PROCESSAR A LISTA DE FAIXAS E PLANOS. ENTRE EM CONTATO COM A EQUIPE DE SUPORTE DA PBH.' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
             END;

          END IF;
      END IF;
  END LOOP;

  return listaRetorno;

END;

begin


    -- Verifica se a operacao foi informada e se e valida
    IF POPERACAO IS NULL THEN
       raise_application_error (-20001,'OPERACAO NAO INFORMADA.');
    ELSE
       vOPERACAO := UPPER(POPERACAO);
    END IF;

    IF vOPERACAO NOT IN (C_OPERACAO_INCLUSAO,C_OPERACAO_EXCLUSAO) THEN
      raise_application_error (-20001,'OPERACAO INVALIDA.');
    END IF;


    -- Verifica se a data de referência foi informada
    IF PANO_MES_REFERENCIA IS NULL THEN
      raise_application_error (-20001,'ANO_MES_REFERENCIA NAO INFORMADO.');
    END IF;

    -- Verifica se o tipo de registro foi informado
    IF PTIPO_REGISTRO IS NULL THEN
        raise_application_error (-20001,'TIPO_REGISTRO NAO INFORMADO.');
    ELSE
        vTIPO_REGISTRO := UPPER(PTIPO_REGISTRO);
    END IF;

    -- Verifica se o tipo de registro informado e valida
    IF vTIPO_REGISTRO NOT IN (C_TIPO_REGISTRO_PLANO,C_TIPO_REGISTRO_FAIXA_SALARIAL,C_TIPO_REGISTRO_FAIXA_ETARIA) THEN
      raise_application_error (-20001,'TIPO_REGISTRO INVALIDO.');
    END IF;

---Raise_application_error (-20001,REGEXP_COUNT(PLISTA_VALORES,','));
    vANO_MES_REFERENCIA := TRUNC(PANO_MES_REFERENCIA);
    VALIDA_LISTA:=1;
  --  raise_application_error (-20001,LPAD(regexp_substr(REPLACE(PLISTA_VALORES,',,',', ,'), '[^,]+', 1, VALIDA_LISTA),15,0));
    vCONTADOR_PLANOS := 0;
    vCONTADOR_FAIXAS_SALARIAIS := 0;
    vCONTADOR_FAIXAS_ETARIAS := 0;
    CASE WHEN vTIPO_REGISTRO = C_TIPO_REGISTRO_PLANO THEN
            -- planos
            BEGIN 
            FOR C1 IN 1..REGEXP_COUNT(PLISTA_VALORES,',')LOOP
             select COUNT(1) INTO vCONTADOR_PLANOS
                   from RHPBH_PS_PLANOS
                  where ANO_MES_REFERENCIA = vANO_MES_REFERENCIA
                  AND CODIGO =LPAD(regexp_substr(REPLACE(PLISTA_VALORES,',,',', ,'), '[^,]+', 1, VALIDA_LISTA),15,0);
        --       raise_application_error (-20001,LPAD(regexp_substr(REPLACE(PLISTA_VALORES,',,',', ,'), '[^,]+', 1, VALIDA_LISTA),15,0));
                
                  
               END LOOP ;
            EXCEPTION
            WHEN OTHERS THEN
                 dbms_output.put_line('ERRO AO TENTAR RECUPERAR PLANOS EXISTENTES NA DATA DE REFERENCIA.' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
            END;

            IF vOPERACAO = C_OPERACAO_INCLUSAO and vCONTADOR_PLANOS > 0  THEN
               raise_application_error (-20001,'JA EXISTE DEFINICAO DE PLANOS PARA A DATA DE REFERENCIA INFORMADA.'||'PLANO:'||LPAD(regexp_substr(REPLACE(PLISTA_VALORES,',,',', ,'), '[^,]+', 1, VALIDA_LISTA),15,0));
            END IF;

            IF vOPERACAO = C_OPERACAO_EXCLUSAO and vCONTADOR_PLANOS = 0  THEN
               raise_application_error (-20001,'NAO EXISTE DEFINICAO DE PLANOS PARA A DATA DE REFERENCIA INFORMADA.');
            END IF;
    VALIDA_LISTA:=VALIDA_LISTA+1;
        WHEN vTIPO_REGISTRO = C_TIPO_REGISTRO_FAIXA_SALARIAL THEN
            -- faixa_salarial
            BEGIN
                 select COUNT(1)
                   into vCONTADOR_FAIXAS_SALARIAIS
                   from RHPBH_PS_FAIXA_SALARIAL
                  where ANO_MES_REFERENCIA = vANO_MES_REFERENCIA;
            EXCEPTION
            WHEN OTHERS THEN
                 --dbms_output.put_line('ERRO AO TENTAR RECUPERAR FAIXAS SALARIAIS EXISTENTES NA DATA DE REFERENCIA.' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
                 raise_application_error (-20001,'ERRO AO TENTAR RECUPERAR FAIXAS SALARIAIS EXISTENTES NA DATA DE REFERENCIA.' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
            END;

            IF vOPERACAO = C_OPERACAO_INCLUSAO and vCONTADOR_FAIXAS_SALARIAIS > 0  THEN
               raise_application_error (-20001,'JA EXISTE DEFINICAO DE FAIXAS SALARIAIS PARA A DATA DE REFERENCIA INFORMADA.');
            END IF;

            IF vOPERACAO = C_OPERACAO_EXCLUSAO and vCONTADOR_FAIXAS_SALARIAIS = 0  THEN
               raise_application_error (-20001,'NAO EXISTE DEFINICAO DE FAIXAS SALARIAIS PARA A DATA DE REFERENCIA INFORMADA.');
            END IF;

        WHEN vTIPO_REGISTRO = C_TIPO_REGISTRO_FAIXA_ETARIA THEN
            -- faixa_etaria
            BEGIN
                 select COUNT(1)
                   into vCONTADOR_FAIXAS_ETARIAS
                   from RHPBH_PS_FAIXA_ETARIA
                  where ANO_MES_REFERENCIA = vANO_MES_REFERENCIA;

            EXCEPTION
            WHEN OTHERS THEN
                 --dbms_output.put_line('ERRO AO TENTAR RECUPERAR FAIXAS ETARIAS EXISTENTES NA DATA DE REFERENCIA.' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
                 raise_application_error (-20001,'ERRO AO TENTAR RECUPERAR FAIXAS ETARIAS EXISTENTES NA DATA DE REFERENCIA.' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
            END;

            IF vOPERACAO = C_OPERACAO_INCLUSAO and vCONTADOR_FAIXAS_ETARIAS > 0  THEN
               raise_application_error (-20001,'JA EXISTE DEFINICAO DE FAIXAS ETARIAS PARA A DATA DE REFERENCIA INFORMADA.');
            END IF;

            IF vOPERACAO = C_OPERACAO_EXCLUSAO and vCONTADOR_FAIXAS_ETARIAS = 0  THEN
               raise_application_error (-20001,'NAO EXISTE DEFINICAO DE FAIXAS ETARIAS PARA A DATA DE REFERENCIA INFORMADA.');
            END IF;

        ELSE
        NULL;
        --dbms_output.put_line('ERRO AO TENTAR RECUPERAR FAIXAS E PLANOS EXISTENTES NA DATA DE REFERENCIA.' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
     END CASE;

     IF vOPERACAO = C_OPERACAO_EXCLUSAO   THEN
        vCONTADOR := 0;
        IF vTIPO_REGISTRO = C_TIPO_REGISTRO_PLANO THEN
           BEGIN
               select COUNT(1) into vCONTADOR
                 from RHPBH_PS_VALORES_PLANO_SAUDE
                where ANO_MES_REF_PLANO = vANO_MES_REFERENCIA;

           EXCEPTION
           WHEN OTHERS THEN
                vCONTADOR := 0;
           END;

          IF vCONTADOR > 0 THEN
             raise_application_error (-20001,'EXCLUSAO DE PLANO NAO PERMITIDA PARA O ANO MES REFERENCIA INFORMADO. EXISTE TABELA DE VALORES USANDO ESTA CONFIGURACAO DE PLANOS.');

          ELSE
             BEGIN
                  DELETE FROM RHPBH_PS_PLANOS where ANO_MES_REFERENCIA = vANO_MES_REFERENCIA;
                  commit;
             EXCEPTION
             WHEN OTHERS THEN
                  raise_application_error (-20001,'EXCECAO AO TENTAR EXCLUIR. ' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
             END;
          END IF;


        END IF;

        IF vTIPO_REGISTRO = C_TIPO_REGISTRO_FAIXA_SALARIAL THEN

           BEGIN
               select COUNT(1) into vCONTADOR
                 from RHPBH_PS_VALORES_PLANO_SAUDE
                where ANO_MES_REF_FAIXA_SALARIAL = vANO_MES_REFERENCIA;

           EXCEPTION
           WHEN OTHERS THEN
                vCONTADOR := 0;
           END;

          IF vCONTADOR > 0 THEN
             raise_application_error (-20001,'EXCLUSAO DE FAIXA_SALARIAL NAO PERMITIDA PARA O ANO MES REFERENCIA INFORMADO. EXISTE TABELA DE VALORES USANDO ESTA CONFIGURACAO DE FAIXAS SALARIAIS.');

          ELSE
             BEGIN
                  DELETE FROM RHPBH_PS_FAIXA_SALARIAL where ANO_MES_REFERENCIA = vANO_MES_REFERENCIA;
                  commit;
             EXCEPTION
             WHEN OTHERS THEN
                  raise_application_error (-20001,'EXCECAO AO TENTAR EXCLUIR. ' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
             END;
          END IF;

        END IF;

        IF vTIPO_REGISTRO = C_TIPO_REGISTRO_FAIXA_ETARIA THEN

           BEGIN
               select COUNT(1) into vCONTADOR
                 from RHPBH_PS_VALORES_PLANO_SAUDE
                where ANO_MES_REF_FAIXA_ETARIA = vANO_MES_REFERENCIA;

           EXCEPTION
           WHEN OTHERS THEN
                vCONTADOR := 0;
           END;

          IF vCONTADOR > 0 THEN
             raise_application_error (-20001,'EXCLUSAO DE FAIXA ETARIA NAO PERMITIDA PARA O ANO MES REFERENCIA INFORMADO. EXISTE TABELA DE VALORES USANDO ESTA CONFIGURACAO DE FAIXAS ETARIAS.');

          ELSE
             BEGIN
                  DELETE FROM RHPBH_PS_FAIXA_ETARIA where ANO_MES_REFERENCIA = vANO_MES_REFERENCIA;
                  commit;
             EXCEPTION
             WHEN OTHERS THEN
                  raise_application_error (-20001,'EXCECAO AO TENTAR EXCLUIR. ' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
             END;
          END IF;


        END IF;


     ELSIF vOPERACAO = C_OPERACAO_INCLUSAO THEN
      --dbms_output.put_line('passei aqui 1');
         BEGIN
         for i in 1..LENGTH(PLISTA_VALORES)
         loop
             vCARACTERE := SUBSTR(PLISTA_VALORES,i,1);
             IF INSTR('1234567890.,',vCARACTERE) <=0 THEN
                raise_application_error (-20001,'VALORES INVALIDOS. PERMITIDO APENAS CARACTERES VIRGULA(,), PONTO(.) E DIGITOS DE ZERO(0) A NOVE(9)');
                EXIT;
             END IF;
         end loop;


         ListaDeFaixasPlanos := PLISTA_VALORES;
         ListaDeFaixasPlanos := REPLACE(ListaDeFaixasPlanos,',',delimitador);
         ListaDeFaixasPlanos := REPLACE(ListaDeFaixasPlanos,'.',',');
         ListaDeFaixasPlanos := ListaDeFaixasPlanos || delimitador;-- || PLISTA_VALORES_COMPLEMENTAR;

         /* CAPTURANDO LISTA DE FAIXAS E VALORES */
         l_string := ListaDeFaixasPlanos || delimitador;

          LOOP EXIT WHEN l_string IS NULL;
               cont := INSTR (l_string, delimitador);

               l_lista_faixas_planos.EXTEND;
               l_lista_faixas_planos (l_lista_faixas_planos.COUNT) := LTRIM (RTRIM (SUBSTR (l_string, 1, cont - 1)));


               l_string := SUBSTR (l_string, cont + 1);
          END LOOP;

          /* IMPRIMINDO LISTA */
          /*
          FOR Lcntr IN 1..l_lista_faixas_planos.count
          LOOP
             dbms_output.put_line(l_lista_faixas_planos(Lcntr));
          END LOOP;
          */
           l_lista_faixas_planos := VALIDA_LISTA_INTEIRO(l_lista_faixas_planos);

           IF vTIPO_REGISTRO in ( C_TIPO_REGISTRO_FAIXA_SALARIAL , C_TIPO_REGISTRO_FAIXA_ETARIA) THEN
              l_dados_grupos := ORDENA_LISTA(l_lista_faixas_planos);
           ELSE
              l_dados_grupos := l_lista_faixas_planos;
           END IF;

          EXCEPTION
          WHEN OTHERS THEN
               raise_application_error (-20002,'[VALIDACAO_REGRAS] - OCORREU UMA EXCECAO AO TENTAR FAZER O PARSER DA LSITA DE FAIXAS E PLANOS. ENTRE EM CONTATO COM A EQUIPE DE SUPORTE DA PBH.' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
          END;

          --dbms_output.put_line('passei aqui 2');
          IF vTIPO_REGISTRO = C_TIPO_REGISTRO_FAIXA_ETARIA THEN
            /* IMPRIMINDO LISTA DE USUARIOS */
            FOR i IN 1..l_dados_grupos.count + 1
            LOOP
               --dbms_output.put_line(l_dados_grupos(i));

               IF (i = 1) THEN
                  vlimite_inferior := 0;
               ELSE
                  vlimite_inferior := vlimite_superior_anterior + 1;
               END IF;

               IF vlimite_superior_anterior = l_dados_grupos(l_dados_grupos.count) THEN
                  vlimite_superior := 99;
               ELSE
                  vlimite_superior := l_dados_grupos(i);
               END IF;



               REG_FAIXA_ETARIA.ANO_MES_REFERENCIA := vANO_MES_REFERENCIA;
               REG_FAIXA_ETARIA.IDENTIFICADOR := 'faixa_etaria_' || i;
               REG_FAIXA_ETARIA.LIMITE_INFERIOR := vlimite_inferior;
               REG_FAIXA_ETARIA.LIMITE_SUPERIOR := vlimite_superior;

               IF vlimite_superior_anterior = l_dados_grupos(l_dados_grupos.count) THEN
                  REG_FAIXA_ETARIA.DESCRICAO := LPAD(vlimite_inferior,'2','0') || ' ou mais';
               ELSE
                  REG_FAIXA_ETARIA.DESCRICAO := LPAD(vlimite_inferior,'2','0') || ' a ' || LPAD(vlimite_superior,'2','0') || ' anos';
               END IF;

               vlimite_superior_anterior := vlimite_superior;

               --dbms_output.put_line('vlimite_inferior = ' || vlimite_inferior || ' vlimite_superior = ' || vlimite_superior);
              -- dbms_output.put_line(REG_FAIXA_ETARIA.DESCRICAO);

            BEGIN
                 Insert into RHPBH_PS_FAIXA_ETARIA values REG_FAIXA_ETARIA;
                 vQTDE_LINHAS_AFETADAS := sql%rowcount;
                 commit;

            EXCEPTION
            WHEN OTHERS THEN
                 raise_application_error (-20002,'[VALIDACAO_REGRAS] - OCORREU UMA EXCECAO AO TENTAR REGISTRAR FAIXAS E PLANOS. ENTRE EM CONTATO COM A EQUIPE DE SUPORTE DA PBH.' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
            END;

            END LOOP;
          END IF;

          IF vTIPO_REGISTRO = C_TIPO_REGISTRO_FAIXA_SALARIAL THEN
            /* IMPRIMINDO LISTA DE USUARIOS */
            FOR i IN 1..l_dados_grupos.count
            LOOP
               --dbms_output.put_line('VALOR = ' || l_dados_grupos(i));

               IF (i = 1) THEN
                  vlimite_inferior := 0.01;
               ELSE
                  vlimite_inferior := vlimite_superior_anterior + 0.01;
               END IF;

               vlimite_superior := l_dados_grupos(i);
               vlimite_superior_anterior := vlimite_superior;

               REG_FAIXA_SALARIAL.ANO_MES_REFERENCIA := vANO_MES_REFERENCIA;
               REG_FAIXA_SALARIAL.IDENTIFICADOR := 'faixa_salarial_' || i;
               REG_FAIXA_SALARIAL.LIMITE_INFERIOR := vlimite_inferior;
               REG_FAIXA_SALARIAL.LIMITE_SUPERIOR := vlimite_superior;
               REG_FAIXA_SALARIAL.DESCRICAO := 'R$ ' || to_char(vlimite_inferior, 'FM999G999G990D90', 'nls_numeric_characters='',.''') || ' a R$ ' || to_char(vlimite_superior, 'FM999G999G990D90', 'nls_numeric_characters='',.''');

               --dbms_output.put_line('vlimite_inferior = ' || vlimite_inferior || ' vlimite_superior = ' || vlimite_superior);
              -- dbms_output.put_line(REG_FAIXA_SALARIAL.DESCRICAO);

            BEGIN
                 Insert into RHPBH_PS_FAIXA_SALARIAL values REG_FAIXA_SALARIAL;
                 vQTDE_LINHAS_AFETADAS := sql%rowcount;
                 commit;

            EXCEPTION
            WHEN OTHERS THEN
                 raise_application_error (-20002,'[VALIDACAO_REGRAS] - OCORREU UMA EXCECAO AO TENTAR REGISTRAR FAIXAS E PLANOS. ENTRE EM CONTATO COM A EQUIPE DE SUPORTE DA PBH.' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
            END;

            END LOOP;
          END IF;

          --dbms_output.put_line('passei aqui 3');
          IF vTIPO_REGISTRO = C_TIPO_REGISTRO_PLANO THEN
             --dbms_output.put_line('passei aqui 4');
            /* IMPRIMINDO LISTA DE USUARIOS */
            FOR Lcntr IN 1..l_dados_grupos.count
            LOOP
               select count(1) into cont from RHBENF_BENEFICIO
                where COD_TIPO_BENEFICIO in ('0005','0006')
                  and CODIGO = LPAD(TRIM(l_dados_grupos(Lcntr)),'15','0');
               IF (cont = 0) THEN
                  --dbms_output.put_line('Não existe');
                  raise_application_error (-20002,'CODIGO DE PLANO INVALIDO');
               END IF;

            END LOOP;

            --dbms_output.put_line('passei aqui 5');
            /* IMPRIMINDO LISTA DE USUARIOS */
            FOR i IN 1..l_dados_grupos.count
           
            LOOP
             NOME_VALIDO:=0;
             i_NOME:=I;
               --dbms_output.put_line('VALOR = ' || l_dados_grupos(i));

               IF (i = 1) THEN
                  vlimite_inferior := 0.01;
               ELSE
                  vlimite_inferior := vlimite_superior_anterior + 0.01;
               END IF;
                    loop
                   SELECT COUNT(1) INTO VALIDADOR FROM RHPBH_PS_PLANOS WHERE identificador='plano_' || i_NOME AND ANO_MES_REFERENCIA=vANO_MES_REFERENCIA;
                    IF VALIDADOR>=1 THEN 
                    NOME_VALIDO:=0;
                    i_NOME:=i_NOME+1;
                    ELSE
                    NOME_VALIDO:=1;
                    REG_PLANO.IDENTIFICADOR := 'plano_' || i_NOME;
                    END IF;
                    
                     EXIT WHEN NOME_VALIDO=1;
                    END LOOP;

               vlimite_superior := l_dados_grupos(i);


               --dbms_output.put_line('vlimite_inferior = ' || vlimite_inferior || ' vlimite_superior = ' || vlimite_superior);
               vlimite_superior_anterior := vlimite_superior;

               REG_PLANO.ANO_MES_REFERENCIA := vANO_MES_REFERENCIA;
              -- REG_PLANO.IDENTIFICADOR := 'plano_' || i;
               REG_PLANO.CODIGO := LPAD(TRIM(l_dados_grupos(i)),'15','0');
               REG_PLANO.DESCRICAO := '';

            BEGIN
                 Insert into RHPBH_PS_PLANOS values REG_PLANO;
                 vQTDE_LINHAS_AFETADAS := sql%rowcount;
                 commit;

            EXCEPTION
            WHEN OTHERS THEN
                 raise_application_error (-20002,'[VALIDACAO_REGRAS] - OCORREU UMA EXCECAO AO TENTAR REGISTRAR FAIXAS E PLANOS. ENTRE EM CONTATO COM A EQUIPE DE SUPORTE DA PBH.' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
            END;

            END LOOP;
          END IF;
      END IF;
end;