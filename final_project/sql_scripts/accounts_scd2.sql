-- 1. Закрытие устаревших записей в dwh (для удалений).
UPDATE miem_dwh_dim_accounts_hist
SET
    effective_to = CURRENT_TIMESTAMP
    , deleted_flg = true
FROM (
    SELECT tgt.account
    FROM miem_dwh_dim_accounts_hist AS tgt
    LEFT JOIN miem_stg_accounts AS stg
        ON tgt.account = stg.account
    WHERE
        stg.account IS null
        AND tgt.effective_to IS null
) AS tmp
WHERE miem_dwh_dim_accounts_hist.account = tmp.account;

-- 2. Закрытие устаревших записей для изменившихся данных.
UPDATE miem_dwh_dim_accounts_hist
SET
    effective_to = CURRENT_TIMESTAMP
    , deleted_flg = false
FROM (
    SELECT tgt.account
    FROM miem_dwh_dim_accounts_hist AS tgt
    INNER JOIN miem_stg_accounts AS stg
        ON tgt.account = stg.account
    WHERE
        (tgt.client <> stg.client OR tgt.valid_to <> stg.valid_to)
        AND tgt.effective_to IS null
) AS tmp
WHERE miem_dwh_dim_accounts_hist.account = tmp.account;

-- 3. Вставка новых записей (для новых и изменившихся данных).
INSERT INTO miem_dwh_dim_accounts_hist (
    account
    , client
    , valid_to
    , effective_from
    , effective_to
    , deleted_flg
)
SELECT
    stg.account
    , stg.client
    , stg.valid_to
    , CURRENT_TIMESTAMP
    , null
    , false
FROM miem_stg_accounts AS stg
LEFT JOIN miem_dwh_dim_accounts_hist AS tgt
    ON
        stg.account = tgt.account
        AND tgt.effective_to IS null
WHERE
    tgt.account IS null
    OR (tgt.client <> stg.client OR tgt.valid_to <> stg.valid_to);
