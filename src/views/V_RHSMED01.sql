
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."V_RHSMED01" ("CODIGO", "NOME", "ENDERECO", "NUMERO", "COMPLEMENTO", "BAIRRO", "NOME_MUNICIPIO", "UF", "CEP", "FAX", "ENDER_ELETRONICO", "NOME_PAI", "NOME_MAE", "DATA_NASCIMENTO", "FATOR_RH", "RACA_COR", "DESCR_COR", "SEXO", "DESCR_SEXO", "ESTADO_CIVIL", "DESCR_EST_CIVIL", "NATURALIDADE", "NACIONALIDADE", "DESCR_NACION", "ANO_CHEGADA", "DATA_NATURALIZACAO", "IDENTIDADE", "ORGAO_EXPEDIDOR", "LOCAL_EXPEDICAO", "DATA_EXPEDICAO", "CPF", "TITULO_ELEITOR", "SECAO_TIT_ELEITOR", "ZONA_TIT_ELEITOR", "PIS_PASEP", "INSCRICAO_CONSELHO", "CART_TRABALHO", "SERIE_CART_TRAB", "DATA_CART_TRAB", "HABILITACAO", "DATA_HABILITACAO", "CATEGORIA", "CERT_RESERVISTA", "TELEFONE", "PESSOA", "COD_CARGO_EFETIVO", "DESC_CARGO", "COD_CARGO_COMISS", "CODIGO_FUNCAO", "DESCRICAO", "COD_UNIDADE1", "COD_UNIDADE2", "COD_UNIDADE3", "COD_UNIDADE4", "COD_UNIDADE5", "COD_UNIDADE6", "DESC_UNIDADE", "PUBLIC_DOM", "DATA_POSSE", "DATA_ADMISSAO", "DATA_EFETIVO_EXERC", "DATA_RESCISAO", "CLASSIFICACAO_CAND", "HOMOLOGACAO_CONCURSO", "DATA_EDITAL", "NUMERO_EDITAL", "DOIS_BM", "VINCULO", "DESC_VINCULO", "DESC_JORNADA_TRAB", "JORNADA_DIARIA", "HORAS_SEMANA_RAIS", "SITUACAO_FUNCIONAL", "DESC_SIT_FUNC", "COD_DEFICIENCIA", "NATURALIZADO", "DESC_CRG_COMISS", "HORA_SEMANAL", "NOME_SOCIAL") AS 
  SELECT DISTINCT 
	rhpess_contrato.codigo, rhpess_contrato.nome,
    RHTABS_TP_LOGRAD.DESCRICAO|| ' ' ||
    rhpess_endereco_p.endereco, rhpess_endereco_p.numero,
    rhpess_endereco_p.complemento, rhpess_endereco_p.bairro,
    rhpess_endereco_p.c_livre_descr01 nome_municipio,
    rhpess_endereco_p.uf, rhpess_endereco_p.cep,
    rhpess_endereco_p.fax, 
    rhpess_contrato.e_mail,
    rhpess_pessoa.c_livre_descr11 nome_pai,
    rhpess_pessoa.c_livre_descr12 nome_mae,
    rhpess_pessoa.data_nascimento, rhpess_pessoa.fator_rh,
    rhpess_pessoa.raca_cor,
    rhtabs_raca_cor.descricao descr_cor, rhpess_pessoa.sexo,
    rhtabs_sexo.descricao descr_sexo,
    rhpess_pessoa.estado_civil,
    rhtabs_est_civil.descricao descr_est_civil,
    RHTABS_MUNICIPIO.CODIGO_IBGE NATURALIDADE,
    rhtabs_nacionalid.CODIGO_PAIS_RECEITA NACIONALIDADE ,
    upper(rhtabs_pais.DESCRICAO) descr_nacion,
    rhpess_pessoa.ano_chegada,
    rhpess_pessoa.data_naturalizacao, rhpess_pessoa.identidade,
    rhpess_pessoa.orgao_expedidor,
    rhpess_pessoa.local_expedicao,
    rhpess_pessoa.data_expedicao, rhpess_pessoa.cpf,
    rhpess_pessoa.titulo_eleitor,
    rhpess_pessoa.secao_tit_eleitor,
    rhpess_pessoa.zona_tit_eleitor, rhpess_pessoa.pis_pasep,
    rhpess_pessoa.inscricao_conselho,
    rhpess_pessoa.cart_trabalho, rhpess_pessoa.serie_cart_trab,
    rhpess_pessoa.data_cart_trab, rhpess_pessoa.habilitacao,
    rhpess_pessoa.data_habilitacao, rhpess_pessoa.categoria,
    rhpess_pessoa.cert_reservista, rhpess_pessoa.telefone,
    rhpess_pessoa.codigo pessoa,
    rhpess_contrato.cod_cargo_efetivo,
    rhplcs_cargo.descricao desc_cargo,
    rhpess_contrato.cod_cargo_comiss,
    rhpess_contrato.codigo_funcao, rhplcs_funcao.descricao,
    rhpess_contrato.cod_unidade1, rhpess_contrato.cod_unidade2,
    rhpess_contrato.cod_unidade3, rhpess_contrato.cod_unidade4,
    rhpess_contrato.cod_unidade5, rhpess_contrato.cod_unidade6,
    rhorga_unidade.descricao desc_unidade,
    rhpess_contrato.c_livre_data31 public_dom,
    rhpess_contrato.data_posse, rhpess_contrato.data_admissao,
    rhpess_contrato.data_efetivo_exerc,
    rhpess_contrato.data_rescisao,
    rhpess_contrato.classificacao_cand,
    rhpess_contrato.c_livre_data32 homologacao_concurso,
    rhpess_contrato.c_livre_data30 data_edital,
    rhpess_contrato.numero_edital,
    rhpess_contrato.c_livre_opcao48 dois_bm,
    rhpess_contrato.vinculo,
    rhtabs_vinculo_emp.descricao desc_vinculo,
    rhpont_escala.descricao desc_jornada_trab,
    rhpont_escala.jornada_diaria,
    TO_CHAR (rhpont_escala.horas_semana_rais,'99.99' ) horas_semana_rais,	
    rhpess_contrato.situacao_funcional,
    rhparm_sit_func.descricao desc_sit_func,
    rhpess_pessoa.cod_deficiencia,
    rhpess_pessoa.naturalizado,
	upper(crg_comiss.descricao) desc_crg_comiss,
	TO_CHAR ((RHPONT_TP_JORNADA.C_LIVRE_SELEC01 / 60),'99.99' ) HORA_SEMANAL,
	RHPESS_PESSOA.NOME_SOCIAL
   FROM 
	rhpess_contrato,
    rhpess_pessoa,
    rhpess_endereco_p,
    RHTABS_TP_LOGRAD,
    rhorga_unidade,
    rhparm_sit_func,
    rhplcs_funcao,
    rhplcs_cargo,
	rhplcs_cargo crg_comiss,
    rhpont_escala,
	RHPONT_TP_JORNADA,
    rhtabs_uf,
    rhtabs_nacionalid,
    rhtabs_sexo,
    rhtabs_est_civil,
    rhtabs_raca_cor,
    rhtabs_vinculo_emp,
    rhtabs_municipio,
    rhtabs_pais 
   WHERE
       (rhpess_contrato.codigo_empresa      = '0001')
   AND (rhpess_contrato.tipo_contrato       = '0001') 
   AND ( RHPESS_ENDERECO_P.TIPO_LOGRADOURO  = RHTABS_TP_LOGRAD.CODIGO ) 
   AND (rhpess_contrato.codigo_pessoa       = rhpess_pessoa.codigo)
   AND (rhpess_contrato.codigo_empresa      = rhpess_pessoa.codigo_empresa  )
   
   AND (rhpess_contrato.codigo_empresa      = rhpess_endereco_p.codigo_empresa )
   AND (rhpess_contrato.codigo_pessoa       = rhpess_endereco_p.codigo_pessoa   )
   
   AND (rhpess_contrato.cod_unidade1 = rhorga_unidade.cod_unidade1  )
   AND (rhpess_contrato.cod_unidade2 = rhorga_unidade.cod_unidade2  )
   AND (rhpess_contrato.cod_unidade3 = rhorga_unidade.cod_unidade3  )
   AND (rhpess_contrato.cod_unidade4 = rhorga_unidade.cod_unidade4  )
   AND (rhpess_contrato.cod_unidade5 = rhorga_unidade.cod_unidade5  )
   AND (rhpess_contrato.cod_unidade6 = rhorga_unidade.cod_unidade6  )
   AND (rhpess_contrato.codigo_empresa = rhorga_unidade.codigo_empresa )
   
   AND (rhpess_contrato.situacao_funcional = rhparm_sit_func.codigo  )
 
   AND (rhpess_contrato.codigo_funcao      = rhplcs_funcao.codigo(+))
   AND (rhpess_contrato.codigo_empresa     = rhplcs_funcao.codigo_empresa(+))
   
   AND (rhpess_contrato.cod_cargo_efetivo  = rhplcs_cargo.codigo)
   AND (rhpess_contrato.codigo_empresa     = rhplcs_cargo.codigo_empresa)
	
   AND (rhpess_contrato.cod_cargo_comiss  =  crg_comiss.codigo(+))
   AND (rhpess_contrato.codigo_empresa    = crg_comiss.codigo_empresa(+))
	
   AND (rhpess_contrato.vinculo       = rhtabs_vinculo_emp.codigo(+))
   AND (rhpess_contrato.codigo_escala = rhpont_escala.codigo(+))
  
   AND (rhpess_contrato.codigo_empresa = rhpont_escala.Codigo_Empresa(+) )     
   
   AND RHPONT_ESCALA.TIPO_JORNADA = RHPONT_TP_JORNADA.CODIGO
	
   AND (rhpess_pessoa.uf_naturalidade = rhtabs_uf.codigo(+))
   
   AND (rhpess_pessoa.nacionalidade = rhtabs_nacionalid.codigo(+))
   and rhtabs_nacionalid.CODIGO_PAIS_RECEITA = rhtabs_pais.CODIGO_PAIS_RECEITA(+) 
   and rhpess_pessoa.cod_municipio = rhtabs_municipio.codigo(+) 
   
   AND (rhpess_pessoa.sexo             = rhtabs_sexo.codigo(+))
   AND (rhpess_pessoa.estado_civil     = rhtabs_est_civil.codigo(+))
   AND (rhpess_pessoa.raca_cor         = rhtabs_raca_cor.codigo(+))

   AND (rhpess_contrato.ano_mes_referencia =
       (SELECT MAX (a.ano_mes_referencia)
        FROM rhpess_contrato a
        WHERE 
	        a.codigo = rhpess_contrato.codigo
        AND a.codigo_empresa = rhpess_contrato.codigo_empresa
        AND a.tipo_contrato = rhpess_contrato.tipo_contrato
        AND a.ano_mes_referencia <= SYSDATE))