--Healthcare Operations & Revenue Analytics

--PostgreSQL Business Analysis

============================================================
-- 1. DATA QUALITY & CLEANING
-- ============================================================

-- 1.1 Check total number of records

SELECT COUNT(*) AS total_records
FROM hospital_raw;

-- Finding:
-- The dataset contains 8,000 records.

-- 1.2 Check NULL values across important columns

SELECT
COUNT() - COUNT(month) AS month_nulls,
COUNT() - COUNT(case_no) AS case_no_nulls,
COUNT() - COUNT(dob) AS dob_nulls,
COUNT() - COUNT(nationality) AS nationality_nulls,
COUNT() - COUNT(gender) AS gender_nulls,
COUNT() - COUNT(doctor_license) AS doctor_license_nulls,
COUNT() - COUNT(doctor_name) AS doctor_name_nulls,
COUNT() - COUNT(doctor_type) AS doctor_type_nulls,
COUNT() - COUNT(doctor_status) AS doctor_status_nulls,
COUNT() - COUNT(cmi_value) AS cmi_nulls,
COUNT() - COUNT(specialty) AS specialty_nulls,
COUNT() - COUNT(insurance_payer) AS insurance_payer_nulls,
COUNT() - COUNT(insurance_plan_name) AS insurance_plan_nulls,
COUNT() - COUNT(payer_mix) AS payer_mix_nulls,
COUNT() - COUNT(case_type) AS case_type_nulls,
COUNT() - COUNT(los) AS los_nulls,
COUNT() - COUNT(severity) AS severity_nulls,
COUNT() - COUNT(surgical_mix) AS surgical_mix_nulls,
COUNT() - COUNT(discharge_time) AS discharge_time_nulls,
COUNT() - COUNT(discharge_before_12pm) AS discharge_before_12pm_nulls,
COUNT(*) - COUNT(revenue) AS revenue_nulls
FROM hospital_raw;

-- Finding:
-- NULL values were checked across the major patient, clinical,
-- operational, doctor, insurance and financial fields.
-- Missing values are handled separately according to the meaning
-- of each field rather than automatically replacing them.

-- 1.3 Check duplicate Case_No values

SELECT
case_no,
COUNT() AS case_count
FROM hospital_raw
GROUP BY case_no
HAVING COUNT() > 1
ORDER BY case_count DESC;

-- Finding:
-- Duplicate Case_No values were checked to determine whether the
-- case identifier uniquely represents a record.
-- Duplicate identifiers should be investigated before removing
-- any records because repeated Case_No values may be legitimate
-- or may represent duplicate records.

-- 1.4 Check for completely duplicated records

SELECT
month,
case_no,
dob,
nationality,
gender,
doctor_license,
doctor_name,
doctor_type,
doctor_status,
cmi_value,
specialty,
insurance_payer,
insurance_plan_name,
payer_mix,
case_type,
los,
severity,
surgical_mix,
discharge_time,
discharge_before_12pm,
revenue,
COUNT() AS duplicate_count
FROM hospital_raw
GROUP BY
month,
case_no,
dob,
nationality,
gender,
doctor_license,
doctor_name,
doctor_type,
doctor_status,
cmi_value,
specialty,
insurance_payer,
insurance_plan_name,
payer_mix,
case_type,
los,
severity,
surgical_mix,
discharge_time,
discharge_before_12pm,
revenue
HAVING COUNT() > 1;

-- Finding:
-- Complete duplicate records were checked across all available columns.
-- Any duplicates should be investigated before removal.

-- 1.5 Check distinct categorical values

SELECT DISTINCT gender
FROM hospital_raw
ORDER BY gender;

SELECT DISTINCT severity
FROM hospital_raw
ORDER BY severity;

SELECT DISTINCT specialty
FROM hospital_raw
ORDER BY specialty;

SELECT DISTINCT case_type
FROM hospital_raw
ORDER BY case_type;

SELECT DISTINCT surgical_mix
FROM hospital_raw
ORDER BY surgical_mix;

SELECT DISTINCT doctor_type
FROM hospital_raw
ORDER BY doctor_type;

