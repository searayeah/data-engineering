-- 1. Захват в стейджинг ключей из источника полным срезом для вычисления удалений.
CREATE TABLE miem_dwh_dim_cards_stg_del (
    card_num VARCHAR
);

INSERT INTO miem_dwh_dim_cards_stg_del (card_num)
SELECT card_num FROM miem_stg_cards;

-- 2. Загрузка в приемник "вставок" на источнике (формат SCD1).
INSERT INTO miem_dwh_dim_cards (
    card_num
    , account
    , create_dt
    , update_dt
)
SELECT
    stg.card_num
    , stg.account
    , stg.create_dt
    , NULL
FROM miem_stg_cards AS stg
LEFT JOIN miem_dwh_dim_cards AS tgt
    ON stg.card_num = tgt.card_num
WHERE tgt.card_num IS NULL;

-- 3. Обновление в приемнике "обновлений" на источнике (формат SCD1).
UPDATE miem_dwh_dim_cards
SET
    account = tmp.account
    , update_dt = tmp.update_dt
FROM (
    SELECT
        stg.card_num
        , stg.account
        , stg.update_dt
    FROM miem_stg_cards AS stg
    INNER JOIN miem_dwh_dim_cards AS tgt
        ON stg.card_num = tgt.card_num
    WHERE
        stg.account <> tgt.account
        OR (stg.account IS NULL AND tgt.account IS NOT NULL)
        OR (stg.account IS NOT NULL AND tgt.account IS NULL)
) AS tmp
WHERE miem_dwh_dim_cards.card_num = tmp.card_num;

-- 4. Удаление в приемнике удаленных в источнике записей (формат SCD1).
DELETE FROM miem_dwh_dim_cards
WHERE card_num IN (
    SELECT tgt.card_num
    FROM miem_dwh_dim_cards AS tgt
    LEFT JOIN miem_dwh_dim_cards_stg_del AS stg
        ON tgt.card_num = stg.card_num
    WHERE stg.card_num IS NULL
);

-- 5. Удаление временной таблицы
DROP TABLE miem_dwh_dim_cards_stg_del;
