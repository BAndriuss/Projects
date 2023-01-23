SELECT *
FROM PortfolioProjects..BCS_IMDb_WebScrapped_Data$

---------------- Creating Temp Table ----------------
DROP table #BCS_IMDb_WebScrapped_DataTemp

-- Changing release_date data type to a more cleaner one
Create Table #BCS_IMDb_WebScrapped_DataTemp
(
episode_title nvarchar(255),
release_Date date,
episode nvarchar(255),
imdb_score float,
user_votes numeric
)

Insert into #BCS_IMDb_WebScrapped_DataTemp
select *
from PortfolioProjects..BCS_IMDb_WebScrapped_Data$

select * 
from #BCS_IMDb_WebScrapped_DataTemp
---------------- Data cleaning ----------------

-- Breaking Out episode column into two separate columns - season and episode
-- SUBSTRING(string, start, length)
SELECT
SUBSTRING(episode, 7, CHARINDEX(',' , episode)+1) as episode,
SUBSTRING(episode, 2, CHARINDEX(',' , episode)-2) as season
FROM #BCS_IMDb_WebScrapped_DataTemp

ALTER TABLE #BCS_IMDb_WebScrapped_DataTemp
ADD season int
UPDATE #BCS_IMDb_WebScrapped_DataTemp
SET season = SUBSTRING(episode, 2, CHARINDEX(',' , episode)-2)

UPDATE #BCS_IMDb_WebScrapped_DataTemp
SET episode = SUBSTRING(episode, 7, CHARINDEX(',' , episode)+1)

-- Getting rid of minus in column user_votes
UPDATE #BCS_IMDb_WebScrapped_DataTemp
SET user_votes = user_votes*-1


---------------- Creating Tables For Analysis ----------------
select * 
from #BCS_IMDb_WebScrapped_DataTemp
order by 4

-- Looking at season scores and votes  // table 1 
SELECT season, AVG(imdb_score) as score, SUM(user_votes) as votes
FROM #BCS_IMDb_WebScrapped_DataTemp
GROUP BY season



----------- Using CTE -----------  

WITH DaysUntilNext (episode_title, episode, next_ep, season, days_until_next_ep)
AS
(
-- Looking how much time for new episode // table 2

SELECT a.episode_title, a.episode,b.episode as next_ep, a.season,
	   DATEDIFF(day,a.release_Date, b.release_date) as days_until_next_ep
FROM #BCS_IMDb_WebScrapped_DataTemp as a
JOIN #BCS_IMDb_WebScrapped_DataTemp as b
ON a.season = b.season AND a.episode = b.episode -1
--order by 4,2
)

-- Average days until next ep for season // table 3
SELECT season, AVG(days_until_next_ep) as AVG_days_until_next_ep
FROM DaysUntilNext
group by season

---------------------------------




