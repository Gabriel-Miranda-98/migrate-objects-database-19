
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_DELEGACAO_TRASFERENCIA_GESTOR" (P_CODIGO_EMPRESA IN CHAR, P_TIPO_CONTRATO IN CHAR,P_CODIGO_CONTRATO IN VARCHAR2, P_TIPO_PROCESSO NUMBER,NEW_ID_GESTOR NUMBER,LOGIN_USUARIO IN VARCHAR2)IS
CONT NUMBER:=0;
rhpbh_pessoa_resp_supervisao arterh.rhuser_pessoa_resp_supervisao%rowtype;

PROCEDURE incluir_subordinado (
		var arterh.rhuser_pessoa_resp_supervisao%rowtype
	) IS
	BEGIN
		INSERT INTO arterh.rhuser_pessoa_resp_supervisao VALUES var;


	END;


BEGIN 


FOR C1 IN (
SELECT
    SUB.* 
FROM
    arterh.rhuser_pessoa_responsavel RESP
    LEFT OUTER JOIN ARTERH.rhuser_pessoa_resp_supervisao SUB
    ON sub.id_rhuser_pessoa_responsavel=RESP.ID
WHERE
        codigo_contrato_resp = lpad(P_CODIGO_CONTRATO, 15, 0)
    AND tipo_contrato_resp = P_TIPO_CONTRATO
    AND codigo_empresa_contrato = P_CODIGO_EMPRESA
    AND dt_fim_responsabilidade IS NULL
    AND RESP.ID_PROCESSO=P_TIPO_PROCESSO
    AND SUB.ID IS NOT NULL
    AND SUB.DT_FIM_SUPERVISAO IS NULL
    )LOOP
   CONT:=CONT+1; 


SELECT MAX(id) + 1
                            INTO rhpbh_pessoa_resp_supervisao.id
                            FROM arterh.rhuser_pessoa_resp_supervisao;

                          
                            rhpbh_pessoa_resp_supervisao.id_rhuser_pessoa_responsavel := NEW_ID_GESTOR;
                            rhpbh_pessoa_resp_supervisao.codigo_empresa_subordinado := C1.codigo_empresa_subordinado;
                            rhpbh_pessoa_resp_supervisao.codigo_contrato_subordinado := C1.codigo_contrato_subordinado;
                            rhpbh_pessoa_resp_supervisao.codigo_pessoa_subordinado := C1.codigo_pessoa_subordinado;
                            rhpbh_pessoa_resp_supervisao.tipo_contrato_subordinado := C1.tipo_contrato_subordinado;
                            rhpbh_pessoa_resp_supervisao.codigo_empresa_ctr_subordinado := C1.codigo_empresa_ctr_subordinado;
                            rhpbh_pessoa_resp_supervisao.codigo_empresa := C1.codigo_empresa;
                            rhpbh_pessoa_resp_supervisao.created := sysdate;
                            rhpbh_pessoa_resp_supervisao.createdby := LOGIN_USUARIO;
                            rhpbh_pessoa_resp_supervisao.updated := sysdate;
                            rhpbh_pessoa_resp_supervisao.updatedby := LOGIN_USUARIO;
                            rhpbh_pessoa_resp_supervisao.dt_inicio_supervisao := sysdate+1;
                            rhpbh_pessoa_resp_supervisao.nome_composto := C1.nome_composto;
                            incluir_subordinado(rhpbh_pessoa_resp_supervisao);
  UPDATE arterh.rhuser_pessoa_resp_supervisao
        SET dt_fim_supervisao = sysdate,
            updated = sysdate,
            updatedby = LOGIN_USUARIO
        WHERE id = c1.id;

        UPDATE arterh.rhuser_pessoa_responsavel
        SET dt_fim_responsabilidade = sysdate,
            updated = sysdate,
            updatedby = LOGIN_USUARIO
        WHERE id = c1.id_rhuser_pessoa_responsavel
        and dt_fim_responsabilidade is null;




    END LOOP;
    END;