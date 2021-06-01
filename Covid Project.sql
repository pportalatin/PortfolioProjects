Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4


--Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


--Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population 
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population


Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT 
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2
go


-- Use Stored Procedure to easily get Death Counts

if exists (select * from sys.procedures where name = 'TotalDeaths')
drop proc TotalDeaths
go
Create Proc TotalDeaths(@Location nvarchar(100)) as
begin
	if exists( Select * from [dbo].[CovidDeaths] where Location = @Location)
	BEGIN
		Select Location, population, max(total_deaths) as TotalDeaths 
		from [dbo].[CovidDeaths]
		where Location = @Location
		group by Location, population
	END
end
go

Execute TotalDeaths @Location = 'United States'


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(int, V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths D
Join PortfolioProject..CovidVaccinations V
	On D.location = V.location
	and D.date = V.date
where D.continent is not null 
order by 2,3


-- Use CTE


With PopvsVac (Continent, Location, Data, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths D
Join PortfolioProject..CovidVaccinations V
	On D.location = V.location
	and D.date = V.date
where D.continent is not null 
-- order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100 as VaccinationPercentage
from PopvsVac



--Use TEMP Table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by dea.Location Order by D.location, D.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths D
Join PortfolioProject..CovidVaccinations V
	On D.location = V.location
	and D.date = V.date
where D.continent is not null 
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
from #PercentPopulationVaccinated

 
--Create View for later visualizations


if exists( Select * from sys.views where name = 'PercentPopulationVaccinated')
drop View PercentPopulationVaccinated
go
Create View PercentPopulationVaccinated as
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths D
Join PortfolioProject..CovidVaccinations V
	On D.location = V.location
	and D.date = V.date
where D.continent is not null 
--order by 2,3

Select * from
PercentPopulationVaccinated


--View of Global Numbers

Create View V_GlobalNumbers as
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
Group by location
--order by TotalDeathCount desc

Select *
from V_GlobalNumbers