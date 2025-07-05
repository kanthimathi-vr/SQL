CREATE DATABASE SQLDAY23;
USE SQLDAY23;

-- ✅ Section 1: Inserting Data (Tasks 1–10)
-- Create a table Departments with columns dept_id, dept_name and insert 3 departments.
CREATE TABLE Departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) UNIQUE
);

INSERT INTO Departments (dept_id, dept_name) VALUES
(1, 'HR'),
(2, 'Finance'),
(3, 'Engineering');
-- Create a table Employees with columns emp_id, name, department, and salary. Insert 5 rows.
CREATE TABLE Employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(100),
    department INT,
    salary DECIMAL(10,2),
    FOREIGN KEY (department) REFERENCES Departments(dept_id)
);

INSERT INTO Employees (emp_id, name, department, salary) VALUES
(101, 'Alice', 1, 60000),
(102, 'Bob', 2, 55000),
(103, 'Charlie', 3, 70000),
(104, 'Diana', 1, 62000),
(105, 'Evan', 3, 72000);

-- Insert a new employee by specifying only emp_id and name.
INSERT INTO Employees (emp_id, name) VALUES (106, 'Fiona');
-- department and salary will be NULL
-- This will fail due to UNIQUE constraint on dept_name

-- Insert an employee using column names in a different order than declared in the table.
INSERT INTO Employees (name, emp_id, salary, department)
VALUES ('George', 107, 50000, 2);

-- Insert multiple employee records in one query using multi-row syntax.
INSERT INTO Employees (emp_id, name, department, salary) VALUES
(108, 'Helen', 3, 69000),
(109, 'Ian', 1, 61000),
(110, 'Judy', 2, 58000);

-- Insert an employee without providing the salary (check NULL behavior).
INSERT INTO Employees (emp_id, name, department) VALUES
(111, 'Kyle', 2);
-- salary will be NULL

-- Insert an employee into a non-existent department (should fail if FOREIGN KEY is applied).
-- This will fail if FK constraint is enforced
INSERT INTO Employees (emp_id, name, department, salary)
VALUES (112, 'Leo', 99, 65000);

-- Insert a record with duplicate emp_id to test PRIMARY KEY constraint.
-- This will fail due to PRIMARY KEY constraint
INSERT INTO Employees (emp_id, name, department, salary)
VALUES (101, 'Mona', 2, 54000);

-- Insert a department with a duplicate name (if UNIQUE constraint is set, it should fail).
-- This will fail due to UNIQUE constraint on dept_name
INSERT INTO Departments (dept_id, dept_name)
VALUES (4, 'HR');

-- Create an Attendance table and insert records with default values where applicable.
CREATE TABLE Attendance (
    att_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    att_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(10) DEFAULT 'Present',
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
);
INSERT INTO Attendance (emp_id) VALUES (101);

INSERT INTO Attendance (emp_id, status) VALUES (102, 'Absent');

INSERT INTO Attendance (emp_id, att_date, status)
VALUES (103, '2025-07-05 09:00:00', 'Late');
INSERT INTO Attendance (emp_id, status) VALUES
(104, 'Present'),
(105, 'Absent'),
(106, 'Late');

-- ✅ Section 2: Updating Data (Tasks 11–20)
-- Update salary of all employees in the HR department by adding ₹5,000.
UPDATE Employees
SET salary = salary + 5000
WHERE department = (
    SELECT dept_id FROM Departments WHERE dept_name = 'HR'
);

--  Update the department of employee with emp_id = 2 to 'Finance'.
UPDATE Employees
SET department = (
    SELECT dept_id FROM Departments WHERE dept_name = 'Finance'
)
WHERE emp_id = 2;

-- Update salary of employees earning less than ₹40,000 to ₹45,000.
UPDATE Employees
SET salary = 45000
WHERE salary < 40000;

-- Change name of employee emp_id = 3 to 'Michael Scott'.
UPDATE Employees
SET name = 'Michael Scott'
WHERE emp_id = 3;

--  Increase all IT department employees' salary by 10%.
UPDATE Employees
SET salary = salary * 1.10
WHERE department = (
    SELECT dept_id FROM Departments WHERE dept_name = 'IT'
);

-- Set salary to NULL for employees in the ‘Testing’ department (test constraint if NOT NULL exists).
UPDATE Employees
SET salary = NULL
WHERE department = (
    SELECT dept_id FROM Departments WHERE dept_name = 'Testing'
);

-- Update department to 'Admin' for all employees with NULL department.
INSERT INTO Departments (dept_id, dept_name) VALUES (4, 'Admin');

UPDATE Employees
SET department = 4
WHERE department IS NULL;

-- Update multiple columns (department and salary) in one query.
UPDATE Employees
SET department = (
        SELECT dept_id FROM Departments WHERE dept_name = 'Finance'
    ),
    salary = 60000
