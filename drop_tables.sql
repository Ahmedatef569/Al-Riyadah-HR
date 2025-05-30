-- Drop tables in correct order (due to foreign key dependencies)
drop table if exists payroll;
drop table if exists salaries;
drop table if exists penalties;
drop table if exists overtime;
drop table if exists excuses;
drop table if exists leaves;
drop table if exists employees;
drop table if exists users;

-- Drop the function
drop function if exists init_hr_tables;
