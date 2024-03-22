
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."V_RH_REL_4062" ("MATRICULA", "NOME", "DATA_NASCIMENTO", "CPF", "DATA_APOSENTA_FGTS", "DATA_ADMISSAO", "SITUACAO_FUNCIONAL", "FUNCAO", "CARGO_PAGTO", "CLA", "GR", "ESPECIALIDADE", "COD_LOTACAO", "DIRETORIA", "LOTACAO", "ABREVIACAO", "SUPERINTENDENCIA", "FORMA_PROVIMENTO", "MOTIVO_ADMISSAO", "SAL_CONTR", "GTS", "VP", "IND_PAM", "GF", "GRA_ESTRAT", "GDE", "GF_INCORP", "GF_INCORP_JUD", "BANCO_HORAS", "COMPL_GF", "GTTS", "VANT_AD_NOT", "ADIC_NOTURNO", "ADIC_PERIC", "HORAS_BIP", "HORAS_EXTRAS", "AUX_CRECHE", "SEG_VIDA", "SUB_DEPENDENTE", "SUB_TITULAR", "ASSIST_MEDICA", "VALE_TRANSP", "VALE_REFEICAO", "ENCARGOS", "VALE_LANCHE") AS 
  SELECT DISTINCT SUBSTR(RHPESS_CONTRATO.CODIGO,7,8) || '-' ||SUBSTR(RHPESS_CONTRATO.CODIGO,15,1) AS MATRICULA,
       RHPESS_CONTRATO.NOME,
       PES.DATA_NASCIMENTO,
       PES.CPF,
       RHPESS_CONTRATO.DATA_APOSENTA_FGTS,
       RHPESS_CONTRATO.DATA_ADMISSAO,
       RHPESS_CONTRATO.SITUACAO_FUNCIONAL,
       FUN.DESCRICAO AS FUNCAO,       
       CG.DESCRICAO AS CARGO_PAGTO,       
       CASE 
         WHEN SUBSTR(RHPESS_CONTRATO.COD_CARGO_PAGTO,15,1) = '0' THEN '0'
         WHEN SUBSTR(RHPESS_CONTRATO.COD_CARGO_PAGTO,15,1) = '1' THEN 'I'
         WHEN SUBSTR(RHPESS_CONTRATO.COD_CARGO_PAGTO,15,1) = '2' THEN 'II'
         WHEN SUBSTR(RHPESS_CONTRATO.COD_CARGO_PAGTO,15,1) = '3' THEN 'III'
         WHEN SUBSTR(RHPESS_CONTRATO.COD_CARGO_PAGTO,15,1) = '4' THEN 'IV'
         WHEN SUBSTR(RHPESS_CONTRATO.COD_CARGO_PAGTO,15,1) = '5' THEN 'V'
       ELSE ' ' END CLA,
	   SUBSTR(TRIM(RHPESS_CONTRATO.NIVEL_CARGO_PAGTO),-2) GR,       
       SUBSTR(RHPESS_CONTRATO.COD_ESPECIALIDADE,-4) AS ESPECIALIDADE,
       SUBSTR(RHPESS_CONTRATO.COD_UNIDADE1,5,2) || '.' || SUBSTR(RHPESS_CONTRATO.COD_UNIDADE2,5,2) || '.' || SUBSTR(RHPESS_CONTRATO.COD_UNIDADE3,5,2) || '.' ||
       SUBSTR(RHPESS_CONTRATO.COD_UNIDADE4,5,2) || '.' || SUBSTR(RHPESS_CONTRATO.COD_UNIDADE5,5,2) || '.' || SUBSTR(RHPESS_CONTRATO.COD_UNIDADE6,4,3) AS COD_LOTACAO,
       DIR.DESCRICAO AS DIRETORIA,
       GER.DESCRICAO AS LOTACAO,
       GER.ABREVIACAO AS ABREVIACAO,
       SUP.DESCRICAO AS SUPERINTENDENCIA,
       RHPESS_CONTRATO.FORMA_PROVIMENTO || ' - ' || FOP.DESCRICAO AS FORMA_PROVIMENTO,
       RHPESS_CONTRATO.MOTIVO_ADMISSAO  || ' - ' || MOA.DESCRICAO AS MOTIVO_ADMISSAO,
       (NVL(SC.VALOR_VERBA,0) + NVL(SC1.VALOR_VERBA,0)) AS SAL_CONTR,GRATS.VALOR_VERBA AS GTS, VPTS.VALOR_VERBA AS VP,IND.VALOR_VERBA AS IND_PAM, VRGF.VALOR_VERBA AS GF,
	   VREST.VALOR_VERBA AS GRA_ESTRAT,VRGDE.VALOR_VERBA AS GDE,VRIGF.VALOR_VERBA AS GF_INCORP,VRDJ.VALOR_VERBA AS GF_INCORP_JUD,HENC.VALOR_VERBA AS BANCO_HORAS,
	   VRCGF.VALOR_VERBA AS COMPL_GF,VRGTTS.VALOR_VERBA AS GTTS,VRACT.VALOR_VERBA AS VANT_AD_NOT,ADICN.VALOR_VERBA AS ADIC_NOTURNO,
	   ADICP.VALOR_VERBA AS ADIC_PERIC,HP.VALOR_VERBA AS HORAS_BIP,VRHE.VALOR_VERBA AS HORAS_EXTRAS,(NVL(AUXC.VALOR_VERBA,0) + NVL(AUXC1.VALOR_VERBA,0)) AS AUX_CRECHE,SEGV.VALOR_VERBA AS SEG_VIDA,
	   (  NVL(SDEP.VALOR_VERBA,0) 
	    - (NVL(STIT.VALOR_VERBA,0) + NVL(STIT2.VALOR_VERBA,0) + NVL(STIT3.VALOR_VERBA,0) + NVL(STIT4.VALOR_VERBA,0) + NVL(STIT5.VALOR_VERBA,0) + NVL(STIT6.VALOR_VERBA,0))
		- NVL(SDEP1.VALOR_VERBA,0))  AS SUB_DEPENDENTE,	   
	   (NVL(STIT.VALOR_VERBA,0) + NVL(STIT2.VALOR_VERBA,0) + NVL(STIT3.VALOR_VERBA,0) + 
	    NVL(STIT4.VALOR_VERBA,0) + NVL(STIT5.VALOR_VERBA,0) + NVL(STIT6.VALOR_VERBA,0)) AS SUB_TITULAR,	   
	   ASMED.VALOR_VERBA AS ASSIST_MEDICA,VLTR.VALOR_VERBA AS VALE_TRANSP,VLREF.VALOR_VERBA AS VALE_REFEICAO,
	   ENCG.VALOR_VERBA AS ENCARGOS,VLLAN.VALOR_VERBA AS VALE_LANCHE
