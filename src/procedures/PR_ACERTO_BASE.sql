
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PR_ACERTO_BASE" AS 
BEGIN 
DECLARE
CONT NUMBER;
BEGIN
CONT:=0;
FOR C1 IN (
SELECT XX.*,SYSDATE AS DATA_DADOS,CASE WHEN XX.EMPRESA_ARTE='0001' THEN 'PBH' 
  WHEN XX.EMPRESA_ARTE='0003' THEN 'SUDECAP'
  WHEN XX.EMPRESA_ARTE='0013' THEN 'FMC'
  WHEN XX.EMPRESA_ARTE='0014' THEN 'FMZB'
  END AS EMPRESA,
   CASE WHEN XX.EMPRESA_ARTE='0001' THEN 'ADMINISTRACAO_DIRETE' 
  WHEN XX.EMPRESA_ARTE='0003' THEN 'ADMINISTRACAO_INDIRETA'
  WHEN XX.EMPRESA_ARTE='0013' THEN 'ADMINISTRACAO_INDIRETA'
  WHEN XX.EMPRESA_ARTE='0014' THEN 'ADMINISTRACAO_INDIRETA'
  END AS AGRUPAMENTO_EMPRESA
FROM
  (SELECT
    CASE
      WHEN (X.CONTRATO_ARTE           IS NOT NULL
      AND X.CONTRATO_IFPONTO          IS NOT NULL)
      AND X.DATA_DESLIGAMENTO_IFPONTO IS NOT NULL
      AND X.DATA_DESLIGAMENTO_ARTE    IS NOT NULL
      THEN'PESSOA_DESLIGADA'
      WHEN(X.CONTRATO_ARTE            IS NOT NULL
      AND X.CONTRATO_IFPONTO          IS NOT NULL)
      AND X.DATA_DESLIGAMENTO_IFPONTO IS NULL
      AND X.DATA_DESLIGAMENTO_ARTE    IS NOT NULL
      THEN'DESLIGAR_PESSOA'
      WHEN(X.CONTRATO_ARTE            IS NOT NULL
      AND X.CONTRATO_IFPONTO          IS NOT NULL)
      AND X.DATA_DESLIGAMENTO_IFPONTO IS NULL
      AND X.DATA_DESLIGAMENTO_ARTE    IS NULL
      AND X.CHAVE_INTEGRACAO           ='INATIVO'
      THEN'DESLIGAR_PESSOA'
      WHEN(X.CONTRATO_ARTE            IS NOT NULL
      AND X.CONTRATO_IFPONTO          IS NOT NULL)
      AND X.DATA_DESLIGAMENTO_IFPONTO IS NOT NULL
      AND X.DATA_DESLIGAMENTO_ARTE    IS NULL
      THEN'REATIVAR_PESSOA'
      WHEN(X.CONTRATO_ARTE            IS NOT NULL
      AND X.CONTRATO_IFPONTO          IS NOT NULL)
      AND X.DATA_DESLIGAMENTO_IFPONTO IS NOT NULL
      AND X.DATA_DESLIGAMENTO_ARTE    IS NOT NULL
      AND X.CHAVE_INTEGRACAO           ='ATIVO'
      THEN'REATIVAR_PESSOA'
      WHEN(X.CONTRATO_ARTE            IS NOT NULL
      AND X.CONTRATO_IFPONTO          IS NOT NULL)
      AND X.DATA_DESLIGAMENTO_IFPONTO IS NULL
      AND X.DATA_DESLIGAMENTO_ARTE    IS NULL
      AND X.CHAVE_INTEGRACAO           ='ATIVO'
      THEN'PESSOA_ATIVA'
      ELSE'AVALIAR'
    END AS TIPO_PESSOA,
    CASE
      WHEN X.CONTRATO_IFPONTO IS NOT NULL
      AND X.CONTRATO_ARTE     IS NULL
      THEN 'PESSOA_NAO_ENCONTRADA_ARTE'
      WHEN X.CONTRATO_IFPONTO IS NULL
      AND X.CONTRATO_ARTE     IS NOT NULL
      THEN 'PESSOA_NAO_ENCONTRADA_IFPONTO'
      WHEN X.CONTRATO_IFPONTO= X.CONTRATO_ARTE
      THEN'PESSOA_ENCONTRADA'
      ELSE 'AVALIAR'
    END AS PESSOA,
    CASE
      WHEN TRIM(X.NOME_IFPONTO)!=TRIM(X.NOME_ARTE)
      THEN 'NOME_DIFERENTE'
      ELSE 'NOME_IGUAL'
    END AS NOME_DIFERENTE,
    CASE
      WHEN X.CPF_IFPONTO!=X.CPF_ARTE
      THEN'CPF_DIFERENTE'
      ELSE 'CPF_IGUAL'
    END AS CPF_DIFERENTE,
    CASE
      WHEN X.CODIGO_ESCALA_IFPONTO!= X.CODIGO_ESCALA_ARTE
      THEN'ESCALA_DIFERENTE'
      WHEN X.CODIGO_ESCALA_IFPONTO IS NULL
      AND X.CODIGO_ESCALA_ARTE     IS NOT NULL
      THEN 'ESCALA_DIFERENTE'
      ELSE 'ESCALA_IGUAL'
    END AS CODIGO_ESCALA_DIFERENTE,
    CASE
      WHEN X.DATA_INICIO_ESCALA_IFPONTO!=X.DATA_INICIO_ESCALA_ARTE
      THEN'DATA_ESCALA_DIFERENTE'
      ELSE'DATA_ESCALA_IGUAL'
    END AS DATA_ESCALA_DIFERENTE,
    CASE
      WHEN (X.COD_UNIDADE1_IFPONTO!=X.COD_UNIDADE1_ARTE
      OR X.COD_UNIDADE2_IFPONTO!   =X.COD_UNIDADE2_ARTE
      OR X.COD_UNIDADE3_IFPONTO!   =X.COD_UNIDADE3_ARTE
      OR X.COD_UNIDADE4_IFPONTO!   =X.COD_UNIDADE4_ARTE
      OR X.COD_UNIDADE5_IFPONTO!   =X.COD_UNIDADE5_ARTE
      OR X.COD_UNIDADE6_IFPONTO!   =X.COD_UNIDADE6_ARTE)
      THEN'CODIGO_UNIDADE_DIFERENTE'
      ELSE 'CODIGO_UNIDADE_IGUAL'
    END AS CODIGO_UNIDADE_DIFERENTE ,
    CASE
      WHEN X.CONTRATO_GESTOR_IFPONTO!= CONTRATO_GESTOR_ARTE
      THEN'GESTOR_DIFERENTE'
     WHEN ((X.CONTRATO_GESTOR_IFPONTO IS NULL AND  CONTRATO_GESTOR_ARTE IS NOT NULL)OR (X.CODIGO_HIERARQUIA IS NULL AND X.EMPRESA_HIERARQUIA<>X.EMPRESA_ARTE)) THEN 'GESTOR_DIFERENTE'
     ELSE 'GESTOR_IGUAL'
    END AS GESTOR_DIFERENTE ,
    CASE WHEN X.TIPO_USUARIO_IFPONTO != X.TIPO_USUARIO_ARTE THEN'TIPO_USUARIO_DIFERENTE' ELSE 'TIPO_USUARIO_IGUAL' END AS TIPO_USUARIO_DIFERENTE,
    CASE WHEN X.CARGO_IFPONTO<>X.CARGO_ARTE THEN 'CARGO_DIFERENTE' ELSE 'CARGO_IGUAL' END AS CARGO_DIFERENTE,
     CASE WHEN X.DIA_COMECO_CICLO_ARTE<>X.DIA_COMECO_CICLO_IFPONTO THEN 'MUDOU_DIA_COMECO_CICLO' ELSE 'DIA_COMECO_CICLO_IGUAL' END AS CICLO_DIFERENTE,
    X.*
  FROM
    (SELECT IF.CODIGO_EMPRESA AS EMPRESA_IFPONTO,
      ARTE.CODIGO_EMPRESA     AS EMPRESA_ARTE,
      IF.TIPO_CONTRATO        AS TIPO_CONTRATO_IFPONTO,
      ARTE.TIPO_CONTRATO      AS TIPO_CONTRATO_ARTE,
      IF.CODIGO_CONTRATO      AS CONTRATO_IFPONTO,
      ARTE.CODIGO_CONTRATO    AS CONTRATO_ARTE,
      IF.NOME                 AS NOME_IFPONTO,
      ARTE.NOME               AS NOME_ARTE,
      IF.CPF                  AS CPF_IFPONTO,
      ARTE.CPF                AS CPF_ARTE,
      if.codigo_escala        AS CODIGO_ESCALA_IFPONTO,
      SUBSTR(ARTE.CODIGO_EMPRESA,3,2)
      ||ARTE.CODIGO_ESCALA  AS CODIGO_ESCALA_ARTE,
      IF.DATA_INICIO_ESCALA AS DATA_INICIO_ESCALA_IFPONTO,
      ARTE.DT_ULT_ESCALA    AS DATA_INICIO_ESCALA_ARTE,
      ARTE.DIA_COMECO_CICLO AS DIA_COMECO_CICLO_ARTE,
      IF.DIA_COMECO_CICLO AS DIA_COMECO_CICLO_IFPONTO,
      CASE
        WHEN LENGTH(IF.CODIGO_UNIDADE)=41
        THEN SUBSTR(IF.CODIGO_UNIDADE,1,6)
        WHEN LENGTH(IF.CODIGO_UNIDADE)=44
        THEN SUBSTR(IF.CODIGO_UNIDADE,4,6)
        ELSE 'AVALIAR'
      END               AS COD_UNIDADE1_IFPONTO ,
      ARTE.COD_UNIDADE1 AS COD_UNIDADE1_ARTE,
      CASE
        WHEN LENGTH(IF.CODIGO_UNIDADE)=41
        THEN SUBSTR(IF.CODIGO_UNIDADE,8,6)
        WHEN LENGTH(IF.CODIGO_UNIDADE)=44
        THEN SUBSTR(IF.CODIGO_UNIDADE,11,6)
        ELSE 'AVALIAR'
      END               AS COD_UNIDADE2_IFPONTO ,
      ARTE.COD_UNIDADE2 AS COD_UNIDADE2_ARTE,
      CASE
        WHEN LENGTH(IF.CODIGO_UNIDADE)=41
        THEN SUBSTR(IF.CODIGO_UNIDADE,15,6)
        WHEN LENGTH(IF.CODIGO_UNIDADE)=44
        THEN SUBSTR(IF.CODIGO_UNIDADE,18,6)
        ELSE 'AVALIAR'
      END               AS COD_UNIDADE3_IFPONTO ,
      ARTE.COD_UNIDADE3 AS COD_UNIDADE3_ARTE,
      CASE
        WHEN LENGTH(IF.CODIGO_UNIDADE)=41
        THEN SUBSTR(IF.CODIGO_UNIDADE,22,6)
        WHEN LENGTH(IF.CODIGO_UNIDADE)=44
        THEN SUBSTR(IF.CODIGO_UNIDADE,25,6)
        ELSE 'AVALIAR'
      END               AS COD_UNIDADE4_IFPONTO ,
      ARTE.COD_UNIDADE4 AS COD_UNIDADE4_ARTE,
      CASE
        WHEN LENGTH(IF.CODIGO_UNIDADE)=41
        THEN SUBSTR(IF.CODIGO_UNIDADE,29,6)
        WHEN LENGTH(IF.CODIGO_UNIDADE)=44
        THEN SUBSTR(IF.CODIGO_UNIDADE,32,6)
        ELSE 'AVALIAR'
      END               AS COD_UNIDADE5_IFPONTO ,
      ARTE.COD_UNIDADE5 AS COD_UNIDADE5_ARTE,
      CASE
        WHEN LENGTH(IF.CODIGO_UNIDADE)=41
        THEN SUBSTR(IF.CODIGO_UNIDADE,36,6)
        WHEN LENGTH(IF.CODIGO_UNIDADE)=44
        THEN SUBSTR(IF.CODIGO_UNIDADE,39,6)
        ELSE 'AVALIAR'
      END                       AS COD_UNIDADE6_IFPONTO,
      ARTE.COD_UNIDADE6         AS COD_UNIDADE6_ARTE,
      IF.NOME_UNIDADE           AS NOME_UNIDADE_IFPONTO,
      ARTE.DESCRICAO_UNIDADE    AS NOME_UNIDADE_ARTE,
      IF.CODIGO_CONTRATO_GESTOR AS CONTRATO_GESTOR_IFPONTO,
      ARTE.CONTRATO_GESTOR      AS CONTRATO_GESTOR_ARTE,
      IF.CPF_GESTOR             AS CPF_GESTOR_IFPONTO,
      ARTE.CPF_GESTOR           AS CPF_GESTOR_ARTE,
      IF.CODIGO_CARGO           AS CARGO_IFPONTO,
      CASE WHEN (COD_CARGO_COMISS IS NULL OR COD_CARGO_COMISS=LPAD('0',15,0)) AND (ARTE.CODIGO_FUNCAO IS NULL OR ARTE.CODIGO_FUNCAO =LPAD('0',15,0)) THEN SUBSTR(ARTE.CODIGO_EMPRESA,3,2)||SUBSTR(ARTE.COD_CARGO_EFETIVO,11,5)
      WHEN (COD_CARGO_COMISS IS NOT  NULL OR COD_CARGO_COMISS!=LPAD('0',15,0)) AND (ARTE.CODIGO_FUNCAO IS NULL OR ARTE.CODIGO_FUNCAO =LPAD('0',15,0)) THEN SUBSTR(ARTE.CODIGO_EMPRESA,3,2)||SUBSTR(ARTE.COD_CARGO_COMISS,11,5)
      WHEN (COD_CARGO_COMISS IS NOT  NULL OR COD_CARGO_COMISS!=LPAD('0',15,0)) AND (ARTE.CODIGO_FUNCAO IS NOT NULL OR ARTE.CODIGO_FUNCAO !=LPAD('0',15,0)) THEN SUBSTR(ARTE.CODIGO_EMPRESA,3,2)|| 9 || SUBSTR(ARTE.CODIGO_FUNCAO ,12,4)
      WHEN  (COD_CARGO_COMISS IS NULL OR COD_CARGO_COMISS=LPAD('0',15,0)) AND (ARTE.CODIGO_FUNCAO IS NOT NULL OR ARTE.CODIGO_FUNCAO !=LPAD('0',15,0)) THEN SUBSTR(ARTE.CODIGO_EMPRESA,3,2)|| 9 || SUBSTR(ARTE.CODIGO_FUNCAO ,12,4) END AS CARGO_ARTE,
      IF.NOME_CARGO             AS NOME_CARGO_IFPONTO,
      ARTE.CARGO_COMISSIONADO   AS NOME_CARGO_COMISS_ARTE,
      ARTE.CARGO_EFETIVO        AS NOME_CARGO_EFETIVO_ARTE,
      ARTE.FUNCAO_PUBLICA       AS NOME_FUNCAO_ARTE,
      IF.DATA_DEMISSAO          AS DATA_DESLIGAMENTO_IFPONTO,
      ARTE.DATA_RESCISAO        AS DATA_DESLIGAMENTO_ARTE,
      IF.TIPO_USUARIO AS TIPO_USUARIO_IFPONTO,
      CASE WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='N' AND  VINCULO = '0009'AND ARTE.TIPO_USUARIO NOT IN ('USA_NAVEGADOR','USA_AMBOS') THEN '3'----- CODIGO DO IFPONTO ESTAGIRIO
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='N' AND  VINCULO <> '0009' AND REGISTRO_PONTO IN ('0010','0020', '0030','0140','0170','0100')AND ARTE.TIPO_USUARIO NOT IN ('USA_NAVEGADOR','USA_AMBOS') THEN '4'------ CODIGO PARA SERVIDOR NO IFPONTO
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='N' AND  VINCULO <> '0009' AND REGISTRO_PONTO IN('0110','0160','0120','0150')AND ARTE.TIPO_USUARIO NOT IN ('USA_NAVEGADOR','USA_AMBOS')THEN'13'------ CODIGO SERVIDOR NO IFPONTO PARA SERVIDOR ISENTO
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='N' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0130') AND ARTE.TIPO_USUARIO NOT IN ('USA_NAVEGADOR','USA_AMBOS')THEN '10'
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0010','0020', '0030','0140','0170','0100')AND ARTE.TIPO_USUARIO NOT IN ('USA_NAVEGADOR','USA_AMBOS') THEN '5'
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0130')AND ARTE.TIPO_USUARIO NOT IN ('USA_NAVEGADOR','USA_AMBOS') THEN '11'
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0110','0160','0120','0150')AND ARTE.TIPO_USUARIO NOT IN ('USA_NAVEGADOR','USA_AMBOS') AND ARTE.CODIGO_EMPRESA <> '0002' THEN '12'
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0110','0160','0120','0150')AND ARTE.TIPO_USUARIO NOT IN ('USA_NAVEGADOR','USA_AMBOS') AND ARTE.CODIGO_EMPRESA = '0002'  THEN '359' --Prodabel Gestor isento
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='N' AND  VINCULO = '0009' AND ARTE.TIPO_USUARIO='USA_NAVEGADOR'THEN '342'----- CODIGO DO IFPONTO ESTAGIRIO
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='N' AND  VINCULO <> '0009' AND  REGISTRO_PONTO IN ('0010','0020', '0030','0140','0170','0100')AND ARTE.TIPO_USUARIO='USA_NAVEGADOR' THEN '342'------ CODIGO PARA SERVIDOR NO IFPONTO
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='N' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0130')AND ARTE.TIPO_USUARIO='USA_NAVEGADOR' THEN '343'
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='N' AND VINCULO<>'0009' AND REGISTRO_PONTO IN('0110','0160','0120','0150')AND ARTE.TIPO_USUARIO='USA_NAVEGADOR' THEN'13'
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='N' AND  VINCULO = '0009' AND ARTE.TIPO_USUARIO='USA_AMBOS'THEN '350'----- CODIGO DO IFPONTO ESTAGIRIO
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='N' AND  VINCULO <> '0009' AND REGISTRO_PONTO IN ('0010','0020', '0030','0140','0170','0100')AND ARTE.TIPO_USUARIO='USA_AMBOS' AND ARTE.CODIGO_EMPRESA <> '0002' THEN '350'------ CODIGO PARA SERVIDOR NO IFPONTO
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='N' AND  VINCULO <> '0009' AND REGISTRO_PONTO IN ('0010','0020', '0030','0140','0170','0100')AND ARTE.TIPO_USUARIO='USA_AMBOS' AND ARTE.CODIGO_EMPRESA = '0002' THEN '357'--357- Prodabel Subordinado- registro APP e desktop NOVO EM 2/6/23 EMAIL ([IMPLANTAÇÃO IFPONTO] Tolerância das jornadas fixas)
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='N' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0130')AND ARTE.TIPO_USUARIO='USA_AMBOS' THEN '351'
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='N' AND VINCULO<>'0009' AND REGISTRO_PONTO IN('0110','0160','0120','0150')AND ARTE.TIPO_USUARIO='USA_AMBOS' THEN'13'
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0010','0020', '0030','0140','0170','0100')AND ARTE.TIPO_USUARIO='USA_NAVEGADOR' THEN '340'
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0130')AND ARTE.TIPO_USUARIO='USA_NAVEGADOR' THEN '341'
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0110','0160','0120','0150')AND ARTE.TIPO_USUARIO='USA_NAVEGADOR' AND ARTE.CODIGO_EMPRESA <> '0002' THEN '12'
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0110','0160','0120','0150')AND ARTE.TIPO_USUARIO='USA_NAVEGADOR' AND ARTE.CODIGO_EMPRESA = '0002' THEN '359'--Prodabel Gestor isento
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0010','0020', '0030','0140','0170','0100')AND ARTE.TIPO_USUARIO='USA_AMBOS' AND ARTE.CODIGO_EMPRESA <> '0002' THEN '348'
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0010','0020', '0030','0140','0170','0100')AND ARTE.TIPO_USUARIO='USA_AMBOS' AND ARTE.CODIGO_EMPRESA = '0002' THEN '360'--Prodabel Gestor - registro APP e desktop
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0130')AND ARTE.TIPO_USUARIO='USA_AMBOS' THEN '349'
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0110','0160','0120','0150')AND ARTE.TIPO_USUARIO='USA_AMBOS' AND ARTE.CODIGO_EMPRESA <> '0002' THEN '12'
  WHEN ARTE.CHAVE_INTEGRACAO IN  ('ATIVO') AND E_GESTOR='S' AND VINCULO<>'0009' AND REGISTRO_PONTO IN ('0110','0160','0120','0150')AND ARTE.TIPO_USUARIO='USA_AMBOS' AND ARTE.CODIGO_EMPRESA = '0002' THEN '359'--Prodabel Gestor isento
  END AS TIPO_USUARIO_ARTE,
      ARTE.CHAVE_INTEGRACAO,ARTE.E_GESTOR,ARTE.TIPO,
      IF.CODIGO_HIERARQUIA,ARTE.EMPRESA_HIERARQUIA
    FROM PONTO_ELETRONICO.SUGESP_INT_PE_IFPONTO IF
    LEFT OUTER JOIN PONTO_ELETRONICO.SUGESP_BI_1CONTRAT_INTIF_ARTE ARTE
    ON IF.CODIGO_EMPRESA   =ARTE.CODIGO_EMPRESA
    AND IF.TIPO_CONTRATO   =ARTE.TIPO_CONTRATO
    AND IF.CODIGO_CONTRATO = ARTE.CODIGO_CONTRATO

   -- AND IF.CPF             =ARTE.CPF
    WHERE IF.DATA_IFPONTO =(SELECT MAX (AUX.DATA_IFPONTO)
    FROM PONTO_ELETRONICO.SUGESP_INT_PE_IFPONTO AUX
    WHERE AUX.TIPO_CONTRATO=IF.TIPO_CONTRATO
    AND AUX.CODIGO_EMPRESA =IF.CODIGO_EMPRESA
    AND AUX.CODIGO_CONTRATO=IF.CODIGO_CONTRATO
    )
    AND TRUNC(ARTE.DT_SAIU_ARTE)=TRUNC(SYSDATE)
---and if.codigo_contrato=LPAD('1175279',15,0)
    )X
  )XX
WHERE ( (XX.NOME_DIFERENTE     ='NOME_DIFERENTE'
AND XX.TIPO_PESSOA             ='PESSOA_ATIVA')
OR (XX.CPF_DIFERENTE           ='CPF_DIFERENTE'
AND XX.TIPO_PESSOA             ='PESSOA_ATIVA')
OR (XX.CODIGO_ESCALA_DIFERENTE ='ESCALA_DIFERENTE'
AND XX.TIPO_PESSOA             ='PESSOA_ATIVA')
OR (XX.DATA_ESCALA_DIFERENTE   ='DATA_ESCALA_DIFERENTE'
AND XX.TIPO_PESSOA             ='PESSOA_ATIVA')
OR (XX.CODIGO_UNIDADE_DIFERENTE='CODIGO_UNIDADE_DIFERENTE'
AND XX.TIPO_PESSOA             ='PESSOA_ATIVA')
OR (XX.GESTOR_DIFERENTE        ='GESTOR_DIFERENTE'
AND XX.TIPO_PESSOA             ='PESSOA_ATIVA')
OR (XX.TIPO_PESSOA            IN ('PESSOA_NAO_ENCONTRADA_IFPONTO','PESSOA_NAO_ENCONTRADA_ARTE'))
OR (XX.TIPO_PESSOA            IN ('DESLIGAR_PESSOA','REATIVAR_PESSOA','AVALIAR')) 
OR (XX.TIPO_USUARIO_DIFERENTE='TIPO_USUARIO_DIFERENTE' AND XX.TIPO_PESSOA             ='PESSOA_ATIVA')
OR (XX.CARGO_DIFERENTE='CARGO_DIFERENTE' AND XX.TIPO_PESSOA             ='PESSOA_ATIVA')
OR (XX.CICLO_DIFERENTE='MUDOU_DIA_COMECO_CICLO' AND XX.TIPO_PESSOA             ='PESSOA_ATIVA') )
)


