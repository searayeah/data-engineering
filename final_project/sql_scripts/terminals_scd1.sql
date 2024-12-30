-- 1. Захват в стейджинг ключей из источника полным срезом для вычисления удалений.
CREATE TABLE miem_dwh_dim_terminals_stg_del (
    terminal_id VARCHAR
);

INSERT INTO miem_dwh_dim_terminals_stg_del (terminal_id)
SELECT terminal_id FROM miem_stg_terminals;

-- 2. Загрузка в приемник "вставок" на источнике (формат SCD1).
INSERT INTO miem_dwh_dim_terminals (
    terminal_id
    , terminal_type
    , terminal_city
    , terminal_address
    , create_dt
    , update_dt
)
SELECT
    stg.terminal_id
    , stg.terminal_type
    , stg.terminal_city
    , stg.terminal_address
    , stg.create_dt
    , NULL
FROM miem_stg_terminals AS stg
LEFT JOIN miem_dwh_dim_terminals AS tgt
    ON stg.terminal_id = tgt.terminal_id
WHERE tgt.terminal_id IS NULL;

-- 3. Обновление в приемнике "обновлений" на источнике (формат SCD1).
UPDATE miem_dwh_dim_terminals
SET
    terminal_type = tmp.terminal_type
    , terminal_city = tmp.terminal_city
    , terminal_address = tmp.terminal_address
    , update_dt = tmp.update_dt
FROM (
    SELECT
        stg.terminal_id
        , stg.terminal_type
        , stg.terminal_city
        , stg.terminal_address
        , stg.update_dt
    FROM miem_stg_terminals AS stg
    INNER JOIN miem_dwh_dim_terminals AS tgt
        ON stg.terminal_id = tgt.terminal_id
    WHERE
        stg.terminal_type <> tgt.terminal_type
        OR (stg.terminal_type IS NULL AND tgt.terminal_type IS NOT NULL)
        OR (stg.terminal_type IS NOT NULL AND tgt.terminal_type IS NULL)
        OR stg.terminal_city <> tgt.terminal_city
        OR (stg.terminal_city IS NULL AND tgt.terminal_city IS NOT NULL)
        OR (stg.terminal_city IS NOT NULL AND tgt.terminal_city IS NULL)
        OR stg.terminal_address <> tgt.terminal_address
        OR (stg.terminal_address IS NULL AND tgt.terminal_address IS NOT NULL)
        OR (stg.terminal_address IS NOT NULL AND tgt.terminal_address IS NULL)
) AS tmp
WHERE miem_dwh_dim_terminals.terminal_id = tmp.terminal_id;

-- 4. Удаление в приемнике удаленных в источнике записей (формат SCD1).
DELETE FROM miem_dwh_dim_terminals
WHERE terminal_id IN (
    SELECT tgt.terminal_id
    FROM miem_dwh_dim_terminals AS tgt
    LEFT JOIN miem_dwh_dim_terminals_stg_del AS stg
        ON tgt.terminal_id = stg.terminal_id
    WHERE stg.terminal_id IS NULL
);

-- 5. Удаление временной таблицы
DROP TABLE miem_dwh_dim_terminals_stg_del;
