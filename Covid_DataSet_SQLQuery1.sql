SELECT *
FROM portfolio_project..CovidDeaths
where continent is Not NULL

--SELECT *
--FROM portfolio_project..CovidVaccine

SELECT location,date, total_cases, new_cases,total_deaths, population
FROM portfolio_project..CovidDeaths
order by 1, 2

--Shows likelyhood of dying if you contact covid in your country
SELECT location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolio_project..CovidDeaths
Where location = 'India'
order by 1, 2

--Toatal cases vs population
--Shows percentage of people contacted covid relative to the population
SELECT location,date, population, total_cases, (total_cases/population)*100 as CovidContactPercentage
FROM portfolio_project..CovidDeaths
Where location = 'India'
order by 1, 2

-- Looking at countries with heighest infection rate
SELECT location, population, MAX(total_cases) as Highestinfectedpopulation, MAX((total_cases/population))*100 as HighestInfectedRate
FROM portfolio_project..CovidDeaths
group by location, population
order by HighestInfectedRate desc

-- Countries with heighest death count per population
SELECT location, population, MAX(cast(total_deaths as int)) as Highestdeathcount
FROM portfolio_project..CovidDeaths
where continent is Not NULL
group by location, population
order by Highestdeathcount desc

--Global Numbers

SELECT  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeathCount, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Death_Percentage
FROM portfolio_project..CovidDeaths
where continent is Not NULL

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeathCount, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Death_Percentage
FROM portfolio_project..CovidDeaths
where continent is Not NULL
group by date
order by date


-- Looking at total population vs total vaccination
With PopulationVSvaccination (Continent, Location, Date, Population, New_Vaccination, Rollingpeoplevaccinated )
as
(
SELECT det.continent, det.location, det.date, det.population, vac.new_vaccinations,
	SUM(cast( vac.new_vaccinations as float)) OVER (Partition BY det.location order by det.location, det.date) as Rollingpeoplevaccinated
FROM portfolio_project..CovidDeaths as det
Join portfolio_project..CovidVaccination as vac
	ON det.date = vac.date and det.location = vac.location
where det.continent is Not NULL
)
Select *, (Rollingpeoplevaccinated/Population)*100 as PercentageOfPopulationVaccinated
From PopulationVSvaccination
Order by Location, Date