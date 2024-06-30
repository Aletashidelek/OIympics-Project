SELECT *
FROM oly

-- See the time range
SELECT MIN(year), MAX(year)
FROM oly

-- See which country has the most Gold medals historically
SELECT country, COUNT(*) AS total_golds
FROM oly
WHERE medal = 'Gold'
GROUP BY country
ORDER BY total_golds DESC