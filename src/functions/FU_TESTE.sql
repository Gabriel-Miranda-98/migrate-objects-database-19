
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."FU_TESTE" RETURN clob
AS
teste clob;

PROCEDURE SS AS
BEGIN 
 execute immediate'Alter Session Set nls_language=''BRAZILIAN PORTUGUESE''';
 execute immediate'Alter Session Set NLS_TERRITORY = ''BRAZIL''';

END;

BEGIN 

SS();

FOR CI IN (
SELECT  JSON_OBJECT('lista' VALUE JSON_ARRAYAGG(
JSON_OBJECT(
'consignatariaDTO' VALUE 
JSON_OBJECT(
'razaoSocial' VALUE X.razao_social,
'sigla' VALUE X.nome_fantasia,
'cnpjCpf' VALUE X.cgc_cpf,
'tipoPessoaConsignataria' VALUE 'PJU',
'naturezaJuridica' VALUE 'Banco'
),
'email' value'fernando.katsumi@gmail.com',
'endereco' VALUE JSON_OBJECT(
'logradouro' VALUE X.LOGRADOURO,
'numero' VALUE X.NUMERo ,
'complemento' value X.complemento,
'cep'value X.cep,
'bairro' value X.bairro,
'cidade' value X.CIDADE,
'uf' value X.UF
),
'listaTelefone' value JSON_ARRAY(
JSON_OBJECT(
'numero' VALUE TO_NUMBER(nvl(X.telefone,999999999)),
'ddd' value 31

)
),
'numeroContrato' value '',
'dataInicioVigencia' value null,
'numeroPrazoVigencia' value null,
'dadosBancariosDTO' value json_object(
'numeroBancoDTO' value json_object (
'sigla' value to_char(rownum)
),

'numeroAgencia' value 9999,
'numeroConta ' value 9999
),
'listaServicoDTO'value  JSON_QUERY(dados_verbas, '$'),
'listaRepresentanteLegal' value JSON_ARRAY(
JSON_OBJECT('nome' value x.nome,
'cpf' value x.cpf,
'tipoRepresentanteLegal' value json_object('sigla' value'PRI' ),
'email' value'fernando.katsumi@gmail.com',
'telefones' value JSON_ARRAY(
JSON_OBJECT(
'numero' VALUE TO_NUMBER(nvl(X.telefone,999999999)),
'ddd' value 31

)
),
'endereco' VALUE JSON_OBJECT(
'logradouro' VALUE X.LOGRADOURO,
'numero' VALUE X.NUMERo ,
'complemento' value X.complemento,
'cep'value X.cep,
'bairro' value X.bairro,
'cidade' value X.CIDADE,
'uf' value X.UF
)
)



)

)
RETURNING CLOB)
RETURNING CLOB) AS ARQ FROM (SELECT 
F.razao_social,
F.nome_fantasia,
F.cgc_cpf,
tp.descricao|| ' '|| eN.descricao AS LOGRADOURO,
    trim(TO_CHAR(EN.NUMERo)) AS NUMERO,
    en.complemento,
    trim(to_char(en.cep)) AS CEP,
    trim(en.bairro) AS BAIRRO,
    trim(mp.descricao) AS CIDADE,
    trim(to_char(uf.codigo_rais))AS UF,
    P.NOME_ACESSO AS NOME,
    P.CPF AS CPF,
    EN.TELEFONE,
    json_arrayagg(
json_object(
'nome' value vb.descricao,
'codigoServicoConsignante' VALUE TO_CHAR(VB.CODIGO),
'tipoConsignacao' value json_object('idTipoConsigConsignante' value c.dado_destino)


)


) as dados_verbas

FROM ARTERH.rhorga_fornecedor F
LEFT OUTER JOIN ARTERH.RHORGA_EMPRESA EM
ON EM.CODIGO ='0001'
LEFT OUTER JOIN ARTERH.RHORGA_ENDERECO EN 
ON EN.CODIGO=em.codigo_endereco
LEFT OUTER JOIN arterh.rhtabs_tp_lograd      tp ON tp.codigo = eN.tipo_logradouro
LEFT OUTER JOIN ARTERH.rhtabs_municipio MP 
ON MP.CODIGO=en.municipio
LEFT OUTER JOIN ARTERH.RHTABS_UF UF 
ON UF.CODIGO=en.uf
LEFT OUTER JOIN ARTERH.RHPESS_PESSOA P 
ON P.CODIGO_EMPrESA='0001'
AND P.CODIGO='000006670125674'
LEFT OUTER JOIN ARTERH.RHORGA_FORN_VERBA FB
ON FB.CODIGO_FORNECEDOR=F.CODIGO
LEFT OUTER JOIN ARTERH.rhparm_verba_empr VBE
ON VBE.CODIGO_EMPRESA=EM.CODIGO 
AND FB.CODIGO_VERBA=VBE.CODIGO_VERBA
LEFT OUTER JOIN ARTERH.RHPARM_VERBA VB 
ON VBE.CODIGO_VERBA=VB.CODIGO
LEFT OUTER JOIN ARTERH.RHINTE_ED_IT_CONV C 
ON C.CODIGO_CONVERSAO='AQC5'
AND C.DADO_ORIGEM=VB.CODIGO
WHERE F.CODIGO IN (LPAD('5142',15,0))
AND  F.codigo_categ_forn='0001'
AND VBE.CODIGO_VERBA IS NOT NULL
GROUP BY 
F.razao_social,
F.nome_fantasia,
F.cgc_cpf,
tp.descricao
    || ' '
    || eN.descricao ,
    trim(TO_CHAR(EN.NUMERo)) ,
    en.complemento,
    trim(to_char(en.cep)) ,
    trim(en.bairro) ,
    trim(mp.descricao) ,
    trim(to_char(uf.codigo_rais)),
    P.NOME_ACESSO ,
    P.CPF,
     EN.TELEFONE
    )x
)
LOOP
teste:=CI.ARQ;

END LOOP;
return teste;
end;