
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."SMARH_INT_IMPORTA_SGE" 
AS
BEGIN
UPDATE PONTO_ELETRONICO.SMARH_INT_PONTO_SGE_ARQUIVOS SET BM_SERVIDOR = LPAD(REPLACE(BM_SERVIDOR,' ',''),15,0);
COMMIT;
  DECLARE
    vCONTADOR NUMBER;
    
  BEGIN -- 1º BEGIN
    dbms_output.enable(NULL);
    vCONTADOR :=0;
    
    
    
    FOR C1 IN
    (
    --1.2 - CONTROLE DE DATAS E GRAVAR REGISTRO TABELA DEFINITIVA (SMARH_INT_PE_EXTENSOES_JORNAD)
    --CRIADO KELLYSSON EM 2/4/18
    ---PARA CONTROLAR AS DATAS DE RECEBIMENTO DO CADASTRO E CANCELAMENTO DAS EXTENSÕES DO SGE PARA DENTRO DO ARTERH
    --ALTERADO EM 17/4/18 PARA TABELA NOVA NÃO OFICIAL DO ARTERH
    --alterado em 3/10/18 para adicionar os novos campos que o SGE comecou a preencher
    -------------INICIO---------------------------------------------------------------------------------PARA REGISTROS NOVOS---------------------------------------------------------------
    SELECT BM_SERVIDOR,
      CODIGO_CONTRATO_SGE,
      CODIGO_ESCOLA,
      DISCIPLINA_MINISTRADA,
      CANCELAMENTO,
      DT_CANCELAMENTO_SGE,
      DT_CRIACAO_SGE,
      FIM,
      INICIO,
      FAZ_JUS_VALE_REF,
      CASE
        WHEN INICIO_SEGUNDA IS NULL
        OR INICIO_SEGUNDA    = '00:00'
        THEN NULL
        ELSE TO_CHAR(TO_DATE('01/01/2001 '
          ||INICIO_SEGUNDA
          || ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
      END INICIO_SEGUNDA,
      CASE
        WHEN FIM_SEGUNDA IS NULL
        OR FIM_SEGUNDA    = '00:00'
        THEN NULL
        ELSE TO_CHAR(TO_DATE('01/01/2001 '
          ||FIM_SEGUNDA
          || ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
      END FIM_SEGUNDA,
      CASE
        WHEN INICIO_TERCA IS NULL
        OR INICIO_TERCA    = '00:00'
        THEN NULL
        ELSE TO_CHAR(TO_DATE('01/01/2001 '
          ||INICIO_TERCA
          || ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
      END INICIO_TERCA,
      CASE
        WHEN FIM_TERCA IS NULL
        OR FIM_TERCA    = '00:00'
        THEN NULL
        ELSE TO_CHAR(TO_DATE('01/01/2001 '
          ||FIM_TERCA
          || ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
      END FIM_TERCA,
      CASE
        WHEN INICIO_QUARTA IS NULL
        OR INICIO_QUARTA    = '00:00'
        THEN NULL
        ELSE TO_CHAR(TO_DATE('01/01/2001 '
          ||INICIO_QUARTA
          || ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
      END INICIO_QUARTA,
      CASE
        WHEN FIM_QUARTA IS NULL
        OR FIM_QUARTA    = '00:00'
        THEN NULL
        ELSE TO_CHAR(TO_DATE('01/01/2001 '
          ||FIM_QUARTA
          || ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
      END FIM_QUARTA,
      CASE
        WHEN INICIO_QUINTA IS NULL
        OR INICIO_QUINTA    = '00:00'
        THEN NULL
        ELSE TO_CHAR(TO_DATE('01/01/2001 '
          ||INICIO_QUINTA
          || ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
      END INICIO_QUINTA,
      CASE
        WHEN FIM_QUINTA IS NULL
        OR FIM_QUINTA    = '00:00'
        THEN NULL
        ELSE TO_CHAR(TO_DATE('01/01/2001 '
          ||FIM_QUINTA
          || ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
      END FIM_QUINTA,
      CASE
        WHEN INICIO_SEXTA IS NULL
        OR INICIO_SEXTA    = '00:00'
        THEN NULL
        ELSE TO_CHAR(TO_DATE('01/01/2001 '
          ||INICIO_SEXTA
          || ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
      END INICIO_SEXTA,
      CASE
        WHEN FIM_SEXTA IS NULL
        OR FIM_SEXTA    = '00:00'
        THEN NULL
        ELSE TO_CHAR(TO_DATE('01/01/2001 '
          ||FIM_SEXTA
          || ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
      END FIM_SEXTA,
      CASE
        WHEN INICIO_SABADO IS NULL
        OR INICIO_SABADO    = '00:00'
        THEN NULL
        ELSE TO_CHAR(TO_DATE('01/01/2001 '
          ||INICIO_SABADO
          || ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
      END INICIO_SABADO,
      CASE
        WHEN FIM_SABADO IS NULL
        OR FIM_SABADO    = '00:00'
        THEN NULL
        ELSE TO_CHAR(TO_DATE('01/01/2001 '
          ||FIM_SABADO
          || ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
      END FIM_SABADO,
      CASE
        WHEN INICIO_DOMINGO IS NULL
        OR INICIO_DOMINGO    = '00:00'
        THEN NULL
        ELSE TO_CHAR(TO_DATE('01/01/2001 '
          ||INICIO_DOMINGO
          || ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
      END INICIO_DOMINGO,
      CASE
        WHEN FIM_DOMINGO IS NULL
        OR FIM_DOMINGO    = '00:00'
        THEN NULL
        ELSE TO_CHAR(TO_DATE('01/01/2001 '
          ||FIM_DOMINGO
          || ':00','DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')
      END FIM_DOMINGO,
      HORAS,
      ID_JORNADA,
      ID_REGISTRO_ARQUIVO,
      MOTIVO,
      NOME_ESCOLA,
      NOME_SERVIDOR,
      OBSERVACAO,
      REQUER_VALE_REF,
      DIAS,
      TURNO
    FROM PONTO_ELETRONICO.SMARH_INT_PONTO_SGE_ARQUIVOS X
    WHERE NOT EXISTS
      (SELECT H.*
      FROM PONTO_ELETRONICO.SMARH_INT_PE_EXTENSOES_JORNAD H
      WHERE X.ID_JORNADA = H.ID_JORNADA
      )
      --and id_jornada = 371220
    )
    LOOP
      vCONTADOR :=vCONTADOR+1;
      INSERT
      INTO PONTO_ELETRONICO.SMARH_INT_PE_EXTENSOES_JORNAD
        (
          TIPO_EXTENSAO,
          CODIGO_EMPRESA,
          ID_REGISTRO_ARQUIVO,
          CODIGO_CONTRATO_SGE,
          BM_SERVIDOR,
          NOME_SERVIDOR,
          CODIGO_ESCOLA,
          COD_LOCAL1,
          COD_LOCAL2,
          COD_LOCAL3,
          COD_LOCAL4,
          COD_LOCAL5,
          COD_LOCAL6,
          NOME_ESCOLA,
          MOTIVO,
          DT_INICIO,
          DT_FIM,
          TOTAL_DIAS,
          HORAS_SEMANAIS,
          TURNO,
          DISCIPLINA_MINISTRADA,
          DT_CANCELAMENTO,
          ID_JORNADA,
          DT_RECEBEU_CADASTRO,
          DT_RECEBEU_CANCELAMENTO,
          DT_CRIACAO_SGE,
          FAZ_JUS_VALE_REF,
          REQUER_VALE_REF,
          OBSERVACAO,
          HORARIO_INICIO_SEGUNDA,
          HORARIO_FIM_SEGUNDA,
          HORARIO_INICIO_TERCA,
          HORARIO_FIM_TERCA,
          HORARIO_INICIO_QUARTA,
          HORARIO_FIM_QUARTA,
          HORARIO_INICIO_QUINTA,
          HORARIO_FIM_QUINTA,
          HORARIO_INICIO_SEXTA,
          HORARIO_FIM_SEXTA,
          HORARIO_INICIO_SABADO,
          HORARIO_FIM_SABADO,
          HORARIO_INICIO_DOMINGO,
          HORARIO_FIM_DOMINGO
        )
        VALUES
        (
          'EXTENSAO_SGE_PROFESSOR_SALA_DE_AULA',
          '0001',
          ''
          || C1.ID_REGISTRO_ARQUIVO
          ||'',
          ''
          || C1.CODIGO_CONTRATO_SGE
          ||'',
          C1.BM_SERVIDOR
          ,
          ''
          || C1.NOME_SERVIDOR
          ||'',
          ''
          || C1.CODIGO_ESCOLA
          ||'',
          ''
          || LPAD(SUBSTR(C1.CODIGO_ESCOLA,1,2),6,0)
          ||'',
          ''
          || LPAD(SUBSTR(C1.CODIGO_ESCOLA,3,2),6,0)
          ||'',
          ''
          || LPAD(SUBSTR(C1.CODIGO_ESCOLA,5,2),6,0)
          ||'',
          ''
          || LPAD(SUBSTR(C1.CODIGO_ESCOLA,7,2),6,0)
          ||'',
          ''
          || LPAD(SUBSTR(C1.CODIGO_ESCOLA,9,2),6,0)
          ||'',
          ''
          || LPAD(SUBSTR(C1.CODIGO_ESCOLA,11,3),6,0)
          ||'',
          ''
          || C1.NOME_ESCOLA
          ||'',
          ''
          || C1.MOTIVO
          ||'',
          ''
          || C1.INICIO
          ||'',
          ''
          || C1.FIM
          ||'',
          ''
          || C1.DIAS
          ||'',
          ''
          || C1.HORAS
          ||'',
          ''
          || C1.TURNO
          ||'',
          ''
          || C1.DISCIPLINA_MINISTRADA
          ||'',
          NULL,
          ''
          || C1.ID_JORNADA
          || '',
          SYSDATE,
          NULL ,
          TO_DATE(''
          || C1.DT_CRIACAO_SGE
          ||'','DD/MM/YYYY'),
          ''
          || C1.FAZ_JUS_VALE_REF
          ||'',
          ''
          || C1.REQUER_VALE_REF
          ||'',
          ''
          || C1.OBSERVACAO
          ||'',
          ''
          || C1.INICIO_SEGUNDA
          ||'',
          ''
          || C1.FIM_SEGUNDA
          ||'',
          ''
          || C1.INICIO_TERCA
          ||'',
          ''
          || C1.FIM_TERCA
          ||'',
          ''
          || C1.INICIO_QUARTA
          ||'',
          ''
          || C1.FIM_QUARTA
          ||'',
          ''
          || C1.INICIO_QUINTA
          ||'',
          ''
          || C1.FIM_QUINTA
          ||'',
          ''
          || C1.INICIO_SEXTA
          ||'',
          ''
          || C1.FIM_SEXTA
          ||'',
          ''
          || C1.INICIO_SABADO
          ||'',
          ''
          || C1.FIM_SABADO
          ||'',
          ''
          || C1.INICIO_DOMINGO
          ||'',
          ''
          || C1.FIM_DOMINGO
          ||''
        );
    END LOOP;
    -------------FIM---------------------------------------------------------------------------------PARA REGISTROS NOVOS---------------------------------------------------------------
    -------------INICIO---------------------------------------------------------------------------------PARA REGISTROS CANCELAMENTO---------------------------------------------------------------
    FOR C1 IN
    (SELECT *
      FROM PONTO_ELETRONICO.SMARH_INT_PONTO_SGE_ARQUIVOS X
      WHERE X.CANCELAMENTO IS NOT NULL
      AND EXISTS
        (SELECT H.*
        FROM PONTO_ELETRONICO.SMARH_INT_PE_EXTENSOES_JORNAD H
        WHERE X.ID_JORNADA    = H.ID_JORNADA
        AND (X.CANCELAMENTO  <> H.DT_CANCELAMENTO
        OR H.DT_CANCELAMENTO IS NULL)
        )
    )
    LOOP
      vCONTADOR :=vCONTADOR+1;
      UPDATE PONTO_ELETRONICO.SMARH_INT_PE_EXTENSOES_JORNAD
      SET DT_CANCELAMENTO = ''
        ||C1.CANCELAMENTO
        ||'',
        DT_CANCELAMENTO_SGE = TO_DATE(''
        ||C1.DT_CANCELAMENTO_SGE
        ||'','DD/MM/YYYY'),
        DT_RECEBEU_CANCELAMENTO = SYSDATE
      WHERE ID_JORNADA          = ''
        ||C1.ID_JORNADA
        || '';
    END LOOP;
    -------------FIM---------------------------------------------------------------------------------PARA REGISTROS CANCELAMENTO---------------------------------------------------------------
  END;
END SMARH_INT_IMPORTA_SGE;