SELECT DISTINCT doctor_status
FROM hospital_raw
ORDER BY doctor_status;

SELECT DISTINCT insurance_payer
FROM hospital_raw
ORDER BY insurance_payer;

SELECT DISTINCT payer_mix
FROM hospital_raw
ORDER BY payer_mix;

SELECT DISTINCT discharge_before_12pm
FROM hospital_raw
ORDER BY discharge_before_12pm;

-- Finding:
-- Distinct categorical values were inspected to identify unexpected
-- categories, inconsistent spellings or formatting issues before analysis.

-- 1.6 Check for leading/trailing whitespace in categorical fields

SELECT
specialty,
TRIM(specialty) AS cleaned_specialty
FROM hospital_raw
WHERE specialty <> TRIM(specialty);

-- Finding:
-- TRIM can be used to identify categorical values containing
-- unnecessary leading or trailing spaces.

-- 1.7 Check numeric ranges for LOS

SELECT
MIN(los) AS minimum_los,
MAX(los) AS maximum_los,
AVG(los) AS average_los
FROM hospital_raw;

-- Finding:
-- LOS was checked for unexpected negative or extreme values before
-- using it for operational and revenue analysis.

-- 1.8 Check numeric ranges for Revenue

SELECT
MIN(revenue) AS minimum_revenue,
MAX(revenue) AS maximum_revenue,
AVG(revenue) AS average_revenue
FROM hospital_raw;

-- Finding:
-- Revenue was checked for negative or unexpected values before
-- performing financial analysis.

-- 1.9 Check numeric ranges for CMI

SELECT
MIN(cmi_value) AS minimum_cmi,
MAX(cmi_value) AS maximum_cmi,
ROUND(AVG(cmi_value), 2) AS average_cmi
FROM hospital_raw;

-- Finding:
-- CMI values range from 0.65 to 1.472, with an overall average
-- of approximately 1.06.

-- 1.10 Check Month range

SELECT
MIN(month) AS earliest_month,
MAX(month) AS latest_month
FROM hospital_raw;

-- Finding:
-- The dataset covers the year 2025.

-- 1.11 Check Discharge Time range

SELECT
MIN(discharge_time) AS earliest_discharge_time,
MAX(discharge_time) AS latest_discharge_time
FROM hospital_raw;

-- Finding:
-- Discharge times were checked for unexpected time values before
-- analyzing discharge patterns.

-- 1.12 Calculate missing percentage for Discharge Before 12PM

SELECT
COUNT() AS total_cases,
COUNT(discharge_before_12pm) AS recorded_cases,
COUNT() - COUNT(discharge_before_12pm) AS missing_cases,
ROUND(
(COUNT() - COUNT(discharge_before_12pm)) * 100.0
/ COUNT(),
2
) AS missing_percentage
FROM hospital_raw;

-- Finding:
-- 4,891 out of 8,000 cases have missing Discharge Before 12PM data,
-- representing 61.14% of the dataset.
-- Missing values are not treated as "No" because missing information
-- does not necessarily mean the discharge did not occur before 12 PM.

-- 1.13 Calculate missing percentage for Insurance Plan

SELECT
COUNT() AS total_cases,
COUNT(insurance_plan_name) AS recorded_cases,
COUNT() - COUNT(insurance_plan_name) AS missing_cases,
ROUND(
(COUNT() - COUNT(insurance_plan_name)) * 100.0
/ COUNT(),
2
) AS missing_percentage
FROM hospital_raw;

-- Finding:
-- Insurance Plan information is missing for a significant portion
-- of the dataset and should be considered when interpreting
-- insurance-plan-level analysis.

-- ============================================================

-- 1. Patient & Demographic Analysis

--1.1 What is the age distribution of patients?

SELECT
    dob,
    2025 - dob AS age,
    COUNT(*) AS case_count
FROM hospital_raw
GROUP BY dob
ORDER BY age;


-- Finding

--The dataset contains patients approximately between 19 and 75 years of age. Since only the birth year is available, the calculated age is approximate.

--1.2 Which age group has the highest number of cases?

