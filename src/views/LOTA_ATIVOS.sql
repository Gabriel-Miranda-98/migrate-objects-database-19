
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."LOTA_ATIVOS" ("COD_PLANO", "COD_ORG", "MATRICULA", "CPF_SEGURADO", "DATA_ADMISSAO", "SITU", "COD_LOTACAO", "COD_LOTACAO_SUPERIOR", "DATA_DESLIGAMENTO", "CODIGO_SITUACAO", "COD_LOTA_CEDIDO", "RAZAO_SOCIAL", "CPNJ_CEDIDO", "SERVIDOR_CEDIDO", "PRIMEIRO_EMPREGO") AS 
  SELECT  
CASE
   WHEN to_char(CO.DATA_ADMISSAO,'YYYYMMDD') < '20111230'
    THEN '0001'
    WHEN to_char(CO.DATA_ADMISSAO,'YYYYMMDD') >= '20111230'
    THEN '0002'
  END AS COD_PLANO, 

CO.CODIGO_EMPRESA AS COD_ORG, 
TO_NUMBER(SUBSTR(CO.CODIGO, 5,10)) ||
	CASE
	WHEN SUBSTR(CO.CODIGO, 15,1) = 'X'
	THEN 7
	ELSE to_number(SUBSTR(CO.CODIGO, 15,1))
	END                                     AS MATRICULA,
SUBSTR(PE.CPF, 1,11) AS CPF_SEGURADO,
to_char(CO.DATA_ADMISSAO,'YYYYMMDD') AS DATA_ADMISSAO,
CO.SITUACAO_FUNCIONAL AS SITU,
SUBSTR(CO.COD_CUSTO_GERENC1,5,2)||'00000000000' AS COD_LOTACAO,

SUBSTR(CO.COD_CUSTO_GERENC1,5,2)||'00000000000' AS COD_LOTACAO_SUPERIOR,


CASE  
WHEN   TO_CHAR(CO.DATA_RESCISAO,'YYYYMMDD') IS NOT NULL THEN TO_CHAR(CO.DATA_RESCISAO,'YYYYMMDD')
WHEN co.situacao_funcional = '5800' and TO_CHAR(PE.DATA_FALECIMENTO,'YYYYMMDD')  IS NULL AND TO_NUMBER(CO.DATA_RESCISAO,'YYYYMMDD') IS NULL THEN TO_CHAR('20000101','99999999')
WHEN co.situacao_funcional  NOT IN ('1000','1002','1004','1202','1219','1212','1400','1450','1700','1701')  THEN TO_CHAR(CO.DATA_INIC_AFAST,'YYYYMMDD')
else TO_CHAR(PE.DATA_FALECIMENTO,'YYYYMMDD')
END  AS  DATA_DESLIGAMENTO,

case when  co.situacao_funcional in ('5300') then 2
when co.situacao_funcional in ('5800') then 3
when co.situacao_funcional in('5000','5002','5003','5004') then 6
when  co.situacao_funcional between '5100' and '5113' then 7
when co.situacao_funcional in ('5500','5555','5600','5610','6000','6003','6010','8000') then 8
else 1 end AS CODIGO_SITUACAO,

CASE WHEN co.situacao_funcional ='5300' THEN (SUBSTR(ORGA.COD_UNIDADE1,5,2)||'00000000000') ELSE NULL END AS COD_LOTA_CEDIDO,
CASE WHEN co.situacao_funcional ='5300' THEN ORGA.RAZAO_SOCIAL ELSE NULL END AS RAZAO_SOCIAL,
CASE WHEN co.situacao_funcional ='5300' THEN ORGA.CGC ELSE NULL END AS CPNJ_CEDIDO,
CASE WHEN co.situacao_funcional ='5300' THEN 'S' ELSE 'N' END AS SERVIDOR_CEDIDO,

NULL AS PRIMEIRO_EMPREGO

FROM RHPESS_CONTRATO CO, RHPESS_PESSOA PE, RHORGA_CUSTO_GEREN CG, RHPARM_SIT_FUNC ST,RHORGA_UNIDADE ORGA

