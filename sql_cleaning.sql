--Made a copy of original table to perform data cleaning.
CREATE OR REPLACE TABLE `cedar-turbine-501913-v0.lend_club.accepted_clean`
AS
SELECT * FROM `cedar-turbine-501913-v0.lend_club.accepted`

--Checked for duplicates (none found)
SELECT DISTINCT 
  * 
FROM 
  `cedar-turbine-501913-v0.lend_club.accepted_clean`

--Removed columns with no analytical value
CREATE OR REPLACE TABLE `cedar-turbine-501913-v0.lend_club.accepted_clean`
AS
SELECT * EXCEPT(
    id,
    member_id,
    emp_title,
    pymnt_plan,
    payment_plan_start_date,
    url,
    policy_code,
    title,
    zip_code,
    hardship_type,
    hardship_reason,
    hardship_status,
    hardship_amount,
    hardship_loan_status,
    hardship_start_date,
    hardship_end_date,
    deferral_term,
    hardship_length,
    hardship_dpd,
    hardship_payoff_balance_amount,
    hardship_last_payment_amount,
    `desc`
)
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean`

--Created columns with the dates converted from string to date format
CREATE OR REPLACE TABLE `cedar-turbine-501913-v0.lend_club.accepted_clean`
AS
SELECT
  *,
  PARSE_DATE('%b-%Y', issue_d) AS issue_date,
  PARSE_DATE('%b-%Y', last_pymnt_d) AS last_pymnt_date, 
  PARSE_DATE('%b-%Y', next_pymnt_d) AS next_pymnt_date,
  PARSE_DATE('%b-%Y', last_credit_pull_d) AS last_credit_pull_date,
  PARSE_DATE('%b-%Y', earliest_cr_line) AS earliest_cr_line_date,
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean`

--Checked for missing values in key fields
SELECT
  COUNT(*) AS total_rows,

  --Overview
  COUNT(loan_amnt) AS loan_amnt_count,
  COUNT(funded_amnt) AS funded_amnt_count,
  COUNT(funded_amnt_inv) AS funded_amnt_inv_count,
  COUNT(term) AS term_count,
  COUNT(int_rate) AS int_rate_count,
  COUNT(installment) AS installment_count,
  COUNT(addr_state) AS addr_state_count,
  
  --Risk Analysis
  COUNT(grade) AS grade_count,
  COUNT(sub_grade) AS sub_grade_count,
  COUNT(dti) AS dti_count, --missing 1,711
  COUNT(fico_range_low) AS fico_low_count,
  COUNT(fico_range_high) AS fico_high_count,

  --Borrowers
  COUNT(annual_inc) AS income_count, --missing 4
  COUNT(verification_status) AS verification_count,
  COUNT(home_ownership) AS home_ownership_count,
  COUNT(emp_length) AS emp_length_count, --missing 146,907
  COUNT(purpose) AS purpose_count,

  --Performance
  COUNT(loan_status) AS loan_status_count,
  COUNT(total_pymnt) AS total_pymnt_count,
  COUNT(total_rec_prncp) AS principal_received_count,
  COUNT(total_rec_int) AS interest_received_count,
  COUNT(recoveries) AS recoveries_count,

  --Dates
  COUNT(issue_date) AS issue_date_count,
  COUNT(last_pymnt_date) AS last_pymnt_date_count --missing 2,427
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean`

--Replaced null emp_length values with 'Unknown'
UPDATE `cedar-turbine-501913-v0.lend_club.accepted_clean`
SET emp_length = 'Unknown'
WHERE emp_length IS NULL;

--Checked distinct values for the following categorical fields:
--loan_status, verification_status, home_ownership, purpose,
--grade, sub_grade, term, emp_length, addr_state

--Updated all misc home ownership types to 'OTHER'
UPDATE `cedar-turbine-501913-v0.lend_club.accepted_clean`
SET home_ownership = 'OTHER'
WHERE home_ownership = 'NONE' OR home_ownership = 'ANY'

--Combined credit policy statusus
UPDATE `cedar-turbine-501913-v0.lend_club.accepted_clean`
SET loan_status = 'Fully Paid'
WHERE loan_status = 'Does not meet the credit policy. Status:Fully Paid'

UPDATE `cedar-turbine-501913-v0.lend_club.accepted_clean`
SET loan_status = 'Charged Off'
WHERE loan_status = 'Does not meet the credit policy. Status:Charged Off'

--Grouped loan status types into new categories, created temp table for safety
CREATE OR REPLACE TABLE `cedar-turbine-501913-v0.lend_club.accepted_clean_temp`
AS
SELECT
  *,
  CASE
    WHEN loan_status IN ('Charged Off', 'Default') THEN 'Default'
    WHEN loan_status IN ('Late (16-30 days)', 'Late (31-120 days)', 'In Grace Period') THEN 'Delinquent'
    WHEN loan_status = 'Current' THEN 'Active'
    WHEN loan_status = 'Fully Paid' THEN 'Paid'
    ELSE 'Unknown'
  END AS loan_outcome
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean`
--Noticed many of the money values in the new table had a long string of trailing decimals