SELECT
    CASE
        WHEN 2025 - dob BETWEEN 19 AND 30 THEN '19-30'
        WHEN 2025 - dob BETWEEN 31 AND 45 THEN '31-45'
        WHEN 2025 - dob BETWEEN 46 AND 60 THEN '46-60'
        WHEN 2025 - dob BETWEEN 61 AND 75 THEN '61-75'
    END AS age_group,
    COUNT(*) AS case_count
FROM hospital_raw
GROUP BY age_group
ORDER BY age_group;

-- Finding

--The 31–45 age group had the highest number of cases with 2,178 cases, while the 19–30 age group had the lowest with 1,646 cases.

-- 1.3 What is the gender distribution of cases?

SELECT
    gender,
    COUNT(*) AS case_count
FROM hospital_raw
GROUP BY gender
ORDER BY case_count DESC;

-- Finding

--The gender distribution was almost equal, with 4,004 male cases and 3,996 female cases.

-- 1.4 What is the distribution of cases by case type?

SELECT
    case_type,
    COUNT(*) AS case_count
FROM hospital_raw
GROUP BY case_type
ORDER BY case_count DESC;

-- Finding

--OP had the highest number of cases with 4,891 cases, followed by IP with 2,165 cases and DC with 944 cases.

--1.5 What is the distribution of cases by nationality?

SELECT
    nationality,
    COUNT(*) AS case_count
FROM hospital_raw
GROUP BY nationality
ORDER BY case_count DESC;

-- Finding

--The dataset contains 14 nationalities. Germany had the highest number of cases with 605, while Sri Lanka had the lowest with 518. Overall, the distribution was relatively even.

--2. Clinical Analysis

--2.1 What is the distribution of cases across severity levels?

SELECT
    severity,
    COUNT(*) AS case_count
FROM hospital_raw
GROUP BY severity
ORDER BY severity;

-- Finding

--Severity 1 had 3,328 cases, Severity 2 had 3,186 cases, and Severity 3 had 1,486 cases.

-- 2.2 How are severity levels distributed across specialties?

SELECT
    specialty,
    severity,
    COUNT(case_no) AS case_count
FROM hospital_raw
GROUP BY specialty, severity
ORDER BY specialty, severity;

-- Finding

--Orthopaedics had the highest number of cases across all three severity levels. This represents higher case volume and does not necessarily indicate higher severity.

-- 2.3 What percentage of each specialty's cases belong to each severity level?

SELECT
    specialty,
    severity,
    COUNT(*) AS cases,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY specialty),
        2
    ) AS percentage
FROM hospital_raw
GROUP BY specialty, severity
ORDER BY specialty, severity;

--Finding

--The query shows the percentage distribution of severity levels within each specialty. For example, Emergency had 43.87% of its cases at Severity 1, while Gastroenterology had 42.60% at Severity 2.

--2.4 How are severity levels distributed between Medical and Surgery cases?

SELECT
    surgical_mix,
    severity,
    COUNT(*) AS case_count
FROM hospital_raw
GROUP BY surgical_mix, severity
ORDER BY surgical_mix, severity;

--Finding

--Medical cases had a higher number of cases than Surgery cases across all three severity levels.

--2.5 Does average length of stay vary across severity levels?

SELECT
    severity,
    COUNT(*) AS case_count,
    ROUND(AVG(los), 2) AS average_los
FROM hospital_raw
GROUP BY severity
ORDER BY severity;

--Finding

--Average LOS remained almost constant across all three severity levels, ranging from 1.32 to 1.33 days.

-- 2.6 What is the overall range and average of CMI?

SELECT
    MIN(cmi_value) AS min_cmi,
    MAX(cmi_value) AS max_cmi,
    ROUND(AVG(cmi_value), 2) AS average_cmi
FROM hospital_raw;

-- Finding

--CMI ranged from 0.65 to 1.472, with an overall average of 1.06.

-- 2.7 How does average CMI vary across severity levels?

SELECT
    severity,
    COUNT(*) AS case_count,
    ROUND(AVG(cmi_value), 2) AS average_cmi
FROM hospital_raw
GROUP BY severity
ORDER BY severity;

-- Finding

