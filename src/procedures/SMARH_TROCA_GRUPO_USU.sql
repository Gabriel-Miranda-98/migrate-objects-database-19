
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."SMARH_TROCA_GRUPO_USU" (ListaDeLogins IN VARCHAR2, ListaDeGrupos IN VARCHAR2, SistemaFechadoLancamento IN CHAR DEFAULT 'S')
as
vCodigoVinculo Varchar2(4);
vCodigoCargoEfetivo Varchar2(15);
vDescricaoVinculo Varchar2(4000);
vDescricaoCarreira Varchar2(4000);
vComplementoCarreira Varchar2(4000);
VERF NUMBER := 0;

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

begin

     dbms_output.put_line('TESTE');
     /* CAPTURANDO LISTA DE USUARIOS */
     l_string := ListaDeLogins || delimitador;

      LOOP EXIT WHEN l_string IS NULL;
           cont := INSTR (l_string, delimitador);
          -- dbms_output.put_line(LTRIM (RTRIM (SUBSTR (l_string, 1, cont - 1))));

          SELECT COUNT (1) INTO VERF from RHUSER_P_SIST where CODIGO_USUARIO = (LTRIM (RTRIM (SUBSTR (l_string, 1, cont - 1)))) AND STATUS_USUARIO = 'A';

           IF (VERF = 1 ) THEN
             l_dados_usuarios.EXTEND;
             l_dados_usuarios (l_dados_usuarios.COUNT) := LTRIM (RTRIM (SUBSTR (l_string, 1, cont - 1)));
             l_string := SUBSTR (l_string, cont + 1);
           ELSE
           l_string := SUBSTR (l_string, cont + 1);
           END IF;

      END LOOP;

     /* CAPTURANDO LISTA DE GRUPOS */
     l_string := ListaDeGrupos || delimitador;

      LOOP EXIT WHEN l_string IS NULL;
           cont := INSTR (l_string, delimitador);

           l_dados_grupos.EXTEND;
           l_dados_grupos (l_dados_grupos.COUNT) := LTRIM (RTRIM (SUBSTR (l_string, 1, cont - 1)));


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

      /* IMPRIMINDO LISTA DE GRUPOS */
      FOR Lcntr IN 1..l_dados_grupos.count
      LOOP
         --dbms_output.put_line(l_dados_grupos(Lcntr));
         select count(1) into cont from RHUSER_GRUPO where CODIGO = l_dados_grupos(Lcntr);
         IF (cont = 0) THEN
            --dbms_output.put_line('Não existe');
            raise_application_error (-20002,'Grupo de Grupo Inválido');
         END IF;

      END LOOP;

      vCODIGO_GRUPO_DEFAULT := l_dados_grupos(1);

      select SQ_SMARH_TROCA_GRUPO.NEXTVAL into vCODIGO_TROCA_GRUPO from dual;

      insert into SMARH_TROCA_GRUPO (ID_TROCA_GRUPO, DT_TROCA_GRUPO) values (vCODIGO_TROCA_GRUPO, sysdate);

      FOR Lcntr IN 1..l_dados_grupos.count
      LOOP
         vCODIGO_GRUPO := l_dados_grupos(Lcntr);
         insert into SMARH_TROCA_GRUPO_DESTINO (ID_TROCA_GRUPO, CODIGO_GRUPO) values (vCODIGO_TROCA_GRUPO, vCODIGO_GRUPO);
      END LOOP;

      FOR Lcntr IN 1..l_dados_usuarios.count
      LOOP
         vCODIGO_USUARIO := l_dados_usuarios(Lcntr);

         BEGIN
          IF SistemaFechadoLancamento = 'N' THEN
               BEGIN
                select PERMITE_INCLUSAO, PERMITE_ALTERACAO, PERMITE_EXCLUSAO, CODIGO_GRUPO, GRUPO_SEGURANCA
                 into vPERMITE_INCLUSAO,
                      vPERMITE_ALTERACAO,
                      vPERMITE_EXCLUSAO,
                      vCODIGO_GRUPO_ATUAL,
                      vCODIGO_GRUPO_SEGURANCA
                 from RHUSER_P_SIST
                where CODIGO_USUARIO = vCODIGO_USUARIO;
               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                      vPERMITE_INCLUSAO := 'N';
                      vPERMITE_ALTERACAO := 'N';
                      vPERMITE_EXCLUSAO := 'N';
                      vCODIGO_GRUPO_ATUAL := vCODIGO_GRUPO_GENERICO;
                      vCODIGO_GRUPO_SEGURANCA := vCODIGO_GRUPO_GENERICO;
               END;
          ELSE
               BEGIN
              select
                 CASE when c_livre_selec01 = '0' then 'N' else 'S' end PERMITE_INCLUSAO,
                 CASE when c_livre_selec02 = '0' then 'N' else 'S' end PERMITE_ALTERACAO,
                 CASE when c_livre_selec03 = '0' then 'N' else 'S' end PERMITE_EXCLUSAO,
                 CODIGO_GRUPO, GRUPO_SEGURANCA
                 into vPERMITE_INCLUSAO,
                      vPERMITE_ALTERACAO,
                      vPERMITE_EXCLUSAO,
                      vCODIGO_GRUPO_ATUAL,
                      vCODIGO_GRUPO_SEGURANCA
              from RHUSER_P_SIST
              where CODIGO_USUARIO = vCODIGO_USUARIO;
               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                      vPERMITE_INCLUSAO := 'N';
                      vPERMITE_ALTERACAO := 'N';
                      vPERMITE_EXCLUSAO := 'N';
                      vCODIGO_GRUPO_ATUAL := vCODIGO_GRUPO_GENERICO;
                      vCODIGO_GRUPO_SEGURANCA := vCODIGO_GRUPO_GENERICO;
               END;
           END IF;
         END;

         --dbms_output.put_line('vCODIGO_GRUPO_ATUAL:' || vCODIGO_GRUPO_ATUAL);
         --dbms_output.put_line('vCODIGO_GRUPO_SEGURANCA:' || vCODIGO_GRUPO_SEGURANCA);

         IF vCODIGO_GRUPO_ATUAL is null THEN
          vCODIGO_GRUPO_ATUAL := vCODIGO_GRUPO_GENERICO;
         END IF;

         IF vCODIGO_GRUPO_SEGURANCA is null THEN
          vCODIGO_GRUPO_SEGURANCA := vCODIGO_GRUPO_GENERICO;
         END IF;

         dbms_output.put_line('vCODIGO_GRUPO_ATUAL:' || vCODIGO_GRUPO_ATUAL);
         dbms_output.put_line('vCODIGO_GRUPO_SEGURANCA:' || vCODIGO_GRUPO_SEGURANCA);

         insert into SMARH_TROCA_GRUPO_USUARIO (ID_TROCA_GRUPO, CODIGO_USUARIO, STATUS, DT_TROCA_GRUPO_RETORNO,
         PERMITE_INCLUSAO, PERMITE_ALTERACAO, PERMITE_EXCLUSAO, CODIGO_GRUPO, CODIGO_GRUPO_SEGURANCA
         )
         values (vCODIGO_TROCA_GRUPO, vCODIGO_USUARIO, '1' , null,
                 vPERMITE_INCLUSAO,
                 vPERMITE_ALTERACAO,
                 vPERMITE_EXCLUSAO,
                 vCODIGO_GRUPO_ATUAL,
                 vCODIGO_GRUPO_SEGURANCA
                );

         insert into SMARH_TROCA_GRUPO_ORIGEM (ID_TROCA_GRUPO, CODIGO_USUARIO, CODIGO_GRUPO, LOGIN_USUARIO, DT_ULT_ALTER_USUA)
         select vCODIGO_TROCA_GRUPO AS ID_TROCA_GRUPO, CODIGO_USUARIO, CODIGO_GRUPO, LOGIN_USUARIO, DT_ULT_ALTER_USUA from RHUSER_RL_USR_GRP where CODIGO_USUARIO = vCODIGO_USUARIO;

      END LOOP;

      FOR Lcntr IN 1..l_dados_usuarios.count
      LOOP
         vCODIGO_USUARIO := l_dados_usuarios(Lcntr);
