-- Creating tables for PH-EmployeeDB
CREATE TABLE departments ( 
	dept_no VARCHAR(4) NOT NULL, 
dept_name VARCHAR(40) NOT NULL, 
	PRIMARY KEY (dept_no), UNIQUE (dept_name)
);
CREATE TABLE employees ( 
	emp_no INT NOT NULL, 
	birth_date DATE NOT NULL, 
	first_name VARCHAR NOT NULL, 
	last_name VARCHAR NOT NULL, 
	gender VARCHAR NOT NULL, 
	hire_date DATE NOT NULL, 
	PRIMARY KEY (emp_no)
);
CREATE TABLE dept_manager (
	dept_no VARCHAR(4) NOT NULL, 
	emp_no INT NOT NULL, 
	from_date DATE NOT NULL, 
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no), 
	PRIMARY KEY (emp_no, dept_no)
);
CREATE TABLE salaries ( 
	emp_no INT NOT NULL, 
	salary INT NOT NULL, 
	from_date DATE NOT NULL, 
	to_date DATE NOT NULL, 
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no), 
	PRIMARY KEY (emp_no)
);
CREATE TABLE dept_emp ( 
	emp_no INT NOT NULL, 
	dept_no VARCHAR(4) NOT NULL, 
	from_date DATE NOT NULL, 
	to_date DATE NOT NULL, 
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no), 
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no), 
	PRIMARY KEY (emp_no, dept_no)
);
CREATE TABLE titles ( 
	emp_no INT NOT NULL, 
	title VARCHAR NOT NULL, 
	from_date DATE NOT NULL, 
	to_date DATE NOT NULL, 
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no), 
	PRIMARY KEY (emp_no, title, from_date)
);
SELECT * FROM departments;
SELECT * FROM employees;
SELECT * FROM dept_manager;
SELECT * FROM salaries;
SELECT * FROM dept_emp;
SELECT * FROM titles;
-- Determine Retirement Eligibility
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
-- Count the Queries
-- Number of employees retiring
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
-- Create a table
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
SELECT COUNT(first_name)
FROM retirement_info;
-- Drop retirement_info and create new one with emp_no
DROP TABLE retirement_info;
-- Create new table for retiring employees
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
-- Check the table
SELECT * FROM retirement_info;
-- Joining departments and dept_manager tables
SELECT departments.dept_name,
     dept_manager.emp_no,
     dept_manager.from_date,
     dept_manager.to_date
FROM departments
INNER JOIN dept_manager
ON departments.dept_no = dept_manager.dept_no;
-- Joining retirement_info and dept_emp tables
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	de.to_date 
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no;
-- Use Left Join for retirement_info and dept_emp tables
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	de.to_date
INTO current_emp
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');
-- Employee count by department number
SELECT COUNT(ce.emp_no), de.dept_no
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;
-- List 1: Employee Information
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	e.gender,
	s.salary,
	de.to_date
INTO emp_info
FROM employees as e
INNER JOIN salaries as s
ON (e.emp_no = s.emp_no)
INNER JOIN dept_emp as de
ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
		AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
		AND (de.to_date = '9999-01-01');
SELECT * FROM emp_info;
-- List 2: Management
-- List of managers per department
SELECT  dm.dept_no,
        d.dept_name,
        dm.emp_no,
        ce.last_name,
        ce.first_name,
        dm.from_date,
        dm.to_date
INTO manager_info
FROM dept_manager AS dm
    INNER JOIN departments AS d
        ON (dm.dept_no = d.dept_no)
    INNER JOIN current_emp AS ce
        ON (dm.emp_no = ce.emp_no);
-- List 3: Department Retirees
SELECT ce.emp_no,
	ce.first_name,
	ce.last_name,
	d.dept_name	
INTO dept_info
FROM current_emp as ce
INNER JOIN dept_emp AS de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
ON (de.dept_no = d.dept_no);
-- Table for Sales retirees
SELECT 
	ce.emp_no, 
	ce.first_name,
	ce.last_name,
	d.dept_name
INTO retirees_sales
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments as d
ON (de.dept_no = d.dept_no)
WHERE (d.dept_name = 'Sales')
ORDER BY ce.emp_no;
-- Table for Sales and Development Teams
SELECT 
	ce.emp_no, 
	ce.first_name,
	ce.last_name,
	d.dept_name
INTO retirees_sales_development
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments as d
ON (de.dept_no = d.dept_no)
WHERE d.dept_name IN ('Sales', 'Development')
ORDER BY ce.emp_no;

-- CHALLENGE
-- Deliverable 1: Number of Retiring Employees by Title
--- 1st TABLE is retirees_by_birthDate
---- List of current employees born between Jan. 1, 1952 and Dec. 31, 1955
SELECT 
	ce.emp_no, 
	ce.first_name,
	ce.last_name,
	e.birth_date
INTO retirees_by_birthDate
FROM current_emp as ce
INNER JOIN employees as e
ON (ce.emp_no = e.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31') 
ORDER BY ce.emp_no;
SELECT * FROM retirees_by_birthDate;

--- 2nd TABLE: retiring employees with recent titles
SELECT 
	ce.emp_no, 
	ce.first_name,
	ce.last_name,
	tl.title,
	tl.from_date,
	tl.to_date
INTO retirees_by_title
FROM current_emp as ce
INNER JOIN titles as tl
ON (ce.emp_no = tl.emp_no)
ORDER BY ce.emp_no;
SELECT * FROM retirees_by_title;
---- Only use the most recent titles
SELECT emp_no, first_name, last_name, title, from_date, to_date 
INTO retirees_by_recent_title
FROM
  (SELECT emp_no, first_name, last_name, title, from_date, to_date,
     ROW_NUMBER() OVER 
		(PARTITION BY (emp_no) ORDER BY from_date DESC) rn
   FROM retirees_by_title) tmp WHERE rn = 1;
SELECT * FROM retirees_by_recent_title;

--- 3rd TABLE: retirees_count_by_title 
SELECT COUNT (emp_no), title 
INTO retirees_count_by_title
FROM retirees_by_recent_title
GROUP BY title;
SELECT * FROM retirees_count_by_title;

-- Deliverable 2: Mentorship Eligibility
--- Table for eligible retirees: born in 1965
SELECT 
	e.emp_no, 
	e.first_name,
	e.last_name,
	tl.title,
	tl.from_date,
	tl.to_date
INTO mentors_met_eligibility
FROM employees as e
INNER JOIN titles as tl
ON (e.emp_no = tl.emp_no)
INNER JOIN dept_emp as de
ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
		AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
		AND (de.to_date = '9999-01-01') 
ORDER BY e.emp_no;
SELECT * FROM mentors_met_eligibility;
--- Table of mentors with recent title
SELECT emp_no, first_name, last_name, title, from_date, to_date 
INTO mentors_by_recent_title
FROM
  (SELECT emp_no, first_name, last_name, title, from_date, to_date,
     ROW_NUMBER() OVER 
		(PARTITION BY (emp_no) ORDER BY from_date DESC) rn
   FROM mentors_met_eligibility) tmp WHERE rn = 1;
SELECT * FROM mentors_by_recent_title;