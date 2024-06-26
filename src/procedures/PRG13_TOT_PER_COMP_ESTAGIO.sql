
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PRG13_TOT_PER_COMP_ESTAGIO" (DATA_FIM IN DATE) AS
BEGIN
--KELLYSSON EM 6/8/20 
      --**************TROCAR DATA
DECLARE   
vCONTADOR NUMBER (10);
vDATA DATE;
vNUMERO NUMBER;
vSTRING VARCHAR2 (10 BYTE);

BEGIN 
dbms_output.enable(null);

vCONTADOR := 0;
vDATA := TO_DATE(DATA_FIM,'DD/MM/YYYY'); --**************TROCAR DATA --ULTIMO DIA DO PERIODO EM FECHAMENTO
vNUMERO := 0;
vSTRING := NULL;

--INICIO---C0---------------TODOS BMS
FOR C0 IN (

SELECT X3.* FROM(
SELECT X2.EMPRESA, X2.TIPO_CONTRATO, X2.MATRICULA, COUNT(1)QUANT_DIAS, SUM(X2.FALTA_COMPENSAR) TOTAL_FALTA_COMPENSAR FROM(
SELECT X.*
FROM PONTO_ELETRONICO.IFPONTO_ESPELHO_HISTORICA X
LEFT OUTER JOIN ARTERH.RHPESS_CONTRATO c on X.EMPRESA = c.codigo_empresa and X.TIPO_CONTRATO = C.TIPO_CONTRATO AND X.MATRICULA = C.CODIGO
WHERE X.MATRICULA IS NOT NULL
AND X.DATA_PROCESSAMENTO IS NULL
AND LPAD(X.EMPRESA,4,'0') IN (SELECT DADO_ORIGEM FROM ARTERH.RHINTE_ED_IT_CONV WHERE CODIGO_CONVERSAO = 'IFP4')--NOVO EM 7/11/23
AND C.ANO_MES_REFERENCIA = (SELECT MAX(AUX.ANO_MES_REFERENCIA) FROM ARTERH.RHPESS_CONTRATO AUX WHERE AUX.CODIGO_EMPRESA = C.CODIGO_EMPRESA AND AUX.TIPO_CONTRATO = C.TIPO_CONTRATO AND AUX.CODIGO = C.CODIGO)
AND C.VINCULO = '0009'
)X2 
GROUP BY X2.EMPRESA, X2.TIPO_CONTRATO, X2.MATRICULA
ORDER BY X2.EMPRESA, X2.TIPO_CONTRATO, X2.MATRICULA
)X3
WHERE X3.TOTAL_FALTA_COMPENSAR > 0

)LOOP -- INICIO C0

vNUMERO := C0.TOTAL_FALTA_COMPENSAR;
vSTRING := CASE WHEN INSTR(vNUMERO,',',1,1) = 0 THEN TO_CHAR(vNUMERO) WHEN INSTR(vNUMERO,',',1,1) <> 0 THEN TO_CHAR(SUBSTR(vNUMERO,1,INSTR(vNUMERO,',',1,1)-1) ||'.'||SUBSTR(vNUMERO,INSTR(vNUMERO,',' ,1,1)+1, LENGTH(vNUMERO))) end ;

vCONTADOR :=vCONTADOR+1;
dbms_output.put_line('--vCONTADOR: '||vCONTADOR);
dbms_output.put_line('--GRAVAR: 1203-TOTAL HORAS PROGRAMADAS NAO COMPENSADAS, NO DIA: '|| vDATA||' COM SALDO: '||C0.TOTAL_FALTA_COMPENSAR);
dbms_output.put_line('DELETE RHPONT_RES_SIT_DIA WHERE TIPO_APURACAO = ''F'' AND CODIGO_EMPRESA = ''' ||LPAD(C0.EMPRESA,4,0) ||''' AND TIPO_CONTRATO = ''' || LPAD(C0.TIPO_CONTRATO,4,0) ||''' AND CODIGO_CONTRATO = '''|| LPAD(C0.MATRICULA,15,0) ||'''AND TRUNC(DATA) = TO_DATE('''|| trunc(vDATA) ||''',''DD/MM/YYYY'') AND CODIGO_SITUACAO = ''1203''; COMMIT;' );  
dbms_output.put_line('INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, TIPO_APURACAO, DT_ULT_ALTER_USUA, LOGIN_USUARIO, FORCA_SITUACAO, TEXTO_ASSOCIADO) VALUES ('''||LPAD(C0.EMPRESA,4,0) ||''','''|| LPAD(C0.TIPO_CONTRATO,4,0) ||''','''|| LPAD(C0.MATRICULA,15,0) ||''', TO_DATE('''|| trunc(vDATA) ||''',''DD/MM/YYYY''),''1203'', ROUND('|| vSTRING ||',2), ''F'', SYSDATE, ''IFPONTO'', ''N'',''SCRIPT FECHAMENTO IFPONTO(totais_periodo_comp_pbh_V1_estagio.sql)''); COMMIT;' );
DELETE ARTERH.RHPONT_RES_SIT_DIA WHERE TIPO_APURACAO = 'F' AND CODIGO_EMPRESA =  LPAD(C0.EMPRESA,4,0)  AND TIPO_CONTRATO =   LPAD(C0.TIPO_CONTRATO,4,0)  AND CODIGO_CONTRATO =  LPAD(C0.MATRICULA,15,0) AND TRUNC(DATA) = vDATA  AND CODIGO_SITUACAO = '1203'; COMMIT;
INSERT INTO ARTERH.RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, TIPO_APURACAO, DT_ULT_ALTER_USUA, LOGIN_USUARIO, FORCA_SITUACAO, TEXTO_ASSOCIADO) VALUES (LPAD(C0.EMPRESA,4,0) , LPAD(C0.TIPO_CONTRATO,4,0) , LPAD(C0.MATRICULA,15,0), vDATA,'1203', ROUND(vNUMERO,2), 'F', SYSDATE, 'IFPONTO', 'N','PRG13_TOT_PER_COMP_ESTAGIO'); COMMIT;


END LOOP;--C0
--FIM----C0--------------TODOS BMS

END;

END;
