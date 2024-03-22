
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."SMARH_AJUSTE_MOV_BENF_DIRF" AS

vCONTADOR NUMBER;
vCONTADOR_PESSOAS NUMBER;
vNOME VARCHAR2(100);
vNOME_ANTERIOR VARCHAR2(100);
vDATA_NASCIMENTO DATE;
vDATA_NASCIMENTO_ANTERIOR DATE;
vMESMA_PESSOA BOOLEAN;
vTEXTO_PESSOA VARCHAR2(4000);
vCODIGO_PESSOA_ATUALIZACAO CHAR(15);
begin

vCONTADOR := 0;
for c0 in(

select GRUPO_DIRF, CODIGO_CONTRATO, CODIGO_FORNECEDOR, CPF_RELAC, count(1) from RHDIRF_CONSOL_2011
 where GRUPO_DIRF in ('16A1','16A2','16A3','16A4','16A5','16A6')
   and CODIGO_EMPRESA = '0001'
   and TIPO_REGISTRO = 'DTPSE'
   and ANO_REFERENCIA = TO_DATE('01/01/2016','DD/MM/YYYY')
   and CNPJ_DECLARANTE = '18715383000140'
   and CPF_RELAC IS NOT NULL
   group by GRUPO_DIRF, CODIGO_CONTRATO, CODIGO_FORNECEDOR, CPF_RELAC
   having count(1) > 1

)
loop
    vCONTADOR := vCONTADOR + 1;
    dbms_output.put_line('CPF_RELAC = ' || c0.CPF_RELAC);

    vMESMA_PESSOA := true;
    vNOME := NULL;
    vNOME_ANTERIOR := NULL;
    vDATA_NASCIMENTO := NULL;
    vDATA_NASCIMENTO_ANTERIOR := NULL;
    vTEXTO_PESSOA := '';
    vCONTADOR_PESSOAS := 0;
    for c1 in(
    select CODIGO,  UPPER(translate(TRIM(NOME),'Ã¢Ã Ã£Ã¡Ã?Ã¿Ã¿Ã¿Ã©ÃªÃ¿Ã¿Ã­Ã?Ã³Ã´ÃµÃ¿Ã¿Ã¿Ã¼ÃºÃ¿Ã¿Ã¿Ã§','AAAAAAAAEEEEIIOOOOOOUUUUCC')) AS NOME, DATA_NASCIMENTO, CPF
      from RHPESS_PESSOA
     where CODIGO_EMPRESA = '0001'
       and TRIM(CPF) = TRIM(c0.CPF_RELAC)
       order by CODIGO
    )
    loop
        vCONTADOR_PESSOAS := vCONTADOR_PESSOAS + 1;

        IF vCONTADOR_PESSOAS = 1 THEN
           vCODIGO_PESSOA_ATUALIZACAO := c1.CODIGO;
        END IF;

        vNOME := c1.NOME;
        vDATA_NASCIMENTO := c1.DATA_NASCIMENTO;

        vTEXTO_PESSOA := vTEXTO_PESSOA || 'CPF' || c1.CPF ||' CODIGO = ' || c1.CODIGO || ' NOME = ' || c1.NOME || ' DATA NASCIMENTO = ' || c1.DATA_NASCIMENTO || CHR(13);

        IF ((vNOME_ANTERIOR IS NOT NULL and vNOME <> vNOME_ANTERIOR) OR
           (vDATA_NASCIMENTO_ANTERIOR IS NOT NULL and vDATA_NASCIMENTO <> vDATA_NASCIMENTO_ANTERIOR)) THEN
           vMESMA_PESSOA := false;

        END IF;

        vNOME_ANTERIOR := vNOME;
        vDATA_NASCIMENTO_ANTERIOR := vDATA_NASCIMENTO;

    end loop;

    IF NOT vMESMA_PESSOA THEN
       dbms_output.put_line(vTEXTO_PESSOA);
    ELSE


    for c2 in(
    select CODIGO,  UPPER(translate(TRIM(NOME),'Ã¢Ã Ã£Ã¡Ã?Ã¿Ã¿Ã¿Ã©ÃªÃ¿Ã¿Ã­Ã?Ã³Ã´ÃµÃ¿Ã¿Ã¿Ã¼ÃºÃ¿Ã¿Ã¿Ã§','AAAAAAAAEEEEIIOOOOOOUUUUCC')) AS NOME, DATA_NASCIMENTO, CPF
      from RHPESS_PESSOA
     where CODIGO_EMPRESA = '0001'
       and CODIGO <> vCODIGO_PESSOA_ATUALIZACAO
       and TRIM(CPF) = TRIM(c0.CPF_RELAC)
       order by CODIGO
    )
    loop

       BEGIN

        update RHBENF_MOV_BENEFIC M
           set CODIGO_PESSOA = vCODIGO_PESSOA_ATUALIZACAO
         where M.CODIGO_EMPRESA = '0001'
           and M.TIPO_CONTR_TITULAR = '0001'
           and M.COD_CONTR_TITULAR = c0.CODIGO_CONTRATO
           and M.MES_INCIDENCIA between 1 and 12
           and M.CODIGO_PESSOA = c2.CODIGO
           and M.ANO_MES_REFERENCIA between TO_DATE('01/12/2015','DD/MM/YYYY') and TO_DATE('01/11/2016','DD/MM/YYYY')
           and exists(
               select * from RHPESS_PESSOA P1, RHPESS_PESSOA P2
                where P1.CODIGO_EMPRESA = P2.CODIGO_EMPRESA
                  and P1.CODIGO <> P2.CODIGO
                  and P1.CPF = P2.CPF
                  and P1.CODIGO_EMPRESA = M.CODIGO_EMPRESA
                  and P1.CODIGO = vCODIGO_PESSOA_ATUALIZACAO
                  and P2.CODIGO = c2.CODIGO
           );

        update RHBENF_CONCESSOES C
           set C.CODIGO_BENEFIC = vCODIGO_PESSOA_ATUALIZACAO
         where C.CODIGO_EMPRESA = '0001'
           and C.CODIGO_BENEFIC = c2.CODIGO
           and exists(
               select * from RHPESS_PESSOA P1, RHPESS_PESSOA P2
                where P1.CODIGO_EMPRESA = P2.CODIGO_EMPRESA
                  and P1.CODIGO <> P2.CODIGO
                  and P1.CPF = P2.CPF
                  and P1.CODIGO_EMPRESA = C.CODIGO_EMPRESA
                  and P1.CODIGO = vCODIGO_PESSOA_ATUALIZACAO
                  and P2.CODIGO = c2.CODIGO
           );

           commit;
       EXCEPTION
       WHEN OTHERS THEN
            dbms_output.put_line('!!!ERRO!!!');
            rollback;
       END;

    end loop;

    END IF;
end loop;
    dbms_output.put_line('vCONTADOR = ' || vCONTADOR);
end;

 