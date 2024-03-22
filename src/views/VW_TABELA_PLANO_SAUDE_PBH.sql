
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_TABELA_PLANO_SAUDE_PBH" ("PLANO", "FAIXA_ETARIA", "VALOR") AS 
  select PLANO.VALCHR as PLANO, FAIXA_ETARIA.VALNUM AS FAIXA_ETARIA, VALOR.VALNUM AS VALOR
  from
(
select VPNUM.*
  from RHPESS_TABELAS VP, RHPESS_VALCHR VPNUM
 where VP.CODIGO_TABELA = VPNUM.CODIGO_TABELA
   and VPNUM.CODIGO_TABELA = '000000000008001'
   and VPNUM.NRO_COLUNA = 1
   and VPNUM.ANO_MES_REF = (select max(ANO_MES_REF)
                              from RHPESS_VALCHR VPNUM_AUX
                             where VPNUM_AUX.CODIGO_TABELA = VPNUM.CODIGO_TABELA
                               and VPNUM_AUX.NRO_COLUNA = VPNUM.NRO_COLUNA
                               and VPNUM.ANO_MES_REF <= sysdate
                           ) order by NRO_LINHA
) PLANO,
(
select VPNUM.*
  from RHPESS_TABELAS VP, RHPESS_VALNUM VPNUM
 where VP.CODIGO_TABELA = VPNUM.CODIGO_TABELA
   and VPNUM.CODIGO_TABELA = '000000000008001'
   and VPNUM.NRO_COLUNA = 2
   and VPNUM.ANO_MES_REF = (select max(ANO_MES_REF)
                              from RHPESS_VALNUM VPNUM_AUX
                             where VPNUM_AUX.CODIGO_TABELA = VPNUM.CODIGO_TABELA
                               and VPNUM_AUX.NRO_COLUNA = VPNUM.NRO_COLUNA
                               and VPNUM.ANO_MES_REF <= sysdate
                           ) order by NRO_LINHA
) FAIXA_ETARIA,
(
select VPNUM.*
  from RHPESS_TABELAS VP, RHPESS_VALNUM VPNUM
 where VP.CODIGO_TABELA = VPNUM.CODIGO_TABELA
   and VPNUM.CODIGO_TABELA = '000000000008001'
   and VPNUM.NRO_COLUNA = 3
   and VPNUM.ANO_MES_REF = (select max(ANO_MES_REF)
                              from RHPESS_VALNUM VPNUM_AUX
                             where VPNUM_AUX.CODIGO_TABELA = VPNUM.CODIGO_TABELA
                               and VPNUM_AUX.NRO_COLUNA = VPNUM.NRO_COLUNA
                               and VPNUM.ANO_MES_REF <= sysdate
                           ) order by NRO_LINHA
) VALOR
where FAIXA_ETARIA.CODIGO_TABELA = VALOR.CODIGO_TABELA
  and FAIXA_ETARIA.NRO_LINHA = VALOR.NRO_LINHA
  and FAIXA_ETARIA.CODIGO_TABELA = PLANO.CODIGO_TABELA
  and FAIXA_ETARIA.NRO_LINHA = PLANO.NRO_LINHA
 