LOOP
CONT:=CONT+1;
IF C1.TIPO_PESSOA='DESLIGAR_PESSOA' AND C1.CHAVE_INTEGRACAO='INATIVO' THEN 
INSERT INTO ACERTO_IFPONTO (EMPRESA,AGRUPAMENTO_EMPRESA,CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,TIPO_AJUSTE,DATA_GEROU,TIPO_PESSOA) VALUES(C1.EMPRESA,C1.AGRUPAMENTO_EMPRESA,C1.EMPRESA_ARTE,C1.TIPO_CONTRATO_ARTE,C1.CONTRATO_ARTE,C1.TIPO_PESSOA,C1.DATA_DADOS,C1.CHAVE_INTEGRACAO);
BEGIN
DECLARE 
CONT2 NUMBER;
BEGIN 
CONT2:=0;
FOR C2 IN (
SELECT X.* FROM (SELECT CASE WHEN AT.CODIGO_EMPRESA='0001' THEN 'PBH' 
  WHEN AT.CODIGO_EMPRESA='0003' THEN 'SUDECAP'
  WHEN AT.CODIGO_EMPRESA='0013' THEN 'FMC'
  WHEN AT.CODIGO_EMPRESA='0014' THEN 'FMZB'
  END AS EMPRESA,
   CASE WHEN AT.CODIGO_EMPRESA='0001' THEN 'ADMINISTRACAO_DIRETE' 
  WHEN AT.CODIGO_EMPRESA='0003' THEN 'ADMINISTRACAO_INDIRETA'
  WHEN AT.CODIGO_EMPRESA='0013' THEN 'ADMINISTRACAO_INDIRETA'
  WHEN AT.CODIGO_EMPRESA='0014' THEN 'ADMINISTRACAO_INDIRETA'
  END AS AGRUPAMENTO_EMPRESA,'DESLIGAMENTO' TIPO_VW_DADOS_SERVIDOR,
  'PROCEDURE_ACERTO_BASE: PESSOA_DESLIGADA' AS LOCAL_GESTOR,
  CASE WHEN DATA_RESCISAO IS NULL AND SF.data_inic_situacao IS NOT NULL THEN (SELECT MAX (AUX.DATA_INIC_SITUACAO) FROM RHCGED_ALT_SIT_FUN AUX 
WHERE AUX.CODIGO_EMPRESA=SF.CODIGO_EMPRESA
AND AUX.CODIGO=SF.CODIGO
AND AUX.TIPO_CONTRATO=SF.TIPO_CONTRATO
AND AUX.COD_SIT_FUNCIONAL=SF.COD_SIT_FUNCIONAL)
  WHEN DATA_RESCISAO IS NULL AND SF.data_inic_situacao IS  NULL THEN SYSDATE ELSE DATA_RESCISAO END AS DATA_RESCISAO ,
  SYSDATE AS DT_SAIU_ARTE,
  AT.CODIGO_EMPRESA,
 AT.TIPO_CONTRATO,
  AT.CODIGO_CONTRATO
FROM  PONTO_ELETRONICO.SUGESP_BI_1CONTRAT_INTIF_ARTE AT
LEFT OUTER JOIN  RHCGED_ALT_SIT_FUN SF
ON SF.CODIGO_EMPRESA=AT.CODIGO_EMPRESA
AND SF.TIPO_CONTRATO=AT.TIPO_CONTRATO 
AND SF.CODIGO=AT.CODIGO_CONTRATO
AND SF.COD_SIT_FUNCIONAL=AT.SITUACAO_FUNCIONAL
WHERE AT.CODIGO_CONTRATO=''||C1.CONTRATO_ARTE||'' AND AT.CODIGO_EMPRESA=''||C1.EMPRESA_ARTE||''
AND AT.TIPO_CONTRATO=''||C1.TIPO_CONTRATO_ARTE||''
AND TRUNC(AT.DT_SAIU_ARTE)=TRUNC(SYSDATE)
)X
GROUP BY X.TIPO_VW_DADOS_SERVIDOR,X.LOCAL_GESTOR,X.DATA_RESCISAO,X.DT_SAIU_ARTE,X.CODIGO_EMPRESA,X.TIPO_CONTRATO,X.CODIGO_CONTRATO,X.EMPRESA,X.AGRUPAMENTO_EMPRESA
)LOOP
CONT2:=CONT2+1;
INSERT INTO PONTO_ELETRONICO.SMARH_INT_PONTO_DADOS_SERV_V10 (CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,DATA_RESCISAO,TIPO_VW_DADOS_SERVIDOR,DT_SAIU_ARTE,LOCAL_GESTOR,EMPRESA,AGRUPAMENTO_EMPRESA,CODIGO_INTEGRA_ARTE)
VALUES (C2.CODIGO_EMPRESA,C2.TIPO_CONTRATO,C2.CODIGO_CONTRATO,C2.DATA_RESCISAO,C2.TIPO_VW_DADOS_SERVIDOR,C2.DT_SAIU_ARTE,C2.LOCAL_GESTOR,C2.EMPRESA,C2.AGRUPAMENTO_EMPRESA,PONTO_ELETRONICO.SEQUENCE_INTEGRA_ARTE.NEXTVAL);
COMMIT;
UPDATE ACERTO_IFPONTO SET DATA_PROCESSADO=SYSDATE WHERE TIPO_AJUSTE=C1.TIPO_PESSOA AND CODIGO_CONTRATO=C2.CODIGO_CONTRATO AND TIPO_CONTRATO=C2.TIPO_CONTRATO AND CODIGO_EMPRESA=C2.CODIGO_EMPRESA;
COMMIT;
END LOOP;
END;
END;
END IF;
------------------ FIM TRATA PESSOA DESLIGA E GERA REGITRO NA VW PARA DESLIGAR------------------------------------------------------

