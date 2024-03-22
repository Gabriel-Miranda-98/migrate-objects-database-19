
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ARTERH"."VIEW_VALE_DADOS_GERAIS" ("rowId", "periodo", "codigoEmpresa", "tipoContrato", "codigoContrato", "nome", "email", "emailGestor", "saldoDevedor", "qtdDiasValeDeCaleMes", "qtdOcorrenciasFreq", "qtdDiasDireito", "qtdDiasPagos", "valorJaDescontado", "saldoAtualizadoINPC", "valorDiasPagos", "valorDeDireito") AS 
  ( SELECT "rowId","periodo","codigoEmpresa","tipoContrato","codigoContrato","nome","email","emailGestor","saldoDevedor","qtdDiasValeDeCaleMes","qtdOcorrenciasFreq","qtdDiasDireito","qtdDiasPagos","valorJaDescontado","saldoAtualizadoINPC","valorDiasPagos","valorDeDireito" FROM (SELECT
            vale.rowid as "rowId",
            vale.periodo AS "periodo",
            vale.codigo_empresa AS "codigoEmpresa",
            vale.tipo_contrato AS "tipoContrato",
            vale.codigo_contrato AS "codigoContrato",
            vale.nome AS "nome",
            COALESCE(trim(c.e_mail), trim(pp.ender_eletronico)) AS "email",
            COALESCE(trim(GES.e_mail), trim(PPGES.ender_eletronico)) AS "emailGestor",
            vale.saldo_devedor AS "saldoDevedor",
            (
                SELECT
                    SUM(qtd_trablho_mes_vale)
                FROM
                    arterh.smarh_int_recalculo_vale p
                WHERE
                    p.codigo_contrato = vale.codigo_contrato
                    AND p.tipo_contrato = vale.tipo_contrato
                    AND p.codigo_empresa = vale.codigo_empresa
                    AND p.data_calculo_folha BETWEEN TO_DATE('01/08/2018', 'dd/mm/yyyy') AND TO_DATE('31/12/2018', 'dd/mm/yyyy')
            ) AS "qtdDiasValeDeCaleMes",
            (
                SELECT
                    COUNT(1)
                FROM
                    arterh.smarh_int_ocorrencia_freq f
                WHERE
                    f.codigo_contrato = vale.codigo_contrato
                    AND f.tipo_contrato = vale.tipo_contrato
                    AND f.codigo_empresa = vale.codigo_empresa
                    AND f.data_ocorrencia BETWEEN TO_DATE('01/08/2018', 'dd/mm/yyyy') AND TO_DATE('31/12/2018', 'dd/mm/yyyy')
            ) AS "qtdOcorrenciasFreq",
            total_dias_de_direito AS "qtdDiasDireito",
            total_dias_pago AS "qtdDiasPagos",
            valor_descontado AS "valorJaDescontado",
           vale.saldo_devedor_inpc AS "saldoAtualizadoINPC",
            (
                SELECT
                    SUM(valor_pago)
                FROM
                    arterh.smarh_int_recalculo_vale p
                WHERE
                    p.codigo_contrato = vale.codigo_contrato
                    AND p.tipo_contrato = vale.tipo_contrato
                    AND p.codigo_empresa = vale.codigo_empresa
                    AND p.data_calculo_folha BETWEEN TO_DATE('01/08/2018', 'dd/mm/yyyy') AND TO_DATE('31/12/2018', 'dd/mm/yyyy')
            ) AS "valorDiasPagos",
            vl.valor_dias_de_direito AS "valorDeDireito"
        FROM
            arterh.rhpbh_vale_totalizador vale
            LEFT OUTER JOIN arterh.rhpess_contrato c ON c.codigo = vale.codigo_contrato
                AND c.tipo_contrato = vale.tipo_contrato
                AND c.codigo_empresa = vale.codigo_empresa
            LEFT OUTER JOIN arterh.rhpess_pessoa p ON p.codigo_empresa = c.codigo_empresa
                AND p.codigo = c.codigo_pessoa
            LEFT OUTER JOIN arterh.rhpess_endereco_p pp ON pp.codigo_pessoa = p.codigo
                AND pp.codigo_empresa = p.codigo_empresa
            LEFT OUTER JOIN (
                SELECT
                    sum(vl.valor_dias_de_direito) AS valor_dias_de_direito,
                    vl.codigo_contrato,
                    vl.codigo_empresa,
                    vl.tipo_contrato 
                FROM
                    ARTERH.VIEW_TOTAL_DIAS_DIRETIRO_VALE_RECALCULO VL
                WHERE
                    VL.data_calculo_folha BETWEEN TO_DATE('01/08/2018', 'dd/mm/yyyy') AND TO_DATE('31/12/2018', 'dd/mm/yyyy')
                GROUP BY
                    vl.codigo_contrato,
                    vl.codigo_empresa,
                    vl.tipo_contrato
            ) vl ON vl.codigo_empresa = vale.codigo_empresa
                AND vl.tipo_contrato = vale.tipo_contrato
                AND vl.codigo_contrato = vale.codigo_contrato
           LEFT OUTER JOIN ARTERH.rhorga_custo_geren G 
           ON G.CODIGO_EMPRESA=C.CODIGO_EMPRESA
           AND g.cod_cgerenc1=C.cod_custo_gerenc1
           AND g.cod_cgerenc2=C.cod_custo_gerenc2
           AND g.cod_cgerenc3=C.cod_custo_gerenc3
           AND g.cod_cgerenc4=C.cod_custo_gerenc4
           AND g.cod_cgerenc5=C.cod_custo_gerenc5
           AND g.cod_cgerenc6=C.cod_custo_gerenc6
          LEFT OUTER JOIN (SELECT * FROM ARTERH.RHPESS_CONTRATO C WHERE C.ANO_MES_REFERENCIA=(SELECT MAX(AUX.ANO_MES_REFERENCIA) FROM 
           ARTERH.RHPESS_CONTRATO AUX WHERE AUX.CODIGO=C.CODIGO AND AUX.TIPO_CONTRATO=C.TIPO_CONTRATO AND AUX.CODIGO_EMPRESA=C.CODIGO_EMPRESA)
           )GES
           ON GES.CODIGO=G.CONTRATO_RESP
           AND GES.TIPO_CONTRATO=G.TIPO_CONT_RESP
           AND GES.CODIGO_EMPRESA=G.COD_EMPRESA_PESS
           INNER JOIN ARTERH.RHPESS_PESSOA PGES
           ON PGES.CODIGO_EMPRESA=GES.CODIGO_EMPRESA
           AND PGES.CODIGO=GES.CODIGO_PESSOA
           LEFT OUTER JOIN arterh.rhpess_endereco_p ppGES ON ppGES.codigo_pessoa = PGES.codigo
                AND ppGES.codigo_empresa = PGES.codigo_empresa
        WHERE
            c.ano_mes_referencia = (
                SELECT
                    MAX(aux.ano_mes_referencia)
                FROM
                    arterh.rhpess_contrato aux
                WHERE
                    aux.codigo = c.codigo
                    AND aux.codigo_empresa = c.codigo_empresa
                    AND aux.tipo_contrato = c.tipo_contrato
            )
            and TO_DATE(vale.data_inic_desconto)=TO_DATE('25/07/2023')
            and notificado is null
            )x
            WHERE "qtdDiasValeDeCaleMes" is not null)