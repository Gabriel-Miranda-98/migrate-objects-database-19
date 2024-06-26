
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."SMARH_INT_CAR_ARTE_END" AS
BEGIN
DECLARE
CONT NUMBER;
QTD_LINHAS_AFETADAS NUMBER;
BEGIN
CONT:=0;
FOR C1 IN (
SELECT
CASE WHEN SUBSTR(LOGRADOURO,0,3)='RUA' THEN SUBSTR(LOGRADOURO,5,100)
WHEN (SUBSTR(LOGRADOURO,0,7)='AVENIDA' OR SUBSTR(LOGRADOURO,0,7)='ALAMEDA' OR SUBSTR(LOGRADOURO,0,7)='ESTRADA' OR SUBSTR(LOGRADOURO,0,7)='RODOVIA' OR SUBSTR(LOGRADOURO,0,7)='FAZENDA' OR SUBSTR(LOGRADOURO,0,7)='LADEIRA')  THEN SUBSTR(LOGRADOURO,9,100)
WHEN (SUBSTR(LOGRADOURO,0,4)='BECO' OR SUBSTR(LOGRADOURO,0,4)='VILA') THEN  SUBSTR(LOGRADOURO,5,100)
WHEN SUBSTR(LOGRADOURO,0,8)='TRAVESSA' THEN   SUBSTR(LOGRADOURO,9,100)
WHEN (SUBSTR(LOGRADOURO,0,6)='QUADRA' OR SUBSTR(LOGRADOURO,0,6)='PARQUE') THEN SUBSTR(LOGRADOURO,7,100)
WHEN SUBSTR(LOGRADOURO,0,10)='CONDOMINIO'THEN  SUBSTR(LOGRADOURO,11,100)
WHEN (SUBSTR(LOGRADOURO,0,5)='PRACA' OR SUBSTR(LOGRADOURO,0,5)='SITIO' OR SUBSTR(LOGRADOURO,0,5)='LARGO') THEN SUBSTR(LOGRADOURO,5,100)
WHEN SUBSTR(LOGRADOURO,0,9)='ESCADARIA' THEN SUBSTR(LOGRADOURO,10,100)
ELSE LOGRADOURO
END AS  DESCRICAO,
CODIGO_ARTE, CODIGO_EMPRESA,
LATITUDE,
LONGITUDE,
LOGRADOURO,
TIPO_LOGRADOURO,
NUMERO,
BAIRRO,
CODIGO_MUNICIPIO,
CEP,
UF,
REDE,
DATA_EXTINCAO,TIPO_FAZER,
CODIGO_REGIONAL
FROM ATUALIZA_ARTERH_SIOM_SDM S
WHERE DATA_ENVIADO_ARTE  IS NULL
AND CODIGO_ARTE <>'00'
AND S.ID=(SELECT MAX(AUX.ID) FROM ATUALIZA_ARTERH_SIOM_SDM AUX
WHERE AUX.CODIGO_ARTE=S.CODIGO_ARTE)
GROUP BY CODIGO_ARTE, CODIGO_EMPRESA,
LATITUDE,
LONGITUDE,
 LOGRADOURO, TIPO_LOGRADOURO,NUMERO,
BAIRRO,
CODIGO_MUNICIPIO,
CEP,
UF,
REDE,DATA_EXTINCAO,TIPO_FAZER,CODIGO_REGIONAL)
LOOP
CONT:=CONT+1;
IF C1.DATA_EXTINCAO IS NULL AND C1.TIPO_FAZER='I' THEN
QTD_LINHAS_AFETADAS:=0;
------PARTE QUE INCLUI UM NOVO ENDERECO QUANDO ENCONTRAR
INSERT INTO ARTERH.RHORGA_ENDERECO (CODIGO, DESCRICAO,TIPO_LOGRADOURO,ENDERECO,NUMERO,BAIRRO,MUNICIPIO,UF,CEP,CAIXA_POSTAL,TELEX,LOGIN_USUARIO,DT_ULT_ALTER_USUA,TEXTO_ASSOC,C_LIVRE_DATA01,codigo_endereco01)
VALUES(C1.CODIGO_ARTE,TRIM(C1.DESCRICAO),C1.TIPO_LOGRADOURO,C1.DESCRICAO,C1.NUMERO,C1.BAIRRO,C1.CODIGO_MUNICIPIO,C1.UF,C1.CEP,C1.LATITUDE,C1.LONGITUDE,'INTEGRACAO_SIOM',SYSDATE,C1.REDE,SYSDATE,C1.CODIGO_REGIONAL);
QTD_LINHAS_AFETADAS:=SQL%ROWCOUNT;
COMMIT;
dbms_output.put_line('QTD_LINHAS_AFETADAS'||QTD_LINHAS_AFETADAS);
------PARQUE QUE ATUALIZA DATA DE INTEGRACAO DAS TABELAS HISTORIACAS
IF QTD_LINHAS_AFETADAS>0 THEN
UPDATE ATUALIZA_ARTERH_SIOM_SDM SET DATA_ENVIADO_ARTE= SYSDATE WHERE CODIGO_ARTE=C1.CODIGO_ARTE;
END IF;
END IF;
-------------PARQUE  QUE ATUALIZA OQUE MUDAR NO DIA INDIVIDUALMENTE POR CAMPO
IF C1.DATA_EXTINCAO IS NULL AND C1.TIPO_FAZER='A' THEN
     IF C1.LATITUDE IS NOT NULL THEN
        UPDATE ARTERH.RHORGA_ENDERECO SET CAIXA_POSTAL=C1.LATITUDE,LOGIN_USUARIO='INTEGRACAO_SIOM',DT_ULT_ALTER_USUA=SYSDATE WHERE CODIGO=C1.CODIGO_ARTE;
        QTD_LINHAS_AFETADAS:=SQL%ROWCOUNT;
        COMMIT;
        IF QTD_LINHAS_AFETADAS>0 THEN
        dbms_output.put_line('QTD_LINHAS_AFETADAS 1 IF '||QTD_LINHAS_AFETADAS);
           UPDATE ATUALIZA_ARTERH_SIOM_SDM SET DATA_ENVIADO_ARTE= SYSDATE WHERE CODIGO_ARTE=C1.CODIGO_ARTE;
            END IF;
     END IF;

    IF C1.LONGITUDE IS NOT NULL THEN
       UPDATE ARTERH.RHORGA_ENDERECO SET TELEX=C1.LATITUDE,LOGIN_USUARIO='INTEGRACAO_SIOM',DT_ULT_ALTER_USUA=SYSDATE WHERE CODIGO=C1.CODIGO_ARTE;
        QTD_LINHAS_AFETADAS:=SQL%ROWCOUNT;
        COMMIT;
         dbms_output.put_line('QTD_LINHAS_AFETADAS 2 IF '||QTD_LINHAS_AFETADAS);
        IF QTD_LINHAS_AFETADAS>0 THEN
           UPDATE ATUALIZA_ARTERH_SIOM_SDM SET DATA_ENVIADO_ARTE= SYSDATE WHERE CODIGO_ARTE=C1.CODIGO_ARTE;
        END IF;
   END IF;

   IF C1.REDE IS NOT NULL THEN
      UPDATE ARTERH.RHORGA_ENDERECO SET TEXTO_ASSOC=C1.REDE,LOGIN_USUARIO='INTEGRACAO_SIOM',DT_ULT_ALTER_USUA=SYSDATE WHERE CODIGO=C1.CODIGO_ARTE;
       QTD_LINHAS_AFETADAS:=SQL%ROWCOUNT;
        COMMIT;
         dbms_output.put_line('QTD_LINHAS_AFETADAS 3 IF '||QTD_LINHAS_AFETADAS);
        IF QTD_LINHAS_AFETADAS>0 THEN
           UPDATE ATUALIZA_ARTERH_SIOM_SDM SET DATA_ENVIADO_ARTE= SYSDATE WHERE CODIGO_ARTE=C1.CODIGO_ARTE;
        END IF;
   END IF;
   IF C1.TIPO_LOGRADOURO IS NOT NULL THEN
      UPDATE ARTERH.RHORGA_ENDERECO SET TIPO_LOGRADOURO=C1.TIPO_LOGRADOURO,LOGIN_USUARIO='INTEGRACAO_SIOM',DT_ULT_ALTER_USUA=SYSDATE WHERE CODIGO=C1.CODIGO_ARTE;
       QTD_LINHAS_AFETADAS:=SQL%ROWCOUNT;
        COMMIT;
         dbms_output.put_line('QTD_LINHAS_AFETADAS 4 IF '||QTD_LINHAS_AFETADAS);
        IF QTD_LINHAS_AFETADAS>0 THEN
           UPDATE ATUALIZA_ARTERH_SIOM_SDM SET DATA_ENVIADO_ARTE= SYSDATE WHERE CODIGO_ARTE=C1.CODIGO_ARTE;
        END IF;
   END IF;

   IF C1.LOGRADOURO IS NOT NULL THEN
      UPDATE ARTERH.RHORGA_ENDERECO SET ENDERECO=C1.LOGRADOURO,LOGIN_USUARIO='INTEGRACAO_SIOM',DT_ULT_ALTER_USUA=SYSDATE WHERE CODIGO=C1.CODIGO_ARTE;
      QTD_LINHAS_AFETADAS:=SQL%ROWCOUNT;
      COMMIT;
      IF QTD_LINHAS_AFETADAS>0 THEN
           UPDATE ATUALIZA_ARTERH_SIOM_SDM SET DATA_ENVIADO_ARTE= SYSDATE WHERE CODIGO_ARTE=C1.CODIGO_ARTE;
      END IF;
   END IF;

   IF C1.NUMERO IS NOT NULL THEN
      UPDATE ARTERH.RHORGA_ENDERECO SET NUMERO=C1.NUMERO,LOGIN_USUARIO='INTEGRACAO_SIOM',DT_ULT_ALTER_USUA=SYSDATE WHERE CODIGO=C1.CODIGO_ARTE;
       QTD_LINHAS_AFETADAS:=SQL%ROWCOUNT;
        COMMIT;
        IF QTD_LINHAS_AFETADAS>0 THEN
           UPDATE ATUALIZA_ARTERH_SIOM_SDM SET DATA_ENVIADO_ARTE= SYSDATE WHERE CODIGO_ARTE=C1.CODIGO_ARTE;
        END IF;
   END IF;

   IF C1.BAIRRO IS NOT NULL THEN
      UPDATE ARTERH.RHORGA_ENDERECO SET BAIRRO=C1.BAIRRO,LOGIN_USUARIO='INTEGRACAO_SIOM',DT_ULT_ALTER_USUA=SYSDATE WHERE CODIGO=C1.CODIGO_ARTE;
       QTD_LINHAS_AFETADAS:=SQL%ROWCOUNT;
        COMMIT;
        IF QTD_LINHAS_AFETADAS>0 THEN
           UPDATE ATUALIZA_ARTERH_SIOM_SDM SET DATA_ENVIADO_ARTE= SYSDATE WHERE CODIGO_ARTE=C1.CODIGO_ARTE;
        END IF;
   END IF;

   IF C1.CEP IS NOT NULL THEN
      UPDATE ARTERH.RHORGA_ENDERECO SET CEP=C1.CEP,LOGIN_USUARIO='INTEGRACAO_SIOM',DT_ULT_ALTER_USUA=SYSDATE WHERE CODIGO=C1.CODIGO_ARTE;
       QTD_LINHAS_AFETADAS:=SQL%ROWCOUNT;
        COMMIT;
        IF QTD_LINHAS_AFETADAS>0 THEN
           UPDATE ATUALIZA_ARTERH_SIOM_SDM SET DATA_ENVIADO_ARTE= SYSDATE WHERE CODIGO_ARTE=C1.CODIGO_ARTE;
           COMMIT;
        END IF;
   END IF;

   IF C1.CODIGO_REGIONAL IS NOT NULL THEN
      UPDATE ARTERH.RHORGA_ENDERECO SET codigo_endereco01=C1.CODIGO_REGIONAL,LOGIN_USUARIO='INTEGRACAO_SIOM',DT_ULT_ALTER_USUA=SYSDATE WHERE CODIGO=C1.CODIGO_ARTE;
       QTD_LINHAS_AFETADAS:=SQL%ROWCOUNT;
        COMMIT;
        IF QTD_LINHAS_AFETADAS>0 THEN
           UPDATE ATUALIZA_ARTERH_SIOM_SDM SET DATA_ENVIADO_ARTE= SYSDATE WHERE CODIGO_ARTE=C1.CODIGO_ARTE;
           COMMIT;
        END IF;
   END IF;

