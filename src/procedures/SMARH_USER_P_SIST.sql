
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."SMARH_USER_P_SIST" (vEMPRESA_USUARIO_NEW IN VARCHAR, vCONTRATO_USUARIO_NEW IN VARCHAR, vTP_CONTR_USUARIO_NEW IN VARCHAR,vCODIGO_USUARIO_NEW IN VARCHAR,vSTATUS_USUARIO_NEW IN CHAR, vCODIGO_SGBD_PADRAO_NEW IN CHAR) AS

BEGIN
 DECLARE
    vCGC      VARCHAR2(20);
    vERRO     VARCHAR2(2000);
    VVINCULO  VARCHAR(4);
    VGUARDA   CHAR(1);
    vVERIFICAUSUARIOEXTRA VARCHAR2(200);
BEGIN

 IF ( vSTATUS_USUARIO_NEW = 'A' ) THEN /*O USUÁRIO DEVE ESTAR ATIVO*/

          -- INSERE O SGBD
                  IF ( vCODIGO_SGBD_PADRAO_NEW IS NOT NULL ) THEN
                          INSERT INTO RHUSER_USR_SGBD (
                          SELECT vCODIGO_USUARIO_NEW ,  CODIGO_SGBD, 'TR_RHUSER_P_SIST', sysdate 
                          FROM RHUSER_SGBD where CODIGO_SGBD not in (SELECT CODIGO_SGBD FROM RHUSER_USR_SGBD WHERE CODIGO_USUARIO = vCODIGO_USUARIO_NEW )
                          AND CODIGO_SGBD = vCODIGO_SGBD_PADRAO_NEW );
                  END IF;

 SELECT sum(INSTR(vCODIGO_USUARIO_NEW,RHINTE_ED_IT_CONV.DADO_ORIGEM,-1)) into vVERIFICAUSUARIOEXTRA FROM RHINTE_ED_IT_CONV WHERE RHINTE_ED_IT_CONV.CODIGO_CONVERSAO = 'US03'  ;

    IF( REGEXP_LIKE( vCODIGO_USUARIO_NEW, '^p|^f|^s|^b|^l|^u') and  ( vVERIFICAUSUARIOEXTRA < 4 ) ) THEN /*O USUÁRIO DEVE TER O CODIGO INICIADO COM AS LETRAS P,F,S,B,L,U E NÃO PODE TERMINAR COM LETRAS. EX: pr054788, pres005587484..*/


          IF ( vEMPRESA_USUARIO_NEW IS NOT NULL AND vTP_CONTR_USUARIO_NEW IS NOT NULL AND vCONTRATO_USUARIO_NEW IS NOT NULL ) THEN  

                BEGIN
                      SELECT VINCULO, CASE WHEN COD_CARGO_EFETIVO IN  ( SELECT C.CODIGO FROM RHPLCS_CARGO C INNER JOIN RHPLCS_CRG_AREATU A ON C.CODIGO_EMPRESA  = A.CODIGO_EMPRESA AND C.CODIGO  = A.CODIGO_CARGO  INNER JOIN RHTABS_AREA_ATUA AT ON AT.CODIGO = A.AREA_ATUACAO WHERE AT.CODIGO_EMPRESA    = '0001'  AND A.AREA_ATUACAO  = '0001' AND C.DATA_EXTINC_CARGO IS NULL
                      ) THEN 'S' ELSE 'N' END AS VERIFICA_SE_GUARDA INTO VVINCULO, VGUARDA 
                      FROM RHPESS_CONTRATO WHERE 
                      RHPESS_CONTRATO.CODIGO_EMPRESA = vEMPRESA_USUARIO_NEW
                      AND RHPESS_CONTRATO.TIPO_CONTRATO = vTP_CONTR_USUARIO_NEW
                      AND RHPESS_CONTRATO.CODIGO = vCONTRATO_USUARIO_NEW
                      AND RHPESS_CONTRATO.ANO_MES_REFERENCIA =
                        (SELECT MAX(ANO_MES_REFERENCIA)
                        FROM RHPESS_CONTRATO AUX
                        WHERE AUX.CODIGO_EMPRESA = RHPESS_CONTRATO.CODIGO_EMPRESA
                        AND AUX.TIPO_CONTRATO    = RHPESS_CONTRATO.TIPO_CONTRATO
                        AND AUX.CODIGO           = RHPESS_CONTRATO.CODIGO
                        ) ;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                vERRO := 'ERRO NO USUÁRIO: '||vCODIGO_USUARIO_NEW || '. VERIFIQUE O CONTRATO, EMPRESA E TIPO DE CONTRATO INFORMADO NO USUÁRIO!';
                DBMS_Output.PUT_LINE(vERRO);
                WHEN OTHERS THEN
                vERRO := 'ENCONTRADO ERRO NO CONTRATO: '||vCONTRATO_USUARIO_NEW||' -- '||SQLCODE|| ' -ERROR- '||SQLERRM||'';
                DBMS_Output.PUT_LINE(vERRO);
                END;

                select cgc INTO vCGC from RHORGA_EMPRESA where codigo = vEMPRESA_USUARIO_NEW ;