-- colocar owner
         delete from RHUSER_RL_USR_GRP where CODIGO_USUARIO = vCODIGO_USUARIO and codigo_grupo not in ( SELECT codigo FROM SIARTE_GRUPO_MENUGRUP where ativo = 'S' AND REGEXP_LIKE(CODIGO,'^[A-Za-z.]') group by codigo ) ;

          insert into RHUSER_RL_USR_GRP (CODIGO_USUARIO, CODIGO_GRUPO, LOGIN_USUARIO, DT_ULT_ALTER_USUA)
          select distinct
                 SMARH_TROCA_GRUPO_USUARIO.CODIGO_USUARIO,
                 SMARH_TROCA_GRUPO_DESTINO.CODIGO_GRUPO,
                 'admin' AS LOGIN_USUARIO,
                 sysdate AS DT_ULT_ALTER_USUA
           from SMARH_TROCA_GRUPO, SMARH_TROCA_GRUPO_USUARIO, SMARH_TROCA_GRUPO_DESTINO
           where SMARH_TROCA_GRUPO.ID_TROCA_GRUPO = SMARH_TROCA_GRUPO_DESTINO.ID_TROCA_GRUPO
             and SMARH_TROCA_GRUPO.ID_TROCA_GRUPO = SMARH_TROCA_GRUPO_USUARIO.ID_TROCA_GRUPO
             and SMARH_TROCA_GRUPO.ID_TROCA_GRUPO = vCODIGO_TROCA_GRUPO
             and SMARH_TROCA_GRUPO_USUARIO.CODIGO_USUARIO = vCODIGO_USUARIO
             and SMARH_TROCA_GRUPO_DESTINO.codigo_grupo not in ( SELECT codigo FROM SIARTE_GRUPO_MENUGRUP where ativo = 'S' AND REGEXP_LIKE(CODIGO,'^[A-Za-z.]') group by codigo );

          update RHUSER_P_SIST
          set PERMITE_INCLUSAO = 'S',
              PERMITE_ALTERACAO = 'S',
              PERMITE_EXCLUSAO = 'S',
              CODIGO_GRUPO = vCODIGO_GRUPO_DEFAULT,
              GRUPO_SEGURANCA = vCODIGO_GRUPO_DEFAULT
           where CODIGO_USUARIO = vCODIGO_USUARIO;

      END LOOP;

      commit;
end;