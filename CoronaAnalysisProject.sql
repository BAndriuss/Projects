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


-- Looking at Total Cases vs Population
Select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
From PortfolioProjects..coronaDeaths$
order by 1,2

-- Global numbers
-- total by date
Select date, sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProjects..coronaDeaths$
Where continent is not null
group by date
order by 1,2

-- total /// table 1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjects..coronaDeaths$
where continent is not null 


-- BY CONTINENT /// table 2
Select continent, Sum(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProjects..coronaDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- Looking at Countries with Highest Infection Rate compared to Population /// Table 3
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjects..coronaDeaths$
Where continent is not null
Group by Location, population
order by PercentPopulationInfected desc

--by date /// Table 4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjects..coronaDeaths$
Group by Location, Population, date
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..coronaDeaths$
Where continent is not null
Group by Location
order by TotalDeathCount desc



--Looking at Total Population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as Doses_administered
from PortfolioProjects..coronaDeaths$ dea
join PortfolioProjects..coronaVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3



-- USING CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, Doses_administered)
AS
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as Doses_administered
from PortfolioProjects..coronaDeaths$ dea
join PortfolioProjects..coronaVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
SELECT *, (Doses_administered/Population)*100/2 as PercentPeopleVaccinated -- /2 because average of 2 doses is needed for person to be vaccinated
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

select *, (PeopleVaccinated/Population)*100 as PercentPopulationVaccinated
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




