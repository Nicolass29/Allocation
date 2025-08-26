/*

Português

Descrição do processo de rateio 

1.Cálculo das porcentagens

.As views VW_Generic_ShareRate e VW_Generic_ShareRate2 calculam a porcentagem de participação de cada unidade de negócio (UEN).

.Para isso, exporta-se a base de receita, filtrando apenas unidades de negócio recorrentes e, no caso da segunda view, filtrando ainda pela empresa específica (Empresas = 1).

.O resultado é uma tabela com a receita parcial, receita total e a taxa percentual de rateio por mês e unidade de negócio.

2. Armazenamento das porcentagens

A view VW_Generic_ShareFinal consolida os resultados das duas primeiras views, unificando as taxas de rateio 
e adicionando um identificador (SHARE = 1 ou SHARE = 2) para distinguir cada cálculo.

3. Cálculo do rateio nos valores de despesa

As views VW_Generic_ShareAllocation_1 e VW_Generic_ShareAllocation_2 aplicam a taxa de rateio sobre os valores originais das despesas, gerando o valor rateado por unidade de negócio, centro de custo e conta.

A distribuição considera apenas os registros com correspondência entre a flag da despesa (SHARE_TBL DF) e a taxa de rateio (SHARE_TBL VP).

Criação da view final de origem de centros de custo

A view VW_Generic_CC_Origin faz um mapeamento final do rateio, convertendo unidades de negócio e contas em códigos padronizados (CC_DESTINO e CONTAS_DESTINO).

Essa view também agrega os valores rateados, fornecendo o resultado consolidado por centro de custo, conta e mês.


Resumo do fluxo:

Calcular % de participação das unidades de negócio → VW_Generic_ShareRate e VW_Generic_ShareRate2

Consolidar % em uma única view → VW_Generic_ShareFinal

Aplicar % sobre os valores originais → VW_Generic_ShareAllocation_1 e VW_Generic_ShareAllocation_2

Mapear centros de custo e contas finais → VW_Generic_CC_Origin

O resultado final permite analisar de forma detalhada como os valores foram distribuídos mês a mês entre as unidades de negócio, centros de custo e contas, garantindo transparência e rastreabilidade do processo de rateio.


English

Description of the allocation process

1. Calculation of percentages

. The views VW_Generic_ShareRate and VW_Generic_ShareRate2 calculate the participation percentage of each business unit (UEN).

. To do this, the revenue base is exported, filtering only recurring business units, and for the second view, also filtering by a specific company (Empresas = 1).

. The result is a table with partial revenue, total revenue, and the allocation percentage per month and business unit.

2. Storage of percentages

The view VW_Generic_ShareFinal consolidates the results of the first two views, unifying the allocation rates 
and adding an identifier (SHARE = 1 or SHARE = 2) to distinguish each calculation.

3. Allocation calculation on expense values

The views VW_Generic_ShareAllocation_1 and VW_Generic_ShareAllocation_2 apply the allocation rate to the original expense values, generating the allocated value per business unit, cost center, and account.

The distribution only considers records where the expense flag (SHARE_TBL DF) matches the allocation rate (SHARE_TBL VP).

Creation of the final cost center origin view

The view VW_Generic_CC_Origin provides the final mapping of the allocation, converting business units and accounts into standardized codes (CC_DESTINO and CONTAS_DESTINO).

This view also aggregates the allocated values, providing a consolidated result by cost center, account, and month.

Process flow summary:

Calculate business unit participation % → VW_Generic_ShareRate and VW_Generic_ShareRate2

Consolidate % in a single view → VW_Generic_ShareFinal

Apply % to the original values → VW_Generic_ShareAllocation_1 and VW_Generic_ShareAllocation_2

Map final cost centers and accounts → VW_Generic_CC_Origin

The final result allows a detailed analysis of how values were distributed month by month across business units, cost centers, and accounts, ensuring transparency and traceability of the allocation process.










*/
------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE 
VIEW `VW_Generic_ShareRate` AS
    SELECT 
        `c`.`EUN` AS `UEN`,
        SUM(`r`.`Value`) AS `Receita_Parcial`,
        `r`.`Tempo` AS `Tempo`,
        `Total`.`Receita_Total` AS `Receita_Total`,
        ROUND(((SUM(`r`.`Value`) / `Total`.`Receita_Total`) * 100), 2) AS `Taxa_Rateio`
    FROM
        ((`Tbl_Generic_RevenueShare` `r`
        JOIN `Tbl_Generic_CostCenters` `c` 
            ON (`r`.`Centro de Custos` = `c`.`DRE_CCustosKey`))
        JOIN (
            SELECT 
                SUM(`r`.`Value`) AS `Receita_Total`, 
                `r`.`Tempo` AS `Tempo`
            FROM
                (`Tbl_Generic_RevenueShare` `r`
            LEFT JOIN `Tbl_Generic_CostCenters` `c` 
                ON (`r`.`Centro de Custos` = `c`.`DRE_CCustosKey`))
            WHERE
                ((TRIM(UPPER(`c`.`EUN`)) IN ('UNIT_A', 'UNIT_B', 'UNIT_C', 'UNIT_D', 'UNIT_E'))
                    AND (`c`.`RECORRENTE` = 'Sim'))
            GROUP BY `r`.`Tempo`
        ) `Total` 
            ON (`Total`.`Tempo` = `r`.`Tempo`))
    WHERE
        ((TRIM(UPPER(`c`.`EUN`)) IN ('UNIT_A', 'UNIT_B', 'UNIT_C', 'UNIT_D', 'UNIT_E'))
            AND (`c`.`RECORRENTE` = 'Sim'))
    GROUP BY 
        `c`.`EUN`, 
        `r`.`Tempo`;
