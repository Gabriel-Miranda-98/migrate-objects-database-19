
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_CRIAR_VALE_PLANTAO" (Pcodigo_empresa VARCHAR2,Ptipo_contrato VARCHAR2, Pdata_vale1 DATE,Pdata_vale2 DATE)
-- CRIADA POR LETICIA ROSA EM 13/07/2023
-- DEVE SER EXECUTADA NO FECHAMENTO DO SISTEMA
-- INICIO EM JULHO/2023 (VALE DE AGOSTO/2023)
-- EXECUTE ARTERH.PR_CRIAR_VALE_PLANTAO('0001','0001', '01/08/2023','31/08/2023');

AS
  JORNADA NUMBER;
  vdata_inicio date;
  vdata_fim date;
  vescala VARCHAR2(4 BYTE);
  vList arterh.TABLE_VALE := arterh.TABLE_VALE(null,null,null,null,null,null,null);
  ttList ARTERH.T_VALE := ARTERH.T_VALE ();
  vocor_horario NUMBER;
  ultima_semana NUMBER;
  DIAS NUMBER ;
  DIA_MES DATE;
  COLUNA VARCHAR2(15 BYTE);
  vID_EXECUCAO NUMBER;

FUNCTION PR_VERIFICA_EXTRA (pCODIGO_EMPRESA IN VARCHAR2, pTIPO_CONTRATO IN VARCHAR2, pCODIGO IN VARCHAR2 ,pDATA DATE )
RETURN NUMBER IS
QTD NUMBER:=NULL;
BEGIN
    SELECT COUNT(1) INTO QTD FROM RHVALE_DESLOCA WHERE CODIGO_EMPRESA = pCODIGO_EMPRESA AND TIPO_CONTRATO = pTIPO_CONTRATO AND CODIGO_CONTRATO = pCODIGO and DATA_INICIO = pDATA;
RETURN QTD ;

END;

FUNCTION PR_VERIFICA_EXTRA_CRIADO_POR_ROTINA (pCODIGO_EMPRESA IN VARCHAR2, pTIPO_CONTRATO IN VARCHAR2, pCODIGO IN VARCHAR2 ,pDATA DATE )
RETURN NUMBER IS
QTD NUMBER:=NULL;
BEGIN
    SELECT COUNT(1) INTO QTD FROM RHVALE_DESLOCA WHERE CODIGO_EMPRESA = pCODIGO_EMPRESA AND TIPO_CONTRATO = pTIPO_CONTRATO AND CODIGO_CONTRATO = pCODIGO and DATA_INICIO = pDATA
    AND C_LIVRE_DESCR03 = 'INSERIDO PELA ROTINA DE CRIA  O DE VALE';
RETURN QTD ;

END;

PROCEDURE PR_INSERE_VALE_DESLOCA (pCODIGO_EMPRESA IN VARCHAR2, pTIPO_CONTRATO IN VARCHAR2, pCODIGO IN VARCHAR2 ,pDATA_INICIO DATE, pDATA_FIM DATE) AS
BEGIN
    INSERT INTO RHVALE_DESLOCA (CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,DATA_INICIO,DATA_FIM,SEGUNDA,TERCA,QUARTA,QUINTA,SEXTA,SABADO,DOMINGO,LOGIN_USUARIO,DT_ULT_ALTER_USUA, C_LIVRE_DESCR03, OBSERVACAO) VALUES (pCODIGO_EMPRESA,pTIPO_CONTRATO,pCODIGO,pDATA_INICIO,pDATA_FIM,'N','N','N','N','N','N','N','PR_GERA_VR_PLANTAO_AUTO',sysdate,'INSERIDO PELA ROTINA DE CRIA  O DE VALE','OS REGISTROS DE PLANT O FORAM CRIADOS ANALISANDO A ESCALA DO SERVIDOR.  ');
END;

PROCEDURE PR_INSERE_RHVALE_RL_DESL_LIN (pCODIGO_EMPRESA IN VARCHAR2, pTIPO_CONTRATO IN VARCHAR2, pCODIGO IN VARCHAR2 ,pDATA_INICIO DATE, pDATA_FIM DATE, QTDE NUMBER) AS
BEGIN
    INSERT INTO ARTERH.RHVALE_RL_DESL_LIN (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA_INICIO, DATA_FIM, CODIGO_LINHA, CODIGO_ITINERARIO, QTDE_VALES) VALUES (pCODIGO_EMPRESA,pTIPO_CONTRATO,pCODIGO,pDATA_INICIO,pDATA_FIM,'000000000000142','0142',QTDE);

