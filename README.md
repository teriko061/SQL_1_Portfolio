SQL příkazy pro zpracování dat ze dvou tabulek s kovidovými údaji. Zdrojem dat je YouTube kanál Alex The Analyst. Příkazy obsahují základní filtrování, agregační funkce SUM a MAX, jednoduché spojování tabulek (JOIN), ukázku použítí CTE a TEMP table. Ukázka spojení dvou tabulek:

SELECT *
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVactinations vac
	on dea.location = vac.location
	and dea.date = vac.date

-------------------------------------------------------------------------------------------------------------------------

SQL commands for processing data from two tables containing COVID-related information. The data source is the YouTube channel "Alex The Analyst." The commands cover basic filtering, the aggregate functions SUM and MAX, simple table joins (JOIN), and examples of using CTEs and temporary tables. Example of simple JOIN:

SELECT *
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVactinations vac
	on dea.location = vac.location
	and dea.date = vac.date