------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE 
VIEW `VW_Generic_ShareRate2` AS
    SELECT 
        `c`.`EUN` AS `UEN`,
        SUM(`r`.`Value`) AS `Receita_Parcial`,
        `r`.`Tempo` AS `Tempo`,
        `Total`.`Receita_Total` AS `Receita_Total`,
        ROUND(((SUM(`r`.`Value`) / `Total`.`Receita_Total`) * 100), 2) AS `Taxa_Rateio`
    FROM
        ((`Tbl_Generic_RevenueShare` `r`
        JOIN `Tbl_Generic_CostCenters` `c` 
            ON (`r`.`Centro de Custos` = `c`.`DRE_CCustosKey`))
        JOIN (
            SELECT 
                SUM(`r`.`Value`) AS `Receita_Total`, 
                `r`.`Tempo` AS `Tempo`
            FROM
                (`Tbl_Generic_RevenueShare` `r`
            LEFT JOIN `Tbl_Generic_CostCenters` `c` 
                ON (`r`.`Centro de Custos` = `c`.`DRE_CCustosKey`))
            WHERE
                ((TRIM(UPPER(`c`.`EUN`)) IN ('UNIT_A', 'UNIT_B', 'UNIT_C', 'UNIT_D', 'UNIT_E'))
                    AND (`c`.`RECORRENTE` = 'Sim'))
            GROUP BY `r`.`Tempo`
        ) `Total` 
            ON (`Total`.`Tempo` = `r`.`Tempo`))
    WHERE
        ((TRIM(UPPER(`c`.`EUN`)) IN ('UNIT_A', 'UNIT_B', 'UNIT_C', 'UNIT_D', 'UNIT_E'))
                    AND (`r`.`Empresas` = 1)
            AND (`c`.`RECORRENTE` = 'Sim'))
    GROUP BY 
        `c`.`EUN`, 
        `r`.`Tempo`;


------------------------------------------------------------------------------------------------------------------------------------------------------



