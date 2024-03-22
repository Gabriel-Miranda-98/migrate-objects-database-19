
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."V_RH_REL_LIC1" ("CODIGO_EMPRESA", "TIPO_CONTRATO", "MATRICULA", "NOME", "SEXO", "DATA_NASCIMENTO", "DATA_ADMISSAO", "DATA_RESCISAO", "TIPO_CARGO", "CARGO", "DESC_CARGO", "CODIGO_FUNCAO", "DESC_FUNCAO", "COD_ESPECIALIDADE", "DESC_ESPECIALIDADE", "COD_LOTACAO", "LOTACAO", "ABREVIACAO_LOTACAO", "DIRETORIA", "ABREVIACAO_DIRETORIA", "SUPERINTENDENCIA", "ABREVIACAO_SUPERINTENDENCIA", "DATA_INI_AFAST", "DATA_FIM_AFAST", "DIAS_AFASTAMENTO", "COD_DOENCA", "DESC_DOENCA") AS 
  SELECT CNT.CODIGO_EMPRESA,
       CNT.TIPO_CONTRATO,
       SUBSTR(CNT.CODIGO,7,8) || '-' ||SUBSTR(CNT.CODIGO,15,1) AS MATRICULA,       
       CNT.NOME,
       CASE WHEN PE.SEXO = '0001' THEN 'MASCULINO' ELSE 'FEMININO' END SEXO,
       PE.DATA_NASCIMENTO,
       CNT.DATA_ADMISSAO,
       CNT.DATA_RESCISAO,
       CASE 
         WHEN CNT.SALARIO_PAGTO = 'E' THEN 'EFETIVO'
         WHEN CNT.SALARIO_PAGTO = 'C' THEN 'COMISSIONADO'
         WHEN CNT.SALARIO_PAGTO = 'A' THEN 'AMPARADO'
         WHEN CNT.SALARIO_PAGTO = 'P' THEN 'PAGAMENTO'
       ELSE 'FUNÇÃO' END TIPO_CARGO,              
       CNT.COD_CARGO_PAGTO AS CARGO,
       CG.DESCRICAO AS DESC_CARGO,
       CNT.CODIGO_FUNCAO,
       FUN.DESCRICAO AS DESC_FUNCAO,
       CNT.COD_ESPECIALIDADE,
       ESP.DESCRICAO AS DESC_ESPECIALIDADE,
       SUBSTR(CNT.COD_CUSTO_GERENC1,5,2) || '.' || SUBSTR(CNT.COD_CUSTO_GERENC2,5,2) || '.' || SUBSTR(CNT.COD_CUSTO_GERENC3,5,2) || '.' ||
       SUBSTR(CNT.COD_CUSTO_GERENC4,5,2) || '.' || SUBSTR(CNT.COD_CUSTO_GERENC5,5,2) || '.' || SUBSTR(CNT.COD_CUSTO_GERENC6,4,3) AS COD_LOTACAO,       
       GER.DESCRICAO AS LOTACAO,
       GER.ABREVIACAO AS ABREVIACAO_LOTACAO,       
       DIR.DESCRICAO AS DIRETORIA,
       DIR.ABREVIACAO AS ABREVIACAO_DIRETORIA,
       SUP.DESCRICAO AS SUPERINTENDENCIA,
       SUP.ABREVIACAO AS ABREVIACAO_SUPERINTENDENCIA,
       FM.DATA_INI_AFAST,
       FM.DATA_FIM_AFAST,
       CASE 
         WHEN FM.DATA_FIM_AFAST IS NULL 
              THEN TRUNC(FM.DATA_INI_AFAST) - TRUNC(FM.DATA_INI_AFAST) + 1
         ELSE TRUNC(FM.DATA_FIM_AFAST) - TRUNC(FM.DATA_INI_AFAST) + 1 END DIAS_AFASTAMENTO,
       SUBSTR(FD.COD_DOENCA,12,4) AS COD_DOENCA,
       DO.DESCRICAO AS DESC_DOENCA
