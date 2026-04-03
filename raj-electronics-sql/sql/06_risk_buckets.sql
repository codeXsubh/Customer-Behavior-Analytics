-- Simple risk-style buckets from outstanding balance (illustrative thresholds).

SELECT
    CASE
        WHEN due >= 500000 THEN '500k+'
        WHEN due >= 300000 THEN '300k–500k'
        WHEN due >= 150000 THEN '150k–300k'
        ELSE 'under 150k'
    END AS due_bucket,
    COUNT(*) AS clients,
    SUM(due) AS total_due
FROM clients
GROUP BY due_bucket
ORDER BY total_due DESC;
