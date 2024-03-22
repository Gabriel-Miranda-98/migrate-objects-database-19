
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."SUGESP_APONS_ALT_ESC_SIT_FUNC" (PGLB_MES_ANO_SISTEMA IN VARCHAR2, PGLB_USUARIO IN VARCHAR2) AS
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

select * from arterh.rhpont_alt_escala where login_usuario = vGLB_USUARIO and trunc(DT_ULT_ALTER_USUA) = trunc(sysdate) and codigo_empresa = '0001'

--FIM para testes

)--FIM DO FOR
    LOOP
      vCONTADOR :=vCONTADOR+1;
  --    dbms_output.put_line(vCONTADOR || '-'|| c1.codigo_contrato ||'-'|| c1.DT_INICIO_TROCA ||'-'|| c1.DT_FIM_TROCA ||'-'|| c1.LOGIN_USUARIO  ||'-'|| c1.DT_ULT_ALTER_USUA ||'-'|| c1.COD_ESCALA ||'-'|| c1.texto_associado );

UPDATE arterh.RHPESS_CONTRATO SET codigo_escala = '' ||c1.cod_escala || '', dt_ult_escala = SYSDATE where CODigo_empresa = '0001' and tipo_contrato = '0001' and  codigo = ''|| C1.CODIGO_contrato ||'' AND ANO_MES_REFERENCIA = (select max(ANO_MES_REFERENCIA) from arterh.RHPESS_CONTRATO AUX where RHPESS_CONTRATO.CODIGO_EMPRESA=AUX.CODIGO_EMPRESA and RHPESS_CONTRATO.CODIGO =AUX.CODIGO AND RHPESS_CONTRATO.TIPO_CONTRATO = AUX.TIPO_CONTRATO);


--dbms_output.put_line('1-UPDATE RHPESS_CONTRATO SET codigo_escala = ''' ||c1.cod_escala || ''', dt_ult_escala = SYSDATE where CODigo_empresa = ''0001'' and tipo_contrato = ''0001'' and  codigo = '''|| C1.CODIGO_contrato ||''' AND ANO_MES_REFERENCIA = (select max(ANO_MES_REFERENCIA) from RHPESS_CONTRATO AUX where RHPESS_CONTRATO.CODIGO_EMPRESA=AUX.CODIGO_EMPRESA and RHPESS_CONTRATO.CODIGO =AUX.CODIGO AND RHPESS_CONTRATO.TIPO_CONTRATO = AUX.TIPO_CONTRATO );');
--dbms_output.put_line('2-insert into RHCGED_ALT_SIT_FUN () values ();');


    END LOOP; --FIM LOOP 1
  END;


END ;
