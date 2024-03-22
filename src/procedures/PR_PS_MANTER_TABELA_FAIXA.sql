
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_PS_MANTER_TABELA_FAIXA" (POPERACAO IN CHAR, PANO_MES_REFERENCIA IN DATE, PTIPO_REGISTRO IN VARCHAR, PREAJUSTE_VALOR IN NUMBER, PREAJUSTE_VALOR_SUBSIDIO IN NUMBER ) as

vRETORNO RETORNO_PROCESSAMENTO := RETORNO_PROCESSAMENTO(null,null,null);
REG_LOG LOG_PROCESSAMENTO;
vLISTA_LOG LISTA_LOG := LISTA_LOG(null,null,null);

  TIPO_LOG_SUCESSO      CONSTANT NUMBER := 0;
  TIPO_LOG_INFO         CONSTANT NUMBER := 2;
  TIPO_LOG_ALERTA       CONSTANT NUMBER := 2;
  TIPO_LOG_ERRO         CONSTANT NUMBER := 99;

  CATEGORIA_LOG_VALIDACAO CONSTANT NUMBER := 0;
  CATEGORIA_LOG_EXECUCAO  CONSTANT NUMBER := 1;

  vCARACTERE CHAR(1);
  vOPERACAO CHAR(1);
  vTIPO_REGISTRO VARCHAR2(30);

  C_OPERACAO_INCLUSAO CHAR(1) := 'I';
  C_OPERACAO_EXCLUSAO CHAR(1) := 'E';
  C_OPERACAO_REAJUSTE CHAR(1) := 'A';
  C_TIPO_REGISTRO_TABELA VARCHAR2(30) := 'TABELA';
  C_TIPO_REGISTRO_PLANO VARCHAR2(30) := 'PLANO';
  C_TIPO_REGISTRO_FAIXA_SALARIAL VARCHAR2(30) := 'FAIXA_SALARIAL';
  C_TIPO_REGISTRO_FAIXA_ETARIA VARCHAR2(30) := 'FAIXA_ETARIA';

  vVALORES VARCHAR2(4000);
  vREAJUSTE_MENSALIDADE NUMBER(15,4);
  vREAJUSTE_SUBSIDIO NUMBER(15,4);
  vREAJUSTE_FAIXA NUMBER(15,4);

  vCONTADOR NUMBER;
  vCONTADOR_PLANOS NUMBER;
  vCONTADOR_FAIXAS_SALARIAIS NUMBER;
  vCONTADOR_FAIXAS_ETARIAS NUMBER;

  vTIPO_ARQUIVO CHAR(4);
  vDATA_PROCESSAMENTO DATE;
  vIS_TESTE BOOLEAN;
  vSITUACAO_PROCESSAMENTO NUMBER;
  vCODIGO_EMPRESA CHAR(4);
  vTIPO_CONTRATO CHAR(4);
  vANO_MES_REFERENCIA DATE;
  vCATEGORIA_LOG NUMBER;
  vTIPO_LOG NUMBER;
  vANO_CORRENTE NUMBER;
  vANO NUMBER;

PROCEDURE REGISTRA_LOG(TipoLog IN NUMBER, Numero_linha IN NUMBER, DescricaoLog IN VARCHAR2, DetalheLog IN VARCHAR2) AS
BEGIN

REG_LOG.TIPO_LOG := TipoLog;
REG_LOG.DESCRICAO_LOG := DescricaoLog;
REG_LOG.DETALHE_LOG := DetalheLog;

vLISTA_LOG.Extend;
vLISTA_LOG(vLISTA_LOG.count) := REG_LOG;
END;

PROCEDURE GRAVA_LOG(CodigoEmpresa IN CHAR, CategoriaLog IN NUMBER, TipoLog IN NUMBER, IdArquivo IN NUMBER, Numero_linha IN NUMBER, CodigoLog IN CHAR, DetalheLog IN VARCHAR2) AS
BEGIN
     INSERT INTO RHPBH_ARQUIVO_LOG(ID_LOG, DATA_LOG, CATEGORIA, TIPO, ID_ARQUIVO, NUMERO_LINHA, CODIGO_LOG, DETALHE, CODIGO_EMPRESA)
     values (SQ_RHPBH_PS_IMPORTACAO_LOG.NEXTVAL, sysdate, CategoriaLog, TipoLog, IdArquivo, Numero_linha, CodigoLog, DetalheLog, CodigoEmpresa);
     COMMIT;