WHERE emp_id = 5;

-- Update employee salaries based on a condition using a subquery (e.g., above average).
-- Step 1: Get the average salary
SELECT AVG(salary) AS avg_salary FROM Employees WHERE salary IS NOT NULL;

SET SQL_SAFE_UPDATES = 0;

UPDATE Employees
JOIN (
    SELECT AVG(salary) AS avg_salary FROM Employees WHERE salary IS NOT NULL
) AS avg_table
ON Employees.salary > avg_table.avg_salary
SET Employees.salary = Employees.salary * 1.10;
SET SQL_SAFE_UPDATES = 1;
-- Add a bonus column and update it with 5% of each employee’s salary.
ALTER TABLE Employees ADD COLUMN bonus DECIMAL(10,2);

UPDATE Employees
SET bonus = salary * 0.05
WHERE salary IS NOT NULL;

-- Section 3: Deleting Data (Tasks 21–30)
-- Delete an employee with emp_id = 2.
DELETE FROM Employees
WHERE emp_id = 2;

-- Delete all employees from the 'Finance' department.
-- Step 1: Delete attendance records for employees in Finance
DELETE FROM Attendance
WHERE emp_id IN (
    SELECT emp_id FROM Employees
    WHERE department = (
        SELECT dept_id FROM Departments WHERE dept_name = 'Finance'
    )
);

-- Step 2: Now delete employees from Finance
DELETE FROM Employees
WHERE department = (
    SELECT dept_id FROM Departments WHERE dept_name = 'Finance'
);


-- Delete employees whose salary is below ₹30,000.
DELETE FROM Employees
WHERE salary < 30000;

-- Delete all rows from the Employees table using DELETE without a WHERE clause.
TRUNCATE TABLE Employees;
DELETE FROM Employees;
DELETE FROM Attendance;
DELETE FROM Employees;


-- Try deleting a department that is referenced in Employees table (test FOREIGN KEY).
-- This will fail if employees are still linked to this department
DELETE FROM Departments
WHERE dept_name = 'HR';

-- Delete employees who joined before a specific year (with a date column).
ALTER TABLE Employees ADD COLUMN join_date DATE;

-- Delete all employees except those in ‘HR’ using WHERE NOT IN.
DELETE FROM Employees
WHERE department NOT IN (
    SELECT dept_id FROM Departments WHERE dept_name = 'HR'
);

-- Delete employees with NULL department.
DELETE FROM Employees
WHERE department IS NULL;

-- Delete a record and immediately insert it again (test data integrity).
-- Backup employee details
SELECT * FROM Employees WHERE emp_id = 105;

-- Delete
DELETE FROM Employees WHERE emp_id = 105;

-- Re-insert
INSERT INTO Employees (emp_id, name, department, salary)
VALUES (105, 'Evan', 3, 72000);

-- Perform a delete operation inside a transaction and rollback it.
START TRANSACTION;

DELETE FROM Employees WHERE emp_id = 106;

-- Check deletion (optional)
SELECT * FROM Employees WHERE emp_id = 106;

-- Rollback the deletion
ROLLBACK;

-- Confirm restoration
SELECT * FROM Employees WHERE emp_id = 106;

-- Section 4: Constraints & Data Integrity (Tasks 31–40)
-- Create Departments with PRIMARY KEY on dept_id and UNIQUE on dept_name.
CREATE DATABASE DEPARTMENT;
USE DEPARTMENT;
CREATE TABLE Departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) UNIQUE
);

-- Create Employees with NOT NULL on name and salary.
CREATE TABLE Employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department_id INT,
    salary DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_department FOREIGN KEY (department_id) REFERENCES Departments(dept_id),
    CONSTRAINT chk_salary CHECK (salary > 3000)
);
ALTER TABLE Employees
ADD CONSTRAINT chk_salary_min CHECK (salary > 3000);


-- Add a CHECK constraint to ensure salary is above ₹3,000.
SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
WHERE TABLE_NAME = 'Employees' AND TABLE_SCHEMA = DATABASE();



-- Create a FOREIGN KEY from Employees.department_id to Departments.dept_id.
ALTER TABLE Employees
DROP FOREIGN KEY fk_department;
ALTER TABLE Employees
ADD CONSTRAINT fk_department FOREIGN KEY (department_id) REFERENCES Departments(dept_id);

-- Insert an employee with a NULL name to test NOT NULL constraint.
INSERT INTO Employees (emp_id, name, department_id, salary)
VALUES (1, NULL, 1, 50000);
-- Expected: ERROR due to NOT NULL constraint on name

-- Insert an employee with salary below ₹3,000 to test CHECK constraint.
INSERT INTO Employees (emp_id, name, department_id, salary)
VALUES (2, 'Test User', 1, 2500);
-- Expected: ERROR due to CHECK constraint violation

