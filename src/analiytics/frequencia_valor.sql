SELECT  idCliente,
        count (DISTINCT substr(DtCriacao,0 ,11)) AS qtdeFrequencia,
        sum (CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdePontosPos,
        sum (abs(QtdePontos)) AS qtdePontosAbs

FROM transacoes
WHERE dtCriacao < '2026-09-01'
AND DtCriacao > date(dtCriacao, '-28 days')
GROUP BY 1
ORDER BY DtCriacao DESC;
