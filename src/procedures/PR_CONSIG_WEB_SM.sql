
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_CONSIG_WEB_SM" (p_ano_mes_referencia IN date
       , p_data_corte IN date
       , p_usuario IN VARCHAR2
       , p_codigo_fornecedor IN VARCHAR2
       )
IS
 error VARCHAR2(255);
 v_temp1 INTEGER;
 v_data_autoriza DATE;
 v_data_solicitacao DATE;
 v_fim_vigencia DATE;
 v_ini_vigencia DATE;
 v_data2 DATE;
 v_tipo_erro CHAR(4); /*TIPO DE ERRO DESCRITO NA TABELARHPBH_CONSIG_ERRO*/
BEGIN
 /*Preparando tabela*/
/* [3]
 update rhpbh_consig_impo a
 set a.dt_exec_importacao = sysdate
 where (a.origem_importacao, a.codigo_empresa, a.codigo_contrato,a.codigo_Verba)
  IN (SELECT origem_importacao, codigo_empresa, codigo_contrato,codigo_Verba
    from rhpbh_consig_impo
    where operacao_importacao IN ('I', 'A')
    and origem_importacao = 'CONSIGWEB'
    and ano_mes_referencia = p_ano_mes_referencia
    and dt_exec_importacao is null
    and data_autoriza >= a.data_autoriza)
 and a.origem_importacao = 'CONSIGWEB'
 and a.ano_mes_referencia = p_ano_mes_referencia
 and a.dt_exec_importacao is null
 and a.operacao_importacao = 'E';

 commit work;
*/

 DECLARE CURSOR CONTRATOS IS
  SELECT i.*
  FROM RHPBH_CONSIG_IMPO i
  ,   RHORGA_FORN_VERBA fv
  WHERE i.ORIGEM_IMPORTACAO = 'CONSIGWEB'
  AND  i.dt_exec_importacao IS NULL
  AND  i.ANO_MES_REFERENCIA = p_ano_mes_referencia
  AND  fv.codigo_Verba = i.codigo_verba
  AND  (p_codigo_fornecedor is null or fv.codigo_fornecedor =p_codigo_fornecedor)
  ORDER BY i.DATA_AUTORIZA
  ;

 BEGIN
  FOR CONTRATO IN CONTRATOS
  LOOP

   BEGIN
    v_tipo_erro := NULL;

    IF CONTRATO.OPERACAO_IMPORTACAO = 'E' THEN /*cancelamento ?imediato*/

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

    ELSE /*inclusao e alteracao*/
     v_temp1 := 0;
     SELECT COUNT(*) INTO v_temp1 /*Verificar se existe*/
     FROM DUAL
     WHERE EXISTS (
      SELECT 1
      FROM RHMOVI_SOL_MOVI
      WHERE CODIGO_CONTRATO = CONTRATO.CODIGO_CONTRATO
      AND CODIGO_EMPRESA = CONTRATO.CODIGO_EMPRESA
      AND CODIGO_VERBA = CONTRATO.CODIGO_VERBA
      AND TIPO_CONTRATO = '0001'
      AND TIPO_MOVIMENTO = 'CS');

     /*Inicio do Calculo data ini e fim vigencia*/
     IF contrato.data_autoriza<p_data_corte THEN /*Entrar no mesatual*/
      v_ini_vigencia := p_ano_mes_referencia;

      SELECT DECODE (CONTRATO.CONTADOR, /*Data_fim_vigencia,calcula*/
        0, DECODE(TIPO_DA_VERBA, 'F', TO_DATE(NULL),add_months(p_ano_mes_referencia, CONTRATO.CONTADOR-1)) ,
        1, DECODE(TIPO_DA_VERBA, 'F', TO_DATE(NULL),add_months(p_ano_mes_referencia, CONTRATO.CONTADOR-1)) ,
        add_months(p_ano_mes_referencia, CONTRATO.CONTADOR-1))
      INTO v_fim_vigencia
      FROM RHPARM_VERBA
      WHERE codigo = CONTRATO.CODIGO_VERBA;

     ELSE
      SELECT ADD_MONTHS(p_ano_mes_referencia, 1)
      INTO v_ini_vigencia
      FROM DUAL;

      SELECT DECODE (CONTRATO.CONTADOR, /*Data_fim_vigencia,calcula*/
        0, DECODE(TIPO_DA_VERBA, 'F', TO_DATE(NULL),add_months(p_ano_mes_referencia, CONTRATO.CONTADOR)) ,
        1, DECODE(TIPO_DA_VERBA, 'F', TO_DATE(NULL),add_months(p_ano_mes_referencia, CONTRATO.CONTADOR)) ,
        add_months(p_ano_mes_referencia, CONTRATO.CONTADOR))
      INTO v_fim_vigencia
      FROM RHPARM_VERBA
      WHERE codigo = CONTRATO.CODIGO_VERBA;

     END IF;

     /*Fim do Calculo data ini e fim vigencia*/

     SELECT C_LIVRE_DATA01 INTO v_data2 /*Data de prioridade daconsignataria*/
     FROM RHORGA_FORN_VERBA
     WHERE codigo_verba = CONTRATO.CODIGO_VERBA;

     IF v_temp1>0 THEN /*EXISTE*/

      /*Existe, agora verifica se ? cancelado*/
