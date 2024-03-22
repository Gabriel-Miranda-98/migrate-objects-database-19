
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."FU_PS_PROCESSAR_REG_MOVIMENTO" (Numero_linha IN NUMBER, LinhaTexto IN VARCHAR2, NomeArquivo IN VARCHAR2, DataCarga IN DATE, AnoMesReferencia DATE, ListaTipoBeneficio IN LISTA, ListaVerbasDirf IN LISTA, INDICADOR_TESTE BOOLEAN)
RETURN RETORNO_PROCESSAMENTO
 IS
  REG_LOG LOG_PROCESSAMENTO;
  vLISTA_LOG LISTA_LOG;
  vRETORNO RETORNO_PROCESSAMENTO;

  LISTA_TIPO_BENEFICIO LISTA;
  LISTA_VERBAS_DIRF LISTA;
  
  ARQUIVO_MOVIMENTOS      CONSTANT CHAR(4) := '0003';
  ARQUIVO_MOVIMENTOS_DIRF CONSTANT CHAR(4) := '0004';
    
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

  C_TIPO_CONTRATO       CONSTANT CHAR(4) := '0001';
  C_TIPO_MOVIMENTO      CONSTANT CHAR(2) := 'CS';
  C_MODO_OPERACAO       CONSTANT CHAR(1) := 'R';
  C_FASE                CONSTANT CHAR(1) := '0';
  C_ID_CLIENTE          CONSTANT NUMBER := 0;

  OBJETO_SOLICITACAO_MOVIMENTO         CONSTANT VARCHAR2(40) := 'rhmovi_sol_movi';
  OBJETO_MOVIMENTO_BENEFICIARIO        CONSTANT VARCHAR2(40) := 'rhbenf_mov_benefic';

  PREFIXO_CODIGO_FORNECEDOR    CONSTANT VARCHAR2(1) := 'F';
  PREFIXO_CODIGO_BENEFICIO     CONSTANT VARCHAR2(1) := 'B';

  TAMANHO_MAXIMO_LINHA  CONSTANT NUMBER := 155;
  FORMATO_DATA          CONSTANT VARCHAR2(8)  := 'DDMMYYYY';
  FORMATO_DATA_HORA     CONSTANT VARCHAR2(16) := 'DDMMYYYYHH24MISS';

  TYPE REGISTRO_APOIO_LOG_SISTEMA is RECORD(
  CODIGO_EMPRESA             CHAR(4),
  TIPO_CONTRATO              CHAR(4),
  CODIGO_CONTRATO            CHAR(15),
  CODIGO_PESSOA              CHAR(15),
  CODIGO_BENEFICIO           CHAR(15),
  DATA_SOLICITACAO           DATE,
  ANO_MES_REFERENCIA         DATE,
  CODIGO_VERBA               CHAR(4),
  TIPO_MOVIMENTO             CHAR(4),
  ID_CLIENTE                 CHAR(15),
  OCORRENCIA                 NUMBER(4)
  );

  REG_APOIO_LOG_SIST REGISTRO_APOIO_LOG_SISTEMA;

  TYPE MOVIMENTO is RECORD (
     CODIGO_EMPRESA CHAR(4),
     CODIGO_CONTRATO CHAR(15),
     CODIGO_FORNECEDOR CHAR(15),
     CODIGO_VERBA CHAR(4),
     VALOR_VERBA NUMBER,
     CONTADOR CHAR(5),
     REFERENCIA_VERBA CHAR(10),
     DATA_AUTORIZACAO DATE,
     TIPO_OPERACAO CHAR(15),
     CODIGO_CONSIG_ERRO CHAR(2),
     NUMERO_GUIA_IPTU CHAR(13),
     CPF CHAR(11),
     DATA_CADASTRAMENTO DATE,
     NUMERO_CARTEIRA VARCHAR2(30)
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

   TYPE INTERFACE_SERVIDOR IS VARRAY(14) OF INTERFACE;

   TYPE LISTA_CAMPOS_SERVIDOR IS VARRAY(10000) OF LISTA_CAMPOS;

   I_S INTERFACE_SERVIDOR;
   REG LISTA_CAMPOS_SERVIDOR;

   REGISTRO_MOVIMENTO MOVIMENTO;

   vCONTEUDO VARCHAR2(1000);
   vCAMPO VARCHAR2(1000);
   vCARACTERE CHAR(1);
   vCARACTERE_TRANSLATE CHAR(1);
   vCONTADOR NUMBER;
   vTAM_LINHA_PERCORRIDO NUMBER;
   vTAM_REGISTRO  NUMBER;
   vTAM_INTERFACE NUMBER;
   vTAM_LOOP      NUMBER;
   vTAM_LINHA     NUMBER;
   vTAM_CAMPO     NUMBER;
   vCONTADOR_CAMPO NUMBER;
   vCAMPO_PODE_SER_NULO BOOLEAN;
   vUSUARIO VARCHAR2(15) := 'IMPORT_PS';
   vUSUARIO_ATUALIZACAO VARCHAR2(15) := 'IMPORT_PS_A';
   vDATA_ATUALIZACAO DATE;
   vTIPO_CONTRATO CHAR(4) := '0001';
   vCODIGO_PESSOA CHAR(15);
   vCODIGO_PESSOA_BENEFICIARIO CHAR(15);
   vTIPO_RELACIONAMENTO CHAR(4);
   vDATA_NASCIMENTO DATE;
   vIDADE NUMBER;
   vJA_POSSUI_PLANO_SAUDE NUMBER;
   vOCORRENCIA NUMBER;
   vCODIGO_FORNECEDOR CHAR(15);
vlimite_inf_ref NUMBER(11,4);
vlimite_inf_val NUMBER(11,4);
vlimite_inf_cont NUMBER(3);
vlimite_sup_ref NUMBER(16,4);
vlimite_sup_val NUMBER(16,4);
vlimite_sup_cont NUMBER(3);
vCPF_VALIDO BOOLEAN;
vVALOR_BENEFICIO NUMBER(16,4);

 error VARCHAR2(255);
 v_temp1 INTEGER;
 v_data_autoriza DATE;
 v_data_solicitacao DATE;
 v_fim_vigencia DATE;
 v_ini_vigencia DATE;
 v_data2 DATE;
 v_tipo_erro CHAR(4); /*TIPO DE ERRO DESCRITO NA TABELARHPBH_CONSIG_ERRO*/


 vCODIGO_BENEFICIO VARCHAR2(15);
 vCODIGO_CATEGORIA_BENEFICIARIO VARCHAR2(4);

p_ano_mes_referencia date := AnoMesReferencia;
p_data_corte date;
p_usuario VARCHAR2(40);
p_codigo_fornecedor VARCHAR2(40);

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
/*
       'codigo_empresa: 0001
tipo_contrato: 0001
codigo_contrato: 000000000947095
tipo_movimento: CS
data_solicitacao: 12/02/2011 17:17:21
codigo_verba: 240J
ocorrencia: 1',

       'codigo_empresa: 0001
tipo_contr_titular: 0001
cod_contr_titular: 000000000947095
codigo_pessoa: 00000000084153X
codigo_beneficio: 000000000002650
ano_mes_referencia: 01/05/2016 00:00:00
mes_incidencia: 05
id_cliente: 0
codigo_verba: 2TU1',
  */
IF pObjeto = OBJETO_SOLICITACAO_MOVIMENTO THEN
   vKEY_STR := 'codigo_empresa: ' || pReg.CODIGO_EMPRESA ||
               'tipo_contrato: ' || pReg.TIPO_CONTRATO ||
               'codigo_contrato: ' || pReg.CODIGO_CONTRATO ||
               'tipo_movimento: ' || pReg.TIPO_MOVIMENTO ||
               'data_solicitacao: ' || pReg.DATA_SOLICITACAO ||
               'codigo_verba: ' || pReg.CODIGO_VERBA ||
               'ocorrencia: ' || pReg.OCORRENCIA;
ELSIF pObjeto = OBJETO_MOVIMENTO_BENEFICIARIO THEN
   vKEY_STR := 'codigo_empresa: ' || pReg.CODIGO_EMPRESA ||
               'tipo_contr_titular: ' || pReg.TIPO_CONTRATO ||
               'cod_contr_titular: ' || pReg.CODIGO_CONTRATO ||
               'codigo_pessoa: ' || pReg.CODIGO_PESSOA ||
               'codigo_beneficio: ' || pReg.CODIGO_BENEFICIO ||
               'ano_mes_referencia: ' || pReg.ANO_MES_REFERENCIA ||
               'id_cliente: ' || pReg.ID_CLIENTE ||
               'codigo_verba: ' || pReg.CODIGO_VERBA;
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
    WHEN indice = 1  THEN REGISTRO_MOVIMENTO.CODIGO_EMPRESA := valorTexto;
    WHEN indice = 2  THEN REGISTRO_MOVIMENTO.CODIGO_CONTRATO := valorTexto;
    WHEN indice = 3  THEN REGISTRO_MOVIMENTO.CODIGO_FORNECEDOR := valorTexto;
    WHEN indice = 4  THEN REGISTRO_MOVIMENTO.CODIGO_VERBA := valorTexto;
    WHEN indice = 5  THEN REGISTRO_MOVIMENTO.VALOR_VERBA := valorNumero;
    WHEN indice = 6  THEN REGISTRO_MOVIMENTO.CONTADOR := valorTexto;
    WHEN indice = 7  THEN REGISTRO_MOVIMENTO.REFERENCIA_VERBA := valorTexto;
    WHEN indice = 8  THEN REGISTRO_MOVIMENTO.DATA_AUTORIZACAO := valorData;
    WHEN indice = 9  THEN REGISTRO_MOVIMENTO.TIPO_OPERACAO := valorTexto;
    WHEN indice = 10 THEN REGISTRO_MOVIMENTO.CODIGO_CONSIG_ERRO := valorTexto;
    WHEN indice = 11 THEN REGISTRO_MOVIMENTO.NUMERO_GUIA_IPTU := valorTexto;
    WHEN indice = 12 THEN REGISTRO_MOVIMENTO.CPF := valorTexto;
    WHEN indice = 13 THEN REGISTRO_MOVIMENTO.DATA_CADASTRAMENTO := valorData;
    WHEN indice = 14 THEN REGISTRO_MOVIMENTO.NUMERO_CARTEIRA := valorTexto;
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

PROCEDURE IMPRIME_REGISTRO(RG MOVIMENTO) AS
BEGIN
  dbms_output.put_line('*** IMPRESSSÃO REGISTRO ***');
    dbms_output.put_line(RG.CODIGO_EMPRESA);
    dbms_output.put_line(RG.CODIGO_CONTRATO);
    dbms_output.put_line(RG.CODIGO_FORNECEDOR);
    dbms_output.put_line(RG.CODIGO_VERBA);
    dbms_output.put_line(RG.VALOR_VERBA);
    dbms_output.put_line(RG.CONTADOR);
    dbms_output.put_line(RG.REFERENCIA_VERBA);
    dbms_output.put_line(RG.DATA_AUTORIZACAO);
    dbms_output.put_line(RG.TIPO_OPERACAO);
    dbms_output.put_line(RG.CODIGO_CONSIG_ERRO);
    dbms_output.put_line(RG.NUMERO_GUIA_IPTU);
    dbms_output.put_line(RG.CPF);
    dbms_output.put_line(RG.DATA_CADASTRAMENTO);
    dbms_output.put_line(RG.NUMERO_CARTEIRA);
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
/*
   IF (vTAM_LINHA <> TAMANHO_MAXIMO_LINHA) THEN
      GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'TAMANHO DA LINHA INVÁLIDO', 'VALOR_ESPERADO: ' || TAMANHO_MAXIMO_LINHA || ' VALOR_OBTIDO: ' || vTAM_LINHA);
   END IF;
*/
     vCONTADOR := 1;
     I_S := INTERFACE_SERVIDOR();
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'CODIGO_EMPRESA';               I_S(vCONTADOR).TAMANHO_IS := 10;  I_S(vCONTADOR).TAMANHO := 4;   I_S(vCONTADOR).TIPO_IS := TIPO_NUMERICO;     I_S(vCONTADOR).TIPO := TIPO_NUMERICO;     I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'CODIGO_CONTRATO';              I_S(vCONTADOR).TAMANHO_IS := 10;  I_S(vCONTADOR).TAMANHO := 15;  I_S(vCONTADOR).TIPO_IS := TIPO_ALFANUMERICO; I_S(vCONTADOR).TIPO := TIPO_NUMERICO;     I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'CODIGO_FORNECEDOR';            I_S(vCONTADOR).TAMANHO_IS := 10;  I_S(vCONTADOR).TAMANHO := 15;  I_S(vCONTADOR).TIPO_IS := TIPO_NUMERICO;     I_S(vCONTADOR).TIPO := TIPO_NUMERICO;     I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'CODIGO_VERBA';                 I_S(vCONTADOR).TAMANHO_IS := 10;  I_S(vCONTADOR).TAMANHO := 4;   I_S(vCONTADOR).TIPO_IS := TIPO_ALFANUMERICO; I_S(vCONTADOR).TIPO := TIPO_ALFANUMERICO; I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'VALOR_VERBA';                  I_S(vCONTADOR).TAMANHO_IS := 15;  I_S(vCONTADOR).TAMANHO := 15;  I_S(vCONTADOR).TIPO_IS := TIPO_NUMERICO;     I_S(vCONTADOR).TIPO := TIPO_VALOR;        I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'CONTADOR';                     I_S(vCONTADOR).TAMANHO_IS := 5;   I_S(vCONTADOR).TAMANHO := 5;   I_S(vCONTADOR).TIPO_IS := TIPO_NUMERICO;     I_S(vCONTADOR).TIPO := TIPO_NUMERICO;     I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'REFERENCIA_VERBA';             I_S(vCONTADOR).TAMANHO_IS := 10;  I_S(vCONTADOR).TAMANHO := 10;  I_S(vCONTADOR).TIPO_IS := TIPO_NUMERICO;     I_S(vCONTADOR).TIPO := TIPO_NUMERICO;     I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'DATA_AUTORIZACAO';             I_S(vCONTADOR).TAMANHO_IS := 14;  I_S(vCONTADOR).TAMANHO := 14;  I_S(vCONTADOR).TIPO_IS := TIPO_DATA_HORA;    I_S(vCONTADOR).TIPO := TIPO_DATA_HORA;    I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'TIPO_OPERACAO';                I_S(vCONTADOR).TAMANHO_IS := 1;   I_S(vCONTADOR).TAMANHO := 1;   I_S(vCONTADOR).TIPO_IS := TIPO_ALFANUMERICO; I_S(vCONTADOR).TIPO := TIPO_ALFANUMERICO; I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'CODIGO_CONSIG_ERRO ';          I_S(vCONTADOR).TAMANHO_IS := 2;   I_S(vCONTADOR).TAMANHO := 2;   I_S(vCONTADOR).TIPO_IS := TIPO_NUMERICO;     I_S(vCONTADOR).TIPO := TIPO_NUMERICO;     I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;

     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'NUMERO_GUIA_IPTU';             I_S(vCONTADOR).TAMANHO_IS := 13;  I_S(vCONTADOR).TAMANHO := 13;  I_S(vCONTADOR).TIPO_IS := TIPO_NUMERICO;     I_S(vCONTADOR).TIPO := TIPO_NUMERICO;     I_S(vCONTADOR).NULO := SIM; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'CPF';                          I_S(vCONTADOR).TAMANHO_IS := 11;  I_S(vCONTADOR).TAMANHO := 11;  I_S(vCONTADOR).TIPO_IS := TIPO_NUMERICO;     I_S(vCONTADOR).TIPO := TIPO_NUMERICO;     I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'DATA_CADASTRAMENTO';           I_S(vCONTADOR).TAMANHO_IS := 14;  I_S(vCONTADOR).TAMANHO := 14;  I_S(vCONTADOR).TIPO_IS := TIPO_DATA_HORA;    I_S(vCONTADOR).TIPO := TIPO_DATA_HORA;    I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;
     I_S.EXTEND(1); I_S(vCONTADOR).CAMPO := 'NUMERO_CARTEIRA';              I_S(vCONTADOR).TAMANHO_IS := 30;  I_S(vCONTADOR).TAMANHO := 30;  I_S(vCONTADOR).TIPO_IS := TIPO_ALFANUMERICO; I_S(vCONTADOR).TIPO := TIPO_ALFANUMERICO; I_S(vCONTADOR).NULO := NAO; vCONTADOR := vCONTADOR + 1;

    vCONTADOR := 1;
    vTAM_LINHA_PERCORRIDO := 1;
    FOR i in 1..vTAM_LINHA LOOP
        IF vTAM_LINHA_PERCORRIDO >= vTAM_LINHA THEN
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

   vTAM_REGISTRO := REG.COUNT();
   vTAM_INTERFACE := I_S.COUNT();

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

          IF (vTAM_CAMPO > (I_S(i).TAMANHO_IS)) THEN

          GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'TAMANHO DE CAMPO INVÁLIDO', I_S(i).CAMPO  || ' VALOR_ESPERADO =  ' || I_S(i).TAMANHO_IS || ' VALOR_OBTIDO = ' || vTAM_CAMPO);

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

          IF (I_S(i).TIPO_IS = TIPO_DATA) THEN

             BEGIN
             V_DATA := TO_DATE(V_CONTEUDO, FORMATO_DATA);
             ATRIBUI_DADO(i,V_TEXTO, V_NUMERICO, V_DATA);
             EXCEPTION
             WHEN OTHERS THEN

             GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DATA INVÁLIDA', I_S(i).CAMPO || ' VALOR: ' || '|' || V_CONTEUDO  || '|');

             END;

          END IF;

          IF (I_S(i).TIPO_IS = TIPO_DATA_HORA) THEN

             BEGIN
             V_DATA := TO_DATE(V_CONTEUDO, FORMATO_DATA_HORA);
             ATRIBUI_DADO(i,V_TEXTO, V_NUMERICO, V_DATA);
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

         IF (I_S(i).TIPO_IS = TIPO_SIM_NAO) THEN

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
    --IMPRIME_REGISTRO(REGISTRO_MOVIMENTO);

  -- Lista de valores válidos nas bases de dados da Pensão, Ativos e Aposentados 
  -- Pensão      CODIGO_EMPRESA = 0011
  -- Ativos      CODIGO_EMPRESA = 0001
  -- Aposentados CODIGO_EMPRESA = 1700    
  LISTA_TIPO_BENEFICIO := ListaTipoBeneficio;    
  LISTA_VERBAS_DIRF := ListaVerbasDirf; 
  /*                            
  IF REGISTRO_MOVIMENTO.CODIGO_EMPRESA = '0011' THEN
                                          
    LISTA_TIPO_BENEFICIO := LISTA('0025', '0026');  
  ELSE
                                       
    LISTA_TIPO_BENEFICIO := LISTA('0005', '0006');  
  END IF;
*/

  BEGIN -- INICIO VALIDACOES REGRAS

      -- Valores Válidos
      IF REGISTRO_MOVIMENTO.TIPO_OPERACAO NOT IN ('I','A','E') THEN
         GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'TIPO_OPERACAO_INVALIDO', null);
      END IF;
  
      -- Validar Fornecedor
      BEGIN
      vCODIGO_FORNECEDOR := NULL;
  
      select F.CODIGO into vCODIGO_FORNECEDOR
        from RHORGA_FORNECEDOR F
       where F.CODIGO = REGISTRO_MOVIMENTO.CODIGO_FORNECEDOR;
  
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
           raise_application_error (-20003,'FORNECEDOR NAO ENCONTRADO PARA O CODIGO INFORMADO: ' || REGISTRO_MOVIMENTO.CODIGO_FORNECEDOR);
           GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'TIPO_OPERACAO_INVALIDO', null);
      WHEN OTHERS THEN
           NULL;
      END;
    
      -- CPF deve ser válido
      vCPF_VALIDO:= VALIDA_CPF_CNPJ(REGISTRO_MOVIMENTO.CPF);
  
      IF NOT vCPF_VALIDO THEN
         --raise_application_error (-20003,'CPF INVALIDO');
         GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'CPF INVALIDO', REGISTRO_MOVIMENTO.CPF);
      END IF;
  
  
      -- Confere se há concessão de benefício para o número de carteira informado.
      BEGIN
  
        vCODIGO_BENEFICIO := NULL;
        select CONC.CODIGO_BENEFIC, CONC.CODIGO_BENEFICIO, CONC.CATEGORIA_BENEF
          into vCODIGO_PESSOA_BENEFICIARIO,
               vCODIGO_BENEFICIO,
               vCODIGO_CATEGORIA_BENEFICIARIO
          from RHBENF_CONCESSOES CONC, RHBENF_BENEFICIO BENF
         where CONC.CODIGO_EMPRESA = REGISTRO_MOVIMENTO.CODIGO_EMPRESA
           and CONC.TIPO_CONTRATO = vTIPO_CONTRATO
           and CONC.CODIGO_CONTRATO = REGISTRO_MOVIMENTO.CODIGO_CONTRATO
           and CONC.CODIGO_BENEFICIO = BENF.CODIGO
           and BENF.COD_TIPO_BENEFICIO member LISTA_TIPO_BENEFICIO
           and CONC.C_LIVRE_DESCR08 = REGISTRO_MOVIMENTO.NUMERO_CARTEIRA;
  
  
             IF vCODIGO_PESSOA_BENEFICIARIO IS NOT NULL and vCODIGO_CATEGORIA_BENEFICIARIO IS NOT NULL and vCODIGO_CATEGORIA_BENEFICIARIO <> '0001' THEN
             
               BEGIN
                 select PP.TP_RELACIONAMENTO
                   into vTIPO_RELACIONAMENTO
                   from RHPESS_PESSOA P, RHPESS_RL_PESS_PES PP
               where P.CODIGO = PP.COD_PESSOA
                 and P.CODIGO_EMPRESA = PP.COD_EMPRESA
                 and P.CODIGO_EMPRESA = REGISTRO_MOVIMENTO.CODIGO_EMPRESA
                 and PP.COD_PESSOA_RELAC = vCODIGO_PESSOA_BENEFICIARIO;
               EXCEPTION
                WHEN NO_DATA_FOUND THEN          
                    BEGIN
                     select PP.TP_RELACIONAMENTO
                       into vTIPO_RELACIONAMENTO
                       from RHPESS_PESSOA P, RHPESS_RL_PESS_PES PP
                   where P.CODIGO = PP.COD_PESSOA
                     and P.CODIGO_EMPRESA = PP.COD_EMPRESA
                     and P.CODIGO_EMPRESA = REGISTRO_MOVIMENTO.CODIGO_EMPRESA
                     and PP.COD_PESSOA_RELAC in (select CODIGO from RHPESS_PESSOA 
                                                  where CODIGO_EMPRESA = P.CODIGO_EMPRESA
                                                    and CPF = REGISTRO_MOVIMENTO.CPF
                                                );
                   EXCEPTION
                    WHEN NO_DATA_FOUND THEN          
                         vTIPO_RELACIONAMENTO := 0;           
                         GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'NÃO FOI POSSÍVEL RECUPERAR o TIPO DE RELACIONAMENTO DO BENEFICIÁRIO INFORMADO.', REGISTRO_MOVIMENTO.CODIGO_EMPRESA||vTIPO_CONTRATO||REGISTRO_MOVIMENTO.CODIGO_CONTRATO||vCODIGO_PESSOA||REGISTRO_MOVIMENTO.NUMERO_CARTEIRA || REGISTRO_MOVIMENTO.CPF);
                    WHEN OTHERS THEN
                         vTIPO_RELACIONAMENTO := 0; 
                    END;
                WHEN OTHERS THEN
                     vTIPO_RELACIONAMENTO := 0; 
                END;
             END IF;
             
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
           --raise_application_error (-20003, '1NUMERO CARTEIRA INVALIDO. NÃO FOI ENCONTRADO PLANO DE SAÚDE COM ESSE NÚMERO DE CARTEIRA.' || 'DETALHE:' || REGISTRO_MOVIMENTO.CODIGO_EMPRESA||vTIPO_CONTRATO||REGISTRO_MOVIMENTO.CODIGO_CONTRATO||vCODIGO_PESSOA||REGISTRO_MOVIMENTO.NUMERO_CARTEIRA);
           GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'NUMERO CARTEIRA INVALIDO. NÃO FOI ENCONTRADO PLANO DE SAÚDE COM ESSE NÚMERO DE CARTEIRA.', REGISTRO_MOVIMENTO.CODIGO_EMPRESA||vTIPO_CONTRATO||REGISTRO_MOVIMENTO.CODIGO_CONTRATO||vCODIGO_PESSOA||REGISTRO_MOVIMENTO.NUMERO_CARTEIRA || REGISTRO_MOVIMENTO.CPF);
      WHEN OTHERS THEN
           NULL;
      END;
      
       IF TO_CHAR(REGISTRO_MOVIMENTO.DATA_AUTORIZACAO,'YYYYMM') <> TO_CHAR(p_ano_mes_referencia,'YYYYMM') THEN
          GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DATA DE AUTORIZACAO/REFERENCIA INVALIDA.', REGISTRO_MOVIMENTO.CODIGO_EMPRESA||vTIPO_CONTRATO||REGISTRO_MOVIMENTO.CODIGO_CONTRATO||vCODIGO_PESSOA||REGISTRO_MOVIMENTO.NUMERO_CARTEIRA || REGISTRO_MOVIMENTO.CPF);
       END IF;      
    
    
    
    IF nomeArquivo = ARQUIVO_MOVIMENTOS_DIRF THEN
       
       IF REGISTRO_MOVIMENTO.CODIGO_VERBA not member LISTA_VERBAS_DIRF THEN
          GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'CODIGO DE VERBA INVALIDO. VALORES VÁLIDOS SÃO 24I8, 24I9 e 16I8', REGISTRO_MOVIMENTO.CODIGO_EMPRESA||vTIPO_CONTRATO||REGISTRO_MOVIMENTO.CODIGO_CONTRATO||vCODIGO_PESSOA||REGISTRO_MOVIMENTO.NUMERO_CARTEIRA || REGISTRO_MOVIMENTO.CPF);
       END IF;
       
       IF REGISTRO_MOVIMENTO.VALOR_VERBA <= 0 THEN
          GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'VALOR DE VERBA INVALIDO. VALOR DEVE SER MAIOR OU IGUAL A ZERO.', REGISTRO_MOVIMENTO.CODIGO_EMPRESA||vTIPO_CONTRATO||REGISTRO_MOVIMENTO.CODIGO_CONTRATO||vCODIGO_PESSOA||REGISTRO_MOVIMENTO.NUMERO_CARTEIRA || REGISTRO_MOVIMENTO.CPF);
       END IF;
       
       IF REGISTRO_MOVIMENTO.TIPO_OPERACAO = 'I' THEN
        
        
        -- Inclui movimento de beneficiário
        BEGIN
        BEGIN
        vDATA_ATUALIZACAO := sysdate;
        
        insert into RHBENF_MOV_BENEFIC (CODIGO_EMPRESA,
                                        TIPO_CONTR_TITULAR,
                                        COD_CONTR_TITULAR,
                                        CODIGO_PESSOA,
                                        TP_RELACIONAMENTO,
                                        CODIGO_BENEFICIO,
                                        ANO_MES_REFERENCIA,
                                        MES_INCIDENCIA,
                                        VALOR_BENEFICIO,
                                        CODIGO_VERBA,
                                        REF_VERBA,
                                        CONSIDERA_DIRF,
                                        CTRL_LANCAMENTO,
                                        C_LIVRE_SELEC01,
                                        C_LIVRE_VALOR01,
                                        C_LIVRE_OPCAO01,
                                        ID_CLIENTE,
                                        LOGIN_USUARIO,
                                        DT_ULT_ALTER_USUA )
        values(
              REGISTRO_MOVIMENTO.CODIGO_EMPRESA,
              C_TIPO_CONTRATO,
              REGISTRO_MOVIMENTO.CODIGO_CONTRATO,
              vCODIGO_PESSOA_BENEFICIARIO,
              vTIPO_RELACIONAMENTO,
              vCODIGO_BENEFICIO,
              p_ano_mes_referencia,
              to_CHAR(p_ano_mes_referencia, 'MM'),
              REGISTRO_MOVIMENTO.VALOR_VERBA,
              REGISTRO_MOVIMENTO.CODIGO_VERBA,
              REGISTRO_MOVIMENTO.REFERENCIA_VERBA,
              'N',
              '0',
              '0',
              '0',
              'N',
              C_ID_CLIENTE,
              vUSUARIO,
              SYSDATE
        );
        GRAVA_LOG(TIPO_LOG_INFO, Numero_linha, 'INCLUSAO DE MOVIMENTO DE BENEFICIARIO',null);
  
          -- Grava log do sistema
          REG_APOIO_LOG_SIST.CODIGO_EMPRESA    := REGISTRO_MOVIMENTO.CODIGO_EMPRESA;
          REG_APOIO_LOG_SIST.TIPO_CONTRATO     := C_TIPO_CONTRATO;
          REG_APOIO_LOG_SIST.CODIGO_CONTRATO   := REGISTRO_MOVIMENTO.CODIGO_CONTRATO;
          REG_APOIO_LOG_SIST.CODIGO_PESSOA     := vCODIGO_PESSOA_BENEFICIARIO;
          REG_APOIO_LOG_SIST.CODIGO_BENEFICIO  := vCODIGO_BENEFICIO;
          REG_APOIO_LOG_SIST.DATA_SOLICITACAO  := REGISTRO_MOVIMENTO.DATA_CADASTRAMENTO;
          REG_APOIO_LOG_SIST.ANO_MES_REFERENCIA:= p_ano_mes_referencia;
          REG_APOIO_LOG_SIST.CODIGO_VERBA      := REGISTRO_MOVIMENTO.CODIGO_VERBA;
          REG_APOIO_LOG_SIST.TIPO_MOVIMENTO    := C_TIPO_MOVIMENTO;
          REG_APOIO_LOG_SIST.ID_CLIENTE        := C_ID_CLIENTE;
          REG_APOIO_LOG_SIST.OCORRENCIA        := 1;
          GRAVA_LOG_SISTEMA(vDATA_ATUALIZACAO, OBJETO_MOVIMENTO_BENEFICIARIO, vUSUARIO_ATUALIZACAO, 'I', REG_APOIO_LOG_SIST);
  
         EXCEPTION
         WHEN OTHERS THEN
              GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ERRO AO TENTAR INCLUIR MOVIMENTO DE BENEFICIARIO','ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM || ' - DETALHES: ' || REGISTRO_MOVIMENTO.CODIGO_CONTRATO || vCODIGO_PESSOA_BENEFICIARIO || vCODIGO_BENEFICIO || p_ano_mes_referencia || REGISTRO_MOVIMENTO.CODIGO_VERBA|| 'TIPO_RELACIONAMENTO = ' || vTIPO_RELACIONAMENTO || '|');
         END;
  
        EXCEPTION
           WHEN DUP_VAL_ON_INDEX THEN
              --raise_application_error (-20001,'TENTATIVA DE INCLUSÃO DE REGITROS JÁ CADASTRADOS');
              GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'TENTATIVA DE INCLUSÃO DE REGITROS JÁ CADASTRADOS',null);
  
           WHEN OTHERS THEN
              --raise_application_error (-20002,'OCORREU UM ERRO AO TENTAR INCLUIR REGISTRO');
              GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'OCORREU UM ERRO AO TENTAR INCLUIR REGISTRO', 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
        END;
  
      ---------------------------------------------------------------------------
  
      ELSIF REGISTRO_MOVIMENTO.TIPO_OPERACAO = 'A' THEN
         NULL;
      ELSIF REGISTRO_MOVIMENTO.TIPO_OPERACAO = 'E' THEN
         NULL;
      ELSE
           --raise_application_error (-20001,'TIPO DE OPERAÇÃO INVALIDO');
           GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'TIPO DE OPERAÇÃO INVALIDO',null);
      END IF;    
    
    ELSE
    
      -- Valores Válidos
      IF REGISTRO_MOVIMENTO.TIPO_OPERACAO NOT IN ('I','A','E') THEN
         GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'TIPO_OPERACAO_INVALIDO', null);
      END IF;
  
      -- Validar Fornecedor
      BEGIN
      vCODIGO_FORNECEDOR := NULL;
  
      select F.CODIGO into vCODIGO_FORNECEDOR
        from RHORGA_FORNECEDOR F
       where F.CODIGO = REGISTRO_MOVIMENTO.CODIGO_FORNECEDOR
         --and F.CODIGO_EMPRESA = REGISTRO_MOVIMENTO.CODIGO_EMPRESA
         ;
  
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
           raise_application_error (-20003,'FORNECEDOR NAO ENCONTRADO PARA O CODIGO INFORMADO: ' || REGISTRO_MOVIMENTO.CODIGO_FORNECEDOR);
           GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'TIPO_OPERACAO_INVALIDO', null);
      WHEN OTHERS THEN
           NULL;
      END;
  
      -- Validar Verba / Fornecedor
      BEGIN
      vCODIGO_FORNECEDOR := NULL;
      vlimite_inf_ref := 0;
      vlimite_inf_val:= 0;
      vlimite_inf_cont:= 0;
      vlimite_sup_ref:= 0;
      vlimite_sup_val:= 0;
      vlimite_sup_cont:= 0;
  
      select F.CODIGO, limite_inf_ref, limite_inf_val, limite_inf_cont,
             limite_sup_ref, limite_sup_val, limite_sup_cont
        into vCODIGO_FORNECEDOR,
             vlimite_inf_ref,vlimite_inf_val,vlimite_inf_cont,
             vlimite_sup_ref,vlimite_sup_val,vlimite_sup_cont
        from RHORGA_FORNECEDOR F, RHORGA_FORN_VERBA V
       where F.CODIGO = REGISTRO_MOVIMENTO.CODIGO_FORNECEDOR
        -- and F.CODIGO_EMPRESA = REGISTRO_MOVIMENTO.CODIGO_EMPRESA
         and V.CODIGO_VERBA = REGISTRO_MOVIMENTO.CODIGO_VERBA;
  
         IF NOT REGISTRO_MOVIMENTO.VALOR_VERBA BETWEEN vlimite_inf_val AND vlimite_sup_val  THEN
            GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'VALOR DE VERBA INVALIDO - FORA DE LIMITE: ', ' De ' ||  vlimite_inf_val || ' Até ' || vlimite_sup_val || ' CODIGO_VERBA: ' || REGISTRO_MOVIMENTO.CODIGO_VERBA || ' VALOR INFORMADO: ' || REGISTRO_MOVIMENTO.VALOR_VERBA || ' CPF: ' || REGISTRO_MOVIMENTO.CPF);
         END IF;
  
         IF NOT REGISTRO_MOVIMENTO.CONTADOR BETWEEN vlimite_inf_cont AND vlimite_sup_cont  THEN
            GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'CONTADOR DE VERBA INVALIDO - FORA DE LIMITE: ', ' De ' ||  vlimite_inf_cont || ' Até ' || vlimite_sup_cont|| ' CODIGO_VERBA: ' || REGISTRO_MOVIMENTO.CODIGO_VERBA || ' VALOR INFORMADO: ' || REGISTRO_MOVIMENTO.CONTADOR || ' CPF: ' || REGISTRO_MOVIMENTO.CPF);
         END IF;
  
         IF NOT REGISTRO_MOVIMENTO.REFERENCIA_VERBA BETWEEN vlimite_inf_ref AND vlimite_sup_ref  THEN
            GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'REFERENCIA DE VERBA INVALIDO - FORA DE LIMITE: ',' De ' ||  vlimite_inf_ref || ' Até ' || vlimite_sup_ref|| ' CODIGO_VERBA: ' || REGISTRO_MOVIMENTO.CODIGO_VERBA || ' VALOR INFORMADO: ' || REGISTRO_MOVIMENTO.REFERENCIA_VERBA || ' CPF: ' || REGISTRO_MOVIMENTO.CPF);
         END IF;
  
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
           --raise_application_error (-20003,'VERBA NÃO CADASTRADA PARA O FORNECEDOR INFORMADO: ' || REGISTRO_MOVIMENTO.CODIGO_FORNECEDOR || REGISTRO_MOVIMENTO.CODIGO_VERBA);
           GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'VERBA NÃO CADASTRADA PARA O FORNECEDOR INFORMADO', REGISTRO_MOVIMENTO.CODIGO_FORNECEDOR || REGISTRO_MOVIMENTO.CODIGO_VERBA);
      WHEN OTHERS THEN
           NULL;
      END;
  
      -- CPF deve ser válido
      vCPF_VALIDO:= VALIDA_CPF_CNPJ(REGISTRO_MOVIMENTO.CPF);
  
      IF NOT vCPF_VALIDO THEN
         --raise_application_error (-20003,'CPF INVALIDO');
         GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'CPF INVALIDO', REGISTRO_MOVIMENTO.CPF);
      END IF;
  
  
      -- Confere se há concessão de benefício para o número de carteira informado.
      BEGIN
  
        vCODIGO_BENEFICIO := NULL;
        select CONC.CODIGO_BENEFIC, CONC.CODIGO_BENEFICIO, CONC.CATEGORIA_BENEF
          into vCODIGO_PESSOA_BENEFICIARIO,
               vCODIGO_BENEFICIO,
               vCODIGO_CATEGORIA_BENEFICIARIO
          from RHBENF_CONCESSOES CONC, RHBENF_BENEFICIO BENF
         where CONC.CODIGO_EMPRESA = REGISTRO_MOVIMENTO.CODIGO_EMPRESA
           and CONC.TIPO_CONTRATO = vTIPO_CONTRATO
           and CONC.CODIGO_CONTRATO = REGISTRO_MOVIMENTO.CODIGO_CONTRATO
           --and CONC.DATA_CANCELAMENTO IS NULL
           and CONC.CODIGO_BENEFICIO = BENF.CODIGO
           and BENF.COD_TIPO_BENEFICIO member LISTA_TIPO_BENEFICIO
           and CONC.C_LIVRE_DESCR08 = REGISTRO_MOVIMENTO.NUMERO_CARTEIRA;
  
  /*
             IF vCODIGO_PESSOA IS NOT NULL and vCODIGO_CATEGORIA_BENEFICIARIO IS NOT NULL and vCODIGO_CATEGORIA_BENEFICIARIO <> '0001' THEN
  
               select PP.TP_RELACIONAMENTO
                 into vTIPO_RELACIONAMENTO
                 from RHPESS_PESSOA P, RHPESS_RL_PESS_PES PP
             where P.CODIGO = PP.COD_PESSOA
               and P.CODIGO_EMPRESA = PP.COD_EMPRESA
               and P.CODIGO_EMPRESA = REGISTRO_MOVIMENTO.CODIGO_EMPRESA
               and P.CODIGO = vCODIGO_PESSOA;
  
             END IF;
             */
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
           --raise_application_error (-20003, '1NUMERO CARTEIRA INVALIDO. NÃO FOI ENCONTRADO PLANO DE SAÚDE COM ESSE NÚMERO DE CARTEIRA.' || 'DETALHE:' || REGISTRO_MOVIMENTO.CODIGO_EMPRESA||vTIPO_CONTRATO||REGISTRO_MOVIMENTO.CODIGO_CONTRATO||vCODIGO_PESSOA||REGISTRO_MOVIMENTO.NUMERO_CARTEIRA);
           GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'NUMERO CARTEIRA INVALIDO. NÃO FOI ENCONTRADO PLANO DE SAÚDE COM ESSE NÚMERO DE CARTEIRA.', REGISTRO_MOVIMENTO.CODIGO_EMPRESA||vTIPO_CONTRATO||REGISTRO_MOVIMENTO.CODIGO_CONTRATO||vCODIGO_PESSOA||REGISTRO_MOVIMENTO.NUMERO_CARTEIRA || REGISTRO_MOVIMENTO.CPF);
      WHEN OTHERS THEN
           NULL;
      END;
  
      IF vCODIGO_CATEGORIA_BENEFICIARIO = '0001' THEN
      -- CPF deve existir na base de dados de pessoa
  
  BEGIN
        select P.CODIGO, P.DATA_NASCIMENTO, trunc(months_between(sysdate, P.DATA_NASCIMENTO)/12)
          into vCODIGO_PESSOA, vDATA_NASCIMENTO, vIDADE
          from RHPESS_PESSOA P, RHPESS_CONTRATO C
         where P.CODIGO_EMPRESA = REGISTRO_MOVIMENTO.CODIGO_EMPRESA
           and P.CPF = REGISTRO_MOVIMENTO.CPF
           and P.CODIGO_EMPRESA = C.CODIGO_EMPRESA
           and P.CODIGO = C.CODIGO_PESSOA
           and C.TIPO_CONTRATO = vTIPO_CONTRATO
           and C.CODIGO = REGISTRO_MOVIMENTO.CODIGO_CONTRATO
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
         GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'NAO ENCONTRADO REGISTRO DE PESSOA TITULAR PARA O BENEFICIO E O CPF INFORMADO.', 'CONTRATO: ' || REGISTRO_MOVIMENTO.CODIGO_CONTRATO || ' CPF: ' || REGISTRO_MOVIMENTO.CPF || ' NUMERO_CARTEIRA: ' || REGISTRO_MOVIMENTO.NUMERO_CARTEIRA);
      WHEN TOO_MANY_ROWS THEN
        GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ENCONTRADO MAIS DE UM REGISTRO DE PESSOA TITULAR PARA O BENEFICIO E O CPF INFORMADO.', 'CONTRATO: ' || REGISTRO_MOVIMENTO.CODIGO_CONTRATO || ' CPF: ' || REGISTRO_MOVIMENTO.CPF || ' NUMERO_CARTEIRA: ' || REGISTRO_MOVIMENTO.NUMERO_CARTEIRA);
      WHEN OTHERS THEN
        GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ERRO AO TENTAR RECUPERAR PESSOA TITULAR PARA O BENEFICIO E O CPF INFORMADO.', 'CONTRATO: ' || REGISTRO_MOVIMENTO.CODIGO_CONTRATO || ' CPF: ' || REGISTRO_MOVIMENTO.CPF || ' NUMERO_CARTEIRA: ' || REGISTRO_MOVIMENTO.NUMERO_CARTEIRA);
      END;
  
  
      ELSE
   BEGIN
  
              select P.CODIGO, P.DATA_NASCIMENTO, trunc(months_between(sysdate, P.DATA_NASCIMENTO)/12)
                into vCODIGO_PESSOA, vDATA_NASCIMENTO, vIDADE
                from RHPESS_PESSOA P, RHPESS_PESSOA TIT, RHPESS_RL_PESS_PES PP
               where P.CODIGO_EMPRESA = REGISTRO_MOVIMENTO.CODIGO_EMPRESA
                 and P.CPF = REGISTRO_MOVIMENTO.CPF
                 and P.CODIGO_EMPRESA = PP.COD_EMPRESA
                 and P.CODIGO = PP.COD_PESSOA_RELAC
                 and PP.COD_EMPRESA = TIT.CODIGO_EMPRESA
                 and PP.COD_PESSOA = TIT.CODIGO
                 and TIT.CODIGO in (select CODIGO_PESSOA
                                           from RHPESS_CONTRATO C
                                          where C.CODIGO_EMPRESA = TIT.CODIGO_EMPRESA
                                            and C.CODIGO = REGISTRO_MOVIMENTO.CODIGO_CONTRATO
                                            and C.ANO_MES_REFERENCIA = (select max(ANO_MES_REFERENCIA)
                                               from RHPESS_CONTRATO AUX
                                              where AUX.CODIGO_EMPRESA = C.CODIGO_EMPRESA
                                                and AUX.TIPO_CONTRATO = C.TIPO_CONTRATO
                                                and AUX.CODIGO = C.CODIGO
                                                and AUX.ANO_MES_REFERENCIA <= sysdate
                                            )
                                            );
                                      /*
              select CODIGO, DATA_NASCIMENTO, trunc(months_between(sysdate, DATA_NASCIMENTO)/12)
                into vCODIGO_PESSOA, vDATA_NASCIMENTO, vIDADE
                from RHPESS_PESSOA P
               where P.CODIGO_EMPRESA = REGISTRO_MOVIMENTO.CODIGO_EMPRESA
                 and P.CPF = REGISTRO_MOVIMENTO.CPF;
                 */
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
             GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'NAO ENCONTRADO REGISTRO DE PESSOA DEPENDENTE/AGREGADO PARA O BENEFICIO E O CPF INFORMADO.', 'CONTRATO: ' || REGISTRO_MOVIMENTO.CODIGO_CONTRATO || ' CPF: ' || REGISTRO_MOVIMENTO.CPF || ' NUMERO_CARTEIRA: ' || REGISTRO_MOVIMENTO.NUMERO_CARTEIRA);
          WHEN TOO_MANY_ROWS THEN
            GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ENCONTRADO MAIS DE UM REGISTRO DE PESSOA DEPENDENTE/AGREGADO PARA O BENEFICIO E O CPF INFORMADO.', 'CONTRATO: ' || REGISTRO_MOVIMENTO.CODIGO_CONTRATO || ' CPF: ' || REGISTRO_MOVIMENTO.CPF || ' NUMERO_CARTEIRA: ' || REGISTRO_MOVIMENTO.NUMERO_CARTEIRA);
          WHEN OTHERS THEN
            GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ERRO AO TENTAR RECUPERAR PESSOA DEPENDENTE/AGREGADO PARA O BENEFICIO E O CPF INFORMADO.', 'CONTRATO: ' || REGISTRO_MOVIMENTO.CODIGO_CONTRATO || ' CPF: ' || REGISTRO_MOVIMENTO.CPF || ' NUMERO_CARTEIRA: ' || REGISTRO_MOVIMENTO.NUMERO_CARTEIRA);
          END;
      END IF;
      /*
      -- Confere valor do plano de saúde
      BEGIN
          select VALOR
            into vVALOR_BENEFICIO
            from VW_TABELA_PLANO_SAUDE_PBH PS
           where PS.FAIXA_ETARIA = (select min(FAIXA_ETARIA) from VW_TABELA_PLANO_SAUDE_PBH
                                     where FAIXA_ETARIA > vIDADE)
             and PS.PLANO = vCODIGO_BENEFICIO;
  
           IF vVALOR_BENEFICIO <> REGISTRO_MOVIMENTO.VALOR_VERBA THEN
              GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'VALOR DO PLANO INFORMADO É DIFERENTE DO VALOR DO PLANO CADASTRADO NA PBH', 'BENEFICIO = ' || vCODIGO_BENEFICIO || 'IDADE = ' || vIDADE || ' VALOR CADASTRADO = ' || vVALOR_BENEFICIO || 'VALOR INFORMADO = ' || REGISTRO_MOVIMENTO.VALOR_VERBA);
           END IF;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
           GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'VALOR DO PLANO NÃO ENCONTRADO. NÃO FOI POSSIVEL VALIDAR VALOR RECEBIDO COM O VALOR DO PLANO CADASTRADO NA PBH', 'BENEFICIO = ' || vCODIGO_BENEFICIO || 'IDADE = ' || vIDADE);
      WHEN TOO_MANY_ROWS THEN
           GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ENCONTRADO MAIS DE UM VALOR PARA O PLANO. NÃO FOI POSSIVEL VALIDAR VALOR RECEBIDO COM O VALOR DO PLANO CADASTRADO NA PBH', 'BENEFICIO = ' || vCODIGO_BENEFICIO || 'IDADE = ' || vIDADE);
      WHEN OTHERS THEN
           GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ERRO AO TENTAR VALIDAR VALOR DE BENEFICIO', 'BENEFICIO = ' || vCODIGO_BENEFICIO || 'IDADE = ' || vIDADE);
      END;
      */
      IF REGISTRO_MOVIMENTO.TIPO_OPERACAO in  ('I', 'A') THEN
      -- Se for o tipo de operação de inclusão, não pode haver concessão de benefício vigente, de mesmo tipo de benefício, para o mesmo contrato
      BEGIN
        vJA_POSSUI_PLANO_SAUDE := 0;
  /*
        select count(1)
          into vJA_POSSUI_PLANO_SAUDE
          from RHBENF_CONCESSOES CONC, RHBENF_BENEFICIO BENF
         where CONC.CODIGO_EMPRESA = REGISTRO_MOVIMENTO.CODIGO_EMPRESA
           and CONC.TIPO_CONTRATO = vTIPO_CONTRATO
           and CONC.CODIGO_CONTRATO = REGISTRO_MOVIMENTO.CODIGO_CONTRATO
           and CONC.CODIGO_BENEFIC = vCODIGO_PESSOA
           and CONC.DATA_CANCELAMENTO IS NULL
           and CONC.CODIGO_BENEFICIO = BENF.CODIGO
           and BENF.COD_TIPO_BENEFICIO in ('0003', '0005', '0006')
           and BENF.COD_TIPO_BENEFICIO = (select BB.COD_TIPO_BENEFICIO
                                             from RHBENF_BENEFICIO BB
                                           where BB.CODIGO = REGISTRO_MOVIMENTO.CODIGO_BENEFICIO);
  */
  
           IF vJA_POSSUI_PLANO_SAUDE > 0 THEN
              --raise_application_error (-20003,'BENEFICIARIO JÁ POSSUI PLANO DE SAÚDE VIGENTE PARA O BENEFICIO DE TIPO SIMILAR AO BENEFICIO');
              GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'BENEFICIARIO JÁ POSSUI PLANO DE SAÚDE VIGENTE PARA O BENEFICIO DE TIPO SIMILAR AO BENEFICIO',null);
           END IF;
  
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
           --raise_application_error (-20003,'DEPENDENTE SEM RELACIOAMENTO PESSOA PESSOA COM O TITULAR');
           GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'DEPENDENTE SEM RELACIOAMENTO PESSOA PESSOA COM O TITULAR',null);
      END;
  
      IF vCODIGO_PESSOA_BENEFICIARIO IS NOT NULL AND vCODIGO_BENEFICIO IS NOT NULL THEN
  ---------------------------------------------------------------------------
       /*inclusao e alteracao*/
  
       -- Verifica se já existe a solicitação de movimento
       v_temp1 := 0;
       SELECT COUNT(*) INTO v_temp1 /*Verificar se existe*/
       FROM DUAL
       WHERE EXISTS (
        SELECT 1
        FROM RHMOVI_SOL_MOVI
        WHERE CODIGO_CONTRATO = REGISTRO_MOVIMENTO.CODIGO_CONTRATO
        AND CODIGO_EMPRESA = REGISTRO_MOVIMENTO.CODIGO_EMPRESA
        AND CODIGO_VERBA = REGISTRO_MOVIMENTO.CODIGO_VERBA
        AND TIPO_CONTRATO = C_TIPO_CONTRATO
        AND TIPO_MOVIMENTO = C_TIPO_MOVIMENTO
        AND DATA_INI_VIGENCIA = p_ano_mes_referencia
        );
  
  
       -- Data de vigência
       v_ini_vigencia := p_ano_mes_referencia;
       v_fim_vigencia := p_ano_mes_referencia;
  
       -- Data de prioridade daconsignataria
       SELECT C_LIVRE_DATA01 INTO v_data2 /*Data de prioridade daconsignataria*/
       FROM RHORGA_FORN_VERBA
       WHERE codigo_verba = REGISTRO_MOVIMENTO.CODIGO_VERBA;
  
       IF v_temp1>0 THEN /*EXISTE*/
  
         vDATA_ATUALIZACAO := sysdate;
  
         UPDATE RHMOVI_SOL_MOVI
         SET  CODIGO_EMPRESA = REGISTRO_MOVIMENTO.CODIGO_EMPRESA,
         TIPO_CONTRATO = C_TIPO_CONTRATO,
         MODO_OPERACAO = C_MODO_OPERACAO,
         TIPO_MOVIMENTO = C_TIPO_MOVIMENTO,
         CODIGO_CONTRATO = REGISTRO_MOVIMENTO.CODIGO_CONTRATO,
         CODIGO_VERBA = REGISTRO_MOVIMENTO.CODIGO_VERBA,
         MES_INCIDENCIA = to_CHAR(p_ano_mes_referencia, 'MM'),
         CTRL_DEMO = 'N',
         CTRL_LANCAMENTO = 0,
         REF_VERBA = REGISTRO_MOVIMENTO.REFERENCIA_VERBA,
         VALOR_VERBA = REGISTRO_MOVIMENTO.VALOR_VERBA,
         CONTADOR = REGISTRO_MOVIMENTO.CONTADOR,
         OCORRENCIA = 1,
         C_LIVRE_DESCR01 = REGISTRO_MOVIMENTO.DATA_AUTORIZACAO,
         DATA_SOLICITACAO = REGISTRO_MOVIMENTO.DATA_AUTORIZACAO,--REGISTRO_MOVIMENTO.DATA_CADASTRAMENTO,
         DATA_INI_VIGENCIA = v_ini_vigencia,
         DATA_FIM_VIGENCIA = v_fim_vigencia,
         DATA_AUTORIZA = to_date('01/'|| to_CHAR(p_ano_mes_referencia,'MM')||'/'|| to_char(p_ano_mes_referencia,'YYYY'),'dd/mm/yyyyHH24:MI:SS'),
         FASE = C_FASE,
         CTRL_PROP_REF = 'N',
         PROJ_CONTADOR = DECODE(REGISTRO_MOVIMENTO.CONTADOR, 0, 'N', 1, 'N','S'),
         CONTROLE_GERACAO = 'I',
         DESTINO_GERACAO = 'M',
         C_LIVRE_OPCAO01 = 'N',
         C_LIVRE_OPCAO02 = 'N',
         LOGIN_USUARIO = vUSUARIO,
         DT_ULT_ALTER_USUA = SYSDATE,
         C_LIVRE_DATA02 = v_data2,
         C_Livre_Descr02 = REGISTRO_MOVIMENTO.NUMERO_GUIA_IPTU
         WHERE CODIGO_CONTRATO = REGISTRO_MOVIMENTO.CODIGO_CONTRATO
         AND CODIGO_EMPRESA = REGISTRO_MOVIMENTO.CODIGO_EMPRESA
         AND CODIGO_VERBA = REGISTRO_MOVIMENTO.CODIGO_VERBA
         AND TIPO_CONTRATO = C_TIPO_CONTRATO
         AND TIPO_MOVIMENTO = C_TIPO_MOVIMENTO
         AND MODO_OPERACAO = C_MODO_OPERACAO;
  
         GRAVA_LOG(TIPO_LOG_INFO, Numero_linha, 'ATUALIZACAO DE SOLICITACAO DE MOVIMENTO',null);
  
          -- Grava log do sistema
          REG_APOIO_LOG_SIST.CODIGO_EMPRESA    := REGISTRO_MOVIMENTO.CODIGO_EMPRESA;
          REG_APOIO_LOG_SIST.TIPO_CONTRATO     := C_TIPO_CONTRATO;
          REG_APOIO_LOG_SIST.CODIGO_CONTRATO   := REGISTRO_MOVIMENTO.CODIGO_CONTRATO;
          REG_APOIO_LOG_SIST.CODIGO_PESSOA     := vCODIGO_PESSOA_BENEFICIARIO;
          REG_APOIO_LOG_SIST.CODIGO_BENEFICIO  := vCODIGO_BENEFICIO;
          REG_APOIO_LOG_SIST.DATA_SOLICITACAO  := REGISTRO_MOVIMENTO.DATA_AUTORIZACAO;--REGISTRO_MOVIMENTO.DATA_CADASTRAMENTO;
          REG_APOIO_LOG_SIST.ANO_MES_REFERENCIA:= p_ano_mes_referencia;
          REG_APOIO_LOG_SIST.CODIGO_VERBA      := REGISTRO_MOVIMENTO.CODIGO_VERBA;
          REG_APOIO_LOG_SIST.TIPO_MOVIMENTO    := C_TIPO_MOVIMENTO;
          REG_APOIO_LOG_SIST.ID_CLIENTE        := C_ID_CLIENTE;
          REG_APOIO_LOG_SIST.OCORRENCIA        := 1;
          GRAVA_LOG_SISTEMA(vDATA_ATUALIZACAO, OBJETO_SOLICITACAO_MOVIMENTO, vUSUARIO_ATUALIZACAO, 'A', REG_APOIO_LOG_SIST);
  
       ELSE /*Nao Existe*/
       --dbms_output.put_line('teste 6');
       BEGIN
  
       BEGIN
        vDATA_ATUALIZACAO := sysdate;
  
        INSERT INTO RHMOVI_SOL_MOVI(
        CODIGO_EMPRESA,
        TIPO_CONTRATO,
        MODO_OPERACAO,
        TIPO_MOVIMENTO,
        CODIGO_CONTRATO,
        CODIGO_VERBA,
        MES_INCIDENCIA,
        CTRL_DEMO,
        CTRL_LANCAMENTO,
        REF_VERBA,
        VALOR_VERBA,
        CONTADOR,
        OCORRENCIA,
        C_LIVRE_DESCR01,
        DATA_SOLICITACAO,
        DATA_INI_VIGENCIA,
        DATA_FIM_VIGENCIA,
        DATA_AUTORIZA,
        FASE,
        CTRL_PROP_REF,
        PROJ_CONTADOR,
        CONTROLE_GERACAO,
        DESTINO_GERACAO,
        C_LIVRE_OPCAO01,
        C_LIVRE_OPCAO02,
        LOGIN_USUARIO,
        DT_ULT_ALTER_USUA,
        C_LIVRE_DATA02,
        C_Livre_Descr02
        )
        VALUES(
        REGISTRO_MOVIMENTO.CODIGO_EMPRESA,
        C_TIPO_CONTRATO,
        C_MODO_OPERACAO,
        C_TIPO_MOVIMENTO,
        REGISTRO_MOVIMENTO.CODIGO_CONTRATO,
        REGISTRO_MOVIMENTO.CODIGO_VERBA,
        to_CHAR(p_ano_mes_referencia, 'MM'), /*mes ocorrencia nao vemno arquivo.*/'N', /*nao vem no arquivo (FIXO N)*/0, /*nao vem no arquivo, fixo 0??*/
        REGISTRO_MOVIMENTO.REFERENCIA_VERBA,
        REGISTRO_MOVIMENTO.VALOR_VERBA,
        REGISTRO_MOVIMENTO.CONTADOR,
        1,
        REGISTRO_MOVIMENTO.DATA_AUTORIZACAO,--REGISTRO_MOVIMENTO.DATA_CADASTRAMENTO,
        REGISTRO_MOVIMENTO.DATA_AUTORIZACAO,--REGISTRO_MOVIMENTO.DATA_CADASTRAMENTO,
        v_ini_vigencia,
        v_fim_vigencia,
        to_date('01/'|| to_CHAR(p_ano_mes_referencia, 'MM')||'/'||to_char(p_ano_mes_referencia, 'YYYY') , 'dd/mm/yyyy HH24:MI:SS'),
        C_FASE,
        'N',
        DECODE(REGISTRO_MOVIMENTO.CONTADOR, 0, 'N', 1, 'N', 'S'),
        'I',
        'M',
        'N',
        'N',
        vUSUARIO,
        SYSDATE,
        v_data2,
        REGISTRO_MOVIMENTO.NUMERO_GUIA_IPTU
        );
  
        GRAVA_LOG(TIPO_LOG_INFO, Numero_linha, 'INCLUSAO DE SOLICITACAO DE MOVIMENTO',null);
  
          -- Grava log do sistema
          REG_APOIO_LOG_SIST.CODIGO_EMPRESA    := REGISTRO_MOVIMENTO.CODIGO_EMPRESA;
          REG_APOIO_LOG_SIST.TIPO_CONTRATO     := C_TIPO_CONTRATO;
          REG_APOIO_LOG_SIST.CODIGO_CONTRATO   := REGISTRO_MOVIMENTO.CODIGO_CONTRATO;
          REG_APOIO_LOG_SIST.CODIGO_PESSOA     := vCODIGO_PESSOA_BENEFICIARIO;
          REG_APOIO_LOG_SIST.CODIGO_BENEFICIO  := vCODIGO_BENEFICIO;
          REG_APOIO_LOG_SIST.DATA_SOLICITACAO  := REGISTRO_MOVIMENTO.DATA_AUTORIZACAO;
          REG_APOIO_LOG_SIST.ANO_MES_REFERENCIA:= p_ano_mes_referencia;
          REG_APOIO_LOG_SIST.CODIGO_VERBA      := REGISTRO_MOVIMENTO.CODIGO_VERBA;
          REG_APOIO_LOG_SIST.TIPO_MOVIMENTO    := C_TIPO_MOVIMENTO;
          REG_APOIO_LOG_SIST.ID_CLIENTE        := C_ID_CLIENTE;
          REG_APOIO_LOG_SIST.OCORRENCIA        := 1;
  
          GRAVA_LOG_SISTEMA(vDATA_ATUALIZACAO, OBJETO_SOLICITACAO_MOVIMENTO, vUSUARIO_ATUALIZACAO, 'I', REG_APOIO_LOG_SIST);
         EXCEPTION
         WHEN OTHERS THEN
              GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ERRO AO TENTAR INCLUIR SOLICITACAO DE MOVIMENTO','ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
         END;
  
        -- Inclui movimento de beneficiário
        BEGIN
        insert into RHBENF_MOV_BENEFIC (CODIGO_EMPRESA,
                                        TIPO_CONTR_TITULAR,
                                        COD_CONTR_TITULAR,
                                        CODIGO_PESSOA,
                                        TP_RELACIONAMENTO,
                                        CODIGO_BENEFICIO,
                                        ANO_MES_REFERENCIA,
                                        MES_INCIDENCIA,
                                        VALOR_BENEFICIO,
                                        CODIGO_VERBA,
                                        REF_VERBA,
                                        CONSIDERA_DIRF,
                                        CTRL_LANCAMENTO,
                                        C_LIVRE_SELEC01,
                                        C_LIVRE_VALOR01,
                                        C_LIVRE_OPCAO01,
                                        ID_CLIENTE,
                                        LOGIN_USUARIO,
                                        DT_ULT_ALTER_USUA )
        values(
              REGISTRO_MOVIMENTO.CODIGO_EMPRESA,
              C_TIPO_CONTRATO,
              REGISTRO_MOVIMENTO.CODIGO_CONTRATO,
              vCODIGO_PESSOA_BENEFICIARIO,
              vTIPO_RELACIONAMENTO,
              vCODIGO_BENEFICIO,
              p_ano_mes_referencia,
              to_CHAR(p_ano_mes_referencia, 'MM'),
              REGISTRO_MOVIMENTO.VALOR_VERBA,
              REGISTRO_MOVIMENTO.CODIGO_VERBA,
              REGISTRO_MOVIMENTO.REFERENCIA_VERBA,
              'N',
              '0',
              '0',
              '0',
              'N',
              C_ID_CLIENTE,
              vUSUARIO,
              SYSDATE
        );
        GRAVA_LOG(TIPO_LOG_INFO, Numero_linha, 'INCLUSAO DE MOVIMENTO DE BENEFICIARIO',null);
  
          -- Grava log do sistema
          REG_APOIO_LOG_SIST.CODIGO_EMPRESA    := REGISTRO_MOVIMENTO.CODIGO_EMPRESA;
          REG_APOIO_LOG_SIST.TIPO_CONTRATO     := C_TIPO_CONTRATO;
          REG_APOIO_LOG_SIST.CODIGO_CONTRATO   := REGISTRO_MOVIMENTO.CODIGO_CONTRATO;
          REG_APOIO_LOG_SIST.CODIGO_PESSOA     := vCODIGO_PESSOA_BENEFICIARIO;
          REG_APOIO_LOG_SIST.CODIGO_BENEFICIO  := vCODIGO_BENEFICIO;
          REG_APOIO_LOG_SIST.DATA_SOLICITACAO  := REGISTRO_MOVIMENTO.DATA_CADASTRAMENTO;
          REG_APOIO_LOG_SIST.ANO_MES_REFERENCIA:= p_ano_mes_referencia;
          REG_APOIO_LOG_SIST.CODIGO_VERBA      := REGISTRO_MOVIMENTO.CODIGO_VERBA;
          REG_APOIO_LOG_SIST.TIPO_MOVIMENTO    := C_TIPO_MOVIMENTO;
          REG_APOIO_LOG_SIST.ID_CLIENTE        := C_ID_CLIENTE;
          REG_APOIO_LOG_SIST.OCORRENCIA        := 1;
          GRAVA_LOG_SISTEMA(vDATA_ATUALIZACAO, OBJETO_MOVIMENTO_BENEFICIARIO, vUSUARIO_ATUALIZACAO, 'I', REG_APOIO_LOG_SIST);
  
         EXCEPTION
         WHEN OTHERS THEN
              GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'ERRO AO TENTAR INCLUIR MOVIMENTO DE BENEFICIARIO','ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
         END;
  
        EXCEPTION
           WHEN DUP_VAL_ON_INDEX THEN
              --raise_application_error (-20001,'TENTATIVA DE INCLUSÃO DE REGITROS JÁ CADASTRADOS');
              GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'TENTATIVA DE INCLUSÃO DE REGITROS JÁ CADASTRADOS',null);
  
           WHEN OTHERS THEN
              --raise_application_error (-20002,'OCORREU UM ERRO AO TENTAR INCLUIR REGISTRO');
              GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'OCORREU UM ERRO AO TENTAR INCLUIR REGISTRO', 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
        END;
  
       END IF;
  
       END IF;
      ---------------------------------------------------------------------------
  
  
      ELSIF REGISTRO_MOVIMENTO.TIPO_OPERACAO = 'A' THEN
        BEGIN
  
         NULL;
  
        EXCEPTION
           WHEN OTHERS THEN
              --raise_application_error (-20002,'OCORREU UM ERRO AO TENTAR ALTERAR REGISTRO');
              GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'OCORREU UM ERRO AO TENTAR ALTERAR REGISTRO','ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
        END;
      ELSIF REGISTRO_MOVIMENTO.TIPO_OPERACAO = 'E' THEN
         NULL;
         /*
         vDATA_ATUALIZACAO := sysdate;
  
         UPDATE RHMOVI_SOL_MOVI
         SET C_LIVRE_OPCAO01 = 'S',
           DATA_AUTORIZA = NULL,
           c_livre_data01 = SYSDATE, --p_ano_mes_referencia,
           LOGIN_USUARIO = vUSUARIO,
           dt_ult_alter_usua = SYSDATE
         WHERE CODIGO_CONTRATO = REGISTRO_MOVIMENTO.CODIGO_CONTRATO
         AND CODIGO_EMPRESA = REGISTRO_MOVIMENTO.CODIGO_EMPRESA
         AND CODIGO_VERBA = REGISTRO_MOVIMENTO.CODIGO_VERBA
         AND TIPO_CONTRATO = C_TIPO_CONTRATO
         AND TIPO_MOVIMENTO = C_TIPO_MOVIMENTO
         AND MODO_OPERACAO = C_MODO_OPERACAO;
  
         GRAVA_LOG(TIPO_LOG_INFO, Numero_linha, 'CANCELAMENTO DE SOLICITACAO DE MOVIMENTO',null);
  
          -- Grava log do sistema
          REG_APOIO_LOG_SIST.CODIGO_EMPRESA    := REGISTRO_MOVIMENTO.CODIGO_EMPRESA;
          REG_APOIO_LOG_SIST.TIPO_CONTRATO     := C_TIPO_CONTRATO;
          REG_APOIO_LOG_SIST.CODIGO_CONTRATO   := REGISTRO_MOVIMENTO.CODIGO_CONTRATO;
          REG_APOIO_LOG_SIST.CODIGO_PESSOA     := vCODIGO_PESSOA_BENEFICIARIO;
          REG_APOIO_LOG_SIST.CODIGO_BENEFICIO  := vCODIGO_BENEFICIO;
          REG_APOIO_LOG_SIST.DATA_SOLICITACAO  := REGISTRO_MOVIMENTO.DATA_CADASTRAMENTO;
          REG_APOIO_LOG_SIST.ANO_MES_REFERENCIA:= p_ano_mes_referencia;
          REG_APOIO_LOG_SIST.CODIGO_VERBA      := REGISTRO_MOVIMENTO.CODIGO_VERBA;
          REG_APOIO_LOG_SIST.TIPO_MOVIMENTO    := C_TIPO_MOVIMENTO;
          REG_APOIO_LOG_SIST.ID_CLIENTE        := REGISTRO_MOVIMENTO.CODIGO_EMPRESA;
          REG_APOIO_LOG_SIST.OCORRENCIA        := REGISTRO_MOVIMENTO.CODIGO_EMPRESA;
          GRAVA_LOG_SISTEMA(vDATA_ATUALIZACAO, OBJETO_SOLICITACAO_MOVIMENTO, vUSUARIO_ATUALIZACAO, 'A', REG_APOIO_LOG_SIST);
              */
      ELSE
           --raise_application_error (-20001,'TIPO DE OPERAÇÃO INVALIDO');
           GRAVA_LOG(TIPO_LOG_ERRO, Numero_linha, 'TIPO DE OPERAÇÃO INVALIDO',null);
      END IF;    
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