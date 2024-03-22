
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_CONSIG_CSNATARIA_SM" (p_ano_mes_referencia IN date
                                                  , p_usuario IN VARCHAR2)
IS
  error VARCHAR2(255);
  v_temp1 INTEGER;
  v_data_autoriza DATE;
  v_data_solicitacao DATE;
  v_data1 DATE;
  v_data2 DATE;
  v_tipo_erro CHAR(4);
BEGIN

  DECLARE CURSOR CONTRATOS IS
    SELECT *
    FROM  RHPBH_CONSIG_IMPO
    WHERE UPPER(ORIGEM_IMPORTACAO) = 'CONSIGNATARIA'
    AND  dt_exec_importacao IS NULL
    AND  ANO_MES_REFERENCIA = p_ano_mes_referencia
    AND  UPPER(operacao_importacao) = 'I'
    ORDER BY DATA_AUTORIZA
    ;
  BEGIN
    FOR CONTRATO IN CONTRATOS
    LOOP

      BEGIN

        v_tipo_erro := NULL;

        SELECT  DECODE (CONTRATO.CONTADOR,
            0, DECODE(TIPO_DA_VERBA, 'F', TO_DATE(NULL), add_months(to_date('01/' || SUBSTR(CONTRATO.LINHA_ARQUIVO, 12, 2) || '/' || to_char(p_ano_mes_referencia, 'YYYY') , 'dd/mm/yyyy HH24:MI:SS'), CONTRATO.CONTADOR-1)) ,
            1, DECODE(TIPO_DA_VERBA, 'F', TO_DATE(NULL), add_months(to_date('01/' || SUBSTR(CONTRATO.LINHA_ARQUIVO, 12, 2) || '/' || to_char(p_ano_mes_referencia, 'YYYY') , 'dd/mm/yyyy HH24:MI:SS'), CONTRATO.CONTADOR-1)) ,
            add_months(to_date('01/' || SUBSTR(CONTRATO.LINHA_ARQUIVO, 12, 2) || '/' || to_char(p_ano_mes_referencia, 'YYYY') , 'dd/mm/yyyy HH24:MI:SS'), CONTRATO.CONTADOR-1))
        INTO v_data1
        FROM RHPARM_VERBA
        WHERE codigo = CONTRATO.CODIGO_VERBA;

        SELECT C_LIVRE_DATA01 INTO v_data2
        FROM RHORGA_FORN_VERBA
        WHERE codigo_verba = CONTRATO.CODIGO_VERBA;

        v_temp1 := 0;


        SELECT COUNT(*) INTO v_temp1
        FROM DUAL
        WHERE EXISTS (
          SELECT 1
          FROM RHMOVI_SOL_MOVI
          WHERE CODIGO_CONTRATO = CONTRATO.CODIGO_CONTRATO
          AND CODIGO_EMPRESA = CONTRATO.CODIGO_EMPRESA
          AND CODIGO_VERBA = CONTRATO.CODIGO_VERBA
          AND TIPO_CONTRATO = '0001'
          AND TIPO_MOVIMENTO = 'CS');

        IF v_temp1 > 0 THEN

          /*Existe, agora verifica se ? cancelado*/
          SELECT data_autoriza, data_solicitacao
          INTO v_data_autoriza, v_data_solicitacao
          FROM RHMOVI_SOL_MOVI
          WHERE CODIGO_CONTRATO = CONTRATO.CODIGO_CONTRATO
          AND CODIGO_EMPRESA = CONTRATO.CODIGO_EMPRESA
          AND CODIGO_VERBA = CONTRATO.CODIGO_VERBA
          AND TIPO_CONTRATO = '0001'
          AND TIPO_MOVIMENTO = 'CS';

          IF v_data_autoriza IS NULL THEN /*CANCELADO*/
            v_tipo_erro := '0004';

          ELSE /*Nao cancelado ATUALIZAR*/

            IF CONTRATO.data_autoriza >= v_data_solicitacao THEN /*ATUALIZA*/
              /*ATUALIZA*/

              UPDATE RHMOVI_SOL_MOVI
              SET    CODIGO_EMPRESA = CONTRATO.CODIGO_EMPRESA,
              TIPO_CONTRATO = '0001',
              MODO_OPERACAO = 'R',
              TIPO_MOVIMENTO  = 'CS',
              CODIGO_CONTRATO = CONTRATO.CODIGO_CONTRATO,
              CODIGO_VERBA = CONTRATO.CODIGO_VERBA,
              MES_INCIDENCIA = SUBSTR(CONTRATO.LINHA_ARQUIVO, 12, 2),
              CTRL_DEMO = SUBSTR(CONTRATO.LINHA_ARQUIVO, 23, 1),
              CTRL_LANCAMENTO = SUBSTR(CONTRATO.LINHA_ARQUIVO, 56, 1),
              REF_VERBA = CONTRATO.REFERENCIA_VERBA,
              VALOR_VERBA = CONTRATO.VALOR_VERBA,
              CONTADOR = CONTRATO.CONTADOR,
              OCORRENCIA = 1,
              C_LIVRE_DESCR01 = SUBSTR(CONTRATO.LINHA_ARQUIVO, 57, 14),
              DATA_SOLICITACAO = CONTRATO.DATA_AUTORIZA,
              DATA_INI_VIGENCIA = to_date('01/' || SUBSTR(CONTRATO.LINHA_ARQUIVO, 12, 2) || '/' || to_char(p_ano_mes_referencia, 'YYYY') , 'dd/mm/yyyy HH24:MI:SS'),
              DATA_FIM_VIGENCIA = v_data1,
              DATA_AUTORIZA = to_date('01/'|| SUBSTR(CONTRATO.LINHA_ARQUIVO,12,2)||'/'|| to_char(p_ano_mes_referencia, 'YYYY') , 'dd/mm/yyyy HH24:MI:SS'),
              FASE = '0',
              CTRL_PROP_REF = 'N',
              PROJ_CONTADOR = DECODE(CONTRATO.CONTADOR, 0, 'N', 1, 'N', 'S'),
              CONTROLE_GERACAO = 'I',
              DESTINO_GERACAO = 'M',
              C_LIVRE_OPCAO01 = 'N',
              C_LIVRE_OPCAO02 = 'N',
              LOGIN_USUARIO = p_usuario,
              DT_ULT_ALTER_USUA = SYSDATE,
              C_LIVRE_DATA02 = v_data2,
              C_Livre_Descr02 = SUBSTR(CONTRATO.LINHA_ARQUIVO, 72, 20)
              WHERE CODIGO_CONTRATO = CONTRATO.CODIGO_CONTRATO
              AND CODIGO_EMPRESA = CONTRATO.CODIGO_EMPRESA
              AND CODIGO_VERBA = CONTRATO.CODIGO_VERBA
              AND TIPO_CONTRATO = '0001'
              AND TIPO_MOVIMENTO = 'CS'
              AND TIPO_CONTRATO = '0001'
              AND MODO_OPERACAO = 'R';


            ELSE
              /*CONTRATO COM DATA MAIS ANTIGA*/
              v_tipo_erro := '0002';

            END IF;
          END IF;

        ELSE

          /*IF NOT EXISTS*/

          INSERT INTO RHMOVI_SOL_MOVI
          (CODIGO_EMPRESA,
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
          VALUES
          (CONTRATO.CODIGO_EMPRESA,
           '0001',
           'R',
           'CS',
           UPPER(CONTRATO.CODIGO_CONTRATO),
           CONTRATO.CODIGO_VERBA,
           SUBSTR(CONTRATO.LINHA_ARQUIVO, 12, 2),
           SUBSTR(CONTRATO.LINHA_ARQUIVO, 23, 1),
           SUBSTR(CONTRATO.LINHA_ARQUIVO, 56, 1),
           CONTRATO.REFERENCIA_VERBA,
           CONTRATO.VALOR_VERBA,
           CONTRATO.CONTADOR,
           1,
           SUBSTR(CONTRATO.LINHA_ARQUIVO, 57, 14),
           CONTRATO.DATA_AUTORIZA,
           to_date('01/' || SUBSTR(CONTRATO.LINHA_ARQUIVO, 12, 2) || '/' || to_char(p_ano_mes_referencia, 'YYYY') , 'dd/mm/yyyy HH24:MI:SS'),
           v_data1,
           to_date('01/'|| SUBSTR(CONTRATO.LINHA_ARQUIVO,12,2)||'/'|| to_char(p_ano_mes_referencia, 'YYYY') , 'dd/mm/yyyy HH24:MI:SS'),
           '0',
           'N',
           DECODE(CONTRATO.CONTADOR, 0, 'N', 1, 'N', 'S'),
           'I',
           'M',
           'N',
           'N',
           p_usuario,
           SYSDATE,
           v_data2,
           SUBSTR(CONTRATO.LINHA_ARQUIVO, 72, 20)
           );


        END IF;

        /*GRAVA SUCESSO OU ERRO*/

        UPDATE RHPBH_CONSIG_IMPO
        SET DT_EXEC_IMPORTACAO = DECODE(v_tipo_erro, '', SYSDATE, NULL),
            CODIGO_CONSIG_ERRO = v_tipo_erro,
            LOGIN_USUARIO = p_usuario,
            dt_ult_alter_usua = SYSDATE
        WHERE CONTRATO.ANO_MES_REFERENCIA = ANO_MES_REFERENCIA
        AND CONTRATO.CODIGO_CONTRATO = CODIGO_CONTRATO
        AND CONTRATO.CODIGO_EMPRESA = CODIGO_EMPRESA
        AND CONTRATO.CODIGO_VERBA = CODIGO_VERBA
        AND CONTRATO.DATA_AUTORIZA = DATA_AUTORIZA
        AND CONTRATO.OPERACAO_IMPORTACAO = OPERACAO_IMPORTACAO
        AND CONTRATO.ORIGEM_IMPORTACAO = ORIGEM_IMPORTACAO;

        COMMIT WORK;

      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;

          UPDATE RHPBH_CONSIG_IMPO
          SET CODIGO_CONSIG_ERRO = '0000',
              LOGIN_USUARIO = p_usuario,
              dt_ult_alter_usua = SYSDATE
          WHERE CONTRATO.ANO_MES_REFERENCIA = ANO_MES_REFERENCIA
          AND CONTRATO.CODIGO_CONTRATO = CODIGO_CONTRATO
          AND CONTRATO.CODIGO_EMPRESA = CODIGO_EMPRESA
          AND CONTRATO.CODIGO_VERBA = CODIGO_VERBA
          AND CONTRATO.DATA_AUTORIZA = DATA_AUTORIZA
          AND CONTRATO.OPERACAO_IMPORTACAO = OPERACAO_IMPORTACAO
          AND CONTRATO.ORIGEM_IMPORTACAO = ORIGEM_IMPORTACAO;
          COMMIT WORK;
      END;

    END LOOP;

  END;

END; /*PR_CONSIG_CSNATARIA_SM*/

 