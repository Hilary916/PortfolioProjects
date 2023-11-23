/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 2,3 


-- To select the data we are to use 


Select location, date, total_cases, new_cases,total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

-- Total cases versus Total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Order by 1,2


-- Total Cases Versus Total Deaths in the United Kingdom


Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%kingdom%'
Order by 1,2


-- Total Cases Versus Population in the United Kingdom


Select location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentageInfected
From PortfolioProject..CovidDeaths
where location like '%kingdom%'
Order by 1,2


-- Countries with the highest infection rate compared to population 


Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PopulationPercentageInfected
From PortfolioProject..CovidDeaths
Group by location, population
Order by PopulationPercentageInfected desc


-- Countries with highest deathcount per population


Select location, population, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by TotalDeathCount desc


-- Continents with highest deathcount


Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global Numbers

-- Total Death Percentage by Date


Select date, SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, 
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2 


-- Total Death Percentage


Select SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, 
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


-- Total Death Percentage by Location


Select location, SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, 
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by 1,2


-- Percentage of Population Infected


Select location, population, SUM(new_cases) as Total_Cases, 
	SUM(new_cases)/population*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by 1,2


-- Total Death Percentage by Population


Select location, population, SUM(CAST(new_deaths as int)) as Total_Deaths, 
	SUM(CAST(new_deaths as int))/population*100 as DeadPopulationPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by 1


-- Total Population Vs Vaccination 


Select dth.continent, dth.location, dth.date, dth.population,vac.new_vaccinations
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	And dth.date = vac.date
Where dth.continent is not null
Order by 2,3


-- Percentage of Population Vaccinated


Select dth.continent, dth.location, dth.population, SUM(CAST(vac.new_vaccinations as int)) as Total_Vaccinations,
	SUM(CAST(vac.new_vaccinations as int))/dth.population*100 as PopulationVaccinationPercentage
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	And dth.date = vac.date
Where dth.continent is not null
Group by dth.continent, dth.location, dth.population
Order by 1,2


-- Percentage of Population Vaccinated (Using CTE)


With PopVaccination (Continent,Location,Date,Population,New_Vaccinations,RollingVaccinationSum)
as
(
Select dth.continent, dth.location, dth.date, dth.population,vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dth.location order by dth.location, dth.date) as RollingVaccinationSum
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	And dth.date = vac.date
Where dth.continent is not null
)
Select *, (RollingVaccinationSum/population)*100 as PopulationVaccinationPercentage
From PopVaccination


-- Percentage of Population Vaccinated (Using Temp Tables)


DROP Table if exists #PopulationVaccinationPercent
Create Table #PopulationVaccinationPercent
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingVaccinationSum numeric)

Insert into #PopulationVaccinationPercent
Select dth.continent, dth.location, dth.date, dth.population,vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dth.location order by dth.location, dth.date) as RollingVaccinationSum
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	And dth.date = vac.date
Where dth.continent is not null

Select *, (RollingVaccinationSum/population)*100 as PopulationVaccinationPercentage
From #PopulationVaccinationPercent


-- Creating Views To Store Data


Create View PopulationVaccinationPercentage as
Select dth.continent, dth.location, dth.population, SUM(CAST(vac.new_vaccinations as int)) as Total_Vaccinations,
	SUM(CAST(vac.new_vaccinations as int))/dth.population*100 as PopulationVaccinationPercentage
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	And dth.date = vac.date
Where dth.continent is not null
Group by dth.continent, dth.location, dth.population
--Order by 1,2

Select *
From PopulationVaccinationPercentage