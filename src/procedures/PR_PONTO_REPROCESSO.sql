
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PR_PONTO_REPROCESSO" AS 
CONT NUMBER;
BEGIN 
CONT:=0;
FOR C1 IN (
SELECT 'DIARIA_NOVOS' AS TIPO, AT.CODIGO_EMPRESA,AT.TIPO_CONTRATO,at.codigo_contrato,AT.CPF
FROM  PONTO_ELETRONICO.SUGESP_BI_1CONTRAT_INTIF_ARTE AT
WHERE CHAVE_INTEGRACAO='ATIVO'
AND AT.DATA_RESCISAO IS NULL
AND INTEGRADO='S'
and TRUNC(DT_SAIU_ARTE)=TRUNC(SYSDATE)
--AND CODIGO_CONTRATO=LPAD('1304389',15,0)
AND NOT EXISTS(SELECT * FROM  PONTO_ELETRONICO.SUGESP_INT_PE_IFPONTO AF
WHERE AF.CODIGO_CONTRATO=AT.CODIGO_CONTRATO
AND AF.TIPO_CONTRATO=AT.TIPO_CONTRATO
AND AF.CODIGO_EMPRESA=AT.CODIGO_EMPRESA
AND AF.CPF=AT.CPF)
AND AT.SITUACAO_FUNCIONAL NOT IN ('1851')

UNION ALL
SELECT 'READMISSAO' AS TIPO,AT.CODIGO_EMPRESA,AT.TIPO_CONTRATO,at.codigo_contrato,AT.CPF
FROM  PONTO_ELETRONICO.SUGESP_BI_1CONTRAT_INTIF_ARTE AT
WHERE CHAVE_INTEGRACAO='ATIVO'
AND AT.DATA_RESCISAO IS NULL
AND INTEGRADO='S'
and TRUNC(DT_SAIU_ARTE)=TRUNC(SYSDATE)
--AND CODIGO_CONTRATO=LPAD('1304389',15,0)
AND EXISTS (SELECT * FROM  PONTO_ELETRONICO.SUGESP_INT_PE_IFPONTO AF
WHERE AF.CODIGO_CONTRATO=AT.CODIGO_CONTRATO
AND AF.TIPO_CONTRATO=AT.TIPO_CONTRATO
AND AF.CODIGO_EMPRESA=AT.CODIGO_EMPRESA
AND AF.CPF=AT.CPF
AND AF.DATA_DEMISSAO IS NOT NULL 
AND TO_DATE(AF.DATA_DEMISSAO,'DD/MM/YYYY') <>TO_DATE('01/01/1970','DD/MM/YYYY')
)
AND AT.SITUACAO_FUNCIONAL NOT IN ('1851')
)LOOP
CONT:=CONT+1;
INSERT INTO  PONTO_ELETRONICO.SMARH_INT_REPROCESSO_CONTRATO(ID,DATA_REPROCESSO,CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,CPF,tipo)VALUES (ID_SEQ_PONTO.NEXTVAL,SYSDATE,C1.CODIGO_EMPRESA,C1.TIPO_CONTRATO,C1.CODIGO_CONTRATO,C1.CPF,c1.tipo);


COMMIT;

END LOOP;

