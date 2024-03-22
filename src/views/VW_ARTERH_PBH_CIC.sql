
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_ARTERH_PBH_CIC" ("EMPRESA", "BM", "NOME", "SIT_FUNC", "CARGO_EFETIVO", "NIVEL_CARGO_EFETIV", "CARGO_COMISS", "DATA_CARGO_COMISS", "FUNCAO_PUBLICA", "DATA_FUNCAO", "ADMISSAO", "QUINQ_ANT_EMEND", "Q_AP_EMEND_AT_9_2010", "Q_AP_EC_AP_9_2010", "NASCIMENTO", "GRAU_INST", "ESPECIL_NA_PESSOA", "ESPECIL_NO_CONTRATO", "CATEGORIA_PROFISS", "JORNADA_DIARIA", "VINCULO", "DATA_INI_AFAST", "MOTIVO_DEMISSAO", "DATA_DESLIG", "MOTIVO_RESCISAO", "SIGLA_SECRET", "SECRETARIA", "SIGLA_SUB_SECRET", "SUB_SECRETARIA", "SIGLA_LOT_NIVEL3", "LOT_NIVEL3", "SIGLA_LOT_NIVEL4", "LOT_NIVEL4", "SIGLA_LOT_NIVEL5", "LOT_NIVEL5", "SIGLA_LOT", "LOTACAO", "MES_REF", "VERBA", "VALOR_VERBA") AS 
  select
