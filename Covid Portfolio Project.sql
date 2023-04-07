Select * 
From [Portfolio Project]..CovidDeaths
Where Total_cases is not null and Total_Deaths is Not NULl
Order by 3, 4

--Select * 
--From [Portfolio Project]..CovidVacinations
--Order by 3, 4

Select Location, date, Total_cases, New_cases, total_deaths, Population
From [Portfolio Project]..CovidDeaths
Order By 1,2



-- Looking at Total Cases vs Total Deaths

Select Location, date, Total_cases,total_deaths, (total_deaths/Total_cases)*100 as DeathPercentage 
From [Portfolio Project]..CovidDeaths
Where location like '%states%'
Order By 1,2

--Alter Table covidDeaths 
--Alter Column Total_deaths bigint;


--Looking at total cases vs population
--Shows What percentage of population got covid

Select Location, date, Population, Total_cases, (total_cases/population)*100 as PercentageOfPopulation
From [Portfolio Project]..CovidDeaths
Where location like '%states%'
Order By 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location,Population, MAX(Total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentageOfInfection
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Group BY Population, Location
Order By PercentageOfInfection Desc

--Showing the Countries with the Highest Death Count Per Population 

Select Location, MAX(total_deaths) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where total_deaths is not null
Group BY Location
Order By TotalDeathCount Desc

-- LETS BREAK THINGS DOWN BY CONTINENT 

Select location, MAX(total_deaths) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where total_deaths is not null
Group BY Location
Order By TotalDeathCount Desc

--Showing continents with the Highest death count per population 

Select Continent, MAX(total_deaths) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where total_deaths is not null
Group BY Continent
Order By TotalDeathCount Desc

--Global Numbers 



Select  SUM(cast(New_Cases as int)) as Total_Cases, SUM(cast(New_Deaths as int)) as Total_Deaths, Coalesce(NullIf(SUM(cast(New_Deaths as int)),0),0/NulliF(SUM(cast(New_Cases as int)),0),0) as DeathPercentage 
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
Order By 1,2

--Select New_cases, New_deaths
--From [Portfolio Project]..CovidDeaths
--Order by 1,2
--
--Looking for Total Population vs Vaccinations 

--Alter Table CovidVaccinations
--Alter Column New_Vaccinations bigint;

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.New_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--	(RollingPeopleVaccinated/Population)*100
From [Portfolio Project]..CovidDeaths as dea
join [Portfolio Project]..CovidVaccinations as vac 
	on dea.location = vac.location 
	and dea.date = vac.date 
Where vac.new_vaccinations is not null
	and dea.continent is not null
order By 2,3 

-- USE CTE 

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.New_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/Population)*100
From [Portfolio Project]..CovidDeaths as dea
join [Portfolio Project]..CovidVaccinations as vac 
	on dea.location = vac.location 
	and dea.date = vac.date 
Where vac.new_vaccinations is not null
	and dea.continent is not null
--order By 2,3 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac



--Temp Table 

Drop Table IF Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent Nvarchar(255),
Location Nvarchar(255),
Date Datetime,
Population Numeric, 
New_vaccinations Numeric, 
RollingPeopleVaccinated Numeric
)

Insert Into #PercentPopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.New_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--	(RollingPeopleVaccinated/Population)*100
From [Portfolio Project]..CovidDeaths as dea
join [Portfolio Project]..CovidVaccinations as vac 
	on dea.location = vac.location 
	and dea.date = vac.date 
--Where vac.new_vaccinations is not null
--and dea.continent is not null
--order By 2,3 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to store Data for later visualizations 

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.New_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--	(RollingPeopleVaccinated/Population)*100
From [Portfolio Project]..CovidDeaths as dea
join [Portfolio Project]..CovidVaccinations as vac 
	on dea.location = vac.location 
	and dea.date = vac.date 
Where vac.new_vaccinations is not null
and dea.continent is not null
--order By 2,3 

Create View GlobalNumbers as 
Select  SUM(cast(New_Cases as int)) as Total_Cases, SUM(cast(New_Deaths as int)) as Total_Deaths, Coalesce(NullIf(SUM(cast(New_Deaths as int)),0),0/NulliF(SUM(cast(New_Cases as int)),0),0) as DeathPercentage 
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
--Order By 1,2

Create View DeathCountByContinent as
Select Continent, MAX(total_deaths) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where total_deaths is not null
Group BY Continent
--Order By TotalDeathCount Desc

Create View DeathByCountry as 
Select Location, MAX(total_deaths) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where total_deaths is not null
Group BY Location
--Order By TotalDeathCount Desc

Create View InfectionRatePerCountry as 
Select Location,Population, MAX(Total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentageOfInfection
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Group BY Population, Location
--Order By PercentageOfInfection Desc