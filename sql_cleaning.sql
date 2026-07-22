--Made a copy of original table to perform data cleaning.
CREATE OR REPLACE TABLE `cedar-turbine-501913-v0.lend_club.accepted_clean`
AS
SELECT * FROM `cedar-turbine-501913-v0.lend_club.accepted`
