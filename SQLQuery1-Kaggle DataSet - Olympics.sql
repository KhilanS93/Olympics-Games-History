--SQL Question 1
--1. How many olympics games have been held?

--Problem Statement: Write a SQL query to find the total no of Olympic Games held as per the dataset.
select count(distinct(games)) as total_olympics_games
from Olympics..Olympics_History

--2. List down all Olympics games held so far.

--Problem Statement: Write a SQL query to list down all the Olympic Games held so far.

select distinct Year,Season, City
from Olympics..Olympics_History
order by year	

--3. Mention the total no of nations who participated in each olympics game?

--Problem Statement: SQL query to fetch total no of countries participated in each olympic games.

select distinct games, count(distinct(NOC)) as total_countires
from Olympics..Olympics_History
group by games
order by Games

--4. Which year saw the highest and lowest no of countries participating in olympics

--Problem Statement: Write a SQL query to return the Olympic Games which had the highest participating countries and the lowest participating countries.

--select distinct games, count(distinct(NOC)) as total_countires
--from Olympics..Olympics_History
--group by games
--order by Games

--select *
--from Olympics..Olympics_History

--alter table Olympics..Olympics_History
--drop column total_countries

      with all_countries as
              (select games, nr.region
              from olympics..olympics_history oh
              join olympics..Olympics_histor_noc_regions nr ON nr.noc=oh.noc
              group by games, nr.region),
          tot_countries as
              (select games, count(1) as total_countries
              from all_countries
              group by games)
      select distinct
      concat(first_value(games) over(order by total_countries)
      , ' - '
      , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
      concat(first_value(games) over(order by total_countries desc)
      , ' - '
      , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
      from tot_countries
      order by 1;

--5. Which nation has participated in all of the olympic games

--Problem Statement: SQL query to return the list of countries who have been part of every Olympics games.

      with tot_games as
              (select count(distinct games) as total_games
              from Olympics..Olympics_History),
          countries as
              (select games, nr.region as country
              from olympics..Olympics_History oh
              join olympics..Olympics_histor_noc_regions nr ON nr.noc=oh.noc
              group by games, nr.region),
          countries_participated as
              (select country, count(1) as total_participated_games
              from countries
              group by country)
      select cp.*
      from countries_participated cp
      join tot_games tg on tg.total_games = cp.total_participated_games
      order by 1;

--6. Identify the sport which was played in all summer olympics.

--Problem Statement: SQL query to fetch the list of all sports which have been part of every olympics.

with t1 as
	(select count (distinct games) as total_games
	from Olympics..Olympics_history
	where season = 'summer'),
t2 as 
	(select distinct games, sport
	from Olympics..Olympics_History
	where Season = 'summer'),
t3 as 
	(select sport, count(1) as no_of_games
	from t2
	group by Sport)
select * 
from t3
join t1 on t1.total_games = t3.no_of_games


--7. Which Sports were just played only once in the olympics.

--Problem Statement: Using SQL query, Identify the sport which were just played once in all of olympics.
with t1 as
        (select distinct games, sport
   		from olympics..Olympics_History),
t2 as
      	(select sport, count(1) as no_of_games
         from t1
         group by sport)
 select t2.*, t1.games
  from t2
  join t1 on t1.sport = t2.sport
  where t2.no_of_games = 1
  order by t1.sport;

--8. Fetch the total no of sports played in each olympic games.

--Problem Statement: Write SQL query to fetch the total no of sports played in each olympics.

select games, count(distinct sport) as _no_of_games
from olympics..Olympics_History
group by Games
order by _no_of_games desc

--9. Fetch oldest athletes to win a gold medal

--Problem Statement: SQL Query to fetch the details of the oldest athletes to win a gold medal at the olympics
--select *
--from olympics..Olympics_History
--where Medal = 'gold'
--order by Age desc

with temp as
(select name, sex, isnull(age,0) as age, team, games, city, sport, event, medal
from olympics..Olympics_History
),
rankings as (
select *, rank() over(order by age desc) as rnk
from temp
where medal ='gold')
select *
from rankings
where rnk =1

--10. Find the Ratio of male and female athletes participated in all olympic games.

--Problem Statement: Write a SQL query to get the ratio of male and female participants
with t1 as (
SELECT SEX, COUNT(SEX) AS CNT
FROM OLYMPICS..Olympics_History
GROUP BY Sex
),
t2 as  (
select *, ROW_NUMBER() over(order by sex) as rn
from t1
),
min_cnt as  (
select cnt from t2 where rn=1),
max_cnt as (
select cnt from t2 where rn = 2)
select concat('1: ', round(max_cnt::decimal/min_cnt.cnt, 2)) as ratio
from min_cnt,max_cnt;

-- cannot figure out, have to check

--11. Fetch the top 5 athletes who have won the most gold medals.
--Problem Statement: SQL query to fetch the top 5 athletes who have won the most gold medals.
with t1 as (
select name,team, count(1) as no_of_medals
from Olympics..Olympics_History
where medal in ('gold')
group by Name,Team
),
t2 as (
select *, dense_rank() over(order by no_of_medals desc) as rnk
from t1
)
select name, team, no_of_medals
from t2
where rnk <= 5
order by no_of_medals desc;
--12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
--Problem Statement: SQL Query to fetch the top 5 athletes who have won the most medals (Medals include gold, silver and bronze).
with t1 as (
select name,team, count(1) as no_of_medals
from Olympics..Olympics_History
where medal in ('gold','silver','bronze')
group by Name,Team
),
t2 as (
select *, dense_rank() over(order by no_of_medals desc) as rnk
from t1
)
select name, team, no_of_medals
from t2
where rnk <= 5
order by no_of_medals desc;

--13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

--Problem Statement: Write a SQL query to fetch the top 5 most successful countries in olympics. (Success is defined by no of medals won).
with t1 as (
select NOC,team, count(Medal) as no_of_medals
from Olympics..Olympics_History
where medal in ('gold','silver','bronze')
group by NOC,Team
),
t2 as (
select *, dense_rank() over(order by no_of_medals desc) as rnk
from t1
)
select NOC, team, no_of_medals
from t2
where rnk <= 5
order by no_of_medals desc;

--14. List down total gold, silver and bronze medals won by each country.

--Problem Statement: Write a SQL query to list down the  total gold, silver and bronze medals won by each country.
with t1 as (
select nr.region as country, medal, count(1) as total_medals
from Olympics..Olympics_History oh 
join Olympics..Olympics_histor_noc_regions nr on nr.noc = oh.NOC
where medal <> 'NA'
group by nr.region, medal
order by nr.region, Medal
)

SELECT country
,ISNULL(gold, 0) as gold
,isnull (silver,0) as silver
,isnull (bronze, 0) as bronze

FROM
(
  SELECT country, total_medals
  FROM t1
) AS  sourcetable
PIVOT  
(  
  total_medals,
  FOR country IN ([bronze], [silver], [gold])  
) AS PivotTable;

--Have to check PIVOT tables



	


	 