/*--------------------------------------------------------------------  ESTAGIÁRIOS ----------------------------------------------------------- */
                      IF(VVINCULO = '0009' ) THEN
                            -- INSERE GRUPO DO PORTAL DO ESTAGIÁRIO E SOGD
                                  INSERT INTO RHUSER_RL_USR_GRP (
                                  select  vCODIGO_USUARIO_NEW , codigo, 'TR_RHUSER_P_SIST', sysdate 
                                  from RHUSER_GRUPO where codigo not in (select codigo_grupo from RHUSER_RL_USR_GRP where RHUSER_RL_USR_GRP.CODIGO_USUARIO = vCODIGO_USUARIO_NEW) 
                                  and codigo in ('.080','SOGD') );

                              -- DELETA O GRUPO DO PORTAL DO SERVIDOR DOS ESTAGIÁRIOS
                              delete from RHUSER_RL_USR_GRP where RHUSER_RL_USR_GRP.CODIGO_USUARIO = vCODIGO_USUARIO_NEW and codigo_grupo in ('.001','.002') ;

                      ELSE    
/*--------------------------------------------------------------------  SERVIDORES ----------------------------------------------------------- */

                                -- INSERE GRUPO DO PORTAL DO SERVIDOR PARA GUARDAS E SERVIDORES
                                  INSERT INTO RHUSER_RL_USR_GRP (
                                  select  vCODIGO_USUARIO_NEW , codigo, 'TR_RHUSER_P_SIST', sysdate 
                                  from RHUSER_GRUPO where codigo not in (select codigo_grupo from RHUSER_RL_USR_GRP where RHUSER_RL_USR_GRP.CODIGO_USUARIO = vCODIGO_USUARIO_NEW) 
                                  and codigo in ('SOGD',case when VGUARDA = 'S' THEN 'PCGM' ELSE '.001' END )  );



                               -- DELETA O GRUPO DO PORTAL DO SERVIDOR E PORTAL DO ESTAGIARIO
                              delete from RHUSER_RL_USR_GRP where RHUSER_RL_USR_GRP.CODIGO_USUARIO = vCODIGO_USUARIO_NEW and codigo_grupo in ('.080',case when VGUARDA = 'S' THEN '.001' ELSE 'PCGM' END) ;



                      END IF;   

                      -- INSERE O TIPO DE CONTRATO DO USUARIO 
                               INSERT INTO RHUSER_USR_TPCONT ( select vCODIGO_USUARIO_NEW , codigo, '' , 'TR_RHUSER_P_SIST', sysdate 
                            from RHPESS_TP_CONTRATO 
                            where codigo not in (select RHUSER_USR_TPCONT.tipo_contrato from RHUSER_USR_TPCONT where RHUSER_USR_TPCONT.CODIGO_USUARIO = vCODIGO_USUARIO_NEW) 
                            AND codigo = vTP_CONTR_USUARIO_NEW );

                      -- INSERE A EMPRESA DO USUARIO
                          INSERT INTO RHUSER_RL_USR_EMP ( select vCODIGO_USUARIO_NEW , codigo, 'TR_RHUSER_P_SIST', sysdate 
                            from RHORGA_EMPRESA 
                            where codigo not in (select codigo_empresa from RHUSER_RL_USR_EMP where CODIGO_USUARIO = vCODIGO_USUARIO_NEW) 
                            AND codigo = vEMPRESA_USUARIO_NEW );