--Average CMI increased from 1.01 for Severity 1 to 1.13 for Severity 3, indicating that higher severity was associated with higher case complexity in this dataset.

-- 2.8 How does average revenue vary across severity levels?

SELECT
    severity,
    COUNT(*) AS case_count,
    ROUND(AVG(revenue), 2) AS average_revenue
FROM hospital_raw
GROUP BY severity
ORDER BY severity;

-- Finding

--Average revenue increased slightly across severity levels, from ₹16,775.70 for Severity 1 to ₹17,198.81 for Severity 3.

-- 2.9 How do Medical and Surgery cases differ in CMI, LOS and revenue?

SELECT
    surgical_mix,
    COUNT(*) AS case_count,
    ROUND(AVG(cmi_value), 2) AS average_cmi,
    ROUND(AVG(los), 2) AS average_los,
    ROUND(AVG(revenue), 2) AS average_revenue
FROM hospital_raw
GROUP BY surgical_mix
ORDER BY surgical_mix;

--Finding

--Medical cases had higher case volume, while Surgery cases had slightly higher average LOS and higher average revenue per case. Average CMI was identical at 1.06.

-- 2.10 Which specialties have the highest average CMI?

SELECT
    specialty,
    COUNT(*) AS case_count,
    ROUND(AVG(cmi_value), 2) AS average_cmi
FROM hospital_raw
GROUP BY specialty
ORDER BY average_cmi DESC;

-- Finding

--Average CMI showed very little variation across specialties, ranging from 1.05 to 1.07. General Surgery had the highest average CMI at 1.07.

--2.11 Which specialties have the highest average LOS?

SELECT
    specialty,
    COUNT(*) AS case_count,
    ROUND(AVG(los), 2) AS average_los
FROM hospital_raw
GROUP BY specialty
ORDER BY average_los DESC;

-- Finding

--Average LOS ranged from 1.19 days in Gastroenterology to 1.45 days in Pulmonology. Pulmonology had the highest average LOS.

--3. Operations Analysis

--3.1 What is the availability of discharge-before-12PM information?

SELECT
    discharge_before_12pm,
    COUNT(*) AS case_count
FROM hospital_raw
GROUP BY discharge_before_12pm
ORDER BY case_count DESC;

-- Finding

--4,891 cases had missing discharge-before-12PM information. There were 1,930 cases marked Yes and 1,179 marked No.

-- 3.2 What percentage of recorded cases were discharged before 12 PM?

SELECT
    discharge_before_12pm,
    COUNT(*) AS case_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM hospital_raw
WHERE discharge_before_12pm IS NOT NULL
GROUP BY discharge_before_12pm
ORDER BY discharge_before_12pm;

--Finding

--Among the 3,109 cases with recorded values, 62.08% were discharged before 12 PM and 37.92% were not. However, 4,891 cases had missing information, so the percentage applies only to cases with recorded values.

-- 3.3 How does early discharge vary across specialties?

