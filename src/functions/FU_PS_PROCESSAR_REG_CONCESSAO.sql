
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."FU_PS_PROCESSAR_REG_CONCESSAO" (Numero_linha IN NUMBER, LinhaTexto IN VARCHAR2, NomeArquivo IN VARCHAR2, DataCarga IN DATE, listaFornecedores IN VARCHAR2, INDICADOR_TESTE BOOLEAN)
RETURN RETORNO_PROCESSAMENTO
 IS
  REG_LOG LOG_PROCESSAMENTO;
  vLISTA_LOG LISTA_LOG;
  vRETORNO RETORNO_PROCESSAMENTO;

  LISTA_TIPO_RELACI_VALIDO LISTA;
  LISTA_TIPO_BENEFICIO LISTA;

  TIPO_ALFANUMERICO     CONSTANT NUMBER := 1;
  TIPO_NUMERICO         CONSTANT NUMBER := 2;
  TIPO_DATA             CONSTANT NUMBER := 3;
  TIPO_DATA_HORA        CONSTANT NUMBER := 4;
  TIPO_SIM_NAO          CONSTANT NUMBER := 5;
  TIPO_VALOR            CONSTANT NUMBER := 6;
  SIM                   CONSTANT NUMBER := 1;
  NAO                   CONSTANT NUMBER := 0;


  TIPO_LOG_SUCESSO      CONSTANT NUMBER := 0;
  TIPO_LOG_INFO         CONSTANT NUMBER := 2;
  TIPO_LOG_ALERTA       CONSTANT NUMBER := 2;
  TIPO_LOG_ERRO         CONSTANT NUMBER := 99;

  OBJETO_CONCESSAO_BENEFICIO  CONSTANT VARCHAR2(40) := 'd_mantem_concessao_beneficio1';

  PREFIXO_CODIGO_FORNECEDOR    CONSTANT VARCHAR2(1) := 'F';
  PREFIXO_CODIGO_BENEFICIO     CONSTANT VARCHAR2(1) := 'B';

  TAMANHO_MAXIMO_LINHA  CONSTANT NUMBER := 240;
  FORMATO_DATA          CONSTANT VARCHAR2(8)  := 'DDMMYYYY';
  FORMATO_DATA_HORA     CONSTANT VARCHAR2(16) := 'DDMMYYYYHH24MISS';

  TYPE REGISTRO_APOIO_LOG_SISTEMA is RECORD(
  CODIGO_EMPRESA             CHAR(4),
  CODIGO_BENEFIC             CHAR(15),
  DATA_CONCESSAO             DATE,
  OCORRENCIA                 NUMBER(4)
  );

  REG_APOIO_LOG_SIST REGISTRO_APOIO_LOG_SISTEMA;

  TYPE CONCESSAO is RECORD (
     TIPO_OPERACAO CHAR(15),
     CODIGO_EMPRESA CHAR(4),
     CODIGO_CONTRATO CHAR(15),
     CPF CHAR(11),
     CODIGO_ANS_FORNECEDOR CHAR(6),
     CODIGO_BENEFICIO CHAR(15),
     CATEGORIA_BENEFICIARIO CHAR(4),
     ORDEM_DEPENDENTE CHAR(1),
     MOTIVO_CONCESSAO CHAR(4),
     DATA_CONCESSAO DATE,
     MOTIVO_CANCELAMENTO CHAR(4),
     DATA_CANCELAMENTO DATE,
     OBSERVACAO VARCHAR2(60),
     NUMERO_CARTEIRA VARCHAR2(25),
     NUMERO_PROTOCOLO VARCHAR2(25),
     DATA_FIM_ESCOLARIDADE DATE,
     INVALIDEZ CHAR(1),
     DATA_CADASTRAMENTO DATE
    );

  TYPE INTERFACE is RECORD (
    CAMPO      VARCHAR2(1000),
    TAMANHO    NUMBER,
    TAMANHO_IS NUMBER,
    TIPO       NUMBER,
    TIPO_IS    NUMBER,
    NULO       NUMBER,
    VALOR      VARCHAR2(1000)
    );

    V_CONTEUDO VARCHAR2(1000);
    V_TEXTO VARCHAR2(1000);
    V_NUMERICO NUMBER;
    V_DATA DATE;

  TYPE LISTA_CAMPOS is RECORD (
    CONTEUDO    VARCHAR2(1000)
    );

   TYPE INTERFACE_SERVIDOR IS VARRAY(18) OF INTERFACE;

   TYPE LISTA_CAMPOS_SERVIDOR IS VARRAY(10000) OF LISTA_CAMPOS;

   I_S INTERFACE_SERVIDOR;
   REG LISTA_CAMPOS_SERVIDOR;

   /*TYPE TAB_CONCESSAO IS TABLE OF CONCESSAO
      INDEX BY BINARY_INTEGER; */
   REGISTRO_CONCESSAO CONCESSAO;
   --REG_CONCESSAO REGISTRO_CONCESSAO;

   vCONTEUDO VARCHAR2(1000);
   vCAMPO VARCHAR2(1000);
   vCARACTERE CHAR(1);
   --vCARACTERE_TRANSLATE CHAR(1);
   vCONTADOR NUMBER;
   vTAM_REGISTRO  NUMBER;
   vTAM_INTERFACE NUMBER;
   --vTAM_LOOP      NUMBER;
   vTAM_LINHA     NUMBER;
   vTAM_CAMPO     NUMBER;
   --vCONTADOR_CAMPO NUMBER;
   vCAMPO_PODE_SER_NULO BOOLEAN;
   vUSUARIO VARCHAR2(15) := 'IMPORT_PS';
   vUSUARIO_ATUALIZACAO VARCHAR2(15) := 'IMPORT_PS_A';
   vDATA_ATUALIZACAO DATE;
   vTIPO_CONTRATO CHAR(4) := '0001';
   vCODIGO_PESSOA CHAR(15);
   vTIPO_RELACIONAMENTO CHAR(4);
   vDATA_NASCIMENTO DATE;
   vIDADE NUMBER;
   vJA_POSSUI_PLANO_SAUDE NUMBER;
   vOCORRENCIA NUMBER;
   vCODIGO_FORNECEDOR CHAR(15);
   vCPF_VALIDO BOOLEAN;
   vCODIGO_BENEFICIO VARCHAR2(15);
   vCODIGO_CATEGORIA_BENEFICIARIO VARCHAR2(4);
   vCODIGO_PESSOA_BENEFICIARIO VARCHAR2(15);
   vORDEM_DEPENDENCIA  CHAR(2);
   vEXCECAO_DEPENDENCIA  CHAR(1);
   vDATA_FIM_EXCECAO_DEPENDENCIA  DATE;
   vHOUVE_ALTERACAO_DADOS BOOLEAN;

PROCEDURE GRAVA_LOG(TipoLog IN NUMBER, Numero_linha IN NUMBER, DescricaoLog IN VARCHAR2, DetalheLog IN VARCHAR2) AS
BEGIN
REG_LOG.TIPO_LOG := TipoLog;
REG_LOG.DESCRICAO_LOG := DescricaoLog;
REG_LOG.DETALHE_LOG := DetalheLog;

vLISTA_LOG.Extend;
vLISTA_LOG(vLISTA_LOG.count) := REG_LOG;
/*
     INSERT INTO RHPBH_PS_IMPORTACAO_LOG(ID_LOG, TIPO_ARQUIVO, DATA_IMPORTACAO, TIPO, LINHA, DESCRICAO, DETALHE)
     values (SQ_RHPBH_PS_IMPORTACAO_LOG.NEXTVAL, NomeArquivo, DataCarga, TipoLog, Numero_linha, DescricaoLog, DetalheLog);
     COMMIT;
*/

END;

PROCEDURE GRAVA_LOG_SISTEMA(pDataAlteracao IN DATE, pObjeto IN VARCHAR2, pUsuario IN VARCHAR2, pOperacao IN CHAR, pReg IN REGISTRO_APOIO_LOG_SISTEMA) AS
vTERMINAL_ESTACAO_REDE VARCHAR2(40);
vKEY_STR VARCHAR2(2000);
vOCORRENCIA NUMBER;
BEGIN
GRAVA_LOG(TIPO_LOG_INFO, 0, 'ENTROU GRAVA_LOG_SISTEMA', null);

--vOCORRENCIA := OBTER_OCORRENCIA_LOG(pDataAlteracao);
vOCORRENCIA := 0;
  -- Recupera a estação da rede que o comando está sendo executado
  BEGIN
  SELECT max(OCORRENCIA)
    INTO vOCORRENCIA
    FROM RHPARM_LOG_SIST
   WHERE MODULO = 'arte'
     AND DATA_ALTERACAO = pDataAlteracao
     AND OBJETO = pObjeto
     AND USUARIO = 'IMPORT_PS'
     AND OPERACAO = pOperacao
     ;
  EXCEPTION
  WHEN OTHERS THEN
  vOCORRENCIA := 0;
  END;

IF vOCORRENCIA IS NULL THEN
   vOCORRENCIA := 1;
ELSE
   vOCORRENCIA := vOCORRENCIA + 1;
END IF;

/*
  -- Recupera a estação da rede que o comando está sendo executado
  BEGIN
  SELECT TERMINAL
    INTO vTERMINAL_ESTACAO_REDE
    FROM v$session
   WHERE AUDSID = SYS_CONTEXT('USERENV','SESSIONID');
  EXCEPTION
  WHEN OTHERS THEN
  vTERMINAL_ESTACAO_REDE := NULL;
  END;
*/

IF pObjeto = OBJETO_CONCESSAO_BENEFICIO THEN
   vKEY_STR := 'codigo_empresa: ' || pReg.CODIGO_EMPRESA || CHR(10) ||
               'codigo_benefic: ' || pReg.CODIGO_BENEFIC || CHR(10) ||
               'data_concessao: ' || pReg.DATA_CONCESSAO || CHR(10) ||
               'ocorrencia: ' || pReg.OCORRENCIA;
ELSE
   vKEY_STR := 'codigo_empresa: ' || pReg.CODIGO_EMPRESA || CHR(10) ||
               'codigo_benefic: ' || pReg.CODIGO_BENEFIC || CHR(10) ||
               'data_concessao: ' || pReg.DATA_CONCESSAO || CHR(10) ||
               'ocorrencia: ' || pReg.OCORRENCIA;
