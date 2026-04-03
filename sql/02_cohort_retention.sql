-- Monthly cohorts by first purchase month; period = whole months since cohort month.
-- Retention rate = active_customers_in_period / cohort_size.

WITH first_cohort AS (
    SELECT
        customer_id,
        strftime('%Y-%m', first_purchase_date) AS cohort_month,
        CAST(strftime('%Y', first_purchase_date) AS INTEGER) * 12
            + CAST(strftime('%m', first_purchase_date) AS INTEGER) AS cohort_ym
    FROM customers
),
pay_months AS (
    SELECT DISTINCT
        customer_id,
        strftime('%Y-%m', payment_date) AS activity_month,
        CAST(strftime('%Y', payment_date) AS INTEGER) * 12
            + CAST(strftime('%m', payment_date) AS INTEGER) AS activity_ym
    FROM payments
),
cohort_activity AS (
    SELECT
        p.customer_id,
        f.cohort_month,
        (p.activity_ym - f.cohort_ym) AS period
    FROM pay_months p
    JOIN first_cohort f ON p.customer_id = f.customer_id
    WHERE p.activity_ym >= f.cohort_ym
),
cohort_sizes AS (
    SELECT cohort_month, COUNT(*) AS cohort_size
    FROM first_cohort
    GROUP BY cohort_month
)
SELECT
    ca.cohort_month,
    ca.period,
    cs.cohort_size,
    COUNT(DISTINCT ca.customer_id) AS active_customers,
    ROUND(
        CAST(COUNT(DISTINCT ca.customer_id) AS REAL) / cs.cohort_size,
        4
    ) AS retention_rate
FROM cohort_activity ca
JOIN cohort_sizes cs ON ca.cohort_month = cs.cohort_month
GROUP BY ca.cohort_month, ca.period, cs.cohort_size
ORDER BY ca.cohort_month, ca.period;
