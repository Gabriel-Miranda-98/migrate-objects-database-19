
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_ARTERH_SIGBASES_PROFIS" ("ID_PROF", "NOME_PROF", "IND_STATUS_PROF", "NOME_SOCIAL_PROF", "DATA_NASCIM_PROF", "NOME_MAE_PROF", "SEXO_PROF", "IND_BRASILEIRO", "NATURALIDADE", "NACIONALIDADE", "CPF_PROF", "IDENTIDADE_PROF", "ORGAO_EXP_PROF", "DATA_EXP_PROF", "CNH_PROF", "DATA_EXP_CNH_PROF", "DATA_VALIDADE_CNH_PROF", "CATEG_HAB_PROF", "IDENT_ESTRANG_PROF", "ANO_CHEGADA_PROF", "TELEFONE_PROF", "EMAIL_PROF", "LOG_ENDER_PROF", "ENDER_ENDER_PROF", "NUMERO_ENDER_PROF", "COMPL_ENDER_PROF", "BAIRRO_PROF", "DESC_MUNICIPIO_PROF", "UF_ENDER_PROF", "CEP_ENDER_PROF", "PAIS_ORIG_PROF", "CRM_REGISTRO_PROFISSIONAL", "INSC_CONS_REGI_PROFIS", "DT_EXPED_CONS_PROF", "DT_VALID_CONS_PROF", "UF_CRM_PROF", "PAIS_ORIG_PROF_1", "UF_NATURAL_PROF", "UF_IDENT_PROF", "CNS", "ULTIMA_ALTERACAO") AS 
  SELECT
