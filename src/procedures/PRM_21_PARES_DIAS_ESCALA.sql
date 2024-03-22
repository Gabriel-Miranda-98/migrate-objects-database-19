
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PRM_21_PARES_DIAS_ESCALA" 
AS
BEGIN
--Kellysson em 8/4/22 baseado (transfor_pares_em_dias_escala.sql)


--KELLYSSON EM 24/3/21 --- para piloto da SMSA marcacoes, saber em qual escala a pessoa esta pegando do historico de escala e espelho do Ifponto 
declare
vCONTADOR1 NUMBER;
vCONTADOR2 NUMBER;
vQTD_DIAS_CICLO_ESCALA NUMBER;
vCONTADOR3 NUMBER;
vNUMERO_LINHA_ATUAL NUMBER;

begin
dbms_output.enable(null);
vCONTADOR1 :=0;
vCONTADOR2 :=0;
vQTD_DIAS_CICLO_ESCALA := null;
vCONTADOR3 :=0;
vNUMERO_LINHA_ATUAL :=0;

FOR C1 IN (
--SELECT * FROM  PONTO_ELETRONICO.IFPONTO_ESCALA_PADRAO  ORDER BY CODIGO_LEGADO
SELECT X2.* FROM(
SELECT 
'Semanal' TIPO, X.COD_ESCALA_PADRAO, COUNT(1)QTD_DIAS --
--INTO vQTD_DIAS_CICLO_ESCALA
--CASE WHEN X.QT_FOLG = 1 THEN 'FOLGA' ELSE 'TRABALHO' END TIPO_DIA,
--X.*
FROM(
SELECT 
E.TIPO,
CASE WHEN EH.QTD_TRABALHO IS NULL THEN 0 ELSE EH.QTD_TRABALHO END QT_TRAB,
CASE WHEN EH.QTD_FOLGA IS NULL THEN 0 ELSE EH.QTD_FOLGA END QT_FOLG
, EH.*--, E.*, H.*
FROM PONTO_ELETRONICO.IFPONTO_ESCALA_HORARIO EH
LEFT OUTER JOIN PONTO_ELETRONICO.IFPONTO_ESCALA_PADRAO E ON E.CODIGO = EH.COD_ESCALA_PADRAO--7762 registros
LEFT OUTER JOIN PONTO_ELETRONICO.IFPONTO_HORARIO H ON H.CODIGO = EH.COD_HORARIO--7762 registros
WHERE E.TIPO = 'Semanal'-- EH.COD_ESCALA_PADRAO IN (151)-- 
)X  GROUP BY X.COD_ESCALA_PADRAO 
UNION ALL
SELECT 
'Ciclica' TIPO, X.COD_ESCALA_PADRAO, SUM(X.QT_TRAB + X.QT_FOLG)QTD_DIAS --
FROM(
SELECT 
E.TIPO,
CASE WHEN EH.QTD_TRABALHO IS NULL THEN 0 ELSE EH.QTD_TRABALHO END QT_TRAB,
CASE WHEN EH.QTD_FOLGA IS NULL THEN 0 ELSE EH.QTD_FOLGA END QT_FOLG
, EH.*
FROM PONTO_ELETRONICO.IFPONTO_ESCALA_HORARIO EH
LEFT OUTER JOIN PONTO_ELETRONICO.IFPONTO_ESCALA_PADRAO E ON E.CODIGO = EH.COD_ESCALA_PADRAO--7762 registros
LEFT OUTER JOIN PONTO_ELETRONICO.IFPONTO_HORARIO H ON H.CODIGO = EH.COD_HORARIO--7762 registros
WHERE E.TIPO = 'Ciclica'-- EH.COD_ESCALA_PADRAO IN (577)
)X GROUP BY X.COD_ESCALA_PADRAO 
)X2 ORDER BY X2.COD_ESCALA_PADRAO


)
LOOP
vCONTADOR1 := vCONTADOR1 + 1;
dbms_output.put_line('--vCONTADOR1: '||vCONTADOR1||' C1.TIPO: '||C1.TIPO|| ' C1.COD_ESCALA_PADRAO: '||C1.COD_ESCALA_PADRAO||' C1.QTD_DIAS: '||C1.QTD_DIAS);

