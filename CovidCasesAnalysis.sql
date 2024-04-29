-- Looking into data that we are using 
SELECT *
FROM CovidCaseAnalysis..CovidDeaths
ORDER BY  1, 2;

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location, date , total_cases, total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 as DeathPercentage
FROM CovidCaseAnalysis..CovidDeaths
WHERE location like 'India'
ORDER BY  1, 2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT Location, date , total_cases, total_deaths, (CAST(total_cases AS float)/CAST(population AS float))*100 as CasePercentage
FROM CovidCaseAnalysis..CovidDeaths
ORDER BY  1, 2;

-- Looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(CAST(total_cases AS float)) as total_cases , MAX(CAST(total_cases AS float)/CAST(population AS float))*100 as PercentPopulationInfected
FROM CovidCaseAnalysis..CovidDeaths
WHERE continent IS NOT NUll
GROUP BY location, population
ORDER BY  PercentPopulationInfected desc;

-- Showing Countries with highest death count per population
SELECT Location, MAX(CAST(total_deaths AS int)) as totaldeathcounts
FROM CovidCaseAnalysis..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY  totaldeathcounts desc;

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing highest deaths in continent 
SELECT continent, MAX(CAST(total_deaths AS int)) as totaldeathcounts
FROM CovidCaseAnalysis..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeathcounts desc;
 

 -- Looking at how many people are vaccinated
 
WITH peoplevac (continent, location, date, population, new_vaccinations, PeopleVaccinated)
AS(

 SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as PeopleVaccinated
 FROM CovidCaseAnalysis..CovidDeaths d
 JOIN CovidCaseAnalysis..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
 WHERE d.continent IS NOT NULL

)

SELECT *, (PeopleVaccinated/population)*100 FROM peoplevac;

-- with TEMP Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
PeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
 SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as PeopleVaccinated
 FROM CovidCaseAnalysis..CovidDeaths d
 JOIN CovidCaseAnalysis..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
 WHERE d.continent IS NOT NULL

 SELECT *, (PeopleVaccinated/population)*100 FROM #PercentPopulationVaccinated;