--------INICIO TRATA PESSOA ATIVA COM ERRO DE NOME-----------------------------------------------------------------------------------

IF C1.TIPO_PESSOA='PESSOA_ATIVA' AND C1.NOME_DIFERENTE='NOME_DIFERENTE' AND C1.CHAVE_INTEGRACAO='ATIVO' and (c1.DATA_DESLIGAMENTO_IFPONTO is null) THEN 

INSERT INTO ACERTO_IFPONTO (EMPRESA,AGRUPAMENTO_EMPRESA,CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,TIPO_AJUSTE,DATA_GEROU,TIPO_PESSOA) VALUES(C1.EMPRESA,C1.AGRUPAMENTO_EMPRESA,C1.EMPRESA_ARTE,C1.TIPO_CONTRATO_ARTE,C1.CONTRATO_ARTE,C1.NOME_DIFERENTE,C1.DATA_DADOS,C1.CHAVE_INTEGRACAO);
BEGIN
DECLARE 
CONT3 NUMBER;
BEGIN
FOR C2 IN (
SELECT CASE WHEN AT.CODIGO_EMPRESA='0001' THEN 'PBH' 
  WHEN AT.CODIGO_EMPRESA='0003' THEN 'SUDECAP'
  WHEN AT.CODIGO_EMPRESA='0013' THEN 'FMC'
  WHEN AT.CODIGO_EMPRESA='0014' THEN 'FMZB'
  END AS EMPRESA,
   CASE WHEN AT.CODIGO_EMPRESA='0001' THEN 'ADMINISTRACAO_DIRETE' 
  WHEN AT.CODIGO_EMPRESA='0003' THEN 'ADMINISTRACAO_INDIRETA'
  WHEN AT.CODIGO_EMPRESA='0013' THEN 'ADMINISTRACAO_INDIRETA'
  WHEN AT.CODIGO_EMPRESA='0014' THEN 'ADMINISTRACAO_INDIRETA'
  END AS AGRUPAMENTO_EMPRESA,'ALTERACOES_DIVERSAS' TIPO_VW_DADOS_SERVIDOR,
  'PROCEDURE_ACERTO_BASE: PESSOA_ATIVA_NOME_DIFERENTE' AS LOCAL_GESTOR,
  SYSDATE AS DT_SAIU_ARTE,
  AT.CODIGO_EMPRESA,
  AT.TIPO_CONTRATO,
  AT.CODIGO_CONTRATO,
  AT.NOME
FROM  SUGESP_BI_1CONTRAT_INTIF_ARTE AT
WHERE AT.CODIGO_CONTRATO=''||C1.CONTRATO_ARTE||'' AND AT.CODIGO_EMPRESA=''||C1.EMPRESA_ARTE||''
AND AT.TIPO_CONTRATO=''||C1.TIPO_CONTRATO_ARTE||''
AND TRUNC(AT.DT_SAIU_ARTE)=TRUNC(SYSDATE)

)
LOOP
CONT3:=CONT3+1;
INSERT INTO PONTO_ELETRONICO.SMARH_INT_PONTO_DADOS_SERV_V10 (CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,NOME,TIPO_VW_DADOS_SERVIDOR,DT_SAIU_ARTE,LOCAL_GESTOR,EMPRESA,AGRUPAMENTO_EMPRESA,CODIGO_INTEGRA_ARTE)
VALUES (C2.CODIGO_EMPRESA,C2.TIPO_CONTRATO,C2.CODIGO_CONTRATO,C2.NOME,C2.TIPO_VW_DADOS_SERVIDOR,C2.DT_SAIU_ARTE,C2.LOCAL_GESTOR,C2.EMPRESA,C2.AGRUPAMENTO_EMPRESA,PONTO_ELETRONICO.SEQUENCE_INTEGRA_ARTE.NEXTVAL);
COMMIT;
UPDATE ACERTO_IFPONTO SET DATA_PROCESSADO=SYSDATE WHERE TIPO_AJUSTE=C1.NOME_DIFERENTE AND CODIGO_CONTRATO=C2.CODIGO_CONTRATO AND TIPO_CONTRATO=C2.TIPO_CONTRATO AND CODIGO_EMPRESA=C2.CODIGO_EMPRESA;
COMMIT;
END LOOP;
END;
END;
END IF;
---- FIM PARTE TRATA NOME

