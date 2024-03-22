
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."SMARH_INT_PE_CAD_HORARIO" (DATA_INICIO IN VARCHAR2, DATA_FIM IN VARCHAR2)
AS
BEGIN
DECLARE
---ALTER TABLE SMARH_INT_PE_JORNADA_V2 ADD(DATA_EXTINCAO DATE , TIPO VARCHAR2(15 BYTE));
vCONTADOR NUMBER;
vDATA_INICIO Varchar2(10);
vDATA_FIM Varchar2(10);
BEGIN
dbms_output.enable(null);
vCONTADOR :=0;
vDATA_INICIO := DATA_INICIO;
vDATA_FIM := DATA_FIM;
FOR C1 IN (
SELECT H.CODIGO_EMPRESA,H.CODIGO,

REGEXP_REPLACE(lpad(TO_CHAR(trim( H.HORARIO_NORMAL_1 )),4,'0'), '([0-9]{2})([0-9]{2})', '\1:\2') AS HORARIO1,
CASE WHEN SUBSTR(H.jornada_diaria,1,2) = '24' AND H.tp_intervalo_esocial = '0' THEN '00:00' ELSE
REGEXP_REPLACE(lpad(TO_CHAR(trim( H.HORARIO_NORMAL_2 )),4,'0'), '([0-9]{2})([0-9]{2})', '\1:\2') END AS HORARIO2,
CASE WHEN SUBSTR(H.jornada_diaria,1,2) = '24' AND H.tp_intervalo_esocial = '0' THEN '00:00' ELSE
REGEXP_REPLACE(lpad(TO_CHAR(trim( H.HORARIO_NORMAL_3 )),4,'0'), '([0-9]{2})([0-9]{2})', '\1:\2') END AS HORARIO3,
CASE WHEN SUBSTR(H.jornada_diaria,1,2) = '24' AND H.tp_intervalo_esocial = '0' THEN REGEXP_REPLACE(lpad(TO_CHAR(trim( H.HORARIO_NORMAL_2 )),4,'0'), '([0-9]{2})([0-9]{2})', '\1:\2') ELSE
REGEXP_REPLACE(lpad(TO_CHAR(trim( H.HORARIO_NORMAL_4 )),4,'0'), '([0-9]{2})([0-9]{2})', '\1:\2')END  AS HORARIO4,
NULL AS HORARIO5,NULL AS HORARIO6,NULL AS HORARIO7,NULL AS HORARIO8,NULL AS HORARIO9,NULL AS HORARIO10,NULL AS HORARIO11, NULL AS HORARIO12,
CASE WHEN H.data_extincao IS NULL THEN 'INCLUIR' ELSE 'EXCLUIR' END AS TIPO,
 H.data_extincao,
SYSDATE AS DT_SAIU_ARTE,
TO_DATE(H.DT_ULT_ALTER_USUA,'DD/MM/RR')AS DTULTIMA_ALTERACAO,
H.DT_ULT_ALTER_USUA,
--comentado em 20/9/22 --REGEXP_REPLACE(rpad(case when length(TO_CHAR(replace(trim( H.qtde_proj_interv ),',','')))=1 then 0||TO_CHAR(replace(trim( H.qtde_proj_interv ),',','')) else TO_CHAR(replace(trim( H.qtde_proj_interv ),',','')) end,4,'0'), '([0-9]{2})([0-9]{2})', '\1:\2')AS INTERVALO_ALMOCO
CASE
WHEN LENGTH(H.qtde_proj_interv) = 1 THEN LPAD(SUBSTR(H.qtde_proj_interv,1,2),2,0)||':00'
WHEN LENGTH(H.qtde_proj_interv) = 2 THEN '00:'||SUBSTR(H.qtde_proj_interv,2,1)||'0'
WHEN LENGTH(H.qtde_proj_interv) = 3 AND SUBSTR(H.qtde_proj_interv,1,1) <> ',' THEN LPAD(SUBSTR(H.qtde_proj_interv,1,1),2,0)||':'||SUBSTR(H.qtde_proj_interv,3,1)||'0'
WHEN LENGTH(H.qtde_proj_interv) = 3 AND SUBSTR(H.qtde_proj_interv,1,1) = ','  THEN '00:'||LPAD(SUBSTR(H.qtde_proj_interv,2,2),2,0)
WHEN LENGTH(H.qtde_proj_interv) = 4 THEN LPAD(SUBSTR(H.qtde_proj_interv,1,1),2,0)||':'||LPAD(SUBSTR(H.qtde_proj_interv,3,2),2,0)
END  INTERVALO_ALMOCO --novo em 20/9/22
FROM ARTERH.RHPONT_HORARIO H
LEFT OUTER JOIN ARTERH.RHORGA_EMPRESA EMP
ON H.CODIGO_EMPRESA=EMP.CODIGO

WHERE EMP.c_livre_selec02=1
 AND (TRUNC(H.DT_ULT_ALTER_USUA) BETWEEN vDATA_INICIO AND vDATA_FIM)
/*  inclui todos os outros horarios tipo N T que fazem parte da escala_horario do horario -- nao incluido 08/03/24
AND  ( H.CODIGO||H.CODIGO_EMPRESA IN (SELECT DISTINCT he2.codigo_horario||HE2.CODIGO_EMPRESA FROM arterh.rhpont_RL_ESC_HOR HE2
                                      LEFT OUTER JOIN ARTERH.RHPONT_HORARIO HR ON HR.CODIGO=HE2.CODIGO_HORARIO AND HR.CODIGO_EMPRESA=HE2.CODIGO_EMPRESA
                                      WHERE he2.codigo_escala IN ( SELECT DISTINCT HE1.CODIGO_ESCALA FROM arterh.rhpont_RL_ESC_HOR HE1
                                                                  LEFT OUTER JOIN ARTERH.RHPONT_HORARIO HO
                                                                  ON HO.CODIGO=HE1.CODIGO_HORARIO
                                                                  AND HO.CODIGO_EMPRESA=HE1.CODIGO_EMPRESA
                                                                  WHERE  TRUNC(HO.DT_ULT_ALTER_USUA) BETWEEN vDATA_INICIO AND vDATA_FIM
                                                                  AND  HO.TIPO_HORARIO IN ('N','T')
                                                                  )
                                     AND  HR.TIPO_HORARIO IN ('N','T')  
                                    AND HE2.CODIGO_EMPRESA = HR.CODIGO_EMPRESA
                  ) 
        )   ---NOVO paulo 06/03/2024 PARA FORÇAR TODOS OS HORARIOS DA MESMA ESCALA HORARIO DE UM HORARIO ALTERADO 
 --OR  TRUNC(H.DT_ULT_ALTER_USUA) BETWEEN vDATA_INICIO AND vDATA_FIM
*/
 )LOOP
 vCONTADOR :=vCONTADOR+1;
