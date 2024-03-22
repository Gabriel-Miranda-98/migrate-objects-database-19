
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."SMARH_INT_AFASTAMENTOS_EXC" (
    DATA_INICIO IN VARCHAR2,
    DATA_FIM    IN VARCHAR2)
AS
BEGIN
  DECLARE
    vCONTADOR    NUMBER;
    vDATA_INICIO VARCHAR2(10);
    vDATA_FIM    VARCHAR2(10);
  BEGIN
    dbms_output.enable(NULL);
    vCONTADOR    :=0;
    vDATA_INICIO := DATA_INICIO;
    vDATA_FIM    := DATA_FIM;
    FOR C1 IN
    (SELECT
      CASE
        WHEN X3.CODIGO_EMPRESA = '0001'
        THEN 'PREF.MUN.BELO HORIZONTE'
        WHEN x3.CODIGO_EMPRESA = '0098'
        THEN 'PREF.MUN.BH CONTRATOS'
      END AS EMPRESA,
      CASE
        WHEN X3.CODIGO_EMPRESA IN ('0001','0098','0015','0021','0032')
        THEN 'ADM DIRETA'
        ELSE 'ADM INDIRETA'
      END AS AGRUPAMENTO_EMPRESA,
      X3.CODIGO_EMPRESA
      ||X3.TIPO_CONTRATO
      ||LTRIM(X3.CODIGO_CONTRATO,0)||X3.CODIGO_JUSTIFICATIVA
      ||TO_CHAR(to_date(X3.DATA_INICIO,'dd/mm/yyyy'),'yyyy-MM-dd hh24:mi:ss') AS CODIGO_LEGADO,
      X3.*
    FROM
      (SELECT CASE WHEN FIM.tipo='ATUALIZAR_NOVA_DT_FIM' THEN 'ATUALIZAR' ELSE FIM.tipo END AS TIPO,
        fim.codigo_empresa,
        FIM.TIPO_CONTRATO,
        FIM.CODIGO_CONTRATO,
        FIM.CODIGO_JUSTIFICATIVA,
        FIM.DESCRICAO,
        CASE
        WHEN  TIPO                          !='ATUALIZAR' AND TO_DATE(FIM.DATA_INICIO,'DD/MM/YYYY')<= TO_DATE(FIM.FECHAMENTO_SISTEMA,'DD/MM/YYYY')  and FIM.FECHAMENTO_SISTEMA IS NOT NULL
        THEN TO_CHAR(TO_DATE(FIM.FECHAMENTO_SISTEMA,'DD/MM/YYYY')+1,'DD/MM/YYYY')
        WHEN  TIPO                          !='ATUALIZAR' AND TO_DATE(FIM.DATA_INICIO,'DD/MM/YYYY')>=TO_DATE(FIM.FECHAMENTO_SISTEMA,'DD/MM/YYYY') AND FIM.FECHAMENTO_SISTEMA IS NOT  NULL
        THEN DATA_INICIO
        ELSE FIM.DATA_INICIO
      END AS DATA_INICIO,
        CASE
          WHEN TIPO                          ='ATUALIZAR_NOVA_DT_FIM'
          AND TO_DATE(DATA_FIM,'DD/MM/YYYY')<=TO_DATE(FECHAMENTO_SISTEMA,'DD/MM/YYYY') AND FIM.FECHAMENTO_SISTEMA IS NOT  NULL
          THEN TO_CHAR(TO_DATE(FECHAMENTO_SISTEMA,'DD/MM/YYYY'),'DD/MM/YYYY')
          WHEN TIPO                          ='EXCLUIR'
          AND TO_DATE(DATA_FIM,'DD/MM/YYYY')<=TO_DATE(FECHAMENTO_SISTEMA,'DD/MM/YYYY') AND FIM.FECHAMENTO_SISTEMA IS NOT  NULL
          THEN TO_CHAR(TO_DATE(FECHAMENTO_SISTEMA,'DD/MM/YYYY'),'DD/MM/YYYY')
          WHEN TIPO                          ='ATUALIZAR_NOVA_DT_FIM'
          AND TO_DATE(DATA_FIM,'DD/MM/YYYY')>=TO_DATE(FECHAMENTO_SISTEMA,'DD/MM/YYYY') AND FIM.FECHAMENTO_SISTEMA IS NOT  NULL
          THEN TO_CHAR(TO_DATE(DATA_FIM,'DD/MM/YYYY'),'DD/MM/YYYY')
          WHEN TIPO                          ='EXCLUIR'
          AND TO_DATE(DATA_FIM,'DD/MM/YYYY')>=TO_DATE(FECHAMENTO_SISTEMA,'DD/MM/YYYY') AND FIM.FECHAMENTO_SISTEMA IS NOT  NULL
          THEN TO_CHAR(TO_DATE(DATA_FIM,'DD/MM/YYYY'),'DD/MM/YYYY')
          WHEN TIPO                          ='ATUALIZAR' THEN TO_CHAR(TO_DATE(FECHAMENTO_SISTEMA,'DD/MM/YYYY'),'DD/MM/YYYY')
          ELSE TO_CHAR(TO_DATE(DATA_FIM,'DD/MM/YYYY'),'DD/MM/YYYY')
        END AS DATA_FIM,
        SYSDATE AS DT_SAIU_ARTE,
        NULL AS DT_ENVIADO_IFPONTO_SURICATO
        ,FIM.PK_ARTE
      FROM
        (SELECT X.*
        FROM
          (SELECT 'EXCLUIR'TIPO,
            LC.ID,
            LC.CODIGO_EMPRESA,
            LC.TIPO_CONTRATO,
            LC.CODIGO                AS CODIGO_CONTRATO,
            LC.OLD_COD_SIT_FUNCIONAL AS SITUACAO_FUNCIONAL,
            PN.CODIGO                AS CODIGO_JUSTIFICATIVA,
            PN.DESCRICAO,
            TO_CHAR(LC.DATA_INIC_SITUACAO,'DD/MM/YYYY')    AS DATA_INICIO,
            TO_CHAR(LC.OLD_DATA_FIM_SITUACAO,'DD/MM/YYYY') AS DATA_FIM,
            CN.cod_custo_gerenc1
            || '.'
            || CN.cod_custo_gerenc2
            || '.'
            || CN.cod_custo_gerenc3
            || '.'
            || CN.cod_custo_gerenc4
            || '.'
            || CN.cod_custo_gerenc5
            || '.'
            || CN.cod_custo_gerenc6                                  AS CODIGO_UNIDADE,
           (SELECT    dado_origem FROM     ARTERH.rhinte_ed_it_conv cv WHERE codigo_conversao = 'FCPT' AND TO_DATE(dado_origem,'DD/MM/YYYY') = (SELECT MAX(TO_DATE(AUX.dado_origem,'DD/MM/YYYY')) FROM arterh.rhinte_ed_it_conv aux WHERE cv.codigo_conversao = aux.codigo_conversao))          FECHAMENTO_SISTEMA
, LC.CODIGO_EMPRESA||LC.TIPO_CONTRATO||LC.CODIGO||LC.DATA_INIC_SITUACAO AS PK_ARTE
        FROM ARTERH.SMARH_INT_PE_ALTSITFUN_AUDITO LC
          LEFT OUTER JOIN ARTERH.RHPESS_CONTRATO CN
          ON LC.CODIGO_EMPRESA=CN.CODIGO_EMPRESA
          AND LC.TIPO_CONTRATO=CN.TIPO_CONTRATO
          AND LC.CODIGO       =CN.CODIGO
          LEFT OUTER JOIN ARTERH.RHPARM_SIT_FUNC SF
          ON LC.OLD_COD_SIT_FUNCIONAL=SF.CODIGO
          LEFT OUTER JOIN ARTERH.RHPONT_SITUACAO PN
          ON SF.SITUACAO_PONTO=PN.CODIGO

          LEFT OUTER JOIN
          (SELECT * FROM RHINTE_ED_IT_CONV WHERE CODIGO_CONVERSAO='PONT')PONTR
          ON   SUBSTR(PONTR.DADO_ORIGEM,20,4)=LC.CODIGO_EMPRESA
          AND SUBSTR(PONTR.DADO_ORIGEM,24,4)=LC.TIPO_CONTRATO

          WHERE SUBSTR(PONTR.DADO_ORIGEM,24,4) IS NOT NULL

          AND LC.TIPO_DML IN ('D')
          AND LC.ID        =
            (SELECT MAX(AUX.ID)
            FROM ARTERH.SMARH_INT_PE_ALTSITFUN_AUDITO AUX
            WHERE AUX.CODIGO                 =LC.CODIGO
            AND AUX.TIPO_CONTRATO            =LC.TIPO_CONTRATO
            AND AUX.CODIGO_EMPRESA           =LC.CODIGO_EMPRESA
            AND TRUNC(aux.DATA_INIC_SITUACAO)=TRUNC(LC.DATA_INIC_SITUACAO)
          --  AND AUX.TIPO_DML=LC.TIPO_DML
            )
          AND CN.ANO_MES_REFERENCIA=
            (SELECT MAX(AUX.ANO_MES_REFERENCIA)
            FROM ARTERH.RHPESS_CONTRATO AUX
            WHERE AUX.CODIGO           =CN.CODIGO
            AND AUX.TIPO_CONTRATO      =CN.TIPO_CONTRATO
            AND AUX.CODIGO_EMPRESA     =CN.CODIGO_EMPRESA
            AND AUX.ANO_MES_REFERENCIA<=
              (SELECT data_do_sistema FROM ARTERH.rhparm_p_sist
              )
            )
          AND PN.TIPO_SITUACAO      IN ('P','I','F')
          AND SF.CONTROLE_FOLHA NOT IN('D','S')
          AND pn.c_livre_valor01='1'
          ---PN.usa_apuracao        ='S'
          ---gabriel  deixei de usar aqui em 27/08/2020 devido as emrpesas da unificacao nÃƒÆ’Ã‚Â£o ter fechamento
       /*   AND AP.data_fim_folha      =
            (SELECT MAX(AUX.data_fim_folha)
            FROM ARTERH.RHPONT_APUR_AGRUP AUX
            WHERE AUX.codigo_empresa = AP.CODIGO_EMPRESA
            AND AP.tipo_apur         = AUX.TIPO_APUR
            AND AP.c_livre_selec01   = AUX.c_livre_selec01
            AND AP.id_agrup          = AUX.id_agrup
            )*/
          AND trunc(LC.DT_ULT_ALTER_USUA) BETWEEN vDATA_INICIO AND vDATA_FIM
          AND TO_DATE(TO_CHAR(LC.OLD_DATA_FIM_SITUACAO,'DD/MM/YYYY'),'DD/MM/YYYY')>=(SELECT    dado_origem FROM     ARTERH.rhinte_ed_it_conv cv WHERE codigo_conversao = 'FCPT' AND TO_DATE(dado_origem,'DD/MM/YYYY') = (SELECT MAX(TO_DATE(AUX.dado_origem,'DD/MM/YYYY')) FROM arterh.rhinte_ed_it_conv aux WHERE cv.codigo_conversao = aux.codigo_conversao))

          and TO_DATE(TO_CHAR(LC.DATA_INIC_SITUACAO,'DD/MM/YYYY'),'DD/MM/YYYY')>=(SELECT    dado_origem FROM     ARTERH.rhinte_ed_it_conv cv WHERE codigo_conversao = 'FCPT' AND TO_DATE(dado_origem,'DD/MM/YYYY') = (SELECT MAX(TO_DATE(AUX.dado_origem,'DD/MM/YYYY')) FROM arterh.rhinte_ed_it_conv aux WHERE cv.codigo_conversao = aux.codigo_conversao))
          )X
        UNION ALL
        SELECT X.*
        FROM
          (SELECT 'ATUALIZAR_NOVA_DT_FIM' AS TIPO,
            LC.ID,
            LC.CODIGO_EMPRESA,
            LC.TIPO_CONTRATO,
            LC.CODIGO                AS CODIGO_CONTRATO,
            LC.NEW_COD_SIT_FUNCIONAL AS SITUACAO_FUNCIONAL,
            PN.CODIGO                AS CODIGO_JUSTIFICATIVA,
            PN.DESCRICAO,
            TO_CHAR(LC.DATA_INIC_SITUACAO,'DD/MM/YYYY')    AS DATA_INICIO,
            TO_CHAR(LC.NEW_DATA_FIM_SITUACAO,'DD/MM/YYYY') AS DATA_FIM,
            C.cod_custo_gerenc1
            || '.'
            || C.cod_custo_gerenc2
            || '.'
            || C.cod_custo_gerenc3
            || '.'
            || C.cod_custo_gerenc4
            || '.'
            || C.cod_custo_gerenc5
            || '.'
            || C.cod_custo_gerenc6                                   AS CODIGO_UNIDADE,
           (SELECT    dado_origem FROM     ARTERH.rhinte_ed_it_conv cv WHERE codigo_conversao = 'FCPT' AND TO_DATE(dado_origem,'DD/MM/YYYY') = (SELECT MAX(TO_DATE(AUX.dado_origem,'DD/MM/YYYY')) FROM arterh.rhinte_ed_it_conv aux WHERE cv.codigo_conversao = aux.codigo_conversao))          FECHAMENTO_SISTEMA
, LC.CODIGO_EMPRESA||LC.TIPO_CONTRATO||LC.CODIGO||LC.DATA_INIC_SITUACAO AS PK_ARTE
  FROM ARTERH.SMARH_INT_PE_ALTSITFUN_AUDITO LC
          LEFT OUTER JOIN ARTERH.RHPARM_SIT_FUNC SF
          ON LC.NEW_COD_SIT_FUNCIONAL=SF.CODIGO
          LEFT OUTER JOIN ARTERH.RHPONT_SITUACAO PN
          ON SF.SITUACAO_PONTO=PN.CODIGO
          LEFT OUTER JOIN ARTERH.RHPESS_CONTRATO C
          ON C.CODIGO_EMPRESA=LC.CODIGO_EMPRESA
          AND C.CODIGO       =LC.CODIGO
          AND C.TIPO_CONTRATO=LC.TIPO_CONTRATO

           LEFT OUTER JOIN
          (SELECT * FROM RHINTE_ED_IT_CONV WHERE CODIGO_CONVERSAO='PONT')PONTR
          ON   SUBSTR(PONTR.DADO_ORIGEM,20,4)=LC.CODIGO_EMPRESA
          AND SUBSTR(PONTR.DADO_ORIGEM,24,4)=LC.TIPO_CONTRATO

          WHERE SUBSTR(PONTR.DADO_ORIGEM,24,4) IS NOT NULL
          AND TIPO_DML        IN ('U')
          AND LC.ID              =
            (SELECT MAX(AUX.ID)
            FROM ARTERH.SMARH_INT_PE_ALTSITFUN_AUDITO AUX
            WHERE AUX.CODIGO                 =LC.CODIGO
            AND AUX.TIPO_CONTRATO            =LC.TIPO_CONTRATO
            AND AUX.CODIGO_EMPRESA           =LC.CODIGO_EMPRESA
            AND TRUNC(aux.DATA_INIC_SITUACAO)=TRUNC(LC.DATA_INIC_SITUACAO)
          ---  AND AUX.TIPO_DML=LC.TIPO_DML
            )
          AND C.ANO_MES_REFERENCIA=
            (SELECT MAX(AUX.ANO_MES_REFERENCIA)
            FROM ARTERH.RHPESS_CONTRATO AUX
            WHERE AUX.CODIGO           =C.CODIGO
            AND AUX.TIPO_CONTRATO      =C.TIPO_CONTRATO
            AND AUX.CODIGO_EMPRESA     =C.CODIGO_EMPRESA
            AND AUX.ANO_MES_REFERENCIA<=
              (SELECT data_do_sistema FROM ARTERH.rhparm_p_sist
              )
            )
          AND PN.TIPO_SITUACAO IN ('P','I','F')
          AND SF.CONTROLE_FOLHA NOT IN('D','S')
          AND pn.c_livre_valor01='1'
          ---PN.usa_apuracao        ='S'
          /*AND AP.data_fim_folha      =
            (SELECT MAX(AUX.data_fim_folha)
            FROM ARTERH.RHPONT_APUR_AGRUP AUX
            WHERE AUX.codigo_empresa = AP.CODIGO_EMPRESA
            AND AP.tipo_apur         = AUX.TIPO_APUR
            AND AP.c_livre_selec01   = AUX.c_livre_selec01
            AND AP.id_agrup          = AUX.id_agrup
            )*/
          AND (LC.NEW_DATA_FIM_SITUACAO!=LC.OLD_DATA_FIM_SITUACAO)
          and (trunc(lc.NEW_DATA_FIM_SITUACAO)<=(SELECT    dado_origem FROM     ARTERH.rhinte_ed_it_conv cv WHERE codigo_conversao = 'FCPT' AND TO_DATE(dado_origem,'DD/MM/YYYY') = (SELECT MAX(TO_DATE(AUX.dado_origem,'DD/MM/YYYY')) FROM arterh.rhinte_ed_it_conv aux WHERE cv.codigo_conversao = aux.codigo_conversao)))

        AND trunc(LC.DT_ULT_ALTER_USUA) BETWEEN vDATA_INICIO AND vDATA_FIM
          AND LC.NEW_DATA_FIM_SITUACAO IS NOT NULL
          )X
           WHERE EXISTS (SELECT F.* FROM ARTERH.RHCGED_ALT_SIT_FUN F
      WHERE F.CODIGO=X.CODIGO_CONTRATO
      AND F.CODIGO_EMPRESA=X.CODIGO_EMPRESA
      AND F.TIPO_CONTRATO=X.TIPO_CONTRATO
      AND F.COD_SIT_FUNCIONAL=X.SITUACAO_FUNCIONAL
      AND TRUNC(F.DATA_INIC_SITUACAO)=TRUNC(TO_DATE(X.DATA_INICIO,'DD/MM/YYYY')))
      and TO_DATE(X.DATA_FIM,'DD/MM/YYYY')<=CASE WHEN TO_DATE(x.FECHAMENTO_SISTEMA,'DD/MM/YYYY') IS NULL THEN TO_DATE('01/01/2020','DD/MM/YYYY') ELSE TO_DATE(x.FECHAMENTO_SISTEMA,'DD/MM/YYYY') END
        UNION ALL
        SELECT X.TIPO,X.ID,X.CODIGO_EMPRESA,X.TIPO_CONTRATO,X.CODIGO_CONTRATO,X.SITUACAO_FUNCIONAL_OLD,X.CODIGO_JUSTIFICATIVA,X.DESCRICAO,X.DATA_INICIO,X.DATA_FIM,X.CODIGO_UNIDADE,X.FECHAMENTO_SISTEMA
       ,X.PK_ARTE
        FROM
          (SELECT 'EXCLUIR' AS TIPO,
            LC.ID,
            LC.CODIGO_EMPRESA,
            LC.TIPO_CONTRATO,
            LC.CODIGO                AS CODIGO_CONTRATO,
            LC.OLD_COD_SIT_FUNCIONAL AS SITUACAO_FUNCIONAL_OLD,
            PN.CODIGO                AS CODIGO_JUSTIFICATIVA,
            PN.DESCRICAO,
            TO_CHAR(LC.DATA_INIC_SITUACAO,'DD/MM/YYYY')    AS DATA_INICIO,
            TO_CHAR(LC.NEW_DATA_FIM_SITUACAO,'DD/MM/YYYY') AS DATA_FIM,
            TO_CHAR(LC.OLD_DATA_FIM_SITUACAO,'DD/MM/YYYY') AS DATA_FIM_A,
            C.cod_custo_gerenc1
            || '.'
            || C.cod_custo_gerenc2
            || '.'
            || C.cod_custo_gerenc3
            || '.'
            || C.cod_custo_gerenc4
            || '.'
            || C.cod_custo_gerenc5
            || '.'
            || C.cod_custo_gerenc6                                   AS CODIGO_UNIDADE,
          (SELECT    dado_origem FROM     ARTERH.rhinte_ed_it_conv cv WHERE codigo_conversao = 'FCPT' AND TO_DATE(dado_origem,'DD/MM/YYYY') = (SELECT MAX(TO_DATE(AUX.dado_origem,'DD/MM/YYYY')) FROM arterh.rhinte_ed_it_conv aux WHERE cv.codigo_conversao = aux.codigo_conversao))          FECHAMENTO_SISTEMA
, LC.CODIGO_EMPRESA||LC.TIPO_CONTRATO||LC.CODIGO||LC.DATA_INIC_SITUACAO AS PK_ARTE
   FROM ARTERH.SMARH_INT_PE_ALTSITFUN_AUDITO LC
          LEFT OUTER JOIN ARTERH.RHPARM_SIT_FUNC SF
          ON LC.OLD_COD_SIT_FUNCIONAL=SF.CODIGO
          LEFT OUTER JOIN ARTERH.RHPONT_SITUACAO PN
          ON SF.SITUACAO_PONTO=PN.CODIGO
          LEFT OUTER JOIN ARTERH.RHPESS_CONTRATO C
          ON C.CODIGO_EMPRESA=LC.CODIGO_EMPRESA
          AND C.CODIGO       =LC.CODIGO
          AND C.TIPO_CONTRATO=LC.TIPO_CONTRATO

           LEFT OUTER JOIN
          (SELECT * FROM RHINTE_ED_IT_CONV WHERE CODIGO_CONVERSAO='PONT')PONTR
          ON   SUBSTR(PONTR.DADO_ORIGEM,20,4)=LC.CODIGO_EMPRESA
          AND SUBSTR(PONTR.DADO_ORIGEM,24,4)=LC.TIPO_CONTRATO

          WHERE SUBSTR(PONTR.DADO_ORIGEM,24,4) IS NOT NULL
          AND TIPO_DML        IN ('U')
          AND LC.ID              =
            (SELECT MAX(AUX.ID)
            FROM ARTERH.SMARH_INT_PE_ALTSITFUN_AUDITO AUX
            WHERE AUX.CODIGO                 =LC.CODIGO
            AND AUX.TIPO_CONTRATO            =LC.TIPO_CONTRATO
            AND AUX.CODIGO_EMPRESA           =LC.CODIGO_EMPRESA
            AND TRUNC(aux.DATA_INIC_SITUACAO)=TRUNC(LC.DATA_INIC_SITUACAO)
           ---- AND AUX.TIPO_DML=LC.TIPO_DML
            )
          AND C.ANO_MES_REFERENCIA=
            (SELECT MAX(AUX.ANO_MES_REFERENCIA)
            FROM ARTERH.RHPESS_CONTRATO AUX
            WHERE AUX.CODIGO           =C.CODIGO
            AND AUX.TIPO_CONTRATO      =C.TIPO_CONTRATO
            AND AUX.CODIGO_EMPRESA     =C.CODIGO_EMPRESA
            AND AUX.ANO_MES_REFERENCIA<=
              (SELECT data_do_sistema FROM ARTERH.rhparm_p_sist
              )
            )
          AND PN.TIPO_SITUACAO IN ('P','I','F')
         AND SF.CONTROLE_FOLHA NOT IN('D','S')
          AND pn.c_livre_valor01='1'
          --PN.usa_apuracao        ='S'
          /*AND AP.data_fim_folha      =
            (SELECT MAX(AUX.data_fim_folha)
            FROM ARTERH.RHPONT_APUR_AGRUP AUX
            WHERE AUX.codigo_empresa = AP.CODIGO_EMPRESA
            AND AP.tipo_apur         = AUX.TIPO_APUR
            AND AP.c_livre_selec01   = AUX.c_livre_selec01
            AND AP.id_agrup          = AUX.id_agrup
            )*/
       --   AND ((LC.OLD_COD_SIT_FUNCIONAL!=LC.NEW_COD_SIT_FUNCIONAL)or (LC.NEW_DATA_FIM_SITUACAO!=LC.OLD_DATA_FIM_SITUACAO))
        --  and (trunc(LC.NEW_DATA_FIM_SITUACAO)>trunc(AP.data_fim_folha))
          AND LC.NEW_DATA_FIM_SITUACAO IS NOT NULL
       AND trunc(LC.DT_ULT_ALTER_USUA) BETWEEN vDATA_INICIO AND vDATA_FIM
          )X
            WHERE NOT EXISTS (SELECT F.* FROM ARTERH.RHCGED_ALT_SIT_FUN F
      WHERE F.CODIGO=X.CODIGO_CONTRATO
      AND F.CODIGO_EMPRESA=X.CODIGO_EMPRESA
      AND F.TIPO_CONTRATO=X.TIPO_CONTRATO
      AND F.COD_SIT_FUNCIONAL=X.SITUACAO_FUNCIONAL_OLD
      AND TRUNC(F.DATA_FIM_SITUACAO)=TRUNC(TO_DATE(X.DATA_FIM_A,'DD/MM/YYYY'))
      AND TRUNC(F.DATA_INIC_SITUACAO)=TRUNC(TO_DATE(X.DATA_INICIO,'DD/MM/YYYY')))
      and TO_DATE(X.DATA_FIM,'DD/MM/YYYY')>CASE WHEN TO_DATE(x.FECHAMENTO_SISTEMA,'DD/MM/YYYY') IS NULL THEN TO_DATE('01/01/2020','DD/MM/YYYY') ELSE TO_DATE(x.FECHAMENTO_SISTEMA,'DD/MM/YYYY') END
      UNION ALL
       SELECT X.*
        FROM
          (SELECT 'ATUALIZAR' AS TIPO,
            LC.ID,
            LC.CODIGO_EMPRESA,
            LC.TIPO_CONTRATO,
            LC.CODIGO                AS CODIGO_CONTRATO,
            LC.NEW_COD_SIT_FUNCIONAL AS SITUACAO_FUNCIONAL,
            PN.CODIGO                AS CODIGO_JUSTIFICATIVA,
            PN.DESCRICAO,
            TO_CHAR(LC.DATA_INIC_SITUACAO,'DD/MM/YYYY')    AS DATA_INICIO,
            TO_CHAR(LC.OLD_DATA_FIM_SITUACAO,'DD/MM/YYYY') AS DATA_FIM,
            C.cod_custo_gerenc1
            || '.'
            || C.cod_custo_gerenc2
            || '.'
            || C.cod_custo_gerenc3
            || '.'
            || C.cod_custo_gerenc4
            || '.'
            || C.cod_custo_gerenc5
            || '.'
            || C.cod_custo_gerenc6                                   AS CODIGO_UNIDADE,
                     (SELECT    dado_origem FROM     ARTERH.rhinte_ed_it_conv cv WHERE codigo_conversao = 'FCPT' AND TO_DATE(dado_origem,'DD/MM/YYYY') = (SELECT MAX(TO_DATE(AUX.dado_origem,'DD/MM/YYYY')) FROM arterh.rhinte_ed_it_conv aux WHERE cv.codigo_conversao = aux.codigo_conversao))          FECHAMENTO_SISTEMA
, LC.CODIGO_EMPRESA||LC.TIPO_CONTRATO||LC.CODIGO||LC.DATA_INIC_SITUACAO AS PK_ARTE
          FROM ARTERH.SMARH_INT_PE_ALTSITFUN_AUDITO LC
          LEFT OUTER JOIN ARTERH.RHPARM_SIT_FUNC SF
          ON LC.OLD_COD_SIT_FUNCIONAL=SF.CODIGO
          LEFT OUTER JOIN ARTERH.RHPONT_SITUACAO PN
          ON SF.SITUACAO_PONTO=PN.CODIGO
          LEFT OUTER JOIN ARTERH.RHPESS_CONTRATO C
          ON C.CODIGO_EMPRESA=LC.CODIGO_EMPRESA
          AND C.CODIGO       =LC.CODIGO
          AND C.TIPO_CONTRATO=LC.TIPO_CONTRATO

           LEFT OUTER JOIN
          (SELECT * FROM RHINTE_ED_IT_CONV WHERE CODIGO_CONVERSAO='PONT')PONTR
          ON   SUBSTR(PONTR.DADO_ORIGEM,20,4)=LC.CODIGO_EMPRESA
          AND SUBSTR(PONTR.DADO_ORIGEM,24,4)=LC.TIPO_CONTRATO

          WHERE SUBSTR(PONTR.DADO_ORIGEM,24,4) IS NOT NULL
          AND TIPO_DML        IN ('D')
          AND LC.ID              =
            (SELECT MAX(AUX.ID)
            FROM ARTERH.SMARH_INT_PE_ALTSITFUN_AUDITO AUX
            WHERE AUX.CODIGO                 =LC.CODIGO
            AND AUX.TIPO_CONTRATO            =LC.TIPO_CONTRATO
            AND AUX.CODIGO_EMPRESA           =LC.CODIGO_EMPRESA
            AND TRUNC(aux.DATA_INIC_SITUACAO)=TRUNC(LC.DATA_INIC_SITUACAO)
          ---  AND AUX.TIPO_DML=LC.TIPO_DML
            )
          AND C.ANO_MES_REFERENCIA=
            (SELECT MAX(AUX.ANO_MES_REFERENCIA)
            FROM ARTERH.RHPESS_CONTRATO AUX
            WHERE AUX.CODIGO           =C.CODIGO
            AND AUX.TIPO_CONTRATO      =C.TIPO_CONTRATO
            AND AUX.CODIGO_EMPRESA     =C.CODIGO_EMPRESA
            AND AUX.ANO_MES_REFERENCIA<=
              (SELECT data_do_sistema FROM ARTERH.rhparm_p_sist
              )
            )
          AND PN.TIPO_SITUACAO IN ('P','I','F')
          AND SF.CONTROLE_FOLHA NOT IN('D','S')
          AND pn.c_livre_valor01='1'
          --PN.usa_apuracao        ='S'
          /*AND AP.data_fim_folha      =
            (SELECT MAX(AUX.data_fim_folha)
            FROM ARTERH.RHPONT_APUR_AGRUP AUX
            WHERE AUX.codigo_empresa = AP.CODIGO_EMPRESA
            AND AP.tipo_apur         = AUX.TIPO_APUR
            AND AP.c_livre_selec01   = AUX.c_livre_selec01
            AND AP.id_agrup          = AUX.id_agrup
            )*/
         -- AND (LC.NEW_DATA_FIM_SITUACAO!=LC.OLD_DATA_FIM_SITUACAO)
          and (trunc(lc.DATA_INIC_SITUACAO)<=(SELECT    dado_origem FROM     ARTERH.rhinte_ed_it_conv cv WHERE codigo_conversao = 'FCPT' AND TO_DATE(dado_origem,'DD/MM/YYYY') = (SELECT MAX(TO_DATE(AUX.dado_origem,'DD/MM/YYYY')) FROM arterh.rhinte_ed_it_conv aux WHERE cv.codigo_conversao = aux.codigo_conversao)))

       AND trunc(LC.DT_ULT_ALTER_USUA) BETWEEN vDATA_INICIO AND vDATA_FIM
      ---    AND LC.NEW_DATA_FIM_SITUACAO IS NOT NULL
          )X
           WHERE NOT EXISTS (SELECT F.* FROM ARTERH.RHCGED_ALT_SIT_FUN F
      WHERE F.CODIGO=X.CODIGO_CONTRATO
      AND F.CODIGO_EMPRESA=X.CODIGO_EMPRESA
      AND F.TIPO_CONTRATO=X.TIPO_CONTRATO
      AND F.COD_SIT_FUNCIONAL=X.SITUACAO_FUNCIONAL
      AND TRUNC(F.DATA_INIC_SITUACAO)=TRUNC(TO_DATE(X.DATA_INICIO,'DD/MM/YYYY')))
   --   and TO_DATE(X.DATA_FIM,'DD/MM/YYYY')<=CASE WHEN TO_DATE(x.FECHAMENTO_SISTEMA,'DD/MM/YYYY') IS NULL THEN TO_DATE('01/01/2020','DD/MM/YYYY') ELSE TO_DATE(x.FECHAMENTO_SISTEMA,'DD/MM/YYYY') END



        )FIM
      ORDER BY FIM.CODIGO_CONTRATO,
        TIPO
      )X3
     )LOOP
  vCONTADOR :=vCONTADOR+1;
  INSERT INTO PONTO_ELETRONICO.SMARH_INT_PE_AFASTAMENTOS_V1
  (EMPRESA, AGRUPAMENTO_EMPRESA,CODIGO_LEGADO,CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,CODIGO_JUSTIFICATIVA,DESCRICAO,DATA_INICIO,DATA_FIM,TIPO,DT_SAIU_ARTE,DT_ENVIADO_IFPONTO_SURICATO,CODIGO_INTEGRA_ARTE, PK_ARTE )
  VALUES
  (C1.EMPRESA,C1.AGRUPAMENTO_EMPRESA,C1.CODIGO_LEGADO,C1.CODIGO_EMPRESA,C1.TIPO_CONTRATO,C1.CODIGO_CONTRATO,C1.CODIGO_JUSTIFICATIVA,C1.DESCRICAO,C1.DATA_INICIO,C1.DATA_FIM,C1.TIPO,C1.DT_SAIU_ARTE,C1.DT_ENVIADO_IFPONTO_SURICATO,PONTO_ELETRONICO.SEQUENCE_INTEGRA_ARTE.NEXTVAL, C1.PK_ARTE );
  COMMIT;
  END LOOP;
  END;
  END;