/* [3]
      SELECT data_autoriza, data_solicitacao
      INTO v_data_autoriza, v_data_solicitacao
      FROM RHMOVI_SOL_MOVI
      WHERE CODIGO_CONTRATO = CONTRATO.CODIGO_CONTRATO
      AND CODIGO_EMPRESA = CONTRATO.CODIGO_EMPRESA
      AND CODIGO_VERBA = CONTRATO.CODIGO_VERBA
      AND TIPO_CONTRATO = '0001'
      AND TIPO_MOVIMENTO = 'CS';

      IF v_data_autoriza IS NOT NULL THEN
*/
       UPDATE RHMOVI_SOL_MOVI
       SET  CODIGO_EMPRESA = CONTRATO.CODIGO_EMPRESA,
       TIPO_CONTRATO = '0001',
       MODO_OPERACAO = 'R',
       TIPO_MOVIMENTO = 'CS',
       CODIGO_CONTRATO = CONTRATO.CODIGO_CONTRATO,
       CODIGO_VERBA = CONTRATO.CODIGO_VERBA,
       MES_INCIDENCIA = to_CHAR(p_ano_mes_referencia, 'MM'),
       CTRL_DEMO = 'N',
       CTRL_LANCAMENTO = 0,
       REF_VERBA = CONTRATO.REFERENCIA_VERBA,
       VALOR_VERBA = CONTRATO.VALOR_VERBA,
       CONTADOR = CONTRATO.CONTADOR,
       OCORRENCIA = 1,
       C_LIVRE_DESCR01 = SUBSTR(CONTRATO.LINHA_ARQUIVO, 71, 14),
       DATA_SOLICITACAO = CONTRATO.DATA_AUTORIZA,
       DATA_INI_VIGENCIA = v_ini_vigencia,
       DATA_FIM_VIGENCIA = v_fim_vigencia,
       DATA_AUTORIZA = to_date('01/'|| to_CHAR(p_ano_mes_referencia,'MM')||'/'|| to_char(p_ano_mes_referencia,'YYYY'),'dd/mm/yyyyHH24:MI:SS'),FASE = '0',CTRL_PROP_REF = 'N',
       PROJ_CONTADOR = DECODE(CONTRATO.CONTADOR, 0, 'N', 1, 'N','S'),
       CONTROLE_GERACAO = 'I',
       DESTINO_GERACAO = 'M',
       C_LIVRE_OPCAO01 = 'N',
       C_LIVRE_OPCAO02 = 'N',
       LOGIN_USUARIO = p_usuario,
       DT_ULT_ALTER_USUA = SYSDATE,
       C_LIVRE_DATA02 = v_data2,
       C_Livre_Descr02 = SUBSTR(CONTRATO.LINHA_ARQUIVO, 88, 20)
       WHERE CODIGO_CONTRATO = CONTRATO.CODIGO_CONTRATO
       AND CODIGO_EMPRESA = CONTRATO.CODIGO_EMPRESA
       AND CODIGO_VERBA = CONTRATO.CODIGO_VERBA
       AND TIPO_CONTRATO = '0001'
       AND TIPO_MOVIMENTO = 'CS'
       AND TIPO_CONTRATO = '0001'
       AND MODO_OPERACAO = 'R';
/* [3]
      ELSE
       v_tipo_erro := '0004';

      END IF;
*/
     ELSE /*Nao Esiste*/

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
      C_Livre_Descr02)
      VALUES(
      CONTRATO.CODIGO_EMPRESA,
      '0001',
      'R',
      'CS',
      CONTRATO.CODIGO_CONTRATO,
      CONTRATO.CODIGO_VERBA,
      to_CHAR(p_ano_mes_referencia, 'MM'), /*mes ocorrencia nao vemno arquivo.*/'N', /*nao vem no arquivo (FIXO N)*/0, /*nao vem no arquivo, fixo 0??*/
      CONTRATO.REFERENCIA_VERBA,
      CONTRATO.VALOR_VERBA,
      CONTRATO.CONTADOR,
      1,
      SUBSTR(CONTRATO.LINHA_ARQUIVO, 71, 14),
      CONTRATO.DATA_AUTORIZA,
      v_ini_vigencia,
      v_fim_vigencia,
      to_date('01/'|| to_CHAR(p_ano_mes_referencia, 'MM')||'/'||to_char(p_ano_mes_referencia, 'YYYY') , 'dd/mm/yyyy HH24:MI:SS'),
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
      SUBSTR(CONTRATO.LINHA_ARQUIVO, 88, 20));

     END IF;

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

END; /*PR_CONSIG_WEB_SM*/
 