------INCIO CORRIGE ESCALA E DATA DE ESCLA --------------------------
IF C1.CHAVE_INTEGRACAO='ATIVO' AND (C1.CODIGO_ESCALA_DIFERENTE='ESCALA_DIFERENTE' OR C1.DATA_ESCALA_DIFERENTE='DATA_ESCALA_DIFERENTE' OR C1.CICLO_DIFERENTE='MUDOU_DIA_COMECO_CICLO' ) and (c1.DATA_DESLIGAMENTO_IFPONTO is null) THEN 
INSERT INTO ACERTO_IFPONTO (EMPRESA,AGRUPAMENTO_EMPRESA,CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,TIPO_AJUSTE,DATA_GEROU,TIPO_PESSOA) VALUES(C1.EMPRESA,C1.AGRUPAMENTO_EMPRESA,C1.EMPRESA_ARTE,C1.TIPO_CONTRATO_ARTE,C1.CONTRATO_ARTE,C1.CODIGO_ESCALA_DIFERENTE||'-'||C1.DATA_ESCALA_DIFERENTE,C1.DATA_DADOS,C1.CHAVE_INTEGRACAO);
BEGIN
DECLARE 
CONT3 NUMBER;
BEGIN
FOR C2 IN (
SELECT CASE WHEN AT.CODIGO_EMPRESA='0001' THEN 'PBH' 
  WHEN AT.CODIGO_EMPRESA='0003' THEN 'SUDECAP'
  WHEN AT.CODIGO_EMPRESA='0013' THEN 'FMC'
  WHEN AT.CODIGO_EMPRESA='0014' THEN 'FMZB'
  END AS EMPRESA,
   CASE WHEN AT.CODIGO_EMPRESA='0001' THEN 'ADMINISTRACAO_DIRETE' 
  WHEN AT.CODIGO_EMPRESA='0003' THEN 'ADMINISTRACAO_INDIRETA'
  WHEN AT.CODIGO_EMPRESA='0013' THEN 'ADMINISTRACAO_INDIRETA'
  WHEN AT.CODIGO_EMPRESA='0014' THEN 'ADMINISTRACAO_INDIRETA'
  END AS AGRUPAMENTO_EMPRESA,'ALTERACOES_DIVERSAS' TIPO_VW_DADOS_SERVIDOR,
  'PROCEDURE_ACERTO_BASE: AJUSTE_ESCALA' AS LOCAL_GESTOR,
  SYSDATE AS DT_SAIU_ARTE,
  AT.CODIGO_EMPRESA,
  AT.TIPO_CONTRATO,
  AT.CODIGO_CONTRATO,
  SUBSTR(AT.CODIGO_EMPRESA,3,2)||AT.CODIGO_ESCALA AS CODIGO_ESCALA,
  AT.DIA_COMECO_CICLO,
  CASE WHEN AT.DT_ULT_ESCALA IS NULL THEN SYSDATE ELSE AT.DT_ULT_ESCALA END AS DT_ULT_ESCALA
FROM  SUGESP_BI_1CONTRAT_INTIF_ARTE AT
WHERE AT.CODIGO_CONTRATO=''||C1.CONTRATO_ARTE||'' AND AT.CODIGO_EMPRESA=''||C1.EMPRESA_ARTE||''
AND AT.TIPO_CONTRATO=''||C1.TIPO_CONTRATO_ARTE||''
AND TRUNC(AT.DT_SAIU_ARTE)=TRUNC(SYSDATE)

)
LOOP
CONT3:=CONT3+1;
INSERT INTO PONTO_ELETRONICO.SMARH_INT_PONTO_DADOS_SERV_V10 (CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,CODIGO_ESCALA,DIA_COMECO_CICLO,DT_ULT_ESCALA,TIPO_VW_DADOS_SERVIDOR,DT_SAIU_ARTE,LOCAL_GESTOR,EMPRESA,AGRUPAMENTO_EMPRESA,CODIGO_INTEGRA_ARTE)
VALUES (C2.CODIGO_EMPRESA,C2.TIPO_CONTRATO,C2.CODIGO_CONTRATO,C2.CODIGO_ESCALA,C2.DIA_COMECO_CICLO,C2.DT_ULT_ESCALA,C2.TIPO_VW_DADOS_SERVIDOR,C2.DT_SAIU_ARTE,C2.LOCAL_GESTOR,C2.EMPRESA,C2.AGRUPAMENTO_EMPRESA,PONTO_ELETRONICO.SEQUENCE_INTEGRA_ARTE.NEXTVAL);
COMMIT;
UPDATE ACERTO_IFPONTO SET DATA_PROCESSADO=SYSDATE WHERE TIPO_AJUSTE=C1.CODIGO_ESCALA_DIFERENTE||'-'||C1.DATA_ESCALA_DIFERENTE AND CODIGO_CONTRATO=C2.CODIGO_CONTRATO AND TIPO_CONTRATO=C2.TIPO_CONTRATO AND CODIGO_EMPRESA=C2.CODIGO_EMPRESA;
COMMIT;
END LOOP;
END;
END;
END IF;

