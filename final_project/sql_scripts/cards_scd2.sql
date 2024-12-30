-- 1. Закрытие устаревших записей в dwh (для удалений).
UPDATE miem_dwh_dim_cards_hist
SET
    effective_to = CURRENT_TIMESTAMP
    , deleted_flg = true
FROM (
    SELECT tgt.card_num
    FROM miem_dwh_dim_cards_hist AS tgt
    LEFT JOIN miem_stg_cards AS stg
        ON tgt.card_num = stg.card_num
    WHERE
        stg.card_num IS null
        AND tgt.effective_to IS null
) AS tmp
WHERE miem_dwh_dim_cards_hist.card_num = tmp.card_num;

-- 2. Закрытие устаревших записей для изменившихся данных.
UPDATE miem_dwh_dim_cards_hist
SET
    effective_to = CURRENT_TIMESTAMP
    , deleted_flg = false
FROM (
    SELECT tgt.card_num
    FROM miem_dwh_dim_cards_hist AS tgt
    INNER JOIN miem_stg_cards AS stg
        ON tgt.card_num = stg.card_num
    WHERE
        tgt.account <> stg.account
        AND tgt.effective_to IS null
) AS tmp
WHERE miem_dwh_dim_cards_hist.card_num = tmp.card_num;

-- 3. Вставка новых записей (для новых и изменившихся данных).
INSERT INTO miem_dwh_dim_cards_hist (
    card_num
    , account
    , effective_from
    , effective_to
    , deleted_flg
)
SELECT
    stg.card_num
    , stg.account
    , CURRENT_TIMESTAMP
    , null
    , false
FROM miem_stg_cards AS stg
LEFT JOIN miem_dwh_dim_cards_hist AS tgt
    ON
        stg.card_num = tgt.card_num
        AND tgt.effective_to IS null
WHERE
    tgt.card_num IS null
    OR tgt.account <> stg.account;
