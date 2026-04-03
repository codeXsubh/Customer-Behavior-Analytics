-- Exposure by anonymized region bucket.

SELECT
    region_code,
    COUNT(*) AS clients,
    SUM(due) AS total_due,
    ROUND(AVG(due), 0) AS avg_due
FROM clients
GROUP BY region_code
ORDER BY total_due DESC;
