-- PostgreSQL version of cohort retention (same logic as sql/02_cohort_retention.sql).

WITH first_cohort AS (
    SELECT
        customer_id,
        to_char(first_purchase_date, 'YYYY-MM') AS cohort_month,
        EXTRACT(YEAR FROM first_purchase_date)::integer * 12
            + EXTRACT(MONTH FROM first_purchase_date)::integer AS cohort_ym
    FROM customers
),
pay_months AS (
    SELECT DISTINCT
        customer_id,
        to_char(payment_date, 'YYYY-MM') AS activity_month,
        EXTRACT(YEAR FROM payment_date)::integer * 12
            + EXTRACT(MONTH FROM payment_date)::integer AS activity_ym
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
        (COUNT(DISTINCT ca.customer_id)::numeric / cs.cohort_size),
        4
    ) AS retention_rate
FROM cohort_activity ca
JOIN cohort_sizes cs ON ca.cohort_month = cs.cohort_month
GROUP BY ca.cohort_month, ca.period, cs.cohort_size
ORDER BY ca.cohort_month, ca.period;
