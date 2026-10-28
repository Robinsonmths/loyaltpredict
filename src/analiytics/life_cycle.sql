-- Crio uma CTE para listar os dias únicos em que cada cliente realizou transações até a data de referência
WITH tb_daily AS (
    SELECT  
            DISTINCT
            IdCliente,
            substr(DtCriacao,0,11) AS dtDia
    FROM transacoes
    WHERE DtCriacao <= '{date}'
),

-- Calculo a idade da primeira e da última transação em relação à data de referência
tb_idade AS (
    SELECT  IdCliente,
            cast(max(julianday('{date}') - julianday(dtDia)) AS int) AS qtdDiasPrimTransacao,
            cast(min(julianday('{date}') - julianday(dtDia)) AS int) AS qtdDiasUltTransacao
    FROM tb_daily
    GROUP BY IdCliente
),

-- Ordeno os dias de transação de cada cliente do mais recente para o mais antigo para encontrar a penúltima ativação
tb_rn AS (
    SELECT *,
           row_number() OVER (PARTITION BY IdCliente ORDER BY dtDia DESC) AS rnDia
    FROM tb_daily
),

-- Filtro apenas a penúltima ativação (segunda linha mais recente) de cada cliente
tb_penultima_ativacao AS (
        SELECT IdCliente,
                dtDia,
                CAST(julianday('{date}') - julianday(dtDia) AS INT) AS qtdDiasPenulTransacao
        FROM tb_rn
        WHERE rnDia = 2
),

-- Cruzamento final para classificar cada cliente em uma categoria de ciclo de vida com base nos intervalos de dias
tb_life_cicle AS (
    SELECT  t1.*,
            t2.qtdDiasPenulTransacao,
            CASE
                    WHEN t1.qtdDiasPrimTransacao <= 7 THEN '01-CURIOSO'
                    WHEN t1.qtdDiasUltTransacao <= 7 AND (t2.qtdDiasPenulTransacao - t1.qtdDiasUltTransacao) <= 14 THEN '02-FIEL'
                    WHEN t1.qtdDiasUltTransacao BETWEEN 8 AND 14 THEN '03-TURISTA'
                    WHEN t1.qtdDiasUltTransacao BETWEEN 15 AND 28 THEN '04-DESENCANTADA'
                    WHEN t1.qtdDiasUltTransacao >= 28 THEN '05-ZUMBI'
                    WHEN t1.qtdDiasUltTransacao <= 7 AND (t2.qtdDiasPenulTransacao - t1.qtdDiasUltTransacao) BETWEEN 15 AND 27 THEN '02-RECONQUISTADO'
                    WHEN t1.qtdDiasUltTransacao <= 7 AND (t2.qtdDiasPenulTransacao - t1.qtdDiasUltTransacao) > 28 THEN '06-REBORN'
            END AS descLifeCycle
    FROM tb_idade AS t1
    LEFT JOIN tb_penultima_ativacao AS t2
    ON t1.IdCliente = t2.IdCliente
)

-- Seleciono o resultado final adicionando a coluna 'dtRef' com o dia anterior à data de referência
SELECT 
        date('{date}', '-1 day')dtRef,*
FROM tb_life_cicle;