END;

begin


    -- Verifica se a operacao foi informada e se e valida
    IF POPERACAO IS NULL THEN
       raise_application_error (-20001,'OPERACAO NAO INFORMADA.');
    ELSE
       vOPERACAO := UPPER(POPERACAO);
    END IF;

    IF vOPERACAO NOT IN (C_OPERACAO_REAJUSTE,C_OPERACAO_EXCLUSAO) THEN
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
    IF vTIPO_REGISTRO NOT IN (C_TIPO_REGISTRO_TABELA,C_TIPO_REGISTRO_FAIXA_SALARIAL) THEN
      raise_application_error (-20001,'TIPO_REGISTRO INVALIDO.');
    END IF;

    IF vTIPO_REGISTRO = C_TIPO_REGISTRO_FAIXA_SALARIAL and vOPERACAO <> C_OPERACAO_REAJUSTE THEN
      raise_application_error (-20001,'OPERACAO NAO PERMITIDA PARA O TIPO DE REGISTRO INFORMADO.');
    END IF;

    -- Verifica se o percentual de reajuste foi informado
    IF vOPERACAO = C_OPERACAO_REAJUSTE and vTIPO_REGISTRO = C_TIPO_REGISTRO_TABELA and PREAJUSTE_VALOR IS NULL THEN
        raise_application_error (-20001,'PERCENTUAL DE REAJUSTE DE MENSALIDADE NAO INFORMADO.');
    END IF;

    IF vOPERACAO = C_OPERACAO_REAJUSTE and vTIPO_REGISTRO = C_TIPO_REGISTRO_TABELA and PREAJUSTE_VALOR_SUBSIDIO IS NULL THEN
        raise_application_error (-20001,'PERCENTUAL DE REAJUSTE DE SUBSIDIO NAO INFORMADO.');
    END IF;

    IF vOPERACAO = C_OPERACAO_REAJUSTE and vTIPO_REGISTRO = C_TIPO_REGISTRO_FAIXA_SALARIAL and PREAJUSTE_VALOR IS NULL THEN
        raise_application_error (-20001,'PERCENTUAL DE REAJUSTE DE FAIXA SALARIAL NAO INFORMADO.');
    END IF;

    BEGIN
         vREAJUSTE_FAIXA := TO_NUMBER(PREAJUSTE_VALOR);
         vREAJUSTE_MENSALIDADE := TO_NUMBER(PREAJUSTE_VALOR);
    EXCEPTION
    WHEN OTHERS THEN
         raise_application_error (-20001,'PERCENTUAL DE REAJUSTE INFORMADO NAO E UM NUMERO VALIDO.');
    END;

    BEGIN
         vREAJUSTE_SUBSIDIO := TO_NUMBER(PREAJUSTE_VALOR_SUBSIDIO);
    EXCEPTION
    WHEN OTHERS THEN
         raise_application_error (-20001,'PERCENTUAL DE REAJUSTE INFORMADO NAO E UM NUMERO VALIDO.');
    END;

    IF (vOPERACAO = C_OPERACAO_REAJUSTE and vTIPO_REGISTRO = C_TIPO_REGISTRO_FAIXA_SALARIAL and vREAJUSTE_FAIXA = 0) THEN
        raise_application_error (-20001,'PARA A OPERACAO INFORMADA, O PERCENTUAL DE REAJUSTE DEVE DIFERENTE DE ZERO.');
    ELSIF (vOPERACAO = C_OPERACAO_REAJUSTE and vTIPO_REGISTRO = C_TIPO_REGISTRO_FAIXA_SALARIAL and vREAJUSTE_FAIXA <> 0 and (vREAJUSTE_FAIXA not between -1 and 10)) THEN
          raise_application_error (-20001,'PERCENTUAL DE REAJUSTE INVALIDO. VALORES VALIDOS SAO [-1 , 10]*. DE MENOS UM ATE 10, EXCETO ZERO');
    END IF;

    IF (vOPERACAO = C_OPERACAO_REAJUSTE and vTIPO_REGISTRO = C_TIPO_REGISTRO_TABELA and vREAJUSTE_SUBSIDIO = 0 and vREAJUSTE_MENSALIDADE = 0) THEN
        raise_application_error (-20001,'PARA A OPERACAO INFORMADA, PELO MENOS UM PERCENTUAL DE REAJUSTE DEVE DIFERENTE DE ZERO.');
    ELSIF (vOPERACAO = C_OPERACAO_REAJUSTE and vTIPO_REGISTRO = C_TIPO_REGISTRO_TABELA and vREAJUSTE_MENSALIDADE <> 0 and (vREAJUSTE_MENSALIDADE not between -1 and 10)) THEN
          raise_application_error (-20001,'PERCENTUAL DE REAJUSTE INVALIDO. VALORES VALIDOS SAO [-1 , 10]. DE MENOS UM(-1) ATE DEZ(10), SENDO QUE PELO MENOS UM DOS REAJUSTES DEVE SER DIFERENTE DE ZERO.');
    ELSIF (vOPERACAO = C_OPERACAO_REAJUSTE and vTIPO_REGISTRO = C_TIPO_REGISTRO_TABELA and vREAJUSTE_SUBSIDIO <> 0 and (vREAJUSTE_SUBSIDIO not between -1 and 10)) THEN
          raise_application_error (-20001,'PERCENTUAL DE REAJUSTE INVALIDO. VALORES VALIDOS SAO [-1 , 10]. DE MENOS UM(-1) ATE DEZ(10), SENDO QUE PELO MENOS UM DOS REAJUSTES DEVE SER DIFERENTE DE ZERO.');
    END IF;

    vANO_MES_REFERENCIA := TRUNC(PANO_MES_REFERENCIA);
    vCONTADOR_PLANOS := 0;
    vCONTADOR_FAIXAS_SALARIAIS := 0;
    vCONTADOR_FAIXAS_ETARIAS := 0;
    CASE WHEN vTIPO_REGISTRO = C_TIPO_REGISTRO_TABELA THEN
            -- planos
            BEGIN
                 select COUNT(1)
                   into vCONTADOR_PLANOS
                   from RHPBH_PS_VALORES_PLANO_SAUDE
                  where ANO_MES_REFERENCIA = vANO_MES_REFERENCIA;
            EXCEPTION
            WHEN OTHERS THEN
                 dbms_output.put_line('ERRO AO TENTAR RECUPERAR TABELA DE VALORES DE PLANO DE SAUDE EXISTENTE NA DATA DE REFERENCIA.' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
            END;

            IF vOPERACAO = C_OPERACAO_REAJUSTE and vCONTADOR_PLANOS > 0  THEN
               raise_application_error (-20001,'JA EXISTE DEFINICAO DE TABELA DE VALORES DE PLANO DE SAUDE PARA A DATA DE REFERENCIA INFORMADA.');
            END IF;

            IF vOPERACAO = C_OPERACAO_EXCLUSAO and vCONTADOR_PLANOS = 0  THEN
               raise_application_error (-20001,'NAO EXISTE DEFINICAO DE TABELA DE VALORES DE PLANO DE SAUDE PARA A DATA DE REFERENCIA INFORMADA.');
            END IF;

        WHEN vTIPO_REGISTRO = C_TIPO_REGISTRO_FAIXA_SALARIAL THEN
            -- faixa_salarial
            BEGIN
                 select COUNT(1)
                   into vCONTADOR_FAIXAS_SALARIAIS
                   from RHPBH_PS_FAIXA_SALARIAL
                  where ANO_MES_REFERENCIA = vANO_MES_REFERENCIA;
            EXCEPTION
            WHEN OTHERS THEN
                 raise_application_error (-20001,'ERRO AO TENTAR RECUPERAR FAIXAS SALARIAIS EXISTENTES NA DATA DE REFERENCIA.' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
            END;

            IF vOPERACAO = C_OPERACAO_REAJUSTE and vCONTADOR_FAIXAS_SALARIAIS > 0  THEN
               raise_application_error (-20001,'JA EXISTE DEFINICAO DE FAIXAS SALARIAIS PARA A DATA DE REFERENCIA INFORMADA.');
            END IF;

            IF vOPERACAO = C_OPERACAO_EXCLUSAO and vCONTADOR_FAIXAS_SALARIAIS = 0  THEN
               raise_application_error (-20001,'NAO EXISTE DEFINICAO DE FAIXAS SALARIAIS PARA A DATA DE REFERENCIA INFORMADA.');
            END IF;
        ELSE
        NULL;
        --dbms_output.put_line('ERRO AO TENTAR RECUPERAR FAIXAS E PLANOS EXISTENTES NA DATA DE REFERENCIA.' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
     END CASE;

     IF vTIPO_REGISTRO = C_TIPO_REGISTRO_FAIXA_SALARIAL THEN
        begin
        for c1 in(
        select limite_superior, limite_superior*(1 +vREAJUSTE_FAIXA) as limite_superior_reajustado from RHPBH_PS_FAIXA_SALARIAL
         where ANO_MES_REFERENCIA = (select max(ANO_MES_REFERENCIA)
                                       from RHPBH_PS_FAIXA_SALARIAL
                                      where ANO_MES_REFERENCIA <= vANO_MES_REFERENCIA
                                    )
                                    order by limite_superior
        )
        loop
            vVALORES := vVALORES || ROUND(c1.LIMITE_SUPERIOR_REAJUSTADO,2) || ',';
            dbms_output.put_line(c1.LIMITE_SUPERIOR || ' - ' || c1.LIMITE_SUPERIOR_REAJUSTADO || ' - ' || ROUND(c1.LIMITE_SUPERIOR_REAJUSTADO,2));
        end loop;

        -- Cria a nova configuração de faixas salariais
        BEGIN
        PR_PS_PROCESSAR_FAIXAS_PLANOS ('I',vANO_MES_REFERENCIA, 'faixa_salarial',vVALORES);
        EXCEPTION
        WHEN OTHERS THEN
           raise_application_error (-20002,'NAO FOI POSSIVEL REALIZAR O REAJUSTE DAS FAIXAS SALARIAIS. ENTRE EM CONTATO COM A EQUIPE DE SUPORTE DA PBH.');
        END;

        -- Cria a nova taela de valores com a faixa salarial atualizada
        begin
            insert into RHPBH_PS_VALORES_PLANO_SAUDE(
                   ANO_MES_REFERENCIA,
                   ANO_MES_REF_PLANO,
                   ANO_MES_REF_FAIXA_SALARIAL,
                   ANO_MES_REF_FAIXA_ETARIA,
                   DATA_CRIACAO,
                   IDENTIFICADOR_PLANO,
                   IDENTIFICADOR_FAIXA_SALARIAL,
                   IDENTIFICADOR_FAIXA_ETARIA,
                   VALOR_MENSALIDADE,
                   VALOR_SUBSIDIO,
                   LOGIN_USUARIO,
                   DT_ULT_ALTER_USUA
            )
            (
            select vANO_MES_REFERENCIA AS ANO_MES_REFERENCIA,
                   ANO_MES_REF_PLANO,
                   vANO_MES_REFERENCIA AS ANO_MES_REF_FAIXA_SALARIAL,
                   ANO_MES_REF_FAIXA_ETARIA,
                   sysdate AS DATA_CRIACAO,
                   IDENTIFICADOR_PLANO,
                   IDENTIFICADOR_FAIXA_SALARIAL,
                   IDENTIFICADOR_FAIXA_ETARIA,
                   VALOR_MENSALIDADE,
                   VALOR_SUBSIDIO,
                   LOGIN_USUARIO,
                   sysdate AS DT_ULT_ALTER_USUA
              from RHPBH_PS_VALORES_PLANO_SAUDE
             where ANO_MES_REFERENCIA = (select max(ANO_MES_REFERENCIA)
                                           from RHPBH_PS_VALORES_PLANO_SAUDE
                                          where ANO_MES_REFERENCIA <= vANO_MES_REFERENCIA
                                        )
            );

          EXCEPTION
          WHEN OTHERS THEN
             raise_application_error (-20002,'NAO FOI POSSIVEL REALIZAR A ATUALIZACAO DA TABELA DE VALORES DE PLANO DE SAUDE APOS O REAJUSTE DAS FAIXAS SALARIAIS. ENTRE EM CONTATO COM A EQUIPE DE SUPORTE DA PBH.');
          END;

        end;
     END IF;

     IF vTIPO_REGISTRO = C_TIPO_REGISTRO_TABELA and VOPERACAO = C_OPERACAO_REAJUSTE THEN

          begin
          insert into RHPBH_PS_VALORES_PLANO_SAUDE(
                 ANO_MES_REFERENCIA,
                 ANO_MES_REF_PLANO,
                 ANO_MES_REF_FAIXA_SALARIAL,
                 ANO_MES_REF_FAIXA_ETARIA,
                 DATA_CRIACAO,
                 IDENTIFICADOR_PLANO,
                 IDENTIFICADOR_FAIXA_SALARIAL,
                 IDENTIFICADOR_FAIXA_ETARIA,
                 VALOR_MENSALIDADE,
                 VALOR_SUBSIDIO,
                 LOGIN_USUARIO,
                 DT_ULT_ALTER_USUA
          )
          (
          select vANO_MES_REFERENCIA AS ANO_MES_REFERENCIA,
                 ANO_MES_REF_PLANO,
                 ANO_MES_REF_FAIXA_SALARIAL,
                 ANO_MES_REF_FAIXA_ETARIA,
                 sysdate AS DATA_CRIACAO,
                 IDENTIFICADOR_PLANO,
                 IDENTIFICADOR_FAIXA_SALARIAL,
                 IDENTIFICADOR_FAIXA_ETARIA,
                 (VALOR_MENSALIDADE * (1 + vREAJUSTE_MENSALIDADE)) AS VALOR_MENSALIDADE,
                 (VALOR_SUBSIDIO * (1 + vREAJUSTE_SUBSIDIO)) AS VALOR_SUBSIDIO,
                 LOGIN_USUARIO,
                 sysdate AS DT_ULT_ALTER_USUA
            from RHPBH_PS_VALORES_PLANO_SAUDE
           where ANO_MES_REFERENCIA = (select max(ANO_MES_REFERENCIA)
                                         from RHPBH_PS_VALORES_PLANO_SAUDE
                                        where ANO_MES_REFERENCIA <= vANO_MES_REFERENCIA
                                      )
          );

    EXCEPTION
    WHEN OTHERS THEN
       raise_application_error (-20002,'NAO FOI POSSIVEL REALIZAR O REAJUSTE NA TABELA DE VALORES DE PLANO DE SAUDE. ENTRE EM CONTATO COM A EQUIPE DE SUPORTE DA PBH.');
    END;

     END IF;




    IF vTIPO_REGISTRO = C_TIPO_REGISTRO_TABELA and VOPERACAO = C_OPERACAO_EXCLUSAO THEN
        BEGIN
             delete from RHPBH_PS_VALORES_PLANO_SAUDE
              where ANO_MES_REFERENCIA = PANO_MES_REFERENCIA;

              VCONTADOR := sql%rowcount;

        EXCEPTION
        WHEN OTHERS THEN
           raise_application_error (-20002,'NAO FOI POSSIVEL REALIZAR O CANCELAMENTO DE MOVIMENTO DIRF. ENTRE EM CONTATO COM A EQUIPE DE SUPORTE DA PBH.');
        END;

        IF VCONTADOR = 0 THEN
           raise_application_error (-20002,'NAO EXISTE REGISTRO DE TABELA DE VALORES DE PLANO DE SAUDE A SER EXCLUIDO COM OS PARAMETROS INFORMADOS.');
        END IF;
    END IF;
end;