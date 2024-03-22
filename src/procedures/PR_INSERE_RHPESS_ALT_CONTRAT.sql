
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_INSERE_RHPESS_ALT_CONTRAT" (
 pcodigo_empresa IN VARCHAR2,
 ptipo_contrato  IN VARCHAR2,
 pcodigo_contrato   IN VARCHAR2,
 plogin_usuario  IN VARCHAR2,
 pdata_alteracao in date,
 pcampo  IN lista,
 pconteudo_anterior  IN lista,
 pconteudo_novo IN lista
) AS BEGIN

DECLARE 

vcodigo_alteracao VARCHAR2(4);
vERRO VARCHAR2(2000);

    BEGIN
    vcodigo_alteracao:= NULL;

        FOR i IN 1..pcampo.count
        LOOP
            vcodigo_alteracao:= NULL;
            --dbms_output.put_line(pcampo(i)||' : ' ||pconteudo_novo(i));
            BEGIN
                SELECT CODIGO INTO vcodigo_alteracao FROM RHTABS_TP_ALT_CONT WHERE COLUNA = upper(pcampo(i)) AND CODIGO LIKE '%E%' AND GERA_AUTOMATICO = 'S';         
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            vERRO := 'NÃO EXISTE TIPO DE ALTERAÇÃO CADASTRAL PARA O CAMPO '||upper(pcampo(i));
            DBMS_Output.PUT_LINE(vERRO);
            --raise_application_error (-20003,vERRO);
            WHEN OTHERS THEN
            vERRO := 'ENCONTRADO ERRO - '||SQLCODE|| ' -ERROR- '||SQLERRM||'';
            DBMS_Output.PUT_LINE(vERRO);
            --raise_application_error (-20003,vERRO);
            END;
            if vcodigo_alteracao is not null then
                INSERT INTO arterh.rhpess_alt_contrat ( codigo_empresa,tipo_contrato,codigo_contrato,data_alteracao,ocorrencia,codigo_alteracao,conteudo_anterior,conteudo_novo,login_usuario,dt_ult_alter_usua,texto_associado,obs_geracao ) 
                VALUES (pcodigo_empresa,ptipo_contrato,pcodigo_contrato,pdata_alteracao,( SELECT nvl(MAX(ocorrencia),0) + 1 FROM rhpess_alt_contrat WHERE codigo_empresa = pcodigo_empresa AND tipo_contrato = ptipo_contrato AND codigo_contrato = pcodigo_contrato AND codigo_alteracao = vcodigo_alteracao AND data_alteracao = pdata_alteracao),vcodigo_alteracao,pconteudo_anterior(i),pconteudo_novo(i),plogin_usuario,sysdate,'INSERIDO PELA ' || plogin_usuario,'Em '|| sysdate );
            end if;
        end loop; 
    END;

END;