
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."FU_PS_OBTER_TP_RELACIONAMENTO" (PCODIGO_EMPRESA CHAR, LISTA_MAPEA_TIPO_RELACI LISTA, PCPF_TITULAR CHAR, PCPF_DEPENDENTE CHAR) RETURN CHAR IS

NAO_EXISTE_TP_RELACIONAMENTO EXCEPTION;
MAIS_DE_UM_TP_RELACIONAMENTO EXCEPTION;
ERRO_AO_TENTAR_RECUPERAR_DADO EXCEPTION;
ERRO_GENERICO EXCEPTION;

RET_ENCONTRADO CONSTANT NUMBER := 0;
RET_NAO_ENCONTRADO CONSTANT NUMBER := 97;
RET_MAIS_DE_UM_REGISTRO CONSTANT NUMBER := 98;
RET_ERRO CONSTANT NUMBER := 99;

vTP_RELACIONAMENTO CHAR(4);
BEGIN
   --dbms_output.put_line('PCODIGO_EMPRESA: ' || PCODIGO_EMPRESA);
   --dbms_output.put_line('PCPF_TITULAR: ' || PCPF_TITULAR);
   --dbms_output.put_line('PCPF_DEPENDENTE: ' || PCPF_DEPENDENTE);
   BEGIN
     begin
        vTP_RELACIONAMENTO := NULL;
        select TP_RELACIONAMENTO
          into vTP_RELACIONAMENTO
          from RHPESS_RL_PESS_PES PP, RHPESS_PESSOA PTIT, RHPESS_PESSOA PDEP
         where PP.COD_EMPRESA = PCODIGO_EMPRESA
           and PP.COD_EMPRESA = PTIT.CODIGO_EMPRESA
           and PP.COD_PESSOA = PTIT.CODIGO
           and PP.COD_EMPRESA = PDEP.CODIGO_EMPRESA
           and PP.COD_PESSOA_RELAC = PDEP.CODIGO
           and PTIT.CPF = PCPF_TITULAR
           and PDEP.CPF = PCPF_DEPENDENTE
           and PP.TP_RELACIONAMENTO member (LISTA_MAPEA_TIPO_RELACI)
           AND PTIT.DT_TERMINO IS NULL
           AND PDEP.DT_TERMINO IS NULL;
     exception
     when NO_DATA_FOUND then
          --dbms_output.put_line('Passo 1');
          RAISE NAO_EXISTE_TP_RELACIONAMENTO;
     when TOO_MANY_ROWS then

          begin
          select TP_RELACIONAMENTO
            into vTP_RELACIONAMENTO
            from RHPESS_RL_PESS_PES PP, RHPESS_PESSOA PTIT, RHPESS_PESSOA PDEP
           where PP.COD_EMPRESA = PCODIGO_EMPRESA
             and PP.COD_EMPRESA = PTIT.CODIGO_EMPRESA
             and PP.COD_PESSOA = PTIT.CODIGO
             and PP.COD_EMPRESA = PDEP.CODIGO_EMPRESA
             and PP.COD_PESSOA_RELAC = PDEP.CODIGO
             and PTIT.CPF = PCPF_TITULAR
             and PDEP.CPF = PCPF_DEPENDENTE
             and PP.TP_RELACIONAMENTO member (LISTA_MAPEA_TIPO_RELACI)
             AND PTIT.DT_TERMINO IS NULL
             AND PDEP.DT_TERMINO IS NULL
             group by TP_RELACIONAMENTO;
           exception
           when TOO_MANY_ROWS then
                --dbms_output.put_line('Passo 2');
                begin
                    select TP_RELACIONAMENTO
                      into vTP_RELACIONAMENTO
                      from RHPESS_RL_PESS_PES PP, RHPESS_PESSOA PTIT, RHPESS_PESSOA PDEP
                     where PP.COD_EMPRESA = PCODIGO_EMPRESA
                       and PP.COD_EMPRESA = PTIT.CODIGO_EMPRESA
                       and PP.COD_PESSOA = PTIT.CODIGO
                       and PP.COD_EMPRESA = PDEP.CODIGO_EMPRESA
                       and PP.COD_PESSOA_RELAC = PDEP.CODIGO
                       and PTIT.CPF = PCPF_TITULAR
                       and PDEP.CPF = PCPF_DEPENDENTE
                       and PP.TP_RELACIONAMENTO member (LISTA_MAPEA_TIPO_RELACI)
                       AND PTIT.DT_TERMINO IS NULL AND PDEP.DT_TERMINO IS NULL

                       --and PP.COD_PESSOA_RELAC = C2.CODIGO_PESSOA_DEPENDENTE
                       group by TP_RELACIONAMENTO;
                 exception
                 when others then
                      --dbms_output.put_line('Passo 3');
                      RAISE MAIS_DE_UM_TP_RELACIONAMENTO;
                 end;
           when others then
                --dbms_output.put_line('Passo 5');
                RAISE ERRO_AO_TENTAR_RECUPERAR_DADO;
           end;
     when others then
          --dbms_output.put_line('Passo 6');
          RAISE ERRO_GENERICO;
     end;

     EXCEPTION
      WHEN NAO_EXISTE_TP_RELACIONAMENTO THEN
           --raise_application_error (-20002,'Tipo de Relacionamento nao encontrado para os dados informados.');
           --RAISE;
           vTP_RELACIONAMENTO := RET_NAO_ENCONTRADO;
      WHEN MAIS_DE_UM_TP_RELACIONAMENTO THEN
           --raise_application_error (-20003,'Foram encontrados mais de um tipo de relacionamento para os dados informados. Verifique e regularize o relacionamento entre o titular e o depedente.');
           --RAISE;
           vTP_RELACIONAMENTO := RET_MAIS_DE_UM_REGISTRO;
      WHEN ERRO_AO_TENTAR_RECUPERAR_DADO THEN
           --raise_application_error (-20004,'Ocorreu um erro ao tentar recuperar o Tipo de Relacionamento. Entre em contato com o suporte.');
           --RAISE;
           vTP_RELACIONAMENTO := RET_ERRO;
      WHEN ERRO_GENERICO THEN
           vTP_RELACIONAMENTO := RET_ERRO;
           --RAISE;
      WHEN OTHERS THEN
           --raise_application_error (-20001,'Ocorreu um erro GENERICO ao tentar recuperar o Tipo de Relacionamento. Entre em contato com o suporte.');
           --RAISE;
           vTP_RELACIONAMENTO := RET_ERRO;
     END;

     return vTP_RELACIONAMENTO;

END;