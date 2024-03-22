
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."SMARH_INT_PE_CAD_DEPTO_HIERAR" (DATA_INICIO IN VARCHAR2, DATA_FIM IN VARCHAR2)
AS
BEGIN
DECLARE
vCONTADOR NUMBER;
vDATA_INICIO Varchar2(10);
vDATA_FIM Varchar2(10);
BEGIN
dbms_output.enable(null);
vCONTADOR :=0;
vDATA_INICIO := DATA_INICIO;
vDATA_FIM := DATA_FIM;
FOR C1 IN
(
SELECT XX.* FROM(
----------------------------------------------------------------------------------PARTE 1 JÃƒÆ’Ã‚Â? EXISTENTE ADM DIRETA---------------------------------------------------------------------------------------------------
select
X.CODIGO_EMPRESA,
CASE WHEN X.CODIGO_EMPRESA = '0001' THEN 'PREF.MUN.BELO HORIZONTE' WHEN x.CODIGO_EMPRESA = '0098' THEN 'PREF.MUN.BH CONTRATOS' END AS EMPRESA,
CASE WHEN X.CODIGO_EMPRESA in ('0001','0098','0015','0021','0032') then 'ADM DIRETA' else 'ADM INDIRETA' END AS AGRUPAMENTO_EMPRESA,
CASE WHEN X.COD_CGERENC1 IS NOT NULL THEN SUBSTR(X.CODIGO_EMPRESA,3,2)||'.'||X.COD_CGERENC1||'.'||X.COD_CGERENC2||'.'||X.COD_CGERENC3||'.'||X.COD_CGERENC4||'.'||X.COD_CGERENC5||'.'||X.COD_CGERENC6 ELSE NULL END AS CODIGO_UNIDADE,
--ATE 27/3/2017 PASSAR COM 3 DIGITOS
--SUBSTR(COD_CGERENC1,4,3)||'.'||SUBSTR(COD_CGERENC2,4,3)||'.'||SUBSTR(COD_CGERENC3,4,3)||'.'||SUBSTR(COD_CGERENC4,4,3)||'.'||SUBSTR(COD_CGERENC5,4,3)||'.'||SUBSTR(COD_CGERENC6,4,3) AS CODIGO_UNIDADE,
TRIM(X.TEXTO_ASSOCIADO) AS DESCRICAO_UNIDADE,
TRIM(X.ABREVIACAO) AS ABREVIACAO,
X.COD_CGERENC1 AS COD_UNIDADE1,
X.COD_CGERENC2 AS COD_UNIDADE2,
X.COD_CGERENC3 AS COD_UNIDADE3,
X.COD_CGERENC4 AS COD_UNIDADE4,
X.COD_CGERENC5 AS COD_UNIDADE5,
X.COD_CGERENC6 AS COD_UNIDADE6,
CASE WHEN  X.CONTRATO_RESP_INF IS NOT NULL THEN NULL ELSE X.COD_PESSOA_RESP END AS COD_PESSOA_RESP,
CASE WHEN  X.CONTRATO_RESP_INF IS NOT NULL THEN NULL ELSE X.CONTRATO_RESP END AS CONTRATO_RESP,
CASE WHEN X.CONTRATO_RESP_INF IS NOT NULL THEN NULL ELSE X.TIPO_CONT_RESP END AS TIPO_CONT_RESP,
CASE WHEN X.CONTRATO_RESP_INF IS NOT NULL THEN NULL ELSE X.COD_EMPRESA_PESS END AS COD_EMPRESA_PESS,
X.DATA_IMPLANT,
X.DATA_EXTINCAO,
NULL AS TIPO_LOGRADOURO,
NULL AS ENDERECO,
NULL AS NUMERO,
NULL AS COMPLEMENTO,
NULL AS BAIRRO,
NULL AS MUNICIPIO,
NULL AS UF,
NULL AS CEP,
SYSDATE DT_SAIU_ARTE,
NULL AS DT_ENVIADO_IFPONTO_SURICATO,
'POR_LOCAL' AS TIPO_HIERARQUIA,
CASE WHEN  X.CONTRATO_RESP_INF IS NOT NULL THEN NULL ELSE X.cod_empresa_pess END AS EMPRESA_CODIGO_RESPONSAVEL,
CASE WHEN X.CONTRATO_RESP_INF IS NOT NULL THEN NULL ELSE  X.CONTRATO_RESP END AS CODIGO_RESPONSAVEL,
X.CONTRATO_RESP_INF AS CODIGO_RESPONSAVEL_INFORMAL,
X.cod_empr_pess_INF AS EMPRESA_CODIGO_RESPONSAVEL_INF,
X.TIPO_CONT_RESP_INF,
CASE WHEN X.cod_cgerenc_sup1 IS NOT NULL THEN SUBSTR(X.CODIGO_EMPRESA,3,2)||'.'||X.cod_cgerenc_sup1||'.'||X.cod_cgerenc_sup2||'.'||X.cod_cgerenc_sup3||'.'||X.cod_cgerenc_sup4||'.'||X.cod_cgerenc_sup5||'.'||X.cod_cgerenc_sup6 ELSE NULL END AS  CODIGO_LOCAL_SUPERIOR,
S.TEXTO_ASSOCIADO AS DESCRICAO_LOCAL_SUPERIO,
E.Nivel_Agrup_Estrut
FROM RHORGA_CUSTO_GEREN X
----GABRIEL AQUI EM 12/06/2019 ADICIONEI AQUI PARA PEGAR O NOME DO LOCAL DO SUPERIRO PRA REALIZAR O DENTRO DE NO MENU HIERARQUIA DO NOVO SISTEMA DE PONTO
  LEFT OUTER JOIN RHORGA_CUSTO_GEREN S
  ON S.CODIGO_EMPRESA    =x.CODIGO_EMPRESA
  AND S.COD_CGERENC1 = x.COD_CGERENC_SUP1
  AND S.COD_CGERENC2 =x.COD_CGERENC_SUP2
  AND S.COD_CGERENC3 =x.COD_CGERENC_SUP3
  AND S.COD_CGERENC4 =x.COD_CGERENC_SUP4
  AND S.COD_CGERENC5 =x.COD_CGERENC_SUP5
  AND S.COD_CGERENC6 =x.COD_CGERENC_SUP6
left outer join RHORGA_AGRUPADOR A on x.codigo_empresa = a.codigo_empresa and x.COD_CGERENC1 = a.cod_agrup1 and x.COD_CGERENC2 = a.cod_agrup2 and x.COD_CGERENC3 = a.cod_agrup3 and x.COD_CGERENC4 = a.cod_agrup4 and x.COD_CGERENC5 = a.cod_agrup5 and x.COD_CGERENC6 = a.cod_agrup6
left outer join rhorga_estrut_agr E on  E.ID_AGRUP = A.ID_AGRUP and e.codigo_empresa=a.codigo_empresa
and e.codigo_empresa=a.codigo_empresa
----------GABRIEL AQUI EM  30/03/2020 NOVA REGRA COM CGC DAS UNIDADES ----------------------------
LEFT OUTER JOIN ARTERH.RHORGA_EMPRESA EM
ON X.CODIGO_EMPRESA=EM.CODIGO

WHERE X.CODIGO_EMPRESA =(SELECT PONT.* FROM (SELECT SUBSTR(PONT.DADO_ORIGEM,20,4)EMPRESA
                                             FROM RHINTE_ED_IT_CONV PONT WHERE CODIGO_CONVERSAO='PONT' GROUP BY SUBSTR(PONT.DADO_ORIGEM,20,4))PONT
                                             WHERE PONT.EMPRESA=X.CODIGO_EMPRESA)
and a.tipo_agrup = 'G'
and a.CODIGO_EMPRESA =(SELECT PONT.* FROM (SELECT SUBSTR(PONT.DADO_ORIGEM,20,4)EMPRESA
                                             FROM RHINTE_ED_IT_CONV PONT WHERE CODIGO_CONVERSAO='PONT' GROUP BY SUBSTR(PONT.DADO_ORIGEM,20,4))PONT
                                             WHERE PONT.EMPRESA=A.CODIGO_EMPRESA)
and e.ano_mes_referencia = (select max(ano_mes_referencia) from rhorga_estrut_agr aux where aux.id_agrup = e.id_agrup and aux.codigo_empresa=e.codigo_empresa)
and E.Nivel_Agrup_Estrut = E.Nivel_Sup_Agr_Est
AND TRIM(X.CGC)=TRIM(EM.CGC)
AND trunc(X.DT_ULT_ALTER_USUA) BETWEEN vDATA_INICIO AND vDATA_FIM
AND X.LOGIN_USUARIO NOT IN ('IFPONTO','IMP_AMPS_SMED') --NOVO EM 12/8/22
)XX
WHERE XX.COD_UNIDADE1 NOT IN ('000099','000098') AND XX.COD_UNIDADE2 NOT IN ('000095')
ORDER BY 4
)-----FIM DO FOR
LOOP
vCONTADOR :=vCONTADOR+1;
dbms_output.put_line(vCONTADOR);
dbms_output.put_line(vDATA_INICIO||'-'||vDATA_FIM);
insert into PONTO_ELETRONICO.smarh_int_pe_unidade_v2 (CODIGO_EMPRESA, EMPRESA, AGRUPAMENTO_EMPRESA, CODIGO_UNIDADE, DESCRICAO_UNIDADE, ABREVIACAO, COD_UNIDADE1, COD_UNIDADE2, COD_UNIDADE3, COD_UNIDADE4, COD_UNIDADE5, COD_UNIDADE6, COD_PESSOA_RESP, CONTRATO_RESP, TIPO_CONT_RESP, COD_EMPRESA_PESS, DATA_IMPLANT, DATA_EXTINCAO, TIPO_LOGRADOURO, ENDERECO, NUMERO, COMPLEMENTO, BAIRRO, MUNICIPIO, UF, CEP, DT_SAIU_ARTE, DT_ENVIADO_IFPONTO_SURICATO, TIPO_HIERARQUIA, EMPRESA_CODIGO_RESPONSAVEL, CODIGO_RESPONSAVEL, CODIGO_RESPONSAVEL_INFORMAL, EMPRESA_CODIGO_RESPONSAVEL_INF, CODIGO_LOCAL_SUPERIOR,DESCRICAO_LOCAL_SUPERIO, Nivel_Agrup_Estrut,TIPO_CONT_RESP_INF
,CODIGO_INTEGRA_ARTE --NOVO 4/7/22
)
VALUES (C1.CODIGO_EMPRESA, C1.EMPRESA, C1.AGRUPAMENTO_EMPRESA, C1.CODIGO_UNIDADE, C1.DESCRICAO_UNIDADE, C1.ABREVIACAO, C1.COD_UNIDADE1, C1.COD_UNIDADE2, C1.COD_UNIDADE3, C1.COD_UNIDADE4, C1.COD_UNIDADE5, C1.COD_UNIDADE6, C1.COD_PESSOA_RESP, C1.CONTRATO_RESP, C1.TIPO_CONT_RESP, C1.COD_EMPRESA_PESS, C1.DATA_IMPLANT, C1.DATA_EXTINCAO, C1.TIPO_LOGRADOURO, C1.ENDERECO, C1.NUMERO, C1.COMPLEMENTO, C1.BAIRRO, C1.MUNICIPIO, C1.UF, C1.CEP, C1.DT_SAIU_ARTE, C1.DT_ENVIADO_IFPONTO_SURICATO, C1.TIPO_HIERARQUIA, C1.EMPRESA_CODIGO_RESPONSAVEL, C1.CODIGO_RESPONSAVEL, C1.CODIGO_RESPONSAVEL_INFORMAL, C1.EMPRESA_CODIGO_RESPONSAVEL_INF, C1.CODIGO_LOCAL_SUPERIOR,C1.DESCRICAO_LOCAL_SUPERIO, C1.Nivel_Agrup_Estrut,C1.TIPO_CONT_RESP_INF
,SEQUENCE_INTEGRA_ARTE.NEXTVAL --NOVO 4/7/22
);
Commit;
END LOOP;
END;
END SMARH_INT_PE_CAD_DEPTO_HIERAR;