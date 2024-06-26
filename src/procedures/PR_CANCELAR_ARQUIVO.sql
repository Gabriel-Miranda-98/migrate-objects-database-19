
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_CANCELAR_ARQUIVO" (PID_ARQUIVO IN NUMBER) AS

  vID_ARQUIVO NUMBER;
  vSITUACAO_ARQUIVO CHAR(2);
  vTIPO_ARQUIVO CHAR(4);
  vLOGIN_USUARIO VARCHAR2(40) := 'IMPORT_CANCEL';
  vLINHA_ATUALIZADA NUMBER;
BEGIN
    BEGIN
         vID_ARQUIVO := null;
         select ID_ARQUIVO, SITUACAO, TIPO_ARQUIVO into vID_ARQUIVO, vSITUACAO_ARQUIVO, vTIPO_ARQUIVO from RHPBH_ARQUIVO where ID_ARQUIVO = PID_ARQUIVO;

         IF vID_ARQUIVO IS NULL THEN
            raise_application_error (-20001,'ID ARQUIVO INVALIDO.');
         END IF;

    EXCEPTION
    WHEN OTHERS THEN
       raise_application_error (-20002,'NAO FOI POSSIVEL RECUPERAR O ARQUIVO COM O ID_ARQUIVO INFORMADO.' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
    END;

    BEGIN
         update RHPBH_ARQUIVO
            set SITUACAO = '01',
                DATA_CANCELAMENTO = sysdate,
                LOGIN_USUARIO = vLOGIN_USUARIO,
                DT_ULT_ALTER_USUA = sysdate
          where ID_ARQUIVO = PID_ARQUIVO;

          vLINHA_ATUALIZADA := sql%rowcount;
          
          IF vLINHA_ATUALIZADA = 0 THEN
             raise_application_error (-20002,'NAO FOI POSSIVEL CANCELAR O ARQUIVO COM O ID_ARQUIVO INFORMADO. ENTRE EM CONTATO COM A AREA DE SUPORTE DA PBH.');
          END IF;

    EXCEPTION
    WHEN OTHERS THEN
       raise_application_error (-20002,'NAO FOI POSSIVEL CANCELAR O ARQUIVO COM O ID_ARQUIVO INFORMADO.' || 'ENCONTRADO ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
    END;
    COMMIT;
END;