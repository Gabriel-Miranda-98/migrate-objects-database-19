
  CREATE OR REPLACE EDITIONABLE TRIGGER "ARTERH"."TR_VALE_LOG" BEFORE
  INSERT OR
  UPDATE OR
  DELETE ON "ARTERH"."RHVALE_TRANSPORTE" FOR EACH ROW 
   DECLARE v_DML CHAR(1 BYTE);
  BEGIN
    IF INSERTING THEN
      v_DML := 'I';
      INSERT
      INTO RHPBH_VALE_LOG
        (
          ID,
          TIPO_DML,
          DATA_LOG,
          CODIGO_EMPRESA,
          TIPO_CONTRATO,
          CODIGO_CONTRATO,
          NEW_CODIGO_LINHA,
          NEW_CODIGO_ITINERARIO,
          NEW_TIPO_DIA,
          NEW_QTDE_VALES,
          NEW_LOGIN_USUARIO,
          DT_ULT_ALTER_USUA,
          NEW_SEQUENCIA,
          NEW_SENTIDO,
          NEW_OCORRENCIA,
          NEW_DATA_INI_VIGENCIA,
          NEW_DATA_FIM_VIGENCIA,
          NEW_TEXTO_ASSOCIADO,
          NEW_CODIGO_VAGA
        )
        VALUES
        (
          SEQ_LOG_VALE.NEXTVAL,
          v_DML,
          SYSDATE,
          :NEW.CODIGO_EMPRESA,
          :NEW.TIPO_CONTRATO,
          :NEW.CODIGO_CONTRATO,
          :NEW.CODIGO_LINHA,
          :NEW.CODIGO_ITINERARIO,
          :NEW.TIPO_DIA,
          :NEW.QTDE_VALES,
          :NEW.LOGIN_USUARIO,
          :NEW.DT_ULT_ALTER_USUA,
          :NEW.SEQUENCIA,
          :NEW.SENTIDO,
          :NEW.OCORRENCIA,
          :NEW.DATA_INI_VIGENCIA,
          :NEW.DATA_FIM_VIGENCIA,
          :NEW.TEXTO_ASSOCIADO,
          :NEW.CODIGO_VAGA
        );
    ELSIF UPDATING THEN
      v_DML := 'U';
      INSERT
      INTO RHPBH_VALE_LOG
        (
          ID,
          TIPO_DML,
          DATA_LOG,
          CODIGO_EMPRESA,
          TIPO_CONTRATO,
          CODIGO_CONTRATO,
          NEW_CODIGO_LINHA,
          OLD_CODIGO_LINHA,
          NEW_CODIGO_ITINERARIO,
          OLD_CODIGO_ITINERARIO,
          NEW_TIPO_DIA,
          OLD_TIPO_DIA,
          NEW_QTDE_VALES,
          OLD_QTDE_VALES,
          NEW_LOGIN_USUARIO,
          OLD_LOGIN_USUARIO,
          DT_ULT_ALTER_USUA,
          NEW_SEQUENCIA,
          OLD_SEQUENCIA,
          NEW_SENTIDO,
          OLD_SENTIDO,
          NEW_OCORRENCIA,
          OLD_OCORRENCIA,
          NEW_DATA_INI_VIGENCIA,
          OLD_DATA_INI_VIGENCIA,
          NEW_DATA_FIM_VIGENCIA,
          OLD_DATA_FIM_VIGENCIA,
          NEW_TEXTO_ASSOCIADO,
          OLD_TEXTO_ASSOCIADO,
          NEW_CODIGO_VAGA,
          OLD_CODIGO_VAGA
        )
        VALUES
        (
          SEQ_LOG_VALE.NEXTVAL,
          v_DML,
          SYSDATE,
          :NEW.CODIGO_EMPRESA,
          :NEW.TIPO_CONTRATO,
          :NEW.CODIGO_CONTRATO,
          :NEW.CODIGO_LINHA,
          :OLD.CODIGO_LINHA,
          :NEW.CODIGO_ITINERARIO,
          :OLD.CODIGO_ITINERARIO,
          :NEW.TIPO_DIA,
          :OLD.TIPO_DIA,
          :NEW.QTDE_VALES,
          :OLD.QTDE_VALES,
          :NEW.LOGIN_USUARIO,
          :OLD.LOGIN_USUARIO,
          :NEW.DT_ULT_ALTER_USUA,
          :NEW.SEQUENCIA,
          :OLD.SEQUENCIA,
          :NEW.SENTIDO,
          :OLD.SENTIDO,
          :NEW.OCORRENCIA,
          :OLD.OCORRENCIA,
          :NEW.DATA_INI_VIGENCIA,
          :OLD.DATA_INI_VIGENCIA,
          :NEW.DATA_FIM_VIGENCIA,
          :OLD.DATA_FIM_VIGENCIA,
          :NEW.TEXTO_ASSOCIADO,
          :OLD.TEXTO_ASSOCIADO,
          :NEW.CODIGO_VAGA,
          :OLD.CODIGO_VAGA
        );
    ELSIF DELETING THEN
      v_DML := 'D';
      INSERT
      INTO RHPBH_VALE_LOG
        (
          ID,
          TIPO_DML,
          DATA_LOG,
          CODIGO_EMPRESA,
          TIPO_CONTRATO,
          CODIGO_CONTRATO,
          OLD_CODIGO_LINHA,
          OLD_CODIGO_ITINERARIO,
          OLD_TIPO_DIA,
          OLD_QTDE_VALES,
          OLD_LOGIN_USUARIO,
          DT_ULT_ALTER_USUA,
          OLD_SEQUENCIA,
          OLD_SENTIDO,
          OLD_OCORRENCIA,
          OLD_DATA_INI_VIGENCIA,
          OLD_DATA_FIM_VIGENCIA,
          OLD_TEXTO_ASSOCIADO,
          OLD_CODIGO_VAGA
        )
        VALUES
        (
          SEQ_LOG_VALE.NEXTVAL,
          v_DML,
          SYSDATE,
          :OLD.CODIGO_EMPRESA,
          :OLD.TIPO_CONTRATO,
          :OLD.CODIGO_CONTRATO,
          :OLD.CODIGO_LINHA,
          :OLD.CODIGO_ITINERARIO,
          :OLD.TIPO_DIA,
          :OLD.QTDE_VALES,
          :OLD.LOGIN_USUARIO,
          :OLD.DT_ULT_ALTER_USUA,
          :OLD.SEQUENCIA,
          :OLD.SENTIDO,
          :OLD.OCORRENCIA,
          :OLD.DATA_INI_VIGENCIA,
          :OLD.DATA_FIM_VIGENCIA,
          :OLD.TEXTO_ASSOCIADO,
          :OLD.CODIGO_VAGA
        );
    END IF;
  END;




ALTER TRIGGER "ARTERH"."TR_VALE_LOG" ENABLE