/*--------------------------------------------------------------------  GESTORES ----------------------------------------------------------- */

                        -- INSERE OS TIPOS DE CONTRATO PARA GESTORES
                         INSERT INTO RHUSER_USR_TPCONT 
                          (
                          select vCODIGO_USUARIO_NEW , codigo, '' , 'TR_RHUSER_P_SIST', sysdate 
                          from RHPESS_TP_CONTRATO 
                          where codigo NOT IN (select RHUSER_USR_TPCONT.tipo_contrato from RHUSER_USR_TPCONT where RHUSER_USR_TPCONT.CODIGO_USUARIO = vCODIGO_USUARIO_NEW ) 
                          AND codigo IN 
                          (
                          SELECT DISTINCT B.TIPO_CONTRATO FROM RHORGA_AGRUPADOR CG
                          INNER JOIN RHPESS_CONTRATO B
                          ON B.CODIGO_EMPRESA  = CG.CODIGO_EMPRESA AND b.cod_custo_gerenc1 = CG.COD_AGRUP1 AND b.cod_custo_gerenc2 = CG.COD_AGRUP2 AND b.cod_custo_gerenc3 = CG.COD_AGRUP3 AND b.cod_custo_gerenc4 = CG.COD_AGRUP4 AND b.cod_custo_gerenc5 = CG.COD_AGRUP5 AND b.cod_custo_gerenc6 = CG.COD_AGRUP6
                          INNER JOIN RHPARM_SIT_FUNC ST 
                          ON B.SITUACAO_FUNCIONAL   = ST.CODIGO
                          WHERE 
                          B.ANO_MES_REFERENCIA = (SELECT MAX(ANO_MES_REFERENCIA) FROM RHPESS_CONTRATO AUX WHERE AUX.CODIGO_EMPRESA = B.CODIGO_EMPRESA AND AUX.TIPO_CONTRATO = B.TIPO_CONTRATO AND AUX.CODIGO = B.CODIGO)
                          AND ST.CONTROLE_FOLHA NOT IN ('D','S') AND  CG.TIPO_AGRUP = 'G' AND CG.DATA_EXTINCAO IS NULL AND 
                          ( ( CG.CONTRATO_RESP = vCONTRATO_USUARIO_NEW AND CG.TIPO_CONT_RESP = vTP_CONTR_USUARIO_NEW ) OR ( cg.CONTRATO_RESP_INF = vCONTRATO_USUARIO_NEW AND CG.TIPO_CONT_RESP_INF = vTP_CONTR_USUARIO_NEW ))
                          AND CG.CODIGO_EMPRESA = vEMPRESA_USUARIO_NEW
                          AND CG.CGC = vCGC
                          )
                          );

               -- INSERE GRUPO DO PORTAL DO GESTOR
                          INSERT INTO RHUSER_RL_USR_GRP (
                          select  vCODIGO_USUARIO_NEW , codigo, 'TR_RHUSER_P_SIST', sysdate 
                          from RHUSER_GRUPO where codigo not in (select codigo_grupo from RHUSER_RL_USR_GRP where RHUSER_RL_USR_GRP.CODIGO_USUARIO = vCODIGO_USUARIO_NEW) 
                          and codigo = ( case when VGUARDA = 'S' THEN 'GFGM' ELSE '.002' END )
                          AND EXISTS (SELECT G.CONTRATO_RESP FROM RHORGA_AGRUPADOR G WHERE 
                          ( ( G.CONTRATO_RESP = vCONTRATO_USUARIO_NEW AND G.TIPO_CONT_RESP = vTP_CONTR_USUARIO_NEW AND COD_EMPRESA_PESS = vEMPRESA_USUARIO_NEW) 
                          OR ( g.CONTRATO_RESP_INF = vCONTRATO_USUARIO_NEW AND G.TIPO_CONT_RESP_INF = vTP_CONTR_USUARIO_NEW AND COD_EMPR_PESS_INF = vEMPRESA_USUARIO_NEW ) ) 
                          AND G.CODIGO_EMPRESA = vEMPRESA_USUARIO_NEW
                          AND G.TIPO_AGRUP = 'G' AND G.DATA_EXTINCAO IS NULL AND G.CGC = vCGC) );

                   IF( VGUARDA = 'S') THEN      
                          dbms_output.put_line('É guarda' );

                               INSERT INTO RHUSER_RL_USR_GRP (
                                select  vCODIGO_USUARIO_NEW , codigo, 'TR_RHUSER_P_SIST', sysdate 
                                from RHUSER_GRUPO where codigo not in (select codigo_grupo from RHUSER_RL_USR_GRP where RHUSER_RL_USR_GRP.CODIGO_USUARIO = vCODIGO_USUARIO_NEW) 
                                and codigo = '.002'
                                AND EXISTS (
                                    SELECT 1 FROM RHPESS_CONTRATO AUX
                                    WHERE AUX.CODIGO_EMPRESA = vEMPRESA_USUARIO_NEW
                                    AND AUX.TIPO_CONTRATO = vTP_CONTR_USUARIO_NEW
                                    AND AUX.DATA_RESCISAO IS NULL
                                    AND AUX.CODIGO_PESSOA <> (SELECT CODIGO_PESSOA FROM ARTERH.RHPESS_CONTR_MEST WHERE CODIGO_EMPRESA = vEMPRESA_USUARIO_NEW AND TIPO_CONTRATO = vTP_CONTR_USUARIO_NEW AND CODIGO_CONTRATO = vCONTRATO_USUARIO_NEW)
                                    AND AUX.COD_PROCURADOR = (SELECT CODIGO_PESSOA FROM ARTERH.RHPESS_CONTR_MEST WHERE CODIGO_EMPRESA = vEMPRESA_USUARIO_NEW AND TIPO_CONTRATO = vTP_CONTR_USUARIO_NEW AND CODIGO_CONTRATO = vCONTRATO_USUARIO_NEW)
                                    AND (AUX.ANO_MES_REFERENCIA = (SELECT MAX(ARTERH_CONTRATO.ANO_MES_REFERENCIA) FROM RHPESS_CONTRATO ARTERH_CONTRATO WHERE AUX.CODIGO_EMPRESA = ARTERH_CONTRATO.CODIGO_EMPRESA AND AUX.TIPO_CONTRATO = ARTERH_CONTRATO.TIPO_CONTRATO AND AUX.CODIGO = ARTERH_CONTRATO.CODIGO  )) 
                                    AND AUX.COD_CARGO_EFETIVO NOT IN ( SELECT C.CODIGO FROM RHPLCS_CARGO C INNER JOIN RHPLCS_CRG_AREATU A ON C.CODIGO_EMPRESA  = A.CODIGO_EMPRESA AND C.CODIGO  = A.CODIGO_CARGO  INNER JOIN RHTABS_AREA_ATUA AT ON AT.CODIGO = A.AREA_ATUACAO WHERE AT.CODIGO_EMPRESA    = '0001'  AND A.AREA_ATUACAO  = '0001' AND C.DATA_EXTINC_CARGO IS NULL)
                                ));


                                INSERT INTO RHUSER_RL_USR_GRP (
                                select  vCODIGO_USUARIO_NEW , codigo, 'TR_RHUSER_P_SIST', sysdate 
                                from RHUSER_GRUPO where codigo not in (select codigo_grupo from RHUSER_RL_USR_GRP where RHUSER_RL_USR_GRP.CODIGO_USUARIO = vCODIGO_USUARIO_NEW) 
                                and codigo = '.002'
                                AND EXISTS (
                                select 1 from RHPESS_CONTRATO 
                                where RHPESS_CONTRATO.CODIGO_EMPRESA = vEMPRESA_USUARIO_NEW /*O CÓDIGO DE EMPRESA DO SUBORDINADO PODE SER DIFERENTE DO CÓDIGO DE EMPRESA DO GESTOR LOGADO*/
                                 AND RHPESS_CONTRATO.TIPO_CONTRATO = vEMPRESA_USUARIO_NEW 
                                /*O GESTOR DEVERÁ ACESSAR O TIPO DE CONTRATO DESEJADO*/
                                AND RHPESS_CONTRATO.CODIGO_PESSOA <> (SELECT CODIGO_PESSOA FROM ARTERH.RHPESS_CONTR_MEST WHERE CODIGO_EMPRESA = vEMPRESA_USUARIO_NEW AND TIPO_CONTRATO = vTP_CONTR_USUARIO_NEW AND CODIGO_CONTRATO = vCONTRATO_USUARIO_NEW)
                                AND RHPESS_CONTRATO.DATA_RESCISAO IS NULL
                                AND RHPESS_CONTRATO.COD_CARGO_EFETIVO NOT IN (SELECT C.CODIGO FROM RHPLCS_CARGO C, RHPLCS_CRG_AREATU A, 
                                                                             RHTABS_AREA_ATUA AT WHERE C.CODIGO_EMPRESA  = A.CODIGO_EMPRESA
                                                                             AND C.CODIGO  = A.CODIGO_CARGO AND AT.CODIGO = A.AREA_ATUACAO
                                                                             AND AT.CODIGO_EMPRESA    = '0001' AND A.AREA_ATUACAO  = '0001')   
                                AND EXISTS 
                                (
                                SELECT 1 FROM RHORGA_AGRUPADOR ACONT 
                                INNER JOIN RHORGA_ESTRUT_AGR E ON 
                                ACONT.CODIGO_EMPRESA = E.CODIGO_EMPRESA 	
                                AND ACONT.ID_AGRUP = E.ID_AGRUP 	
                                AND E.ANO_MES_REFERENCIA = ( SELECT MAX( AGR.ANO_MES_REFERENCIA ) 		
                                FROM RHORGA_ESTRUT_AGR AGR 		
                                WHERE E.CODIGO_EMPRESA = AGR.CODIGO_EMPRESA		
                                AND AGR.ID_AGRUP = E.ID_AGRUP 		
                                AND AGR.ANO_MES_REFERENCIA <= (select data_do_sistema from rhparm_p_sist)  
                                ) 
                                INNER JOIN RHORGA_AGRUPADOR ASUP ON /*AGRUPADOR SUPERIOR DO AGRUPADOR DO CONTRATO*/
                                ASUP.CODIGO_EMPRESA = E.CODIGO_EMPRESA 
                                AND ASUP.TIPO_AGRUP = 'G'
                                AND ASUP.ID_AGRUP = E.ID_AGRUP_SUP
                                /*O CÓDIGO DA EMPRESA DO RESPONSÁVEL PODE NÃO SER O MESMO DO SUBORDINADO*/	
                                AND (SELECT CODIGO_PESSOA FROM ARTERH.RHPESS_CONTR_MEST WHERE CODIGO_EMPRESA = vEMPRESA_USUARIO_NEW AND TIPO_CONTRATO = vTP_CONTR_USUARIO_NEW AND CODIGO_CONTRATO = vCONTRATO_USUARIO_NEW) IN ( ASUP.COD_PESS_INFORMAL, ASUP.COD_PESSOA_RESP )
                                AND E.NIVEL_AGRUP_ESTRUT BETWEEN ASUP.NIVEL_AGRUP_ESTRUT 
                                AND ASUP.NIVEL_AGRUP_ESTRUT+1
                                /*USUARIO VISUALIZA OS AGRUAPDORES  AO QUAL É RESPONSAVEL FORMAL OU INFORMAL E O AGRUPADOR UM NIVEL ABAIXO*/
                                WHERE ACONT.CODIGO_EMPRESA = vEMPRESA_USUARIO_NEW
                                /*ENTENDIMENTO QUE O GESTOR ESTARÁ SELECIONADO NA EMPRESA DO SUBORDINADO*/	
                                AND ACONT.TIPO_AGRUP = 'G' 	
                                AND ((ASUP.COD_PESS_INFORMAL = (SELECT CODIGO_PESSOA FROM ARTERH.RHPESS_CONTR_MEST WHERE CODIGO_EMPRESA = vEMPRESA_USUARIO_NEW AND TIPO_CONTRATO = vTP_CONTR_USUARIO_NEW AND CODIGO_CONTRATO = vCONTRATO_USUARIO_NEW)	
                                AND  RHPESS_CONTRATO.CODIGO_PESSOA = CASE 
                                WHEN ( ASUP.COD_PESS_INFORMAL IS NOT  NULL 
                                AND ACONT.ID_AGRUP = ASUP.ID_AGRUP )  THEN RHPESS_CONTRATO.CODIGO_PESSOA
                                ELSE ACONT.COD_PESSOA_RESP END 	
                                AND  RHPESS_CONTRATO.CODIGO_PESSOA <> CASE WHEN ( ASUP.COD_PESS_INFORMAL IS NOT  NULL AND  ACONT.ID_AGRUP = ASUP.ID_AGRUP )
                                THEN ASUP.COD_PESSOA_RESP
                                ELSE (SELECT CODIGO_PESSOA FROM ARTERH.RHPESS_CONTR_MEST WHERE CODIGO_EMPRESA = vEMPRESA_USUARIO_NEW AND TIPO_CONTRATO = vTP_CONTR_USUARIO_NEW AND CODIGO_CONTRATO = vCONTRATO_USUARIO_NEW)  END
                                /*SE USUARIO = GESTOR INFORMAL VISUALISA A EQUIPO DO AGRUPADOR AO QUAL É INFORMAL MAIS FORMAIS DO NIVEL ABAIXO NÃO VISUALIA O FORMA DO AGRUPDOR AO QUAL É INFORMAL*/
                                ) 
                                OR 
                                (ASUP.COD_PESSOA_RESP = (SELECT CODIGO_PESSOA FROM ARTERH.RHPESS_CONTR_MEST WHERE CODIGO_EMPRESA = vEMPRESA_USUARIO_NEW AND TIPO_CONTRATO = vTP_CONTR_USUARIO_NEW AND CODIGO_CONTRATO = vCONTRATO_USUARIO_NEW) 	
                                AND  ASUP.COD_PESS_INFORMAL IS NOT NULL 	
                                AND  RHPESS_CONTRATO.CODIGO_PESSOA =  ASUP.COD_PESS_INFORMAL 
                                /*SE USUÁRIO = AO GESTOR FORMAL DO AGRUPADOR SUPERIOR E ESTE POSSUI INFORMAL VISUALIZA SOMENTE O GESTORE INFORMAL*/
                                )
                                OR 
                                (ASUP.COD_PESSOA_RESP = (SELECT CODIGO_PESSOA FROM ARTERH.RHPESS_CONTR_MEST WHERE CODIGO_EMPRESA = vEMPRESA_USUARIO_NEW AND TIPO_CONTRATO = vTP_CONTR_USUARIO_NEW AND CODIGO_CONTRATO = vCONTRATO_USUARIO_NEW) 	
                                AND  ASUP.COD_PESS_INFORMAL IS NULL 	
                                AND  RHPESS_CONTRATO.CODIGO_PESSOA = CASE WHEN  ASUP.COD_PESS_INFORMAL IS NULL 
                                AND ACONT.NIVEL_AGRUP_ESTRUT > ASUP.NIVEL_AGRUP_ESTRUT 
                                 THEN ACONT.COD_PESSOA_RESP 
                                ELSE RHPESS_CONTRATO.CODIGO_PESSOA END
                                 /*SE USUÁRIO = AO GESTOR FORMAL DO AGRUPADOR SUPERIOR E ESTE NÃO POSSUI INFORMAL VISUALIZA TODOS OS SUBORDINADOS DO PROPRIO AGRUPADOR E OS GESTORES FORMAIS DOS AGRUPADORES ABAIXO */
                                )
                                )	
                                AND ACONT.CODIGO_EMPRESA = RHPESS_CONTRATO.CODIGO_EMPRESA 
                                AND ACONT.TIPO_AGRUP = RHPESS_CONTRATO.TIPO_AGRUP_CGER
                                AND ACONT.COD_AGRUP1 = RHPESS_CONTRATO.COD_CUSTO_GERENC1 
                                AND ACONT.COD_AGRUP2 = RHPESS_CONTRATO.COD_CUSTO_GERENC2 
                                AND ACONT.COD_AGRUP3 = RHPESS_CONTRATO.COD_CUSTO_GERENC3 
                                AND ACONT.COD_AGRUP4 = RHPESS_CONTRATO.COD_CUSTO_GERENC4 
                                AND ACONT.COD_AGRUP5 = RHPESS_CONTRATO.COD_CUSTO_GERENC5 
                                AND ACONT.COD_AGRUP6 = RHPESS_CONTRATO.COD_CUSTO_GERENC6
                                AND RHPESS_CONTRATO.COD_PROCURADOR IS NULL

                                ) 
                                AND (RHPESS_CONTRATO.ANO_MES_REFERENCIA = (SELECT MAX(ARTERH_CONTRATO.ANO_MES_REFERENCIA) FROM RHPESS_CONTRATO ARTERH_CONTRATO WHERE RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH_CONTRATO.CODIGO_EMPRESA AND RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH_CONTRATO.TIPO_CONTRATO AND RHPESS_CONTRATO.CODIGO = ARTERH_CONTRATO.CODIGO  )) 
                                )
                                );
                            ELSIF( VGUARDA = 'N') THEN
                               -- DELETA O GRUPO DO PORTAL DO GESTOR PARA NÃO GUARDAS
                                delete from RHUSER_RL_USR_GRP where RHUSER_RL_USR_GRP.CODIGO_USUARIO = vCODIGO_USUARIO_NEW and codigo_grupo in ('PCGM') ;
                            END IF;       

        IF ( vEMPRESA_USUARIO_NEW not in ( '0010')) then  
                -- INSERIR GRUPO DO PORTAL DA INTERRUPÇÃO DE FÉRIAS ( SECRETARIOS )
                          INSERT INTO RHUSER_RL_USR_GRP (
                          select vCODIGO_USUARIO_NEW , codigo, 'TR_RHUSER_P_SIST', sysdate 
                          from RHUSER_GRUPO where codigo not in (select codigo_grupo from RHUSER_RL_USR_GRP where RHUSER_RL_USR_GRP.CODIGO_USUARIO = vCODIGO_USUARIO_NEW) 
                          and codigo = 'INFE'
                          AND EXISTS (SELECT CG.CONTRATO_RESP FROM RHORGA_AGRUPADOR CG WHERE 
                          ( ( CG.CONTRATO_RESP    = vCONTRATO_USUARIO_NEW AND CG.TIPO_CONT_RESP = vTP_CONTR_USUARIO_NEW AND COD_EMPRESA_PESS = vEMPRESA_USUARIO_NEW ) 
                          OR ( cg.CONTRATO_RESP_INF = vCONTRATO_USUARIO_NEW AND CG.TIPO_CONT_RESP_INF = vTP_CONTR_USUARIO_NEW AND COD_EMPR_PESS_INF = vEMPRESA_USUARIO_NEW) 
                          ) AND CG.TIPO_AGRUP = 'G' AND CG.DATA_EXTINCAO IS NULL
                          AND CG.CODIGO_EMPRESA = vEMPRESA_USUARIO_NEW AND CG.COD_AGRUP2 = '000000' AND CG.COD_AGRUP3 = '000000' AND CG.COD_AGRUP4 = '000000' AND CG.COD_AGRUP5 = '000000' AND CG.COD_AGRUP6 = '000000'
                          AND CG.CGC = vCGC)) ;

               -- INSERIR GRUPO DO PORTAL DA SECRETARIA ( SECRETARIOS )
                          INSERT INTO RHUSER_RL_USR_GRP (
                          select vCODIGO_USUARIO_NEW , codigo, 'TR_RHUSER_P_SIST', sysdate 
                          from RHUSER_GRUPO where codigo not in (select codigo_grupo from RHUSER_RL_USR_GRP where RHUSER_RL_USR_GRP.CODIGO_USUARIO = vCODIGO_USUARIO_NEW) 
                          and codigo = '.100'
                          AND EXISTS (SELECT CG.CONTRATO_RESP FROM RHORGA_AGRUPADOR CG WHERE 
                          ( ( CG.CONTRATO_RESP    = vCONTRATO_USUARIO_NEW AND CG.TIPO_CONT_RESP = vTP_CONTR_USUARIO_NEW AND COD_EMPRESA_PESS = vEMPRESA_USUARIO_NEW ) 
                          OR ( cg.CONTRATO_RESP_INF = vCONTRATO_USUARIO_NEW AND CG.TIPO_CONT_RESP_INF = vTP_CONTR_USUARIO_NEW AND COD_EMPR_PESS_INF = vEMPRESA_USUARIO_NEW) 
                          ) AND CG.TIPO_AGRUP = 'G' AND CG.DATA_EXTINCAO IS NULL
                          AND CG.CODIGO_EMPRESA = vEMPRESA_USUARIO_NEW AND CG.COD_AGRUP2 = '000000' AND CG.COD_AGRUP3 = '000000' AND CG.COD_AGRUP4 = '000000' AND CG.COD_AGRUP5 = '000000' AND CG.COD_AGRUP6 = '000000'
                          AND CG.CGC = vCGC)) ;

        END IF;        
              END IF;

     END IF;                                      
END IF; 

   IF ( vSTATUS_USUARIO_NEW = 'E' ) THEN /*O USUÁRIO DEVE ESTAR EXCLUIDO*/

          -- REALIZAR A EXCLUSAO DO LOGIN NAS LISTAS DE CONVERSÃO DE: LOGINS QUE NUNCA FECHAM(US20) E TROCA DE GRUPO DE USUARIO(US07)
          DELETE FROM RHINTE_ED_IT_CONV WHERE CODIGO_CONVERSAO = 'US07' AND DADO_ORIGEM = vCODIGO_USUARIO_NEW ;
          DELETE FROM RHINTE_ED_IT_CONV WHERE CODIGO_CONVERSAO = 'US20' AND DADO_ORIGEM = vCODIGO_USUARIO_NEW;
   END IF;
   END;
END;