
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_APAGA_REGISTROS_PONTO" (pCOD_EMPRESA IN VARCHAR2, pCOD_FECHAMENTO IN NUMBER, pDATA_INI IN DATE, pDATA_FIM IN DATE)
-- *******************************************************************************************************************
-- Descricao.....: PROCEDURE RESPONSÁVEL PELA EXCLUSÃO DOS REGISTROS NAS TABELAS DE APOIO DO ARTERH
--                 TABELAS PRINCIPAIS: ARTERH.RHPONT_RES_SIT_DIA, PONTO_ELETRONICO.IFPONTO_ESPELHO_TOTALIZADORES
-- 									   PONTO_ELETRONICO.IFPONTO_BANCO_HORAS, PONTO_ELETRONICO.IFPONTO_ESPELHO_HISTORICA	
-- 									   PONTO_ELETRONICO.IFPONTO_ESPELHO

-- Autor................: MARCELO SOARES
-- Última alteração.....: 30/28/2023
-- Compilada em PRODUÇÃO: SIM

-- Parametros....: INFORMAR O CÓDIGO DE FECHAMENTO CRIADO NO SISTEMA IFPONTO MAIS 
--                 O CÓDIGO DA EMPRESA 
-- Funcionamento.: EXECUÇÃO MANUAL
-- Periodicidade.: CONFORME A NECESSIDADE DO RH DA EMPRESA

--  PASSOS DE EXECUÇÃO PARA INTEGRAÇÃO DA PRODABEL:

--	1) CRIAR O FECHAMENTO DO ESPELHO NO SISTEMA
--	2) ENTRAR NO SISTEMA POWER CENTER E EXECUTAR O WORKFLOW:
--		2.1) INTEGRAÇÃO DO ESPELHO
--		2.1) INTEGRAÇÃO DE BANCO DE HORAS
--	3) ENTRAR  NO SISTEMA ARTERH NA OPÇÃO COMANDO SQL  E EXECUTAR OS SQL´S:
--		3.1) GRAVA REGISTROS DO ESPELHO NA HISTORICA
--		3.2) GERAR TOTALIZADORA DO ESPELHO DE PONTO
--		3.3) GERAR TOTALIZADORA DE BANCO DE HORAS
--		3.4) GRAVA PLANILHA DE SITUAÇÃO DE PONTO 
-- 		3.5) EXECUTAR O SQL QUE APAGARÁ TODOS OS REGISTROS CRIADOS NA PLANILHA SITUAÇÃO PONTO E NAS TABELAS DE APOIO

-- *******************************************************************************************************************
IS
BEGIN
	-- ORDEM DE EXCLUSÃO: 

	-- RHPONT_RES_SIT_DIA
	DELETE FROM ARTERH.RHPONT_RES_SIT_DIA
	WHERE TRUNC(DATA) BETWEEN TRUNC(pDATA_INI) AND TRUNC(pDATA_FIM)
	AND TIPO_APURACAO = 'F'
	AND CODIGO_EMPRESA = pCOD_EMPRESA
	AND LOGIN_USUARIO = 'IFPONTO';

	COMMIT;

	-- IFPONTO_ESPELHO_TOTALIZADORES
	DELETE FROM PONTO_ELETRONICO.IFPONTO_ESPELHO_TOTALIZADORES
	WHERE CODIGO_EMPRESA = pCOD_EMPRESA
	AND TRUNC(DATA) BETWEEN TRUNC(pDATA_INI) AND TRUNC(pDATA_FIM);

	COMMIT;

	-- IFPONTO_BANCO_HORAS
	DELETE FROM PONTO_ELETRONICO.IFPONTO_BANCO_HORAS
	WHERE COD_EMPRESA = pCOD_EMPRESA
	AND TRUNC(DATA) BETWEEN TRUNC(pDATA_INI) AND TRUNC(pDATA_FIM)
	AND COD_PONTO_FECHAMENTO = pCOD_FECHAMENTO;

	COMMIT;

	-- IFPONTO_ESPELHO_HISTORICA
	DELETE FROM PONTO_ELETRONICO.IFPONTO_ESPELHO_HISTORICA
	WHERE COD_PONTO_FECHAMENTO = pCOD_FECHAMENTO
	AND COD_EMPRESA = TO_NUMBER(pCOD_EMPRESA)
	AND TRUNC(DATA) BETWEEN TRUNC(pDATA_INI) AND TRUNC(pDATA_FIM);

	COMMIT;

	-- IFPONTO_ESPELHO
	DELETE FROM PONTO_ELETRONICO.IFPONTO_ESPELHO
	WHERE COD_PONTO_FECHAMENTO = pCOD_FECHAMENTO
	AND COD_EMPRESA = TO_NUMBER(pCOD_EMPRESA)
	AND TRUNC(DATA) BETWEEN TRUNC(pDATA_INI) AND TRUNC(pDATA_FIM);

	COMMIT;	
END PR_APAGA_REGISTROS_PONTO;
