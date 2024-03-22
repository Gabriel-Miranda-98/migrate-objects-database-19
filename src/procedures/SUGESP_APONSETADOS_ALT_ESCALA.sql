
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."SUGESP_APONSETADOS_ALT_ESCALA" (PGLB_MES_ANO_SISTEMA IN VARCHAR2, PGLB_USUARIO IN VARCHAR2) AS
--KELLYSSON 01/04/19
BEGIN

  DECLARE
    vCONTADOR NUMBER;
    vGLB_MES_ANO_SISTEMA VARCHAR2(10);
    vGLB_USUARIO VARCHAR2(40);

  BEGIN -- 1º BEGIN
    dbms_output.enable(NULL);
    vCONTADOR :=0;
    vGLB_MES_ANO_SISTEMA := PGLB_MES_ANO_SISTEMA;
    vGLB_USUARIO := PGLB_USUARIO;

    FOR C1 IN
(

select
case when contrato_0001.dt_ult_escala  is null then trunc(sysdate) else trunc(contrato_0001.dt_ult_escala) end as data_escala,
contrato_0001.* from
arterh.rhpess_contrato contrato_0001

where contrato_0001.codigo_empresa = '0001'
and contrato_0001.tipo_contrato = '0001'

--INICIO para OFICIAL
and contrato_0001.situacao_funcional in ('1002','1700','1701')
AND NOT EXISTS ( SELECT 1 FROM arterh.RHPESS_CONTR_MEST
WHERE RHPESS_CONTR_MEST.CODIGO_EMPRESA = '1700'
AND RHPESS_CONTR_MEST.CODIGO_CONTRATO = contrato_0001.codigo
AND RHPESS_CONTR_MEST.TIPO_CONTRATO = contrato_0001.tipo_contrato)
and contrato_0001.ano_mes_referencia = (select max(contrato.ano_mes_referencia) from arterh.rhpess_contrato contrato
where contrato.codigo_empresa = contrato_0001.codigo_empresa
and contrato.tipo_contrato = contrato_0001.tipo_contrato
and contrato.codigo = contrato_0001.codigo
and TRUNC(contrato.ano_mes_referencia) < = vGLB_MES_ANO_SISTEMA)
--FIM para OFICIAL

/*--INICIO para testes
and contrato_0001.codigo in ('000000000280171','000000000326775','000000000348477', '000000001048625', '000000001182364')
and contrato_0001.ano_mes_referencia = (select max(contrato.ano_mes_referencia) from rhpess_contrato contrato
                                                                    where contrato.codigo_empresa = contrato_0001.codigo_empresa
                                                                    and contrato.tipo_contrato = contrato_0001.tipo_contrato
                                                                    and contrato.codigo = contrato_0001.codigo
                                                                    and contrato.ano_mes_referencia <= sysdate)
--FIM para testes
*/
)--FIM DO FOR
    LOOP
      vCONTADOR :=vCONTADOR+1;
  --    dbms_output.put_line(vCONTADOR || '-'|| c1.codigo ||'-'|| c1.ano_mes_referencia||'-' || c1.codigo_escala ||'-'|| c1.data_escala||'-'|| c1.dt_ult_escala );

insert into arterh.rhpont_alt_escala (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DT_INICIO_TROCA, DT_FIM_TROCA, LOGIN_USUARIO, DT_ULT_ALTER_USUA, ALTER_DEFINITIVA, COD_ESCALA, texto_associado)
values ('0001','0001',c1.codigo, trunc(SYSDATE), trunc(SYSDATE), vGLB_USUARIO, sysdate, 'S', C1.CODIGO_ESCALA, 'via processo AP01 - backup ultima escala do servidor no contrato');
COMMIT;


    END LOOP; --FIM LOOP 1
  END;


END;
