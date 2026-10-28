# %%
import pandas as pd
import sqlalchemy


# %%
# Função para ler meu arquivo SQL
def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query


# Carrego a minha query do arquivo externo
query = import_query("life_cycle.sql")

# Minhas conexões com o banco da aplicação e o banco analítico
engine_app = sqlalchemy.create_engine("sqlite:///../../data/loyalt_system/database.db")
engine_analytical = sqlalchemy.create_engine(
    "sqlite:///../../data/analytics/database.db"
)

# %%
# Minha lista de datas de referência para rodar o loop
dates = [
    "2024-05-01",
    "2024-06-01",
    "2024-07-01",
    "2024-08-01",
    "2024-09-01",
    "2024-10-01",
    "2024-11-01",
    "2024-12-01",
    "2025-01-01",
    "2025-02-01",
    "2025-03-01",
    "2025-04-01",
    "2025-05-01",
    "2025-06-01",
    "2025-07-01",
    "2025-08-01",
    "2025-09-01",
    "2025-10-01",
    "2025-11-01",
    "2025-12-01",
    "2026-01-01",
    "2026-02-01",
    "2026-03-01",
    "2026-04-01",
    "2026-05-01",
    "2026-06-01",
    "2026-07-01",
    "2026-08-01",
    "2026-09-01",
    "2026-10-01",
]

# Passo por cada data, aplico na query e salvo no meu banco analítico
for i in dates:
    print(i)
    query_format = query.format(date=i)
    df = pd.read_sql(query_format, engine_app)
    df.to_sql("life_cycle", engine_analytical, index=False, if_exists="append")

# %%
# Faço uma checagem geral dos dados salvos no banco analítico
check = pd.read_sql(
    """
    SELECT dtRef,
           COUNT(*) AS total,
           SUM(qtdDiasUltTransacao IS NULL) AS ult_null,
           SUM(descLifeCycle IS NULL) AS desc_null
    FROM life_cycle
    GROUP BY dtRef
    ORDER BY dtRef
    """,
    engine_analytical,
)
# Imprimo a verificação para conferir se deu tudo certo
print(check)

# %%
