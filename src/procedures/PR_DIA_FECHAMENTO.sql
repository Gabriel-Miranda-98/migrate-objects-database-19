
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PR_DIA_FECHAMENTO" AS 
vDIA_FECHAMENTO CHAR(2);
err_msg VARCHAR2(4000 BYTE);


PROCEDURE GRAVA_ERRO(PROCEDURE_ERRO IN VARCHAR2,COD_ERRO IN VARCHAR2, SQL_ERRO IN VARCHAR2) AS
BEGIN
INSERT INTO SMARH_INT_LOG_INTEGRA_DIARIA(ID,PROCEDURE_ERRO,CODIGO_ERRO,DESCRICAO_ERRO) VALUES(ID_SEQ_LOG_PONTO.NEXTVAL,PROCEDURE_ERRO,COD_ERRO,SQL_ERRO);
COMMIT;
END;
PROCEDURE GRAVA_SUCESSO(PROCEDURE_ERRO IN VARCHAR2,COD_ERRO IN VARCHAR2, SQL_ERRO IN VARCHAR2) AS
BEGIN
INSERT INTO SMARH_INT_LOG_INTEGRA_DIARIA(ID,PROCEDURE_ERRO,CODIGO_ERRO,DESCRICAO_ERRO,VERIFICADO) VALUES(ID_SEQ_LOG_PONTO.NEXTVAL,PROCEDURE_ERRO,COD_ERRO,SQL_ERRO,'S');
COMMIT;
END;
BEGIN 
SELECT TO_CHAR(SYSDATE,'DD')INTO vDIA_FECHAMENTO FROM DUAL;

IF vDIA_FECHAMENTO<>'10' THEN 
       raise_application_error (-20001,'PROCEDURE SO PODE SER EXECUTADA NO DIA DO FECHAMENTO DOS ESPELHOS DE PONTO');

END IF;


BEGIN 
execute immediate 'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';
UPDATE PONTO_ELETRONICO.SMARH_INT_PE_JUSTIFICATIVA_IF SET DT_ENVIADO_IFPONTO_SURICATO=SYSDATE WHERE DT_ENVIADO_IFPONTO_SURICATO IS NULL;
COMMIT;
UPDATE PONTO_ELETRONICO.SMARH_INT_CAD_CERCA_DIGITAL SET DT_ENVIADO_IFPONTO_SURICATO=SYSDATE WHERE DT_ENVIADO_IFPONTO_SURICATO is null;
COMMIT;
UPDATE PONTO_ELETRONICO.SMARH_INT_PE_CARGO_V2 set DT_ENVIADO_IFPONTO_SURICATO = SYSDATE where DT_ENVIADO_IFPONTO_SURICATO is  null;
COMMIT;
UPDATE PONTO_ELETRONICO.smarh_int_pe_escala_v2 SET DT_ENVIADO_IFPONTO_SURICATO= SYSDATE WHERE DT_ENVIADO_IFPONTO_SURICATO is null;
COMMIT;
UPDATE PONTO_ELETRONICO.smarh_int_pe_jorn_escala_v2 SET DT_ENVIADO_IFPONTO_SURICATO= SYSDATE WHERE DT_ENVIADO_IFPONTO_SURICATO is null;
COMMIT;
UPDATE PONTO_ELETRONICO.SMARH_INT_PE_JORNADA_V2 SET DT_ENVIADO_IFPONTO_SURICATO= SYSDATE WHERE DT_ENVIADO_IFPONTO_SURICATO is null;
COMMIT;
update PONTO_ELETRONICO.smarh_int_pe_unidade_v2 set DT_ENVIADO_IFPONTO_SURICATO = SYSDATE   where DT_ENVIADO_IFPONTO_SURICATO is  null ;
COMMIT;
update PONTO_ELETRONICO.SMARH_INT_PONTO_DADOS_SERV_V10 set DT_ENVIADO_IFPONTO_SURICATO = SYSDATE   where DT_ENVIADO_IFPONTO_SURICATO is  null ;
COMMIT;
UPDATE PONTO_ELETRONICO.SMARH_INT_CAD_PESS_CERCA SET DT_ENVIADO_IFPONTO_SURICATO=SYSDATE WHERE DT_ENVIADO_IFPONTO_SURICATO is null;
COMMIT;
UPDATE PONTO_ELETRONICO.SMARH_INT_PE_AFASTAMENTOS_V1  SET DT_ENVIADO_IFPONTO_SURICATO = SYSDATE where DT_ENVIADO_IFPONTO_SURICATO is null;
COMMIT;

END;