------FIM CORRIGE ESCALA E DATA ESCALA--------------------------
-------- INICIO AJUSTE HIERARQUIA POR LOCAL NAO GESTOR--------------------------
IF C1.CHAVE_INTEGRACAO='ATIVO' AND  (C1.CODIGO_UNIDADE_DIFERENTE='CODIGO_UNIDADE_DIFERENTE' OR C1.GESTOR_DIFERENTE='GESTOR_DIFERENTE')  AND C1.E_GESTOR='N' AND C1.TIPO !='HIERARQUIA POR PESSOA'  and (c1.DATA_DESLIGAMENTO_IFPONTO is null) THEN 
INSERT INTO ACERTO_IFPONTO (EMPRESA,AGRUPAMENTO_EMPRESA,CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,TIPO_AJUSTE,DATA_GEROU,TIPO_PESSOA) VALUES(C1.EMPRESA,C1.AGRUPAMENTO_EMPRESA,C1.EMPRESA_ARTE,C1.TIPO_CONTRATO_ARTE,C1.CONTRATO_ARTE,C1.CODIGO_UNIDADE_DIFERENTE||'-'||C1.GESTOR_DIFERENTE,C1.DATA_DADOS,C1.CHAVE_INTEGRACAO);
BEGIN
DECLARE 
CONT3 NUMBER;
BEGIN
FOR C2 IN (
SELECT CASE WHEN AT.CODIGO_EMPRESA='0001' THEN 'PBH' 
  WHEN AT.CODIGO_EMPRESA='0003' THEN 'SUDECAP'
  WHEN AT.CODIGO_EMPRESA='0013' THEN 'FMC'
  WHEN AT.CODIGO_EMPRESA='0014' THEN 'FMZB'
  END AS EMPRESA,
   CASE WHEN AT.CODIGO_EMPRESA='0001' THEN 'ADMINISTRACAO_DIRETE' 
  WHEN AT.CODIGO_EMPRESA='0003' THEN 'ADMINISTRACAO_INDIRETA'
  WHEN AT.CODIGO_EMPRESA='0013' THEN 'ADMINISTRACAO_INDIRETA'
  WHEN AT.CODIGO_EMPRESA='0014' THEN 'ADMINISTRACAO_INDIRETA'
  END AS AGRUPAMENTO_EMPRESA,'ALTERACOES_DIVERSAS' TIPO_VW_DADOS_SERVIDOR,
  'PROCEDURE_ACERTO_BASE: AJUSTE HIERARQUIA POR LOCAL NAO GESTOR' AS LOCAL_GESTOR,
  SYSDATE AS DT_SAIU_ARTE,
  AT.CODIGO_EMPRESA,
  AT.TIPO_CONTRATO,
  AT.CODIGO_CONTRATO,
  COD_UNIDADE1,
  COD_UNIDADE2,
  COD_UNIDADE3,
  COD_UNIDADE4,
  COD_UNIDADE5,
  COD_UNIDADE6,
  DESCRICAO_UNIDADE,
  CASE WHEN COD_UNIDADE1 IS NOT NULL THEN
SUBSTR(EMPRESA_HIERARQUIA,3,2)||'.'||COD_UNIDADE1||'.'||COD_UNIDADE2||'.'||COD_UNIDADE3||'.'||COD_UNIDADE4||'.'||COD_UNIDADE5||'.'||COD_UNIDADE6 ELSE NULL END AS CODIGO_UNIDADE -- VOLTANDO EM 10/1/23 SUBSTR(CODIGO_EMPRESA,3,2) --ajuste em 10/8/22--SUBSTR(EMPRESA_HIERARQUIA,3,2)
FROM  SUGESP_BI_1CONTRAT_INTIF_ARTE AT
WHERE AT.CODIGO_CONTRATO=''||C1.CONTRATO_ARTE||'' AND AT.CODIGO_EMPRESA=''||C1.EMPRESA_ARTE||''
AND AT.TIPO_CONTRATO=''||C1.TIPO_CONTRATO_ARTE||''
AND TRUNC(AT.DT_SAIU_ARTE)=TRUNC(SYSDATE)

)
LOOP
CONT3:=CONT3+1;
INSERT INTO PONTO_ELETRONICO.SMARH_INT_PONTO_DADOS_SERV_V10 (CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,COD_UNIDADE1,COD_UNIDADE2,COD_UNIDADE3,COD_UNIDADE4,COD_UNIDADE5,COD_UNIDADE6,DESCRICAO_UNIDADE,CODIGO_UNIDADE,TIPO_VW_DADOS_SERVIDOR,DT_SAIU_ARTE,LOCAL_GESTOR,EMPRESA,AGRUPAMENTO_EMPRESA,CODIGO_INTEGRA_ARTE)
VALUES (C2.CODIGO_EMPRESA,C2.TIPO_CONTRATO,C2.CODIGO_CONTRATO,C2.COD_UNIDADE1,C2.COD_UNIDADE2,C2.COD_UNIDADE3,C2.COD_UNIDADE4,C2.COD_UNIDADE5,C2.COD_UNIDADE6,C2.DESCRICAO_UNIDADE,C2.CODIGO_UNIDADE,C2.TIPO_VW_DADOS_SERVIDOR,C2.DT_SAIU_ARTE,C2.LOCAL_GESTOR,C2.EMPRESA,C2.AGRUPAMENTO_EMPRESA,PONTO_ELETRONICO.SEQUENCE_INTEGRA_ARTE.NEXTVAL);
COMMIT;
UPDATE ACERTO_IFPONTO SET DATA_PROCESSADO=SYSDATE WHERE TIPO_AJUSTE=C1.CODIGO_UNIDADE_DIFERENTE||'-'||C1.GESTOR_DIFERENTE AND CODIGO_CONTRATO=C2.CODIGO_CONTRATO AND TIPO_CONTRATO=C2.TIPO_CONTRATO AND CODIGO_EMPRESA=C2.CODIGO_EMPRESA;
COMMIT;
END LOOP;
END;
END;
END IF;
------AJUSTE HIERAQUIA PARTE GESTOR
IF C1.CHAVE_INTEGRACAO='ATIVO' AND (C1.CODIGO_UNIDADE_DIFERENTE='CODIGO_UNIDADE_DIFERENTE' OR C1.GESTOR_DIFERENTE='GESTOR_DIFERENTE')  AND C1.E_GESTOR='S'  and (c1.DATA_DESLIGAMENTO_IFPONTO is null) THEN 
INSERT INTO ACERTO_IFPONTO (EMPRESA,AGRUPAMENTO_EMPRESA,CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,TIPO_AJUSTE,DATA_GEROU,TIPO_PESSOA) VALUES(C1.EMPRESA,C1.AGRUPAMENTO_EMPRESA,C1.EMPRESA_ARTE,C1.TIPO_CONTRATO_ARTE,C1.CONTRATO_ARTE,C1.CODIGO_UNIDADE_DIFERENTE||'-'||C1.GESTOR_DIFERENTE,C1.DATA_DADOS,C1.CHAVE_INTEGRACAO);
BEGIN
DECLARE 
CONT3 NUMBER;
BEGIN
FOR C2 IN (
SELECT CASE WHEN AT.CODIGO_EMPRESA='0001' THEN 'PBH' 
  WHEN AT.CODIGO_EMPRESA='0003' THEN 'SUDECAP'
  WHEN AT.CODIGO_EMPRESA='0013' THEN 'FMC'
  WHEN AT.CODIGO_EMPRESA='0014' THEN 'FMZB'
  END AS EMPRESA,
   CASE WHEN AT.CODIGO_EMPRESA='0001' THEN 'ADMINISTRACAO_DIRETE' 
  WHEN AT.CODIGO_EMPRESA='0003' THEN 'ADMINISTRACAO_INDIRETA'
  WHEN AT.CODIGO_EMPRESA='0013' THEN 'ADMINISTRACAO_INDIRETA'
  WHEN AT.CODIGO_EMPRESA='0014' THEN 'ADMINISTRACAO_INDIRETA'
  END AS AGRUPAMENTO_EMPRESA,'ALTERACOES_DIVERSAS' TIPO_VW_DADOS_SERVIDOR,
  'PROCEDURE_ACERTO_BASE: AJUSTE HIERAQUIA PARTE GESTOR' AS LOCAL_GESTOR,
  SYSDATE AS DT_SAIU_ARTE,
  AT.CODIGO_EMPRESA,
  AT.TIPO_CONTRATO,
  AT.CODIGO_CONTRATO,
  COD_UNIDADE1,
  COD_UNIDADE2,
  COD_UNIDADE3,
  COD_UNIDADE4,
  COD_UNIDADE5,
  COD_UNIDADE6,
  DESCRICAO_UNIDADE,
  CASE WHEN COD_UNIDADE1 IS NOT NULL THEN
SUBSTR(CODIGO_EMPRESA,3,2)||'.'||COD_UNIDADE1||'.'||COD_UNIDADE2||'.'||COD_UNIDADE3||'.'||COD_UNIDADE4||'.'||COD_UNIDADE5||'.'||COD_UNIDADE6 ELSE NULL END AS CODIGO_UNIDADE,
AT.CODIGO_EMPRESA_GESTOR,
AT.TIPO_CONTRATO_GESTOR,
AT.CONTRATO_GESTOR AS CODIGO_RESPONSAVEL
FROM  SUGESP_BI_1CONTRAT_INTIF_ARTE AT
WHERE AT.CODIGO_CONTRATO=''||C1.CONTRATO_ARTE||'' AND AT.CODIGO_EMPRESA=''||C1.EMPRESA_ARTE||''
AND AT.TIPO_CONTRATO=''||C1.TIPO_CONTRATO_ARTE||''
AND TRUNC(AT.DT_SAIU_ARTE)=TRUNC(SYSDATE)

)
LOOP
CONT3:=CONT3+1;
INSERT INTO PONTO_ELETRONICO.SMARH_INT_PONTO_DADOS_SERV_V10 (CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,COD_UNIDADE1,COD_UNIDADE2,COD_UNIDADE3,COD_UNIDADE4,COD_UNIDADE5,COD_UNIDADE6,DESCRICAO_UNIDADE,CODIGO_UNIDADE,CODIGO_EMPRESA_GESTOR,TIPO_CONTRATO_GESTOR,CODIGO_RESPONSAVEL,TIPO_VW_DADOS_SERVIDOR,DT_SAIU_ARTE,LOCAL_GESTOR,EMPRESA,AGRUPAMENTO_EMPRESA,CODIGO_INTEGRA_ARTE)
VALUES (C2.CODIGO_EMPRESA,C2.TIPO_CONTRATO,C2.CODIGO_CONTRATO,C2.COD_UNIDADE1,C2.COD_UNIDADE2,C2.COD_UNIDADE3,C2.COD_UNIDADE4,C2.COD_UNIDADE5,C2.COD_UNIDADE6,C2.DESCRICAO_UNIDADE,C2.CODIGO_UNIDADE,C2.CODIGO_EMPRESA_GESTOR,C2.TIPO_CONTRATO_GESTOR,C2.CODIGO_RESPONSAVEL,C2.TIPO_VW_DADOS_SERVIDOR,C2.DT_SAIU_ARTE,C2.LOCAL_GESTOR,C2.EMPRESA,C2.AGRUPAMENTO_EMPRESA,PONTO_ELETRONICO.SEQUENCE_INTEGRA_ARTE.NEXTVAL);
COMMIT;
UPDATE ACERTO_IFPONTO SET DATA_PROCESSADO=SYSDATE WHERE TIPO_AJUSTE=C1.CODIGO_UNIDADE_DIFERENTE||'-'||C1.GESTOR_DIFERENTE AND CODIGO_CONTRATO=C2.CODIGO_CONTRATO AND TIPO_CONTRATO=C2.TIPO_CONTRATO AND CODIGO_EMPRESA=C2.CODIGO_EMPRESA;
COMMIT;
END LOOP;
END;
END;
END IF;


