SELECT * 
FROM PortfolioProjects..coronaDeaths$

Select location, date, total_cases,new_cases, total_deaths, population
From PortfolioProjects..coronaDeaths$
Where continent is not null
order by date

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you get covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..coronaDeaths$
Where location like '%Lithuania%'
order by 1,2


-- Looking at TOtal Cases vs Population
Select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
From PortfolioProjects..coronaDeaths$
--Where location like '%Lithuania%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjects..coronaDeaths$
--Where location like '%states%'
Where continent is not null
Group by Location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..coronaDeaths$
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- BY CONTINENT
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..coronaDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- Global numbers

Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProjects..coronaDeaths$
Where continent is not null
group by date
order by 1,2




--Looking at Total Population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
from PortfolioProjects..coronaDeaths$ dea
join PortfolioProjects..coronaVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3



-- USING CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, PeopleVaccinated)
AS
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
from PortfolioProjects..coronaDeaths$ dea
join PortfolioProjects..coronaVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
SELECT *, (PeopleVaccinated/Population)*100
FROM PopvsVac
order by 2,3



-- Temp Table
DROP table #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
from PortfolioProjects..coronaDeaths$ dea
join PortfolioProjects..coronaVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

select *, (PeopleVaccinated/Population)*100
from #PercentPopulationVaccinated
order by 2,3



-- Creating View to store data for later visualizations
USE PortfolioProjects 
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as bigint))
			OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
FROM PortfolioProjects..coronaDeaths$ dea
JOIN PortfolioProjects..coronaVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


SELECT *
FROM PercentPopulationVaccinated