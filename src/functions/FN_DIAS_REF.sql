
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."FN_DIAS_REF" (pEMPRESA char, pTIPO_CONTRATO char, pCPF varchar2,pCONTRATO varchar2,pDATA_REF date ,pDATA_REF_FREQ date) RETURN TB_VALOR_DIAS_VALE  PIPELINED IS 

    CONT              NUMBER;
    V_MOD             NUMBER;
    qtd_dias_ciclo    NUMBER;
    DT_INI            DATE;
    DT_FIM            DATE;
    direito           NUMBER;
    DATA_LOOP         DATE;
    NRO_DIAS          NUMBER;
    QTD_DIAS_TRABALHO NUMBER;
    v_OCORRENCIA      NUMBER;
    V_HORARIO         CHAR (4 BYTE);
    V_SITUACAO        VARCHAR2(20 BYTE);
    sit_pont       NUMBER;
    qtd_dias_ferias number;
    DATA_OCORRENCIA   DATE;
    DIA_UTIL DATE;
    RET VALOR_DIAS_VALE;
    DT_INI_SIT DATE;
    DT_FIM_SIT DATE;
    MES_COMPLETO_AFASTAMENTO CHAR (1 BYTE);
    
    /*INICIO FUNCTION DIA_TRABALHO*/
    FUNCTION DIA_TRABALHO( tp_cont CHAR, vempresa CHAR, vcontrato VARCHAR2, DIA DATE)  RETURN NUMBER
    AS
      QTD_DIAS       NUMBER;
      qtd_dias_ciclo NUMBER;
      FERIADOS       NUMBER;
    BEGIN
      QTD_DIAS:=0;

      FOR C1 IN
      (SELECT AE.CODIGO_EMPRESA,AE.CODIGO_CONTRATO,AE.DT_INICIO_TROCA,AE.DT_FIM_TROCA,COD_ESCALA AS CODIGO_ESCALA,EL.DATA_BASE
      FROM RHPONT_ALT_ESCALA AE
      LEFT OUTER JOIN RHPONT_ESCALA EL
      ON EL.CODIGO             =AE.COD_ESCALA
      AND EL.CODIGO_EMPRESA    =AE.CODIGO_EMPRESA
      WHERE AE.CODIGO_CONTRATO =vcontrato
      AND ae.tipo_contrato     =tp_cont
      AND ae.codigo_empresa    =vempresa
      AND ((AE.DT_FIM_TROCA   IS NULL)
      OR (AE.DT_FIM_TROCA     >=DIA))
      )
      LOOP
          SELECT COUNT(1)QUANT
          INTO qtd_dias_ciclo
          FROM RHPONT_RL_ESC_HOR AUX
          WHERE AUX.CODIGO_EMPRESA=c1.codigo_empresa
          AND aux.codigo_escala   =c1.codigo_escala;
          V_MOD                  :=MOD(DIA-C1.DATA_BASE,qtd_dias_ciclo)+1;
        -- dbms_output.put_line('DIA :'||DATA_OCORRENCIA||'-- MOD: '||V_MOD);
          SELECT X.OCORRENCIA,X.HORARIO,X.SITUACAO
          INTO v_OCORRENCIA,V_HORARIO,V_SITUACAO
          FROM
            (SELECT E.DATA_BASE,EH.CODIGO_ESCALA,EH.OCORRENCIA,H.CODIGO AS HORARIO,
              CASE
                WHEN H.TIPO_HORARIO IN ('T','N')
                THEN'TRABALHO'
                ELSE 'FOLGA'
              END AS SITUACAO
            FROM RHPONT_RL_ESC_HOR EH
            LEFT OUTER JOIN RHPONT_HORARIO H
            ON H.CODIGO_EMPRESA=EH.CODIGO_EMPRESA
            AND H.CODIGO       =EH.CODIGO_HORARIO
            LEFT OUTER JOIN RHPONT_ESCALA E
            ON E.CODIGO            =EH.CODIGO_ESCALA
            AND E.CODIGO_EMPRESA   =EH.CODIGO_EMPRESA
            WHERE EH.CODIGO_EMPRESA=C1.CODIGO_EMPRESA
            AND e.codIGO           =C1.CODIGO_ESCALA
            )X
          WHERE X.OCORRENCIA=V_MOD;
        
        IF V_SITUACAO     ='TRABALHO' THEN
              SELECT COUNT(1)QUANT
              INTO FERIADOS
              FROM
                (SELECT D.NRO_DIA_SEMANA,
                  D.DIA_SEMANA ,
                  CASE
                    WHEN T.DESCRICAO IS NULL
                    THEN 'DIA NORMAL'
                    ELSE T.DESCRICAO
                  END TIPO_DATA
                  /*INTO vNRO_DIA_SEMANA,
                  vDIA_SEMANA,
                  vTIPO_DATA*/
                FROM RHTABS_DATAS D
                LEFT OUTER JOIN RHPARM_CALEND_DT C
                ON TRUNC(C.DATA_DIA)= TRUNC(D.DATA_DIA)
                AND c.codigo        = '0001'
                LEFT OUTER JOIN rhparm_p_calend T
                ON T.CTRL_PONTO         = C.CALEND
                AND T.CODIGO_P_CALEND   = C.CODIGO
                WHERE TRUNC(D.DATA_DIA) = TRUNC(DIA)
                )X
              WHERE TRIM(TIPO_DATA)='FERIADO';

              IF (FERIADOS>0) THEN
                QTD_DIAS :=0;
              ELSE
                QTD_DIAS :=1;
              END IF;
          
        ELSE
          QTD_DIAS :=0;
        END IF;
        
      END LOOP;
      -- dbms_output.put_line(QTD_DIAS);
      RETURN QTD_DIAS;
    END;
    
   /*FIM FUNCTION DIA_TRABALHO*/  
   
   
  /*INICIO FUNCTION FN_DIAS_REF */
  BEGIN
    CONT             :=0;
    direito          :=0;
    QTD_DIAS_TRABALHO:=0;
    RET:=VALOR_DIAS_VALE(NULL,NULL,NULL);
    --sit_pont:=0;
    DT_INI:=TO_DATE(pDATA_REF,'DD/MM/YYYY');
    DT_FIM:=LAST_DAY(TO_DATE(pDATA_REF,'DD/MM/YYYY'));
    --dbms_output.put_line(pCONTRATO);
    BEGIN 
      
      SELECT DATA_INI,DATA_FIM
      INTO  DT_INI_SIT,    DT_FIM_SIT 
      FROM (    
        SELECT af.codigo_empresa, af.tipo_contrato, af.codigo,
        CASE WHEN to_date(af.data_inic_situacao, 'DD/MM/YYYY') < TO_DATE(DT_INI, 'DD/MM/YYYY') THEN TO_DATE(DT_INI, 'DD/MM/YYYY') ELSE af.data_inic_situacao END AS data_ini,
        CASE WHEN to_date(af.data_FIM_situacao, 'DD/MM/YYYY') > TO_DATE(DT_FIM, 'DD/MM/YYYY') THEN TO_DATE(DT_FIM, 'DD/MM/YYYY') ELSE to_date(af.data_FIM_situacao, 'DD/MM/YYYY') END AS data_FIM
        FROM rhcged_alt_sit_fun af
        LEFT OUTER JOIN rhparm_sit_func sf 
        ON af.cod_sit_funcional = sf.codigo
        WHERE AF.CODIGO=pCONTRATO
        AND AF.TIPO_CONTRATO=pTIPO_CONTRATO
        AND AF.CODIGO_EMPRESA=pEMPRESA
        AND sf.suspende_vale = 'S'
        AND sf.controle_folha NOT IN ( 'D', 'S' )
        AND ( af.cod_sit_funcional < '1715' OR af.cod_sit_funcional = '1800' )
        AND ( ( af.data_fim_situacao IS NULL ) OR ( TO_DATE(af.data_fim_situacao, 'dd/mm/yyyy') >= TO_DATE(DT_INI, 'dd/mm/yyyy') ) )
        AND ( sf.data_fim_vigencia IS NULL OR TO_DATE(sf.data_fim_vigencia, 'dd/mm/yyyy') >= TO_DATE(DT_INI, 'dd/mm/yyyy') )
    )X;

    IF ((DT_FIM_SIT >=DT_FIM) OR (DT_INI_SIT IS NOT NULL AND DT_FIM_SIT IS NULL )) THEN    
        MES_COMPLETO_AFASTAMENTO:='S';
    ELSIF DT_FIM_SIT<DT_FIM THEN 
        DT_INI:=DT_FIM_SIT+1;
        MES_COMPLETO_AFASTAMENTO:='N';
    END IF;
    
    exception
           when NO_DATA_FOUND then
               DT_FIM_SIT:=NULL ;
               DT_INI_SIT:=NULL;
               MES_COMPLETO_AFASTAMENTO:='N';
    END;


      IF MES_COMPLETO_AFASTAMENTO='N' THEN 
            NRO_DIAS:=(DT_FIM-DT_INI);
            
            if pDATA_REF_FREQ is not null then 
                SELECT count(1)quant
                into sit_pont
                FROM RHPONT_RES_SIT_DIA pt
                left outer join RHPONT_SITUACAO SP
                ON SP.CODIGO=PT.CODIGO_SITUACAO
                WHERE PT.CODIGO_CONTRATO=LPAD(pCONTRATO,15,0)
                and PT.codigo_empresa=pEMPRESA
                and PT.tipo_contrato=pTIPO_CONTRATO
                AND PT.DATA BETWEEN to_date(pDATA_REF_FREQ,'dd/mm/yyyy') AND LAST_DAY(to_date(pDATA_REF_FREQ,'dd/mm/yyyy'))
                AND SP.FALTA_VALE='S'
                AND PT.FORCA_SITUACAO='N';
            end if;


      FOR I           IN 0..NRO_DIAS
      LOOP
        DATA_LOOP:=(DT_INI+I);
         dbms_output.put_line(DATA_LOOP);
        SELECT COUNT(1)quant
        INTO direito
        FROM
          (SELECT VL.CODIGO_EMPRESA,
            VL.TIPO_CONTRATO,
            P.CPF,
            VL.CODIGO_CONTRATO,
            P.CODIGO      AS CODIGO_PESSOA,
            P.NOME_ACESSO AS NOME,
            VL.CODIGO_ITINERARIO,
            vl.codigo_linha,
            LI.DESCRICAO,
            VL.DATA_INI_VIGENCIA,
            VL.DATA_FIM_VIGENCIA ,
            VL.DT_ULT_ALTER_USUA,
            VL.TEXTO_ASSOCIADO
          FROM RHVALE_TRANSPORTE VL
          LEFT OUTER JOIN RHVALE_ITINERARIO IT
          ON IT.CODIGO=VL.CODIGO_ITINERARIO
          LEFT OUTER JOIN RHVALE_LINHA_TRANS LI
          ON LI.CODIGO    =VL.CODIGO_LINHA
          AND IT.TIPO_VALE=LI.TIPO_VALE
          LEFT OUTER JOIN
            (SELECT *
            FROM RHPESS_CONTRATO CN
            WHERE CN.ANO_MES_REFERENCIA=
              (SELECT MAX(AUX.ANO_MES_REFERENCIA)
              FROM RHPESS_CONTRATO AUX
              WHERE AUX.TIPO_CONTRATO=CN.TIPO_CONTRATO
              AND AUX.CODIGO_EMPRESA =CN.CODIGO_EMPRESA
              AND AUX.CODIGO         = CN.CODIGO
              )
            ) CN
          ON CN.CODIGO         =VL.CODIGO_CONTRATO
          AND CN.TIPO_CONTRATO =VL.TIPO_CONTRATO
          AND CN.CODIGO_EMPRESA=VL.CODIGO_EMPRESA
          LEFT OUTER JOIN RHPESS_PESSOA P
          ON P.CODIGO                 =CN.CODIGO_PESSOA
          AND P.CODIGO_EMPRESA        =CN.CODIGO_EMPRESA
          WHERE VL.CODIGO_EMPRESA     =pEMPRESA
          AND VL.TIPO_CONTRATO        =pTIPO_CONTRATO
          AND LI.TIPO_VALE            ='0002'
          AND P.CPF                   =pCPF
          AND VL.CODIGO_LINHA NOT    IN ('000000000000900')
          AND VL.DATA_INI_VIGENCIA   <=TO_DATE(DATA_LOOP,'DD/MM/YYYY')
          AND ((VL.DATA_FIM_VIGENCIA IS NULL )
          OR (VL.DATA_FIM_VIGENCIA   >=TO_DATE(DATA_LOOP,'DD/MM/YYYY')))
          )X;
          ---pEMPRESA char, pTIPO_CONTRATO char, pCPF varchar2,pCONTRATO
        ----    dbms_output.put_line(direito);
        IF direito         >=0 THEN
          QTD_DIAS_TRABALHO:=((QTD_DIAS_TRABALHO+DIA_TRABALHO(pTIPO_CONTRATO,pEMPRESA,pCONTRATO,DATA_LOOP)));

        END IF;
      END LOOP;

