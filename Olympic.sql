-- Remove the unnecessary columns
ALTER TABLE olympia
DROP COLUMN code,
DROP COLUMN code3,
DROP COLUMN url,
DROP COLUMN participant_title
	
-- Split the game column into two individual columns with host city and year
SELECT
LEFT(game,LENGTH(game)-5) AS city
FROM olympia
	
-- Add a column to store city
ALTER TABLE olympia
ADD city VARCHAR(500)
	
UPDATE olympia
SET city = LEFT(game,LENGTH(game)-5)
    
-- Extract year from the game column
SELECT
RIGHT(game,4) AS game_year
FROM olympia

-- Add a column to store year
ALTER TABLE olympia
ADD game_year NUMERIC
    
-- Cast the year from characters into number
UPDATE olympia
SET game_year = CAST(RIGHT(game,4)AS INTEGER)
    
/* Deleted the countries that have
little value to our project (countries/political entities that no longer exist) */
UPDATE olympia
SET country = 'Germany'
WHERE (country = 'German Democratic Republic (Germany)'
OR country = 'Federal Republic of Germany')
    

-- DATA EXPLORATION PART
- SELECT country, COUNT(*) AS gold_count
FROM olympia
WHERE medal = 'GOLD'
GROUP BY country
ORDER BY gold_count DESC
LIMIT 10

-- Look at the country with most golds by category
WITH ranking AS (
SELECT*,
RANK()OVER(PARTITION BY sport ORDER BY gold_count DESC) AS sport_rank
FROM (
SELECT country, sport, COUNT(*) AS gold_count
FROM olympia
WHERE medal = 'GOLD'
GROUP BY country, sport
)
)
SELECT country, sport, gold_count
FROM ranking
WHERE sport_rank = 1

-- Look at countries with most Gold each year
WITH gold AS (
SELECT
country,
game_year,
COUNT(*) AS gold_count
FROM olympia
WHERE medal = 'GOLD'
GROUP BY country, game_year
),
yearly AS (
SELECT*,
ROW_NUMBER()OVER(PARTITION BY game_year ORDER BY gold_count DESC) AS gold_rank
FROM gold
)
SELECT *
FROM yearly
WHERE gold_rank = 1
ORDER BY game_year

-- Rolling Medals Count of Japan (one of our target coutries)
WITH rolling AS (
SELECT
country,
game_year,
COUNT(*) AS medal_count
FROM olympia
WHERE country = 'Japan'
GROUP BY country, game_year
)
SELECT country, game_year, medal_count,
SUM(medal_count) OVER(ORDER BY game_year) AS rolling_total
FROM rolling

-- Look at the medal to population ratio by country in 2020
WITH medal_ratio AS (SELECT
oly.country, popu.pop, COUNT(*) AS medal_num
FROM population popu
JOIN olympia oly ON popu.country = oly.country
WHERE oly.game_year = 2020
GROUP BY oly.country, popu.pop)
SELECT *,
(medal_num / pop) AS medal_percentage
FROM medal_ratio
ORDER BY medal_percentage DESC

[Issue Handbook](https://www.notion.so/Issue-Handbook-cb2d3b4091f24e17985c4ae27cdb3508?pvs=21)

-- Look at the historical Gold-content of countries with golds
SELECT gold.country, medal.total_medal, gold.total_gold,
ROUND((CAST(gold.total_gold AS NUMERIC)/ medal.total_medal),2) AS gold_ratio,
CASE
WHEN (CAST(gold.total_gold AS NUMERIC) / medal.total_medal) <= 0.20 THEN 'Less than 20%'
WHEN (CAST(gold.total_gold AS NUMERIC) / medal.total_medal) > 0.20
AND (CAST(gold.total_gold AS NUMERIC) / medal.total_medal) <= 0.50 THEN 'Between 21%-50%'
ELSE 'Larger than 50%'
END AS "gold-ratio"
FROM
(SELECT
country, COUNT(*) AS total_gold
FROM olympia
WHERE medal = 'GOLD'
GROUP BY country) gold
JOIN
(SELECT
country, COUNT(*) AS total_medal
FROM olympia
GROUP BY country) medal
ON gold.country = medal.country

-- Check The Most Competitive Sport of Each Country
WITH medals AS (SELECT country, sport, COUNT(*) AS medal_count
FROM olympia
GROUP BY country, sport)
,top_sport AS (SELECT
country, sport, medal_count,
RANK()OVER(PARTITION BY country ORDER BY medal_count DESC) AS best_sport
FROM medals)
SELECT *
FROM top_sport
WHERE best_sport = 1

-- Check the country that are competitive in the sports in which we have existing resources. (Double Sub-query)
SELECT *
    FROM (SELECT *,
    RANK()OVER(PARTITION BY sport ORDER BY medal_count DESC) AS ranking
    FROM (SELECT country, sport, COUNT(*) AS medal_count
    FROM olympia
    WHERE sport = 'Boxing'
    OR sport = 'Snowboard'
    OR sport = 'Snowboard'
    GROUP BY country, sport)
    )
WHERE ranking <= 5
    

/* Look at the medal profile of our partner countres. What sports are they good at 
So that we can better design and promote our product */
WITH top_sport AS (SELECT country, sport, COUNT(*) AS medal_count
    FROM olympia
    WHERE country = 'Germany'
    OR country = 'Georgia'
    OR country = 'Switzerland'
    OR country = 'Uzbekistan'
    GROUP BY country, sport),
Ranking AS (SELECT *,
    DENSE_RANK()OVER(PARTITION BY country ORDER BY medal_count DESC) AS sport_rank
    FROM top_sport)
SELECT *
FROM Ranking
WHERE sport_rank  < 6
    

-- For Fun: What Is The First Name That Wins The Most Medal For Men And Momen
WITH top_name AS (SELECT *,
ROW_NUMBER()OVER(PARTITION BY gender ORDER BY medal_count DESC) AS ranking
FROM (SELECT
SUBSTRING(athlete FROM 1 FOR POSITION(' ' IN athlete) -1) AS first_name,
gender,
COUNT(*) AS medal_count
FROM olympia
WHERE athlete IS NOT NULL
AND (gender = 'Men' OR gender = 'Women')
GROUP BY first_name, gender
ORDER BY medal_count DESC
)
)
SELECT *
FROM top_name
WHERE ranking < 6
