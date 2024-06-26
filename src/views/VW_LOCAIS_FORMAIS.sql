
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "PONTO_ELETRONICO"."VW_LOCAIS_FORMAIS" ("CODIGO_EMPRESA", "CGC", "CODIGO_END", "ID_AGRUP", "NIVEL_AGRUP_ESTRUT", "COD_CGERENC1", "COD_CGERENC2", "COD_CGERENC3", "COD_CGERENC4", "COD_CGERENC5", "COD_CGERENC6", "DESCRICAO", "ABREVIACAO", "DATA_IMPLANT", "DATA_EXTINCAO", "EMPRESA_GESTOR", "COD_PESSOA_GESTOR", "TIPO_CONTRATO_GESTOR", "CONTRATO_GESTOR", "COD_CGERENC_SUP1", "COD_CGERENC_SUP2", "COD_CGERENC_SUP3", "COD_CGERENC_SUP4", "COD_CGERENC_SUP5", "COD_CGERENC_SUP6", "DESCRIC_LOCAL_SUPERIOR", "COD_ENDERECO", "DESCR_ENDERECO", "TIPO_LOGRADOURO", "ENDERECO", "NUMERO", "COMPLEMENTO", "BAIRRO", "MUNICIPIO", "CEP", "REGIAO", "LATITUDE", "LONGITUDE", "IPS_REDE", "LOGIN_ENDERECO", "DT_ULT_ALTER_ENDE") AS 
  (
    SELECT  
X2.CODIGO_EMPRESA, X2.CGC, X2.CODIGO_END, X2.ID_AGRUP, X2.NIVEL_AGRUP_ESTRUT, X2.COD_CGERENC1, X2.COD_CGERENC2, X2.COD_CGERENC3, X2.COD_CGERENC4, X2.COD_CGERENC5, X2.COD_CGERENC6, X2.DESCRICAO, X2.ABREVIACAO, X2.DATA_IMPLANT, X2.DATA_EXTINCAO, 
X2.EMPRESA_GESTOR, X2.COD_PESSOA_GESTOR, X2.TIPO_CONTRATO_GESTOR, X2.CONTRATO_GESTOR, 
X2.COD_CGERENC_SUP1, X2.COD_CGERENC_SUP2, X2.COD_CGERENC_SUP3, X2.COD_CGERENC_SUP4, X2.COD_CGERENC_SUP5, X2.COD_CGERENC_SUP6, X2.DESCRIC_LOCAL_SUPERIOR, 
X2.COD_ENDERECO, X2.DESCR_ENDERECO, X2.TIPO_LOGRADOURO, X2.ENDERECO, X2.NUMERO, X2.COMPLEMENTO, X2.BAIRRO, X2.MUNICIPIO, X2.CEP, X2.REGIAO, X2.LATITUDE, X2.LONGITUDE, X2.IPS_REDE, X2.LOGIN_ENDERECO, X2.DT_ULT_ALTER_ENDE
FROM( SELECT X.ID_AGRUP, X.CGC, X.COD_ENDERECO CODIGO_END, X.CODIGO_EMPRESA, 
X.COD_CGERENC1, X.COD_CGERENC2, X.COD_CGERENC3, X.COD_CGERENC4, X.COD_CGERENC5, X.COD_CGERENC6, X.DESCRICAO, X.ABREVIACAO,
X.DATA_IMPLANT, X.DATA_EXTINCAO, 
CASE WHEN X.COD_EMPR_PESS_INF IS NOT NULL THEN X.COD_EMPR_PESS_INF ELSE X.COD_EMPRESA_PESS END AS EMPRESA_GESTOR,
CASE WHEN X.COD_PESS_INFORMAL IS NOT NULL THEN X.COD_PESS_INFORMAL ELSE X.COD_PESSOA_RESP END AS COD_PESSOA_GESTOR,
CASE WHEN X.TIPO_CONT_RESP_INF IS NOT NULL THEN X.TIPO_CONT_RESP_INF ELSE X.TIPO_CONT_RESP END AS TIPO_CONTRATO_GESTOR,
CASE WHEN  X.CONTRATO_RESP_INF IS NOT NULL THEN X.CONTRATO_RESP_INF ELSE X.CONTRATO_RESP END AS CONTRATO_GESTOR,
X.COD_CGERENC_SUP1, X.COD_CGERENC_SUP2, X.COD_CGERENC_SUP3, X.COD_CGERENC_SUP4, X.COD_CGERENC_SUP5, X.COD_CGERENC_SUP6, 
S.TEXTO_ASSOCIADO AS DESCRIC_LOCAL_SUPERIOR, E.NIVEL_AGRUP_ESTRUT
,EN.*
FROM ARTERH.RHORGA_CUSTO_GEREN X
LEFT OUTER JOIN ARTERH.RHORGA_CUSTO_GEREN S ON S.CODIGO_EMPRESA = X.CODIGO_EMPRESA AND S.COD_CGERENC1 = X.COD_CGERENC_SUP1 AND S.COD_CGERENC2 =X.COD_CGERENC_SUP2 AND S.COD_CGERENC3 =X.COD_CGERENC_SUP3 AND S.COD_CGERENC4 =X.COD_CGERENC_SUP4 AND S.COD_CGERENC5 =X.COD_CGERENC_SUP5 AND S.COD_CGERENC6 =X.COD_CGERENC_SUP6
LEFT OUTER JOIN ARTERH.RHORGA_AGRUPADOR A ON X.CODIGO_EMPRESA = A.CODIGO_EMPRESA AND X.COD_CGERENC1 = A.COD_AGRUP1 AND X.COD_CGERENC2 = A.COD_AGRUP2 AND X.COD_CGERENC3 = A.COD_AGRUP3 AND X.COD_CGERENC4 = A.COD_AGRUP4 AND X.COD_CGERENC5 = A.COD_AGRUP5 AND X.COD_CGERENC6 = A.COD_AGRUP6
LEFT OUTER JOIN ARTERH.RHORGA_ESTRUT_AGR E ON  E.ID_AGRUP = A.ID_AGRUP AND E.CODIGO_EMPRESA=A.CODIGO_EMPRESA AND E.CODIGO_EMPRESA=A.CODIGO_EMPRESA
LEFT OUTER JOIN ARTERH.RHORGA_EMPRESA EM ON X.CODIGO_EMPRESA=EM.CODIGO
LEFT OUTER JOIN (SELECT EN.CODIGO COD_ENDERECO, EN.DESCRICAO DESCR_ENDERECO, EN.TIPO_LOGRADOURO, EN.ENDERECO, EN.NUMERO, EN.COMPLEMENTO, EN.BAIRRO, EN.MUNICIPIO, EN.CEP, EN.CODIGO_ENDERECO01 REGIAO, EN.CAIXA_POSTAL LATITUDE, EN.TELEX LONGITUDE, EN.TEXTO_ASSOC IPS_REDE, EN.LOGIN_USUARIO LOGIN_ENDERECO, EN.DT_ULT_ALTER_USUA DT_ULT_ALTER_ENDE
FROM ARTERH.RHORGA_ENDERECO EN WHERE EN.CODIGO_ENDERECO01 IS NOT NULL OR EN.CAIXA_POSTAL IS NOT NULL OR EN.TELEX IS NOT NULL) EN ON EN.COD_ENDERECO = X.COD_ENDERECO
WHERE 
--X.CODIGO_EMPRESA =(SELECT PONT.* FROM (SELECT SUBSTR(PONT.DADO_ORIGEM,20,4)EMPRESA FROM ARTERH.RHINTE_ED_IT_CONV PONT WHERE CODIGO_CONVERSAO='PONT' GROUP BY SUBSTR(PONT.DADO_ORIGEM,20,4))PONT WHERE PONT.EMPRESA=X.CODIGO_EMPRESA)
X.CODIGO_EMPRESA =(SELECT PONT.* FROM (SELECT PONT.DADO_ORIGEM EMPRESA FROM ARTERH.RHINTE_ED_IT_CONV PONT WHERE CODIGO_CONVERSAO='EMPA' GROUP BY PONT.DADO_ORIGEM)PONT WHERE PONT.EMPRESA=X.CODIGO_EMPRESA)
AND A.TIPO_AGRUP = 'G'
--AND A.CODIGO_EMPRESA =(SELECT PONT.* FROM (SELECT SUBSTR(PONT.DADO_ORIGEM,20,4)EMPRESA FROM ARTERH.RHINTE_ED_IT_CONV PONT WHERE CODIGO_CONVERSAO='PONT' GROUP BY SUBSTR(PONT.DADO_ORIGEM,20,4))PONT WHERE PONT.EMPRESA=A.CODIGO_EMPRESA)
AND A.CODIGO_EMPRESA =(SELECT PONT.* FROM (SELECT PONT.DADO_ORIGEM EMPRESA FROM ARTERH.RHINTE_ED_IT_CONV PONT WHERE CODIGO_CONVERSAO='EMPA' GROUP BY PONT.DADO_ORIGEM)PONT WHERE PONT.EMPRESA=A.CODIGO_EMPRESA)
AND E.ANO_MES_REFERENCIA = (SELECT MAX(ANO_MES_REFERENCIA) FROM ARTERH.RHORGA_ESTRUT_AGR AUX WHERE AUX.ID_AGRUP = E.ID_AGRUP AND AUX.CODIGO_EMPRESA=E.CODIGO_EMPRESA)
AND E.NIVEL_AGRUP_ESTRUT = E.NIVEL_SUP_AGR_EST AND TRIM(X.CGC)=TRIM(EM.CGC)
)X2 WHERE X2.COD_CGERENC1 NOT IN ('000099','000098') AND X2.COD_CGERENC2 NOT IN ('000095')
AND SUBSTR(X2.COD_CGERENC1,1,4) = '0000'
--AND X2.DATA_EXTINCAO IS NULL --LOCAIS ATIVOS
--ORDER BY X2.CODIGO_EMPRESA, X2.COD_CGERENC1, X2.COD_CGERENC2, X2.COD_CGERENC3, X2.COD_CGERENC4, X2.COD_CGERENC5, X2.COD_CGERENC6
    )