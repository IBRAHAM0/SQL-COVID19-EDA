-- ==================================================== Covid-19 Data Exploration =====================================================

-- Creating the "covid_death" table

CREATE TABLE covid_deaths (    
	continent  Text, 
    location  Text, 
    date  Date, 
    population  bigint, 
    total_cases  Int, 
    new_cases  Int, 
    total_deaths  Int, 
    new_deaths  Int
	)


-- Creating the "vaccinations" table

CREATE TABLE vaccinations (    
	continent  Text, 
    location  Text, 
    date  Date, 
    new_vaccinations  Int
	)


-- Importing records from the source into the "covid_death" table
	
COPY covid_deaths
FROM 'D:\Covid_Deaths.csv'
DELIMITER ','
CSV HEADER;


-- Importing records from the source into the "vaccinations" table

COPY vaccinations
FROM 'D:\vaccincations.csv'
DELIMITER ','
CSV HEADER;


-- A quick overview of the data 
SELECT * 
FROM covid_deaths;

SELECT * 
FROM vaccinations;



-- Review the data of interest
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE continent IS NOT NULL 
ORDER BY 1,2;

-- Total Deaths of Total Cases % in Egypt
SELECT Location, date, total_cases,total_deaths, ROUND((total_deaths :: numeric/total_cases),2) AS DeathPercentage
FROM covid_deaths
WHERE location ILIKE '%egypt%'
AND continent IS NOT NULL
ORDER BY 1,2;

--  Total Cases of Population % in Egypt 
SELECT Location, date, total_cases, population, Round((total_cases :: numeric/population),5) AS DeathPercentage
FROM covid_deaths
WHERE location ILIKE '%egypt%'
AND continent IS NOT NULL 
ORDER BY 1,2;
	

 -- Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS top_infection,  Max((total_cases :: numeric/population))*100 AS percent_population
FROM covid_deaths
GROUP BY Location, Population
ORDER BY percent_population desc nulls last;


-- Countries with Highest Death Count per Population
SELECT Location, MAX(Total_deaths) AS total_Death_count
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY Location
ORDER BY total_Death_count desc nulls last;


-- continents with the highest death count per population
SELECT continent, MAX(Total_deaths) AS total_Death_count
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY total_Death_count desc;

-- GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
		ROUND(SUM(new_deaths :: numeric)/SUM(New_Cases)*100,3) AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- view vaccinations data
SELECT *
FROM vaccinations
LIMIT 20;


--  Vaccinations vs Population
-- Shows the Percentage of the Population that has received at least one Covid Vaccine
WITH vac_of_pop AS (
	SELECT cd.continent, cd.location, cd.date, population, new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION BY cd.Location ORDER BY cd.location, cd.Date) AS rolling_vaccinated
FROM covid_deaths AS cd
JOIN vaccinations AS vac
USING(location,date)
	)
SELECT *, ROUND((rolling_vaccinated :: numeric / population)*100, 4) AS vac_percentage
FROM vac_of_pop
WHERE (continent, new_vaccinations) IS NOT NULL
ORDER BY 5 DESC;

-- Creatr View to store data for later visualizations
CREATE VIEW vac_of_pop AS
SELECT cd.continent, cd.location, cd.date, population, new_vaccinations
	, SUM(new_vaccinations) OVER (PARTITION BY cd.Location ORDER BY cd.location, cd.Date) AS rolling_vaccinated
FROM covid_deaths AS cd
JOIN vaccinations AS vac
USING(location,date);

SELECT *, ROUND((rolling_vaccinated :: numeric / population)*100, 4) AS vac_percentage
FROM vac_of_pop
WHERE (continent, new_vaccinations) IS NOT NULL
ORDER BY 2,3 DESC;



































