dbms_output.put_line(vCONTADOR);
dbms_output.put_line(vDATA_INICIO||'-'||vDATA_FIM);


insert into PONTO_ELETRONICO.SMARH_INT_PE_JORNADA_V2 (CODIGO_EMPRESA, CODIGO, HORARIO1, HORARIO2, HORARIO3, HORARIO4, HORARIO5, HORARIO6, HORARIO7, HORARIO8, HORARIO9, HORARIO10, HORARIO11, HORARIO12, DTULTIMA_ALTERACAO, DT_ULT_ALTER_USUA, DT_SAIU_ARTE,DATA_EXTINCAO,TIPO,INTERVALO_ALMOCO,CODIGO_INTEGRA_ARTE )
VALUES (C1.CODIGO_EMPRESA, C1.CODIGO, C1.HORARIO1, C1.HORARIO2, C1.HORARIO3, C1.HORARIO4, C1.HORARIO5, C1.HORARIO6, C1.HORARIO7, C1.HORARIO8, C1.HORARIO9, C1.HORARIO10, C1.HORARIO11, C1.HORARIO12, C1.DTULTIMA_ALTERACAO, C1.DT_ULT_ALTER_USUA, C1.DT_SAIU_ARTE,C1.DATA_EXTINCAO,C1.TIPO,c1.INTERVALO_ALMOCO,PONTO_ELETRONICO.SEQUENCE_INTEGRA_ARTE.NEXTVAL );
Commit;

 END LOOP;
END;
END;