END IF;
----FIM PARTE ATUALIZA INDIVIDUAL
END LOOP;
----- INICIO PARTE VINCULA O CADASTRO DOS ENDERECOES AS TABELAS DE CUSTO GERENCIAL E AGRUPADORES
BEGIN
DECLARE
CONT2 NUMBER;
BEGIN
CONT2:=0;
FOR C2 IN
(
SELECT
 LOGRADOURO||' '||NUMERO AS DESCRICAO,
CODIGO_ARTE, CODIGO_EMPRESA,
LATITUDE,
LONGITUDE,
LOGRADOURO,
TIPO_LOGRADOURO,
NUMERO,
BAIRRO,
CODIGO_MUNICIPIO,
CEP,
UF,
REDE,
CODIGO_UNIDADE,
COD_UNIDADE1,
COD_UNIDADE2,
COD_UNIDADE3,
COD_UNIDADE4,
COD_UNIDADE5,
COD_UNIDADE6
FROM ATUALIZA_ARTERH_SIOM_SDM
WHERE TRUNC(DATA_ENVIADO_ARTE)=TRUNC(SYSDATE) )
LOOP
CONT2:=CONT2+1;
----- RHORGA_CUSTO_GEREN
UPDATE ARTERH.RHORGA_CUSTO_GEREN GN SET GN.COD_ENDERECO=C2.CODIGO_ARTE,GN.LOGIN_USUARIO='INTEGRACAO_SIOM',GN.DT_ULT_ALTER_USUA=SYSDATE WHERE GN.COD_CGERENC1=C2.COD_UNIDADE1
AND GN.COD_CGERENC2=C2.COD_UNIDADE2
AND GN.COD_CGERENC3=C2.COD_UNIDADE3
AND GN.COD_CGERENC4=C2.COD_UNIDADE4
AND GN.COD_CGERENC5=C2.COD_UNIDADE5
AND GN.COD_CGERENC6=C2.COD_UNIDADE6
AND GN.CODIGO_EMPRESA IN (SELECT DADO_ORIGEM FROM RHINTE_ED_IT_CONV WHERE CODIGO_CONVERSAO = 'EMPA')--ALTERADO EM 9/5/23--in ('0001','0002','0003','0013','0014');
;COMMIT;
----RHORGA_LOTACAO
UPDATE ARTERH.RHORGA_LOTACAO L SET L.COD_ENDERECO=C2.CODIGO_ARTE,L.LOGIN_USUARIO='INTEGRACAO_SIOM',L.DT_ULT_ALTER_USUA=SYSDATE
WHERE L.COD_LOTACAO1=C2.COD_UNIDADE1
AND L.COD_LOTACAO2=C2.COD_UNIDADE2
AND L.COD_LOTACAO3=C2.COD_UNIDADE3
AND L.COD_LOTACAO4=C2.COD_UNIDADE4
AND L.COD_LOTACAO5=C2.COD_UNIDADE5
AND L.COD_LOTACAO6=C2.COD_UNIDADE6
AND L.CODIGO_EMPRESA=C2.CODIGO_EMPRESA;
COMMIT;
----- UNIDADE
UPDATE ARTERH.RHORGA_UNIDADE U SET U.COD_ENDERECO=C2.CODIGO_ARTE,U.LOGIN_USUARIO='INTEGRACAO_SIOM',U.DT_ULT_ALTER_USUA=SYSDATE
WHERE U.COD_UNIDADE1=C2.COD_UNIDADE1
AND U.COD_UNIDADE2=C2.COD_UNIDADE2
AND U.COD_UNIDADE3=C2.COD_UNIDADE3
AND U.COD_UNIDADE4=C2.COD_UNIDADE4
AND U.COD_UNIDADE5=C2.COD_UNIDADE5
AND U.COD_UNIDADE6=C2.COD_UNIDADE6
AND U.CODIGO_EMPRESA=C2.CODIGO_EMPRESA;
COMMIT;
----- CUSTO_CONTABIL
UPDATE ARTERH.RHORGA_CUSTO_CONT CT SET CT.COD_ENDERECO=C2.CODIGO_ARTE,CT.LOGIN_USUARIO='INTEGRACAO_SIOM',CT.DT_ULT_ALTER_USUA=SYSDATE
WHERE CT.COD_CCONTAB1=C2.COD_UNIDADE1
AND CT.COD_CCONTAB2=C2.COD_UNIDADE2
AND CT.COD_CCONTAB3=C2.COD_UNIDADE3
AND CT.COD_CCONTAB4=C2.COD_UNIDADE4
AND CT.COD_CCONTAB5=C2.COD_UNIDADE5
AND CT.COD_CCONTAB6=C2.COD_UNIDADE6
AND CT.CODIGO_EMPRESA=C2.CODIGO_EMPRESA;
COMMIT;
UPDATE RHORGA_AGRUPADOR AG SET AG.COD_ENDERECO=C2.CODIGO_ARTE,AG.LOGIN_USUARIO='INTEGRACAO_SIOM',AG.DT_ULT_ALTER_USUA=SYSDATE WHERE AG.TIPO_AGRUP IN ('G','U','L','C')
AND AG.COD_AGRUP1=C2.COD_UNIDADE1
AND AG.COD_AGRUP2=C2.COD_UNIDADE2
AND AG.COD_AGRUP3=C2.COD_UNIDADE3
AND AG.COD_AGRUP4=C2.COD_UNIDADE4
AND AG.COD_AGRUP5=C2.COD_UNIDADE5
AND AG.COD_AGRUP6=C2.COD_UNIDADE6
AND AG.CODIGO_EMPRESA=C2.CODIGO_EMPRESA;
COMMIT;
UPDATE RHORGA_AGRUPADOR_H A SET A.COD_ENDERECO=C2.CODIGO_ARTE,A.LOGIN_USUARIO='INTEGRACAO_SIOM',A.DT_ULT_ALTER_USUA=SYSDATE WHERE A.TIPO_AGRUP IN ('G','U','L','C')
AND A.COD_AGRUP1=C2.COD_UNIDADE1
AND A.COD_AGRUP2=C2.COD_UNIDADE2
AND A.COD_AGRUP3=C2.COD_UNIDADE3
AND A.COD_AGRUP4=C2.COD_UNIDADE4
AND A.COD_AGRUP5=C2.COD_UNIDADE5
AND A.COD_AGRUP6=C2.COD_UNIDADE6
AND A.CODIGO_EMPRESA=C2.CODIGO_EMPRESA
AND A.ANO_MES_REFERENCIA=(SELECT MAX(AUX.ANO_MES_REFERENCIA) FROM RHORGA_AGRUPADOR_H AUX
WHERE AUX.ID_AGRUP=A.ID_AGRUP
AND AUX.TIPO_AGRUP=A.TIPO_AGRUP
AND AUX.CODIGO_EMPRESA=A.CODIGO_EMPRESA);
COMMIT;
END LOOP;
END;
END;
BEGIN
  DECLARE
    CONT NUMBER;
  BEGIN
    CONT:=0;
    FOR C3 IN
    (SELECT G.CODIGO_EMPRESA,
      G.COD_CGERENC1,
      G.COD_CGERENC2,
      G.COD_CGERENC3,
      G.COD_CGERENC4,
      G.COD_CGERENC5,
      G.COD_CGERENC6,
      G.COD_ENDERECO,
      CASE
        WHEN LENGTH(SUBSTR(X.CODIGO_OPUS,1,2))=2
        THEN LPAD (SUBSTR(X.CODIGO_OPUS,1,2),6,'0')
        ELSE NULL
      END AS COD_UNIDADE1,
      CASE
        WHEN LENGTH(SUBSTR(X.CODIGO_OPUS,3,2))=2
        THEN LPAD (SUBSTR(X.CODIGO_OPUS,3,2),6,'0')
        ELSE NULL
      END AS COD_UNIDADE2,
      CASE
        WHEN LENGTH(SUBSTR(X.CODIGO_OPUS,5,2))=2
        THEN LPAD (SUBSTR(X.CODIGO_OPUS,5,2),6,'0')
        ELSE NULL
      END AS COD_UNIDADE3,
      CASE
        WHEN LENGTH(SUBSTR(X.CODIGO_OPUS,7,2))=2
        THEN LPAD (SUBSTR(X.CODIGO_OPUS,7,2),6,'0')
        ELSE NULL
      END AS COD_UNIDADE4,
      CASE
        WHEN LENGTH(SUBSTR(X.CODIGO_OPUS,9,2))=2
        THEN LPAD (SUBSTR(X.CODIGO_OPUS,9,2),6,'0')
        ELSE NULL
      END AS COD_UNIDADE5,
      CASE
        WHEN LENGTH(SUBSTR(X.CODIGO_OPUS,12,2))=2
        THEN LPAD (SUBSTR(X.CODIGO_OPUS,12,2),6,'0')
        ELSE NULL
      END AS COD_UNIDADE6,
      X.CODIGO_ARTE
    FROM ARTERH.RHORGA_CUSTO_GEREN G
    LEFT OUTER JOIN ARTERH.RHORGA_EMPRESA EM
    ON G.CODIGO_EMPRESA=EM.CODIGO
    LEFT OUTER JOIN PONTO_ELETRONICO.ARTERH_SIOM X
    ON LPAD (SUBSTR(X.CODIGO_OPUS,1,2),6,'0')  =G.COD_CGERENC1
    AND LPAD (SUBSTR(X.CODIGO_OPUS,3,2),6,'0') =G.COD_CGERENC2
    AND LPAD (SUBSTR(X.CODIGO_OPUS,5,2),6,'0') =G.COD_CGERENC3
    AND LPAD (SUBSTR(X.CODIGO_OPUS,7,2),6,'0') =G.COD_CGERENC4
    AND LPAD (SUBSTR(X.CODIGO_OPUS,9,2),6,'0') =G.COD_CGERENC5
    AND LPAD (SUBSTR(X.CODIGO_OPUS,12,2),6,'0')=G.COD_CGERENC6
    WHERE (  NOT EXISTS
      (SELECT *
      FROM ARTERH.RHORGA_ENDERECO EM
      WHERE EM.CODIGO        =G.COD_ENDERECO
      AND EM.C_LIVRE_DATA01 IS NOT NULL
      )OR G.COD_ENDERECO<>x.codigo_arte)
   and  G.CODIGO_EMPRESA IN (SELECT DADO_ORIGEM FROM RHINTE_ED_IT_CONV WHERE CODIGO_CONVERSAO = 'EMPA')--ALTERADO EM 9/5/23--IN('0001','0002','0003','0013','00014')
  ---AND (G.COD_CGERENC1||'.'||G.COD_CGERENC2||'.'||G.COD_CGERENC3||'.'||G.COD_CGERENC4||'.'||G.COD_CGERENC5||'.'||G.COD_CGERENC6 !='000095.000000.000023.000025.000000.000000')
    AND G.DATA_EXTINCAO IS NULL
    AND X.CODIGO_ARTE   IS NOT NULL
    AND X.DATA_CARGA     =
      (SELECT MAX(AUX.DATA_CARGA)
      FROM PONTO_ELETRONICO.ARTERH_SIOM AUX
      WHERE LPAD (SUBSTR(AUX.CODIGO_OPUS,1,2),6,'0')=LPAD (SUBSTR(X.CODIGO_OPUS,1,2),6,'0')
      AND LPAD (SUBSTR(AUX.CODIGO_OPUS,3,2),6,'0')  =LPAD (SUBSTR(X.CODIGO_OPUS,3,2),6,'0')
      AND LPAD (SUBSTR(AUX.CODIGO_OPUS,5,2),6,'0')  =LPAD (SUBSTR(X.CODIGO_OPUS,5,2),6,'0')
      AND LPAD (SUBSTR(AUX.CODIGO_OPUS,7,2),6,'0')  =LPAD (SUBSTR(X.CODIGO_OPUS,7,2),6,'0')
      AND LPAD (SUBSTR(AUX.CODIGO_OPUS,9,2),6,'0')  =LPAD (SUBSTR(X.CODIGO_OPUS,9,2),6,'0')
      AND LPAD (SUBSTR(AUX.CODIGO_OPUS,12,2),6,'0') =LPAD (SUBSTR(X.CODIGO_OPUS,12,2),6,'0')
      )
------------------------- FIM DO FOR
      )
      LOOP
      CONT:=CONT+1;
      BEGIN 
      UPDATE ARTERH.RHORGA_CUSTO_GEREN GN SET GN.COD_ENDERECO=C3.CODIGO_ARTE,GN.LOGIN_USUARIO='INTEGRACAO_SIOM',GN.DT_ULT_ALTER_USUA=SYSDATE,gn.c_livre_selec09='3',GN.c_livre_opcao13='S' WHERE GN.COD_CGERENC1=C3.COD_UNIDADE1