FOR C2 IN (

SELECT CASE WHEN X2.MOD_NUM_LINHA = 1 THEN 'IMPAR' WHEN X2.MOD_NUM_LINHA = 0 THEN 'PAR' END IMPAR_PAR, 
X2.* FROM(
SELECT 
MOD(X.NUMERO_LINHA,2) MOD_NUM_LINHA,
X.* FROM(
/*SELECT 
ROW_NUMBER() OVER (PARTITION BY EH.COD_ESCALA_PADRAO ORDER BY EH.POSICAO) NUMERO_LINHA,
E.TIPO,
CASE WHEN EH.QTD_TRABALHO IS NULL THEN 0 ELSE EH.QTD_TRABALHO END QT_TRAB,
CASE WHEN EH.QTD_FOLGA IS NULL THEN 0 ELSE EH.QTD_FOLGA END QT_FOLG
, EH.*--, E.*, H.*
FROM PONTO_ELETRONICO.IFPONTO_ESCALA_HORARIO EH
LEFT OUTER JOIN PONTO_ELETRONICO.IFPONTO_ESCALA_PADRAO E ON E.CODIGO = EH.COD_ESCALA_PADRAO--7762 registros
LEFT OUTER JOIN PONTO_ELETRONICO.IFPONTO_HORARIO H ON H.CODIGO = EH.COD_HORARIO--7762 registros
WHERE EH.COD_ESCALA_PADRAO = C1.COD_ESCALA_PADRAO--E.TIPO = 'Semanal'-- EH.COD_ESCALA_PADRAO IN (151)-- 
UNION ALL*/
SELECT 
ROW_NUMBER() OVER (PARTITION BY EH.COD_ESCALA_PADRAO ORDER BY EH.POSICAO) NUMERO_LINHA,
E.TIPO,
CASE WHEN EH.QTD_TRABALHO IS NULL THEN 0 ELSE EH.QTD_TRABALHO END QT_TRAB,
CASE WHEN EH.QTD_FOLGA IS NULL THEN 0 ELSE EH.QTD_FOLGA END QT_FOLG
, EH.*
FROM PONTO_ELETRONICO.IFPONTO_ESCALA_HORARIO EH
LEFT OUTER JOIN PONTO_ELETRONICO.IFPONTO_ESCALA_PADRAO E ON E.CODIGO = EH.COD_ESCALA_PADRAO--7762 registros
LEFT OUTER JOIN PONTO_ELETRONICO.IFPONTO_HORARIO H ON H.CODIGO = EH.COD_HORARIO--7762 registros
WHERE  EH.COD_ESCALA_PADRAO = C1.COD_ESCALA_PADRAO--E.TIPO = 'Ciclica'-- EH.COD_ESCALA_PADRAO IN (577)
)X
)X2

)
LOOP
vCONTADOR2 := vCONTADOR2 + 1;
vNUMERO_LINHA_ATUAL := C2.NUMERO_LINHA;
dbms_output.put_line('--vCONTADOR2: '||vCONTADOR2||' C2.IMPAR_PAR: '||C2.IMPAR_PAR ||' C2.MOD_NUM_LINHA: '||C2.MOD_NUM_LINHA ||' C2.NUMERO_LINHA: '||C2.NUMERO_LINHA||' C2.TIPO: ' ||C2.TIPO||' C2.QT_TRAB: ' ||C2.QT_TRAB||' C2.QT_FOLG:'  ||C2.QT_FOLG||' C2.CODIGO: ' ||C2.CODIGO||' C2.COD_HORARIO: ' ||C2.COD_HORARIO||' C2.COD_ESCALA_PADRAO: ' ||C2.COD_ESCALA_PADRAO||' C2.POSICAO: ' ||C2.POSICAO);


