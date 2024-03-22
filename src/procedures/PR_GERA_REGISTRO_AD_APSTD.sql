
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_GERA_REGISTRO_AD_APSTD" 
/*****************************************************************************
  -- Descricao.....: PROCEDURE DIÁRIA PARA GERAR INFORMAÇÕES DE INCLUÃO,
                     ALTERAÇÃO E EXCLUSÃO DE UMA DETERMINADA MATRÍCULA
                     E GRAVAR NA TABELA RHPBH_REGISTRO_AD

  -- Autor.........: MARCELO SOARES / WAGNER SOUZA / PEDRO PAULO LARA RESENDE
  --           Data: 11/04/2019

  -- Parametros....: NA
  -- Funcionamento.: Processo batch
  -- Periodicidade.: batch = TODOS OS DIAS ÀS 23:00
*****************************************************************************/
IS

-- padrao de seleçao de ativos de folha das empresas
/*
  EMPRESA = 0001  PADRAO DE SELEÇÃO CNT:  0000 / 1000 (ATIVOS) E 0000 / 1800 (ESTAGIARIOS)
  EMPRESA = 0002  PADRAO DE SELEÇÃO CNT:  0000 / 0004 (ATIVOS) E 0000 / 1800 (ESTAGIARIOS)
  EMPRESA = 0003  PADRAO DE SELEÇÃO CNT:  0000 / 0190 + 1100 (ATIVOS) E 0000 / 1800 (ESTAGIARIOS)
  EMPRESA = 0007  PADRAO DE SELEÇÃO CNT:  0000 / 0011 (ATIVOS) E 0000 / 1800 (ESTAGIARIOS)
  EMPRESA = 0009  PADRAO DE SELEÇÃO CNT:  0000 / 1003 (ATIVOS) NÃO POSSUEM ESTAGIARIO
  EMPRESA = 0010  PADRAO DE SELEÇÃO CNT:  0000 / 0004 (ATIVOS)
  EMPRESA = 0011  PADRAO DE SELEÇÃO CNT:  UTILIZAR A SITUAÇÃO FUNCIONAL IGUAL 1900
  EMPRESA = 0013  PADRAO DE SELEÇÃO CNT:  0001 / 0004 (ATIVOS) / 0001 / 0006 (ESTAGIARIOS)  TC 0001 ATIVO  0003 ESTAG
  EMPRESA = 0014  PADRAO DE SELEÇÃO CNT:  0002 / 0004 (ATIVOS) / 0002 / 0006 (ESTAGIARIOS)  TC 0001 ATIVO  0003 ESTAG
  EMPRESA = 0015  PADRAO DE SELEÇÃO CNT:  0021 / 0015
  EMPRESA = 0021  PADRAO DE SELEÇÃO CNT:  0021 / 7715
  EMPRESA = 0032  PADRAO DE SELEÇÃO CNT:  0021 / 0007

                                              EMPRESA FANTASIA                  FROM                        DIRETORIO
  EMPRESA = 0001  ARTERH_PBH_PRD            - PREFEITURA       -- existe    -- 'Smarh/Gepe'             -- '/trab/arquivos_pbh_ad'          -- PR_GERA_REGISTRO_AD_PBH_NEW
  EMPRESA = 0002  ARTERH_PRODABEL_PRD       - PRODABEL         -- existe    -- 'SRA/GPRA'               -- '/trab/arquivos_prodabel_ad'     -- PR_GERA_REGISTRO_AD_PDBL_NEW
  EMPRESA = 0003  ARTERH_SUDECAP_PRD        - SUDECAP          -- existe    -- 'Dep.pes/sudecap'        -- '/trab/arquivos_sudecap_ad'      -- PR_GERA_REGISTRO_AD_SUDE_NEW
  EMPRESA = 0007  ARTERH_SLU_PRD            - SLU              -- existe    -- 'Dep.pes/slu'            -- '/trab/arquivos_slu_ad'          -- PR_GERA_REGISTRO_AD_SLU_NEW
  EMPRESA = 0009  ARTERH_BELOTUR            - BELOTUR          -- existe    -- 'Dep.pes/belotur'        -- '/trab/arquivos_belotur_ad'      -- PR_GERA_REGISTRO_AD_BELO_NEW
  EMPRESA = 0010  ARTERH_URBEL_PRD          - URBEL            -- existe    -- 'Dep.pes/urbel'          -- '/trab/arquivos_urbel_ad'        -- PR_GERA_REGISTRO_AD_URBL_NEW
  EMPRESA = 0011  ARTERH_PENSAO_FUFIN_PRD   - PENSAO           -- não       -- 'Dep.pes/pensao'         -- '/trab/arquivos_pensao_ad'       -- PR_GERA_REGISTRO_AD_PNSAO_NEW
  EMPRESA = 0013  ARTERH_FMC_PRD            - FMC              -- existe    -- 'Dep.pes/Cultura'        -- '/trab/arquivos_cultura_ad'      -- PR_GERA_REGISTRO_AD_FMC_NEW
  EMPRESA = 0014  ARTERH_FMC_PRD            - FMP              -- existe    -- 'Dep.pes/fpm'            -- '/trab/arquivos_fpm_ad'          -- PR_GERA_REGISTRO_AD_FMP_NEW
  EMPRESA = 0015  PBH_SAUDE_PRD             - PBH SAUDE        -- não       -- 'Dep.pes/PBHSaude'       -- '/trab/arquivos_pbhsaude_ad'     -- PR_GERA_REGISTRO_AD_SAUDE_NEW
  EMPRESA = 0021  PBH_SAUDE_PRD             - CONTRATOS SA     -- não       -- 'Dep.pes/ContratosSA'    -- '/trab/arquivos_contratossa_ad'  -- PR_GERA_REGISTRO_AD_SAUDE_NEW
  EMPRESA = 0032  PBH_SAUDE_PRD             - PBH ZOONOZES     -- não       -- 'Dep.pes/Zoonozes'       -- '/trab/arquivos_zoonozes_ad'     -- PR_GERA_REGISTRO_AD_ZOONZ_NEW
  EMPRESA = 0098  ARTERH_PBH_PRD            - CONTRATOS PBH    -- não       -- 'Dep.pes/ContratosPBH'   -- '/trab/arquivos_contratospbh_ad' -- PR_GERA_REGISTRO_AD_CNTPBH_NEW
  EMPRESA = 1700  ARTERH_PBH_PRD            - APOSENTADOS      -- não       -- 'Dep.pes/Aposentados'    -- '/trab/arquivos_aposentados_ad'  -- PR_GERA_REGISTRO_AD_APSTD_NEW
*/
  --VARIAVEIS CONFORME OS TIPOS CRIADOS NA TABELA RHPBH_REGISTRO_AD
  V_NOME                     RHPBH_REGISTRO_AD.NOME%TYPE;
  V_CARGO                    RHPBH_REGISTRO_AD.CARGO%TYPE;
  V_SECRETARIA               RHPBH_REGISTRO_AD.SECRETARIA%TYPE;
  V_UNIDADE                  RHPBH_REGISTRO_AD.UNIDADE%TYPE;
  V_OPERACAO_JOIN            RHPBH_REGISTRO_AD.IND_OPERACAO%TYPE;
  --VARIAVEIS COMUM
  V_QTD_REGISTRO             INTEGER;
  V_QTD_ARQUIVO_CRIADO       INTEGER;
  V_CONT_INC                 INTEGER;
  V_CONT_ALT                 INTEGER;
  V_CONT_EXE                 INTEGER;
  V_TELEFONE                 VARCHAR(20);
  V_EMAIL                    VARCHAR(200);
  V_ULT_IND_OPERACAO         VARCHAR(01);
  V_ULT_DATA_RESCISAO        DATE;
  V_INSERE                   BOOLEAN;

  --VARIÁVEIS REFERENTE A GERAÇÃO DE ARQUIVO TXT
  ID_ARQ                     UTL_FILE.FILE_TYPE;
  LINHA                      VARCHAR(2000) := '';
  DIRETORIO                  VARCHAR(50)   := '/trab/arquivos_aposentados_ad';
  ARQUIVO_INC                VARCHAR(50)   := 'Inclusao_AD_APSTD_' || TO_CHAR(sysdate,'DDMMYYYY')||'.txt';
  ARQUIVO_ALT                VARCHAR(50)   := 'Alteracao_AD_APSTD_'|| TO_CHAR(sysdate,'DDMMYYYY')||'.txt';
  ARQUIVO_EXC                VARCHAR(50)   := 'Exclusao_AD_APSTD_' || TO_CHAR(sysdate,'DDMMYYYY')||'.txt';
  V_TIPO_ARQUIVO             VARCHAR(01)   := 'I';
  V_CONTA_REGISTRO           INTEGER       := 0;

  --VARIÁVEIS REFERENTE A GERAÇÃO DE EMAIL
  AV_NAME_FROM               VARCHAR(200) := 'Dep.pes/aposentados';
  AV_MSG_FROM                VARCHAR(200) := 'servicos@pbh.gov.br';
  AV_NAME_TO                 VARCHAR(200) := 'servicos@pbh.gov.br';
  AV_MSG_TO                  VARCHAR(200) := 'servicos@pbh.gov.br;gss@pbh.gov.br';
  AV_MSG_SUBJECT_INC         VARCHAR(200) := 'Arquivo para incluir APOSENTADOS no AD';
  AV_MSG_SUBJECT_ALT         VARCHAR(200) := 'Arquivo para alterar APOSENTADOS no AD';
  AV_MSG_SUBJECT_EXC         VARCHAR(200) := 'Arquivo para excluir APOSENTADOS no AD';
  AV_MSG_TEXT_INC            VARCHAR(200) := 'Senhores,'||CHR(13)||CHR(13)||'  Segue em anexo o Arquivo com as inclusões de funcionários da APOSENTADOS';
  AV_MSG_TEXT_ALT            VARCHAR(200) := 'Senhores,'||CHR(13)||CHR(13)||'  Segue em anexo o Arquivo com as alterações de funcionários da APOSENTADOS';
  AV_MSG_TEXT_EXC            VARCHAR(200) := 'Senhores,'||CHR(13)||CHR(13)||'  Segue em anexo o Arquivo com as exclusões de funcionários da APOSENTADOS';
  AV_BODY_HTML               VARCHAR(01)  := 'N';

