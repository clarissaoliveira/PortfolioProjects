/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM MyPortfolioProject..COVID_DEATHS
ORDER BY 3,4

SELECT *
FROM MyPortfolioProject..COVID_VACCINATION
ORDER BY 3,4

-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM MyPortfolioProject..COVID_DEATHS
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country


SELECT location, date, total_cases, total_deaths, cast(total_deaths as bigint) /NULLIF (cast( total_cases as float),0)*100 AS DeathPercentage
FROM MyPortfolioProject..COVID_DEATHS
WHERE location LIKE '%states%'
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid


SELECT location, date, population, total_cases, cast(total_cases as bigint) /NULLIF (cast(population as float),0)*100 AS PercentPopulationInfected
FROM MyPortfolioProject..COVID_DEATHS
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(cast(total_cases as bigint)) AS HighestInfectionCount, MAX(cast(total_cases as bigint) /NULLIF (cast(population as float),0))*100 AS PercentPopulationInfected
FROM MyPortfolioProject..COVID_DEATHS
GROUP BY population, location
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as bigint)) AS TotalDeathCount
FROM MyPortfolioProject..COVID_DEATHS
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as bigint)) AS TotalDeathCount
FROM MyPortfolioProject..COVID_DEATHS
WHERE REPLACE(continent, ' ','')<>''
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

Select SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE REPLACE(continent, ' ','')<>''
----Group By date
order by 1,2



Select date,
	SUM(cast(new_cases as float)) as total_cases, 
	SUM(cast(new_deaths as float)) as total_deaths, 
	SUM(cast(new_deaths as float))/NULLIF(SUM(cast(new_cases as float)),0)*100 as DeathPerc
From PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE REPLACE(continent, ' ','')<>''
GROUP BY date
ORDER BY CAST(date as date)


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM (CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM MyPortfolioProject..COVID_DEATHS dea
JOIN MyPortfolioProject..COVID_VACCINATION vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE REPLACE(dea.continent, ' ','')<>''
ORDER BY 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM (CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM MyPortfolioProject..COVID_DEATHS dea
JOIN MyPortfolioProject..COVID_VACCINATION vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE REPLACE(dea.continent, ' ','')<>''
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/NULLIF(Population,0))*100
FROM PopvsVac


-- Creating View to store data for later visualizations

CREATE VIEW TotalDeathsPerContinent AS
SELECT continent, MAX(cast(total_deaths as bigint)) AS TotalDeathCount
FROM MyPortfolioProject..COVID_DEATHS
WHERE REPLACE(continent, ' ','')<>''
GROUP BY continent


SELECT *
FROM TotalDeathsPerContinent
