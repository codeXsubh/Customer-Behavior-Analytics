-- PostgreSQL: payment recency buckets vs delinquency rate.

SELECT
    CASE
        WHEN days_since_payment <= 30 THEN '0-30 days'
        WHEN days_since_payment <= 60 THEN '31-60 days'
        WHEN days_since_payment <= 90 THEN '61-90 days'
        ELSE '90+ days'
    END AS payment_recency_bucket,
    COUNT(*) AS customers,
    ROUND(AVG(delinquent_flag::numeric), 4) AS avg_delinquency_rate,
    SUM(delinquent_flag) AS delinquent_count
FROM customers
GROUP BY 1
ORDER BY MIN(
    CASE
        WHEN days_since_payment <= 30 THEN 1
        WHEN days_since_payment <= 60 THEN 2
        WHEN days_since_payment <= 90 THEN 3
        ELSE 4
    END
);
