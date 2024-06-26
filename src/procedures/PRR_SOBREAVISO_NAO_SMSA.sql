
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PRR_SOBREAVISO_NAO_SMSA" AS
BEGIN

DECLARE               
vCONTADOR NUMBER; 



BEGIN
dbms_output.enable(null);
vCONTADOR := 0;


FOR C1 IN(
SELECT 'DATA|TIPO_SOBREAVISO|HRINICIO_SOBREAVISO|HRFIM_SOBREAVISO|PREVISTO_SOBREAVISO|EXECUTADO_SOBREAVISO|EMPRESA|TIPO_CONTRATO|MATRICULA|NOME|MARCACAO_USAR1|MARCACAO_USAR2|MARCACAO_USAR3|MARCACAO_USAR4|SIT_PONTO|JUSTIFICATIVA|ACEITO|HORAS_ABONADA|H_NORMAIS|HORAS_EXCEDIDAS|HORAS_DIFERENCIADAS|COD_CARGO_EFETIVO|CARGO_EFETIVO|COD_CARGO_COMISS|CODIGO_FUNCAO|TIPO_LOCAL_SMSA|COD_CGERENC1|COD_CGERENC2|COD_CGERENC3|COD_CGERENC4|COD_CGERENC5|COD_CGERENC6|LOCAL|TIPO_LOCAL_LOTACAO|REGIONAL' 
AS LINHA FROM DUAL 
UNION ALL
SELECT 
X.DATA||'|'||X.TIPO_SOBREAVISO||'|'||X.HRINICIO_SOBREAVISO||'|'||X.HRFIM_SOBREAVISO||'|'||X.PREVISTO_SOBREAVISO||'|'||X.EXECUTADO_SOBREAVISO||'|'||X.EMPRESA||'|'||X.TIPO_CONTRATO||'|'||X.MATRICULA||'|'||X.NOME||'|'||X.MARCACAO_USAR1||'|'||X.MARCACAO_USAR2||'|'||X.MARCACAO_USAR3||'|'||X.MARCACAO_USAR4||'|'||X.SIT_PONTO||'|'||X.JUSTIFICATIVA||'|'||X.ACEITO||'|'||X.HORAS_ABONADA||'|'||X.H_NORMAIS||'|'||X.HORAS_EXCEDIDAS||'|'||X.HORAS_DIFERENCIADAS||'|'||X.COD_CARGO_EFETIVO||'|'||X.CARGO_EFETIVO||'|'||X.COD_CARGO_COMISS||'|'||X.CODIGO_FUNCAO||'|'||X.TIPO_LOCAL_SMSA||'|'||X.COD_CGERENC1||'|'||X.COD_CGERENC2||'|'||X.COD_CGERENC3||'|'||X.COD_CGERENC4||'|'||X.COD_CGERENC5||'|'||X.COD_CGERENC6||'|'||X.LOCAL||'|'||X.TIPO_LOCAL_LOTACAO||'|'||X.REGIONAL
AS LINHA
FROM(

SELECT 
E.DATA,
E.TIPO_SOBREAVISO, E.HRINICIO_SOBREAVISO, E.HRFIM_SOBREAVISO, E.PREVISTO_SOBREAVISO, E.EXECUTADO_SOBREAVISO, A.OBS,
LPAD(E.EMPRESA,4,0) EMPRESA, E.TIPO_CONTRATO, LPAD(E.MATRICULA,15,0) MATRICULA, B.NOME,
CASE WHEN E.MARCACAO1_ALTERADA IS NOT NULL AND E.ACEITO = 'ABONADO' THEN E.MARCACAO1_ALTERADA ELSE E.MARCACAO1 END MARCACAO_USAR1
,CASE WHEN E.MARCACAO2_ALTERADA IS NOT NULL AND E.ACEITO = 'ABONADO' THEN E.MARCACAO2_ALTERADA ELSE E.MARCACAO2 END MARCACAO_USAR2
,CASE WHEN E.MARCACAO3_ALTERADA IS NOT NULL AND E.ACEITO = 'ABONADO' THEN E.MARCACAO3_ALTERADA ELSE E.MARCACAO3 END MARCACAO_USAR3
,CASE WHEN E.MARCACAO4_ALTERADA IS NOT NULL AND E.ACEITO = 'ABONADO' THEN E.MARCACAO4_ALTERADA ELSE E.MARCACAO4 END MARCACAO_USAR4
,E.SIT_PONTO, SP.DESCRICAO JUSTIFICATIVA, E.ACEITO, E.HORAS_ABONADA
,E.H_NORMAIS, E.EXTRA_DIA_INFO_SEM_MENSAL HORAS_EXCEDIDAS, E.DESCONTO_DIA_INFO_SEM_MENSAL HORAS_DIFERENCIADAS
,B.COD_CARGO_EFETIVO, CE.DESCRICAO CARGO_EFETIVO,
B.COD_CARGO_COMISS, B.CODIGO_FUNCAO, GN.C_LIVRE_SELEC10 TIPO_LOCAL_SMSA, GN.COD_CGERENC1, GN.COD_CGERENC2, GN.COD_CGERENC3, GN.COD_CGERENC4, GN.COD_CGERENC5, GN.COD_CGERENC6, GN.DESCRICAO LOCAL,
CASE WHEN GN.C_LIVRE_SELEC10 = '1' THEN 'APS'
WHEN GN.C_LIVRE_SELEC10 = '2' THEN 'COM'
WHEN GN.C_LIVRE_SELEC10 = '3' THEN 'UPA'
WHEN GN.C_LIVRE_SELEC10 = '4' THEN 'SUP'
WHEN GN.C_LIVRE_SELEC10 = '5' THEN 'CER'
ELSE 'ERRO'
END TIPO_LOCAL_LOTACAO
,ENR.DESCRICAO REGIONAL
FROM 
PONTO_ELETRONICO.IFPONTO_ESPELHO_HISTORICA E
LEFT OUTER JOIN PONTO_ELETRONICO.AUTORIZACAO_EXTRA_PESSOA A ON A.COD_PESSOA = E.COD_PESSOA AND TRUNC(E.DATA) BETWEEN TRUNC(A.DTINICIO) AND TRUNC(A.DTFIM)
LEFT OUTER JOIN ARTERH.RHPESS_CONTRATO B ON LPAD(E.EMPRESA,4,0) = B.CODIGO_EMPRESA AND E.TIPO_CONTRATO = B.TIPO_CONTRATO AND LPAD(E.MATRICULA,15,0) = B.CODIGO
LEFT OUTER JOIN ARTERH.RHORGA_CUSTO_GEREN GN ON B.CODIGO_EMPRESA = GN.CODIGO_EMPRESA AND B.COD_CUSTO_GERENC1 = GN.COD_CGERENC1 AND B.COD_CUSTO_GERENC2 = GN.COD_CGERENC2 AND B.COD_CUSTO_GERENC3 = GN.COD_CGERENC3
AND B.COD_CUSTO_GERENC4 = GN.COD_CGERENC4 AND B.COD_CUSTO_GERENC5 = GN.COD_CGERENC5 AND B.COD_CUSTO_GERENC6 = GN.COD_CGERENC6
LEFT OUTER JOIN ARTERH.RHPLCS_CARGO C ON C.CODIGO_EMPRESA = B.CODIGO_EMPRESA AND C.CODIGO = B.COD_CARGO_COMISS
LEFT OUTER JOIN ARTERH.RHPLCS_CARGO CE ON CE.CODIGO_EMPRESA = B.CODIGO_EMPRESA AND CE.CODIGO = B.COD_CARGO_EFETIVO
LEFT OUTER JOIN ARTERH.RHPONT_SITUACAO SP ON SP.CODIGO = E.SIT_PONTO
LEFT OUTER JOIN ARTERH.RHORGA_ENDERECO EN ON EN.CODIGO = GN.COD_ENDERECO
LEFT OUTER JOIN ARTERH.RHORGA_ENDERECO ENR ON ENR.CODIGO = EN.CODIGO_ENDERECO01
WHERE 
B.ANO_MES_REFERENCIA = (SELECT MAX(AUX.ANO_MES_REFERENCIA) FROM ARTERH.RHPESS_CONTRATO AUX WHERE AUX.CODIGO_EMPRESA = B.CODIGO_EMPRESA AND AUX.TIPO_CONTRATO = B.TIPO_CONTRATO AND AUX.CODIGO = B.CODIGO) 
AND
E.DATA_PROCESSAMENTO IS NULL 
AND E.PREVISTO_SOBREAVISO is not null AND E.PREVISTO_SOBREAVISO > 0 AND (E.EXECUTADO_SOBREAVISO = 0 OR E.EXECUTADO_SOBREAVISO IS NULL) ---programados e nao executados
ORDER BY E.TIPO_SOBREAVISO, E.EMPRESA, E.TIPO_CONTRATO, E.MATRICULA, E.DATA

)X

)LOOP

vCONTADOR :=vCONTADOR+1;
dbms_output.put_line('--vCONTADOR: '||vCONTADOR||' C1.LINHA: '||C1.LINHA);
INSERT INTO PONTO_ELETRONICO.IFPONTO_FECHAMENTO_LOG_RELAT (DATA_DADOS, CAMPO_1, CONSIDERACOES)VALUES(SYSDATE,'PRR_SOBREAVISO_NAO_SMSA',C1.LINHA);COMMIT;

END LOOP;

END;

END;
