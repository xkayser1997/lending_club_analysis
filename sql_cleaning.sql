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
