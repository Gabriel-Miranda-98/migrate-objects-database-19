
  CREATE OR REPLACE EDITIONABLE TRIGGER "ARTERH"."TR_DELEGACAO" FOR
    UPDATE  ON arterh.rhorga_custo_geren
COMPOUND TRIGGER
TYPE campos_gerenc IS RECORD (
            new_id_agrup         rhorga_custo_geren.id_agrup%TYPE,
            old_id_agrup         rhorga_custo_geren.id_agrup%TYPE,
            codigo_empresa       rhorga_custo_geren.codigo_empresa%TYPE,
            new_cod_cgerenc1     rhorga_custo_geren.cod_cgerenc1%TYPE,
            new_cod_cgerenc2     rhorga_custo_geren.cod_cgerenc2%TYPE,
            new_cod_cgerenc3     rhorga_custo_geren.cod_cgerenc3%TYPE,
            new_cod_cgerenc4     rhorga_custo_geren.cod_cgerenc4%TYPE,
            new_cod_cgerenc5     rhorga_custo_geren.cod_cgerenc5%TYPE,
            new_cod_cgerenc6     rhorga_custo_geren.cod_cgerenc6%TYPE,
            new_cod_empresa_pess rhorga_custo_geren.cod_empresa_pess%TYPE,
            new_cod_pessoa_resp  rhorga_custo_geren.cod_pessoa_resp%TYPE,
            new_tipo_cont_resp   rhorga_custo_geren.tipo_cont_resp%TYPE,
            new_contrato_resp    rhorga_custo_geren.contrato_resp%TYPE,
            new_data_extincao    rhorga_custo_geren.data_extincao%TYPE,
            old_data_extincao    rhorga_custo_geren.data_extincao%TYPE,
            old_cod_cgerenc1     rhorga_custo_geren.cod_cgerenc1%TYPE,
            old_cod_cgerenc2     rhorga_custo_geren.cod_cgerenc2%TYPE,
            old_cod_cgerenc3     rhorga_custo_geren.cod_cgerenc3%TYPE,
            old_cod_cgerenc4     rhorga_custo_geren.cod_cgerenc4%TYPE,
            old_cod_cgerenc5     rhorga_custo_geren.cod_cgerenc5%TYPE,
            old_cod_cgerenc6     rhorga_custo_geren.cod_cgerenc6%TYPE,
            old_cod_empresa_pess rhorga_custo_geren.cod_empresa_pess%TYPE,
            old_cod_pessoa_resp  rhorga_custo_geren.cod_pessoa_resp%TYPE,
            old_tipo_cont_resp   rhorga_custo_geren.tipo_cont_resp%TYPE,
            old_contrato_resp    rhorga_custo_geren.contrato_resp%TYPE,
            new_texto_associado  rhorga_custo_geren.texto_associado%TYPE,
            old_texto_associado  rhorga_custo_geren.texto_associado%TYPE,
            new_descricao        rhorga_custo_geren.descricao%TYPE,
            old_descricao        rhorga_custo_geren.descricao%TYPE,
            new_login_usuario    rhorga_custo_geren.login_usuario%TYPE,
            old_login_usuario    rhorga_custo_geren.login_usuario%TYPE,
            dt_ult_alter_usua    rhorga_custo_geren.dt_ult_alter_usua%TYPE
    );

    TYPE linha IS
        TABLE OF campos_gerenc INDEX BY PLS_INTEGER;
    linha_info                   linha;

      v_log                        arterh.sugesp_log_delegacao_para_cima%rowtype;

    v_dados_gestor               TYPE_FINALIZAR_DELEGACAO_E_GESTOR;
    v_retorno_dados_gestores DADOS_GESTORES;
    rhpbh_pessoa_responsavel arterh.rhuser_pessoa_responsavel%rowtype;
    rhpbh_pessoa_resp_supervisao arterh.rhuser_pessoa_resp_supervisao%rowtype;
    PROCEDURE grava_log (
        var arterh.sugesp_log_delegacao_para_cima%rowtype
    ) IS
    BEGIN
        INSERT INTO arterh.sugesp_log_delegacao_para_cima VALUES var;

    END;

    PROCEDURE        PR_incluir_responsavel (
        var arterh.rhuser_pessoa_responsavel%rowtype
    ) IS
    BEGIN
        INSERT INTO arterh.rhuser_pessoa_responsavel VALUES var;

    END;

    PROCEDURE        PR_incluir_subordinado (
        var arterh.rhuser_pessoa_resp_supervisao%rowtype
    ) IS
    BEGIN
        INSERT INTO arterh.rhuser_pessoa_resp_supervisao VALUES var;

    END;
