
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."FN_DADOS_DELEGACAO_GESTOR" (P_COD_EMPRESA IN CHAR, P_TIPO_CONTRATO IN CHAR, P_CODIGO_CONTRATO IN VARCHAR,v_cod_unidade1 in varchar,v_cod_unidade2 in varchar,v_cod_unidade3 in varchar,v_cod_unidade4 in varchar,v_cod_unidade5 in varchar,v_cod_unidade6 in varchar)  RETURN DADOS_GESTORES AS 

v_retorno DADOS_GESTORES :=null;
BEGIN
v_retorno:=DADOS_GESTORES(NULL,NULL,NULL,NULL,NULL,NULL);
SELECT  C.CODIGO_EMPRESA,
    C.TIPO_CONTRATO,
   C.CODIGO AS CODIGO_CONTRATO,
   C.codigo|| ' - '|| nvl(TRIM(p.nome_social),TRIM(p.nome_acesso))|| ' - '|| C.tipo_contrato|| ' - '|| nvl(TRIM(G.texto_associado),TRIM(G.descricao)) AS NOME_COMPOSTO_GESTOR,
   P.CODIGO AS CODIGO_PESSOA_GESTOR,
   AD.CODIGO_USUARIO
  INTO v_retorno.CODIGO_EMPRESA,

v_retorno.TIPO_CONTRATO ,
v_retorno.CODIGO_CONTRATO,

v_retorno.NOME_COMPOSTO_GESTOR  ,
v_retorno.CODIGO_PESSOA_GESTOR,
v_retorno.LOGIN_USUARIO_GESTOR
   FROM ARTERH.RHPESS_CONTRATO C 

INNER JOIN ARTERH.RHPESS_PESSOA P 
ON P.CODIGO=c.codigo_pessoa
AND P.CODIGO_EMPRESA=c.codigo_empresa
inner join arterh.rhorga_custo_geren g
on g.codigo_empresa=c.codigo_empresa
and g.cod_cgerenc1=c.cod_custo_gerenc1
and g.cod_cgerenc2=c.cod_custo_gerenc2
and g.cod_cgerenc3=c.cod_custo_gerenc3
and g.cod_cgerenc4=c.cod_custo_gerenc4
and g.cod_cgerenc5=c.cod_custo_gerenc5
and g.cod_cgerenc6=c.cod_custo_gerenc6
LEFT OUTER JOIN 
    ARTERH.RHUSER_P_SIST@LK_HOM_PBH12 AD ON 
    AD.EMPRESA_USUARIO = C.CODIGO_EMPRESA AND
    AD.TP_CONTR_USUARIO = C.TIPO_CONTRATO AND
    AD.CONTRATO_USUARIO = C.CODIGO AND
    AD.STATUS_USUARIO = CASE WHEN C.DATA_RESCISAO IS NOT NULL THEN 'E' ELSE 'A' END AND
    (
        (C.DATA_RESCISAO IS NULL AND USUARIO_LDAP IS NOT NULL) OR
        (C.DATA_RESCISAO IS NOT NULL AND USUARIO_LDAP IS NULL)
    ) AND
    AD.TIPO_LOGIN IN ('2', '3') AND
    AD.CODIGO_SERV_AUTENT = 'PWS1'

WHERE C.ANO_MES_REFERENCIA=(SELECT MAX(AUX.ANO_MES_REFERENCIA) FROM ARTERH.RHPESS_CONTRATO AUX
WHERE AUX.CODIGO=C.CODIGO
AND AUX.TIPO_CONTRATO=C.TIPO_CONTRATO
AND AUX.CODIGO_EMPRESA=C.CODIGO_EMPRESA)
AND C.CODIGO=P_CODIGO_CONTRATO
AND C.TIPO_CONTRATO=P_TIPO_CONTRATO
AND C.CODIGO_EMPRESA=P_COD_EMPRESA
and rownum<=1

--and ad.codigo_usuario='pr097918'
;
    return v_retorno;
END;