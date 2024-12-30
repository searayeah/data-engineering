-- Заблокированный или просроченный паспорт:
INSERT INTO miem_rep_fraud (
    event_dt, passport, fio, phone, event_type, report_dt
)
SELECT
    ft.trans_date AS event_dt
    , c.passport_num AS passport
    , c.first_name || ' ' || c.last_name AS fio
    , c.phone
    , 'Заблокированный или просроченный паспорт' AS event_type
    , CURRENT_DATE AS report_dt
FROM miem_dwh_fact_transactions AS ft
INNER JOIN miem_dwh_dim_cards AS cd ON ft.card_num = cd.card_num
INNER JOIN miem_dwh_dim_accounts AS a ON cd.account = a.account
INNER JOIN miem_dwh_dim_clients AS c ON a.client = c.client_id
LEFT JOIN
    miem_dwh_fact_passport_blacklist AS b
    ON c.passport_num = b.passport_num
WHERE
    (b.passport_num IS NOT NULL OR c.passport_valid_to < CURRENT_DATE)
    AND ft.trans_date >= CURRENT_DATE::DATE - INTERVAL '1 day';


-- Недействующий договор
INSERT INTO miem_rep_fraud (
    event_dt, passport, fio, phone, event_type, report_dt
)
SELECT
    ft.trans_date AS event_dt
    , c.passport_num AS passport
    , c.first_name || ' ' || c.last_name AS fio
    , c.phone
    , 'Недействующий договор' AS event_type
    , CURRENT_DATE AS report_dt
FROM miem_dwh_fact_transactions AS ft
INNER JOIN miem_dwh_dim_cards AS cd ON ft.card_num = cd.card_num
INNER JOIN miem_dwh_dim_accounts AS a ON cd.account = a.account
INNER JOIN miem_dwh_dim_clients AS c ON a.client = c.client_id
WHERE
    a.valid_to < CURRENT_DATE
    AND ft.trans_date >= CURRENT_DATE::DATE - INTERVAL '1 day';


-- Совершение операций в разных городах за короткое время
WITH city_transactions AS (
    SELECT
        ft.trans_date
        , ft.card_num
        , c.client_id
        , t.terminal_city
        , ROW_NUMBER()
            OVER (PARTITION BY ft.card_num ORDER BY ft.trans_date)
        AS rn
    FROM miem_dwh_fact_transactions AS ft
    INNER JOIN miem_dwh_dim_cards AS cd ON ft.card_num = cd.card_num
    INNER JOIN miem_dwh_dim_accounts AS a ON cd.account = a.account
    INNER JOIN miem_dwh_dim_clients AS c ON a.client = c.client_id
    INNER JOIN miem_dwh_dim_terminals AS t ON ft.terminal = t.terminal_id
    WHERE ft.trans_date >= CURRENT_DATE::DATE - INTERVAL '1 day'

)

INSERT INTO miem_rep_fraud (
    event_dt, passport, fio, phone, event_type, report_dt
)
SELECT
    t1.trans_date AS event_dt
    , c.passport_num AS passport
    , c.first_name || ' ' || c.last_name AS fio
    , c.phone
    , 'Операции в разных городах за короткое время' AS event_type
    , CURRENT_DATE AS report_dt
FROM city_transactions AS t1

INNER JOIN city_transactions AS t2
    ON
        t1.client_id = t2.client_id
        AND t1.terminal_city != t2.terminal_city
        AND t1.trans_date - t2.trans_date <= INTERVAL '1 hour'
INNER JOIN miem_dwh_dim_clients AS c ON t1.client_id = c.client_id;