IF C1.CHAVE_INTEGRACAO='ATIVO' AND  (C1.CODIGO_UNIDADE_DIFERENTE='CODIGO_UNIDADE_DIFERENTE' OR C1.GESTOR_DIFERENTE='GESTOR_DIFERENTE') AND C1.E_GESTOR='N'  AND C1.TIPO='HIERARQUIA POR PESSOA'  and (c1.DATA_DESLIGAMENTO_IFPONTO is null)THEN 
INSERT INTO ACERTO_IFPONTO (EMPRESA,AGRUPAMENTO_EMPRESA,CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,TIPO_AJUSTE,DATA_GEROU,TIPO_PESSOA) VALUES(C1.EMPRESA,C1.AGRUPAMENTO_EMPRESA,C1.EMPRESA_ARTE,C1.TIPO_CONTRATO_ARTE,C1.CONTRATO_ARTE,C1.CODIGO_UNIDADE_DIFERENTE||'-'||C1.GESTOR_DIFERENTE,C1.DATA_DADOS,C1.CHAVE_INTEGRACAO);
BEGIN
DECLARE 
CONT3 NUMBER;
BEGIN
FOR C2 IN (
SELECT CASE WHEN AT.CODIGO_EMPRESA='0001' THEN 'PBH' 
  WHEN AT.CODIGO_EMPRESA='0003' THEN 'SUDECAP'
  WHEN AT.CODIGO_EMPRESA='0013' THEN 'FMC'
  WHEN AT.CODIGO_EMPRESA='0014' THEN 'FMZB'
  END AS EMPRESA,
   CASE WHEN AT.CODIGO_EMPRESA='0001' THEN 'ADMINISTRACAO_DIRETE' 
  WHEN AT.CODIGO_EMPRESA='0003' THEN 'ADMINISTRACAO_INDIRETA'
  WHEN AT.CODIGO_EMPRESA='0013' THEN 'ADMINISTRACAO_INDIRETA'
  WHEN AT.CODIGO_EMPRESA='0014' THEN 'ADMINISTRACAO_INDIRETA'
  END AS AGRUPAMENTO_EMPRESA,'ALTERACOES_DIVERSAS' TIPO_VW_DADOS_SERVIDOR,
  'PROCEDURE_ACERTO_BASE: AJUSTE HIERARQUIA POR LOCAL' AS LOCAL_GESTOR,
  SYSDATE AS DT_SAIU_ARTE,
  AT.CODIGO_EMPRESA,
  AT.TIPO_CONTRATO,
  AT.CODIGO_CONTRATO,
  COD_UNIDADE1,
  COD_UNIDADE2,
  COD_UNIDADE3,
  COD_UNIDADE4,
  COD_UNIDADE5,
  COD_UNIDADE6,
  DESCRICAO_UNIDADE,
  CASE WHEN COD_UNIDADE1 IS NOT NULL THEN
SUBSTR(EMPRESA_HIERARQUIA,3,2)||'.'||COD_UNIDADE1||'.'||COD_UNIDADE2||'.'||COD_UNIDADE3||'.'||COD_UNIDADE4||'.'||COD_UNIDADE5||'.'||COD_UNIDADE6 ELSE NULL END AS CODIGO_UNIDADE,--TROCADO EM 10/1/2300SUBSTR(CODIGO_EMPRESA,3,2)
AT.CODIGO_EMPRESA_GESTOR,
AT.TIPO_CONTRATO_GESTOR,
AT.CONTRATO_GESTOR AS CODIGO_RESPONSAVEL
FROM  SUGESP_BI_1CONTRAT_INTIF_ARTE AT
WHERE AT.CODIGO_CONTRATO=''||C1.CONTRATO_ARTE||'' AND AT.CODIGO_EMPRESA=''||C1.EMPRESA_ARTE||''
AND AT.TIPO_CONTRATO=''||C1.TIPO_CONTRATO_ARTE||''
AND TRUNC(AT.DT_SAIU_ARTE)=TRUNC(SYSDATE)

)
LOOP
CONT3:=CONT3+1;
INSERT INTO PONTO_ELETRONICO.SMARH_INT_PONTO_DADOS_SERV_V10 (CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,COD_UNIDADE1,COD_UNIDADE2,COD_UNIDADE3,COD_UNIDADE4,COD_UNIDADE5,COD_UNIDADE6,DESCRICAO_UNIDADE,CODIGO_UNIDADE,CODIGO_EMPRESA_GESTOR,TIPO_CONTRATO_GESTOR,CODIGO_RESPONSAVEL,TIPO_VW_DADOS_SERVIDOR,DT_SAIU_ARTE,LOCAL_GESTOR,EMPRESA,AGRUPAMENTO_EMPRESA,CODIGO_INTEGRA_ARTE)
VALUES (C2.CODIGO_EMPRESA,C2.TIPO_CONTRATO,C2.CODIGO_CONTRATO,C2.COD_UNIDADE1,C2.COD_UNIDADE2,C2.COD_UNIDADE3,C2.COD_UNIDADE4,C2.COD_UNIDADE5,C2.COD_UNIDADE6,C2.DESCRICAO_UNIDADE,C2.CODIGO_UNIDADE,C2.CODIGO_EMPRESA_GESTOR,C2.TIPO_CONTRATO_GESTOR,C2.CODIGO_RESPONSAVEL,C2.TIPO_VW_DADOS_SERVIDOR,C2.DT_SAIU_ARTE,C2.LOCAL_GESTOR,C2.EMPRESA,C2.AGRUPAMENTO_EMPRESA,PONTO_ELETRONICO.SEQUENCE_INTEGRA_ARTE.NEXTVAL);
COMMIT;
UPDATE ACERTO_IFPONTO SET DATA_PROCESSADO=SYSDATE WHERE TIPO_AJUSTE=C1.CODIGO_UNIDADE_DIFERENTE||'-'||C1.GESTOR_DIFERENTE AND CODIGO_CONTRATO=C2.CODIGO_CONTRATO AND TIPO_CONTRATO=C2.TIPO_CONTRATO AND CODIGO_EMPRESA=C2.CODIGO_EMPRESA;
COMMIT;
END LOOP;
END;
END;
END IF;

