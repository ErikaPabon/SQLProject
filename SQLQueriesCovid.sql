-- some of the most important data
select location, date, total_cases, new_cases, total_deaths, population
from ProjectPortfolio..CovidDeaths
order by 1, 2;

-- looking at total cases vs Total deaths. How many people died from covid compared to the total people who reported covid?by percentage

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
order by 1,2;

--Looking at % of total cases vs total deaths in a specific country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
where location = 'Colombia'
order by 1,2;
--Analysis by the end of 2021 in Colombia there were 1'642.775 total cases in Colombia with 43.213 deaths reported, which it is about 2.6% likehood of dying

--Looking at total cases vs Population
select location, date, total_cases, population, (total_cases/population)*100 as CovidPercPerPopulation
from ProjectPortfolio..CovidDeaths
where location = 'Colombia'
order by 1,2
--Analysis: By April 30 2021 there were 2'859.724 Covid cases which refers to the 5.6% of the total population in Colombia

--Looking for countries with the highest infections rate compared to population
select location,population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases/population))*100 as CovidPercPerPopulation
from ProjectPortfolio..CovidDeaths
group by location, population
order by CovidPercPerPopulation desc;
--Analysis: We can see the countries with the highest rates of infection based on their population

--Looking for countries with the highest death count caused by covid
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;
--Analysis: US is the #1 on death count as of Aug 2021

--More indepth lookout into continent based rates
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;
--Analysis: We can see total of deaths by continent

--looking for worldwide numbers
select date, sum(new_cases) as New_Cases, sum(cast(new_deaths as int)) as New_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Worldwide_DeathRates
from ProjectPortfolio..CovidDeaths
where continent is not null
group by date
order by 1;
--Analysis: this shows the count per day of new cases, new dates and the global rate for each day

--Joining tables to compare values of population vaccinated
Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, vac.new_vaccinations
, Sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by Deaths.location Order by Deaths.location, Deaths.date) as AddingPeopleVaccinated
--breaking by location, so that everytime the location changes, the count starts over
from ProjectPortfolio..CovidDeaths Deaths
join ProjectPortfolio..CovidVaccinations vac
on Deaths.location = vac.location
and Deaths.date = vac.date
where Deaths.continent is not null
order by 2,3;
--Analysis: Most of the vaccinations started on 2021

--Creating a CTE for 

With PopsVsVacs (continent, location, Date, Population,new_vaccinations, AddingPeopleVaccinated)
as 
(
Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, vac.new_vaccinations
, Sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by Deaths.location Order by Deaths.location, Deaths.date) as AddingPeopleVaccinated
--breaking by location, so that everytime the location changes, the count starts over
from ProjectPortfolio..CovidDeaths Deaths
join ProjectPortfolio..CovidVaccinations vac
on Deaths.location = vac.location
and Deaths.date = vac.date
where Deaths.continent is not null
)
Select * , (AddingPeopleVaccinated/population)*100 as PercOfNewVac
from PopsVsVacs

--Usings a Temp table 

create Table #PercPopuVaccionates
(
Continent nvarchar(225),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric, 
AddingPeopleVaccinated numeric)

Insert into #PercPopuVaccionates

select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, vac.new_vaccinations
, Sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by Deaths.location Order by Deaths.location, Deaths.date) as AddingPeopleVaccinated
--breaking by location, so that everytime the location changes, the count starts over
from ProjectPortfolio..CovidDeaths Deaths
join ProjectPortfolio..CovidVaccinations vac
on Deaths.location = vac.location
and Deaths.date = vac.date
where Deaths.continent is not null

Select * , (AddingPeopleVaccinated/population)*100 as PercOfNewVac
from #PercPopuVaccionates



--Creating views for data visualization

CREATE VIEW PercPopuVaccionates as

select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, vac.new_vaccinations
, Sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by Deaths.location Order by Deaths.location, Deaths.date) as AddingPeopleVaccinated
--breaking by location, so that everytime the location changes, the count starts over
from ProjectPortfolio..CovidDeaths Deaths
join ProjectPortfolio..CovidVaccinations vac
on Deaths.location = vac.location
and Deaths.date = vac.date
where Deaths.continent is not null






