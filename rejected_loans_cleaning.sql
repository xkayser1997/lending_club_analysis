--Created new table with no duplicate values, removed 157,954 duplicates
CREATE OR REPLACE TABLE `cedar-turbine-501913-v0.lend_club.accepted_clean_final`
AS
SELECT
  *
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_temp_num`

--Checking for nulls and outliers in Amount Requested
SELECT
  COUNT(*) as total_rejects,
  COUNT(`Amount Requested`) AS non_null_amounts,
  COUNTIF(`Amount Requested` is NULL) AS null_amounts,
  MIN(`Amount Requested`) AS min_amt,
  MAX(`Amount Requested`) AS max_amt,
  AVG(`Amount Requested`) AS avg_amt
FROM `cedar-turbine-501913-v0.lend_club.rejected_clean`
--No nulls

--Checking Application date
SELECT
  COUNT(*) as total_rows,
FROM `cedar-turbine-501913-v0.lend_club.rejected_clean`
WHERE `Application Date` IS NULL
--No nulls

SELECT
  MIN(`Application Date`) as min_date,
  MAX(`Application Date`) as max_date
FROM `cedar-turbine-501913-v0.lend_club.rejected_clean`
--No unexpected values

--Added Month and Year columns for easier analysis
ALTER TABLE `cedar-turbine-501913-v0.lend_club.rejected_clean`
ADD COLUMN application_month INT64;
ALTER TABLE `cedar-turbine-501913-v0.lend_club.rejected_clean`
ADD COLUMN application_year INT64;

UPDATE `cedar-turbine-501913-v0.lend_club.rejected_clean`
SET application_month = EXTRACT(MONTH FROM `Application Date`),
    application_year = EXTRACT(YEAR FROM `Application Date`)
WHERE TRUE

--Checking Loan Title Categories
SELECT 
  CASE
    WHEN LOWER(`Loan Title`) LIKE '%debt%' 
      OR LOWER(`Loan Title`) LIKE '%consolid%'
      THEN 'Debt Consolidation'

    WHEN LOWER(`Loan Title`) LIKE '%credit%' 
      OR LOWER(`Loan Title`) LIKE '%card%'
      THEN 'Credit Card'

    WHEN LOWER(`Loan Title`) LIKE '%car%' 
      OR LOWER(`Loan Title`) LIKE '%auto%'
      OR LOWER(`Loan Title`) LIKE '%vehicle%'
      THEN 'Auto Loan'

    WHEN LOWER(`Loan Title`) LIKE '%home%' 
      OR LOWER(`Loan Title`) LIKE '%house%'
      OR LOWER(`Loan Title`) Like '%repair%'
      THEN 'Home Improvement'

    WHEN LOWER(`Loan Title`) LIKE '%medical%' 
      OR LOWER(`Loan Title`) LIKE '%health%'
      OR LOWER(`Loan Title`) Like '%hospital%'
      THEN 'Medical'

    WHEN LOWER(`Loan Title`) LIKE '%business%' 
      THEN 'Business'

    WHEN LOWER(`Loan Title`) LIKE '%school%' 
      OR LOWER(`Loan Title`) LIKE '%education%'
      OR LOWER(`Loan Title`) Like '%college%'
      THEN 'Education'

    ELSE 'Other'
  END AS loan_purpose_category,
  COUNT(*) AS loan_count
FROM`cedar-turbine-501913-v0.lend_club.rejected_clean`
GROUP BY loan_purpose_category
ORDER BY loan_count DESC;

--Created column for Loan Purpose, updated with values
UPDATE `cedar-turbine-501913-v0.lend_club.rejected_clean`
SET `Loan Purpose` = 
  CASE
    WHEN LOWER(`Loan Title`) LIKE '%debt%' 
      OR LOWER(`Loan Title`) LIKE '%consolid%'
      THEN 'Debt Consolidation'

    WHEN LOWER(`Loan Title`) LIKE '%credit%' 
      OR LOWER(`Loan Title`) LIKE '%card%'
      THEN 'Credit Card'

    WHEN LOWER(`Loan Title`) LIKE '%car%' 
      OR LOWER(`Loan Title`) LIKE '%auto%'
      OR LOWER(`Loan Title`) LIKE '%vehicle%'
      THEN 'Auto Loan'

    WHEN LOWER(`Loan Title`) LIKE '%home%' 
      OR LOWER(`Loan Title`) LIKE '%house%'
      OR LOWER(`Loan Title`) Like '%repair%'
      THEN 'Home Improvement'

    WHEN LOWER(`Loan Title`) LIKE '%medical%' 
      OR LOWER(`Loan Title`) LIKE '%health%'
      OR LOWER(`Loan Title`) Like '%hospital%'
      THEN 'Medical'

    WHEN LOWER(`Loan Title`) LIKE '%business%' 
      THEN 'Business'

    WHEN LOWER(`Loan Title`) LIKE '%school%' 
      OR LOWER(`Loan Title`) LIKE '%education%'
      OR LOWER(`Loan Title`) Like '%college%'
      THEN 'Education'

    ELSE 'Other'
  END
WHERE TRUE

--Checked Risk Scores
SELECT 
  COUNT(*) as total_records,
  COUNT(Risk_Score) AS populated_scores,
  COUNTIF(Risk_Score IS NULL) as null_scores,
  MIN(Risk_Score) as min_score,
  MAX(Risk_Score) as max_score,
  AVG(Risk_Score) as avg_score
FROM `cedar-turbine-501913-v0.lend_club.rejected_clean`
--Returned 18359858 null values

SELECT 
  COUNT(*) as total_records,
  COUNTIF(Risk_Score <300) AS low_scores,
  COUNTIF(Risk_Score > 850) as high_scores

FROM `cedar-turbine-501913-v0.lend_club.rejected_clean`
--Small distribution outside of normal range