C.CODIGO_PESSOA as ID_PROF,
SUBSTR(P.NOME,1,60) AS NOME_PROF,
CASE WHEN P.DT_TERMINO IS NULL THEN 'A'  ELSE 'I' END  AS IND_STATUS_PROF,
CASE WHEN P.NOME_SOCIAL IS NULL THEN LPAD(' ',60,' ') ELSE SUBSTR(P.NOME_SOCIAL,1,60) END AS NOME_SOCIAL_PROF,
TO_CHAR(P.DATA_NASCIMENTO, 'DD/MM/YYYY') AS DATA_NASCIM_PROF,
CASE WHEN MAE.NOME IS NULL THEN SUBSTR(P.C_LIVRE_DESCR12,1,60) ELSE SUBSTR(MAE.NOME,1,60) END AS NOME_MAE_PROF,
CASE WHEN P.SEXO = '0001' THEN 'M' ELSE 'F' END  AS SEXO_PROF,
CASE WHEN P.NACIONALIDADE = '0010' THEN 'S' ELSE 'N' END  AS IND_BRASILEIRO,
CASE WHEN TM1.DESCRICAO IS NULL THEN LPAD (' ',40,' ') ELSE SUBSTR(TM1.DESCRICAO,1,40) END AS NATURALIDADE,
CASE WHEN TN.DESCRICAO IS NULL THEN LPAD (' ',40,' ') ELSE SUBSTR(TN.DESCRICAO,1,40) END AS NACIONALIDADE,
CASE WHEN P.CPF IS NULL THEN LPAD (' ',14, ' ') ELSE substr(P.CPF,1,14) END AS CPF_PROF,
CASE WHEN P.IDENTIDADE IS NULL THEN LPAD (' ',20, ' ') ELSE SUBSTR(P.IDENTIDADE,1,20) END AS IDENTIDADE_PROF,
CASE WHEN P.ORGAO_EXPEDIDOR IS NULL THEN RPAD (' ',40, ' ') ELSE substr(P.ORGAO_EXPEDIDOR,1,30) END AS ORGAO_EXP_PROF,
CASE WHEN P.DATA_EXPEDICAO IS NULL THEN RPAD (' ',8, ' ') ELSE TO_CHAR(P.DATA_EXPEDICAO,'DD/MM/YYYY') END AS DATA_EXP_PROF,
CASE WHEN P.HABILITACAO IS NULL THEN RPAD (' ',11, ' ') ELSE SUBSTR(P.HABILITACAO,1,11) END AS CNH_PROF,
CASE WHEN P.DATA_HABILITACAO IS NULL THEN RPAD (' ',8, ' ') ELSE TO_CHAR(P.DATA_HABILITACAO,'DD/MM/YYYY')END AS DATA_EXP_CNH_PROF,
CASE WHEN P.DT_VAL_HABILITACAO IS NULL THEN RPAD (' ',8, ' ')ELSE TO_CHAR(P.DT_VAL_HABILITACAO,'DD/MM/YYYY')END AS DATA_VALIDADE_CNH_PROF,
CASE WHEN P.CATEGORIA IS NULL THEN RPAD (' ',15, ' ') ELSE SUBSTR(P.CATEGORIA,1,15) END AS CATEG_HAB_PROF,
CASE WHEN P.IDENT_ESTRANGEIRO IS NULL THEN RPAD (' ',20, ' ') ELSE SUBSTR(P.IDENT_ESTRANGEIRO,1,20) END AS IDENT_ESTRANG_PROF,
CASE WHEN P.ANO_CHEGADA IS NULL THEN RPAD (' ',4, ' ') ELSE TO_CHAR (P.ANO_CHEGADA,'YYYY') END AS ANO_CHEGADA_PROF,
CASE WHEN TEL.TELEFONE IS NULL THEN RPAD (' ',14, ' ') ELSE LPAD(SUBSTR(TEL.DDD,1,3),3,0)||SUBSTR(TEL.TELEFONE,1,10) END AS TELEFONE_PROF,
CASE WHEN EP.ENDER_ELETRONICO IS NULL THEN RPAD (' ',60, ' ') ELSE SUBSTR(EP.ENDER_ELETRONICO,1,60) END AS EMAIL_PROF,
CASE WHEN TL.DESCRICAO IS NULL THEN RPAD (' ',20, ' ') ELSE SUBSTR(TL.DESCRICAO,1,20) END AS LOG_ENDER_PROF,
CASE WHEN EP.ENDERECO IS NULL THEN RPAD (' ',60, ' ') ELSE SUBSTR(EP.ENDERECO,1,60) END AS ENDER_ENDER_PROF,
CASE WHEN EP.NUMERO IS NULL THEN RPAD (' ',10, ' ') ELSE SUBSTR(EP.NUMERO,1,10) END AS NUMERO_ENDER_PROF,
CASE WHEN EP.COMPLEMENTO IS NULL THEN RPAD (' ',20, ' ') ELSE SUBSTR(EP.COMPLEMENTO,1,20) END AS COMPL_ENDER_PROF,
CASE WHEN EP.BAIRRO IS NULL THEN RPAD (' ',20, ' ') ELSE SUBSTR(EP.BAIRRO,1,20) END AS BAIRRO_PROF,
CASE WHEN TM.DESCRICAO IS NULL THEN RPAD (' ',40, ' ') ELSE SUBSTR(TM.DESCRICAO,1,40) END AS DESC_MUNICIPIO_PROF,
CASE WHEN UF.CODIGO_RAIS IS NULL THEN RPAD (' ',4, ' ') ELSE SUBSTR(UF.CODIGO_RAIS,1,4)||'- '|| SUBSTR(UF.DESCRICAO,1,40) END AS UF_ENDER_PROF,
CASE WHEN EP.CEP IS NULL THEN RPAD(' ',8,' ') ELSE SUBSTR(EP.CEP,1,8) END AS CEP_ENDER_PROF,
CASE WHEN PAIS.DESCRICAO IS NULL THEN RPAD (' ',40, ' ') ELSE SUBSTR(PAIS.DESCRICAO,1,40) END AS PAIS_ORIG_PROF,
CASE WHEN CN.DESCRICAO IS NULL THEN RPAD (' ',30, ' ') ELSE SUBSTR(CN.DESCRICAO,1,30) END AS CRM_REGISTRO_PROFISSIONAL,
CASE WHEN P.INSCRICAO_CONSELHO IS NULL THEN RPAD (' ',30, ' ') ELSE SUBSTR(P.INSCRICAO_CONSELHO,1,30) END AS INSC_CONS_REGI_PROFIS,
CASE WHEN P.DATA_EXP_CONSELHO IS NULL THEN RPAD(' ',10,' ') ELSE TO_CHAR (P.DATA_EXP_CONSELHO, 'DD/MM/YYYY') END AS DT_EXPED_CONS_PROF,
CASE WHEN P.DT_VALIDADE_CONSELHO IS NULL THEN RPAD(' ',10,' ') ELSE TO_CHAR (P.DT_VALIDADE_CONSELHO, 'DD/MM/YYYY') END AS DT_VALID_CONS_PROF,
CASE WHEN UF1.CODIGO_RAIS IS NULL THEN RPAD (' ',4, ' ') ELSE SUBSTR(UF1.CODIGO_RAIS,1,4) ||'- '|| SUBSTR(UF1.DESCRICAO,1,40) END AS UF_CRM_PROF,
CASE WHEN PAIS.DESCRICAO IS NULL THEN RPAD (' ',40, ' ') ELSE RPAD(SUBSTR(PAIS.DESCRICAO,1,40),40,' ') END AS PAIS_ORIG_PROF,
CASE WHEN UF2.CODIGO_RAIS IS NULL THEN LPAD (' ',4,' ') ELSE SUBSTR(UF2.CODIGO_RAIS,1,4) ||'- '|| SUBSTR(UF2.DESCRICAO,1,40) END as UF_NATURAL_PROF,
CASE WHEN P.UF_IDENTIDADE IS NULL THEN RPAD (' ',2,' ') ELSE RPAD(SUBSTR(P.UF_IDENTIDADE,1,2),2,' ')END AS UF_IDENT_PROF,
P.cartao_nacio_saude AS CNS
, GREATEST(P.DT_ULT_ALTER_USUA, EP.DT_ULT_ALTER_USUA) AS ULTIMA_ALTERACAO
FROM ARTERH.RHPESS_CONTRATO C
INNER JOIN ARTERH.RHPESS_PESSOA P
ON P.CODIGO=C.CODIGO_PESSOA
AND P.CODIGO_EMPRESA=C.CODIGO_EMPRESA

