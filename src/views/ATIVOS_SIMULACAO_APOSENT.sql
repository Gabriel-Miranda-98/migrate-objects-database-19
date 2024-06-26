
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."ATIVOS_SIMULACAO_APOSENT" ("ANO_MES_REFERENCIA", "CODIGO_PLANO", "CODIGO_EMPRESA", "MATRICULA", "DIGITO", "NOME", "CPF", "PIS_PASEP", "CODIGO_CARGO", "DATA_ADMISSAO_POSSE", "SITUACAO_FUNCIONAL", "TIPO_OCORRENCIA", "DATA_INICIO", "DATA_FIM", "DIAS", "CID") AS 
  SELECT 
  TB.ANO_MES_REFERENCIA,
  TB.CODIGO_PLANO,
  TB.CODIGO_EMPRESA,
  TB.MATRICULA,
  TB.DIGITO,
  TB.NOME,
  TB.CPF,
  TB.PIS_PASEP,
  TB.CODIGO_CARGO,
  TB.DATA_ADMISSAO_POSSE,
  TB.SITUACAO_FUNCIONAL,
  TB.TIPO_OCORRENCIA,
  TB.DATA_INICIO,
  TB.DATA_FIM,
  TB.DIAS,
  TB.CID
FROM (  
  SELECT DISTINCT
    TO_CHAR(RHC.DATA_INIC_SITUACAO, 'YYYYMM') AS ANO_MES_REFERENCIA,
    TO_NUMBER(SUBSTR(TRIM(CO.COD_CARGO_EFETIVO), 12, 4), '9999') AS CODIGO_CARGO,
    CO.CODIGO_EMPRESA,
    TO_NUMBER (SUBSTR(CO.CODIGO, 5, 10)) AS MATRICULA,
    CASE WHEN SUBSTR (CO.CODIGO, 15, 1) = 'X' THEN 7 ELSE TO_NUMBER (SUBSTR (CO.CODIGO, 15, 1)) END AS DIGITO,
    SUBSTR(TRIM(CO.NOME), 1, 80) AS NOME,
    SUBSTR(TRIM(PE.CPF), 1, 11) AS CPF,
    NVL(TO_NUMBER(TRIM(PE.PIS_PASEP)), 0) AS PIS_PASEP,
    CASE 
        WHEN CO.DATA_ADMISSAO <= '30/12/2011' THEN TO_NUMBER('0001') ELSE TO_NUMBER('0002')
    END AS CODIGO_PLANO,
    CASE
        WHEN CO.DATA_EFETIVO_EXERC IS NOT NULL THEN CO.DATA_EFETIVO_EXERC ELSE CO.DATA_ADMISSAO
    END AS DATA_ADMISSAO_POSSE,
    RHC.COD_SIT_FUNCIONAL AS SITUACAO_FUNCIONAL,
    CASE RHC.COD_SIT_FUNCIONAL
			WHEN '5000' THEN '0002'  --5000 5002 5003 5004 5010 5012 5019 5555
			WHEN '5002' THEN '0002'
			WHEN '5003' THEN '0002'
			WHEN '5004' THEN '0002'
			WHEN '5010' THEN '0002'
			WHEN '5012' THEN '0002'
			WHEN '5019' THEN '0002'
			WHEN '5555' THEN '0002'
			WHEN '1005' THEN '0003'  --1005 1007 1009 1010 1015 1026 1027 1029 1200 1201 1202 1203 1204 1205 1206 1207 1208 1209 1212 1218 1219 1220 1221 1222 1223 1225 1226 1227 1255 1237 1350
			WHEN '1007' THEN '0003'
			WHEN '1009' THEN '0003'
			WHEN '1010' THEN '0003'
			WHEN '1015' THEN '0003'
			WHEN '1026' THEN '0003'
			WHEN '1027' THEN '0003'
			WHEN '1029' THEN '0003'
			WHEN '1200' THEN '0003'
			WHEN '1201' THEN '0003'
			WHEN '1202' THEN '0003'
			WHEN '1203' THEN '0003'
			WHEN '1204' THEN '0003'
			WHEN '1205' THEN '0003'
			WHEN '1206' THEN '0003'
			WHEN '1207' THEN '0003'
			WHEN '1208' THEN '0003'
			WHEN '1209' THEN '0003'
			WHEN '1212' THEN '0003'
			WHEN '1218' THEN '0003'
			WHEN '1219' THEN '0003'
			WHEN '1220' THEN '0003'
			WHEN '1221' THEN '0003'
			WHEN '1222' THEN '0003'
			WHEN '1223' THEN '0003'
			WHEN '1225' THEN '0003'
			WHEN '1226' THEN '0003'
			WHEN '1227' THEN '0003'
			WHEN '1255' THEN '0003'
			WHEN '1237' THEN '0003'
			WHEN '1350' THEN '0003'
			WHEN '5100' THEN '0004' -- 5100 5101 5102 5103 5104 5105 5106 5107 5108 5109 5110 5111 5112 5113 5114 5116 5118 5119 5120 5121 5122 5123 6122  
			WHEN '5101' THEN '0004'
			WHEN '5102' THEN '0004'
			WHEN '5103' THEN '0004'
			WHEN '5104' THEN '0004'
			WHEN '5105' THEN '0004'
			WHEN '5106' THEN '0004'
			WHEN '5107' THEN '0004'
			WHEN '5108' THEN '0004'
			WHEN '5109' THEN '0004'
			WHEN '5110' THEN '0004'
			WHEN '5111' THEN '0004'
			WHEN '5112' THEN '0004'
			WHEN '5113' THEN '0004'
			WHEN '5114' THEN '0004'
			WHEN '5116' THEN '0004'
			WHEN '5118' THEN '0004'
			WHEN '5119' THEN '0004'
			WHEN '5120' THEN '0004'
			WHEN '5121' THEN '0004'
			WHEN '5122' THEN '0004'
			WHEN '5123' THEN '0004'
			WHEN '6122' THEN '0004'
			WHEN '1302' THEN '0005' -- 1302 1303 1316 1400 1402 1403 1404 1405 1406 1407 1409 1450 1453 1454 1456
			WHEN '1303' THEN '0005'
			WHEN '1316' THEN '0005'
			WHEN '1400' THEN '0005'
			WHEN '1402' THEN '0005'
			WHEN '1403' THEN '0005'
			WHEN '1404' THEN '0005'
			WHEN '1405' THEN '0005'
			WHEN '1406' THEN '0005'
			WHEN '1407' THEN '0005'
			WHEN '1409' THEN '0005'
			WHEN '1450' THEN '0005'
			WHEN '1453' THEN '0005'
			WHEN '1454' THEN '0005'
			WHEN '1456' THEN '0005'  
			WHEN '5200' THEN '0006' -- 5200 5201 5203 5204 5205 5206 5207 5210 5300 5303 5401
			WHEN '5201' THEN '0006'
			WHEN '5203' THEN '0006'
			WHEN '5204' THEN '0006'
			WHEN '5205' THEN '0006'
			WHEN '5206' THEN '0006'
			WHEN '5207' THEN '0006'
			WHEN '5210' THEN '0006'
			WHEN '5300' THEN '0006'
			WHEN '5303' THEN '0006'
			WHEN '5401' THEN '0006'
			WHEN 'REQUISITADO(A) COM ÔNUS' THEN '0007'
			WHEN 'REQUISITADO(A) SEM ÔNUS' THEN '0008'
			WHEN '1310' THEN '0010' -- 1310
			WHEN '5800' THEN '0011' -- 5800 5808 5809 5810 
			WHEN '5808' THEN '0011'
			WHEN '5809' THEN '0011'
			WHEN '5810' THEN '0011'
			WHEN '1002' THEN '0012' -- 1002 1700 1701 1703 1704 1705 1706 1707 1715
			WHEN '1700' THEN '0012'
			WHEN '1701' THEN '0012'
			WHEN '1703' THEN '0012'
			WHEN '1704' THEN '0012'
			WHEN '1705' THEN '0012'
			WHEN '1706' THEN '0012'
			WHEN '1707' THEN '0012'
			WHEN '1715' THEN '0012'
			WHEN '1230' THEN '0013' -- 1230 
			WHEN 'REFORMA MILITAR' THEN '0014' 
			WHEN 'RESERVA MILITAR' THEN '0015'
			WHEN 'FALTA (NÃO CONTADA COMO TEMPO DE EFETIVO EXERCÍCIO)' THEN '0030'
		ELSE '0099' 
		END AS TIPO_OCORRENCIA,
    RHC.DATA_INIC_SITUACAO AS DATA_INICIO,
    RHC.DATA_FIM_SITUACAO  AS DATA_FIM,
    CASE 
			WHEN RHC.DATA_FIM_SITUACAO - RHC.DATA_INIC_SITUACAO IS NULL THEN TRUNC(SYSDATE - RHC.DATA_INIC_SITUACAO, 0)
			WHEN RHC.DATA_FIM_SITUACAO - RHC.DATA_INIC_SITUACAO = 0 THEN 1
			ELSE TRUNC(RHC.DATA_FIM_SITUACAO - RHC.DATA_INIC_SITUACAO, 0) 
		END AS DIAS,
    NULL AS CID
 FROM  RHPESS_CONTRATO CO, RHCGED_ALT_SIT_FUN RHC, RHPESS_PESSOA PE
WHERE CO.CODIGO = RHC.CODIGO
  AND PE.CODIGO = CO.CODIGO_PESSOA
  AND RHC.CODIGO = '000000000451170' AND
  CO.SITUACAO_FUNCIONAL IN (
        '5000', '5002', '5003', '5004', '5010', '5012', '5019', '5555', '1005', '1007', '1009', '1010', '1015', '1026', '1027', '1029', '1200', 
        '1201', '1202', '1203', '1204', '1205', '1206', '1207', '1208', '1209', '1212', '1218', '1219', '1220', '1221', '1222', '1223', '1225',
        '1226', '1227', '1255', '1237', '1350', '5100', '5101', '5102', '5103', '5104', '5105', '5106', '5107', '5108', '5109', '5110', '5111', 
        '5112', '5113', '5114', '5116', '5118', '5119', '5120', '5121', '5122', '5123', '6122', '1302', '1303', '1316', '1400', '1402', '1403',
        '1404', '1405', '1406', '1407', '1409', '1450', '1453', '1454', '1456', '5200', '5201', '5203', '5204', '5205', '5206', '5207', '5210',
        '5300', '5303', '5401', '1310')
) TB
ORDER BY TB.ANO_MES_REFERENCIA, TB.CPF