IF C1.CHAVE_INTEGRACAO='ATIVO' AND C1.TIPO_USUARIO_DIFERENTE='TIPO_USUARIO_DIFERENTE' and (c1.DATA_DESLIGAMENTO_IFPONTO is null) THEN 
INSERT INTO ACERTO_IFPONTO (EMPRESA,AGRUPAMENTO_EMPRESA,CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,TIPO_AJUSTE,DATA_GEROU,TIPO_PESSOA) 
VALUES(C1.EMPRESA,C1.AGRUPAMENTO_EMPRESA,C1.EMPRESA_ARTE,C1.TIPO_CONTRATO_ARTE,C1.CONTRATO_ARTE,C1.TIPO_USUARIO_DIFERENTE,C1.DATA_DADOS,C1.CHAVE_INTEGRACAO);
COMMIT;
INSERT INTO PONTO_ELETRONICO.SMARH_INT_PONTO_DADOS_SERV_V10 (CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,COD_TIPO_PESSOA,TIPO_VW_DADOS_SERVIDOR,DT_SAIU_ARTE,LOCAL_GESTOR,EMPRESA,AGRUPAMENTO_EMPRESA,CODIGO_INTEGRA_ARTE)
VALUES(C1.EMPRESA_ARTE,C1.TIPO_CONTRATO_ARTE,C1.CONTRATO_ARTE,C1.TIPO_USUARIO_ARTE,'ALTERACOES_DIVERSAS',SYSDATE,'PROCEDURE_ACERTO_BASE: TIPO_USUARIO_DIFERENTE',CASE WHEN C1.EMPRESA_ARTE='0001' THEN 'PBH' 
  WHEN C1.EMPRESA_ARTE='0003' THEN 'SUDECAP'
  WHEN C1.EMPRESA_ARTE='0013' THEN 'FMC'
  WHEN C1.EMPRESA_ARTE='0014' THEN 'FMZB'
  END,CASE WHEN  C1.EMPRESA_ARTE='0001' THEN 'ADMINISTRACAO_DIRETE' 
  WHEN  C1.EMPRESA_ARTE='0003' THEN 'ADMINISTRACAO_INDIRETA'
  WHEN  C1.EMPRESA_ARTE='0013' THEN 'ADMINISTRACAO_INDIRETA'
  WHEN  C1.EMPRESA_ARTE='0014' THEN 'ADMINISTRACAO_INDIRETA'
  END
  ,PONTO_ELETRONICO.SEQUENCE_INTEGRA_ARTE.NEXTVAL 
  );COMMIT;
  UPDATE ACERTO_IFPONTO SET DATA_PROCESSADO=SYSDATE WHERE TIPO_AJUSTE=C1.TIPO_USUARIO_DIFERENTE AND CODIGO_CONTRATO=C1.CONTRATO_ARTE AND TIPO_CONTRATO=C1.TIPO_CONTRATO_ARTE AND CODIGO_EMPRESA=C1.EMPRESA_ARTE;

