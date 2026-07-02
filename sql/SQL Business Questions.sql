SELECT *
FROM gameapp_data
LIMIT 30;

-- Q1. App version nào có nhiều người chơi nhất?
SELECT
    app_version,
    COUNT(DISTINCT user_id) AS total_users
FROM gameapp_data
GROUP BY app_version
ORDER BY total_users DESC;

-- Q2. App version nào tạo ra doanh thu cao nhất?
SELECT
    app_version,
    ROUND(SUM(total_revenue)::numeric, 2) AS revenue
FROM gameapp_data
GROUP BY app_version
ORDER BY revenue DESC;

-- Q3. LTV trung bình của mỗi app version là bao nhiêu?
SELECT
    app_version,
    ROUND(
        SUM(total_revenue)::numeric /
        COUNT(DISTINCT user_id)
    ,2) AS ltv
FROM gameapp_data
GROUP BY app_version
ORDER BY ltv DESC;

-- Q4. D1 Retention của từng app version
WITH installs AS (
    SELECT
        app_version,
        COUNT(DISTINCT user_id) AS install_users
    FROM gameapp_data
    WHERE days_since_install = 0
    GROUP BY app_version
),

d1 AS (
    SELECT
        app_version,
        COUNT(DISTINCT user_id) AS retained_users
    FROM gameapp_data
    WHERE days_since_install = 1
    GROUP BY app_version
)

SELECT
    i.app_version,
    install_users,
    retained_users,
    ROUND(
        retained_users * 100.0 / install_users,
        2
    ) AS d1_retention
FROM installs i
JOIN d1 d
ON i.app_version = d.app_version;

-- Q5. D7 Retention theo app version
WITH installs AS (
    SELECT
        app_version,
        COUNT(DISTINCT user_id) AS install_users
    FROM gameapp_data
    WHERE days_since_install = 0
    GROUP BY app_version
),

d7 AS (
    SELECT
        app_version,
        COUNT(DISTINCT user_id) AS retained_users
    FROM gameapp_data
    WHERE days_since_install = 7
    GROUP BY app_version
)

SELECT
    i.app_version,
    ROUND(
        retained_users * 100.0 / install_users,
        2
    ) AS d7_retention
FROM installs i
JOIN d7 d
ON i.app_version = d.app_version;

-- Q6. Pass Rate tổng thể của từng version
SELECT
    app_version,
    COUNT(*) FILTER (WHERE result = 'win') AS win_attempts,
    COUNT(*) FILTER (WHERE result = 'lose') AS lose_attempts,
    ROUND(
        COUNT(*) FILTER (WHERE result = 'win') * 100.0 /
        COUNT(*) FILTER (WHERE result IN ('win','lose')),
        2
    ) AS pass_rate_pct
FROM gameapp_data
WHERE event_name = 'level_end'
GROUP BY app_version
ORDER BY app_version;
  
-- Q7. Tỷ lệ payer theo app version
SELECT
    app_version,
    ROUND(
        100.0 *
        COUNT(DISTINCT CASE WHEN is_payer=1 THEN user_id END)
        /
        COUNT(DISTINCT user_id)
    ,2) AS payer_rate
FROM gameapp_data
GROUP BY app_version;

-- Q8. ARPPU theo app version
SELECT
    app_version,
    ROUND(
        SUM(iap_revenue_usd)::numeric
        /
        COUNT(DISTINCT CASE
            WHEN is_payer=1
            THEN user_id
        END)
    ,2) AS arppu
FROM gameapp_data
GROUP BY app_version;
