
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_INSERE_CONTRATO" (pCODIGO_EMPRESA IN VARCHAR2, pTIPO_CONTRATO IN VARCHAR2, pCODIGO IN VARCHAR2 ,pANO_MES DATE ) AS
VCAMPO CLOB;
VCAMPOS CLOB;
Vcomando CLOB;
vCRIA_CONTRATO VARCHAR2(1); 
BEGIN

        SELECT CASE WHEN COUNT(1) = 0 THEN 'S' ELSE 'N' END AS CRIA_CONTRATO INTO vCRIA_CONTRATO
        FROM rhpess_contrato C where C.codigo_empresa = pCODIGO_EMPRESA and C.tipo_contrato = pTIPO_CONTRATO And C.CODIGO = pCODIGO AND C.ano_mes_referencia = to_date(to_char(trunc(pANO_MES,'MM'),'dd/mm/yyyy'),'dd/mm/yyyy');
        dbms_output.put_line(vCRIA_CONTRATO);

        IF( vCRIA_CONTRATO = 'S' ) THEN
            SELECT REPLACE(X.COLUNAS,'ANO_MES_REFERENCIA','to_date('''||to_char(trunc(pANO_MES,'MM'),'dd/mm/yyyy')||''',''dd/mm/yyyy'') as ANO_MES_REFERENCIA') AS COLUNAS into VCAMPO 
            FROM ( SELECT LISTAGG( column_name,',') WITHIN GROUP( ORDER BY COLUMN_ID ) AS COLUNAS FROM  all_tab_cols WHERE table_name = 'RHPESS_CONTRATO' and owner = 'ARTERH' AND COLUMN_ID <150 ) X;            
            VCAMPOS:= VCAMPO;            
            SELECT REPLACE(X.COLUNAS,'ANO_MES_REFERENCIA','to_date('''||to_char(trunc(pANO_MES,'MM'),'dd/mm/yyyy')||''',''dd/mm/yyyy'') as ANO_MES_REFERENCIA') AS COLUNAS into VCAMPO 
            FROM ( SELECT LISTAGG( column_name,',') WITHIN GROUP( ORDER BY COLUMN_ID ) AS COLUNAS FROM  all_tab_cols WHERE table_name = 'RHPESS_CONTRATO' and owner = 'ARTERH' AND COLUMN_ID >=150 ) X;

            VCAMPOS:= VCAMPOS||',' ||VCAMPO;

            Vcomando:='insert into arterh.RHPESS_CONTRATO select '||VCAMPOS||' from RHPESS_CONTRATO P2 WHERE P2.CODIGO_EMPRESA = '''||pCODIGO_EMPRESA||''' AND P2.CODIGO = '''||pCODIGO||''' AND P2.TIPO_CONTRATO = '''||pTIPO_CONTRATO||''' AND P2.ANO_MES_REFERENCIA = (select max(AUX.ano_mes_referencia) from RHPESS_CONTRATO AUX where AUX.codigo_empresa = P2.codigo_empresa and AUX.TIPO_CONTRATO = P2.TIPO_CONTRATO  AND AUX.codigo = P2.codigo AND AUX.ano_mes_referencia < to_date('''||to_char(trunc(pANO_MES,'MM'),'dd/mm/yyyy')||''',''dd/mm/yyyy'') )';            
            dbms_output.put_line(Vcomando);
             --dbms_output.put_line(VCAMPO);
               execute IMMEDIATE(Vcomando);
               COMMIT;

        END IF;

END;