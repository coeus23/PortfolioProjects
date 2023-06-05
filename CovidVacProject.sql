SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

-- Select Data that we are going to be using
--Select Location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..CovidDeaths
--ORDER BY 1,2

-- Looking at the total cases vs total deaths
Select Location, date, total_cases, total_deaths, (CAST(total_deaths AS decimal(12,2))/CAST(total_cases AS decimal(12,2))) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

CREATE VIEW totalcasesvspopulation AS
-- Looking at total cases vs population
-- Shows what percentage of population got covid
Select Location, date,population, total_cases, (CAST(total_cases AS decimal(12,2))/CAST(population AS decimal(12,2))) * 100 as percentpopulation
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
--ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
Select Location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100 as percentpopulationinfectedrate
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY percentpopulationinfectedrate DESC

--Showing countries with highest deaths per population

CREATE VIEW continentshighestdeaths AS
--Showing continents with the highest death count
Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location like '%states%'
GROUP BY continent
--ORDER BY TotalDeathCount DESC

CREATE VIEW globalnumbersdate AS
-- GLOBAL NUMBERS SELECTED DATE
Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/NULLIF(SUM(new_cases), 0) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
--ORDER BY 1,2
CREATE VIEW globalnumbertotals AS
-- GLOBAL NUMBERS TOTALS
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/NULLIF(SUM(new_cases), 0) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--ORDER BY 1,2

CREATE VIEW TotalPopVsVaccs AS
-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as INT)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3


-- USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
) 
Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac
Where new_vaccinations is not null




-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated
Where new_vaccinations is not null

-- Creating View to store data for later visualizations 
CREATE VIEW PercentPopulationVaccinated1 
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