BEGIN
  -- VERIFICA SE A TABELA RHPBH_REGISTRO_AD POSSUI REGISTRO SENÃO GERAR A CARGA INICIAL
  SELECT NVL(COUNT(*),0) INTO V_QTD_REGISTRO FROM RHPBH_REGISTRO_AD;
  -- ******************************************************************************************************
  -- *******************************************  BUSCA ATIVOS E DEMITIDOS ********************************
  -- ******************************************************************************************************
  FOR I IN (
    SELECT CNT.CODIGO AS MATRICULA,
           'pr'   || SUBSTR(CNT.CODIGO,9,6) LOGIN,
           CNT.NOME AS NOME,
           CG.DESCRICAO AS CARGO_PGTO,
           'APOSENTADOS' EMPRESA,
           DIR.ABREVIACAO AS SECRETARIA,
           GER.ABREVIACAO AS UNIDADE,
           PES.CPF AS CPF,
           CNT.DATA_ADMISSAO,
           CNT.DATA_RESCISAO,
           CNT.DATA_INIC_AFAST,
           CNT.SITUACAO_FUNCIONAL,
           CNT.TIPO_CONTRATO,
           CNT.CODIGO_EMPRESA,
           CNT.CODIGO_PESSOA
    FROM RHPESS_CONTRATO CNT
         INNER JOIN RHPESS_PESSOA PES  ON (CNT.CODIGO_EMPRESA = PES.CODIGO_EMPRESA AND CNT.CODIGO_PESSOA = PES.CODIGO)
         INNER JOIN RHPLCS_CARGO CG    ON (CNT.CODIGO_EMPRESA = CG.CODIGO_EMPRESA AND CNT.COD_CARGO_PAGTO = CG.CODIGO)
         INNER JOIN RHPARM_SIT_FUNC ST ON (CNT.SITUACAO_FUNCIONAL = ST.CODIGO)
         INNER JOIN RHORGA_EMPRESA EMP ON (CNT.CODIGO_EMPRESA = EMP.CODIGO AND EMP.DATA_EXTINCAO IS NULL)
         LEFT  JOIN RHORGA_UNIDADE DIR ON (CNT.CODIGO_EMPRESA = DIR.CODIGO_EMPRESA)
         LEFT  JOIN RHORGA_UNIDADE GER ON (CNT.CODIGO_EMPRESA = GER.CODIGO_EMPRESA)
    WHERE CNT.CODIGO_EMPRESA     = '1700'
    AND CNT.ANO_MES_REFERENCIA   = (SELECT MAX (CNT2.ANO_MES_REFERENCIA)
                                    FROM RHPESS_CONTRATO CNT2
                                    WHERE CNT2.CODIGO       = CNT.CODIGO
                                    AND CNT2.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA
                                    AND CNT2.TIPO_CONTRATO  = CNT.TIPO_CONTRATO
                                    AND CNT2.ANO_MES_REFERENCIA <= SYSDATE)
    AND CNT.TIPO_CONTRATO        = '0001'
    AND DIR.COD_UNIDADE1         = CNT.COD_UNIDADE1
    AND DIR.COD_UNIDADE2         = CNT.COD_UNIDADE2
    AND DIR.COD_UNIDADE3         = CNT.COD_UNIDADE3
    AND DIR.COD_UNIDADE4         = '000000'
    AND DIR.COD_UNIDADE5         = '000000'
    AND DIR.COD_UNIDADE6         = '000000'
    AND GER.COD_UNIDADE1         = CNT.COD_UNIDADE1
    AND GER.COD_UNIDADE2         = CNT.COD_UNIDADE2
    AND GER.COD_UNIDADE3         = CNT.COD_UNIDADE3
    AND GER.COD_UNIDADE4         = CNT.COD_UNIDADE4
    AND GER.COD_UNIDADE5         = CNT.COD_UNIDADE5
    AND GER.COD_UNIDADE6         = CNT.COD_UNIDADE6
	AND CNT.SITUACAO_FUNCIONAL  <> '5903'  --  REVERSÃO DA APOSENTADORIA POR INVALIDEZ - O FUNCIONÁRIO DEIXA DE SER APOSENTADO E VOLTA ATIVO PARA EMPRESA DE ORIGEM
    AND (   (CNT.DATA_RESCISAO IS NULL)
         OR (CNT.DATA_RESCISAO > (SYSDATE - (EMP.C_LIVRE_SELEC01 + 1))))
    AND 1 = 2 -- PROCEDURE SENDO EXECUTA POR OUTRO SISTEMA
    ORDER BY MATRICULA
    )

  LOOP
    BEGIN
      SELECT '('||SUBSTR(TRIM(NVL(TO_CHAR(TEL.DDD, '000'), '031')), 2, 2)||')'||
                 DECODE(LENGTH(TEL.TELEFONE), 8, '9'||TRIM(SUBSTR(TEL.TELEFONE, 1, 4))||'-'||SUBSTR(TEL.TELEFONE, 5, 8),
                        TRIM(SUBSTR(TEL.TELEFONE, 1, 5))||'-'||SUBSTR(TEL.TELEFONE, 6, 9)) INTO V_TELEFONE
      FROM   (SELECT P.CODIGO_EMPRESA, C.CODIGO,
                     TRIM(TRANSLATE(P.TELEFONE, TRANSLATE('('||P.TELEFONE, '1234567890', ' '), ' ')) TELEFONE,
                     TRIM(TRANSLATE(P.DDD, TRANSLATE('('||P.DDD, '1234567890', ' '), ' ')) DDD
              FROM   RHPESS_TELEFONE_P P, RHPESS_CONTRATO C
              WHERE  P.COD_TIPO_TELEFONE = 2
              AND    P.CODIGO_EMPRESA    = C.CODIGO_EMPRESA
              AND    P.CODIGO_PESSOA     = C.CODIGO_PESSOA
              AND    P.PREFERENCIAL      = 'S') TEL
      WHERE   TEL.CODIGO_EMPRESA = '1700'
      AND     TEL.CODIGO         = I.MATRICULA;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_TELEFONE := NULL;
      WHEN TOO_MANY_ROWS THEN
        V_TELEFONE := NULL;
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(I.MATRICULA);
        V_TELEFONE := 1/0;
    END;
    /**********************************************************************************************************/
    BEGIN
      SELECT NVL(E.ENDER_ELETRONICO, ' ') INTO V_EMAIL
      FROM   (SELECT P.ENDER_ELETRONICO, P.CODIGO_EMPRESA, C.CODIGO,
                     SUBSTR(TRIM(TRANSLATE(ENDER_ELETRONICO, TRANSLATE(ENDER_ELETRONICO, '@', ' '), ' ')), 1, 1) ARROBA
              FROM   RHPESS_ENDERECO_P P, RHPESS_CONTRATO C
              WHERE  P.ENDER_ELETRONICO IS NOT NULL
              AND    P.CODIGO_EMPRESA   = C.CODIGO_EMPRESA
              AND    P.CODIGO_PESSOA    = C.CODIGO_PESSOA) E
      WHERE  E.CODIGO_EMPRESA = '1700'
      AND    E.ARROBA         = '@'
      AND    E.CODIGO         = I.MATRICULA;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_EMAIL := NULL;
      WHEN TOO_MANY_ROWS THEN
        V_EMAIL := NULL;
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(I.MATRICULA);
        V_EMAIL := 1/0;
    END;
    /**********************************************************************************************************/
    -- VERIFICA SE A MATRICULA ENCONTRADA NO LOOP EXISTE NA TABELA RHPBH_REGISTRO_AD
    SELECT NVL(COUNT(*),0) INTO V_QTD_ARQUIVO_CRIADO
    FROM   RHPBH_REGISTRO_AD AD
    WHERE  AD.BM_MATRIC    = I.LOGIN AND AD.EMPRESA = 'APOSENTADOS';

    V_INSERE := FALSE;
    V_OPERACAO_JOIN := 'I';
    IF V_QTD_ARQUIVO_CRIADO = 0 THEN
      --NÃO EXISTE NA TABELA RHPBH_REGISTRO_AD
      V_INSERE := TRUE;
      IF I.DATA_RESCISAO IS NOT NULL THEN
        V_OPERACAO_JOIN := 'E';
      END IF;
    ELSE
      --EXISTE NA TABELA RHPBH_REGISTRO_AD
      --BUSCA NOME, CARGO, SECRETARIA, UNIDADE, DATA_RESCISAO E IND_OPERACAO DO ÚLTIMO REGISTRO PARA COMPARAÇÃO
      BEGIN
        SELECT NOME, CARGO, SECRETARIA, UNIDADE, DATA_RESCISAO, IND_OPERACAO INTO
               V_NOME, V_CARGO, V_SECRETARIA, V_UNIDADE, V_ULT_DATA_RESCISAO, V_ULT_IND_OPERACAO
        FROM   RHPBH_REGISTRO_AD AD
        WHERE  AD.BM_MATRIC            = I.LOGIN
        AND    AD.ID_RHPBH_REGISTRO_AD = (SELECT MAX(A.ID_RHPBH_REGISTRO_AD)AS ID_RHPBH_REGISTRO_AD
                                          FROM   RHPBH_REGISTRO_AD A
                                          WHERE  A.BM_MATRIC = I.LOGIN AND A.EMPRESA = 'APOSENTADOS');
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_NOME       := NULL;
          V_CARGO      := NULL;
          V_SECRETARIA := NULL;
          V_UNIDADE    := NULL;
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE(I.MATRICULA);
          V_NOME       := 1/0;
      END;

      IF I.DATA_RESCISAO IS NOT NULL THEN --DEMITIDO NO RH
        V_OPERACAO_JOIN := 'E';
        V_INSERE := (V_ULT_IND_OPERACAO <> 'E');--ULTIMO REGISTRO NA TABELA RHPBH_REGISTRO_AD NÃO É DEMISSÃO
      ELSE --ATIVO NO RH
        V_OPERACAO_JOIN := 'A';
        V_INSERE := (V_NOME <> I.NOME) OR (V_CARGO <> I.CARGO_PGTO) OR (V_SECRETARIA <> I.SECRETARIA) OR
                    (V_UNIDADE <> I.UNIDADE) OR (V_ULT_DATA_RESCISAO <> I.DATA_RESCISAO);--EXISTE ALGUMA ALTERAÇÃO NOS CAMPOS
      END IF;
    END IF;

    IF V_INSERE THEN
      INSERT INTO RHPBH_REGISTRO_AD
      VALUES (ID_SEQ_REGISTRO_AD.NEXTVAL, I.LOGIN, I.NOME, I.CARGO_PGTO, I.EMPRESA, I.SECRETARIA, I.UNIDADE, I.CPF, 'N', V_OPERACAO_JOIN,
              TRUNC(SYSDATE), I.DATA_ADMISSAO, I.DATA_RESCISAO, I.DATA_INIC_AFAST, NULL, NULL, I.SITUACAO_FUNCIONAL, V_TELEFONE, V_EMAIL);

      SELECT NVL(COUNT(*),0) INTO V_QTD_REGISTRO
      FROM   RHUSER_P_SIST U
      WHERE  U.CODIGO_USUARIO = I.LOGIN;

      IF V_QTD_REGISTRO = 0 THEN
        INSERT INTO RHUSER_P_SIST (CODIGO_USUARIO,          GERA_LOG,                USA_JANELA_ACOMP,        DT_M_OPER_PROPRIO,       DATA_SISTEMA,
                                   ANO_BASE,                USA_SAL_PRINCIPAL,       MODO_OPER_MOVI,          CTRL_OPER_AUXILIAR,      MODO_OPER_TSAL,
                                   MODO_OPER_PONTO,         EMPR_TP_CONTR_PROP,      EMPRESA_SELEC,           TIPO_CONTR_SELEC,        LOGIN_USUARIO,
                                   DT_ULT_ALTER_USUA,       ALT_MOV_LIQUIDO,         COD_PAD_CONTRATO,        MSG_PARA_ARQ_TEXTO,      EXIBE_IDENT_TABELA,
                                   USA_DELIMIT_EXPORT,      DELIMITADOR_EXPORT,      EXPORT_NRO_REAL,         ALT_MV_PT_DT_RETRO,      USA_COD_ALTER_VERB,
                                   CODIGO_GRUPO,            GRUPO_SEL_CONTRATO,      GRUPO_SEL_PESSOA,        COD_SEL_PESSOA,          GRUPO_SEL_CAND,
                                   COD_SEL_CANDIDATO,       GRUPO_SEL_VERBA,         COD_SEL_VERBA,           ALT_PROPRIEDADES,        QTDE_MIN_ATIVO,
                                   PERMITE_INCLUSAO,        PERMITE_EXCLUSAO,        PERMITE_ALTERACAO,       PERMITE_EXECUCAO,        GRUPO_SEL_UNID,
                                   COD_SEL_UNID,            GRUPO_SEL_CCONT,         COD_SEL_CCONT,           GRUPO_SEL_CGER,          COD_SEL_CGER,
                                   EMPRESA_USUARIO,         TP_CONTR_USUARIO,        CONTRATO_USUARIO,        PESSOA_USUARIO,          GRUPO_SEL_LOC,
                                   COD_SEL_LOC,             USA_DT_MAQUINA,          CTRL_ATIVO,              NRO_MOD_SIMULT,          QTDE_REG_AUTO,
                                   CONSISTE_LANC_VERB,      INSERE_LIQUIDO,          BLOQUEIA_CONTRATO,       BLOQUEIA_PESSOA,         EXIBE_DICA,
                                   ALT_CONT_DT_RETRO,       ALT_PESS_DT_RETRO,       ALT_DATA_GERAL,          COD_PERIODO,             EDITA_SALARIO,
                                   NATUR_PROC_SELEC,        GRUPO_SEGURANCA,         MENU_DEF_ENABLED,        MENU_DEF_VISIBLE,        SENHA_USUARIO,
                                   STATUS_USUARIO,          DT_ULT_TROCA_SENHA,      CODIGO_SGBD_PADRAO,      DIAS_EXPIRA_SENHA,       PW_QTDE_POSIC,
                                   PW_ALFANUM,              PW_SUBSET_USUA,          PW_QTDE_TENTA,           PW_COMECA_VOGAL,         APLIC_PROPRIEDADES,
                                   NOME_USUARIO,            CODIGO_IDIOMA,           DIAS_EXP_SEM_ACESS,      DT_ULT_ACESSO,           CT_APLIC_PSEL_CONT,
                                   CT_APLIC_PSEL_PESS,      C_LIVRE_SELEC01,         C_LIVRE_SELEC02,         C_LIVRE_SELEC03,         C_LIVRE_VALOR01,
                                   C_LIVRE_VALOR02,         C_LIVRE_VALOR03,         C_LIVRE_DESCR01,         C_LIVRE_DESCR02,         C_LIVRE_DESCR03,
                                   C_LIVRE_OPCAO01,         C_LIVRE_OPCAO02,         C_LIVRE_OPCAO03,         C_LIVRE_DATA01,          C_LIVRE_DATA02,
                                   C_LIVRE_DATA03,          ALT_MOV_LIQ_AGRUP,       EXPAND_CAMINHO,          EDITA_GRUPO,             GRAVA_TEMPO_FORM,
                                   MIN_TESTE_ESCALONA,      ACERTO_BASE_HIST,        MODULO_ACESSADO,         ALT_PONTO_DT_RETRO,      CTRL_ACESSO_IND,
                                   APELIDO,                 TIPO_AGRUP_USUARIO,      PERMITE_TPAGR_ESP,       DEPURA,                  PW_SUBSET_NOME,
                                   PW_DATAS_PESSOAIS,       PW_DOCS_PESSOAIS,        USUARIO_LDAP,            TIPO_LOGIN,              CODIGO_SERV_AUTENT,
                                   INS_MOV_MEST_CONTR,      INS_MOV_MEST_AGRUP,      INS_MOV_MEST_VAGA,       ACESSA_OUTRO_USUA,       MODULO_ACES_WEB,
                                   ESTACAO_REDE,            LOG_DETALHADO,           PERSISTE_ARG_SEL,        DATA_CRIACAO,            EXEC_INST_ESCALONA,
                                   PERMITE_EFETIVAR_SQL,    CONTROLE_BPM,            ULTIMO_PERFIL_ACESSO_AZC)
        SELECT I.LOGIN,                      USR.GERA_LOG,                 USR.USA_JANELA_ACOMP,         USR.DT_M_OPER_PROPRIO,        USR.DATA_SISTEMA,
               USR.ANO_BASE,                 USR.USA_SAL_PRINCIPAL,        USR.MODO_OPER_MOVI,           USR.CTRL_OPER_AUXILIAR,       USR.MODO_OPER_TSAL,
               USR.MODO_OPER_PONTO,          USR.EMPR_TP_CONTR_PROP,       USR.EMPRESA_SELEC,            USR.TIPO_CONTR_SELEC,         USR.LOGIN_USUARIO,
               USR.DT_ULT_ALTER_USUA,        USR.ALT_MOV_LIQUIDO,          USR.COD_PAD_CONTRATO,         USR.MSG_PARA_ARQ_TEXTO,       USR.EXIBE_IDENT_TABELA,
               USR.USA_DELIMIT_EXPORT,       USR.DELIMITADOR_EXPORT,       USR.EXPORT_NRO_REAL,          USR.ALT_MV_PT_DT_RETRO,       USR.USA_COD_ALTER_VERB,
               USR.CODIGO_GRUPO,             USR.GRUPO_SEL_CONTRATO,       USR.GRUPO_SEL_PESSOA,         USR.COD_SEL_PESSOA,           USR.GRUPO_SEL_CAND,
               USR.COD_SEL_CANDIDATO,        USR.GRUPO_SEL_VERBA,          USR.COD_SEL_VERBA,            USR.ALT_PROPRIEDADES,         USR.QTDE_MIN_ATIVO,
               USR.PERMITE_INCLUSAO,         USR.PERMITE_EXCLUSAO,         USR.PERMITE_ALTERACAO,        USR.PERMITE_EXECUCAO,         USR.GRUPO_SEL_UNID,
               USR.COD_SEL_UNID,             USR.GRUPO_SEL_CCONT,          USR.COD_SEL_CCONT,            USR.GRUPO_SEL_CGER,           USR.COD_SEL_CGER,
               I.CODIGO_EMPRESA,             I.TIPO_CONTRATO,              I.MATRICULA,                  I.CODIGO_PESSOA,              USR.GRUPO_SEL_LOC,
               USR.COD_SEL_LOC,              USR.USA_DT_MAQUINA,           USR.CTRL_ATIVO,               USR.NRO_MOD_SIMULT,           USR.QTDE_REG_AUTO,
               USR.CONSISTE_LANC_VERB,       USR.INSERE_LIQUIDO,           USR.BLOQUEIA_CONTRATO,        USR.BLOQUEIA_PESSOA,          USR.EXIBE_DICA,
               USR.ALT_CONT_DT_RETRO,        USR.ALT_PESS_DT_RETRO,        USR.ALT_DATA_GERAL,           USR.COD_PERIODO,              USR.EDITA_SALARIO,
               USR.NATUR_PROC_SELEC,         USR.GRUPO_SEGURANCA,          USR.MENU_DEF_ENABLED,         USR.MENU_DEF_VISIBLE,         USR.SENHA_USUARIO,
               USR.STATUS_USUARIO,           USR.DT_ULT_TROCA_SENHA,       USR.CODIGO_SGBD_PADRAO,       USR.DIAS_EXPIRA_SENHA,        USR.PW_QTDE_POSIC,
               USR.PW_ALFANUM,               USR.PW_SUBSET_USUA,           USR.PW_QTDE_TENTA,            USR.PW_COMECA_VOGAL,          USR.APLIC_PROPRIEDADES,
               I.NOME,                       USR.CODIGO_IDIOMA,            USR.DIAS_EXP_SEM_ACESS,       USR.DT_ULT_ACESSO,            USR.CT_APLIC_PSEL_CONT,
               USR.CT_APLIC_PSEL_PESS,       USR.C_LIVRE_SELEC01,          USR.C_LIVRE_SELEC02,          USR.C_LIVRE_SELEC03,          USR.C_LIVRE_VALOR01,
               USR.C_LIVRE_VALOR02,          USR.C_LIVRE_VALOR03,          USR.C_LIVRE_DESCR01,          USR.C_LIVRE_DESCR02,          USR.C_LIVRE_DESCR03,
               USR.C_LIVRE_OPCAO01,          USR.C_LIVRE_OPCAO02,          USR.C_LIVRE_OPCAO03,          USR.C_LIVRE_DATA01,           USR.C_LIVRE_DATA02,
               USR.C_LIVRE_DATA03,           USR.ALT_MOV_LIQ_AGRUP,        USR.EXPAND_CAMINHO,           USR.EDITA_GRUPO,              USR.GRAVA_TEMPO_FORM,
               USR.MIN_TESTE_ESCALONA,       USR.ACERTO_BASE_HIST,         USR.MODULO_ACESSADO,          USR.ALT_PONTO_DT_RETRO,       USR.CTRL_ACESSO_IND,
               USR.APELIDO,                  USR.TIPO_AGRUP_USUARIO,       USR.PERMITE_TPAGR_ESP,        USR.DEPURA,                   USR.PW_SUBSET_NOME,
               USR.PW_DATAS_PESSOAIS,        USR.PW_DOCS_PESSOAIS,         I.LOGIN,                      USR.TIPO_LOGIN,               USR.CODIGO_SERV_AUTENT,
               USR.INS_MOV_MEST_CONTR,       USR.INS_MOV_MEST_AGRUP,       USR.INS_MOV_MEST_VAGA,        USR.ACESSA_OUTRO_USUA,        USR.MODULO_ACES_WEB,
               USR.ESTACAO_REDE,             USR.LOG_DETALHADO,            USR.PERSISTE_ARG_SEL,         SYSDATE,                      USR.EXEC_INST_ESCALONA,
               USR.PERMITE_EFETIVAR_SQL,     USR.CONTROLE_BPM,             USR.ULTIMO_PERFIL_ACESSO_AZC
        FROM   RHUSER_P_SIST USR
        WHERE  USR.CODIGO_USUARIO = 'MODELO';

        DELETE RHUSER_RL_USR_GRP WHERE CODIGO_USUARIO = I.LOGIN;

        INSERT INTO RHUSER_RL_USR_GRP (CODIGO_USUARIO, CODIGO_GRUPO, LOGIN_USUARIO, DT_ULT_ALTER_USUA)
        SELECT I.LOGIN, T.CODIGO_GRUPO, 'PROCEDURE_AD', SYSDATE
        FROM   RHUSER_RL_USR_GRP T
        WHERE  T.CODIGO_USUARIO = 'MODELO';

      END IF;
    END IF;

  END LOOP;
  COMMIT;

  -- ******************************************************************************************************
  -- ******************************** GERAR ARQUIVO TXT E MODIFICAR PARÂMETROS ****************************
  -- ******************************************************************************************************

  SELECT NVL(COUNT(*),0) INTO V_CONT_INC
  FROM   RHPBH_REGISTRO_AD AD
  WHERE  AD.IND_OPERACAO = 'I'
  AND    AD.IND_GEROU_ARQ_TXT = 'N';

  SELECT NVL(COUNT(*),0) INTO V_CONT_ALT
  FROM   RHPBH_REGISTRO_AD AD
  WHERE  AD.IND_OPERACAO = 'A'
  AND    AD.IND_GEROU_ARQ_TXT = 'N';

  SELECT NVL(COUNT(*),0) INTO V_CONT_EXE
  FROM   RHPBH_REGISTRO_AD AD
  WHERE  AD.IND_OPERACAO = 'E'
  AND    AD.IND_GEROU_ARQ_TXT = 'N';

  FOR I IN 1..3
  LOOP
    V_CONTA_REGISTRO := 0;
    CASE WHEN I = 1 THEN
      BEGIN
        V_TIPO_ARQUIVO := 'I';
        ID_ARQ := UTL_FILE.FOPEN(DIRETORIO,ARQUIVO_INC,'W');
      END;
      WHEN I = 2 THEN
      BEGIN
        V_TIPO_ARQUIVO := 'A';
        ID_ARQ := UTL_FILE.FOPEN(DIRETORIO,ARQUIVO_ALT,'W');
      END;
      WHEN I = 3 THEN
      BEGIN
        V_TIPO_ARQUIVO := 'E';
        ID_ARQ := UTL_FILE.FOPEN(DIRETORIO,ARQUIVO_EXC,'W');
      END;
    END CASE;

    FOR ARQTXT IN(SELECT TRIM(BM_MATRIC)  ||';'|| TRIM(NOME)    ||';'|| TRIM(CARGO) ||';'|| TRIM(EMPRESA)    ||';'||
                         TRIM(SECRETARIA) ||';'|| TRIM(UNIDADE) ||';'|| TRIM(CPF)   ||';'|| IND_OPERACAO     ||';'||
                         TO_CHAR(DATA_INCLUSAO, 'DD/MM/YYYY')   ||';'|| TO_CHAR(DATA_ADMISSAO, 'DD/MM/YYYY') ||';'||
                         TO_CHAR(DATA_RESCISAO, 'DD/MM/YYYY')   ||';'|| TELEFONE    ||';'|| EMAIL AS REGISTRO
                  FROM   RHPBH_REGISTRO_AD WHERE IND_GEROU_ARQ_TXT = 'N' AND IND_OPERACAO = V_TIPO_ARQUIVO
                  ORDER  BY BM_MATRIC)
    LOOP
      V_CONTA_REGISTRO := V_CONTA_REGISTRO + 1;
      LINHA := TRIM(RPAD(ARQTXT.REGISTRO, 477)) || CHR(13);
      UTL_FILE.PUT_LINE(ID_ARQ, LINHA);
    END LOOP;

    IF V_CONTA_REGISTRO > 0 THEN
      UTL_FILE.FCLOSE(ID_ARQ);
      UPDATE RHPBH_REGISTRO_AD SET IND_GEROU_ARQ_TXT = 'S', DATA_PROCESSAMENTO_ARQ = TRUNC(SYSDATE)
      WHERE  IND_OPERACAO = V_TIPO_ARQUIVO AND IND_GEROU_ARQ_TXT = 'N';
      COMMIT;
    END IF;
  END LOOP;
  -- ******************************************************************************************************
  -- ******************** ENVIA ARQUIVO TXT DE INCLUSÃO E EXCLUSÃO POR E-MAIL *****************************
  -- ******************************************************************************************************
  FOR I IN 1..3
  LOOP
    CASE
      WHEN I = 1 THEN
        IF V_CONT_INC > 0 THEN
          PR_ENVIA_EMAIL_AD(AV_NAME_FROM, AV_MSG_FROM, AV_NAME_TO, AV_MSG_TO, AV_MSG_SUBJECT_INC, AV_MSG_TEXT_INC, ARQUIVO_INC, DIRETORIO, AV_BODY_HTML);
        END IF;
      WHEN I = 2 THEN
        IF V_CONT_ALT > 0 THEN
          PR_ENVIA_EMAIL_AD(AV_NAME_FROM, AV_MSG_FROM, AV_NAME_TO, AV_MSG_TO, AV_MSG_SUBJECT_ALT, AV_MSG_TEXT_ALT, ARQUIVO_ALT, DIRETORIO, AV_BODY_HTML);
        END IF;
      WHEN I = 3 THEN
        IF V_CONT_EXE > 0 THEN
          PR_ENVIA_EMAIL_AD(AV_NAME_FROM, AV_MSG_FROM, AV_NAME_TO, AV_MSG_TO, AV_MSG_SUBJECT_EXC, AV_MSG_TEXT_EXC, ARQUIVO_EXC, DIRETORIO, AV_BODY_HTML);
        END IF;
    END CASE;
  END LOOP;

END PR_GERA_REGISTRO_AD_APSTD;