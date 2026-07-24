--Creation of Summary Tables for export to Tableau

--Portfolio Overview: Overview of KPIs, Yearly Trends, State performance, and Purpose
--Overview of KPIs
CREATE OR REPLACE TABLE `cedar-turbine-501913-v0.lend_club.overview_KPIs`
AS
SELECT
  COUNT(*) AS total_loans,
  SUM(funded_amnt) AS total_funded,
  SUM(total_pymnt) AS total_received,
  SUM(total_pymnt) - SUM(funded_amnt) AS net_profit,
  ROUND(AVG(loan_amnt),2) AS avg_loan_amount,
  ROUND(AVG(int_rate),2) AS avg_interest,
  ROUND(AVG(dti),2) AS avg_dti,
  ROUND(AVG(annual_inc),2) AS avg_annual_inc,
  ROUND(AVG(default_flag)*100,2) AS default_rate
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_final`
  
--Yearly trends
CREATE OR REPLACE TABLE `cedar-turbine-501913-v0.lend_club.overview_by_year`
AS
SELECT
  issue_year,
  COUNT(*) AS total_loans,
  SUM(funded_amnt) AS total_funded,
  SUM(total_pymnt) AS total_received,
  ROUND(AVG(loan_amnt),2) AS avg_loan_amount,
  ROUND(AVG(int_rate),2) AS avg_interest,
  ROUND(AVG(dti),2) AS avg_dti,
  ROUND(AVG(annual_inc),2) AS avg_annual_inc,
  ROUND(AVG(default_flag)*100,2) AS default_rate
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_final`
GROUP BY issue_year
ORDER BY issue_year

--State performance
CREATE OR REPLACE TABLE `cedar-turbine-501913-v0.lend_club.overview_by_state`
AS
SELECT
  addr_state,
  COUNT(*) AS total_loans,
  SUM(funded_amnt) AS total_funded,
  SUM(total_pymnt) AS total_received,
  ROUND(AVG(loan_amnt),2) AS avg_loan_amount,
  ROUND(AVG(int_rate),2) AS avg_interest,
  ROUND(AVG(annual_inc),2) AS avg_annual_inc,
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_final`
GROUP BY addr_state
ORDER BY addr_state

--Overview by purpose
  CREATE OR REPLACE TABLE `cedar-turbine-501913-v0.lend_club.overview_by_purpose`
AS
SELECT
  purpose,
  COUNT(*) AS total_loans,
  SUM(funded_amnt) AS total_funded,
  SUM(total_pymnt) AS total_received,
  ROUND(AVG(loan_amnt),2) AS avg_loan_amount,
  ROUND(AVG(int_rate),2) AS avg_interest,
  ROUND(AVG(annual_inc),2) AS avg_annual_inc,
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_final`
GROUP BY purpose
ORDER BY purpose

  
--Risk Analysis: Risk by Grade. DTI bands, Income bands, Employment Length, Purpose, and Loan Size bands
--Risk by Grade
CREATE OR REPLACE TABLE `cedar-turbine-501913-v0.lend_club.risk_by_grade` 
AS
SELECT
  grade,
  COUNT(*) as total_loans,
  ROUND(AVG(default_flag)*100, 2) as default_rate
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_final`
GROUP BY grade
ORDER BY grade

--Risk by Income
CREATE OR REPLACE TABLE `cedar-turbine-501913-v0.lend_club.risk_by_income` 
AS
SELECT
  income_band,
  COUNT(*) as total_loans,
  ROUND(AVG(default_flag)*100, 2) as default_rate
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_final`
GROUP BY income_band
ORDER BY income_band

--Risk by Purpose
CREATE OR REPLACE TABLE `cedar-turbine-501913-v0.lend_club.risk_by_purpose` 
AS
SELECT
  purpose,
  COUNT(*) as total_loans,
  ROUND(AVG(default_flag)*100, 2) as default_rate
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_final`
GROUP BY purpose
ORDER BY purpose
