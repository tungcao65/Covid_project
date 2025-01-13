SELECT * 
FROM  porfolio_project.coviddeathsrevise
ORDER BY 3,4;

SELECT * 
FROM  porfolio_project.covidvaccinations
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, new_deaths, population
FROM porfolio_project.coviddeathsrevise
ORDER BY 1,2;

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM porfolio_project.coviddeathsrevise
WHERE location LIKE '%Vietnam%'
ORDER BY 1,2;

SELECT location, population,  MAX(total_cases) AS MaxTotalCase , MAX(total_cases/population)*100 AS PercentagePopulationInfected
FROM porfolio_project.coviddeathsrevise
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC;

-- showing countries with highest death count per population --

SELECT location,  MAX(CAST(total_deaths AS SIGNED )) AS TotalDeathCount
FROM porfolio_project.coviddeathsrevise
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Break things down by continent --



-- Showing continent with the highest death count per population --

SELECT continent,  MAX(CAST(total_deaths AS SIGNED )) AS TotalDeathCount
FROM porfolio_project.coviddeathsrevise
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Number --
SELECT date, SUM(new_cases), SUM(CAST(new_deaths AS SIGNED)), SUM(CAST(new_deaths AS SIGNED))/SUM(new_cases) *100 AS DeathPercentage
FROM porfolio_project.coviddeathsrevise
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

-- Looking at Total Population vs Vaccinations --

WITH vacByPopulation (continent, location, date, population, new_vaccinations, total_new_vac) AS
(

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(new_vaccinations, SIGNED)) OVER (PARTITION BY dea.location ORDER BY  dea.date) AS total_new_vac
FROM porfolio_project.coviddeathsrevise dea
JOIN porfolio_project.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3 
)

SELECT *, (total_new_vac/population)*100 FROM vacByPopulation;


-- TempTable --

DROP TABLE IF EXISTS  RollingVac;
CREATE TEMPORARY TABLE RollingVac (
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_new_vac numeric
);

INSERT INTO RollingVac(

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(new_vaccinations, SIGNED)) OVER (PARTITION BY dea.location ORDER BY  dea.date) AS total_new_vac
FROM porfolio_project.coviddeathsrevise dea
JOIN porfolio_project.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3 
);

SELECT *, (total_new_vac/population)*100 FROM RollingVac;

-- Creating view for data visualization later --
DROP VIEW IF EXISTS porfolio_project.PercentPopulationVac;
CREATE VIEW  porfolio_project.PercentPopulationVac AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(new_vaccinations, SIGNED)) OVER (PARTITION BY dea.location ORDER BY  dea.date) AS total_new_vac
FROM porfolio_project.coviddeathsrevise dea
JOIN porfolio_project.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3 )






