
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."SMARH_DESFAZ_TROCA_GRUPO_USU" (ListaDeLogins IN VARCHAR2, SistemaFechadoLancamento IN CHAR DEFAULT 'S')
as
vCodigoVinculo Varchar2(4);
vCodigoCargoEfetivo Varchar2(15);
vDescricaoVinculo Varchar2(4000);
vDescricaoCarreira Varchar2(4000);
vComplementoCarreira Varchar2(4000);

vComando_update varchar2(4000);
vNome_coluna varchar2(30);
l_string VARCHAR2(4000);
delimitador CHAR(1):=',';
cont number;
l_dados_usuarios lista:= lista ();
l_dados_grupos lista:= lista ();
vCODIGO_TROCA_GRUPO NUMBER(20);
vCODIGO_GRUPO VARCHAR2(4000);
vCODIGO_USUARIO VARCHAR2(4000);
vPERMITE_INCLUSAO CHAR(1);
vPERMITE_ALTERACAO CHAR(1);
vPERMITE_EXCLUSAO CHAR(1);
vCODIGO_GRUPO_ATUAL CHAR(4);
vCODIGO_GRUPO_SEGURANCA CHAR(4);
vCODIGO_GRUPO_GENERICO CHAR(4):= '.001';
vCODIGO_GRUPO_DEFAULT CHAR(4);

vcontador NUMBER;
vsid VARCHAR2(4000);
vserial VARCHAR2(4000);
vqtdesessao NUMBER;