BEGIN
  ARTERH.PR_PROXIMA_SITUACAO_FUNCIONAL (to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));
    err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_PROXIMA_SITUACAO_FUNCIONAL','000',err_msg);
  exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_PROXIMA_SITUACAO_FUNCIONAL',SQLCODE,err_msg);
END;
BEGIN 
ARTERH.PR_FICHA_FUTURA_GRAVA_SIT_FUNC(to_char(sysdate,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy'));
 err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_FICHA_FUTURA_GRAVA_SIT_FUNC','000',err_msg);
exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_FICHA_FUTURA_GRAVA_SIT_FUNC',SQLCODE,err_msg);
  END;

BEGIN
ARTERH.PR_AJUSTES_ALT_SIT_FUNC_2022(to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy')); 
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_AJUSTES_ALT_SIT_FUNC_2022','000',err_msg);
exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_AJUSTES_ALT_SIT_FUNC_2022',SQLCODE,err_msg);
END;

BEGIN
 ARTERH.PR_ACERTOS_ALT_SIT_FUNC_2022; 
 err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_ACERTOS_ALT_SIT_FUNC_2022','000',err_msg);
exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_ACERTOS_ALT_SIT_FUNC_2022',SQLCODE,err_msg);
END;


 BEGIN
    ARTERH.PR_LOTE_FIC_MED_AJUSTE_ATENDEN(to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));
    err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_LOTE_FIC_MED_AJUSTE_ATENDEN','000',err_msg);
  exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_LOTE_FIC_MED_AJUSTE_ATENDEN',SQLCODE,err_msg);
  END;
  BEGIN
 ARTERH.PR_LOTE_FIC_MED_AJUSTE_DOENCA(to_char(sysdate-1,'dd/mm/yyyy'), to_char(sysdate-1,'dd/mm/yyyy'));
       err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_LOTE_FIC_MED_AJUSTE_DOENCA','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_LOTE_FIC_MED_AJUSTE_DOENCA',SQLCODE,err_msg);
END;


/*
--Gabriel aqui em 03/09 deixou de rodar aparti do dia 04/09 a pedido do kellysson pelo chat 
BEGIN
ARTERH.PR_ACERTO_LACUNAS_SIT_FUNC;
    err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_ACERTO_LACUNAS_SIT_FUNC','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_ACERTO_LACUNAS_SIT_FUNC',SQLCODE,err_msg);
END;
*/

BEGIN
 ARTERH.PR_ACERTOS_HIST_ESCALA_CONTR;
     err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_ACERTOS_HIST_ESCALA_CONTR','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_ACERTOS_HIST_ESCALA_CONTR',SQLCODE,err_msg);
END;

BEGIN
 ARTERH.PR_ACERTOS_LACUNAS_HIST_ESCALA;
      err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_ACERTOS_LACUNAS_HIST_ESCALA','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_ACERTOS_LACUNAS_HIST_ESCALA',SQLCODE,err_msg);
END;




--------------------------------------------------------------------------------COMECO DAS INTEGRACOES  DIARIAS COM PONTO ELETRONIOC ---------------------------------------------------------------------------------------------------------------------------








begin
 PONTO_ELETRONICO.SMARH_INT_ATT_ENDERECOS;
        err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_ATT_ENDERECOS','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_ATT_ENDERECOS',SQLCODE,err_msg);
END;

begin
 PONTO_ELETRONICO.SMARH_INT_CAR_ARTE_END;
         err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_CAR_ARTE_END','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_CAR_ARTE_END',SQLCODE,err_msg);
END;

begin
 PONTO_ELETRONICO.SMARH_INT_PE_CONTRATOS_ARTE;
          err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_CONTRATOS_ARTE','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_CONTRATOS_ARTE',SQLCODE,err_msg);
END;

begin
 PONTO_ELETRONICO.SMARH_INT_PE_CAD_JUSTIFICATIVA(to_char(sysdate ,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy'));
           err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_CAD_JUSTIFICATIVA','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_CAD_JUSTIFICATIVA',SQLCODE,err_msg);
END;

begin
 PONTO_ELETRONICO.SMARH_INT_CAD_CERCAS(to_char(sysdate,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy'));
            err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_CAD_CERCAS','000',err_msg);
 exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_CAD_CERCAS',SQLCODE,err_msg);
END;

begin
PONTO_ELETRONICO.SMARH_INT_PE_CAD_CARGO_FUNCAO (to_char(sysdate ,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_CAD_CARGO_FUNCAO','000',err_msg);
exception
              when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_CAD_CARGO_FUNCAO',SQLCODE,err_msg);
END;

begin
PONTO_ELETRONICO.SMARH_INT_PE_CAD_DEPTO_HIERAR  (to_char(sysdate,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_CAD_DEPTO_HIERAR','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_CAD_DEPTO_HIERAR',SQLCODE,err_msg);
END;
begin
PONTO_ELETRONICO.SMARH_INT_PE_CAD_HORARIO (to_char(sysdate,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_CAD_HORARIO','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_CAD_HORARIO',SQLCODE,err_msg);
END;
begin
PONTO_ELETRONICO.SMARH_INT_PE_CAD_ESCALA (to_char(sysdate,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_CAD_ESCALA','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_CAD_ESCALA',SQLCODE,err_msg);
END;
begin
PONTO_ELETRONICO.SMARH_INT_PE_CAD_JORN_HOR (to_char(sysdate,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_CAD_JORN_HOR','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_CAD_JORN_HOR',SQLCODE,err_msg);
END;
begin
PONTO_ELETRONICO.SMARH_INT_PE_E_GESTOR_V1;
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_E_GESTOR_V1','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_E_GESTOR_V1',SQLCODE,err_msg);
END;
begin
PONTO_ELETRONICO.SMARH_INT_PE_ATUALIZA_IFPONTO;
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_ATUALIZA_IFPONTO','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_ATUALIZA_IFPONTO',SQLCODE,err_msg);
END;
begin
suricato.sp_integra@LK_PROD_SUR.PBH;
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SURICATO','000',err_msg);

 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SURICATO',SQLCODE,err_msg);
END;
begin
PONTO_ELETRONICO.SMARH_INT_CAD_PESSOA(to_char(sysdate,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_CAD_PESSOA','000',err_msg);

 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_CAD_PESSOA',SQLCODE,err_msg);
END;
begin
PONTO_ELETRONICO.SMARH_INT_PE_CAD_FERIAS_EXCLUI (to_char(sysdate,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_CAD_FERIAS_EXCLUI','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_CAD_FERIAS_EXCLUI',SQLCODE,err_msg);
END;

begin
PONTO_ELETRONICO.SMARH_INT_AFASTAMENTOS_EXC (to_char(sysdate,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_AFASTAMENTOS_EXC','000',err_msg);

 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_AFASTAMENTOS_EXC',SQLCODE,err_msg);
END;

begin
PONTO_ELETRONICO.SMARH_INT_PE_CAD_FERIAS_INCLUI (to_char(sysdate,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_CAD_FERIAS_INCLUI','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_CAD_FERIAS_INCLUI',SQLCODE,err_msg);
END;

begin
PONTO_ELETRONICO.SMARH_INT_AFASTAMENTOS_INC (to_char(sysdate,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy'));
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_AFASTAMENTOS_INC','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_AFASTAMENTOS_INC',SQLCODE,err_msg);
END;





begin
UPDATE ARTERH.SMARH_INT_ATUALIZA_AD AD  SET AD.INTEGRADO='S' WHERE TRUNC(AD.DATA_CARGA)=TRUNC(sysdate) AND EXISTS (SELECT * FROM ARTERH.SMARH_INT_ATUALIZA_AD AUX WHERE TRUNC(AUX.DATA_CARGA)<=TRUNC(sysdate-2) AND AUX.LOGIN_USUARIO=AD.LOGIN_USUARIO) ;
COMMIT;
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('ATUALIZA_TABELA_AD','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('ATUALIZA_TABELA_AD',SQLCODE,err_msg);
END;

begin
ARTERH.PR_SMARH_ATUALIZA_AD_EMAIL;
COMMIT;
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_SMARH_ATUALIZA_AD_EMAIL','000',err_msg);

 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_SMARH_ATUALIZA_AD_EMAIL',SQLCODE,err_msg);
END;
begin
PONTO_ELETRONICO.SMARH_INT_PE_ATUALIZA_ARTE_V1;
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('SMARH_INT_PE_ATUALIZA_ARTE_V1','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('SMARH_INT_PE_ATUALIZA_ARTE_V1',SQLCODE,err_msg);
END;
begin
PONTO_ELETRONICO.PR_PONTO_ATUALIZA_REDE;
err_msg := SUBSTR('EXECUCAO_REALIZADA_COM_SUCESSO', 1, 4000);
              GRAVA_SUCESSO('PR_PONTO_ATUALIZA_REDE','000',err_msg);
 exception       when others then
               err_msg := SUBSTR(SQLERRM, 1, 4000);
              GRAVA_ERRO('PR_PONTO_ATUALIZA_REDE',SQLCODE,err_msg);
END;





END;