rhpess_contrato.codigo_empresa as empresa,
substr(rhpess_contrato.codigo,9,6)||'-'||substr(rhpess_contrato.codigo,15,1) as bm,
rhpess_contrato.nome,
rhpess_contrato.situacao_funcional||' - '||rhparm_sit_func.descricao as sit_func,
substr(rhpess_contrato.cod_cargo_efetivo,12,4)||' - '||cargo_efetivo.descricao as cargo_efetivo,
rhpess_contrato.nivel_cargo_efetiv,
decode(rhpess_contrato.cod_cargo_comiss,'000000000000000','-',substr(rhpess_contrato.cod_cargo_comiss,12,4)||' - '||cargo_comiss.descricao) as cargo_comiss,
to_char(rhpess_contrato.dt_ult_cargo_com,'dd/mm/yyyy') data_cargo_comiss,
substr(rhpess_contrato.codigo_funcao,12,4)||' - '||funcao.descricao as funcao_publica,
to_char(rhpess_contrato.dt_ult_funcao,'dd/mm/yyyy') as data_funcao,
to_char(rhpess_contrato.data_admissao,'dd/mm/yyyy') as admissao,
rhpess_contrato.c_livre_valor18 as quinq_ant_emend,
rhpess_contrato.c_livre_selec07 as q_ap_emend_at_9_2010,
rhpess_contrato.c_livre_selec04 as q_ap_ec_ap_9_2010,
to_char(rhpess_pessoa.data_nascimento,'dd/mm/yyyy') nascimento,
rhpess_pessoa.grau_instrucao||' - '||rhtabs_grau_inst.descricao grau_inst,
substr(rhpess_pessoa.espec_formacao,12,4)||' - '||rhplcs_especialid.descricao especil_na_pessoa,
substr(rhpess_contrato.cod_especialidade,12,4)||' - '||espec_contrato.descricao especil_no_contrato,
rhtabs_cat_profis.descricao categoria_profiss,
rhpess_contrato.codigo_escala||' - '||rhpont_escala.descricao as jornada_diaria,
rhtabs_vinculo_emp.codigo||' - '||rhtabs_vinculo_emp.descricao as vinculo,
to_char(rhpess_contrato.data_inic_afast,'dd/mm/yyyy') as data_ini_afast,
rhpess_contrato.motivo_demissao||' - '||rhparm_motivo_dem.descricao as motivo_demissao,
to_char(rhpess_contrato.data_rescisao,'dd/mm/yyyy') as data_deslig,
rhpess_contrato.causa_rescisao||' - '||rhparm_causa_resc.descricao as motivo_rescisao,
secretaria.abreviacao as sigla_secret,
substr(rhpess_contrato.cod_unidade1,5,2)||'.'||'00'||'.'||'00'||'.'||'00'||'.'||'00'||'.'||'000'||' - '||nvl(secretaria.texto_associado, secretaria.descricao) as secretaria,
sub_secret.abreviacao as sigla_sub_secret,
substr(rhpess_contrato.cod_unidade1,5,2)||'.'||substr(rhpess_contrato.cod_unidade2,5,2)||'.'||'00'||'.'||'00'||'.'||'00'||'.'||'000'||' - '||nvl(sub_secret.texto_associado, sub_secret.descricao) as sub_secretaria,
lot_nivel3.abreviacao as sigla_lot_nivel3,
substr(rhpess_contrato.cod_unidade1,5,2)||'.'||substr(rhpess_contrato.cod_unidade2,5,2)||'.'||substr(rhpess_contrato.cod_unidade3,5,2)||'.'||'00'||'.'||'00'||'.'||'000'||' - '||nvl(lot_nivel3.texto_associado, lot_nivel3.descricao) as lot_nivel3,
lot_nivel4.abreviacao as sigla_lot_nivel4,
substr(rhpess_contrato.cod_unidade1,5,2)||'.'||substr(rhpess_contrato.cod_unidade2,5,2)||'.'||substr(rhpess_contrato.cod_unidade3,5,2)||'.'||substr(rhpess_contrato.cod_unidade4,5,2)||'.'||'00'||'.'||'000'||' - '||nvl(lot_nivel4.texto_associado, lot_nivel4.descricao) as lot_nivel4,
lot_nivel5.abreviacao as sigla_lot_nivel5,
substr(rhpess_contrato.cod_unidade1,5,2)||'.'||substr(rhpess_contrato.cod_unidade2,5,2)||'.'||substr(rhpess_contrato.cod_unidade3,5,2)||'.'||substr(rhpess_contrato.cod_unidade4,5,2)||'.'||substr(rhpess_contrato.cod_unidade5,5,2)||'.'||'000'||' - '||nvl(lot_nivel5.texto_associado, lot_nivel5.descricao) as lot_nivel5,
rhorga_unidade.abreviacao as sigla_lot,
substr(rhpess_contrato.cod_unidade1,5,2)||'.'||substr(rhpess_contrato.cod_unidade2,5,2)||'.'||substr(rhpess_contrato.cod_unidade3,5,2)||'.'||substr(rhpess_contrato.cod_unidade4,5,2)||'.'||substr(rhpess_contrato.cod_unidade5,5,2)||'.'||substr(rhpess_contrato.cod_unidade6,4,3)||' - '||nvl(rhorga_unidade.texto_associado,rhorga_unidade.descricao) as lotacao,
to_char(rhmovi_movimento.ano_mes_referencia,'mm/yyyy') as mes_ref,
rhmovi_movimento.codigo_verba verba,
rhmovi_movimento.valor_verba
from
ARTERH.rhpess_contrato rhpess_contrato,
ARTERH.rhpess_pessoa rhpess_pessoa,
ARTERH.rhorga_unidade rhorga_unidade,
ARTERH.rhorga_unidade secretaria,
ARTERH.rhorga_unidade sub_secret,
ARTERH.rhorga_unidade lot_nivel3,
ARTERH.rhorga_unidade lot_nivel4,
ARTERH.rhorga_unidade lot_nivel5,
ARTERH.rhplcs_cargo cargo_efetivo,
ARTERH.rhplcs_cargo cargo_comiss,
ARTERH.rhplcs_funcao funcao,
ARTERH.rhpont_escala rhpont_escala,
ARTERH.rhtabs_vinculo_emp rhtabs_vinculo_emp,
ARTERH.rhparm_sit_func rhparm_sit_func,
ARTERH.rhtabs_grau_inst rhtabs_grau_inst,
ARTERH.rhplcs_especialid rhplcs_especialid,
ARTERH.rhplcs_especialid espec_contrato,
ARTERH.rhtabs_cat_profis,
ARTERH.rhparm_causa_resc rhparm_causa_resc,
ARTERH.rhparm_motivo_dem rhparm_motivo_dem,
ARTERH.rhmovi_movimento rhmovi_movimento,
ARTERH.rhparm_verba rhparm_verba