END IF;

BEGIN
insert into RHPARM_LOG_SIST (MODULO, DATA_ALTERACAO, OBJETO, USUARIO, OPERACAO, KEY_STR, REGISTRO, ESTACAO_REDE, OCORRENCIA, DATA_FIM_OPER, ID_ESCALONA)
values(
       'arte',
       pDataAlteracao,
       pObjeto,
       'IMPORT_PS',
       pOperacao,
       'IMPORTACAO_PLANO_SAUDE ' || vKEY_STR,
       vKEY_STR,
       vTERMINAL_ESTACAO_REDE,
       vOCORRENCIA,
       null,
       null
);

EXCEPTION
WHEN DUP_VAL_ON_INDEX THEN
BEGIN
vOCORRENCIA := vOCORRENCIA + 1;
insert into RHPARM_LOG_SIST (MODULO, DATA_ALTERACAO, OBJETO, USUARIO, OPERACAO, KEY_STR, REGISTRO, ESTACAO_REDE, OCORRENCIA, DATA_FIM_OPER, ID_ESCALONA)
values(
       'arte',
       pDataAlteracao + (1/(24*60*60)),
       pObjeto,
       'IMPORT_PS',
       pOperacao,
       'IMPORTACAO_PLANO_SAUDE ' || vKEY_STR,
       vKEY_STR,
       vTERMINAL_ESTACAO_REDE,
       vOCORRENCIA,
       null,
       null
);
EXCEPTION
WHEN OTHERS THEN
   GRAVA_LOG(TIPO_LOG_ERRO, 0, 'ERRO AO TENTAR REGISTRAR LOG DO SISTEMA APOS NOVA TENTATIVA', 'pDataAlteracao: ' || TO_CHAR(pDataAlteracao, 'DD/MM/YYYY HH24:MI:SS') ||
                                                                          'pObjeto: ' || pObjeto ||
                                                                          'pUsuario: ' || pUsuario ||
                                                                          'pOperacao: ' || pOperacao ||
                                                                          'vOCORRENCIA: ' || vOCORRENCIA ||
                                                                          'vKEY_STR: ' || vKEY_STR ||
                                                                          'vTERMINAL_ESTACAO_REDE: ' || vTERMINAL_ESTACAO_REDE ||
                                                                          'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
END;

WHEN OTHERS THEN
   GRAVA_LOG(TIPO_LOG_ERRO, 0, 'ERRO AO TENTAR REGISTRAR LOG DO SISTEMA', 'pDataAlteracao: ' || TO_CHAR(pDataAlteracao, 'DD/MM/YYYY HH24:MI:SS') ||
                                                                          'pObjeto: ' || pObjeto ||
                                                                          'pUsuario: ' || pUsuario ||
                                                                          'pOperacao: ' || pOperacao ||
                                                                          'vOCORRENCIA: ' || vOCORRENCIA ||
                                                                          'vKEY_STR: ' || vKEY_STR ||
                                                                          'vTERMINAL_ESTACAO_REDE: ' || vTERMINAL_ESTACAO_REDE ||
                                                                          'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
END;

GRAVA_LOG(TIPO_LOG_INFO, 0, 'SAIU GRAVA_LOG_SISTEMA',null);
END;

PROCEDURE ATRIBUI_DADO(indice IN NUMBER, valorTexto IN VARCHAR2,valorNumero IN NUMBER, valorData IN DATE) AS

BEGIN
    CASE
    WHEN indice = 1  THEN REGISTRO_CONCESSAO.TIPO_OPERACAO := valorTexto;
    WHEN indice = 2  THEN REGISTRO_CONCESSAO.CODIGO_EMPRESA := valorTexto;
    WHEN indice = 3  THEN REGISTRO_CONCESSAO.CODIGO_CONTRATO := valorTexto;
    WHEN indice = 4  THEN REGISTRO_CONCESSAO.CPF := valorTexto;
    WHEN indice = 5  THEN REGISTRO_CONCESSAO.CODIGO_ANS_FORNECEDOR := valorNumero;
    WHEN indice = 6  THEN REGISTRO_CONCESSAO.CODIGO_BENEFICIO := valorTexto;
    WHEN indice = 7  THEN REGISTRO_CONCESSAO.CATEGORIA_BENEFICIARIO := valorTexto;
    WHEN indice = 8  THEN REGISTRO_CONCESSAO.ORDEM_DEPENDENTE := valorNumero;
    WHEN indice = 9  THEN REGISTRO_CONCESSAO.MOTIVO_CONCESSAO := valorTexto;
    WHEN indice = 10 THEN REGISTRO_CONCESSAO.DATA_CONCESSAO := valorData;
    WHEN indice = 11 THEN REGISTRO_CONCESSAO.MOTIVO_CANCELAMENTO := valorTexto;
    WHEN indice = 12 THEN REGISTRO_CONCESSAO.DATA_CANCELAMENTO := valorData;
    WHEN indice = 13 THEN REGISTRO_CONCESSAO.OBSERVACAO := valorTexto;
    WHEN indice = 14 THEN REGISTRO_CONCESSAO.NUMERO_CARTEIRA := valorTexto;
    WHEN indice = 15 THEN REGISTRO_CONCESSAO.NUMERO_PROTOCOLO := valorTexto;
    WHEN indice = 16 THEN REGISTRO_CONCESSAO.DATA_FIM_ESCOLARIDADE := valorData;
    WHEN indice = 17 THEN REGISTRO_CONCESSAO.INVALIDEZ := valorTexto;
    WHEN indice = 18 THEN REGISTRO_CONCESSAO.DATA_CADASTRAMENTO := valorData;
    END CASE;

END;


PROCEDURE IMPRIME_CAMPOS(I_S INTERFACE_SERVIDOR) AS
BEGIN
  dbms_output.put_line('*** IMPRESSSÃO REGISTRO ***');
  dbms_output.put_line(RPAD('CAMPO', 30, ' ') || RPAD('VALOR', 1000, ' '));

  FOR i in 1..I_S.COUNT() LOOP
      dbms_output.put_line(RPAD(I_S(i).CAMPO, 30, ' ') || RPAD(I_S(i).VALOR, 1000, ' '));
  END LOOP;

END;

PROCEDURE IMPRIME_REGISTRO(RG CONCESSAO) AS
BEGIN
  dbms_output.put_line('*** IMPRESSSÃO REGISTRO ***');
    dbms_output.put_line(RG.TIPO_OPERACAO);
    dbms_output.put_line(RG.CODIGO_EMPRESA);
    dbms_output.put_line(RG.CODIGO_CONTRATO);
    dbms_output.put_line(RG.CPF);
    dbms_output.put_line(RG.CODIGO_ANS_FORNECEDOR);
    dbms_output.put_line(RG.CODIGO_BENEFICIO);
    dbms_output.put_line(RG.CATEGORIA_BENEFICIARIO);
    dbms_output.put_line(RG.ORDEM_DEPENDENTE);
    dbms_output.put_line(RG.MOTIVO_CONCESSAO);
    dbms_output.put_line(RG.DATA_CONCESSAO);
    dbms_output.put_line(RG.MOTIVO_CANCELAMENTO);
    dbms_output.put_line(RG.DATA_CANCELAMENTO);
    dbms_output.put_line(RG.OBSERVACAO);
    dbms_output.put_line(RG.NUMERO_CARTEIRA);
    dbms_output.put_line(RG.NUMERO_PROTOCOLO);
    dbms_output.put_line(RG.DATA_FIM_ESCOLARIDADE);
    dbms_output.put_line(RG.INVALIDEZ);
    dbms_output.put_line(RG.DATA_CADASTRAMENTO);

END;

begin

    REG := LISTA_CAMPOS_SERVIDOR();
    vLISTA_LOG := LISTA_LOG();
    REG_LOG := LOG_PROCESSAMENTO(null, null,null,null);
    vRETORNO := RETORNO_PROCESSAMENTO(null,null,null);

    vCONTADOR := 1;
    vCONTEUDO := LinhaTexto;
    vTAM_LINHA := LENGTH(vCONTEUDO);
    --dbms_output.put_line(LinhaTexto);


        FOR i in 1..vTAM_LINHA LOOP
        vCARACTERE := SUBSTR(vCONTEUDO,i,1);
        IF vCARACTERE = ';' THEN
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



     vCONTADOR := 1;
     I_S := INTERFACE_SERVIDOR();
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'TIPO_OPERACAO';                I_S(vCONTADOR).TAMANHO_IS := 1;  I_S(vCONTADOR).TAMANHO := 1;  I_S(vCONTADOR).TIPO_IS := TIPO_ALFANUMERICO; I_S(vCONTADOR).TIPO := TIPO_ALFANUMERICO; I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'CODIGO_EMPRESA';               I_S(vCONTADOR).TAMANHO_IS := 4;  I_S(vCONTADOR).TAMANHO := 4;  I_S(vCONTADOR).TIPO_IS := TIPO_NUMERICO;     I_S(vCONTADOR).TIPO := TIPO_NUMERICO;     I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'CODIGO_CONTRATO';              I_S(vCONTADOR).TAMANHO_IS := 15; I_S(vCONTADOR).TAMANHO := 15; I_S(vCONTADOR).TIPO_IS := TIPO_ALFANUMERICO; I_S(vCONTADOR).TIPO := TIPO_NUMERICO;     I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'CPF';                          I_S(vCONTADOR).TAMANHO_IS := 11; I_S(vCONTADOR).TAMANHO := 11; I_S(vCONTADOR).TIPO_IS := TIPO_NUMERICO;     I_S(vCONTADOR).TIPO := TIPO_NUMERICO;     I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'CODIGO_ANS_FORNECEDOR';        I_S(vCONTADOR).TAMANHO_IS := 15; I_S(vCONTADOR).TAMANHO := 15; I_S(vCONTADOR).TIPO_IS := TIPO_NUMERICO;     I_S(vCONTADOR).TIPO := TIPO_NUMERICO;     I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'CODIGO_BENEFICIO';             I_S(vCONTADOR).TAMANHO_IS := 15; I_S(vCONTADOR).TAMANHO := 15; I_S(vCONTADOR).TIPO_IS := TIPO_NUMERICO;     I_S(vCONTADOR).TIPO := TIPO_NUMERICO;     I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'CATEGORIA_BENEFICIARIO';       I_S(vCONTADOR).TAMANHO_IS := 4;  I_S(vCONTADOR).TAMANHO := 4;  I_S(vCONTADOR).TIPO_IS := TIPO_NUMERICO;     I_S(vCONTADOR).TIPO := TIPO_NUMERICO;     I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'ORDEM_DEPENDENTE';             I_S(vCONTADOR).TAMANHO_IS := 2;  I_S(vCONTADOR).TAMANHO := 2;  I_S(vCONTADOR).TIPO_IS := TIPO_NUMERICO;     I_S(vCONTADOR).TIPO := TIPO_NUMERICO;     I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'MOTIVO_CONCESSAO';             I_S(vCONTADOR).TAMANHO_IS := 4;  I_S(vCONTADOR).TAMANHO := 4;  I_S(vCONTADOR).TIPO_IS := TIPO_ALFANUMERICO; I_S(vCONTADOR).TIPO := TIPO_ALFANUMERICO; I_S(vCONTADOR).NULO := SIM; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'DATA_CONCESSAO';               I_S(vCONTADOR).TAMANHO_IS := 8;  I_S(vCONTADOR).TAMANHO := 8;  I_S(vCONTADOR).TIPO_IS := TIPO_DATA;         I_S(vCONTADOR).TIPO := TIPO_DATA;         I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;

     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'MOTIVO_CANCELAMENTO';          I_S(vCONTADOR).TAMANHO_IS := 4;  I_S(vCONTADOR).TAMANHO := 4;  I_S(vCONTADOR).TIPO_IS := TIPO_ALFANUMERICO; I_S(vCONTADOR).TIPO := TIPO_ALFANUMERICO; I_S(vCONTADOR).NULO := SIM; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'DATA_CANCELAMENTO';            I_S(vCONTADOR).TAMANHO_IS := 8;  I_S(vCONTADOR).TAMANHO := 8;  I_S(vCONTADOR).TIPO_IS := TIPO_DATA;         I_S(vCONTADOR).TIPO := TIPO_DATA;         I_S(vCONTADOR).NULO := SIM; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'OBSERVACAO';                   I_S(vCONTADOR).TAMANHO_IS := 60; I_S(vCONTADOR).TAMANHO := 60; I_S(vCONTADOR).TIPO_IS := TIPO_ALFANUMERICO; I_S(vCONTADOR).TIPO := TIPO_ALFANUMERICO; I_S(vCONTADOR).NULO := SIM; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'NUMERO_CARTEIRA';              I_S(vCONTADOR).TAMANHO_IS := 25; I_S(vCONTADOR).TAMANHO := 25; I_S(vCONTADOR).TIPO_IS := TIPO_ALFANUMERICO; I_S(vCONTADOR).TIPO := TIPO_ALFANUMERICO; I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'NUMERO_PROTOCOLO';             I_S(vCONTADOR).TAMANHO_IS := 25; I_S(vCONTADOR).TAMANHO := 25; I_S(vCONTADOR).TIPO_IS := TIPO_ALFANUMERICO; I_S(vCONTADOR).TIPO := TIPO_ALFANUMERICO; I_S(vCONTADOR).NULO := SIM; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'DATA_FIM_EXCECAO_DEPENDENCIA'; I_S(vCONTADOR).TAMANHO_IS := 8;  I_S(vCONTADOR).TAMANHO := 8;  I_S(vCONTADOR).TIPO_IS := TIPO_DATA;         I_S(vCONTADOR).TIPO := TIPO_DATA;         I_S(vCONTADOR).NULO := SIM; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'EXCECAO_DEPENDENCIA';          I_S(vCONTADOR).TAMANHO_IS := 1;  I_S(vCONTADOR).TAMANHO := 1;  I_S(vCONTADOR).TIPO_IS := TIPO_NUMERICO;     I_S(vCONTADOR).TIPO := TIPO_NUMERICO;     I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'DATA_CADASTRAMENTO';           I_S(vCONTADOR).TAMANHO_IS := 14; I_S(vCONTADOR).TAMANHO := 14; I_S(vCONTADOR).TIPO_IS := TIPO_DATA_HORA;    I_S(vCONTADOR).TIPO := TIPO_DATA_HORA;    I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;

   vTAM_REGISTRO := REG.COUNT();
   vTAM_INTERFACE := I_S.COUNT();
/*
   IF (vTAM_LINHA <> TAMANHO_MAXIMO_LINHA) THEN
      GRAVA_LOG(Numero_linha, 'TAMANHO DA LINHA INVÁLIDO' || 'VALOR_ESPERADO: ' || TAMANHO_MAXIMO_LINHA || ' VALOR_OBTIDO: ' || vTAM_LINHA);
   END IF;
*/
   IF (vTAM_INTERFACE <> vTAM_REGISTRO) THEN
      GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'QUANTIDADE DE CAMPOS INVÁLIDA', 'VALOR_ESPERADO: ' || vTAM_INTERFACE || ' VALOR_OBTIDO: ' || vTAM_REGISTRO);
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
         GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'CAMPO NULO', I_S(i).CAMPO);
      ELSIF (vTAM_CAMPO IS NOT NULL) THEN

          IF (vTAM_CAMPO > (I_S(i).TAMANHO)) THEN

          GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'TAMANHO DE CAMPO INVÁLIDO', I_S(i).CAMPO  || ' VALOR_ESPERADO =  ' || I_S(i).TAMANHO || ' VALOR_OBTIDO = ' || vTAM_CAMPO);

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

             ATRIBUI_DADO(i,V_TEXTO, V_NUMERICO, V_DATA);
             EXCEPTION
             WHEN OTHERS THEN

             GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'NÚMERO INVÁLIDO', I_S(i).CAMPO || ' VALOR: ' || '|' || V_CONTEUDO  || '|');

             END;
          END IF;


          IF (I_S(i).TIPO = TIPO_DATA) THEN

             BEGIN
             IF V_CONTEUDO = '00000000' THEN
                IF (NOT vCAMPO_PODE_SER_NULO) THEN
                   GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'CAMPO NULO', I_S(i).CAMPO);
                END IF;
             ELSE
               V_DATA := TO_DATE(V_CONTEUDO, FORMATO_DATA);
               ATRIBUI_DADO(i,V_TEXTO, V_NUMERICO, V_DATA);
             END IF;

             EXCEPTION
             WHEN OTHERS THEN

             GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DATA INVÁLIDA', I_S(i).CAMPO || ' VALOR: ' || '|' || V_CONTEUDO  || '|');

             END;

          END IF;

          IF (I_S(i).TIPO = TIPO_DATA_HORA) THEN


             BEGIN
             IF V_CONTEUDO = '00000000000000' THEN
                IF (NOT vCAMPO_PODE_SER_NULO) THEN
                   GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'CAMPO NULO', I_S(i).CAMPO);
                END IF;
             ELSE
               V_DATA := TO_DATE(V_CONTEUDO, FORMATO_DATA_HORA);
               ATRIBUI_DADO(i,V_TEXTO, V_NUMERICO, V_DATA);
             END IF;

             EXCEPTION
             WHEN OTHERS THEN

             GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DATA INVÁLIDA', I_S(i).CAMPO || ' VALOR: ' || '|' || V_CONTEUDO  || '|');

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
             ATRIBUI_DADO(i,V_TEXTO, V_NUMERICO, V_DATA);
             EXCEPTION
             WHEN OTHERS THEN

             GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'TEXTO INVÁLIDO', I_S(i).CAMPO || ' VALOR: ' || '|' || V_CONTEUDO  || '|');

             END;

         END IF;


         IF (I_S(i).TIPO = TIPO_SIM_NAO) THEN

             BEGIN
               IF V_CONTEUDO IN ('S','N') THEN
                  V_TEXTO := V_CONTEUDO;
                       ATRIBUI_DADO(i,V_TEXTO, V_NUMERICO, V_DATA);
               ELSE
                   GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'TEXTO INVÁLIDO', I_S(i).CAMPO || ' VALOR: ' || '|' || V_CONTEUDO  || '|');
               END IF;
             EXCEPTION
             WHEN OTHERS THEN

             GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'TEXTO INVÁLIDO', I_S(i).CAMPO || ' VALOR: ' || '|' || V_CONTEUDO  || '|');

             END;

         END IF;

      END IF;
    END LOOP;
    --IMPRIME_CAMPOS(I_S);
    --IMPRIME_REGISTRO(REGISTRO_CONCESSAO);

  -- Lista de valores válidos nas bases de dados da Pensão, Ativos e Aposentados
  -- Pensão      CODIGO_EMPRESA = 0011
  -- Ativos      CODIGO_EMPRESA = 0001
  -- Aposentados CODIGO_EMPRESA = 1700
  IF REGISTRO_CONCESSAO.CODIGO_EMPRESA = '0011' THEN
    LISTA_TIPO_RELACI_VALIDO := LISTA('0016','0020','0021','0022','0023','0024','0025','0026','0031');

    LISTA_TIPO_BENEFICIO := LISTA('0022', '0025', '0026');
  ELSE

    LISTA_TIPO_RELACI_VALIDO := LISTA('0001','0002','0003','0004','0005','0006',
                                      '0015','0016','0018','0028','0029','0030');

    LISTA_TIPO_BENEFICIO := LISTA('0003','0004', '0005', '0006');
  END IF;

