
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."FU_DIAS_LIQUIDO_AVERB" (
    DIAS_ANOS_REF IN NUMBER,
    DIAS_MES_REF  IN NUMBER,
    DATA_INICIO   IN DATE,
    DATA_FIM      IN DATE,
    FALTA         IN NUMBER
) RETURN TP_DIAS
    PIPELINED
IS
/*OBJETIVO: REALIZAR A CONTAGEM DO TEMPO CONFORME ARTERH
REALIZANDO A CONTAGEM DE 
365 POR 30
365 POR 31
360 POR 30

ALTERAÇÃO: 18/07/2022
AUTORES: 
NOVA VERSÃO:MARCOS PB003529
VERSÃO INICIAL: GABRIEL
*/
    NRO_MESES_LOOP       NUMBER := 0;
    NRO_DIAS             NUMBER := 0;
    NRO_DIAS_FINAL       NUMBER := 0;
    NRO_MESES            NUMBER := 0;
    DIAS_TRABALHADOS     NUMBER := 0;
    DIAS_N_TRABALHADOS   NUMBER := 0;
    DIAS_TRABALHADOS_FIM NUMBER := 0;
    NRO_ANOS             NUMBER := 0;
    NRO_DIAS_LIQUI       NUMBER := 0;
    NRO_DIAS_FIM         NUMBER := 0;
    RET                  TP_VALOR_DIAS;
    DT_FIM               DATE;
    AUX_1                NUMBER := 0;
    AUX                  NUMBER := 0;
    VALID_MES_INICIAL    BOOLEAN := FALSE;
    CONT_INICIO          NUMBER := 0;
    CONT_FIM             NUMBER := 0;
