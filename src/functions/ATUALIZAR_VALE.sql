
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."ATUALIZAR_VALE" (COD_EMPRESA CHAR,  TP_CONT CHAR,COD_CONT VARCHAR2,DATA_INI DATE,DATA_FIM DATE ,COD_LINHA CHAR,COD_IT   CHAR )
    RETURN NUMBER
  IS
    vQTDE_LINHAS_AFETADAS NUMBER;
  BEGIN
    BEGIN
      UPDATE ARTERH.RHVALE_TRANSPORTE
      SET DATA_FIM_VIGENCIA  =DATA_FIM,
        TEXTO_ASSOCIADO      = 'REGISTRO FINALIZADO PELA ROTINA AUTOMATICA DO VALE',
        LOGIN_USUARIO        = 'PR_GERA_VALE_AUTOMATICO',
        DT_ULT_ALTER_USUA    = SYSDATE
      WHERE CODIGO_CONTRATO  =COD_CONT
      AND TIPO_CONTRATO      =TP_CONT
      AND CODIGO_EMPRESA     = COD_EMPRESA
      AND CODIGO_LINHA       =COD_LINHA
      AND CODIGO_ITINERARIO  =COD_IT
      AND DATA_INI_VIGENCIA  =DATA_INI;
      vQTDE_LINHAS_AFETADAS := sql%rowcount;
      COMMIT;
    EXCEPTION
    WHEN OTHERS THEN
      raise_application_error (-20002,'[VALIDACAO_REGRAS] - OCORREU UMA EXCECAO AO TENTAR ATUALIZAR A SITUACAO DOS REGISTROS VALIDADOS. ENTRE EM CONTATO COM A EQUIPE DE SUPORTE DA PBH.'||'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
    END;
    RETURN vQTDE_LINHAS_AFETADAS;
  END;