BEGIN
FOR C2 IN (select
X.CODIGO_EMPRESA,
CASE WHEN X.CODIGO_EMPRESA = '0001' THEN 'PREF.MUN.BELO HORIZONTE'  WHEN X.CODIGO_EMPRESA = '0098' THEN 'PREF.MUN.BH CONTRATOS'
     WHEN X.CODIGO_EMPRESA = '0013' THEN 'FUND MUNC CULTURA'
     WHEN X.CODIGO_EMPRESA = '0014' THEN 'FUND PARQUES MUNICIPAIS E ZOOBOTANICA DE BH'
     WHEN X.CODIGO_EMPRESA = '0003' THEN 'SUDECAP'
WHEN X.CODIGO_EMPRESA = '0015' THEN 'SES - MUNICIPALIZADOS' WHEN X.CODIGO_EMPRESA = '0021' THEN 'SMSABH/FMSBH - CONTRATOS ADMINISTRATIVOS' WHEN X.CODIGO_EMPRESA = '0032' THEN 'CA - PROJETOS ESPECIAIS'
END AS EMPRESA,
CASE WHEN X.CODIGO_EMPRESA in ('0001','0098','0015','0021','0032') then 'ADM DIRETA' else 'ADM INDIRETA' END AS AGRUPAMENTO_EMPRESA,
X.CPF,
X.NOME,
X.APELIDO,
X.PIS_PASEP,
X.IDENTIDADE,
X.TIPO_CONTRATO,
X.CODIGO_CONTRATO    ,
SUBSTR(X.CODIGO_EMPRESA,3,2)||X.CODIGO_ESCALA AS CODIGO_ESCALA ,
CASE WHEN X.DT_ULT_ESCALA IS NULL AND X.CODIGO_ESCALA IS NOT NULL THEN TRUNC(SYSDATE)
WHEN X.CODIGO_ESCALA IS NOT NULL  AND X.DT_ULT_ESCALA IS NOT NULL THEN X.DT_ULT_ESCALA
END AS DT_ULT_ESCALA ,
X.COD_UNIDADE1 as COD_UNIDADE1,
X.COD_UNIDADE2 as COD_UNIDADE2,
X.COD_UNIDADE3 as COD_UNIDADE3,
X.COD_UNIDADE4 as COD_UNIDADE4,
X.COD_UNIDADE5 as COD_UNIDADE5,
X.COD_UNIDADE6 as COD_UNIDADE6,
X.DESCRICAO_UNIDADE    ,
CASE WHEN X.COD_UNIDADE1 IS NOT NULL THEN SUBSTR(X.empresa_hierarquia,3,2)||'.'||X.COD_UNIDADE1||'.'||X.COD_UNIDADE2||'.'||X.COD_UNIDADE3||'.'||X.COD_UNIDADE4||'.'||X.COD_UNIDADE5||'.'||X.COD_UNIDADE6 ELSE NULL END AS CODIGO_UNIDADE,
--DESCRICAO_UNIDADE_TESTE,
X.CODIGO_CARGO_EFETIVO,

X.DESCRICAO_CARGO_EFETIVO    ,
X.CODIGO_CARGO_COMISSIONADO    ,
X.DESCRICAO_CARGO_COMISSIONADO    ,
X.DATA_ADMISSAO    ,
X.DATA_RESCISAO    ,
--TIPO_USUARIO,
--REGISTRO_PONTO,
X.tipo_contrato_gestor,
X.codigo_empresa_gestor,

X.CONTRATO_GESTOR AS CODIGO_RESPONSAVEL,
x.TIPO_VW_DADOS_SERVIDOR,
  SYSDATE AS DT_SAIU_ARTE,
  NULL AS DT_ENVIADO_IFPONTO_SURICATO,

X.COD_TIPO_PESSOA,
X.CODIGO_LEGADO,
x.dia_comeco_ciclo
,X.EXCECAO_FUNCIONAL--NOVO 16/8/22
FROM (
SELECT 
 CASE WHEN   E_GESTOR='N' AND  VINCULO = '0009'AND TIPO_USUARIO NOT IN ('USA_NAVEGADOR','USA_AMBOS') THEN '3'----- CODIGO DO IFPONTO ESTAGIRIO
  WHEN  E_GESTOR='N' AND  VINCULO <> '0009' AND REGISTRO_PONTO IN ('0010','0020', '0030','0140','0100')AND TIPO_USUARIO NOT IN ('USA_NAVEGADOR','USA_AMBOS') THEN '4'------ CODIGO PARA SERVIDOR NO IFPONTO
  WHEN  E_GESTOR='N' AND  VINCULO <> '0009' AND REGISTRO_PONTO IN('0110','0120')AND TIPO_USUARIO NOT IN ('USA_NAVEGADOR','USA_AMBOS')THEN'13'------ CODIGO SERVIDOR NO IFPONTO PARA SERVIDOR ISENTO
  WHEN  E_GESTOR='N' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0130') AND TIPO_USUARIO NOT IN ('USA_NAVEGADOR','USA_AMBOS')THEN '10'
  WHEN  E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0010','0020', '0030','0140','0100')AND TIPO_USUARIO NOT IN ('USA_NAVEGADOR','USA_AMBOS') THEN '5'
  WHEN  E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0130')AND TIPO_USUARIO NOT IN ('USA_NAVEGADOR','USA_AMBOS') THEN '11'
  WHEN  E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0110','0120')AND TIPO_USUARIO NOT IN ('USA_NAVEGADOR','USA_AMBOS') THEN '12'

----------------------------------------------USA NAVEGADOR  Ã‰ CADASTRO NOVO(SERVIDOR) ---------------------------------------------------------------------------------------------------------
  WHEN  E_GESTOR='N' AND  VINCULO = '0009' AND TIPO_USUARIO='USA_NAVEGADOR'THEN '342'----- CODIGO DO IFPONTO ESTAGIRIO
  WHEN  E_GESTOR='N' AND  VINCULO <> '0009' AND REGISTRO_PONTO IN ('0010','0020', '0030','0140','0100')AND TIPO_USUARIO='USA_NAVEGADOR' THEN '342'------ CODIGO PARA SERVIDOR NO IFPONTO
  WHEN  E_GESTOR='N' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0130')AND TIPO_USUARIO='USA_NAVEGADOR' THEN '343'
  WHEN  E_GESTOR='N' AND VINCULO<>'0009' AND REGISTRO_PONTO IN('0110','0120')AND TIPO_USUARIO='USA_NAVEGADOR' THEN'13'

--------------------------------------------------------------------------USA NAVEGADOR Ã‰ APP E Ã‰ CADASTRO NOVO(SERVIDOR)-------------------------------------------------------------------------------------------------------------
  WHEN  E_GESTOR='N' AND  VINCULO = '0009' AND TIPO_USUARIO='USA_AMBOS'THEN '350'----- CODIGO DO IFPONTO ESTAGIRIO
  WHEN  E_GESTOR='N' AND  VINCULO <> '0009' AND REGISTRO_PONTO IN ('0010','0020', '0030','0140','0100')AND TIPO_USUARIO='USA_AMBOS' THEN '350'------ CODIGO PARA SERVIDOR NO IFPONTO
  WHEN  E_GESTOR='N' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0130')AND TIPO_USUARIO='USA_AMBOS' THEN '351'
  WHEN  E_GESTOR='N' AND VINCULO<>'0009' AND REGISTRO_PONTO IN('0110','0120')AND TIPO_USUARIO='USA_AMBOS' THEN'13'

--------------------------------------------------------------USA NAVEGADOR  Ã‰ CADASTRO NOVO(GESTOR)-----------------------------------------------------------------------------------
  WHEN  E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0010','0020', '0030','0140','0100')AND TIPO_USUARIO='USA_NAVEGADOR' THEN '340'
  WHEN  E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0130')AND TIPO_USUARIO='USA_NAVEGADOR' THEN '341'
  WHEN  E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0110','0120')AND TIPO_USUARIO='USA_NAVEGADOR' THEN '12'


--------------------------------------------------------------------------USA NAVEGADOR Ã‰ APP E Ã‰ CADASTRO NOVO(GESTOR)-------------------------------------------------------------------------------------------------------------
  WHEN  E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0010','0020', '0030','0140','0100')AND TIPO_USUARIO='USA_AMBOS' THEN '348'
  WHEN  E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0130')AND TIPO_USUARIO='USA_AMBOS' THEN '349'
  WHEN  E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0110','0120')AND TIPO_USUARIO='USA_AMBOS' THEN '12'
  ELSE NULL END AS COD_TIPO_PESSOA,
   CASE WHEN x.TIPO = 'HIERARQUIA POR PESSOA' THEN CONTRATO_GESTOR
  ELSE NULL END AS CODIGO_RESPONSAVEL,

    CASE  WHEN  X.cod_cargo_efetivo is null or X.cod_cargo_efetivo = '000000000000000' THEN NULL
   WHEN (X.cod_cargo_efetivo is NOT null or X.cod_cargo_efetivo <> '000000000000000') THEN  SUBSTR(X.CODIGO_EMPRESA,3,2)||SUBSTR(X.cod_cargo_efetivo,11,5)
  ELSE NULL END AS CODIGO_CARGO_EFETIVO,
--------------------------------------------DESCRIÃ‡ÃƒO CARGO EFETIVO 01/08/2019------------------------------------------------------------------------------
  CASE  WHEN  X.cod_cargo_efetivo is null or X.cod_cargo_efetivo = '000000000000000' THEN NULL
   WHEN  (X.cod_cargo_efetivo is NOT null or X.cod_cargo_efetivo <> '000000000000000') THEN CARGO_EFETIVO
  ELSE NULL END AS DESCRICAO_CARGO_EFETIVO,
-------------------------------------------  CARGO COMISS 01/08/2019------------------------------------------------------------------
  CASE WHEN  (X.cod_cargo_COMISS IS NULL OR X.cod_cargo_COMISS = '000000000000000')AND (X.codIGO_FUNCAO is null or X.codIGO_FUNCAO = '000000000000000') THEN NULL
   WHEN  (X.cod_cargo_COMISS IS NOT NULL OR  X.cod_cargo_COMISS <> '000000000000000')AND (X.codIGO_FUNCAO is NOT null or X.codIGO_FUNCAO <> '000000000000000') THEN  SUBSTR(X.CODIGO_EMPRESA,3,2)||9 || SUBSTR(X.codIGO_FUNCAO,12,4)
   WHEN  (X.cod_cargo_COMISS IS  NULL OR  X.cod_cargo_COMISS = '000000000000000')AND (X.codIGO_FUNCAO is NOT null or X.codIGO_FUNCAO <> '000000000000000') THEN  SUBSTR(X.CODIGO_EMPRESA,3,2)||9 || SUBSTR(X.codIGO_FUNCAO,12,4)
   WHEN  (X.cod_cargo_COMISS is NOT null or X.cod_cargo_COMISS <> '000000000000000')AND (X.codIGO_FUNCAO is null or X.codIGO_FUNCAO = '000000000000000')THEN  SUBSTR(X.CODIGO_EMPRESA,3,2)||SUBSTR(X.cod_cargo_COMISS,11,5)
 ELSE NULL end AS CODIGO_CARGO_COMISSIONADO,
---------------------------------------------------- DESCRIÃ‡ÃƒO CARGO COMISS 01/08/2019-----------------------------
  CASE WHEN  (X.cod_cargo_COMISS IS NULL OR X.cod_cargo_COMISS = '000000000000000')AND (X.codIGO_FUNCAO is null or X.codIGO_FUNCAO = '000000000000000') THEN NULL
   WHEN  (X.cod_cargo_COMISS IS NOT NULL OR  X.cod_cargo_COMISS <> '000000000000000')AND (X.codIGO_FUNCAO is NOT null or X.codIGO_FUNCAO <> '000000000000000') THEN FUNCAO_PUBLICA
   WHEN  (X.cod_cargo_COMISS IS  NULL OR  X.cod_cargo_COMISS = '000000000000000')AND (X.codIGO_FUNCAO is NOT null or X.codIGO_FUNCAO <> '000000000000000') THEN FUNCAO_PUBLICA
   WHEN  (X.cod_cargo_COMISS is NOT null or X.cod_cargo_COMISS <> '000000000000000')AND (X.codIGO_FUNCAO is null or X.codIGO_FUNCAO = '000000000000000')THEN CARGO_COMISSIONADO
   ELSE NULL end AS DESCRICAO_CARGO_COMISSIONADO,
   CASE WHEN (X.PIS_PASEP IS NULL OR X.PIS_PASEP  = '00000000000')THEN LTRIM(X.CODIGO_EMPRESA,0)||REPLACE(LTRIM(X.CODIGO_CONTRATO,0),'X','')
   WHEN  X.PIS_PASEP IS NOT NULL THEN PIS_PASEP
  ELSE NULL 
  END AS PIS_PASEP,X.CODIGO_LEGADO,X.REGISTRO_PONTO,X.DATA_RESCISAO,X.DATA_ADMISSAO,X.DESCRICAO_UNIDADE,
  X.COD_UNIDADE1,
X.COD_UNIDADE2,
X.COD_UNIDADE3,
X.COD_UNIDADE4,
X.COD_UNIDADE5,
X.COD_UNIDADE6,
X.DT_ULT_ESCALA,
X.CODIGO_ESCALA,
X.CODIGO_CONTRATO,
X.TIPO_CONTRATO,
X.IDENTIDADE,
X.APELIDO,
X.NOME,
X.CPF,
X.CODIGO_EMPRESA,
x.tipo_contrato_gestor,
x.codigo_empresa_gestor,
X.CONTRATO_GESTOR,
x.empresa_hierarquia,
x.dia_comeco_ciclo,
rt.tipo as tipo_vw_dados_servidor
,X.EXCECAO_FUNCIONAL--NOVO 16/8/22
  FROM 
(SELECT 'ULTIMO' AS DIA,U.*
          FROM PONTO_ELETRONICO.SUGESP_BI_1CONTRAT_INTIF_ARTE U
          WHERE trunc(U.dt_saiu_arte) =trunc(sysdate)
          )X
          LEFT OUTER JOIN PONTO_ELETRONICO.SMARH_INT_REPROCESSO_CONTRATO RT
          ON RT.CODIGO_CONTRATO=X.CODIGO_CONTRATO
          AND RT.TIPO_CONTRATO=X.TIPO_CONTRATO
          AND RT.CODIGO_EMPRESA=X.CODIGO_EMPRESA

     WHERE RT.VERIFICADO='N'
)X
WHERE X.DATA_RESCISAO IS NULL)
LOOP 
INSERT INTO PONTO_ELETRONICO.SMARH_INT_PONTO_DADOS_SERV_V10(CODIGO_EMPRESA,EMPRESA,AGRUPAMENTO_EMPRESA,CPF,NOME,APELIDO,PIS_PASEP,IDENTIDADE,TIPO_CONTRATO,CODIGO_CONTRATO,CODIGO_ESCALA , DT_ULT_ESCALA ,COD_UNIDADE1,COD_UNIDADE2,COD_UNIDADE3,COD_UNIDADE4,COD_UNIDADE5,COD_UNIDADE6,DESCRICAO_UNIDADE ,CODIGO_UNIDADE,CODIGO_CARGO_EFETIVO,DESCRICAO_CARGO_EFETIVO    ,CODIGO_CARGO_COMISSIONADO    ,DESCRICAO_CARGO_COMISSIONADO    ,DATA_ADMISSAO    ,DATA_RESCISAO    ,tipo_contrato_gestor,codigo_empresa_gestor, CODIGO_RESPONSAVEL,TIPO_VW_DADOS_SERVIDOR, DT_SAIU_ARTE,DT_ENVIADO_IFPONTO_SURICATO,COD_TIPO_PESSOA,CODIGO_LEGADO,dia_comeco_ciclo,LOCAL_GESTOR,CODIGO_INTEGRA_ARTE, EXCECAO_FUNCIONAL) VALUES
(C2.CODIGO_EMPRESA,C2.EMPRESA,C2.AGRUPAMENTO_EMPRESA,C2.CPF,C2.NOME,C2.APELIDO,C2.PIS_PASEP,C2.IDENTIDADE,C2.TIPO_CONTRATO,C2.CODIGO_CONTRATO,C2.CODIGO_ESCALA , C2.DT_ULT_ESCALA ,C2.COD_UNIDADE1,C2.COD_UNIDADE2,C2.COD_UNIDADE3,C2.COD_UNIDADE4,C2.COD_UNIDADE5,C2.COD_UNIDADE6,C2.DESCRICAO_UNIDADE ,C2.CODIGO_UNIDADE,C2.CODIGO_CARGO_EFETIVO,C2.DESCRICAO_CARGO_EFETIVO    ,C2.CODIGO_CARGO_COMISSIONADO    ,C2.DESCRICAO_CARGO_COMISSIONADO    ,C2.DATA_ADMISSAO    ,C2.DATA_RESCISAO    ,C2.tipo_contrato_gestor,C2.codigo_empresa_gestor, C2.CODIGO_RESPONSAVEL,C2.TIPO_VW_DADOS_SERVIDOR, C2.DT_SAIU_ARTE,C2.DT_ENVIADO_IFPONTO_SURICATO,C2.COD_TIPO_PESSOA,C2.CODIGO_LEGADO,C2.dia_comeco_ciclo,'REPROCESSAMENTO CONTRATO',PONTO_ELETRONICO.SEQUENCE_INTEGRA_ARTE.NEXTVAL, C2.EXCECAO_FUNCIONAL)
;
END LOOP;
END;

END;