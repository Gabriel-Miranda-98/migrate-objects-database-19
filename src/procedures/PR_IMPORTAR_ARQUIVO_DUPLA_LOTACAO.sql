
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_IMPORTAR_ARQUIVO_DUPLA_LOTACAO" (PCODIGO_EMPRESA CHAR, PIDENTIFICADOR_ARQUIVO CHAR, PROTULO_ARQUIVO VARCHAR2) as

vRETORNO RETORNO_PROCESSAMENTO := RETORNO_PROCESSAMENTO(null,null,null);
REG_LOG LOG_PROCESSAMENTO;
vLISTA_LOG LISTA_LOG := LISTA_LOG(null,null,null);

  ARQUIVO_DUPLA_LOTACAO         CONSTANT CHAR(4) := 'DPL1';


  EMPRESA_ATIVOS        CONSTANT CHAR(4) := '0001';
  EMPRESA_APOSENTADOS   CONSTANT CHAR(4) := '1700';
  EMPRESA_PENSIONISTAS  CONSTANT CHAR(4) := '0011';

  STATUS_CARREGADO    CONSTANT NUMBER := 0;
  STATUS_VALIDADO     CONSTANT NUMBER := 1;
  STATUS_INVALIDADO   CONSTANT NUMBER := 2;
  STATUS_PROCESSADO   CONSTANT NUMBER := 3;
  STATUS_EFETIVADO    CONSTANT NUMBER := 4;

  TIPO_LOG_SUCESSO      CONSTANT NUMBER := 0;
  TIPO_LOG_INFO         CONSTANT NUMBER := 2;
  TIPO_LOG_ALERTA       CONSTANT NUMBER := 2;
  TIPO_LOG_ERRO         CONSTANT NUMBER := 99;

  CATEGORIA_LOG_VALIDACAO CONSTANT NUMBER := 0;
  CATEGORIA_LOG_EXECUCAO  CONSTANT NUMBER := 1;


  vCONTADOR NUMBER;
  vTIPO_ARQUIVO CHAR(4);
  vDATA_PROCESSAMENTO DATE;
  vIS_TESTE BOOLEAN;
  vSITUACAO_PROCESSAMENTO CHAR(2);
  vCODIGO_EMPRESA CHAR(4);
  vANO_MES_REFERENCIA DATE;
  vCATEGORIA_LOG NUMBER;
  vTIPO_LOG NUMBER;

    v_ID_ARQUIVO NUMBER;
    v_CODIGO_EMPRESA CHAR(4);
    v_TIPO_ARQUIVO CHAR(4);
    v_DATA_CARGA DATE;
    v_LOGIN_USUARIO VARCHAR2(40);
    v_DT_ULT_ALTER_USUA DATE;
    v_SITUACAO CHAR(2);
    v_NOME_ARQUIVO VARCHAR2(1000);
    v_CAMINHO_ARQUIVO VARCHAR2(4000);
    v_PATH VARCHAR2(1000);
    v_ULTIMA_MODIFICACAO DATE;
    v_TAMANHO NUMBER;
    v_QUANTIDADE_LINHAS NUMBER;
    vROTULO_ARQUIVO VARCHAR2(30);

PROCEDURE GRAVA_LOG(CodigoEmpresa IN CHAR, TipoArquivo IN CHAR, DataImportacao IN DATE, CategoriaLog IN NUMBER, TipoLog IN NUMBER, Numero_linha IN NUMBER, DescricaoLog IN VARCHAR2, DetalheLog IN VARCHAR2) AS
BEGIN

     INSERT INTO RHPBH_PS_IMPORTACAO_LOG(ID_LOG, DATA_LOG, CODIGO_EMPRESA, TIPO_ARQUIVO, DATA_IMPORTACAO, CATEGORIA, TIPO, LINHA, DESCRICAO, DETALHE)
     values (SQ_RHPBH_PS_IMPORTACAO_LOG.NEXTVAL, sysdate, CodigoEmpresa, TipoArquivo, DataImportacao, CategoriaLog, TipoLog, Numero_linha, DescricaoLog, DetalheLog);
     COMMIT;

END;

