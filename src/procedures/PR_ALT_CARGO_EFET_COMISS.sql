
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_ALT_CARGO_EFET_COMISS" 
IS
   V_OCORRENCIA		INTEGER;
   V_MOTIVO_ALT		VARCHAR(4);
   V_DT_ALTER_CARGO	DATE;
   V_DT_FIM_TEMP	DATE;
   
BEGIN   
  -- BUSCA SOMENTE CONTRATOS EFETIVOS
  FOR I IN (SELECT DISTINCT CNT.CODIGO_EMPRESA,CNT.TIPO_CONTRATO,CNT.CODIGO,CNT.SALARIO_PAGTO
            FROM ARTERH.RHPESS_CONTRATO CNT
            WHERE 1 = 1
            AND CNT.ANO_MES_REFERENCIA = (SELECT MAX (CNT2.ANO_MES_REFERENCIA)
										  FROM ARTERH.RHPESS_CONTRATO CNT2
										  WHERE CNT2.CODIGO              = CNT.CODIGO											  
										  AND   TRUNC(CNT2.ANO_MES_REFERENCIA) <= (SELECT DT_MAX_DATAS FROM ARTERH.RHPARM_P_SIST)
										  AND   CNT2.TIPO_CONTRATO       = CNT.TIPO_CONTRATO
										  AND   CNT2.CODIGO_EMPRESA      = CNT.CODIGO_EMPRESA)
            AND CNT.TIPO_CONTRATO IN ('0001','0003','0098')
            AND CNT.CODIGO_EMPRESA = '0002' 
			AND CNT.SALARIO_PAGTO  = 'E'
            ORDER BY CNT.CODIGO)
  LOOP
    -- APAGAR TODOS REGISTROS DA TABELA RHPLCS_ALT_CARGO DO CONTRATO DO LOOP
    DELETE FROM ARTERH.RHPLCS_ALT_CARGO 
    WHERE CODIGO_EMPRESA = I.CODIGO_EMPRESA AND TIPO_CONTRATO = I.TIPO_CONTRATO AND CODIGO_CONTRATO = I.CODIGO;
    COMMIT;	
	
    -- BUSCA SOMENTE OS CARGOS ALTERADOS NO HISTÓRICO DO CONTRATO
	FOR A IN (SELECT CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO,DATA_ADMISSAO,DATA_RESCISAO,COD_CARGO_EFETIVO,NIVEL_CARGO_EFETIV,
                     OBSERVACAO,LOGIN,DT_ALTER_USUA,DT_FIM_TEMP, ROWNUM AS OCORRENCIA,SALARIO_PAGTO 
			  FROM 
	          ( SELECT DISTINCT CNT.CODIGO_EMPRESA,CNT.TIPO_CONTRATO,CNT.CODIGO,       
                      CNT.DATA_ADMISSAO,CNT.DATA_RESCISAO,
                      LPAD(CNT.COD_CARGO_EFETIVO,15,0) AS COD_CARGO_EFETIVO,
					  LPAD(CNT.NIVEL_CARGO_EFETIV,8,0) AS NIVEL_CARGO_EFETIV,
                      'INSERIDO VIA PROCEDURE PR_ALT_CARGO_EFET_COMISS - PRODABEL' AS OBSERVACAO, 
 					  'pb002707' AS LOGIN, SYSDATE AS DT_ALTER_USUA, CG.DATA_EXTINC_CARGO AS DT_FIM_TEMP,
					  CNT.SALARIO_PAGTO
                FROM ARTERH.RHPESS_CONTRATO CNT 
			         INNER JOIN ARTERH.RHPLCS_CARGO CG ON CG.CODIGO         = CNT.COD_CARGO_EFETIVO 
				                                      AND CG.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA
                WHERE CNT.CODIGO       = I.CODIGO
                AND CNT.TIPO_CONTRATO  = I.TIPO_CONTRATO
                AND CNT.CODIGO_EMPRESA = I.CODIGO_EMPRESA
                AND CNT.SALARIO_PAGTO  = I.SALARIO_PAGTO
			    AND CNT.COD_CARGO_EFETIVO IS NOT NULL
			    AND CNT.NIVEL_CARGO_EFETIV IS NOT NULL			  
                ORDER BY CG.DATA_EXTINC_CARGO,CNT.CODIGO,COD_CARGO_EFETIVO,NIVEL_CARGO_EFETIV))
	LOOP
	  -- PADRONIZA O CODIGO DE MOTIVO DE ALTERAÇÃO DE CARGO
	  IF A.OCORRENCIA = 1 THEN V_MOTIVO_ALT := '0030'; ELSE V_MOTIVO_ALT := '1001'; END IF; 
	  
	  -- BUSCA A VIGENCIA DO CARGO E DO NIVEL DO LOOP (A) HISTÓRICO DOS CARGOS ALTERADOS NO CONTRATO
      -- DATA INCIAL
      SELECT CASE WHEN TO_CHAR(CNT.ANO_MES_REFERENCIA,'MM-YYYY') = TO_CHAR(CNT.DATA_ADMISSAO,'MM-YYYY') 
             THEN CNT.DATA_ADMISSAO ELSE CNT.ANO_MES_REFERENCIA END INTO V_DT_ALTER_CARGO
      FROM ARTERH.RHPESS_CONTRATO CNT
      WHERE CNT.CODIGO           = A.CODIGO
      AND CNT.ANO_MES_REFERENCIA = (SELECT MIN (CNT2.ANO_MES_REFERENCIA)
      								FROM ARTERH.RHPESS_CONTRATO CNT2
      								WHERE CNT2.CODIGO                     = CNT.CODIGO											  
      								AND   TRUNC(CNT2.ANO_MES_REFERENCIA) <= (SELECT DT_MAX_DATAS FROM ARTERH.RHPARM_P_SIST)
      								AND   CNT2.TIPO_CONTRATO              = CNT.TIPO_CONTRATO
      								AND   CNT2.CODIGO_EMPRESA             = CNT.CODIGO_EMPRESA
                                    AND   CNT2.SALARIO_PAGTO              = CNT.SALARIO_PAGTO
                                    AND   CNT2.COD_CARGO_EFETIVO          = CNT.COD_CARGO_EFETIVO
                                    AND   CNT2.NIVEL_CARGO_EFETIV         = CNT.NIVEL_CARGO_EFETIV)
      AND CNT.TIPO_CONTRATO      = A.TIPO_CONTRATO
      AND CNT.CODIGO_EMPRESA     = A.CODIGO_EMPRESA
      AND CNT.SALARIO_PAGTO      = A.SALARIO_PAGTO
      AND CNT.COD_CARGO_EFETIVO  = A.COD_CARGO_EFETIVO
      AND CNT.NIVEL_CARGO_EFETIV = A.NIVEL_CARGO_EFETIV;
	  
      -- DATA FINAL
      SELECT CASE WHEN TO_CHAR(CNT.ANO_MES_REFERENCIA,'MM-YYYY') = TO_CHAR(CNT.DATA_ADMISSAO,'MM-YYYY') 
             THEN CNT.DATA_ADMISSAO ELSE CNT.ANO_MES_REFERENCIA END INTO V_DT_FIM_TEMP
      FROM ARTERH.RHPESS_CONTRATO CNT
      WHERE CNT.CODIGO           = A.CODIGO
      AND CNT.ANO_MES_REFERENCIA = (SELECT MAX (CNT2.ANO_MES_REFERENCIA)
      								FROM ARTERH.RHPESS_CONTRATO CNT2
      								WHERE CNT2.CODIGO                     = CNT.CODIGO											  
      								AND   TRUNC(CNT2.ANO_MES_REFERENCIA) <= (SELECT DT_MAX_DATAS FROM ARTERH.RHPARM_P_SIST)
      								AND   CNT2.TIPO_CONTRATO              = CNT.TIPO_CONTRATO
      								AND   CNT2.CODIGO_EMPRESA             = CNT.CODIGO_EMPRESA
                                    AND   CNT2.SALARIO_PAGTO              = CNT.SALARIO_PAGTO
                                    AND   CNT2.COD_CARGO_EFETIVO          = CNT.COD_CARGO_EFETIVO
                                    AND   CNT2.NIVEL_CARGO_EFETIV         = CNT.NIVEL_CARGO_EFETIV)
      AND CNT.TIPO_CONTRATO      = A.TIPO_CONTRATO
      AND CNT.CODIGO_EMPRESA     = A.CODIGO_EMPRESA
      AND CNT.SALARIO_PAGTO      = A.SALARIO_PAGTO
      AND CNT.COD_CARGO_EFETIVO  = A.COD_CARGO_EFETIVO
      AND CNT.NIVEL_CARGO_EFETIV = A.NIVEL_CARGO_EFETIV;
	  
	  -- GRAVA OS REGISTROS DO LOOP (A) HISTÓRICO DOS CARGOS ALTERADOS NO CONTRATO
	  INSERT INTO ARTERH.RHPLCS_ALT_CARGO 
             ( CODIGO_EMPRESA,
               TIPO_CONTRATO,
               CODIGO_CONTRATO,
               DT_ALTER_CARGO,
               MOTIVO_ALTERACAO,
               COD_CARGO_EFET_AT,
               NIV_CARGO_EFET_AT,
			   OBSERVACAO,
               LOGIN_USUARIO,
               DT_ULT_ALTER_USUA,
               DT_FIM_TEMP,
			   OCORRENCIA,
               SALARIO_PAGTO)	  		 
      VALUES ( A.CODIGO_EMPRESA,
	           A.TIPO_CONTRATO,
			   A.CODIGO,
			   TO_DATE(V_DT_ALTER_CARGO,'DD/MM/YYYY'),
			   V_MOTIVO_ALT,
			   A.COD_CARGO_EFETIVO,
			   A.NIVEL_CARGO_EFETIV,
               A.OBSERVACAO,
			   A.LOGIN,
			   A.DT_ALTER_USUA,
			   TO_DATE(V_DT_FIM_TEMP,'DD/MM/YYYY'),
		       A.OCORRENCIA,
			   A.SALARIO_PAGTO);
	END LOOP; -- (A)
	
	-- ABRE A ULTIMA DATA FIM DO HISTÓRICO DE ALTERAÇÃO DE CARGO
	UPDATE ARTERH.RHPLCS_ALT_CARGO SET DT_FIM_TEMP = NULL
	WHERE CODIGO_CONTRATO = I.CODIGO
	AND   TIPO_CONTRATO   = I.TIPO_CONTRATO
	AND   CODIGO_EMPRESA  = I.CODIGO_EMPRESA
	AND   DT_FIM_TEMP     = (SELECT MAX(AUX.DT_FIM_TEMP) FROM ARTERH.RHPLCS_ALT_CARGO AUX
	                         WHERE AUX.CODIGO_CONTRATO = I.CODIGO
	                         AND   AUX.TIPO_CONTRATO   = I.TIPO_CONTRATO
	                         AND   AUX.CODIGO_EMPRESA  = I.CODIGO_EMPRESA);
  END LOOP; -- (I)
  COMMIT;
  
  -- BUSCA SOMENTE CONTRATOS RECRUTAMENTO AMPLO
  FOR C IN (SELECT DISTINCT CNT.CODIGO_EMPRESA,CNT.TIPO_CONTRATO,CNT.CODIGO,CNT.SALARIO_PAGTO
            FROM ARTERH.RHPESS_CONTRATO CNT
            WHERE 1 = 1
            AND CNT.ANO_MES_REFERENCIA = (SELECT MAX (CNT2.ANO_MES_REFERENCIA)
										  FROM ARTERH.RHPESS_CONTRATO CNT2
										  WHERE CNT2.CODIGO              = CNT.CODIGO											  
										  AND   TRUNC(CNT2.ANO_MES_REFERENCIA) <= (SELECT DT_MAX_DATAS FROM ARTERH.RHPARM_P_SIST)
										  AND   CNT2.TIPO_CONTRATO       = CNT.TIPO_CONTRATO
										  AND   CNT2.CODIGO_EMPRESA      = CNT.CODIGO_EMPRESA)
            AND CNT.TIPO_CONTRATO IN ('0001','0003','0098')
            AND CNT.CODIGO_EMPRESA = '0002' 
			AND CNT.SALARIO_PAGTO  = 'C'
            ORDER BY CNT.CODIGO)
  LOOP
    -- APAGAR TODOS REGISTROS DA TABELA RHPLCS_ALT_CARGO DO CONTRATO DO LOOP
    DELETE FROM ARTERH.RHPLCS_ALT_CARGO 
    WHERE CODIGO_EMPRESA = C.CODIGO_EMPRESA AND TIPO_CONTRATO = C.TIPO_CONTRATO AND CODIGO_CONTRATO = C.CODIGO;
    COMMIT;	
	
    -- BUSCA SOMENTE OS CARGOS ALTERADOS NO HISTÓRICO DO CONTRATO
	FOR D IN (SELECT CODIGO_EMPRESA,TIPO_CONTRATO,CODIGO,DATA_ADMISSAO,DATA_RESCISAO,COD_CARGO_COMISS,NIVEL_CARGO_COMISS,
                     OBSERVACAO,LOGIN,DT_ALTER_USUA,DT_FIM_TEMP, ROWNUM AS OCORRENCIA,SALARIO_PAGTO 
			  FROM 
	          ( SELECT DISTINCT CNT.CODIGO_EMPRESA,CNT.TIPO_CONTRATO,CNT.CODIGO,       
                      CNT.DATA_ADMISSAO,CNT.DATA_RESCISAO,
					  LPAD(CNT.COD_CARGO_COMISS,15,0) AS COD_CARGO_COMISS,
					  LPAD(CNT.NIVEL_CARGO_COMISS,8,0) AS NIVEL_CARGO_COMISS,
                      'INSERIDO VIA PROCEDURE PR_ALT_CARGO_EFET_COMISS - PRODABEL' AS OBSERVACAO, 
 					  'pb002707' AS LOGIN, SYSDATE AS DT_ALTER_USUA, CG.DATA_EXTINC_CARGO AS DT_FIM_TEMP,
					  CNT.SALARIO_PAGTO
                FROM ARTERH.RHPESS_CONTRATO CNT 
			         INNER JOIN ARTERH.RHPLCS_CARGO CG ON CG.CODIGO         = CNT.COD_CARGO_COMISS 
				                                      AND CG.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA
                WHERE CNT.CODIGO       = C.CODIGO
                AND CNT.TIPO_CONTRATO  = C.TIPO_CONTRATO
                AND CNT.CODIGO_EMPRESA = C.CODIGO_EMPRESA
                AND CNT.SALARIO_PAGTO  = C.SALARIO_PAGTO
			    AND CNT.COD_CARGO_COMISS IS NOT NULL
			    AND CNT.NIVEL_CARGO_COMISS IS NOT NULL			  
                ORDER BY CG.DATA_EXTINC_CARGO,CNT.CODIGO,COD_CARGO_COMISS,NIVEL_CARGO_COMISS))
	LOOP
	  -- PADRONIZA O CODIGO DE MOTIVO DE ALTERAÇÃO DE CARGO
	  IF D.OCORRENCIA = 1 THEN V_MOTIVO_ALT := '0030'; ELSE V_MOTIVO_ALT := '1001'; END IF; 
	  
	  -- BUSCA A VIGENCIA DO CARGO E DO NIVEL DO LOOP (D) HISTÓRICO DOS CARGOS ALTERADOS NO CONTRATO
      -- DATA INCIAL
      SELECT CASE WHEN TO_CHAR(CNT.ANO_MES_REFERENCIA,'MM-YYYY') = TO_CHAR(CNT.DATA_ADMISSAO,'MM-YYYY') 
             THEN CNT.DATA_ADMISSAO ELSE CNT.ANO_MES_REFERENCIA END INTO V_DT_ALTER_CARGO
      FROM ARTERH.RHPESS_CONTRATO CNT
      WHERE CNT.CODIGO           = D.CODIGO
      AND CNT.ANO_MES_REFERENCIA = (SELECT MIN (CNT2.ANO_MES_REFERENCIA)
      								FROM ARTERH.RHPESS_CONTRATO CNT2
      								WHERE CNT2.CODIGO                     = CNT.CODIGO											  
      								AND   TRUNC(CNT2.ANO_MES_REFERENCIA) <= (SELECT DT_MAX_DATAS FROM ARTERH.RHPARM_P_SIST)
      								AND   CNT2.TIPO_CONTRATO              = CNT.TIPO_CONTRATO
      								AND   CNT2.CODIGO_EMPRESA             = CNT.CODIGO_EMPRESA
                                    AND   CNT2.SALARIO_PAGTO              = CNT.SALARIO_PAGTO
                                    AND   CNT2.COD_CARGO_COMISS           = CNT.COD_CARGO_COMISS
                                    AND   CNT2.NIVEL_CARGO_COMISS         = CNT.NIVEL_CARGO_COMISS)
      AND CNT.TIPO_CONTRATO      = D.TIPO_CONTRATO
      AND CNT.CODIGO_EMPRESA     = D.CODIGO_EMPRESA
      AND CNT.SALARIO_PAGTO      = D.SALARIO_PAGTO
      AND CNT.COD_CARGO_COMISS   = D.COD_CARGO_COMISS
      AND CNT.NIVEL_CARGO_COMISS = D.NIVEL_CARGO_COMISS;
	  
      -- DATA FINAL
      SELECT CASE WHEN TO_CHAR(CNT.ANO_MES_REFERENCIA,'MM-YYYY') = TO_CHAR(CNT.DATA_ADMISSAO,'MM-YYYY') 
             THEN CNT.DATA_ADMISSAO ELSE CNT.ANO_MES_REFERENCIA END INTO V_DT_FIM_TEMP
      FROM ARTERH.RHPESS_CONTRATO CNT
      WHERE CNT.CODIGO           = D.CODIGO
      AND CNT.ANO_MES_REFERENCIA = (SELECT MAX (CNT2.ANO_MES_REFERENCIA)
      								FROM ARTERH.RHPESS_CONTRATO CNT2
      								WHERE CNT2.CODIGO                     = CNT.CODIGO											  
      								AND   TRUNC(CNT2.ANO_MES_REFERENCIA) <= (SELECT DT_MAX_DATAS FROM ARTERH.RHPARM_P_SIST)
      								AND   CNT2.TIPO_CONTRATO              = CNT.TIPO_CONTRATO
      								AND   CNT2.CODIGO_EMPRESA             = CNT.CODIGO_EMPRESA
                                    AND   CNT2.SALARIO_PAGTO              = CNT.SALARIO_PAGTO
                                    AND   CNT2.COD_CARGO_COMISS           = CNT.COD_CARGO_COMISS
                                    AND   CNT2.NIVEL_CARGO_COMISS         = CNT.NIVEL_CARGO_COMISS)
      AND CNT.TIPO_CONTRATO      = D.TIPO_CONTRATO
      AND CNT.CODIGO_EMPRESA     = D.CODIGO_EMPRESA
      AND CNT.SALARIO_PAGTO      = D.SALARIO_PAGTO
      AND CNT.COD_CARGO_COMISS   = D.COD_CARGO_COMISS
      AND CNT.NIVEL_CARGO_COMISS = D.NIVEL_CARGO_COMISS;

	  
	  -- GRAVA OS REGISTROS DO LOOP (D) HISTÓRICO DOS CARGOS ALTERADOS NO CONTRATO
	  INSERT INTO ARTERH.RHPLCS_ALT_CARGO 
             ( CODIGO_EMPRESA,
               TIPO_CONTRATO,
               CODIGO_CONTRATO,
               DT_ALTER_CARGO,
               MOTIVO_ALTERACAO,
               COD_CARGO_COMIS_AT,
               NIV_CARGO_COMIS_AT,
			   OBSERVACAO,
               LOGIN_USUARIO,
               DT_ULT_ALTER_USUA,
               DT_FIM_TEMP,
			   OCORRENCIA,
               SALARIO_PAGTO)	  		 
      VALUES ( D.CODIGO_EMPRESA,
	           D.TIPO_CONTRATO,
			   D.CODIGO,
			   TO_DATE(V_DT_ALTER_CARGO,'DD/MM/YYYY'),
			   V_MOTIVO_ALT,
			   D.COD_CARGO_COMISS,
			   D.NIVEL_CARGO_COMISS,
               D.OBSERVACAO,
			   D.LOGIN,
			   D.DT_ALTER_USUA,
			   TO_DATE(V_DT_FIM_TEMP,'DD/MM/YYYY'),
		       D.OCORRENCIA,
			   D.SALARIO_PAGTO);
	END LOOP; -- (D)
	
	-- ABRE A ULTIMA DATA FIM DO HISTÓRICO DE ALTERAÇÃO DE CARGO
	UPDATE ARTERH.RHPLCS_ALT_CARGO SET DT_FIM_TEMP = NULL
	WHERE CODIGO_CONTRATO = C.CODIGO
	AND   TIPO_CONTRATO   = C.TIPO_CONTRATO
	AND   CODIGO_EMPRESA  = C.CODIGO_EMPRESA
	AND   DT_FIM_TEMP     = (SELECT MAX(AUX.DT_FIM_TEMP) FROM ARTERH.RHPLCS_ALT_CARGO AUX
	                         WHERE AUX.CODIGO_CONTRATO = C.CODIGO
	                         AND   AUX.TIPO_CONTRATO   = C.TIPO_CONTRATO
	                         AND   AUX.CODIGO_EMPRESA  = C.CODIGO_EMPRESA);
  END LOOP; -- (C)
  COMMIT;  
END PR_ALT_CARGO_EFET_COMISS;