FROM ARTERH.RHPESS_CONTRATO CNT
     INNER JOIN ARTERH.RHPESS_PESSOA PE           ON PE.CODIGO            = CNT.CODIGO_PESSOA
                                                 AND PE.CODIGO_EMPRESA    = CNT.CODIGO_EMPRESA
     INNER JOIN ARTERH.RHPLCS_CARGO CG            ON CG.CODIGO = CNT.COD_CARGO_PAGTO
                                                 AND CG.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA     
     INNER JOIN ARTERH.RHORGA_CUSTO_GEREN GER     ON GER.COD_CGERENC1 = CNT.COD_CUSTO_GERENC1
                                                 AND GER.COD_CGERENC2 = CNT.COD_CUSTO_GERENC2
                                                 AND GER.COD_CGERENC3 = CNT.COD_CUSTO_GERENC3
                                                 AND GER.COD_CGERENC4 = CNT.COD_CUSTO_GERENC4
                                                 AND GER.COD_CGERENC5 = CNT.COD_CUSTO_GERENC5
                                                 AND GER.COD_CGERENC6 = CNT.COD_CUSTO_GERENC6
                                                 AND GER.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA
     INNER JOIN ARTERH.RHORGA_CUSTO_GEREN SUP     ON SUP.COD_CGERENC1 = CNT.COD_CUSTO_GERENC1
                                                 AND SUP.COD_CGERENC2 = CNT.COD_CUSTO_GERENC2
                                                 AND SUP.COD_CGERENC3 = CNT.COD_CUSTO_GERENC3
                                                 AND SUP.COD_CGERENC4 = '000000'
                                                 AND SUP.COD_CGERENC5 = '000000'
                                                 AND SUP.COD_CGERENC6 = '000000'
                                                 AND SUP.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA
     INNER JOIN ARTERH.RHORGA_CUSTO_GEREN DIR     ON DIR.COD_CGERENC1 = CNT.COD_CUSTO_GERENC1
                                                 AND DIR.COD_CGERENC2 = CNT.COD_CUSTO_GERENC2
                                                 AND DIR.COD_CGERENC3 = '000000'
                                                 AND DIR.COD_CGERENC4 = '000000'
                                                 AND DIR.COD_CGERENC5 = '000000'
                                                 AND DIR.COD_CGERENC6 = '000000'
                                                 AND DIR.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA
     LEFT JOIN ARTERH.RHPLCS_FUNCAO FUN           ON FUN.CODIGO = CNT.CODIGO_FUNCAO
                                                 AND FUN.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA     
     LEFT JOIN ARTERH.RHPLCS_ESPECIALID ESP       ON ESP.CODIGO = CNT.COD_ESPECIALIDADE
                                                 AND ESP.CODIGO_EMPRESA = CNT.CODIGO_EMPRESA     
     INNER JOIN ARTERH.RHMEDI_FICHA_MED FM        ON FM.CODIGO_PESSOA     = CNT.CODIGO_PESSOA
                                                 AND FM.CODIGO_EMPRESA    = CNT.CODIGO_EMPRESA 
                                                 AND FM.CODIGO_CONTRATO   = CNT.CODIGO
     LEFT JOIN ARTERH.RHMEDI_RL_FICH_DOE FD       ON FD.CODIGO_PESSOA     = FM.CODIGO_PESSOA
                                                 AND FD.DT_REG_OCORRENCIA = FM.DT_REG_OCORRENCIA
                                                 AND FD.OCORRENCIA        = FM.OCORRENCIA
                                                 AND FD.CODIGO_EMPRESA    = FM.CODIGO_EMPRESA
     LEFT JOIN ARTERH.RHMEDI_DOENCA DO            ON DO.CODIGO = FD.COD_DOENCA
WHERE 1 = 1
AND CNT.ANO_MES_REFERENCIA  = ( SELECT MAX (CNT2.ANO_MES_REFERENCIA)
        								  FROM ARTERH.RHPESS_CONTRATO CNT2
        								  WHERE CNT2.CODIGO              = CNT.CODIGO											  
        								  AND   TRUNC(CNT2.ANO_MES_REFERENCIA) <= (SELECT DT_MAX_DATAS FROM ARTERH.RHPARM_P_SIST)
        								  AND   CNT2.TIPO_CONTRATO       = CNT.TIPO_CONTRATO
        								  AND   CNT2.CODIGO_EMPRESA      = CNT.CODIGO_EMPRESA)
AND CNT.CODIGO_EMPRESA = '0002'
ORDER BY CNT.CODIGO