where
(rhpess_contrato.codigo_pessoa = rhpess_pessoa.codigo) and
(rhpess_contrato.codigo_empresa = rhpess_pessoa.codigo_empresa) and
(rhpess_contrato.codigo_empresa = secretaria.codigo_empresa) and
(rhpess_contrato.cod_unidade1 = secretaria.cod_unidade1(+)) and
(secretaria.cod_unidade2(+) = '000000') and
(secretaria.cod_unidade3(+) = '000000') and
(secretaria.cod_unidade4(+) = '000000') and
(secretaria.cod_unidade5(+) = '000000') and
(secretaria.cod_unidade6(+) = '000000') and
(rhpess_contrato.codigo_empresa = sub_secret.codigo_empresa(+)) and
(rhpess_contrato.cod_unidade1 = sub_secret.cod_unidade1(+)) and
(rhpess_contrato.cod_unidade2 = sub_secret.cod_unidade2(+)) and
(sub_secret.cod_unidade3(+) = '000000') and
(sub_secret.cod_unidade4(+) = '000000') and
(sub_secret.cod_unidade5(+) = '000000') and
(sub_secret.cod_unidade6(+) = '000000') and
(rhpess_contrato.codigo_empresa = lot_nivel3.codigo_empresa(+)) and
(rhpess_contrato.cod_unidade1 = lot_nivel3.cod_unidade1(+)) and
(rhpess_contrato.cod_unidade2 = lot_nivel3.cod_unidade2(+)) and
(rhpess_contrato.cod_unidade3 = lot_nivel3.cod_unidade3(+)) and
(lot_nivel3.cod_unidade4(+) = '000000') and
(lot_nivel3.cod_unidade5(+) = '000000') and
(lot_nivel3.cod_unidade6(+) = '000000') and
(rhpess_contrato.codigo_empresa = lot_nivel4.codigo_empresa(+)) and
(rhpess_contrato.cod_unidade1 = lot_nivel4.cod_unidade1(+)) and
(rhpess_contrato.cod_unidade2 = lot_nivel4.cod_unidade2(+)) and
(rhpess_contrato.cod_unidade3 = lot_nivel4.cod_unidade3(+)) and
(rhpess_contrato.cod_unidade4 = lot_nivel4.cod_unidade4(+)) and
(lot_nivel4.cod_unidade5(+) = '000000') and
(lot_nivel4.cod_unidade6(+) = '000000') and
(rhpess_contrato.codigo_empresa = lot_nivel5.codigo_empresa(+)) and
(rhpess_contrato.cod_unidade1 = lot_nivel5.cod_unidade1(+)) and
(rhpess_contrato.cod_unidade2 = lot_nivel5.cod_unidade2(+)) and
(rhpess_contrato.cod_unidade3 = lot_nivel5.cod_unidade3(+)) and
(rhpess_contrato.cod_unidade4 = lot_nivel5.cod_unidade4(+)) and
(rhpess_contrato.cod_unidade5 = lot_nivel5.cod_unidade5(+)) and
(lot_nivel5.cod_unidade6(+) = '000000') and
(rhpess_contrato.codigo_empresa = rhorga_unidade.codigo_empresa) and
(rhpess_contrato.cod_unidade1 = rhorga_unidade.cod_unidade1) and
(rhpess_contrato.cod_unidade2 = rhorga_unidade.cod_unidade2) and
(rhpess_contrato.cod_unidade3 = rhorga_unidade.cod_unidade3) and
(rhpess_contrato.cod_unidade4 = rhorga_unidade.cod_unidade4) and
(rhpess_contrato.cod_unidade5 = rhorga_unidade.cod_unidade5) and
(rhpess_contrato.cod_unidade6 = rhorga_unidade.cod_unidade6) and
(rhpess_contrato.cod_cargo_efetivo = cargo_efetivo.codigo(+) and rhpess_contrato.codigo_empresa = cargo_efetivo.codigo_empresa(+)) and
(rhpess_contrato.cod_cargo_comiss = cargo_comiss.codigo(+) and rhpess_contrato.codigo_empresa = cargo_comiss.codigo_empresa(+)) and
(rhpess_contrato.codigo_funcao = funcao.codigo(+) and rhpess_contrato.codigo_empresa = funcao.codigo_empresa(+)) and
(rhpess_contrato.vinculo = rhtabs_vinculo_emp.codigo(+)) and
(rhpess_contrato.codigo_escala = rhpont_escala.codigo and rhpess_contrato.codigo_empresa = rhpont_escala.codigo_empresa) and
(rhpess_contrato.situacao_funcional = rhparm_sit_func.codigo) and
(rhpess_pessoa.grau_instrucao = rhtabs_grau_inst.codigo(+)) and
(rhpess_pessoa.espec_formacao = rhplcs_especialid.codigo (+) and rhpess_pessoa.codigo_empresa = rhplcs_especialid.codigo_empresa (+) ) and  
(rhpess_contrato.cod_especialidade = espec_contrato.codigo (+) and rhpess_contrato.codigo_empresa = espec_contrato.codigo_empresa (+) ) and
(rhpess_contrato.causa_rescisao = rhparm_causa_resc.codigo(+)) and
(rhpess_contrato.motivo_demissao = rhparm_motivo_dem.codigo(+)) and
(rhpess_contrato.codigo_empresa = rhparm_motivo_dem.codigo_empresa(+)) and
(rhpess_contrato.categ_profissional = rhtabs_cat_profis.codigo(+)) and
(rhpess_contrato.codigo_empresa = rhtabs_cat_profis.codigo_empresa(+)) and

