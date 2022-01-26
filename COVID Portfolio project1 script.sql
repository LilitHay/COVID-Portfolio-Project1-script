/* For COVID19 analysis had been used dataset available in "Our World in data" from the period of January 24, 2020 - January 24, 2022.
Link to Dataset: https://ourworldindata.org/covid-deaths
All analysis was arranged with BigQuery data warehouse.
*/

-- Checking COVID19 Deaths dataset

SELECT *
FROM noble-district-333321.PortfolioProjects.Deaths
WHERE continent IS NOT NULL
ORDER BY location, date
LIMIT 1000;


-- Checking COVID19 vaccination dataset
SELECT *
FROM noble-district-333321.PortfolioProjects.Vaccinations
ORDER BY location, date
LIMIT 1000 


-- Selecting required info for starting the analysis

SELECT location, date,population, total_cases,new_cases,total_deaths
FROM noble-district-333321.PortfolioProjects.Deaths
WHERE continent IS NOT NULL
ORDER BY location, date



-- Total Cases vs Total Deaths
-- Likelihood of dying after getting infected with COVID19

SELECT location, date, total_cases,total_deaths, ROUND((total_deaths/total_cases)*100, 2) as DeathPercentage
FROM noble-district-333321.PortfolioProjects.Deaths
WHERE location = 'Croatia' AND continent IS NOT NULL
ORDER BY location, date


--  Total Cases vs Population
-- Shows what percentage of population infected with COVID19 in Worldwide and Croatia in specific case

SELECT location, date, total_cases,population, ROUND((total_cases/population)*100, 2) as PercentageOfInfection
FROM noble-district-333321.PortfolioProjects.Deaths
WHERE continent IS NOT NULL
ORDER BY location, date

SELECT location, date, total_cases,population, ROUND((total_cases/population)*100, 2) as PercentageOfInfection
FROM noble-district-333321.PortfolioProjects.Deaths
WHERE location = 'Croatia' AND  continent IS NOT NULL
ORDER BY location, date

-- Infection Rate vs Population
-- Looking at the countries with Highest Infection Rate Per Population

SELECT location, population,MAX(total_cases) AS HighestInfectionCount, ROUND(((MAX(total_cases)/population)*100),1) AS PercentPopulationInfected
FROM noble-district-333321.PortfolioProjects.Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Deaths count vs Population
--Showing the countries with the Highest Death Count Per Populationn

SELECT location, MAX(total_deaths) AS HighestDeathsCount
FROM noble-district-333321.PortfolioProjects.Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathsCount DESC


-- ANALYSING BY CONTINENT
--Showing the Continent with the Highest Death Count Per Populationn

SELECT continent, MAX(total_deaths) AS HighestDeathsCount
FROM noble-district-333321.PortfolioProjects.Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathsCount DESC




-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) as total_deaths, ROUND((SUM(new_deaths)/SUM(new_cases))*100, 2) AS PercentOfNewDeaths
FROM noble-district-333321.PortfolioProjects.Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date


-- Showing Total Death Rate globally
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) as total_deaths, ROUND((SUM(new_deaths)/SUM(new_cases))*100, 2) AS PercentOfNewDeaths
FROM noble-district-333321.PortfolioProjects.Deaths
WHERE continent IS NOT NULL


--Total Population vs Vaccinations
--Shows Number of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(vac.new_vaccinations) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollPeopleVaccinated
FROM noble-district-333321.PortfolioProjects.Vaccinations as vac
JOIN noble-district-333321.PortfolioProjects.Deaths as dea
    ON vac.location = dea.location AND vac.date=dea.date

WHERE dea.continent IS NOT NULL
--GROUP BY dea.continent, dea.location
ORDER BY dea.location, dea.date;




-- Using CTE to perform Calculation on Partition By in previous query and looking at the Percentage Of Vaccined People

WITH CTE_PopvsVac
AS (
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(vac.new_vaccinations) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollPeopleVaccinated
FROM noble-district-333321.PortfolioProjects.Vaccinations as vac
JOIN noble-district-333321.PortfolioProjects.Deaths as dea
    ON vac.location = dea.location AND vac.date=dea.date

WHERE dea.continent IS NOT NULL
)
SELECT *, ROUND((RollPeopleVaccinated/population)*100,3) AS PercentageOfVaccinedPeople
FROM CTE_PopvsVac;


