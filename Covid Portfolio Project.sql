

select *
from CovidDeath$
where continent is not null
order by 3,4

--select data that we are going to use
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeath$
where continent is not null
order by 1,2

--looking at total cases to total deaths
--shows percentage got covid
select location, date, population,total_cases,  total_deaths,	(total_cases/population)*100 as InfectionRate
from CovidDeath$
where location = 'china' and continent is not null
order by 1,2

--looking at countries with highest infection rate 
select location, population, max(total_cases) as highestInfectionCount,	Max((total_cases/population)*100) as InfectionRate
from CovidDeath$
where continent is not null
group by location, population
order by InfectionRate Desc

--showing countries with highest death count per population
select location,  max(cast(total_deaths as int)) as TotalDeathCount	
from CovidDeath$
where continent is not null
group by location
order by TotalDeathCount Desc

--Break things down by continent 
select continent,  max(cast(total_deaths as int)) as TotalDeathCount	
from CovidDeath$
where continent is NOT null
group by continent
order by TotalDeathCount Desc

--Showing continents with the highest death count per population
select continent,  max(cast(total_deaths as int)) as TotalDeathCount	
from CovidDeath$
where continent is NOT null
group by continent
order by TotalDeathCount Desc

--Global numbers
select date, SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeath,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeath$
where continent is not null
group by date
order by 1,2


--Looking at total population and vaccination
--use CTE 
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as 
(
select CovidDeath$.continent, CovidDeath$.location,CovidDeath$.date, CovidDeath$.population,CovidVaccinations$.new_vaccinations,
SUM(cast(CovidVaccinations$.new_vaccinations as numeric)) over (partition by CovidDeath$.location order by CovidDeath$.location, CovidDeath$.date) as RollingPeopleVaccinated
from CovidDeath$
join CovidVaccinations$
on CovidDeath$.location = CovidVaccinations$.location
and CovidDeath$.date = CovidVaccinations$.date
where CovidDeath$.continent is not null
--group by CovidDeath$.continent, CovidDeath$.location, CovidDeath$.population,CovidVaccinations$.new_vaccinations
--order by 2,3
)
select *,RollingPeopleVaccinated/population*100
from PopvsVac

--Temp Table
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent varchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select CovidDeath$.continent, CovidDeath$.location,CovidDeath$.date, CovidDeath$.population,CovidVaccinations$.new_vaccinations,
SUM(cast(CovidVaccinations$.new_vaccinations as numeric)) over (partition by CovidDeath$.location order by CovidDeath$.location, CovidDeath$.date) as RollingPeopleVaccinated
from CovidDeath$
join CovidVaccinations$
on CovidDeath$.location = CovidVaccinations$.location
and CovidDeath$.date = CovidVaccinations$.date
--where CovidDeath$.continent is not null
--group by CovidDeath$.continent, CovidDeath$.location, CovidDeath$.population,CovidVaccinations$.new_vaccinations
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualization
Create view PercentPopulationVaccinated as 
select CovidDeath$.continent, CovidDeath$.location,CovidDeath$.date, CovidDeath$.population,CovidVaccinations$.new_vaccinations,
SUM(cast(CovidVaccinations$.new_vaccinations as numeric)) over (partition by CovidDeath$.location order by CovidDeath$.location, CovidDeath$.date) as RollingPeopleVaccinated
from CovidDeath$
join CovidVaccinations$
on CovidDeath$.location = CovidVaccinations$.location
and CovidDeath$.date = CovidVaccinations$.date
where CovidDeath$.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated