-- EXPLORATORY ANALYSIS

SELECT * 
FROM LAYOFF_STAGING2;

SELECT max(total_laid_off)
FROM LAYOFF_STAGING2;

SELECT max(percentage_laid_off)
FROM LAYOFF_STAGING2;
-- we can have a lok at companies where % laid off is 1 meaning the company closed down.

SELECT *
FROM LAYOFF_STAGING2
where percentage_laid_off = 1;

SELECT *
FROM LAYOFF_STAGING2
where percentage_laid_off = 1
order by total_laid_off desc;
-- you could order by anything you want basically and explore the data


SELECT company, sum(total_laid_off)
FROM LAYOFF_STAGING2
group by company
order by 2 desc;

-- this shows sum of total laid off starting with the highest laid off company
-- you can group by industry, country, stage and explore data more and more.

-- so we can look at the year with the most laid off

SELECT  year(`date`), sum(total_laid_off)
FROM LAYOFF_STAGING2
group by year(`date`)
order by 1 desc; -- 1 here represent column

SELECT  month(`date`), sum(total_laid_off), max(total_laid_off)
FROM LAYOFF_STAGING2
group by month(`date`)
order by 2 desc; 

-- alternatively
SELECT  substring(`date` , 6, 2) as `month`, sum(total_laid_off)
FROM LAYOFF_STAGING2
group by `month`
order by 1 desc;

-- i want to remove the null value in date column

SELECT  year(`date`), sum(total_laid_off)
FROM LAYOFF_STAGING2
where year(`date`) is not null
group by year(`date`)
order by 1 desc;

-- let's do year and month together

SELECT  substring(`date` , 1, 7) as `month`, sum(total_laid_off)
FROM LAYOFF_STAGING2
group by `month`
order by 1 desc;

-- let's do the rolling total

with rolling_total as 

(SELECT  substring(`date` , 1, 7) as `month`, sum(total_laid_off) as total_off
FROM LAYOFF_STAGING2
where  substring(`date` , 1, 7) is not null
group by `month`
order by 1 asc
)

select `month`, total_off,sum(total_off) over(order by `month`) as rolling_total
from rolling_total;

-- let's check company that laid off most and the date 


SELECT company, year(`date`), sum(total_laid_off)
FROM LAYOFF_STAGING2
group by company, year(`date`)
order by 3 desc;

-- let's identify the top 5 company with most laid off by year. 

with company_year (company, years, total_laid_off) as 
(SELECT company, year(`date`), sum(total_laid_off)
FROM LAYOFF_STAGING2
group by company, year(`date`)
), company_year_rank as 
(
select *,
dense_rank() over(partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
)
select *
from company_year_rank
where ranking <= 5;

