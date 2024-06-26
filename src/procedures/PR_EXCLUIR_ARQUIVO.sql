
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_EXCLUIR_ARQUIVO" (PID_ARQUIVO IN NUMBER) AS

  vID_ARQUIVO NUMBER;
  vSITUACAO_ARQUIVO CHAR(2);
  vTIPO_ARQUIVO CHAR(4);
  vLINHA_ATUALIZADA NUMBER;

  STATUS_CARREGADO    CONSTANT NUMBER := 0;
  STATUS_VALIDADO     CONSTANT NUMBER := 1;
  STATUS_INVALIDADO   CONSTANT NUMBER := 2;
  STATUS_PROCESSADO   CONSTANT NUMBER := 3;
  STATUS_EFETIVADO    CONSTANT NUMBER := 4;
BEGIN
    BEGIN
         vID_ARQUIVO := null;
         select ID_ARQUIVO, SITUACAO, TIPO_ARQUIVO into vID_ARQUIVO, vSITUACAO_ARQUIVO, vTIPO_ARQUIVO from RHPBH_ARQUIVO where ID_ARQUIVO = PID_ARQUIVO;

         IF vID_ARQUIVO IS NULL THEN
            raise_application_error (-20001,'ID ARQUIVO INVALIDO.');
         END IF;

         IF vSITUACAO_ARQUIVO NOT IN ('00','01','02','03','04','05','06','07') THEN
            raise_application_error (-20001,'O ARQUIVO INFORMADO ESTA COM SITUACAO INVALIDA. ENTRE EM CONTATO COM O SUPORTE TECNICO DA PBH.');
         END IF;

         CASE WHEN vSITUACAO_ARQUIVO <> '00' THEN
              raise_application_error (-20002,'O ARQUIVO INFORMADO ESTA COM PROCESSAMENTO JA CONCLUIDO E NAO PODE SER MAIS CANCELADO.');
              ELSE
                  NULL;
         END CASE;

    EXCEPTION
    WHEN OTHERS THEN
       raise_application_error (-20002,'NAO FOI POSSIVEL RECUPERAR O ARQUIVO COM O ID_ARQUIVO INFORMADO.' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
    END;

    BEGIN
         delete from RHPBH_ARQUIVO_PROCESSA_STATS
          where ID_ARQUIVO = PID_ARQUIVO;
          
         delete from RHPBH_ARQUIVO_LOG
          where ID_ARQUIVO = PID_ARQUIVO;
          
         delete from RHPBH_ARQUIVO_LINHA
          where ID_ARQUIVO = PID_ARQUIVO;
                        
         delete from RHPBH_ARQUIVO
          where ID_ARQUIVO = PID_ARQUIVO;

          vLINHA_ATUALIZADA := sql%rowcount;
          
    EXCEPTION
    WHEN OTHERS THEN
       raise_application_error (-20002,'NAO FOI POSSIVEL CANCELAR O ARQUIVO COM O ID_ARQUIVO INFORMADO.' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
    END;
    COMMIT;
END;