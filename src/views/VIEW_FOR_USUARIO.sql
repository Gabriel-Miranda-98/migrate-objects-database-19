
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "PONTO_ELETRONICO"."VIEW_FOR_USUARIO" ("TIPO_VW_DADOS_SERVIDOR", "E_CADASTRO_NOVO", "ALTEROU_LOCAL", "ALTEROU_NOME", "ALTEROU_CONTROLE_FOLHA", "ALTEROU_E_GESTOR", "ANALISE_GUARDA", "TIPO_PESSOA", "APELIDO", "CODIGO_EMPRESA", "TIPO_CONTRATO", "CODIGO_CONTRATO", "VINCULO", "ORDEM_BM", "NOME", "NOME_SEGUINTE", "DIA", "DIA_SEGUINTE", "TIPO", "TIPO_SEGUINTE", "INTEGRADO", "INTEGRADO_SEGUINTE", "DATA_ADMISSAO", "COD_UNIDADE1", "COD_UNIDADE1_SEGUINTE", "COD_UNIDADE2", "COD_UNIDADE2_SEGUINTE", "COD_UNIDADE3", "COD_UNIDADE3_SEGUINTE", "COD_UNIDADE4", "COD_UNIDADE4_SEGUINTE", "COD_UNIDADE5", "COD_UNIDADE5_SEGUINTE", "COD_UNIDADE6", "COD_UNIDADE6_SEGUINTE", "DESCRICAO_UNIDADE", "DESCRICAO_UNIDADE_SEGUINTE", "SITUACAO_FUNCIONAL", "SITUACAO_FUNCIONAL_SEGUINTE", "NOME_SIT_FUNC", "NOME_SIT_FUNC_SEGUINTE", "CONTROLE_FOLHA", "CONTROLE_FOLHA_SEGUINTE", "DATA_RESCISAO", "DATA_RESCISAO_SEGUINTE", "CODIGO_EMPRESA_GESTOR", "CODIGO_EMPRESA_GESTOR_SEGUINTE", "TIPO_CONTRATO_GESTOR", "TIPO_CONTRATO_GESTOR_SEGUINTE", "CONTRATO_GESTOR", "CONTRATO_GESTOR_SEGUINTE", "CPF_GESTOR", "CPF_GESTOR_SEGUINTE", "E_GESTOR", "E_GESTOR_SEGUINTE", "TIPO_USUARIO", "TIPO_USUARIO_SEGUINTE", "DT_SAIU_ARTE", "CODIGO_LEGADO", "CODIGO_LEGADO_SEGUINTE", "TEM_CARGO_EFETIVO", "TEM_CARGO_EFETIVO_SEGUINTE", "CHAVE_INTEGRACAO", "CHAVE_INTEGRACAO_SEGUINTE", "SUSPENDE_REMUNERA", "SUSPENDE_REMUNERA_SEGUINTE", "E_AFASTAMENTO", "E_AFASTAMENTO_SEGUINTE", "PESSOA_GESTOR") AS 
  SELECT XXXX.TIPO_VW_DADOS_SERVIDOR,XXXX.E_CADASTRO_NOVO,XXXX.ALTEROU_LOCAL,XXXX.ALTEROU_NOME,XXXX.ALTEROU_CONTROLE_FOLHA,XXXX.ALTEROU_E_GESTOR,XXXX.ANALISE_GUARDA,XXXX.TIPO_PESSOA,XXXX.APELIDO,XXXX.CODIGO_EMPRESA,XXXX.TIPO_CONTRATO,XXXX.CODIGO_CONTRATO,XXXX.VINCULO,XXXX.ORDEM_BM,XXXX.NOME,XXXX.NOME_SEGUINTE,XXXX.DIA,XXXX.DIA_SEGUINTE,XXXX.TIPO,XXXX.TIPO_SEGUINTE,XXXX.INTEGRADO,XXXX.INTEGRADO_SEGUINTE,XXXX.DATA_ADMISSAO,XXXX.COD_UNIDADE1,XXXX.COD_UNIDADE1_SEGUINTE,XXXX.COD_UNIDADE2,XXXX.COD_UNIDADE2_SEGUINTE,XXXX.COD_UNIDADE3,XXXX.COD_UNIDADE3_SEGUINTE,XXXX.COD_UNIDADE4,XXXX.COD_UNIDADE4_SEGUINTE,XXXX.COD_UNIDADE5,XXXX.COD_UNIDADE5_SEGUINTE,XXXX.COD_UNIDADE6,XXXX.COD_UNIDADE6_SEGUINTE,XXXX.DESCRICAO_UNIDADE,XXXX.DESCRICAO_UNIDADE_SEGUINTE,XXXX.SITUACAO_FUNCIONAL,XXXX.SITUACAO_FUNCIONAL_SEGUINTE,XXXX.NOME_SIT_FUNC,XXXX.NOME_SIT_FUNC_SEGUINTE,XXXX.CONTROLE_FOLHA,XXXX.CONTROLE_FOLHA_SEGUINTE,XXXX.DATA_RESCISAO,XXXX.DATA_RESCISAO_SEGUINTE,XXXX.CODIGO_EMPRESA_GESTOR,XXXX.CODIGO_EMPRESA_GESTOR_SEGUINTE,XXXX.TIPO_CONTRATO_GESTOR,XXXX.TIPO_CONTRATO_GESTOR_SEGUINTE,XXXX.CONTRATO_GESTOR,XXXX.CONTRATO_GESTOR_SEGUINTE,XXXX.CPF_GESTOR,XXXX.CPF_GESTOR_SEGUINTE,XXXX.E_GESTOR,XXXX.E_GESTOR_SEGUINTE,XXXX.TIPO_USUARIO,XXXX.TIPO_USUARIO_SEGUINTE,XXXX.DT_SAIU_ARTE,XXXX.CODIGO_LEGADO,XXXX.CODIGO_LEGADO_SEGUINTE,XXXX.TEM_CARGO_EFETIVO,XXXX.TEM_CARGO_EFETIVO_SEGUINTE,XXXX.CHAVE_INTEGRACAO,XXXX.CHAVE_INTEGRACAO_SEGUINTE,XXXX.SUSPENDE_REMUNERA,XXXX.SUSPENDE_REMUNERA_SEGUINTE,XXXX.E_AFASTAMENTO,XXXX.E_AFASTAMENTO_SEGUINTE,XXXX.PESSOA_GESTOR
