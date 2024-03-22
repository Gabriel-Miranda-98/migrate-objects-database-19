
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."FU_CALCULA_IDADE" (DATA_NASCIMENTO DATE, DATA_REFERENCIA DATE DEFAULT NULL)
RETURN TABLE_LINHA
PIPELINED IS
DATA_ATUAL DATE;
ANOS NUMBER;
MESES NUMBER;
DIAS NUMBER;
RETORNO VARCHAR2(100);
out_rec REG_LINHA := reg_LINHA(NULL,NULL,NULL,NULL);
rel_tab Table_linha;
BEGIN

IF DATA_REFERENCIA IS NOT NULL THEN
   DATA_ATUAL := DATA_REFERENCIA;
ELSE
   DATA_ATUAL := TRUNC(SYSDATE);
END IF;

IF DATA_NASCIMENTO IS NOT NULL THEN
BEGIN
ANOS := trunc(MONTHS_BETWEEN(DATA_ATUAL, DATA_NASCIMENTO)/12);
MESES := trunc(((MONTHS_BETWEEN(DATA_ATUAL, DATA_NASCIMENTO)) - (12*ANOS)));
DIAS := (Trunc(DATA_ATUAL - ADD_MONTHS( DATA_NASCIMENTO, (ANOS * 12) + MESES )));

dbms_output.put_line('ANOS = ' || ANOS || ' MESES = ' || MESES || ' DIAS = ' || DIAS);
RETORNO := CASE WHEN ANOS > 0 THEN
             CASE WHEN MESES > 0 THEN
                    CASE WHEN DIAS > 0 THEN ANOS ||'a' || MESES ||'m' || DIAS ||'d'
                    END
                  ELSE
                    CASE WHEN DIAS > 0 THEN ANOS ||'a' || DIAS ||'d'
                         ELSE ANOS ||'a'
                    END                
             END
             ELSE
             CASE WHEN MESES > 0 THEN
                       CASE WHEN DIAS > 0 THEN MESES ||'m' || DIAS ||'d'
                       END
                  ELSE
                      CASE WHEN DIAS > 0 THEN DIAS ||'d'
                      END
             END
        END;
EXCEPTION
WHEN OTHERS THEN
RETORNO := 'ERRO';
END;
END IF;

out_rec.CODIGO_EMPRESA := null;
out_rec.TIPO_CONTRATO := null;
out_rec.CODIGO_CONTRATO := null;
out_rec.LINHA := RETORNO;

rel_tab := TABLE_LINHA();
rel_tab.extend(1);
rel_tab(rel_tab.last) := out_rec;
PIPE ROW(rel_tab(1));
return;

END;