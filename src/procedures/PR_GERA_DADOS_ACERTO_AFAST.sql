
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PR_GERA_DADOS_ACERTO_AFAST" AS 
CONT NUMBER:=0;
begin 
for c1 in (
SELECT X.EMPRESA,X.AGRUPAMENTO_EMPRESA,X.ORIGEM,X.CODIGO_EMPRESA,X.TIPO_CONTRATO,X.CODIGO_CONTRATO,X.CODIGO_LEGADO,X.CODIGO_JUSTIFICATIVA,X.DESCRICAO_JUSTIFICATIVA,X.DT_SAIU_ARTE,X.TIPO,X.DATA_INICIO,
CASE WHEN X.TIPO='ATUALIZAR' AND X.DATA_INICIO<X.FECHAMENTO_SISTEMA THEN TO_DATE(X.FECHAMENTO_SISTEMA,'DD/MM/YYYY') ELSE X.DATA_FIM END AS DATA_FIM
,X.PK_ARTE
FROM (SELECT 
CASE
    WHEN X.CODIGO_EMPRESA = '0001'
    THEN 'PREF.MUN.BELO HORIZONTE'
    WHEN X.CODIGO_EMPRESA = '0098'
    THEN 'PREF.MUN.BH CONTRATOS'
  END          AS EMPRESA,
  'ADM DIRETA' AS AGRUPAMENTO_EMPRESA,
  'ACERTO_BASE' AS ORIGEM,
X.CODIGO_EMPRESA,X.TIPO_CONTRATO,X.CODIGO_CONTRATO,X.CODIGO_LEGADO,X.CODIGO_JUSTIFICATIVA,X.NOME_JUSTIFICATIVA AS DESCRICAO_JUSTIFICATIVA,
SYSDATE AS DT_SAIU_ARTE,
CASE WHEN X.POSSIVEL_ACAO='REMOVER OU ATUALIZAR' AND X.DATA_INICIO<=X.FECHAMENTO_SISTEMA  THEN 'ATUALIZAR'
WHEN X.POSSIVEL_ACAO='REMOVER OU ATUALIZAR' AND X.DATA_INICIO>X.FECHAMENTO_SISTEMA  THEN 'EXCLUIR'
WHEN X.POSSIVEL_ACAO='INCLUIR' THEN 'INCLUIR' END AS TIPO,
X.DATA_INICIO,
 X.DATA_FIM,
 X.FECHAMENTO_SISTEMA
,X.PK_ARTE
FROM (SELECT 
(SELECT    dado_origem FROM     ARTERH.rhinte_ed_it_conv cv WHERE codigo_conversao = 'FCPT' AND TO_DATE(dado_origem,'DD/MM/YYYY') = (SELECT MAX(TO_DATE(AUX.dado_origem,'DD/MM/YYYY')) FROM arterh.rhinte_ed_it_conv aux WHERE cv.codigo_conversao = aux.codigo_conversao))FECHAMENTO_SISTEMA,


'REMOVER OU ATUALIZAR' AS POSSIVEL_ACAO, 'IFPONTO' AS ORIGEM,IF.CODIGO_EMPRESA,IF.TIPO_CONTRATO,IF.CODIGO_CONTRATO,IF.CODIGO_LEGADO,if.codigo_justificativa,if.nome_justificativa,IF.DATA_INICIO,IF.DATA_FIM, IF.PK_ARTE FROM PONTO_ELETRONICO.IFPONTO_AFASTAMENTOS IF 

WHERE NOT EXISTS (
SELECT * FROM PONTO_ELETRONICO.sugesp_bi_afastamentos A WHERE A.CODIGO_EMPRESA=IF.CODIGO_EMPRESA AND A.CODIGO_CONTRATO=IF.CODIGO_CONTRATO AND A.TIPO_CONTRATO=IF.TIPO_CONTRATO
AND a.codigo_justificativa=case when IF.CODIGO_JUSTIFICATIVA='1157' then '0029' 
when IF.CODIGO_JUSTIFICATIVA='504' then '0504'
when IF.CODIGO_JUSTIFICATIVA='529' then '0529'
else IF.CODIGO_JUSTIFICATIVA end 
AND A.ORIGEM='ACERTO_BASE' AND TRUNC(A.DT_SAIU_ARTE)=TRUNC(SYSDATE)
AND (

(TO_DATE(IF.DATA_INICIO,'DD/MM/YYYY') BETWEEN TO_DATE(A.DATA_INICIO,'DD/MM/YYYY') AND TO_DATE(A.DATA_FIM,'DD/MM/YYYY')AND  TO_DATE(IF.DATA_FIM,'DD/MM/YYYY') = TO_DATE(A.DATA_FIM,'DD/MM/YYYY')  ) 
OR 
( TO_DATE(IF.DATA_INICIO,'DD/MM/YYYY')<= TO_DATE(A.DATA_INICIO,'DD/MM/YYYY')  and  TO_DATE(IF.DATA_FIM,'DD/MM/YYYY') = TO_DATE(A.DATA_FIM,'DD/MM/YYYY') )


OR (TO_DATE(if.data_inicio,'DD/MM/YYYY')=TO_DATE(a.data_inicio,'DD/MM/YYYY') AND  TO_DATE(IF.DATA_FIM,'DD/MM/YYYY')=TO_DATE(A.DATA_FIM,'DD/MM/YYYY'))
)
)

AND if.codigo_justificativa NOT IN ('0580')
--AND IF.CODIGO_LEGADO IS NOT NULL
UNION ALL 
SELECT 
(SELECT    dado_origem FROM     ARTERH.rhinte_ed_it_conv cv WHERE codigo_conversao = 'FCPT' AND TO_DATE(dado_origem,'DD/MM/YYYY') = (SELECT MAX(TO_DATE(AUX.dado_origem,'DD/MM/YYYY')) FROM arterh.rhinte_ed_it_conv aux WHERE cv.codigo_conversao = aux.codigo_conversao))FECHAMENTO_SISTEMA,

'INCLUIR' AS POSSIVEL_ACAO,'ARTE' AS ORIGEM,A.CODIGO_EMPRESA,A.TIPO_CONTRATO,A.CODIGO_CONTRATO,A.CODIGO_LEGADO,A.codigo_justificativa,a.descricao,A.DATA_INICIO,A.DATA_FIM , A.PK_ARTE FROM PONTO_ELETRONICO.sugesp_bi_afastamentos A
WHERE  A.ORIGEM='ACERTO_BASE' AND TRUNC(A.DT_SAIU_ARTE)=TRUNC(SYSDATE) AND NOT EXISTS (
SELECT * FROM PONTO_ELETRONICO.IFPONTO_AFASTAMENTOS IF WHERE A.CODIGO_EMPRESA=IF.CODIGO_EMPRESA AND A.CODIGO_CONTRATO=IF.CODIGO_CONTRATO AND A.TIPO_CONTRATO=IF.TIPO_CONTRATO
AND a.codigo_justificativa=case when IF.CODIGO_JUSTIFICATIVA='1157' then '0029' 
when IF.CODIGO_JUSTIFICATIVA='504' then '0504'
when IF.CODIGO_JUSTIFICATIVA='529' then '0529'
else IF.CODIGO_JUSTIFICATIVA end 
AND (

(TO_DATE(A.DATA_INICIO,'DD/MM/YYYY') BETWEEN TO_DATE(IF.DATA_INICIO,'DD/MM/YYYY') AND TO_DATE(IF.DATA_FIM,'DD/MM/YYYY')
AND  TO_DATE(A.DATA_FIM,'DD/MM/YYYY') = TO_DATE(IF.DATA_FIM,'DD/MM/YYYY')
) 
OR 
(  TO_DATE(IF.DATA_INICIO,'DD/MM/YYYY')<= TO_DATE(A.DATA_INICIO,'DD/MM/YYYY') AND  TO_DATE(A.DATA_FIM,'DD/MM/YYYY') = TO_DATE(IF.DATA_FIM,'DD/MM/YYYY') 



)
OR (TO_DATE(if.data_inicio,'DD/MM/YYYY')=TO_DATE(a.data_inicio,'DD/MM/YYYY') AND  TO_DATE(IF.DATA_FIM,'DD/MM/YYYY')=TO_DATE(A.DATA_FIM,'DD/MM/YYYY'))
)
)
)X
---where codigo_contrato in (lpad('3094527',15,0))
)X

)loop
CONT:=CONT+1;
 INSERT
      INTO PONTO_ELETRONICO.SMARH_INT_PE_AFASTAMENTOS_V1
        (
          EMPRESA,
          AGRUPAMENTO_EMPRESA,
          CODIGO_LEGADO,
          TIPO,
          CODIGO_EMPRESA,
          TIPO_CONTRATO,
          CODIGO_CONTRATO,
          CODIGO_JUSTIFICATIVA,
          DESCRICAO,
          DATA_INICIO,
          DATA_FIM,
          DT_SAIU_ARTE,
          ORIGEM
    ,CODIGO_INTEGRA_ARTE
    ,PK_ARTE
        )
        VALUES
        (
          C1.EMPRESA,
          C1.AGRUPAMENTO_EMPRESA,
          C1.CODIGO_LEGADO,
          C1.TIPO,
          C1.CODIGO_EMPRESA,
          C1.TIPO_CONTRATO,
          C1.CODIGO_CONTRATO,
          C1.CODIGO_JUSTIFICATIVA,
          C1.DESCRICAO_JUSTIFICATIVA,
          C1.DATA_INICIO,
          C1.DATA_FIM,
          C1.DT_SAIU_ARTE,
          C1.ORIGEM
          ,PONTO_ELETRONICO.SEQUENCE_INTEGRA_ARTE.NEXTVAL 
          ,C1.PK_ARTE
        );
      COMMIT;
end loop;
end;
