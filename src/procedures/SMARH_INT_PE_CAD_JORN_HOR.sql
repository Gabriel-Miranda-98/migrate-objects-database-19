
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."SMARH_INT_PE_CAD_JORN_HOR" (DATA_INICIO IN VARCHAR2,DATA_FIM    IN VARCHAR2) AS
BEGIN
  DECLARE
    vCONTADOR        NUMBER;
    vDATA_INICIO     VARCHAR2(10);
    vDATA_FIM        VARCHAR2(10);
    CONT             NUMBER;
    FOLGA            NUMBER;
    TRABALHO         NUMBER;
    POS              NUMBER;
     COD_HORARIO      VARCHAR2(4 byte);
    cod_escala       VARCHAR2(4 byte);
    cod_empresa      VARCHAR2(4 byte);
    TRABALHO_SEGUIDO CHAR(1 BYTE);
    BEGIN
    dbms_output.enable(NULL);
    vCONTADOR    :=0;
    vDATA_INICIO := DATA_INICIO;
    vDATA_FIM    := DATA_FIM;
    FOR C1 IN
    (
SELECT X.* FROM (SELECT he.CODIGO_EMPRESA,
        he.CODIGO_HORARIO AS COD_JORNADA,
        SUBSTR(he.CODIGO_EMPRESA,3,2)||LPAD(he.CODIGO_ESCALA,4,0)  AS COD_ESCALA,
        CASE WHEN he.OCORRENCIA = 7 THEN 0
             ELSE he.OCORRENCIA
             END AS POSICAO,
        CASE WHEN H.tipo_horario = 'F'THEN 0
             WHEN H.tipo_horario = 'C' THEN 0
             ELSE 1
             END AS QTD_TRABALHO,
        CASE WHEN H.tipo_horario = 'F' THEN 1
             WHEN H.tipo_horario = 'C' THEN 1
             ELSE 0
             END AS QTD_FOLGA,
        he.DT_ULT_ALTER_USUA AS DTULTIMA_ALTERACAO,
        he.DT_ULT_ALTER_USUA ,
        SYSDATE AS DT_SAIU_ARTE
        FROM ARTERH.RHPONT_ESCALA E
LEFT OUTER JOIN ARTERH.RHORGA_EMPRESA EMP
ON E.CODIGO_EMPRESA=EMP.CODIGO
LEFT OUTER JOIN ARTERH.RHPONT_RL_ESC_HOR HE
ON HE.CODIGO_EMPRESA=E.CODIGO_EMPRESA
AND HE.CODIGO_ESCALA=E.CODIGO
LEFT OUTER JOIN ARTERH.RHPONT_HORARIO H
ON H.CODIGO_EMPRESA=HE.CODIGO_EMPRESA
AND H.CODIGO=HE.CODIGO_HORARIO
WHERE EMP.c_livre_selec02=1
AND E.c_livre_selec3     = '1'
AND (E.TIPO_ESCALA    IS NOT NULL AND E.TIPO_ESCALA     IN ('1','2','3'))
AND (E.c_livre_selec2 IS NOT NULL AND E.c_livre_selec2  IN ('1','2','3'))
AND (E.c_livre_selec3 IS NOT NULL AND E.c_livre_selec3   = '1')
AND E.TIPO_ESCALA    = '1'
AND HE.OCORRENCIA     IN (1,2,3,4,5,6,7)
AND (
(TRUNC(E.DT_ULT_ALTER_USUA) BETWEEN vDATA_INICIO AND vDATA_FIM )
OR
EXISTS
( SELECT AUX.* FROM ARTERH.RHPONT_RL_ESC_HOR AUX
WHERE AUX.CODIGO_EMPRESA = HE.CODIGO_EMPRESA
AND AUX.CODIGO_ESCALA = HE.CODIGO_ESCALA
AND (TRUNC(AUX.DT_ULT_ALTER_USUA) BETWEEN  vDATA_INICIO AND vDATA_FIM)
)
/* or 
--TRUNC(h.DT_ULT_ALTER_USUA) BETWEEN  vDATA_INICIO AND vDATA_FIM
((
      SELECT COUNT(1) FROM arterh.rhpont_horario H1                                                 -- INCLUIDO EM 30/01/24 IMPEDIR INTERGRAÇÃO INCOOMPLETA
      WHERE H1.CODIGO IN ( SELECT EH1.CODIGO_HORARIO FROM arterh.rhpont_rl_esc_hor EH1 
                            WHERE EH1.CODIGO_EMPRESA = HE.CODIGO_EMPRESA
                            AND EH1.CODIGO_ESCALA=HE.CODIGO_ESCALA)
      AND (TRUNC(H1.DT_ULT_ALTER_USUA) BETWEEN vDATA_INICIO AND vDATA_FIM) 
      AND  H1.TIPO_HORARIO IN ('N','T') 
      ) >'0')  */  --retirado em 08/03/24

)
)x
group BY X.CODIGO_EMPRESA,X.COD_JORNADA,X.COD_ESCALA,X.POSICAO,X.QTD_TRABALHO,X.QTD_FOLGA,X.DTULTIMA_ALTERACAO,X.DT_ULT_ALTER_USUA,X.DT_SAIU_ARTE
ORDER BY X.CODIGO_EMPRESA,X.COD_ESCALA,X.POSICAO
)
LOOP
 vCONTADOR :=vCONTADOR+1;
      dbms_output.put_line(vCONTADOR);
      dbms_output.put_line(vDATA_INICIO||'-'||vDATA_FIM);
      INSERT
      INTO PONTO_ELETRONICO.SMARH_INT_PE_JORN_ESCALA_V2
        (
          CODIGO_EMPRESA,
          COD_JORNADA,
          COD_ESCALA,
          POSICAO,
          QTD_TRABALHO,
          QTD_FOLGA,
          DTULTIMA_ALTERACAO,
          DT_ULT_ALTER_USUA,
          DT_SAIU_ARTE
          ,CODIGO_INTEGRA_ARTE 
        )
        VALUES
        (
          C1.CODIGO_EMPRESA,
          C1.COD_JORNADA,
          C1.COD_ESCALA,
          C1.POSICAO,
          C1.QTD_TRABALHO,
          C1.QTD_FOLGA,
          C1.DTULTIMA_ALTERACAO,
          C1.DT_ULT_ALTER_USUA,
          C1.DT_SAIU_ARTE
          ,PONTO_ELETRONICO.SEQUENCE_INTEGRA_ARTE.NEXTVAL 
        );
      COMMIT;
