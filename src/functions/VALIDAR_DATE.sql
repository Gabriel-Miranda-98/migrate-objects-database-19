
  CREATE OR REPLACE EDITIONABLE FUNCTION "PONTO_ELETRONICO"."VALIDAR_DATE" (COD_EMPRESA IN CHAR,TP_CONT IN CHAR,COD_CONT IN VARCHAR2,COD_SIT_FUNC IN CHAR) RETURN VARCHAR2 IS
vRETORO VARCHAR2 (15 BYTE);
vDate date;
BEGIN 
SELECT trunc(S.DATA_INIC_SITUACAO) into vDate FROM ARTERH.RHCGED_ALT_SIT_FUN S WHERE S.CODIGO_EMPRESA  =COD_EMPRESA
   AND S.CODIGO =COD_CONT AND S.TIPO_CONTRATO=TP_CONT AND S.COD_SIT_FUNCIONAL =COD_SIT_FUNC
   AND S.DATA_INIC_SITUACAO =(SELECT MAX(AUX.DATA_INIC_SITUACAO)FROM RHCGED_ALT_SIT_FUN AUX WHERE S.CODIGO_EMPRESA =AUX.CODIGO_EMPRESA AND S.CODIGO=AUX.CODIGO
   AND S.TIPO_CONTRATO    =AUX.TIPO_CONTRATO);
    IF vDate <=TRUNC(SYSDATE) THEN
   vRETORO:= 'DESLIGAMENTO';
   ELSE
   vRETORO:='ATIVO';
   END IF;

   RETURN vRETORO;
END;