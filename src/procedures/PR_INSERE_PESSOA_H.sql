
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_INSERE_PESSOA_H" (pCODIGO_EMPRESA IN VARCHAR2, pCODIGO IN VARCHAR2, pANO_MES DATE ) AS
VCAMPO CLOB;
Vcomando CLOB;
vCRIA_PESSOA VARCHAR2(1); 
begin

SELECT CASE WHEN COUNT(1) = 0 THEN 'S' ELSE 'N' END AS CRIA_CONTRATO INTO vCRIA_PESSOA FROM RHPESS_PESSOA_H C where C.codigo_empresa = pCODIGO_EMPRESA and C.CODIGO = pCODIGO;
IF( vCRIA_PESSOA = 'S' ) THEN
            SELECT REPLACE(X.COLUNAS,'ANO_MES_REFERENCIA,','to_date('''||trunc(pANO_MES,'MM')||''',''dd/mm/yyyy'') as ANO_MES_REFERENCIA') AS COLUNAS into VCAMPO 
            FROM ( SELECT LISTAGG( column_name,',') WITHIN GROUP( ORDER BY COLUMN_ID ) AS COLUNAS FROM   all_tab_cols WHERE  table_name = 'RHPESS_PESSOA_H' and owner = 'ARTERH' order by COLUMN_ID ) X;

            Vcomando:='insert into arterh.RHPESS_PESSOA_H select '||VCAMPO||' from  RHPESS_PESSOA P2 WHERE P2.CODIGO_EMPRESA = ''' ||pCODIGO_EMPRESA||''' AND P2.CODIGO = '''||pCODIGO||''' ';
           -- dbms_output.put_line(Vcomando);
            execute IMMEDIATE(Vcomando);
            COMMIT;

ELSE
SELECT CASE WHEN COUNT(1) = 0 THEN 'S' ELSE 'N' END AS CRIA_CONTRATO INTO vCRIA_PESSOA FROM RHPESS_PESSOA_H C where C.codigo_empresa = pCODIGO_EMPRESA and C.CODIGO = pCODIGO AND C.ano_mes_referencia = trunc(pANO_MES,'MM');
    IF( vCRIA_PESSOA = 'S' ) THEN
            SELECT REPLACE(X.COLUNAS,'ANO_MES_REFERENCIA','to_date('''||trunc(pANO_MES,'MM')||''',''dd/mm/yyyy'') as ANO_MES_REFERENCIA') AS COLUNAS into VCAMPO 
            FROM ( SELECT LISTAGG( column_name,',') WITHIN GROUP( ORDER BY COLUMN_ID ) AS COLUNAS FROM   all_tab_cols WHERE  table_name = 'RHPESS_PESSOA_H' and owner = 'ARTERH' order by COLUMN_ID ) X;

            Vcomando:='insert into arterh.RHPESS_PESSOA_H select '||VCAMPO||' from  RHPESS_PESSOA_H P2 WHERE P2.CODIGO_EMPRESA = ''' ||pCODIGO_EMPRESA||''' AND P2.CODIGO = '''||pCODIGO||''' AND P2.ANO_MES_REFERENCIA =(select max(AUX.ano_mes_referencia) from RHPESS_PESSOA_H AUX where AUX.codigo_empresa = P2.codigo_empresa and AUX.codigo = P2.codigo AND AUX.ano_mes_referencia < to_date('''||trunc(pANO_MES,'MM')||''',''dd/mm/yy''))';
           -- dbms_output.put_line(Vcomando);
            execute IMMEDIATE(Vcomando);
            COMMIT;
        END IF;             
END IF;  



END;