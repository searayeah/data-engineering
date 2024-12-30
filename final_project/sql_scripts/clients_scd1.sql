-- 1. Захват в стейджинг ключей из источника полным срезом для вычисления удалений.
CREATE TABLE miem_dwh_dim_clients_stg_del (
    client_id VARCHAR
);

INSERT INTO miem_dwh_dim_clients_stg_del (client_id)
SELECT client_id FROM miem_stg_clients;

-- 2. Загрузка в приемник "вставок" на источнике (формат SCD1).
INSERT INTO miem_dwh_dim_clients (
    client_id
    , first_name
    , last_name
    , patronymic
    , date_of_birth
    , phone
    , passport_num
    , passport_valid_to
    , create_dt
    , update_dt
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
    , stg.create_dt
    , NULL
FROM miem_stg_clients AS stg
LEFT JOIN miem_dwh_dim_clients AS tgt
    ON stg.client_id = tgt.client_id
WHERE tgt.client_id IS NULL;

-- 3. Обновление в приемнике "обновлений" на источнике (формат SCD1).
UPDATE miem_dwh_dim_clients
SET
    first_name = tmp.first_name
    , last_name = tmp.last_name
    , patronymic = tmp.patronymic
    , date_of_birth = tmp.date_of_birth
    , phone = tmp.phone
    , passport_num = tmp.passport_num
    , passport_valid_to = tmp.passport_valid_to
    , update_dt = tmp.update_dt
FROM (
    SELECT
        stg.client_id
        , stg.first_name
        , stg.last_name
        , stg.patronymic
        , stg.date_of_birth
        , stg.phone
        , stg.passport_num
        , stg.passport_valid_to
        , stg.update_dt
    FROM miem_stg_clients AS stg
    INNER JOIN miem_dwh_dim_clients AS tgt
        ON stg.client_id = tgt.client_id
    WHERE
        stg.first_name <> tgt.first_name
        OR (stg.first_name IS NULL AND tgt.first_name IS NOT NULL)
        OR (stg.first_name IS NOT NULL AND tgt.first_name IS NULL)
        OR stg.last_name <> tgt.last_name
        OR (stg.last_name IS NULL AND tgt.last_name IS NOT NULL)
        OR (stg.last_name IS NOT NULL AND tgt.last_name IS NULL)
        OR stg.patronymic <> tgt.patronymic
        OR (stg.patronymic IS NULL AND tgt.patronymic IS NOT NULL)
        OR (stg.patronymic IS NOT NULL AND tgt.patronymic IS NULL)
        OR stg.date_of_birth <> tgt.date_of_birth
        OR (stg.date_of_birth IS NULL AND tgt.date_of_birth IS NOT NULL)
        OR (stg.date_of_birth IS NOT NULL AND tgt.date_of_birth IS NULL)
        OR stg.phone <> tgt.phone
        OR (stg.phone IS NULL AND tgt.phone IS NOT NULL)
        OR (stg.phone IS NOT NULL AND tgt.phone IS NULL)
        OR stg.passport_num <> tgt.passport_num
        OR (stg.passport_num IS NULL AND tgt.passport_num IS NOT NULL)
        OR (stg.passport_num IS NOT NULL AND tgt.passport_num IS NULL)
        OR stg.passport_valid_to <> tgt.passport_valid_to
        OR (stg.passport_valid_to IS NULL AND tgt.passport_valid_to IS NOT NULL)
        OR (stg.passport_valid_to IS NOT NULL AND tgt.passport_valid_to IS NULL)
) AS tmp
WHERE miem_dwh_dim_clients.client_id = tmp.client_id;

-- 4. Удаление в приемнике удаленных в источнике записей (формат SCD1).
DELETE FROM miem_dwh_dim_clients
WHERE client_id IN (
    SELECT tgt.client_id
    FROM miem_dwh_dim_clients AS tgt
    LEFT JOIN miem_dwh_dim_clients_stg_del AS stg
        ON tgt.client_id = stg.client_id
    WHERE stg.client_id IS NULL
);

-- 5. Удаление временной таблицы
DROP TABLE miem_dwh_dim_clients_stg_del;
