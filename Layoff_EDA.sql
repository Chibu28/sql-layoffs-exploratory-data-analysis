-- EXPLORATORY DATA ANALYSIS (EDA)
-- Exploring the layoffs dataset to identify trends, patterns,
-- and key business insights across industries,
-- companies, countries, and time periods.

-- DATASET OVERVIEW
-- Performed a review of the cleaned layoffs dataset to
-- understand the available columns and verify that the data is
-- ready for exploratory analysis

SELECT * 
FROM layoff_eda.layoffs;

-- LARGEST LAYOFF EVENT

-- Identified the highest number of employees laid off in a single
-- recorded event. This helps establish the max layoffs
-- alongside the industry and the date 
-- and this highlights the scale of the most significant workforcereduction in the dataset

SELECT total_laid_off, company, industry, `date`
FROM layoff_eda.layoffs
ORDER BY total_laid_off desc
LIMIT 1;

-- Identified the highest number of employees laid off within each industry
-- across the dataset. This helps highlight which industries experienced
-- the most severe single layoff events

SELECT MAX(total_laid_off), industry
FROM layoff_eda.layoffs
Group BY industry
ORDER BY MAX(total_laid_off) DESC
LIMIT 5;

-- This calculates the cumulative number of employees laid off
-- by each company across all recorded layoff events in the dataset
SELECT company, SUM(total_laid_off)
FROM layoff_eda.layoffs
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;

-- LAYOFF SEVERITY ANALYSIS

-- Examine the range of workforce reductions across industries by identifying
-- the highest and lowest layoff percentages recorded.
-- Highlighting sectors where companies experienced minimal workforce impact
-- versus those that underwent large scale or total reductions

SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off), industry
FROM layoff_eda.layoffs
WHERE  percentage_laid_off IS NOT NULL
GROUP BY industry;

-- Identified companies that laid off 100% of their workforce,
-- indicating full shutdowns/complete cessation of operations.
-- This highlights the most extreme cases of layoffs in the dataset,
-- where companies exited the market 

SELECT company, percentage_laid_off
FROM layoff_eda.layoffs
WHERE  percentage_laid_off = 1;

-- This analysis compares overall company funding levels against companies
-- that experienced complete workforce layoffs (100%).
-- First, all companies are ordered by funds raised to understand the
-- distribution of funding across the dataset.
-- Then the dataset is filtered to only include companies with 100% layoffs
-- This allows direct comparison between funding size and business failure,

SELECT *
FROM layoff_eda.layoffs
ORDER BY funds_raised_millions DESC;

SELECT *
FROM layoff_eda.layoffs
WHERE  percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


-- LAYOFFS BY LOCATION

-- Aggregate total layoffs by geographic location to identify
-- which cities or regions experienced the highest workforce reductions.
-- This helps reveal geographic hotspots of layoffs and provides insight
-- into how job losses are distributed across different locations.

SELECT location, SUM(total_laid_off) AS total_laid_off
FROM layoff_eda.layoffs
GROUP BY location
ORDER BY total_laid_off DESC;


-- YEARLY LAYOFF TREND ANALYSIS
-- Aggregate total layoffs by year to examine how workforce
-- reductions changed over time across the dataset.

ALTER TABLE layoff_eda.layoffs
ADD COLUMN date_clean DATE;
UPDATE layoff_eda.layoffs
SET date_clean = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT YEAR(date_clean) AS YEAR, SUM(total_laid_off)
FROM layoff_eda.layoffs
WHERE date_clean IS NOT NULL
GROUP BY YEAR;


-- LAYOFFS BY COMPANY FUNDING STAGE

-- Analyze total workforce reductions across different stages
-- of company growth and funding
-- this analysis reveals which
-- business maturity levels were most affected by workforce reductions

SELECT stage, SUM(total_laid_off)
FROM layoff_eda.layoffs
GROUP BY stage
ORDER BY 2 DESC;


-- TOP COMPANIES BY YEARLY LAYOFFS
-- Identify the companies with the highest total layoffs in each year
-- This analysis provides insight into yearly layoff trends and
-- identifies the companies most impacted during each period.

WITH Company_Year AS 
(
  SELECT company, YEAR(date_clean) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoff_eda.layoffs
  GROUP BY company, years
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;


-- MONTHLY LAYOFF TRENDS ANALYSIS

-- This allows us to track how workforce reductions evolve over time
-- at a more granular level than yearly analysis, helping to identify
-- short-term spikes, trends, and periods of intensified layoffs.

SELECT SUBSTRING(date_clean,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoff_eda.layoffs
GROUP BY dates
ORDER BY dates ASC;

-- This helps highlight the overall progression and acceleration of layoffs
-- across the entire time period in the dataset.

WITH DATE_CTE AS 
(
SELECT SUBSTRING(date_clean,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoff_eda.layoffs
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;

