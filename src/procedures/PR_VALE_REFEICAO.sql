
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_VALE_REFEICAO" ( vTP_CONTRATO CHAR,vCOD_EMPRESA CHAR, vDATA_INI DATE , vdata_fim DATE, vdt_corte date)
    /*PROCEDURE INICIAL CRIADA PARA VALIDAR OS VALES ATIVOS DAS PESSOAS (PELO CPF)
    SE O CONTRATO POSSUIR DATA DE RESCISAO O VALE ABERTO VINCULADO A ELE RECEBE UMA DATA FIM.
    */
    AS
      CONT    NUMBER;
      RETORNO CHAR (1 BYTE);
      err_msg VARCHAR2(4000 BYTE);
      SGE     NUMBER:=0;

    BEGIN
      --raise_application_error (-20002,vdata_fim);
      EXECUTE immediate('INSERT INTO SMARH_INT_DIA_EXECUCAO(ID_EXECUCAO,DESCRICAO,DATA_EXECUCAO) VALUES(ID_SEQ_VALE_DIA.NEXTVAL,''EXECUCAO_DIARIA_VALE'',SYSDATE)');
      CONT:=CONT+1;
      FOR C1   IN
      (SELECT C.CODIGO_EMPRESA,
        C.TIPO_CONTRATO,
        C.CODIGO      AS CODIGO_CONTRATO ,
        P.CODIGO      AS CODIGO_PESSOA,
        P.NOME_ACESSO AS NOME,
        SF.controle_folha,
        c.vinculo,
        P.CPF,
        C.DATA_EFETIVO_EXERC               AS EFETIVO_EXERCICIO,
        C.DATA_RESCISAO                    AS DATA_DESLIGAMENTO,
        SF.CODIGO                          AS SITUACAO_FUNCIONAL,
        SF.DESCRICAO                       AS NOME_SITUACAO_FUNCIONAL,
        G.COD_CGERENC1                     AS COD_UNIDADE1,
        G.COD_CGERENC2                     AS COD_UNIDADE2,
        G.COD_CGERENC3                     AS COD_UNIDADE3,
        G.COD_CGERENC4                     AS COD_UNIDADE4,
        G.COD_CGERENC5                     AS COD_UNIDADE5,
        G.COD_CGERENC6                     AS COD_UNIDADE6,
        NVL(G.DESCRICAO,g.texto_associado) AS nome_unidade,
        EL.CODIGO                          AS ESCALA,
        C.DT_ULT_ESCALA                    AS DATA_INI_ESCALA,
        EL.DESCRICAO                       AS NOME_ESCALA,
        EL.JORNADA_DIARIA JORNADA_DIA,
        CASE
          WHEN C.DATA_RESCISAO IS NOT NULL
          THEN 'N'
          ELSE 'S'
        END AS GERA_VALE  FROM ARTERH.RHPESS_CONTRATO C
      LEFT OUTER JOIN ARTERH.RHPESS_PESSOA P
      ON P.CODIGO_EMPRESA=C.CODIGO_EMPRESA
      AND P.CODIGO       =C.CODIGO_PESSOA
      LEFT OUTER JOIN ARTERH.RHORGA_CUSTO_GEREN G
      ON G.CODIGO_EMPRESA=C.CODIGO_EMPRESA
      AND G.COD_CGERENC1 =C.COD_CUSTO_GERENC1
      AND G.COD_CGERENC2 =C.COD_CUSTO_GERENC2
      AND G.COD_CGERENC3 =C.COD_CUSTO_GERENC3
      AND G.COD_CGERENC4 =C.COD_CUSTO_GERENC4
      AND G.COD_CGERENC5 =C.COD_CUSTO_GERENC5
      AND G.COD_CGERENC6 =C.COD_CUSTO_GERENC6
      LEFT OUTER JOIN RHPONT_ESCALA EL
      ON EL.CODIGO_EMPRESA=C.CODIGO_EMPRESA
      AND EL.CODIGO       =C.CODIGO_ESCALA
      LEFT OUTER JOIN RHPARM_SIT_FUNC SF
      ON SF.CODIGO              =C.SITUACAO_FUNCIONAL
      WHERE C.ANO_MES_REFERENCIA=
        (SELECT MAX(AUX.ANO_MES_REFERENCIA)
        FROM ARTERH.RHPESS_CONTRATO AUX
        WHERE AUX.CODIGO           =C.CODIGO
        AND AUX.TIPO_CONTRATO      =C.TIPO_CONTRATO
        AND AUX.CODIGO_EMPRESA     =C.CODIGO_EMPRESA
        AND AUX.ANO_MES_REFERENCIA<=vdata_fim
        )
      AND C.CODIGO_EMPRESA=vCOD_EMPRESA
      AND C.TIPO_CONTRATO =vTP_CONTRATO
      AND P.CPF  IN ('99313375672', '22152920678', '69184585668', '90775759600', '00015336654', '02891535650', '01394035667','06007680665' )
      AND C.DATA_EFETIVO_EXERC IS NOT NULL

      AND NOT EXISTS (SELECT * FROM ARTERH.RHINTE_ED_IT_CONV WHERE RHINTE_ED_IT_CONV.CODIGO_CONVERSAO='EXVR' AND c.CODIGO=LPAD(trim(RHINTE_ED_IT_CONV.DADO_DESTINO),15,0))

      AND   C.VINCULO NOT IN ('0055') /* JETON - ESOCIAL*/
      AND ( C.VINCULO NOT IN ('0014') OR ( C.VINCULO IN ('0014') AND C.CODIGO_FUNCAO NOT IN '000000000002014' )) /* PARA REMOVER OS CONSELHEIROS TUTELARES SUPLENTES*/
     /* AND ( C.TIPO_CONTRATO NOT IN ('0098') OR ( C.TIPO_CONTRATO IN ('0098' ) AND C.COD_CARGO_PAGTO IN ( SELECT LPAD(DADO_ORIGEM,15,0) AS CARGOS FROM ARTERH.RHINTE_ED_IT_CONV WHERE RHINTE_ED_IT_CONV.CODIGO_CONVERSAO='VRCT' )) )  *//* PARA INCLUIR OS CONTRATOS ADM QUE TEM DIREITO*/

      )
      LOOP
        CONT   :=CONT+1;
        RETORNO:=VERIFICA_SEGUNDO_BM(C1.CODIGO_EMPRESA,C1.TIPO_CONTRATO ,C1.CODIGO_CONTRATO );
        SGE    :=VALIDA_SGE(C1.CPF,C1.TIPO_CONTRATO,C1.CODIGO_EMPRESA, vDATA_INI);
        IF SGE  =0 AND C1.DATA_DESLIGAMENTO IS NULL and c1.controle_folha not in ('D','S') THEN
          BEGIN
            INSERT
            INTO SMARH_INT_VALE
              (
                ID_VALE,
                ID_EXECUCAO,
                CODIGO_EMPRESA,
                TIPO_CONTRATO,
                CODIGO_CONTRATO,
                CPF,
                NOME,
                SITUACAO_FUNCIONAL,
                NOME_SITUACAO_FUNCIONAL,
                EFETIVO_EXERCICIO,
                DATA_DESLIGAMENTO,
                COD_UNIDADE1,
                COD_UNIDADE2,
                COD_UNIDADE3,
                COD_UNIDADE4,
                COD_UNIDADE5,
                COD_UNIDADE6,
                NOME_UNIDADE,
                ESCALA,
                DATA_INI_ESCALA,
                NOME_ESCALA,
                JORNADA_DIA,
                DOIS_CONTRATOS,
                DATA_SAIU_ARTE,
                GERA_VALE
              )
              VALUES
              (
                ID_SEQ_VALE.NEXTVAL,
                (SELECT MAX(ID_EXECUCAO) FROM ARTERH.SMARH_INT_DIA_EXECUCAO
                ),
                C1.CODIGO_EMPRESA,
                C1.TIPO_CONTRATO,
                C1.CODIGO_CONTRATO,
                C1.CPF,
                C1.NOME,
                C1.SITUACAO_FUNCIONAL,
                C1.NOME_SITUACAO_FUNCIONAL,
                C1.EFETIVO_EXERCICIO,
                C1.DATA_DESLIGAMENTO,
                C1.COD_UNIDADE1,
                C1.COD_UNIDADE2,
                C1.COD_UNIDADE3,
                C1.COD_UNIDADE4,
                C1.COD_UNIDADE5,
                C1.COD_UNIDADE6,
                C1.NOME_UNIDADE,
                C1.ESCALA,
                C1.DATA_INI_ESCALA,
                C1.NOME_ESCALA,
                C1.JORNADA_DIA,
                RETORNO,
                SYSDATE,
                C1.GERA_VALE
              );
            COMMIT;
          EXCEPTION
          WHEN OTHERS THEN
            err_msg := SUBSTR(SQLERRM, 1, 4000);
            GRAVA_ERRO(C1.CODIGO_EMPRESA,C1.TIPO_CONTRATO,C1.CODIGO_CONTRATO,SQLCODE,err_msg,'PR_VALE_REFEICAO');
          END;

        END IF;

        IF C1.DATA_DESLIGAMENTO IS NOT NULL or c1.controle_folha in ('D','S')  THEN
          BEGIN
            FOR C4 IN
            (SELECT VL.CODIGO_EMPRESA,
                VL.TIPO_CONTRATO,
                VL.CODIGO_CONTRATO,
                P.CPF,
                VL.DATA_INI_VIGENCIA,
                VL.DATA_FIM_VIGENCIA,
                VL.CODIGO_LINHA,
                VL.CODIGO_ITINERARIO,
                VL.OCORRENCIA,
                VL.TIPO_DIA
              FROM RHVALE_TRANSPORTE VL
              LEFT OUTER JOIN RHVALE_ITINERARIO IT
              ON IT.CODIGO=VL.CODIGO_ITINERARIO
              LEFT OUTER JOIN RHVALE_LINHA_TRANS LI
              ON LI.CODIGO    =VL.CODIGO_LINHA
              AND IT.TIPO_VALE=LI.TIPO_VALE
              LEFT OUTER JOIN
                (SELECT *
                FROM RHPESS_CONTRATO CN
                WHERE CN.ANO_MES_REFERENCIA=
                  (SELECT MAX(AUX.ANO_MES_REFERENCIA)
                  FROM RHPESS_CONTRATO AUX
                  WHERE AUX.TIPO_CONTRATO=CN.TIPO_CONTRATO
                  AND AUX.CODIGO_EMPRESA =CN.CODIGO_EMPRESA
                  AND AUX.CODIGO         = CN.CODIGO
                  )
                ) CN
              ON CN.CODIGO         =VL.CODIGO_CONTRATO
              AND CN.TIPO_CONTRATO =VL.TIPO_CONTRATO
              AND CN.CODIGO_EMPRESA=VL.CODIGO_EMPRESA
              LEFT OUTER JOIN RHPESS_PESSOA P
              ON P.CODIGO             =CN.CODIGO_PESSOA
              AND P.CODIGO_EMPRESA    =CN.CODIGO_EMPRESA
              WHERE CN.CODIGO_EMPRESA =c1.codigo_empresa
              AND CN.TIPO_CONTRATO    =c1.tipo_contrato
              AND LI.TIPO_VALE        ='0002'
              AND CN.CODIGO= C1.CODIGO_CONTRATO
              AND VL.DATA_FIM_VIGENCIA IS NULL
              AND  VL.CODIGO_LINHA NOT IN (SELECT DADO_DESTINO FROM ARTERH.RHINTE_ED_IT_CONV XL WHERE XL.CODIGO_CONVERSAO='VRLC' AND TRIM(VL.CODIGO_LINHA)=TRIM(XL.DADO_ORIGEM))
            )
            LOOP

              IF (( NVL(C4.DATA_INI_VIGENCIA,TO_DATE('01/01/1900','DD/MM/YYYY'))<C1.DATA_DESLIGAMENTO ))  THEN
             --DBMS_Output.PUT_LINE('Entrou no excluir '||C4.CODIGO_CONTRATO);

                UPDATE ARTERH.RHVALE_TRANSPORTE
                SET DATA_FIM_VIGENCIA =NVL(C4.DATA_INI_VIGENCIA,C1.DATA_DESLIGAMENTO),
                  TEXTO_ASSOCIADO     = 'REGISTRO FINALIZADO PELA ROTINA AUTOMATICA DO VALE',
                  LOGIN_USUARIO       = 'PR_GERA_VALE_AUTOMATICO',
                  DT_ULT_ALTER_USUA   = SYSDATE
                WHERE CODIGO_CONTRATO =C4.CODIGO_CONTRATO
                AND TIPO_CONTRATO     =C4.TIPO_CONTRATO
                AND CODIGO_EMPRESA    =C4.CODIGO_EMPRESA
                AND CODIGO_LINHA      =C4.CODIGO_LINHA
                AND CODIGO_ITINERARIO =C4.CODIGO_ITINERARIO
                AND OCORRENCIA  = c4.OCORRENCIA
                and TIPO_DIA = c4.TIPO_DIA;


              ELSIF((NVL(C4.DATA_INI_VIGENCIA,TO_DATE('01/01/1900','DD/MM/YYYY'))>C1.DATA_DESLIGAMENTO)) THEN 
                 UPDATE ARTERH.RHVALE_TRANSPORTE
                SET DATA_FIM_VIGENCIA =C1.DATA_DESLIGAMENTO,
                  TEXTO_ASSOCIADO     = 'REGISTRO FINALIZADO PELA ROTINA AUTOMATICA DO VALE',
                  LOGIN_USUARIO       = 'PR_GERA_VALE_AUTOMATICO',
                  DT_ULT_ALTER_USUA   = SYSDATE
                WHERE CODIGO_CONTRATO =C4.CODIGO_CONTRATO
                AND TIPO_CONTRATO     =C4.TIPO_CONTRATO
                AND CODIGO_EMPRESA    =C4.CODIGO_EMPRESA
                AND CODIGO_LINHA      =C4.CODIGO_LINHA
                AND CODIGO_ITINERARIO =C4.CODIGO_ITINERARIO
                AND OCORRENCIA  = c4.OCORRENCIA
                and TIPO_DIA = c4.TIPO_DIA;

              END IF;
            END LOOP;
          END;
      END IF;
      END LOOP;
          BEGIN
        ARTERH.PR_CRIAR_VALE_V2(vDATA_INI,vdata_fim,vdt_corte);
      END;
    END;