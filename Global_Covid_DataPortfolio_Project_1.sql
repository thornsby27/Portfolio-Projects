SELECT *
FROM
	PortfolioProject.dbo.CovidDeaths$
	order by 3,4

--SELECT *
--FROM
--	PortfolioProject.dbo.CovidVaccinations$
--	order by 3,4

/* Select the data that we're going to be using */




Select
	Location, date, total_cases, new_cases, total_deaths, population
FROM
	PortfolioProject.dbo.CovidDeaths$
Order By 1,2 /* based on location and date */
--creates a table based on the items we chose to select

--Looking at the total cases vs total deaths

--Shows the likelihood of dying if you contract covid in your country. 




Select
	Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM
	PortfolioProject.dbo.CovidDeaths$
WHERE 
	location like '%japan%'
Order By 1,2	




--Looking at total cases vs population
--Shows what percentage of population got covid
Select
	Location, date, Population, total_cases, (total_cases/Population)*100 as Infected_Percentage
FROM
	PortfolioProject.dbo.CovidDeaths$
WHERE 
	location like '%Japan%'
Order By 1,2 

--Looking at countries with highest infection rate compared to populations 




Select
	Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as Infected_Percentage
FROM
	PortfolioProject.dbo.CovidDeaths$
--WHERE 
--	location like '%states%'
Group By continent
Order By Infected_Percentage desc



--Showing the countries with the highest death count per population
--###
Select
	Location, MAX(cast(TOTAL_deaths as int)) as TOTALDEATHCOUNT
FROM
	PortfolioProject.dbo.CovidDeaths$
--WHERE 
--	location like '%states%'
Group By continent
Order By TotalDeathCount desc
--As this is right now, everything is being grouped too generally. Example: World, South America, Africa. 
--So....let's take the first Query and examine the data
--### Dataset with continent as Null Data. Keeping this as an example for note taking. 
--# Next Query will be more cleaned up


--#This set looks a lot better
Select
	Location, MAX(cast(TOTAL_deaths as int)) as TOTALDEATHCOUNT
FROM
	PortfolioProject.dbo.CovidDeaths$
--WHERE 
--	location like '%states%'
WHERE continent is not null
Group By continent
Order By TotalDeathCount desc
--# This set looks a lot better!


SELECT *
FROM
	PortfolioProject.dbo.CovidDeaths$
	order by 3,4
--If you execute a Query on this, you'll notice that Asia will appear as a continent and location under some lines. 
--With Asia appearing as a location in parts and having data as Null. Therefore...

SELECT *
FROM
	PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null	
order by 3,4



--### Lets break things down by continent
---Showing the continents with the highest death count per population 
-- Made a view for this one down below (last example)
Select
	continent, MAX(cast(TOTAL_deaths as int)) as TOTALDEATHCOUNT
FROM
	PortfolioProject.dbo.CovidDeaths$
--WHERE 
--	location like '%states%'
WHERE continent is not null
Group By continent
Order By TotalDeathCount desc


--###Try something else
--##Accurate continent death count
Select
	location, MAX(cast(TOTAL_deaths as int)) as TOTALDEATHCOUNT
FROM
	PortfolioProject.dbo.CovidDeaths$
--WHERE 
--	location like '%states%'
WHERE continent is null
Group By location
Order By TotalDeathCount desc
--###Accurate continent count 


--Global Numbers -- Block above are global covid numbers daily - death percentage a little over 2%


Select
	date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/ SUM(New_cases)*100 as DeathPercentage /* total_deaths, (total_deaths/total_cases) * 100 as DEATHPERCENTAGE */	

FROM
	PortfolioProject.dbo.CovidDeaths$
--WHERE 
--	location like '%states%'
WHERE continent is not null
Group By Date
Order By 1,2	

--Block above are global covid numbers daily - death percentage a little over 2%


-- Block below gives you total covid deaths as an aggregate - death percentage a little over 2%
Select
	SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/ SUM(New_cases)*100 as DeathPercentage /* total_deaths, (total_deaths/total_cases) * 100 as DEATHPERCENTAGE */	

FROM
	PortfolioProject.dbo.CovidDeaths$
--WHERE 
--	location like '%states%'
WHERE continent is not null
--Group By Date
Order By 1,2	
-- Block above gives you total covid deaths as an aggregate - death percentage a litle over 2%






--Looking at total population versus vaccination
-- Gonna use the Covid Vaccinations Table now
SELECT *
FROM 
	PortfolioProject..CovidDeaths$ dea
JOIN
	PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date 


	---What's the total amount of people who have been vaccinated?
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM 
	PortfolioProject..CovidDeaths$ dea

JOIN
	PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date 
WHERE dea.continent is not null
Order By 1,2,3

	--with joined tables, if I solely said "date" and not dea.date or vac.date I would get an error. Need to specify since it's on both tables.

	--There's already a column titled "Total Vaccinations" but to showcase my skill with SQL we will create a rolling count


	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location) -- I initially tried running SUM(vac.new_vaccinations as int) however it didn't work since I didn't cast the string as an integer.
FROM 
	PortfolioProject..CovidDeaths$ dea
JOIN
	PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date 
WHERE dea.continent is not null
Order By 2,3



--Look at total population vs vaccinations
--The below Query and the Query above are the same. Just different ways of typing it out.
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order By dea.location, dea.Date) 
	as RollingPeopleVaccinated,
	-- (RollingPeopleVaccinated/population)*100
FROM 
	PortfolioProject..CovidDeaths$ dea
JOIN
	PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date 
WHERE dea.continent is not null
Order By 2,3

-- Use CTE the following will showcase two examples of comparing Population vs vaccination

With PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated) --if number of columns here is different from what's in the select statement, it will give an error.
as 

(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order By dea.location, dea.Date) 
	as RollingPeopleVaccinated
	-- (RollingPeopleVaccinated/population)*100
FROM 
	PortfolioProject..CovidDeaths$ dea
JOIN
	PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date 
WHERE dea.continent is not null
-- Order By 2,3
)
SELECT *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac


--Temp Table

Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order By dea.location, dea.Date) 
	as RollingPeopleVaccinated
	-- (RollingPeopleVaccinated/population)*100
FROM 
	PortfolioProject..CovidDeaths$ dea
JOIN
	PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date 
WHERE dea.continent is not null
-- Order By 2,3

SELECT *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated


--Creating view to store data for later visualization

Create View Percentpopulationvaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order By dea.location, dea.Date) 
	as RollingPeopleVaccinated
	-- (RollingPeopleVaccinated/population)*100
FROM 
	PortfolioProject..CovidDeaths$ dea
JOIN
	PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date 
WHERE dea.continent is not null