rhpess_contrato.codigo_empresa in('0001', '0098', '0015','0021','0032')
and rhpess_contrato.tipo_contrato = '0001'
and rhpess_contrato.ano_mes_referencia =
(select max(arterh_contrato.ano_mes_referencia)
from
rhpess_contrato arterh_contrato
where
rhpess_contrato.codigo_empresa = arterh_contrato.codigo_empresa
and rhpess_contrato.tipo_contrato = arterh_contrato.tipo_contrato
and rhpess_contrato.codigo = arterh_contrato.codigo
and arterh_contrato.ano_mes_referencia <= sysdate
and arterh_contrato.ano_mes_referencia >= to_date('1900/01/01','yyyy/mm/dd'))
and rhpess_contrato.codigo_empresa = rhmovi_movimento.codigo_empresa
and rhpess_contrato.codigo = rhmovi_movimento.codigo_contrato
and rhpess_contrato.tipo_contrato = rhmovi_movimento.tipo_contrato
and rhmovi_movimento.codigo_verba = rhparm_verba.codigo
and (rhmovi_movimento.codigo_verba between '1000' and '1ZZZ' 
or rhmovi_movimento.codigo_verba in ('3502','3504','3510','3511','3512','3513','3514','3505','3508','3515','3516', 
'351A','351B','351C','351D','351E','351F','361A','361B','361C','361D','361E',
'361F','3716','3916'))
and valor_verba > 0
and rhmovi_movimento.tipo_movimento = 'ME'
and rhmovi_movimento.fase = '0'
and rhmovi_movimento.modo_operacao = 'R'