AFTER EACH ROW IS BEGIN
        linha_info(linha_info.count + 1).codigo_empresa := :new.codigo_empresa;
        linha_info(linha_info.count).new_id_agrup := :new.id_agrup;
        linha_info(linha_info.count).old_id_agrup := :old.id_agrup;
        linha_info(linha_info.count).new_cod_cgerenc1 := :new.cod_cgerenc1;
        linha_info(linha_info.count).old_cod_cgerenc1 := :old.cod_cgerenc1;
        linha_info(linha_info.count).new_cod_cgerenc2 := :new.cod_cgerenc2;
        linha_info(linha_info.count).old_cod_cgerenc2 := :old.cod_cgerenc2;
        linha_info(linha_info.count).new_cod_cgerenc3 := :new.cod_cgerenc3;
        linha_info(linha_info.count).old_cod_cgerenc3 := :old.cod_cgerenc3;
        linha_info(linha_info.count).new_cod_cgerenc4 := :new.cod_cgerenc4;
        linha_info(linha_info.count).old_cod_cgerenc4 := :old.cod_cgerenc4;
        linha_info(linha_info.count).new_cod_cgerenc5 := :new.cod_cgerenc5;
        linha_info(linha_info.count).old_cod_cgerenc5 := :old.cod_cgerenc5;
        linha_info(linha_info.count).new_cod_cgerenc6 := :new.cod_cgerenc6;
        linha_info(linha_info.count).old_cod_cgerenc6 := :old.cod_cgerenc6;
        linha_info(linha_info.count).new_cod_empresa_pess := :new.cod_empresa_pess;
        linha_info(linha_info.count).old_cod_empresa_pess := :old.cod_empresa_pess;
        linha_info(linha_info.count).new_cod_pessoa_resp := :new.cod_pessoa_resp;
        linha_info(linha_info.count).old_cod_pessoa_resp := :old.cod_pessoa_resp;
        linha_info(linha_info.count).new_tipo_cont_resp := :new.tipo_cont_resp;
        linha_info(linha_info.count).old_tipo_cont_resp := :old.tipo_cont_resp;
        linha_info(linha_info.count).new_contrato_resp := :new.contrato_resp;
        linha_info(linha_info.count).old_contrato_resp := :old.contrato_resp;
        linha_info(linha_info.count).new_data_extincao := :new.data_extincao;
        linha_info(linha_info.count).old_data_extincao := :old.data_extincao;
        linha_info(linha_info.count).new_login_usuario := :new.login_usuario;
        linha_info(linha_info.count).old_login_usuario := :old.login_usuario;
        linha_info(linha_info.count).new_descricao := :new.descricao;
        linha_info(linha_info.count).old_descricao := :old.login_usuario;
        linha_info(linha_info.count).new_texto_associado := :new.texto_associado;
        linha_info(linha_info.count).old_texto_associado := :old.texto_associado;
        linha_info(linha_info.count).dt_ult_alter_usua := :new.dt_ult_alter_usua;
    END AFTER EACH ROW;
     AFTER STATEMENT IS BEGIN
        FOR indx IN 1..linha_info.count LOOP
            v_retorno_dados_gestores:=DADOS_GESTORES(NULL,NULL,NULL,NULL,NULL,NULL);
            v_log.tipo_dml :='U';
            v_log.ID:=SQ_SUGESP_LOG_DELEGACAO_PARA_CIMA.NEXTVAL;
            v_log.codigo_empresa := linha_info(indx).codigo_empresa;
            v_log.new_cod_unidade1 := linha_info(indx).new_cod_cgerenc1;
            v_log.new_cod_unidade2 := linha_info(indx).new_cod_cgerenc2;
            v_log.new_cod_unidade3 := linha_info(indx).new_cod_cgerenc3;
            v_log.new_cod_unidade4 := linha_info(indx).new_cod_cgerenc4;
            v_log.new_cod_unidade5 := linha_info(indx).new_cod_cgerenc5;
            v_log.new_cod_unidade6 := linha_info(indx).new_cod_cgerenc6;
            v_log.old_cod_unidade1 := linha_info(indx).old_cod_cgerenc1;
            v_log.old_cod_unidade2 := linha_info(indx).old_cod_cgerenc2;
            v_log.old_cod_unidade3 := linha_info(indx).old_cod_cgerenc3;
            v_log.old_cod_unidade4 := linha_info(indx).old_cod_cgerenc4;
            v_log.old_cod_unidade5 := linha_info(indx).old_cod_cgerenc5;
            v_log.old_cod_unidade6 := linha_info(indx).old_cod_cgerenc6;
            v_log.new_codigo_empresa_resp_gestor := linha_info(indx).new_cod_empresa_pess;
            v_log.new_codigo_pessoa_resp_gestor := linha_info(indx).new_cod_pessoa_resp;
            v_log.new_tipo_contrato_resp_gestor := linha_info(indx).new_tipo_cont_resp;
            v_log.new_codigo_contrato_resp_gestor := linha_info(indx).new_contrato_resp;
            v_log.old_codigo_empresa_resp_gestor := linha_info(indx).old_cod_empresa_pess;
            v_log.old_codigo_pessoa_resp_gestor := linha_info(indx).old_cod_pessoa_resp;
            v_log.old_tipo_contrato_resp_gestor := linha_info(indx).old_tipo_cont_resp;
            v_log.old_codigo_contrato_resp_gestor := linha_info(indx).old_contrato_resp;
            v_log.new_data_extincao := linha_info(indx).new_data_extincao;
            v_log.old_data_extincao := linha_info(indx).old_data_extincao;
            v_log.new_login_usuario := linha_info(indx).new_login_usuario;
            v_log.old_login_usuario := linha_info(indx).old_login_usuario;
            v_log.dt_ult_alter_usua := linha_info(indx).dt_ult_alter_usua;
            grava_log(v_log);

            ----INICIO DA LOGICA PARA ATUALIZAR A TELA DE DELEGACAO
            --IF GERAL BEGIN
            IF updating AND linha_info(indx).old_data_extincao IS  NULL AND linha_info(indx).new_data_extincao IS NOT NULL  and linha_info(indx).OLD_contrato_resp is not null THEN
            v_retorno_dados_gestores := fn_dados_delegacao_gestor(linha_info(indx).OLD_cod_empresa_pess, linha_info(indx).OLD_tipo_cont_resp , linha_info(indx).OLD_contrato_resp,linha_info(indx).old_cod_cgerenc1,linha_info(indx).old_cod_cgerenc2,linha_info(indx).old_cod_cgerenc3,linha_info(indx).old_cod_cgerenc4,linha_info(indx).old_cod_cgerenc5,linha_info(indx).old_cod_cgerenc6);
            FOR C1 IN (
            SELECT RESp.ID,RESP.ID_PROCESSO 
            FROM ARTERH.rhuser_pessoa_responsavel RESP
            INNER JOIN ARTERH.rhuser_pessoa_resp_supervisao SUB
            ON sub.id_rhuser_pessoa_responsavel=RESP.ID
            LEFT OUTER JOIN ARTERH.RHPESS_CONTRATO C
            ON C.CODIGO_EMPRESA=sub.codigo_empresa_ctr_subordinado
            AND C.TIPO_CONTRATO=sub.tipo_contrato_subordinado
            AND C.CODIGO=sub.codigo_contrato_subordinado
            WHERE RESP.ID_PROCESSO IN ('2') AND RESP.DT_FIM_RESPONSABILIDADE IS NULL OR RESP.DT_FIM_RESPONSABILIDADE >TRUNC(SYSDATE)
                        AND RESP.CODIGO_EMPRESA=v_retorno_dados_gestores.codigo_empresa
                        AND RESP.CODIGO_EMPRESA_PESSOA_RESP=v_retorno_dados_gestores.codigo_empresa
                        AND RESP.CODIGO_PESSOA_RESP=v_retorno_dados_gestores.CODIGO_PESSOA_GESTOR
                        AND RESP.CODIGO_CONTRATO_RESP=v_retorno_dados_gestores.CODIGO_CONTRATO
                        AND RESP.TIPO_CONTRATO_RESP=v_retorno_dados_gestores.TIPO_CONTRATO
                        AND RESP.CODIGO_EMPRESA_CONTRATO=v_retorno_dados_gestores.codigo_empresa
                        AND c.ano_mes_referencia=(SELECT MAX(AUX.ano_mes_referencia) FROM ARTERH.RHPESS_CONTRATO AUX 
                        WHERE AUX.CODIGO=C.CODIGO
                        AND AUX.TIPO_CONTRATO=C.TIPO_CONTRATO
                        AND AUX.CODIGO_EMPRESA=C.CODIGO_EMPRESA
                        AND aux.ano_mes_referencia<=(select data_do_sistema from rhparm_p_sist))
                        AND c.cod_custo_gerenc1=linha_info(indx).old_cod_cgerenc1
                        AND c.cod_custo_gerenc2=linha_info(indx).old_cod_cgerenc2
                        AND c.cod_custo_gerenc3=linha_info(indx).old_cod_cgerenc3
                        AND c.cod_custo_gerenc4=linha_info(indx).old_cod_cgerenc4
                        AND c.cod_custo_gerenc5=linha_info(indx).old_cod_cgerenc5
                        AND c.cod_custo_gerenc6=linha_info(indx).old_cod_cgerenc6
            )LOOP
            UPDATE ARTERH.rhuser_pessoa_responsavel SET DT_FIM_RESPONSABILIDADE=SYSDATE, updated=sysdate,updatedby=linha_info(indx).new_login_usuario where id=c1.id AND ID_PROCESSO=C1.ID_PROCESSO;
            UPDATE ARTERH.rhuser_pessoa_resp_supervisao set dt_fim_supervisao=sysdate, updated=sysdate,updatedby=linha_info(indx).new_login_usuario where id_rhuser_pessoa_responsavel=c1.id;
            END LOOP;
           
                
                
                
            END IF;
            --IF GERAL END 
        END LOOP;
    END AFTER STATEMENT;
END;
ALTER TRIGGER "ARTERH"."TR_DELEGACAO" DISABLE