SELECT * 
FROM [Portfolio Project].dbo.[Covid Deaths]
WHERE continent IS NOT Null
ORDER BY 3, 4

--SELECT * 
--FROM [Portfolio Project].dbo.[Covid Vaccinations]
--ORDER BY 3, 4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].dbo.[Covid Deaths]
WHERE continent IS NOT Null
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likehood of dying if you contract COVID in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS DeathPercentage
FROM [Portfolio Project].dbo.[Covid Deaths]
WHERE continent IS NOT Null
AND Location LIKE '%States'
ORDER BY 1,2

--Looking at Total cases VS Population
--Shows what percentage of population got COVID

SELECT Location, date, population, total_cases, (total_cases / population)*100 AS DeathPercentage
FROM [Portfolio Project].dbo.[Covid Deaths]
WHERE continent IS NOT Null
WHERE Location LIKE '%States'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX (total_cases) AS HighestInfectionCount, MAX ((total_cases / population))*100 AS PercentagePopulationInfected
FROM [Portfolio Project].dbo.[Covid Deaths]
WHERE continent IS NOT Null
--WHERE Location LIKE '%States'
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

--Showing countries with the highest death count per population

SELECT Location, MAX (cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.[Covid Deaths]
WHERE continent IS NOT Null
--WHERE Location LIKE '%States'
GROUP BY location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT Location, MAX (cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.[Covid Deaths]
--WHERE Location LIKE '%States'
WHERE continent IS Null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Showing continents with highest death count per population

SELECT Location, MAX (cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.[Covid Deaths]
--WHERE Location LIKE '%States'
WHERE continent IS Null
GROUP BY Location
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM (new_cases) * 100 AS Deathpercentage
FROM [Portfolio Project].dbo.[Covid Deaths]
--WHERE Location LIKE '%States'
WHERE continent IS NOT NULL
--GROUP BY Date
ORDER BY 1,2



-- Looking at Total Populations vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations
)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project].dbo.[Covid Deaths] AS dea
JOIN [Portfolio Project].dbo.[Covid Vaccinations] AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

With PopvsVac (Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations
)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project].dbo.[Covid Deaths] AS dea
JOIN [Portfolio Project].dbo.[Covid Vaccinations] AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
) 
SELECT * , (RollingPeopleVaccinated / population) * 100
FROM PopvsVac

-- TEMP TABLE

CREATE TABLE PercentPeopleVaccinated
(
Continent varchar (255),
Location varchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

INSERT INTO PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations
)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project].dbo.[Covid Deaths] AS dea
JOIN [Portfolio Project].dbo.[Covid Vaccinations] AS vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT * , (RollingPeopleVaccinated / population) * 100
FROM PercentPeopleVaccinated

-- Creating view to store data for later visualizations

CREATE VIEW TotalDeathCount 
SELECT Location, MAX (cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.[Covid Deaths]
WHERE continent IS NOT Null
--WHERE Location LIKE '%States'
GROUP BY location
ORDER BY TotalDeathCount DESC