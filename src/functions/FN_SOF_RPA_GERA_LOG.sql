
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."FN_SOF_RPA_GERA_LOG" (
	v_CODIGO_EMPRESA IN char,
	v_TIPO_CONTRATO IN char, 
	v_CODIGO_CONTRATO IN VARCHAR,
	v_MES_REF IN char,
	v_ANO_REF IN char,
    v_CPF IN number,
    v_DATA_REG timestamp :=SYSDATE,
    v_ACAO_REG IN varchar,
    v_DESCRICAO_REG in varchar,
	v_STATUS IN NUMBER
	)
	RETURN NUMBER
		IS total_reg NUMBER :=1;
	BEGIN
    	BEGIN
	    	INSERT INTO arterh.TB_SOF_RPA_LOG 
	        (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, MES_REF, ANO_REF, CPF, DATA_REG, ACAO_REG, DESCRICAO_REG, STATUS)
	        VALUES (v_CODIGO_EMPRESA,v_TIPO_CONTRATO, v_CODIGO_CONTRATO,v_MES_REF,v_ANO_REF,v_CPF,v_DATA_REG, v_ACAO_REG,v_DESCRICAO_REG ,v_STATUS);
				EXCEPTION          
		     	WHEN OTHERS THEN
		    	 DBMS_Output.Put_Line('ERRO AO REGISTRAR O LOG DA AÇÃO'); --this exception not handled
		        -- RAISE;
		    	 total_reg:=0;
	    END;
    	 
		RETURN total_reg;
	END;