-- What are the top 10 highest-paying Data Analyst jobs?
SELECT 
    j.job_title,
    c.name AS company_name,
    j.job_location,
    j.salary_year_avg,
    j.job_schedule_type,
    j.job_work_from_home
FROM job_postings_fact j
JOIN company_dim c ON j.company_id = c.company_id
WHERE j.job_title_short = 'Data Analyst'
  AND j.salary_year_avg IS NOT NULL
ORDER BY j.salary_year_avg DESC
LIMIT 10;

-- What skills are required for the top-paying Data Analyst jobs?
SELECT 
    j.job_title,
    j.salary_year_avg,
    STRING_AGG(s.skills, ', ') AS required_skills
FROM job_postings_fact j
LEFT JOIN skills_job_dim sj ON j.job_id = sj.job_id
LEFT JOIN skills_dim s ON sj.skill_id = s.skill_id
WHERE j.job_title_short = 'Data Analyst'
  AND j.salary_year_avg IS NOT NULL
GROUP BY j.job_id, j.job_title, j.salary_year_avg
ORDER BY j.salary_year_avg DESC
LIMIT 10;

-- What are the most in-demand skills for Data Analyst positions?
SELECT 
    s.skills,
    COUNT(sj.job_id) AS demand_count
FROM job_postings_fact j
JOIN skills_job_dim sj ON j.job_id = sj.job_id
JOIN skills_dim s ON sj.skill_id = s.skill_id
WHERE j.job_title_short = 'Data Analyst'
GROUP BY s.skills
ORDER BY demand_count DESC
LIMIT 10;

-- Which skills are associated with higher salaries for Data Analysts?
SELECT 
    s.skills,
    ROUND(AVG(j.salary_year_avg), 2) AS avg_salary,
    COUNT(sj.job_id) AS job_count
FROM job_postings_fact j
JOIN skills_job_dim sj ON j.job_id = sj.job_id
JOIN skills_dim s ON sj.skill_id = s.skill_id
WHERE j.job_title_short = 'Data Analyst'
  AND j.salary_year_avg IS NOT NULL
GROUP BY s.skills
HAVING COUNT(sj.job_id) >= 10
ORDER BY avg_salary DESC
LIMIT 20;

-- What is the average salary for Data Analysts by location?
SELECT 
    job_location,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_year_avg), 2) AS avg_salary,
    MAX(salary_year_avg) AS max_salary
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
  AND salary_year_avg IS NOT NULL
GROUP BY job_location
HAVING COUNT(*) >= 5
ORDER BY avg_salary DESC
LIMIT 15;

-- Do remote Data Analyst jobs pay more than on-site jobs?
SELECT 
    work_type,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_year_avg), 2) AS avg_salary,
    MAX(salary_year_avg) AS max_salary,
    MIN(salary_year_avg) AS min_salary,
    (
        SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_year_avg)
        FROM job_postings_fact jpf2
        WHERE 
            jpf2.job_title_short = 'Data Analyst'
            AND jpf2.salary_year_avg IS NOT NULL
            AND (
                (jpf2.job_work_from_home = TRUE AND work_type = 'Remote') OR
                (jpf2.job_work_from_home = FALSE AND work_type = 'On-site')
            )
    ) AS median_salary
FROM (
    SELECT 
        CASE 
            WHEN job_work_from_home = TRUE THEN 'Remote'
            ELSE 'On-site'
        END AS work_type,
        salary_year_avg
    FROM job_postings_fact
    WHERE job_title_short = 'Data Analyst'
      AND salary_year_avg IS NOT NULL
) AS sub
GROUP BY work_type
ORDER BY avg_salary DESC;



-- Which companies offer the highest average salaries for Data Analysts?
SELECT 
    c.name AS company_name,
    COUNT(j.job_id) AS job_count,
    ROUND(AVG(j.salary_year_avg), 2) AS avg_salary,
    MAX(j.salary_year_avg) AS max_salary
FROM job_postings_fact j
JOIN company_dim c ON j.company_id = c.company_id
WHERE j.job_title_short = 'Data Analyst'
  AND j.salary_year_avg IS NOT NULL
GROUP BY c.name
HAVING COUNT(j.job_id) >= 3
ORDER BY avg_salary DESC
LIMIT 20;

-- What is the salary difference between Senior and Junior Data Analysts?
SELECT 
    CASE 
        WHEN LOWER(job_title) LIKE '%senior%' OR LOWER(job_title) LIKE '%sr%' 
             OR LOWER(job_title) LIKE '%lead%' THEN 'Senior'
        WHEN LOWER(job_title) LIKE '%junior%' OR LOWER(job_title) LIKE '%jr%' 
             OR LOWER(job_title) LIKE '%entry%' THEN 'Junior'
        ELSE 'Mid-Level'
    END AS experience_level,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_year_avg), 2) AS avg_salary,
    MAX(salary_year_avg) AS max_salary,
    MIN(salary_year_avg) AS min_salary
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
  AND salary_year_avg IS NOT NULL
GROUP BY experience_level
ORDER BY avg_salary DESC;

