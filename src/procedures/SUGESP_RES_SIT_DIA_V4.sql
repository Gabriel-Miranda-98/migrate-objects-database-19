
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."SUGESP_RES_SIT_DIA_V4" (ORIGEM IN VARCHAR2, ID IN NUMBER --, DATA_PROCESSADA DATE, DADO_ORIGEM_TC1 IN VARCHAR2, DADO_DESTINO_TC1 IN VARCHAR2, ACAO IN VARCHAR2
) AS
--KELLYSSON 31/7/19

BEGIN-- 1Ã‚Âº BEGIN

DECLARE
vORIGEM VARCHAR2(20);
vID NUMBER;
vULT_DIA_APUR_IFPONTO DATE;
vULT_DIA_APUR_FOLHA_PAGAMENTO DATE; --NOVO EM 19/8/21 PARA ESTORNAR APENAS O QUE A FOLHA JA PROCESSOU E EXCLUIR O QUE AINDA NAO PROCESSOU
--vDATA_PROCESSADA DATE;
--vDADO_ORIGEM_TC1 VARCHAR2(80);
--vDADO_DESTINO_TC1 VARCHAR2(80);
--vACAO VARCHAR2(1);

BEGIN -- 2Ã‚Âº BEGIN

vORIGEM := ORIGEM;
vID := ID;
vULT_DIA_APUR_IFPONTO := NULL;
vULT_DIA_APUR_FOLHA_PAGAMENTO := NULL;

--vDATA_PROCESSADA := DATA_PROCESSADA;
--vDADO_ORIGEM_TC1 := DADO_ORIGEM_TC1;
--vDADO_DESTINO_TC1 := DADO_DESTINO_TC1;
--vACAO := ACAO;

--data ultimo fechamento apuracAO frequencia no Arterh
--COMENTADO EM 21-8-20--SELECT trunc(MAX(x.data_fim_folha)) into vULT_DIA_APUR_IFPONTO from RHPONT_APUR_AGRUP x where x.codigo_empresa = '0001' and x.tipo_apur = 'F' AND c_livre_selec01 = 2 AND id_agrup = 152123;

--novo em 19/8/21--PEGAR DATA ultimo processamento da folha ja processada ou em processamento
select u.data_fim_folha FIM_FOLHA  INTO vULT_DIA_APUR_FOLHA_PAGAMENTO from RHPONT_APUR_AGRUP u  where u.ocorrencia = (seLECT MAX(x.ocorrencia) from RHPONT_APUR_AGRUP x where x.codigo_empresa = '0001' and x.tipo_apur = 'F' AND c_livre_selec01 = 3 AND id_agrup = 152123)and u.c_livre_selec01 = 3;
dbms_output.put_line('vULT_DIA_APUR_FOLHA_PAGAMENTO: '||vULT_DIA_APUR_FOLHA_PAGAMENTO);


--INICIO 21-8-20--PARTE NOVA PARA ACHAR DATA DE FECHAMENTO 
IF vORIGEM =  'ALT_SIT_FUNC' THEN
select 
CASE WHEN V.FECHAMENTO_AGRUPADOR IS NOT NULL THEN V.FECHAMENTO_AGRUPADOR WHEN V.FECHAMENTO_ORGANOGRAMA IS NOT NULL THEN V.FECHAMENTO_ORGANOGRAMA ELSE V.FECHAMENTO_GERAL 
END DATA_USAR
--,L.codigo_empresa, L.tipo_contrato, L.codigo,  c.cod_custo_gerenc1, c.cod_custo_gerenc2, c.cod_custo_gerenc3, c.cod_custo_gerenc4, c.cod_custo_gerenc5, c.cod_custo_gerenc6 
into vULT_DIA_APUR_IFPONTO
FROM SMARH_INT_PE_ALTSITFUN_AUDITO L
left outer join (select c.* from rhpess_contrato c 
left outer join RHORGA_CUSTO_GEREN cg on c.cod_custo_gerenc1 = CG.COD_CGERENC1 AND c.cod_custo_gerenc2 = CG.COD_CGERENC2 AND c.cod_custo_gerenc3 = CG.COD_CGERENC3 AND
c.cod_custo_gerenc4 = CG.COD_CGERENC4 AND c.cod_custo_gerenc5 = CG.COD_CGERENC5 AND c.cod_custo_gerenc6 = CG.COD_CGERENC6 AND C.CODIGO_EMPRESA = CG.CODIGO_EMPRESA
where c.ano_mes_referencia = (select max(a.ano_mes_referencia) from rhpess_contrato a where a.codigo_empresa = c.codigo_empresa and a.tipo_contrato = c.tipo_contrato and a.codigo = c.codigo)
--and c.data_rescisao is null --comentado em 5/5/21 email (Re: URGENTE - Correção frequência)
)c on C.codigo_empresa = L.codigo_empresa and L.tipo_contrato = c.tipo_contrato and L.codigo = c.codigo
LEFT OUTER JOIN SUGESP_DATA_APURACAO_FREQUENC V 
ON c.cod_custo_gerenc1 = V.COD_AGRUP1 AND c.cod_custo_gerenc2 = V.COD_AGRUP2 AND c.cod_custo_gerenc3 = V.COD_AGRUP3 AND
c.cod_custo_gerenc4 = V.COD_AGRUP4 AND c.cod_custo_gerenc5 = V.COD_AGRUP5 AND c.cod_custo_gerenc6 =V.COD_AGRUP6 
--AND /*C.CODIGO_EMPRESA =*/ '0001' = V.CODIGO_EMPRESA --comentado em 5/5/21 email (Re: URGENTE - Correção frequência)
AND C.CODIGO_EMPRESA =V.CODIGO_EMPRESA----ajustado em 5/5/21 email (Re: URGENTE - Correção frequência)
where L.id = vID;

ELSIF vORIGEM =  'FERIAS' THEN
select 
CASE WHEN V.FECHAMENTO_AGRUPADOR IS NOT NULL THEN V.FECHAMENTO_AGRUPADOR WHEN V.FECHAMENTO_ORGANOGRAMA IS NOT NULL THEN V.FECHAMENTO_ORGANOGRAMA ELSE V.FECHAMENTO_GERAL 
END DATA_USAR
--,L.codigo_empresa, L.tipo_contrato, L.codigo_contrato,  c.cod_custo_gerenc1, c.cod_custo_gerenc2, c.cod_custo_gerenc3, c.cod_custo_gerenc4, c.cod_custo_gerenc5, c.cod_custo_gerenc6 
into vULT_DIA_APUR_IFPONTO
FROM PONTO_ELETRONICO.SUGESP_BI_RHFERI_FERIAS L
left outer join (select c.* from rhpess_contrato c 
left outer join RHORGA_CUSTO_GEREN cg on c.cod_custo_gerenc1 = CG.COD_CGERENC1 AND c.cod_custo_gerenc2 = CG.COD_CGERENC2 AND c.cod_custo_gerenc3 = CG.COD_CGERENC3 AND
c.cod_custo_gerenc4 = CG.COD_CGERENC4 AND c.cod_custo_gerenc5 = CG.COD_CGERENC5 AND c.cod_custo_gerenc6 = CG.COD_CGERENC6 AND C.CODIGO_EMPRESA = CG.CODIGO_EMPRESA
where c.ano_mes_referencia = (select max(a.ano_mes_referencia) from rhpess_contrato a where a.codigo_empresa = c.codigo_empresa and a.tipo_contrato = c.tipo_contrato and a.codigo = c.codigo)
--and c.data_rescisao is null --comentado em 5/5/21 email (Re: URGENTE - Correção frequência)
)c on C.codigo_empresa = L.codigo_empresa and L.tipo_contrato = c.tipo_contrato and L.codigo_contrato = c.codigo
LEFT OUTER JOIN SUGESP_DATA_APURACAO_FREQUENC V 
ON c.cod_custo_gerenc1 = V.COD_AGRUP1 AND c.cod_custo_gerenc2 = V.COD_AGRUP2 AND c.cod_custo_gerenc3 = V.COD_AGRUP3 AND
c.cod_custo_gerenc4 = V.COD_AGRUP4 AND c.cod_custo_gerenc5 = V.COD_AGRUP5 AND c.cod_custo_gerenc6 =V.COD_AGRUP6
--AND /*C.CODIGO_EMPRESA =*/ '0001' = V.CODIGO_EMPRESA --comentado em 5/5/21 email (Re: URGENTE - Correção frequência)
AND C.CODIGO_EMPRESA =V.CODIGO_EMPRESA----ajustado em 5/5/21 email (Re: URGENTE - Correção frequência)
where L.id = vID;

END IF;
--FIM 21-8-20--PARTE NOVA PARA ACHAR DATA DE FECHAMENTO 


--INICIO ---------------------------------------------------------------------------------IDENTIFICANDO ORIGENS-----------------------------------------------------------------------------------------------------------------------
--1 IF
IF vORIGEM = 'ALT_SIT_FUNC' THEN
--INICIO-------------------------------------------------------------------------------------------------------------------------'ALT_SIT_FUNC'
dbms_output.put_line(vORIGEM ||'-'||vID );
dbms_output.put_line('vULT_DIA_APUR_IFPONTO - '||vULT_DIA_APUR_IFPONTO);
BEGIN --1 'ALT_SIT_FUNC'

DECLARE
vTIPO_DML VARCHAR2(1);
vCODIGO_EMPRESA VARCHAR2(4);
vTIPO_CONTRATO VARCHAR2(4);
vCODIGO VARCHAR2(15);
vDATA_INIC_SITUACAO DATE;
vNEW_COD_SIT_FUNCIONAL VARCHAR2(4);
vSF_NEW_CONTROLE_FOLHA VARCHAR2(1);
vOLD_COD_SIT_FUNCIONAL VARCHAR2(4);
vSF_OLD_CONTROLE_FOLHA VARCHAR2(1);
vNEW_DATA_FIM_SITUACAO DATE;
vOLD_DATA_FIM_SITUACAO DATE;
vLOGIN_USUARIO VARCHAR2(40);
vLOGIN_OS VARCHAR2(40);
vSP_NEW_CODIGO VARCHAR2(4);
vSP_NEW_SITUACAO_ASSOC VARCHAR2(4);
vSP_OLD_CODIGO VARCHAR2(4);
vSP_OLD_SITUACAO_ASSOC VARCHAR2(4);
vULT_SP_NO_DIA VARCHAR2(4);
vNEW_TIPO_SP VARCHAR2(1);
vOLD_TIPO_SP VARCHAR2(1);
vOLD_SIT_FUNC_SEM_DT_FIM_PONT VARCHAR2(1);--novo em 16/8/21
vULT_CODIGO_EMPRESA  VARCHAR2(4);--novo em 16/8/21
vULT_TIPO_CONTRATO  VARCHAR2(15);--novo em 16/8/21
vULT_CODIGO_SIT_FUNC VARCHAR2(4);--novo em 16/8/21, 
vULT_DATA_INIC_SITUACAO DATE;--novo em 16/8/21
--vSER_ULT_SIT_FUNC VARCHAR2(1);--novo em 16/8/21

BEGIN --2 'ALT_SIT_FUNC'
vTIPO_DML := NULL;
vCODIGO_EMPRESA := NULL;
vTIPO_CONTRATO := NULL;
vCODIGO := NULL;
vDATA_INIC_SITUACAO := NULL;
vNEW_COD_SIT_FUNCIONAL := NULL;
vSF_NEW_CONTROLE_FOLHA := NULL;
vOLD_COD_SIT_FUNCIONAL := NULL;
vSF_OLD_CONTROLE_FOLHA := NULL;
vNEW_DATA_FIM_SITUACAO := NULL;
vOLD_DATA_FIM_SITUACAO := NULL;
vLOGIN_USUARIO := NULL;
vLOGIN_OS := NULL;
vSP_NEW_CODIGO := NULL;
vSP_NEW_SITUACAO_ASSOC := NULL;
vSP_OLD_CODIGO := NULL;
vSP_OLD_SITUACAO_ASSOC := NULL;
vULT_SP_NO_DIA := NULL;
vNEW_TIPO_SP := NULL;
vOLD_TIPO_SP := NULL;
vOLD_SIT_FUNC_SEM_DT_FIM_PONT := NULL;
vULT_CODIGO_EMPRESA := NULL;
vULT_TIPO_CONTRATO := NULL;
vULT_CODIGO_SIT_FUNC := NULL;
vULT_DATA_INIC_SITUACAO := NULL;
--vSER_ULT_SIT_FUNC := NULL;

--pegar dados para manipular
SELECT 
X.TIPO_DML,
X.CODIGO_EMPRESA,
X.TIPO_CONTRATO,
X.CODIGO,
to_date(to_char(X.DATA_INIC_SITUACAO,'dd/mm/yyyy'),'dd/mm/yyyy'),

to_date(to_char(X.NEW_DATA_FIM_SITUACAO,'dd/mm/yyyy'),'dd/mm/yyyy'),
X.NEW_COD_SIT_FUNCIONAL,
SF_NEW.CONTROLE_FOLHA SF_NEW_CONTROLE_FOLHA,
SP_NEW.CODIGO SP_NEW_CODIGO,
SP_NEW.TIPO_SITUACAO SP_NEW_TIPO_SITUACAO,
SP_NEW.SITUACAO_ASSOC SP_NEW_SITUACAO_ASSOC,

to_date(to_char(X.OLD_DATA_FIM_SITUACAO,'dd/mm/yyyy'),'dd/mm/yyyy'),
X.OLD_COD_SIT_FUNCIONAL,
SF_OLD.CONTROLE_FOLHA SF_OLD_CONTROLE_FOLHA,
SP_OLD.CODIGO SP_OLD_CODIGO,
SP_OLD.TIPO_SITUACAO SP_OLD_TIPO_SITUACAO,    
SP_OLD.SITUACAO_ASSOC SP_OLD_SITUACAO_ASSOC,

X.LOGIN_USUARIO, 
X.LOGIN_OS
INTO 
vTIPO_DML, 
vCODIGO_EMPRESA, 
vTIPO_CONTRATO, 
vCODIGO,
vDATA_INIC_SITUACAO, 

vNEW_DATA_FIM_SITUACAO, 
vNEW_COD_SIT_FUNCIONAL, 
vSF_NEW_CONTROLE_FOLHA, 
vSP_NEW_CODIGO,
vNEW_TIPO_SP, 
vSP_NEW_SITUACAO_ASSOC, 

vOLD_DATA_FIM_SITUACAO, 
vOLD_COD_SIT_FUNCIONAL, 
vSF_OLD_CONTROLE_FOLHA, 
vSP_OLD_CODIGO, 
vOLD_TIPO_SP, 
vSP_OLD_SITUACAO_ASSOC,  

vLOGIN_USUARIO, 
vLOGIN_OS
FROM SMARH_INT_PE_ALTSITFUN_AUDITO X
LEFT OUTER JOIN RHPARM_SIT_FUNC SF_NEW ON SF_NEW.CODIGO = X.NEW_COD_SIT_FUNCIONAL
LEFT OUTER JOIN RHPONT_SITUACAO SP_NEW ON SP_NEW.CODIGO = SF_NEW.SITUACAO_PONTO
LEFT OUTER JOIN RHPARM_SIT_FUNC SF_OLD ON SF_OLD.CODIGO = X.OLD_COD_SIT_FUNCIONAL
LEFT OUTER JOIN RHPONT_SITUACAO SP_OLD ON SP_OLD.CODIGO = SF_OLD.SITUACAO_PONTO
WHERE X.ID = vID;

dbms_output.put_line('vTIPO_DML: '||vTIPO_DML||' vCODIGO_EMPRESA: '||vCODIGO_EMPRESA||' vTIPO_CONTRATO: '||vTIPO_CONTRATO||' vCODIGO: '||vCODIGO||' vDATA_INIC_SITUACAO: '||vDATA_INIC_SITUACAO);
dbms_output.put_line('vNEW_DATA_FIM_SITUACAO: '||vNEW_DATA_FIM_SITUACAO||' vNEW_COD_SIT_FUNCIONAL: '||vNEW_COD_SIT_FUNCIONAL||' vSF_NEW_CONTROLE_FOLHA: '||vSF_NEW_CONTROLE_FOLHA||' vSP_NEW_CODIGO: '||vSP_NEW_CODIGO||' vNEW_TIPO_SP: '||vNEW_TIPO_SP||' vSP_NEW_SITUACAO_ASSOC: '||vSP_NEW_SITUACAO_ASSOC);
dbms_output.put_line('vOLD_DATA_FIM_SITUACAO: '||vOLD_DATA_FIM_SITUACAO||' vOLD_COD_SIT_FUNCIONAL: '||vOLD_COD_SIT_FUNCIONAL||' vSF_OLD_CONTROLE_FOLHA: '||vSF_OLD_CONTROLE_FOLHA||' vSP_OLD_CODIGO: '||vSP_OLD_CODIGO||' vOLD_TIPO_SP: '||vOLD_TIPO_SP||' vSP_OLD_SITUACAO_ASSOC: '||vSP_OLD_SITUACAO_ASSOC);
dbms_output.put_line('vLOGIN_USUARIO:'||vLOGIN_USUARIO||' vLOGIN_OS: '||vLOGIN_OS);
--novo INICIO -------------------------------------------------------------------------------------------------------em 16/8/21