WHERE
CO.CODIGO_EMPRESA = PE.CODIGO_EMPRESA
AND CO.CODIGO_PESSOA = PE.CODIGO 
AND CO.CODIGO_EMPRESA = CG.CODIGO_EMPRESA  
AND CO.SITUACAO_FUNCIONAL = ST.CODIGO
---AND CG.COD_PESSOA_RESP = PE.CODIGO  
AND  CG.COD_CGERENC1 = CO.COD_CUSTO_GERENC1
AND CO.COD_UNIDADE1 = ORGA.COD_UNIDADE1  
AND CO.COD_UNIDADE2 = ORGA.COD_UNIDADE2
AND CO.COD_UNIDADE3 = ORGA.COD_UNIDADE3
AND CO.COD_UNIDADE4 = ORGA.COD_UNIDADE4
AND CO.COD_UNIDADE5 = ORGA.COD_UNIDADE5
AND CO.COD_UNIDADE6 = ORGA.COD_UNIDADE6 
AND CO.CODIGO_EMPRESA = ORGA.CODIGO_EMPRESA 

AND cO.codigo_empresa IN  ('0013','0014','0001')
AND CO.TIPO_CONTRATO IN('0001', '0007')
AND CO.VINCULO IN ('0000','0002')
--and SUBSTR(CO.CODIGO, 5,10) = 0000042849
AND CO.SITUACAO_FUNCIONAL NOT IN ('1710', '1715', '1800', '1850', '1900', '5000', '5001', '5002', '5003', '5004', '5005', '5006',
                                      '5008', '5009', '5011', '5019', '5022', '5026', '5028', '5200', '5201', '5400', '5555', '5700', '5800',
                                      '5801', '5808', '5900', '5901', '6002', '6003', '8000')
AND (CO.CODIGO < '000000099999999' AND CO.CODIGO NOT IN('000000000777777','000000000823701','000000000833014','000000000866265','000000000747428','000000000190072','000000000420534')) /*FALECIDOS PIA*/

AND CO.ANO_MES_REFERENCIA  =
(SELECT MAX(A.ANO_MES_REFERENCIA)
  FROM RHPESS_CONTRATO A
  WHERE A.CODIGO            = CO.CODIGO
  AND A.CODIGO_EMPRESA      = CO.CODIGO_EMPRESA
  AND A.TIPO_CONTRATO       = CO.TIPO_CONTRATO
  AND A.ANO_MES_REFERENCIA <= add_months(sysdate,(-1))-0)
and not exists (select c.codigo from rhpess_contrato c where 
  PE.CODIGO_EMPRESA = ('1700')
  AND C.TIPO_CONTRATO = '0001'
  AND C.VINCULO IN ('0000','0002')
  AND C.SITUACAO_FUNCIONAL = '5800'
--AND CO.SITUACAO_FUNCIONAL NOT IN ('1700','1002','1701','1715','1800','1900','5000','5002','5003','5004','5005','5006','5008','5009','5011','5200','5700','5900','5901','6002','8000')
--AND SUBSTR(CO.CODIGO,5,10) ='0000091112' --'0000009627'
AND PE.CODIGO < '000000099999999'
AND C.ANO_MES_REFERENCIA  =
(SELECT MAX(B.ANO_MES_REFERENCIA)
  FROM RHPESS_CONTRATO B
  WHERE B.CODIGO            = C.CODIGO
  AND B.CODIGO_EMPRESA      = C.CODIGO_EMPRESA
  AND B.TIPO_CONTRATO       = C.TIPO_CONTRATO
  AND B.ANO_MES_REFERENCIA <= add_months(sysdate,(-1))-0)
  AND C.CODIGO = CO.CODIGO)

GROUP BY co.codigo,PE.CPF,CO.DATA_ADMISSAO,CO.CODIGO_EMPRESA, co.situacao_funcional,PE.DATA_FALECIMENTO,CO.DATA_RESCISAO,CO.DATA_INIC_AFAST,ORGA.COD_UNIDADE1,ORGA.RAZAO_SOCIAL,ORGA.CGC,PE.CODIGO,
SUBSTR(CO.COD_CUSTO_GERENC1,5,2)