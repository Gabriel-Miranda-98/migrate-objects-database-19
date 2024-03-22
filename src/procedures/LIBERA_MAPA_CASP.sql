
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."LIBERA_MAPA_CASP" (ano IN char, mes IN char, tp_folha IN char, ch_acesso IN varchar, cod_empresa IN varchar)
IS
    TYPE cursor_mapa IS REF CURSOR;
    mapas2 cursor_mapa;

    vaux1 number;
    vaux2 varchar(2000);
    vchave varchar(2000);
    vsql long;
    vmapa varchar(4000);
    verro varchar(4000);

BEGIN

  vaux1 := (ano * 10000) + (mes * 100) + tp_folha;
  vaux2 := to_char(vaux1) || '%''';
  vchave := lower(trim(ch_acesso));
  --DBMS_OUTPUT.PUT_LINE(vaux2);

  if cod_empresa = '0001' then
    vsql := 'SELECT numero_mapa mapa
             FROM casp.vw_interoperabilidade_arterh@LK_arterh_CASP.PBH
             where ano_ref_apropriacao_mapa = ''' || trim(ano) || ''' AND ';
    vsql := vsql || ' num_mes_ref_apropriacao_mapa = lpad(''' || trim(mes) || ''', 2, ''0'' ) ';
    vsql := vsql || ' AND TRIM(CHAVE_ACESSO) = '''||trim(vchave) || '''';
    vsql := vsql || ' AND ( substr(numero_mapa, 9, 3) in (''201'', ''210'', ''216'') ';
    vsql := vsql || ' or ( substr(numero_mapa, 9, 3) in (''235'', ''236'') and cod_assunto_folha in (''R'') )) ';
    vsql := vsql || ' GROUP BY NUMERO_MAPA';
  else
    vsql := 'SELECT NUMERO_MAPA mapa
             FROM CASP.VW_INTEROPERABILIDADE_ARTERH@LK_arterh_CASP.PBH
             WHERE NUMERO_MAPA like '''||vaux2;
    vsql := vsql || ' AND TRIM(CHAVE_ACESSO) = '''||vchave;
    vsql := vsql || ''' GROUP BY NUMERO_MAPA';
  end if;

 DBMS_OUTPUT.PUT_LINE(vsql);

  verro := '';

  OPEN mapas2 FOR vsql;

    LOOP
       FETCH mapas2 INTO vmapa;

       EXIT WHEN mapas2%NOTFOUND;
/*
       -- TRECHO PARA AVALIAÇÃO APENAS
       IF vmapa = 201504010000010 THEN
          DBMS_OUTPUT.PUT_LINE('mapa: '||vmapa);
          --DBMS_OUTPUT.PUT_LINE('chave: '||ch_acesso);
          DBMS_OUTPUT.PUT_LINE('chave: '||vchave);
          DBMS_OUTPUT.PUT_LINE('erro: '||verro);
          DBMS_OUTPUT.PUT_LINE('qtde: '||mapas2%rowcount);
          CASP.SP_LIBERAR_MAPA_ARTERH@LK_ARTERH_CASP.PBH(vmapa,vchave,verro);
          EXIT;
       END IF;
       -- FIM TRECHO AVALIAÇÃO
 */

     --DBMS_OUTPUT.PUT_LINE('mapa: '||vmapa);

       CASP.SP_LIBERAR_MAPA_ARTERH@LK_ARTERH_CASP.PBH(vmapa,vchave,verro);

    END LOOP;

  CLOSE mapas2;

EXCEPTION
   WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);

END LIBERA_MAPA_CASP;