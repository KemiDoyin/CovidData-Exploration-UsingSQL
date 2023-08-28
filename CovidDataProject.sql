--Get all data from covid deaths and vaccinations--

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select *
from PortfolioProject..CovidVaccinations
order by 3,4



select location, date, total_cases, new_cases, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--total deaths versus total cases in Nigeria--

--percent of dying if one contracts covid--

select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..CovidDeaths
where location like 'Nigeria' and continent is not null
order by 1,2 


--looking at total cases vs population--

--percent of population that contracted covid--

select location, date, population, total_cases,  (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulation
from PortfolioProject..CovidDeaths
--where location like 'Nigeria'
order by 1,2 


--countries with highest infection rate compared to population--

select location, population, max(cast(total_cases as int)) as HighestInfectionCount,  max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

--countries with the highest death count per population--

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
group by location
order by TotalDeathCount desc

--the above query gives world as a location whereas it is not meant to be--
--looking at the fisrt query, we'd have to get the data where the continent is not null--

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc



--we can get our data by continent--

--continents with highest deathcount--

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

--global numbers--

--death percent across the world--
select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(nullif(new_cases,0)) as DeathPercent
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2 


--Join Covid deaths and vaccination together--

Select *
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date

--total population vs total vaccination

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3

--use cte--

With PopvsVac ( continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp table--

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Loation nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--create views to store data--

create view PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null


select*
from PercentPopulationVaccinated