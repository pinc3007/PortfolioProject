Select *
From PortfolioProject..CovidDeath
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select data that are going to be used

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeath
order by 1,2

--Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
Where location like '%emirates%'
order by 1,2

--Looking at Total Cases vs Population (what % of population got Covid)

Select location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
From PortfolioProject..CovidDeath
Where location like '%emirates%'
order by 1,2


-- Looking at Countries with Highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfection, Max((total_cases/population))*100  as HighestRate
From PortfolioProject..CovidDeath
-- Where location like '%emirates%'
Group by location, population 
order by HighestRate desc

-- showing countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as HighestDeath
From PortfolioProject..CovidDeath
--Where location like '%emirates%'
Where continent is not null
Group by location 
order by HighestDeath desc


--Breaking downt to continents
--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as HighestDeath
From PortfolioProject..CovidDeath
--Where location like '%emirates%'
Where continent is not null
Group by continent
order by HighestDeath desc


--Global numbers

Select   SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, SUM(cast(new_deaths as int))/
SUM(new_cases)*100 as DeathPercentageGlobaly
From PortfolioProject..CovidDeath
--Where location like '%emirates%'
Where continent is not null
--Group by date
order by 1,2


--Looking total population vs vaccinations

--Use CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select*, (RollingPeopleVaccinated/population)*100
From PopvsVac



-- Temp table

Drop Table if exists #PercentPopulationVaccinated

Create table #PercentPopulationVaccinated

(
continent nvarchar(255),
locatio nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


 Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select*, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--Creating view to store data for later visualizsations

Create View PercentPopulationVaccinated as 

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated