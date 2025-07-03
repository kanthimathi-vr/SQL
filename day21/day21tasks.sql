CREATE DATABASE COMPANY1;
USE COMPANY1;
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100),
    salary DECIMAL(10,2),
    hire_date DATE,
    department_id INT,
    manager_id INT
);
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);
CREATE TABLE salaries (
    salary_id INT PRIMARY KEY,
    employee_id INT,
    amount DECIMAL(10,2),
    date_paid DATE
);
INSERT INTO departments (department_id, department_name) VALUES
(1, 'HR'),
(2, 'IT'),
(3, 'Marketing'),
(4, 'Finance'),
(5, 'Operations'),
(6, NULL); 

INSERT INTO employees (employee_id, name, salary, hire_date, department_id, manager_id) VALUES
(1, 'Alice', 60000, '2019-04-10', 1, NULL),
(2, 'Bob', 55000, '2021-07-01', 2, 1),
(3, 'Charlie', 75000, '2022-01-15', 2, 1),
(4, 'David', 50000, '2020-09-20', 3, 2),
(5, 'Eve', 62000, '2018-03-05', 3, 2),
(6, 'Frank', 48000, '2023-05-01', 4, 1),
(7, 'Grace', 51000, '2024-02-10', NULL, 1),
(8, 'Heidi', 59000, '2021-11-11', 5, 3),
(9, 'Ivan', 72000, '2020-08-18', 5, 3),
(10, 'Judy', 58000, '2019-12-30', 1, NULL);

INSERT INTO salaries (salary_id, employee_id, amount, date_paid) VALUES
(1, 1, 60000, '2024-12-31'),
(2, 2, 55000, '2024-12-31'),
(3, 3, 75000, '2024-12-31'),
(4, 4, 50000, '2024-12-31'),
(5, 5, 62000, '2024-12-31'),
(6, 6, 48000, '2024-12-31'),
(7, 8, 59000, '2024-12-31'),
(8, 9, 72000, '2024-12-31'),
(9, 10, 58000, '2024-12-31');
-- Note: Employee 7 (Grace) has never been paid

## Aggregate Functions
-- 1. Count the total number of employees in the employees table.
SELECT COUNT(*) AS total_employees
FROM EMPLOYEES;
-- 2. Count how many employees are in the "IT" department.
SELECT COUNT(*) AS it_employees
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE d.department_name = 'IT';

-- 3. Find the sum of all employees’ salaries.
SELECT SUM(salary) AS total_salaries
FROM employees;

-- 4. Find the sum of salaries for employees in the "HR" department.
SELECT SUM(e.salary) AS hr_total_salaries
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE d.department_name = 'HR';

-- 5. Calculate the average salary of all employees.
SELECT AVG(salary) AS average_salary
FROM employees;

-- 6. Find the average salary of employees in the "Marketing" department.
SELECT round(AVG(e.salary),2) AS marketing_avg_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE d.department_name = 'Marketing';

-- 7. Find the minimum salary in the employees table.
SELECT MIN(salary) AS min_salary
FROM employees;

-- 8. Find the maximum salary in the employees table.
SELECT MAX(salary) AS max_salary
FROM employees;

-- 9. Find the minimum hire date in the employees table.
SELECT MIN(hire_date) AS earliest_hire
FROM employees;

-- 10. Find the maximum hire date in the employees table.
 SELECT MAX(hire_date) AS latest_hire
FROM employees;

## GROUP BY
-- 11. Show the total salary paid for each department.
SELECT d.department_name, SUM(e.salary) AS total_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name;

-- 12. Show the average salary for each department.
SELECT d.department_name, round(AVG(e.salary),2) AS average_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name;

-- 13. List the number of employees in each department.
SELECT d.department_name, COUNT(e.employee_id) AS employee_count
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name;

-- 14. List departments with more than 2 employees (use HAVING).
SELECT d.department_name, COUNT(e.employee_id) AS employee_count
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
HAVING COUNT(e.employee_id) > 1;

-- 15. Show the minimum salary for each department.
SELECT d.department_name, MIN(e.salary) AS min_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name;

-- 16. Show the maximum salary for each department.
SELECT d.department_name, MAX(e.salary) AS max_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name;

-- 17. List the number of employees hired each year.
SELECT YEAR(hire_date) AS hire_year, COUNT(*) AS employees_hired
FROM employees
GROUP BY YEAR(hire_date);

-- 18. Show the total salary for departments where the total salary exceeds 100,000.
SELECT d.department_name, SUM(e.salary) AS total_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
HAVING SUM(e.salary) > 100000;

-- 19. List departments where the average salary is above 60,000.
SELECT d.department_name, round(AVG(e.salary),2) AS avg_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
HAVING AVG(e.salary) > 60000;

-- 20. List years and the number of employees hired in each year.
SELECT YEAR(hire_date) AS year_hired, COUNT(*) AS employee_count
FROM employees
GROUP BY YEAR(hire_date);

 
## HAVING
-- 21. Find departments where the sum of salaries is less than 120,000.
SELECT d.department_name, SUM(e.salary) AS total_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
HAVING SUM(e.salary) < 120000;

-- 22. Find departments with an average salary below 55,000.
SELECT d.department_name, round(AVG(e.salary),2) AS avg_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
HAVING AVG(e.salary) < 55000;

-- 23. List departments with more than 3 employees and total salary above 150,000.
SELECT d.department_name, COUNT(e.employee_id) AS employee_count, SUM(e.salary) AS total_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
HAVING COUNT(e.employee_id) >= 1 AND SUM(e.salary) > 100000;


