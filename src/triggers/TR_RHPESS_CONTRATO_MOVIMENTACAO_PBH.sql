
  CREATE OR REPLACE EDITIONABLE TRIGGER "ARTERH"."TR_RHPESS_CONTRATO_MOVIMENTACAO_PBH" 
FOR UPDATE OR INSERT OF DT_ULT_ALTER_USUA ON "ARTERH"."RHPESS_CONTRATO"

FOLLOWS ARTERH.TR_RHPESS_CONTRATO_AUDIT
COMPOUND TRIGGER


   TYPE id_contrato IS RECORD (
      CODIGO_EMPRESA  RHPESS_CONTRATO.CODIGO_EMPRESA%TYPE
    , CODIGO          RHPESS_CONTRATO.CODIGO%TYPE
    , TIPO_CONTRATO 	RHPESS_CONTRATO.TIPO_CONTRATO%TYPE
	, ANO_MES_REFERENCIA 	RHPESS_CONTRATO.ANO_MES_REFERENCIA%TYPE
	, COD_UNIDADE6_OLD 	RHPESS_CONTRATO.COD_UNIDADE6%TYPE
	, COD_UNIDADE6_NEW 	RHPESS_CONTRATO.COD_UNIDADE6%TYPE
	, COD_MOVIMENTACAO_NEW 	RHPESS_CONTRATO.COD_MOVIMENTACAO%TYPE
	, COD_MOVIMENTACAO_OLD RHPESS_CONTRATO.COD_MOVIMENTACAO%TYPE
	, DATA_TRANSF_ENTRAD RHPESS_CONTRATO.DATA_TRANSF_ENTRAD%TYPE

   );
   

   TYPE row_level_info_t IS TABLE OF id_contrato  INDEX BY PLS_INTEGER;
   g_row_level_info  row_level_info_t;
        
    vCount number;

   AFTER EACH ROW IS   
	
   BEGIN
	   
     g_row_level_info(g_row_level_info.COUNT + 1).CODIGO_EMPRESA := :NEW.CODIGO_EMPRESA;
     g_row_level_info(g_row_level_info.COUNT).CODIGO := :NEW.CODIGO;  
     g_row_level_info(g_row_level_info.COUNT).TIPO_CONTRATO := :NEW.TIPO_CONTRATO;
     g_row_level_info(g_row_level_info.COUNT).COD_MOVIMENTACAO_NEW := :NEW.COD_MOVIMENTACAO;  
     g_row_level_info(g_row_level_info.COUNT).COD_MOVIMENTACAO_OLD:= :OLD.COD_MOVIMENTACAO; 
     g_row_level_info(g_row_level_info.COUNT).ANO_MES_REFERENCIA := :NEW.ANO_MES_REFERENCIA;
     g_row_level_info(g_row_level_info.COUNT).COD_UNIDADE6_OLD := :OLD.COD_UNIDADE6;
     g_row_level_info(g_row_level_info.COUNT).COD_UNIDADE6_NEW := :NEW.COD_UNIDADE6;
    g_row_level_info(g_row_level_info.COUNT).DATA_TRANSF_ENTRAD :=:NEW.DATA_TRANSF_ENTRAD;
    
   END AFTER EACH ROW;

   AFTER STATEMENT IS 

   BEGIN
   
      FOR indx IN 1 .. g_row_level_info.COUNT

      LOOP
 
        INSERT INTO "ARTERH"."DEBUG_SQL_VALID_APOIO_ROBSON" (DEBUG_MSG,DT_ULT_ALTER_USUA) 
		VALUES ('TRIGGER CONTRATO_MOVIMENTAÇÃO CHAMADA - ' || g_row_level_info(indx).COD_UNIDADE6_OLD
		|| ' - ' || g_row_level_info(indx).COD_UNIDADE6_NEW,SYSDATE); 
        
        /*VERIFICAR SE EXISTE AJUSTE PENDENTE*/
        SELECT COUNT(1) into vCount FROM ARTERH.RHPESS_ALT_CONTRAT 
        where codigo_CONTRATO = g_row_level_info(indx).CODIGO
        and codigo_empresa =g_row_level_info(indx).CODIGO_EMPRESA
        AND DATA_ALTERACAO = g_row_level_info(indx).ANO_MES_REFERENCIA
        AND CONTEUDO_NOVO_DESC = 'ABERTO'
        AND CODIGO_ALTERACAO = 'M001'
        AND ROWNUM=1
        ORDER BY DATA_ALTERACAO DESC;
                
		if (vCount=1) then
        
            ARTERH.PR_ACERTOS_HIST_MOV_CONTRATO(
            g_row_level_info(indx).CODIGO, 
            g_row_level_info(indx).COD_MOVIMENTACAO_NEW, 
            TO_CHAR(g_row_level_info(indx).DATA_TRANSF_ENTRAD,'RRRRMMDD'), 
            g_row_level_info(indx).TIPO_CONTRATO, 
            g_row_level_info(indx).CODIGO_EMPRESA,
            'A',
            g_row_level_info(indx).ANO_MES_REFERENCIA ,'prcp1329446');
            
        else 
        
         INSERT INTO "ARTERH"."DEBUG_SQL_VALID_APOIO_ROBSON" (DEBUG_MSG,DT_ULT_ALTER_USUA) 
        	VALUES ('Sem registros com status ABERTO', sysdate);
        end if;
		
        --INSERT INTO "ARTERH"."DEBUG_SQL_VALID_APOIO_ROBSON" (DEBUG_MSG,DT_ULT_ALTER_USUA) 
		--		(SELECT 'AFTER LOOP ' || COD_LOCAL6, SYSDATE FROM RHPESS_CONTRATO C 
		--		WHERE C.CODIGO_EMPRESA = g_row_level_info(indx).CODIGO_EMPRESA
		--		AND C.TIPO_CONTRATO = g_row_level_info(indx).TIPO_CONTRATO
		--		AND C.ANO_MES_REFERENCIA = g_row_level_info(indx).ANO_MES_REFERENCIA );
        
      END LOOP;

 END AFTER STATEMENT;   


END TR_RHPESS_CONTRATO_MOVIMENTACAO_PBH;


--ALTER TRIGGER ARTERH.TR_RHPESS_CONTRATO_MOVIMENTACAO_PBH COMPILE


ALTER TRIGGER "ARTERH"."TR_RHPESS_CONTRATO_MOVIMENTACAO_PBH" ENABLE