INNER JOIN  ARTERH.RHTABS_C_REGIONAL CN
ON CN.CODIGO=P.CONSELHO_REGIONAL
INNER JOIN  ARTERH.RHTABS_NACIONALID TN
ON TN.CODIGO=P.NACIONALIDADE
LEFT OUTER JOIN ARTERH.RHPESS_ENDERECO_P EP
ON EP.CODIGO_EMPRESA=P.CODIGO_EMPRESA
AND EP.CODIGO_PESSOA=P.CODIGO
INNER JOIN  ARTERH.RHTABS_UF UF
ON UF.CODIGO = EP.UF
INNER JOIN  ARTERH.RHTABS_UF UF1
ON UF1.CODIGO = P.UF_CONSELHO
INNER JOIN  ARTERH.RHTABS_UF UF2
ON UF2.CODIGO = P.UF_NATURALIDADE
INNER JOIN  ARTERH.RHTABS_MUNICIPIO TM
ON TM.CODIGO=EP.MUNICIPIO

INNER JOIN  ARTERH.RHTABS_MUNICIPIO TM1
ON TM1.CODIGO = P.COD_MUNICIPIO
INNER JOIN  ARTERH.RHTABS_TP_LOGRAD TL
ON TL.CODIGO=EP.TIPO_LOGRADOURO
LEFT OUTER JOIN ARTERH.RHPESS_TELEFONE_P TEL
ON  TEL.CODIGO_EMPRESA=P.CODIGO_EMPRESA
AND TEL.CODIGO_PESSOA=P.CODIGO
AND TEL.COD_TIPO_TELEFONE = '0002' AND ((TEL.DATA_FIM_VIGENCIA IS NULL) OR (TEL.DATA_FIM_VIGENCIA >= TRUNC(SYSDATE)))
AND TEL.PREFERENCIAL='S'
INNER JOIN  ARTERH.RHTABS_TP_TELEFONE TPL
ON TPL.COD_TIPO_TELEFONE=TEL.COD_TIPO_TELEFONE
LEFT OUTER JOIN ARTERH.RHPESS_RL_PESS_PES PS
ON PS.COD_EMPRESA=P.CODIGO_EMPRESA
AND PS.COD_PESSOA=P.CODIGO
AND PS.TP_RELACIONAMENTO = '0005'
AND PS.data_fim_vigencia is null


