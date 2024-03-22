
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_LOTE_FIC_MED_AJUSTE_DOENCA" (DATA_INICIO IN VARCHAR2,DATA_FIM  IN VARCHAR2)
AS
BEGIN

declare  
vCONTADOR NUMBER ;
    vDATA_INICIO VARCHAR2(10);
    vDATA_FIM    VARCHAR2(10);
err_msg varchar2 (4000);

begin
dbms_output.enable(null);
vCONTADOR :=0;
vDATA_INICIO := DATA_INICIO;
vDATA_FIM    := DATA_FIM;

err_msg := NULL;


FOR C1 IN (

select CODIGO_EMPRESA, CODIGO_PESSOA, TRUNC(DT_REG_OCORRENCIA) DT_REG_OCORRENCIA, OCORRENCIA, COUNT(1)QUANT
from SUGESP_FICHAS_MEDICAS X WHERE TRUNC(DT_ULT_ALTER_USUA)  BETWEEN vDATA_INICIO AND vDATA_FIM
AND TIPO_DML = 'U'  
AND TABELA = 'RHMEDI_FICHA_MED' AND 
(
(NEW_NATUREZA_EXAME IS NOT NULL AND OLD_NATUREZA_EXAME IS NOT NULL AND NEW_NATUREZA_EXAME <> OLD_NATUREZA_EXAME) OR
(NEW_DATA_INI_AFAST IS NOT NULL AND OLD_DATA_INI_AFAST IS NOT NULL AND NEW_DATA_INI_AFAST <> OLD_DATA_INI_AFAST) OR
(NEW_DATA_FIM_AFAST IS NOT NULL AND OLD_DATA_FIM_AFAST IS NOT NULL AND NEW_DATA_FIM_AFAST <> OLD_DATA_FIM_AFAST)
OR ((OLD_DATA_INI_AFAST IS NULL AND NEW_DATA_INI_AFAST IS NOT NULL )AND --MUDEI DE OR PARA AND EM 17/11/20 --NAO TINHA DATA AGORA TEM
(OLD_DATA_FIM_AFAST IS NULL AND NEW_DATA_FIM_AFAST IS NOT NULL ))--novo em 19/11/20
)
and exists
(SELECT F.* FROM RHMEDI_FICHA_MED F WHERE 
    TRUNC(F.DT_ULT_ALTER_USUA)  BETWEEN vDATA_INICIO AND vDATA_FIM AND F.CODIGO_EMPRESA = X.CODIGO_EMPRESA AND F.CODIGO_PESSOA = X.CODIGO_PESSOA 
    AND TRUNC(F.DT_REG_OCORRENCIA) = TRUNC(X.DT_REG_OCORRENCIA) AND F.OCORRENCIA = X.OCORRENCIA)

GROUP BY CODIGO_EMPRESA, CODIGO_PESSOA, TRUNC(DT_REG_OCORRENCIA), OCORRENCIA
ORDER BY CODIGO_EMPRESA, CODIGO_PESSOA, TRUNC(DT_REG_OCORRENCIA), OCORRENCIA



)LOOP

BEGIN --EXCEPTION

vCONTADOR :=vCONTADOR+1;
dbms_output.put_line('--'||vCONTADOR);
dbms_output.put_line('EXECUTE PR_FICHA_MEDICA_AJUSTE_DOENCAS(''RHMEDI_FICHA_MED'','''|| C1.CODIGO_EMPRESA || ''', '''|| C1.CODIGO_PESSOA ||''', ''' ||TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD')|| ''','|| C1.OCORRENCIA ||', ''M'', 0);');
PR_FICHA_MEDICA_AJUSTE_DOENCAS('RHMEDI_FICHA_MED', C1.CODIGO_EMPRESA  , C1.CODIGO_PESSOA , TO_CHAR(C1.DT_REG_OCORRENCIA,'YYYYMMDD'), C1.OCORRENCIA , 'M', 0);

EXCEPTION WHEN OTHERS THEN
err_msg := SQLCODE||' '||SUBSTR(SQLERRM, 1, 4000);
dbms_output.put_line('err_msg:' ||err_msg);

INSERT INTO SUGESP_AJUSTE_LOTE_CAMPO_HIST(CODIGO_EMPRESA, CAMPO_VALOR_2, CAMPO_VALOR_3, CAMPO_VALOR_4, CAMPO_VALOR_1,  DATA_DADOS, CONSIDERACOES)
VALUES(C1.CODIGO_EMPRESA,C1.CODIGO_PESSOA, C1.DT_REG_OCORRENCIA, C1.OCORRENCIA,'LOG EXECUCAO PROCEDURE PR_LOTE_FIC_MED_AJUSTE_DOENCA', SYSDATE, err_msg
);COMMIT;

END;--BEGIN EXCEPTION

err_msg := NULL;

END LOOP;

END;

END;