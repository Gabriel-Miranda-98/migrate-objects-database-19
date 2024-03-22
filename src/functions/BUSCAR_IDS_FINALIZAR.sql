
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."BUSCAR_IDS_FINALIZAR" (P_CODIGO_EMPRESA IN CHAR, P_TIPO_CONTRATO IN CHAR, P_CODIGO_CONTRATO IN VARCHAR) RETURN TYPE_FINALIZAR_DELEGACAO_GESTOR IS
 CURSOR ids
    IS
      SELECT id
      FROM	
			arterh.rhuser_pessoa_responsavel
		WHERE
			codigo_empresa = P_CODIGO_EMPRESA
			AND codigo_contrato_resp = lpad(P_CODIGO_CONTRATO, 15, 0)
			AND tipo_contrato_resp = P_TIPO_CONTRATO
   AND dt_fim_responsabilidade IS NULL
			AND id_processo IN ( '2' );
V TYPE_FINALIZAR_DELEGACAO_GESTOR;
TAMNHO_LISTA NUMBER:=0;
I PLS_INTEGER;
V_IDS NUMBER(10,0);


BEGIN 
 I:=1;
V:=TYPE_FINALIZAR_DELEGACAO_GESTOR('N',LISTA());
 SELECT COUNT(1) INTO TAMNHO_LISTA
      FROM	
			arterh.rhuser_pessoa_responsavel
		WHERE
			codigo_empresa = P_CODIGO_EMPRESA
			AND codigo_contrato_resp = lpad(P_CODIGO_CONTRATO, 15, 0)
			AND tipo_contrato_resp = P_TIPO_CONTRATO
   AND dt_fim_responsabilidade IS NULL
			AND id_processo IN ( '2' ); 


IF(TAMNHO_LISTA>0) THEN 
V.E_GESTOR:='S';
V.IDS.EXTEND(TAMNHO_LISTA);

 OPEN ids;
    LOOP
      FETCH ids
      INTO V_IDS;
      EXIT
    WHEN ids%notfound;
      V.IDS(I) := V_IDS;
      I    := I+1;
  DBMS_Output.PUT_LINE(V_IDS);

    END LOOP;
    CLOSE ids;


END IF;
 RETURN v;



END;