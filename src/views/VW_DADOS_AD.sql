
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VW_DADOS_AD" ("NOME", "BM", "CPF", "EMAIL") AS 
  SELECT p.nome_acesso AS NOME,CONT.CODIGO AS BM,P.CPF,X.EMAIL FROM (SELECT      *  FROM      arterh.smarh_int_atualiza_ad ad  WHERE      trunc(data_carga) = (          SELECT              MAX(trunc(aux.data_carga))          FROM              arterh.smarh_int_atualiza_ad aux          WHERE                  aux.login_usuario = ad.login_usuario              AND ad.cpf = aux.cpf      )      )X      LEFT OUTER JOIN RHUSER_P_SIST USR      ON usr.codigo_usuario=X.LOGIN_USUARIO          LEFT OUTER JOIN            (SELECT *            FROM ARTERH.RHPESS_CONTRATO C            WHERE C.ANO_MES_REFERENCIA=              (SELECT MAX (AUX.ANO_MES_REFERENCIA)              FROM ARTERH.RHPESS_CONTRATO AUX              WHERE AUX.CODIGO      =C.CODIGO              AND AUX.TIPO_CONTRATO =C.TIPO_CONTRATO              AND AUX.CODIGO_EMPRESA=C.CODIGO_EMPRESA              )            )CONT          ON USR.EMPRESA_USUARIO  =CONT.CODIGO_EMPRESA          AND USR.CONTRATO_USUARIO=CONT.CODIGO          AND USR.TP_CONTR_USUARIO=CONT.TIPO_CONTRATO          LEFT OUTER JOIN ARTERH.RHPESS_PESSOA P          ON P.CODIGO_EMPRESA =CONT.CODIGO_EMPRESA          AND P.CODIGO        =CONT.CODIGO_PESSOA          WHERE P.CPF=X.CPF          AND CONT.CODIGO_EMPRESA='0001'          ORDER BY P.NOME_ACESSO ASC