begin

     /* CAPTURANDO LISTA DE USUARIOS */
     l_string := ListaDeLogins || delimitador;

      LOOP EXIT WHEN l_string IS NULL;
           cont := INSTR (l_string, delimitador);

           l_dados_usuarios.EXTEND;
           l_dados_usuarios (l_dados_usuarios.COUNT) := LTRIM (RTRIM (SUBSTR (l_string, 1, cont - 1)));

           l_string := SUBSTR (l_string, cont + 1);
      END LOOP;

      /* IMPRIMINDO LISTA DE USUARIOS */
      FOR Lcntr IN 1..l_dados_usuarios.count
      LOOP
         --dbms_output.put_line(l_dados_usuarios(Lcntr));
         select count(1) into cont from RHUSER_P_SIST where CODIGO_USUARIO = l_dados_usuarios(Lcntr);
         IF (cont = 0) THEN
            --dbms_output.put_line('Não existe');
            raise_application_error (-20002,'Login de Usuário Inválido');
         END IF;

      END LOOP;

      -- Início da transação
      BEGIN

     /*   FOR Lcntr IN 1..l_dados_usuarios.count
        LOOP
           vCODIGO_USUARIO := l_dados_usuarios(Lcntr);

           delete from RHUSER_RL_USR_GRP where CODIGO_USUARIO = vCODIGO_USUARIO
           and CODIGO_GRUPO in (select SMARH_TROCA_GRUPO_DESTINO.CODIGO_GRUPO
                                  from SMARH_TROCA_GRUPO_DESTINO, SMARH_TROCA_GRUPO_USUARIO
                                 where SMARH_TROCA_GRUPO_USUARIO.ID_TROCA_GRUPO = SMARH_TROCA_GRUPO_DESTINO.ID_TROCA_GRUPO
                                   and SMARH_TROCA_GRUPO_USUARIO.CODIGO_USUARIO = vCODIGO_USUARIO);

        END LOOP;
*/
        FOR Lcntr IN 1..l_dados_usuarios.count
        LOOP
           vCODIGO_USUARIO := l_dados_usuarios(Lcntr);

           select max(ID_TROCA_GRUPO) into vCODIGO_TROCA_GRUPO from SMARH_TROCA_GRUPO_USUARIO where SMARH_TROCA_GRUPO_USUARIO.CODIGO_USUARIO = vCODIGO_USUARIO and status = '1';

          if (vCODIGO_TROCA_GRUPO is not null) then

           delete from RHUSER_RL_USR_GRP where CODIGO_USUARIO = vCODIGO_USUARIO
           and CODIGO_GRUPO in (select SMARH_TROCA_GRUPO_DESTINO.CODIGO_GRUPO
                                  from SMARH_TROCA_GRUPO_DESTINO, SMARH_TROCA_GRUPO_USUARIO
                                 where SMARH_TROCA_GRUPO_USUARIO.ID_TROCA_GRUPO = SMARH_TROCA_GRUPO_DESTINO.ID_TROCA_GRUPO
                                   and SMARH_TROCA_GRUPO_USUARIO.CODIGO_USUARIO = vCODIGO_USUARIO);
            dbms_output.put_line('Passei 2');

            insert into RHUSER_RL_USR_GRP (CODIGO_USUARIO, CODIGO_GRUPO, LOGIN_USUARIO, DT_ULT_ALTER_USUA)
            select SMARH_TROCA_GRUPO_ORIGEM.CODIGO_USUARIO,
                   SMARH_TROCA_GRUPO_ORIGEM.CODIGO_GRUPO,
                   SMARH_TROCA_GRUPO_ORIGEM.LOGIN_USUARIO,
                   SMARH_TROCA_GRUPO_ORIGEM.DT_ULT_ALTER_USUA
             from SMARH_TROCA_GRUPO, SMARH_TROCA_GRUPO_ORIGEM
             where SMARH_TROCA_GRUPO.ID_TROCA_GRUPO = SMARH_TROCA_GRUPO_ORIGEM.ID_TROCA_GRUPO
               and SMARH_TROCA_GRUPO.ID_TROCA_GRUPO = vCODIGO_TROCA_GRUPO
               and CODIGO_USUARIO = vCODIGO_USUARIO
               and SMARH_TROCA_GRUPO_ORIGEM.CODIGO_GRUPO not in (select CODIGO_GRUPO from RHUSER_RL_USR_GRP where CODIGO_USUARIO = vCODIGO_USUARIO ) ;

            update SMARH_TROCA_GRUPO_USUARIO set STATUS = '0', DT_TROCA_GRUPO_RETORNO = sysdate
             where ID_TROCA_GRUPO = vCODIGO_TROCA_GRUPO
               and CODIGO_USUARIO = vCODIGO_USUARIO
               and STATUS = '1';
          end if;
             BEGIN


            select min(SMARH_TROCA_GRUPO_ORIGEM.CODIGO_GRUPO)
              into vCODIGO_GRUPO_DEFAULT
             from SMARH_TROCA_GRUPO, SMARH_TROCA_GRUPO_ORIGEM
             where SMARH_TROCA_GRUPO.ID_TROCA_GRUPO = SMARH_TROCA_GRUPO_ORIGEM.ID_TROCA_GRUPO
               and SMARH_TROCA_GRUPO.ID_TROCA_GRUPO = vCODIGO_TROCA_GRUPO
               and CODIGO_USUARIO = vCODIGO_USUARIO;

                --dbms_output.put_line('SistemaFechadoLancamento:' || SistemaFechadoLancamento);
             IF SistemaFechadoLancamento = 'N' THEN
                    BEGIN

                       select PERMITE_INCLUSAO, PERMITE_ALTERACAO, PERMITE_EXCLUSAO, CODIGO_GRUPO, CODIGO_GRUPO_SEGURANCA
                         into vPERMITE_INCLUSAO,
                              vPERMITE_ALTERACAO,
                              vPERMITE_EXCLUSAO,
                              vCODIGO_GRUPO_ATUAL,
                              vCODIGO_GRUPO_SEGURANCA
                         from SMARH_TROCA_GRUPO_USUARIO
                        where CODIGO_USUARIO = vCODIGO_USUARIO
                          and ID_TROCA_GRUPO = vCODIGO_TROCA_GRUPO;

                       EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                              vPERMITE_INCLUSAO := 'N';
                              vPERMITE_ALTERACAO := 'N';
                              vPERMITE_EXCLUSAO := 'N';
                              vCODIGO_GRUPO_ATUAL := vCODIGO_GRUPO_DEFAULT;
                              vCODIGO_GRUPO_SEGURANCA := vCODIGO_GRUPO_DEFAULT;
                       WHEN OTHERS THEN
                            raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);

                       END;
              ELSE
                  vPERMITE_INCLUSAO := 'N';
                  vPERMITE_ALTERACAO := 'N';
                  vPERMITE_EXCLUSAO := 'N';
                  vCODIGO_GRUPO_ATUAL := vCODIGO_GRUPO_DEFAULT;
                  vCODIGO_GRUPO_SEGURANCA := vCODIGO_GRUPO_DEFAULT;
              END IF;

                   --dbms_output.put_line('vPERMITE_INCLUSAO :' || vPERMITE_INCLUSAO);
                   --dbms_output.put_line('vPERMITE_ALTERACAO :' || vPERMITE_ALTERACAO);
                   --dbms_output.put_line('vPERMITE_EXCLUSAO :' || vPERMITE_EXCLUSAO);
                  if (vCODIGO_TROCA_GRUPO is not null)  THEN
                   update RHUSER_P_SIST
                        set PERMITE_INCLUSAO = vPERMITE_INCLUSAO,
                        PERMITE_ALTERACAO = vPERMITE_ALTERACAO,
                        PERMITE_EXCLUSAO = vPERMITE_EXCLUSAO,
                        CODIGO_GRUPO = vCODIGO_GRUPO_ATUAL,
                        GRUPO_SEGURANCA = vCODIGO_GRUPO_SEGURANCA
                        where CODIGO_USUARIO = vCODIGO_USUARIO;
                END IF;
            
             EXCEPTION
             WHEN OTHERS THEN
                    raise_application_error (-20002,'Ocorreu um erro ao tentar atualizar dados do usuário.');
             END;
        END LOOP;


        commit;
        -- Fim da transação
      EXCEPTION
      WHEN OTHERS THEN
           raise_application_error (-20001,'Ocorreu um erro ao tentar desfazer a troca de grupos de usuários.');

END;
end;