CREATE 
VIEW `VW_Generic_ShareAllocation_1` AS
    SELECT 
        `br`.`Centro de Custos` AS `Centro de Custos`,
        `br`.Versão AS Versão,
        br.Contas AS Contas,
        CONCAT(br.Contas, 'I') AS AgrupadorInput,
        br.`Contas Destino` AS `Contas Destino`,
        br.Empresas AS Empresas,
        br.Tempo AS Tempo,
        br.Value AS ValorOriginal,
        df.Value AS `SHARE_TBL DF`,
        vp.SHARE AS `SHARE_TBL VP`,
        vp.Taxa_Rateio AS Taxa_Rateio,
        vp.UEN AS UEN,
        (CASE
            WHEN (df.Value = vp.SHARE)
            THEN TRUNCATE((br.Value * (vp.Taxa_Rateio / 100)), 2)
            ELSE 0
        END) AS ValorRateado
    FROM
        ((`Source_ExpenseBase` br
        JOIN `Source_ExpenseFlag` df 
            ON (br.`Centro de Custos` = df.`Centro de Custos`))
        JOIN `VW_Generic_ShareFinal` vp 
            ON ((df.Value = vp.SHARE)
            AND (br.Tempo = vp.Tempo)))
    WHERE
        (df.Value = '1');
------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE 
VIEW `VW_Generic_ShareAllocation_2` AS
    SELECT 
        br.`Centro de Custos` AS `Centro de Custos`,
        br.Versão AS Versão,
        br.Contas AS Contas,
        CONCAT(br.Contas, 'I') AS AgrupadorInput,
        br.`Contas Destino` AS `Contas Destino`,
        br.Empresas AS Empresas,
        br.Tempo AS Tempo,
        br.Value AS ValorOriginal,
        df.Value AS `SHARE_TBL DF`,
        vp.SHARE AS `SHARE_TBL VP`,
        vp.Taxa_Rateio AS Taxa_Rateio,
        vp.UEN AS UEN,
        (CASE
            WHEN (df.Value = vp.SHARE)
            THEN TRUNCATE((br.Value * (vp.Taxa_Rateio / 100)), 2)
            ELSE 0
        END) AS ValorRateado
    FROM
        ((`Tbl_Generic_ExpenseBase` br
        JOIN `Tbl_Generic_ExpenseFlag` df 
            ON (br.`Centro de Custos` = df.`Centro de Custos`))
        JOIN `VW_Generic_ShareFinal` vp 
            ON ((df.Value = vp.SHARE)
            AND (br.Tempo = vp.Tempo))))
    WHERE
        (df.Value = '2');

------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE 
VIEW `VW_Generic_ShareFinal` AS
    SELECT 
        `VW_Generic_ShareRate`.*,
        '1' AS `SHARE`
    FROM
        `VW_Generic_ShareRate`
    UNION 
    SELECT 
        `VW_Generic_ShareRate2`.*,
        '2' AS `SHARE`
    FROM
        `VW_Generic_ShareRate2`;


        CREATE VIEW `VW_Generic_CC_Origin` AS
SELECT  
    UEN,
    `Centro de Custos`, 
    CASE UEN 
        WHEN 'UNIT_A' THEN '000.999.90'
        WHEN 'UNIT_B' THEN '000.999.91'
        WHEN 'UNIT_C' THEN '000.999.92'
        WHEN 'UNIT_D' THEN '000.999.93' 
        ELSE NULL 
    END AS CC_DESTINO, 
    contas,
    CASE contas 
        WHEN 5555 THEN '9.4.2.1.0.99'
        WHEN 6666 THEN '9.4.2.2.0.99'
        WHEN 7777 THEN '9.4.2.6.0.99'
        WHEN 8888 THEN '9.4.3.0.0.99' 
        ELSE NULL 
    END AS CONTAS_DESTINO, 
    empresas,
    Tempo, 
    ValorOriginal,  
    Taxa_Rateio, 
    SUM(ValorRateado) AS VALOR_RATEADO
FROM `VW_Generic_ShareAllocation_1`
GROUP BY 
    Tempo, UEN, `Centro de Custos`, contas, empresas, ValorOriginal, Taxa_Rateio
ORDER BY 
    empresas, UEN, `Centro de Custos`, contas, Tempo;
------------------------------------------------------------------------------------------------------------------------------------------------------