AND GN.COD_CGERENC2=C3.COD_UNIDADE2
AND GN.COD_CGERENC3=C3.COD_UNIDADE3
AND GN.COD_CGERENC4=C3.COD_UNIDADE4
AND GN.COD_CGERENC5=C3.COD_UNIDADE5
AND GN.COD_CGERENC6=C3.COD_UNIDADE6
AND GN.CODIGO_EMPRESA=C3.CODIGO_EMPRESA;
COMMIT;
 exception
              when others then
              NULL;
              END;
----RHORGA_LOTACAO
BEGIN 
UPDATE ARTERH.RHORGA_LOTACAO L SET L.COD_ENDERECO=C3.CODIGO_ARTE,L.LOGIN_USUARIO='INTEGRACAO_SIOM',L.DT_ULT_ALTER_USUA=SYSDATE
WHERE L.COD_LOTACAO1=C3.COD_UNIDADE1
AND L.COD_LOTACAO2=C3.COD_UNIDADE2
AND L.COD_LOTACAO3=C3.COD_UNIDADE3
AND L.COD_LOTACAO4=C3.COD_UNIDADE4
AND L.COD_LOTACAO5=C3.COD_UNIDADE5
AND L.COD_LOTACAO6=C3.COD_UNIDADE6
AND L.CODIGO_EMPRESA=C3.CODIGO_EMPRESA;
COMMIT;
 exception
              when others then
              NULL;
              END;