begin

    -- Verifica se o identificador de arquivo informado é válido
    IF PIDENTIFICADOR_ARQUIVO NOT IN (ARQUIVO_DUPLA_LOTACAO) THEN
      raise_application_error (-20001,'IDENTIFICADOR_ARQUIVO INVALIDO.');
    END IF;

    -- Verifica se a empresa informada é válida
    BEGIN
         v_CODIGO_EMPRESA := null;
         select CODIGO into v_CODIGO_EMPRESA from RHORGA_EMPRESA where CODIGO = PCODIGO_EMPRESA;

         IF v_CODIGO_EMPRESA IS NULL THEN
            raise_application_error (-20001,'EMPRESA INVALIDA.');
         END IF;
    EXCEPTION
    WHEN OTHERS THEN
       raise_application_error (-20001,'EMPRESA INVALIDA.');
    END;

    -- Verifica se o rótulo para arquivo informado é válido
    IF PROTULO_ARQUIVO <> 'N' THEN
      IF LENGTH(PROTULO_ARQUIVO) < 8 or LENGTH(PROTULO_ARQUIVO) > 30 THEN
        raise_application_error (-20001,'ROTULO_ARQUIVO INVALIDO. SE PARAMETRO DIFERENTE DE N, ENTAO DEVE CONTER NO MINIMO 8 E NO MAXIMO 30 CARACTERES. PODE NAO SER INFORMADO. NESTE CASO INFORME O CARACTERE N E O SISTEMA GERARÁ O ROTULO AUTOMATICAMENTE.');
      END IF;
    END IF;

    IF PROTULO_ARQUIVO = 'N' THEN
    dbms_output.put_line('PROTULO_ARQUIVO = ' || PROTULO_ARQUIVO);
       vROTULO_ARQUIVO := NULL;
    ELSE
        BEGIN
        vCONTADOR := 0;
        select COUNT(1)
          into vCONTADOR
          from RHPBH_ARQUIVO
         where CODIGO_EMPRESA = PCODIGO_EMPRESA
           and ROTULO_ARQUIVO = PROTULO_ARQUIVO;

        IF vCONTADOR > 0 THEN
          raise_application_error (-20001,'O ROTULO INFORMADO PARA O ARQUIVO JA EXISTE PARA A EMPRESA INFORMADA.');
        ELSE
            vROTULO_ARQUIVO := PROTULO_ARQUIVO;
        END IF;

        EXCEPTION
        WHEN OTHERS THEN
           raise_application_error (-20001,'ERRO AO VALIDAR ROTULO.'|| 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
           vROTULO_ARQUIVO := NULL;
        END;
    END IF;


    BEGIN
    v_QUANTIDADE_LINHAS := 0;
    select COUNT(1)
      into v_QUANTIDADE_LINHAS
      from RHPBH_APOIO_IMPORTACAO_DUPLA_LOTACAO
     where CODIGO_EMPRESA = v_CODIGO_EMPRESA;

    EXCEPTION
    WHEN OTHERS THEN
       raise_application_error (-20001,'ERRO AO TENTAR RECUPERAR INFORMACAO A SER IMPORTADA');
    END;

    IF v_QUANTIDADE_LINHAS = 0 THEN
      raise_application_error (-20001,'NAO FORAM ENCONTRADOS REGISTROS NA AREA DE ARMAZENAMENTO TEMPORARIO DE IMPORTACAO DE ARQUIVOS PARA A EMPRESA SELECIONADA.');
    END IF;

    BEGIN
    v_CAMINHO_ARQUIVO := NULL;

    select CAMINHO_ARQUIVO
      into v_CAMINHO_ARQUIVO
      from RHPBH_APOIO_IMPORTACAO_DUPLA_LOTACAO
     where CODIGO_EMPRESA = v_CODIGO_EMPRESA
     group by CAMINHO_ARQUIVO;

     IF v_CAMINHO_ARQUIVO IS NOT NULL THEN
        v_NOME_ARQUIVO := SUBSTR(v_CAMINHO_ARQUIVO, INSTR(v_CAMINHO_ARQUIVO, '\', -1)+1);
     END IF;

    EXCEPTION
    WHEN OTHERS THEN
       v_CAMINHO_ARQUIVO := NULL;
       v_NOME_ARQUIVO := NULL;
    END;

   BEGIN

    v_ID_ARQUIVO := SQ_RHPBH_ARQUIVO.NEXTVAL;
    v_TIPO_ARQUIVO := PIDENTIFICADOR_ARQUIVO;
    v_DATA_CARGA := TRUNC(sysdate);
    v_LOGIN_USUARIO := 'IMPORT';
    v_DT_ULT_ALTER_USUA := sysdate;
    v_SITUACAO := '00';
    v_PATH := v_CAMINHO_ARQUIVO;
    v_ULTIMA_MODIFICACAO := sysdate;
    v_TAMANHO := 0;


    /*
     NAO_DEFINIDO_<CODIGO_EMPRESA>_<TIPO_ARQUIVO>_<DATA_CARGA>_<ID_ARQUIVO>
     NAO_DEFINIDO_0001_0004_20170601_1
    */
    IF v_NOME_ARQUIVO IS NULL THEN
       v_NOME_ARQUIVO := 'NAO_DEFINIDO' || '_' || v_CODIGO_EMPRESA || '_' || v_TIPO_ARQUIVO || '_' || v_DATA_CARGA || '_' || v_ID_ARQUIVO;
    END IF;

    --<CODIGO_EMPRESA>_<TIPO_ARQUIVO>_<DATA_CARGA>_<ID_ARQUIVO>
    -- 4 + 1 + 4 + 1 + 8 + 1
    --0001_0004_20170601_1
  
    IF vROTULO_ARQUIVO IS NULL THEN
       vROTULO_ARQUIVO := v_CODIGO_EMPRESA || '_' || '_' || v_DATA_CARGA || '_' || LPAD(v_ID_ARQUIVO, 10, '0');
  END IF;


    /*
    dbms_output.put_line('v_ID_ARQUIVO = ' || v_ID_ARQUIVO);
    dbms_output.put_line('PCODIGO_EMPRESA = ' || PCODIGO_EMPRESA);
    dbms_output.put_line('v_TIPO_ARQUIVO = ' || v_TIPO_ARQUIVO);
    dbms_output.put_line('v_DATA_CARGA = ' || v_DATA_CARGA);
    dbms_output.put_line('v_SITUACAO = ' || v_SITUACAO);
    */

    insert into RHPBH_ARQUIVO(ID_ARQUIVO, CODIGO_EMPRESA, TIPO_ARQUIVO, DATA_CARGA, SITUACAO, ROTULO_ARQUIVO, NOME_ARQUIVO, PATH, ULTIMA_MODIFICACAO, DATA_ULTIMO_PROCESSAMENTO, TAMANHO, QUANTIDADE_LINHAS, LOGIN_USUARIO, DT_ULT_ALTER_USUA)
    values (v_ID_ARQUIVO, v_CODIGO_EMPRESA, v_TIPO_ARQUIVO, v_DATA_CARGA, v_SITUACAO, vROTULO_ARQUIVO,
    v_NOME_ARQUIVO, v_PATH, v_ULTIMA_MODIFICACAO, sysdate, v_TAMANHO, v_QUANTIDADE_LINHAS, v_LOGIN_USUARIO, v_DT_ULT_ALTER_USUA
    );

    insert into RHPBH_ARQUIVO_LINHA (ID_ARQUIVO, NUMERO_LINHA, LINHA, SITUACAO, LOGIN_USUARIO, DT_ULT_ALTER_USUA, ROWID_LINHA)
    (
    select * from(
    select ID_ARQUIVO, NUMERO_LINHA, LINHA, SITUACAO, LOGIN_USUARIO, DT_ULT_ALTER_USUA, ROWID_LINHA from(
    select ROWID_LINHA, DATA_IMPORTACAO_LINHA, ID_ARQUIVO, NUMERO_LINHA, LINHA, SITUACAO, LOGIN_USUARIO, DT_ULT_ALTER_USUA from (
    select ROWID AS ROWID_LINHA, DT_ULT_ALTER_USUA AS DATA_IMPORTACAO_LINHA,
           v_ID_ARQUIVO AS ID_ARQUIVO,
           --ROWNUM AS NUMERO_LINHA,
           NUMERO_LINHA,
           LINHA_ARQUIVO AS LINHA,
           v_SITUACAO AS SITUACAO,
           v_LOGIN_USUARIO AS LOGIN_USUARIO,
           v_DT_ULT_ALTER_USUA AS DT_ULT_ALTER_USUA
      from RHPBH_APOIO_IMPORTACAO_DUPLA_LOTACAO
     where CODIGO_EMPRESA = v_CODIGO_EMPRESA
    ) order by DATA_IMPORTACAO_LINHA, NUMERO_LINHA
    ) --order by ID_ARQUIVO, NUMERO_LINHA
    )
    );


    COMMIT;


    DELETE from RHPBH_APOIO_IMPORTACAO_DUPLA_LOTACAO
     where exists(
     select NUMERO_LINHA
       from RHPBH_ARQUIVO, RHPBH_ARQUIVO_LINHA
      where RHPBH_ARQUIVO.ID_ARQUIVO = RHPBH_ARQUIVO_LINHA.ID_ARQUIVO
        and RHPBH_ARQUIVO.CODIGO_EMPRESA = RHPBH_APOIO_IMPORTACAO_DUPLA_LOTACAO.CODIGO_EMPRESA
        and RHPBH_ARQUIVO_LINHA.NUMERO_LINHA = RHPBH_APOIO_IMPORTACAO_DUPLA_LOTACAO.NUMERO_LINHA
        and RHPBH_ARQUIVO.ID_ARQUIVO = v_ID_ARQUIVO
     );

     COMMIT;
    EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK;
       raise_application_error (-20001,'ERRO AO TENTAR IMPOTAR INFORMACOES. INFORME O ERRO AO SUPORTE DA PBH.' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
    END;

end;