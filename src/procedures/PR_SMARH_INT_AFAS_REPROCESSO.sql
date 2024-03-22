
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PR_SMARH_INT_AFAS_REPROCESSO" AS
BEGIN
DECLARE CONT NUMBER;
BEGIN
CONT:=0;
FOR C1 IN (
SELECT x1.*,CASE
        WHEN TO_DATE(x1.data_inic_situacao,'DD/MM/YYYY')<= TO_DATE(x1.FECHAMENTO_SISTEMA,'DD/MM/YYYY')
        THEN TO_CHAR(TO_DATE(x1.FECHAMENTO_SISTEMA,'DD/MM/YYYY')+1,'DD/MM/YYYY')
        WHEN TO_DATE(x1.data_inic_situacao,'DD/MM/YYYY')>=TO_DATE(x1.FECHAMENTO_SISTEMA,'DD/MM/YYYY')
        THEN to_char(x1.data_inic_situacao,'dd/mm/yyyy') else  to_char(x1.data_inic_situacao,'dd/mm/yyyy')
      END AS DATA_INICIO_fim,
    CASE   WHEN X1.TIPO                          ='ALTERAR'
          AND TO_DATE(X1.DATA_FIM_SITUACAO,'DD/MM/YYYY')<=TO_DATE(X1.FECHAMENTO_SISTEMA,'DD/MM/YYYY')
          THEN TO_CHAR(TO_DATE(X1.FECHAMENTO_SISTEMA,'DD/MM/YYYY'),'DD/MM/YYYY')
          WHEN X1.TIPO                          ='ALTERAR'
          AND TO_DATE(X1.DATA_FIM_SITUACAO,'DD/MM/YYYY')>=TO_DATE(X1.FECHAMENTO_SISTEMA,'DD/MM/YYYY')
          THEN TO_CHAR(TO_DATE(X1.DATA_FIM_SITUACAO,'DD/MM/YYYY'),'DD/MM/YYYY')
          WHEN X1.TIPO                          ='ATUALIZADA_DATA' THEN TO_CHAR(LAST_DAY(X1.DATA_COMPARA),'DD/MM/YYYY')  ELSE  TO_CHAR(TO_DATE(X1.DATA_FIM_SITUACAO,'DD/MM/YYYY'),'DD/MM/YYYY') END AS DATA_FIM_FIM

          FROM (SELECT X.*,
  CASE
    WHEN X.DATA_FIM_SITUACAO IS NOT NULL AND X.DATA_FIM_SITUACAO>X.FECHAMENTO_SISTEMA AND X.DATA_FIM_SITUACAO!=X.DATA_SIMULADA THEN 'EXCLUIR_INCLUIR'
    WHEN X.DATA_FIM_SITUACAO IS NOT NULL AND X.DATA_FIM_SITUACAO<=X.FECHAMENTO_SISTEMA AND X.DATA_FIM_SITUACAO!=X.DATA_SIMULADA THEN 'ALTERAR'
    WHEN X.DATA_FIM_SITUACAO IS NOT NULL AND X.DATA_FIM_SITUACAO=X.DATA_SIMULADA THEN 'NADA'
    WHEN X.DATA_FIM_SITUACAO IS NULL AND X.DATA_SIMULADA<DATA_COMPARA THEN'ATUALIZADA_DATA'
    ELSE NULL
  END AS TIPO
FROM
  (SELECT AT.CODIGO_EMPRESA,
    AT.TIPO_CONTRATO,
    AT.CODIGO AS CODIGO_CONTRATO,
    AT.DATA_INIC_SITUACAO ,
    AT.DATA_FIM_SITUACAO ,
    SYSDATE AS DATA_COMPARA,
    PT.CODIGO_JUSTIFICATIVA,
    pt.descricao,
    PT.DATA_INICIO,
    PT.DATA_FIM,
    PT.DATA_SIMULADA,
    PT.CODIGO_LEGADO,
    CASE WHEN TO_CHAR(W.FECHAMENTO_AGRUPADOR,'DD/MM/YYYY') IS NOT NULL THEN TO_CHAR(W.FECHAMENTO_AGRUPADOR,'DD/MM/YYYY') WHEN TO_CHAR(W.FECHAMENTO_ORGANOGRAMA,'DD/MM/YYYY') IS NOT NULL THEN TO_CHAR(W.FECHAMENTO_ORGANOGRAMA,'DD/MM/YYYY')
          WHEN W.FECHAMENTO_AGRUPADOR IS NULL AND W.FECHAMENTO_ORGANOGRAMA IS NULL THEN TO_CHAR(AP.data_fim_folha,'DD/MM/YYYY')
          ELSE TO_CHAR(ADD_MONTHS(W.FECHAMENTO_GERAL,-1),'DD/MM/YYYY')
          END FECHAMENTO_SISTEMA
  FROM PONTO_ELETRONICO.SMARH_INT_PE_AFASTAMENTOS_V1 PT
  LEFT OUTER JOIN ARTERH.RHCGED_ALT_SIT_FUN at

  on at.codigo                                  =PT.CODIGO_CONTRATO
  AND at.codigo_empresa                          =pt.codigo_empresa
  AND at.tipo_contrato                           =pt.tipo_contrato
  LEFT OUTER JOIN ARTERH.RHPESS_CONTRATO C
        ON C.CODIGO_EMPRESA=at.CODIGO_EMPRESA
        AND C.CODIGO       =at.CODIGO
        AND C.TIPO_CONTRATO=at.TIPO_CONTRATO

  LEFT OUTER JOIN (SELECT * FROM
        ARTERH.RHPONT_APUR_AGRUP AP
        WHERE  AP.TIPO_APUR       ='F'
        AND AP.c_livre_selec01 = 2
        AND AP.id_agrup        = 152123
        AND AP.data_fim_folha      =
          (SELECT MAX(ADD_MONTHS(AUX.data_fim_folha,-1))
          FROM ARTERH.RHPONT_APUR_AGRUP AUX
          WHERE AUX.codigo_empresa = AP.CODIGO_EMPRESA
          AND AP.tipo_apur         = AUX.TIPO_APUR
          AND AP.c_livre_selec01   = AUX.c_livre_selec01
          AND AP.id_agrup          = AUX.id_agrup
          )
        )AP
        ON AP.CODIGO_EMPRESA=PT.CODIGO_EMPRESA
          LEFT OUTER JOIN
          (SELECT * FROM RHINTE_ED_IT_CONV WHERE CODIGO_CONVERSAO='PONT'
          )PONTR
        ON SUBSTR(PONTR.DADO_ORIGEM,20,4)     =at.CODIGO_EMPRESA
        AND SUBSTR(PONTR.DADO_ORIGEM,24,4)    =at.TIPO_CONTRATO
        LEFT OUTER JOIN ARTERH.VW_DATA_APURACAO_FREQUENCIA W
        ON C.CODIGO_EMPRESA=W.CODIGO_EMPRESA
        AND C.COD_CUSTO_GERENC1=W.COD_AGRUP1
        AND C.COD_CUSTO_GERENC2=W.COD_AGRUP2
        AND C.COD_CUSTO_GERENC3=W.COD_AGRUP3
        AND C.COD_CUSTO_GERENC4=W.COD_AGRUP4
        AND C.COD_CUSTO_GERENC5=W.COD_AGRUP5
        AND C.COD_CUSTO_GERENC6=W.COD_AGRUP6
        WHERE SUBSTR(PONTR.DADO_ORIGEM,20,4) IS NOT NULL
        and  SIMULA_DATA     ='SIM'
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
          and  TO_DATE(AT.DATA_INIC_SITUACAO,'DD/MM/YYYY') =to_date(PT.DATA_INICIO_REAL,'dd/mm/yyyy')
  --AND pt.codigo_contrato='00000000116000X'

  )X
  )x1
  )LOOP
  CONT:=CONT+1;
  IF C1.TIPO='EXCLUIR_INCLUIR' THEN
  INSERT INTO PONTO_ELETRONICO.SMARH_INT_PE_AFASTAMENTOS_V1(EMPRESA,AGRUPAMENTO_EMPRESA,CODIGO_LEGADO,TIPO,CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,CODIGO_JUSTIFICATIVA,DESCRICAO,DATA_INICIO,DATA_FIM,DT_SAIU_ARTE)
  SELECT 'PREF.MUN.BELO HORIZONTE','ADM DIRETA',CODIGO_LEGADO,'EXCLUIR',CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,CODIGO_JUSTIFICATIVA,DESCRICAO,DATA_INICIO,DATA_FIM,SYSDATE FROM PONTO_ELETRONICO.SMARH_INT_PE_AFASTAMENTOS_V1
  WHERE CODIGO_CONTRATO=''||C1.CODIGO_CONTRATO||''
  AND CODIGO_LEGADO=''||C1.CODIGO_LEGADO||''
  AND DATA_INICIO=''||C1.DATA_INICIO||''
  AND DATA_FIM=''||C1.DATA_FIM||''
  AND CODIGO_JUSTIFICATIVA=''||C1.CODIGO_JUSTIFICATIVA||'';
  COMMIT;
  INSERT INTO PONTO_ELETRONICO.SMARH_INT_PE_AFASTAMENTOS_V1(EMPRESA,AGRUPAMENTO_EMPRESA,CODIGO_LEGADO,TIPO,CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,CODIGO_JUSTIFICATIVA,DESCRICAO,DATA_INICIO,DATA_FIM,DT_SAIU_ARTE)VALUES
  ('PREF.MUN.BELO HORIZONTE','ADM DIRETA',''||c1.CODIGO_LEGADO||'','INCLUIR',''||c1.CODIGO_EMPRESA||'',''||c1.TIPO_CONTRATO||'',''||c1.CODIGO_CONTRATO||'',''||c1.CODIGO_JUSTIFICATIVA||'',''||c1.DESCRICAO||'',''||c1.DATA_INICIO_fim||'',''||C1.DATA_FIM_FIM||'',SYSDATE);
  COMMIT;
  END IF;

  IF C1.TIPO='ATUALIZADA_DATA' THEN
   UPDATE PONTO_ELETRONICO.SMARH_INT_PE_AFASTAMENTOS_V1 SET DATA_FIM=''||C1.DATA_FIM_FIM||'',DT_ENVIADO_IFPONTO_SURICATO='',DT_REPROCESSOU=SYSDATE ,TIPO='ATUALIZAR'WHERE CODIGO_CONTRATO=''||C1.CODIGO_CONTRATO||''AND CODIGO_LEGADO=''||C1.CODIGO_LEGADO||''AND DATA_INICIO=''||C1.DATA_INICIO||''AND DATA_FIM=''||C1.DATA_FIM||''AND CODIGO_JUSTIFICATIVA=''||C1.CODIGO_JUSTIFICATIVA||'';
   COMMIT;
  END IF;

  IF C1.TIPO='ALTERAR' THEN
     UPDATE PONTO_ELETRONICO.SMARH_INT_PE_AFASTAMENTOS_V1 SET DATA_FIM=''||C1.DATA_FIM_FIM||'',DT_ENVIADO_IFPONTO_SURICATO='',DT_REPROCESSOU=SYSDATE,TIPO='ATUALIZAR' WHERE CODIGO_CONTRATO=''||C1.CODIGO_CONTRATO||''AND CODIGO_LEGADO=''||C1.CODIGO_LEGADO||''AND DATA_INICIO=''||C1.DATA_INICIO||''AND DATA_FIM=''||C1.DATA_FIM||''AND CODIGO_JUSTIFICATIVA=''||C1.CODIGO_JUSTIFICATIVA||'';
     COMMIT;

  END IF;
  END LOOP;
  END;
  END;