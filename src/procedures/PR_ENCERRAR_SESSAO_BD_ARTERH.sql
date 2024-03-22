
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_ENCERRAR_SESSAO_BD_ARTERH" (ListaDeLoginsExcecao IN VARCHAR2 DEFAULT NULL, ListaDeLoginsEspecifica IN VARCHAR2 DEFAULT NULL)
as

l_string VARCHAR2(4000);
delimitador CHAR(1):=',';
cont number;
l_lista_logins_excecao lista := lista ();
l_lista_logins_especificos lista := lista ();
vsid VARCHAR2(4000);
vserial VARCHAR2(4000);

begin

     /* CAPTURANDO LISTA DE USUARIOS DE EXCECAO, QUE NAO TERAO AS SESSOES DE BANCO DE DADOS DO ARTERH ENCERRADAS */
     IF ListaDeLoginsExcecao IS NOT NULL THEN

       l_string := ListaDeLoginsExcecao || delimitador;

        LOOP EXIT WHEN l_string IS NULL;
             cont := INSTR (l_string, delimitador);

             l_lista_logins_excecao.EXTEND;
             l_lista_logins_excecao (l_lista_logins_excecao.COUNT) := LTRIM (RTRIM (SUBSTR (l_string, 1, cont - 1)));


             l_string := SUBSTR (l_string, cont + 1);
        END LOOP;

     END IF;


     /* CAPTURANDO LISTA DE USUARIOS ESPECIFICOS, QUE TERAO AS SESSOES DE BANCO DE DADOS DO ARTERH ENCERRADAS */
     IF ListaDeLoginsEspecifica IS NOT NULL THEN
       l_string := ListaDeLoginsEspecifica || delimitador;

        LOOP EXIT WHEN l_string IS NULL;
             cont := INSTR (l_string, delimitador);

             l_lista_logins_especificos.EXTEND;
             l_lista_logins_especificos (l_lista_logins_especificos.COUNT) := LTRIM (RTRIM (SUBSTR (l_string, 1, cont - 1)));


             l_string := SUBSTR (l_string, cont + 1);
        END LOOP;
      END IF;

      /* 
      No procedimento de encerramento de sessões definido nesta procedure, são consideradas apenas 
      as sessões cujo módulo/programa pelo qual a sessão foi criada seja aplicativos do ARTERH (like 'rh%.exe').
      Este procedimento é executado para garantir que o processamento de Folha inicie com usuários 
      sem a permissão de fazer lançamentos. Este procedimento é parte da atividade de "Fechamento do sistema",
      e deve ser executado após a retirada das permissões "PERMITE_INCLUSAO", "PERMITE_ALTERACAO" e "PERMITE_EXCLUSAO"


      Se a lista de logins especificos for maior que zero,
      serão encerradas todas as sessões de banco de dados associadas à lista de usuários de sistema operacional especificada,
      exceto, aqueles usuários contidos na lista de exceção.

       */  
      IF l_lista_logins_especificos.COUNT > 0 THEN
         /*dbms_output.put_line('ENCERRAMENTO SESSÃO LOGINS ESPECIFICOS...');*/
      for c1 in(
        select s.program, sid, serial#, user#, username, status, osuser
          from v$session s 
         where module like 'rh%.exe' 
           and osuser member (l_lista_logins_especificos)      
           and osuser not member (l_lista_logins_excecao) 
      )
         loop
              /*dbms_output.put_line('INFO SESSÃO = ' || '''' || C1.SID || ',' || C1.serial# || ''''
                                                            || ',' || C1.program || ''''
                                                            || ',' || C1.user# || ''''
                                                            || ',' || C1.username || ''''
                                                            || ',' || C1.status || ''''
                                                            || ',' || C1.osuser || ''''
                                  );*/
              vsid := C1.SID;
              vserial := C1.serial#;   
          BEGIN
               /*dbms_output.put_line('COMANDO MATAR SESSÃO = ' || '''' || vsid || ',' || vserial || '''');*/
               SYS.KILL_SESSION(vsid,vserial); 
          EXCEPTION
          WHEN OTHERS THEN
               NULL;
               /*dbms_output.put_line('ERRO AO TENTAR MATAR SESSÃO = ' || '''' || vsid || ',' || vserial || '''');*/
          END;
         end loop;  

      ELSE
      /* 

      Se a lista de logins especificos não for maior que zero,
      serão encerradas todas as sessões de banco de dados,
      exceto, aqueles usuários contidos na lista de exceção.

       */        
          /*dbms_output.put_line('ENCERRAMENTO SESSÃO LOGINS GERAL...');*/
      for c1 in(
      select s.program, sid, serial#, user#, username, status, osuser
        from v$session s 
       where module like 'rh%.exe' 
         and osuser not member (l_lista_logins_excecao)    
      )
         loop
              /*dbms_output.put_line('INFO SESSÃO = ' || '''' || C1.SID || ',' || C1.serial# || ''''
                                                            || ',' || C1.program || ''''
                                                            || ',' || C1.user# || ''''
                                                            || ',' || C1.username || ''''
                                                            || ',' || C1.status || ''''
                                                            || ',' || C1.osuser || ''''
                                  );*/
              vsid := C1.SID;
              vserial := C1.serial#;   
          BEGIN
               /*dbms_output.put_line('COMANDO MATAR SESSÃO = ' || '''' || vsid || ',' || vserial || '''');*/
               SYS.KILL_SESSION(vsid,vserial); 
          EXCEPTION
          WHEN OTHERS THEN
               NULL;
               /*dbms_output.put_line('ERRO AO TENTAR MATAR SESSÃO = ' || '''' || vsid || ',' || vserial || '''');*/
          END;
         end loop;                
      END IF;



end;