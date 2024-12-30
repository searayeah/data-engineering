-- 1. Захват в стейджинг ключей из источника полным срезом для вычисления удалений.
CREATE TABLE miem_dwh_dim_accounts_stg_del (
    account VARCHAR
);

INSERT INTO miem_dwh_dim_accounts_stg_del (account)
SELECT account FROM miem_stg_accounts;

-- 2. Загрузка в приемник "вставок" на источнике (формат SCD1).
INSERT INTO miem_dwh_dim_accounts (
    account, client, valid_to, create_dt, update_dt
)
SELECT
    stg.account
    , stg.client
    , stg.valid_to
    , stg.create_dt
    , NULL
FROM miem_stg_accounts AS stg
LEFT JOIN miem_dwh_dim_accounts AS tgt
    ON stg.account = tgt.account
WHERE tgt.account IS NULL;

-- 3. Обновление в приемнике "обновлений" на источнике (формат SCD1).
UPDATE miem_dwh_dim_accounts
SET
    client = tmp.client
    , valid_to = tmp.valid_to
    , update_dt = tmp.update_dt
FROM (
    SELECT
        stg.account
        , stg.client
        , stg.valid_to
        , stg.update_dt
    FROM miem_stg_accounts AS stg
    INNER JOIN miem_dwh_dim_accounts AS tgt
        ON stg.account = tgt.account
    WHERE
        stg.client <> tgt.client
        OR (stg.client IS NULL AND tgt.client IS NOT NULL)
        OR (stg.client IS NOT NULL AND tgt.client IS NULL)
        OR stg.valid_to <> tgt.valid_to
        OR (stg.valid_to IS NULL AND tgt.valid_to IS NOT NULL)
        OR (stg.valid_to IS NOT NULL AND tgt.valid_to IS NULL)
) AS tmp
WHERE miem_dwh_dim_accounts.account = tmp.account;

-- 4. Удаление в приемнике удаленных в источнике записей (формат SCD1).
DELETE FROM miem_dwh_dim_accounts
WHERE account IN (
    SELECT tgt.account
    FROM miem_dwh_dim_accounts AS tgt
    LEFT JOIN miem_dwh_dim_accounts_stg_del AS stg
        ON tgt.account = stg.account
    WHERE stg.account IS NULL
);

-- 5. Удаление временной таблицы
DROP TABLE miem_dwh_dim_accounts_stg_del;
