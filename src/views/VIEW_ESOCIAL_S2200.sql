
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VIEW_ESOCIAL_S2200" ("TIPO", "CODIGO_EMPRESA", "VINCULO", "CODIGO_CONTRATO", "TIPO_CONTRATO", "CPF", "CODIGO_PESSOA", "NOME", "DESCRICAO_ERRO") AS 
  SELECT X."TIPO",X."CODIGO_EMPRESA",X."VINCULO", X."CODIGO_CONTRATO",X."TIPO_CONTRATO",X."CPF",X."CODIGO_PESSOA",X."NOME",X."DESCRICAO_ERRO" FROM (SELECT
'SERVIDOR' AS TIPO,
    c.codigo_empresa ,c.codigo as codigo_contrato,c.tipo_contrato,P.cpf ,p.codigo as codigo_pessoa,P.NOME_ACESSO AS NOME,
    C.VINCULO,
       case when end.codigo_pessoa is null then 'PESSOA SE ENDERECO'
    WHEN ( end.tipo_logradouro IS NULL
          OR end.endereco IS NULL
          OR end.numero IS NULL
          OR end.bairro IS NULL
          OR end.cep IS NULL
          OR end.uf IS NULL
          OR end.pais IS NULL) THEN 'CAMPOS INCOMPLETOS NO CASDATRO DE ENDERECO'
          WHEN ( P.raca_cor IS NULL OR P.incapacidade_labor IS NULL OR P.CPF IS NULL) THEN 'RACA/COR E/OU INCAPACIDADE LABORATIVA E/OU CPF NÃO INFORMADOS' 

          END AS DESCRICAO_ERRO
FROM
    arterh.rhpess_contrato c
    LEFT OUTER JOIN ARTERH.rhparm_sit_func SF
    ON c.situacao_funcional=SF.CODIGO
    LEFT OUTER JOIN ARTERH.RHPESS_PESSOA P 
    ON P.CODIGO=C.CODIGO_PESSOA
    and p.codigo_empresa=c.codigo_empresa
    LEFT OUTER JOIN ARTERH.RHPESS_ENDERECO_P END
    ON END.CODIGO_EMPRESA=P.CODIGO_EMPRESA 
    AND END.CODIGO_PESSOA= P.CODIGO


WHERE
    c.ano_mes_referencia = (
        SELECT
            MAX(aux.ano_mes_referencia)
        FROM
            arterh.rhpess_contrato aux
        WHERE
                aux.codigo_empresa = c.codigo_empresa
            AND aux.tipo_contrato = c.tipo_contrato
            AND aux.codigo = c.codigo
    )
    AND SF.CODIGO<>'6008'
    AND C.CODIGO_EMPRESA='0001'
    AND c.data_rescisao IS NULL
    AND (END.CODIGO_PESSOA IS NULL OR END.TIPO_LOGRADOURO IS NULL OR END.ENDERECO IS NULL OR END.NUMERO IS NULL OR END.BAIRRO IS NULL OR END.CEP IS NULL OR END.UF IS NULL OR END.PAIS IS NULL OR P.RACA_COR IS NULL OR  P.incapacidade_labor IS NULL OR P.CPF IS NULL)
    AND C.TIPO_CONTRATO IN ('0001','0015','0007')



    UNION ALL
     SELECT X.* FROM (SELECT  'DEPENDENTE'    AS tipo,
    c.codigo_empresa,
    C.CODIGO            AS cidigo_contrato,
    C.TIPO_CONTRATO            AS tipo_contrato,
    pdep.cpf ,
    pdep.codigo      AS codigo_pessoa,
    pdep.nome_acesso AS nome,
    C.VINCULO,
    case when ( pdep.incapacidade_labor IS NULL) THEN ' INCAPACIDADE LABORATIVA NÃO INFORAMAD'
    WHEN pDEP.CPF IS NULL THEN 'CPF NÃO INFORMADO' 

          END AS DESCRICAO_ERRO
FROM ARTERH.RHPESS_CONTRATO C
INNER JOIN ARTERH.rhpess_dependencia DEP
ON DEP.CODIGO_EMPRESA=C.CODIGO_EMPRESA
AND DEP.tipo_contrato=c.tipo_contrato
and dep.codigo_contrato=c.codigo
 INNER JOIN arterh.rhpess_pessoa      pdep 
 ON pdep.codigo =dep.codigo_pessoa
AND pdep.codigo_empresa =dep.codigo_empresa
INNER JOIN arterh.rhparm_sit_func    sf ON c.situacao_funcional = sf.codigo
WHERE
        c.ano_mes_referencia = (
            SELECT
                MAX(aux.ano_mes_referencia)
            FROM
                arterh.rhpess_contrato aux
            WHERE
                    aux.codigo = c.codigo
                AND aux.tipo_contrato = c.tipo_contrato
                AND aux.codigo_empresa = c.codigo_empresa
        )

    AND sf.codigo <> '6008'
    AND c.codigo_empresa = '0001'
    AND C.TIPO_CONTRATO IN ('0001','0015','0007')
    AND c.data_rescisao IS NULL
    and (dep.DATA_FIM IS NULL  OR DEP.DATA_FIM >= TO_DATE('20/11/2021','DD/MM/YYYY'))
AND dep.e_dependente='S'

AND dep.cod_classe_depend IN ('0001','0002','0011')
AND ( pdep.incapacidade_labor IS NULL OR pDEP.CPF IS NULL )
)X
     )X
     ORDER BY X.TIPO,X.NOME