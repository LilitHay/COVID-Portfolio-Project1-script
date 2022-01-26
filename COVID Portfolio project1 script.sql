SELECT *
FROM noble-district-333321.PortfolioProjects.Deaths
WHERE continent IS NOT NULL
ORDER BY location, date
LIMIT 1000;

/* SELECT *
FROM noble-district-333321.PortfolioProjects.Vaccinations
ORDER BY location, date
LIMIT 1000 */

--Selecting all info

SELECT location, date,population, total_cases,new_cases,total_deaths
FROM noble-district-333321.PortfolioProjects.Deaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- Looking at Total_cases vs Total_deaths
--Likelihood of dying after COVID19 infection

SELECT location, date, total_cases,total_deaths, ROUND((total_deaths/total_cases)*100, 2) as DeathPercentage
FROM noble-district-333321.PortfolioProjects.Deaths
WHERE location = 'Croatia' AND continent IS NOT NULL
ORDER BY location, date


-- Loooking at total_cases vs population
-- SHows what % of population got COVID

SELECT location, date, total_cases,population, ROUND((total_cases/population)*100, 2) as PercentageOfInfection
FROM noble-district-333321.PortfolioProjects.Deaths
WHERE location = 'Croatia' AND continent IS NOT NULL
ORDER BY location, date

--Looking Countries with highest infection rate compared to population

SELECT location, population,MAX(total_cases) AS HighestInfectionCount, ROUND(((MAX(total_cases)/population)*100),1) AS PercentPopulationInfected
FROM noble-district-333321.PortfolioProjects.Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing the countries with the highest death count per population

SELECT location, MAX(total_deaths) AS HighestDeathsCount
FROM noble-district-333321.PortfolioProjects.Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathsCount DESC

-- Braking down everything by continent
--Showing the continent with the highest death count per population

/* SELECT location, MAX(total_deaths) AS HighestDeathsCount
FROM noble-district-333321.PortfolioProjects.Deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeathsCount DESC  */

SELECT continent, MAX(total_deaths) AS HighestDeathsCount
FROM noble-district-333321.PortfolioProjects.Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathsCount DESC

--Global members

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) as total_deaths, ROUND((SUM(new_deaths)/SUM(new_cases))*100, 2) AS PercentOfNewDeaths
FROM noble-district-333321.PortfolioProjects.Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

-- Showing globally total death percentage
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) as total_deaths, ROUND((SUM(new_deaths)/SUM(new_cases))*100, 2) AS PercentOfNewDeaths
FROM noble-district-333321.PortfolioProjects.Deaths
WHERE continent IS NOT NULL








 
--Looking total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(vac.new_vaccinations) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollPeopleVaccinated
FROM noble-district-333321.PortfolioProjects.Vaccinations as vac
JOIN noble-district-333321.PortfolioProjects.Deaths as dea
    ON vac.location = dea.location AND vac.date=dea.date

WHERE dea.continent IS NOT NULL
--GROUP BY dea.continent, dea.location
ORDER BY dea.location, dea.date;




--Using CTE

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

--TEMP table
CREATE TEMPORARY TABLE temp_PercentPopulationVaccinated

(Continent STRING(255),
Location STRING(255),
Date Date,
Population NUMERIC(20),
New_vaccinations NUMERIC(20),
RollPeopleVaccinated NUMERIC(20)
);

INSERT INTO temp_PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(vac.new_vaccinations) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollPeopleVaccinated
FROM noble-district-333321.PortfolioProjects.Vaccinations as vac
JOIN noble-district-333321.PortfolioProjects.Deaths as dea
    ON vac.location = dea.location AND vac.date=dea.date

WHERE dea.continent IS NOT NULL;

SELECT *, ROUND((RollPeopleVaccinated/population)*100,2)
FROM temp_PercentPopulationVaccinated;




