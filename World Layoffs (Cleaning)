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


-- WORKING WITH NULL
 
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL; 		

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT DISTINCT *
FROM layoffs_staging2
WHERE industry IS NULL 				
	OR industry LIKE ''; 			
	

-- Filling the null 
	-- here i fill it with the 'industry' of same company from different entry
SELECT t1.company, 
		t1.industry, 
        t2.company,
		t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
ON t1.company = t2.company
	AND t1.location = t2.location		
WHERE t1.industry IS NULL OR t1.industry LIKE ''
AND t2. industry IS NOT NULL;  	
											
                                            
UPDATE  layoffs_staging2
SET industry = NULL
WHERE industry LIKE '';


UPDATE  layoffs_staging2 AS t1
JOIN  layoffs_staging2 AS t2
ON t1.company = t2.company
	AND t1.location = t2.location	
SET t1.industry = t2.industry   					
WHERE t1.industry IS NULL							
	AND t2.industry IS NOT NULL;
    
    -- CEK HASILNYA
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL;

-- there is some company that didn't have another different entry that can't be filled
SELECT *
FROM layoffs_staging2
WHERE (total_laid_off IS NULL OR  total_laid_off LIKE '')
AND (percentage_laid_off IS NULL OR percentage_laid_off LIKE '');

DELETE
FROM layoffs_staging2
WHERE (total_laid_off IS NULL OR  total_laid_off LIKE '')
AND (percentage_laid_off IS NULL OR percentage_laid_off LIKE '');

-- Check

SELECT *
FROM layoffs_staging2
WHERE (total_laid_off IS NULL OR  total_laid_off LIKE '')
AND (percentage_laid_off IS NULL OR percentage_laid_off LIKE '');


ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


SELECT * 
FROM layoffs_staging2;


-- STANDARDIZING


UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT *
FROM layoffs_staging2;  
	
-- Here i check each column one by one

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'crypto%';


SELECT DISTINCT location   			
FROM layoffs_staging2
ORDER BY 1;  						


SELECT DISTINCT country   	
FROM layoffs_staging2
ORDER BY 1;  						
						
UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';
 
SELECT date, 
		STR_TO_DATE(`date`, '%m/%d/%Y')  		
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
           
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE; 						
