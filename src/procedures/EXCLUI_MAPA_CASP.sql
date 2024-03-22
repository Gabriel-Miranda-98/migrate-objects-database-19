
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."EXCLUI_MAPA_CASP" (ano IN char, mes IN char, tp_folha IN char, ch_acesso IN varchar)
IS
    TYPE cursor_mapa IS REF CURSOR;
    mapas1 cursor_mapa;
    
    vaux1 number;
    vaux2 varchar(2000);
    vchave varchar(2000);
    vsql long;   
    vmapa varchar(4000);   
    verro varchar(4000);
   
BEGIN 
/*
  DBMS_OUTPUT.PUT_LINE(ano);
  DBMS_OUTPUT.PUT_LINE(lpad(mes,2,'0'));
  DBMS_OUTPUT.PUT_LINE(lpad(tp_folha,2,'0'));
  DBMS_OUTPUT.PUT_LINE(ch_acesso);
*/

  vaux1 := (ano * 10000) + (mes * 100) + tp_folha;
  vaux2 := to_char(vaux1) || '%''';
  vchave := lower(trim(ch_acesso)); 
  --DBMS_OUTPUT.PUT_LINE(vaux2);     
     
  vsql := 'SELECT NUMERO_MAPA mapa 
           FROM CASP.VW_INTEROPERABILIDADE_ARTERH@LK_arterh_CASP.PBH  
           WHERE NUMERO_MAPA like '''||vaux2;
  vsql := vsql || ' AND TRIM(CHAVE_ACESSO) = '''||vchave; 
  vsql := vsql || ''' GROUP BY NUMERO_MAPA';       
  --DBMS_OUTPUT.PUT_LINE(vsql);

  verro := '';
  
  OPEN mapas1 FOR vsql;

    LOOP
       FETCH mapas1 INTO vmapa;
       
       EXIT WHEN mapas1%NOTFOUND; 
/*           
       -- TRECHO PARA AVALIAÇÃO APENAS 
       IF vmapa = 201504010000026 THEN
          DBMS_OUTPUT.PUT_LINE('mapa: '||vmapa);
          --DBMS_OUTPUT.PUT_LINE('chave: '||ch_acesso);
          DBMS_OUTPUT.PUT_LINE('chave: '||vchave);
          DBMS_OUTPUT.PUT_LINE('erro: '||verro);
          DBMS_OUTPUT.PUT_LINE('qtde: '||mapas1%rowcount);
          CASP.SP_EXCLUIR_MAPA_ARTERH@LK_ARTERH_CASP.PBH(vmapa,vchave,verro);
          EXIT;
       END IF;  
       -- FIM TRECHO AVALIAÇÃO
 */     
       CASP.SP_EXCLUIR_MAPA_ARTERH@LK_ARTERH_CASP.PBH(vmapa,vchave,verro);
  
    END LOOP;   
 
  CLOSE mapas1;
  
END;
 