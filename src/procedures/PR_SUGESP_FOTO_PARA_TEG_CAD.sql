
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_SUGESP_FOTO_PARA_TEG_CAD" 
AS
--KELLYSSON EM 7/8/20 BASEADO roteiro_relatorio_cad.sql

BEGIN  
--******************DIARIAMENTE****************

--1º passo - limpar tabela temporaria
delete ARTERH.SUGESP_FOTO_PARA_TEG; commit;


--2º passo - bater foto DE TODOS OS CONTRATOS NA BASE DE DADOS DO ARTERH
--entrar e rodar no Pentaho TRANSFORMATION (03-2020 TEG) STEP (IN ARTERH.SUGESP_FOTO_PARA_TEG)

FOR C1 IN(


SELECT X.* FROM(
------------inicio-----------------------------------------------------------------------------PARA ATIVOS
SELECT
RHPESS_CONTRATO.ANO_MES_REFERENCIA,
'ARTERH' TIPO,
RHPESS_CONTRATO.CODIGO_EMPRESA,
RHPESS_CONTRATO.TIPO_CONTRATO,
RHPESS_PESSOA.CODIGO AS CODIGO_PESSOA, 
RHPESS_CONTRATO.CODIGO AS CODIGO_CONTRATO, 
RHPESS_CONTRATO.NOME, 
RHPESS_PESSOA.NOME_SOCIAL, 
RHPESS_PESSOA.DATA_NASCIMENTO, 
CASE WHEN RHPESS_PESSOA.SEXO = '0001' THEN 'M' ELSE 'F'END SEXO,
RHPESS_PESSOA.CPF, 
RHPESS_PESSOA.PIS_PASEP AS PIS_PASEP_NIT,  
RHPESS_PESSOA.IDENTIDADE, 
RHPESS_ENDERECO_P.CEP, 
RHTABS_TP_LOGRAD.DESCRICAO AS TIPO_LOGRADOURO, 
RHPESS_CONTRATO.SITUACAO_FUNCIONAL AS CODIGO_SITUACAO_FUNCIONAL, 
RHPARM_SIT_FUNC.DESCRICAO AS SITUACAO_FUNCIONAL, 
RHPESS_ENDERECO_P.ENDERECO AS LOGRADOURO,   
RHPESS_ENDERECO_P.NUMERO, 
RHPESS_ENDERECO_P.COMPLEMENTO,
RHPESS_ENDERECO_P.BAIRRO, 
RHTABS_MUNICIPIO.DESCRICAO AS MUNICIPIO, 
RHPESS_ENDERECO_P.UF,
RHPESS_CONTRATO.VINCULO, 
RHTABS_VINCULO_EMP.DESCRICAO AS DESCRICAO_VINCULO,
RHPESS_CONTRATO.COD_CARGO_EFETIVO, 
EFET.DESCRICAO CARGO_EFETIVO, 
RHPESS_CONTRATO.COD_CARGO_COMISS, 
COMISS.DESCRICAO CARGO_COMISSIONADO, 
RHPLCS_ESPECIALID.DESCRICAO AS ESPECIALIDADE,
       GR.COD_CGERENC1 COD_UNIDADE1, GR.COD_CGERENC2 COD_UNIDADE2, GR.COD_CGERENC3 COD_UNIDADE3, 
       GR.COD_CGERENC4 COD_UNIDADE4, GR.COD_CGERENC5 COD_UNIDADE5, GR.COD_CGERENC6 COD_UNIDADE6, 
       GR.TEXTO_ASSOCIADO AS LOTACAO,
RHPESS_CONTRATO.DATA_ADMISSAO, 
RHPESS_CONTRATO.DATA_EFETIVO_EXERC,
RHPESS_CONTRATO.DATA_RESCISAO, 
RHPESS_CONTRATO.causa_rescisao COD_CAUSA_RESCISAO,   
RHPARM_CAUSA_RESC.DESCRICAO CAUSA_RESCISAO,
RHPONT_ESCALA.JORNADA_MENSAL,
RHPONT_ESCALA.DESCRICAO AS ESCALA
,RHPESS_CONTRATO.E_MAIL
,RHPESS_ENDERECO_P.TELEFONE 
,CASE WHEN RHPESS_CONTRATO.DATA_RESCISAO IS NULL THEN 'NAO' ELSE 'SIM' END TEM_RESCISAO
FROM RHPESS_CONTRATO
LEFT OUTER JOIN RHPESS_PESSOA ON RHPESS_PESSOA.CODIGO = RHPESS_CONTRATO.CODIGO_PESSOA AND RHPESS_PESSOA.CODIGO_EMPRESA = RHPESS_CONTRATO.CODIGO_EMPRESA
LEFT OUTER JOIN RHPESS_ENDERECO_P ON RHPESS_PESSOA.CODIGO = RHPESS_ENDERECO_P.CODIGO_PESSOA AND RHPESS_PESSOA.CODIGO_EMPRESA = RHPESS_ENDERECO_P.CODIGO_EMPRESA
LEFT OUTER JOIN RHTABS_TP_LOGRAD ON RHTABS_TP_LOGRAD.CODIGO = RHPESS_ENDERECO_P.TIPO_LOGRADOURO
LEFT OUTER JOIN RHTABS_MUNICIPIO ON RHTABS_MUNICIPIO.CODIGO = RHPESS_ENDERECO_P.MUNICIPIO
LEFT OUTER JOIN RHTABS_VINCULO_EMP ON RHPESS_CONTRATO.VINCULO = RHTABS_VINCULO_EMP.CODIGO
LEFT OUTER JOIN RHPLCS_ESPECIALID ON RHPESS_CONTRATO.COD_ESPECIALIDADE = RHPLCS_ESPECIALID.CODIGO AND RHPESS_CONTRATO.CODIGO_EMPRESA = RHPLCS_ESPECIALID.CODIGO_EMPRESA 
LEFT OUTER JOIN RHPONT_ESCALA ON RHPONT_ESCALA.CODIGO = RHPESS_CONTRATO.CODIGO_ESCALA AND RHPONT_ESCALA.CODIGO_EMPRESA = RHPESS_CONTRATO.CODIGO_EMPRESA 
LEFT OUTER JOIN RHPLCS_CARGO EFET ON EFET.CODIGO = RHPESS_CONTRATO.COD_CARGO_EFETIVO AND EFET.CODIGO_EMPRESA = RHPESS_CONTRATO.CODIGO_EMPRESA
LEFT OUTER JOIN RHPLCS_CARGO COMISS ON COMISS.CODIGO = RHPESS_CONTRATO.COD_CARGO_COMISS AND COMISS.CODIGO_EMPRESA = RHPESS_CONTRATO.CODIGO_EMPRESA
LEFT OUTER JOIN RHPARM_SIT_FUNC ON RHPARM_SIT_FUNC.CODIGO = RHPESS_CONTRATO.SITUACAO_FUNCIONAL
LEFT OUTER JOIN RHORGA_UNIDADE ON RHORGA_UNIDADE.COD_UNIDADE1 = RHPESS_CONTRATO.COD_UNIDADE1 
AND RHORGA_UNIDADE.COD_UNIDADE2= RHPESS_CONTRATO.COD_UNIDADE2 
AND RHORGA_UNIDADE.COD_UNIDADE3= RHPESS_CONTRATO.COD_UNIDADE3 
AND RHORGA_UNIDADE.COD_UNIDADE4= RHPESS_CONTRATO.COD_UNIDADE4 
AND RHORGA_UNIDADE.COD_UNIDADE5= RHPESS_CONTRATO.COD_UNIDADE5 
AND RHORGA_UNIDADE.COD_UNIDADE6= RHPESS_CONTRATO.COD_UNIDADE6 
AND RHORGA_UNIDADE.CODIGO_EMPRESA= RHPESS_CONTRATO.CODIGO_EMPRESA
 LEFT JOIN RHORGA_CUSTO_GEREN GR
          ON RHPESS_CONTRATO.COD_CUSTO_GERENC1  = GR.COD_CGERENC1
          AND RHPESS_CONTRATO.COD_CUSTO_GERENC2 = GR.COD_CGERENC2
          AND RHPESS_CONTRATO.COD_CUSTO_GERENC3 = GR.COD_CGERENC3
          AND RHPESS_CONTRATO.COD_CUSTO_GERENC4 = GR.COD_CGERENC4
          AND RHPESS_CONTRATO.COD_CUSTO_GERENC5 = GR.COD_CGERENC5
          AND RHPESS_CONTRATO.COD_CUSTO_GERENC6 = GR.COD_CGERENC6
          AND RHPESS_CONTRATO.CODIGO_EMPRESA    = GR.CODIGO_EMPRESA
LEFT OUTER JOIN RHORGA_EMPRESA ON RHORGA_EMPRESA.CODIGO = RHPESS_CONTRATO.CODIGO_EMPRESA
LEFT OUTER JOIN RHPESS_TP_CONTRATO ON RHPESS_TP_CONTRATO.CODIGO = RHPESS_CONTRATO.TIPO_CONTRATO
LEFT OUTER JOIN RHPARM_CAUSA_RESC ON RHPARM_CAUSA_RESC.CODIGO = RHPESS_CONTRATO.causa_rescisao
WHERE 
RHPESS_CONTRATO.ANO_MES_REFERENCIA = (SELECT MAX (A.ANO_MES_REFERENCIA) /*MAX CONTRATO*/
                                          FROM RHPESS_CONTRATO A
												                  WHERE A.CODIGO = RHPESS_CONTRATO.CODIGO AND
                                          A.CODIGO_EMPRESA = RHPESS_CONTRATO.CODIGO_EMPRESA AND
                                          A.TIPO_CONTRATO = RHPESS_CONTRATO.TIPO_CONTRATO 
                                         -- AND a.ANO_MES_REFERENCIA <= TO_DATE('01/12/19','DD/MM/YY') ------------------------------------- :DATA_1
                                          )
------------fim-----------------------------------------------------------------------------PARA ATIVOS

)X
--WHERE CODIGO_CONTRATO = '000000000883291'
ORDER BY X.TIPO, X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.NOME

)LOOP
INSERT INTO ARTERH.SUGESP_FOTO_PARA_TEG VALUES(
C1.ANO_MES_REFERENCIA, C1.TIPO, C1.CODIGO_EMPRESA, C1.TIPO_CONTRATO, C1.CODIGO_PESSOA, C1.CODIGO_CONTRATO, C1.NOME, C1.NOME_SOCIAL, C1.DATA_NASCIMENTO, C1.SEXO, C1.CPF, C1.PIS_PASEP_NIT, C1.IDENTIDADE, C1.CEP, C1.TIPO_LOGRADOURO, C1.CODIGO_SITUACAO_FUNCIONAL, C1.SITUACAO_FUNCIONAL, C1.LOGRADOURO, C1.NUMERO, C1.COMPLEMENTO, C1.BAIRRO, C1.MUNICIPIO, C1.UF, C1.VINCULO, C1.DESCRICAO_VINCULO, C1.COD_CARGO_EFETIVO, C1.CARGO_EFETIVO, C1.COD_CARGO_COMISS, C1.CARGO_COMISSIONADO, C1.ESPECIALIDADE, C1.COD_UNIDADE1, C1.COD_UNIDADE2, C1.COD_UNIDADE3, C1.COD_UNIDADE4, C1.COD_UNIDADE5, C1.COD_UNIDADE6, C1.LOTACAO, C1.DATA_ADMISSAO, C1.DATA_EFETIVO_EXERC, C1.DATA_RESCISAO, C1.COD_CAUSA_RESCISAO, C1.CAUSA_RESCISAO, C1.JORNADA_MENSAL, C1.ESCALA, C1.E_MAIL, C1.TELEFONE, C1.TEM_RESCISAO
)
; COMMIT;