END LOOP;
 BEGIN
    TRABALHO_SEGUIDO:='N';
    dbms_output.enable(NULL);
    vCONTADOR :=0;
    POS       :=1;
    FOLGA     :=0;
    CONT      :=0;
    TRABALHO  :=0;
    FOR C1 IN
    (SELECT RANK() OVER( PARTITION BY codigo_empresa,codigo_escala ORDER BY codigo_empresa,codigo_escala,POSICAO ) AS ordem,
      X.codigo_empresa,
      x.codigo_escala,
      x.horario,
      x.posicao,
      x.DTULTIMA_ALTERACAO,
      x.DT_ULT_ALTER_USUA,
      x.DT_SAIU_ARTE,
      x.QTD_TRABALHO,
      x.QTD_FOLGA
    FROM
      (SELECT *
      FROM
        (SELECT EMP.CODIGO AS CODIGO_EMPRESA,
          E.CODIGO         AS CODIGO_ESCALA ,
          EH.OCORRENCIA    AS POSICAO,
          H.CODIGO         AS HORARIO,
          H.DESCRICAO,
          CASE
            WHEN H.TIPO_HORARIO IN ('N','T')
            THEN 'TRABALHO'
            ELSE 'FOLGA'
          END                  AS TIPO_HORARIO,
          EH.DT_ULT_ALTER_USUA AS DTULTIMA_ALTERACAO,
          EH.DT_ULT_ALTER_USUA ,
          SYSDATE AS DT_SAIU_ARTE
        FROM ARTERH.RHPONT_ESCALA E
        LEFT OUTER JOIN ARTERH.RHORGA_EMPRESA EMP
        ON EMP.CODIGO=E.CODIGO_EMPRESA
        LEFT OUTER JOIN ARTERH.RHPONT_RL_ESC_HOR EH
        ON EH.CODIGO_EMPRESA=E.CODIGO_EMPRESA
        AND EH.CODIGO_ESCALA=E.CODIGO
        LEFT OUTER JOIN ARTERH.RHPONT_HORARIO H
        ON H.CODIGO              =EH.CODIGO_HORARIO
        AND H.CODIGO_EMPRESA     =EH.CODIGO_EMPRESA
        WHERE EMP.c_livre_selec02=1
        AND E.c_livre_selec3     = '1'
          AND (
          (TRUNC(E.DT_ULT_ALTER_USUA) BETWEEN  vDATA_INICIO AND vDATA_FIM )
          OR
          EXISTS
          ( SELECT AUX.* FROM ARTERH.RHPONT_RL_ESC_HOR AUX
          WHERE AUX.CODIGO_EMPRESA = EH.CODIGO_EMPRESA
          AND AUX.CODIGO_ESCALA = EH.CODIGO_ESCALA
          AND (TRUNC(AUX.DT_ULT_ALTER_USUA) BETWEEN  vDATA_INICIO AND vDATA_FIM)
          )
          or 
        --TRUNC(h.DT_ULT_ALTER_USUA) BETWEEN  vDATA_INICIO AND vDATA_FIM
        ((
              SELECT COUNT(1) FROM arterh.rhpont_horario H1                                                 -- INCLUIDO EM 30/01/24 IMPEDIR INTERGRAÇÃO INCOOMPLETA
              WHERE H1.CODIGO IN ( SELECT EH1.CODIGO_HORARIO FROM arterh.rhpont_rl_esc_hor EH1 
                                    WHERE EH1.CODIGO_EMPRESA = EH.CODIGO_EMPRESA
                                    AND EH1.CODIGO_ESCALA=EH.CODIGO_ESCALA)
              AND (TRUNC(H1.DT_ULT_ALTER_USUA) BETWEEN  vDATA_INICIO AND vDATA_FIM) 
              AND  H1.TIPO_HORARIO IN ('N','T') 
              ) >'0')
          )

        AND (E.TIPO_ESCALA    IS NOT NULL
        AND E.TIPO_ESCALA     <>'1')
        AND (E.c_livre_selec2 IS NOT NULL
        AND E.c_livre_selec2  IN ('1','2','3'))
        AND (E.c_livre_selec3 IS NOT NULL
        AND E.c_livre_selec3   = '1')
        ORDER BY e.codigo,
          POSICAO
        ) pivot ( COUNT(TIPO_HORARIO) FOR TIPO_HORARIO IN ('TRABALHO'AS QTD_TRABALHO,'FOLGA' AS QTD_FOLGA) )
      ORDER BY codigo_escala,
        POSICAO
      )X
    )
    LOOP
     IF CONT       =0 THEN
          cod_escala :=C1.CODIGO_ESCALA;
          cod_empresa:=C1.CODIGO_EMPRESA;
        ELSIF CONT   <>0 AND (cod_escala<>C1.CODIGO_ESCALA OR COD_EMPRESA<>C1.CODIGO_EMPRESA) THEN
          --  dbms_output.put_line('ENTROU2'||CONT);
          cod_escala :=C1.CODIGO_ESCALA;
          cod_empresa:=C1.CODIGO_EMPRESA;
          POS        :=1;
          CONT       :=0;
        END IF;

      IF POS          =C1.POSICAO THEN

        IF c1.ordem=1 AND C1.QTD_FOLGA=1 THEN
          FOLGA   :=0;
          CONT    :=CONT+1;
          FOR c2       IN
          (SELECT X.*
          FROM
            (SELECT *
            FROM
              (SELECT E.CODIGO AS CODIGO_ESCALA ,
                EH.OCORRENCIA  AS POSICAO,
                H.CODIGO       AS HORARIO,
                H.DESCRICAO,
                CASE
                  WHEN H.TIPO_HORARIO IN ('N','T')
                  THEN 'TRABALHO'
                  ELSE 'FOLGA'
                END AS TIPO_HORARIO
              FROM ARTERH.RHPONT_ESCALA E
              LEFT OUTER JOIN ARTERH.RHORGA_EMPRESA EMP
              ON EMP.CODIGO=E.CODIGO_EMPRESA
              LEFT OUTER JOIN ARTERH.RHPONT_RL_ESC_HOR EH
              ON EH.CODIGO_EMPRESA=E.CODIGO_EMPRESA
              AND EH.CODIGO_ESCALA=E.CODIGO
              LEFT OUTER JOIN ARTERH.RHPONT_HORARIO H
              ON H.CODIGO              =EH.CODIGO_HORARIO
              AND H.CODIGO_EMPRESA     =EH.CODIGO_EMPRESA
              WHERE EMP.c_livre_selec02=1
              AND E.CODIGO             =c1.codigo_escala
              AND EMP.CODIGO           =C1.CODIGO_EMPRESA
              AND (E.TIPO_ESCALA      IS NOT NULL
              AND E.TIPO_ESCALA       <>'1')
              AND (E.c_livre_selec2   IS NOT NULL
              AND E.c_livre_selec2    IN ('1','2','3'))
              AND (E.c_livre_selec3   IS NOT NULL
              AND E.c_livre_selec3     = '1')
              ORDER BY POSICAO
              ) pivot ( COUNT(TIPO_HORARIO) FOR TIPO_HORARIO IN ('TRABALHO'AS QTD_TRABALHO,'FOLGA' AS QTD_FOLGA) )
            ORDER BY POSICAO
            )X
          WHERE x.posicao>=pos
          )
          LOOP
            IF c2.QTD_FOLGA !=0 THEN
              FOLGA         := FOLGA+ 1;
           pos:= pos+1;

            END IF;
            EXIT
          WHEN c2.QTD_TRABALHO=1 AND FOLGA<>0;
          END LOOP;
           INSERT
          INTO PONTO_ELETRONICO.SMARH_INT_PE_JORN_ESCALA_V2
          (
          CODIGO_EMPRESA,
          COD_JORNADA,
          COD_ESCALA,
          POSICAO,
          QTD_TRABALHO,
          QTD_FOLGA,
          DTULTIMA_ALTERACAO,
          DT_ULT_ALTER_USUA,
          DT_SAIU_ARTE
          ,CODIGO_INTEGRA_ARTE
          )
          VALUES
          (
          C1.CODIGO_EMPRESA,
          c1.horario,
          SUBSTR(C1.CODIGO_EMPRESA,3,2)||LPAD(c1.codigo_escala,4,0),
          CONT,
          C1.QTD_TRABALHO,
          FOLGA,
          C1.DTULTIMA_ALTERACAO,
          C1.DT_ULT_ALTER_USUA,
          C1.DT_SAIU_ARTE
          ,PONTO_ELETRONICO.SEQUENCE_INTEGRA_ARTE.NEXTVAL 
          );
          COMMIT;
          dbms_output.put_line('dados escala:'||'poscicao:'||CONT||'-codigo_escala:'||c1.codigo_escala||'-horario:'||c1.horario ||'-QTD_TRABALHO:'||0||'-QTD_FOLGA:'||FOLGA);
        elsif c1.QTD_TRABALHO=1 THEN
          CONT              :=CONT+1;
          POS               :=C1.POSICAO;
          TRABALHO          :=c1.QTD_TRABALHO;
          FOLGA             :=0;
      FOR x IN (
          SELECT
            CASE
              WHEN X.QTD_TRABALHO<>0
              THEN'S'
              ELSE 'N'
            END AS TRABALHO_SEGUINTE,HORARIO
         -- INTO TRABALHO_SEGUIDO,COD_HORARIO
          FROM
            (SELECT *
            FROM
              (SELECT E.CODIGO AS CODIGO_ESCALA ,
                EH.OCORRENCIA  AS POSICAO,
                H.CODIGO       AS HORARIO,
                H.DESCRICAO,
                CASE
                  WHEN H.TIPO_HORARIO IN ('N','T')
                  THEN 'TRABALHO'
                  ELSE 'FOLGA'
                END AS TIPO_HORARIO
              FROM ARTERH.RHPONT_ESCALA E
              LEFT OUTER JOIN ARTERH.RHORGA_EMPRESA EMP
              ON EMP.CODIGO=E.CODIGO_EMPRESA
              LEFT OUTER JOIN ARTERH.RHPONT_RL_ESC_HOR EH
              ON EH.CODIGO_EMPRESA=E.CODIGO_EMPRESA
              AND EH.CODIGO_ESCALA=E.CODIGO
              LEFT OUTER JOIN ARTERH.RHPONT_HORARIO H
              ON H.CODIGO              =EH.CODIGO_HORARIO
              AND H.CODIGO_EMPRESA     =EH.CODIGO_EMPRESA
              WHERE EMP.c_livre_selec02=1
              AND E.CODIGO             =c1.codigo_escala
              AND (E.TIPO_ESCALA      IS NOT NULL
              AND E.TIPO_ESCALA       <>'1')
              AND (E.c_livre_selec2   IS NOT NULL
              AND E.c_livre_selec2    IN ('1','2','3'))
              AND (E.c_livre_selec3   IS NOT NULL
              AND E.c_livre_selec3     = '1')
              AND EMP.CODIGO           =C1.CODIGO_EMPRESA
              ORDER BY POSICAO
              ) pivot ( COUNT(TIPO_HORARIO) FOR TIPO_HORARIO IN ('TRABALHO'AS QTD_TRABALHO,'FOLGA' AS QTD_FOLGA) )
            ORDER BY POSICAO
            )X
          WHERE x.posicao    >POS)LOOP
          TRABALHO_SEGUIDO:=X.TRABALHO_SEGUINTE;
          COD_HORARIO:=X.HORARIO;
          IF TRABALHO_SEGUIDO='S'  AND C1.HORARIO=COD_HORARIO THEN
            TRABALHO        :=TRABALHO+1;
            POS             :=POS     +1;
          END IF;
            EXIT
          WHEN ((TRABALHO_SEGUIDO='N') OR (C1.HORARIO!=COD_HORARIO));
          END LOOP;

          FOR c3 IN
          (SELECT X.*
          FROM
            (SELECT *
            FROM
              (SELECT E.CODIGO AS CODIGO_ESCALA ,
                EH.OCORRENCIA  AS POSICAO,
                H.CODIGO       AS HORARIO,
                H.DESCRICAO,
                CASE
                  WHEN H.TIPO_HORARIO IN ('N','T')
                  THEN 'TRABALHO'
                  ELSE 'FOLGA'
                END AS TIPO_HORARIO
              FROM ARTERH.RHPONT_ESCALA E
              LEFT OUTER JOIN ARTERH.RHORGA_EMPRESA EMP
              ON EMP.CODIGO=E.CODIGO_EMPRESA
              LEFT OUTER JOIN ARTERH.RHPONT_RL_ESC_HOR EH
              ON EH.CODIGO_EMPRESA=E.CODIGO_EMPRESA
              AND EH.CODIGO_ESCALA=E.CODIGO
              LEFT OUTER JOIN ARTERH.RHPONT_HORARIO H
              ON H.CODIGO              =EH.CODIGO_HORARIO
              AND H.CODIGO_EMPRESA     =EH.CODIGO_EMPRESA
              WHERE EMP.c_livre_selec02=1
              AND E.CODIGO             =c1.codigo_escala
              AND (E.TIPO_ESCALA      IS NOT NULL
              AND E.TIPO_ESCALA       <>'1')
              AND (E.c_livre_selec2   IS NOT NULL
              AND E.c_livre_selec2    IN ('1','2','3'))
              AND (E.c_livre_selec3   IS NOT NULL
              AND E.c_livre_selec3     = '1')
              AND EMP.CODIGO           =C1.CODIGO_EMPRESA
              ORDER BY POSICAO
              ) pivot ( COUNT(TIPO_HORARIO) FOR TIPO_HORARIO IN ('TRABALHO'AS QTD_TRABALHO,'FOLGA' AS QTD_FOLGA) )
            ORDER BY POSICAO
            )X
          WHERE x.posicao>POS
          )
          LOOP
            POS             :=POS+1;
            IF c3.QTD_FOLGA !=0 THEN
              FOLGA         := FOLGA+ 1;
            END IF;
            EXIT
          WHEN ((TRABALHO>=1 AND c3.QTD_TRABALHO=1));
          END LOOP;
         INSERT
          INTO PONTO_ELETRONICO.SMARH_INT_PE_JORN_ESCALA_V2
          (
          CODIGO_EMPRESA,
          COD_JORNADA,
          COD_ESCALA,
          POSICAO,
          QTD_TRABALHO,
          QTD_FOLGA,
          DTULTIMA_ALTERACAO,
          DT_ULT_ALTER_USUA,
          DT_SAIU_ARTE
          ,CODIGO_INTEGRA_ARTE
          )
          VALUES
          (
          C1.CODIGO_EMPRESA,
          c1.horario,
          SUBSTR(C1.CODIGO_EMPRESA,3,2)||LPAD(c1.codigo_escala,4,0),
          CONT,
          TRABALHO,
          FOLGA,
          C1.DTULTIMA_ALTERACAO,
          C1.DT_ULT_ALTER_USUA,
          C1.DT_SAIU_ARTE
          ,PONTO_ELETRONICO.SEQUENCE_INTEGRA_ARTE.NEXTVAL 
          );
       ---   dbms_output.put_line('dados escala:'||'poscicao:'||CONT||'-codigo_escala:'||c1.codigo_escala||'-horario:'||c1.horario ||'-QTD_TRABALHO:'||TRABALHO||'-QTD_FOLGA:'||FOLGA);
        END IF;
      END IF;
    END LOOP;
  END;
END;
END;