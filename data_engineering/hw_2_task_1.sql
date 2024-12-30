--- Part 1
DROP TABLE IF EXISTS miem_log;

CREATE TABLE miem_log (
    dt DATE
    , link VARCHAR(50)
    , user_agent VARCHAR(200)
    , region VARCHAR(30)
);

WITH parsed_log_values AS (
    SELECT
        split_part(data, E'\t', 1) AS ip
        , to_timestamp(split_part(data, E'\t', 4), 'YYYYMMDDHH24MISS') AS dt
        , split_part(data, E'\t', 5) AS link
        , split_part(data, E'\t', 6) AS px
        , split_part(data, E'\t', 7) AS py
        --- лишний "n" и пробел
        , trim(rtrim(split_part(data, E'\t', 8), 'n')) AS user_agent
    FROM de.log
)

, ip_to_region AS (
    SELECT
        split_part(data, E'\t', 1) AS ip
        , split_part(data, E'\t', 2) AS region
    FROM de.ip
)

, log_with_region AS (
    SELECT
        parsed_log_values.dt
        , parsed_log_values.link
        , parsed_log_values.user_agent
        , ip_to_region.region
    FROM parsed_log_values
    LEFT JOIN ip_to_region
        ON parsed_log_values.ip = ip_to_region.ip
)

INSERT INTO miem_log (dt, link, user_agent, region)
SELECT * FROM log_with_region;

--- Part 2
DROP TABLE IF EXISTS miem_log_report;

CREATE TABLE miem_log_report (
    region VARCHAR(30)
    , browser VARCHAR(10)
);

--- row_number заместо rank, чтобы не дублировать region при одинаковом count
WITH browser_ranks AS (
    SELECT
        region
        , split_part(user_agent, '/', 1) AS browser
        , count(*) AS browser_count
        , row_number()
            OVER (PARTITION BY region ORDER BY count(*) DESC)
        AS row_number
    FROM miem_log
    GROUP BY region, browser
)

, browser_report AS (
    SELECT
        region
        , browser
    FROM browser_ranks
    WHERE row_number = 1
    ORDER BY region
)

INSERT INTO miem_log_report (
    region
    , browser
)
SELECT * FROM browser_report;
