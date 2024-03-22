
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."SMARH_AJUSTE_BENEFIC_DIRF" (QTDE_REGISTROS in NUMBER) is

vCONTADOR NUMBER;
vCONTADOR_TP_RELAC_NULO NUMBER;
vTIPO_RELACIONAMENTO CHAR(4);
begin
     vCONTADOR := 0;
     vCONTADOR_TP_RELAC_NULO := 0;
     for c1 in (
select distinct CODIGO_EMPRESA, COD_CONTR_TITULAR, CODIGO_PESSOA, TIPO_CONTR_TITULAR, CODIGO_BENEFICIO
 from RHBENF_MOV_BENEFIC M
  where M.CODIGO_EMPRESA = '0001'
    and M.TP_RELACIONAMENTO IS NULL
    and CODIGO_BENEFICIO in ('000000000002099','000000000002100','000000000002101','000000000002102','000000000002650')
    and rownum <= QTDE_REGISTROS
    and M.ANO_MES_REFERENCIA between TO_DATE('01/12/2015','DD/MM/YYYY') and TO_DATE('30/11/2016','DD/MM/YYYY')
    and M.CODIGO_PESSOA <> (
                                                    
                                                    
                          select A.CODIGO_PESSOA from RHPESS_CONTRATO A 
                           where A.CODIGO_EMPRESA = M.CODIGO_EMPRESA 
                             and A.TIPO_CONTRATO = M.TIPO_CONTR_TITULAR 
                             and A.CODIGO = M.COD_CONTR_TITULAR 
                             and A.ANO_MES_REFERENCIA = (select MAX(ANO_MES_REFERENCIA) from RHPESS_CONTRATO B
                                                       where B.CODIGO_EMPRESA = A.CODIGO_EMPRESA
                                                         and B.TIPO_CONTRATO = A.TIPO_CONTRATO
                                                         and B.CODIGO = A.CODIGO
                                                         and B.ANO_MES_REFERENCIA <= sysdate
                                                      )
                                                    
                             )
     
     )
     loop
         vCONTADOR := vCONTADOR + 1;
         
         vTIPO_RELACIONAMENTO := NULL;
         begin
                   select max(TP_RELACIONAMENTO) into vTIPO_RELACIONAMENTO
                     from RHBENF_MOV_BENEFIC MB
                    where MB.CODIGO_EMPRESA = c1.CODIGO_EMPRESA
                      and MB.TP_RELACIONAMENTO IS NOT NULL
                      and MB.COD_CONTR_TITULAR = c1.COD_CONTR_TITULAR
                      and MB.CODIGO_PESSOA = c1.CODIGO_PESSOA
                      and MB.ANO_MES_REFERENCIA between TO_DATE('01/12/2015','DD/MM/YYYY') and TO_DATE('30/11/2016','DD/MM/YYYY')  
                      and MB.TIPO_CONTR_TITULAR = c1.TIPO_CONTR_TITULAR
                      and MB.CODIGO_VERBA = '24I1'                   
                      and MB.CODIGO_BENEFICIO in ('000000000002099','000000000002100','000000000002101','000000000002102','000000000002650'); 
         exception
         when others then
              vTIPO_RELACIONAMENTO := NULL;
         end;
         
         IF vTIPO_RELACIONAMENTO IS NULL THEN
             begin
                       select distinct TP_RELACIONAMENTO 
                         into vTIPO_RELACIONAMENTO 
                         from RHPESS_RL_PESS_PES 
                        where RHPESS_RL_PESS_PES.COD_EMPRESA = c1.CODIGO_EMPRESA
                          and RHPESS_RL_PESS_PES.COD_PESSOA_RELAC = c1.CODIGO_PESSOA
                          and RHPESS_RL_PESS_PES.TP_RELACIONAMENTO not in ('0007','0008','0010')
                          and RHPESS_RL_PESS_PES.COD_PESSOA = (
                        
                        
                          select A.CODIGO_PESSOA from RHPESS_CONTRATO A 
                           where A.CODIGO_EMPRESA = c1.CODIGO_EMPRESA 
                             and A.TIPO_CONTRATO = c1.TIPO_CONTR_TITULAR 
                             and A.CODIGO = c1.COD_CONTR_TITULAR 
                             and A.ANO_MES_REFERENCIA = (select MAX(ANO_MES_REFERENCIA) from RHPESS_CONTRATO B
                                                       where B.CODIGO_EMPRESA = A.CODIGO_EMPRESA
                                                         and B.TIPO_CONTRATO = A.TIPO_CONTRATO
                                                         and B.CODIGO = A.CODIGO
                                                         and B.ANO_MES_REFERENCIA <= sysdate
                                                      )
                        
                        );
             exception
             when others then
                  vTIPO_RELACIONAMENTO := NULL;
             end;
         END IF;
                  
         IF vTIPO_RELACIONAMENTO IS NOT NULL THEN
         
           update RHBENF_MOV_BENEFIC MB
              set MB.TP_RELACIONAMENTO = vTIPO_RELACIONAMENTO      
            where MB.CODIGO_EMPRESA = c1.CODIGO_EMPRESA
              and MB.TP_RELACIONAMENTO IS NULL
              and MB.COD_CONTR_TITULAR = c1.COD_CONTR_TITULAR
              and MB.CODIGO_PESSOA = c1.CODIGO_PESSOA
              and MB.CODIGO_BENEFICIO = c1.CODIGO_BENEFICIO
              and MB.ANO_MES_REFERENCIA between TO_DATE('01/12/2015','DD/MM/YYYY') and TO_DATE('30/11/2016','DD/MM/YYYY')  
              and MB.TIPO_CONTR_TITULAR = c1.TIPO_CONTR_TITULAR;
              
              commit;              
              
         ELSE
             vCONTADOR_TP_RELAC_NULO := vCONTADOR_TP_RELAC_NULO + 1;      
         END IF;         

     end loop;
     
     dbms_output.put_line('CONTADOR = ' || vCONTADOR);
     dbms_output.put_line('vCONTADOR_TP_RELAC_NULO = ' || vCONTADOR_TP_RELAC_NULO);

end SMARH_AJUSTE_BENEFIC_DIRF;
 