SELECT
    specialty,
    COUNT(*) AS total_cases,
    SUM(
        CASE
            WHEN discharge_before_12pm = 'Yes' THEN 1
            ELSE 0
        END
    ) AS before_12pm,
    ROUND(
        SUM(
            CASE
                WHEN discharge_before_12pm = 'Yes' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS percentage_before_12pm
FROM hospital_raw
WHERE discharge_before_12pm IS NOT NULL
GROUP BY specialty
ORDER BY percentage_before_12pm DESC;

--Finding

--Among cases with recorded discharge information, the percentage discharged before 12 PM ranged from 56.54% in Internal Medicine to 70.67% in Gastroenterology.


-- 3.4 How does the percentage of early discharges vary by month?

SELECT
    month,
    COUNT(*) AS recorded_cases,
    SUM(
        CASE
            WHEN discharge_before_12pm = 'Yes' THEN 1
            ELSE 0
        END
    ) AS before_12pm,
    ROUND(
        SUM(
            CASE
                WHEN discharge_before_12pm = 'Yes' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS percentage_before_12pm
FROM hospital_raw
WHERE discharge_before_12pm IS NOT NULL
GROUP BY month
ORDER BY month;

--Finding

--The percentage of recorded cases discharged before 12 PM ranged from 59.67% in July to 68.60% in October. Most months were around 60–65%, with no clear continuous upward or downward trend.

--3.5 At what time are most discharges recorded?

SELECT
    EXTRACT(HOUR FROM discharge_time) AS discharge_hour,
    COUNT(*) AS case_count
FROM hospital_raw
WHERE discharge_time IS NOT NULL
GROUP BY discharge_hour
ORDER BY discharge_hour;

--Finding

--Discharges were concentrated during the morning and early afternoon. 10 AM had the highest number of recorded discharges with 416 cases, and discharge volume generally decreased after noon.

--4. Doctor Analysis

-- 4.1 How many cases were handled by each doctor?

SELECT
    doctor_name,
    COUNT(*) AS case_count
FROM hospital_raw
GROUP BY doctor_name
ORDER BY case_count DESC;

--Finding

--Dr. Tom Iyer handled the highest number of cases with 165, while Dr. Noor Nguyen handled the lowest with 108. Case volumes were relatively spread out across doctors.

-- 4.2 How are cases distributed across doctor types?

SELECT
    doctor_type,
    COUNT(*) AS case_count
FROM hospital_raw
GROUP BY doctor_type
ORDER BY case_count DESC;

-- Finding

--GP doctors handled 2,731 cases, Specialists handled 2,705, and Consultants handled 2,564. The distribution was relatively balanced.

--4.3 Does average revenue differ by doctor type?

SELECT
    doctor_type,
    COUNT(*) AS case_count,
    ROUND(AVG(revenue), 2) AS average_revenue
FROM hospital_raw
GROUP BY doctor_type
ORDER BY average_revenue DESC;

--Finding

--Specialists had the highest average revenue per case at ₹17,705.24, while GPs had the highest case volume. Higher case volume did not necessarily correspond to higher revenue per case.

-- 5. Insurance & Payer Analysis

-- 5.1 Which insurance payers have the highest case volume?

SELECT
    insurance_payer,
    COUNT(*) AS case_count
FROM hospital_raw
GROUP BY insurance_payer
ORDER BY case_count DESC;

-- Finding

--PureWin Insurance had the highest case volume with 1,918 cases, while BlueMedic Charity had the lowest with 1,059 cases.

-- 5.2 How does average revenue vary by insurance payer?

SELECT
    insurance_payer,
    COUNT(*) AS case_count,
    ROUND(AVG(revenue), 2) AS average_revenue
FROM hospital_raw
GROUP BY insurance_payer
ORDER BY average_revenue DESC;

--Finding

--PureWin Insurance had the highest average revenue per case at ₹17,844.71, while TotalHealth Insurance had the lowest at ₹16,300.84.

--5.3 Which insurance payer generates the highest total revenue?

SELECT
    insurance_payer,
    COUNT(*) AS case_count,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM hospital_raw
GROUP BY insurance_payer
ORDER BY total_revenue DESC;

--Finding

--PureWin Insurance generated the highest total revenue at approximately ₹34.23 million, while BlueMedic Charity generated approximately ₹17.41 million.

--5.4 How complete is the insurance-plan information?

SELECT
    insurance_plan_name,
    COUNT(*) AS case_count
FROM hospital_raw
GROUP BY insurance_plan_name
ORDER BY case_count DESC;

--Finding

--2,198 out of 8,000 cases had no recorded insurance plan, representing approximately 27.48% of the dataset. The named plans each had roughly 609–666 cases.

-- 6. Financial Analysis

--6.1 What is the overall revenue generated by the hospital?

SELECT
    COUNT(*) AS total_cases,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(revenue), 2) AS average_revenue_per_case
FROM hospital_raw;

-- Finding

--The dataset contains 8,000 cases and total revenue of ₹135,845,993, with an average revenue of ₹16,980.75 per case.

-- 6.2 Which specialties generate the highest total revenue?

SELECT
    specialty,
    COUNT(*) AS case_count,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(revenue), 2) AS average_revenue
FROM hospital_raw
GROUP BY specialty
ORDER BY total_revenue DESC;

--Finding

--Orthopaedics generated the highest total revenue at ₹24.54 million, mainly due to its high case volume. Pulmonology had the highest average revenue per case at ₹18,475.98.

--6.3 How does revenue vary by month?

SELECT
    month,
    COUNT(*) AS case_count,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(revenue), 2) AS average_revenue
FROM hospital_raw
GROUP BY month
ORDER BY month;

--Finding

--January had the highest case volume with 714 cases and the highest total revenue at approximately ₹12.78 million. November had the highest average revenue per case at ₹19,032.33, while March had the lowest at ₹15,189.27. Monthly revenue fluctuated without a simple overall trend.

--6.4 How does revenue vary by case type?

SELECT
    case_type,
    COUNT(*) AS case_count,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(revenue), 2) AS average_revenue