IF C2.TIPO = 'Semanal' THEN
--FOR i IN 1..C1.QTD_DIAS LOOP
vCONTADOR3 := vCONTADOR3 + 1;
IF C2.QT_FOLG = 1 THEN 
DBMS_OUTPUT.PUT_LINE ('--vCONTADOR3: '||vCONTADOR3||' FOLGA');
DBMS_OUTPUT.PUT_LINE ('INSERT INTO PONTO_ELETRONICO.IFPONTO_RL_ESC_HOR VALUES('||C2.CODIGO||',''FOLGA'','||vCONTADOR3||','||vCONTADOR2||');'); 
INSERT INTO PONTO_ELETRONICO.IFPONTO_RL_ESC_HOR VALUES(C2.CODIGO,'FOLGA',vCONTADOR3,vCONTADOR2);COMMIT; 

ELSE 
DBMS_OUTPUT.PUT_LINE ('--vCONTADOR3: '||vCONTADOR3||' TRABALHO');
DBMS_OUTPUT.PUT_LINE ('INSERT INTO PONTO_ELETRONICO.IFPONTO_RL_ESC_HOR VALUES('||C2.CODIGO||',''TRABALHO'','||vCONTADOR3||','||vCONTADOR2||');');
INSERT INTO PONTO_ELETRONICO.IFPONTO_RL_ESC_HOR VALUES(C2.CODIGO,'TRABALHO',vCONTADOR3,vCONTADOR2);COMMIT;

END IF;
--END LOOP;

ELSIF C2.TIPO = 'Ciclica' /*AND C2.IMPAR_PAR = 'IMPAR'*/ THEN 
FOR i IN 1..C2.QT_TRAB LOOP
vCONTADOR3 := vCONTADOR3 + 1;
DBMS_OUTPUT.PUT_LINE ('--vCONTADOR3: '||vCONTADOR3||' TRABALHO');
DBMS_OUTPUT.PUT_LINE ('INSERT INTO PONTO_ELETRONICO.IFPONTO_RL_ESC_HOR VALUES('||C2.CODIGO||',''TRABALHO'','||vCONTADOR2||','||vCONTADOR3||');');
INSERT INTO PONTO_ELETRONICO.IFPONTO_RL_ESC_HOR VALUES(C2.CODIGO,'TRABALHO',vCONTADOR2,vCONTADOR3);COMMIT;

  END LOOP;
FOR i IN 1..C2.QT_FOLG LOOP
vCONTADOR3 := vCONTADOR3 + 1;
    DBMS_OUTPUT.PUT_LINE ('--vCONTADOR3: '||vCONTADOR3||' FOLGA');
DBMS_OUTPUT.PUT_LINE ('INSERT INTO PONTO_ELETRONICO.IFPONTO_RL_ESC_HOR VALUES('||C2.CODIGO||',''FOLGA'','||vCONTADOR2||','||vCONTADOR3||');');    
INSERT INTO PONTO_ELETRONICO.IFPONTO_RL_ESC_HOR VALUES(C2.CODIGO,'FOLGA',vCONTADOR2,vCONTADOR3);COMMIT;    

  END LOOP;
/*
ELSIF C2.TIPO = 'Ciclica' AND C2.IMPAR_PAR = 'PAR' THEN 
FOR i IN 1..C2.QT_TRAB LOOP
vCONTADOR3 := vCONTADOR3 + 1;
DBMS_OUTPUT.PUT_LINE ('--vCONTADOR3: '||vCONTADOR3||' TRABALHO');
  END LOOP;
FOR i IN 1..C2.QT_FOLG LOOP
vCONTADOR3 := vCONTADOR3 + 1;
    DBMS_OUTPUT.PUT_LINE ('--vCONTADOR3: '||vCONTADOR3||' FOLGA');
  END LOOP;
*/
END IF;
vCONTADOR3 :=0;
vNUMERO_LINHA_ATUAL :=0;

END LOOP;--FIM C2
vCONTADOR2 :=0;

END LOOP;--FIM C1
vCONTADOR1 :=0;


end;

END;