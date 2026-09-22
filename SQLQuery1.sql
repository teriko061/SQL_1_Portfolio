-- Table sorted by columns location and date
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

-- Choosing data for using, sorted by location and date
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Total_cases vs total_deaths
SELECT location, date, total_cases, total_deaths, (total_cases * 1.0/total_deaths)*100 as DeathsPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Probability of death after infection, filtered by country
SELECT location, date, total_cases, total_deaths, (total_cases *1.0/total_deaths)*100 as DeathsPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%czech%'
ORDER BY 1, 2

-- Percentage of population that has been infected
SELECT location, date, total_cases, population, (total_cases * 1.0 / population) * 100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%czech%'
ORDER BY 1, 2

-- Countries with the highest number of infected people relative to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases * 1.0 / population)) * 100 as PercentPoplulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPoplulationInfected desc

-- Countries with the highest percentage of deaths per population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Total deaths by continent
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Globally
SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(CONVERT(float, new_deaths))/SUM(cast(new_cases as float)) *100 as DeathsPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

-- Joining two tables
SELECT *
FROM PortfolioProject..CovidVactinations

SELECT *
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVactinations vac
	on dea.location = vac.location
	and dea.date = vac.date 

-- Number of vaccinated vs population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVactinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- Two ways to use the RollingPeopleVaccinated calculation. Using a CTE (Common Table Expression) or TEMP table:

-- 1. Using CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVactinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/(CONVERT(float, Population))*100)
FROM PopvsVac

-- 2. TEMP table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVactinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/(CONVERT(float, Population))*100)
FROM #PercentPopulationVaccinated

-- Create view for next visualisation
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVactinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
