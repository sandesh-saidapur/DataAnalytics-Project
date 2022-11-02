--COVID DEATHS

Select *
From PortfolioProject..CovidDeaths
order by 1,2

Select Location, date, total_cases, new_cases, total_deaths
From PortfolioProject..CovidDeaths
order by 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
From PortfolioProject..CovidDeaths
Where location like '%india%'
order by 1,2

--Total Cases vs Population
Select Location, date, total_cases, Population, (total_cases/population)*100 AS infected_percentage
From PortfolioProject..CovidDeaths
Where location like '%india%'
order by 1,2

--Countries with highest infection rates compared to their population
Select Location,MAX(total_cases) AS HighestInfectionCount, Population, Max((total_cases/population))*100 AS percent_population_infected
From PortfolioProject..CovidDeaths
group by location, population
order by percent_population_infected DESC

--Countries with highest death count per population
Select Location, MAX(cast(Total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by location
order by total_death_count DESC

--Countries with total cases found till date
Select Location, MAX(cast(Total_cases as int)) as total_cases
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by location
order by total_cases DESC

--Showing continents with total deaths 
Select continent, MAX(cast(Total_cases as int)) as total_cases
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by continent
order by total_cases DESC

--Deaths across the world from day one
Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Death percent across the entire world due to Covid
Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--COVID VACCINATIONS

select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

--Total people VS vaccinated people
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS rolling_number_of_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not NULL
order by 2,3

--Way1:Using CTE to find "what percent of population has been vaccinated w.r.t location"
With PopluationVSVaccination ( continent, location, date, population, new_vaccinations, rolling_number_of_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS rolling_number_of_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not NULL
)
Select *, (rolling_number_of_people_vaccinated/population)*100 as percent_of_population_vaccinated
from PopluationVSVaccination

--Way2:Using TempTable to find "what percent of population has been vaccinated w.r.t location"
DROP table if exists #percentagepopulationvaccinated
Create table #percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_number_of_people_vaccinated  numeric
)
Insert into #percentagepopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS rolling_number_of_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not NULL
Select *, (rolling_number_of_people_vaccinated/population)*100 as percent_of_population_vaccinated
from #percentagepopulationvaccinated
--THIS THROWS AN ERROR, NOT ABLE TO FIND OUT THE BUG