-- What percentage of Data Analyst jobs offer health insurance?
SELECT 
    CASE 
        WHEN job_health_insurance = TRUE THEN 'With Health Insurance'
        ELSE 'Without Health Insurance'
    END AS health_insurance_status,
    COUNT(*) AS job_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage,
    ROUND(AVG(salary_year_avg), 2) AS avg_salary
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
  AND salary_year_avg IS NOT NULL
GROUP BY job_health_insurance
ORDER BY job_count DESC;

-- What's the optimal skill set for maximum salary as a Data Analyst?
WITH top_paying_jobs AS (
    SELECT 
        j.job_id,
        j.job_title,
        j.salary_year_avg
    FROM job_postings_fact j
    WHERE j.job_title_short = 'Data Analyst'
      AND j.salary_year_avg IS NOT NULL
    ORDER BY j.salary_year_avg DESC
    LIMIT 50
)
SELECT 
    s.skills,
    COUNT(sj.job_id) AS skill_frequency,
    ROUND(AVG(tpj.salary_year_avg), 2) AS avg_salary
FROM top_paying_jobs tpj
JOIN skills_job_dim sj ON tpj.job_id = sj.job_id
JOIN skills_dim s ON sj.skill_id = s.skill_id
GROUP BY s.skills
ORDER BY skill_frequency DESC, avg_salary DESC
LIMIT 15;

-- How has Data Analyst salary changed over time?
SELECT 
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    COUNT(*) AS jobs_posted,
    ROUND(AVG(salary_year_avg), 2) AS avg_salary,
    MAX(salary_year_avg) AS max_salary
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
  AND salary_year_avg IS NOT NULL
GROUP BY EXTRACT(YEAR FROM job_posted_date), EXTRACT(MONTH FROM job_posted_date)
ORDER BY year DESC, month DESC
LIMIT 12;

-- Which job schedule type (Full-time, Part-time, Contract) pays the most?
SELECT 
    job_schedule_type,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_year_avg), 2) AS avg_salary,
    MAX(salary_year_avg) AS max_salary,
    MIN(salary_year_avg) AS min_salary
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
  AND salary_year_avg IS NOT NULL
  AND job_schedule_type IS NOT NULL
GROUP BY job_schedule_type
ORDER BY avg_salary DESC;

-- What skills appear together most frequently in Data Analyst job postings?
WITH job_skills AS (
    SELECT 
        sj.job_id,
        STRING_AGG(s.skills, ', ' ORDER BY s.skills) AS skill_combination,
        COUNT(s.skill_id) AS skill_count
    FROM skills_job_dim sj
    JOIN skills_dim s ON sj.skill_id = s.skill_id
    JOIN job_postings_fact j ON sj.job_id = j.job_id
    WHERE j.job_title_short = 'Data Analyst'
    GROUP BY sj.job_id
)
SELECT 
    skill_combination,
    COUNT(*) AS frequency
FROM job_skills
WHERE skill_count >= 3 AND skill_count <= 5
GROUP BY skill_combination
ORDER BY frequency DESC
LIMIT 20;

--  What's the correlation between number of required skills and salary?
SELECT 
    COUNT(sj.skill_id) AS num_skills_required,
    COUNT(DISTINCT j.job_id) AS job_count,
    ROUND(AVG(j.salary_year_avg), 2) AS avg_salary,
    MAX(j.salary_year_avg) AS max_salary
FROM job_postings_fact j
LEFT JOIN skills_job_dim sj ON j.job_id = sj.job_id
WHERE j.job_title_short = 'Data Analyst'
  AND j.salary_year_avg IS NOT NULL
GROUP BY j.job_id, j.salary_year_avg
HAVING COUNT(sj.skill_id) > 0
ORDER BY num_skills_required;
-- agregation
WITH skill_salary AS (
    SELECT 
        COUNT(sj.skill_id) AS num_skills_required,
        j.salary_year_avg
    FROM job_postings_fact j
    LEFT JOIN skills_job_dim sj ON j.job_id = sj.job_id
    WHERE j.job_title_short = 'Data Analyst'
      AND j.salary_year_avg IS NOT NULL
    GROUP BY j.job_id, j.salary_year_avg
    HAVING COUNT(sj.skill_id) > 0
)
SELECT 
    num_skills_required,
    COUNT(*) AS job_count,
    ROUND(AVG(salary_year_avg), 2) AS avg_salary
FROM skill_salary
GROUP BY num_skills_required
ORDER BY num_skills_required;

-- What Data Analyst jobs don't require a degree but still pay well?
SELECT 
    j.job_title,
    c.name AS company_name,
    j.job_location,
    j.salary_year_avg,
    j.job_no_degree_mention
FROM job_postings_fact j
JOIN company_dim c ON j.company_id = c.company_id
WHERE j.job_title_short = 'Data Analyst'
  AND j.salary_year_avg IS NOT NULL
  AND j.job_no_degree_mention = TRUE
  AND j.salary_year_avg > 80000
ORDER BY j.salary_year_avg DESC
LIMIT 20;