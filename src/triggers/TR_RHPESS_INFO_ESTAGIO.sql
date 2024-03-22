
  CREATE OR REPLACE EDITIONABLE TRIGGER "ARTERH"."TR_RHPESS_INFO_ESTAGIO" BEFORE
  INSERT OR
  UPDATE OR
  DELETE ON "ARTERH"."RHPESS_INFO_ESTAGIO" FOR EACH ROW
   DECLARE v_DML  VARCHAR2(1 BYTE);
  vCODIGO_EMPRESA_SUBORDINADO   VARCHAR2(4);
  vTIPO_CONTRATO_SUBORDINADO    VARCHAR2(4);
  vCODIGO_CONTRATO_SUBORDINADO  VARCHAR2(15);
  vCODIGO_PESSOA_SUBORDINADO    VARCHAR2(15);
  vCOD_CUSTO_GERENC1_SUBORDINAD VARCHAR2(6);
  vCOD_CUSTO_GERENC2_SUBORDINAD VARCHAR2(6);
  vNOME_COMPOSTO_ESTAGIARIO     VARCHAR2(200);
  vCODIGO_EMPRESA_RESP          VARCHAR2(4);
  vTIPO_CONTRATO_RESP           VARCHAR2(4);
  vCONTRATO_RESP                VARCHAR2(15);
  vCOD_PESSOA_RESP              VARCHAR2(15);
  vCODIGO_USUARIO               VARCHAR2(40);
  vNEW_DT_FIM_VIGENCIA          DATE;
  vOLD_DT_FIM_VIGENCIA          DATE;
  vNEW_COORD_ESTAGIO            VARCHAR2(15);
  vOLD_COORD_ESTAGIO            VARCHAR2(15);
  vLOGIN_USUARIO_NEW            VARCHAR2(40);
  vLOGIN_USUARIO_OLD            VARCHAR2(40);
  vLOGIN_OS_NEW                 VARCHAR2(40);
  vLOGIN_OS_OLD                 VARCHAR2(40);
  vLOGIN_NEW                    VARCHAR2(40);
  vLOGIN_OLD                    VARCHAR2(40);
  vCODIGO_EMPRESA_COORD_NEW     VARCHAR2(4);
  vCODIGO_EMPRESA_COORD_OLD     VARCHAR2(4);
  vTIPO_CONTRATO_COORD_NEW      VARCHAR2(4);
  vTIPO_CONTRATO_COORD_OLD      VARCHAR2(4);
  vCONTRATO_COORD_NEW           VARCHAR2(15);
  vCONTRATO_COORD_OLD           VARCHAR2(15);
  vCOD_CUSTO_GERENC1_COORD_NEW  VARCHAR2(6);
  vCOD_CUSTO_GERENC1_COORD_OLD  VARCHAR2(6);
  vCOD_CUSTO_GERENC2_COORD_NEW  VARCHAR2(6);
  vCOD_CUSTO_GERENC2_COORD_OLD  VARCHAR2(6);
  vNOME_COMPOSTO_COORD_NEW      VARCHAR2(200);
  vNOME_COMPOSTO_COORD_OLD      VARCHAR2(200);
  VCODIGO_CONTRATO_OLD            VARCHAR2(15);
  BEGIN
    vCODIGO_EMPRESA_SUBORDINADO   := NULL;
    vTIPO_CONTRATO_SUBORDINADO    := NULL;
    vCODIGO_CONTRATO_SUBORDINADO  := NULL;
    vCODIGO_PESSOA_SUBORDINADO    := NULL;
    vCOD_CUSTO_GERENC1_SUBORDINAD := NULL;
    vCOD_CUSTO_GERENC2_SUBORDINAD := NULL;
    vCODIGO_EMPRESA_RESP          := NULL;
    vTIPO_CONTRATO_RESP           := NULL;
    vCONTRATO_RESP                := NULL;
    vCOD_PESSOA_RESP              := NULL;
    vCODIGO_USUARIO               := NULL;
    vNOME_COMPOSTO_ESTAGIARIO     := NULL;
    vCODIGO_EMPRESA_COORD_NEW     := NULL;
    vCODIGO_EMPRESA_COORD_OLD     := NULL;
    vTIPO_CONTRATO_COORD_NEW      := NULL;
    vTIPO_CONTRATO_COORD_OLD      := NULL;
    vCONTRATO_COORD_NEW           := NULL;
    vCONTRATO_COORD_OLD           := NULL;
    vCOD_CUSTO_GERENC1_COORD_NEW  := NULL;
    vCOD_CUSTO_GERENC1_COORD_OLD  := NULL;
    vCOD_CUSTO_GERENC2_COORD_NEW  := NULL;
    vCOD_CUSTO_GERENC2_COORD_OLD  := NULL;
    vNOME_COMPOSTO_COORD_NEW      := NULL;
    vNOME_COMPOSTO_COORD_OLD      := NULL;
    vNEW_DT_FIM_VIGENCIA          := :NEW.DT_FIM_VIGENCIA;
    vOLD_DT_FIM_VIGENCIA          := :OLD.DT_FIM_VIGENCIA;
    vNEW_COORD_ESTAGIO            := :NEW.COORD_ESTAGIO;
    vOLD_COORD_ESTAGIO            := :OLD.COORD_ESTAGIO;
    vLOGIN_USUARIO_NEW            := :NEW.LOGIN_USUARIO;
    vLOGIN_USUARIO_OLD            := :OLD.LOGIN_USUARIO;
    vLOGIN_OS_NEW                 := SYS_CONTEXT ('USERENV', 'OS_USER');
    vLOGIN_OS_OLD                 := SYS_CONTEXT ('USERENV', 'OS_USER');
    vLOGIN_NEW                    := NULL;
    vLOGIN_OLD                    := NULL;

    --definir login a usar NEW
    IF vLOGIN_USUARIO_NEW = 'ARTERH_UPBH' THEN
      vLOGIN_NEW         := vLOGIN_OS_NEW;
    ELSE
      vLOGIN_NEW := vLOGIN_USUARIO_NEW;
    END IF;
    --definir login a usar OLD
    IF vLOGIN_USUARIO_OLD = 'ARTERH_UPBH' THEN
      vLOGIN_NEW         := vLOGIN_OS_OLD;
    ELSE
      vLOGIN_OLD := vLOGIN_USUARIO_OLD;
    END IF;
    
    IF (:NEW.CODIGO_EMPRESA <> '0005' OR :OLD.CODIGO_EMPRESA <> '0005') THEN /*INCLUIDO POR LETICIA PARA ATENDER AO E-MAIL  Demanda SUMOB -03 Estagiários nivel Superior*/
    
    --INICIO --IF GERAL DO INSERT, DELETE, E TIPOS DE UPDATE
    IF INSERTING AND (vNEW_DT_FIM_VIGENCIA IS NOT NULL AND vNEW_COORD_ESTAGIO IS NOT NULL) --AND (vCOD_PESSOA_RESP <> vNEW_COORD_ESTAGIO)
      THEN
      ------------------------------------------------------------------------------INSERT------------------------------------------------------------------------------------------------------------------------------------
      v_DML := 'I';
      --INICIO --POPULAR TABELAS ()
      --INICIO--buscar dados do ESTAGIARIO e O RESPONSAVEL DO CUSTO GERENCIAL DO ESTAGIARIO E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO
      SELECT C.CODIGO_EMPRESA,
        C.TIPO_CONTRATO,
        C.CODIGO,
        C.CODIGO_PESSOA,
        C.COD_CUSTO_GERENC1,
        C.COD_CUSTO_GERENC2,
        G.CODIGO_EMPRESA,
        G.TIPO_CONT_RESP,
        G.CONTRATO_RESP,
        G.COD_PESSOA_RESP,
        U.CODIGO_USUARIO ,
        C.CODIGO
        ||' - '
        ||NVL(TRIM(P.NOME_SOCIAL),TRIM(P.NOME_ACESSO))
        ||' - '
        ||C.TIPO_CONTRATO
        ||' - '
        || NVL(TRIM(G.TEXTO_ASSOCIADO),TRIM(G.DESCRICAO)) NOME_COMPOSTO_ESTAGIARIO
      INTO vCODIGO_EMPRESA_SUBORDINADO,
        vTIPO_CONTRATO_SUBORDINADO,
        vCODIGO_CONTRATO_SUBORDINADO,
        vCODIGO_PESSOA_SUBORDINADO,
        vCOD_CUSTO_GERENC1_SUBORDINAD,
        vCOD_CUSTO_GERENC2_SUBORDINAD,
        vCODIGO_EMPRESA_RESP,
        vTIPO_CONTRATO_RESP,
        vCONTRATO_RESP,
        vCOD_PESSOA_RESP,
        vCODIGO_USUARIO,
        vNOME_COMPOSTO_ESTAGIARIO
      FROM RHPESS_CONTRATO C
      LEFT OUTER JOIN RHORGA_CUSTO_GEREN G
      ON C.CODIGO_EMPRESA     = G.CODIGO_EMPRESA
      AND C.COD_CUSTO_GERENC1 = G.COD_CGERENC1
      AND C.COD_CUSTO_GERENC2 = G.COD_CGERENC2
      AND C.COD_CUSTO_GERENC3 = G.COD_CGERENC3
      AND C.COD_CUSTO_GERENC4 = G.COD_CGERENC4
      AND C.COD_CUSTO_GERENC5 = G.COD_CGERENC5
      AND C.COD_CUSTO_GERENC6 = G.COD_CGERENC6
      LEFT OUTER JOIN RHUSER_P_SIST U
      ON G.CODIGO_EMPRESA  = U.EMPRESA_USUARIO
      AND G.TIPO_CONT_RESP = U.TP_CONTR_USUARIO
      AND g.contrato_resp  = u.contrato_usuario
      LEFT OUTER JOIN RHPESS_PESSOA P
      ON P.CODIGO_EMPRESA = C.CODIGO_EMPRESA
      AND P.CODIGO        = C.CODIGO_PESSOA
      WHERE u.usuario_ldap         = u.codigo_usuario
      AND U.tipo_login ='1'
      AND U.STATUS_USUARIO NOT IN ('E')
      AND C.CODIGO_EMPRESA     = :NEW.CODIGO_EMPRESA
      AND C.TIPO_CONTRATO      = :NEW.TIPO_CONTRATO
      AND C.CODIGO             = :NEW.CODIGO_CONTRATO
      AND C.ANO_MES_REFERENCIA =
        (SELECT MAX(AUX.ano_mes_referencia)
        FROM rhpess_contrato AUX
        WHERE AUX.codigo_empresa = c.codigo_empresa
        AND AUX.tipo_contrato    = c.tipo_contrato
        AND AUX.codigo           = c.codigo);

      --FIM--buscar dados do ESTAGIARIO e O RESPONSAVEL DO CUSTO GERENCIAL DO ESTAGIARIO E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO
      --INICIO--BUSCAR O CONTRATO DO ***NOVO*** COORD_ESTAGIO da tela E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO
      SELECT C.CODIGO_EMPRESA,
        C.TIPO_CONTRATO,
        C.CODIGO,
        C.CODIGO_PESSOA ,
        C.COD_CUSTO_GERENC1 ,
        C.COD_CUSTO_GERENC2 ,
        C.CODIGO
        ||' - '
        || NVL(TRIM(P.NOME_SOCIAL),TRIM(P.NOME_ACESSO))
        ||' - '
        || C.TIPO_CONTRATO
        ||' - '
        || NVL(TRIM(G.TEXTO_ASSOCIADO),TRIM(G.DESCRICAO)) NOME_COMPOSTO_COORDENADOR
      INTO vCODIGO_EMPRESA_COORD_NEW,
        vTIPO_CONTRATO_COORD_NEW ,
        vCONTRATO_COORD_NEW ,
        vNEW_COORD_ESTAGIO,
        vCOD_CUSTO_GERENC1_COORD_NEW ,
        vCOD_CUSTO_GERENC2_COORD_NEW ,
        vNOME_COMPOSTO_COORD_NEW
      FROM RHPESS_CONTRATO C
      LEFT OUTER JOIN RHPARM_SIT_FUNC S
      ON C.SITUACAO_FUNCIONAL = S.CODIGO
      LEFT OUTER JOIN RHPESS_PESSOA P
      ON P.CODIGO_EMPRESA = C.CODIGO_EMPRESA
      AND P.CODIGO        = C.CODIGO_PESSOA
      LEFT OUTER JOIN RHORGA_CUSTO_GEREN G
      ON C.CODIGO_EMPRESA       = G.CODIGO_EMPRESA
      AND C.COD_CUSTO_GERENC1   = G.COD_CGERENC1
      AND C.COD_CUSTO_GERENC2   = G.COD_CGERENC2
      AND C.COD_CUSTO_GERENC3   = G.COD_CGERENC3
      AND C.COD_CUSTO_GERENC4   = G.COD_CGERENC4
      AND C.COD_CUSTO_GERENC5   = G.COD_CGERENC5
      AND C.COD_CUSTO_GERENC6   = G.COD_CGERENC6
      WHERE C.CODIGO_EMPRESA    = :NEW.CODIGO_EMPRESA_COORD
      AND C.TIPO_CONTRATO       = :NEW.TIPO_CONTRATO_COORD
      AND C.CODIGO       = :NEW.codigo_contrato_coord
      AND S.CONTROLE_FOLHA NOT IN ('D','S')
      AND C.DATA_RESCISAO      IS NULL
      AND C.SITUACAO_FUNCIONAL <> '1017'
      AND C.ANO_MES_REFERENCIA  =
        (SELECT MAX(AUX.ano_mes_referencia)
        FROM rhpess_contrato AUX
        WHERE AUX.codigo_empresa = c.codigo_empresa
        AND AUX.tipo_contrato    = c.tipo_contrato
        AND AUX.codigo           = c.codigo

        );
      --FIM--BUSCAR O CONTRATO DO COORD_ESTAGIO da tela E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO
      --INICIO--BUSCAR O CONTRATO DO ***VELHO*** COORD_ESTAGIO da tela E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO
     /* SELECT C.CODIGO_EMPRESA,
        C.TIPO_CONTRATO,
        C.CODIGO,
        C.CODIGO_PESSOA ,
        C.COD_CUSTO_GERENC1 ,
        C.COD_CUSTO_GERENC2,
        C.CODIGO
        ||' - '
        || NVL(TRIM(P.NOME_SOCIAL),TRIM(P.NOME_ACESSO))
        ||' - '
        || C.TIPO_CONTRATO
        ||' - '
        || NVL(TRIM(G.TEXTO_ASSOCIADO),TRIM(G.DESCRICAO)) NOME_COMPOSTO_COORDENADOR
      INTO vCODIGO_EMPRESA_COORD_OLD,
        vTIPO_CONTRATO_COORD_OLD ,
        vCONTRATO_COORD_OLD,
        vOLD_COORD_ESTAGIO,
        vCOD_CUSTO_GERENC1_COORD_OLD ,
        vCOD_CUSTO_GERENC2_COORD_OLD ,
        vNOME_COMPOSTO_COORD_OLD
      FROM RHPESS_CONTRATO C
      LEFT OUTER JOIN RHPARM_SIT_FUNC S
      ON C.SITUACAO_FUNCIONAL = S.CODIGO
      LEFT OUTER JOIN RHPESS_PESSOA P
      ON P.CODIGO_EMPRESA = C.CODIGO_EMPRESA
      AND P.CODIGO        = C.CODIGO_PESSOA
      LEFT OUTER JOIN RHORGA_CUSTO_GEREN G
      ON C.CODIGO_EMPRESA       = G.CODIGO_EMPRESA
      AND C.COD_CUSTO_GERENC1   = G.COD_CGERENC1
      AND C.COD_CUSTO_GERENC2   = G.COD_CGERENC2
      AND C.COD_CUSTO_GERENC3   = G.COD_CGERENC3
      AND C.COD_CUSTO_GERENC4   = G.COD_CGERENC4
      AND C.COD_CUSTO_GERENC5   = G.COD_CGERENC5
      AND C.COD_CUSTO_GERENC6   = G.COD_CGERENC6
      WHERE C.CODIGO_EMPRESA    = :OLD.CODIGO_EMPRESA
      AND C.TIPO_CONTRATO       = :OLD.TIPO_CONTRATO
      AND C.CODIGO_PESSOA       = :OLD.COORD_ESTAGIO
      AND S.CONTROLE_FOLHA      = 'N'
      AND C.DATA_RESCISAO      IS NULL
      AND C.SITUACAO_FUNCIONAL <> '1017'
      AND C.ANO_MES_REFERENCIA  =
        (SELECT MAX(AUX.ano_mes_referencia)
        FROM rhpess_contrato AUX
        WHERE AUX.codigo_empresa = c.codigo_empresa
        AND AUX.tipo_contrato    = c.tipo_contrato
        AND AUX.codigo           = c.codigo
        );*/
      --FIM--BUSCAR O CONTRATO DO COORD_ESTAGIO da tela E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO
      --FIM --POPULAR VARIAVEIS
      --INICIO IF INTERNO
      IF --1=1
        (vCOD_PESSOA_RESP <> vNEW_COORD_ESTAGIO) THEN
        /*
        INSERT INTO SUGESP_RHPESS_INFOESTAGIO_LOG (TIPO_DML, CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DT_INI_VIGENCIA, NEW_DT_FIM_VIGENCIA, OLD_DT_FIM_VIGENCIA, NEW_COORD_ESTAGIO, OLD_COORD_ESTAGIO, CODIGO_EMPRESA_RESP, TIPO_CONT_RESP, CONTRATO_RESP,
        TEXTO_TESTE_TRIGGER, LOGIN_NEW, LOGIN_OLD, DT_ULT_ALTER_USUA
        ,COD_CUSTO_GERENC1_SUBORDINAD, COD_CUSTO_GERENC2_SUBORDINAD, CONTRATO_COORD, COD_CUSTO_GERENC1_COORD, COD_CUSTO_GERENC2_COORD
        ,COD_PESSOA_RESP
        )
        VALUES(v_DML, :NEW.CODIGO_EMPRESA, :NEW.TIPO_CONTRATO, :NEW.CODIGO_CONTRATO, :NEW.DT_INI_VIGENCIA, :NEW.DT_FIM_VIGENCIA, :NEW.DT_FIM_VIGENCIA, :NEW.COORD_ESTAGIO, null, vCODIGO_EMPRESA_RESP, vTIPO_CONTRATO_RESP, vCONTRATO_RESP
        ,'1_INSERTS NAS TABELAS RHUSER_PESSOA_RESPOSAVEL e RHPESS_RESP_SUPERVISAO', vLOGIN_NEW, vLOGIN_OLD, sysdate
        ,vCOD_CUSTO_GERENC1_SUBORDINAD, vCOD_CUSTO_GERENC2_SUBORDINAD, vCONTRATO_COORD_NEW, vCOD_CUSTO_GERENC1_COORD_NEW, vCOD_CUSTO_GERENC2_COORD_NEW
        ,vCOD_PESSOA_RESP
        );
        */
        --NEW
        --tabela RHUSER_PESSOA_RESPONSAVEL
        INSERT
        INTO RHUSER_PESSOA_RESPONSAVEL
          (
            ID,
            ID_PROCESSO,
            ID_TAREFA,
            CODIGO_EMPRESA,
            CODIGO_USUARIO,
            CODIGO_EMPRESA_PESSOA_RESP,
            CODIGO_PESSOA_RESP,
            CODIGO_CONTRATO_RESP,
            TIPO_CONTRATO_RESP,
            CODIGO_EMPRESA_CONTRATO,
            DT_INICIO_RESPONSABILIDADE,
            DT_FIM_RESPONSABILIDADE,
            CREATED,
            CREATEDBY,
            UPDATED,
            UPDATEDBY,
            NOME_COMPOSTO,
            MOTIVO_DELEGACAO,
            ID_DELEGACAO_SUBSTITUICAO
          )
          VALUES
          (
            (SELECT MAX(ID)+1 FROM RHUSER_PESSOA_RESPONSAVEL
            )
            ,
            2,
            NULL,
            :NEW.CODIGO_EMPRESA,
            vCODIGO_USUARIO,
            vCODIGO_EMPRESA_COORD_NEW,
            vNEW_COORD_ESTAGIO,
            vCONTRATO_COORD_NEW,
            vTIPO_CONTRATO_COORD_NEW,
            vCODIGO_EMPRESA_COORD_NEW,
            TRUNC(:NEW.DT_INI_VIGENCIA),
            TRUNC(:NEW.DT_FIM_VIGENCIA),
            SYSDATE,
            :NEW.LOGIN_USUARIO,
            SYSDATE,
            :NEW.LOGIN_USUARIO,
            vNOME_COMPOSTO_COORD_NEW,
            'D',
            NULL
          );
        --NEW
        --TABELA RHUSER_PESSOA_RESP_SUPERVISAO
        INSERT
        INTO RHUSER_PESSOA_RESP_SUPERVISAO
          (
            ID,
            ID_RHUSER_PESSOA_RESPONSAVEL,
            CODIGO_EMPRESA_SUBORDINADO,
            CODIGO_CONTRATO_SUBORDINADO,
            CODIGO_PESSOA_SUBORDINADO,
            TIPO_CONTRATO_SUBORDINADO,
            CODIGO_EMPRESA_CTR_SUBORDINADO,
            CODIGO_EMPRESA,
            CREATED,
            CREATEDBY,
            UPDATED,
            UPDATEDBY,
            DT_INICIO_SUPERVISAO,
            DT_FIM_SUPERVISAO,
            NOME_COMPOSTO
          )
          VALUES
          (
            (SELECT MAX(ID)+1 FROM RHUSER_PESSOA_RESP_SUPERVISAO
            )
            ,
            (SELECT MAX(ID) FROM RHUSER_PESSOA_RESPONSAVEL
            ),
            vCODIGO_EMPRESA_SUBORDINADO,
            vCODIGO_CONTRATO_SUBORDINADO,
            vCODIGO_PESSOA_SUBORDINADO,
            vTIPO_CONTRATO_SUBORDINADO,
            vCODIGO_EMPRESA_SUBORDINADO,
            vCODIGO_EMPRESA_SUBORDINADO,
            SYSDATE,
            :NEW.LOGIN_USUARIO,
            SYSDATE,
            :NEW.LOGIN_USUARIO,
            TRUNC(:NEW.DT_INI_VIGENCIA),
            TRUNC(:NEW.DT_FIM_VIGENCIA),
            vNOME_COMPOSTO_ESTAGIARIO
          );
      END IF;--FIM IF INTERNO
      --/*
      --------------------------------------------------------------------------------UPDATE------------------------------------------------------------------------------------------------------------------------------------
    elsif UPDATING  THEN
      v_DML := 'U';



      ---------------------------------INICIO if interno
      --2_1**********************--------------------- 1ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Âª vez que preenche o campo COORD ESTAGIO
      IF (vOLD_DT_FIM_VIGENCIA IS NOT NULL AND vOLD_COORD_ESTAGIO IS NOT NULL) AND (vNEW_DT_FIM_VIGENCIA IS NOT NULL AND vNEW_COORD_ESTAGIO IS NOT NULL) THEN
        --INICIO --POPULAR TABELAS
        --INICIO--buscar dados do ESTAGIARIO e O RESPONSAVEL DO CUSTO GERENCIAL DO ESTAGIARIO E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO
        SELECT C.CODIGO_EMPRESA,
          C.TIPO_CONTRATO,
          C.CODIGO,
          C.CODIGO_PESSOA,
          C.COD_CUSTO_GERENC1,
          C.COD_CUSTO_GERENC2,
          G.CODIGO_EMPRESA,
          G.TIPO_CONT_RESP,
          G.CONTRATO_RESP,
          G.COD_PESSOA_RESP,
          U.CODIGO_USUARIO ,
          C.CODIGO
          ||' - '
          ||NVL(TRIM(P.NOME_SOCIAL),TRIM(P.NOME_ACESSO))
          ||' - '
          ||C.TIPO_CONTRATO
          ||' - '
          || NVL(TRIM(G.TEXTO_ASSOCIADO),TRIM(G.DESCRICAO)) NOME_COMPOSTO_ESTAGIARIO
        INTO vCODIGO_EMPRESA_SUBORDINADO,
          vTIPO_CONTRATO_SUBORDINADO,
          vCODIGO_CONTRATO_SUBORDINADO,
          vCODIGO_PESSOA_SUBORDINADO,
          vCOD_CUSTO_GERENC1_SUBORDINAD,
          vCOD_CUSTO_GERENC2_SUBORDINAD,
          vCODIGO_EMPRESA_RESP,
          vTIPO_CONTRATO_RESP,
          vCONTRATO_RESP,
          vCOD_PESSOA_RESP,
          vCODIGO_USUARIO,
          vNOME_COMPOSTO_ESTAGIARIO
        FROM RHPESS_CONTRATO C
        LEFT OUTER JOIN RHORGA_CUSTO_GEREN G
        ON C.CODIGO_EMPRESA     = G.CODIGO_EMPRESA
        AND C.COD_CUSTO_GERENC1 = G.COD_CGERENC1
        AND C.COD_CUSTO_GERENC2 = G.COD_CGERENC2
        AND C.COD_CUSTO_GERENC3 = G.COD_CGERENC3
        AND C.COD_CUSTO_GERENC4 = G.COD_CGERENC4
        AND C.COD_CUSTO_GERENC5 = G.COD_CGERENC5
        AND C.COD_CUSTO_GERENC6 = G.COD_CGERENC6
        LEFT OUTER JOIN RHUSER_P_SIST U
        ON G.CODIGO_EMPRESA  = U.EMPRESA_USUARIO
        AND G.TIPO_CONT_RESP = U.TP_CONTR_USUARIO
        AND g.contrato_resp  = u.contrato_usuario
        LEFT OUTER JOIN RHPESS_PESSOA P
        ON P.CODIGO_EMPRESA = C.CODIGO_EMPRESA
        AND P.CODIGO        = C.CODIGO_PESSOA
        WHERE u.usuario_ldap         = u.codigo_usuario
        AND U.tipo_login ='1'
        AND U.STATUS_USUARIO NOT IN ('E')
          AND  C.CODIGO_EMPRESA     = :NEW.CODIGO_EMPRESA
          AND C.TIPO_CONTRATO      = :NEW.TIPO_CONTRATO
          AND C.CODIGO             = :NEW.CODIGO_CONTRATO
          AND C.ANO_MES_REFERENCIA =
          (SELECT MAX(AUX.ano_mes_referencia)
          FROM rhpess_contrato AUX
          WHERE AUX.codigo_empresa = c.codigo_empresa
          AND AUX.tipo_contrato    = c.tipo_contrato
          AND AUX.codigo           = c.codigo);
        --INICIO--BUSCAR O CONTRATO DO ***NOVO*** COORD_ESTAGIO da tela E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO
        SELECT C.CODIGO_EMPRESA,
          C.TIPO_CONTRATO,
          C.CODIGO,
          C.CODIGO_PESSOA ,
          C.COD_CUSTO_GERENC1 ,
          C.COD_CUSTO_GERENC2 ,
          C.CODIGO
          ||' - '
          || NVL(TRIM(P.NOME_SOCIAL),TRIM(P.NOME_ACESSO))
          ||' - '
          || C.TIPO_CONTRATO
          ||' - '
          || NVL(TRIM(G.TEXTO_ASSOCIADO),TRIM(G.DESCRICAO)) NOME_COMPOSTO_COORDENADOR
        INTO vCODIGO_EMPRESA_COORD_NEW,
          vTIPO_CONTRATO_COORD_NEW ,
          vCONTRATO_COORD_NEW ,
          vNEW_COORD_ESTAGIO,
          vCOD_CUSTO_GERENC1_COORD_NEW ,
          vCOD_CUSTO_GERENC2_COORD_NEW ,
          vNOME_COMPOSTO_COORD_NEW
        FROM RHPESS_CONTRATO C
        LEFT OUTER JOIN RHPARM_SIT_FUNC S
        ON C.SITUACAO_FUNCIONAL = S.CODIGO
        LEFT OUTER JOIN RHPESS_PESSOA P
        ON P.CODIGO_EMPRESA = C.CODIGO_EMPRESA
        AND P.CODIGO        = C.CODIGO_PESSOA
        LEFT OUTER JOIN RHORGA_CUSTO_GEREN G
        ON C.CODIGO_EMPRESA       = G.CODIGO_EMPRESA
        AND C.COD_CUSTO_GERENC1   = G.COD_CGERENC1
        AND C.COD_CUSTO_GERENC2   = G.COD_CGERENC2
        AND C.COD_CUSTO_GERENC3   = G.COD_CGERENC3
        AND C.COD_CUSTO_GERENC4   = G.COD_CGERENC4
        AND C.COD_CUSTO_GERENC5   = G.COD_CGERENC5
        AND C.COD_CUSTO_GERENC6   = G.COD_CGERENC6
        WHERE C.CODIGO_EMPRESA    = :NEW.CODIGO_EMPRESA_COORD
        AND C.TIPO_CONTRATO       = :NEW.TIPO_CONTRATO_COORD
        AND C.CODIGO      = :NEW.codigo_contrato_coord
        AND S.CONTROLE_FOLHA NOT IN ('D','S')
        AND C.DATA_RESCISAO      IS NULL
        AND C.SITUACAO_FUNCIONAL <> '1017'
        AND C.ANO_MES_REFERENCIA  =
          (SELECT MAX(AUX.ano_mes_referencia)
          FROM rhpess_contrato AUX
          WHERE AUX.codigo_empresa = c.codigo_empresa
          AND AUX.tipo_contrato    = c.tipo_contrato
          AND AUX.codigo           = c.codigo
          );
        --INICIO--BUSCAR O CONTRATO DO ***VELHO*** COORD_ESTAGIO da tela E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO

        SELECT C.CODIGO_EMPRESA,
          C.TIPO_CONTRATO,
          C.CODIGO,
          C.CODIGO_PESSOA ,
          C.COD_CUSTO_GERENC1 ,
          C.COD_CUSTO_GERENC2,
          C.CODIGO
          ||' - '
          || NVL(TRIM(P.NOME_SOCIAL),TRIM(P.NOME_ACESSO))
          ||' - '
          || C.TIPO_CONTRATO
          ||' - '
          || NVL(TRIM(G.TEXTO_ASSOCIADO),TRIM(G.DESCRICAO)) NOME_COMPOSTO_COORDENADOR
        INTO vCODIGO_EMPRESA_COORD_OLD,
          vTIPO_CONTRATO_COORD_OLD ,
          vCONTRATO_COORD_OLD,
          vOLD_COORD_ESTAGIO,
          vCOD_CUSTO_GERENC1_COORD_OLD ,
          vCOD_CUSTO_GERENC2_COORD_OLD ,
          vNOME_COMPOSTO_COORD_OLD
        FROM RHPESS_CONTRATO C
        LEFT OUTER JOIN RHPARM_SIT_FUNC S
        ON C.SITUACAO_FUNCIONAL = S.CODIGO
        LEFT OUTER JOIN RHPESS_PESSOA P
        ON P.CODIGO_EMPRESA = C.CODIGO_EMPRESA
        AND P.CODIGO        = C.CODIGO_PESSOA
        LEFT OUTER JOIN RHORGA_CUSTO_GEREN G
        ON C.CODIGO_EMPRESA       = G.CODIGO_EMPRESA
        AND C.COD_CUSTO_GERENC1   = G.COD_CGERENC1
        AND C.COD_CUSTO_GERENC2   = G.COD_CGERENC2
        AND C.COD_CUSTO_GERENC3   = G.COD_CGERENC3
        AND C.COD_CUSTO_GERENC4   = G.COD_CGERENC4
        AND C.COD_CUSTO_GERENC5   = G.COD_CGERENC5
        AND C.COD_CUSTO_GERENC6   = G.COD_CGERENC6
        WHERE C.CODIGO_EMPRESA    = :OLD.CODIGO_EMPRESA_COORD
        AND C.TIPO_CONTRATO       = :OLD.TIPO_CONTRATO_COORD
        AND C.CODIGO       = :OLD.codigo_contrato_coord
    --    AND S.CONTROLE_FOLHA      = 'N'
    ----    AND C.DATA_RESCISAO      IS NULL
      ---  AND C.SITUACAO_FUNCIONAL <> '1017'
        AND C.ANO_MES_REFERENCIA  =
          (SELECT MAX(AUX.ano_mes_referencia)
          FROM rhpess_contrato AUX
          WHERE AUX.codigo_empresa = c.codigo_empresa
          AND AUX.tipo_contrato    = c.tipo_contrato
          AND AUX.codigo           = c.codigo
          );

        --FIM --POPULAR VARIAVEIS
        IF (vCOD_PESSOA_RESP <> vNEW_COORD_ESTAGIO) THEN -------------------------COORDENADOR ESTAGIO ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° <> RESPONSAVEL DO LOCAL
          /*
          INSERT INTO SUGESP_RHPESS_INFOESTAGIO_LOG (TIPO_DML,CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,DT_INI_VIGENCIA,NEW_DT_FIM_VIGENCIA,OLD_DT_FIM_VIGENCIA,NEW_COORD_ESTAGIO,OLD_COORD_ESTAGIO,CODIGO_EMPRESA_RESP,TIPO_CONT_RESP,CONTRATO_RESP, TEXTO_TESTE_TRIGGER, LOGIN_NEW, LOGIN_OLD, DT_ULT_ALTER_USUA)
          VALUES(v_DML,:OLD.CODIGO_EMPRESA,:OLD.TIPO_CONTRATO,:OLD.CODIGO_CONTRATO,TRUNC(:OLD.DT_INI_VIGENCIA), TRUNC(:NEW.DT_FIM_VIGENCIA), TRUNC(:OLD.DT_FIM_VIGENCIA), :NEW.COORD_ESTAGIO, :OLD.COORD_ESTAGIO, vCODIGO_EMPRESA_RESP, vTIPO_CONTRATO_RESP, vCONTRATO_RESP
          ,'2_1_1ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Âª vez que preenche o campo COORD ESTAGIO-INSERTS NAS TABELAS RHUSER_PESSOA_RESPOSAVEL e RHPESS_RESP_SUPERVISAO', vLOGIN_NEW, vLOGIN_OLD, sysdate );
          */
          --NEW
          --tabela RHUSER_PESSOA_RESPONSAVEL
          INSERT
          INTO RHUSER_PESSOA_RESPONSAVEL
            (
              ID,
              ID_PROCESSO,
              ID_TAREFA,
              CODIGO_EMPRESA,
              CODIGO_USUARIO,
              CODIGO_EMPRESA_PESSOA_RESP,
              CODIGO_PESSOA_RESP,
              CODIGO_CONTRATO_RESP,
              TIPO_CONTRATO_RESP,
              CODIGO_EMPRESA_CONTRATO,
              DT_INICIO_RESPONSABILIDADE,
              DT_FIM_RESPONSABILIDADE,
              CREATED,
              CREATEDBY,
              UPDATED,
              UPDATEDBY,
              NOME_COMPOSTO,
              MOTIVO_DELEGACAO,
              ID_DELEGACAO_SUBSTITUICAO
            )
            VALUES
            (
              (SELECT MAX(ID)+1 FROM RHUSER_PESSOA_RESPONSAVEL
              )
              ,
              2,
              NULL,
              :NEW.CODIGO_EMPRESA,
              vCODIGO_USUARIO,
              vCODIGO_EMPRESA_COORD_NEW,
              vNEW_COORD_ESTAGIO,
              vCONTRATO_COORD_NEW,
              vTIPO_CONTRATO_COORD_NEW,
              vCODIGO_EMPRESA_COORD_NEW,
              TRUNC(:NEW.DT_INI_VIGENCIA),
              TRUNC(:NEW.DT_FIM_VIGENCIA),
              SYSDATE,
              :NEW.LOGIN_USUARIO,
              SYSDATE,
              :NEW.LOGIN_USUARIO,
              vNOME_COMPOSTO_COORD_NEW,
              'D',
              NULL
            );
          --NEW
          --TABELA RHUSER_PESSOA_RESP_SUPERVISAO
          INSERT
          INTO RHUSER_PESSOA_RESP_SUPERVISAO
            (
              ID,
              ID_RHUSER_PESSOA_RESPONSAVEL,
              CODIGO_EMPRESA_SUBORDINADO,
              CODIGO_CONTRATO_SUBORDINADO,
              CODIGO_PESSOA_SUBORDINADO,
              TIPO_CONTRATO_SUBORDINADO,
              CODIGO_EMPRESA_CTR_SUBORDINADO,
              CODIGO_EMPRESA,
              CREATED,
              CREATEDBY,
              UPDATED,
              UPDATEDBY,
              DT_INICIO_SUPERVISAO,
              DT_FIM_SUPERVISAO,
              NOME_COMPOSTO
            )
            VALUES
            (
              (SELECT MAX(ID)+1 FROM RHUSER_PESSOA_RESP_SUPERVISAO
              )
              ,
              (SELECT MAX(ID) FROM RHUSER_PESSOA_RESPONSAVEL
              ),
              vCODIGO_EMPRESA_SUBORDINADO,
              vCODIGO_CONTRATO_SUBORDINADO,
              vCODIGO_PESSOA_SUBORDINADO,
              vTIPO_CONTRATO_SUBORDINADO,
              vCODIGO_EMPRESA_SUBORDINADO,
              vCODIGO_EMPRESA_SUBORDINADO,
              SYSDATE,
              :NEW.LOGIN_USUARIO,
              SYSDATE,
              :NEW.LOGIN_USUARIO,
              TRUNC(:NEW.DT_INI_VIGENCIA),
              TRUNC(:NEW.DT_FIM_VIGENCIA),
              vNOME_COMPOSTO_ESTAGIARIO
            );
        END IF; -------------------------COORDENADOR ESTAGIO ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° <> RESPONSAVEL DO LOCAL
        --END IF;
        --2_3**********************------------------------ --  RETIROU COORD ESTAGIO
      elsif ((vNEW_DT_FIM_VIGENCIA IS NOT NULL AND vOLD_DT_FIM_VIGENCIA IS NOT NULL) --AND (vNEW_DT_FIM_VIGENCIA = vOLD_DT_FIM_VIGENCIA)
        ) AND ((vNEW_COORD_ESTAGIO IS NULL AND vOLD_COORD_ESTAGIO IS NOT NULL)) THEN
        --INICIO --POPULAR TABELAS
        --INICIO--buscar dados do ESTAGIARIO e O RESPONSAVEL DO CUSTO GERENCIAL DO ESTAGIARIO E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO
        SELECT C.CODIGO_EMPRESA,
          C.TIPO_CONTRATO,
          C.CODIGO,
          C.CODIGO_PESSOA,
          C.COD_CUSTO_GERENC1,
          C.COD_CUSTO_GERENC2,
          G.CODIGO_EMPRESA,
          G.TIPO_CONT_RESP,
          G.CONTRATO_RESP,
          G.COD_PESSOA_RESP,
          U.CODIGO_USUARIO ,
          C.CODIGO
          ||' - '
          ||NVL(TRIM(P.NOME_SOCIAL),TRIM(P.NOME_ACESSO))
          ||' - '
          ||C.TIPO_CONTRATO
          ||' - '
          || NVL(TRIM(G.TEXTO_ASSOCIADO),TRIM(G.DESCRICAO)) NOME_COMPOSTO_ESTAGIARIO
        INTO vCODIGO_EMPRESA_SUBORDINADO,
          vTIPO_CONTRATO_SUBORDINADO,
          vCODIGO_CONTRATO_SUBORDINADO,
          vCODIGO_PESSOA_SUBORDINADO,
          vCOD_CUSTO_GERENC1_SUBORDINAD,
          vCOD_CUSTO_GERENC2_SUBORDINAD,
          vCODIGO_EMPRESA_RESP,
          vTIPO_CONTRATO_RESP,
          vCONTRATO_RESP,
          vCOD_PESSOA_RESP,
          vCODIGO_USUARIO,
          vNOME_COMPOSTO_ESTAGIARIO
        FROM RHPESS_CONTRATO C
        LEFT OUTER JOIN RHORGA_CUSTO_GEREN G
        ON C.CODIGO_EMPRESA     = G.CODIGO_EMPRESA
        AND C.COD_CUSTO_GERENC1 = G.COD_CGERENC1
        AND C.COD_CUSTO_GERENC2 = G.COD_CGERENC2
        AND C.COD_CUSTO_GERENC3 = G.COD_CGERENC3
        AND C.COD_CUSTO_GERENC4 = G.COD_CGERENC4
        AND C.COD_CUSTO_GERENC5 = G.COD_CGERENC5
        AND C.COD_CUSTO_GERENC6 = G.COD_CGERENC6
        LEFT OUTER JOIN RHUSER_P_SIST U
        ON G.CODIGO_EMPRESA  = U.EMPRESA_USUARIO
        AND G.TIPO_CONT_RESP = U.TP_CONTR_USUARIO
        AND g.contrato_resp  = u.contrato_usuario
        LEFT OUTER JOIN RHPESS_PESSOA P
        ON P.CODIGO_EMPRESA = C.CODIGO_EMPRESA
        AND P.CODIGO        = C.CODIGO_PESSOA
        WHERE u.usuario_ldap         = u.codigo_usuario
        AND U.tipo_login ='1'
        AND U.STATUS_USUARIO NOT IN ('E')
        AND  C.CODIGO_EMPRESA     = :NEW.CODIGO_EMPRESA
        AND C.TIPO_CONTRATO      = :NEW.TIPO_CONTRATO
        AND C.CODIGO             = :NEW.CODIGO_CONTRATO
        AND C.ANO_MES_REFERENCIA =
          (SELECT MAX(AUX.ano_mes_referencia)
          FROM rhpess_contrato AUX
          WHERE AUX.codigo_empresa = c.codigo_empresa
          AND AUX.tipo_contrato    = c.tipo_contrato
          AND AUX.codigo           = c.codigo);
        --INICIO--BUSCAR O CONTRATO DO ***NOVO*** COORD_ESTAGIO da tela E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO
        SELECT C.CODIGO_EMPRESA,
          C.TIPO_CONTRATO,
          C.CODIGO,
          C.CODIGO_PESSOA ,
          C.COD_CUSTO_GERENC1 ,
          C.COD_CUSTO_GERENC2 ,
          C.CODIGO
          ||' - '
          || NVL(TRIM(P.NOME_SOCIAL),TRIM(P.NOME_ACESSO))
          ||' - '
          || C.TIPO_CONTRATO
          ||' - '
          || NVL(TRIM(G.TEXTO_ASSOCIADO),TRIM(G.DESCRICAO)) NOME_COMPOSTO_COORDENADOR
        INTO vCODIGO_EMPRESA_COORD_NEW,
          vTIPO_CONTRATO_COORD_NEW ,
          vCONTRATO_COORD_NEW ,
          vNEW_COORD_ESTAGIO,
          vCOD_CUSTO_GERENC1_COORD_NEW ,
          vCOD_CUSTO_GERENC2_COORD_NEW ,
          vNOME_COMPOSTO_COORD_NEW
        FROM RHPESS_CONTRATO C
        LEFT OUTER JOIN RHPARM_SIT_FUNC S
        ON C.SITUACAO_FUNCIONAL = S.CODIGO
        LEFT OUTER JOIN RHPESS_PESSOA P
        ON P.CODIGO_EMPRESA = C.CODIGO_EMPRESA
        AND P.CODIGO        = C.CODIGO_PESSOA
        LEFT OUTER JOIN RHORGA_CUSTO_GEREN G
        ON C.CODIGO_EMPRESA       = G.CODIGO_EMPRESA
        AND C.COD_CUSTO_GERENC1   = G.COD_CGERENC1
        AND C.COD_CUSTO_GERENC2   = G.COD_CGERENC2
        AND C.COD_CUSTO_GERENC3   = G.COD_CGERENC3
        AND C.COD_CUSTO_GERENC4   = G.COD_CGERENC4
        AND C.COD_CUSTO_GERENC5   = G.COD_CGERENC5
        AND C.COD_CUSTO_GERENC6   = G.COD_CGERENC6
        WHERE C.CODIGO_EMPRESA    = :NEW.CODIGO_EMPRESA_COORD
        AND C.TIPO_CONTRATO       = :NEW.TIPO_CONTRATO_COORD
        AND C.CODIGO       = :NEW.codigo_contrato_coord
        AND S.CONTROLE_FOLHA      = 'N'
        AND C.DATA_RESCISAO      IS NULL
        AND C.SITUACAO_FUNCIONAL <> '1017'
        AND C.ANO_MES_REFERENCIA  =
          (SELECT MAX(AUX.ano_mes_referencia)
          FROM rhpess_contrato AUX
          WHERE AUX.codigo_empresa = c.codigo_empresa
          AND AUX.tipo_contrato    = c.tipo_contrato
          AND AUX.codigo           = c.codigo
          );
        --INICIO--BUSCAR O CONTRATO DO ***VELHO*** COORD_ESTAGIO da tela E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO

        SELECT C.CODIGO_EMPRESA,
          C.TIPO_CONTRATO,
          C.CODIGO,
          C.CODIGO_PESSOA ,
          C.COD_CUSTO_GERENC1 ,
          C.COD_CUSTO_GERENC2,
          C.CODIGO
          ||' - '
          || NVL(TRIM(P.NOME_SOCIAL),TRIM(P.NOME_ACESSO))
          ||' - '
          || C.TIPO_CONTRATO
          ||' - '
          || NVL(TRIM(G.TEXTO_ASSOCIADO),TRIM(G.DESCRICAO)) NOME_COMPOSTO_COORDENADOR
        INTO vCODIGO_EMPRESA_COORD_OLD,
          vTIPO_CONTRATO_COORD_OLD ,
          vCONTRATO_COORD_OLD,
          vOLD_COORD_ESTAGIO,
          vCOD_CUSTO_GERENC1_COORD_OLD ,
          vCOD_CUSTO_GERENC2_COORD_OLD ,
          vNOME_COMPOSTO_COORD_OLD
        FROM RHPESS_CONTRATO C
        LEFT OUTER JOIN RHPARM_SIT_FUNC S
        ON C.SITUACAO_FUNCIONAL = S.CODIGO
        LEFT OUTER JOIN RHPESS_PESSOA P
        ON P.CODIGO_EMPRESA = C.CODIGO_EMPRESA
        AND P.CODIGO        = C.CODIGO_PESSOA
        LEFT OUTER JOIN RHORGA_CUSTO_GEREN G
        ON C.CODIGO_EMPRESA       = G.CODIGO_EMPRESA
        AND C.COD_CUSTO_GERENC1   = G.COD_CGERENC1
        AND C.COD_CUSTO_GERENC2   = G.COD_CGERENC2
        AND C.COD_CUSTO_GERENC3   = G.COD_CGERENC3
        AND C.COD_CUSTO_GERENC4   = G.COD_CGERENC4
        AND C.COD_CUSTO_GERENC5   = G.COD_CGERENC5
        AND C.COD_CUSTO_GERENC6   = G.COD_CGERENC6
        WHERE C.CODIGO_EMPRESA    = :OLD.CODIGO_EMPRESA_COORD
        AND C.TIPO_CONTRATO       = :OLD.TIPO_CONTRATO_COORD
        AND C.CODIGO       = :OLD.codigo_contrato_coord
    --    AND S.CONTROLE_FOLHA      = 'N'
    ----    AND C.DATA_RESCISAO      IS NULL
      ---  AND C.SITUACAO_FUNCIONAL <> '1017'
        AND C.ANO_MES_REFERENCIA  =
          (SELECT MAX(AUX.ano_mes_referencia)
          FROM rhpess_contrato AUX
          WHERE AUX.codigo_empresa = c.codigo_empresa
          AND AUX.tipo_contrato    = c.tipo_contrato
          AND AUX.codigo           = c.codigo
          );

        --FIM --POPULAR VARIAVEIS
        --INICIO IF INTERNO
        IF (vCOD_PESSOA_RESP <> vOLD_COORD_ESTAGIO) THEN-------------------------COORDENADOR ESTAGIO ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° <> RESPONSAVEL DO LOCAL
          /*
          INSERT INTO SUGESP_RHPESS_INFOESTAGIO_LOG (TIPO_DML,CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,DT_INI_VIGENCIA,NEW_DT_FIM_VIGENCIA,OLD_DT_FIM_VIGENCIA,NEW_COORD_ESTAGIO,OLD_COORD_ESTAGIO,CODIGO_EMPRESA_RESP,TIPO_CONT_RESP,CONTRATO_RESP, TEXTO_TESTE_TRIGGER, LOGIN_NEW, LOGIN_OLD, DT_ULT_ALTER_USUA)
          VALUES(v_DML,:OLD.CODIGO_EMPRESA,:OLD.TIPO_CONTRATO,:OLD.CODIGO_CONTRATO,:OLD.DT_INI_VIGENCIA,:NEW.DT_FIM_VIGENCIA,:OLD.DT_FIM_VIGENCIA,:NEW.COORD_ESTAGIO,:OLD.COORD_ESTAGIO,vCODIGO_EMPRESA_RESP,vTIPO_CONTRATO_RESP, vCONTRATO_RESP
          ,'2_3_RETIROU COORD ESTAGIO-UPDATE DATA FIM com sysdate DO REGISTRO EXISTENTE (old) NAS TABELAS RHUSER_PESSOA_RESPOSAVEL e RHPESS_RESP_SUPERVISAO', vLOGIN_NEW, vLOGIN_OLD, sysdate );
          */
          --OLD
          --tabela RHUSER_PESSOA_RESPONSAVEL
          UPDATE RHUSER_PESSOA_RESPONSAVEL
          SET DT_FIM_RESPONSABILIDADE    = TRUNC(SYSDATE),
            UPDATED                      = SYSDATE,
            UPDATEDBY                    = vLOGIN_USUARIO_NEW
          WHERE motivo_delegacao         = 'D'
          AND ID_PROCESSO                = 2
          AND CODIGO_EMPRESA             = :OLD.CODIGO_EMPRESA
          AND CODIGO_EMPRESA_PESSOA_RESP = vCODIGO_EMPRESA_COORD_OLD
          AND CODIGO_PESSOA_RESP         = vOLD_COORD_ESTAGIO
          AND CODIGO_CONTRATO_RESP       = vCONTRATO_COORD_OLD
          AND TIPO_CONTRATO_RESP         = vTIPO_CONTRATO_COORD_OLD
          AND CODIGO_EMPRESA_CONTRATO    = vCODIGO_EMPRESA_COORD_OLD
          AND DT_INICIO_RESPONSABILIDADE = :OLD.DT_INI_VIGENCIA
          AND DT_FIM_RESPONSABILIDADE    = :OLD.DT_FIM_VIGENCIA;
          --OLD
          --TABELA RHUSER_PESSOA_RESP_SUPERVISAO
          UPDATE RHUSER_PESSOA_RESP_SUPERVISAO
          SET DT_FIM_SUPERVISAO              = TRUNC(SYSDATE),
            UPDATED                          = SYSDATE,
            UPDATEDBY                        = vLOGIN_USUARIO_NEW
          WHERE CODIGO_EMPRESA_SUBORDINADO   = vCODIGO_EMPRESA_SUBORDINADO
          AND CODIGO_CONTRATO_SUBORDINADO    = vCODIGO_CONTRATO_SUBORDINADO
          AND CODIGO_PESSOA_SUBORDINADO      = vCODIGO_PESSOA_SUBORDINADO
          AND TIPO_CONTRATO_SUBORDINADO      = vTIPO_CONTRATO_SUBORDINADO
          AND CODIGO_EMPRESA_CTR_SUBORDINADO = vCODIGO_EMPRESA_SUBORDINADO
          AND DT_INICIO_SUPERVISAO           = :OLD.DT_INI_VIGENCIA
          AND DT_FIM_SUPERVISAO              = :OLD.DT_FIM_VIGENCIA;
        END IF; --FIM IF INTERNO
        --2_4.1**********************---------------------------- apenas ATUALIZOU COORD ESTAGIO e ANTIGO E NOVO COORDENADOR <> DO GESTOR FORMAL DO LOCAL
      elsif ((vNEW_DT_FIM_VIGENCIA IS NOT NULL AND vOLD_DT_FIM_VIGENCIA IS NOT NULL) --AND (vNEW_DT_FIM_VIGENCIA = vOLD_DT_FIM_VIGENCIA)
        ) AND ((vNEW_COORD_ESTAGIO IS NOT NULL AND vOLD_COORD_ESTAGIO IS NOT NULL)   --AND (vNEW_COORD_ESTAGIO <> vOLD_COORD_ESTAGIO)
        ) THEN
        --INICIO --POPULAR TABELAS
        --INICIO--buscar dados do ESTAGIARIO e O RESPONSAVEL DO CUSTO GERENCIAL DO ESTAGIARIO E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO
        SELECT C.CODIGO_EMPRESA,
          C.TIPO_CONTRATO,
          C.CODIGO,
          C.CODIGO_PESSOA,
          C.COD_CUSTO_GERENC1,
          C.COD_CUSTO_GERENC2,
          G.CODIGO_EMPRESA,
          G.TIPO_CONT_RESP,
          G.CONTRATO_RESP,
          G.COD_PESSOA_RESP,
          U.CODIGO_USUARIO ,
          C.CODIGO
          ||' - '
          ||NVL(TRIM(P.NOME_SOCIAL),TRIM(P.NOME_ACESSO))
          ||' - '
          ||C.TIPO_CONTRATO
          ||' - '
          || NVL(TRIM(G.TEXTO_ASSOCIADO),TRIM(G.DESCRICAO)) NOME_COMPOSTO_ESTAGIARIO
        INTO vCODIGO_EMPRESA_SUBORDINADO,
          vTIPO_CONTRATO_SUBORDINADO,
          vCODIGO_CONTRATO_SUBORDINADO,
          vCODIGO_PESSOA_SUBORDINADO,
          vCOD_CUSTO_GERENC1_SUBORDINAD,
          vCOD_CUSTO_GERENC2_SUBORDINAD,
          vCODIGO_EMPRESA_RESP,
          vTIPO_CONTRATO_RESP,
          vCONTRATO_RESP,
          vCOD_PESSOA_RESP,
          vCODIGO_USUARIO,
          vNOME_COMPOSTO_ESTAGIARIO
        FROM RHPESS_CONTRATO C
        LEFT OUTER JOIN RHORGA_CUSTO_GEREN G
        ON C.CODIGO_EMPRESA     = G.CODIGO_EMPRESA
        AND C.COD_CUSTO_GERENC1 = G.COD_CGERENC1
        AND C.COD_CUSTO_GERENC2 = G.COD_CGERENC2
        AND C.COD_CUSTO_GERENC3 = G.COD_CGERENC3
        AND C.COD_CUSTO_GERENC4 = G.COD_CGERENC4
        AND C.COD_CUSTO_GERENC5 = G.COD_CGERENC5
        AND C.COD_CUSTO_GERENC6 = G.COD_CGERENC6
        LEFT OUTER JOIN RHUSER_P_SIST U
        ON G.CODIGO_EMPRESA  = U.EMPRESA_USUARIO
        AND G.TIPO_CONT_RESP = U.TP_CONTR_USUARIO
        AND g.contrato_resp  = u.contrato_usuario
        LEFT OUTER JOIN RHPESS_PESSOA P
        ON P.CODIGO_EMPRESA = C.CODIGO_EMPRESA
        AND P.CODIGO        = C.CODIGO_PESSOA
        WHERE u.usuario_ldap         = u.codigo_usuario
        AND U.tipo_login ='1'
        AND U.STATUS_USUARIO NOT IN ('E')
        AND   C.CODIGO_EMPRESA     = :NEW.CODIGO_EMPRESA
        AND C.TIPO_CONTRATO      = :NEW.TIPO_CONTRATO
        AND C.CODIGO             = :NEW.CODIGO_CONTRATO
        AND C.ANO_MES_REFERENCIA =
          (SELECT MAX(AUX.ano_mes_referencia)
          FROM rhpess_contrato AUX
          WHERE AUX.codigo_empresa = c.codigo_empresa
          AND AUX.tipo_contrato    = c.tipo_contrato
          AND AUX.codigo           = c.codigo

          );
        --INICIO--BUSCAR O CONTRATO DO ***NOVO*** COORD_ESTAGIO da tela E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO
        SELECT C.CODIGO_EMPRESA,
          C.TIPO_CONTRATO,
          C.CODIGO,
          C.CODIGO_PESSOA ,
          C.COD_CUSTO_GERENC1 ,
          C.COD_CUSTO_GERENC2 ,
          C.CODIGO
          ||' - '
          || NVL(TRIM(P.NOME_SOCIAL),TRIM(P.NOME_ACESSO))
          ||' - '
          || C.TIPO_CONTRATO
          ||' - '
          || NVL(TRIM(G.TEXTO_ASSOCIADO),TRIM(G.DESCRICAO)) NOME_COMPOSTO_COORDENADOR
        INTO vCODIGO_EMPRESA_COORD_NEW,
          vTIPO_CONTRATO_COORD_NEW ,
          vCONTRATO_COORD_NEW ,
          vNEW_COORD_ESTAGIO,
          vCOD_CUSTO_GERENC1_COORD_NEW ,
          vCOD_CUSTO_GERENC2_COORD_NEW ,
          vNOME_COMPOSTO_COORD_NEW
        FROM RHPESS_CONTRATO C
        LEFT OUTER JOIN RHPARM_SIT_FUNC S
        ON C.SITUACAO_FUNCIONAL = S.CODIGO
        LEFT OUTER JOIN RHPESS_PESSOA P
        ON P.CODIGO_EMPRESA = C.CODIGO_EMPRESA
        AND P.CODIGO        = C.CODIGO_PESSOA
        LEFT OUTER JOIN RHORGA_CUSTO_GEREN G
        ON C.CODIGO_EMPRESA       = G.CODIGO_EMPRESA
        AND C.COD_CUSTO_GERENC1   = G.COD_CGERENC1
        AND C.COD_CUSTO_GERENC2   = G.COD_CGERENC2
        AND C.COD_CUSTO_GERENC3   = G.COD_CGERENC3
        AND C.COD_CUSTO_GERENC4   = G.COD_CGERENC4
        AND C.COD_CUSTO_GERENC5   = G.COD_CGERENC5
        AND C.COD_CUSTO_GERENC6   = G.COD_CGERENC6
        WHERE C.CODIGO_EMPRESA    = :NEW.CODIGO_EMPRESA_COORD
        AND C.TIPO_CONTRATO       = :NEW.TIPO_CONTRATO_COORD
        AND C.CODIGO      = :NEW.codigo_contrato_coord
        AND S.CONTROLE_FOLHA NOT IN ('D','S')
        AND C.DATA_RESCISAO      IS NULL
        AND C.SITUACAO_FUNCIONAL <> '1017'
        AND C.ANO_MES_REFERENCIA  =
          (SELECT MAX(AUX.ano_mes_referencia)
          FROM rhpess_contrato AUX
          WHERE AUX.codigo_empresa = c.codigo_empresa
          AND AUX.tipo_contrato    = c.tipo_contrato
          AND AUX.codigo           = c.codigo
          );
        --INICIO--BUSCAR O CONTRATO DO ***VELHO*** COORD_ESTAGIO da tela E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO

        SELECT C.CODIGO_EMPRESA,
          C.TIPO_CONTRATO,
          C.CODIGO,
          C.CODIGO_PESSOA ,
          C.COD_CUSTO_GERENC1 ,
          C.COD_CUSTO_GERENC2,
          C.CODIGO
          ||' - '
          || NVL(TRIM(P.NOME_SOCIAL),TRIM(P.NOME_ACESSO))
          ||' - '
          || C.TIPO_CONTRATO
          ||' - '
          || NVL(TRIM(G.TEXTO_ASSOCIADO),TRIM(G.DESCRICAO)) NOME_COMPOSTO_COORDENADOR
        INTO vCODIGO_EMPRESA_COORD_OLD,
          vTIPO_CONTRATO_COORD_OLD ,
          vCONTRATO_COORD_OLD,
          vOLD_COORD_ESTAGIO,
          vCOD_CUSTO_GERENC1_COORD_OLD ,
          vCOD_CUSTO_GERENC2_COORD_OLD ,
          vNOME_COMPOSTO_COORD_OLD
        FROM RHPESS_CONTRATO C
        LEFT OUTER JOIN RHPARM_SIT_FUNC S
        ON C.SITUACAO_FUNCIONAL = S.CODIGO
        LEFT OUTER JOIN RHPESS_PESSOA P
        ON P.CODIGO_EMPRESA = C.CODIGO_EMPRESA
        AND P.CODIGO        = C.CODIGO_PESSOA
        LEFT OUTER JOIN RHORGA_CUSTO_GEREN G
        ON C.CODIGO_EMPRESA       = G.CODIGO_EMPRESA
        AND C.COD_CUSTO_GERENC1   = G.COD_CGERENC1
        AND C.COD_CUSTO_GERENC2   = G.COD_CGERENC2
        AND C.COD_CUSTO_GERENC3   = G.COD_CGERENC3
        AND C.COD_CUSTO_GERENC4   = G.COD_CGERENC4
        AND C.COD_CUSTO_GERENC5   = G.COD_CGERENC5
        AND C.COD_CUSTO_GERENC6   = G.COD_CGERENC6
        WHERE C.CODIGO_EMPRESA    = :OLD.CODIGO_EMPRESA_COORD
        AND C.TIPO_CONTRATO       = :OLD.TIPO_CONTRATO_COORD
        AND C.CODIGO       = :OLD.codigo_contrato_coord
    --    AND S.CONTROLE_FOLHA      = 'N'
    ----    AND C.DATA_RESCISAO      IS NULL
      ---  AND C.SITUACAO_FUNCIONAL <> '1017'
        AND C.ANO_MES_REFERENCIA  =
          (SELECT MAX(AUX.ano_mes_referencia)
          FROM rhpess_contrato AUX
          WHERE AUX.codigo_empresa = c.codigo_empresa
          AND AUX.tipo_contrato    = c.tipo_contrato
          AND AUX.codigo           = c.codigo
          );

        --FIM --POPULAR VARIAVEIS
        IF (vCOD_PESSOA_RESP <> vOLD_COORD_ESTAGIO) AND (vCOD_PESSOA_RESP <> vNEW_COORD_ESTAGIO) THEN-------------------------COORDENADOR ESTAGIO ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° <> RESPONSAVEL DO LOCAL
          --************PARTE ANTIGA
          /*
          INSERT INTO SUGESP_RHPESS_INFOESTAGIO_LOG (TIPO_DML,CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,DT_INI_VIGENCIA,NEW_DT_FIM_VIGENCIA,OLD_DT_FIM_VIGENCIA,NEW_COORD_ESTAGIO,OLD_COORD_ESTAGIO,CODIGO_EMPRESA_RESP,TIPO_CONT_RESP,CONTRATO_RESP, TEXTO_TESTE_TRIGGER, LOGIN_NEW, LOGIN_OLD, DT_ULT_ALTER_USUA)
          VALUES(v_DML,:OLD.CODIGO_EMPRESA,:OLD.TIPO_CONTRATO,:OLD.CODIGO_CONTRATO,:OLD.DT_INI_VIGENCIA,:NEW.DT_FIM_VIGENCIA,:OLD.DT_FIM_VIGENCIA,:NEW.COORD_ESTAGIO,:OLD.COORD_ESTAGIO,vCODIGO_EMPRESA_RESP,vTIPO_CONTRATO_RESP, vCONTRATO_RESP
          ,'2_4.1_1_UPDATE DATA FIM com sysdate DO REGISTRO EXISTENTE (old) NAS TABELAS RHUSER_PESSOA_RESPOSAVEL e RHPESS_RESP_SUPERVISAO', vLOGIN_NEW, vLOGIN_OLD, sysdate );
          */
          --OLD
          --tabela RHUSER_PESSOA_RESPONSAVEL
          UPDATE RHUSER_PESSOA_RESPONSAVEL
          SET DT_FIM_RESPONSABILIDADE    = TRUNC(SYSDATE),
            UPDATED                      = SYSDATE,
            UPDATEDBY                    = vLOGIN_USUARIO_NEW
          WHERE motivo_delegacao         = 'D'
          AND ID_PROCESSO                = 2
          AND CODIGO_EMPRESA             = :OLD.CODIGO_EMPRESA
          AND CODIGO_EMPRESA_PESSOA_RESP = vCODIGO_EMPRESA_COORD_OLD
          AND CODIGO_PESSOA_RESP         = vOLD_COORD_ESTAGIO
          AND CODIGO_CONTRATO_RESP       = vCONTRATO_COORD_OLD
          AND TIPO_CONTRATO_RESP         = vTIPO_CONTRATO_COORD_OLD
          AND CODIGO_EMPRESA_CONTRATO    = vCODIGO_EMPRESA_COORD_OLD
          AND DT_INICIO_RESPONSABILIDADE = :OLD.DT_INI_VIGENCIA
          AND DT_FIM_RESPONSABILIDADE    = :OLD.DT_FIM_VIGENCIA;
          --OLD
          --TABELA RHUSER_PESSOA_RESP_SUPERVISAO
          UPDATE RHUSER_PESSOA_RESP_SUPERVISAO
          SET DT_FIM_SUPERVISAO              = TRUNC(SYSDATE),
            UPDATED                          = SYSDATE,
            UPDATEDBY                        = vLOGIN_USUARIO_NEW
          WHERE CODIGO_EMPRESA_SUBORDINADO   = vCODIGO_EMPRESA_SUBORDINADO
          AND CODIGO_CONTRATO_SUBORDINADO    = vCODIGO_CONTRATO_SUBORDINADO
          AND CODIGO_PESSOA_SUBORDINADO      = vCODIGO_PESSOA_SUBORDINADO
          AND TIPO_CONTRATO_SUBORDINADO      = vTIPO_CONTRATO_SUBORDINADO
          AND CODIGO_EMPRESA_CTR_SUBORDINADO = vCODIGO_EMPRESA_SUBORDINADO
          AND DT_INICIO_SUPERVISAO           = :OLD.DT_INI_VIGENCIA
          AND DT_FIM_SUPERVISAO              = :OLD.DT_FIM_VIGENCIA;
          --************PARTE NOVA
          /*
          INSERT INTO SUGESP_RHPESS_INFOESTAGIO_LOG (TIPO_DML,CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,DT_INI_VIGENCIA,NEW_DT_FIM_VIGENCIA,OLD_DT_FIM_VIGENCIA,NEW_COORD_ESTAGIO,OLD_COORD_ESTAGIO,CODIGO_EMPRESA_RESP,TIPO_CONT_RESP,CONTRATO_RESP, TEXTO_TESTE_TRIGGER,  LOGIN_NEW, LOGIN_OLD, DT_ULT_ALTER_USUA)
          VALUES(v_DML,:OLD.CODIGO_EMPRESA,:OLD.TIPO_CONTRATO,:OLD.CODIGO_CONTRATO,:OLD.DT_INI_VIGENCIA,:NEW.DT_FIM_VIGENCIA,:OLD.DT_FIM_VIGENCIA,:NEW.COORD_ESTAGIO,:OLD.COORD_ESTAGIO,vCODIGO_EMPRESA_RESP,vTIPO_CONTRATO_RESP, vCONTRATO_RESP
          ,'2_4.1_2_INSERTS (new) NAS TABELAS RHUSER_PESSOA_RESPOSAVEL e RHPESS_RESP_SUPERVISAO', vLOGIN_NEW, vLOGIN_OLD, sysdate );
          */
          --NEW
          --tabela RHUSER_PESSOA_RESPONSAVEL
          INSERT
          INTO RHUSER_PESSOA_RESPONSAVEL
            (
              ID,
              ID_PROCESSO,
              ID_TAREFA,
              CODIGO_EMPRESA,
              CODIGO_USUARIO,
              CODIGO_EMPRESA_PESSOA_RESP,
              CODIGO_PESSOA_RESP,
              CODIGO_CONTRATO_RESP,
              TIPO_CONTRATO_RESP,
              CODIGO_EMPRESA_CONTRATO,
              DT_INICIO_RESPONSABILIDADE,
              DT_FIM_RESPONSABILIDADE,
              CREATED,
              CREATEDBY,
              UPDATED,
              UPDATEDBY,
              NOME_COMPOSTO,
              MOTIVO_DELEGACAO,
              ID_DELEGACAO_SUBSTITUICAO
            )
            VALUES
            (
              (SELECT MAX(ID)+1 FROM RHUSER_PESSOA_RESPONSAVEL
              )
              ,
              2,
              NULL,
              :NEW.CODIGO_EMPRESA,
              vCODIGO_USUARIO,
              vCODIGO_EMPRESA_COORD_NEW,
              vNEW_COORD_ESTAGIO,
              vCONTRATO_COORD_NEW,
              vTIPO_CONTRATO_COORD_NEW,
              vCODIGO_EMPRESA_COORD_NEW,
              TRUNC(:NEW.DT_INI_VIGENCIA),
              TRUNC(:NEW.DT_FIM_VIGENCIA),
              SYSDATE,
              :NEW.LOGIN_USUARIO,
              SYSDATE,
              :NEW.LOGIN_USUARIO,
              vNOME_COMPOSTO_COORD_NEW,
              'D',
              NULL
            );
          --NEW
          --TABELA RHUSER_PESSOA_RESP_SUPERVISAO
          INSERT
          INTO RHUSER_PESSOA_RESP_SUPERVISAO
            (
              ID,
              ID_RHUSER_PESSOA_RESPONSAVEL,
              CODIGO_EMPRESA_SUBORDINADO,
              CODIGO_CONTRATO_SUBORDINADO,
              CODIGO_PESSOA_SUBORDINADO,
              TIPO_CONTRATO_SUBORDINADO,
              CODIGO_EMPRESA_CTR_SUBORDINADO,
              CODIGO_EMPRESA,
              CREATED,
              CREATEDBY,
              UPDATED,
              UPDATEDBY,
              DT_INICIO_SUPERVISAO,
              DT_FIM_SUPERVISAO,
              NOME_COMPOSTO
            )
            VALUES
            (
              (SELECT MAX(ID)+1 FROM RHUSER_PESSOA_RESP_SUPERVISAO
              )
              ,
              (SELECT MAX(ID) FROM RHUSER_PESSOA_RESPONSAVEL
              ),
              vCODIGO_EMPRESA_SUBORDINADO,
              vCODIGO_CONTRATO_SUBORDINADO,
              vCODIGO_PESSOA_SUBORDINADO,
              vTIPO_CONTRATO_SUBORDINADO,
              vCODIGO_EMPRESA_SUBORDINADO,
              vCODIGO_EMPRESA_SUBORDINADO,
              SYSDATE,
              :NEW.LOGIN_USUARIO,
              SYSDATE,
              :NEW.LOGIN_USUARIO,
              TRUNC(:NEW.DT_INI_VIGENCIA),
              TRUNC(:NEW.DT_FIM_VIGENCIA),
              vNOME_COMPOSTO_ESTAGIARIO
            );
        END IF; --FIM IF INTERNO
        --2_4.2**********************---------------------------- apenas ATUALIZOU COORD ESTAGIO e COORDENADOR  ANTIGO <> E NOVO = aO GESTOR FORMAL DO LOCAL
        IF (vCOD_PESSOA_RESP <> vOLD_COORD_ESTAGIO) AND (vCOD_PESSOA_RESP = vNEW_COORD_ESTAGIO) THEN -------------------------COORDENADOR ESTAGIO ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° <> RESPONSAVEL DO LOCAL
          /*
          INSERT INTO SUGESP_RHPESS_INFOESTAGIO_LOG (TIPO_DML,CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,DT_INI_VIGENCIA,NEW_DT_FIM_VIGENCIA,OLD_DT_FIM_VIGENCIA,NEW_COORD_ESTAGIO,OLD_COORD_ESTAGIO,CODIGO_EMPRESA_RESP,TIPO_CONT_RESP,CONTRATO_RESP, TEXTO_TESTE_TRIGGER, LOGIN_NEW, LOGIN_OLD, DT_ULT_ALTER_USUA)
          VALUES(v_DML,:OLD.CODIGO_EMPRESA,:OLD.TIPO_CONTRATO,:OLD.CODIGO_CONTRATO,:OLD.DT_INI_VIGENCIA,:NEW.DT_FIM_VIGENCIA,:OLD.DT_FIM_VIGENCIA,:NEW.COORD_ESTAGIO,:OLD.COORD_ESTAGIO,vCODIGO_EMPRESA_RESP,vTIPO_CONTRATO_RESP, vCONTRATO_RESP
          ,'2_4.2_UPDATE DATA FIM com SYSDATE do REGISTRO EXISTENTE (old) NAS TABELAS RHUSER_PESSOA_RESPOSAVEL e RHPESS_RESP_SUPERVISAO', vLOGIN_NEW, vLOGIN_OLD, sysdate );
          */
          --OLD
          --tabela RHUSER_PESSOA_RESPONSAVEL
          UPDATE RHUSER_PESSOA_RESPONSAVEL
          SET DT_FIM_RESPONSABILIDADE    = TRUNC(sysdate),
            UPDATED                      = SYSDATE,
            UPDATEDBY                    = vLOGIN_USUARIO_NEW
          WHERE motivo_delegacao         = 'D'
          AND ID_PROCESSO                = 2
          AND CODIGO_EMPRESA             = :OLD.CODIGO_EMPRESA
          AND CODIGO_EMPRESA_PESSOA_RESP = vCODIGO_EMPRESA_COORD_OLD
          AND CODIGO_PESSOA_RESP         = vOLD_COORD_ESTAGIO
          AND CODIGO_CONTRATO_RESP       = vCONTRATO_COORD_OLD
          AND TIPO_CONTRATO_RESP         = vTIPO_CONTRATO_COORD_OLD
          AND CODIGO_EMPRESA_CONTRATO    = vCODIGO_EMPRESA_COORD_OLD
          AND DT_INICIO_RESPONSABILIDADE = :OLD.DT_INI_VIGENCIA
          AND DT_FIM_RESPONSABILIDADE    = :OLD.DT_FIM_VIGENCIA;
          --OLD
          --TABELA RHUSER_PESSOA_RESP_SUPERVISAO
          UPDATE RHUSER_PESSOA_RESP_SUPERVISAO
          SET DT_FIM_SUPERVISAO              = TRUNC(sysdate),
            UPDATED                          = SYSDATE,
            UPDATEDBY                        = vLOGIN_USUARIO_NEW
          WHERE CODIGO_EMPRESA_SUBORDINADO   = vCODIGO_EMPRESA_SUBORDINADO
          AND CODIGO_CONTRATO_SUBORDINADO    = vCODIGO_CONTRATO_SUBORDINADO
          AND CODIGO_PESSOA_SUBORDINADO      = vCODIGO_PESSOA_SUBORDINADO
          AND TIPO_CONTRATO_SUBORDINADO      = vTIPO_CONTRATO_SUBORDINADO
          AND CODIGO_EMPRESA_CTR_SUBORDINADO = vCODIGO_EMPRESA_SUBORDINADO
          AND DT_INICIO_SUPERVISAO           = :OLD.DT_INI_VIGENCIA
          AND DT_FIM_SUPERVISAO              = :OLD.DT_FIM_VIGENCIA;
        END IF; --FIM IF INTERNO
        --2_4.3**********************---------------------------- apenas ATUALIZOU COORD ESTAGIO e COORDENADOR  ANTIGO = E NOVO <>  DIFERENTE DO GESTOR FORMAL DO LOCAL
        IF (vCOD_PESSOA_RESP = vOLD_COORD_ESTAGIO) AND (vCOD_PESSOA_RESP <> vNEW_COORD_ESTAGIO) THEN -------------------------COORDENADOR ESTAGIO ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° <> RESPONSAVEL DO LOCAL
          /*
          INSERT INTO SUGESP_RHPESS_INFOESTAGIO_LOG (TIPO_DML,CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,DT_INI_VIGENCIA,NEW_DT_FIM_VIGENCIA,OLD_DT_FIM_VIGENCIA,NEW_COORD_ESTAGIO,OLD_COORD_ESTAGIO,CODIGO_EMPRESA_RESP,TIPO_CONT_RESP,CONTRATO_RESP, TEXTO_TESTE_TRIGGER,  LOGIN_NEW, LOGIN_OLD, DT_ULT_ALTER_USUA)
          VALUES(v_DML,:OLD.CODIGO_EMPRESA,:OLD.TIPO_CONTRATO,:OLD.CODIGO_CONTRATO,:OLD.DT_INI_VIGENCIA,:NEW.DT_FIM_VIGENCIA,:OLD.DT_FIM_VIGENCIA,:NEW.COORD_ESTAGIO,:OLD.COORD_ESTAGIO,vCODIGO_EMPRESA_RESP,vTIPO_CONTRATO_RESP, vCONTRATO_RESP
          ,'2_4.3_INSERTS (new) NAS TABELAS RHUSER_PESSOA_RESPOSAVEL e RHPESS_RESP_SUPERVISAO', vLOGIN_NEW, vLOGIN_OLD, sysdate );
          */
          --NEW
          --tabela RHUSER_PESSOA_RESPONSAVEL
          INSERT
          INTO RHUSER_PESSOA_RESPONSAVEL
            (
              ID,
              ID_PROCESSO,
              ID_TAREFA,
              CODIGO_EMPRESA,
              CODIGO_USUARIO,
              CODIGO_EMPRESA_PESSOA_RESP,
              CODIGO_PESSOA_RESP,
              CODIGO_CONTRATO_RESP,
              TIPO_CONTRATO_RESP,
              CODIGO_EMPRESA_CONTRATO,
              DT_INICIO_RESPONSABILIDADE,
              DT_FIM_RESPONSABILIDADE,
              CREATED,
              CREATEDBY,
              UPDATED,
              UPDATEDBY,
              NOME_COMPOSTO,
              MOTIVO_DELEGACAO,
              ID_DELEGACAO_SUBSTITUICAO
            )
            VALUES
            (
              (SELECT MAX(ID)+1 FROM RHUSER_PESSOA_RESPONSAVEL
              )
              ,
              2,
              NULL,
              :NEW.CODIGO_EMPRESA,
              vCODIGO_USUARIO,
              vCODIGO_EMPRESA_COORD_NEW,
              vNEW_COORD_ESTAGIO,
              vCONTRATO_COORD_NEW,
              vTIPO_CONTRATO_COORD_NEW,
              vCODIGO_EMPRESA_COORD_NEW,
              TRUNC(:NEW.DT_INI_VIGENCIA),
              TRUNC(:NEW.DT_FIM_VIGENCIA),
              SYSDATE,
              :NEW.LOGIN_USUARIO,
              SYSDATE,
              :NEW.LOGIN_USUARIO,
              vNOME_COMPOSTO_COORD_NEW,
              'D',
              NULL
            );
          --NEW
          --TABELA RHUSER_PESSOA_RESP_SUPERVISAO
          INSERT
          INTO RHUSER_PESSOA_RESP_SUPERVISAO
            (
              ID,
              ID_RHUSER_PESSOA_RESPONSAVEL,
              CODIGO_EMPRESA_SUBORDINADO,
              CODIGO_CONTRATO_SUBORDINADO,
              CODIGO_PESSOA_SUBORDINADO,
              TIPO_CONTRATO_SUBORDINADO,
              CODIGO_EMPRESA_CTR_SUBORDINADO,
              CODIGO_EMPRESA,
              CREATED,
              CREATEDBY,
              UPDATED,
              UPDATEDBY,
              DT_INICIO_SUPERVISAO,
              DT_FIM_SUPERVISAO,
              NOME_COMPOSTO
            )
            VALUES
            (
              (SELECT MAX(ID)+1 FROM RHUSER_PESSOA_RESP_SUPERVISAO
              )
              ,
              (SELECT MAX(ID) FROM RHUSER_PESSOA_RESPONSAVEL
              ),
              vCODIGO_EMPRESA_SUBORDINADO,
              vCODIGO_CONTRATO_SUBORDINADO,
              vCODIGO_PESSOA_SUBORDINADO,
              vTIPO_CONTRATO_SUBORDINADO,
              vCODIGO_EMPRESA_SUBORDINADO,
              vCODIGO_EMPRESA_SUBORDINADO,
              SYSDATE,
              :NEW.LOGIN_USUARIO,
              SYSDATE,
              :NEW.LOGIN_USUARIO,
              TRUNC(:NEW.DT_INI_VIGENCIA),
              TRUNC(:NEW.DT_FIM_VIGENCIA),
              vNOME_COMPOSTO_ESTAGIARIO
            );
        END IF; --FIM IF INTERNO
        ---TIREI DAQUI EM 25/6/19 AS 17H05
        --------------------------------FUGA
        /*else
        INSERT INTO SUGESP_RHPESS_INFOESTAGIO_LOG (TIPO_DML,CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,DT_INI_VIGENCIA,NEW_DT_FIM_VIGENCIA,OLD_DT_FIM_VIGENCIA,NEW_COORD_ESTAGIO,OLD_COORD_ESTAGIO,CODIGO_EMPRESA_RESP,TIPO_CONT_RESP,CONTRATO_RESP,TEXTO_TESTE_TRIGGER, LOGIN_NEW, LOGIN_OLD, DT_ULT_ALTER_USUA)
        VALUES(v_DML,:OLD.CODIGO_EMPRESA,:OLD.TIPO_CONTRATO,:OLD.CODIGO_CONTRATO,:OLD.DT_INI_VIGENCIA,:NEW.DT_FIM_VIGENCIA,:OLD.DT_FIM_VIGENCIA,:NEW.COORD_ESTAGIO,:OLD.COORD_ESTAGIO,vCODIGO_EMPRESA_RESP,vTIPO_CONTRATO_RESP, vCONTRATO_RESP
        ,'9_ERRO', vLOGIN_NEW, vLOGIN_OLD, sysdate );
        */
      END IF;---------------------------------FIM if interno

      --------------------------------------------------------------------------------DELETE------------------------------------------------------------------------------------------------------------------------------------
    ELSIF DELETING AND (vOLD_DT_FIM_VIGENCIA IS NOT NULL AND vOLD_COORD_ESTAGIO IS NOT NULL) THEN
      --AND (vCOD_PESSOA_RESP <> vOLD_COORD_ESTAGIO)
      v_DML := 'D';
      -- INICIO --POPULAR TABELAS
      --INICIO--buscar dados do ESTAGIARIO e O RESPONSAVEL DO CUSTO GERENCIAL DO ESTAGIARIO E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO
      SELECT C.CODIGO_EMPRESA,
        C.TIPO_CONTRATO,
        C.CODIGO,
        C.CODIGO_PESSOA,
        C.COD_CUSTO_GERENC1,
        C.COD_CUSTO_GERENC2,
        G.CODIGO_EMPRESA,
        G.TIPO_CONT_RESP,
        G.CONTRATO_RESP,
        G.COD_PESSOA_RESP,
        U.CODIGO_USUARIO ,
        C.CODIGO
        ||' - '
        ||NVL(TRIM(P.NOME_SOCIAL),TRIM(P.NOME_ACESSO))
        ||' - '
        ||C.TIPO_CONTRATO
        ||' - '
        || NVL(TRIM(G.TEXTO_ASSOCIADO),TRIM(G.DESCRICAO)) NOME_COMPOSTO_ESTAGIARIO
      INTO vCODIGO_EMPRESA_SUBORDINADO,
        vTIPO_CONTRATO_SUBORDINADO,
        vCODIGO_CONTRATO_SUBORDINADO,
        vCODIGO_PESSOA_SUBORDINADO,
        vCOD_CUSTO_GERENC1_SUBORDINAD,
        vCOD_CUSTO_GERENC2_SUBORDINAD,
        vCODIGO_EMPRESA_RESP,
        vTIPO_CONTRATO_RESP,
        vCONTRATO_RESP,
        vCOD_PESSOA_RESP,
        vCODIGO_USUARIO,
        vNOME_COMPOSTO_ESTAGIARIO
      FROM RHPESS_CONTRATO C
      LEFT OUTER JOIN RHORGA_CUSTO_GEREN G
      ON C.CODIGO_EMPRESA     = G.CODIGO_EMPRESA
      AND C.COD_CUSTO_GERENC1 = G.COD_CGERENC1
      AND C.COD_CUSTO_GERENC2 = G.COD_CGERENC2
      AND C.COD_CUSTO_GERENC3 = G.COD_CGERENC3
      AND C.COD_CUSTO_GERENC4 = G.COD_CGERENC4
      AND C.COD_CUSTO_GERENC5 = G.COD_CGERENC5
      AND C.COD_CUSTO_GERENC6 = G.COD_CGERENC6
      LEFT OUTER JOIN RHUSER_P_SIST U
      ON G.CODIGO_EMPRESA  = U.EMPRESA_USUARIO
      AND G.TIPO_CONT_RESP = U.TP_CONTR_USUARIO
      AND g.contrato_resp  = u.contrato_usuario
      LEFT OUTER JOIN RHPESS_PESSOA P
      ON P.CODIGO_EMPRESA = C.CODIGO_EMPRESA
      AND P.CODIGO        = C.CODIGO_PESSOA
      WHERE u.usuario_ldap         = u.codigo_usuario
      AND U.tipo_login ='1'
      AND U.STATUS_USUARIO NOT IN ('E')
      AND   C.CODIGO_EMPRESA     = :OLD.codigo_empresa
      AND C.TIPO_CONTRATO      = :OLD.tipo_contrato
      AND C.CODIGO             = :OLD.codigo_contrato
      AND C.ANO_MES_REFERENCIA =
        (SELECT MAX(AUX.ano_mes_referencia)
        FROM rhpess_contrato AUX
        WHERE AUX.codigo_empresa = c.codigo_empresa
        AND AUX.tipo_contrato    = c.tipo_contrato
        AND AUX.codigo           = c.codigo

        );
      --FIM--buscar dados do ESTAGIARIO e O RESPONSAVEL DO CUSTO GERENCIAL DO ESTAGIARIO E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO
      --INICIO--BUSCAR O CONTRATO DO ***NOVO*** COORD_ESTAGIO da tela E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO
        /*  GABRIEL AQUI EM 15/07/2020 POIS DELETE NAO TEM VALOR :NEW GERANDO ERRO NA HORA DE EXCUTAR A EXCLUSÃƒO
      SELECT C.CODIGO_EMPRESA,
        C.TIPO_CONTRATO,
        C.CODIGO,
        C.CODIGO_PESSOA ,
        C.COD_CUSTO_GERENC1 ,
        C.COD_CUSTO_GERENC2 ,
        C.CODIGO
        ||' - '
        || NVL(TRIM(P.NOME_SOCIAL),TRIM(P.NOME_ACESSO))
        ||' - '
        || C.TIPO_CONTRATO
        ||' - '
        || NVL(TRIM(G.TEXTO_ASSOCIADO),TRIM(G.DESCRICAO)) NOME_COMPOSTO_COORDENADOR
      INTO vCODIGO_EMPRESA_COORD_NEW,
        vTIPO_CONTRATO_COORD_NEW ,
        vCONTRATO_COORD_NEW ,
        vNEW_COORD_ESTAGIO,
        vCOD_CUSTO_GERENC1_COORD_NEW ,
        vCOD_CUSTO_GERENC2_COORD_NEW ,
        vNOME_COMPOSTO_COORD_NEW
      FROM RHPESS_CONTRATO C
      LEFT OUTER JOIN RHPARM_SIT_FUNC S
      ON C.SITUACAO_FUNCIONAL = S.CODIGO
      LEFT OUTER JOIN RHPESS_PESSOA P
      ON P.CODIGO_EMPRESA = C.CODIGO_EMPRESA
      AND P.CODIGO        = C.CODIGO_PESSOA
      LEFT OUTER JOIN RHORGA_CUSTO_GEREN G
      ON C.CODIGO_EMPRESA       = G.CODIGO_EMPRESA
      AND C.COD_CUSTO_GERENC1   = G.COD_CGERENC1
      AND C.COD_CUSTO_GERENC2   = G.COD_CGERENC2
      AND C.COD_CUSTO_GERENC3   = G.COD_CGERENC3
      AND C.COD_CUSTO_GERENC4   = G.COD_CGERENC4
      AND C.COD_CUSTO_GERENC5   = G.COD_CGERENC5
      AND C.COD_CUSTO_GERENC6   = G.COD_CGERENC6
      WHERE C.CODIGO_EMPRESA    = :NEW.CODIGO_EMPRESA
      AND C.TIPO_CONTRATO       = :NEW.TIPO_CONTRATO
      AND C.CODIGO       = :NEW.codigo_contrato_coord
      AND S.CONTROLE_FOLHA      = 'N'
      AND C.DATA_RESCISAO      IS NULL
      AND C.SITUACAO_FUNCIONAL <> '1017'
      AND C.ANO_MES_REFERENCIA  =
        (SELECT MAX(AUX.ano_mes_referencia)
        FROM rhpess_contrato AUX
        WHERE AUX.codigo_empresa = c.codigo_empresa
        AND AUX.tipo_contrato    = c.tipo_contrato
        AND AUX.codigo           = c.codigo
        );*/
      --FIM--BUSCAR O CONTRATO DO COORD_ESTAGIO da tela E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO
      --INICIO--BUSCAR O CONTRATO DO ***VELHO*** COORD_ESTAGIO da tela E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO
      SELECT C.CODIGO_EMPRESA,
        C.TIPO_CONTRATO,
        C.CODIGO,
        C.CODIGO_PESSOA ,
        C.COD_CUSTO_GERENC1 ,
        C.COD_CUSTO_GERENC2,
        C.CODIGO
        ||' - '
        || NVL(TRIM(P.NOME_SOCIAL),TRIM(P.NOME_ACESSO))
        ||' - '
        || C.TIPO_CONTRATO
        ||' - '
        || NVL(TRIM(G.TEXTO_ASSOCIADO),TRIM(G.DESCRICAO)) NOME_COMPOSTO_COORDENADOR
      INTO vCODIGO_EMPRESA_COORD_OLD,
        vTIPO_CONTRATO_COORD_OLD ,
        vCONTRATO_COORD_OLD,
        vOLD_COORD_ESTAGIO,
        vCOD_CUSTO_GERENC1_COORD_OLD ,
        vCOD_CUSTO_GERENC2_COORD_OLD ,
        vNOME_COMPOSTO_COORD_OLD
      FROM RHPESS_CONTRATO C
      LEFT OUTER JOIN RHPARM_SIT_FUNC S
      ON C.SITUACAO_FUNCIONAL = S.CODIGO
      LEFT OUTER JOIN RHPESS_PESSOA P
      ON P.CODIGO_EMPRESA = C.CODIGO_EMPRESA
      AND P.CODIGO        = C.CODIGO_PESSOA
      LEFT OUTER JOIN RHORGA_CUSTO_GEREN G
      ON C.CODIGO_EMPRESA       = G.CODIGO_EMPRESA
      AND C.COD_CUSTO_GERENC1   = G.COD_CGERENC1
      AND C.COD_CUSTO_GERENC2   = G.COD_CGERENC2
      AND C.COD_CUSTO_GERENC3   = G.COD_CGERENC3
      AND C.COD_CUSTO_GERENC4   = G.COD_CGERENC4
      AND C.COD_CUSTO_GERENC5   = G.COD_CGERENC5
      AND C.COD_CUSTO_GERENC6   = G.COD_CGERENC6
      WHERE C.CODIGO_EMPRESA    = :OLD.CODIGO_EMPRESA_COORD
      AND C.TIPO_CONTRATO       = :OLD.TIPO_CONTRATO_COORD
      AND C.CODIGO       = :OLD.codigo_contrato_coord
      AND S.CONTROLE_FOLHA NOT IN ('D','S')
      AND C.DATA_RESCISAO      IS NULL
      AND C.SITUACAO_FUNCIONAL <> '1017'
      AND C.ANO_MES_REFERENCIA  =
        (SELECT MAX(AUX.ano_mes_referencia)
        FROM rhpess_contrato AUX
        WHERE AUX.codigo_empresa = c.codigo_empresa
        AND AUX.tipo_contrato    = c.tipo_contrato
        AND AUX.codigo           = c.codigo
        );
      --FIM--BUSCAR O CONTRATO DO COORD_ESTAGIO da tela E CONFERIR SE ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€?Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â° O MESMO DO COORDENADOR ESTAGIO SENDO DEFINIDO
      --FIM --POPULAR VARIAVEIS
      --INICIO IF INTERNO
      IF (vCOD_PESSOA_RESP <> vOLD_COORD_ESTAGIO) THEN
        /*
        INSERT INTO SUGESP_RHPESS_INFOESTAGIO_LOG (TIPO_DML,CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,DT_INI_VIGENCIA,NEW_DT_FIM_VIGENCIA,OLD_DT_FIM_VIGENCIA,NEW_COORD_ESTAGIO,OLD_COORD_ESTAGIO,CODIGO_EMPRESA_RESP,TIPO_CONT_RESP,CONTRATO_RESP, TEXTO_TESTE_TRIGGER, LOGIN_NEW, LOGIN_OLD, DT_ULT_ALTER_USUA)
        VALUES(v_DML,:OLD.CODIGO_EMPRESA,:OLD.TIPO_CONTRATO,:OLD.CODIGO_CONTRATO,:OLD.DT_INI_VIGENCIA,:NEW.DT_FIM_VIGENCIA,:OLD.DT_FIM_VIGENCIA,:NEW.COORD_ESTAGIO,:OLD.COORD_ESTAGIO,vCODIGO_EMPRESA_RESP,vTIPO_CONTRATO_RESP, vCONTRATO_RESP
        ,'3_DELETE REGISTRO UPDATE DATA FIM com sysdate NO REGISTRO EXISTENTE (old) NAS TABELAS RHUSER_PESSOA_RESPOSAVEL e RHPESS_RESP_SUPERVISAO', vLOGIN_NEW, vLOGIN_OLD, sysdate );
        */
        --OLD
        --tabela RHUSER_PESSOA_RESPONSAVEL
        DELETE RHUSER_PESSOA_RESPONSAVEL
        WHERE motivo_delegacao                = 'D'
        AND ID_PROCESSO                       = 2
        AND CODIGO_EMPRESA                    = :OLD.CODIGO_EMPRESA
        AND CODIGO_EMPRESA_PESSOA_RESP        = vCODIGO_EMPRESA_COORD_OLD
        AND CODIGO_PESSOA_RESP                = vOLD_COORD_ESTAGIO
        AND CODIGO_CONTRATO_RESP              = vCONTRATO_COORD_OLD
        AND TIPO_CONTRATO_RESP                = vTIPO_CONTRATO_COORD_OLD
        AND CODIGO_EMPRESA_CONTRATO           = vCODIGO_EMPRESA_COORD_OLD
        AND TRUNC(DT_INICIO_RESPONSABILIDADE) = TRUNC(:OLD.DT_INI_VIGENCIA)
        AND TRUNC(DT_FIM_RESPONSABILIDADE)    = TRUNC(:OLD.DT_FIM_VIGENCIA);
        --OLD
        --TABELA RHUSER_PESSOA_RESP_SUPERVISAO
        DELETE RHUSER_PESSOA_RESP_SUPERVISAO
        WHERE CODIGO_EMPRESA_SUBORDINADO   = vCODIGO_EMPRESA_SUBORDINADO
        AND CODIGO_CONTRATO_SUBORDINADO    = vCODIGO_CONTRATO_SUBORDINADO
        AND CODIGO_PESSOA_SUBORDINADO      = vCODIGO_PESSOA_SUBORDINADO
        AND TIPO_CONTRATO_SUBORDINADO      = vTIPO_CONTRATO_SUBORDINADO
        AND CODIGO_EMPRESA_CTR_SUBORDINADO = vCODIGO_EMPRESA_SUBORDINADO
        AND TRUNC(DT_INICIO_SUPERVISAO)    = TRUNC(:OLD.DT_INI_VIGENCIA)
        AND TRUNC(DT_FIM_SUPERVISAO)       = TRUNC(:OLD.DT_FIM_VIGENCIA);
      END IF; --FIM IF INTERNO
      --*/
    END IF; --FIM --IF GERAL DO INSERT, DELETE, E TIPOS DE UPDATE
  
  
    END IF;
  END;

ALTER TRIGGER "ARTERH"."TR_RHPESS_INFO_ESTAGIO" ENABLE