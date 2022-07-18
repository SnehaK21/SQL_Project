use SQLportfolio;
select * from [dbo].[CovidDeaths$]
select * from [dbo].[CovidVaccinations$]

-- 1. Total Cases vs Total Deaths (Death Percentage)
select location,date, total_cases, total_deaths, round((total_deaths/total_cases)*100,1) as DeathPercentage 
from [dbo].[CovidDeaths$] 
where location like 'India' and continent is not null
order by 1,2

--2. Total Cases vs Population (CasePercentage)
select location,date,Population, total_cases, round((total_cases/Population)*100,1) as CasePercentage
from [dbo].[CovidDeaths$] 
where location like 'India' and continent is not null
order by 1,2 Des

--3. Countries with the highest population rate compared to the population
select location, Population, sum(total_cases) as HighestInfectionCount, max(round((total_cases/Population)*100,1)) as PercentPopulationInfected
from [dbo].[CovidDeaths$] 
where continent is not null
group by location,population
order by PercentPopulationInfected Desc

--4. Countries with the highest death count per Population
select location,Max(cast(total_deaths as int)) as TotalDeathCount
from [dbo].[CovidDeaths$]
where continent is not null
group by location
order by TotalDeathCount Desc

--5. Group by continent with the highest death count per Population
select continent,Max(cast(total_deaths as int)) as TotalDeathCount
from [dbo].[CovidDeaths$]
where continent is not null
group by continent
order by TotalDeathCount Desc

--6. Global Data (Total Cases and Total Deaths)
select /*date*/ sum(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths,round((sum(cast(new_deaths as int))/sum(new_cases))*100,2) as DeathPercentage 
from [dbo].[CovidDeaths$] 
where continent is not null
--group by date
order by 1,2

-- 7. Total Population vs Vaccinations 		
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(cast(v.new_vaccinations as int)) OVER (PARTITION BY d.location order by d.location, d.date) as Rolling_count_of_vaccinations
from [dbo].[CovidDeaths$] d
join [dbo].[CovidVaccinations$] v
  On d.location=v.location and d.date=v.date
where d.continent is not null
order by 2,3

-- 8.1 CTE Common Table Expression

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, Rolling_count_of_vaccinations)
as
(select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(cast(v.new_vaccinations as int)) OVER (PARTITION BY d.location order by d.location, d.date) as Rolling_count_of_vaccinations
from [dbo].[CovidDeaths$] d
join [dbo].[CovidVaccinations$] v
  On d.location=v.location and d.date=v.date
where d.continent is not null
--order by 2,3
)

select * ,round((Rolling_count_of_vaccinations/Population)*100,2) from PopvsVac


-- 8.2 TEMP Table
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(cast(v.new_vaccinations as int)) OVER (PARTITION BY d.location order by d.location, d.date) as Rolling_count_of_vaccinations
from [dbo].[CovidDeaths$] d
join [dbo].[CovidVaccinations$] v
  On d.location=v.location and d.date=v.date
where d.continent is not null

select * , round((RollingPeopleVaccinated/Population)*100,2) as RollingPeopleVaccinatedPercent from #PercentPopulationVaccinated 

-- 9 Create View
create View PercentPopulationVaccination as 
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(cast(v.new_vaccinations as int)) OVER (PARTITION BY d.location order by d.location, d.date) as Rolling_count_of_vaccinations
from [SQLportfolio]..[CovidDeaths$] d
join [SQLportfolio]..[CovidVaccinations$] v
  On d.location=v.location and d.date=v.date
where d.continent is not null

select * from PercentPopulationVaccination