
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."F_RELAT_LACON" (P_CODIGO_EMPRESA VARCHAR2, P_CODIGO_PESSOA VARCHAR2)
RETURN T_LACON IS

 TYPE tList IS REF CURSOR;
 sList tList;
 vList ARTERH.TABLE_LACON := ARTERH.TABLE_LACON(null,null, null, null, null, null, null, null,null, null,  null, null, null, null);
 ttList ARTERH.T_LACON := ARTERH.T_LACON ();
 linha number;
 data_inicio_vigencia date;

BEGIN
--dbms_output.enable(null);
linha :=0;
data_inicio_vigencia:=null;

  BEGIN
  OPEN sList FOR 

  select  rownum nmr_linha , x.* from ( 
  select RHMEDI_FICHA_MED.CODIGO_EMPRESA, RHMEDI_FICHA_MED.CODIGO_PESSOA, RHMEDI_FICHA_MED.TIPO_CONTRATO, RHMEDI_FICHA_MED.CODIGO_CONTRATO , RHMEDI_FICHA_MED.natureza_exame || ' - '|| RHMEDI_NATUREZA_EX.descricao as procedimento,
  RHMEDI_RL_FICH_PRO.codigo_proc_med || ' - '|| RHMEDI_PROC_MED.DESCRICAO as CONDUTA, RHMEDI_FICHA_MED.DT_REG_OCORRENCIA,RHMEDI_FICHA_MED.OCORRENCIA , RHMEDI_FICHA_MED.DATA_INI_AFAST,
  RHMEDI_FICHA_MED.DATA_FIM_AFAST, RHMEDI_FICHA_MED.DATA_FIM_AFAST - RHMEDI_FICHA_MED.DATA_INI_AFAST + 1 as DIAS_LACON, null as DATA_INICIO_VIGENCI ,null as DATA_FIM_VIGENCIA
  from ARTERH.RHMEDI_FICHA_MED
  left join ARTERH.RHMEDI_NATUREZA_EX
  on RHMEDI_FICHA_MED.natureza_exame = RHMEDI_NATUREZA_EX.codigo
  and RHMEDI_FICHA_MED.CODIGO_EMPRESA = RHMEDI_NATUREZA_EX.CODIGO_EMPRESA
  LEFT  JOIN ARTERH.RHMEDI_RL_FICH_PRO
  ON
  RHMEDI_FICHA_MED.CODIGO_EMPRESA = RHMEDI_RL_FICH_PRO.CODIGO_EMPRESA AND
  RHMEDI_FICHA_MED.CODIGO_PESSOA = RHMEDI_RL_FICH_PRO.CODIGO_PESSOA AND
  RHMEDI_FICHA_MED.DT_REG_OCORRENCIA = RHMEDI_RL_FICH_PRO.DT_REG_OCORRENCIA AND
  RHMEDI_FICHA_MED.OCORRENCIA = RHMEDI_RL_FICH_PRO.OCORRENCIA
  left join ARTERH.RHMEDI_PROC_MED
  on RHMEDI_RL_FICH_PRO.codigo_proc_med = RHMEDI_PROC_MED.CODIGO_PROC_MED
  where 
  RHMEDI_FICHA_MED.natureza_exame = '0107'
  AND RHMEDI_RL_FICH_PRO.codigo_proc_med in ('000000000000003','000000000000001')
  and RHMEDI_FICHA_MED.codigo_pessoa = P_CODIGO_PESSOA
  and RHMEDI_FICHA_MED.CODIGO_EMPRESA = P_CODIGO_EMPRESA
  order by 2 ) x;

   LOOP


   FETCH sList INTO 
   vList.nmr_linha, 
   vList.CODIGO_EMPRESA, 
   vList.CODIGO_PESSOA ,
   vList.TIPO_CONTRATO,
   vList.CODIGO_CONTRATO ,
   vList.PROCEDIMENTO,
   vList.CONDUTA ,
   vList.DATA_OCORRENCIA ,
   vList.OCORRENCIA ,
   vList.DATA_INICIO_AFAST ,
   vList.DATA_FIM_AFAST ,
   vList.DIAS_LACON ,
   vList.DATA_INICIO_VIGENCIA ,
   vList.DATA_FIM_VIGENCIA 
   ;

   EXIT WHEN sList%NOTFOUND;
   -- Vamos manipular os dados

    linha := vList.nmr_linha; 
       if ( linha = 1) then
        data_inicio_vigencia := vList.DATA_INICIO_AFAST ;
        vList.DATA_INICIO_VIGENCIA := data_inicio_vigencia;
        vList.DATA_FIM_VIGENCIA := ADD_MONTHS(data_inicio_vigencia,24);
      end if;

      if ( linha > 1) then
        if ( vList.DATA_INICIO_AFAST <= ADD_MONTHS(data_inicio_vigencia,24)) then
        vList.DATA_INICIO_VIGENCIA := data_inicio_vigencia;
        vList.DATA_FIM_VIGENCIA := ADD_MONTHS(data_inicio_vigencia,24);
        end if;
       if ( vList.DATA_INICIO_AFAST > ADD_MONTHS(data_inicio_vigencia,24)) then
        data_inicio_vigencia := vList.DATA_INICIO_AFAST ;
        vList.DATA_INICIO_VIGENCIA := data_inicio_vigencia;
        vList.DATA_FIM_VIGENCIA := ADD_MONTHS(data_inicio_vigencia,24);
        end if;
      end if;

    vList := ARTERH.TABLE_LACON(vList.nmr_linha,    vList.CODIGO_EMPRESA,    vList.CODIGO_PESSOA ,   vList.TIPO_CONTRATO,   vList.CODIGO_CONTRATO ,   vList.PROCEDIMENTO,   vList.CONDUTA ,   vList.DATA_OCORRENCIA ,   vList.OCORRENCIA ,   vList.DATA_INICIO_AFAST ,   vList.DATA_FIM_AFAST ,   vList.DIAS_LACON ,   vList.DATA_INICIO_VIGENCIA,   vList.DATA_FIM_VIGENCIA);
    ttList.extend;
    ttList(vList.nmr_linha) :=  vList;
   END LOOP;

   CLOSE sList;
   EXCEPTION
   WHEN OTHERS THEN
   --DBMS_OUTPUT.PUT_LINE('[ ERRO ] ' || TO_CHAR(SQLCODE) || ' - ' || SQLERRM); 
   vList := ARTERH.TABLE_LACON(1,'ERRO', null, null, null, null, null, null,null, null,  null, null, null, null);
   ttList.extend;
   ttList(1) :=  vList;
   -- Não esqueça de sempre fechar o seu cursor :)
     IF sList%ISOPEN THEN
     CLOSE sList;
     END IF;
   END;
  RETURN(ttList);


END F_RELAT_LACON;