FROM ARTERH.RHPESS_CONTRATO RHPESS_CONTRATO
     INNER JOIN RHPESS_PESSOA           PES ON PES.CODIGO = RHPESS_CONTRATO.CODIGO_PESSOA
                                           AND PES.CODIGO_EMPRESA = RHPESS_CONTRATO.CODIGO_EMPRESA
     INNER JOIN ARTERH.RHPLCS_CARGO      CG ON CG.CODIGO = RHPESS_CONTRATO.COD_CARGO_PAGTO
                                           AND CG.CODIGO_EMPRESA = RHPESS_CONTRATO.CODIGO_EMPRESA     
     LEFT JOIN ARTERH.RHPLCS_FUNCAO     FUN ON FUN.CODIGO = RHPESS_CONTRATO.CODIGO_FUNCAO
                                           AND FUN.CODIGO_EMPRESA = RHPESS_CONTRATO.CODIGO_EMPRESA     
     LEFT JOIN ARTERH.RHPESS_FORMA_PROV FOP ON FOP.CODIGO = RHPESS_CONTRATO.FORMA_PROVIMENTO
     LEFT JOIN ARTERH.RHPARM_MOTIVO_ADM MOA ON MOA.CODIGO = RHPESS_CONTRATO.MOTIVO_ADMISSAO
                                           AND MOA.CODIGO_EMPRESA = RHPESS_CONTRATO.CODIGO_EMPRESA     
     INNER JOIN ARTERH.RHMOVI_MOVIMENTO  MV ON MV.CODIGO_CONTRATO = RHPESS_CONTRATO.CODIGO
                                           AND MV.TIPO_CONTRATO = MV.TIPO_CONTRATO
                                           AND MV.CODIGO_EMPRESA = RHPESS_CONTRATO.CODIGO_EMPRESA
        INNER JOIN ARTERH.RHORGA_UNIDADE GER  ON GER.COD_UNIDADE1 = RHPESS_CONTRATO.COD_UNIDADE1
                                             AND GER.COD_UNIDADE2 = RHPESS_CONTRATO.COD_UNIDADE2
                                             AND GER.COD_UNIDADE3 = RHPESS_CONTRATO.COD_UNIDADE3
                                             AND GER.COD_UNIDADE4 = RHPESS_CONTRATO.COD_UNIDADE4
                                             AND GER.COD_UNIDADE5 = RHPESS_CONTRATO.COD_UNIDADE5
                                             AND GER.COD_UNIDADE6 = RHPESS_CONTRATO.COD_UNIDADE6
                                             AND GER.CODIGO_EMPRESA = RHPESS_CONTRATO.CODIGO_EMPRESA
        INNER JOIN ARTERH.RHORGA_UNIDADE SUP  ON SUP.COD_UNIDADE1 = RHPESS_CONTRATO.COD_UNIDADE1
                                             AND SUP.COD_UNIDADE2 = RHPESS_CONTRATO.COD_UNIDADE2
                                             AND SUP.COD_UNIDADE3 = RHPESS_CONTRATO.COD_UNIDADE3
                                             AND SUP.COD_UNIDADE4 = '000000'
                                             AND SUP.COD_UNIDADE5 = '000000'
                                             AND SUP.COD_UNIDADE6 = '000000'
                                             AND SUP.CODIGO_EMPRESA = RHPESS_CONTRATO.CODIGO_EMPRESA
        INNER JOIN ARTERH.RHORGA_UNIDADE DIR  ON DIR.COD_UNIDADE1 = RHPESS_CONTRATO.COD_UNIDADE1
                                             AND DIR.COD_UNIDADE2 = RHPESS_CONTRATO.COD_UNIDADE2
                                             AND DIR.COD_UNIDADE3 = '000000'
                                             AND DIR.COD_UNIDADE4 = '000000'
                                             AND DIR.COD_UNIDADE5 = '000000'
                                             AND DIR.COD_UNIDADE6 = '000000'
                                             AND DIR.CODIGO_EMPRESA = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO SC ON SC.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND SC.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND SC.CODIGO_VERBA       = '1P00'
                                                   AND SC.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND SC.FASE               = MV.FASE
                                                   AND SC.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND SC.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND SC.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO SC1 ON SC1.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND SC1.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND SC1.CODIGO_VERBA       = '1P21'
                                                   AND SC1.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND SC1.FASE               = MV.FASE
                                                   AND SC1.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND SC1.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND SC1.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO GRATS ON GRATS.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND GRATS.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND GRATS.CODIGO_VERBA IN ('5P04')
                                                   AND GRATS.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND GRATS.FASE               = MV.FASE
                                                   AND GRATS.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND GRATS.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND GRATS.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO VPTS ON VPTS.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND VPTS.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND VPTS.CODIGO_VERBA IN ('4P1C')
                                                   AND VPTS.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND VPTS.FASE               = MV.FASE
                                                   AND VPTS.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND VPTS.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND VPTS.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO IND ON IND.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND IND.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND IND.CODIGO_VERBA IN ('4P1F')
                                                   AND IND.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND IND.FASE               = MV.FASE
                                                   AND IND.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND IND.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND IND.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO VRGF ON VRGF.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND VRGF.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND VRGF.CODIGO_VERBA IN ('4P1G')
                                                   AND VRGF.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND VRGF.FASE               = MV.FASE
                                                   AND VRGF.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND VRGF.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND VRGF.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA       
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO VREST ON VREST.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND VREST.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND VREST.CODIGO_VERBA IN ('4P1L')
                                                   AND VREST.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND VREST.FASE               = MV.FASE
                                                   AND VREST.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND VREST.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND VREST.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO VRGDE ON VRGDE.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND VRGDE.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND VRGDE.CODIGO_VERBA IN ('4P1H')
                                                   AND VRGDE.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND VRGDE.FASE               = MV.FASE
                                                   AND VRGDE.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND VRGDE.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND VRGDE.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO VRIGF ON VRIGF.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND VRIGF.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND VRIGF.CODIGO_VERBA IN ('4P1I')
                                                   AND VRIGF.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND VRIGF.FASE               = MV.FASE
                                                   AND VRIGF.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND VRIGF.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND VRIGF.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO VRDJ ON VRDJ.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND VRDJ.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND VRDJ.CODIGO_VERBA IN ('4P6L')
                                                   AND VRDJ.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND VRDJ.FASE               = MV.FASE
                                                   AND VRDJ.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND VRDJ.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND VRDJ.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO HENC ON HENC.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND HENC.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND HENC.CODIGO_VERBA IN ('1P3X')
                                                   AND HENC.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND HENC.FASE               = MV.FASE
                                                   AND HENC.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND HENC.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND HENC.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO VRCGF ON VRCGF.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND VRCGF.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND VRCGF.CODIGO_VERBA IN ('4P1J')
                                                   AND VRCGF.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND VRCGF.FASE               = MV.FASE
                                                   AND VRCGF.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND VRCGF.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND VRCGF.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO VRGTTS ON VRGTTS.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND VRGTTS.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND VRGTTS.CODIGO_VERBA IN ('4P1K')
                                                   AND VRGTTS.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND VRGTTS.FASE               = MV.FASE
                                                   AND VRGTTS.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND VRGTTS.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND VRGTTS.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO VRACT ON VRACT.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND VRACT.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND VRACT.CODIGO_VERBA IN ('4P1O')
                                                   AND VRACT.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND VRACT.FASE               = MV.FASE
                                                   AND VRACT.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND VRACT.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND VRACT.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO ADICN ON ADICN.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND ADICN.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND ADICN.CODIGO_VERBA IN ('1P03')
                                                   AND ADICN.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND ADICN.FASE               = MV.FASE
                                                   AND ADICN.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND ADICN.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND ADICN.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO ADICP ON ADICP.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND ADICP.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND ADICP.CODIGO_VERBA IN ('1PD6')
                                                   AND ADICP.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND ADICP.FASE               = MV.FASE
                                                   AND ADICP.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND ADICP.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND ADICP.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO HP ON HP.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND HP.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND HP.CODIGO_VERBA IN ('1P25')
                                                   AND HP.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND HP.FASE               = MV.FASE
                                                   AND HP.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND HP.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND HP.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO VRHE ON VRHE.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND VRHE.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND VRHE.CODIGO_VERBA IN ('4P4A')
                                                   AND VRHE.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND VRHE.FASE               = MV.FASE
                                                   AND VRHE.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND VRHE.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND VRHE.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO AUXC ON AUXC.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND AUXC.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND AUXC.CODIGO_VERBA       = '1P3P'
                                                   AND AUXC.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND AUXC.FASE               = MV.FASE
                                                   AND AUXC.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND AUXC.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND AUXC.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO AUXC1 ON AUXC1.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND AUXC1.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND AUXC1.CODIGO_VERBA       = '1PB8'
                                                   AND AUXC1.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND AUXC1.FASE               = MV.FASE
                                                   AND AUXC1.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND AUXC1.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND AUXC1.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA

        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO SEGV ON SEGV.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND SEGV.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND SEGV.CODIGO_VERBA IN ('3P0F')
                                                   AND SEGV.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND SEGV.FASE               = MV.FASE
                                                   AND SEGV.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND SEGV.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND SEGV.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO SDEP ON SDEP.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND SDEP.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND SDEP.CODIGO_VERBA IN ('3P0G')                                                   
                                                   AND SDEP.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND SDEP.FASE               = MV.FASE
                                                   AND SDEP.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND SDEP.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND SDEP.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO SDEP1 ON SDEP1.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND SDEP1.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND SDEP1.CODIGO_VERBA IN ('12V7')                                                   
                                                   AND SDEP1.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND SDEP1.FASE               = MV.FASE
                                                   AND SDEP1.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND SDEP1.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND SDEP1.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO STIT ON STIT.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND STIT.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND STIT.CODIGO_VERBA LIKE '3ST1'
                                                   AND STIT.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND STIT.FASE               = MV.FASE
                                                   AND STIT.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND STIT.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND STIT.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO STIT2 ON STIT2.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND STIT2.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND STIT2.CODIGO_VERBA LIKE '3ST2'
                                                   AND STIT2.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND STIT2.FASE               = MV.FASE
                                                   AND STIT2.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND STIT2.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND STIT2.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO STIT3 ON STIT3.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND STIT3.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND STIT3.CODIGO_VERBA LIKE '3ST3'
                                                   AND STIT3.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND STIT3.FASE               = MV.FASE
                                                   AND STIT3.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND STIT3.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND STIT3.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO STIT4 ON STIT4.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND STIT4.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND STIT4.CODIGO_VERBA LIKE '3ST4'
                                                   AND STIT4.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND STIT4.FASE               = MV.FASE
                                                   AND STIT4.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND STIT4.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND STIT4.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO STIT5 ON STIT5.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND STIT5.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND STIT5.CODIGO_VERBA LIKE '3ST5'
                                                   AND STIT5.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND STIT5.FASE               = MV.FASE
                                                   AND STIT5.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND STIT5.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND STIT5.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO STIT6 ON STIT6.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND STIT6.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND STIT6.CODIGO_VERBA LIKE '3ST6'
                                                   AND STIT6.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND STIT6.FASE               = MV.FASE
                                                   AND STIT6.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND STIT6.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND STIT6.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA

        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO ASMED ON ASMED.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND ASMED.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND ASMED.CODIGO_VERBA       = '3P0G'
                                                   AND ASMED.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND ASMED.FASE               = MV.FASE
                                                   AND ASMED.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND ASMED.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND ASMED.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO VLTR ON VLTR.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND VLTR.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND VLTR.CODIGO_VERBA       = '3P0C'
                                                   AND VLTR.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND VLTR.FASE               = MV.FASE
                                                   AND VLTR.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND VLTR.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND VLTR.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO VLREF ON VLREF.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND VLREF.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND VLREF.CODIGO_VERBA       = '3P0D'
                                                   AND VLREF.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND VLREF.FASE               = MV.FASE
                                                   AND VLREF.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND VLREF.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND VLREF.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO ENCG ON ENCG.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND ENCG.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND ENCG.CODIGO_VERBA       = '4P22'
                                                   AND ENCG.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND ENCG.FASE               = MV.FASE
                                                   AND ENCG.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND ENCG.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND ENCG.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
        LEFT JOIN ARTERH.RHMOVI_MOVIMENTO VLLAN ON VLLAN.CODIGO_CONTRATO    = RHPESS_CONTRATO.CODIGO
                                                   AND VLLAN.ANO_MES_REFERENCIA = MV.ANO_MES_REFERENCIA
                                                   AND VLLAN.CODIGO_VERBA       = '3P0U'
                                                   AND VLLAN.TIPO_MOVIMENTO     = MV.TIPO_MOVIMENTO
                                                   AND VLLAN.FASE               = MV.FASE
                                                   AND VLLAN.MODO_OPERACAO      = MV.MODO_OPERACAO
                                                   AND VLLAN.TIPO_CONTRATO      = RHPESS_CONTRATO.TIPO_CONTRATO
                                                   AND VLLAN.CODIGO_EMPRESA     = RHPESS_CONTRATO.CODIGO_EMPRESA
