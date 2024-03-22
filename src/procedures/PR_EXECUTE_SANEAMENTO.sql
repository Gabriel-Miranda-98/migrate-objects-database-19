
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_EXECUTE_SANEAMENTO" AS
vQTDE_LINHAS_AFETADAS NUMBER;
CONT NUMBER :=0;
NUMERO_LINHAS NUMBER:=0;
vINSERT VARCHAR2(4000);
err_msg VARCHAR2(1000);
vCOMANDO_PADRAO VARCHAR2(400):='INSERT INTO SUGESP_SANEAMENTO_SITFUNCPONT(ID, O_QUE_FAZER, CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, ORIGEM, COD_SIT_FUNC, SITUACAO_FUNCIONAL, COD_SIT_PONTO, SITUACAO_PONTO, DATA_INICIO, DATA_FIM, DATA_DOM, INFO_ONUS, CNPJ_CESSIONARIO,TEXTO_ASSOCIADO,REFERENCIA, USUARIO, DATA_SANEAMENTO, CONCEDIDO_ATE)';

CURSOR C1 IS
SELECT * FROM ARTERH.rhpbh_apoio_assessoria WHERE STATUS_LINHA='CARREGADO' and trunc(DATA_CARGA)=trunc(sysdate-1)   ORDER BY CODIGO_EMPRESA,TIPO_CONTRATO,codigo_contrato,numero_linha;
REG_LINHAS C1%ROWTYPE;

FUNCTION MAX_LINHA_BM(REG_DADOS rhpbh_apoio_assessoria%ROWTYPE ) RETURN NUMBER IS
MAX_LINHA NUMBER:=0;
BEGIN
SELECT MAX(MAX_LINHA) INTO MAX_LINHA FROM ARTERH.rhpbh_apoio_assessoria WHERE STATUS_LINHA='CARREGADO' and  codigo_empresa =REG_DADOS.CODIGO_EMPRESA AND TIPO_CONTRATO=REG_DADOS.TIPO_CONTRATO AND CODIGO_CONTRATO=REG_DADOS.CODIGO_CONTRATO AND trunc(data_carga)=trunc(REG_DADOS.DATA_CARGA);
RETURN MAX_LINHA;
END;
BEGIN
DBMS_OUTPUT.ENABLE (buffer_size => NULL);
vQTDE_LINHAS_AFETADAS:=0;

begin
DELETE FROM rhpbh_apoio_assessoria  WHERE STATUS_LINHA='CARREGADO' AND codigo_contrato=lpad('0',15,0);

commit;
end;

OPEN C1;

LOOP
CONT:=CONT+1;
    fetch C1 into REG_LINHAS;
        EXIT WHEN C1%NOTFOUND;
