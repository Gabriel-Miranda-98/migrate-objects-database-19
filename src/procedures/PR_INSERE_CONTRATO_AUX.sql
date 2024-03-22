
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_INSERE_CONTRATO_AUX" (pCODIGO_EMPRESA IN VARCHAR2, pTIPO_CONTRATO IN VARCHAR2, pCODIGO IN VARCHAR2 ,pANO_MES DATE, pLOGIN_USUARIO IN VARCHAR2 ) AS
VCAMPO CLOB;
Vcomando CLOB;
vCRIA_CONTRATO_AUX VARCHAR2(1); 
begin

SELECT CASE WHEN COUNT(1) = 0 THEN 'S' ELSE 'N' END AS CRIA_CONTRATO INTO vCRIA_CONTRATO_AUX FROM RHPESS_CONTRATO_AUX C where C.codigo_empresa = pCODIGO_EMPRESA and C.tipo_contrato = pTIPO_CONTRATO And C.CODIGO = pCODIGO;

IF( vCRIA_CONTRATO_AUX = 'S' ) THEN
    Vcomando:='INSERT INTO RHPESS_CONTRATO_AUX ( CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO, ANO_MES_REFERENCIA, LOGIN_USUARIO, DT_ULT_ALTER_USUA ) VALUES (''' ||pCODIGO_EMPRESA||''' , '''||pTIPO_CONTRATO||''', '''||pCODIGO||''', to_date('''||trunc(pANO_MES,'MM')||''',''dd/mm/yy'') ,'''||pLOGIN_USUARIO||''',SYSDATE )';
    execute IMMEDIATE(Vcomando);
    COMMIT;

ELSE
SELECT CASE WHEN COUNT(1) = 0 THEN 'S' ELSE 'N' END AS CRIA_CONTRATO INTO vCRIA_CONTRATO_AUX FROM RHPESS_CONTRATO_AUX C where C.codigo_empresa = pCODIGO_EMPRESA and C.tipo_contrato = pTIPO_CONTRATO And C.CODIGO = pCODIGO AND C.ano_mes_referencia = trunc(pANO_MES,'MM');

    IF( vCRIA_CONTRATO_AUX = 'S' ) THEN
            SELECT REPLACE(X.COLUNAS,'ANO_MES_REFERENCIA','to_date('''||trunc(pANO_MES,'MM')||''',''dd/mm/yyyy'') as ANO_MES_REFERENCIA') AS COLUNAS into VCAMPO 
            FROM ( SELECT LISTAGG( column_name,',') WITHIN GROUP( ORDER BY COLUMN_ID ) AS COLUNAS FROM   all_tab_cols WHERE  table_name = 'RHPESS_CONTRATO_AUX' and owner = 'ARTERH' order by COLUMN_ID ) X;

            Vcomando:='insert into arterh.RHPESS_CONTRATO_AUX select '||VCAMPO||' from RHPESS_CONTRATO_AUX P2 WHERE P2.CODIGO_EMPRESA = ''' ||pCODIGO_EMPRESA||''' AND P2.CODIGO = '''||pCODIGO||''' AND P2.TIPO_CONTRATO = '''||pTIPO_CONTRATO||''' AND P2.ANO_MES_REFERENCIA = (select max(AUX.ano_mes_referencia) from RHPESS_CONTRATO_AUX AUX where AUX.codigo_empresa = P2.codigo_empresa and AUX.TIPO_CONTRATO = P2.TIPO_CONTRATO  AND AUX.codigo = P2.codigo AND AUX.ano_mes_referencia < to_date('''||trunc(pANO_MES,'MM')||''',''dd/mm/yy''))';            
            --dbms_output.put_line(Vcomando);
            execute IMMEDIATE(Vcomando);
            COMMIT;
        END IF;             
END IF;  



END;