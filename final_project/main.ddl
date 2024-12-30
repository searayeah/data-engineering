-- ##########
-- STG TABLES
-- ##########

-- Временная таблица клиентов
CREATE TABLE IF NOT EXISTS miem_stg_clients (
    client_id VARCHAR PRIMARY KEY
    , last_name VARCHAR
    , first_name VARCHAR
    , patronymic VARCHAR
    , date_of_birth DATE
    , passport_num VARCHAR
    , passport_valid_to DATE
    , phone VARCHAR
    , create_dt TIMESTAMP
    , update_dt TIMESTAMP
);

-- Временная таблица счетов
CREATE TABLE IF NOT EXISTS miem_stg_accounts (
    account VARCHAR PRIMARY KEY
    , valid_to DATE
    , client VARCHAR REFERENCES miem_stg_clients (client_id)
    , create_dt TIMESTAMP
    , update_dt TIMESTAMP
);

-- Временная таблица карт
CREATE TABLE IF NOT EXISTS miem_stg_cards (
    card_num VARCHAR PRIMARY KEY
    , account VARCHAR REFERENCES miem_stg_accounts (account)
    , create_dt TIMESTAMP
    , update_dt TIMESTAMP
);

-- Временная таблица для терминалов
CREATE TABLE IF NOT EXISTS miem_stg_terminals (
    terminal_id VARCHAR PRIMARY KEY
    , terminal_type VARCHAR
    , terminal_city VARCHAR
    , terminal_address VARCHAR
    , create_dt TIMESTAMP
    , update_dt TIMESTAMP
);

-- Временная таблица для черного списка паспортов
CREATE TABLE IF NOT EXISTS miem_stg_passport_blacklist (
    passport_num VARCHAR PRIMARY KEY
    , entry_dt TIMESTAMP
);

-- Временная таблица для транзакций
CREATE TABLE IF NOT EXISTS miem_stg_transactions (
    trans_id VARCHAR PRIMARY KEY
    , trans_date TIMESTAMP
    , card_num VARCHAR REFERENCES miem_stg_cards (card_num)
    , oper_type VARCHAR
    , amt DECIMAL
    , oper_result VARCHAR
    , terminal VARCHAR REFERENCES miem_stg_terminals (terminal_id)
);


-- ##########
-- DIM SCD1 TABLES
-- ##########

-- Таблица клиентов
CREATE TABLE IF NOT EXISTS miem_dwh_dim_clients (
    client_id VARCHAR PRIMARY KEY
    , last_name VARCHAR
    , first_name VARCHAR
    , patronymic VARCHAR
    , date_of_birth DATE
    , passport_num VARCHAR
    , passport_valid_to DATE
    , phone VARCHAR
    , create_dt TIMESTAMP
    , update_dt TIMESTAMP
);

-- Таблица счетов
CREATE TABLE IF NOT EXISTS miem_dwh_dim_accounts (
    account VARCHAR PRIMARY KEY
    , valid_to DATE
    , client VARCHAR REFERENCES miem_dwh_dim_clients (client_id)
    , create_dt TIMESTAMP
    , update_dt TIMESTAMP
);

-- Таблица карт
CREATE TABLE IF NOT EXISTS miem_dwh_dim_cards (
    card_num VARCHAR PRIMARY KEY
    , account VARCHAR REFERENCES miem_dwh_dim_accounts (account)
    , create_dt TIMESTAMP
    , update_dt TIMESTAMP

);

-- Таблица для терминалов
CREATE TABLE IF NOT EXISTS miem_dwh_dim_terminals (
    terminal_id VARCHAR PRIMARY KEY
    , terminal_type VARCHAR
    , terminal_city VARCHAR
    , terminal_address VARCHAR
    , create_dt TIMESTAMP
    , update_dt TIMESTAMP
);

-- ##########
-- FACT TABLES
-- ##########

-- FACT таблица для черного списка паспортов
CREATE TABLE IF NOT EXISTS miem_dwh_fact_passport_blacklist (
    passport_num VARCHAR
    , entry_dt TIMESTAMP
);

-- FACT таблица для транзакций
CREATE TABLE IF NOT EXISTS miem_dwh_fact_transactions (
    trans_id VARCHAR PRIMARY KEY
    , trans_date TIMESTAMP
    , card_num VARCHAR REFERENCES miem_dwh_dim_cards (card_num)
    , oper_type VARCHAR
    , amt DECIMAL
    , oper_result VARCHAR
    , terminal VARCHAR REFERENCES miem_dwh_dim_terminals (terminal_id)
);

-- ##########
-- REPORT TABLES
-- ##########

CREATE TABLE IF NOT EXISTS miem_rep_fraud (
    event_dt TIMESTAMP
    , passport VARCHAR
    , fio VARCHAR
    , phone VARCHAR
    , event_type VARCHAR
    , report_dt DATE
);

-- ##########
-- DIM SCD2 TABLES
-- ##########

-- Таблица клиентов
CREATE TABLE IF NOT EXISTS miem_dwh_dim_clients_hist (
    client_id VARCHAR
    , last_name VARCHAR
    , first_name VARCHAR
    , patronymic VARCHAR
    , date_of_birth DATE
    , passport_num VARCHAR
    , passport_valid_to DATE
    , phone VARCHAR
    , effective_from TIMESTAMP
    , effective_to TIMESTAMP
    , deleted_flg BOOLEAN
);

-- Таблица счетов
CREATE TABLE IF NOT EXISTS miem_dwh_dim_accounts_hist (
    account VARCHAR
    , valid_to DATE
    , client VARCHAR
    , effective_from TIMESTAMP
    , effective_to TIMESTAMP
    , deleted_flg BOOLEAN
);

-- Таблица карт
CREATE TABLE IF NOT EXISTS miem_dwh_dim_cards_hist (
    card_num VARCHAR
    , account VARCHAR
    , effective_from TIMESTAMP
    , effective_to TIMESTAMP
    , deleted_flg BOOLEAN
);

-- Таблица для терминалов
CREATE TABLE IF NOT EXISTS miem_dwh_dim_terminals_hist (
    terminal_id VARCHAR
    , terminal_type VARCHAR
    , terminal_city VARCHAR
    , terminal_address VARCHAR
    , effective_from TIMESTAMP
    , effective_to TIMESTAMP
    , deleted_flg BOOLEAN
);
