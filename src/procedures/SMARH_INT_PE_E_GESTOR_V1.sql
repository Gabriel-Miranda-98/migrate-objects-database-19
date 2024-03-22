
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."SMARH_INT_PE_E_GESTOR_V1" AS
CONT NUMBER;


BEGIN
--KELLYSSON 27/11/18
--GRAVAR SE A PESSOA É GESTORA NO ULTIMO DIA
/*UPDATE  ponto_eletronico.sugesp_bi_1contrat_intif_arte u SET U.E_GESTOR='S' WHERE        u.dt_saiu_arte = ( SELECT MAX(aux.dt_saiu_arte)FROM  ponto_eletronico.sugesp_bi_1contrat_intif_arte aux )
AND u.cpf= ( SELECT g.cpf_gestor  FROM ponto_eletronico.sugesp_bi_1contrat_intif_arte g WHERE g.dt_saiu_arte = u.dt_saiu_arte AND G.cpf_gestor IS NOT NULL AND g.cpf_gestor = u.cpf GROUP BY g.cpf_gestor );
commit;*/

FOR C1 IN (
SELECT CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO_CONTRATO,CPF ,DT_SAIU_ARTE FROM  ponto_eletronico.sugesp_bi_1contrat_intif_arte u
WHERE u.dt_saiu_arte = ( SELECT MAX(aux.dt_saiu_arte)FROM  ponto_eletronico.sugesp_bi_1contrat_intif_arte aux )
AND  EXISTS(SELECT g.cpf_gestor  FROM ponto_eletronico.sugesp_bi_1contrat_intif_arte g WHERE g.dt_saiu_arte = u.dt_saiu_arte AND G.cpf_gestor IS NOT NULL AND g.cpf_gestor = u.cpf GROUP BY g.cpf_gestor )
)LOOP
UPDATE ponto_eletronico.sugesp_bi_1contrat_intif_arte  SET E_GESTOR='S' WHERE CODIGO_CONTRATO=C1.CODIGO_CONTRATO AND CODIGO_EMPRESA=C1.CODIGO_EMPRESA AND TIPO_CONTRATO=C1.TIPO_CONTRATO AND CPF=C1.CPF AND DT_SAIU_ARTE=C1.DT_SAIU_ARTE;
COMMIT;
END LOOP;

UPDATE PONTO_ELETRONICO.SUGESP_BI_1CONTRAT_INTIF_ARTE U
SET U.E_GESTOR       = 'S'
WHERE U.dt_saiu_arte =
  (SELECT MAX(dt_saiu_arte) FROM PONTO_ELETRONICO.SUGESP_BI_1CONTRAT_INTIF_ARTE
  )
AND U.TIPO_PESSOA IN ('GESTOR_SUP_INFORMAL','GESTOR_SUP_FORMAL') AND U.E_GESTOR NOT IN ('S');
commit;

END SMARH_INT_PE_E_GESTOR_V1;