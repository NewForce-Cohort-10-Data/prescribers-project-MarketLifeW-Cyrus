-- a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

-- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.

SELECT *
FROM prescriber;

SELECT *
FROM prescription;

SELECT npi, SUM(total_claim_count) highest_claim_count
FROM prescription
Group BY npi
ORDER BY highest_claim_count DESC;

SELECT pn.npi, pr.nppes_provider_first_name, pr.nppes_provider_last_org_name, pr.specialty_description, SUM(total_claim_count) highest_claim_count
FROM prescription pn
INNER JOIN prescriber pr
ON pn.npi = pr.npi
Group BY pn.npi, pr.nppes_provider_first_name, pr.nppes_provider_last_org_name, pr.specialty_description
ORDER BY highest_claim_count DESC;

-- a. Which specialty had the most total number of claims (totaled over all drugs)?

-- b. Which specialty had the most total number of claims for opioids?

-- c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

-- d. Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- ANSWER
SELECT DISTINCT pr.specialty_description, COUNT(pn.total_claim_count)
FROM prescriber pr
INNER JOIN prescription pn
ON pn.npi = pr.npi
INNER JOIN drug d
ON d.drug_name = pn.drug_name
WHERE d.opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY COUNT(pn.total_claim_count) desc;

SELECT pn.drug_name, opioid_drug_flag, pn.total_claim_count
FROM drug d
INNER JOIN prescription pn
ON pn.drug_name = d.drug_name
WHERE opioid_drug_flag = 'Y';

SELECT * 
FROM prescription;

WITH opioid_total AS (SELECT  COUNT(pn.total_claim_count) AS opioid_count
FROM prescriber pr
INNER JOIN prescription pn
ON pn.npi = pr.npi
INNER JOIN drug d
ON d.drug_name = pn.drug_name
WHERE d.opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY COUNT(pn.total_claim_count) desc),
total_total AS (SELECT COUNT(pn.total_claim_count) AS total_claims
FROM prescriber pr
INNER JOIN prescription pn
ON pn.npi = pr.npi
GROUP BY pr.specialty_description
ORDER BY COUNT( pn.total_claim_count) DESC)
SELECT (o.opioid_count/t.total_claims) AS percentage_claims_opioids
FROM opioid_total o, total_total t;

-- a. Which drug (generic_name) had the highest total drug cost?

-- b. Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.

SELECT generic_name, total_drug_cost
FROM drug d
INNER JOIN prescription p
ON p.drug_name = d.drug_name
ORDER BY total_drug_cost DESC;

SELECT total_day_supply, total_drug_cost, ROUND((total_drug_cost/total_day_supply), 2) AS cost_per_day
FROM prescription
ORDER by cost_per_Day DESC;

SELECT generic_name, ROUND((total_drug_cost/total_day_supply), 2) :: MONEY AS cost_per_day
FROM prescription p
INNER JOIN drug d
ON p.drug_name = d.drug_name
ORDER BY cost_per_day DESC;


-- a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. Hint: You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/

-- b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.



SELECT drug_name,
CASE
WHEN opioid_drug_flag = 'Y' THEN 'opioid'
WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE 'neither'
END AS drug_type
FROM drug;


SELECT drug_name,
CASE
WHEN opioid_drug_flag = 'Y' THEN 'opioid'
WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE 'neither'
END AS drug_type
FROM drug;

SELECT drug_type,
SUM(p.total_drug_cost) :: MONEY AS total_cost
FROM
(SELECT d.drug_name,
CASE
WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
WHEN d.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE 'neither'
END AS drug_type
FROM drug d)
AS group_drug
INNER JOIN prescription p
on group_drug.drug_name = p.drug_name
WHERE drug_type IN ('opioid','antibiotic') 
group BY drug_type
ORDER BY total_cost DESC;

-- a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.

-- b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

-- c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT COUNT(*)
FROM cbsa
WHERE cbsaname LIKE '%TN';
-- 33

SELECT DISTINCT c.cbsaname, 
p.population
FROM cbsa c
JOIN fips_county fc
ON c.fipscounty = fc.fipscounty
JOIN population p
ON fc.fipscounty = p.fipscounty
GROUP BY c.cbsaname, p.population
ORDER BY p.population DESC
LIMIT 1;


SELECT DISTINCT c.cbsaname, 
p.population
FROM cbsa c
JOIN fips_county fc
ON c.fipscounty = fc.fipscounty
JOIN population p
ON fc.fipscounty = p.fipscounty
GROUP BY c.cbsaname, p.population
ORDER BY p.population ASC
LIMIT 1;


SELECT  f.county,f.state,
p.population
FROM population p
JOIN fips_county f 
ON p.fipscounty = f.fipscounty
LEFT JOIN cbsa c 
ON f.fipscounty = c.fipscounty
WHERE c.cbsa IS NULL
ORDER BY p.population DESC
LIMIT 1;

-- a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
9

-- b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

-- c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.


SELECT p.drug_name, p.total_claim_count, d.opioid_drug_flag, nppes_provider_first_name, nppes_provider_last_org_name
FROM prescription p
INNER JOIN drug d
ON p.drug_name = d.drug_name
INNER JOIN
prescriber pr
ON pr.npi = p.npi
WHERE p.total_claim_count > 3000
ORDER BY total_claim_count DESC;


-- The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. Hint: The results from all 3 parts will have 637 rows.

-- a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

-- b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

-- c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

SELECT pr.npi, pr.specialty_description, d.drug_name
FROM prescriber pr
JOIN drug d
ON opioid_drug_flag = 'Y'
WHERE pr.specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE';

SELECT chart1.npi, chart1.drug_name, coalesce(total_claim_count, 0) AS total_claims
FROM
(SELECT pr.npi, pr.specialty_description, d.drug_name
FROM prescriber pr
JOIN drug d
ON opioid_drug_flag = 'Y'
WHERE pr.specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE') chart1
LEFT JOIN prescription pn
ON chart1.npi = pn.npi AND pn.drug_name = chart1.drug_name
ORDER BY total_claims DESC;