FROM
      (SELECT
        --------------------------------------------------------------------------------DIARIA_NOVOS----------------------------------------------------------------------------------------------
        CASE
          WHEN XXX.E_CADASTRO_NOVO = 'SIM'
          AND XXX.INTEGRADO        ='N'
          THEN 'DIARIA_NOVOS'
        -------------------------------------------------------------------------------APOSENTOU E NÃO PERDEU O ACESSO-----------------------------------------------------------------------------      
          WHEN XXX.CONTROLE_FOLHA NOT IN ('S') 
          AND XXX.CONTROLE_FOLHA_SEGUINTE IN ('S')
          AND XXX.DT_SAIU_ARTE < ADD_MONTHS(XXX.DATA_RESCISAO_SEGUINTE, 12) 
          THEN 'APOSENTOU'
        -------------------------------------------------------------------------------DESLIGAMENTO----------------------------------------------------------------------------------------------  
          WHEN XXX.DATA_RESCISAO          IS NULL
          AND XXX.CONTROLE_FOLHA NOT      IN ('D')
          AND XXX.CONTROLE_FOLHA_SEGUINTE IN ('D')
          AND XXX.DATA_RESCISAO_SEGUINTE IS NOT NULL
          THEN 'DESLIGAMENTO'
          
          WHEN XXX.CONTROLE_FOLHA IN ('S')
          AND XXX.CONTROLE_FOLHA_SEGUINTE IN ('S')
          AND TRUNC(XXX.DT_SAIU_ARTE) >= ADD_MONTHS(TRUNC(XXX.DATA_RESCISAO_SEGUINTE), 12) 
          THEN 'DESLIGAMENTO_APOSENTADO'
          
          WHEN XXX.DATA_RESCISAO         IS NULL
          AND XXX.DATA_RESCISAO_SEGUINTE IS NOT NULL
          THEN 'DESLIGAMENTO'

            ----------------------------------------------------------------------------READMISSAO---------------------------------------------------------------------------------------------------
          WHEN XXX.DATA_RESCISAO         IS NOT NULL
          AND XXX.DATA_RESCISAO_SEGUINTE IS NULL
          THEN 'READMISSAO'

          WHEN XXX.DATA_RESCISAO_SEGUINTE     IS NULL
          AND XXX.DATA_RESCISAO         IS NOT NULL
          AND XXX.CONTROLE_FOLHA              IN ('D','S')
          AND XXX.CONTROLE_FOLHA_SEGUINTE NOT IN ('D','S')
          THEN 'READMISSAO'
          

           -----------------------------------------------------------------------ALTERACAO_DIVERSAS----------------------------------------------------------------------------------------------------------------------------------------------
          ELSE 'NÃO MAPEADO'
        END TIPO_VW_DADOS_SERVIDOR,
        --------------------------------------------------------------------------------FIM--------------------------------------------------------------------------------------------------------------
        XXX.*
      FROM
        (SELECT
          --------------------------------------------------------------------------------E_CADASTRO_NOVO--------------------------------------------------------------------------------------------
          CASE
            WHEN XX.CONTROLE_FOLHA NOT IN ('D','S')
            AND XX.DIA                  = 'ULTIMO'
            THEN 'SIM'
            ELSE 'NAO'
          END E_CADASTRO_NOVO,  
          --------------------------------------------------------------------------------LOCAL_MUDOU----------------------------------------------------------------------------------------------
          CASE
            WHEN XX.CONTROLE_FOLHA_SEGUINTE NOT IN ('D','S')
            AND(XX.COD_UNIDADE1                 <> XX.COD_UNIDADE1_SEGUINTE
            OR XX.COD_UNIDADE2                  <> XX.COD_UNIDADE2_SEGUINTE
            OR XX.COD_UNIDADE3                  <> XX.COD_UNIDADE3_SEGUINTE
            OR XX.COD_UNIDADE4                  <> XX.COD_UNIDADE4_SEGUINTE
            OR XX.COD_UNIDADE5                  <> XX.COD_UNIDADE5_SEGUINTE
            OR XX.COD_UNIDADE6                  <> XX.COD_UNIDADE6_SEGUINTE)
            THEN 'LOCAL_MUDOU'
            ELSE 'LOCAL_IGUAL'
          END ALTEROU_LOCAL,
          ------------------------------------------------------------------------------------NOME----------------------------------------------------------------------------------------------------
          CASE
            WHEN XX.CONTROLE_FOLHA_SEGUINTE NOT IN ('D','S')
            AND XX.NOME                         <> XX.NOME_SEGUINTE
            THEN 'NOME_MUDOU'
            ELSE 'NOME_IGUAL'
          END ALTEROU_NOME, /*verificar com a Lele sobre as demais tabelas*/
          ---------------------------------------------------------------------------------CONTROLE_FOLHA-----------------------------------------------------------------------------------------------
          CASE
            WHEN XX.CONTROLE_FOLHA <> XX.CONTROLE_FOLHA_SEGUINTE
            THEN 'CONTROLE_FOLHA_MUDOU'
            ELSE 'CONTROLE_FOLHA_IGUAL'
          END ALTEROU_CONTROLE_FOLHA,

          ----------------------------------------------------------------------------------E_GESTOR-------------------------------------------------------------------------------------------------
          CASE
            WHEN XX.CONTROLE_FOLHA_SEGUINTE NOT IN ('D','S')
            AND XX.E_GESTOR                     <> XX.E_GESTOR_SEGUINTE
            THEN 'E_GESTOR_MUDOU'
            ELSE 'E_GESTOR_IGUAL'
          END ALTEROU_E_GESTOR,
          ----------------------------------------------------------------------------------VERIFICA_GUARDA----------------------------------------------------------------------------------------------
          CASE
            WHEN XX.COD_UNIDADE1_SEGUINTE = '000091'
            AND XX.COD_UNIDADE2_SEGUINTE  = '000098'
            THEN 'GUARDA'
            ELSE 'OUTROS'
          END ANALISE_GUARDA,          
          --------------------------------------------------------------------------------------------FIM DE TUDO----------------------------------------------------------------------------------------------
          XX.*,
          PC.CODIGO_PESSOA AS PESSOA_GESTOR
        FROM
          (SELECT X.TIPO_PESSOA ,X.APELIDO, X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO, X.VINCULO ,
          Row_Number () Over (Partition BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO Order By X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA)ORDEM_BM,
          X.NOME,
          LEAD(X.NOME, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) NOME_SEGUINTE,
          X.DIA,
          LEAD(X.DIA, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) DIA_SEGUINTE,
          X.TIPO ,
          LEAD(X.TIPO, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) TIPO_SEGUINTE,
          X.INTEGRADO ,
          LEAD(X.INTEGRADO, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) INTEGRADO_SEGUINTE,
          X.DATA_ADMISSAO,
          X.PIS_PASEP,
          LEAD(X.PIS_PASEP, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) PIS_PASEP_SEGUINTE,
          X.CPF,
          LEAD(X.CPF, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) CPF_SEGUINTE,
          X.CNPJ,
          LEAD(X.CNPJ,1,NULL)OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA)CNPJ_SEGUINTE,
          X.IDENTIDADE,
          LEAD(X.IDENTIDADE, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) IDENTIDADE_SEGUINTE ,
          X.COD_UNIDADE1 ,
          LEAD(X.COD_UNIDADE1, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO, X.TIPO_CONTRATO,X.DIA) COD_UNIDADE1_SEGUINTE ,
          X.COD_UNIDADE2 ,
          LEAD(X.COD_UNIDADE2, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO, X.TIPO_CONTRATO,X.DIA) COD_UNIDADE2_SEGUINTE ,
          X.COD_UNIDADE3 ,
          LEAD(X.COD_UNIDADE3, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) COD_UNIDADE3_SEGUINTE ,
          X.COD_UNIDADE4 ,
          LEAD(X.COD_UNIDADE4, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) COD_UNIDADE4_SEGUINTE ,
          X.COD_UNIDADE5 ,
          LEAD(X.COD_UNIDADE5, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) COD_UNIDADE5_SEGUINTE ,
          X.COD_UNIDADE6 ,
          LEAD(X.COD_UNIDADE6, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) COD_UNIDADE6_SEGUINTE ,
          X.DESCRICAO_UNIDADE ,
          LEAD(X.DESCRICAO_UNIDADE, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) DESCRICAO_UNIDADE_SEGUINTE ,
          X.REGISTRO_PONTO ,
          LEAD(X.REGISTRO_PONTO, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) REGISTRO_PONTO_SEGUINTE ,
          X.SITUACAO_FUNCIONAL ,
          LEAD(X.SITUACAO_FUNCIONAL, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) SITUACAO_FUNCIONAL_SEGUINTE ,
          X.NOME_SIT_FUNC ,
          LEAD(X.NOME_SIT_FUNC, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) NOME_SIT_FUNC_SEGUINTE ,
          X.CONTROLE_FOLHA ,
          LEAD(X.CONTROLE_FOLHA, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) CONTROLE_FOLHA_SEGUINTE ,
          X.DATA_RESCISAO ,
          LEAD(X.DATA_RESCISAO, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) DATA_RESCISAO_SEGUINTE ,
          X.CODIGO_ESCALA ,
          LEAD(X.CODIGO_ESCALA, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) CODIGO_ESCALA_SEGUINTE ,
          X.DT_ULT_ESCALA ,
          LEAD(X.DT_ULT_ESCALA, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) DT_ULT_ESCALA_SEGUINTE ,
          X.COD_CARGO_EFETIVO ,
          LEAD(X.COD_CARGO_EFETIVO, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) COD_CARGO_EFETIVO_SEGUINTE ,
          X.CARGO_EFETIVO ,
          LEAD(X.CARGO_EFETIVO, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) CARGO_EFETIVO_SEGUINTE ,
          X.COD_CARGO_COMISS ,
          LEAD(X.COD_CARGO_COMISS, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) COD_CARGO_COMISS_SEGUINTE ,
          X.CARGO_COMISSIONADO ,
          LEAD(X.CARGO_COMISSIONADO, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) CARGO_COMISSIONADO_SEGUINTE ,
          X.CODIGO_FUNCAO ,
          LEAD(X.CODIGO_FUNCAO, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) CODIGO_FUNCAO_SEGUINTE ,
          X.FUNCAO_PUBLICA ,
          LEAD(X.FUNCAO_PUBLICA, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) FUNCAO_PUBLICA_SEGUINTE ,
          X.CODIGO_EMPRESA_GESTOR ,
          LEAD(X.CODIGO_EMPRESA_GESTOR, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) CODIGO_EMPRESA_GESTOR_SEGUINTE ,
          X.TIPO_CONTRATO_GESTOR ,
          LEAD(X.TIPO_CONTRATO_GESTOR, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) TIPO_CONTRATO_GESTOR_SEGUINTE ,
          X.CONTRATO_GESTOR ,
          LEAD(X.CONTRATO_GESTOR, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) CONTRATO_GESTOR_SEGUINTE ,
          X.CPF_GESTOR ,
          LEAD(X.CPF_GESTOR, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) CPF_GESTOR_SEGUINTE ,
          X.E_GESTOR ,
          LEAD(X.E_GESTOR, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) E_GESTOR_SEGUINTE ,
          X.TIPO_USUARIO ,
          LEAD(X.TIPO_USUARIO, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) TIPO_USUARIO_SEGUINTE ,
          X.DT_SAIU_ARTE,
          X.CODIGO_LEGADO,
          LEAD(X.CODIGO_LEGADO, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) CODIGO_LEGADO_SEGUINTE,
          X.TEM_CARGO_EFETIVO,
          LEAD(X.TEM_CARGO_EFETIVO, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA)TEM_CARGO_EFETIVO_SEGUINTE,
          X.CHAVE_INTEGRACAO,
          LEAD(X.CHAVE_INTEGRACAO, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA) CHAVE_INTEGRACAO_SEGUINTE,
          X.SUSPENDE_REMUNERA,
          LEAD(X.SUSPENDE_REMUNERA, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA)SUSPENDE_REMUNERA_SEGUINTE,
          X.E_AFASTAMENTO,
          LEAD(X.E_AFASTAMENTO, 1, NULL) OVER(PARTITION BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO ORDER BY X.CODIGO_EMPRESA, X.CODIGO_CONTRATO, X.TIPO_CONTRATO,X.DIA)E_AFASTAMENTO_SEGUINTE
        FROM
          (SELECT 'ULTIMO' AS DIA,U.*,GN.CGC AS CNPJ
          FROM PONTO_ELETRONICO.SUGESP_BI_1CONTRAT_INTIF_ARTE U
          LEFT OUTER JOIN ARTERH.RHORGA_CUSTO_GEREN GN
          ON U.CODIGO_EMPRESA  =GN.CODIGO_EMPRESA
          AND U.COD_UNIDADE1   =GN.cod_cgerenc1
          AND U.COD_UNIDADE2   =GN.cod_cgerenc2
          AND U.COD_UNIDADE3   =GN.cod_cgerenc3
          AND U.COD_UNIDADE4   =GN.cod_cgerenc4
          AND U.COD_UNIDADE5   =GN.cod_cgerenc5
          AND U.COD_UNIDADE6   =GN.cod_cgerenc6
          WHERE TRUNC(U.dt_saiu_arte) = TRUNC(SYSDATE) --(SELECT MAX(dt_saiu_arte)FROM PONTO_ELETRONICO.SUGESP_BI_1CONTRAT_INTIF_ARTE)
          UNION ALL
          --PENULTIMO DIA
          SELECT 'PENULTIMO' AS DIA,P.*,GN.CGC AS CNPJ
          FROM PONTO_ELETRONICO.SUGESP_BI_1CONTRAT_INTIF_ARTE P
          LEFT OUTER JOIN ARTERH.RHORGA_CUSTO_GEREN GN
          ON P.CODIGO_EMPRESA  =GN.CODIGO_EMPRESA
          AND P.COD_UNIDADE1   =GN.cod_cgerenc1
          AND P.COD_UNIDADE2   =GN.cod_cgerenc2
          AND P.COD_UNIDADE3   =GN.cod_cgerenc3
          AND P.COD_UNIDADE4   =GN.cod_cgerenc4
          AND P.COD_UNIDADE5   =GN.cod_cgerenc5
          AND P.COD_UNIDADE6   =GN.cod_cgerenc6
         WHERE TRUNC(P.dt_saiu_arte) = TRUNC(SYSDATE)-1
         /*(SELECT X.DT_SAIU_ARTE FROM(SELECT K.DT_SAIU_ARTE,ROWNUM ORDEM_DATA FROM(SELECT Z.*FROM(SELECT x.dt_saiu_arte
          FROM PONTO_ELETRONICO.SUGESP_BI_1CONTRAT_INTIF_ARTE x
          GROUP BY x.dt_saiu_arte
          ORDER BY x.dt_saiu_arte DESC)Z)K)X
            WHERE X.ORDEM_DATA = 2)*/
            )X
        ORDER BY X.CODIGO_EMPRESA,X.CODIGO_CONTRATO, X.DIA
          )XX
        LEFT OUTER JOIN ARTERH.RHPESS_CONTRATO PC----- PEGAR CODIGO PESSOA GESTOR
        ON XX.CODIGO_EMPRESA_GESTOR = PC.CODIGO_EMPRESA
        AND XX.CONTRATO_GESTOR      =PC.CODIGO
        AND XX.TIPO_CONTRATO_GESTOR =PC.TIPO_CONTRATO
        WHERE(XX.ORDEM_BM           = 1)
        AND PC.ANO_MES_REFERENCIA   =
          (SELECT MAX(AUX.ANO_MES_REFERENCIA)
          FROM ARTERH.RHPESS_CONTRATO AUX
          WHERE PC.CODIGO_EMPRESA     =AUX.CODIGO_EMPRESA
          AND PC.TIPO_CONTRATO        =AUX.TIPO_CONTRATO
          AND PC.CODIGO               = AUX.CODIGO
          AND AUX.ANO_MES_REFERENCIA <=
            (SELECT data_do_sistema FROM rhparm_p_sist
            )
          )
       )XXX
      WHERE ( (XXX.E_CADASTRO_NOVO = 'SIM'
      AND XXX.INTEGRADO = 'N')--Kellysson 3/12/18-- para sinalizar que NAO INTEGROU
      OR (XXX.ALTEROU_LOCAL = 'LOCAL_MUDOU' AND XXX.INTEGRADO = 'S')--Kellysson 3/12/18-- Quando altera o CUSTO GERENCIAL no contrato da pessoa
      OR (ALTEROU_CONTROLE_FOLHA = 'CONTROLE_FOLHA_MUDOU' AND XXX.INTEGRADO = 'S')--Kellysson 20/12/18 -- Quando a pessoa desligou ou readmitiu
      OR (XXX.ALTEROU_E_GESTOR = 'E_GESTOR_MUDOU' AND XXX.INTEGRADO = 'S')--Kellysson 3/12/18-- significa que a pessoa ERA ou PASSOU A SER gestora
      OR (XXX.ALTEROU_NOME ='NOME_MUDOU' AND XXX.INTEGRADO = 'S') )
      OR (TO_CHAR(XXX.DT_SAIU_ARTE,'DDMMYYYY') = TO_CHAR(ADD_MONTHS(XXX.DATA_RESCISAO_SEGUINTE, 12),'DDMMYYYY') AND XXX.CONTROLE_FOLHA_SEGUINTE IN ('S') AND XXX.CONTROLE_FOLHA IN ('S') )/* RAFAELLA EM 26-06-2023, TRATAR OS APOSENTADOS*/
      )XXXX
       --WHERE XXXX.CODIGO_CONTRATO IN ('000000001025218','000000000819216')
      --FIM XXXX
    ORDER BY XXXX.CODIGO_CONTRATO