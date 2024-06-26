
  CREATE OR REPLACE EDITIONABLE PROCEDURE "PONTO_ELETRONICO"."PRM_22_COMPRIMENTO_ESCALA" 
AS
BEGIN
--Kellysson em 8/4/22 baseado (comprimento_escala.sql)


--KELLYSSON EM 25/3/21 --- para piloto da SMSA marcacoes, saber em qual escala a pessoa esta pegando do historico de escala e espelho do Ifponto 
--em 10/5/21 ajuste para erros encontrados na logica
--/*
declare
vCOMPRIMENTO VARCHAR2 (4000 BYTE);
vTIPO_DIA VARCHAR2 (10 BYTE);
vQTD_DIA NUMBER;
vCOD_HORARIO NUMBER; --NOVO EM 10/5/21

begin
dbms_output.enable(null);
vCOMPRIMENTO := NULL;
vTIPO_DIA := NULL;
vQTD_DIA := 0;
vCOD_HORARIO := 0;

FOR C1 IN 
(

select EH.COD_ESCALA_PADRAO, COUNT(1)QTD_DIAS_ESCALA 
from PONTO_ELETRONICO.IFPONTO_RL_ESC_HOR IFH 
LEFT OUTER JOIN PONTO_ELETRONICO.IFPONTO_ESCALA_HORARIO EH ON EH.CODIGO = IFH.CODIGO 
--WHERE EH.COD_ESCALA_PADRAO IN  (151,347,354,483,575,561)--(151,347,354,483)--(575,561)----(665)--(134,157,1304,456) --TESTES
GROUP BY EH.COD_ESCALA_PADRAO ORDER BY EH.COD_ESCALA_PADRAO

)
LOOP
dbms_output.put_line('C1.COD_ESCALA_PADRAO: '|| C1.COD_ESCALA_PADRAO);

FOR C2 IN (

SELECT
ROW_NUMBER() OVER (PARTITION BY E.CODIGO ORDER BY E.TIPO,E.COD_EMPRESA, E.CODIGO, IEH.SUB_CICLO, IEH.DIA_NO_SUB_CICLO) AS DIA_CICLO_ESCALA, 
E.TIPO, E.CODIGO COD_ESCALA, H.CODIGO COD_HORARIO, CASE WHEN IEH.TIPO_DIA = 'FOLGA' THEN 'F' WHEN IEH.TIPO_DIA = 'TRABALHO' THEN 'T' END TIPO_DIA, 
H.MARCACAO1, H.MARCACAO2, H.MARCACAO3, H.MARCACAO4,
 CASE WHEN EH.QTD_FOLGA = 0 THEN 1 ELSE 0 END QTD_TRABALHO, EH.QTD_FOLGA,
IEH.CODIGO, IEH.SUB_CICLO, IEH.DIA_NO_SUB_CICLO,
EH.POSICAO, 
E.COD_EMPRESA,  E.CODIGO_LEGADO CODIGO_LEGADO_ESCALA, E.NOME NOME_ESCALA, 
CASE WHEN E.MIN_FLEX_ENTRADA = 0 AND E.MIN_FLEX_SAIDA = 0 THEN 'SIM'  WHEN E.MIN_FLEX_ENTRADA <> 0 AND E.MIN_FLEX_SAIDA <> 0 THEN 'NAO' ELSE 'ERRO'END HORARIO_FLEXIVEL,
 H.CODIGO_LEGADO CODIGO_LEGADO_HORARIO, H.NOME NOME_HORARIO
FROM PONTO_ELETRONICO.IFPONTO_RL_ESC_HOR IEH --9487 REGISTROS
LEFT OUTER JOIN PONTO_ELETRONICO.IFPONTO_ESCALA_HORARIO EH ON IEH.CODIGO = EH.CODIGO--7762 registros
LEFT OUTER JOIN PONTO_ELETRONICO.IFPONTO_ESCALA_PADRAO E ON E.CODIGO = EH.COD_ESCALA_PADRAO--7762 registros
LEFT OUTER JOIN PONTO_ELETRONICO.IFPONTO_HORARIO H ON H.CODIGO = EH.COD_HORARIO--7762 registros
WHERE E.CODIGO = C1.COD_ESCALA_PADRAO--561--483--354--347--151--

)

LOOP
--dbms_output.put_line(C2.DIA_CICLO_ESCALA);
-------------------------------------------------------------------primeiro dia
--primeiro registro da escala/horario
IF C2.DIA_CICLO_ESCALA = 1 AND C2.DIA_CICLO_ESCALA < C1.QTD_DIAS_ESCALA THEN
vTIPO_DIA := C2.TIPO_DIA;
vQTD_DIA := 1;
vCOD_HORARIO := C2.COD_HORARIO; --NOVO EM 10/5/21
vCOMPRIMENTO := C2.TIPO ||'|'|| C2.CODIGO_LEGADO_ESCALA ||'|'|| C2.MARCACAO1 ||'|'|| C2.MARCACAO2 ||'|'|| C2.MARCACAO3 ||'|'|| C2.MARCACAO4;
--dbms_output.put_line('1-vCOMPRIMENTO: '||vCOMPRIMENTO);

-------------------------------------------------------------dias do meio
--diferene do primeiro regitro e nÃ£o Ã© o ultimo tambem e o tipo_dia igual ainda 
--e COD_HORARIO IGUAL --novo em 10/5/21
ELSIF C2.DIA_CICLO_ESCALA <> 1 AND C2.DIA_CICLO_ESCALA < C1.QTD_DIAS_ESCALA AND C2.TIPO_DIA = vTIPO_DIA 
AND C2.COD_HORARIO = vCOD_HORARIO THEN --novo em 10/5/21
vQTD_DIA := vQTD_DIA + 1;
--dbms_output.put_line('2.1-vCOMPRIMENTO: '||vCOMPRIMENTO);

--e COD_HORARIO DIFERENTE--novo em 10/5/21
ELSIF C2.DIA_CICLO_ESCALA <> 1 AND C2.DIA_CICLO_ESCALA < C1.QTD_DIAS_ESCALA AND C2.TIPO_DIA = vTIPO_DIA 
AND C2.COD_HORARIO <> vCOD_HORARIO THEN --novo em 10/5/21
--dbms_output.put_line('2.2.A-vCOMPRIMENTO: '||vCOMPRIMENTO);
vCOMPRIMENTO := vCOMPRIMENTO ||'|'|| vQTD_DIA ||'|'|| vTIPO_DIA || SUBSTR(vCOMPRIMENTO, length(vCOMPRIMENTO)-23, length(vCOMPRIMENTO))||'|0|F|'|| C2.MARCACAO1 ||'|'|| C2.MARCACAO2 ||'|'|| C2.MARCACAO3 ||'|'|| C2.MARCACAO4 ;
--dbms_output.put_line('2.2.D-vCOMPRIMENTO: '||vCOMPRIMENTO);
vQTD_DIA := 1;
vTIPO_DIA := C2.TIPO_DIA;
vCOD_HORARIO := C2.COD_HORARIO; --NOVO EM 10/5/21


--diferene do primeiro regitro e nÃ£o Ã© o ultimo tambem e o tipo_dia diferente
ELSIF C2.DIA_CICLO_ESCALA <> 1 AND C2.DIA_CICLO_ESCALA < C1.QTD_DIAS_ESCALA AND C2.TIPO_DIA <> vTIPO_DIA THEN
--dbms_output.put_line('2.3.A-vCOMPRIMENTO: '||vCOMPRIMENTO);
vCOMPRIMENTO := vCOMPRIMENTO ||'|'|| vQTD_DIA ||'|'|| vTIPO_DIA ||'|'|| C2.MARCACAO1 ||'|'|| C2.MARCACAO2 ||'|'|| C2.MARCACAO3 ||'|'|| C2.MARCACAO4;
--dbms_output.put_line('2.3.D-vCOMPRIMENTO: '||vCOMPRIMENTO);
vQTD_DIA := 1;
vTIPO_DIA := C2.TIPO_DIA;
vCOD_HORARIO := C2.COD_HORARIO; --NOVO EM 10/5/21

----------------------------------------------------------ultimo dia
--ultimo registro e o tipo_dia igual ainda
ELSIF C2.DIA_CICLO_ESCALA = C1.QTD_DIAS_ESCALA AND C2.TIPO_DIA = vTIPO_DIA 
AND C2.COD_HORARIO = vCOD_HORARIO  --novo em 10/5/21
THEN
vQTD_DIA := vQTD_DIA + 1;--novo em 26/3/21
vCOMPRIMENTO := vCOMPRIMENTO ||'|'|| vQTD_DIA ||'|'|| vTIPO_DIA ;
--dbms_output.put_line('3.1-vCOMPRIMENTO: '||vCOMPRIMENTO);

--e COD_HORARIO DIFERENTE--novo em 10/5/21
ELSIF C2.DIA_CICLO_ESCALA = C1.QTD_DIAS_ESCALA AND C2.TIPO_DIA = vTIPO_DIA
AND C2.COD_HORARIO <> vCOD_HORARIO  --novo em 10/5/21
THEN
vQTD_DIA := vQTD_DIA + 1;--novo em 26/3/21
vCOMPRIMENTO := vCOMPRIMENTO ||'|0|F|'|| SUBSTR(vCOMPRIMENTO, length(vCOMPRIMENTO)-23, length(vCOMPRIMENTO)) ||'|'||  vQTD_DIA ||'|'|| vTIPO_DIA ;
--dbms_output.put_line('3.2-vCOMPRIMENTO: '||vCOMPRIMENTO);

--ultimo registro e o tipo_dia diferente
ELSIF C2.DIA_CICLO_ESCALA = C1.QTD_DIAS_ESCALA AND C2.TIPO_DIA <> vTIPO_DIA THEN
--dbms_output.put_line('3.3-A-vCOMPRIMENTO: '||vCOMPRIMENTO);
vCOMPRIMENTO := vCOMPRIMENTO ||'|'|| vQTD_DIA ||'|'|| vTIPO_DIA ||'|'|| C2.MARCACAO1 ||'|'|| C2.MARCACAO2 ||'|'|| C2.MARCACAO3 ||'|'|| C2.MARCACAO4||'|'|| '1' ||'|'|| C2.TIPO_DIA ;
--dbms_output.put_line('3.3-D-vCOMPRIMENTO: '||vCOMPRIMENTO);


END IF;     


END LOOP;--C2
dbms_output.put_line('FINAL       : '||vCOMPRIMENTO);
dbms_output.put_line('---------------------------------------------------------------------------------------------------------------------------------------------------------------------');
UPDATE PONTO_ELETRONICO.IFPONTO_ESCALA_PADRAO SET COMPRIMENTO = vCOMPRIMENTO WHERE CODIGO = C1.COD_ESCALA_PADRAO;COMMIT;
vCOMPRIMENTO := NULL;
vTIPO_DIA := NULL;

END LOOP;--C1


END;

END;