-- 24. Show departments where the maximum salary is at least 70,000.
SELECT d.department_name, MAX(e.salary) AS max_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
HAVING MAX(e.salary) >= 70000;

-- 25. List departments where the minimum salary is above 50,000.
SELECT d.department_name, MIN(e.salary) AS min_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
HAVING MIN(e.salary) > 50000;

 
## Advanced Aggregates
-- 26. Find the highest salary among employees who joined after 2020-01-01.
SELECT MAX(salary) AS highest_salary
FROM employees
WHERE hire_date > '2020-01-01';

-- 27. Count how many employees have a salary below the overall average.
SELECT COUNT(*) AS below_avg_count
FROM employees
WHERE salary < (
    SELECT AVG(salary) FROM employees
);

-- 28. List all departments and their total salary, including those with NULL department names.
SELECT 
    COALESCE(d.department_name, 'Unknown') AS department_name,
    SUM(e.salary) AS total_salary
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name;

-- 29. Find the department with the most employees.
SELECT d.department_name, COUNT(e.employee_id) AS employee_count
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY employee_count DESC
LIMIT 1;

-- 30. Find the department with the lowest total salary.
 SELECT d.department_name, SUM(e.salary) AS total_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY total_salary ASC
LIMIT 1;

## Joins (Assume you have a departments table: department_id, department_name)
-- 31. List all employees and their department names (use INNER JOIN).
SELECT e.name AS employee_name, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;

-- 32. List all employees and their department names, including those without a department (LEFT JOIN).
SELECT e.name AS employee_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;

-- 33. List all departments and employees, including departments with no employees (RIGHT JOIN).
SELECT e.name AS employee_name, d.department_name
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.department_id;

-- 34. Show all department names, even if there are no employees in them (RIGHT or LEFT JOIN).
SELECT d.department_name
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name;

-- 35. For each department, list the department name and the number of employees in it (JOIN + GROUP BY).
SELECT d.department_name, COUNT(e.employee_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name;
 
## Multiple Joins (Assume you have a salaries table: employee_id, amount, date_paid)
-- 36. Show all employees, their department names, and their latest salary paid.
SELECT 
    e.name AS employee_name,
    d.department_name,
    s.amount AS latest_salary
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN salaries s ON e.employee_id = s.employee_id
WHERE s.date_paid = (
    SELECT MAX(s2.date_paid)
    FROM salaries s2
    WHERE s2.employee_id = e.employee_id
);

-- 37. List all salaries paid in each department.
SELECT 
    d.department_name,
    s.amount,
    s.date_paid
FROM salaries s
JOIN employees e ON s.employee_id = e.employee_id
JOIN departments d ON e.department_id = d.department_id
ORDER BY d.department_name, s.date_paid;

-- 38. Find employees who have never been paid a salary (LEFT JOIN with salaries).
SELECT e.name AS employee_name
FROM employees e
LEFT JOIN salaries s ON e.employee_id = s.employee_id
WHERE s.salary_id IS NULL;

-- 39. List departments and the total paid to their employees (JOIN + GROUP BY).
SELECT d.department_name, SUM(s.amount) AS total_paid
FROM salaries s
JOIN employees e ON s.employee_id = e.employee_id
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name;

-- 40. Find the average salary amount paid per department.
 SELECT d.department_name, round(AVG(s.amount),2) AS avg_salary_paid
FROM salaries s
JOIN employees e ON s.employee_id = e.employee_id
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name;

## Self Joins (Assume employees table has manager_id referencing employee_id)
-- 41. List all employees with their manager’s name.
SELECT 
    e.name AS employee_name,
    m.name AS manager_name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id;

-- 42. Find employees who are also managers.
SELECT DISTINCT m.employee_id, m.name AS manager_name
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id;

-- 43. Find employees who have the same manager.
SELECT 
    e1.name AS employee1,
    e2.name AS employee2,
    e1.manager_id
FROM employees e1
JOIN employees e2 ON e1.manager_id = e2.manager_id
WHERE e1.employee_id <> e2.employee_id
ORDER BY e1.manager_id;

-- 44. List all managers and the number of employees reporting to them.
SELECT 
    m.employee_id AS manager_id,
    m.name AS manager_name,
    COUNT(e.employee_id) AS reportee_count
FROM employees m
JOIN employees e ON e.manager_id = m.employee_id
GROUP BY m.employee_id, m.name;

-- 45. Show employees whose manager is in the "IT" department.
 SELECT 
    e.name AS employee_name,
    m.name AS manager_name,
    d.department_name AS manager_department
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id
JOIN departments d ON m.department_id = d.department_id
WHERE d.department_name = 'IT';

## Combining Aggregates and Joins
-- 46. For each department, show the department name and the highest salary of its employees.
SELECT d.department_name, MAX(e.salary) AS highest_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name;

-- 47. List employees whose salary is higher than the average salary of their department.
SELECT e.name, e.salary, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
);

-- 48. List all departments with the total salary paid to employees who joined before 2020.
SELECT d.department_name, SUM(e.salary) AS total_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.hire_date < '2020-01-01'
GROUP BY d.department_name;

-- 49. Show departments where all employees have a salary above 50,000.
SELECT d.department_name
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name
HAVING MIN(e.salary) > 50000;

-- 50. Find the manager who manages the most employees.
SELECT 
    m.employee_id AS manager_id,
    m.name AS manager_name,
    COUNT(e.employee_id) AS reportee_count
FROM employees m
JOIN employees e ON e.manager_id = m.employee_id
GROUP BY m.employee_id, m.name
ORDER BY reportee_count DESC
LIMIT 1;