,RHTABS_WHERE
WHERE RHPESS_CONTRATO.ANO_MES_REFERENCIA  = (   SELECT MAX (CNT2.ANO_MES_REFERENCIA)
                                                FROM ARTERH.RHPESS_CONTRATO CNT2
                                                WHERE CNT2.CODIGO              = RHPESS_CONTRATO.CODIGO											  
                                                AND   TRUNC(CNT2.ANO_MES_REFERENCIA) <= TO_DATE('01/'||TO_CHAR(ADD_MONTHS(SYSDATE,-1),'MM')||'/'||TO_CHAR(SYSDATE,'YYYY'))
                                                AND   CNT2.TIPO_CONTRATO       = RHPESS_CONTRATO.TIPO_CONTRATO
                                                AND   CNT2.CODIGO_EMPRESA      = RHPESS_CONTRATO.CODIGO_EMPRESA)
AND  RHPESS_CONTRATO.TIPO_CONTRATO = '0001'  
AND  RHPESS_CONTRATO.CODIGO_EMPRESA = '0002'
AND  RHPESS_CONTRATO.DATA_RESCISAO IS NULL
AND MV.FASE = 0
AND MV.MODO_OPERACAO = 'R'
AND MV.TIPO_MOVIMENTO = 'ME'
AND MV.ANO_MES_REFERENCIA = TO_DATE('01/'||TO_CHAR(ADD_MONTHS(SYSDATE,-1),'MM')||'/'||TO_CHAR(SYSDATE,'YYYY'))
GROUP BY RHPESS_CONTRATO.CODIGO,RHPESS_CONTRATO.NOME,PES.DATA_NASCIMENTO,PES.CPF,RHPESS_CONTRATO.DATA_APOSENTA_FGTS,
       RHPESS_CONTRATO.DATA_ADMISSAO,RHPESS_CONTRATO.SITUACAO_FUNCIONAL,FUN.DESCRICAO,CG.DESCRICAO,RHPESS_CONTRATO.COD_CARGO_PAGTO,RHPESS_CONTRATO.NIVEL_CARGO_PAGTO,RHPESS_CONTRATO.COD_ESPECIALIDADE,
       RHPESS_CONTRATO.COD_UNIDADE1,RHPESS_CONTRATO.COD_UNIDADE2,RHPESS_CONTRATO.COD_UNIDADE3,RHPESS_CONTRATO.COD_UNIDADE4,RHPESS_CONTRATO.COD_UNIDADE5,RHPESS_CONTRATO.COD_UNIDADE6,
       DIR.DESCRICAO,GER.DESCRICAO,GER.ABREVIACAO,SUP.DESCRICAO,RHPESS_CONTRATO.FORMA_PROVIMENTO,FOP.DESCRICAO,RHPESS_CONTRATO.MOTIVO_ADMISSAO,MOA.DESCRICAO,
       SC.VALOR_VERBA,SC1.VALOR_VERBA,GRATS.VALOR_VERBA,VPTS.VALOR_VERBA,IND.VALOR_VERBA,VRGF.VALOR_VERBA,VREST.VALOR_VERBA,VRGDE.VALOR_VERBA,VRIGF.VALOR_VERBA,VRDJ.VALOR_VERBA,
	   HENC.VALOR_VERBA,VRCGF.VALOR_VERBA,VRGTTS.VALOR_VERBA,VRACT.VALOR_VERBA,ADICN.VALOR_VERBA,ADICP.VALOR_VERBA,HP.VALOR_VERBA,
	   VRHE.VALOR_VERBA,AUXC.VALOR_VERBA,AUXC1.VALOR_VERBA,SEGV.VALOR_VERBA,SDEP.VALOR_VERBA,SDEP1.VALOR_VERBA,
       STIT.VALOR_VERBA,STIT2.VALOR_VERBA,STIT3.VALOR_VERBA,STIT4.VALOR_VERBA,STIT5.VALOR_VERBA,STIT6.VALOR_VERBA,
	   ASMED.VALOR_VERBA,VLTR.VALOR_VERBA,VLREF.VALOR_VERBA,ENCG.VALOR_VERBA,VLLAN.VALOR_VERBA
ORDER BY 13,1