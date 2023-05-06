select *
from CovidDeaths

select new_cases
from CovidDeaths

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths
from CovidDeaths

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

-- Looking at Total cases vs Total deaths
-- shows the likelihood of dying from covid 
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%states%'
order by 1,2

alter table coviddeaths
alter column total_cases float

--total_cases vs population
--shows % of people that got covid

select location,date,population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where location like '%states%'
order by 1,2

--countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
--where location like '%states%'
group by location,population
order by PercentPopulationInfected desc

--countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--breaking things down by continent

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

-- showing the continents with highest death count

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- breaking into global 

select date,sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2


select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,sum(new_deaths)/sum(new_cases) *100 as DeathPercentage
from CovidDeaths
where new_cases !=0
and continent is not null
--group by date
order by 1,2

--TOTAL POPULATION VS VACCINATION

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float))over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population)*100
from CovidDeaths as dea
join CovidVaccination as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--METHOD 1: USE CTE

WITH PopvsVac (continent,location,date,population,new_vaccination,rollingpeoplevaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float))over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population)*100
from CovidDeaths as dea
join CovidVaccination as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from PopvsVac

--METHOD 2:  use temp table

drop table if exists #PercentPeopleVccinated
create table #PercentPeopleVccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)


insert into #PercentPeopleVccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float))over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population)*100
from CovidDeaths as dea
join CovidVaccination as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #PercentPeopleVccinated


--CREATING VIEW TO STORE DATE FOR LATER VISUALISATION

create view PercentPeopleVccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float))over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population)*100
from CovidDeaths as dea
join CovidVaccination as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPeopleVccinated