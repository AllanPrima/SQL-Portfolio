-- DATA CLEANING

SELECT *
FROM layoffs;

-- Here i make a staging table that is separate from the raw table, as to not permanently alter it
CREATE TABLE layoffs_staging
LIKE layoffs;
SELECT *
FROM layoffs_staging;
INSERT layoffs_staging 
SELECT *
FROM layoffs; 

-- REMOVING DUPLICATE by utilizing ROW_NUMBER
SELECT 	*,
        ROW_NUMBER () OVER (
        PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging; 

WITH duplikat_cte AS 
(
SELECT 	*,
        ROW_NUMBER () OVER (
        PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
		FROM layoffs_staging 
) 
SELECT *
FROM duplikat_cte
WHERE row_num > 1;
  

  DROP TABLE IF EXISTS `layoffs_staging2`;
  CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT    											
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT 	*,
        ROW_NUMBER () OVER (
        PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging;

SELECT *
FROM layoffs_staging2;

-- Now that we have make a table containing row number, we can find duplicate values by identifying the row number that is more than 1
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- here we check for more duplicate
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;