END;

BEGIN
JORNADA:=0;
vocor_horario := 0;
ultima_semana := 0;
DIAS :=(Pdata_vale2-Pdata_vale1);
DIA_MES:=NULL;
COLUNA:= '';
vID_EXECUCAO := ID_VALE_PLANTAO.NEXTVAL;
dbms_output.enable(NULL);

    FOR C1 IN
  (
select distinct VL.codigo_contrato codigo_contrato, vID_EXECUCAO ID_EXECUCAO
    from ARTERH.SMARH_INT_VALE VL
    LEFT OUTER JOIN ARTERH.SMARH_INT_DIA_EXECUCAO EX
    ON VL.ID_EXECUCAO      =EX.ID_EXECUCAO
    WHERE EX.DATA_EXECUCAO =    ( SELECT MAX(AUX.DATA_EXECUCAO) FROM arterh.SMARH_INT_DIA_EXECUCAO AUX )
    and VL.codigo_empresa= Pcodigo_empresa
    and VL.tipo_contrato= Ptipo_contrato
    and escala in  
     ( select distinct RHPONT_ESCALA.codigo AS CODIGO_ESCALA
       from RHPONT_ESCALA
       inner join RHPONT_RL_ESC_HOR
       on RHPONT_ESCALA.codigo = RHPONT_RL_ESC_HOR.codigo_escala 
       and RHPONT_ESCALA.CODIGO_EMPRESA = RHPONT_RL_ESC_HOR.CODIGO_EMPRESA 
       INNER JOIN RHPONT_HORARIO
        ON  RHPONT_RL_ESC_HOR.CODIGO_EMPRESA = RHPONT_HORARIO.CODIGO_EMPRESA
        AND RHPONT_RL_ESC_HOR.CODIGO_HORARIO        = RHPONT_HORARIO.CODIGO
       where RHPONT_ESCALA.CODIGO_EMPRESA = Pcodigo_empresa
       and RHPONT_HORARIO.JORNADA_DIARIA >= '1200'
       and RHPONT_ESCALA.data_extincao is null  )
       --and rownum <= 50
       -- and VL.codigo_contrato IN ( '000000000872826','000000000867873' )

  )
  loop
  select to_char( last_day(to_date(Pdata_vale1,'dd/mm/yyyy')) ,'W') into ultima_semana from dual;
         DBMS_Output.PUT_LINE( c1.codigo_contrato);

    FOR I IN 0..DIAS LOOP
    DIA_MES:=Pdata_vale1+I;

        begin
        select cod_escala into vescala from RHPONT_ALT_ESCALA where codigo_empresa = Pcodigo_empresa and tipo_contrato = Ptipo_contrato 
        and codigo_contrato = c1.codigo_contrato and 
        ( DIA_MES between dt_inicio_troca and dt_fim_troca  or  ( DIA_MES>= dt_inicio_troca and dt_fim_troca is null ) ) 
        AND DT_INICIO_TROCA =
            (SELECT MAX(AUX.DT_INICIO_TROCA)
            FROM RHPONT_ALT_ESCALA AUX
            WHERE AUX.CODIGO_EMPRESA    = RHPONT_ALT_ESCALA.CODIGO_EMPRESA
            AND AUX.TIPO_CONTRATO       = RHPONT_ALT_ESCALA.TIPO_CONTRATO
            AND AUX.CODIGO_CONTRATO     = RHPONT_ALT_ESCALA.CODIGO_CONTRATO
            AND DIA_MES>= AUX.dt_inicio_troca 
            );

        EXCEPTION
          -- Se o select n o retornar resultados, fa a o insert na tabela de log
          WHEN NO_DATA_FOUND THEN
            INSERT INTO ARTERH.SMARH_VALE_PLANTAO VALUES('SEM HIST RICO DE ESCALA',C1.ID_EXECUCAO,SYSDATE,Pcodigo_empresa,Ptipo_contrato,c1.codigo_contrato,null,null,null,null,null,null, null, null,null);
            DBMS_OUTPUT.PUT_LINE('Nenhum resultado encontrado na ESCALA.');
            EXIT;
        END;

        select count(1) into vocor_horario from RHPONT_RL_ESC_HOR where codigo_escala = vescala and codigo_empresa = Pcodigo_empresa;

        BEGIN
        SELECT REGEXP_REPLACE (lpad(TO_CHAR(trim (RHPONT_HORARIO.JORNADA_DIARIA)),4,'0'), '([0-9]{2})([0-9]{2})', '\1\2') AS carga_horaria INTO JORNADA FROM RHPONT_RL_ESC_HOR
         INNER JOIN RHPONT_HORARIO
         ON  RHPONT_RL_ESC_HOR.CODIGO_EMPRESA = RHPONT_HORARIO.CODIGO_EMPRESA
         AND RHPONT_RL_ESC_HOR.CODIGO_HORARIO        = RHPONT_HORARIO.CODIGO
         WHERE CODIGO_ESCALA = vescala 
         AND RHPONT_HORARIO.CODIGO_EMPRESA = Pcodigo_empresa
         AND OCORRENCIA = ( SELECT mod(to_date(DIA_MES)-to_date(ESCALA.DATA_BASE), ESCALA.OCORRENCIA )+1  FROM (
           SELECT RHPONT_ESCALA.DATA_BASE, RHPONT_RL_ESC_HOR.OCORRENCIA FROM RHPONT_ESCALA 
           INNER JOIN ( SELECT COUNT(1) AS OCORRENCIA, CODIGO_EMPRESA, CODIGO_ESCALA  FROM RHPONT_RL_ESC_HOR GROUP BY CODIGO_EMPRESA, CODIGO_ESCALA ) RHPONT_RL_ESC_HOR
           ON RHPONT_RL_ESC_HOR.CODIGO_EMPRESA = RHPONT_ESCALA.CODIGO_EMPRESA 
           AND RHPONT_RL_ESC_HOR.CODIGO_ESCALA = RHPONT_ESCALA.CODIGO
           WHERE RHPONT_ESCALA.CODIGO = vescala AND RHPONT_ESCALA.CODIGO_EMPRESA = Pcodigo_empresa) ESCALA )  ;
        EXCEPTION
          -- Se o select n o retornar resultados, fa a o insert na tabela de log
          WHEN NO_DATA_FOUND THEN
            INSERT INTO ARTERH.SMARH_VALE_PLANTAO VALUES('CADASTRO DO HOR RIO DA ESCALA '||vescala||' INCORRETO. EST  FALTANDO UMA OCORRENCIA' ,C1.ID_EXECUCAO,SYSDATE,Pcodigo_empresa,Ptipo_contrato,c1.codigo_contrato,DIA_MES,null,null,null,null,null, null, vescala,null);
            DBMS_OUTPUT.PUT_LINE('Nenhum resultado encontrado no HORARIO DE ESCALA.');
        END;
        if(JORNADA >= 1200) then
         DBMS_Output.PUT_LINE( DIA_MES||' '|| to_char(DIA_MES,'d')||' '|| to_char(DIA_MES,'dy')||' '||to_char(DIA_MES,'day')||' '|| to_char(DIA_MES,'W') || ' '|| vescala || ' '|| JORNADA);
          vList := ARTERH.TABLE_VALE(DIA_MES, to_char(DIA_MES,'d'), to_char(DIA_MES,'dy'), to_char(DIA_MES,'day'), to_char(DIA_MES,'W'),vescala,JORNADA );
          ttList.extend;
          ttList(ttList.count) :=  vList;
        end if;

    end loop;

       if ( vocor_horario = 7 ) then

            IF  ( ( PR_VERIFICA_EXTRA(Pcodigo_empresa,Ptipo_contrato,c1.codigo_contrato,Pdata_vale1) > 0
                AND PR_VERIFICA_EXTRA_CRIADO_POR_ROTINA (Pcodigo_empresa,Ptipo_contrato,c1.codigo_contrato,Pdata_vale1) > 0 )
                OR ( PR_VERIFICA_EXTRA(Pcodigo_empresa,Ptipo_contrato,c1.codigo_contrato,Pdata_vale1) = 0 ) ) THEN
                /* Verifica se j  existe um vale extra  na tabela com a data de inicio, ( primeiro dia do mes ), 
                se existir ele executa as instru  es abaixo apenas se esse registro tiver sido inserido pela l gica. Caso contr rio n o faz NADA*/

                IF PR_VERIFICA_EXTRA_CRIADO_POR_ROTINA (Pcodigo_empresa,Ptipo_contrato,c1.codigo_contrato,Pdata_vale1) = 0 THEN
                        dbms_output.put_line('Insert de :' || Pdata_vale1||' at  :'|| Pdata_vale1 );  
                    PR_INSERE_VALE_DESLOCA(Pcodigo_empresa,Ptipo_contrato,c1.codigo_contrato,Pdata_vale1,Pdata_vale2);
                    IF (JORNADA < 2400) THEN
                        PR_INSERE_RHVALE_RL_DESL_LIN (Pcodigo_empresa,Ptipo_contrato,c1.codigo_contrato,Pdata_vale1,Pdata_vale2,1) ;
                    ELSIF (JORNADA >= 2399) THEN
                        PR_INSERE_RHVALE_RL_DESL_LIN (Pcodigo_empresa,Ptipo_contrato,c1.codigo_contrato,Pdata_vale1,Pdata_vale2,4) ;
                    END IF;
                END IF;   

                for i in 1.. ttList.count/ultima_semana
                loop
                    dbms_output.put_line('Fazer update no dia da semana 2' ||upper(ttList(i).abreviacao));
                    SELECT DECODE(ttList(i).DIA_SEMANA, 1, 'DOMINGO', 2, 'SEGUNDA', 3, 'TERCA', 4, 'QUARTA', 5, 'QUINTA', 6 , 'SEXTA', 7, 'SABADO') INTO COLUNA FROM DUAL;
                    EXECUTE IMMEDIATE('UPDATE arterh.RHVALE_DESLOCA SET ' || COLUNA || ' = ''S'', LOGIN_USUARIO = ''PR_GERA_VR_PLANTAO_AUTO'', DT_ULT_ALTER_USUA = SYSDATE WHERE CODIGO_EMPRESA = '''|| Pcodigo_empresa|| ''' AND TIPO_CONTRATO = '''||Ptipo_contrato|| ''' AND CODIGO_CONTRATO = '''||c1.codigo_contrato || '''and DATA_INICIO =  to_date('''||Pdata_vale1|| ''',''DD/MM/YYYY'')');

                end loop;

                for i in 1.. ttList.count
                loop
                        UPDATE arterh.RHVALE_DESLOCA SET OBSERVACAO = OBSERVACAO || CHR(10) ||' DATA: ' ||ttList(i).DATA ||' ESCALA: ' || ttList(i).ESCALA ||' JORNADA: ' ||ttList(i).JORNADA WHERE CODIGO_EMPRESA =  Pcodigo_empresa AND TIPO_CONTRATO = Ptipo_contrato AND CODIGO_CONTRATO = c1.codigo_contrato and DATA_INICIO =  to_date(Pdata_vale1,'DD/MM/YYYY');      
                end loop;


             ELSE
                 --VARRE O ARRAY E INSERIR AS INFORMA  ES EM UMA TABELA DE "LOG" PARA OS REGISTROS NAO CRIADOS POR MES
                dbms_output.put_line('Insert de :' || Pdata_vale1||' at  :'|| Pdata_vale2);

                for i in 1.. ttList.count
                loop

                   INSERT INTO ARTERH.SMARH_VALE_PLANTAO VALUES('J  EXISTE UM VALE EXTRA NA DATA DE INICIO',C1.ID_EXECUCAO,SYSDATE,Pcodigo_empresa,Ptipo_contrato,c1.codigo_contrato,ttList(i).DATA,ttList(i).DIA_SEMANA,ttList(i).ABREV,ttList(i).ABREVIACAO,ttList(i).SEMANA,Pdata_vale1, Pdata_vale2, ttList(i).ESCALA,ttList(i).JORNADA);

                end loop;   

            END IF;
       elsif ( vocor_horario > 7 ) then
       vdata_inicio:= Pdata_vale1;
       vdata_fim:=Pdata_vale1+ 6;
           for s in 1.. ultima_semana
                loop  

                IF  ( ( PR_VERIFICA_EXTRA(Pcodigo_empresa,Ptipo_contrato,c1.codigo_contrato,vdata_inicio) > 0
                AND PR_VERIFICA_EXTRA_CRIADO_POR_ROTINA (Pcodigo_empresa,Ptipo_contrato,c1.codigo_contrato,vdata_inicio) > 0 )
                OR ( PR_VERIFICA_EXTRA(Pcodigo_empresa,Ptipo_contrato,c1.codigo_contrato,vdata_inicio) = 0 ) ) THEN
                /* Verifica se j  existe um vale extra na tabela com a data de inicio, ( primeiro dia do mes ), 
                se existir ele executa as instru  es abaixo apenas se esse registro tiver sido inserido pela l gica. Caso contr rio n o faz NADA*/

                        IF PR_VERIFICA_EXTRA_CRIADO_POR_ROTINA (Pcodigo_empresa,Ptipo_contrato,c1.codigo_contrato,vdata_inicio) = 0 THEN
                        dbms_output.put_line('Insert de :' || vdata_inicio||' at  :'|| vdata_fim );  
                            PR_INSERE_VALE_DESLOCA(Pcodigo_empresa,Ptipo_contrato,c1.codigo_contrato,vdata_inicio,vdata_fim);                        
                            IF (JORNADA < 2400) THEN
                                PR_INSERE_RHVALE_RL_DESL_LIN (Pcodigo_empresa,Ptipo_contrato,c1.codigo_contrato,vdata_inicio,vdata_fim,1) ;
                            ELSIF (JORNADA >= 2399) THEN
                                PR_INSERE_RHVALE_RL_DESL_LIN (Pcodigo_empresa,Ptipo_contrato,c1.codigo_contrato,vdata_inicio,vdata_fim,4) ;
                            END IF;
                        END IF;

                        for i in 1.. ttList.count
                            loop
                                if (ttList(i).SEMANA = s) then
                                    dbms_output.put_line('Fazer update no dia da semana 1 ' ||upper(ttList(i).abreviacao));
                                    SELECT DECODE(ttList(i).DIA_SEMANA, 1, 'DOMINGO', 2, 'SEGUNDA', 3, 'TERCA', 4, 'QUARTA', 5, 'QUINTA', 6 , 'SEXTA', 7, 'SABADO') INTO COLUNA FROM DUAL;
                                    EXECUTE IMMEDIATE('UPDATE arterh.RHVALE_DESLOCA SET ' || COLUNA || ' = ''S'', LOGIN_USUARIO = ''PR_GERA_VR_PLANTAO_AUTO'', DT_ULT_ALTER_USUA = SYSDATE WHERE CODIGO_EMPRESA = '''|| Pcodigo_empresa|| ''' AND TIPO_CONTRATO = '''||Ptipo_contrato|| ''' AND CODIGO_CONTRATO = '''||c1.codigo_contrato || ''' and DATA_INICIO =  to_date('''||vdata_inicio|| ''',''DD/MM/YYYY'')');

                                end if;
                             end loop;

                        for i in 1.. ttList.count
                        loop 
                            if (ttList(i).SEMANA = s) then
                                UPDATE arterh.RHVALE_DESLOCA SET OBSERVACAO = OBSERVACAO || CHR(10) ||'DATA: ' ||ttList(i).DATA ||' ESCALA: ' || ttList(i).ESCALA ||' JORNADA: ' ||ttList(i).JORNADA WHERE CODIGO_EMPRESA =  Pcodigo_empresa AND TIPO_CONTRATO = Ptipo_contrato AND CODIGO_CONTRATO = c1.codigo_contrato and DATA_INICIO =  to_date(vdata_inicio,'DD/MM/YYYY');      
                            end if;
                        end loop;

                ELSE

            --VARRE O ARRAY E INSERIR AS INFORMA  ES EM UMA TABELA DE "LOG" PARA OS REGISTROS NAO CRIADOS. NESSE CASO VAI SER POR SEMANA
                    for i in 1.. ttList.count
                            loop
                                if (ttList(i).SEMANA = s) then
                                 INSERT INTO ARTERH.SMARH_VALE_PLANTAO VALUES('J  EXISTE UM VALE EXTRA NA DATA DE INICIO',C1.ID_EXECUCAO,SYSDATE,Pcodigo_empresa,Ptipo_contrato,c1.codigo_contrato,ttList(i).DATA,ttList(i).DIA_SEMANA,ttList(i).ABREV,ttList(i).ABREVIACAO,ttList(i).SEMANA,vdata_inicio, vdata_fim, ttList(i).ESCALA,ttList(i).JORNADA);
                                end if;
                             end loop;

                END IF;
                vdata_inicio:= vdata_fim+1;
                vdata_fim:= case when vdata_fim+7 > Pdata_vale2 then Pdata_vale2 else vdata_fim+7 end ;
           end loop;
       end if;

       ttList.DELETE;

  END LOOP;-- FIM LOOP FOR C1
  END;