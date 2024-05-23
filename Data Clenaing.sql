-- DATA CLEANING

SELECT * 
FROM layoffs;

-- (1)Remove Duplicates data in the table
-- (2)Standardize the Data
-- (3)Null values or Blank values
-- (4)Remove columns or rows that are not useful

-- (1) REMOVE DUPLICATE DATA IN THE TABLE
-- Create a duplicate for layoffs, so that I can work with the duplicate, instead of working with the original copy
CREATE TABLE layoff_staging
LIKE layoffs;

SELECT *
FROM layoff_staging;

INSERT layoff_staging
SELECT *
FROM layoffs; 

-- looking for duplicate rows
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
FROM layoff_staging;

-- we can use cte's or subqueries to write the code block below
-- Note: A CTE cannot be updated, so we can't delete the duplicate rows directly by merely writing a DELETE statement
WITH duplicate_cte AS
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)
AS row_num
FROM layoff_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Just checking the authenticity of the result
SELECT *
FROM layoff_staging
WHERE company = 'Cazoo';

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
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Checking that the columns were well created as specified in the code block above
SELECT *
FROM layoff_staging2;

INSERT INTO layoff_staging2
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)
AS row_num
FROM layoff_staging;

-- try identify what you are deleting using the select statement first
SELECT *
FROM layoff_staging2
WHERE row_num > 1;

DELETE
FROM layoff_staging2
WHERE row_num > 1;


-- (2) STANDARDIZING THE DATA
-- It's about looking for issues with the data and fixing them

-- starting with the 'company' column
SELECT company
FROM layoff_staging2;

SELECT company, TRIM(company)
FROM layoff_staging2;

UPDATE layoff_staging2
SET company = TRIM(company);

SELECT *
FROM layoff_staging2;

-- moving to industry
SELECT DISTINCT industry
FROM layoff_staging2
ORDER BY 1;

-- From the result from the code block above, there is a repitition with 'Crypto%'
SELECT * 
FROM layoff_staging2
WHERE industry LIKE 'crypto%';

UPDATE layoff_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'crypto%';

-- checking if correction has been made
SELECT DISTINCT industry
FROM layoff_staging2
ORDER BY 1;

-- moving to 'location' and 'country' column
SELECT DISTINCT location
FROM layoff_staging2
ORDER BY 1;

SELECT DISTINCT country
FROM layoff_staging2
ORDER BY 1;

-- removing a full stop after we noticed that United states have a full stop (.) in its front
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoff_staging2
ORDER BY 1;

UPDATE layoff_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- Moving to the 'date' column
-- str_to_date(`date`, '%m/%d/%Y') -> This is what is used to convert date from text or string to a date format
SELECT date, 
str_to_date(`date`, '%m/%d/%Y')
FROM layoff_staging2;

UPDATE layoff_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

-- Just double-checking if what I wrote above is correct
SELECT *
FROM layoff_staging2;

-- Change the text format that appears attached to the date column. Check from the left Panel area
ALTER TABLE layoff_staging2
MODIFY COLUMN `date` DATE;

-- (4) Remove rows that have empty or null values

SELECT * 
FROM layoff_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoff_staging2
WHERE industry IS NULL
OR industry = '';

SELECT * 
FROM layoff_staging2
WHERE company = 'Airbnb';

-- Update industry column from 'empty cells' to 'null'
UPDATE layoff_staging2
SET industry = NULL
WHERE industry = '';

SELECT * 
FROM layoff_staging2 t1
JOIN layoff_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;


UPDATE layoff_staging2 t1
JOIN layoff_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

-- "Bally's Interactive" does not have any other row of its kind that we can cross-check it with
SELECT * 
FROM layoff_staging2
WHERE company = "Bally's Interactive";

SELECT * 
FROM layoff_staging2;

SELECT * 
FROM layoff_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

DELETE
FROM layoff_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

ALTER TABLE layoff_staging2
DROP COLUMN row_num;

SELECT * 
FROM layoff_staging2;