BEGIN
/*necesário realizar a carga da função arterh.VALIDA_ANO_BISEXTO
para produção ou homologação*/

    RET := TP_VALOR_DIAS(NULL, NULL, NULL, NULL);
    NRO_ANOS := TRUNC(EXTRACT(YEAR FROM(DATA_FIM)) - EXTRACT(YEAR FROM(DATA_INICIO)));

    NRO_MESES_LOOP := TRUNC(MONTHS_BETWEEN(DATA_FIM, DATA_INICIO));
    CONT_INICIO := ( 30 - TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'DD') ) + 1;

    CONT_FIM := ( TO_DATE ( DATA_FIM, 'DD/MM/YYYY' ) - TRUNC(TO_DATE(DATA_FIM, 'DD/MM/YYYY'), 'MM') ) + 1;

    IF (
        TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'DD') <> ( '01' )
        AND TO_CHAR(TO_DATE(DATA_FIM, 'DD/MM/YYYY'), 'DD') = ( '01' )
    ) THEN
        AUX_1 := 1;
    ELSIF (
        TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'DD') <> ( '01' )
        AND TO_CHAR(TO_DATE(DATA_FIM, 'DD/MM/YYYY'), 'DD') <> ( '01' )
    ) THEN
        CONT_INICIO := ( 30 - TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'DD') ) + 1;

        IF CONT_INICIO < 0 THEN
            CONT_INICIO := 1;
        END IF;
        CONT_FIM := ( TO_DATE ( DATA_FIM, 'DD/MM/YYYY' ) - TRUNC(TO_DATE(DATA_FIM, 'DD/MM/YYYY'), 'MM') ) + 1;

        IF CONT_INICIO + CONT_FIM >= 30 THEN
            AUX_1 := 0;
        ELSE
            AUX_1 := 1;
        END IF;

    ELSE
        AUX_1 := 0;
    END IF;

    IF DIAS_MES_REF = 31 AND DIAS_ANOS_REF = 365 THEN
    /*ESSA CONTAGEM É REALIZADA EM CONFORMIDADE COM O CÁLCULO DA FACILITA-HCM*/
    NRO_DIAS_LIQUI   := (TRUNC(DATA_FIM           -DATA_INICIO) + 1) - FALTA;
    NRO_ANOS         := TRUNC( NRO_DIAS_LIQUI /DIAS_ANOS_REF);
    NRO_MESES        := TRUNC(mod( NRO_DIAS_LIQUI ,DIAS_ANOS_REF)/30);
    NRO_DIAS_FINAL :=  NRO_DIAS_LIQUI - (365 * NRO_ANOS) - (30 * NRO_MESES) ; 
    ELSIF
        DIAS_MES_REF = 30
        AND DIAS_ANOS_REF = 365
    THEN
        NRO_DIAS_LIQUI := TRUNC(DATA_FIM - DATA_INICIO) + 1;
        IF NRO_DIAS_LIQUI = 365 THEN
            NRO_ANOS := TRUNC((TRUNC(DATA_FIM - DATA_INICIO) + 1) / DIAS_ANOS_REF);

            NRO_MESES := TRUNC(MOD(TRUNC(DATA_FIM - DATA_INICIO) + 1, DIAS_ANOS_REF) / 30);

            NRO_DIAS_FINAL := MOD(MOD(TRUNC(DATA_FIM - DATA_INICIO) + 1, DIAS_ANOS_REF), 30);

        ELSIF NRO_DIAS_LIQUI < 365 THEN
            IF TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'MM/YYYY') = TO_CHAR(TO_DATE(DATA_FIM, 'DD/MM/YYYY'), 'MM/YYYY') THEN
                IF TO_CHAR(EXTRACT(MONTH FROM(DATA_INICIO))) = '2' THEN
                    IF DATA_FIM < LAST_DAY(DATA_FIM) THEN
                        NRO_DIAS_LIQUI := TRUNC(DATA_FIM - DATA_INICIO) + 1;
                        NRO_MESES := TRUNC(MOD(TRUNC(DATA_FIM - DATA_INICIO) + 1, DIAS_ANOS_REF) / 30);

                        NRO_DIAS_FINAL := MOD(MOD(TRUNC(DATA_FIM - DATA_INICIO) + 1, DIAS_ANOS_REF), 30);

                    ELSE
                        IF
                            NRO_DIAS_LIQUI > 28
                            AND ( VALIDA_ANO_BISEXTO(TO_DATE(DATA_INICIO, 'DD/MM/YYYY')) = 'TRUE' )
                        THEN
                            NRO_DIAS_LIQUI := 30;
                        ELSIF (
                            NRO_DIAS_LIQUI = 28
                            AND ( VALIDA_ANO_BISEXTO(TO_DATE(DATA_INICIO, 'DD/MM/YYYY')) = 'FALSE' )
                        ) THEN
                            NRO_DIAS_LIQUI := 30;
                        ELSIF
                            NRO_DIAS_LIQUI < 28
                            AND ( VALIDA_ANO_BISEXTO(TO_DATE(DATA_INICIO, 'DD/MM/YYYY')) = 'TRUE' )
                        THEN
                            NRO_DIAS_LIQUI := NRO_DIAS_LIQUI + 1;
                        ELSIF
                            NRO_DIAS_LIQUI < 28
                            AND ( VALIDA_ANO_BISEXTO(TO_DATE(DATA_INICIO, 'DD/MM/YYYY')) = 'FALSE' )
                        THEN
                            NRO_DIAS_LIQUI := NRO_DIAS_LIQUI + 2;
                        END IF;
            /*RAFAELLA ACRESCENTOU EM 17/08, POIS QUANDO É 30 DIAS, É APENAS UM MES */
                        NRO_DIAS_FINAL := NRO_DIAS_LIQUI;
                        IF NRO_DIAS_FINAL = 30 THEN
                            NRO_DIAS_FINAL := 0;
                            NRO_MESES := 1;
                        ELSE
                            NRO_DIAS_FINAL := NRO_DIAS_LIQUI;
                        END IF;

                    END IF;

                ELSE
                    IF DATA_FIM < LAST_DAY(DATA_FIM) THEN
                        NRO_DIAS_LIQUI := TRUNC(DATA_FIM - DATA_INICIO) + 1;
                        NRO_MESES := TRUNC(MOD(TRUNC(DATA_FIM - DATA_INICIO) + 1, DIAS_ANOS_REF) / 30);

                        NRO_DIAS_FINAL := MOD(MOD(TRUNC(DATA_FIM - DATA_INICIO) + 1, DIAS_ANOS_REF), 30);

                    ELSE
                        IF NRO_DIAS_LIQUI = 31 THEN
                            NRO_DIAS_LIQUI := 30;
                            NRO_MESES := 1;
                            NRO_DIAS_FINAL := 0;
                        END IF;
                    END IF;
                END IF;

            ELSE
    /*> menor QUE 365 DIAS */
                FOR C1 IN 0..NRO_MESES_LOOP + AUX_1 LOOP
                    IF C1 = 0 THEN
                        IF
                            TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') > DIAS_MES_REF
                            AND DATA_FIM > LAST_DAY(DATA_INICIO)
                        THEN
                            DT_FIM := LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)) - 1;
                        ELSIF
                            TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') <= DIAS_MES_REF
                            AND DATA_FIM > LAST_DAY(DATA_INICIO)
                        THEN
                            DT_FIM := LAST_DAY(ADD_MONTHS(DATA_INICIO, C1));
                        ELSE
                            DT_FIM := DATA_FIM;
                        END IF;

                        DIAS_TRABALHADOS := DIAS_TRABALHADOS + ( TRUNC(DT_FIM - ADD_MONTHS(DATA_INICIO, C1) + 1) );

                        IF TO_CHAR(EXTRACT(MONTH FROM(DATA_INICIO))) = '2' THEN
                            IF
                                DIAS_TRABALHADOS > 28
                                AND ( VALIDA_ANO_BISEXTO(TO_DATE(DATA_INICIO, 'DD/MM/YYYY')) = 'TRUE' )
                            THEN
                                DIAS_TRABALHADOS := 30;
                            ELSIF
                                DIAS_TRABALHADOS = 28
                                AND ( VALIDA_ANO_BISEXTO(TO_DATE(DATA_INICIO, 'DD/MM/YYYY')) = 'TRUE' )
                            THEN
                                DIAS_TRABALHADOS := 28;
                            ELSIF
                                DIAS_TRABALHADOS < 28
                                AND ( VALIDA_ANO_BISEXTO(TO_DATE(DATA_INICIO, 'DD/MM/YYYY')) = 'TRUE' )
                            THEN
                                DIAS_TRABALHADOS := ( 30 - TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'DD') ) + 1;
                            ELSIF
                                DIAS_TRABALHADOS = 28
                                AND ( VALIDA_ANO_BISEXTO(TO_DATE(DATA_INICIO, 'DD/MM/YYYY')) = 'FALSE' )
                            THEN
                                DIAS_TRABALHADOS := 30;
                            ELSIF
                                DIAS_TRABALHADOS < 28
                                AND ( VALIDA_ANO_BISEXTO(TO_DATE(DATA_INICIO, 'DD/MM/YYYY')) = 'FALSE' )
                            THEN
                                DIAS_TRABALHADOS := ( 30 - TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'DD') ) + 1;
                            END IF;
                        ELSE
                            IF DIAS_TRABALHADOS = 31 THEN
                                DIAS_TRABALHADOS := 30;
                            ELSE
                                DIAS_TRABALHADOS := DIAS_TRABALHADOS;
                            END IF;
                        END IF;

                    ELSIF C1 = NRO_MESES_LOOP THEN
                        IF DT_FIM <> DATA_FIM THEN
                            DIAS_TRABALHADOS_FIM := ( DIAS_TRABALHADOS_FIM + ( ( TRUNC(DATA_FIM - TRUNC(DATA_FIM, 'MM')) + 1 ) ) );
                        END IF;

                        IF TO_CHAR(EXTRACT(MONTH FROM(DATA_FIM))) = '2' THEN
                            IF
                                DIAS_TRABALHADOS_FIM > 28
                                AND ( VALIDA_ANO_BISEXTO(TO_DATE(DATA_FIM, 'DD/MM/YYYY')) = 'TRUE' )
                            THEN
                                DIAS_TRABALHADOS_FIM := 30;
                            ELSIF
                                DIAS_TRABALHADOS_FIM = 28
                                AND ( VALIDA_ANO_BISEXTO(TO_DATE(DATA_FIM, 'DD/MM/YYYY')) = 'TRUE' )
                            THEN
                                DIAS_TRABALHADOS_FIM := 28;
                            ELSIF (
                                DIAS_TRABALHADOS_FIM = 28
                                AND VALIDA_ANO_BISEXTO(TO_DATE(DATA_FIM, 'DD/MM/YYYY')) = 'FALSE'
                            ) THEN
                                DIAS_TRABALHADOS_FIM := 30;
                            END IF;

                        ELSE
                            IF DIAS_TRABALHADOS_FIM = 31 THEN
                                DIAS_TRABALHADOS_FIM := 30;
                            END IF;
                        END IF;

                    ELSE
                        IF TO_CHAR(TO_DATE(LAST_DAY(ADD_MONTHS(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'),
                                                               C1))), 'DD') = '31' THEN
                            NRO_DIAS := NRO_DIAS + 30;
                        ELSIF TO_CHAR(TO_DATE(LAST_DAY(ADD_MONTHS(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'),
                                                                  C1))), 'DD') = '30' THEN
                            NRO_DIAS := NRO_DIAS + 30;
                        ELSIF TO_CHAR(TO_DATE(LAST_DAY(ADD_MONTHS(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'),
                                                                  C1))), 'DD') = '29' THEN
                            NRO_DIAS := NRO_DIAS + 30;
                        ELSIF TO_CHAR(TO_DATE(LAST_DAY(ADD_MONTHS(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'),
                                                                  C1))), 'DD') = '28' THEN
                            NRO_DIAS := NRO_DIAS + 30;
                        END IF;

                        AUX := AUX + 1;
                    END IF;
                END LOOP;

                IF ( NRO_DIAS + DIAS_TRABALHADOS_FIM + DIAS_TRABALHADOS ) = '360' THEN
                    NRO_DIAS_LIQUI := ( NRO_DIAS + DIAS_TRABALHADOS_FIM + DIAS_TRABALHADOS ) + 5;
                ELSE
                    NRO_DIAS_LIQUI := ( NRO_DIAS + DIAS_TRABALHADOS_FIM + DIAS_TRABALHADOS );
                END IF;

                IF NRO_DIAS_LIQUI = '365' THEN
                    NRO_MESES := 0;
                    NRO_DIAS_FINAL := 0;
                    NRO_ANOS := 1;
                ELSE
                    NRO_ANOS := TRUNC((TRUNC(DATA_FIM - DATA_INICIO) + 1) / DIAS_ANOS_REF);

                    NRO_MESES := TRUNC(MOD(NRO_DIAS_LIQUI, 365) / 30);
                    NRO_DIAS_FINAL := ( NRO_DIAS_LIQUI - ( NRO_MESES * 30 ) - ( NRO_ANOS * 365 ) );

                END IF;

            END IF;
        ELSE
    /*> MAIOR QUE 365 DIAS */
            FOR C1 IN 0..NRO_MESES_LOOP + AUX_1 LOOP
                IF C1 = 0 THEN /* TRATANDO APENAS O PRIMEIRO MÊS*/
                    IF
                        TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') > DIAS_MES_REF
                        AND DATA_FIM > LAST_DAY(DATA_INICIO)
                    THEN
                        DT_FIM := LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)) - 1;
                    ELSIF
                        TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') <= DIAS_MES_REF
                        AND DATA_FIM > LAST_DAY(DATA_INICIO)
                    THEN
                        DT_FIM := LAST_DAY(ADD_MONTHS(DATA_INICIO, C1));
                    ELSE
                        DT_FIM := DATA_FIM;
                    END IF;

                    DIAS_TRABALHADOS := DIAS_TRABALHADOS + ( TRUNC(DT_FIM - ADD_MONTHS(DATA_INICIO, C1) + 1) );

                    IF TO_CHAR(EXTRACT(MONTH FROM(DATA_INICIO))) = '2' THEN
                        IF
                            DIAS_TRABALHADOS > 28
                            AND ( VALIDA_ANO_BISEXTO(TO_DATE(DATA_INICIO, 'DD/MM/YYYY')) = 'TRUE' )
                        THEN
                            DIAS_TRABALHADOS := 30;
                        ELSIF
                            DIAS_TRABALHADOS = 28
                            AND ( VALIDA_ANO_BISEXTO(TO_DATE(DATA_INICIO, 'DD/MM/YYYY')) = 'TRUE' )
                        THEN
                            DIAS_TRABALHADOS := 28;
                        ELSIF
                            DIAS_TRABALHADOS < 28
                            AND ( VALIDA_ANO_BISEXTO(TO_DATE(DATA_INICIO, 'DD/MM/YYYY')) = 'TRUE' )
                        THEN
                            DIAS_TRABALHADOS := ( 30 - TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'DD') ) + 1;
                        ELSIF
                            DIAS_TRABALHADOS = 28
                            AND ( VALIDA_ANO_BISEXTO(TO_DATE(DATA_INICIO, 'DD/MM/YYYY')) = 'FALSE' )
                        THEN
                            DIAS_TRABALHADOS := 30;
                        ELSIF
                            DIAS_TRABALHADOS < 28
                            AND ( VALIDA_ANO_BISEXTO(TO_DATE(DATA_INICIO, 'DD/MM/YYYY')) = 'FALSE' )
                        THEN
                            DIAS_TRABALHADOS := ( 30 - TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'DD') ) + 1; /* TALVEZ AUMENTAR PAR +2 */
                        END IF;
                    ELSE
                        IF DIAS_TRABALHADOS = 31 THEN
                            DIAS_TRABALHADOS := 30;
                        ELSE
                            DIAS_TRABALHADOS := DIAS_TRABALHADOS;
                        END IF;
                    END IF;

                ELSIF C1 = NRO_MESES_LOOP THEN
                    IF DT_FIM <> DATA_FIM THEN
                        DIAS_TRABALHADOS_FIM := ( DIAS_TRABALHADOS_FIM + ( ( TRUNC(DATA_FIM - TRUNC(DATA_FIM, 'MM')) + 1 ) ) );
                    END IF;

                    IF TO_CHAR(EXTRACT(MONTH FROM(DATA_FIM))) = '2' THEN
                        IF
                            DIAS_TRABALHADOS_FIM > 28
                            AND ( VALIDA_ANO_BISEXTO(TO_DATE(DATA_FIM, 'DD/MM/YYYY')) = 'TRUE' )
                        THEN
                            DIAS_TRABALHADOS_FIM := 30;
                        ELSIF
                            DIAS_TRABALHADOS_FIM = 28
                            AND ( VALIDA_ANO_BISEXTO(TO_DATE(DATA_FIM, 'DD/MM/YYYY')) = 'TRUE' )
                        THEN
                            DIAS_TRABALHADOS_FIM := 28;
                        ELSIF (
                            DIAS_TRABALHADOS_FIM = 28
                            AND VALIDA_ANO_BISEXTO(TO_DATE(DATA_FIM, 'DD/MM/YYYY')) = 'FALSE'
                        ) THEN
                            DIAS_TRABALHADOS_FIM := 30;
                        END IF;

                    ELSE
                        IF DIAS_TRABALHADOS_FIM = 31 THEN
                            DIAS_TRABALHADOS_FIM := 30;
                        END IF;
                    END IF;

                ELSE
                    IF TO_CHAR(EXTRACT(MONTH FROM(ADD_MONTHS(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), C1)))) = '2' THEN
                        IF (
                            TO_CHAR(TO_DATE(LAST_DAY(ADD_MONTHS(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'),
                                                                C1))), 'DD') = '28'
                            AND VALIDA_ANO_BISEXTO(ADD_MONTHS(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), C1)) = 'TRUE'
                        ) THEN
                            NRO_DIAS := NRO_DIAS + 28;
                        ELSIF (
                            TO_CHAR(TO_DATE(LAST_DAY(ADD_MONTHS(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'),
                                                                C1))), 'DD') = '28'
                            AND VALIDA_ANO_BISEXTO(ADD_MONTHS(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), C1)) = 'FALSE'
                        ) THEN
                            NRO_DIAS := NRO_DIAS + 30;
                        ELSIF (
                            TO_CHAR(TO_DATE(LAST_DAY(ADD_MONTHS(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'),
                                                                C1))), 'DD') = '29'
                            AND ( VALIDA_ANO_BISEXTO(ADD_MONTHS(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), C1)) = 'TRUE' )
                        ) THEN
                            NRO_DIAS := NRO_DIAS + 30;
                        END IF;

                    ELSE
                        IF TO_CHAR(TO_DATE(LAST_DAY(ADD_MONTHS(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'),
                                                               C1))), 'DD') = '31' THEN
                            NRO_DIAS := NRO_DIAS + 30;
                        ELSIF TO_CHAR(TO_DATE(LAST_DAY(ADD_MONTHS(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'),
                                                                  C1))), 'DD') = '30' THEN
                            NRO_DIAS := NRO_DIAS + 30;
                        END IF;
                    END IF;
                END IF;
            END LOOP;

            NRO_DIAS_LIQUI := ( NRO_DIAS + DIAS_TRABALHADOS_FIM + DIAS_TRABALHADOS );
            NRO_DIAS_LIQUI := ( NRO_DIAS_LIQUI + ( TRUNC(NRO_MESES_LOOP / 12) * 5 ) );
            NRO_MESES := TRUNC(MOD(NRO_DIAS_LIQUI, 365) / 30);
            NRO_ANOS := TRUNC(NRO_MESES_LOOP / 12);
            NRO_DIAS_FINAL := NRO_DIAS_LIQUI - ( 365 * NRO_ANOS ) - ( 30 * NRO_MESES );
        END IF;

    ELSE
  
    /*PARA O CALCULO DOS DIAS CONTEMPLANDO O ANO DE 360 DIAS O SISTEMA CONTABILIZA NO MÁXIMO 30 DIAS DE CADA MÊS */
        DBMS_OUTPUT.PUT_LINE('30/360 --> ' || DT_FIM);
        FOR C1 IN 0..NRO_MESES_LOOP LOOP
            IF C1 = 0 THEN
                IF
                    TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') > DIAS_MES_REF
                    AND DATA_FIM > LAST_DAY(DATA_INICIO)
                THEN
                    DT_FIM := LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)) - 1;
           /*DBMS_OUTPUT.PUT_LINE('IF DENTRO DO C1: 1 '||LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)) - 1);*/
                ELSIF
                    TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') <= DIAS_MES_REF
                    AND DATA_FIM > LAST_DAY(DATA_INICIO)
                THEN
                    DT_FIM := LAST_DAY(ADD_MONTHS(DATA_INICIO, C1));
         /* DBMS_OUTPUT.PUT_LINE('IF DENTRO DO C1: 2 '||LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)));*/
                ELSE
                    DT_FIM := DATA_FIM;
                END IF;

                IF TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'),
                           'DD') IN ( '28', '29' ) THEN
                    DIAS_TRABALHADOS := DIAS_TRABALHADOS + ( TRUNC(DT_FIM - ADD_MONTHS(DATA_INICIO, C1) + 1) );
         /* DBMS_OUTPUT.PUT_LINE('1.0 DIAS_TRABALHADOS =' ||DIAS_TRABALHADOS);*/
                ELSIF TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'DD') = '31' THEN
                    DIAS_TRABALHADOS := DIAS_TRABALHADOS + ( TRUNC(DT_FIM - ADD_MONTHS(DATA_INICIO, C1) + 1) ) + 1;

                    DBMS_OUTPUT.PUT_LINE('2.0 DIAS_TRABALHADOS =' || DIAS_TRABALHADOS);
                ELSE
                    DIAS_TRABALHADOS := DIAS_TRABALHADOS + ( TRUNC(DT_FIM - ADD_MONTHS(DATA_INICIO, C1)) + 1 );
        /*  DBMS_OUTPUT.PUT_LINE('3.0 DIAS_TRABALHADOS  =' ||DIAS_TRABALHADOS);*/
                END IF;

                IF TO_CHAR(EXTRACT(MONTH FROM(DATA_INICIO))) = '2' THEN
                    IF TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'MM/YYYY') = TO_CHAR(TO_DATE(DATA_FIM, 'DD/MM/YYYY'), 'MM/YYYY') THEN
                        IF
                            TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') = '28'
                            AND TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'DD') < '28'
                        THEN
                            NRO_DIAS := 30 - ( TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') - DIAS_TRABALHADOS );
                           /* DBMS_OUTPUT.PUT_LINE('1 ENTRADA FEV' || NRO_DIAS);*/
                        ELSIF
                            TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') = '29'
                            AND TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'DD') < '28'
                        THEN
                            NRO_DIAS := 30 - ( TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') - DIAS_TRABALHADOS );
                          /*  DBMS_OUTPUT.PUT_LINE('2 ENTRADA FEV' || NRO_DIAS);*/
                        ELSE
                            NRO_DIAS := NRO_DIAS + TRUNC(DT_FIM - ADD_MONTHS(DATA_INICIO, C1) + 1);
                          /*  DBMS_OUTPUT.PUT_LINE('3 ENTRADA FEV ' || NRO_DIAS);*/
                        END IF;

                    ELSE
                        IF
                            TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') = '28'
                            AND TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'DD') < '28'
                        THEN
                            NRO_DIAS := 30 - ( TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') - DIAS_TRABALHADOS );
                           /* DBMS_OUTPUT.PUT_LINE('4 ENTRADA FEV' || NRO_DIAS);*/
                        ELSIF
                            TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') = '29'
                            AND TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'DD') < '29'
                        THEN
                            NRO_DIAS := 30 - ( TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') - DIAS_TRABALHADOS );
                           /* DBMS_OUTPUT.PUT_LINE('5 ENTRADA FEV' || NRO_DIAS);*/
                        ELSIF
                            TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') = '28'
                            AND TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'DD') = '28'
                        THEN
                            NRO_DIAS := 30 - ( TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') - DIAS_TRABALHADOS );
                           /* DBMS_OUTPUT.PUT_LINE('6 ENTRADA FEV' || NRO_DIAS);*/
                        ELSIF
                            TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') = '29'
                            AND TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'DD') = '29'
                        THEN
                            NRO_DIAS := 30 - ( TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') - DIAS_TRABALHADOS );
                           /* DBMS_OUTPUT.PUT_LINE('7 ENTRADA FEV' || NRO_DIAS);*/
                        ELSE
                            NRO_DIAS := NRO_DIAS + TRUNC(DT_FIM - ADD_MONTHS(DATA_INICIO, C1) + 1);
                           /* DBMS_OUTPUT.PUT_LINE('8 ENTRADA FEV ' || NRO_DIAS);*/
                        END IF;
                    END IF;
                ELSE /*MESES DIFERENTES DE FEVEREIRO */
                    IF TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'MM/YYYY') = TO_CHAR(TO_DATE(DATA_FIM, 'DD/MM/YYYY'), 'MM/YYYY') THEN
                        IF
                            TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') = '31'
                            AND DIAS_TRABALHADOS >= '30'
                        THEN
                            NRO_DIAS := NRO_DIAS + TRUNC(DT_FIM - ADD_MONTHS(DATA_INICIO, C1));  
                              /*DBMS_OUTPUT.PUT_LINE('1 ENTRADA <> FEV ' || NRO_DIAS);*/
                        ELSIF
                            TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') = '31'
                            AND DIAS_TRABALHADOS < '30'
                        THEN
                            NRO_DIAS := NRO_DIAS + TRUNC(DT_FIM - ADD_MONTHS(DATA_INICIO, C1) + 1);  
                              /*DBMS_OUTPUT.PUT_LINE('2 ENTRADA <> FEV ' || NRO_DIAS);*/
                        ELSIF
                            TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') = '31'
                            AND TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'DD') = '31'
                        THEN
                            NRO_DIAS := NRO_DIAS + TRUNC(DT_FIM - ADD_MONTHS(DATA_INICIO, C1) + 1);                  
                              /*DBMS_OUTPUT.PUT_LINE('3 ENTRADA <> FEV ' || NRO_DIAS);                                      */
                        ELSE
                            NRO_DIAS := NRO_DIAS + TRUNC(DT_FIM - ADD_MONTHS(DATA_INICIO, C1) + 1);
                              /*DBMS_OUTPUT.PUT_LINE('4 ENTRADA <> FEV  ' || NRO_DIAS);*/
                        END IF;

                    ELSE
                        IF
                            TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') = '31'
                            AND TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'DD') < '30'
                        THEN
                            NRO_DIAS := NRO_DIAS + TRUNC(DT_FIM - ADD_MONTHS(DATA_INICIO, C1) + 1);  
                              /*DBMS_OUTPUT.PUT_LINE('5 ENTRADA <> FEV ' || NRO_DIAS);*/
                        ELSIF TO_CHAR(LAST_DAY(ADD_MONTHS(DATA_INICIO, C1)), 'DD') = '31' THEN
                            NRO_DIAS := NRO_DIAS + TRUNC(DT_FIM - ADD_MONTHS(DATA_INICIO, C1) + 1) + 1;                  
                              /*DBMS_OUTPUT.PUT_LINE('6 ENTRADA <> FEV ' || NRO_DIAS);                                      */
                        ELSE
                            NRO_DIAS := NRO_DIAS + TRUNC(DT_FIM - ADD_MONTHS(DATA_INICIO, C1) + 1);
                              /*DBMS_OUTPUT.PUT_LINE('7 ENTRADA <> FEV  ' || NRO_DIAS);*/
                        END IF;
                    END IF;
                END IF;

            ELSIF C1 = NRO_MESES_LOOP THEN
                IF DT_FIM <> DATA_FIM THEN
                    DIAS_TRABALHADOS_FIM := ( DIAS_TRABALHADOS_FIM + ( ( TRUNC(DATA_FIM - TRUNC(DATA_FIM, 'MM')) + 1 ) ) );
              /*   DBMS_OUTPUT.PUT_LINE('DIAS_TRABALHADOS_FIM: ' ||DIAS_TRABALHADOS_FIM);*/
                    IF
                        DIAS_TRABALHADOS_FIM = '28'
                        AND TO_CHAR(EXTRACT(MONTH FROM(DATA_FIM))) = '2'
                    THEN
                        NRO_DIAS := ( NRO_DIAS + ( ( TRUNC(DATA_FIM - TRUNC(DATA_FIM, 'MM')) + 1 ) ) ) + 2;
               /*   DBMS_OUTPUT.PUT_LINE('ULTIMO MES 1 ' || NRO_DIAS);*/
                    ELSIF
                        DIAS_TRABALHADOS_FIM = '29'
                        AND TO_CHAR(EXTRACT(MONTH FROM(DATA_FIM))) = '2'
                    THEN
                        NRO_DIAS := ( NRO_DIAS + ( ( TRUNC(DATA_FIM - TRUNC(DATA_FIM, 'MM')) + 1 ) ) ) + 1;
              /*   DBMS_OUTPUT.PUT_LINE('ULTIMO MES 2 ' || NRO_DIAS);*/
                    ELSIF
                        DIAS_TRABALHADOS_FIM = '31'
                        AND TO_CHAR(EXTRACT(MONTH FROM(DATA_FIM))) <> '2'
                    THEN
                        NRO_DIAS := ( NRO_DIAS + ( ( TRUNC(DATA_FIM - TRUNC(DATA_FIM, 'MM')) ) ) );
                /* DBMS_OUTPUT.PUT_LINE('ULTIMO MES 3 ' || NRO_DIAS);*/
                    ELSE
                        NRO_DIAS := ( NRO_DIAS + ( ( TRUNC(DATA_FIM - TRUNC(DATA_FIM, 'MM')) + 1 ) ) );
               /*  DBMS_OUTPUT.PUT_LINE('ULTIMO MES 4 ' || NRO_DIAS);*/
                    END IF;

                END IF;
            END IF;

            IF 
                DIAS_MES_REF = 30
                AND NRO_MESES_LOOP = 0
                AND ( TO_CHAR(TO_DATE(DATA_INICIO, 'DD/MM/YYYY'), 'MM/YYYY') <> TO_CHAR(TO_DATE(DATA_FIM, 'DD/MM/YYYY'), 'MM/YYYY') )
            THEN
                NRO_DIAS := ( NRO_DIAS + ( ( TRUNC(DATA_FIM - TRUNC(DATA_FIM, 'MM')) + 1 ) ) );
       /* DBMS_OUTPUT.PUT_LINE('MES ENTRE INICIO E FIM -->' || NRO_DIAS);*/
            END IF;

        END LOOP;

        IF
            DIAS_MES_REF != 31
            AND DATA_FIM > LAST_DAY(DATA_INICIO)
        THEN
            NRO_DIAS := NRO_DIAS + ( ROUND(MONTHS_BETWEEN(LAST_DAY(ADD_MONTHS(DATA_FIM, -1)), TRUNC(ADD_MONTHS(DATA_INICIO, 1), 'MM')
            )) * DIAS_MES_REF );
        END IF;

        NRO_DIAS_LIQUI := NRO_DIAS;
        NRO_DIAS := MOD(NRO_DIAS, DIAS_ANOS_REF);
        NRO_ANOS := TRUNC(NRO_DIAS_LIQUI / DIAS_ANOS_REF);
        NRO_MESES := TRUNC(MOD(NRO_DIAS_LIQUI, DIAS_ANOS_REF) / DIAS_MES_REF);
        NRO_DIAS_FINAL := MOD(NRO_DIAS, DIAS_MES_REF);
    END IF;

    RET.QTD_DIAS := NRO_DIAS_FINAL;
    RET.QTD_MESES := NRO_MESES;
    RET.QTD_ANOS := NRO_ANOS;
    RET.QTD_DIAS_LIQUIDOS := NRO_DIAS_LIQUI;
    PIPE ROW ( RET );
    RETURN;
END;