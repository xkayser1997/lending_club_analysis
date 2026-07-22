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

--Converted dates from strings to dates
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
