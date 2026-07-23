--Creation of Summary Tables for export to Tableau

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
