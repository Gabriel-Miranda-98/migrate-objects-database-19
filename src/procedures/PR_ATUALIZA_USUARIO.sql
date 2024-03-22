
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PR_ATUALIZA_USUARIO" AS
    CONT NUMBER := 0;
BEGIN
    FOR C1 IN (
        SELECT
            *
        FROM
            PONTO_ELETRONICO.VIEW_FOR_USUARIO
    ) LOOP
        CONT := CONT + 1;
          --------------------------------------------------------------------INICIO DA LOGICA PARA LIMPAR OS GRUPOS---------------------------------------------------------------
          ---------------------------------------------------------------------------------------------QUANDO DEIXA DE SER GESTOR DO LOCAL------------------------------------------------------
        IF ( C1.E_GESTOR = 'S' AND C1.E_GESTOR_SEGUINTE = 'N' ) THEN
            DELETE FROM ARTERH.RHUSER_RL_USR_GRP GRUPO
            WHERE
                    GRUPO.CODIGO_GRUPO IN (SELECT REGEXP_SUBSTR(DADO_ORIGEM, '[^;]+',1, 2) AS GRUPO FROM RHINTE_ED_IT_CONV WHERE CODIGO_CONVERSAO = 'US01' AND DADO_DESTINO = 'EXCLUIR')
                AND GRUPO.CODIGO_USUARIO IN (
                    SELECT
                        ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                    FROM
                        ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST, ARTERH.RHUSER_RL_USR_GRP
                    WHERE
                            ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                SELECT
                                    MAX(A.ANO_MES_REFERENCIA)
                                FROM
                                    ARTERH.RHPESS_CONTRATO A
                                WHERE
                                        A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                    AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                    AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                            )
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ''|| C1.CODIGO_EMPRESA || ''
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                        AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                        AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                        AND ARTERH.RHUSER_P_SIST.CODIGO_USUARIO = ARTERH.RHUSER_RL_USR_GRP.CODIGO_USUARIO
                        AND GRUPO.CODIGO_USUARIO = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                        /*AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                );

            COMMIT;
        END IF;
          -----------------------------------------------------------------------------NOVO_GESTOR----------------------------------------------------------------------------------------------------
        IF ( C1.E_GESTOR = 'N' AND C1.E_GESTOR_SEGUINTE = 'S') THEN
            BEGIN
                DECLARE
                    VCONT NUMBER;
                BEGIN
                    VCONT := 0;
                    FOR C6 IN (----- INICIO DO FOR C6
                        SELECT
                            ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, C1.ANALISE_GUARDA
                        FROM
                            ARTERH.RHPESS_CONTRATO,
                            ARTERH.RHUSER_P_SIST
                        WHERE
                                ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                SELECT
                                    MAX(A.ANO_MES_REFERENCIA)
                                FROM
                                    ARTERH.RHPESS_CONTRATO A
                                WHERE
                                        A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                    AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                    AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                            )
                            AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                            AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                            AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                            AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                            AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                            AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                            AND ARTERH.RHUSER_P_SIST.TIPO_LOGIN IN ('2','3') 
                            AND ARTERH.RHUSER_P_SIST.CODIGO_SERV_AUTENT IN ('PWS1') 
                            AND ARTERH.RHUSER_P_SIST.CODIGO_USUARIO = ARTERH.RHUSER_P_SIST.USUARIO_LDAP
                            /*REGRA CRIADA PARA RETIRAR OS USUARIOS QUE NAO SAO AD*/
                            AND NOT EXISTS (SELECT RHINTE_ED_IT_CONV.DADO_ORIGEM FROM RHINTE_ED_IT_CONV WHERE RHINTE_ED_IT_CONV.CODIGO_CONVERSAO = 'US03' 
                                                                                                            AND INSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO,RHINTE_ED_IT_CONV.DADO_ORIGEM,-1) > 4)
                          /*AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                                                   
                    )---- FIM DO FOR C6
                     LOOP
                        VCONT := VCONT + 1;
                        BEGIN
                            DECLARE
                                VCONT1 NUMBER;
                            BEGIN
                                VCONT1 := 0;
                                FOR C7 IN (
                                    SELECT
                                        X3.*
                                    FROM
                                        (
                                            SELECT
                                                COUNT(1) QUANT,
                                                X2.CODIGO_USUARIO,
                                                X2.ANALISE_GUARDA
                                            FROM
                                                (
                                                    SELECT
                                                        X.TEM_GRUP_2,
                                                        X.CODIGO_USUARIO,
                                                        X.ANALISE_GUARDA
                                                    FROM
                                                        (
                                                            SELECT
                                                                CASE
                                                                    WHEN A.CODIGO_GRUPO = '.002' THEN 'SIM'
                                                                    WHEN A.CODIGO_GRUPO = 'GFGM' THEN 'SIM'
                                                                    ELSE
                                                                        'NAO'
                                                                END TEM_GRUP_2,
                                                                A.CODIGO_USUARIO,
                                                                A.CODIGO_GRUPO,
                                                                C6.ANALISE_GUARDA
                                                            FROM
                                                                ARTERH.RHUSER_RL_USR_GRP A
                                                            WHERE
                                                                A.CODIGO_USUARIO = C6.CODIGO_USUARIO
                                                        ) X
                                                    GROUP BY
                                                        X.TEM_GRUP_2,
                                                        X.CODIGO_USUARIO,
                                                        X.ANALISE_GUARDA
                                                ) X2
                                            GROUP BY
                                                X2.CODIGO_USUARIO,
                                                X2.ANALISE_GUARDA
                                        ) X3
                                    WHERE
                                        X3.QUANT = 1
                                ) LOOP
                                    BEGIN
                                        INSERT INTO ARTERH.RHUSER_RL_USR_GRP (
                                            CODIGO_USUARIO,
                                            CODIGO_GRUPO,
                                            LOGIN_USUARIO,
                                            DT_ULT_ALTER_USUA
                                        ) VALUES (
                                            ''||C7.CODIGO_USUARIO|| '',
                                            CASE WHEN C7.ANALISE_GUARDA = 'GUARDA' THEN 'GFGM'  ELSE '.002' END ,
                                            'INTEGRACAO_IFPONTO',
                                            SYSDATE
                                        );

                                        COMMIT;
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            NULL;
                                    END;
                                END LOOP;

                            END;

                        END;

                    END LOOP;

                END;

            END;
        END IF;
          -------------------------------------------------------------------------------QUANDO OCORRE A MOVIMENTACAO-------------------------------------------------------------------------------------
          -----------------------------------------------------------------------------QUANDO A PESSOA E MOVIMENTADA E NAO E GESTORA----------------------------------------------------------
          --------------------------------------------------------------------------LIMPA GRUPOS EXCETO '.001','SOGD'--------------------------------------------------------------------------------------
        IF ( C1.ALTEROU_LOCAL = 'LOCAL_MUDOU' AND C1.E_GESTOR_SEGUINTE = 'N' ) THEN
            DELETE FROM ARTERH.RHUSER_RL_USR_GRP GRUPO
            WHERE
                GRUPO.CODIGO_USUARIO IN (
                    SELECT
                        ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                    FROM
                        ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST, ARTERH.RHUSER_RL_USR_GRP
                    WHERE
                            ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                SELECT
                                    MAX(A.ANO_MES_REFERENCIA)
                                FROM
                                    ARTERH.RHPESS_CONTRATO A
                                WHERE
                                        A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                    AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                    AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                            )
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                        AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO|| ''
                        AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                        AND ARTERH.RHUSER_P_SIST.CODIGO_USUARIO = ARTERH.RHUSER_RL_USR_GRP.CODIGO_USUARIO
                        AND GRUPO.CODIGO_USUARIO = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                        /*AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                )
                /*AND GRUPO.CODIGO_GRUPO NOT IN ( '.001', 'SOGD', 'PE01', '0070' ); EM 20/06/2023 RAFAELLA, ALTERACAO DE ACORDO COM TABELA DE CONVERSAO ABAIXO*/
                AND GRUPO.CODIGO_GRUPO NOT IN ( SELECT REGEXP_SUBSTR(RHINTE_ED_IT_CONV.DADO_ORIGEM, '[^;]+',1, 2) AS GRUPO FROM RHINTE_ED_IT_CONV 
                                                        WHERE RHINTE_ED_IT_CONV.CODIGO_CONVERSAO = 'US01' AND RHINTE_ED_IT_CONV.DADO_DESTINO = 'MANTER');

            COMMIT;
            -------------------------------------------------------------------------------------RETIRAR O CODIGO SGBD-------------------------------------------------------------------------------------
            DELETE FROM RHUSER_USR_SGBD SGDB
            WHERE
                SGDB.CODIGO_USUARIO IN (
                    SELECT
                        ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                    FROM
                        ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST, RHUSER_USR_SGBD
                    WHERE
                            ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                SELECT
                                    MAX(A.ANO_MES_REFERENCIA)
                                FROM
                                    ARTERH.RHPESS_CONTRATO A
                                WHERE
                                        A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                    AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                    AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                            )
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                        AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                        AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                        AND ARTERH.RHUSER_P_SIST.CODIGO_USUARIO = RHUSER_USR_SGBD.CODIGO_USUARIO
                        /*AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                        AND SGDB.CODIGO_USUARIO = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                );

            COMMIT;
            ------------------------------------------------------------------------RETIRAR O CODIGO EMPRESA---------------------------------------------------------------------------------------------
            -----ALTERADO AQUI EM 03/02/2020 A PEDIDO DA RAFAELLA  PARA NAO RETIRAR A EMPRESA DO DESTIDO DO USUARIO (A MESMA DO CONTRATO)
            DELETE FROM RHUSER_RL_USR_EMP EMPRESA
            WHERE
                EMPRESA.CODIGO_USUARIO IN (
                    SELECT
                        ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                    FROM
                        ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST, RHUSER_RL_USR_EMP
                    WHERE
                            ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                SELECT
                                    MAX(A.ANO_MES_REFERENCIA)
                                FROM
                                    ARTERH.RHPESS_CONTRATO A
                                WHERE
                                        A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                    AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                    AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                            )
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                        AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                        /*AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                        AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                        AND ARTERH.RHUSER_P_SIST.CODIGO_USUARIO = RHUSER_RL_USR_EMP.CODIGO_USUARIO
                        AND EMPRESA.CODIGO_USUARIO = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                )
                AND EMPRESA.CODIGO_EMPRESA NOT IN ( '' || C1.CODIGO_EMPRESA || '' );

            COMMIT;
            -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
            UPDATE ARTERH.RHUSER_P_SIST USUARIO
            SET
                USUARIO.CODIGO_GRUPO = CASE WHEN C1.VINCULO = '0009' THEN '.080' WHEN C1.ANALISE_GUARDA = 'GUARDA' THEN 'PCGM' ELSE '.001' END,
                USUARIO.GRUPO_SEGURANCA = CASE WHEN C1.VINCULO = '0009' THEN '.080' WHEN C1.ANALISE_GUARDA = 'GUARDA' THEN 'PCGM' ELSE '.001' END,
                USUARIO.ULTIMO_PERFIL_ACESSO_AZC = CASE WHEN C1.VINCULO = '0009' THEN '.080' WHEN C1.ANALISE_GUARDA = 'GUARDA' THEN 'PCGM' ELSE '.001' END,
                USUARIO.PERMITE_INCLUSAO = 'N',
                USUARIO.PERMITE_EXCLUSAO = 'N',
                USUARIO.PERMITE_ALTERACAO = 'N',
                USUARIO.EMPRESA_SELEC = C1.CODIGO_EMPRESA,
                USUARIO.TIPO_CONTR_SELEC = C1.TIPO_CONTRATO,
                USUARIO.USA_SAL_PRINCIPAL = 'N',
                USUARIO.ALT_MV_PT_DT_RETRO = 'N',
                USUARIO.ALT_PONTO_DT_RETRO = 'N',
                USUARIO.PERMITE_EXECUCAO = 'N',
                USUARIO.MENU_DEF_ENABLED = 'N',
                USUARIO.ACERTO_BASE_HIST = 'N',
                USUARIO.ALT_CONT_DT_RETRO = 'N',
                USUARIO.ALT_PESS_DT_RETRO = 'N',
                USUARIO.EXIBE_DICA = 'N',
                USUARIO.MENU_DEF_VISIBLE = 'N',
                USUARIO.CODIGO_SGBD_PADRAO = NULL
            WHERE
                USUARIO.CODIGO_USUARIO IN (
                    SELECT
                        ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                    FROM
                        ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST
                    WHERE
                            ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                SELECT
                                    MAX(A.ANO_MES_REFERENCIA)
                                FROM
                                    ARTERH.RHPESS_CONTRATO A
                                WHERE
                                        A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                    AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                    AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                            )
                        /*AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                        AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                        AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                        AND USUARIO.CODIGO_USUARIO = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                        AND USUARIO.CONTRATO_USUARIO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND USUARIO.TP_CONTR_USUARIO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND USUARIO.EMPRESA_USUARIO = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                        AND NOT EXISTS (SELECT RHINTE_ED_IT_CONV.DADO_ORIGEM FROM RHINTE_ED_IT_CONV WHERE RHINTE_ED_IT_CONV.CODIGO_CONVERSAO = 'US03' AND 
                                                                    INSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO,RHINTE_ED_IT_CONV.DADO_ORIGEM,-1) > 4)
                );

            COMMIT;
            ---------------------------------------------------------------------RETIRA O ACESSO DA TROCA GRUPO USUARIO E LISTA DOS LOGINS QUE NUNCA FECHAM-----------------------------------------------
            DELETE FROM ARTERH.RHINTE_ED_IT_CONV C
                     WHERE
                        C.CODIGO_CONVERSAO IN ('US20','US07') AND 
                        TRIM(C.DADO_ORIGEM) in (SELECT
                                            ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                                        FROM
                                            ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST, RHUSER_USR_SGBD
                                        WHERE
                                                ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                                    SELECT
                                                        MAX(A.ANO_MES_REFERENCIA)
                                                    FROM
                                                        ARTERH.RHPESS_CONTRATO A
                                                    WHERE
                                                            A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                                        AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                                        AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                                                )
                                            AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                                            AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                                            AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                                            AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                                            AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                                            AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                                            /*AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                                            AND TRIM(C.DADO_ORIGEM) = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO);
        COMMIT;                                            
        END IF;
          ----------------------------------------------------------LIMPA GRUPOS EXCETO '.001','SOGD','.002'--------------------------------------------------------------------------------------
        IF ( C1.ALTEROU_LOCAL = 'LOCAL_MUDOU' AND C1.E_GESTOR_SEGUINTE = 'S' ) THEN
            DELETE FROM ARTERH.RHUSER_RL_USR_GRP GRUPO
            WHERE
                GRUPO.CODIGO_USUARIO IN (
                    SELECT
                        ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                    FROM
                        ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST, ARTERH.RHUSER_RL_USR_GRP
                    WHERE
                            ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                SELECT
                                    MAX(A.ANO_MES_REFERENCIA)
                                FROM
                                    ARTERH.RHPESS_CONTRATO A
                                WHERE
                                        A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                    AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                    AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                            )
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                        AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                        /*AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                        AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                        AND ARTERH.RHUSER_P_SIST.CODIGO_USUARIO = ARTERH.RHUSER_RL_USR_GRP.CODIGO_USUARIO
                        AND GRUPO.CODIGO_USUARIO = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                        AND NOT EXISTS (SELECT RHINTE_ED_IT_CONV.DADO_ORIGEM FROM RHINTE_ED_IT_CONV WHERE RHINTE_ED_IT_CONV.CODIGO_CONVERSAO = 'US03' AND 
                                                                    INSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO,RHINTE_ED_IT_CONV.DADO_ORIGEM,-1) > 4)
                )
                /*AND GRUPO.CODIGO_GRUPO NOT IN ( '.001', 'SOGD', 'PE01', '0070' ); EM 20/06/2023 RAFAELLA, ALTERACAO DE ACORDO COM TABELA DE CONVERSAO ABAIXO*/
                AND GRUPO.CODIGO_GRUPO NOT IN ( SELECT REGEXP_SUBSTR(DADO_ORIGEM, '[^;]+',1, 2) AS GRUPO FROM RHINTE_ED_IT_CONV WHERE CODIGO_CONVERSAO = 'US01' AND DADO_DESTINO = 'MANTER');

            COMMIT;
            ------------------------------------------------------------------------------------RETIRAR O CODIGO SGBD----------------------------------------------------------------------------------------
            DELETE FROM RHUSER_USR_SGBD SGDB
            WHERE
                SGDB.CODIGO_USUARIO IN (
                    SELECT
                        ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                    FROM
                        ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST, RHUSER_USR_SGBD
                    WHERE
                            ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                SELECT
                                    MAX(A.ANO_MES_REFERENCIA)
                                FROM
                                    ARTERH.RHPESS_CONTRATO A
                                WHERE
                                        A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                    AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                    AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                            )
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                        AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                        /*AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                        AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                        AND ARTERH.RHUSER_P_SIST.CODIGO_USUARIO = RHUSER_USR_SGBD.CODIGO_USUARIO
                        AND SGDB.CODIGO_USUARIO = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                        AND NOT EXISTS (SELECT RHINTE_ED_IT_CONV.DADO_ORIGEM FROM RHINTE_ED_IT_CONV WHERE RHINTE_ED_IT_CONV.CODIGO_CONVERSAO = 'US03' AND 
                                                                    INSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO,RHINTE_ED_IT_CONV.DADO_ORIGEM,-1) > 4)
                );

            COMMIT;
            --------------------------------------------------------------------------------------RETIRAR O CODIGO EMPRESA------------------------------------------------------------------------------
            DELETE FROM RHUSER_RL_USR_EMP EMPRESA
            WHERE
                EMPRESA.CODIGO_USUARIO IN (
                    SELECT
                        ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                    FROM
                        ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST, RHUSER_RL_USR_EMP
                    WHERE
                            ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                SELECT
                                    MAX(A.ANO_MES_REFERENCIA)
                                FROM
                                    ARTERH.RHPESS_CONTRATO A
                                WHERE
                                        A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                    AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                    AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                            )
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                        AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                        /*AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                        AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                        AND ARTERH.RHUSER_P_SIST.CODIGO_USUARIO = RHUSER_RL_USR_EMP.CODIGO_USUARIO
                        AND EMPRESA.CODIGO_USUARIO = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                        AND NOT EXISTS (SELECT RHINTE_ED_IT_CONV.DADO_ORIGEM FROM RHINTE_ED_IT_CONV WHERE RHINTE_ED_IT_CONV.CODIGO_CONVERSAO = 'US03' AND 
                                                                    INSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO,RHINTE_ED_IT_CONV.DADO_ORIGEM,-1) > 4)
                )
                AND EMPRESA.CODIGO_EMPRESA NOT IN ( '' || C1.CODIGO_EMPRESA || '' );

            COMMIT;
            -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
            UPDATE ARTERH.RHUSER_P_SIST USUARIO
            SET
                USUARIO.CODIGO_GRUPO = CASE WHEN C1.VINCULO = '0009' THEN '.080' WHEN C1.ANALISE_GUARDA = 'GUARDA' THEN 'PCGM' ELSE '.001' END,
                USUARIO.GRUPO_SEGURANCA = CASE WHEN C1.VINCULO = '0009' THEN '.080' WHEN C1.ANALISE_GUARDA = 'GUARDA' THEN 'PCGM' ELSE '.001' END,
                USUARIO.ULTIMO_PERFIL_ACESSO_AZC = CASE WHEN C1.VINCULO = '0009' THEN '.080' WHEN C1.ANALISE_GUARDA = 'GUARDA' THEN 'PCGM' ELSE '.001' END,
                USUARIO.PERMITE_INCLUSAO = 'N',
                USUARIO.PERMITE_EXCLUSAO = 'N',
                USUARIO.PERMITE_ALTERACAO = 'N',
                USUARIO.EMPRESA_SELEC = C1.CODIGO_EMPRESA,
                USUARIO.TIPO_CONTR_SELEC = C1.TIPO_CONTRATO,
                USUARIO.USA_SAL_PRINCIPAL = 'N',
                USUARIO.ALT_MV_PT_DT_RETRO = 'N',
                USUARIO.ALT_PONTO_DT_RETRO = 'N',
                USUARIO.PERMITE_EXECUCAO = 'N',
                USUARIO.MENU_DEF_ENABLED = 'N',
                USUARIO.ACERTO_BASE_HIST = 'N',
                USUARIO.ALT_CONT_DT_RETRO = 'N',
                USUARIO.ALT_PESS_DT_RETRO = 'N',
                USUARIO.EXIBE_DICA = 'N',
                USUARIO.MENU_DEF_VISIBLE = 'N',
                USUARIO.CODIGO_SGBD_PADRAO = NULL
            WHERE
                USUARIO.CODIGO_USUARIO IN (
                    SELECT
                        ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                    FROM
                        ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST
                    WHERE
                            ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                SELECT
                                    MAX(A.ANO_MES_REFERENCIA)
                                FROM
                                    ARTERH.RHPESS_CONTRATO A
                                WHERE
                                        A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                    AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                    AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                            )
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                        AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                       /* AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                        AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                        AND USUARIO.CODIGO_USUARIO = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                        AND USUARIO.CONTRATO_USUARIO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND USUARIO.TP_CONTR_USUARIO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND USUARIO.EMPRESA_USUARIO = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                        AND NOT EXISTS (SELECT RHINTE_ED_IT_CONV.DADO_ORIGEM FROM RHINTE_ED_IT_CONV WHERE RHINTE_ED_IT_CONV.CODIGO_CONVERSAO = 'US03' AND 
                                                                    INSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO,RHINTE_ED_IT_CONV.DADO_ORIGEM,-1) > 4)
                );

            COMMIT;
            ---------------------------------------------------------------------RETIRA O ACESSO DA TROCA GRUPO USUARIO E LISTA DOS LOGINS QUE NUNCA FECHAM-----------------------------------------------
            DELETE FROM ARTERH.RHINTE_ED_IT_CONV C
                     WHERE
                        C.CODIGO_CONVERSAO IN ('US20','US07') AND 
                        TRIM(C.DADO_ORIGEM) in (SELECT
                                            ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                                        FROM
                                            ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST, RHUSER_USR_SGBD
                                        WHERE
                                                ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                                    SELECT
                                                        MAX(A.ANO_MES_REFERENCIA)
                                                    FROM
                                                        ARTERH.RHPESS_CONTRATO A
                                                    WHERE
                                                            A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                                        AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                                        AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                                                )
                                            AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                                            AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                                            AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                                            AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                                            AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                                            AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                                            /*AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                                            AND TRIM(C.DADO_ORIGEM) = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO);
        COMMIT;                     
        END IF;
          ----------------------------------------------------------------------------ATUALIZA A SIT FUNCIONAL PARA DESLIGADO--------------------------------------------------------------------
        IF ( C1.TIPO_VW_DADOS_SERVIDOR IN ('DESLIGAMENTO','DESLIGAMENTO_APOSENTADO') /*AND C1.CONTROLE_FOLHA_SEGUINTE NOT IN ( 'S' )*/ ) THEN
            -------------------------------------------------------------------------------ATUALIZAR O STATUS PARA EXCLUIDO-----------------------------------------------------------------------
            UPDATE ARTERH.RHUSER_P_SIST USUARIO
            SET
                USUARIO.STATUS_USUARIO = 'E',
                USUARIO.USUARIO_LDAP = NULL,
                USUARIO.LOGIN_USUARIO = 'INTEGRACAO_IFPONTO',
                USUARIO.DT_ULT_ALTER_USUA = SYSDATE,
                USUARIO.CODIGO_GRUPO = '0070',
                USUARIO.GRUPO_SEGURANCA = '0070',
                USUARIO.ULTIMO_PERFIL_ACESSO_AZC = '0070',
                USUARIO.PERMITE_INCLUSAO = 'N',
                USUARIO.PERMITE_EXCLUSAO = 'N',
                USUARIO.PERMITE_ALTERACAO = 'N',
                USUARIO.USA_SAL_PRINCIPAL = 'N',
                USUARIO.ALT_MV_PT_DT_RETRO = 'N',
                USUARIO.ALT_PONTO_DT_RETRO = 'N',
                USUARIO.PERMITE_EXECUCAO = 'N',
                USUARIO.MENU_DEF_ENABLED = 'N',
                USUARIO.ACERTO_BASE_HIST = 'N',
                USUARIO.ALT_CONT_DT_RETRO = 'N',
                USUARIO.ALT_PESS_DT_RETRO = 'N',
                USUARIO.EXIBE_DICA = 'N',
                USUARIO.MENU_DEF_VISIBLE = 'N',
                USUARIO.CODIGO_SGBD_PADRAO = NULL
            WHERE
                USUARIO.CODIGO_USUARIO IN (
                    SELECT
                        ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                    FROM
                        ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST
                    WHERE
                            ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                SELECT
                                    MAX(A.ANO_MES_REFERENCIA)
                                FROM
                                    ARTERH.RHPESS_CONTRATO A
                                WHERE
                                        A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                    AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                    AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                            )
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                        AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                        AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                        AND USUARIO.CODIGO_USUARIO = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                        AND USUARIO.CONTRATO_USUARIO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND USUARIO.TP_CONTR_USUARIO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND USUARIO.EMPRESA_USUARIO = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                     /*   AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                );

            COMMIT;
            -----------------------------------------RETIRAR OS GRUPOS DO USUARIO QUE ESTIVER NA SIT FUNCIONAL DE DESLIGADO------------------------------------------------------------------------------
            DELETE FROM ARTERH.RHUSER_RL_USR_GRP GRUPO
            WHERE
                GRUPO.CODIGO_USUARIO IN (
                    SELECT
                        ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                    FROM
                        ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST, ARTERH.RHUSER_RL_USR_GRP
                    WHERE
                            ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                SELECT
                                    MAX(A.ANO_MES_REFERENCIA)
                                FROM
                                    ARTERH.RHPESS_CONTRATO A
                                WHERE
                                        A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                    AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                    AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                            )
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                        AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                        AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                        AND ARTERH.RHUSER_P_SIST.CODIGO_USUARIO = ARTERH.RHUSER_RL_USR_GRP.CODIGO_USUARIO
                        AND GRUPO.CODIGO_USUARIO = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                       /* AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                )
                AND GRUPO.CODIGO_GRUPO <> '0070';

            COMMIT;
            ---------------------------------------------------------------------RETIRA O ACESSO DA TROCA GRUPO USUARIO E LISTA DOS LOGINS QUE NUNCA FECHAM-----------------------------------------------
            DELETE FROM ARTERH.RHINTE_ED_IT_CONV C
                     WHERE
                        C.CODIGO_CONVERSAO IN ('US20','US07') AND 
                        TRIM(C.DADO_ORIGEM) in (SELECT
                                            ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                                        FROM
                                            ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST, RHUSER_USR_SGBD
                                        WHERE
                                                ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                                    SELECT
                                                        MAX(A.ANO_MES_REFERENCIA)
                                                    FROM
                                                        ARTERH.RHPESS_CONTRATO A
                                                    WHERE
                                                            A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                                        AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                                        AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                                                )
                                            AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                                            AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                                            AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                                            AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                                            AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                                            AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                                            /*AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                                            AND TRIM(C.DADO_ORIGEM) = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO);
        COMMIT;                     
            -------------------------------------------------------------------------------------------------RETIRAR O CODIGO SGBD-------------------------------------------------------------------------
            DELETE FROM RHUSER_USR_SGBD SGDB
            WHERE
                SGDB.CODIGO_USUARIO IN (
                    SELECT
                        ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                    FROM
                        ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST, RHUSER_USR_SGBD
                    WHERE
                            ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                SELECT
                                    MAX(A.ANO_MES_REFERENCIA)
                                FROM
                                    ARTERH.RHPESS_CONTRATO A
                                WHERE
                                        A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                    AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                    AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                            )
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                        AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                        AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                        AND ARTERH.RHUSER_P_SIST.CODIGO_USUARIO = RHUSER_USR_SGBD.CODIGO_USUARIO
                        AND SGDB.CODIGO_USUARIO = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                        /*AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                );

            COMMIT;
            ------------------------------------------------------------------------------------RETIRAR O CODIGO EMPRESA--------------------------------------------------------------------------
            DELETE FROM RHUSER_RL_USR_EMP EMPRESA
            WHERE
                EMPRESA.CODIGO_USUARIO IN (
                    SELECT
                        ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                    FROM
                        ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST, RHUSER_RL_USR_EMP
                    WHERE
                            ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                SELECT
                                    MAX(A.ANO_MES_REFERENCIA)
                                FROM
                                    ARTERH.RHPESS_CONTRATO A
                                WHERE
                                        A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                    AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                    AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                            )
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                        AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                        AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                        AND ARTERH.RHUSER_P_SIST.CODIGO_USUARIO = RHUSER_RL_USR_EMP.CODIGO_USUARIO
                        AND EMPRESA.CODIGO_USUARIO = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                       /* AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                );

            COMMIT;
            ---------------------------------------------------------DELETA TIPO_CONTRATO--------------------------------------------------------------------------------------------------------------
            DELETE FROM RHUSER_USR_TPCONT EMPRESA
            WHERE
                EMPRESA.CODIGO_USUARIO IN (
                    SELECT
                        ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                    FROM
                        ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST
                    WHERE
                            ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                SELECT
                                    MAX(A.ANO_MES_REFERENCIA)
                                FROM
                                    ARTERH.RHPESS_CONTRATO A
                                WHERE
                                        A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                    AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                    AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                            )
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                        AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                        AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                  --    AND ARTERH.RHUSER_P_SIST.CODIGO_USUARIO                   = RHUSER_RL_USR_EMP.CODIGO_USUARIO
                        AND EMPRESA.CODIGO_USUARIO = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                       /* AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                );

            COMMIT;
            BEGIN
                DECLARE
                    VCONTE NUMBER;
                BEGIN
                    VCONTE := 0;
                    FOR C8 IN (
                        SELECT
                            ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                        FROM
                            ARTERH.RHPESS_CONTRATO,
                            ARTERH.RHUSER_P_SIST
                        WHERE
                                ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                SELECT
                                    MAX(A.ANO_MES_REFERENCIA)
                                FROM
                                    ARTERH.RHPESS_CONTRATO A
                                WHERE
                                        A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                    AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                    AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                            )
                            AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                            AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                            AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                            AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                            AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                            AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                            /*AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                     ) LOOP
                        VCONTE := VCONTE + 1;
                        BEGIN
                            INSERT INTO ARTERH.RHUSER_RL_USR_GRP (
                                CODIGO_USUARIO,
                                CODIGO_GRUPO,
                                LOGIN_USUARIO,
                                DT_ULT_ALTER_USUA
                            ) VALUES (
                                ''||C8.CODIGO_USUARIO|| '',
                                '0070',
                                'INTEGRACAO_IFPONTO',
                                SYSDATE
                            );

                            COMMIT;
                        EXCEPTION
                            WHEN OTHERS THEN
                                NULL;
                        END;

                    END LOOP;

                END;
            END;

        END IF;
          --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        IF (
            C1.TIPO_VW_DADOS_SERVIDOR = 'APOSENTOU'
            --AND C1.CONTROLE_FOLHA_SEGUINTE IN ( 'S' )
        ) THEN
            DELETE FROM ARTERH.RHUSER_RL_USR_GRP GRUPO
            WHERE
                GRUPO.CODIGO_USUARIO IN (
                    SELECT
                        ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                    FROM
                        ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST, ARTERH.RHUSER_RL_USR_GRP
                    WHERE
                            ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                SELECT
                                    MAX(A.ANO_MES_REFERENCIA)
                                FROM
                                    ARTERH.RHPESS_CONTRATO A
                                WHERE
                                        A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                    AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                    AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                            )
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                        AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                        AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                        AND ARTERH.RHUSER_P_SIST.CODIGO_USUARIO = ARTERH.RHUSER_RL_USR_GRP.CODIGO_USUARIO
                        AND GRUPO.CODIGO_USUARIO = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                        /*AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                        AND NOT EXISTS (SELECT RHINTE_ED_IT_CONV.DADO_ORIGEM FROM RHINTE_ED_IT_CONV WHERE RHINTE_ED_IT_CONV.CODIGO_CONVERSAO = 'US03' AND 
                                                                    INSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO,RHINTE_ED_IT_CONV.DADO_ORIGEM,-1) > 4)
                )
                /*AND GRUPO.CODIGO_GRUPO NOT IN ( '.001', 'SOGD', 'PE01', '0070' ); EM 20/06/2023 RAFAELLA, ALTERACAO DE ACORDO COM TABELA DE CONVERSAO ABAIXO*/
                AND GRUPO.CODIGO_GRUPO NOT IN ( '.001', 'SOGD', '0070' );
            ---------------------------------------------------------------------RETIRA O ACESSO DA TROCA GRUPO USUARIO E LISTA DOS LOGINS QUE NUNCA FECHAM-----------------------------------------------
            DELETE FROM ARTERH.RHINTE_ED_IT_CONV C
                     WHERE
                        C.CODIGO_CONVERSAO IN ('US20','US07') AND 
                        TRIM(C.DADO_ORIGEM) in (SELECT
                                            ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                                        FROM
                                            ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST, RHUSER_USR_SGBD
                                        WHERE
                                                ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                                    SELECT
                                                        MAX(A.ANO_MES_REFERENCIA)
                                                    FROM
                                                        ARTERH.RHPESS_CONTRATO A
                                                    WHERE
                                                            A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                                        AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                                        AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                                                )
                                            AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                                            AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                                            AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                                            AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                                            AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                                            AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                                            /*AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                                            AND TRIM(C.DADO_ORIGEM) = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO);
        COMMIT;                     
            -------------------------------------------------------------------------------------SOGD---------------------------------------------------------------------------------------------------
            DELETE FROM RHUSER_USR_SGBD SGDB
            WHERE
                SGDB.CODIGO_USUARIO IN (
                    SELECT
                        ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                    FROM
                        ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST, RHUSER_USR_SGBD
                    WHERE
                            ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                SELECT
                                    MAX(A.ANO_MES_REFERENCIA)
                                FROM
                                    ARTERH.RHPESS_CONTRATO A
                                WHERE
                                        A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                    AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                    AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                            )
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                        AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                        AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                        AND ARTERH.RHUSER_P_SIST.CODIGO_USUARIO = RHUSER_USR_SGBD.CODIGO_USUARIO
                        AND SGDB.CODIGO_USUARIO = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                       /* AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                );

            COMMIT;
            ---------------------------------------------------------------------------------------EMPRESA----------------------------------------------------------------------------------------------------
            --DELETAR AS DEMAIS E DEIXAR SOMENTE A C1.CODIGO_EMPRESA
            DELETE
            FROM RHUSER_RL_USR_EMP EMPRESA
            WHERE EMPRESA.CODIGO_USUARIO IN
              (SELECT ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
              FROM ARTERH.RHPESS_CONTRATO,
                ARTERH.RHUSER_P_SIST,
                RHUSER_RL_USR_EMP
              WHERE ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA =
                (SELECT MAX (A.ANO_MES_REFERENCIA)
                FROM ARTERH.RHPESS_CONTRATO A
                WHERE A.CODIGO       = ARTERH.RHPESS_CONTRATO.CODIGO
                AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                AND A.TIPO_CONTRATO  = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                )
              AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA ='' || C1.CODIGO_EMPRESA ||''
              AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO ||''
              AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
              AND ARTERH.RHPESS_CONTRATO.CODIGO                         = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
              AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO                  = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
              AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA                 = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
              AND ARTERH.RHUSER_P_SIST.CODIGO_USUARIO                   = RHUSER_RL_USR_EMP.CODIGO_USUARIO
              AND EMPRESA.CODIGO_USUARIO                                = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
              /*AND (SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO,9,3) NOT IN ('APB') OR (SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO,9,3)      IS NULL ))*/
              AND NOT EXISTS (SELECT RHINTE_ED_IT_CONV.DADO_ORIGEM FROM RHINTE_ED_IT_CONV WHERE RHINTE_ED_IT_CONV.CODIGO_CONVERSAO = 'US03' AND 
                                                                    INSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO,RHINTE_ED_IT_CONV.DADO_ORIGEM,-1) > 4)
              )
              AND EMPRESA.CODIGO_EMPRESA NOT IN ( '' || C1.CODIGO_EMPRESA || '' ) ;
            COMMIT;
            BEGIN
                INSERT INTO RHUSER_RL_USR_EMP (
                    CODIGO_USUARIO,
                    CODIGO_EMPRESA,
                    LOGIN_USUARIO,
                    DT_ULT_ALTER_USUA
                ) VALUES (
                    (
                        SELECT
                            X.*
                        FROM
                            (
                                SELECT
                                    ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                                FROM
                                    ARTERH.RHPESS_CONTRATO,
                                    ARTERH.RHUSER_P_SIST
                                WHERE
                                        ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                            SELECT
                                                MAX(A.ANO_MES_REFERENCIA)
                                            FROM
                                                ARTERH.RHPESS_CONTRATO A
                                            WHERE
                                                    A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                                AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                                AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                                        )
                                    AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                                    AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                                    AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                                    AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                                    AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                                    AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                                    /*AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                                    AND NOT EXISTS (SELECT RHINTE_ED_IT_CONV.DADO_ORIGEM FROM RHINTE_ED_IT_CONV WHERE RHINTE_ED_IT_CONV.CODIGO_CONVERSAO = 'US03' AND 
                                                                    INSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO,RHINTE_ED_IT_CONV.DADO_ORIGEM,-1) > 4)
                                    AND ARTERH.RHUSER_P_SIST.CODIGO_USUARIO = ARTERH.RHUSER_P_SIST.USUARIO_LDAP
                                    AND ARTERH.RHUSER_P_SIST.TIPO_LOGIN IN ('2','3') 
                                    AND ARTERH.RHUSER_P_SIST.CODIGO_SERV_AUTENT IN ('PWS1')
                            ) X
                            LEFT OUTER JOIN ARTERH.RHUSER_RL_USR_EMP EM ON EM.CODIGO_USUARIO = X.CODIGO_USUARIO
                        WHERE
                            NOT EXISTS (
                                SELECT
                                    *
                                FROM
                                    ARTERH.RHUSER_RL_USR_EMP AU
                                WHERE
                                        AU.CODIGO_USUARIO = EM.CODIGO_USUARIO
                                    AND AU.CODIGO_EMPRESA = '1700'
                            )
                    ),
                    '1700',
                    'INTEGRACAO_PONTO',
                    SYSDATE
                );

            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;


            -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
            UPDATE ARTERH.RHUSER_P_SIST USUARIO
            SET
                USUARIO.CODIGO_GRUPO = CASE WHEN C1.ANALISE_GUARDA = 'GUARDA' THEN 'PCGM' ELSE '.001' END,
                USUARIO.GRUPO_SEGURANCA = CASE WHEN C1.ANALISE_GUARDA = 'GUARDA' THEN 'PCGM' ELSE '.001' END,
                USUARIO.ULTIMO_PERFIL_ACESSO_AZC = CASE WHEN C1.ANALISE_GUARDA = 'GUARDA' THEN 'PCGM' ELSE '.001' END,
                USUARIO.PERMITE_INCLUSAO = 'N',
                USUARIO.PERMITE_EXCLUSAO = 'N',
                USUARIO.PERMITE_ALTERACAO = 'N',
                USUARIO.EMPRESA_SELEC = C1.CODIGO_EMPRESA,
                USUARIO.TIPO_CONTR_SELEC = C1.TIPO_CONTRATO,
                USUARIO.USA_SAL_PRINCIPAL = 'N',
                USUARIO.ALT_MV_PT_DT_RETRO = 'N',
                USUARIO.ALT_PONTO_DT_RETRO = 'N',
                USUARIO.PERMITE_EXECUCAO = 'N',
                USUARIO.MENU_DEF_ENABLED = 'N',
                USUARIO.ACERTO_BASE_HIST = 'N',
                USUARIO.ALT_CONT_DT_RETRO = 'N',
                USUARIO.ALT_PESS_DT_RETRO = 'N',
                USUARIO.EXIBE_DICA = 'N',
                USUARIO.MENU_DEF_VISIBLE = 'N',
                USUARIO.CODIGO_SGBD_PADRAO = NULL
            WHERE
                USUARIO.CODIGO_USUARIO IN (
                    SELECT
                        ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                    FROM
                        ARTERH.RHPESS_CONTRATO, ARTERH.RHUSER_P_SIST
                    WHERE
                            ARTERH.RHPESS_CONTRATO.ANO_MES_REFERENCIA = (
                                SELECT
                                    MAX(A.ANO_MES_REFERENCIA)
                                FROM
                                    ARTERH.RHPESS_CONTRATO A
                                WHERE
                                        A.CODIGO = ARTERH.RHPESS_CONTRATO.CODIGO
                                    AND A.CODIGO_EMPRESA = ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA
                                    AND A.TIPO_CONTRATO = ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO
                            )
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = '' || C1.CODIGO_EMPRESA || ''
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = '' || C1.TIPO_CONTRATO || ''
                        AND ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                        AND ARTERH.RHPESS_CONTRATO.CODIGO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.TIPO_CONTRATO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND ARTERH.RHPESS_CONTRATO.CODIGO_EMPRESA = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                        AND USUARIO.CODIGO_USUARIO = ARTERH.RHUSER_P_SIST.CODIGO_USUARIO
                        AND USUARIO.CONTRATO_USUARIO = ARTERH.RHUSER_P_SIST.CONTRATO_USUARIO
                        AND USUARIO.TP_CONTR_USUARIO = ARTERH.RHUSER_P_SIST.TP_CONTR_USUARIO
                        AND USUARIO.EMPRESA_USUARIO = ARTERH.RHUSER_P_SIST.EMPRESA_USUARIO
                       /* AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                       AND NOT EXISTS (SELECT RHINTE_ED_IT_CONV.DADO_ORIGEM FROM RHINTE_ED_IT_CONV WHERE RHINTE_ED_IT_CONV.CODIGO_CONVERSAO = 'US03' AND 
                                                                    INSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO,RHINTE_ED_IT_CONV.DADO_ORIGEM,-1) > 4)
                       AND ARTERH.RHUSER_P_SIST.CODIGO_USUARIO = ARTERH.RHUSER_P_SIST.USUARIO_LDAP
                       AND ARTERH.RHUSER_P_SIST.TIPO_LOGIN IN ('2','3') 
                       AND ARTERH.RHUSER_P_SIST.CODIGO_SERV_AUTENT IN ('PWS1')
                );

            COMMIT;
        END IF;
---------------ALTERADO AQUI EM 30/01/2020 A PEDIDO DO LUCA PARA CONTEMPLAR A READMISSAO DOS ESTAGIARIOS REGRA DECIDIDA PELA RAFAELLA
        IF ( C1.TIPO_VW_DADOS_SERVIDOR = 'READMISSAO' AND C1.VINCULO NOT IN ( '0009' ) )
        THEN
            BEGIN
                DECLARE
                    CONT NUMBER;
                BEGIN
                    CONT := 0;
                    FOR C2 IN (
                        SELECT
                            STATUS_USUARIO,
                            USUARIO_LDAP,
                            CODIGO_GRUPO,
                            CODIGO_USUARIO,
                            C1.ANALISE_GUARDA
                        FROM
                            ARTERH.RHUSER_P_SIST
                        WHERE
                                CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                            AND EMPRESA_USUARIO = '' || C1.CODIGO_EMPRESA || ''
                            AND TP_CONTR_USUARIO = '' || C1.TIPO_CONTRATO || ''
                            AND TIPO_LOGIN IN ('2','3') 
                            AND CODIGO_SERV_AUTENT IN ('PWS1')
                            /*AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                            AND NOT EXISTS (SELECT RHINTE_ED_IT_CONV.DADO_ORIGEM FROM RHINTE_ED_IT_CONV WHERE RHINTE_ED_IT_CONV.CODIGO_CONVERSAO = 'US03' AND 
                                                                    INSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO,RHINTE_ED_IT_CONV.DADO_ORIGEM,-1) > 4)
                    ) LOOP
                        CONT := CONT + 1;
                        UPDATE ARTERH.RHUSER_P_SIST
                        SET
                            STATUS_USUARIO = 'A',
                            USUARIO_LDAP = '' || C2.CODIGO_USUARIO || '',
                            CODIGO_GRUPO = CASE WHEN C1.VINCULO = '0009' THEN '.080' WHEN C1.ANALISE_GUARDA = 'GUARDA' THEN 'PCGM' ELSE '.001' END,
                            GRUPO_SEGURANCA = CASE WHEN C1.VINCULO = '0009' THEN '.080' WHEN C1.ANALISE_GUARDA = 'GUARDA' THEN 'PCGM' ELSE '.001' END,
                            ULTIMO_PERFIL_ACESSO_AZC = CASE WHEN C1.VINCULO = '0009' THEN '.080' WHEN C1.ANALISE_GUARDA = 'GUARDA' THEN 'PCGM' ELSE '.001' END,
                            LOGIN_USUARIO = 'INTEGRACAO_IFPONTO',
                            DT_ULT_ALTER_USUA = SYSDATE,
                            DATA_SISTEMA = TO_DATE(SYSDATE,'DD/MM/YYYY'),
                            ANO_BASE = TO_DATE('01/01/'||TO_CHAR(SYSDATE,'YYYY'),'DD/MM/YYYY')
                            
                        WHERE
                                CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                            AND EMPRESA_USUARIO = '' || C1.CODIGO_EMPRESA || ''
                            AND TP_CONTR_USUARIO = '' || C1.TIPO_CONTRATO || ''
                           /* AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                            AND NOT EXISTS (SELECT RHINTE_ED_IT_CONV.DADO_ORIGEM FROM RHINTE_ED_IT_CONV WHERE RHINTE_ED_IT_CONV.CODIGO_CONVERSAO = 'US03' AND 
                                                                    INSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO,RHINTE_ED_IT_CONV.DADO_ORIGEM,-1) > 4)
                            AND ARTERH.RHUSER_P_SIST.TIPO_LOGIN IN ('2','3') 
                            AND ARTERH.RHUSER_P_SIST.CODIGO_SERV_AUTENT IN ('PWS1'); COMMIT;
                            
                            DELETE FROM ARTERH.RHUSER_RL_USR_GRP GRUPO WHERE GRUPO.CODIGO_USUARIO = '' || C2.CODIGO_USUARIO || '' 
                            AND GRUPO.CODIGO_GRUPO IN (SELECT REGEXP_SUBSTR(DADO_ORIGEM, '[^;]+',1, 2) AS GRUPO FROM RHINTE_ED_IT_CONV WHERE CODIGO_CONVERSAO = 'US01' AND DADO_DESTINO = 'EXCLUIR');
                            COMMIT;

                        BEGIN
                            DECLARE
                                VCONT NUMBER;
                            BEGIN
                                VCONT := 0;
                                FOR C2 IN (
                                    SELECT
                                        A.CODIGO_USUARIO, C1.ANALISE_GUARDA
                                    FROM
                                        ARTERH.RHUSER_P_SIST A
                                    WHERE
                                        NOT EXISTS (SELECT RHINTE_ED_IT_CONV.DADO_ORIGEM FROM RHINTE_ED_IT_CONV WHERE RHINTE_ED_IT_CONV.CODIGO_CONVERSAO = 'US03' AND 
                                                                    INSTR(A.CODIGO_USUARIO,RHINTE_ED_IT_CONV.DADO_ORIGEM,-1) > 4)
                                            /*( SUBSTR(A.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB'  )                                          OR ( SUBSTR(A.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                                        AND NOT EXISTS (
                                            SELECT
                                                *
                                            FROM
                                                ARTERH.RHUSER_RL_USR_GRP
                                            WHERE
                                                A.CODIGO_USUARIO = ARTERH.RHUSER_RL_USR_GRP.CODIGO_USUARIO
                                        )
                                        AND A.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                                        AND A.EMPRESA_USUARIO = '' || C1.CODIGO_EMPRESA || ''
                                        AND A.TP_CONTR_USUARIO = '' || C1.TIPO_CONTRATO || ''
                                        AND A.TIPO_LOGIN IN ('2','3') 
                                        AND A.CODIGO_SERV_AUTENT IN ('PWS1')
                                ) LOOP
                                    VCONT := VCONT + 1;
                                    BEGIN
                                        DECLARE
                                            VCONTADOR NUMBER;
                                        BEGIN
                                            VCONTADOR := 0;
                                            FOR C3 IN (
                                                SELECT
                                                    CODIGO_GRUPO
                                                FROM
                                                    ARTERH.RHUSER_RL_USR_GRP
                                                WHERE
                                                    CODIGO_USUARIO = 'MODELO'
                                            ) LOOP
                                                VCONTADOR := VCONTADOR + 1;
                                                BEGIN
                                                    INSERT INTO ARTERH.RHUSER_RL_USR_GRP (
                                                        CODIGO_USUARIO,
                                                        CODIGO_GRUPO,
                                                        LOGIN_USUARIO,
                                                        DT_ULT_ALTER_USUA
                                                    ) VALUES (
                                                        ''||C2.CODIGO_USUARIO || '',
                                                        CASE
                                                           WHEN C2.ANALISE_GUARDA = 'GUARDA' AND C3.CODIGO_GRUPO = '.001' THEN 'PCGM' /*ASSOCIAR O GRUPO DE PORTAL PARA OS GUARDAS*/
                                                           WHEN C2.ANALISE_GUARDA = 'OUTRO' AND C3.CODIGO_GRUPO = '.001' THEN '.001' 
                                                           ELSE C3.CODIGO_GRUPO END,
                                                        'INTEGRACAO_IFPONTO',
                                                        SYSDATE
                                                    );

                                                    COMMIT;
                                                EXCEPTION
                                                    WHEN OTHERS THEN
                                                        NULL;
                                                END;

                                            END LOOP;

                                        END;

                                    END;

                                END LOOP;

                            END;
                        END;

                    END LOOP;

                END;

            END;
        END IF;

        IF
            ( C1.TIPO_VW_DADOS_SERVIDOR = 'READMISSAO' )
            AND C1.VINCULO IN ( '0009' )
        THEN
            BEGIN
                DECLARE
                    CONT NUMBER;
                BEGIN
                    CONT := 0;
                    FOR C2 IN (
                        SELECT
                            STATUS_USUARIO,
                            USUARIO_LDAP,
                            CODIGO_GRUPO,
                            CODIGO_USUARIO
                        FROM
                            ARTERH.RHUSER_P_SIST
                        WHERE
                                CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                            AND EMPRESA_USUARIO = '' || C1.CODIGO_EMPRESA || ''
                            AND TP_CONTR_USUARIO = '' || C1.TIPO_CONTRATO || ''
                            AND TIPO_LOGIN IN ('2','3') 
                            AND CODIGO_SERV_AUTENT IN ('PWS1')
                            /*AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                            AND NOT EXISTS (SELECT RHINTE_ED_IT_CONV.DADO_ORIGEM FROM RHINTE_ED_IT_CONV WHERE RHINTE_ED_IT_CONV.CODIGO_CONVERSAO = 'US03' AND 
                                                                    INSTR(RHUSER_P_SIST.CODIGO_USUARIO,RHINTE_ED_IT_CONV.DADO_ORIGEM,-1) > 4)
                    ) LOOP
                        CONT := CONT + 1;
                        UPDATE ARTERH.RHUSER_P_SIST
                        SET
                            STATUS_USUARIO = 'A',
                            USUARIO_LDAP = '' || C2.CODIGO_USUARIO || '',
                            CODIGO_GRUPO = '.080',
                            GRUPO_SEGURANCA = '.080',
                            ULTIMO_PERFIL_ACESSO_AZC = '.080',
                            LOGIN_USUARIO = 'INTEGRACAO_IFPONTO',
                            DT_ULT_ALTER_USUA = SYSDATE,
                            DATA_SISTEMA = TO_DATE(SYSDATE,'DD/MM/YYYY'),
                            ANO_BASE = TO_DATE('01/01/'||TO_CHAR(SYSDATE,'YYYY'),'DD/MM/YYYY')
                        WHERE
                                CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                            AND EMPRESA_USUARIO = '' || C1.CODIGO_EMPRESA || ''
                            AND TP_CONTR_USUARIO = '' || C1.TIPO_CONTRATO || ''
                            /*AND ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(ARTERH.RHUSER_P_SIST.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                            AND NOT EXISTS (SELECT RHINTE_ED_IT_CONV.DADO_ORIGEM FROM RHINTE_ED_IT_CONV WHERE RHINTE_ED_IT_CONV.CODIGO_CONVERSAO = 'US03' AND 
                                                                    INSTR(RHUSER_P_SIST.CODIGO_USUARIO,RHINTE_ED_IT_CONV.DADO_ORIGEM,-1) > 4)
                            AND ARTERH.RHUSER_P_SIST.TIPO_LOGIN IN ('2','3') 
                            AND ARTERH.RHUSER_P_SIST.CODIGO_SERV_AUTENT IN ('PWS1') ;
                            COMMIT;
                            
                            DELETE FROM ARTERH.RHUSER_RL_USR_GRP GRUPO WHERE GRUPO.CODIGO_USUARIO = '' || C2.CODIGO_USUARIO || '' 
                            AND GRUPO.CODIGO_GRUPO IN (SELECT REGEXP_SUBSTR(DADO_ORIGEM, '[^;]+',1, 2) AS GRUPO FROM RHINTE_ED_IT_CONV WHERE CODIGO_CONVERSAO = 'US01' AND DADO_DESTINO = 'EXCLUIR');
                            COMMIT;

                        BEGIN
                            DECLARE
                                VCONT NUMBER;
                            BEGIN
                                VCONT := 0;
                                FOR C2 IN (
                                    SELECT
                                        A.CODIGO_USUARIO
                                    FROM
                                        ARTERH.RHUSER_P_SIST A
                                    WHERE
                                       NOT EXISTS (SELECT RHINTE_ED_IT_CONV.DADO_ORIGEM FROM RHINTE_ED_IT_CONV WHERE RHINTE_ED_IT_CONV.CODIGO_CONVERSAO = 'US03' AND 
                                                                    INSTR(A.CODIGO_USUARIO,RHINTE_ED_IT_CONV.DADO_ORIGEM,-1) > 4)
                                       /* ( SUBSTR(A.CODIGO_USUARIO, 9, 3) NOT IN ( 'APB' ) OR ( SUBSTR(A.CODIGO_USUARIO, 9, 3) IS NULL ) )*/
                                        AND NOT EXISTS (
                                            SELECT
                                                *
                                            FROM
                                                ARTERH.RHUSER_RL_USR_GRP
                                            WHERE
                                                A.CODIGO_USUARIO = ARTERH.RHUSER_RL_USR_GRP.CODIGO_USUARIO
                                        )
                                        AND A.CONTRATO_USUARIO = '' || C1.CODIGO_CONTRATO || ''
                                        AND A.EMPRESA_USUARIO = '' || C1.CODIGO_EMPRESA || ''
                                        AND A.TP_CONTR_USUARIO = '' || C1.TIPO_CONTRATO || ''
                                        AND A.TIPO_LOGIN IN ('2','3') 
                                        AND A.CODIGO_SERV_AUTENT IN ('PWS1')
                                ) LOOP
                                    VCONT := VCONT + 1;
                                    BEGIN
                                        DECLARE
                                            VCONTADOR NUMBER;
                                        BEGIN
                                            VCONTADOR := 0;
                                            FOR C3 IN (
                                                SELECT
                                                    CODIGO_GRUPO
                                                FROM
                                                    ARTERH.RHUSER_RL_USR_GRP
                                                WHERE
                                                    CODIGO_USUARIO = 'MODELO_ESTAGIARIO'
                                            ) LOOP
                                                VCONTADOR := VCONTADOR + 1;
                                                BEGIN
                                                    INSERT INTO ARTERH.RHUSER_RL_USR_GRP (
                                                        CODIGO_USUARIO,
                                                        CODIGO_GRUPO,
                                                        LOGIN_USUARIO,
                                                        DT_ULT_ALTER_USUA
                                                    ) VALUES (
                                                        ''
                                                        || C2.CODIGO_USUARIO
                                                        || '',
                                                        ''
                                                        || C3.CODIGO_GRUPO
                                                        || '',
                                                        'INTEGRACAO_IFPONTO',
                                                        SYSDATE
                                                    );

                                                EXCEPTION
                                                    WHEN OTHERS THEN
                                                        NULL;
                                                END;

                                            END LOOP;

                                        END;

                                    END;

                                END LOOP;

                            END;
                        END;

                    END LOOP;

                END;

            END;
        END IF;

    END LOOP; --END LOOP
END; --FIM PROCEDURE