----- UNIDADE
BEGIN 
UPDATE ARTERH.RHORGA_UNIDADE U SET U.COD_ENDERECO=C3.CODIGO_ARTE,U.LOGIN_USUARIO='INTEGRACAO_SIOM',U.DT_ULT_ALTER_USUA=SYSDATE
WHERE U.COD_UNIDADE1=C3.COD_UNIDADE1
AND U.COD_UNIDADE2=C3.COD_UNIDADE2
AND U.COD_UNIDADE3=C3.COD_UNIDADE3
AND U.COD_UNIDADE4=C3.COD_UNIDADE4
AND U.COD_UNIDADE5=C3.COD_UNIDADE5
AND U.COD_UNIDADE6=C3.COD_UNIDADE6
AND U.CODIGO_EMPRESA=C3.CODIGO_EMPRESA;
COMMIT;
 exception
              when others then
              NULL;
              END;
----- CUSTO_CONTABIL
BEGIN 
UPDATE ARTERH.RHORGA_CUSTO_CONT CT SET CT.COD_ENDERECO=C3.CODIGO_ARTE,CT.LOGIN_USUARIO='INTEGRACAO_SIOM',CT.DT_ULT_ALTER_USUA=SYSDATE
WHERE CT.COD_CCONTAB1=C3.COD_UNIDADE1
AND CT.COD_CCONTAB2=C3.COD_UNIDADE2
AND CT.COD_CCONTAB3=C3.COD_UNIDADE3
AND CT.COD_CCONTAB4=C3.COD_UNIDADE4
AND CT.COD_CCONTAB5=C3.COD_UNIDADE5
AND CT.COD_CCONTAB6=C3.COD_UNIDADE6
AND CT.CODIGO_EMPRESA=C3.CODIGO_EMPRESA;
COMMIT;
 exception
              when others then
              NULL;
              END;
              BEGIN 
