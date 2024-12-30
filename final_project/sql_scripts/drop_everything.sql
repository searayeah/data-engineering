DROP TABLE IF EXISTS miem_stg_transactions CASCADE;
DROP TABLE IF EXISTS miem_stg_passport_blacklist CASCADE;
DROP TABLE IF EXISTS miem_stg_terminals CASCADE;
DROP TABLE IF EXISTS miem_stg_cards CASCADE;
DROP TABLE IF EXISTS miem_stg_accounts CASCADE;
DROP TABLE IF EXISTS miem_stg_clients CASCADE;

DROP TABLE IF EXISTS miem_dwh_dim_clients CASCADE;
DROP TABLE IF EXISTS miem_dwh_dim_accounts CASCADE;
DROP TABLE IF EXISTS miem_dwh_dim_cards CASCADE;
DROP TABLE IF EXISTS miem_dwh_dim_terminals CASCADE;
DROP TABLE IF EXISTS miem_dwh_dim_clients_stg_del;
DROP TABLE IF EXISTS miem_dwh_dim_accounts_stg_del;
DROP TABLE IF EXISTS miem_dwh_dim_cards_stg_del;
DROP TABLE IF EXISTS miem_dwh_dim_terminals_stg_del;

DROP TABLE IF EXISTS miem_dwh_fact_passport_blacklist CASCADE;
DROP TABLE IF EXISTS miem_dwh_fact_transactions CASCADE;

DROP TABLE IF EXISTS miem_dwh_dim_clients_hist;
DROP TABLE IF EXISTS miem_dwh_dim_accounts_hist;
DROP TABLE IF EXISTS miem_dwh_dim_cards_hist;
DROP TABLE IF EXISTS miem_dwh_dim_terminals_hist;

DROP TABLE IF EXISTS miem_rep_fraud;