BEGIN -- INICIO VALIDACOES REGRAS

    -- Valores Válidos
    IF REGISTRO_CONCESSAO.TIPO_OPERACAO NOT IN ('I','A','E') THEN
       GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'TIPO_OPERACAO_INVALIDO', null);
    END IF;

    BEGIN
    vCODIGO_FORNECEDOR := NULL;

    select F.CODIGO into vCODIGO_FORNECEDOR
      from RHORGA_FORNECEDOR F, RHBENF_BENEFICIO BB, RHBENF_TIPO_BENEF BT
     where F.CODIGO = BB.ENTIDADE_FORNECED
       --and F.CODIGO_EMPRESA = REGISTRO_CONCESSAO.CODIGO_EMPRESA
       and F.REGISTRO_ANS = REGISTRO_CONCESSAO.CODIGO_ANS_FORNECEDOR
       and BB.CODIGO = REGISTRO_CONCESSAO.CODIGO_BENEFICIO
       and BB.COD_TIPO_BENEFICIO = BT.CODIGO
       and BT.CODIGO member (LISTA_TIPO_BENEFICIO);

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         --raise_application_error (-20003,'FORNECEDOR NAO ENCONTRADO PARA O CODIGO ANS INFORMADO: ' || 'CODIGO ANS = ' || REGISTRO_CONCESSAO.CODIGO_ANS_FORNECEDOR || 'CODIGO BENEFICIO = ' || REGISTRO_CONCESSAO.CODIGO_BENEFICIO);
         GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'FORNECEDOR NAO ENCONTRADO PARA O CODIGO ANS INFORMADO', 'CODIGO ANS = ' || REGISTRO_CONCESSAO.CODIGO_ANS_FORNECEDOR || 'CODIGO BENEFICIO = ' || REGISTRO_CONCESSAO.CODIGO_BENEFICIO);
         WHEN TOO_MANY_ROWS THEN
         --raise_application_error (-20003,'ENCONTRADO MAIS DE UM FORNECEDOR PARA O CODIGO ANS INFORMADO: ' || 'CODIGO ANS = ' || REGISTRO_CONCESSAO.CODIGO_ANS_FORNECEDOR || 'CODIGO BENEFICIO = ' || REGISTRO_CONCESSAO.CODIGO_BENEFICIO);
         GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ENCONTRADO MAIS DE UM FORNECEDOR PARA O CODIGO ANS INFORMADO', 'CODIGO ANS = ' || REGISTRO_CONCESSAO.CODIGO_ANS_FORNECEDOR || 'CODIGO BENEFICIO = ' || REGISTRO_CONCESSAO.CODIGO_BENEFICIO);
    WHEN OTHERS THEN
         NULL;
    END;

    IF vCODIGO_FORNECEDOR is NULL THEN
       GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'CODIGO_FORNECEDOR_INVALIDO XXXXX', null);
    END IF;

    IF INSTR(listaFornecedores,PREFIXO_CODIGO_FORNECEDOR||REGISTRO_CONCESSAO.CODIGO_ANS_FORNECEDOR,1) = 0 THEN
       GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'CODIGO_FORNECEDOR_INVALIDO', null);
    END IF;

    IF INSTR(listaFornecedores,PREFIXO_CODIGO_BENEFICIO||REGISTRO_CONCESSAO.CODIGO_BENEFICIO,1) = 0 THEN
       GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'CODIGO_BENEFICIO_INVALIDO', null);
    END IF;

    -- O código do benefício informado tem que estar relacionado ao fornecedor informado
    IF INSTR(listaFornecedores,PREFIXO_CODIGO_FORNECEDOR||REGISTRO_CONCESSAO.CODIGO_ANS_FORNECEDOR||PREFIXO_CODIGO_BENEFICIO||REGISTRO_CONCESSAO.CODIGO_BENEFICIO,1) = 0 THEN
       GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'CODIGO_FORNECEDOR_BENEFICIO_INVALIDO',null);
    END IF;


    -- CPF deve ser válido
    vCPF_VALIDO:= VALIDA_CPF_CNPJ(REGISTRO_CONCESSAO.CPF);

    IF NOT vCPF_VALIDO THEN
       --raise_application_error (-20003,'CPF INVALIDO - ' || REGISTRO_CONCESSAO.CPF);
       GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'CPF INVALIDO', REGISTRO_CONCESSAO.CPF);
    END IF;

    -- CPF deve existir na base de dados de pessoa
    BEGIN
         IF REGISTRO_CONCESSAO.CATEGORIA_BENEFICIARIO = '0001' THEN
            BEGIN
            select P.CODIGO, P.DATA_NASCIMENTO, trunc(months_between(sysdate, P.DATA_NASCIMENTO)/12)
              into vCODIGO_PESSOA, vDATA_NASCIMENTO, vIDADE
              from RHPESS_PESSOA P, RHPESS_CONTRATO C
             where P.CODIGO_EMPRESA = REGISTRO_CONCESSAO.CODIGO_EMPRESA
               and P.CPF = REGISTRO_CONCESSAO.CPF
               and P.CODIGO_EMPRESA = C.CODIGO_EMPRESA
               and P.CODIGO = C.CODIGO_PESSOA
               and C.TIPO_CONTRATO = vTIPO_CONTRATO
               and C.CODIGO = REGISTRO_CONCESSAO.CODIGO_CONTRATO
               and C.ANO_MES_REFERENCIA = (select max(ANO_MES_REFERENCIA)
                                             from RHPESS_CONTRATO AUX
                                            where AUX.CODIGO_EMPRESA = C.CODIGO_EMPRESA
                                              and AUX.TIPO_CONTRATO = C.TIPO_CONTRATO
                                              and AUX.CODIGO = C.CODIGO
                                              and AUX.ANO_MES_REFERENCIA <= sysdate
                                          )
               ;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                     --raise_application_error (-20003,'PESSOA NAO ENCONTRADA PARA O CPF INFORMADO');
                     GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'PESSOA NAO ENCONTRADA PARA O CPF INFORMADO', REGISTRO_CONCESSAO.CPF);
                WHEN TOO_MANY_ROWS THEN
                     BEGIN
                        select P.CODIGO, P.DATA_NASCIMENTO, trunc(months_between(sysdate, P.DATA_NASCIMENTO)/12)
                          into vCODIGO_PESSOA, vDATA_NASCIMENTO, vIDADE
                          from RHPESS_PESSOA P, RHPESS_CONTRATO C
                         where P.CODIGO_EMPRESA = REGISTRO_CONCESSAO.CODIGO_EMPRESA
                           and P.CPF = REGISTRO_CONCESSAO.CPF
                           and P.CODIGO_EMPRESA = C.CODIGO_EMPRESA
                           and P.CODIGO = C.CODIGO_PESSOA
                           and C.TIPO_CONTRATO = vTIPO_CONTRATO
                           and C.ANO_MES_REFERENCIA = (select max(ANO_MES_REFERENCIA)
                                                         from RHPESS_CONTRATO AUX
                                                        where AUX.CODIGO_EMPRESA = C.CODIGO_EMPRESA
                                                          and AUX.TIPO_CONTRATO = C.TIPO_CONTRATO
                                                          and AUX.CODIGO = C.CODIGO
                                                          and AUX.ANO_MES_REFERENCIA <= sysdate
                                                      );
                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         --raise_application_error (-20003,'PESSOA NAO ENCONTRADA PARA O CPF INFORMADO');
                         GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'PESSOA NAO ENCONTRADA PARA O CPF INFORMADO', REGISTRO_CONCESSAO.CPF);
                    WHEN OTHERS THEN
                         --raise_application_error (-20004,'ERRO AO TENTAR LOCALIZAR PESSOA' || REGISTRO_CONCESSAO.CPF);
                         GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ERRO AO TENTAR LOCALIZAR PESSOA', REGISTRO_CONCESSAO.CPF);
                    END;
                WHEN OTHERS THEN
                     NULL;
                     --raise_application_error (-20005,'MAIS DE UMA PESSOA ENCONTRADA PARA O CPF INFORMADO :' || REGISTRO_CONCESSAO.CPF);
                     GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'MAIS DE UMA PESSOA ENCONTRADA PARA O CPF INFORMADO', REGISTRO_CONCESSAO.CPF);
                END;
         ELSE
            BEGIN
            select CODIGO, DATA_NASCIMENTO, trunc(months_between(sysdate, DATA_NASCIMENTO)/12)
              into vCODIGO_PESSOA, vDATA_NASCIMENTO, vIDADE
              from RHPESS_PESSOA P
             where P.CODIGO_EMPRESA = REGISTRO_CONCESSAO.CODIGO_EMPRESA
               and P.CPF = REGISTRO_CONCESSAO.CPF;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                     --raise_application_error (-20006,'DEPENDENTE - PESSOA NAO ENCONTRADA PARA O CPF INFORMADO :' || REGISTRO_CONCESSAO.CPF);
                     GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DEPENDENTE - PESSOA NAO ENCONTRADA PARA O CPF INFORMADO', REGISTRO_CONCESSAO.CPF);
            WHEN TOO_MANY_ROWS THEN
                     BEGIN
                     select CODIGO, DATA_NASCIMENTO, trunc(months_between(sysdate, DATA_NASCIMENTO)/12)
                        into vCODIGO_PESSOA, vDATA_NASCIMENTO, vIDADE
                        from RHPESS_PESSOA P
                       where P.CODIGO_EMPRESA = REGISTRO_CONCESSAO.CODIGO_EMPRESA
                         and P.CPF = REGISTRO_CONCESSAO.CPF
                         and P.CODIGO = (select min(CODIGO)
                                           from RHPESS_PESSOA PP
                                          where PP.CODIGO_EMPRESA = P.CODIGO_EMPRESA
                                            and PP.CPF = P.CPF
                                         );
                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         --raise_application_error (-20007,'DEPENDENTE - PESSOA NAO ENCONTRADA PARA O CPF INFORMADO :' || REGISTRO_CONCESSAO.CPF);
                         GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DEPENDENTE - PESSOA NAO ENCONTRADA PARA O CPF INFORMADO', REGISTRO_CONCESSAO.CPF);
                    WHEN OTHERS THEN
                         --raise_application_error (-20008,'DEPENDENTE - ERRO AO TENTAR LOCALIZAR PESSOA');
                         GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DEPENDENTE - ERRO AO TENTAR LOCALIZAR PESSOA', REGISTRO_CONCESSAO.CPF);
                    END;
            WHEN OTHERS THEN
                --raise_application_error (-20008,'DEPENDENTE - ERRO AO TENTAR LOCALIZAR PESSOA');
                GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DEPENDENTE - ERRO AO TENTAR LOCALIZAR PESSOA', REGISTRO_CONCESSAO.CPF);
            END;
         END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         --raise_application_error (-20010,'PESSOA NAO ENCONTRADA PARA O CPF INFORMADO');
         GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'PESSOA NAO ENCONTRADA PARA O CPF INFORMADO', REGISTRO_CONCESSAO.CPF);
    WHEN TOO_MANY_ROWS THEN
         --raise_application_error (-20011,'ENCONTRADA MAIS DE UMA PESSOA PARA O CPF INFORMADO');
         GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ENCONTRADA MAIS DE UMA PESSOA PARA O CPF INFORMADO', REGISTRO_CONCESSAO.CPF);
    WHEN OTHERS THEN
         --raise_application_error (SQLCODE,SQLERRM);
         GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ERRO AO TENTAR LOCALIZAR PESSOA', REGISTRO_CONCESSAO.CPF);
    END;

    -- Ordem de dependência
    IF REGISTRO_CONCESSAO.CATEGORIA_BENEFICIARIO = '0004' THEN

       BEGIN
       V_NUMERICO := TO_NUMBER(REGISTRO_CONCESSAO.ORDEM_DEPENDENTE);
       EXCEPTION
       WHEN INVALID_NUMBER THEN
          --raise_application_error (-20003,'CATEGORIA DE BENEFICIARIO DEPENDENTE - ORDEM DE DEPENDENCIA INVALIDA. DEVE SER NUMERO MAIOR QUE ZERO.');
          GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'CATEGORIA DE BENEFICIARIO DEPENDENTE - ORDEM DE DEPENDENCIA INVALIDA. DEVE SER NUMERO MAIOR QUE ZERO.', null);
       WHEN OTHERS THEN
          --raise_application_error (-20003,'CATEGORIA DE BENEFICIARIO DEPENDENTE - ORDEM DE DEPENDENCIA INVALIDA. DEVE SER NUMERO MAIOR QUE ZERO.');
          GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'CATEGORIA DE BENEFICIARIO DEPENDENTE - ORDEM DE DEPENDENCIA INVALIDA. DEVE SER NUMERO MAIOR QUE ZERO.', null);
       END;

    ELSE
       IF REGISTRO_CONCESSAO.ORDEM_DEPENDENTE <> 0 THEN
          --raise_application_error (-20003,'CATEGORIA DE BENEFICIARIO DIFERENTE DE DEPENDENTE - ORDEM DE DEPENDENCIA INVALIDA. DEVE SER 00.');
          GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'CATEGORIA DE BENEFICIARIO DIFERENTE DE DEPENDENTE - ORDEM DE DEPENDENCIA INVALIDA. DEVE SER 00.', null);
       END IF;
    END IF;

    -- Exceção de Dependência e Data Fim de Exceção de Dependência
    IF REGISTRO_CONCESSAO.CATEGORIA_BENEFICIARIO in ('0004','0015') THEN
       -- Exceção de Dependência
       BEGIN
         V_NUMERICO := TO_NUMBER(REGISTRO_CONCESSAO.INVALIDEZ);

         IF V_NUMERICO IN (0,1,2) THEN

            IF V_NUMERICO <> 0 THEN
              IF REGISTRO_CONCESSAO.DATA_FIM_ESCOLARIDADE IS NULL THEN
                 GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'EXCEÇÃO DE DEPENDÊNCIA INFORMADA. A DATA FIM DA EXCEÇÃO DEVE SER INFORMADA.', null);
              END IF;
            ELSIF (V_NUMERICO = 0 AND (REGISTRO_CONCESSAO.DATA_FIM_ESCOLARIDADE IS NOT NULL))THEN
              GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DATA FIM DE EXCEÇÃO DE DEPENDÊNCIA INFORMADA. A EXCEÇÃO DEVE SER INFORMADA.', null);
            END IF;
         ELSE
            GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'EXCEÇÃO DE DEPENDÊNCIA INVALIDA. VALORES VÁLIDOS (0,1,2)', null);
         END IF;

       EXCEPTION
       WHEN INVALID_NUMBER THEN
          --raise_application_error (-20003,'CATEGORIA DE BENEFICIARIO DEPENDENTE - ORDEM DE DEPENDENCIA INVALIDA. DEVE SER NUMERO MAIOR QUE ZERO.');
          GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'EXCEÇÃO DE DEPENDÊNCIA INVALIDA. DEVE SER NUMERO MAIOR OU IGUAL A ZERO.', null);
       WHEN OTHERS THEN
          --raise_application_error (-20003,'CATEGORIA DE BENEFICIARIO DEPENDENTE - ORDEM DE DEPENDENCIA INVALIDA. DEVE SER NUMERO MAIOR QUE ZERO.');
          GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'EXCEÇÃO DE DEPENDÊNCIA INVALIDA. DEVE SER NUMERO MAIOR OU IGUAL A ZERO.', null);
       END;

       -- Data Fim de Exceção de Dependência
       -- A data de fim de exceção de dependência deve ser maior ou igual a data atual
       IF REGISTRO_CONCESSAO.DATA_FIM_ESCOLARIDADE IS NOT NULL and REGISTRO_CONCESSAO.DATA_FIM_ESCOLARIDADE < sysdate THEN
          GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DATA_FIM_ESCOLARIDADE_MENOR_QUE_DATA_ATUAL', null);
       END IF;

       -- A data fim de exceção de dependência não pode ser superior à 360 dias
       IF REGISTRO_CONCESSAO.DATA_FIM_ESCOLARIDADE IS NOT NULL and REGISTRO_CONCESSAO.DATA_FIM_ESCOLARIDADE > ADD_MONTHS(sysdate, 12) THEN
          GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DATA_FIM_ESCOLARIDADE_NAO PODE_SER_MAIOR_QUE_12_MESES_DA_DATA_ATUAL',null);
       END IF;

    END IF;

    -- Se a categoria do beneficiário for igual à dependente, e se CPF estiver associado à pessoa com maioridade,
    -- devem estar preenchidos ou o campo de data de fim de escolaridade ou o campo invalidez
    IF REGISTRO_CONCESSAO.CATEGORIA_BENEFICIARIO = '0004'
    AND vIDADE IS NOT NULL
    AND vIDADE > 1800
    AND REGISTRO_CONCESSAO.DATA_FIM_ESCOLARIDADE IS NULL
    AND (REGISTRO_CONCESSAO.INVALIDEZ IS NOT NULL AND REGISTRO_CONCESSAO.INVALIDEZ <> 'S') THEN
       --raise_application_error (-20003,'DEPENDENTE JÁ POSSUI MAIORIDADE. DATA DE FIM DE ESCOLARIDADE OU INDICATIVO DE INVALIDEZ DEVE SER INFORMADA.');
       GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DEPENDENTE JÁ POSSUI MAIORIDADE. DATA DE FIM DE ESCOLARIDADE OU INDICATIVO DE INVALIDEZ DEVE SER INFORMADA.', null);
    END IF;

    -- Se a categoria do beneficiário for igual à dependente, a ordem do dependente deve estar preenchida
    IF REGISTRO_CONCESSAO.CATEGORIA_BENEFICIARIO = '0004'
    AND vIDADE IS NOT NULL
    AND vIDADE > 1
    AND REGISTRO_CONCESSAO.ORDEM_DEPENDENTE IS NULL THEN
       --raise_application_error (-20003,'DEPENDENTE. ORDEM E DEPENDENCIA NÃO FOI INFORMADA.');
       GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DEPENDENTE. ORDEM E DEPENDENCIA NÃO FOI INFORMADA.', null);
    END IF;

    -- Se a categoria do beneficiário for diferente de Titular, o CPF deve estar associado
    -- à pessoa com associada à pessoa do titular do contrato com algum tipo de relacionamento
    IF REGISTRO_CONCESSAO.CATEGORIA_BENEFICIARIO <> '0001' THEN
       BEGIN
          select MIN(TP_RELACIONAMENTO)
            into vTIPO_RELACIONAMENTO
            from RHPESS_RL_PESS_PES PP
           where PP.COD_EMPRESA = REGISTRO_CONCESSAO.CODIGO_EMPRESA
             and PP.COD_PESSOA_RELAC in (select CODIGO from RHPESS_PESSOA
                                          where CODIGO_EMPRESA = REGISTRO_CONCESSAO.CODIGO_EMPRESA
                                            and CPF = REGISTRO_CONCESSAO.CPF)
             and PP.COD_PESSOA = (
                                 select CODIGO_PESSOA
                                   from RHPESS_CONTRATO A
                                  where A.CODIGO_EMPRESA = REGISTRO_CONCESSAO.CODIGO_EMPRESA
                                    and A.TIPO_CONTRATO = vTIPO_CONTRATO
                                    and A.CODIGO = REGISTRO_CONCESSAO.CODIGO_CONTRATO
                                    and A.ANO_MES_REFERENCIA = (select max(ANO_MES_REFERENCIA)
                                                                  from RHPESS_CONTRATO B
                                                                 where B.CODIGO_EMPRESA = A.CODIGO_EMPRESA
                                                                   and B.TIPO_CONTRATO = A.TIPO_CONTRATO
                                                                   and B.CODIGO = A.CODIGO
                                                                )
                                 )
             and TP_RELACIONAMENTO member LISTA_TIPO_RELACI_VALIDO;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
             --raise_application_error (-20003,'DEPENDENTE SEM RELACIOAMENTO PESSOA PESSOA COM O TITULAR: ' || REGISTRO_CONCESSAO.CODIGO_EMPRESA||REGISTRO_CONCESSAO.CODIGO_CONTRATO||REGISTRO_CONCESSAO.CPF||vCODIGO_PESSOA);
             GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DEPENDENTE SEM RELACIOAMENTO PESSOA PESSOA COM O TITULAR', REGISTRO_CONCESSAO.CODIGO_EMPRESA||REGISTRO_CONCESSAO.CODIGO_CONTRATO||REGISTRO_CONCESSAO.CPF||vCODIGO_PESSOA);
        WHEN TOO_MANY_ROWS THEN
             --raise_application_error (-20003,'ENCONTRADO MAIS DE UM RELACIOAMENTO PESSOA PESSOA DO DEPENDENTE COM O TITULAR: ' || REGISTRO_CONCESSAO.CODIGO_EMPRESA||REGISTRO_CONCESSAO.CODIGO_CONTRATO||REGISTRO_CONCESSAO.CPF||vCODIGO_PESSOA);
             GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ENCONTRADO MAIS DE UM RELACIOAMENTO PESSOA PESSOA DO DEPENDENTE COM O TITULAR', REGISTRO_CONCESSAO.CODIGO_EMPRESA||REGISTRO_CONCESSAO.CODIGO_CONTRATO||REGISTRO_CONCESSAO.CPF||vCODIGO_PESSOA);
        WHEN OTHERS THEN
             --raise_application_error (-20003,'ERRO AO TENTAR RECUPERAR RELACIOAMENTO PESSOA PESSOA COM O TITULAR: ' || REGISTRO_CONCESSAO.CODIGO_EMPRESA||REGISTRO_CONCESSAO.CODIGO_CONTRATO||REGISTRO_CONCESSAO.CPF||vCODIGO_PESSOA);
             GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ERRO AO TENTAR RECUPERAR RELACIOAMENTO PESSOA PESSOA COM O TITULAR', REGISTRO_CONCESSAO.CODIGO_EMPRESA||REGISTRO_CONCESSAO.CODIGO_CONTRATO||REGISTRO_CONCESSAO.CPF||vCODIGO_PESSOA);
        END;
    END IF;

    IF REGISTRO_CONCESSAO.TIPO_OPERACAO = 'I' THEN
    -- Se for o tipo de operação de inclusão, não pode haver concessão de benefício vigente, de mesmo tipo de benefício, para o mesmo contrato
    BEGIN
      vJA_POSSUI_PLANO_SAUDE := 0;

      select count(1)
        into vJA_POSSUI_PLANO_SAUDE
        from RHBENF_CONCESSOES CONC, RHBENF_BENEFICIO BENF
       where CONC.CODIGO_EMPRESA = REGISTRO_CONCESSAO.CODIGO_EMPRESA
         and CONC.TIPO_CONTRATO = vTIPO_CONTRATO
         and CONC.CODIGO_CONTRATO = REGISTRO_CONCESSAO.CODIGO_CONTRATO
         and CONC.CODIGO_BENEFIC = vCODIGO_PESSOA
         and CONC.DATA_CANCELAMENTO IS NULL
         and CONC.CODIGO_BENEFICIO = BENF.CODIGO
         and BENF.COD_TIPO_BENEFICIO member (LISTA_TIPO_BENEFICIO)
         and BENF.COD_TIPO_BENEFICIO = (select BB.COD_TIPO_BENEFICIO
                                           from RHBENF_BENEFICIO BB
                                         where BB.CODIGO = REGISTRO_CONCESSAO.CODIGO_BENEFICIO);

         IF vJA_POSSUI_PLANO_SAUDE > 0 THEN
            --raise_application_error (-20003,'BENEFICIARIO JÁ POSSUI PLANO DE SAÚDE VIGENTE PARA O BENEFICIO DE TIPO SIMILAR AO BENEFICIO ' || REGISTRO_CONCESSAO.CODIGO_BENEFICIO);
            GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'BENEFICIARIO JÁ POSSUI PLANO DE SAÚDE VIGENTE PARA O BENEFICIO DE TIPO SIMILAR AO BENEFICIO ', REGISTRO_CONCESSAO.CODIGO_BENEFICIO);
         END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         --raise_application_error (-20003,'DEPENDENTE SEM RELACIOAMENTO PESSOA PESSOA COM O TITULAR');
         GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DEPENDENTE SEM RELACIOAMENTO PESSOA PESSOA COM O TITULAR', null);
    END;

    IF vJA_POSSUI_PLANO_SAUDE = 0 THEN

    BEGIN

    -- recupera a última ocorrência de beneficios de concessões
    -- conforme chave primária
    BEGIN
    vOCORRENCIA := 0;
    select NVL(max(OCORRENCIA),0)
      into vOCORRENCIA
      from RHBENF_CONCESSOES
     where CODIGO_EMPRESA = REGISTRO_CONCESSAO.CODIGO_EMPRESA
       and CODIGO_BENEFIC = vCODIGO_PESSOA
       and DATA_CONCESSAO = REGISTRO_CONCESSAO.DATA_CONCESSAO;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         vOCORRENCIA := 0;
    END;

    vOCORRENCIA := vOCORRENCIA + 1;
    vDATA_ATUALIZACAO := sysdate;
    Insert into RHBENF_CONCESSOES (CODIGO_EMPRESA,
                                   CODIGO_BENEFIC,
                                   DATA_CONCESSAO,
                                   OCORRENCIA,
                                   CODIGO_BENEFICIO,
                                   CATEGORIA_BENEF,
                                   PERCENT_PARTICIPAC,
                                   VALOR_BENEFICIO,
                                   DATA_PAGTO_FOLHA,
                                   DATA_DEPOSITO,
                                   MOTIVO_CONCESSAO,
                                   DATA_CANCELAMENTO,
                                   LOGIN_USUARIO,
                                   DT_ULT_ALTER_USUA,
                                   C_LIVRE_SELEC01,
                                   C_LIVRE_SELEC02,
                                   C_LIVRE_SELEC03,
                                   C_LIVRE_VALOR04,
                                   C_LIVRE_VALOR05,
                                   C_LIVRE_VALOR06,
                                   C_LIVRE_DESCR07,
                                   C_LIVRE_DESCR08,
                                   C_LIVRE_DESCR09,
                                   C_LIVRE_DATA10,
                                   C_LIVRE_DATA11,
                                   C_LIVRE_DATA12,
                                   CODIGO_MOT_CANCEL,
                                   TEXTO_ASSOCIADO,
                                   ASSINATURA_01,
                                   ASSINATURA_02,
                                   ASSINATURA_03,
                                   ASSINATURA_04,
                                   C_LIVRE_OPCAO01,
                                   C_LIVRE_OPCAO02,
                                   C_LIVRE_OPCAO03,
                                   NUMERO_PARCELA,
                                   TIPO_CONTRATO,
                                   CODIGO_CONTRATO,
                                   CODIGO_DOENCA,
                                   ID_AGRUP,
                                   ID_DIMENSAO,
                                   DT_REF_CONCEC_RETR,
                                   DT_REF_CANCEL_RETR,
                                   CODIGO_FORNECEDOR,
                                   MUNICIPIO_ORIGEM,
                                   MUNICIPIO_DESTINO)
                           values (REGISTRO_CONCESSAO.CODIGO_EMPRESA,
                                   vCODIGO_PESSOA,
                                   REGISTRO_CONCESSAO.DATA_CONCESSAO,
                                   vOCORRENCIA,
                                   REGISTRO_CONCESSAO.CODIGO_BENEFICIO,
                                   REGISTRO_CONCESSAO.CATEGORIA_BENEFICIARIO,
                                   '0',
                                   '0',
                                   null,
                                   null,
                                   null,
                                   null,
                                   vUSUARIO,
                                   sysdate,
                                   REGISTRO_CONCESSAO.ORDEM_DEPENDENTE,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null,
                                   REGISTRO_CONCESSAO.NUMERO_CARTEIRA,
                                   REGISTRO_CONCESSAO.NUMERO_PROTOCOLO,
                                   null,
                                   REGISTRO_CONCESSAO.DATA_FIM_ESCOLARIDADE,
                                   null,
                                   null,
                                   REGISTRO_CONCESSAO.OBSERVACAO,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null,
                                   vTIPO_CONTRATO,
                                   REGISTRO_CONCESSAO.CODIGO_CONTRATO,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null,
                                   vCODIGO_FORNECEDOR,
                                   null,
                                   null);

      GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'INCLUSAO DE CONCESSAO DE BENEFICIO', 'CPF: ' || REGISTRO_CONCESSAO.CPF || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);

      -- Grava log do sistema
      REG_APOIO_LOG_SIST.CODIGO_EMPRESA := REGISTRO_CONCESSAO.CODIGO_EMPRESA;
      REG_APOIO_LOG_SIST.CODIGO_BENEFIC := vCODIGO_PESSOA;
      REG_APOIO_LOG_SIST.DATA_CONCESSAO := REGISTRO_CONCESSAO.DATA_CONCESSAO;
      REG_APOIO_LOG_SIST.OCORRENCIA     := vOCORRENCIA;
      GRAVA_LOG_SISTEMA(vDATA_ATUALIZACAO, OBJETO_CONCESSAO_BENEFICIO, vUSUARIO_ATUALIZACAO, 'I', REG_APOIO_LOG_SIST);

    EXCEPTION
       WHEN DUP_VAL_ON_INDEX THEN
          --raise_application_error (-20001,'TENTATIVA DE INSERCAO DE CONCESSÃO JÁ REGISTRADA');
          GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'TENTATIVA DE INSERCAO DE CONCESSÃO JÁ REGISTRADA', 'CPF: ' || REGISTRO_CONCESSAO.CPF || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);

       WHEN OTHERS THEN
          --raise_application_error (-20002,'ERRO AO TENTAR A INSERCAO DE CONCESSÃO');
          GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ERRO AO TENTAR A INSERCAO DE CONCESSÃO', 'CPF: ' || REGISTRO_CONCESSAO.CPF || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
    END;

    ELSE
        GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'TESTE - TENTATIVA DE INSERCAO DE CONCESSÃO JÁ REGISTRADA', 'CPF: ' || REGISTRO_CONCESSAO.CPF);
    END IF;

    ELSIF REGISTRO_CONCESSAO.TIPO_OPERACAO = 'A' THEN


      -- Se for o tipo de operação de alteração, tem que existir concessão de benefício vigente, de mesmo tipo de benefício, para o mesmo contrato e de mesmo número de carteira
    -- Confere se há concessão de benefício para o número de carteira informado.
    BEGIN

      vCODIGO_BENEFICIO := NULL;
      vCODIGO_CATEGORIA_BENEFICIARIO := NULL;
      vCODIGO_PESSOA_BENEFICIARIO := NULL;
      vORDEM_DEPENDENCIA := NULL;
      vEXCECAO_DEPENDENCIA := NULL;
      vDATA_FIM_EXCECAO_DEPENDENCIA := NULL;
      select CONC.CODIGO_BENEFIC, CONC.CODIGO_BENEFICIO, CONC.CATEGORIA_BENEF, CONC.C_LIVRE_SELEC01, CONC.C_LIVRE_SELEC03, CONC.C_LIVRE_DATA11
        into vCODIGO_PESSOA_BENEFICIARIO,
             vCODIGO_BENEFICIO,
             vCODIGO_CATEGORIA_BENEFICIARIO,
             vORDEM_DEPENDENCIA,
             vEXCECAO_DEPENDENCIA,
             vDATA_FIM_EXCECAO_DEPENDENCIA
        from RHBENF_CONCESSOES CONC, RHBENF_BENEFICIO BENF
       where CONC.CODIGO_EMPRESA = REGISTRO_CONCESSAO.CODIGO_EMPRESA
         and CONC.TIPO_CONTRATO = vTIPO_CONTRATO
         and CONC.CODIGO_CONTRATO = REGISTRO_CONCESSAO.CODIGO_CONTRATO
         and CONC.DATA_CANCELAMENTO IS NULL
         and CONC.CODIGO_BENEFICIO = BENF.CODIGO
         and BENF.COD_TIPO_BENEFICIO member LISTA_TIPO_BENEFICIO
         and CONC.CODIGO_BENEFICIO = REGISTRO_CONCESSAO.CODIGO_BENEFICIO
         and CONC.C_LIVRE_DESCR08 = REGISTRO_CONCESSAO.NUMERO_CARTEIRA;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'CONCESSAO DE BENEFICIO NAO ENCONTRADA. NÃO FOI ENCONTRADO PLANO DE SAÚDE COM ESSE NÚMERO DE CARTEIRA.', REGISTRO_CONCESSAO.CODIGO_EMPRESA||vTIPO_CONTRATO||REGISTRO_CONCESSAO.CODIGO_CONTRATO||vCODIGO_PESSOA||REGISTRO_CONCESSAO.CODIGO_BENEFICIO||REGISTRO_CONCESSAO.NUMERO_CARTEIRA || REGISTRO_CONCESSAO.CPF);
    WHEN OTHERS THEN
         NULL;
    END;

    IF vCODIGO_CATEGORIA_BENEFICIARIO = '0001' THEN
       GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'CONCESSAO DE BENEFICIO NAO PODE SER ALTERADA POIS A MESMA ESTÁ RLACIONADA AO BENEFICIARIO TITULAR. ALTERAÇÃO PERMITIDA APENAS PARA BENEFICIÁRIOS DE CATEGORIA DEPENDENTE OU AGREGADO', null);
    ELSE

        -- A data de fim de exceção de dependência deve ser maior ou igual a data atual
        IF REGISTRO_CONCESSAO.DATA_FIM_ESCOLARIDADE IS NOT NULL and REGISTRO_CONCESSAO.DATA_FIM_ESCOLARIDADE < sysdate THEN
          GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DATA_FIM_ESCOLARIDADE_MENOR_QUE_DATA_ATUAL', null);
        END IF;

        -- A data fim de exceção de dependência não pode ser superior à 360 dias
        IF REGISTRO_CONCESSAO.DATA_FIM_ESCOLARIDADE IS NOT NULL and REGISTRO_CONCESSAO.DATA_FIM_ESCOLARIDADE > ADD_MONTHS(sysdate, 12) THEN
          GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DATA_FIM_ESCOLARIDADE_NAO PODE_SER_MAIOR_QUE_12_MESES_DA_DATA_ATUAL',null);
        END IF;

             vHOUVE_ALTERACAO_DADOS := FALSE;

             IF (REGISTRO_CONCESSAO.INVALIDEZ IS NOT NULL AND (( vEXCECAO_DEPENDENCIA IS NOT NULL AND (REGISTRO_CONCESSAO.INVALIDEZ <> vEXCECAO_DEPENDENCIA) ) OR (vEXCECAO_DEPENDENCIA IS NULL))) THEN
                GRAVA_LOG(TIPO_LOG_INFO, Numero_linha, 'ATUALIZAÇÃO DE DADOS DE CONCESSAO - EXCEÇÃO DE DEPENDÊNCIA', 'VALOR ANTERIOR: ' || vEXCECAO_DEPENDENCIA || ' VALOR_ATUAL: ' || REGISTRO_CONCESSAO.INVALIDEZ);
                vEXCECAO_DEPENDENCIA := REGISTRO_CONCESSAO.INVALIDEZ;
                vHOUVE_ALTERACAO_DADOS := TRUE;
             END IF;

             IF (REGISTRO_CONCESSAO.DATA_FIM_ESCOLARIDADE IS NOT NULL AND (( vDATA_FIM_EXCECAO_DEPENDENCIA IS NOT NULL AND (REGISTRO_CONCESSAO.DATA_FIM_ESCOLARIDADE <> vDATA_FIM_EXCECAO_DEPENDENCIA) ) OR (vDATA_FIM_EXCECAO_DEPENDENCIA IS NULL))) THEN
                GRAVA_LOG(TIPO_LOG_INFO, Numero_linha, 'ATUALIZAÇÃO DE DADOS DE CONCESSAO - DATA FIM DE EXCEÇÃO DE DEPENDÊNCIA', 'VALOR ANTERIOR: ' || vDATA_FIM_EXCECAO_DEPENDENCIA || ' VALOR_ATUAL: ' || REGISTRO_CONCESSAO.DATA_FIM_ESCOLARIDADE);
                vDATA_FIM_EXCECAO_DEPENDENCIA := REGISTRO_CONCESSAO.DATA_FIM_ESCOLARIDADE;
                vHOUVE_ALTERACAO_DADOS := TRUE;
             END IF;

             IF (REGISTRO_CONCESSAO.ORDEM_DEPENDENTE IS NOT NULL AND (( vORDEM_DEPENDENCIA IS NOT NULL AND (REGISTRO_CONCESSAO.ORDEM_DEPENDENTE <> vORDEM_DEPENDENCIA) ) OR (vORDEM_DEPENDENCIA IS NULL))) THEN
                GRAVA_LOG(TIPO_LOG_INFO, Numero_linha, 'ATUALIZAÇÃO DE DADOS DE CONCESSAO - ORDEM DE DEPENDÊNCIA', 'VALOR ANTERIOR: ' || vORDEM_DEPENDENCIA || ' VALOR_ATUAL: ' || REGISTRO_CONCESSAO.ORDEM_DEPENDENTE);
                vORDEM_DEPENDENCIA := REGISTRO_CONCESSAO.ORDEM_DEPENDENTE;
                vHOUVE_ALTERACAO_DADOS := TRUE;
             END IF;

             IF (REGISTRO_CONCESSAO.CATEGORIA_BENEFICIARIO IS NOT NULL AND (( vCODIGO_CATEGORIA_BENEFICIARIO IS NOT NULL AND (REGISTRO_CONCESSAO.CATEGORIA_BENEFICIARIO <> vCODIGO_CATEGORIA_BENEFICIARIO) ) OR (vCODIGO_CATEGORIA_BENEFICIARIO IS NULL))) THEN
                GRAVA_LOG(TIPO_LOG_INFO, Numero_linha, 'ATUALIZAÇÃO DE DADOS DE CONCESSAO - CATEGORIA DE BENEFICIÁRIO', 'VALOR ANTERIOR: ' || vCODIGO_CATEGORIA_BENEFICIARIO || ' VALOR_ATUAL: ' || REGISTRO_CONCESSAO.CATEGORIA_BENEFICIARIO);
                vCODIGO_CATEGORIA_BENEFICIARIO := REGISTRO_CONCESSAO.CATEGORIA_BENEFICIARIO;
                vHOUVE_ALTERACAO_DADOS := TRUE;
             END IF;

             IF (REGISTRO_CONCESSAO.OBSERVACAO IS NOT NULL) THEN
                GRAVA_LOG(TIPO_LOG_INFO, Numero_linha, 'ATUALIZAÇÃO DE DADOS DE CONCESSAO - OBSERVACAO (APENSSADO NO TEXTO_ASSOCIADO)', ' ADICIONADO AO VALOR_ANTERIOR O VALOR_ATUAL: ' || REGISTRO_CONCESSAO.OBSERVACAO);
                vHOUVE_ALTERACAO_DADOS := TRUE;
             END IF;

             vDATA_ATUALIZACAO := sysdate;

             IF vHOUVE_ALTERACAO_DADOS THEN
                GRAVA_LOG(TIPO_LOG_INFO, Numero_linha, 'ATUALIZAÇÃO DE DADOS DE CONCESSAO', REGISTRO_CONCESSAO.CODIGO_EMPRESA||vTIPO_CONTRATO||REGISTRO_CONCESSAO.CODIGO_CONTRATO||vCODIGO_PESSOA||REGISTRO_CONCESSAO.CODIGO_BENEFICIO||REGISTRO_CONCESSAO.NUMERO_CARTEIRA || REGISTRO_CONCESSAO.CPF);
                BEGIN
                -- ATUALIZAÇÃO DE BENEFICIO
                update RHBENF_CONCESSOES set CATEGORIA_BENEF = vCODIGO_CATEGORIA_BENEFICIARIO,
                                             TEXTO_ASSOCIADO = CASE WHEN REGISTRO_CONCESSAO.OBSERVACAO IS NOT NULL AND TEXTO_ASSOCIADO IS NULL THEN TO_CHAR(sysdate, 'DD/MM/YYYY') || ' - ATUALIZAÇÃO IMPORTADA - ' || REGISTRO_CONCESSAO.OBSERVACAO
                                                                    WHEN REGISTRO_CONCESSAO.OBSERVACAO IS NOT NULL AND TEXTO_ASSOCIADO IS NOT NULL THEN TEXTO_ASSOCIADO || ' ' ||  TO_CHAR(sysdate, 'DD/MM/YYYY') || ' - ATUALIZAÇÃO IMPORTADA - ' || REGISTRO_CONCESSAO.OBSERVACAO
                                                                    ELSE TEXTO_ASSOCIADO
                                                               END,
                                             C_LIVRE_DATA11 = vDATA_FIM_EXCECAO_DEPENDENCIA,
                                             C_LIVRE_SELEC03 = vEXCECAO_DEPENDENCIA,
                                             C_LIVRE_SELEC01 = vORDEM_DEPENDENCIA,
                                             LOGIN_USUARIO = vUSUARIO,
                                             DT_ULT_ALTER_USUA = sysdate
                 where CODIGO_EMPRESA = REGISTRO_CONCESSAO.CODIGO_EMPRESA
                   and TIPO_CONTRATO = vTIPO_CONTRATO
                   and CODIGO_CONTRATO = REGISTRO_CONCESSAO.CODIGO_CONTRATO
                   and CODIGO_BENEFIC = vCODIGO_PESSOA
                   and CODIGO_BENEFICIO = REGISTRO_CONCESSAO.CODIGO_BENEFICIO
                   and C_LIVRE_DESCR08 = REGISTRO_CONCESSAO.NUMERO_CARTEIRA;

                GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ATUALIZACAO DE CONCESSAO DE BENEFICIO',  'Foram atualizados ' || SQL%ROWCOUNT || 'registros. ' || REGISTRO_CONCESSAO.CODIGO_EMPRESA||vTIPO_CONTRATO||REGISTRO_CONCESSAO.CODIGO_CONTRATO||vCODIGO_PESSOA||REGISTRO_CONCESSAO.CODIGO_BENEFICIO||REGISTRO_CONCESSAO.NUMERO_CARTEIRA || REGISTRO_CONCESSAO.CPF);

                -- Grava log do sistema
                REG_APOIO_LOG_SIST.CODIGO_EMPRESA := REGISTRO_CONCESSAO.CODIGO_EMPRESA;
                REG_APOIO_LOG_SIST.CODIGO_BENEFIC := vCODIGO_PESSOA;
                REG_APOIO_LOG_SIST.DATA_CONCESSAO := REGISTRO_CONCESSAO.DATA_CONCESSAO;
                REG_APOIO_LOG_SIST.OCORRENCIA     := vOCORRENCIA;
                GRAVA_LOG_SISTEMA(vDATA_ATUALIZACAO, OBJETO_CONCESSAO_BENEFICIO, vUSUARIO_ATUALIZACAO, 'A', REG_APOIO_LOG_SIST);

              EXCEPTION
                 WHEN OTHERS THEN
                    --raise_application_error (-20002,'ERRO AO TENTAR CANCELAMENTO DE CONCESSÃO');
                    GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ERRO AO TENTAR A INSERCAO DE CONCESSÃO', 'CPF: ' || REGISTRO_CONCESSAO.CPF || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
              END;
           ELSE
               GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ATUALIZACAO DE CONCESSAO DE BENEFICIO - NENHUM DADO ALTERADO', null);
           END IF;

    END IF;


    ELSIF REGISTRO_CONCESSAO.TIPO_OPERACAO = 'E' THEN

      -- Se a operação for de cancelamento, o motivo do cancelamento e a data de cancelamento devem estar preenchidos
      IF REGISTRO_CONCESSAO.MOTIVO_CANCELAMENTO IS NULL THEN
        GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'MOTIVO_CANCELAMENTO_INVALIDO', null);
      END IF;

      IF REGISTRO_CONCESSAO.DATA_CANCELAMENTO IS NULL THEN
        GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DATA_CANCELAMENTO_INVALIDA', null);
      END IF;

      -- A data de cancelamento deve ser maior ou igual a data da concessão do benefício
      IF REGISTRO_CONCESSAO.DATA_CANCELAMENTO < REGISTRO_CONCESSAO.DATA_CONCESSAO THEN
        GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DATA_CANCELAMENTO_MENOR_QUE_DATA_CONCESSAO', null);
      END IF;

      -- A data de cancelamento não pode ser superior à 360 dias
      IF REGISTRO_CONCESSAO.DATA_CANCELAMENTO > ADD_MONTHS(sysdate, 12) THEN
        GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DATA_CANCELAMENTO_NAO PODE_SER_MAIOR_QUE_12_MESES_DA_DATA_ATUAL', null);
      END IF;


      -- Se for o tipo de operação de alteração, tem que existir concessão de benefício vigente, de mesmo tipo de benefício, para o mesmo contrato e de mesmo número de carteira
    -- Confere se há concessão de benefício para o número de carteira informado.
    BEGIN

      vCODIGO_BENEFICIO := NULL;
      vCODIGO_CATEGORIA_BENEFICIARIO := NULL;
      vCODIGO_PESSOA_BENEFICIARIO := NULL;
      vORDEM_DEPENDENCIA := NULL;
      vEXCECAO_DEPENDENCIA := NULL;
      vDATA_FIM_EXCECAO_DEPENDENCIA := NULL;
      select CONC.CODIGO_BENEFIC, CONC.CODIGO_BENEFICIO, CONC.CATEGORIA_BENEF, CONC.C_LIVRE_SELEC01, CONC.C_LIVRE_SELEC03, CONC.C_LIVRE_DATA11
        into vCODIGO_PESSOA_BENEFICIARIO,
             vCODIGO_BENEFICIO,
             vCODIGO_CATEGORIA_BENEFICIARIO,
             vORDEM_DEPENDENCIA,
             vEXCECAO_DEPENDENCIA,
             vDATA_FIM_EXCECAO_DEPENDENCIA
        from RHBENF_CONCESSOES CONC, RHBENF_BENEFICIO BENF
       where CONC.CODIGO_EMPRESA = REGISTRO_CONCESSAO.CODIGO_EMPRESA
         and CONC.TIPO_CONTRATO = vTIPO_CONTRATO
         and CONC.CODIGO_CONTRATO = REGISTRO_CONCESSAO.CODIGO_CONTRATO
         and CONC.DATA_CANCELAMENTO IS NULL
         and CONC.CODIGO_BENEFICIO = BENF.CODIGO
         and BENF.COD_TIPO_BENEFICIO member LISTA_TIPO_BENEFICIO
         and CONC.CODIGO_BENEFICIO = REGISTRO_CONCESSAO.CODIGO_BENEFICIO
         and CONC.C_LIVRE_DESCR08 = REGISTRO_CONCESSAO.NUMERO_CARTEIRA;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'CONCESSAO DE BENEFICIO NAO ENCONTRADA. NÃO FOI ENCONTRADO PLANO DE SAÚDE COM ESSE NÚMERO DE CARTEIRA.', REGISTRO_CONCESSAO.CODIGO_EMPRESA||vTIPO_CONTRATO||REGISTRO_CONCESSAO.CODIGO_CONTRATO||vCODIGO_PESSOA||REGISTRO_CONCESSAO.CODIGO_BENEFICIO||REGISTRO_CONCESSAO.NUMERO_CARTEIRA || REGISTRO_CONCESSAO.CPF);
    WHEN OTHERS THEN
         NULL;
    END;

      BEGIN
        vDATA_ATUALIZACAO := sysdate;

        -- CANCELAMENTO DE BENEFICIO
        update RHBENF_CONCESSOES set DATA_CANCELAMENTO = REGISTRO_CONCESSAO.DATA_CANCELAMENTO,
                                     CODIGO_MOT_CANCEL = REGISTRO_CONCESSAO.MOTIVO_CANCELAMENTO,
                                     TEXTO_ASSOCIADO = CASE WHEN REGISTRO_CONCESSAO.OBSERVACAO IS NOT NULL AND TEXTO_ASSOCIADO IS NULL THEN TO_CHAR(sysdate, 'DD/MM/YYYY') || ' - ATUALIZAÇÃO IMPORTADA - ' || REGISTRO_CONCESSAO.OBSERVACAO
                                                            WHEN REGISTRO_CONCESSAO.OBSERVACAO IS NOT NULL AND TEXTO_ASSOCIADO IS NOT NULL THEN TEXTO_ASSOCIADO || ' ' ||  TO_CHAR(sysdate, 'DD/MM/YYYY') || ' - ATUALIZAÇÃO IMPORTADA - ' || REGISTRO_CONCESSAO.OBSERVACAO
                                                            ELSE TEXTO_ASSOCIADO
                                                       END,
                                     LOGIN_USUARIO = vUSUARIO,
                                     DT_ULT_ALTER_USUA = sysdate
         where CODIGO_EMPRESA = REGISTRO_CONCESSAO.CODIGO_EMPRESA
           and TIPO_CONTRATO = vTIPO_CONTRATO
           and CODIGO_CONTRATO = REGISTRO_CONCESSAO.CODIGO_CONTRATO
           and CODIGO_BENEFIC = vCODIGO_PESSOA_BENEFICIARIO
           and CODIGO_BENEFICIO = REGISTRO_CONCESSAO.CODIGO_BENEFICIO
           and C_LIVRE_DESCR08 = REGISTRO_CONCESSAO.NUMERO_CARTEIRA;

        GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'CANCELAMENTO DE CONCESSAO DE BENEFICIO', 'Foram atualizados ' || SQL%ROWCOUNT || 'registros. ' || REGISTRO_CONCESSAO.CODIGO_EMPRESA||vTIPO_CONTRATO||REGISTRO_CONCESSAO.CODIGO_CONTRATO||vCODIGO_PESSOA||REGISTRO_CONCESSAO.CODIGO_BENEFICIO||REGISTRO_CONCESSAO.NUMERO_CARTEIRA || REGISTRO_CONCESSAO.CPF);

        -- Grava log do sistema
        REG_APOIO_LOG_SIST.CODIGO_EMPRESA := REGISTRO_CONCESSAO.CODIGO_EMPRESA;
        REG_APOIO_LOG_SIST.CODIGO_BENEFIC := vCODIGO_PESSOA;
        REG_APOIO_LOG_SIST.DATA_CONCESSAO := REGISTRO_CONCESSAO.DATA_CONCESSAO;
        REG_APOIO_LOG_SIST.OCORRENCIA     := vOCORRENCIA;
        GRAVA_LOG_SISTEMA(vDATA_ATUALIZACAO, OBJETO_CONCESSAO_BENEFICIO, vUSUARIO_ATUALIZACAO, 'E', REG_APOIO_LOG_SIST);

      EXCEPTION
         WHEN OTHERS THEN
            --raise_application_error (-20002,'ERRO AO TENTAR CANCELAR CONCESSÃO');
            GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ERRO AO TENTAR CANCELAR CONCESSÃO', null);
      END;
    ELSE
         --raise_application_error (-20001,'TIPO DE OPERAÇÃO INVALIDO');
         GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'TIPO DE OPERAÇÃO INVALIDO', null);
    END IF;

    EXCEPTION
    WHEN OTHERS THEN
         --dbms_output.put_line('ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
         --GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM, null);

         vRETORNO.CODIGO_RETORNO := 99;
         vRETORNO.DESCRICAO_RETORNO := 'PROCESSAMENTO COM ERRO';
         vRETORNO.LISTA_LOG_RETORNO := vLISTA_LOG;
    END;

        vRETORNO.CODIGO_RETORNO := 0;
        vRETORNO.DESCRICAO_RETORNO := 'PROCESSAMENTO OK';
        vRETORNO.LISTA_LOG_RETORNO := vLISTA_LOG;

    IF INDICADOR_TESTE THEN
      ROLLBACK;
    END IF;

    RETURN vRETORNO;
 end;