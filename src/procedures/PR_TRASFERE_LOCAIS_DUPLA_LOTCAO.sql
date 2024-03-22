
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_TRASFERE_LOCAIS_DUPLA_LOTCAO" AS
    CONT NUMBER :=0;
    V_CODIGO_GRUPO_RES CONSTANT CHAR(4):='1000';
    V_CODIGO_EMPRESA_CONST CONSTANT CHAR(4):='0001';
    V_TIPO_AGRUP_CONST CONSTANT char(1):='G';
    REC_CUST rhorga_custo_geren%ROWTYPE;
BEGIN 

FOR C1 IN (

SELECT
    x.*,
    ag.cod_agrup1_orig,
    ag.cod_agrup2_orig,
    ag.cod_agrup3_orig,
    ag.cod_agrup4_orig,
    ag.cod_agrup5_orig,
    ag.cod_agrup6_orig,
    ag.cod_agrup1_dest,
    ag.cod_agrup2_dest,
    ag.cod_agrup3_dest,
    ag.cod_agrup4_dest,
    ag.cod_agrup5_dest,
    ag.cod_agrup6_dest,
    g.cod_cgerenc1, 
    g.cod_cgerenc2,
    g.cod_cgerenc3,
    g.cod_cgerenc4,
    g.cod_cgerenc5,
    g.cod_cgerenc6,
    new_DL.CHAVE_SAUDE AS CHAVE_SAUDE,
    G.ROWID AS CHAVE_TABELA_CUSTO

FROM
    (
        SELECT
            codigo_grupo,
            codigo,
            descricao,
            cod_tab_conv_agrup
        FROM
            arterh.rhcged_ed_tran_col
        WHERE
                codigo_grupo = V_CODIGO_GRUPO_RES
            AND codigo = (
                SELECT
                    MAX(codigo)
                FROM
                    arterh.rhcged_ed_tran_col aux
                WHERE
                    aux.codigo_grupo = V_CODIGO_GRUPO_RES
            )
    )                  x
    LEFT OUTER JOIN rhcged_it_conv_agr ag 
    ON ag.codigo_empresa = V_CODIGO_EMPRESA_CONST
    AND ag.tipo_agrup = V_TIPO_AGRUP_CONST
    AND ag.codigo_conversao = x.cod_tab_conv_agrup
    LEFT OUTER JOIN arterh.view_integracao_dupla_lotacao OLD_DL
    ON OLD_DL.COD_UNIDADE1=ag.cod_agrup1_orig
    AND OLD_DL.COD_UNIDADE2=ag.cod_agrup2_orig
    AND OLD_DL.COD_UNIDADE3=ag.cod_agrup3_orig
    AND OLD_DL.COD_UNIDADE4=ag.cod_agrup4_orig
    AND OLD_DL.COD_UNIDADE5=ag.cod_agrup5_orig
    AND OLD_DL.COD_UNIDADE6=ag.cod_agrup6_orig
    LEFT OUTER JOIN arterh.view_integracao_dupla_lotacao new_DL
    ON new_DL.COD_UNIDADE1=ag.cod_agrup1_dest
    AND new_DL.COD_UNIDADE2=ag.cod_agrup2_dest
    AND new_DL.COD_UNIDADE3=ag.cod_agrup3_dest
    AND new_DL.COD_UNIDADE4=ag.cod_agrup4_dest
    AND new_DL.COD_UNIDADE5=ag.cod_agrup5_dest
    AND new_DL.COD_UNIDADE6=ag.cod_agrup6_dest
   LEFT OUTER JOIN   ARTERH.rhorga_custo_geren G
    ON G.CODIGO_EMPRESA=AG.CODIGO_EMPRESA
    AND G.COD_CGERENC_SUP1=OLD_DL.COD_UNIDADE1
    AND G.COD_CGERENC_SUP2=OLD_DL.COD_UNIDADE2
    AND G.COD_CGERENC_SUP3=OLD_DL.COD_UNIDADE3
    AND G.COD_CGERENC_SUP4=OLD_DL.COD_UNIDADE4
    AND G.COD_CGERENC_SUP5=OLD_DL.COD_UNIDADE5
    AND G.COD_CGERENC_SUP6=OLD_DL.COD_UNIDADE6
   -- WHERE ROWNUM <=1
)LOOP
CONT:=CONT+1;
--DBMS_OUTPUT.PUT_LINE(V_DADOS);
SELECT * INTO REC_CUST FROM ARTERH.rhorga_custo_geren WHERE ROWID = C1.CHAVE_TABELA_CUSTO;
REC_CUST.cod_cgerenc5 := C1.chave_saude;
REC_CUST.COD_CGERENC_SUP1:=C1.cod_agrup1_dest;
REC_CUST.COD_CGERENC_SUP2:=C1.cod_agrup2_dest;
REC_CUST.COD_CGERENC_SUP3:=C1.cod_agrup3_dest;
REC_CUST.COD_CGERENC_SUP4:=C1.cod_agrup4_dest;
REC_CUST.COD_CGERENC_SUP5:=C1.cod_agrup5_dest;
REC_CUST.COD_CGERENC_SUP6:=C1.cod_agrup6_dest;





DBMS_OUTPUT.PUT_LINE('CODIGO_EMPRESA: ' || REC_CUST.CODIGO_EMPRESA);
DBMS_OUTPUT.PUT_LINE('COD_CGERENC1: ' || REC_CUST.COD_CGERENC1);
DBMS_OUTPUT.PUT_LINE('COD_CGERENC2: ' || REC_CUST.COD_CGERENC2);
DBMS_OUTPUT.PUT_LINE('COD_CGERENC3: ' || REC_CUST.COD_CGERENC3);
DBMS_OUTPUT.PUT_LINE('COD_CGERENC4: ' || REC_CUST.COD_CGERENC4);
DBMS_OUTPUT.PUT_LINE('COD_CGERENC5: ' || REC_CUST.cod_cgerenc5);
DBMS_OUTPUT.PUT_LINE('COD_CGERENC6: ' || REC_CUST.COD_CGERENC6);
DBMS_OUTPUT.PUT_LINE('DESCRICAO: ' || REC_CUST.DESCRICAO);
DBMS_OUTPUT.PUT_LINE('ABREVIACAO: ' || REC_CUST.ABREVIACAO);


DBMS_OUTPUT.PUT_LINE('ID_AGRUP_SUP: ' || REC_CUST.ID_AGRUP_SUP);

UPDATE ARTERH.rhorga_custo_geren SET data_extincao=SYSDATE , LOGIN_USUARIO='INTEGRACAO_DUPLA_LOTACAO', DT_ULT_ALTER_USUA=SYSDATE WHERE ROWID= C1.CHAVE_TABELA_CUSTO;
COMMIT;

INSERT INTO ARTERH.rhorga_custo_geren VALUES REC_CUST;
COMMIT;



END LOOP;
END;

