-- Teams ranked by share of portfolio-wide outstanding (where to focus collections).

WITH t AS (
    SELECT team_code, SUM(due) AS team_due
    FROM clients
    GROUP BY team_code
),
g AS (
    SELECT SUM(team_due) AS grand_due FROM t
)
SELECT
    t.team_code,
    t.team_due,
    ROUND(100.0 * t.team_due / NULLIF(g.grand_due, 0), 2) AS pct_of_total_due
FROM t
CROSS JOIN g
ORDER BY t.team_due DESC;
