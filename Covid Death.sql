-- DATA SET: Daily new confirmed COVID-19 deaths per million people
-- SOURCE : https://ourworldindata.org/covid-deaths OR https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/CovidDeaths.xlsx
-- Queried using MySQL

-- Firstly, i will create a staging or working data that is seperate from the raw data so is not to permanently alter it.
DROP TABLE IF EXISTS c19_deaths;
CREATE TABLE c19_deaths
LIKE coviddeaths;
INSERT c19_deaths
SELECT *
FROM coviddeaths;

-- in the raw data, There is a field named 'location' which is filled with country names and also continent names and 'world'
	-- I would delete those rows, and change the name field name into "country"

DELETE FROM c19_deaths
WHERE continent = '';

ALTER TABLE c19_deaths CHANGE COLUMN location country varchar(50);

SELECT *
FROM c19_deaths;

-- 1. Total cases VS total deaths VS death percentage
	-- shows the percentage of how likely it is for someone in a location (or continent), in a date to die when contraced covid 19.

SELECT country, 
date,
total_cases,
REPLACE(total_deaths, '', 0) AS total_deaths,
COALESCE(ROUND(((total_deaths / total_cases) * 100), 2), 0) AS death_percentage
FROM c19_deaths
WHERE continent = 'Asia';



-- 2. Population VS total cases

SELECT country, 
date, 
population, 
total_cases,
(total_cases/ population)* 100 AS percentage_infected
FROM c19_deaths;


-- 3. How long a country goes from the lowest percentage to the highest percentage
SELECT country, 
COUNT(*) AS days_from_lowest_to_highest
FROM c19_deaths
WHERE ((total_cases/ population)* 100) <= (SELECT MAX((total_cases/ population)* 100))
GROUP BY location
ORDER BY days_from_lowest_to_highest DESC;


-- 4. what country has the highest infected percentage overall
SELECT country,  
population,
MAX(CAST(total_cases AS SIGNED)) AS highest_case,
CONCAT(ROUND((MAX((total_cases/ population))* 100),2 ), '%') AS max_percentage_infected
FROM c19_deaths
GROUP BY location, population
ORDER BY max_percentage_infected DESC;


-- 5. country with the highest death count per population
SELECT country,
population,
MAX(CAST(total_deaths AS SIGNED)) AS highest_death,
CONCAT(ROUND((MAX((total_deaths/ population))* 100) ,3), '%') AS death_per_pop_percentage
FROM c19_deaths
GROUP BY location, population
ORDER BY highest_death DESC;


-- 6.  What continent has the highest total death count per population?
SELECT continent,
       SUM(highest_death) AS sum_of_highest_deaths
FROM (
    SELECT continent, 
           country,
           MAX(total_deaths) AS highest_death
    FROM c19_deaths
    GROUP BY continent, country
) AS max_deaths_per_country
GROUP BY continent;

-- 7. What continent has the highest cases per population?
SELECT continent,
	SUM(highest_cases)
FROM (
		SELECT continent,
			country,
			MAX(total_cases) AS highest_cases
		FROM c19_deaths
		GROUP BY continent, country
) AS continent_cases
GROUP BY continent;

-- 8. Global numbers
	-- total global population, highest total infected, and highest percentage infected

SELECT SUM(population) AS total_population_world,
	SUM(max_cases) AS highest_total_world,
    CONCAT(ROUND(((SUM(max_cases) / SUM(population))*100), 2), '%') AS highest_percentage_world 
FROM ( 
SELECT MAX(total_cases) AS max_cases, population
FROM c19_deaths
GROUP BY country, population
) AS highest_cases_per_country;

-- 9. Highest in the world at any given date
-- highest case in 01 March 2020
SELECT country, total_cases AS highest_cases
FROM c19_deaths
WHERE date = '01/03/2020' AND total_cases = (
    SELECT MAX(total_cases)
    FROM c19_deaths
    WHERE date = '01/03/2020'
);
-- highest deaths in 01 March 2020
SELECT country, total_deaths AS highest_death
FROM c19_deaths
WHERE date = '01/03/2020' AND total_deaths = (
	SELECT max(total_deaths) FROM c19_deaths
    WHERE date = '01/03/2020'
);




