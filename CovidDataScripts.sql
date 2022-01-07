Select *
	From PortfolioProject..CovidDeaths
	order by 3,4

--Select *
--	From PortfolioProject..CovidVaccinations
--	order by 3,4

-- Selecting the data that we're going to be using ordered by location and date.

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
	order by 1,2


-- Looking at total cases per country vs total deaths
-- shows the liklihood of dying if you contract covid-19 in the US ~ january 6th 2022

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
	order by 1,2

-- looking at total cases vs population
-- shows what % of the population has contracted covid

Select location, date, total_cases, population, (total_cases/population)*100 as infection_rate
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
	order by 1,2

	-- looking at country with highest infection rate compared to total population

Select location, population, MAX(total_cases) as highest_infection_count, Max((total_cases/population))*100 as percent_infected
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Group by location, population
	order by percent_infected desc

-- showing countries with highest death count per population

Select location, max(population) as max_population, max(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
-- Where location like '%states%'
Group by location
	order by total_death_count desc

	-- Breaking things down by continent
	-- Shows deaths per country vs max population
Select location, max(population) as max_population, max(cast(total_deaths as int)) as total_death_count, max(total_cases) as total_cases
From PortfolioProject..CovidDeaths
Where continent is null
-- Where location like '%states%'
Group by location
	order by total_death_count desc


--- GLOBAL NUMBERS

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as death_percentage
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
where continent is not null
--Group by date
order by 1,2

-- we see 297188901 cases and 5440354 deaths with a mortality rate of %1.8306

Select  location, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as death_percentage
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
where continent is not null
Group by location
order by 1,2

Select  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as death_percentage
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
where continent is not null
Group by date
order by 1,2

-- looking at total population vs new vaccinations per day

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
	dea.date) as rolling_vaccination_count
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- WITH CTE / Temp table

With pops_vac (continent, location, date, population, new_vaccinations, rolling_vaccination_count)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
	dea.date) as rolling_vaccination_count
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (rolling_vaccination_count/population)*100
From pops_vac

-- temp table method


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccination_count numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
	dea.date) as rolling_vaccination_count
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (rolling_vaccination_count/population)*100 as VaccinatedPercentage
From #PercentPopulationVaccinated


-- creating views to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
	dea.date) as rolling_vaccination_count
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Create View GlobalDeathPercent as 
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as death_percentage
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
where continent is not null
--Group by date
--order by 1,2

Create View NationalDeathRate as 
Select  location, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as death_percentage
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
where continent is not null
Group by location
--order by 1,2



Create View NationInfectionRate as 
Select location, date, total_cases, population, (total_cases/population)*100 as infection_rate
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--order by 1,2