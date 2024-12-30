CREATE TABLE miem_log_report (
    region VARCHAR(30)
    , browser VARCHAR(10)
);


WITH browser_region_count AS (
    SELECT
        region
        , split_part(user_agent, '/', 1) AS browser
        , count(*) AS browser_count
    FROM miem_log
    GROUP BY region, browser
)

, region_max_count AS (
    SELECT
        region
        , max(browser_count) AS max_browser_count
    FROM browser_region_count
    GROUP BY region
)

, browser_report AS (
    SELECT
        region
        , browser
    FROM browser_region_count
    WHERE (region, browser_count) IN (SELECT * FROM region_max_count)
)

INSERT INTO miem_log_report (
    region
    , browser
)
SELECT * FROM browser_report;
