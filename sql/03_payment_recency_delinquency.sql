-- Payment recency buckets vs average delinquency rate (portfolio / risk segmentation).

SELECT
    CASE
        WHEN days_since_payment <= 30 THEN '0-30 days'
        WHEN days_since_payment <= 60 THEN '31-60 days'
        WHEN days_since_payment <= 90 THEN '61-90 days'
        ELSE '90+ days'
    END AS payment_recency_bucket,
    COUNT(*) AS customers,
    ROUND(AVG(delinquent_flag), 4) AS avg_delinquency_rate,
    SUM(delinquent_flag) AS delinquent_count
FROM customers
GROUP BY payment_recency_bucket
ORDER BY
    CASE payment_recency_bucket
        WHEN '0-30 days' THEN 1
        WHEN '31-60 days' THEN 2
        WHEN '61-90 days' THEN 3
        ELSE 4
    END;