-- Insert two departments with the same name (test UNIQUE constraint).
INSERT INTO Departments (dept_id, dept_name) VALUES (1, 'HR');
INSERT INTO Departments (dept_id, dept_name) VALUES (2, 'HR');
-- Second insert expected to fail due to UNIQUE constraint on dept_name

-- Insert an employee with a non-existent department_id (test FOREIGN KEY constraint).
INSERT INTO Employees (emp_id, name, department_id, salary)
VALUES (3, 'John Doe', 999, 45000);
-- Expected: ERROR due to foreign key constraint violation

-- Add a new constraint to an existing table using ALTER TABLE.
ALTER TABLE Employees
ADD CONSTRAINT unique_emp_name UNIQUE (name);

-- Drop a constraint from a table using ALTER TABLE DROP CONSTRAINT.
ALTER TABLE Employees
DROP INDEX unique_emp_name;

-- Section 5: Transactions & ACID Properties (Tasks 41–50)
-- Start a transaction and insert two new employees. Commit it.
CREATE DATABASE TRANS;
USE TRANS;
USE SQLDAY23;

DESCRIBE Employees;
ALTER TABLE Employees
CHANGE department department_id INT;

INSERT INTO Departments (dept_id, dept_name) VALUES
(1, 'HR'),
(5, 'IT');

START TRANSACTION;

INSERT INTO Employees (emp_id, name, department_id, salary)
VALUES (201, 'Alice', 1, 50000),
       (202, 'Bob', 2, 60000);

COMMIT;

-- Start a transaction, update an employee's salary, then rollback the change.
START TRANSACTION;

UPDATE Employees
SET salary = salary + 10000
WHERE emp_id = 201;

ROLLBACK;
SELECT * FROM sqlday23.employees;

-- Insert a record, create a SAVEPOINT, and update that record. Rollback to SAVEPOINT.
START TRANSACTION;

INSERT INTO Employees (emp_id, name, department_id, salary)
VALUES (203, 'Charlie', 1, 45000);

SAVEPOINT after_insert;

UPDATE Employees
SET salary = 47000
WHERE emp_id = 203;

ROLLBACK TO SAVEPOINT after_insert;

COMMIT;

-- Start a transaction and delete 2 employees. Commit it.
START TRANSACTION;

DELETE FROM Employees WHERE emp_id IN (201, 202);

COMMIT;
-- Update a salary, create two savepoints, then rollback to the first one.
START TRANSACTION;

UPDATE Employees SET salary = 50000 WHERE emp_id = 203;
SAVEPOINT sp1;

UPDATE Employees SET salary = 55000 WHERE emp_id = 203;
SAVEPOINT sp2;

ROLLBACK TO sp1;

COMMIT;

-- Test isolation by trying to update the same record in two separate sessions.
START TRANSACTION;
UPDATE Employees SET salary = 60000 WHERE emp_id = 203;
-- Don’t commit yet
START TRANSACTION;
UPDATE Employees SET salary = 62000 WHERE emp_id = 203;
-- This will be blocked until Session 1 commits or rolls back

-- Insert multiple records inside a transaction and rollback on a simulated error.
START TRANSACTION;

INSERT INTO Employees (emp_id, name, department_id, salary)
VALUES (204, 'David', 1, 70000),
       (205, 'Emma', 99, 60000); -- Simulated error: department_id 99 doesn't exist

-- This will cause foreign key error and prevent commit

ROLLBACK;

-- Update the department name of all departments in a transaction and commit only if all succeed.
START TRANSACTION;

UPDATE Departments SET dept_name = 'Human Resources' WHERE dept_id = 1;
UPDATE Departments SET dept_name = 'Information Technology' WHERE dept_id = 2;

-- If no errors:
COMMIT;

-- If error:
-- ROLLBACK;

-- Simulate a partial failure (e.g., one insert fails due to constraint). Rollback entire transaction.
START TRANSACTION;

INSERT INTO Departments (dept_id, dept_name) VALUES (4, 'Admin');
INSERT INTO Departments (dept_id, dept_name) VALUES (5, 'Admin'); -- Duplicate dept_name (UNIQUE)

-- Fails due to UNIQUE constraint => rollback entire transaction
ROLLBACK;

-- Use a transaction to transfer an employee from one department to another and log the change.
CREATE TABLE IF NOT EXISTS TransferLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    from_dept INT,
    to_dept INT,
    transfer_date DATETIME DEFAULT CURRENT_TIMESTAMP
);
 START TRANSACTION;

-- Get current department (optional if known)
SET @emp_id = 203;
SELECT department_id INTO @old_dept FROM Employees WHERE emp_id = @emp_id;

-- Update employee
UPDATE Employees SET department_id = 2 WHERE emp_id = @emp_id;

-- Log the transfer
INSERT INTO TransferLog (emp_id, from_dept, to_dept)
VALUES (@emp_id, @old_dept, 2);

COMMIT;






























