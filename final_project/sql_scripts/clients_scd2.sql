-- 1. Закрытие устаревших записей в DWH для удаленных записей.
UPDATE miem_dwh_dim_clients_hist
SET
    effective_to = CURRENT_TIMESTAMP
    , deleted_flg = true
FROM (
    SELECT tgt.client_id
    FROM miem_dwh_dim_clients_hist AS tgt
    LEFT JOIN miem_stg_clients AS stg
        ON tgt.client_id = stg.client_id
    WHERE
        stg.client_id IS null
        AND tgt.effective_to IS null -- Открытые записи
) AS tmp
WHERE miem_dwh_dim_clients_hist.client_id = tmp.client_id;

-- 2. Закрытие устаревших записей для изменившихся данных.
UPDATE miem_dwh_dim_clients_hist
SET
    effective_to = CURRENT_TIMESTAMP
    , deleted_flg = false
FROM (
    SELECT tgt.client_id
    FROM miem_dwh_dim_clients_hist AS tgt
    INNER JOIN miem_stg_clients AS stg
        ON tgt.client_id = stg.client_id
    WHERE
        (
            stg.first_name <> tgt.first_name
            OR stg.last_name <> tgt.last_name
            OR stg.patronymic <> tgt.patronymic
            OR stg.date_of_birth <> tgt.date_of_birth
            OR stg.phone <> tgt.phone
            OR stg.passport_num <> tgt.passport_num
            OR stg.passport_valid_to <> tgt.passport_valid_to
        )
        AND tgt.effective_to IS null -- Открытые записи
) AS tmp
WHERE miem_dwh_dim_clients_hist.client_id = tmp.client_id;

-- 3. Вставка новых записей (для новых и изменившихся данных).
INSERT INTO miem_dwh_dim_clients_hist (
    client_id
    , first_name
    , last_name
    , patronymic
    , date_of_birth
    , phone
    , passport_num
    , passport_valid_to
    , effective_from
    , effective_to
    , deleted_flg
)
SELECT
    stg.client_id
    , stg.first_name
    , stg.last_name
    , stg.patronymic
    , stg.date_of_birth
    , stg.phone
    , stg.passport_num
    , stg.passport_valid_to
    , CURRENT_TIMESTAMP
    , null
    , false
FROM miem_stg_clients AS stg
LEFT JOIN miem_dwh_dim_clients_hist AS tgt
    ON
        stg.client_id = tgt.client_id
        AND tgt.effective_to IS null
WHERE
    tgt.client_id IS null
    OR (
        stg.first_name <> tgt.first_name
        OR stg.last_name <> tgt.last_name
        OR stg.patronymic <> tgt.patronymic
        OR stg.date_of_birth <> tgt.date_of_birth
        OR stg.phone <> tgt.phone
        OR stg.passport_num <> tgt.passport_num
        OR stg.passport_valid_to <> tgt.passport_valid_to
    );
