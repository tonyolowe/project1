# project1

## 📞 Contact

**Your Name**
- GitHub: [tonyolowe](https://github.com/tonyolowe)
- Email: tonyolowe02@gmail.com

# Connect to your database
psql -d project1

# Data Analyst Job Market Analysis

## Overview
SQL project analyzing 100,000+ job postings to identify top-paying Data Analyst positions, in-demand skills, and salary trends.

## Database Schema
- **company_dim**: Company information
- **skills_dim**: Skills master list  
- **job_postings_fact**: Job details with salaries
- **skills_job_dim**: Job-skill relationships

## Key Questions Analyzed
1. What are the top-paying Data Analyst jobs?
2. What skills are most in-demand?
3. Which skills command higher salaries?
4. Do remote jobs pay more?
5. What's the optimal skill set?

## Technologies
- PostgreSQL
- SQL
- pgAdmin
- Git/GitHub

## Setup
```bash
# Create database
CREATE DATABASE my_first_project;

# Load data
\copy company_dim FROM 'data/company_dim.csv' WITH (FORMAT csv, HEADER true);
\copy skills_dim FROM 'data/skills_dim.csv' WITH (FORMAT csv, HEADER true);
\copy job_postings_fact FROM 'data/job_postings_fact.csv' WITH (FORMAT csv, HEADER true);
\copy skills_job_dim FROM 'data/skills_job_dim.csv' WITH (FORMAT csv, HEADER true);
```

## Key Findings
- SQL is the most in-demand skill
- Remote positions average 7% higher salaries
- Python + SQL + Tableau is the most valuable skill combination

## Author
**Your Name** - [GitHub](https://github.com/tonyolowe)