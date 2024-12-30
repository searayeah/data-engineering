INSERT INTO miem_dwh_fact_transactions (
    trans_id
    , trans_date
    , card_num
    , oper_type
    , amt
    , oper_result
    , terminal
)
SELECT
    trans_id
    , trans_date
    , card_num
    , oper_type
    , amt
    , oper_result
    , terminal
FROM miem_stg_transactions;

INSERT INTO miem_dwh_fact_passport_blacklist (
    passport_num
    , entry_dt
)
SELECT
    passport_num
    , entry_dt
FROM miem_stg_passport_blacklist;