FROM hospital_raw
GROUP BY case_type
ORDER BY total_revenue DESC;

--Finding

--IP cases generated approximately ₹123.94 million in total revenue despite having only 2,165 cases. Their average revenue per case was ₹57,245.11, compared with ₹1,270.47 for OP and ₹6,034.38 for DC. This shows that case volume does not necessarily correspond to financial contribution.

-- 6.5 How does average revenue vary with length of stay?

SELECT
    los,
    COUNT(*) AS case_count,
    ROUND(AVG(revenue), 2) AS average_revenue
FROM hospital_raw
GROUP BY los
ORDER BY los;

--Finding

--Longer LOS was associated with substantially higher average revenue per case. Average revenue increased from ₹1,270.47 for LOS 0 to ₹84,348.82 for LOS 7.

-- 7. Relationship Analysis

--7.1 How are LOS values distributed across case types?

SELECT
    los,
    case_type,
    COUNT(*) AS case_count
FROM hospital_raw
GROUP BY los, case_type
ORDER BY los, case_type;

--Finding

--The dataset shows a very clear relationship between LOS and case type:

* LOS 0 → OP: 4,891 cases
* LOS 1 → DC: 944 cases
* LOS 2–7 → IP cases

This indicates that LOS and case type are closely structured in this dataset.

---

# 8. Key Findings from PostgreSQL Analysis

The PostgreSQL analysis produced the following major findings:

1. The dataset contains **8,000 healthcare cases**.
2. The gender distribution was almost equal, with **4,004 male and 3,996 female cases**.
3. The **31–45 age group** had the highest case volume with 2,178 cases.
4. **Orthopaedics** had the highest case volume among specialties.
5. Average CMI increased from **1.01 at Severity 1 to 1.13 at Severity 3**.
6. Average LOS remained almost constant across severity levels at approximately **1.32–1.33 days**.
7. **Pulmonology** had the highest average LOS at 1.45 days.
8. Surgery cases had slightly higher average LOS and higher average revenue per case than Medical cases.
9. **61.14% of cases** had missing discharge-before-12PM information.
10. Among cases with recorded discharge information, **62.08% were discharged before 12 PM**.
11. Discharges were concentrated in the morning and early afternoon, with **10 AM having the highest recorded discharge volume**.
12. GP doctors handled the highest number of cases, while Specialists had the highest average revenue per case.
13. **PureWin Insurance** had the highest case volume and highest total revenue among payers.
14. **27.48% of cases** had missing insurance-plan information.
15. Total revenue across the dataset was **₹135,845,993**, with an average of **₹16,980.75 per case**.
16. Orthopaedics generated the highest total specialty revenue, while Pulmonology had the highest average revenue per case.
17. IP cases generated substantially higher total and average revenue than OP and DC cases.
18. Longer LOS was associated with substantially higher average revenue per case.
19. LOS and case type showed a very clear structural relationship: **LOS 0 → OP, LOS 1 → DC, and LOS 2–7 → IP**.

--Conclusion

The PostgreSQL analysis provided a structured view of patient demographics, clinical characteristics, hospital operations, doctor activity, insurance/payer patterns and financial performance.

The analysis also identified important data-quality issues, particularly missing discharge and insurance-plan information. These findings can be explored further through Python-based EDA and visualized through an interactive Power BI dashboard.

**Next Stage: Python EDA → Power BI Dashboard → GitHub Documentation**
