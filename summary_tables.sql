--Creation of Summary Tables for export to Tableau

--Overview of KPIs
CREATE OR REPLACE TABLE `cedar-turbine-501913-v0.lend_club.accepted_KPIs`
AS
SELECT
  COUNT(*) AS total_loans,
  SUM(funded_amnt) AS total_funded,
  SUM(total_pymnt) AS total_received,
  AVG(loan_amnt) AS avg_loan_amount,
  AVG(int_rate) AS avg_interest,
  AVG(dti) AS avg_dti,
  AVG(annual_inc) AS avg_annual_inc
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_final`
  
--Yearly trends
CREATE OR REPLACE TABLE`cedar-turbine-501913-v0.lend_club.accepted_yearly_overview`
AS
SELECT
  issue_year,
  COUNT(*) as total_loans,
  SUM(loan_amnt) as total_loaned,
  SUM(total_pymnt) as total_received,
  AVG(int_rate) as avg_interest,
  AVG(dti) as avg_dti
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_final`
GROUP BY issue_year
ORDER BY issue_year

--State performance
CREATE OR REPLACE TABLE `cedar-turbine-501913-v0.lend_club.accepted_state_summary`
AS
SELECT
  addr_state,
  COUNT(*) AS total_loans,
  SUM(funded_amnt) as total_funded,
  AVG(int_rate) as avg_interest,
  AVG(dti) as avg_dti
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_final`
GROUP BY addr_state
ORDER BY addr_state;

--Risk Analysis
CREATE OR REPLACE TABLE `cedar-turbine-501913-v0.lend_club.accepted_credit_risk`
AS
SELECT
  grade,
  verification_status,
  TRUNC(AVG(annual_inc),2) AS avg_inc,
  COUNT(default_flag) AS num_defaults,
  TRUNC(AVG(default_flag),3)*100 AS default_rate
FROM `cedar-turbine-501913-v0.lend_club.accepted_clean_final`
GROUP BY verification_status, grade
ORDER BY grade, verification_status DESC;
--This table showed the opposite of what I was expecting.
--In every grade, verified income is tied to a higher default rate than unverified.
--I suspect it may be related to the reason income was verified, such as previous defaults.
--Need additional data to confirm.