UPDATE RHORGA_AGRUPADOR AG SET AG.COD_ENDERECO=C3.CODIGO_ARTE,AG.LOGIN_USUARIO='INTEGRACAO_SIOM',AG.DT_ULT_ALTER_USUA=SYSDATE WHERE AG.TIPO_AGRUP IN ('G','U','L','C')
AND AG.COD_AGRUP1=C3.COD_UNIDADE1
AND AG.COD_AGRUP2=C3.COD_UNIDADE2
AND AG.COD_AGRUP3=C3.COD_UNIDADE3
AND AG.COD_AGRUP4=C3.COD_UNIDADE4
AND AG.COD_AGRUP5=C3.COD_UNIDADE5
AND AG.COD_AGRUP6=C3.COD_UNIDADE6
AND AG.CODIGO_EMPRESA=C3.CODIGO_EMPRESA;
COMMIT;
 exception
              when others then
              NULL;
              END;
              BEGIN 
UPDATE RHORGA_AGRUPADOR_H A SET A.COD_ENDERECO=C3.CODIGO_ARTE,A.LOGIN_USUARIO='INTEGRACAO_SIOM',A.DT_ULT_ALTER_USUA=SYSDATE WHERE A.TIPO_AGRUP IN ('G','U','L','C')
AND A.COD_AGRUP1=C3.COD_UNIDADE1
AND A.COD_AGRUP2=C3.COD_UNIDADE2
AND A.COD_AGRUP3=C3.COD_UNIDADE3
AND A.COD_AGRUP4=C3.COD_UNIDADE4
AND A.COD_AGRUP5=C3.COD_UNIDADE5
AND A.COD_AGRUP6=C3.COD_UNIDADE6
AND A.CODIGO_EMPRESA=C3.CODIGO_EMPRESA
AND A.ANO_MES_REFERENCIA=(SELECT MAX(AUX.ANO_MES_REFERENCIA) FROM RHORGA_AGRUPADOR_H AUX
WHERE AUX.ID_AGRUP=A.ID_AGRUP
AND AUX.TIPO_AGRUP=A.TIPO_AGRUP
AND AUX.CODIGO_EMPRESA=A.CODIGO_EMPRESA);
COMMIT;
 exception
              when others then
              NULL;
              END;
      END LOOP;
      END;
      END;
END;
END;