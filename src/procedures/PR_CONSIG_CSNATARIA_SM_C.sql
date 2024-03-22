
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_CONSIG_CSNATARIA_SM_C" (p_ano_mes_referencia IN date
                                                    , p_usuario IN VARCHAR2)
IS
  error VARCHAR2(255);
  v_temp1 INTEGER;
  v_tipo_erro CHAR(4);
  v_data_autoriza DATE;
BEGIN

  DECLARE CURSOR CONTRATOS IS
    SELECT *
    FROM  RHPBH_CONSIG_IMPO
    WHERE UPPER(ORIGEM_IMPORTACAO) = 'CONSIGNATARIA'
    AND  dt_exec_importacao IS NULL
    AND  ANO_MES_REFERENCIA = p_ano_mes_referencia
    AND  UPPER(operacao_importacao) = 'E'
    ORDER BY DATA_AUTORIZA
    ;
  BEGIN
    FOR CONTRATO IN CONTRATOS
    LOOP

      BEGIN
        v_tipo_erro := NULL;
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
          /*Existe, agora verifica se é cancelado*/
          SELECT data_autoriza
          INTO v_data_autoriza
          FROM RHMOVI_SOL_MOVI
          WHERE CODIGO_CONTRATO = CONTRATO.CODIGO_CONTRATO
          AND CODIGO_EMPRESA = CONTRATO.CODIGO_EMPRESA
          AND CODIGO_VERBA = CONTRATO.CODIGO_VERBA
          AND TIPO_CONTRATO = '0001'
          AND TIPO_MOVIMENTO = 'CS';

          IF v_data_autoriza IS NULL THEN /*CANCELADO*/
            v_tipo_erro := '0007';

          ELSE /*Nao cancelado CANCELAR!!!*/

            UPDATE RHMOVI_SOL_MOVI
            SET C_LIVRE_OPCAO01 = 'S',
                DATA_AUTORIZA = NULL,
                c_livre_data01 = p_ano_mes_referencia,
                LOGIN_USUARIO = p_usuario,
                dt_ult_alter_usua = SYSDATE
            WHERE CODIGO_CONTRATO = CONTRATO.CODIGO_CONTRATO
            AND CODIGO_EMPRESA = CONTRATO.CODIGO_EMPRESA
            AND CODIGO_VERBA = CONTRATO.CODIGO_VERBA
            AND TIPO_CONTRATO = '0001'
            AND TIPO_MOVIMENTO = 'CS'
            AND TIPO_CONTRATO = '0001'
            AND MODO_OPERACAO = 'R';

          END IF;

        ELSE
          /*IF NOT EXISTS*/
          v_tipo_erro := '0006';

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

END; /*PR_CONSIG_CSNATARIA_SM_C*/
 