BEGIN 
QTD_DIAS_FERIAS:=0;
FOR C1 IN (
  SELECT 'UTEIS' AS TIPO,x.DT_INI_GOZO,x.DT_FIM_GOZO,(x.DT_FIM_GOZO-x.DT_INI_GOZO)+1 AS NRO_DIAS
    FROM
      (SELECT CASE WHEN F.DT_INI_GOZO<DT_INI THEN DT_INI ELSE F.DT_INI_GOZO END AS DT_INI_GOZO,
        CASE WHEN F.DT_FIM_GOZO >DT_FIM THEN DT_FIM ELSE F.DT_FIM_GOZO END AS DT_FIM_GOZO
      FROM RHFERI_FERIAS F
      LEFT OUTER JOIN RHPARM_P_FERI PF
      ON PF.CODIGO             =F.TIPO_FERIAS
      AND PF.CODIGO_EMPRESA    =F.CODIGO_EMPRESA
      WHERE PF.SITUACAO_PONTO IN ('0029','0521','1003','1126','1156')
      AND (
      (F.DT_INI_GOZO BETWEEN DT_INI AND DT_FIM)
      OR (F.DT_FIM_GOZO BETWEEN DT_INI AND DT_FIM)
      OR(F.DT_INI_GOZO<=DT_INI AND  F.DT_FIM_GOZO >=DT_FIM)
      )
      AND F.CODIGO_CONTRATO   =pCONTRATO
      AND F.CODIGO_EMPRESA    =pEMPRESA
      AND F.TIPO_CONTRATO     =pTIPO_CONTRATO
      AND F.STATUS_CONFIRMACAO='1'
      AND PF.TIPO_INTER_GOZO  ='U'
      )X


  UNION ALL
 SELECT 'CORRIDO' AS TIPO,x.DT_INI_GOZO,x.DT_FIM_GOZO,(x.DT_FIM_GOZO-x.DT_INI_GOZO)+1 AS NRO_DIAS
    FROM
      (SELECT CASE WHEN F.DT_INI_GOZO<DT_INI THEN DT_INI ELSE F.DT_INI_GOZO END AS DT_INI_GOZO,
        CASE
          WHEN F.DT_FIM_GOZO >DT_FIM
          THEN DT_FIM
          ELSE F.DT_FIM_GOZO
        END AS DT_FIM_GOZO
      FROM RHFERI_FERIAS F
      LEFT OUTER JOIN RHPARM_P_FERI PF
      ON PF.CODIGO             =F.TIPO_FERIAS
      AND PF.CODIGO_EMPRESA    =F.CODIGO_EMPRESA
      WHERE PF.SITUACAO_PONTO IN ('0029','0521','1003','1126','1156')
       AND (
      (F.DT_INI_GOZO BETWEEN DT_INI AND DT_FIM)
      OR (F.DT_FIM_GOZO BETWEEN DT_INI AND DT_FIM)
      OR(F.DT_INI_GOZO<=DT_INI AND  F.DT_FIM_GOZO >=DT_FIM)
      )

    AND F.CODIGO_CONTRATO   =pCONTRATO
      AND F.CODIGO_EMPRESA    =pEMPRESA
      AND F.TIPO_CONTRATO     =pTIPO_CONTRATO
      AND F.STATUS_CONFIRMACAO='1'
      AND PF.TIPO_INTER_GOZO  ='C'
      )X
 )LOOP
 IF C1.TIPO='CORRIDO'THEN 
 QTD_DIAS_FERIAS:=QTD_DIAS_FERIAS+C1.NRO_DIAS;
 END IF;
 IF C1.TIPO='UTEIS'THEN 
 FOR I IN 0..c1.NRO_DIAS-1 LOOP
  DIA_UTIL:=C1.DT_INI_GOZO+I;
   dbms_output.put_line( DIA_UTIL||'--'||tO_CHAR(DIA_UTIL,'DAY'));
   IF TRIM(TO_CHAR(DIA_UTIL,'DAY'))NOT IN ('SÁBADO','DOMINGO') THEN 
   QTD_DIAS_FERIAS:=QTD_DIAS_FERIAS+1;
   END IF;
 END LOOP;
 END IF;
 END LOOP;

 END;
END IF;



           QTD_DIAS_TRABALHO:=QTD_DIAS_TRABALHO-qtd_dias_ferias-sit_pont;
           RET.QTD_TRABALHO_MES:=QTD_DIAS_TRABALHO;
           RET.QTD_OCORRENCIA_MES:=sit_pont;
           RET.QTD_DIAS_FERIAS_MES:=qtd_dias_ferias;
          PIPE ROW (RET);
   RETURN;
  END;