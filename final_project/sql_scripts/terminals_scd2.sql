-- 1. Закрытие устаревших записей в dwh.
UPDATE miem_dwh_dim_terminals_hist
SET
    effective_to = CURRENT_TIMESTAMP
    , deleted_flg = true
FROM (
    SELECT tgt.terminal_id
    FROM miem_dwh_dim_terminals_hist AS tgt
    LEFT JOIN miem_stg_terminals AS stg
        ON tgt.terminal_id = stg.terminal_id
    WHERE
        stg.terminal_id IS null
        AND tgt.effective_to IS null
) AS tmp
WHERE miem_dwh_dim_terminals_hist.terminal_id = tmp.terminal_id;

-- 2. Закрытие устаревших записей для изменившихся данных.
UPDATE miem_dwh_dim_terminals_hist
SET
    effective_to = CURRENT_TIMESTAMP
    , deleted_flg = false
FROM (
    SELECT tgt.terminal_id
    FROM miem_dwh_dim_terminals_hist AS tgt
    INNER JOIN miem_stg_terminals AS stg
        ON tgt.terminal_id = stg.terminal_id
    WHERE
        (
            tgt.terminal_type <> stg.terminal_type
            OR tgt.terminal_city <> stg.terminal_city
            OR tgt.terminal_address <> stg.terminal_address
        )
        AND tgt.effective_to IS null
) AS tmp
WHERE miem_dwh_dim_terminals_hist.terminal_id = tmp.terminal_id;

-- 3. Вставка новых записей (для новых и изменившихся данных).
INSERT INTO miem_dwh_dim_terminals_hist (
    terminal_id
    , terminal_type
    , terminal_city
    , terminal_address
    , effective_from
    , effective_to
    , deleted_flg
)
SELECT
    stg.terminal_id
    , stg.terminal_type
    , stg.terminal_city
    , stg.terminal_address
    , CURRENT_TIMESTAMP
    , null
    , false
FROM miem_stg_terminals AS stg
LEFT JOIN miem_dwh_dim_terminals_hist AS tgt
    ON
        stg.terminal_id = tgt.terminal_id
        AND tgt.effective_to IS null
WHERE
    tgt.terminal_id IS null
    OR (tgt.terminal_type <> stg.terminal_type OR tgt.terminal_city <> stg.terminal_city OR tgt.terminal_address <> stg.terminal_address);