END IF;



IF C1.CHAVE_INTEGRACAO='ATIVO' AND C1.CARGO_DIFERENTE='CARGO_DIFERENTE'  and (c1.DATA_DESLIGAMENTO_IFPONTO is null) THEN 


  INSERT INTO ACERTO_IFPONTO (EMPRESA,AGRUPAMENTO_EMPRESA,CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,TIPO_AJUSTE,DATA_GEROU,TIPO_PESSOA) VALUES(C1.EMPRESA,C1.AGRUPAMENTO_EMPRESA,C1.EMPRESA_ARTE,C1.TIPO_CONTRATO_ARTE,C1.CONTRATO_ARTE,C1.CARGO_DIFERENTE,C1.DATA_DADOS,C1.CHAVE_INTEGRACAO);
BEGIN
DECLARE 
CONT3 NUMBER;
BEGIN
FOR C2 IN (
SELECT CASE WHEN AT.CODIGO_EMPRESA='0001' THEN 'PBH' 
  WHEN AT.CODIGO_EMPRESA='0003' THEN 'SUDECAP'
  WHEN AT.CODIGO_EMPRESA='0013' THEN 'FMC'
  WHEN AT.CODIGO_EMPRESA='0014' THEN 'FMZB'
  END AS EMPRESA,
   CASE WHEN AT.CODIGO_EMPRESA='0001' THEN 'ADMINISTRACAO_DIRETE' 
  WHEN AT.CODIGO_EMPRESA='0003' THEN 'ADMINISTRACAO_INDIRETA'
  WHEN AT.CODIGO_EMPRESA='0013' THEN 'ADMINISTRACAO_INDIRETA'
  WHEN AT.CODIGO_EMPRESA='0014' THEN 'ADMINISTRACAO_INDIRETA'
  END AS AGRUPAMENTO_EMPRESA,'ALTERACOES_DIVERSAS' TIPO_VW_DADOS_SERVIDOR,
  'PROCEDURE_ACERTO_BASE: CARGO_DIFERENTE' AS LOCAL_GESTOR,
  SYSDATE AS DT_SAIU_ARTE,
  AT.CODIGO_EMPRESA,
  AT.TIPO_CONTRATO,
  AT.CODIGO_CONTRATO,
 CASE WHEN (COD_CARGO_COMISS IS NULL OR COD_CARGO_COMISS=LPAD('0',15,0)) AND (AT.CODIGO_FUNCAO IS NULL OR AT.CODIGO_FUNCAO =LPAD('0',15,0)) THEN SUBSTR(AT.CODIGO_EMPRESA,3,2)||SUBSTR(AT.COD_CARGO_EFETIVO,11,5)
      WHEN (COD_CARGO_COMISS IS NOT  NULL OR COD_CARGO_COMISS!=LPAD('0',15,0)) AND (AT.CODIGO_FUNCAO IS NULL OR AT.CODIGO_FUNCAO =LPAD('0',15,0)) THEN SUBSTR(AT.CODIGO_EMPRESA,3,2)||SUBSTR(AT.COD_CARGO_COMISS,11,5)
      WHEN (COD_CARGO_COMISS IS NOT  NULL OR COD_CARGO_COMISS!=LPAD('0',15,0)) AND (AT.CODIGO_FUNCAO IS NOT NULL OR AT.CODIGO_FUNCAO !=LPAD('0',15,0)) THEN SUBSTR(AT.CODIGO_EMPRESA,3,2)|| 9 || SUBSTR(AT.CODIGO_FUNCAO ,12,4)
      WHEN  (COD_CARGO_COMISS IS NULL OR COD_CARGO_COMISS=LPAD('0',15,0)) AND (AT.CODIGO_FUNCAO IS NOT NULL OR AT.CODIGO_FUNCAO !=LPAD('0',15,0)) THEN SUBSTR(AT.CODIGO_EMPRESA,3,2)|| 9 || SUBSTR(AT.CODIGO_FUNCAO ,12,4) END AS CARGO_ARTE,
AT.CODIGO_EMPRESA_GESTOR,
AT.TIPO_CONTRATO_GESTOR,
AT.CONTRATO_GESTOR AS CODIGO_RESPONSAVEL
FROM  SUGESP_BI_1CONTRAT_INTIF_ARTE AT
WHERE AT.CODIGO_CONTRATO=''||C1.CONTRATO_ARTE||'' AND AT.CODIGO_EMPRESA=''||C1.EMPRESA_ARTE||''
AND AT.TIPO_CONTRATO=''||C1.TIPO_CONTRATO_ARTE||''
AND TRUNC(AT.DT_SAIU_ARTE)=TRUNC(SYSDATE)

)
LOOP
CONT3:=CONT3+1;
INSERT INTO PONTO_ELETRONICO.SMARH_INT_PONTO_DADOS_SERV_V10 (CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,CODIGO_CARGO_EFETIVO,CODIGO_EMPRESA_GESTOR,TIPO_CONTRATO_GESTOR,CODIGO_RESPONSAVEL,TIPO_VW_DADOS_SERVIDOR,DT_SAIU_ARTE,LOCAL_GESTOR,EMPRESA,AGRUPAMENTO_EMPRESA,CODIGO_INTEGRA_ARTE)
VALUES (C2.CODIGO_EMPRESA,C2.TIPO_CONTRATO,C2.CODIGO_CONTRATO,C2.CARGO_ARTE,C2.CODIGO_EMPRESA_GESTOR,C2.TIPO_CONTRATO_GESTOR,C2.CODIGO_RESPONSAVEL,C2.TIPO_VW_DADOS_SERVIDOR,C2.DT_SAIU_ARTE,C2.LOCAL_GESTOR,C2.EMPRESA,C2.AGRUPAMENTO_EMPRESA,PONTO_ELETRONICO.SEQUENCE_INTEGRA_ARTE.NEXTVAL );
COMMIT;
UPDATE ACERTO_IFPONTO SET DATA_PROCESSADO=SYSDATE WHERE TIPO_AJUSTE=C1.CODIGO_UNIDADE_DIFERENTE||'-'||C1.GESTOR_DIFERENTE AND CODIGO_CONTRATO=C2.CODIGO_CONTRATO AND TIPO_CONTRATO=C2.TIPO_CONTRATO AND CODIGO_EMPRESA=C2.CODIGO_EMPRESA;
COMMIT;
END LOOP;
END;
END;



END IF;


END LOOP;
END;
END;