--Created a new temp table with money values converted from FLOAT64 to NUMERIC rounded to 2 places
CREATE OR REPLACE TABLE `cedar-turbine-501913-v0.lend_club.accepted_clean_temp_num`
AS
SELECT
  *
  EXCEPT(
  loan_amnt,
  funded_amnt,
  funded_amnt_inv,
  installment,
  total_pymnt,
  total_rec_prncp,
  total_rec_int,
  recoveries,
  collection_recovery_fee,
  last_pymnt_amnt
  ),
  CAST(ROUND(loan_amnt,2) AS NUMERIC) AS loan_amnt,
  CAST(ROUND(funded_amnt,2) AS NUMERIC) AS funded_amnt,
  CAST(ROUND(funded_amnt_inv,2) AS NUMERIC) AS funded_amnt_inv,
  CAST(ROUND(installment,2) AS NUMERIC) AS installment,
  CAST(ROUND(total_pymnt,2) AS NUMERIC) AS total_pymnt,
  CAST(ROUND(total_rec_prncp,2) AS NUMERIC) AS total_rec_prncp,
  CAST(ROUND(total_rec_int,2) AS NUMERIC) AS total_rec_int,
  CAST(ROUND(recoveries,2) AS NUMERIC) AS recoveries,
  CAST(ROUND(collection_recovery_fee,2) AS NUMERIC) AS collection_recovery_fee,
  CAST(ROUND(last_pymnt_amnt,2) AS NUMERIC) AS last_pymnt_amnt
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_temp`

--Numeric field validation
SELECT
  MIN(int_rate) AS min_rate,
  MAX(int_rate) AS max_rate,
  AVG(int_rate) AS avg_rate
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_temp_num`

SELECT
  MIN(dti) AS min_dti,
  MAX(dti) AS max_dti,
  AVG(dti) AS avg_dti
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_temp_num`

SELECT
  MIN(annual_inc) AS min_inc,
  MAX(annual_inc) AS max_inc,
  AVG(annual_inc) AS avg_inc
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_temp_num`

--Found unrealistic dti values, counted how many were out of range
SELECT
  COUNT(*) AS bad_dti
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_temp_num`
WHERE dti < 0 or dti > 100;

--Converted the 2563 records found to null values to preserve the average
UPDATE `cedar-turbine-501913-v0.lend_club.accepted_clean_temp_num`
SET dti = NULL
WHERE dti < 0 or dti > 100;

--Found a few extreme values for income, decided to leave them unchanged

--Grouped income into bands for easier analysis
CREATE OR REPLACE TABLE `cedar-turbine-501913-v0.lend_club.accepted_clean_temp_num`
AS
SELECT
  *,
  CASE
    WHEN annual_inc < 50000 THEN '<50k'
    WHEN annual_inc < 100000 THEN '50k-100k'
    WHEN annual_inc < 250000 THEN '100k-250k'
    WHEN annual_inc < 500000 THEN '250K-500K'
    WHEN annual_inc < 1000000 THEN '500K-1M'
    WHEN annual_inc < 5000000 THEN '1M-5M'
    ELSE '>5M'
  END AS income_band
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_temp_num`

--Validated risk factors
SELECT
  MIN(fico_range_low) AS min_fico_low,
  MAX(fico_range_low) AS max_fico_low,
  MIN(fico_range_high) AS min_fico_high,
  MAX(fico_range_high) AS max_fico_high
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_temp_num`

SELECT
  MIN(revol_util) AS min_revol_util,
  MAX(revol_util) AS max_revol_util,
  COUNTIF(revol_util < 0) AS negative_values,
  COUNTIF(revol_util > 100) AS over_100_percent
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_temp_num`

SELECT
  MIN(open_acc) AS min_open_acc,
  MAX(open_acc) AS max_opn_acc,
  COUNTIF(open_acc < 0) AS negative_accounts,
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_temp_num`

SELECT
  MIN(total_acc) AS min_total_acc,
  MAX(total_acc) AS max_total_acc,
  COUNTIF(total_acc < 0) AS negative_accounts,
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_temp_num`

SELECT
  MIN(pub_rec) AS min_pub_rec,
  MAX(pub_rec) AS max_pub_rec,
  COUNTIF(pub_rec < 0) AS negative_records,
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_temp_num`

SELECT
  MIN(pub_rec_bankruptcies) AS min_pub_rec_bankruptcies,
  MAX(pub_rec_bankruptcies) AS max_pub_rec_bankruptcies,
  COUNTIF(pub_rec_bankruptcies < 0) AS negative_pub_rec_bankruptcies,
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_temp_num`

SELECT
  MIN(delinq_2yrs) AS min_delinq_2yrs,
  MAX(delinq_2yrs) AS max_delinq_2yrs,
  COUNTIF(delinq_2yrs < 0) AS negative_delinq_2yrs,
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_temp_num`

SELECT
  MIN(inq_last_6mths) AS min_inq_last_6mths,
  MAX(inq_last_6mths) AS max_inq_last_6mths,
  COUNTIF(inq_last_6mths < 0) AS negative_inq_last_6mths,
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_temp_num`

SELECT
  MIN(mort_acc) AS min_mort_acc,
  MAX(mort_acc) AS max_mort_acc,
  COUNTIF(mort_acc < 0) AS negative_mort_acc,
  COUNTIF(mort_acc IS NULL) AS null_mort_acc,
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_temp_num`


--Final Validation
SELECT
  COUNTIF(fico_range_low IS NULL) AS fico_nulls,
  COUNTIF(revol_util IS NULL) AS revol_util_nulls,
  COUNTIF(open_acc IS NULL) AS open_acc_nulls,
  COUNTIF(total_acc IS NULL) AS total_acc_nulls,
  COUNTIF(pub_rec IS NULL) AS pub_rec_nulls,
  COUNTIF(pub_rec_bankruptcies IS NULL) AS pub_rec_bankruptcies_nulls,
  COUNTIF(delinq_2yrs IS NULL) AS delinq_2yrs_nulls,
  COUNTIF(inq_last_6mths IS NULL) AS inq_last_6mths_nulls,
  COUNTIF(mort_acc IS NULL) AS mort_acc_nulls
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_temp_num`
