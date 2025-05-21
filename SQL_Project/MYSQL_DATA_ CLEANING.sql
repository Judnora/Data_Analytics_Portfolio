-- DATA CLEANING
SELECT *
FROM layoffs;

-- remove duplicates
-- standardize the data
-- remove null /blank 
-- remove columns

-- first off we start by creating another table, it's not best paractice to work on raw data
-- let's call the new able layoff_staging

create table layoff_staging
like layoffs;

select *
from layoff_staging;

insert into layoff_staging
select *
from layoffs;

select *
from layoff_staging;


-- so the next step would be to remove duplicate, there is no unique number to identify the rows, like an id, so we will have to check for duplicates first.
-- to check for duplicates we will use window function

select *,
row_number() over()
from layoff_staging;


-- using CTE to rewrite the code above, 

with duplicate_cte as
(select *,
row_number() over
(partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from layoff_staging
)

select*
from duplicate_cte;


-- so to double checdk the duplicates before we remove them.
with duplicate_cte as
(select *,
row_number() over
(partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from layoff_staging
)

select*
from duplicate_cte
where row_num > 1;

-- we fi9gured 'Oda' is not a duplicate despite being among,
with duplicate_cte as
(select *,
row_number() over
(partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from layoff_staging
)

select*
from duplicate_cte
where company = 'oda';
 
-- so we decided to partition by all the colums as below

with duplicate_cte as
(select *,
row_number() over
(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoff_staging
)

select*
from duplicate_cte;

-- so now we don't have Oda as a duplicate. 
with duplicate_cte as
(select *,
row_number() over
(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoff_staging
)

select*
from duplicate_cte
where row_num = 'oda';

-- we could remove duplicates by deleting the CTE where row_num > 1 but it doesn't work like that in MYSQL
-- for instance 

with duplicate_cte as
(select *,
row_number() over
(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions) as row_num
from layoff_staging
)

delete
from duplicate_cte
where row_num > 1;


-- so we will have to create another table with the row_num column and delete where the row_num > 1




CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- we have created a new table with a new row
-- so let's insert the data into the new table



select *
from layoff_staging2;

insert into layoff_staging2 
select*
from 
(select *,
row_number() over
(partition by company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised_millions) as row_num
from layoff_staging
) as row_num;


select *
from layoff_staging2;

-- now we can delete duplicate where row_num > 1

delete 
from layoff_staging2
where row_num > 1;



select * 
from layoff_staging2
where row_num > 1;

-- STANDARDIZING OF DATA
-- Now we look to find issues in the data and fix it.


select distinct (company)
from layoff_staging2;

-- WE USE TO trim FXN TO REMOVE EXTRA SPACES

select distinct company, (trim(company))
from layoff_staging2;

update layoff_staging2
set company = trim(company);


-- repeat the sasme for industry

select distinct (industry)
from layoff_staging2
order by 1 ;

-- ordering by 1 arranges it in alphabetical order

-- we observed crypto and cryptocurrency could be the same company, so it will be in our best interest to 
-- take one name so avoid confusion when we start visualizing the data


select *
from layoff_staging2
where industry like 'crypto%';

-- using the like statement which goes with % and _
-- now we need to update table and set cryptocurrency into crypto


update layoff_staging2
set industry = 'crypto'
where industry like 'crypto%';

-- repeat same distinct function with location and country, 
-- eventhough it's best to do it with all columns just to be accurate. 

select distinct country
from layoff_staging2
order by 1 ;

--  united states appears 2x with the second written as United states.alter-- so we need to remoive the '.'

select distinct company, (trim(country))
from layoff_staging2
order by 1 ; 
-- trim didn't work

select distinct country, trim( trailing '.' from country)
from layoff_staging2
order by 1;

select* 
from layoff_staging2;

-- the date should be in date format not text

select `date`,
str_to_date (`date`, '%m/%d/%Y')
from layoff_staging2;

update layoff_staging2
set `date` = str_to_date (`date`, '%m/%d/%Y');

-- When you changing str_to_date, it should come in format of lower case m and d then upper case Y,

alter table layoff_staging2
modify column `date` date; 

-- removing/populating null values

select *
from layoff_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- you search for null or blanck space on every column bywriting the equation below

select *
from layoff_staging2
where company = ''
or company is null;

select *
from layoff_staging2
where industry = ''
or industry is null;


-- where we figured airbnb is blank in industry and on filtering airbnb under company column
--  we found other airbnb with name under industry, so we can add that to the blank space
 
select *
from layoff_staging2
where company = 'airbnb';

select company, industry
from layoff_staging2
where industry is null
 or industry = '';


update layoff_staging2
set industry = null
where industry = '';

-- we will use the join statement to join two table on company

select *
from layoff_staging2 as t1
join layoff_staging2 as t2
 on t1.company = t2.company
 where t1.industry is null
 and t2.industry is not null;
 
 -- let's be more specific on the column
 
 select t1.industry, t2.industry
from layoff_staging2 as t1
join layoff_staging2 as t2
 on t1.company = t2.company
 where t1.industry is null
 and t2.industry is not null;
 
 -- so we have to replace t1.industry with t2.industry values
 
update layoff_staging2 t1 
join layoff_staging2 as t2
 on t1.company = t2.company
 set t1.industry = t2.industry
 where t1.industry is null
 and t2.industry is not null;

 
 select *
from layoff_staging2;

-- next is to remove null from total_laid_off and percentage_laid_off

select *
from layoff_staging2
where total_laid_off is null
and percentage_laid_off is null;


delete
from layoff_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- so we need to drop the column we added from the beginning

Alter table layoff_staging2
drop column row_num;

select *
from layoff_staging2;