--sit func com sit ponto mas sem data fim no cadastro da sit func?
IF vTIPO_DML <> 'I' THEN
SELECT CASE WHEN SUM(X.QUANT) = 1 THEN 'S' ELSE 'N' END
INTO vOLD_SIT_FUNC_SEM_DT_FIM_PONT
FROM(
SELECT COUNT(1)QUANT
 FROM 
RHPARM_SIT_FUNC SF 
LEFT OUTER JOIN RHPONT_SITUACAO SP ON SP.CODIGO = SF.SITUACAO_PONTO
WHERE SF.CONTROLE_FOLHA IN ('N','O') AND SF.SITUACAO_PONTO IS NOT NULL AND SF.CODIGO = vOLD_COD_SIT_FUNCIONAL
)X ;
ELSE
SELECT CASE WHEN SUM(X.QUANT) = 1 THEN 'S' ELSE 'N' END
INTO vOLD_SIT_FUNC_SEM_DT_FIM_PONT
FROM(
SELECT COUNT(1)QUANT
 FROM 
RHPARM_SIT_FUNC SF 
LEFT OUTER JOIN RHPONT_SITUACAO SP ON SP.CODIGO = SF.SITUACAO_PONTO
WHERE SF.CONTROLE_FOLHA IN ('N','O') AND SF.SITUACAO_PONTO IS NOT NULL AND SF.CODIGO = vNEW_COD_SIT_FUNCIONAL
)X ;
END IF;
dbms_output.put_line('vOLD_SIT_FUNC_SEM_DT_FIM_PONT: '||vOLD_SIT_FUNC_SEM_DT_FIM_PONT);
-- sit func com sit ponto mas sem data fim no primeiro momento?

--pegar ult ALT SIT FUNC
/* erro mutante
 SELECT A.CODIGO_EMPRESA, A.TIPO_CONTRATO, A.CODIGO, A.DATA_INIC_SITUACAO
INTO vULT_CODIGO_EMPRESA , vULT_TIPO_CONTRATO, vULT_CODIGO_SIT_FUNC, vULT_DATA_INIC_SITUACAO 
    FROM RHCGED_ALT_SIT_FUN A
    WHERE  A.CODIGO_EMPRESA = vCODIGO_EMPRESA AND A.TIPO_CONTRATO = vTIPO_CONTRATO AND A.CODIGO = vCODIGO
    AND A.DATA_INIC_SITUACAO = (SELECT MAX(AUX.DATA_INIC_SITUACAO)FROM RHCGED_ALT_SIT_FUN AUX
                                WHERE  A.CODIGO_EMPRESA = AUX.CODIGO_EMPRESA AND A.TIPO_CONTRATO = AUX.TIPO_CONTRATO AND A.CODIGO = AUX.CODIGO);
*/

--SELECT E_ULT_ALT_SIT_FUNC (vCODIGO_EMPRESA, vTIPO_CONTRATO, vCODIGO,vDATA_INIC_SITUACAO) INTO vSER_ULT_SIT_FUNC FROM DUAL;
--pegar ult ALT SIT FUNC

--DEFINI SER A ULTIMA OU NAO SIT FUNC NO HISTORICO
/*
IF TRUNC(vDATA_INIC_SITUACAO) = TRUNC(vULT_DATA_INIC_SITUACAO) THEN
vSER_ULT_SIT_FUNC := 'S';
dbms_output.put_line('vSER_ULT_SIT_FUNC: '||vSER_ULT_SIT_FUNC);
ELSE 
vSER_ULT_SIT_FUNC := 'N';
dbms_output.put_line('vSER_ULT_SIT_FUNC: '||vSER_ULT_SIT_FUNC);
END IF;
*/
--DEFINI SER A ULTIMA OU NAO SIT FUNC NO HISTORICO
--novo FIM------------------------------------------------------------------------------------------------------------------em 16/8/21


IF (vTIPO_DML = 'I' AND vSP_NEW_CODIGO IS NOT NULL)
 OR((vTIPO_DML = 'U' AND vSP_NEW_CODIGO IS NOT NULL)OR(vTIPO_DML = 'U' AND vSP_OLD_CODIGO IS NOT NULL))
 OR (vTIPO_DML = 'D' AND vSP_OLD_CODIGO IS NOT NULL)
THEN --inicio--Valor ANTIGO ou NOVO possuem Situacao Ponto associada?
dbms_output.put_line('Valor ANTIGO ou NOVO possuem SituACo Ponto associada? = SIM');
dbms_output.put_line('SITUACAO FUNCIONAL OLD- '||vOLD_COD_SIT_FUNCIONAL ||'NEW -'||vNEW_COD_SIT_FUNCIONAL);


--------------------------------------------------------------DELETE
IF vTIPO_DML = 'D' AND (
vOLD_DATA_FIM_SITUACAO IS NOT NULL )
--COMENTADO EM 17/8/21 --OR (vSP_OLD_CODIGO IS NOT NULL AND vSF_OLD_CONTROLE_FOLHA IN ('N','O') AND vOLD_DATA_FIM_SITUACAO IS NULL AND vNEW_DATA_FIM_SITUACAO IS NULL))--NOVO EM 27/4/21 EMAIL (retorno acs do INSS)

THEN
dbms_output.put_line('delete ALT SIT FUNC AFASTAMENTO COM DATA FIM');

--COMENTADO EM 17/8/21 --IF vOLD_DATA_FIM_SITUACAO IS NULL THEN --NOVO EM 27/4/21 EMAIL (retorno acs do INSS)
--COMENTADO EM 17/8/21 --SELECT LAST_DAY(SYSDATE) INTO vOLD_DATA_FIM_SITUACAO FROM DUAL;
--COMENTADO EM 17/8/21 --END IF;--NOVO EM 27/4/21 EMAIL (retorno acs do INSS)


