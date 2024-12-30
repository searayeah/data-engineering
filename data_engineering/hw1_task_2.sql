-- Part 1

CREATE TABLE IF NOT EXISTS miem_salary_hist AS (
    SELECT
        person,
        class,
        salary,
        dt AS effective_from,
        COALESCE(
            LEAD(dt) OVER (PARTITION BY person ORDER BY dt) - interval '1 day',
            TO_DATE('2999-12-31', 'YYYY-MM-DD')
        )::date AS effective_to

    FROM de.histgroup
    ORDER BY person
);

-- Part 2


CREATE TABLE IF NOT EXISTS miem_salary_log AS (
    WITH sp_sum AS (
        SELECT
            sp.dt,
            sp.person,
            sp.payment,
            sh.salary,
            SUM(sp.payment) OVER (
                PARTITION BY sp.person, DATE_TRUNC('month', sp.dt)
                ORDER BY sp.dt
            ) AS month_paid
        FROM de.salary_payments AS sp
        LEFT JOIN miem_salary_hist AS sh
            ON
                sp.person = sh.person
                AND sp.dt BETWEEN sh.effective_from AND sh.effective_to
    )

    SELECT
        sp_sum.dt AS payment_dt,
        sp_sum.person,
        sp_sum.payment,
        sp_sum.month_paid,
        sp_sum.salary - sp_sum.month_paid AS month_rest
    FROM sp_sum
    ORDER BY sp_sum.person, sp_sum.dt
);