NUMERO_LINHAS:=MAX_LINHA_BM(REG_LINHAS);
---dbms_output.put_line(vCOMANDO_PADRAO||'VALUES ('||'(SELECT MAX(ID)+1 FROM ARTERH.SUGESP_SANEAMENTO_SITFUNCPONT)'||','''||reg_linhas.O_QUE_FAZER||''','''||REG_LINHAS.CODIGO_EMPRESA||''','''||REG_LINHAS.TIPO_CONTRATO||''','''||REG_LINHAS.CODIGO_CONTRATO||''','''||REG_LINHAS.ORIGEM||''','''||reg_linhas.COD_ORIGEM||''','''||reg_linhas.DESCRICAO_ORIGEM||''','''||REG_LINHAS.COD_SIT_PONTO||''','''||REG_LINHAS.SITUACAO_PONTO||''','''||reg_linhas.DATA_INICIO||''','''||reg_linhas.DATA_FIM||''','''||reg_linhas.DATA_DOM||''','''||REG_LINHAS.INFO_ONUS||''','''||REG_LINHAS.CNPJ_CESSIONARIO||''','''||reg_linhas.TEXTO_ASSOCIADO||''','''||reg_linhas.REFERENCIA||''','''||reg_linhas.USUARIO||''','''||reg_linhas.DATA_SANEAMENTO||''','''||reg_linhas.CONCEDIDO_ATE||''');');
vINSERT:=vCOMANDO_PADRAO||'VALUES ('||'(SELECT MAX(ID)+1 FROM ARTERH.SUGESP_SANEAMENTO_SITFUNCPONT)'||','''||reg_linhas.O_QUE_FAZER||''','''||REG_LINHAS.CODIGO_EMPRESA||''','''||REG_LINHAS.TIPO_CONTRATO||''','''||REG_LINHAS.CODIGO_CONTRATO||''','''||trim(REG_LINHAS.ORIGEM)||''','''||reg_linhas.COD_ORIGEM||''','''||reg_linhas.DESCRICAO_ORIGEM||''','''||REG_LINHAS.COD_SIT_PONTO||''','''||REG_LINHAS.SITUACAO_PONTO||''','''||reg_linhas.DATA_INICIO||''','''||reg_linhas.DATA_FIM||''','''||reg_linhas.DATA_DOM||''','''||REG_LINHAS.INFO_ONUS||''','''||REG_LINHAS.CNPJ_CESSIONARIO||''','''||reg_linhas.TEXTO_ASSOCIADO||''','''||reg_linhas.REFERENCIA||''','''||reg_linhas.USUARIO||''','''||reg_linhas.DATA_SANEAMENTO||''','''||reg_linhas.CONCEDIDO_ATE||''')';
---dbms_output.put_line(vINSERT);
EXECUTE IMMEDIATE vINSERT;
vQTDE_LINHAS_AFETADAS := sql%rowcount;
    if vQTDE_LINHAS_AFETADAS=1 then 
        --dbms_output.put_line(vQTDE_LINHAS_AFETADAS);
        commit;
    end if;
IF REG_LINHAS.MAX_LINHA=NUMERO_LINHAS THEN 
--dbms_output.put_line('---'||NUMERO_LINHAS);
--dbms_output.put_line('EXECUTE ARTERH.PR_SUGESP_RETORNO_SANEAMENTO ('''||reg_linhas.codigo_empresa||''','''||reg_linhas.tipo_contrato||''','''||reg_linhas.codigo_contrato||''');');
BEGIN 
--dbms_output.put_line('---'||NUMERO_LINHAS);
dbms_output.put_line('EXECUTE ARTERH.PR_SUGESP_RETORNO_SANEAMENTO ('''||reg_linhas.codigo_empresa||''','''||reg_linhas.tipo_contrato||''','''||reg_linhas.codigo_contrato||''');');
ARTERH.PR_SUGESP_RETORNO_SANEAMENTO (''||reg_linhas.codigo_empresa||'',''||reg_linhas.tipo_contrato||'',''||reg_linhas.codigo_contrato||'');
UPDATE ARTERH.rhpbh_apoio_assessoria SET STATUS_LINHA='PROCESSADO' WHERE STATUS_LINHA='CARREGADO' and codigo_contrato=reg_linhas.codigo_contrato and tipo_contrato=reg_linhas.tipo_contrato and codigo_empresa=reg_linhas.codigo_empresa and TRUNC(data_carga)=TRUNC(reg_linhas.data_carga);
commit;
 EXCEPTION
     WHEN OTHERS THEN
     err_msg := SQLCODE||' '||SUBSTR(SQLERRM, 1, 4000);
     UPDATE ARTERH.rhpbh_apoio_assessoria SET STATUS_LINHA='ERRO',E_ERRO='S',ERRO=err_msg  WHERE STATUS_LINHA='CARREGADO' and codigo_contrato=reg_linhas.codigo_contrato and tipo_contrato=reg_linhas.tipo_contrato and codigo_empresa=reg_linhas.codigo_empresa and TRUNC(data_carga)=TRUNC(reg_linhas.data_carga);
     dbms_output.put_line('ERRO DA PROCEDURE:  '||SQLCODE||' -ERROR- '||SQLERRM);
END;


END IF;
END LOOP;
CLOSE C1;
END;