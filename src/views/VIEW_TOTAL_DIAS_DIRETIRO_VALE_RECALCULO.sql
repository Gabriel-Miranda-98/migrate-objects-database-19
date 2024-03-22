
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VIEW_TOTAL_DIAS_DIRETIRO_VALE_RECALCULO" ("TIPO_CONTRATO", "CODIGO_EMPRESA", "CODIGO_CONTRATO", "DATA_CALCULO_FOLHA", "VALOR_DIAS_DE_DIREITO") AS 
  select 
fim.tipo_contrato,
fim.codigo_empresa,
fim.codigo_contrato,
FIM.DATA_CALCULO_FOLHA,
CASE 
WHEN FIM.DATA_CALCULO_FOLHA BETWEEN TO_DATE('01/08/2017','DD/MM/YYYY') AND TO_DATE('31/07/2018','DD/MM/YYYY') 
THEN (FIM.QTD_TRABALHO_VALE_BRUTO-FIM.QTD_DIAS_OCORRENCIA_VALE-FIM.QTD_DIAS_OCORRENCIA_FREQUENCIA)*20 
WHEN FIM.DATA_CALCULO_FOLHA BETWEEN TO_DATE('01/08/2018','DD/MM/YYYY') AND TO_DATE('30/04/2020','DD/MM/YYYY')
THEN (FIM.QTD_TRABALHO_VALE_BRUTO-FIM.QTD_DIAS_OCORRENCIA_VALE-FIM.QTD_DIAS_OCORRENCIA_FREQUENCIA)*20.50
WHEN FIM.DATA_CALCULO_FOLHA BETWEEN TO_DATE('01/05/2020','DD/MM/YYYY') AND TO_DATE('30/11/2020','DD/MM/YYYY')
THEN (FIM.QTD_TRABALHO_VALE_BRUTO-FIM.QTD_DIAS_OCORRENCIA_VALE-FIM.QTD_DIAS_OCORRENCIA_FREQUENCIA)*21.30
WHEN fim.DATA_CALCULO_FOLHA >= TO_DATE('01/12/2020','DD/MM/YYYY')
THEN (FIM.QTD_TRABALHO_VALE_BRUTO-FIM.QTD_DIAS_OCORRENCIA_VALE-FIM.QTD_DIAS_OCORRENCIA_FREQUENCIA)*22.00
ELSE 0 END AS VALOR_DIAS_DE_DIREITO


 from 
 (SELECT
x.codigo_empresa,
x.tipo_contrato,
x.codigo_contrato,

X.DATA_CALCULO_FOLHA,
CASE
          WHEN x.QTD_TRABLHO_MES_VALE IS NULL
          THEN 0
          ELSE x.QTD_TRABLHO_MES_VALE
        END AS QTD_TRABALHO_VALE_BRUTO,

         (
        SELECT SUM(QUANT) FROM (
        SELECT COUNT(1)QUANT FROM (
        SELECT CODIGO_EMPRESA,TIPO_CONTRATO, CODIGO_CONTRATO,DT_INI_GOZO, DT_FIM_GOZO_FORCA,tipo_inter_gozo, data_1 from(
        SELECT CODIGO_EMPRESA,TIPO_CONTRATO, CODIGO_CONTRATO,DT_INI_GOZO, DT_FIM_GOZO_FORCA,tipo_inter_gozo,
        (to_date(DT_INI_GOZO,'dd/mm/yyyy')-1) + level as data_1
        FROM (
        select RHFERI_FERIAS.CODIGO_EMPRESA,RHFERI_FERIAS.TIPO_CONTRATO, RHFERI_FERIAS.CODIGO_CONTRATO,RHFERI_FERIAS.DT_INI_GOZO, RHFERI_FERIAS.DT_FIM_GOZO_FORCA,RHPARM_P_FERI.tipo_inter_gozo 
        from arterh.RHFERI_FERIAS
        INNER JOIN RHPARM_P_FERI
        ON RHFERI_FERIAS.TIPO_FERIAS = RHPARM_P_FERI.CODIGO
        AND RHFERI_FERIAS.CODIGO_EMPRESA = RHPARM_P_FERI.CODIGO_EMPRESA
        WHERE RHFERI_FERIAS.codigo_contrato =x.codigo_contrato
        AND RHFERI_FERIAS.codigo_empresa  =x.codigo_empresa
        AND RHFERI_FERIAS.tipo_contrato   =x.tipo_contrato
        AND ( RHFERI_FERIAS.DT_INI_GOZO BETWEEN DATA_INI_VALE AND DATA_FIM_VALE
        OR RHFERI_FERIAS.DT_FIM_GOZO_FORCA BETWEEN DATA_INI_VALE AND DATA_FIM_VALE )
        AND RHFERI_FERIAS.STATUS_CONFIRMACAO = '5'
        )A
        connect by level <= to_date(DT_FIM_GOZO_FORCA,'dd/mm/yyyy') - (to_date(DT_INI_GOZO,'dd/mm/yyyy')-1) 
        ) A
         WHERE a.data_1 BETWEEN DATA_INI_VALE AND DATA_FIM_VALE
        AND  A.data_1 NOT in (
        SELECT DATA_OCORRENCIA
        FROM ARTERH.SMARH_INT_OCORRENCIA_FREQ fq
        WHERE DATA_OCORRENCIA BETWEEN DATA_INI_VALE AND DATA_FIM_VALE
        AND ORIGEM                       ='MES_VALE'
        and fq.codigo_situcao_ponto = '0029'
        AND fq.codigo_contrato           =x.codigo_contrato
        AND fq.codigo_empresa            =x.codigo_empresa
        AND fq.tipo_contrato             =x.tipo_contrato
        )        
        AND  A.data_1 NOT in (
        select DATA_DIA from RHPARM_CALEND_DT
        WHERE DATA_DIA = A.data_1
        AND CODIGO = '0001' 
        AND A.tipo_inter_gozo = 'U'
        )
        )

        UNION ALL
        SELECT COUNT(1)QUANT
        FROM ARTERH.SMARH_INT_OCORRENCIA_FREQ fq
        WHERE DATA_OCORRENCIA BETWEEN DATA_INI_VALE AND DATA_FIM_VALE
        AND ORIGEM                       ='MES_VALE'
        AND fq.codigo_contrato           =x.codigo_contrato
        AND fq.codigo_empresa            =x.codigo_empresa
        AND fq.tipo_contrato             =x.tipo_contrato
        AND FQ.CODIGO_SITUCAO_PONTO NOT IN ('1012','0515','1004','1006','1145')

        )
        ) AS QTD_DIAS_OCORRENCIA_VALE,

(SELECT COUNT(1)QUANT
        FROM ARTERH.SMARH_INT_OCORRENCIA_FREQ fq
        WHERE DATA_OCORRENCIA BETWEEN DATA_INI_FREQUENCIA AND DATA_FIM_FREQUENCIA
        AND ORIGEM                       ='MES_FREQUENCIA'
        AND fq.codigo_contrato           =x.codigo_contrato
        AND fq.codigo_empresa            =x.codigo_empresa
        AND fq.tipo_contrato             =x.tipo_contrato
        AND FQ.CODIGO_SITUCAO_PONTO NOT IN ('1012','0515','1004','1006','1145')
        )            AS QTD_DIAS_OCORRENCIA_FREQUENCIA



FROM ARTERH.smarh_int_recalculo_vale x 
)fim