LEFT JOIN  ARTERH.RHPESS_PESSOA MAE
ON MAE.CODIGO_EMPRESA=PS.COD_EMPRESA
AND MAE.CODIGO=PS.COD_PESSOA_RELAC



INNER JOIN  ARTERH.RHTABS_PAIS PAIS
ON PAIS.CODIGO = P.PAIS_ORIGEM
WHERE
C.ANO_MES_REFERENCIA =
  (SELECT MAX(AUX.ANO_MES_REFERENCIA)
  FROM ARTERH.RHPESS_CONTRATO AUX
  WHERE AUX.CODIGO_EMPRESA=C.CODIGO_EMPRESA
  AND AUX.TIPO_CONTRATO   =C.TIPO_CONTRATO
  AND AUX.CODIGO          =C.CODIGO
    AND AUX.CODIGO_pessoa          =C.CODIGO_pessoa  )
and c.codigo_empresa='0001'
and c.tipo_contrato in ('0001', '0211', '0212', '0213', '0214', '0215', '0015','0007','0216')
AND C.COD_CUSTO_CONTAB1 IN ('000095')
group by
C.CODIGO_PESSOA ,
SUBSTR(P.NOME,1,60),
CASE WHEN P.DT_TERMINO IS NULL THEN 'A'  ELSE 'I' END  ,
CASE WHEN P.NOME_SOCIAL IS NULL THEN LPAD(' ',60,' ') ELSE SUBSTR(P.NOME_SOCIAL,1,60) END ,
TO_CHAR(P.DATA_NASCIMENTO, 'DD/MM/YYYY') ,
CASE WHEN MAE.NOME IS NULL THEN SUBSTR(P.C_LIVRE_DESCR12,1,60) ELSE SUBSTR(MAE.NOME,1,60) END,
CASE WHEN P.SEXO = '0001' THEN 'M' ELSE 'F' END,
CASE WHEN P.NACIONALIDADE = '0010' THEN 'S' ELSE 'N' END  ,
CASE WHEN TM1.DESCRICAO IS NULL THEN LPAD (' ',40,' ') ELSE SUBSTR(TM1.DESCRICAO,1,40) END ,
CASE WHEN TN.DESCRICAO IS NULL THEN LPAD (' ',40,' ') ELSE SUBSTR(TN.DESCRICAO,1,40) END ,
CASE WHEN P.CPF IS NULL THEN LPAD (' ',14, ' ') ELSE substr(P.CPF,1,14) END ,
CASE WHEN P.IDENTIDADE IS NULL THEN LPAD (' ',20, ' ') ELSE SUBSTR(P.IDENTIDADE,1,20) END ,
CASE WHEN P.ORGAO_EXPEDIDOR IS NULL THEN RPAD (' ',40, ' ') ELSE substr(P.ORGAO_EXPEDIDOR,1,30) END ,
CASE WHEN P.DATA_EXPEDICAO IS NULL THEN RPAD (' ',8, ' ') ELSE TO_CHAR(P.DATA_EXPEDICAO,'DD/MM/YYYY') END ,
CASE WHEN P.HABILITACAO IS NULL THEN RPAD (' ',11, ' ') ELSE SUBSTR(P.HABILITACAO,1,11) END ,
CASE WHEN P.DATA_HABILITACAO IS NULL THEN RPAD (' ',8, ' ') ELSE TO_CHAR(P.DATA_HABILITACAO,'DD/MM/YYYY')END ,
CASE WHEN P.DT_VAL_HABILITACAO IS NULL THEN RPAD (' ',8, ' ')ELSE TO_CHAR(P.DT_VAL_HABILITACAO,'DD/MM/YYYY')END ,
CASE WHEN P.CATEGORIA IS NULL THEN RPAD (' ',15, ' ') ELSE SUBSTR(P.CATEGORIA,1,15) END ,   
CASE WHEN P.IDENT_ESTRANGEIRO IS NULL THEN RPAD (' ',20, ' ') ELSE SUBSTR(P.IDENT_ESTRANGEIRO,1,20) END ,
CASE WHEN P.ANO_CHEGADA IS NULL THEN RPAD (' ',4, ' ') ELSE TO_CHAR (P.ANO_CHEGADA,'YYYY') END ,
CASE WHEN TEL.TELEFONE IS NULL THEN RPAD (' ',14, ' ') ELSE LPAD(SUBSTR(TEL.DDD,1,3),3,0)||SUBSTR(TEL.TELEFONE,1,10) END ,
CASE WHEN EP.ENDER_ELETRONICO IS NULL THEN RPAD (' ',60, ' ') ELSE SUBSTR(EP.ENDER_ELETRONICO,1,60) END ,
CASE WHEN TL.DESCRICAO IS NULL THEN RPAD (' ',20, ' ') ELSE SUBSTR(TL.DESCRICAO,1,20) END ,
CASE WHEN EP.ENDERECO IS NULL THEN RPAD (' ',60, ' ') ELSE SUBSTR(EP.ENDERECO,1,60) END ,
CASE WHEN EP.NUMERO IS NULL THEN RPAD (' ',10, ' ') ELSE SUBSTR(EP.NUMERO,1,10) END ,
CASE WHEN EP.COMPLEMENTO IS NULL THEN RPAD (' ',20, ' ') ELSE SUBSTR(EP.COMPLEMENTO,1,20) END ,
CASE WHEN EP.BAIRRO IS NULL THEN RPAD (' ',20, ' ') ELSE SUBSTR(EP.BAIRRO,1,20) END,
CASE WHEN TM.DESCRICAO IS NULL THEN RPAD (' ',40, ' ') ELSE SUBSTR(TM.DESCRICAO,1,40) END ,
CASE WHEN UF.CODIGO_RAIS IS NULL THEN RPAD (' ',4, ' ') ELSE SUBSTR(UF.CODIGO_RAIS,1,4)||'- '|| SUBSTR(UF.DESCRICAO,1,40) END ,
CASE WHEN EP.CEP IS NULL THEN RPAD(' ',8,' ') ELSE SUBSTR(EP.CEP,1,8) END ,
CASE WHEN PAIS.DESCRICAO IS NULL THEN RPAD (' ',40, ' ') ELSE SUBSTR(PAIS.DESCRICAO,1,40) END ,
CASE WHEN CN.DESCRICAO IS NULL THEN RPAD (' ',30, ' ') ELSE SUBSTR(CN.DESCRICAO,1,30) END ,
CASE WHEN P.INSCRICAO_CONSELHO IS NULL THEN RPAD (' ',30, ' ') ELSE SUBSTR(P.INSCRICAO_CONSELHO,1,30) END ,
CASE WHEN P.DATA_EXP_CONSELHO IS NULL THEN RPAD(' ',10,' ') ELSE TO_CHAR (P.DATA_EXP_CONSELHO, 'DD/MM/YYYY') END ,
CASE WHEN P.DT_VALIDADE_CONSELHO IS NULL THEN RPAD(' ',10,' ') ELSE TO_CHAR (P.DT_VALIDADE_CONSELHO, 'DD/MM/YYYY') END ,
CASE WHEN UF1.CODIGO_RAIS IS NULL THEN RPAD (' ',4, ' ') ELSE SUBSTR(UF1.CODIGO_RAIS,1,4) ||'- '|| SUBSTR(UF1.DESCRICAO,1,40) END ,
CASE WHEN PAIS.DESCRICAO IS NULL THEN RPAD (' ',40, ' ') ELSE RPAD(SUBSTR(PAIS.DESCRICAO,1,40),40,' ') END ,
CASE WHEN UF2.CODIGO_RAIS IS NULL THEN LPAD (' ',4,' ') ELSE SUBSTR(UF2.CODIGO_RAIS,1,4) ||'- '|| SUBSTR(UF2.DESCRICAO,1,40) END ,
CASE WHEN P.UF_IDENTIDADE IS NULL THEN RPAD (' ',2,' ') ELSE RPAD(SUBSTR(P.UF_IDENTIDADE,1,2),2,' ')END,
P.cartao_nacio_saude,
GREATEST(P.DT_ULT_ALTER_USUA, EP.DT_ULT_ALTER_USUA)