END LOOP;


--3º passo - gravar na tabela definitiva que vai ficar arquivada as fotos os dados extraidos nos 2 passos anteriores unindo os mesmos.
--entrar e rodar no Pentaho TRANSFORMATION (03-2020 TEG) STEP (IN ARTERH.SUGESP_FOTO_PARA_TEG e REM)
--select TIPO,trunc(dt_saiu_arte), count(1)quant from ARTERH.SUGESP_FOTO_PARA_TEG_HISTORIC group by TIPO,trunc(dt_saiu_arte) ORDER BY  trunc(dt_saiu_arte) DESC
FOR C2 IN (

SELECT  P.*, R.ano_mes_verba , r.valor_verba, sysdate dt_saiu_arte, null dt_enviou_teg FROM ARTERH.SUGESP_FOTO_PARA_TEG P
LEFT OUTER JOIN ARTERH.SUGESP_FOTO_PARA_TEG_REM R ON P.CODIGO_EMPRESA = R.CODIGO_EMPRESA AND P.TIPO_CONTRATO = R.TIPO_CONTRATO AND P.CODIGO_CONTRATO = R.CODIGO_CONTRATO

)LOOP

INSERT INTO ARTERH.SUGESP_FOTO_PARA_TEG_HISTORIC
(ANO_MES_REFERENCIA, TIPO, CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_PESSOA, CODIGO_CONTRATO, NOME, NOME_SOCIAL, DATA_NASCIMENTO, SEXO, CPF, PIS_PASEP_NIT, IDENTIDADE, CEP, TIPO_LOGRADOURO, CODIGO_SITUACAO_FUNCIONAL, SITUACAO_FUNCIONAL, LOGRADOURO, NUMERO, COMPLEMENTO, BAIRRO, MUNICIPIO, UF, VINCULO, DESCRICAO_VINCULO, COD_CARGO_EFETIVO, CARGO_EFETIVO, COD_CARGO_COMISS, CARGO_COMISSIONADO, ESPECIALIDADE, COD_UNIDADE1, COD_UNIDADE2, COD_UNIDADE3, COD_UNIDADE4, COD_UNIDADE5, COD_UNIDADE6, LOTACAO, DATA_ADMISSAO, DATA_EFETIVO_EXERC, DATA_RESCISAO, COD_CAUSA_RESCISAO, CAUSA_RESCISAO, JORNADA_MENSAL, ESCALA, E_MAIL, TELEFONE, TEM_RESCISAO, ANO_MES_VERBA, VALOR_VERBA, DT_SAIU_ARTE, DT_ENVIOU_TEG)
 VALUES (
C2.ANO_MES_REFERENCIA, C2.TIPO, C2.CODIGO_EMPRESA, C2.TIPO_CONTRATO, C2.CODIGO_PESSOA, C2.CODIGO_CONTRATO, C2.NOME, C2.NOME_SOCIAL, C2.DATA_NASCIMENTO, C2.SEXO, C2.CPF, C2.PIS_PASEP_NIT, C2.IDENTIDADE, C2.CEP, C2.TIPO_LOGRADOURO, C2.CODIGO_SITUACAO_FUNCIONAL, C2.SITUACAO_FUNCIONAL, C2.LOGRADOURO, C2.NUMERO, C2.COMPLEMENTO, C2.BAIRRO, C2.MUNICIPIO, C2.UF, C2.VINCULO, C2.DESCRICAO_VINCULO, C2.COD_CARGO_EFETIVO, C2.CARGO_EFETIVO, C2.COD_CARGO_COMISS, C2.CARGO_COMISSIONADO, C2.ESPECIALIDADE, C2.COD_UNIDADE1, C2.COD_UNIDADE2, C2.COD_UNIDADE3, C2.COD_UNIDADE4, C2.COD_UNIDADE5, C2.COD_UNIDADE6, C2.LOTACAO, C2.DATA_ADMISSAO, C2.DATA_EFETIVO_EXERC, C2.DATA_RESCISAO, C2.COD_CAUSA_RESCISAO, C2.CAUSA_RESCISAO, C2.JORNADA_MENSAL, C2.ESCALA, C2.E_MAIL, C2.TELEFONE, C2.TEM_RESCISAO, C2.ANO_MES_VERBA, C2.VALOR_VERBA, C2.DT_SAIU_ARTE, C2.DT_ENVIOU_TEG
); COMMIT;

END LOOP;

--5º gravar como enviado
update ARTERH.SUGESP_FOTO_PARA_TEG_HISTORIC set dt_enviou_teg = sysdate where dt_enviou_teg is null;commit;                                                  
--select dt_enviou_teg, count(1)quant from ARTERH.SUGESP_FOTO_PARA_TEG_HISTORIC group by dt_enviou_teg order by dt_enviou_teg  desc


--4º gerar relatorio para enviar à TEG com os novos cadastros e alterações realizadas 
--PROCEDURE_FOTO_DIARIA_antigo.sql > PR_FOTO_DIARIA_TEG_ANTIGO.sql 


END;