FOR C1 IN
(
select D.DATA_DIA from RHTABS_DATAS D WHERE trunc(D.DATA_DIA) BETWEEN trunc(vDATA_INIC_SITUACAO) AND trunc(vOLD_DATA_FIM_SITUACAO) order by d.data_dia
--select D.DATA_DIA from RHTABS_DATAS D WHERE D.DATA_DIA BETWEEN TO_DATE(vDATA_INIC_SITUACAO,'DD/MM/YY') AND TO_DATE(vOLD_DATA_FIM_SITUACAO,'DD/MM/YY')order by d.data_dia
)
LOOP
dbms_output.put_line('C1.DATA_DIA - '|| C1.DATA_DIA);
--inicio --para estorno se tiver jÃƒÂ¡ lanÃƒÂ§amento no dia pega a ultima lanÃƒÂ§ada no dia
FOR C2 IN (
SELECT SP.CODIGO_SITUACAO ULT_SP_NO_DIA, S.TIPO_SITUACAO , S.situacao_assoc
,SP.REF_HORAS --NOVO EM 16/3/22
FROM RHPONT_RES_SIT_DIA SP
LEFT OUTER JOIN RHPONT_SITUACAO S ON SP.CODIGO_SITUACAO = S.CODIGO
WHERE SP.CODIGO_EMPRESA = vCODIGO_EMPRESA AND SP.TIPO_CONTRATO = vTIPO_CONTRATO AND SP.CODIGO_CONTRATO = vCODIGO
AND trunc(SP.DATA) = trunc(C1.DATA_DIA)
AND SP.DT_ULT_ALTER_USUA = (SELECT MAX(AUX.DT_ULT_ALTER_USUA) FROM RHPONT_RES_SIT_DIA AUX 
LEFT OUTER JOIN RHPONT_SITUACAO SA ON SA.CODIGO = AUX.CODIGO_SITUACAO
WHERE AUX.CODIGO_EMPRESA = vCODIGO_EMPRESA AND AUX.TIPO_CONTRATO = vTIPO_CONTRATO AND AUX.CODIGO_CONTRATO = vCODIGO
AND trunc(AUX.DATA) = trunc(C1.DATA_DIA)
AND SA.CODIGO <> '1013'--AND SA.TIPO_SITUACAO <> 'F' AND SA.TIPO_REFERENCIA <> 'H' --NOVO EM 30/3/22 EMAIL (Fwd: Licença Médica Pendente não lançada)
AND AUX.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
AND SP.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
LOOP
--dbms_output.put_line('C2.ULT_SP_NO_DIA - '|| C2.ULT_SP_NO_DIA);
IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --Periodo do Lancamento (total/parcial) ja fechado Ifponto? = SIM
AND vSP_OLD_CODIGO IS NOT NULL --Lancamento possuia Situacao Ponto vinculada? = SIM
AND vOLD_TIPO_SP IN ('P','I') --somente situacoes do tipo AFASTAMENTOS
--AND C2.ULT_SP_NO_DIA IS NOT NULL AND C2.ULT_SP_NO_DIA  = vSP_OLD_CODIGO --A ultima situaaco ponto no dia ser a mesma da vinculada a do lancamento? = SIM
--AND C2.situacao_assoc IS NOT NULL THEN --A Situacao Ponto possuiA situacao de estorno associada? = SIM
THEN
--1 TAREFA
dbms_output.put_line('1 TAREFA-Exclui SituaCAo Ponto - '||vSP_OLD_CODIGO||' delete ALT SIT FUNC vOLD_TIPO_SP P,I');
DELETE RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vCODIGO AND trunc(DATA) = trunc(C1.DATA_DIA) AND CODIGO_SITUACAO = vSP_OLD_CODIGO
AND TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
;
--inicio --para Grava ultima Situacao Ponto do dia tipo FALTA/ATRASOS se existir
FOR C3 IN (
SELECT SP.CODIGO_SITUACAO ULT_SP_NO_DIA, S.TIPO_SITUACAO S_TIPO_SITUACAO
FROM RHPONT_RES_SIT_DIA SP
LEFT OUTER JOIN RHPONT_SITUACAO S ON SP.CODIGO_SITUACAO = S.CODIGO
WHERE SP.CODIGO_EMPRESA = vCODIGO_EMPRESA AND SP.TIPO_CONTRATO = vTIPO_CONTRATO AND SP.CODIGO_CONTRATO = vCODIGO
--AND S.tipo_situacao = 'F'----PARTE QUE DIFERE DO C2 PARA VER SE ser DO TIPO FALTA/ATRASOS
AND trunc(SP.DATA) = trunc(C1.DATA_DIA)
AND SP.DT_ULT_ALTER_USUA = (SELECT MAX(AUX.DT_ULT_ALTER_USUA) FROM RHPONT_RES_SIT_DIA AUX WHERE AUX.CODIGO_EMPRESA = vCODIGO_EMPRESA AND AUX.TIPO_CONTRATO = vTIPO_CONTRATO AND AUX.CODIGO_CONTRATO = vCODIGO
AND trunc(AUX.DATA) = trunc(C1.DATA_DIA)
AND AUX.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
AND SP.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência

) LOOP
IF C3.ULT_SP_NO_DIA IS NOT NULL AND C3.S_TIPO_SITUACAO = 'C' THEN -- No dia ha e ser a ultima Estorno de Sit. Ponto tipo FALTA/ATRASOS? = SIM
--2 TAREFA
dbms_output.put_line('2 TAREFA-Exclui SituCAo de Ponto do Estorno - '||C3.ULT_SP_NO_DIA||'-'||C3.S_TIPO_SITUACAO);
DELETE RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vCODIGO AND trunc(DATA) = trunc(C1.DATA_DIA) AND CODIGO_SITUACAO = C3.ULT_SP_NO_DIA;
END IF;

END LOOP;--LOOP 3
END IF;

--inicio --------------------------------------------------------------------------------------------------novo em 18/8/21
IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --Periodo do Lancamento (total/parcial) ja fechado Ifponto? = SIM
AND vSP_OLD_CODIGO IS NOT NULL --Lancamento possuia Situacao Ponto vinculada? = SIM
AND vOLD_TIPO_SP IN ('F') --SIT PONTO DE FALTA? SIM
AND C2.ULT_SP_NO_DIA IS NOT NULL AND C2.ULT_SP_NO_DIA  = vSP_OLD_CODIGO --A ultima situaaco ponto no dia ser a mesma da vinculada a do lancamento? = SIM
AND C2.situacao_assoc IS NOT NULL  --A Situacao Ponto possuiA situacao de estorno associada? = SIM
AND C1.DATA_DIA <= vULT_DIA_APUR_FOLHA_PAGAMENTO --NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21
THEN
--4 TAREFA
dbms_output.put_line('4 TAREFA-Cria Estorno da SituaCAo de Ponto - '||C2.ULT_SP_NO_DIA ||'-'||C2.TIPO_SITUACAO||'-'||C2.situacao_assoc||'delete ALT SIT FUNC AFASTAMENTO COM DATA FIM');
DELETE RHPONT_RES_SIT_DIA where CODIGO_EMPRESA = vCODIGO_EMPRESA and TIPO_CONTRATO = vTIPO_CONTRATO and CODIGO_CONTRATO = vCODIGO and trunc(DATA) = trunc(C1.DATA_DIA) and CODIGO_SITUACAO = C2.situacao_assoc and REF_HORAS = 1 and TIPO_APURACAO = 'F';--NOVO EM 20/1/20
INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, LOGIN_USUARIO, DT_ULT_ALTER_USUA, TIPO_APURACAO, FORCA_SITUACAO  )
VALUES (vCODIGO_EMPRESA, vTIPO_CONTRATO, vCODIGO,trunc(C1.DATA_DIA), C2.situacao_assoc, 
C2.REF_HORAS,--AJUSTE EM 16/3/22
vLOGIN_USUARIO, SYSDATE , 'F', 'N');
END IF;
--fim--------------------------------------------------------------------------------------------------novo em 18/8/21

--inicio ---------------------------------------------------------------------------------------------------NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21
IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --Periodo do Lancamento (total/parcial) ja fechado Ifponto? = SIM
AND vSP_OLD_CODIGO IS NOT NULL --Lancamento possuia Situacao Ponto vinculada? = SIM
AND vOLD_TIPO_SP IN ('F') --SIT PONTO DE FALTA? SIM
AND C2.ULT_SP_NO_DIA IS NOT NULL AND C2.ULT_SP_NO_DIA  = vSP_OLD_CODIGO --A ultima situaaco ponto no dia ser a mesma da vinculada a do lancamento? = SIM
AND C2.situacao_assoc IS NOT NULL  --A Situacao Ponto possuiA situacao de estorno associada? = SIM
AND C1.DATA_DIA > vULT_DIA_APUR_FOLHA_PAGAMENTO --NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21
THEN
--1 TAREFA
dbms_output.put_line('1 TAREFA-Exclui SituaCAo Ponto - '||vSP_OLD_CODIGO||' delete SIT PONTO TIPO FALTA MAS COM DATA POSTERIOR AO ULTIMO FECHAMENTO DA FOLHA LOCAL1');
DELETE RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vCODIGO AND trunc(DATA) = trunc(C1.DATA_DIA) AND CODIGO_SITUACAO = vSP_OLD_CODIGO
AND TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
;
END IF;
--fim--------------------------------------------------------------------------------------------------NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21

END LOOP;--LOOP 2
END LOOP;--LOOP 1


--/*
--inicio -------------------------- novo em 16/8/21 --para corrigir erro de situacoes funcionais sem data fim no primeiro momento depois com data fim onde o fim foi retroativo e ja havia sit ponto gravadas para apagar essas
ELSIF vTIPO_DML = 'D' AND --vSER_ULT_SIT_FUNC = 'S' AND
vOLD_SIT_FUNC_SEM_DT_FIM_PONT = 'S' 
AND vOLD_DATA_FIM_SITUACAO IS NULL 
THEN

dbms_output.put_line('delete ALT SIT FUNC SEM DATA FIM APAGA vOLD_SIT_FUNC_SEM_DT_FIM_PONT = S');
FOR C1 IN
(select D.DATA_DIA from RHTABS_DATAS D WHERE trunc(D.DATA_DIA) BETWEEN trunc(vDATA_INIC_SITUACAO) AND trunc(vULT_DIA_APUR_IFPONTO) order by d.data_dia)
LOOP
dbms_output.put_line('C1.DATA_DIA - '|| C1.DATA_DIA);
--inicio --para estorno se tiver ja lancamento no dia pega a ultima lancada no dia
FOR C2 IN (
SELECT SP.CODIGO_SITUACAO ULT_SP_NO_DIA, S.TIPO_SITUACAO , S.situacao_assoc
,SP.REF_HORAS --NOVO EM 16/3/22
FROM RHPONT_RES_SIT_DIA SP
LEFT OUTER JOIN RHPONT_SITUACAO S ON SP.CODIGO_SITUACAO = S.CODIGO
WHERE SP.CODIGO_EMPRESA = vCODIGO_EMPRESA AND SP.TIPO_CONTRATO = vTIPO_CONTRATO AND SP.CODIGO_CONTRATO = vCODIGO
AND trunc(SP.DATA) = trunc(C1.DATA_DIA)
AND SP.DT_ULT_ALTER_USUA = (SELECT MAX(AUX.DT_ULT_ALTER_USUA) FROM RHPONT_RES_SIT_DIA AUX 
LEFT OUTER JOIN RHPONT_SITUACAO SA ON SA.CODIGO = AUX.CODIGO_SITUACAO
WHERE AUX.CODIGO_EMPRESA = vCODIGO_EMPRESA AND AUX.TIPO_CONTRATO = vTIPO_CONTRATO AND AUX.CODIGO_CONTRATO = vCODIGO
AND trunc(AUX.DATA) = trunc(C1.DATA_DIA)
AND SA.CODIGO <> '1013'--AND SA.TIPO_SITUACAO <> 'F' AND SA.TIPO_REFERENCIA <> 'H' --NOVO EM 30/3/22 EMAIL (Fwd: Licença Médica Pendente não lançada)
AND AUX.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
AND SP.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)

LOOP
--dbms_output.put_line('C2.ULT_SP_NO_DIA - '|| C2.ULT_SP_NO_DIA);
IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --Periodo do Lancamento (total/parcial) ja fechado Ifponto? = SIM
AND vSP_OLD_CODIGO IS NOT NULL --Lancamento possui Situaco Ponto vinculada? = SIM
--AND C2.ULT_SP_NO_DIA IS NOT NULL AND C2.situacao_assoc IS NOT NULL --A ultima situacao ponto no dia possui situacao de estorno? = SIM
AND C2.TIPO_SITUACAO <> 'C'--A ultima situacao ponto no dia ser o ESTORNO de uma FALTA/ATRASOS ? = NAO
AND C2.TIPO_SITUACAO = 'F'--A ultima situacao ponto ser de FALTA/ATRASOS? = SIM
AND C2.ULT_SP_NO_DIA = vSP_OLD_CODIGO 
and  C2.situacao_assoc IS NOT NULL 
AND C1.DATA_DIA <= vULT_DIA_APUR_FOLHA_PAGAMENTO -- PARA ESTORNAR--NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21
THEN
--IF  C2.situacao_assoc IS NOT NULL -- difere do novo em 16/8/21 PARA CRIAR ESTORNO APENAS SE SIT PONTO DE FALTA FOR DIFERENTE DA SIT PONTO DA SIT FUNC EMAIL de 12/08/21(Problema Lancamento Automatico)
--THEN
--4 TAREFA
dbms_output.put_line('4 TAREFA-Cria Estorno da SituaCAo de Ponto - '||C2.ULT_SP_NO_DIA ||'-'||C2.TIPO_SITUACAO||'-'||C2.situacao_assoc||' vOLD_SIT_FUNC_SEM_DT_FIM_PONT = S');
DELETE RHPONT_RES_SIT_DIA where CODIGO_EMPRESA = vCODIGO_EMPRESA and TIPO_CONTRATO = vTIPO_CONTRATO and CODIGO_CONTRATO = vCODIGO and trunc(DATA) = trunc(C1.DATA_DIA) and CODIGO_SITUACAO = C2.situacao_assoc and REF_HORAS = 1 and TIPO_APURACAO = 'F';--NOVO EM 20/1/20
INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, LOGIN_USUARIO, DT_ULT_ALTER_USUA, TIPO_APURACAO, FORCA_SITUACAO  )
VALUES (vCODIGO_EMPRESA, vTIPO_CONTRATO, vCODIGO,trunc(C1.DATA_DIA), C2.situacao_assoc, 
C2.REF_HORAS,--AJUSTE EM 16/3/22 
vLOGIN_USUARIO, SYSDATE, 'F', 'N');
--/*comentado 17/8/21 17h
END IF;--4 TAREFA

--INICIO-----------------------------NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21
IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --Periodo do Lancamento (total/parcial) ja fechado Ifponto? = SIM
AND vSP_OLD_CODIGO IS NOT NULL --Lancamento possui Situaco Ponto vinculada? = SIM
--AND C2.ULT_SP_NO_DIA IS NOT NULL AND C2.situacao_assoc IS NOT NULL --A ultima situacao ponto no dia possui situacao de estorno? = SIM
AND C2.TIPO_SITUACAO <> 'C'--A ultima situacao ponto no dia ser o ESTORNO de uma FALTA/ATRASOS ? = NAO
AND C2.TIPO_SITUACAO = 'F'--A ultima situacao ponto ser de FALTA/ATRASOS? = SIM
AND C2.ULT_SP_NO_DIA = vSP_OLD_CODIGO 
and  C2.situacao_assoc IS NOT NULL 
AND C1.DATA_DIA > vULT_DIA_APUR_FOLHA_PAGAMENTO -- PARA DELETAR--NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21
THEN
--1 TAREFA
dbms_output.put_line('1 TAREFA-Exclui SituaCAo Ponto - '||vSP_OLD_CODIGO||' delete SIT PONTO TIPO FALTA MAS COM DATA POSTERIOR AO ULTIMO FECHAMENTO DA FOLHA LOCAL2');
DELETE RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vCODIGO AND trunc(DATA) = trunc(C1.DATA_DIA) AND CODIGO_SITUACAO = vSP_OLD_CODIGO
AND TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
;
END IF;--1 TAREFA
--FIM--------------------------------NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21


IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --Periodo do Lancamento (total/parcial) ja fechado Ifponto? = SIM
AND vSP_OLD_CODIGO IS NOT NULL --Lancamento possui Situaco Ponto vinculada? = SIM
--AND C2.ULT_SP_NO_DIA IS NOT NULL AND C2.situacao_assoc IS NOT NULL --A ultima situacao ponto no dia possui situacao de estorno? = SIM
AND C2.TIPO_SITUACAO <> 'C'--A ultima situacao ponto no dia ser o ESTORNO de uma FALTA/ATRASOS ? = NAO
AND C2.TIPO_SITUACAO <> 'F'--A ultima situacao ponto ser de FALTA/ATRASOS? = NAO
AND C2.ULT_SP_NO_DIA = vSP_OLD_CODIGO  /*AND C2.situacao_assoc IS NULL*/ -- difere do novo em 16/8/21 PARA CRIAR ESTORNO APENAS SE SIT PONTO DE FALTA FOR DIFERENTE DA SIT PONTO DA SIT FUNC EMAIL de 12/08/21(Problema Lancamento Automatico)
and C2.situacao_assoc IS NULL 
THEN
--*/
--ELSE --NVO EM  17/8/21 17h
--1 TAREFA
--ELSIF  C2.situacao_assoc IS NULL -- difere do novo em 16/8/21 PARA CRIAR ESTORNO APENAS SE SIT PONTO DE FALTA FOR DIFERENTE DA SIT PONTO DA SIT FUNC EMAIL de 12/08/21(Problema Lancamento Automatico)
--THEN
dbms_output.put_line('1 TAREFA-Exclui SituaCAo Ponto - '||vSP_OLD_CODIGO||'  vOLD_SIT_FUNC_SEM_DT_FIM_PONT = S');
DELETE RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vCODIGO AND trunc(DATA) = trunc(C1.DATA_DIA) AND CODIGO_SITUACAO = vSP_OLD_CODIGO
AND TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
;
END IF;--1 TAREFA

--END IF;

END LOOP;--LOOP 2
END LOOP;--LOOP 1
--END IF;
--fim --------------------------------------- novo em 16/8/21 --para corrigir erro de situacoes funcionais sem data fim no primeiro momento depois com data fim onde o fim foi retroativo e ja havia sit ponto gravadas para apagar essas
--*/

-----------------------------------------------------------------------------------------------------------------------------UPDATE
---------------------------------------------------------------------UPDATE OLD
ELSIF vTIPO_DML = 'U' AND (vOLD_DATA_FIM_SITUACAO IS NOT NULL OR vNEW_DATA_FIM_SITUACAO IS NOT NULL)
AND vOLD_SIT_FUNC_SEM_DT_FIM_PONT = 'N' --AND NOVO EM 18/8/21
--ELSIF vTIPO_DML = 'U' AND vOLD_DATA_FIM_SITUACAO IS NOT NULL
THEN
dbms_output.put_line('update-old ALT SIT FUNC');
FOR C1 IN
(select D.DATA_DIA from RHTABS_DATAS D WHERE trunc(D.DATA_DIA) BETWEEN trunc(vDATA_INIC_SITUACAO) AND trunc(vOLD_DATA_FIM_SITUACAO)order by d.data_dia)
LOOP
dbms_output.put_line('C1.DATA_DIA - '|| C1.DATA_DIA);
--inicio --para estorno se tiver ja lancamento no dia pega a ultima lancada no dia
FOR C2 IN (
SELECT SP.CODIGO_SITUACAO ULT_SP_NO_DIA, S.TIPO_SITUACAO , S.situacao_assoc
FROM RHPONT_RES_SIT_DIA SP
LEFT OUTER JOIN RHPONT_SITUACAO S ON SP.CODIGO_SITUACAO = S.CODIGO
WHERE SP.CODIGO_EMPRESA = vCODIGO_EMPRESA AND SP.TIPO_CONTRATO = vTIPO_CONTRATO AND SP.CODIGO_CONTRATO = vCODIGO
AND trunc(SP.DATA) = trunc(C1.DATA_DIA)
AND SP.DT_ULT_ALTER_USUA = (SELECT MAX(AUX.DT_ULT_ALTER_USUA) FROM RHPONT_RES_SIT_DIA AUX WHERE AUX.CODIGO_EMPRESA = vCODIGO_EMPRESA AND AUX.TIPO_CONTRATO = vTIPO_CONTRATO AND AUX.CODIGO_CONTRATO = vCODIGO
AND trunc(AUX.DATA) = trunc(C1.DATA_DIA)
AND AUX.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
AND SP.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
LOOP
--dbms_output.put_line('C2.ULT_SP_NO_DIA - '|| C2.ULT_SP_NO_DIA);
IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --Perioodo do Lancaamento (total/parcial) ja fechado Ifponto? = SIM
AND vSP_OLD_CODIGO IS NOT NULL --Lancamento possuia Situacao Ponto vinculada? = SIM
--AND C2.ULT_SP_NO_DIA IS NOT NULL AND C2.ULT_SP_NO_DIA  = vSP_OLD_CODIGO --A ultima situacao ponto no dia ser a mesma da vinculada a do lancaamento? = SIM
--AND C2.situacao_assoc IS NOT NULL  --A Situacao Ponto possuiA situacao de estorno associada? = SIM
AND vOLD_TIPO_SP IN ('P','I')--somente situacoes do tipo AFASTAMENTOS
THEN
--3 TAREFA
dbms_output.put_line('3 TAREFA-Exclui SituaCAo Ponto - '||vSP_OLD_CODIGO);
DELETE RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vCODIGO AND trunc(DATA) = trunc(C1.DATA_DIA) AND CODIGO_SITUACAO = vSP_OLD_CODIGO
AND TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
;

END IF;
IF vSP_NEW_SITUACAO_ASSOC IS NULL THEN
--inicio --para Grava ultima Situacao Ponto do dia tipo FALTA/ATRASOS se existir
FOR C3 IN (
SELECT SP.CODIGO_SITUACAO ULT_SP_NO_DIA, S.TIPO_SITUACAO S_TIPO_SITUACAO
FROM RHPONT_RES_SIT_DIA SP
LEFT OUTER JOIN RHPONT_SITUACAO S ON SP.CODIGO_SITUACAO = S.CODIGO
WHERE SP.CODIGO_EMPRESA = vCODIGO_EMPRESA AND SP.TIPO_CONTRATO = vTIPO_CONTRATO AND SP.CODIGO_CONTRATO = vCODIGO
--AND S.tipo_situacao = 'F'----PARTE QUE DIFERE DO C2 PARA VER SE ser DO TIPO FALTA/ATRASOS
AND trunc(SP.DATA) = trunc(C1.DATA_DIA)
AND SP.DT_ULT_ALTER_USUA = (SELECT MAX(AUX.DT_ULT_ALTER_USUA) FROM RHPONT_RES_SIT_DIA AUX WHERE AUX.CODIGO_EMPRESA = vCODIGO_EMPRESA AND AUX.TIPO_CONTRATO = vTIPO_CONTRATO AND AUX.CODIGO_CONTRATO = vCODIGO
AND trunc(AUX.DATA) = trunc(C1.DATA_DIA)
AND AUX.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
AND SP.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
LOOP
IF C3.ULT_SP_NO_DIA IS NOT NULL AND C3.S_TIPO_SITUACAO = 'C' THEN -- No dia ha e ser a ultima Estorno de Sit. Ponto tipo FALTA/ATRASOS? = SIM
--5 TAREFA
dbms_output.put_line('5 TAREFA-Exclui SituACAo de Ponto do Estorno - '||C3.ULT_SP_NO_DIA||'-'||C3.S_TIPO_SITUACAO);
DELETE RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vCODIGO AND trunc(DATA) = trunc(C1.DATA_DIA) AND CODIGO_SITUACAO = C3.ULT_SP_NO_DIA
AND TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
;

END IF;-- IF C3
END LOOP;--LOOP 3
END IF;
END LOOP;--LOOP 2
END LOOP;--LOOP 1


------------------------------------------------------------------------UPDATE NEW
--ELSIF vTIPO_DML = 'U' AND vNEW_DATA_FIM_SITUACAO IS NOT NULL  THEN
dbms_output.put_line('update-new ALT SIT FUNC');
FOR C1 IN
(select D.DATA_DIA from RHTABS_DATAS D WHERE trunc(D.DATA_DIA) BETWEEN trunc(vDATA_INIC_SITUACAO) AND trunc(vNEW_DATA_FIM_SITUACAO)order by d.data_dia)
LOOP
dbms_output.put_line('C1.DATA_DIA - '|| C1.DATA_DIA);
--inicio --para estorno se tiver ja lancamento no dia pega a ultima lancada no dia
FOR C2 IN (
SELECT SP.CODIGO_SITUACAO ULT_SP_NO_DIA, S.TIPO_SITUACAO , S.situacao_assoc
,SP.REF_HORAS --NOVO EM 16/3/22
FROM RHPONT_RES_SIT_DIA SP
LEFT OUTER JOIN RHPONT_SITUACAO S ON SP.CODIGO_SITUACAO = S.CODIGO
WHERE SP.CODIGO_EMPRESA = vCODIGO_EMPRESA AND SP.TIPO_CONTRATO = vTIPO_CONTRATO AND SP.CODIGO_CONTRATO = vCODIGO
AND trunc(SP.DATA) = trunc(C1.DATA_DIA)
AND SP.DT_ULT_ALTER_USUA = (SELECT MAX(AUX.DT_ULT_ALTER_USUA) FROM RHPONT_RES_SIT_DIA AUX LEFT OUTER JOIN RHPONT_SITUACAO SA ON SA.CODIGO = AUX.CODIGO_SITUACAO
WHERE AUX.CODIGO_EMPRESA = vCODIGO_EMPRESA AND AUX.TIPO_CONTRATO = vTIPO_CONTRATO AND AUX.CODIGO_CONTRATO = vCODIGO
AND trunc(AUX.DATA) = trunc(C1.DATA_DIA)
AND SA.CODIGO <> '1013'--AND SA.TIPO_SITUACAO <> 'F' AND SA.TIPO_REFERENCIA <> 'H' --NOVO EM 30/3/22 EMAIL (Fwd: Licença Médica Pendente não lançada)
AND AUX.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
AND SP.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
LOOP
--dbms_output.put_line('C2.ULT_SP_NO_DIA - '|| C2.ULT_SP_NO_DIA);
IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --Periodo do Lancamento (total/parcial) ja fechado Ifponto? = SIM
AND vSP_NEW_CODIGO IS NOT NULL --Lancamento possui Situaco Ponto vinculada? = SIM
--AND C2.ULT_SP_NO_DIA IS NOT NULL AND C2.situacao_assoc IS NOT NULL --A ultima situacao ponto no dia possui situacao de estorno? = SIM
AND C2.TIPO_SITUACAO <> 'C'--A ultima situacao ponto no dia ser o ESTORNO de uma FALTA/ATRASOS ? = NAO
AND C2.TIPO_SITUACAO = 'F'--A ultima situacao ponto ser de FALTA/ATRASOS? = SIM
AND C2.ULT_SP_NO_DIA <> vSP_NEW_CODIGO --novo em 16/8/21 PARA CRIAR ESTORNO APENAS SE SIT PONTO DE FALTA FOR DIFERENTE DA SIT PONTO DA SIT FUNC EMAIL de 12/08/21(Problema Lancamento Automatico)
AND C2.SITUACAO_ASSOC IS NOT NULL --MAS INSERIDO MESMO NO CODIGO EM 27/7/22 EMAIL (SITUAÇÃO FUNCIONAL NÃO REFLETIDA - LICENÇAS MÉDICAS)--NOVO EM 28/6/22 AJUSTE JA PENSADO EM OUTRO EMAIL MAS FEITO DEVIDO AO CASO (Ordem de serviço Lázara Cassiano)
THEN
--4 TAREFA
dbms_output.put_line('4 TAREFA-Cria Estorno da SituaCAo de Ponto - '||C2.ULT_SP_NO_DIA ||'-'||C2.TIPO_SITUACAO||'-'||C2.situacao_assoc);
DELETE RHPONT_RES_SIT_DIA where CODIGO_EMPRESA = vCODIGO_EMPRESA and TIPO_CONTRATO = vTIPO_CONTRATO and CODIGO_CONTRATO = vCODIGO and trunc(DATA) = trunc(C1.DATA_DIA) and CODIGO_SITUACAO = C2.situacao_assoc and REF_HORAS = 1 and TIPO_APURACAO = 'F';--NOVO EM 20/1/20
INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, LOGIN_USUARIO, DT_ULT_ALTER_USUA, TIPO_APURACAO, FORCA_SITUACAO  )
VALUES (vCODIGO_EMPRESA, vTIPO_CONTRATO, vCODIGO,trunc(C1.DATA_DIA), C2.situacao_assoc, 
C2.REF_HORAS,--AJUSTE EM 16/3/22
vLOGIN_USUARIO, SYSDATE - 1/24/60/60, 'F', 'N');
END IF;--4 TAREFA
END LOOP;--LOOP 2
IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --PeRIOodo do LanCAamento (total/parcial) jA fechado Ifponto? = SIM
AND vSP_NEW_CODIGO IS NOT NULL THEN --LanCAamento possui SituaCAo Ponto vinculada? = SIM
--7 TAREFA
dbms_output.put_line('7 TAREFA-Cria na data a situaCAo ponto para o bm - '||vSP_NEW_CODIGO );
DELETE RHPONT_RES_SIT_DIA where CODIGO_EMPRESA = vCODIGO_EMPRESA and TIPO_CONTRATO = vTIPO_CONTRATO and CODIGO_CONTRATO = vCODIGO and trunc(DATA) = trunc(C1.DATA_DIA) and CODIGO_SITUACAO = vSP_NEW_CODIGO and REF_HORAS = 1 and TIPO_APURACAO = 'F';--NOVO EM 20/1/20
INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, LOGIN_USUARIO, DT_ULT_ALTER_USUA, TIPO_APURACAO, FORCA_SITUACAO  )
VALUES (vCODIGO_EMPRESA, vTIPO_CONTRATO, vCODIGO,trunc(C1.DATA_DIA), vSP_NEW_CODIGO, 1, vLOGIN_USUARIO, SYSDATE + 1/24/60/60, 'F', 'N');

END IF;--7 TAREFA
END LOOP;--LOOP 1


--/* --PAREI AQUI EM 16/8/21 17H37
--inicio ---------------------------- novo em 16/8/21 --para corrigir erro de situacoes funcionais sem data fim no primeiro momento depois com data fim onde o fim foi retroativo e ja havia sit ponto gravadas para apagar essas
ELSIF  vTIPO_DML = 'U' AND --EM 17/8/21 18H26 --vSER_ULT_SIT_FUNC = 'S' AND 
vOLD_SIT_FUNC_SEM_DT_FIM_PONT = 'S' AND vNEW_DATA_FIM_SITUACAO IS NOT NULL AND vOLD_DATA_FIM_SITUACAO IS NULL AND vSP_NEW_CODIGO = vSP_OLD_CODIGO THEN
dbms_output.put_line('ESTORNA/EXCLUI NO update SIT PONTO vOLD_SIT_FUNC_SEM_DT_FIM_PONT = S');

IF vSP_NEW_SITUACAO_ASSOC IS NULL THEN
dbms_output.put_line('EXCLUI');
--COMENTADO 17/8/21 19H5--
DELETE RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vCODIGO AND  CODIGO_SITUACAO = vSP_OLD_CODIGO AND trunc(DATA) > trunc(vNEW_DATA_FIM_SITUACAO)
AND TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
;

ELSE
dbms_output.put_line('ESTORNA');
FOR C1 IN
(select D.*, S.TIPO_SITUACAO FROM RHPONT_RES_SIT_DIA D LEFT OUTER JOIN RHPONT_SITUACAO S ON S.CODIGO = D.CODIGO_SITUACAO
  WHERE D.CODIGO_EMPRESA = vCODIGO_EMPRESA AND D.TIPO_CONTRATO = vTIPO_CONTRATO AND D.CODIGO_CONTRATO = vCODIGO AND D.CODIGO_SITUACAO = vSP_OLD_CODIGO AND trunc(D.DATA) > trunc(vNEW_DATA_FIM_SITUACAO)
  AND D.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
  )
LOOP
dbms_output.put_line('C1.DATA - '|| C1.DATA);
--inicio --para estorno se tiver ja lancamento no dia pega a ultima lancada no dia
FOR C2 IN (
SELECT SP.CODIGO_SITUACAO ULT_SP_NO_DIA, S.TIPO_SITUACAO , S.situacao_assoc
,SP.REF_HORAS --NOVO EM 16/3/22
FROM RHPONT_RES_SIT_DIA SP
LEFT OUTER JOIN RHPONT_SITUACAO S ON SP.CODIGO_SITUACAO = S.CODIGO
WHERE SP.CODIGO_EMPRESA = vCODIGO_EMPRESA AND SP.TIPO_CONTRATO = vTIPO_CONTRATO AND SP.CODIGO_CONTRATO = vCODIGO
AND trunc(SP.DATA) = trunc(C1.DATA)
AND SP.DT_ULT_ALTER_USUA = (SELECT MAX(AUX.DT_ULT_ALTER_USUA) FROM RHPONT_RES_SIT_DIA AUX LEFT OUTER JOIN RHPONT_SITUACAO SA ON SA.CODIGO = AUX.CODIGO_SITUACAO
WHERE AUX.CODIGO_EMPRESA = vCODIGO_EMPRESA AND AUX.TIPO_CONTRATO = vTIPO_CONTRATO AND AUX.CODIGO_CONTRATO = vCODIGO
AND trunc(AUX.DATA) = trunc(C1.DATA)
AND SA.CODIGO <> '1013'--AND SA.TIPO_SITUACAO <> 'F' AND SA.TIPO_REFERENCIA <> 'H' --NOVO EM 30/3/22 EMAIL (Fwd: Licença Médica Pendente não lançada)
AND AUX.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
AND SP.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
LOOP
--dbms_output.put_line('C2.ULT_SP_NO_DIA - '|| C2.ULT_SP_NO_DIA);
IF C1.DATA <= vULT_DIA_APUR_IFPONTO --Periodo do Lancamento (total/parcial) ja fechado Ifponto? = SIM
AND vSP_NEW_CODIGO IS NOT NULL --Lancamento possui Situaco Ponto vinculada? = SIM
--AND C2.ULT_SP_NO_DIA IS NOT NULL AND C2.situacao_assoc IS NOT NULL --A ultima situacao ponto no dia possui situacao de estorno? = SIM
AND C2.TIPO_SITUACAO <> 'C'--A ultima situacao ponto no dia ser o ESTORNO de uma FALTA/ATRASOS ? = NAO
AND C2.TIPO_SITUACAO = 'F'--A ultima situacao ponto ser de FALTA/ATRASOS? = SIM
AND C2.ULT_SP_NO_DIA = vSP_NEW_CODIGO -- DIFERE DO novo em 16/8/21 PARA CRIAR ESTORNO APENAS SE SIT PONTO DE FALTA FOR DIFERENTE DA SIT PONTO DA SIT FUNC EMAIL de 12/08/21(Problema Lancamento Automatico)
AND C1.DATA <= vULT_DIA_APUR_FOLHA_PAGAMENTO -- PARA ESTORNAR--NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21
AND C2.SITUACAO_ASSOC IS NOT NULL --MAS INSERIDO MESMO NO CODIGO EM 27/7/22 EMAIL (SITUAÇÃO FUNCIONAL NÃO REFLETIDA - LICENÇAS MÉDICAS)--NOVO EM 28/6/22 AJUSTE JA PENSADO EM OUTRO EMAIL MAS FEITO DEVIDO AO CASO (Ordem de serviço Lázara Cassiano)
THEN
--4 TAREFA
dbms_output.put_line('4 TAREFA-Cria Estorno da SituaCAo de Ponto - '||C2.ULT_SP_NO_DIA ||'-'||C2.TIPO_SITUACAO||'-'||C2.situacao_assoc||'ESTORNA DATAS A MAIS SIT FUNC COM PONTO QUE NAO TINA DATA FIM');
DELETE RHPONT_RES_SIT_DIA where CODIGO_EMPRESA = vCODIGO_EMPRESA and TIPO_CONTRATO = vTIPO_CONTRATO and CODIGO_CONTRATO = vCODIGO and trunc(DATA) = trunc(C1.DATA) and CODIGO_SITUACAO = C2.situacao_assoc and REF_HORAS = 1 and TIPO_APURACAO = 'F';--NOVO EM 20/1/20
INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, LOGIN_USUARIO, DT_ULT_ALTER_USUA, TIPO_APURACAO, FORCA_SITUACAO  )
VALUES (vCODIGO_EMPRESA, vTIPO_CONTRATO, vCODIGO,trunc(C1.DATA), C2.situacao_assoc, 
C2.REF_HORAS,--AJUSTE EM 16/3/22
vLOGIN_USUARIO, SYSDATE - 1/24/60/60, 'F', 'N');
END IF;--4 TAREFA

--INICIO-----------------------------NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21
IF C1.DATA <= vULT_DIA_APUR_IFPONTO --Periodo do Lancamento (total/parcial) ja fechado Ifponto? = SIM
AND vSP_NEW_CODIGO IS NOT NULL --Lancamento possui Situaco Ponto vinculada? = SIM
--AND C2.ULT_SP_NO_DIA IS NOT NULL AND C2.situacao_assoc IS NOT NULL --A ultima situacao ponto no dia possui situacao de estorno? = SIM
AND C2.TIPO_SITUACAO <> 'C'--A ultima situacao ponto no dia ser o ESTORNO de uma FALTA/ATRASOS ? = NAO
AND C2.TIPO_SITUACAO = 'F'--A ultima situacao ponto ser de FALTA/ATRASOS? = SIM
AND C2.ULT_SP_NO_DIA = vSP_NEW_CODIGO -- DIFERE DO novo em 16/8/21 PARA CRIAR ESTORNO APENAS SE SIT PONTO DE FALTA FOR DIFERENTE DA SIT PONTO DA SIT FUNC EMAIL de 12/08/21(Problema Lancamento Automatico)
AND C1.DATA > vULT_DIA_APUR_FOLHA_PAGAMENTO -- PARA DELETAR--NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21
THEN
--1 TAREFA
dbms_output.put_line('1 TAREFA-Exclui SituaCAo Ponto - '||vSP_NEW_CODIGO||' delete SIT PONTO TIPO FALTA MAS COM DATA POSTERIOR AO ULTIMO FECHAMENTO DA FOLHA LOCAL3');
DELETE RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vCODIGO AND trunc(DATA) = trunc(C1.DATA) AND CODIGO_SITUACAO = vSP_NEW_CODIGO
AND TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
;
END IF;--1 TAREFA
--FIM--------------------------------NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21

END LOOP;--LOOP 2
END LOOP;--LOOP 1

END IF;
--END IF;
--fim ---------------------------------- novo em 16/8/21 --para corrigir erro de situacoes funcionais sem data fim no primeiro momento depois com data fim onde o fim foi retroativo e ja havia sit ponto gravadas para apagar essas
--*/

--INICIO --------------------------------------------------------------------------------------------------------NOVO EM 18/8/21
ELSIF  vTIPO_DML = 'U' AND --EM 17/8/21 18H26 --vSER_ULT_SIT_FUNC = 'S' AND 
vOLD_SIT_FUNC_SEM_DT_FIM_PONT = 'S' AND vNEW_DATA_FIM_SITUACAO IS NOT NULL AND vOLD_DATA_FIM_SITUACAO IS NOT NULL AND vSP_NEW_CODIGO = vSP_OLD_CODIGO THEN
dbms_output.put_line('INCLUI NO update SIT PONTO vOLD_SIT_FUNC_SEM_DT_FIM_PONT = S');
FOR C1 IN
(select D.DATA_DIA from RHTABS_DATAS D WHERE trunc(D.DATA_DIA) BETWEEN trunc(vDATA_INIC_SITUACAO) AND trunc(vNEW_DATA_FIM_SITUACAO)order by d.data_dia)
LOOP
dbms_output.put_line('C1.DATA_DIA - '|| C1.DATA_DIA);

IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --PeRIOodo do LanCAamento (total/parcial) jA fechado Ifponto? = SIM
AND vSP_NEW_CODIGO IS NOT NULL THEN --LanCAamento possui SituaCAo Ponto vinculada? = SIM
--7 TAREFA
dbms_output.put_line('7 TAREFA-Cria na data a situaCAo ponto para o bm - '||vSP_NEW_CODIGO ||'INCLUI NO update SIT PONTO vOLD_SIT_FUNC_SEM_DT_FIM_PONT = S' );
--COMENTADO 17/8/21 19H11--
DELETE RHPONT_RES_SIT_DIA where CODIGO_EMPRESA = vCODIGO_EMPRESA and TIPO_CONTRATO = vTIPO_CONTRATO and CODIGO_CONTRATO = vCODIGO and trunc(DATA) = trunc(C1.DATA_DIA) and CODIGO_SITUACAO = vSP_NEW_CODIGO and REF_HORAS = 1 and TIPO_APURACAO = 'F';--NOVO EM 20/1/20
INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, LOGIN_USUARIO, DT_ULT_ALTER_USUA, TIPO_APURACAO, FORCA_SITUACAO  )
VALUES (vCODIGO_EMPRESA, vTIPO_CONTRATO, vCODIGO,trunc(C1.DATA_DIA), vSP_NEW_CODIGO, 1, vLOGIN_USUARIO, SYSDATE, 'F', 'N');

END IF;--7 TAREFA
END LOOP;--LOOP 1

--INICIO EM 18/8/21 13H02
IF  trunc(vNEW_DATA_FIM_SITUACAO) < trunc(vOLD_DATA_FIM_SITUACAO) 
AND vSP_OLD_SITUACAO_ASSOC IS NULL---NAO TEM ESTORNO
THEN
FOR C1 IN
(select D.DATA_DIA from RHTABS_DATAS D WHERE trunc(D.DATA_DIA) BETWEEN trunc(vNEW_DATA_FIM_SITUACAO)+1 AND trunc(vOLD_DATA_FIM_SITUACAO)order by d.data_dia)
LOOP
dbms_output.put_line('C1.DATA_DIA - '|| C1.DATA_DIA);

IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --PeRIOodo do LanCAamento (total/parcial) jA fechado Ifponto? = SIM
AND vSP_NEW_CODIGO IS NOT NULL THEN --LanCAamento possui SituaCAo Ponto vinculada? = SIM
--5 TAREFA
dbms_output.put_line('5 TAREFA-Exclui SituACAo de Ponto do Estorno - '||vSP_OLD_CODIGO|| ' EXCLUI NO update SIT PONTO C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO E vOLD_SIT_FUNC_SEM_DT_FIM_PONT = S');
--COMENTADO 17/8/21 19H5--
DELETE RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vCODIGO AND trunc(DATA) = trunc(C1.DATA_DIA) AND CODIGO_SITUACAO = vSP_OLD_CODIGO
AND TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
;
END IF;--5 TAREFA
END LOOP;--LOOP 1
END IF;
--FIM EM 18/8/21 13H02

--INICIO EM 18/8/21 13H33
IF  trunc(vNEW_DATA_FIM_SITUACAO) < trunc(vOLD_DATA_FIM_SITUACAO) 
AND vSP_OLD_SITUACAO_ASSOC IS NOT NULL---TEM ESTORNO
THEN
FOR C1 IN
(select D.DATA_DIA from RHTABS_DATAS D WHERE trunc(D.DATA_DIA) BETWEEN trunc(vNEW_DATA_FIM_SITUACAO)+1 AND trunc(vOLD_DATA_FIM_SITUACAO)order by d.data_dia)
LOOP
dbms_output.put_line('C1.DATA_DIA - '|| C1.DATA_DIA);

IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --PeRIOodo do LanCAamento (total/parcial) jA fechado Ifponto? = SIM
AND vSP_NEW_CODIGO IS NOT NULL  --LanCAamento possui SituaCAo Ponto vinculada? = SIM
AND C1.DATA_DIA <= vULT_DIA_APUR_FOLHA_PAGAMENTO -- PARA ESTORNAR--NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21
THEN
--4 TAREFA
dbms_output.put_line('4 TAREFA-Cria Estorno da SituaCAo de Ponto - '||vSP_OLD_SITUACAO_ASSOC||' ESTORNA NO update SIT PONTO C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO E vOLD_SIT_FUNC_SEM_DT_FIM_PONT = S');
DELETE RHPONT_RES_SIT_DIA where CODIGO_EMPRESA = vCODIGO_EMPRESA and TIPO_CONTRATO = vTIPO_CONTRATO and CODIGO_CONTRATO = vCODIGO and trunc(DATA) = trunc(C1.DATA_DIA) and CODIGO_SITUACAO = vSP_OLD_SITUACAO_ASSOC and REF_HORAS = 1 and TIPO_APURACAO = 'F';--NOVO EM 20/1/20
INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, LOGIN_USUARIO, DT_ULT_ALTER_USUA, TIPO_APURACAO, FORCA_SITUACAO  )
VALUES (vCODIGO_EMPRESA, vTIPO_CONTRATO, vCODIGO,trunc(C1.DATA_DIA), vSP_OLD_SITUACAO_ASSOC, 1, vLOGIN_USUARIO, SYSDATE, 'F', 'N');
END IF;--4 TAREFA

--INICIO-----------------------------NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21
IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --PeRIOodo do LanCAamento (total/parcial) jA fechado Ifponto? = SIM
AND vSP_NEW_CODIGO IS NOT NULL  --LanCAamento possui SituaCAo Ponto vinculada? = SIM
AND C1.DATA_DIA > vULT_DIA_APUR_FOLHA_PAGAMENTO -- PARA DELETAR--NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21
THEN
--1 TAREFA
dbms_output.put_line('1 TAREFA-Exclui SituaCAo Ponto - '||vSP_NEW_CODIGO||' delete SIT PONTO TIPO FALTA MAS COM DATA POSTERIOR AO ULTIMO FECHAMENTO DA FOLHA LOCAL4');
DELETE RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vCODIGO AND trunc(DATA) = trunc(C1.DATA_DIA) AND CODIGO_SITUACAO = vSP_NEW_CODIGO
AND TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
;
END IF;--1 TAREFA
--FIM--------------------------------NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21

END LOOP;--LOOP 1
END IF;
--FIM EM 18/8/21 13H33



---inicio--em 18/8/21 12h18
ELSIF  vTIPO_DML = 'U' AND --EM 17/8/21 18H26 --vSER_ULT_SIT_FUNC = 'S' AND 
vOLD_SIT_FUNC_SEM_DT_FIM_PONT = 'S' AND vNEW_DATA_FIM_SITUACAO IS NULL AND vOLD_DATA_FIM_SITUACAO IS NOT NULL AND vSP_NEW_CODIGO = vSP_OLD_CODIGO THEN
dbms_output.put_line('INCLUI NO update SIT PONTO vOLD_SIT_FUNC_SEM_DT_FIM_PONT = S ate vULT_DIA_APUR_IFPONTO');
FOR C1 IN
(select D.DATA_DIA from RHTABS_DATAS D WHERE trunc(D.DATA_DIA) BETWEEN trunc(vDATA_INIC_SITUACAO) AND trunc(vULT_DIA_APUR_IFPONTO)order by d.data_dia)
LOOP
dbms_output.put_line('C1.DATA_DIA - '|| C1.DATA_DIA);
--7 TAREFA
dbms_output.put_line('7 TAREFA-Cria na data a situaCAo ponto para o bm - '||vSP_NEW_CODIGO ||'INCLUI NO update SIT PONTO vOLD_SIT_FUNC_SEM_DT_FIM_PONT = S ate vULT_DIA_APUR_IFPONTO' );
--COMENTADO 17/8/21 19H11--
DELETE RHPONT_RES_SIT_DIA where CODIGO_EMPRESA = vCODIGO_EMPRESA and TIPO_CONTRATO = vTIPO_CONTRATO and CODIGO_CONTRATO = vCODIGO and trunc(DATA) = trunc(C1.DATA_DIA) and CODIGO_SITUACAO = vSP_NEW_CODIGO and REF_HORAS = 1 and TIPO_APURACAO = 'F';--NOVO EM 20/1/20
INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, LOGIN_USUARIO, DT_ULT_ALTER_USUA, TIPO_APURACAO, FORCA_SITUACAO  )
VALUES (vCODIGO_EMPRESA, vTIPO_CONTRATO, vCODIGO, trunc(C1.DATA_DIA), vSP_NEW_CODIGO, 1, vLOGIN_USUARIO, SYSDATE, 'F', 'N');

END LOOP;--LOOP 1
---fim--em 18/8/21 12h18


--FIM -----------------------------------------------------------------------------------NOVO EM 18/8/21

-----------------------------------------------------------INSERT
ELSIF vTIPO_DML = 'I' AND vNEW_DATA_FIM_SITUACAO IS NOT NULL
THEN
dbms_output.put_line('insert ALT SIT FUNC');
FOR C1 IN
(select D.DATA_DIA from RHTABS_DATAS D WHERE trunc(D.DATA_DIA) BETWEEN trunc(vDATA_INIC_SITUACAO) AND trunc(vNEW_DATA_FIM_SITUACAO)order by d.data_dia)
LOOP
dbms_output.put_line('C1.DATA_DIA - '|| C1.DATA_DIA);
--inicio --para estorno se tiver jA lanCAamento no dia pega a ultima lanCada no dia
FOR C2 IN (
SELECT SP.CODIGO_SITUACAO ULT_SP_NO_DIA, S.TIPO_SITUACAO , S.situacao_assoc
,SP.REF_HORAS --NOVO EM 16/3/22
FROM RHPONT_RES_SIT_DIA SP
LEFT OUTER JOIN RHPONT_SITUACAO S ON SP.CODIGO_SITUACAO = S.CODIGO
WHERE SP.CODIGO_EMPRESA = vCODIGO_EMPRESA AND SP.TIPO_CONTRATO = vTIPO_CONTRATO AND SP.CODIGO_CONTRATO = vCODIGO
AND trunc(SP.DATA) = trunc(C1.DATA_DIA)
AND SP.DT_ULT_ALTER_USUA = (SELECT MAX(AUX.DT_ULT_ALTER_USUA) FROM RHPONT_RES_SIT_DIA AUX 
LEFT OUTER JOIN RHPONT_SITUACAO SA ON SA.CODIGO = AUX.CODIGO_SITUACAO
WHERE AUX.CODIGO_EMPRESA = vCODIGO_EMPRESA AND AUX.TIPO_CONTRATO = vTIPO_CONTRATO AND AUX.CODIGO_CONTRATO = vCODIGO
AND trunc(AUX.DATA) = trunc(C1.DATA_DIA)
AND SA.CODIGO <> '1013'--AND SA.TIPO_SITUACAO <> 'F' AND SA.TIPO_REFERENCIA <> 'H' --NOVO EM 30/3/22 EMAIL (Fwd: Licença Médica Pendente não lançada)
AND AUX.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
AND SP.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
LOOP
--dbms_output.put_line('C2.ULT_SP_NO_DIA - '|| C2.ULT_SP_NO_DIA);

IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --PerIodo do LanCamento (total/parcial) jA fechado Ifponto? = SIM
AND vSP_NEW_CODIGO IS NOT NULL --LanCamento possui SituCAo Ponto vinculada? = SIM
--AND C2.ULT_SP_NO_DIA IS NOT NULL AND C2.situacao_assoc IS NOT NULL THEN --A ultima situaCA£o ponto no dia possui situaCA£o de estorno? = SIM
AND C2.TIPO_SITUACAO <> 'C'--A ultima situaCAo ponto no dia SER o ESTORNO de uma FALTA/ATRASOS ? = NAO
AND C2.TIPO_SITUACAO = 'F'--A ultima situaCAo ponto SER de FALTA/ATRASOS? = SIM
AND C2.ULT_SP_NO_DIA <> vSP_NEW_CODIGO --novo em 16/8/21 PARA CRIAR ESTORNO APENAS SE SIT PONTO DE FALTA FOR DIFERENTE DA SIT PONTO DA SIT FUNC EMAIL de 12/08/21(Problema Lancamento Automatico)
AND C1.DATA_DIA <= vULT_DIA_APUR_FOLHA_PAGAMENTO -- PARA ESTORNAR--NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21
AND C2.SITUACAO_ASSOC IS NOT NULL --NOVO EM 28/6/22 AJUSTE JA PENSADO EM OUTRO EMAIL MAS FEITO DEVIDO AO CASO (Ordem de serviço Lázara Cassiano)
THEN
--6 TAREFA
dbms_output.put_line('6 TAREFA-Cria Estorno da SituaCAo de Ponto - '||C2.ULT_SP_NO_DIA ||'-'||C2.TIPO_SITUACAO||'-'||C2.situacao_assoc);
DELETE RHPONT_RES_SIT_DIA where CODIGO_EMPRESA = vCODIGO_EMPRESA and TIPO_CONTRATO = vTIPO_CONTRATO and CODIGO_CONTRATO = vCODIGO and trunc(DATA) = trunc(C1.DATA_DIA) and CODIGO_SITUACAO = C2.situacao_assoc and REF_HORAS = 1 and TIPO_APURACAO = 'F';--NOVO EM 20/1/20
INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, LOGIN_USUARIO, DT_ULT_ALTER_USUA, TIPO_APURACAO , FORCA_SITUACAO )
VALUES (vCODIGO_EMPRESA, vTIPO_CONTRATO, vCODIGO,trunc(C1.DATA_DIA), C2.situacao_assoc, 
C2.REF_HORAS,--AJUSTE EM 16/3/22
vLOGIN_USUARIO, SYSDATE - 1/24/60/60, 'F', 'N');
END IF;--6 TAREFA


--INICIO-----------------------------NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21
IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --PerIodo do LanCamento (total/parcial) jA fechado Ifponto? = SIM
AND vSP_NEW_CODIGO IS NOT NULL --LanCamento possui SituCAo Ponto vinculada? = SIM
--AND C2.ULT_SP_NO_DIA IS NOT NULL AND C2.situacao_assoc IS NOT NULL THEN --A ultima situaCA£o ponto no dia possui situaCA£o de estorno? = SIM
AND C2.TIPO_SITUACAO <> 'C'--A ultima situaCAo ponto no dia SER o ESTORNO de uma FALTA/ATRASOS ? = NAO
AND C2.TIPO_SITUACAO = 'F'--A ultima situaCAo ponto SER de FALTA/ATRASOS? = SIM
AND C2.ULT_SP_NO_DIA <> vSP_NEW_CODIGO --novo em 16/8/21 PARA CRIAR ESTORNO APENAS SE SIT PONTO DE FALTA FOR DIFERENTE DA SIT PONTO DA SIT FUNC EMAIL de 12/08/21(Problema Lancamento Automatico)
AND C1.DATA_DIA > vULT_DIA_APUR_FOLHA_PAGAMENTO -- PARA DELETAR--NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21
THEN
--1 TAREFA
dbms_output.put_line('1 TAREFA-Exclui SituaCAo Ponto - '||vSP_NEW_CODIGO||' delete SIT PONTO TIPO FALTA MAS COM DATA POSTERIOR AO ULTIMO FECHAMENTO DA FOLHA LOCAL5');
DELETE RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vCODIGO AND trunc(DATA) = trunc(C1.DATA_DIA) AND CODIGO_SITUACAO = vSP_NEW_CODIGO
AND TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
;
END IF;--1 TAREFA
--FIM--------------------------------NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21
END LOOP;--LOOP 2

IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --Periodo do Lancamento (total/parcial) ja fechado Ifponto? = SIM
AND vSP_NEW_CODIGO IS NOT NULL THEN --Lancamento possui Situacao Ponto vinculada? = SIM
--8 TAREFA
dbms_output.put_line('8 TAREFA-Cria na data a situaCAo ponto para o bm - '||vSP_NEW_CODIGO );
DELETE RHPONT_RES_SIT_DIA where CODIGO_EMPRESA = vCODIGO_EMPRESA and TIPO_CONTRATO = vTIPO_CONTRATO and CODIGO_CONTRATO = vCODIGO and trunc(DATA) = trunc(C1.DATA_DIA) and CODIGO_SITUACAO = vSP_NEW_CODIGO and REF_HORAS = 1 and TIPO_APURACAO = 'F';--NOVO EM 20/1/20
INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, LOGIN_USUARIO, DT_ULT_ALTER_USUA, TIPO_APURACAO, FORCA_SITUACAO  )
VALUES (vCODIGO_EMPRESA, vTIPO_CONTRATO, vCODIGO,trunc(C1.DATA_DIA), vSP_NEW_CODIGO, 1, vLOGIN_USUARIO, SYSDATE + 1/24/60/60, 'F', 'N');
END IF;--7 TAREFA
END LOOP;--LOOP 1

--INICIO ---------------------------------------- novo em 16/8/21 --para corrigir erro de situacoes funcionais sem data fim no primeiro momento depois com data fim onde o fim foi retroativo e ja havia sit ponto gravadas para apagar essas
ELSIF vTIPO_DML = 'I' AND -- vSER_ULT_SIT_FUNC = 'S' AND 
vOLD_SIT_FUNC_SEM_DT_FIM_PONT = 'S' AND vNEW_DATA_FIM_SITUACAO IS NULL AND vOLD_DATA_FIM_SITUACAO IS NULL  THEN
dbms_output.put_line('CRIA SIT PONTO NO insert SIT PONTO vOLD_SIT_FUNC_SEM_DT_FIM_PONT = S');

/*
--PEGAR ULTIMO DIA DE FECHAMENTO LOCAL
SELECT L.DATA_USAR INTO vNEW_DATA_FIM_SITUACAO FROM  rhpess_contrato c
LEFT OUTER JOIN 
(
SELECT CASE WHEN W.FECHAMENTO_AGRUPADOR IS NOT NULL THEN W.FECHAMENTO_AGRUPADOR WHEN W.FECHAMENTO_ORGANOGRAMA IS NOT NULL THEN W.FECHAMENTO_ORGANOGRAMA ELSE W.FECHAMENTO_GERAL 
END DATA_USAR, W.* FROM SUGESP_DATA_APURACAO_FREQUENC W --COMENTADO EM 3/8/21--VW_DATA_APURACAO_FREQUENCIA W
WHERE W.FECHAMENTO_ORGANOGRAMA IS NULL AND W.FECHAMENTO_AGRUPADOR IS NULL
)L ON C.CODIGO_EMPRESA = L.CODIGO_EMPRESA AND C.COD_CUSTO_GERENC1 = L.COD_AGRUP1 AND C.COD_CUSTO_GERENC2 = L.COD_AGRUP2 AND C.COD_CUSTO_GERENC3 = L.COD_AGRUP3
AND C.COD_CUSTO_GERENC4 = L.COD_AGRUP4 AND C.COD_CUSTO_GERENC5 = L.COD_AGRUP5 AND C.COD_CUSTO_GERENC6 = L.COD_AGRUP6
WHERE
C.ANO_MES_REFERENCIA = (SELECT MAX(AUX.ANO_MES_REFERENCIA) FROM RHPESS_CONTRATO AUX WHERE AUX.CODIGO_EMPRESA = C.CODIGO_EMPRESA AND AUX.TIPO_CONTRATO = C.TIPO_CONTRATO AND AUX.CODIGO = C.CODIGO)
AND C.CODIGO_EMPRESA = vCODIGO_EMPRESA AND C.TIPO_CONTRATO = vTIPO_CONTRATO AND C.CODIGO = vCODIGO;
*/

FOR C1 IN
(select D.DATA_DIA from RHTABS_DATAS D WHERE trunc(D.DATA_DIA) BETWEEN trunc(vDATA_INIC_SITUACAO) AND trunc(vULT_DIA_APUR_IFPONTO)order by d.data_dia)
LOOP
dbms_output.put_line('C1.DATA_DIA - '|| C1.DATA_DIA);
--inicio --para estorno se tiver jA lanCAamento no dia pega a ultima lanCada no dia
FOR C2 IN (
SELECT SP.CODIGO_SITUACAO ULT_SP_NO_DIA, S.TIPO_SITUACAO , S.situacao_assoc
FROM RHPONT_RES_SIT_DIA SP
LEFT OUTER JOIN RHPONT_SITUACAO S ON SP.CODIGO_SITUACAO = S.CODIGO
WHERE SP.CODIGO_EMPRESA = vCODIGO_EMPRESA AND SP.TIPO_CONTRATO = vTIPO_CONTRATO AND SP.CODIGO_CONTRATO = vCODIGO
AND trunc(SP.DATA) = trunc(C1.DATA_DIA)
AND SP.DT_ULT_ALTER_USUA = (SELECT MAX(AUX.DT_ULT_ALTER_USUA) FROM RHPONT_RES_SIT_DIA AUX WHERE AUX.CODIGO_EMPRESA = vCODIGO_EMPRESA AND AUX.TIPO_CONTRATO = vTIPO_CONTRATO AND AUX.CODIGO_CONTRATO = vCODIGO
AND trunc(AUX.DATA) = trunc(C1.DATA_DIA)
AND AUX.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
AND SP.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
LOOP
--dbms_output.put_line('C2.ULT_SP_NO_DIA - '|| C2.ULT_SP_NO_DIA);
IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --PerIodo do LanCamento (total/parcial) jA fechado Ifponto? = SIM
AND vSP_NEW_CODIGO IS NOT NULL --LanCamento possui SituCAo Ponto vinculada? = SIM
--AND C2.ULT_SP_NO_DIA IS NOT NULL AND C2.situacao_assoc IS NOT NULL THEN --A ultima situaCA£o ponto no dia possui situaCA£o de estorno? = SIM
AND C2.TIPO_SITUACAO <> 'C'--A ultima situaCAo ponto no dia SER o ESTORNO de uma FALTA/ATRASOS ? = NAO
AND C2.TIPO_SITUACAO = 'F'--A ultima situaCAo ponto SER de FALTA/ATRASOS? = SIM
AND C2.ULT_SP_NO_DIA <> vSP_NEW_CODIGO --novo em 16/8/21 PARA CRIAR ESTORNO APENAS SE SIT PONTO DE FALTA FOR DIFERENTE DA SIT PONTO DA SIT FUNC EMAIL de 12/08/21(Problema Lancamento Automatico)
AND C1.DATA_DIA <= vULT_DIA_APUR_FOLHA_PAGAMENTO -- PARA ESTORNAR--NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21
AND C2.SITUACAO_ASSOC IS NOT NULL --NOVO EM 28/6/22 AJUSTE JA PENSADO EM OUTRO EMAIL MAS FEITO DEVIDO AO CASO (Ordem de serviço Lázara Cassiano)
THEN
--6 TAREFA
dbms_output.put_line('6 TAREFA-Cria Estorno da SituaCAo de Ponto - '||C2.ULT_SP_NO_DIA ||'-'||C2.TIPO_SITUACAO||'-'||C2.situacao_assoc||' CRIA SIT PONTO NO insert SIT PONTO vOLD_SIT_FUNC_SEM_DT_FIM_PONT = S');
DELETE RHPONT_RES_SIT_DIA where CODIGO_EMPRESA = vCODIGO_EMPRESA and TIPO_CONTRATO = vTIPO_CONTRATO and CODIGO_CONTRATO = vCODIGO and trunc(DATA) = trunc(C1.DATA_DIA) and CODIGO_SITUACAO = C2.situacao_assoc and REF_HORAS = 1 and TIPO_APURACAO = 'F';--NOVO EM 20/1/20
INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, LOGIN_USUARIO, DT_ULT_ALTER_USUA, TIPO_APURACAO , FORCA_SITUACAO )
VALUES (vCODIGO_EMPRESA, vTIPO_CONTRATO, vCODIGO, trunc(C1.DATA_DIA), C2.situacao_assoc, 1, vLOGIN_USUARIO, SYSDATE - 1/24/60/60, 'F', 'N');
END IF;--6 TAREFA
--INICIO-----------------------------NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21
IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --PerIodo do LanCamento (total/parcial) jA fechado Ifponto? = SIM
AND vSP_NEW_CODIGO IS NOT NULL --LanCamento possui SituCAo Ponto vinculada? = SIM
--AND C2.ULT_SP_NO_DIA IS NOT NULL AND C2.situacao_assoc IS NOT NULL THEN --A ultima situaCA£o ponto no dia possui situaCA£o de estorno? = SIM
AND C2.TIPO_SITUACAO <> 'C'--A ultima situaCAo ponto no dia SER o ESTORNO de uma FALTA/ATRASOS ? = NAO
AND C2.TIPO_SITUACAO = 'F'--A ultima situaCAo ponto SER de FALTA/ATRASOS? = SIM
AND C2.ULT_SP_NO_DIA <> vSP_NEW_CODIGO --novo em 16/8/21 PARA CRIAR ESTORNO APENAS SE SIT PONTO DE FALTA FOR DIFERENTE DA SIT PONTO DA SIT FUNC EMAIL de 12/08/21(Problema Lancamento Automatico)
AND C1.DATA_DIA > vULT_DIA_APUR_FOLHA_PAGAMENTO -- PARA DELETAR--NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21
THEN
--1 TAREFA
dbms_output.put_line('1 TAREFA-Exclui SituaCAo Ponto - '||vSP_NEW_CODIGO||' delete SIT PONTO TIPO FALTA MAS COM DATA POSTERIOR AO ULTIMO FECHAMENTO DA FOLHA LOCAL6');
DELETE RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vCODIGO AND trunc(DATA) = trunc(C1.DATA_DIA) AND CODIGO_SITUACAO = vSP_NEW_CODIGO
AND TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
;
END IF;--1 TAREFA
--FIM--------------------------------NOVO EM 19/8/21 --DEPOIS DE REUNIAO COM GEVIF/GETED EM 18/8/21
END LOOP;--LOOP 2

IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --Periodo do Lancamento (total/parcial) ja fechado Ifponto? = SIM
AND vSP_NEW_CODIGO IS NOT NULL THEN --Lancamento possui Situacao Ponto vinculada? = SIM
--8 TAREFA
dbms_output.put_line('8 TAREFA-Cria na data a situaCAo ponto para o bm - '||vSP_NEW_CODIGO ||' CRIA SIT PONTO NO insert SIT PONTO vOLD_SIT_FUNC_SEM_DT_FIM_PONT = S');
DELETE RHPONT_RES_SIT_DIA where CODIGO_EMPRESA = vCODIGO_EMPRESA and TIPO_CONTRATO = vTIPO_CONTRATO and CODIGO_CONTRATO = vCODIGO and trunc(DATA) = trunc(C1.DATA_DIA) and CODIGO_SITUACAO = vSP_NEW_CODIGO and REF_HORAS = 1 and TIPO_APURACAO = 'F';--NOVO EM 20/1/20
INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, LOGIN_USUARIO, DT_ULT_ALTER_USUA, TIPO_APURACAO, FORCA_SITUACAO  )
VALUES (vCODIGO_EMPRESA, vTIPO_CONTRATO, vCODIGO,trunc(C1.DATA_DIA), vSP_NEW_CODIGO, 1, vLOGIN_USUARIO, SYSDATE + 1/24/60/60, 'F', 'N');

END IF;--7 TAREFA
END LOOP;--LOOP 1



--END IF;
--fim -------------------------------- novo em 16/8/21 --para corrigir erro de situacoes funcionais sem data fim no primeiro momento depois com data fim onde o fim foi retroativo e ja havia sit ponto gravadas para apagar essas


ELSE
dbms_output.put_line('FALTA MAPEAR');
END IF; --2'ALT_SIT_FUNC'





ELSE dbms_output.put_line('Valor ANTIGO ou NOVO possuem SituaCAo Ponto associada? = NAO');
END IF;--------------FIM IF GERAL ALT SIT FUNC --fim--Valor ANTIGO ou NOVO possuem Situacao Ponto associada?





END; --2 'ALT_SIT_FUNC'

END; --1 'ALT_SIT_FUNC'
--FIM-----------------------------------------------------------------------------------------------------------------------------'ALT_SIT_FUNC'



ELSIF vORIGEM = 'FERIAS' THEN
--INICIO-------------------------------------------------------------------------------------------------------------------------'FERIAS'
dbms_output.put_line(vORIGEM ||'-'||vID );
dbms_output.put_line('vULT_DIA_APUR_IFPONTO - '||vULT_DIA_APUR_IFPONTO);
BEGIN --1 'FERIAS'

DECLARE
vTIPO_DML VARCHAR2(1);
vCODIGO_EMPRESA VARCHAR2(4);
vTIPO_CONTRATO VARCHAR2(4);
vCODIGO VARCHAR2(15);
vNEW_DT_INI_GOZO DATE;
vOLD_DT_INI_GOZO DATE;
vNEW_DT_FIM_GOZO DATE;
vOLD_DT_FIM_GOZO DATE;
vNEW_TIPO_FERIAS VARCHAR2(4);
vOLD_TIPO_FERIAS VARCHAR2(4);

vNEW_LOGIN_USUARIO VARCHAR2(40);
vOLD_LOGIN_USUARIO VARCHAR2(40);
vSP_NEW_CODIGO VARCHAR2(4);
vSP_NEW_SITUACAO_ASSOC VARCHAR2(4);
vSP_OLD_CODIGO VARCHAR2(4);
vSP_OLD_SITUACAO_ASSOC VARCHAR2(4);
vULT_SP_NO_DIA VARCHAR2(4);
vNEW_TIPO_SP VARCHAR2(1);
vOLD_TIPO_SP VARCHAR2(1);

vNEW_STATUS_CONFIRMACAO VARCHAR2(1);--NOVO EM 28/7/20
vOLD_STATUS_CONFIRMACAO VARCHAR2(1);--NOVO EM 28/7/20

vNEW_DT_INI_AQUISICAO DATE;--NOVO EM 15/1/21
vOLD_DT_INI_AQUISICAO DATE;--NOVO EM 15/1/21
vNEW_DT_FIM_AQUISICAO DATE;--NOVO EM 15/1/21
vOLD_DT_FIM_AQUISICAO DATE;--NOVO EM 15/1/21

vNEW_DT_RETORNO DATE;--NOVO EM 15/1/21
vOLD_DT_RETORNO DATE;--NOVO EM 15/1/21

BEGIN --2 'FERIAS'
vTIPO_DML := NULL;
vCODIGO_EMPRESA := NULL;
vTIPO_CONTRATO := NULL;
vCODIGO := NULL;
vNEW_DT_INI_GOZO := NULL;
vOLD_DT_INI_GOZO := NULL;
vNEW_DT_FIM_GOZO := NULL;
vOLD_DT_FIM_GOZO := NULL;
vNEW_TIPO_FERIAS := NULL;
vOLD_TIPO_FERIAS:= NULL;

vNEW_LOGIN_USUARIO := NULL;
vOLD_LOGIN_USUARIO := NULL;
vSP_NEW_CODIGO := NULL;
vSP_NEW_SITUACAO_ASSOC := NULL;
vSP_OLD_CODIGO := NULL;
vSP_OLD_SITUACAO_ASSOC := NULL;
vULT_SP_NO_DIA := NULL;
vNEW_TIPO_SP := NULL;
vOLD_TIPO_SP := NULL;

vNEW_STATUS_CONFIRMACAO := NULL;--NOVO EM 28/7/20
vOLD_STATUS_CONFIRMACAO := NULL;--NOVO EM 28/7/20

vNEW_DT_INI_AQUISICAO := NULL;--NOVO EM 15/1/21
vOLD_DT_INI_AQUISICAO := NULL;--NOVO EM 15/1/21
vNEW_DT_FIM_AQUISICAO := NULL;--NOVO EM 15/1/21
vOLD_DT_FIM_AQUISICAO := NULL;--NOVO EM 15/1/21
vNEW_DT_RETORNO := NULL; --NOVO EM 15/1/21
vOLD_DT_RETORNO := NULL;--NOVO EM 15/1/21

--pegar dados para manipular
SELECT SP_NEW.TIPO_SITUACAO SP_NEW_TIPO_SITUACAO, SP_OLD.TIPO_SITUACAO SP_OLD_TIPO_SITUACAO, X.TIPO_COMANDO, X.CODIGO_EMPRESA, X.TIPO_CONTRATO, X.CODIGO_CONTRATO,
to_date(to_char(X.NEW_DT_INI_GOZO,'dd/mm/yyyy'),'dd/mm/yyyy'),
to_date(to_char(X.OLD_DT_INI_GOZO,'dd/mm/yyyy'),'dd/mm/yyyy'),
/*CASE WHEN X.NEW_STATUS_CONFIRMACAO IN ('5','D') THEN --INCLUIDO CASE EM 15/1/21
 (SELECT to_date(to_char(MAX(DT.DATA_DIA),'dd/mm/yyyy'),'dd/mm/yyyy')
      FROM RHFERI_FERIAS F,
        RHTABS_DATAS DT
      WHERE F.CODIGO_EMPRESA = X.CODIGO_EMPRESA
      AND F.TIPO_CONTRATO = X.TIPO_CONTRATO
      AND F.DT_INI_AQUISICAO = X.NEW_DT_INI_AQUISICAO
      AND F.DT_FIM_AQUISICAO = X.NEW_DT_FIM_AQUISICAO
      AND F.CODIGO_CONTRATO = X.CODIGO_CONTRATO
      AND DT.DATA_DIA BETWEEN X.NEW_DT_INI_GOZO AND X.NEW_DT_RETORNO-1
      AND F.STATUS_CONFIRMACAO =X.NEW_STATUS_CONFIRMACAO
      AND DT.DATA_DIA NOT IN
        (SELECT D.DATA_DIA
        FROM RHPARM_CALEND_DT D
        WHERE D.CODIGO  = '0001'
        AND DT.DATA_DIA = D.DATA_DIA))
ELSE to_date(to_char(X.NEW_DT_FIM_GOZO,'dd/mm/yyyy'),'dd/mm/yyyy') END,*/
to_date(to_char(X.NEW_DT_FIM_GOZO,'dd/mm/yyyy'),'dd/mm/yyyy'),
/*CASE WHEN X.OLD_STATUS_CONFIRMACAO IN ('5','D') THEN --INCLUIDO CASE EM 15/1/21
 (SELECT to_date(to_char(MAX(DT.DATA_DIA),'dd/mm/yyyy'),'dd/mm/yyyy')
      FROM RHFERI_FERIAS F,
        RHTABS_DATAS DT
      WHERE F.CODIGO_EMPRESA = X.CODIGO_EMPRESA
      AND F.TIPO_CONTRATO = X.TIPO_CONTRATO
      AND F.DT_INI_AQUISICAO = X.OLD_DT_INI_AQUISICAO
      AND F.DT_FIM_AQUISICAO = X.OLD_DT_FIM_AQUISICAO
      AND F.CODIGO_CONTRATO = X.CODIGO_CONTRATO
      AND DT.DATA_DIA BETWEEN X.OLD_DT_INI_GOZO AND X.OLD_DT_RETORNO-1
      AND F.STATUS_CONFIRMACAO =X.OLD_STATUS_CONFIRMACAO
      AND DT.DATA_DIA NOT IN
        (SELECT D.DATA_DIA
        FROM RHPARM_CALEND_DT D
        WHERE D.CODIGO  = '0001'
        AND DT.DATA_DIA = D.DATA_DIA))
ELSE to_date(to_char(X.OLD_DT_FIM_GOZO,'dd/mm/yyyy'),'dd/mm/yyyy') END,*/
to_date(to_char(X.OLD_DT_FIM_GOZO,'dd/mm/yyyy'),'dd/mm/yyyy'),
X.NEW_TIPO_FERIAS, X.OLD_TIPO_FERIAS, X.NEW_LOGIN_USUARIO, X.OLD_LOGIN_USUARIO, F_NEW.SITUACAO_PONTO, F_OLD.SITUACAO_PONTO
,X.NEW_STATUS_CONFIRMACAO, X.OLD_STATUS_CONFIRMACAO --NOVO EM 28/7/20
,X.NEW_DT_INI_AQUISICAO, X.OLD_DT_INI_AQUISICAO, X.NEW_DT_FIM_AQUISICAO, X.OLD_DT_FIM_AQUISICAO, X.NEW_DT_RETORNO, X.OLD_DT_RETORNO  --NOVO EM 15/1/21
INTO vNEW_TIPO_SP, vOLD_TIPO_SP, vTIPO_DML, vCODIGO_EMPRESA, vTIPO_CONTRATO, vCODIGO, vNEW_DT_INI_GOZO, vOLD_DT_INI_GOZO, 
vNEW_DT_FIM_GOZO, vOLD_DT_FIM_GOZO, vNEW_TIPO_FERIAS, vOLD_TIPO_FERIAS, vNEW_LOGIN_USUARIO, vOLD_LOGIN_USUARIO, vSP_NEW_CODIGO, vSP_OLD_CODIGO
,vNEW_STATUS_CONFIRMACAO, vOLD_STATUS_CONFIRMACAO --NOVO EM 28/7/20
,vNEW_DT_INI_AQUISICAO, vOLD_DT_INI_AQUISICAO, vNEW_DT_FIM_AQUISICAO, vOLD_DT_FIM_AQUISICAO, vNEW_DT_RETORNO, vOLD_DT_RETORNO --NOVO EM 15/1/21
FROM SUGESP_BI_RHFERI_FERIAS X
LEFT OUTER JOIN RHPARM_P_FERI F_NEW ON X.CODIGO_EMPRESA = F_NEW.CODIGO_EMPRESA AND X.NEW_TIPO_FERIAS = F_NEW.CODIGO --F_NEW.CODIGO = X.NEW_COD_SIT_FUNCIONAL
LEFT OUTER JOIN RHPONT_SITUACAO SP_NEW ON SP_NEW.CODIGO = F_NEW.SITUACAO_PONTO
LEFT OUTER JOIN RHPARM_P_FERI F_OLD ON X.CODIGO_EMPRESA = F_OLD.CODIGO_EMPRESA AND X.OLD_TIPO_FERIAS = F_OLD.CODIGO--F_OLD ON F_OLD.CODIGO = X.OLD_COD_SIT_FUNCIONAL
LEFT OUTER JOIN RHPONT_SITUACAO SP_OLD ON SP_OLD.CODIGO = F_OLD.SITUACAO_PONTO
WHERE X.ID = vID
AND((X.TIPO_COMANDO = 'I' AND X.NEW_DT_INI_GOZO IS NOT NULL AND X.NEW_DT_FIM_GOZO IS NOT NULL)OR(X.TIPO_COMANDO = 'D' AND X.OLD_DT_INI_GOZO IS NOT NULL AND X.OLD_DT_FIM_GOZO IS NOT NULL)OR((X.TIPO_COMANDO = 'U' AND X.NEW_DT_INI_GOZO IS NOT NULL AND X.NEW_DT_FIM_GOZO IS NOT NULL)OR(X.TIPO_COMANDO = 'U' AND X.OLD_DT_INI_GOZO IS NOT NULL AND X.OLD_DT_FIM_GOZO IS NOT NULL)))--novo em 15/1/21
;

IF (
(vTIPO_DML = 'I' AND vSP_NEW_CODIGO IS NOT NULL AND vNEW_DT_INI_GOZO IS NOT NULL AND vNEW_DT_FIM_GOZO IS NOT NULL)

 OR(
  ((vTIPO_DML = 'U' AND vSP_NEW_CODIGO IS NOT NULL AND vNEW_DT_INI_GOZO IS NOT NULL AND vNEW_DT_FIM_GOZO IS NOT NULL)
    OR (vTIPO_DML = 'U' AND vSP_OLD_CODIGO IS NOT NULL AND vOLD_DT_INI_GOZO IS NOT NULL AND vOLD_DT_FIM_GOZO IS NOT NULL)
  )
  AND (vNEW_DT_INI_GOZO <> vOLD_DT_INI_GOZO OR vNEW_DT_FIM_GOZO <> vOLD_DT_FIM_GOZO OR vNEW_STATUS_CONFIRMACAO <> vOLD_STATUS_CONFIRMACAO)--houVe alteracao datas de gozo --INCLUIDO EM 27/8/21 houve alteracao no status "OR vNEW_STATUS_CONFIRMACAO <> vOLD_STATUS_CONFIRMACAO" EMAIL (Saneamento de dados - Férias)
    )
--INICIO NOVO 10/7/20
 OR(
  ((vTIPO_DML = 'U' AND (vNEW_DT_INI_GOZO IS NOT NULL AND vOLD_DT_INI_GOZO IS NULL)
    AND (vNEW_DT_FIM_GOZO IS NOT NULL AND vOLD_DT_FIM_GOZO IS NULL)
  )))--TINHA DATAS E LIMPOU
 OR(
  ((vTIPO_DML = 'U' AND (vNEW_DT_INI_GOZO IS NULL AND vOLD_DT_INI_GOZO IS NOT NULL)
    AND (vNEW_DT_FIM_GOZO IS NULL AND vOLD_DT_FIM_GOZO IS NOT NULL)
  )))--NAO TINHA DATAS E INSERIU
    --FIM NOVO 10/7/20
OR (vTIPO_DML = 'D' AND vSP_OLD_CODIGO IS NOT NULL AND vOLD_DT_INI_GOZO IS NOT NULL AND vOLD_DT_FIM_GOZO IS NOT NULL)
 )
THEN --inicio--Valor ANTIGO ou NOVO possuem SituaCAo Ponto associada?
dbms_output.put_line('Valor ANTIGO ou NOVO possuem SituaCAo Ponto associada? = SIM');
dbms_output.put_line('FERIAS OLD- '||vOLD_TIPO_FERIAS ||'NEW -'||vNEW_TIPO_FERIAS);


-----------------------------------------------------------------------DELETE
IF vTIPO_DML = 'D' AND vOLD_DT_INI_GOZO IS NOT NULL
AND vOLD_STATUS_CONFIRMACAO IN ('1','5','D','G')--NOVO EM 28/7/20
THEN
dbms_output.put_line('delete FERIAS');
FOR C1 IN
(select D.DATA_DIA from RHTABS_DATAS D WHERE trunc(D.DATA_DIA) BETWEEN trunc(vOLD_DT_INI_GOZO) AND trunc(vOLD_DT_FIM_GOZO)order by d.data_dia)
LOOP
dbms_output.put_line('C1.DATA_DIA - '|| C1.DATA_DIA);
--inicio --para estorno se tiver jA lanCamento no dia pega a ultima lanCada no dia
FOR C2 IN (
SELECT SP.CODIGO_SITUACAO ULT_SP_NO_DIA, S.TIPO_SITUACAO , S.situacao_assoc
FROM RHPONT_RES_SIT_DIA SP
LEFT OUTER JOIN RHPONT_SITUACAO S ON SP.CODIGO_SITUACAO = S.CODIGO
WHERE SP.CODIGO_EMPRESA = vCODIGO_EMPRESA AND SP.TIPO_CONTRATO = vTIPO_CONTRATO AND SP.CODIGO_CONTRATO = vCODIGO
AND trunc(SP.DATA) = trunc(C1.DATA_DIA)
AND SP.DT_ULT_ALTER_USUA = (SELECT MAX(AUX.DT_ULT_ALTER_USUA) FROM RHPONT_RES_SIT_DIA AUX WHERE AUX.CODIGO_EMPRESA = vCODIGO_EMPRESA AND AUX.TIPO_CONTRATO = vTIPO_CONTRATO AND AUX.CODIGO_CONTRATO = vCODIGO
AND trunc(AUX.DATA) = trunc(C1.DATA_DIA)
AND AUX.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
AND SP.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
LOOP
--dbms_output.put_line('C2.ULT_SP_NO_DIA - '|| C2.ULT_SP_NO_DIA);
IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --Periodo do Lancamento (total/parcial) ja fechado Ifponto? = SIM
AND vSP_OLD_CODIGO IS NOT NULL --Lancamento possuia Situac£o Ponto vinculada? = SIM
AND vOLD_TIPO_SP IN ('P','I')--somente situacoes do tipo AFASTAMENTOS
--AND C2.ULT_SP_NO_DIA IS NOT NULL AND C2.ULT_SP_NO_DIA  = vSP_OLD_CODIGO --A ultima situacao ponto no dia ser a mesma da vinculada a do lancaamento? = SIM
--AND C2.situacao_assoc IS NOT NULL THEN --A Situacao Ponto possuiA situacao de estorno associada? = SIM
THEN
--1 TAREFA
dbms_output.put_line('1 TAREFA-Exclui SituCAo Ponto - '||vSP_OLD_CODIGO);
DELETE RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vCODIGO AND trunc(DATA) = trunc(C1.DATA_DIA) AND CODIGO_SITUACAO = vSP_OLD_CODIGO
AND TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
;

--inicio --para Grava ultima SituaCAo Ponto do dia tipo FALTA/ATRASOS se existir
FOR C3 IN (
SELECT SP.CODIGO_SITUACAO ULT_SP_NO_DIA, S.TIPO_SITUACAO S_TIPO_SITUACAO
FROM RHPONT_RES_SIT_DIA SP
LEFT OUTER JOIN RHPONT_SITUACAO S ON SP.CODIGO_SITUACAO = S.CODIGO
WHERE SP.CODIGO_EMPRESA = vCODIGO_EMPRESA AND SP.TIPO_CONTRATO = vTIPO_CONTRATO AND SP.CODIGO_CONTRATO = vCODIGO
--AND S.tipo_situacao = 'F'----PARTE QUE DIFERE DO C2 PARA VER SE SER DO TIPO FALTA/ATRASOS
AND trunc(SP.DATA) = trunc(C1.DATA_DIA)
AND SP.DT_ULT_ALTER_USUA = (SELECT MAX(AUX.DT_ULT_ALTER_USUA) FROM RHPONT_RES_SIT_DIA AUX WHERE AUX.CODIGO_EMPRESA = vCODIGO_EMPRESA AND AUX.TIPO_CONTRATO = vTIPO_CONTRATO AND AUX.CODIGO_CONTRATO = vCODIGO
AND trunc(AUX.DATA) = trunc(C1.DATA_DIA)
AND AUX.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
AND SP.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
LOOP
IF C3.ULT_SP_NO_DIA IS NOT NULL AND C3.S_TIPO_SITUACAO = 'C' THEN -- No dia hA e SER a ultima Estorno de Sit. Ponto tipo FALTA/ATRASOS? = SIM
--2 TAREFA
dbms_output.put_line('2 TAREFA-Exclui SituACAo de Ponto do Estorno - '||C3.ULT_SP_NO_DIA||'-'||C3.S_TIPO_SITUACAO);
DELETE RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vCODIGO AND trunc(DATA) = trunc(C1.DATA_DIA) AND CODIGO_SITUACAO = C3.ULT_SP_NO_DIA
AND TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
;

END IF;
END LOOP;--LOOP 3
END IF;
END LOOP;--LOOP 2
END LOOP;--LOOP 1


----------------------------------------------------------------------------------------------UPDATE OLD
ELSIF vTIPO_DML = 'U' AND (vOLD_DT_FIM_GOZO IS NOT NULL OR vNEW_DT_FIM_GOZO IS NOT NULL)
--ELSIF vTIPO_DML = 'U' AND vOLD_DATA_FIM_SITUACAO IS NOT NULL
THEN
dbms_output.put_line('update-old FERIAS');
/*
--NOVO EM 15/1/21 --INICIO--BUSCAR A DATA FIM DE GOZO REAL NOS CASOS DE INTERRUPÇÃO DE FERIAS
--OLD
IF vTIPO_DML = 'U' AND vOLD_STATUS_CONFIRMACAO IN ('5','D') THEN
SELECT to_date(to_char(MAX(DT.DATA_DIA),'dd/mm/yyyy'),'dd/mm/yyyy')
INTO vOLD_DT_FIM_GOZO
      FROM RHFERI_FERIAS F,
        RHTABS_DATAS DT
      WHERE F.CODIGO_EMPRESA = vCODIGO_EMPRESA
      AND F.TIPO_CONTRATO = vTIPO_CONTRATO
      AND F.DT_INI_AQUISICAO = vOLD_DT_INI_AQUISICAO
      AND F.DT_FIM_AQUISICAO = vOLD_DT_FIM_AQUISICAO
      AND F.CODIGO_CONTRATO = vCODIGO
      AND DT.DATA_DIA BETWEEN vOLD_DT_INI_GOZO AND vOLD_DT_RETORNO-1
      AND F.STATUS_CONFIRMACAO =vOLD_STATUS_CONFIRMACAO
      AND DT.DATA_DIA NOT IN
        (SELECT D.DATA_DIA
        FROM RHPARM_CALEND_DT D
        WHERE D.CODIGO  = '0001'
        AND DT.DATA_DIA = D.DATA_DIA);
END IF;
--NOVO EM 15/1/21 --FIM--BUSCAR A DATA FIM DE GOZO REAL NOS CASOS DE INTERRUPÇÃO DE FERIAS
*/

FOR C1 IN
(select D.DATA_DIA from RHTABS_DATAS D WHERE trunc(D.DATA_DIA) BETWEEN trunc(vOLD_DT_INI_GOZO) AND trunc(vOLD_DT_FIM_GOZO)order by d.data_dia)
LOOP
dbms_output.put_line('C1.DATA_DIA - '|| C1.DATA_DIA);
--inicio --para estorno se tiver jA lanCamento no dia pega a ultima lancada no dia
FOR C2 IN (
SELECT SP.CODIGO_SITUACAO ULT_SP_NO_DIA, S.TIPO_SITUACAO , S.situacao_assoc
FROM RHPONT_RES_SIT_DIA SP
LEFT OUTER JOIN RHPONT_SITUACAO S ON SP.CODIGO_SITUACAO = S.CODIGO
WHERE SP.CODIGO_EMPRESA = vCODIGO_EMPRESA AND SP.TIPO_CONTRATO = vTIPO_CONTRATO AND SP.CODIGO_CONTRATO = vCODIGO
AND trunc(SP.DATA) = trunc(C1.DATA_DIA)
AND SP.DT_ULT_ALTER_USUA = (SELECT MAX(AUX.DT_ULT_ALTER_USUA) FROM RHPONT_RES_SIT_DIA AUX WHERE AUX.CODIGO_EMPRESA = vCODIGO_EMPRESA AND AUX.TIPO_CONTRATO = vTIPO_CONTRATO AND AUX.CODIGO_CONTRATO = vCODIGO
AND trunc(AUX.DATA) = trunc(C1.DATA_DIA)
AND AUX.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
AND SP.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
LOOP
--dbms_output.put_line('C2.ULT_SP_NO_DIA - '|| C2.ULT_SP_NO_DIA);
IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --Periodo do Lancamento (total/parcial) ja fechado Ifponto? = SIM
AND vSP_OLD_CODIGO IS NOT NULL --Lancamento possuia Situacao Ponto vinculada? = SIM
--AND C2.ULT_SP_NO_DIA IS NOT NULL AND C2.ULT_SP_NO_DIA  = vSP_OLD_CODIGO --A ultima situacao ponto no dia ser a mesma da vinculada a do lancamento? = SIM
--AND C2.situacao_assoc IS NOT NULL  --A SituaCAo Ponto possuiA situaCAo de estorno associada? = SIM
AND vOLD_TIPO_SP IN ('P','I')--somente situacoes do tipo AFASTAMENTOS
AND vOLD_STATUS_CONFIRMACAO IN ('1','5','D','G')--NOVO EM 28/7/20
THEN
--3Ã‚Âª TAREFA
dbms_output.put_line('3 TAREFA-Exclui SituaCAo Ponto - '||vSP_OLD_CODIGO);
DELETE RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vCODIGO AND trunc(DATA) = trunc(C1.DATA_DIA) AND CODIGO_SITUACAO = vSP_OLD_CODIGO
AND TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
;

END IF;

IF vSP_NEW_SITUACAO_ASSOC IS NULL 
AND vOLD_STATUS_CONFIRMACAO IN ('1','5','D','G')--NOVO EM 28/7/20
THEN
--inicio --para Grava ultima SituaCAo Ponto do dia tipo FALTA/ATRASOS se existir
FOR C3 IN (
SELECT SP.CODIGO_SITUACAO ULT_SP_NO_DIA, S.TIPO_SITUACAO S_TIPO_SITUACAO
FROM RHPONT_RES_SIT_DIA SP
LEFT OUTER JOIN RHPONT_SITUACAO S ON SP.CODIGO_SITUACAO = S.CODIGO
WHERE SP.CODIGO_EMPRESA = vCODIGO_EMPRESA AND SP.TIPO_CONTRATO = vTIPO_CONTRATO AND SP.CODIGO_CONTRATO = vCODIGO
--AND S.tipo_situacao = 'F'----PARTE QUE DIFERE DO C2 PARA VER SE ser DO TIPO FALTA/ATRASOS
AND trunc(SP.DATA) = trunc(C1.DATA_DIA)
AND SP.DT_ULT_ALTER_USUA = (SELECT MAX(AUX.DT_ULT_ALTER_USUA) FROM RHPONT_RES_SIT_DIA AUX WHERE AUX.CODIGO_EMPRESA = vCODIGO_EMPRESA AND AUX.TIPO_CONTRATO = vTIPO_CONTRATO AND AUX.CODIGO_CONTRATO = vCODIGO
AND trunc(AUX.DATA) = trunc(C1.DATA_DIA)
AND AUX.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
AND SP.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
LOOP
IF C3.ULT_SP_NO_DIA IS NOT NULL AND C3.S_TIPO_SITUACAO = 'C' 
THEN -- No dia ha e ser a ultima Estorno de Sit. Ponto tipo FALTA/ATRASOS? = SIM
--5Ã‚Âª TAREFA
dbms_output.put_line('5 TAREFA-Exclui SituACo de Ponto do Estorno - '||C3.ULT_SP_NO_DIA||'-'||C3.S_TIPO_SITUACAO);
DELETE RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vCODIGO AND trunc(DATA) = trunc(C1.DATA_DIA) AND CODIGO_SITUACAO = C3.ULT_SP_NO_DIA
AND TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
;

END IF;-- IF C3
END LOOP;--LOOP 3
END IF;
END LOOP;--LOOP 2
END LOOP;--LOOP 1


---------------------------------------------------------------------------UPDATE NEW
dbms_output.put_line('update-new FERIAS');
/*
--NOVO EM 15/1/21 --INICIO--BUSCAR A DATA FIM DE GOZO REAL NOS CASOS DE INTERRUPÇÃO DE FERIAS
--NEW
IF vTIPO_DML = 'U' AND vNEW_STATUS_CONFIRMACAO IN ('5','D') THEN
SELECT to_date(to_char(MAX(DT.DATA_DIA),'dd/mm/yyyy'),'dd/mm/yyyy')
INTO vNEW_DT_FIM_GOZO
      FROM RHFERI_FERIAS F,
        RHTABS_DATAS DT
      WHERE F.CODIGO_EMPRESA = vCODIGO_EMPRESA
      AND F.TIPO_CONTRATO = vTIPO_CONTRATO
      AND F.DT_INI_AQUISICAO = vNEW_DT_INI_AQUISICAO
      AND F.DT_FIM_AQUISICAO = vNEW_DT_FIM_AQUISICAO
      AND F.CODIGO_CONTRATO = vCODIGO
      AND DT.DATA_DIA BETWEEN vNEW_DT_INI_GOZO AND vNEW_DT_RETORNO-1
      AND F.STATUS_CONFIRMACAO =vNEW_STATUS_CONFIRMACAO
      AND DT.DATA_DIA NOT IN
        (SELECT D.DATA_DIA
        FROM RHPARM_CALEND_DT D
        WHERE D.CODIGO  = '0001'
        AND DT.DATA_DIA = D.DATA_DIA);
END IF;
--NOVO EM 15/1/21 --FIM--BUSCAR A DATA FIM DE GOZO REAL NOS CASOS DE INTERRUPÇÃO DE FERIAS
*/
FOR C1 IN
(select D.DATA_DIA from RHTABS_DATAS D WHERE trunc(D.DATA_DIA) BETWEEN trunc(vNEW_DT_INI_GOZO) AND trunc(vNEW_DT_FIM_GOZO) order by d.data_dia)
LOOP
dbms_output.put_line('C1.DATA_DIA - '|| C1.DATA_DIA);
--inicio --para estorno se tiver ja ha lancamento no dia pega a ultima lancada no dia
FOR C2 IN (
SELECT SP.CODIGO_SITUACAO ULT_SP_NO_DIA, S.TIPO_SITUACAO , S.situacao_assoc
FROM RHPONT_RES_SIT_DIA SP
LEFT OUTER JOIN RHPONT_SITUACAO S ON SP.CODIGO_SITUACAO = S.CODIGO
WHERE SP.CODIGO_EMPRESA = vCODIGO_EMPRESA AND SP.TIPO_CONTRATO = vTIPO_CONTRATO AND SP.CODIGO_CONTRATO = vCODIGO
AND trunc(SP.DATA) = trunc(C1.DATA_DIA)
AND SP.DT_ULT_ALTER_USUA = (SELECT MAX(AUX.DT_ULT_ALTER_USUA) FROM RHPONT_RES_SIT_DIA AUX WHERE AUX.CODIGO_EMPRESA = vCODIGO_EMPRESA AND AUX.TIPO_CONTRATO = vTIPO_CONTRATO AND AUX.CODIGO_CONTRATO = vCODIGO
AND trunc(AUX.DATA) = trunc(C1.DATA_DIA)
AND AUX.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
AND SP.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
LOOP
--dbms_output.put_line('C2.ULT_SP_NO_DIA - '|| C2.ULT_SP_NO_DIA);
IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --Perido do Lancamento (total/parcial) ja fechado Ifponto? = SIM
AND vSP_NEW_CODIGO IS NOT NULL --Lancamento possui Situacao Ponto vinculada? = SIM
--AND C2.ULT_SP_NO_DIA IS NOT NULL AND C2.situacao_assoc IS NOT NULL --A ultima situaCAo ponto no dia possui situaCAo de estorno? = SIM
AND C2.TIPO_SITUACAO <> 'C'--A ultima situaco ponto no dia ser o ESTORNO de uma FALTA/ATRASOS ? = NaO
AND C2.TIPO_SITUACAO = 'F'--A ultima situacao ponto ser de FALTA/ATRASOS? = SIM
AND C2.ULT_SP_NO_DIA <> vSP_NEW_CODIGO --novo em 16/8/21 PARA CRIAR ESTORNO APENAS SE SIT PONTO DE FALTA FOR DIFERENTE DA SIT PONTO DA SIT FUNC EMAIL de 12/08/21(Problema Lancamento Automatico)
AND vNEW_STATUS_CONFIRMACAO IN ('1','5','D','G')--NOVO EM 28/7/20
THEN
--4 TAREFA
dbms_output.put_line('4 TAREFA-Cria Estorno da SituaCAo de Ponto - '||C2.ULT_SP_NO_DIA ||'-'||C2.TIPO_SITUACAO||'-'||C2.situacao_assoc);
DELETE RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vCODIGO AND trunc(DATA) = trunc(C1.DATA_DIA) AND CODIGO_SITUACAO = C2.situacao_assoc
AND TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
;--NOVO EM 9/7/20
INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, LOGIN_USUARIO, DT_ULT_ALTER_USUA, TIPO_APURACAO, FORCA_SITUACAO  )
VALUES (vCODIGO_EMPRESA, vTIPO_CONTRATO, vCODIGO, trunc(C1.DATA_DIA), C2.situacao_assoc, 1, vNEW_LOGIN_USUARIO, SYSDATE - 1/24/60/60, 'F', 'N');

END IF;--4 TAREFA
END LOOP;--LOOP 2

IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --PerIodo do LanCamento (total/parcial) jA fechado Ifponto? = SIM
AND vSP_NEW_CODIGO IS NOT NULL
THEN --LanCamento possui SituaCAo Ponto vinculada? = SIM
--7 TAREFA
IF vNEW_DT_FIM_GOZO IS NOT NULL 
AND vNEW_STATUS_CONFIRMACAO IN ('1','5','D','G')--NOVO EM 28/7/20
THEN--NOVO EM 10/7/20
dbms_output.put_line('7 TAREFA-Cria na data a situaCAo ponto para o bm - '||vSP_NEW_CODIGO );
DELETE RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vCODIGO AND trunc(DATA) = trunc(C1.DATA_DIA) AND CODIGO_SITUACAO = vSP_NEW_CODIGO
AND TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
;--NOVO EM 9/7/20
INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, LOGIN_USUARIO, DT_ULT_ALTER_USUA, TIPO_APURACAO, FORCA_SITUACAO  )
VALUES (vCODIGO_EMPRESA, vTIPO_CONTRATO, vCODIGO,trunc(C1.DATA_DIA), vSP_NEW_CODIGO, 1, vNEW_LOGIN_USUARIO, SYSDATE + 1/24/60/60, 'F', 'N');
END IF;--NOVO EM 10/7/20

END IF;--7 TAREFA
END LOOP;--LOOP 1


--------------------------------------------------------------------INSERT
ELSIF vTIPO_DML = 'I' AND vNEW_DT_FIM_GOZO IS NOT NULL
AND vNEW_STATUS_CONFIRMACAO IN ('1','5','D','G')--NOVO EM 28/7/20
THEN
dbms_output.put_line('insert FERIAS');
FOR C1 IN
(select D.DATA_DIA from RHTABS_DATAS D WHERE trunc(D.DATA_DIA) BETWEEN trunc(vNEW_DT_INI_GOZO) AND trunc(vNEW_DT_FIM_GOZO) order by d.data_dia)
LOOP
dbms_output.put_line('C1.DATA_DIA - '|| C1.DATA_DIA);
--inicio --para estorno se tiver jA lanCamento no dia pega a ultima lanCada no dia
FOR C2 IN (
SELECT SP.CODIGO_SITUACAO ULT_SP_NO_DIA, S.TIPO_SITUACAO , S.situacao_assoc
FROM RHPONT_RES_SIT_DIA SP
LEFT OUTER JOIN RHPONT_SITUACAO S ON SP.CODIGO_SITUACAO = S.CODIGO
WHERE SP.CODIGO_EMPRESA = vCODIGO_EMPRESA AND SP.TIPO_CONTRATO = vTIPO_CONTRATO AND SP.CODIGO_CONTRATO = vCODIGO
AND trunc(SP.DATA) = trunc(C1.DATA_DIA)
AND SP.DT_ULT_ALTER_USUA = (SELECT MAX(AUX.DT_ULT_ALTER_USUA) FROM RHPONT_RES_SIT_DIA AUX WHERE AUX.CODIGO_EMPRESA = vCODIGO_EMPRESA AND AUX.TIPO_CONTRATO = vTIPO_CONTRATO AND AUX.CODIGO_CONTRATO = vCODIGO
AND trunc(AUX.DATA) = trunc(C1.DATA_DIA)
AND AUX.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
AND SP.TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
)
LOOP
--dbms_output.put_line('C2.ULT_SP_NO_DIA - '|| C2.ULT_SP_NO_DIA);
IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --PerIOodo do LancAmento (total/parcial) jA fechado Ifponto? = SIM
AND vSP_NEW_CODIGO IS NOT NULL --LanÃƒÂ§amento possui SituaCAo Ponto vinculada? = SIM
--AND C2.ULT_SP_NO_DIA IS NOT NULL AND C2.situacao_assoc IS NOT NULL THEN --A ultima situaCAo ponto no dia possui situaCAo de estorno? = SIM
AND C2.TIPO_SITUACAO <> 'C'--A ultima situaCAo ponto no dia SER o ESTORNO de uma FALTA/ATRASOS ? = NA’O
AND C2.TIPO_SITUACAO = 'F'--A ultima situaCAo ponto SER de FALTA/ATRASOS? = SIM
AND C2.ULT_SP_NO_DIA <> vSP_NEW_CODIGO --novo em 16/8/21 PARA CRIAR ESTORNO APENAS SE SIT PONTO DE FALTA FOR DIFERENTE DA SIT PONTO DA SIT FUNC EMAIL de 12/08/21(Problema Lancamento Automatico)
AND C2.SITUACAO_ASSOC IS NOT NULL --NOVO EM 28/6/22 AJUSTE JA PENSADO EM OUTRO EMAIL MAS FEITO DEVIDO AO CASO (Ordem de serviço Lázara Cassiano)
THEN
--6 TAREFA
dbms_output.put_line('6 TAREFA-Cria Estorno da SituaCAo de Ponto - '||C2.ULT_SP_NO_DIA ||'-'||C2.TIPO_SITUACAO||'-'||C2.situacao_assoc);
DELETE RHPONT_RES_SIT_DIA WHERE CODIGO_EMPRESA = vCODIGO_EMPRESA AND TIPO_CONTRATO = vTIPO_CONTRATO AND CODIGO_CONTRATO = vCODIGO AND trunc(DATA) = trunc(C1.DATA_DIA) AND CODIGO_SITUACAO = C2.situacao_assoc
AND TIPO_APURACAO = 'F'--em 1/2/24 novo devido email: [Virtual] Lançamento de estornos sem a ocorrência
;--NOVO EM 9/7/20
INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, LOGIN_USUARIO, DT_ULT_ALTER_USUA, TIPO_APURACAO, FORCA_SITUACAO  )
VALUES (vCODIGO_EMPRESA, vTIPO_CONTRATO, vCODIGO, trunc(C1.DATA_DIA), C2.situacao_assoc, 1, vNEW_LOGIN_USUARIO, SYSDATE - 1/24/60/60, 'F', 'N');

END IF;--6 TAREFA
END LOOP;--LOOP 2
IF C1.DATA_DIA <= vULT_DIA_APUR_IFPONTO --PerIO­odo do LanCamento (total/parcial) jA fechado Ifponto? = SIM
AND vSP_NEW_CODIGO IS NOT NULL THEN --LanCAamento possui SituaCAo Ponto vinculada? = SIM
--8 TAREFA
dbms_output.put_line('8 TAREFA-Cria na data a situACAo ponto para o bm - '||vSP_NEW_CODIGO );
DELETE RHPONT_RES_SIT_DIA where CODIGO_EMPRESA = vCODIGO_EMPRESA and TIPO_CONTRATO = vTIPO_CONTRATO and CODIGO_CONTRATO = vCODIGO and trunc(DATA) = trunc(C1.DATA_DIA) and CODIGO_SITUACAO = vSP_NEW_CODIGO and REF_HORAS = 1 and TIPO_APURACAO = 'F';--NOVO EM 20/1/20
INSERT INTO RHPONT_RES_SIT_DIA (CODIGO_EMPRESA, TIPO_CONTRATO, CODIGO_CONTRATO, DATA, CODIGO_SITUACAO, REF_HORAS, LOGIN_USUARIO, DT_ULT_ALTER_USUA, TIPO_APURACAO , FORCA_SITUACAO )
VALUES (vCODIGO_EMPRESA, vTIPO_CONTRATO, vCODIGO, trunc(C1.DATA_DIA), vSP_NEW_CODIGO, 1, vNEW_LOGIN_USUARIO, SYSDATE + 1/24/60/60, 'F', 'N');

END IF;--7 TAREFA
END LOOP;--LOOP 1

ELSE
dbms_output.put_line('FALTA MAPEAR');
END IF; 

ELSE dbms_output.put_line('Valor ANTIGO ou NOVO possuem SituaCAO Ponto associada? = NAO');
END IF; --fim--Valor ANTIGO ou NOVO possuem SituaCAo Ponto associada?


END; --2 'FERIAS'
END; --1 'FERIAS'
--FIM----------------------------------------------------------------------------------------------------------------------------'FERIAS'

--INICIO----------------------------------------------------------------------------------------------------------------------------'FICHA MEDICA / TEG'
/*
ELSIF vORIGEM = 'FICHA_MEDICA'  THEN
*/
--FIM----------------------------------------------------------------------------------------------------------------------------'FICHA MEDICA / TEG'


--INICIO----------------------------------------------------------------------------------------------------------------------------'DIRETO SITUACAO DE PONTO'
--FIM----------------------------------------------------------------------------------------------------------------------------'DIRETO SITUACAO DE PONTO'




ELSE
dbms_output.put_line('ORIGEM NAO MAPEADA' );

END IF; --1 IF
--FIM ---------------------------------------------------------------------------------IDENTIFICANDO ORIGENS-----------------------------------------------------------------------------------------------------------------------


END;-- END 2 BEGIN

END;-- END 1 BEGIN
