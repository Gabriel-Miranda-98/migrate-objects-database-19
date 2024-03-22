
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."SITUACAO_FUNCIONAL" ("ANO_MES_REFERENCIA", "CODIGO_PLANO", "CODIGO_EMPRESA", "MATRICULA", "DIGITO", "NOME", "CPF", "PIS_PASEP", "CODIGO_CARGO", "DATA_ADMISSAO_POSSE", "SITUACAO_FUNCIONAL", "TIPO_OCORRENCIA", "DATA_INICIO", "DATA_FIM", "DIAS", "CID", "DATA_ULTIMA_ALTERACAO") AS 
  SELECT DISTINCT P."ANO_MES_REFERENCIA",P."CODIGO_PLANO",P."CODIGO_EMPRESA",P."MATRICULA",P."DIGITO",P."NOME",P."CPF",P."PIS_PASEP",P."CODIGO_CARGO",P."DATA_ADMISSAO_POSSE",P."SITUACAO_FUNCIONAL",P."TIPO_OCORRENCIA",P."DATA_INICIO",P."DATA_FIM",P."DIAS",P."CID",P."DATA_ULTIMA_ALTERACAO" 
  FROM ARTERH.UTILIT_SIT_FUNC P
 WHERE P.DATA_ULTIMA_ALTERACAO = (
    SELECT MAX(PP.DATA_ULTIMA_ALTERACAO) 
      FROM ARTERH.UTILIT_SIT_FUNC PP
     WHERE P.CODIGO_EMPRESA = PP.CODIGO_EMPRESA
       AND P.MATRICULA = PP.MATRICULA
       AND P.DIGITO = PP.DIGITO
       AND P.DATA_INICIO = PP.DATA_INICIO
       AND P.SITUACAO_FUNCIONAL = PP.SITUACAO_FUNCIONAL
    )