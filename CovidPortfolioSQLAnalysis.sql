Select * from dbo.CovidVaccinations
select * from dbo.CovidDeaths


DELETE FROM dbo.CovidDeaths
WHERE COALESCE (your_column1, your_column2, your_column3 ) IS NULL;

-- checking for total cases vs total deaths

Select Location, date , total_cases , total_deaths ,(total_deaths/total_cases) as percentageofdeaths  from dbo.CovidDeaths


----Checking for total cases vs total deaths 

Select Location, date , total_cases , total_deaths ,(total_deaths/total_cases)*100 as percentageofdeaths  from dbo.CovidDeaths

where Location like '%india%' order by 2

------lets check total cases vs total population 

Select Location, date , total_cases , total_deaths ,(total_cases / population)*100 as PercentPopulationInfected  from dbo.CovidDeaths

where Location like '%india%' order by 2


------Country wise highest percentage of population infected.

Select Location, Population ,  MAX(total_cases) as HighestInfectionCount  , MAX((total_cases / population))*100 as PercentageofPopulationInfected  from dbo.CovidDeaths

Group By Location , Population order by PercentageofPopulationInfected desc


----Countries with highest death count

Select continent, Location, MAX(total_deaths) as TotalDeathCount from dbo.CovidDeaths
where continent is not null 
Group by Location, continent 
order by TotalDeathCount desc

------Divide by Continent

Select continent, MAX(total_deaths) as TotalDeathCount from dbo.CovidDeaths
where continent is not null 
Group by continent 
order by TotalDeathCount desc


----
Select location, MAX(total_deaths) as TotalDeathCount from dbo.CovidDeaths
where continent is null 
Group by location
order by TotalDeathCount desc

---Continents with highest death count

Select continent, MAX(total_deaths) as TotalDeathCount from dbo.CovidDeaths
where continent is not null 
Group by continent 
order by TotalDeathCount desc

----- GLOBAL NUMBERS

Select date , SUM(new_cases) as totalcases, SUM(new_deaths) as totaldeaths, (SUM(new_cases)/SUM(new_deaths) * 100 ) AS DeathPercentage from dbo.CovidDeaths 
where continent is not null
group by date
order by 1,2

-----
Select SUM(new_cases) as totalcases, SUM(new_deaths) as totaldeaths, (SUM(new_cases)/SUM(new_deaths) * 100 ) AS DeathPercentage from dbo.CovidDeaths 
where continent is not null
--group by date
order by 1,2

------- Covid Vaccinations Table

Select * from dbo.CovidVaccinations

---join two tables
Select cvd.continent, cvd.location, cvd.date, cvd.population, cvc.new_vaccinations from dbo.CovidVaccinations 
cvc Join dbo.CovidDeaths 
cvd on cvc.location = cvd.location and cvc.date=cvd.date
where cvd.continent is not null
order by 2, 3 


----rolling sum of vaccinations

Select cvd.continent, cvd.location, cvd.date, cvd.population, cvc.new_vaccinations ,
SUM(cvc.new_vaccinations) OVER (Partition by cvd.location order by cvd.location, cvd.date) as RollingPeopleVaccinated
from dbo.CovidVaccinations 
cvc Join dbo.CovidDeaths 
cvd on cvc.location = cvd.location and cvc.date=cvd.date
where cvd.continent is not null
order by 2, 3 

-- PERCENTAGE OF Vaccinations on a given day for country

---TEMP TABLE

with popvsvac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) 
as
(
Select cvd.continent, cvd.location, cvd.date, cvd.population, cvc.new_vaccinations ,
SUM(cvc.new_vaccinations) OVER (Partition by cvd.location order by cvd.location, cvd.date) as RollingPeopleVaccinated
from dbo.CovidVaccinations 
cvc Join dbo.CovidDeaths 
cvd on cvc.location = cvd.location and cvc.date=cvd.date
where cvd.continent is not null
--order by 2, 3 
)
select * ,(RollingPeopleVaccinated/population)*100 as PercentageVaccinated from popvsvac

--TEMP TABLE Version 2
Drop Table if Exists #PopulationPercentVaccinated
Create Table #PopulationPercentVaccinated
(
 continent nvarchar(50) null,
 location nvarchar(50) null,
 date datetime null,
 population float null,
 new_vaccinations float null,
 RollingPeopleVaccinated numeric null
)

Insert into #PopulationPercentVaccinated
Select cvd.continent, cvd.location, cvd.date, cvd.population, cvc.new_vaccinations ,
SUM(cvc.new_vaccinations) OVER (Partition by cvd.location order by cvd.location, cvd.date) as RollingPeopleVaccinated
from dbo.CovidVaccinations 
cvc Join dbo.CovidDeaths 
cvd on cvc.location = cvd.location and cvc.date=cvd.date
where cvd.continent is not null
--order by 2, 3 

select * from #PopulationPercentVaccinated


--- Create view for future data storage

Create View PercentPopulationVaccinated as
Select cvd.continent, cvd.location, cvd.date, cvd.population, cvc.new_vaccinations ,
SUM(cvc.new_vaccinations) OVER (Partition by cvd.location order by cvd.location, cvd.date) as RollingPeopleVaccinated
from dbo.CovidVaccinations 
cvc Join dbo.CovidDeaths 
cvd on cvc.location = cvd.location and cvc.date=cvd.date
where cvd.continent is not null
--order by 2, 3 






















