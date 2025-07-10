-- day25
-- 50 tasks
use day24;
-- A. Views in SQL (Tasks 1–15)
-- Create a view ActiveEmployees that shows employees with status = 'Active'.
ALTER TABLE Employees
ADD COLUMN status VARCHAR(20);
UPDATE Employees
SET status = 'Active'
WHERE emp_id > 0;

CREATE VIEW ActiveEmployees AS
SELECT * FROM Employees
WHERE status = 'Active';

-- Create a view HighSalaryEmployees to display employees earning more than ₹50,000.
CREATE VIEW HighSalaryEmployees AS
SELECT * FROM Employees
WHERE salary > 50000;

-- Create a view that joins Employees and Departments showing emp_name, dept_name.
CREATE VIEW EmployeeDepartments AS
SELECT e.emp_name, d.dept_name
FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id;

-- Update the HighSalaryEmployees view to also include the department column.
DROP VIEW IF EXISTS HighSalaryEmployees;

CREATE VIEW HighSalaryEmployees AS
SELECT e.*, d.dept_name
FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000;

-- Create a view to show only emp_id, emp_name, and hide the salary (for security).
CREATE VIEW EmployeeBasicInfo AS
SELECT emp_id, emp_name
FROM Employees;

-- Create a view ITEmployees showing only employees from the 'IT' department.
CREATE VIEW ITEmployees AS
SELECT e.*
FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id
WHERE d.dept_name = 'IT';

-- Drop the view ITEmployees.
DROP VIEW IF EXISTS ITEmployees;

-- Create a view to show only customers from Customers table who joined in the last 6 months.
ALTER TABLE Customers
ADD COLUMN join_date DATE;
UPDATE Customers
SET join_date = CURDATE() - INTERVAL FLOOR(RAND() * 730) DAY
WHERE customer_id > 0;

CREATE VIEW RecentCustomers AS
SELECT * FROM Customers
WHERE join_date >= CURDATE() - INTERVAL 6 MONTH;

-- Create a view with an alias: show emp_name AS EmployeeName, dept_name AS Dept.
CREATE VIEW EmployeeAliasView AS
SELECT e.emp_name AS EmployeeName, d.dept_name AS Dept
FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id;

-- Create a view that filters out employees with NULL email addresses.
ALTER TABLE Employees
ADD COLUMN email VARCHAR(100);
UPDATE Employees SET email = 'john101@example.com' WHERE emp_id = 1;
UPDATE Employees SET email = 'alice102@example.com' WHERE emp_id = 2;
UPDATE Employees SET email = 'bob101@example.com' WHERE emp_id = 3;
UPDATE Employees SET email = 'carol103@example.com' WHERE emp_id = 4;
UPDATE Employees SET email = 'dave101@example.com' WHERE emp_id = 5;

CREATE VIEW EmployeesWithEmail AS
SELECT * FROM Employees
WHERE email IS NOT NULL;

-- Create a view that displays employees hired in the last year using DATEDIFF or INTERVAL.
CREATE VIEW RecentHires AS
SELECT * FROM Employees
WHERE hire_date >= CURDATE() - INTERVAL 1 YEAR;

-- Create a view that includes a computed column (e.g., bonus = salary * 0.10).
CREATE VIEW EmployeeBonus AS
SELECT emp_id, emp_name, salary, (salary * 0.10) AS bonus
FROM Employees;

-- Create a view that joins 3 tables: Orders, Customers, and Products.
CREATE VIEW OrderDetails AS
SELECT o.order_id, c.customer_name
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id;
-- Create a view to simplify a complex query with GROUP BY (e.g., total salary by department).
CREATE VIEW OrderDetails AS
SELECT o.order_id, c.customer_name
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id;
CREATE VIEW SalaryByDepartment AS
SELECT d.dept_name, SUM(e.salary) AS total_salary
FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name;
-- updating employees table with join date
ALTER TABLE Employees
ADD COLUMN join_date DATE;
UPDATE Employees
SET join_date = CURDATE() - INTERVAL FLOOR(RAND() * 730) DAY
where emp_id > 0;
CREATE TABLE Logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    action VARCHAR(100),
    timestamp DATETIME
);
INSERT INTO Logs (action, timestamp) VALUES
('Employee record created', NOW()),
('Employee salary updated', NOW() - INTERVAL 1 DAY),
('Employee deleted', NOW() - INTERVAL 2 DAY),
('Viewed employee list', NOW() - INTERVAL 3 HOUR),
('Generated monthly report', NOW() - INTERVAL 7 DAY);

-- Create a read-only view for junior staff (exclude salary, bonus, and private info).
CREATE VIEW JuniorStaffView AS
SELECT
    emp_id,
    emp_name,
    dept_id,
    status,
    join_date
FROM Employees;
-- B. Stored Procedures (Tasks 16–30)
-- Create a stored procedure GetAllEmployees to select all records from Employees.
DELIMITER $$

CREATE PROCEDURE GetAllEmployees()
BEGIN
    SELECT * FROM Employees;
END $$

DELIMITER ;

-- Call GetAllEmployees() using CALL.
CALL GetAllEmployees();

-- Create a stored procedure GetEmployeesByDept(IN dept_name VARCHAR(50)).
DELIMITER $$

CREATE PROCEDURE GetEmployeesByDept(IN dept_name VARCHAR(50))
BEGIN
    SELECT e.*
    FROM Employees e
    JOIN Departments d ON e.dept_id = d.dept_id
    WHERE d.dept_name = dept_name;
END $$

DELIMITER ;
-- Call GetEmployeesByDept('HR').
CALL GetEmployeesByDept('it');
SELECT * FROM Departments WHERE dept_name = 'it';

-- Create a stored procedure that inserts a new employee with input parameters.
DELIMITER $$

CREATE PROCEDURE InsertEmployee(
    IN p_name VARCHAR(50),
    IN p_dept_id INT,
    IN p_salary DECIMAL(10,2),
    IN p_status VARCHAR(20),
    IN p_email VARCHAR(100)
)
BEGIN
    INSERT INTO Employees(emp_name, dept_id, salary, status, email)
    VALUES (p_name, p_dept_id, p_salary, p_status, p_email);
END $$

DELIMITER ;

-- Create a stored procedure that deletes an employee by emp_id.
DELIMITER $$
CREATE PROCEDURE DeleteEmployeeById(IN p_emp_id INT)
BEGIN
    DELETE FROM Employees WHERE emp_id = p_emp_id;
END $$
DELIMITER ;

-- Create a stored procedure that updates salary for a given employee.
DELIMITER $$
CREATE PROCEDURE UpdateEmployeeSalary(
    IN p_emp_id INT,
    IN p_new_salary DECIMAL(10,2)
)
BEGIN
    UPDATE Employees
    SET salary = p_new_salary
    WHERE emp_id = p_emp_id;
END $$
DELIMITER ;

-- Create a stored procedure that returns the total number of employees using OUT parameter.
DELIMITER $$
CREATE PROCEDURE GetTotalEmployees(OUT total INT)
BEGIN
    SELECT COUNT(*) INTO total FROM Employees;
END $$
DELIMITER ;
CALL GetTotalEmployees(@count);
SELECT @count AS total_employees;

-- Modify a stored procedure using DROP and recreate it with new logic.
DROP PROCEDURE IF EXISTS GetAllEmployees;

DELIMITER $$
CREATE PROCEDURE GetAllEmployees()
BEGIN
    SELECT emp_id, emp_name, dept_id FROM Employees;
END $$
DELIMITER ;

-- Create a procedure to fetch employees whose name starts with a specific letter.
DELIMITER $$
CREATE PROCEDURE GetEmployeesByLetter(IN p_letter CHAR(1))
BEGIN
    SELECT * FROM Employees
    WHERE emp_name LIKE CONCAT(p_letter, '%');
END $$
DELIMITER ;
CALL GetEmployeesByLetter('A');

-- Create a procedure that calculates and displays average salary per department.
DELIMITER $$
CREATE PROCEDURE AvgSalaryPerDept()
BEGIN
    SELECT d.dept_name, AVG(e.salary) AS avg_salary
    FROM Employees e
    JOIN Departments d ON e.dept_id = d.dept_id
    GROUP BY d.dept_name;
END $$
DELIMITER ;

-- Create a procedure to count employees in each department using GROUP BY.
DELIMITER $$
CREATE PROCEDURE CountEmployeesPerDept()
BEGIN
    SELECT d.dept_name, COUNT(e.emp_id) AS emp_count
    FROM Employees e
    JOIN Departments d ON e.dept_id = d.dept_id
    GROUP BY d.dept_name;
END $$
DELIMITER ;

-- Create a stored procedure to show employees who joined this month.
DELIMITER $$
CREATE PROCEDURE EmployeesJoinedThisMonth()
BEGIN
    SELECT * FROM Employees
    WHERE MONTH(join_date) = MONTH(CURDATE())
      AND YEAR(join_date) = YEAR(CURDATE());
END $$
DELIMITER ;

-- Create a stored procedure that performs multiple queries (select + insert log).
DELIMITER $$
CREATE PROCEDURE GetEmployeesWithLog()
BEGIN
    INSERT INTO Logs(action, timestamp)
    VALUES ('Viewed employees', NOW());

    SELECT * FROM Employees;
END $$
DELIMITER ;

-- Call a procedure inside a transaction and rollback if an error occurs.
DELIMITER $$
CREATE PROCEDURE UpdateSalaryWithTransaction(
    IN p_emp_id INT,
    IN p_new_salary DECIMAL(10,2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE Employees
    SET salary = p_new_salary
    WHERE emp_id = p_emp_id;

    INSERT INTO Logs(action, timestamp)
    VALUES (CONCAT('Updated salary for emp_id = ', p_emp_id), NOW());

    COMMIT;
END $$
DELIMITER ;
-- C. SQL Functions (Tasks 31–40)
-- Create a function EmployeeCount(dept_name VARCHAR(50)) RETURNS INT.
DELIMITER $$

CREATE FUNCTION EmployeeCount(dept_name VARCHAR(50)) RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE emp_count INT;
    SELECT COUNT(*) INTO emp_count
    FROM Employees e
    JOIN Departments d ON e.dept_id = d.dept_id
    WHERE d.dept_name = dept_name;
    RETURN emp_count;
END $$

DELIMITER ;

SELECT EmployeeCount('Finance');

-- Call SELECT EmployeeCount('Finance');.
SELECT EmployeeCount('Finance');
-- Create a function to return the average salary of a department.
DELIMITER $$

CREATE FUNCTION AvgSalary(dept_name VARCHAR(50)) RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE avg_sal DECIMAL(10,2);
    SELECT AVG(e.salary) INTO avg_sal
    FROM Employees e
    JOIN Departments d ON e.dept_id = d.dept_id
    WHERE d.dept_name = dept_name;
    RETURN IFNULL(avg_sal, 0);
END $$

DELIMITER ;

-- Create a function to calculate age from date of birth.
DELIMITER $$

CREATE FUNCTION CalculateAge(dob DATE) RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    RETURN FLOOR(DATEDIFF(CURDATE(), dob) / 365.25);
END $$

DELIMITER ;

-- Create a function that returns the highest salary in the Employees table.
DELIMITER $$

CREATE FUNCTION HighestSalary() RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE max_sal DECIMAL(10,2);
    SELECT MAX(salary) INTO max_sal FROM Employees;
    RETURN max_sal;
END $$

DELIMITER ;

-- Create a function that returns a formatted full name (first_name + ' ' + last_name).
DELIMITER $$

CREATE FUNCTION FullName(emp_id INT) RETURNS VARCHAR(100)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE full_name VARCHAR(100);
    SELECT CONCAT(first_name, ' ', last_name) INTO full_name FROM Employees WHERE emp_id = emp_id;
    RETURN full_name;
END $$

DELIMITER ;

-- Create a function that returns whether a department exists (BOOLEAN output).
DELIMITER $$

CREATE FUNCTION DeptExists(dept_name VARCHAR(50)) RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE exists_flag BOOLEAN;
    SELECT EXISTS (SELECT 1 FROM Departments WHERE dept_name = dept_name) INTO exists_flag;
    RETURN exists_flag;
END $$

DELIMITER ;

-- Create a function to calculate the number of working days since joining.
DELIMITER $$

CREATE FUNCTION WorkingDays(emp_id INT) RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE days INT;
    SELECT DATEDIFF(CURDATE(), join_date) INTO days FROM Employees WHERE emp_id = emp_id;
    RETURN IF(days < 0, 0, days);
END $$

DELIMITER ;

-- Create a function that returns the total number of orders for a customer.
DELIMITER $$

CREATE FUNCTION TotalOrders(customer_id INT) RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE order_count INT;
    SELECT COUNT(*) INTO order_count FROM Orders WHERE customer_id = customer_id;
    RETURN order_count;
END $$

DELIMITER ;

-- Create a function to return true if an employee is eligible for bonus (salary > 60000).
DELIMITER $$

CREATE FUNCTION BonusEligible(emp_id INT) RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE eligible BOOLEAN;
    SELECT salary > 60000 INTO eligible FROM Employees WHERE emp_id = emp_id;
    RETURN IFNULL(eligible, FALSE);
END $$

DELIMITER ;
-- D. Triggers in SQL (Tasks 41–50)
-- Create a table Employee_Audit with emp_id, action, action_time.
CREATE TABLE Employee_Audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    action VARCHAR(50) NOT NULL,
    action_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create an AFTER INSERT trigger on Employees to log new entries into Employee_Audit.
DELIMITER $$

CREATE TRIGGER after_employee_insert
AFTER INSERT ON Employees
FOR EACH ROW
BEGIN
    INSERT INTO Employee_Audit (emp_id, action)
    VALUES (NEW.emp_id, 'INSERT');
END $$

DELIMITER ;

-- Insert a new employee and verify the audit table is updated.
INSERT INTO Employees (emp_name, dept_id, salary, status)
VALUES ('Test Employee', 101, 50000, 'Active');

SELECT * FROM Employee_Audit WHERE emp_id = LAST_INSERT_ID();

-- Create a BEFORE UPDATE trigger to prevent salary from decreasing.
DELIMITER $$

CREATE TRIGGER before_salary_update
BEFORE UPDATE ON Employees
FOR EACH ROW
BEGIN
    IF NEW.salary < OLD.salary THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary decrease not allowed';
    END IF;
END $$

DELIMITER ;

-- Update an employee’s salary and ensure the rule is enforced.
-- This should fail if new salary < old salary
UPDATE Employees SET salary = salary - 1000 WHERE emp_id = 1;

-- Create an AFTER DELETE trigger to log deleted employee IDs in a backup table.
CREATE TABLE Employee_Backup (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT,
    salary DECIMAL(10,2),
    status VARCHAR(20),
    deleted_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create a trigger that updates a LastModified column in Employees after any update.
DELIMITER $$

CREATE TRIGGER after_employee_delete
AFTER DELETE ON Employees
FOR EACH ROW
BEGIN
    INSERT INTO Employee_Backup (emp_id, emp_name, dept_id, salary, status)
    VALUES (OLD.emp_id, OLD.emp_name, OLD.dept_id, OLD.salary, OLD.status);
END $$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER after_employee_update
AFTER UPDATE ON Employees
FOR EACH ROW
BEGIN
    UPDATE Employees SET LastModified = NOW() WHERE emp_id = NEW.emp_id;
END $$

DELIMITER ;

-- Create a trigger to automatically insert default roles for a new user in UserRoles table.
DELIMITER $$

CREATE TRIGGER after_user_insert
AFTER INSERT ON Users
FOR EACH ROW
BEGIN
    INSERT INTO UserRoles (user_id, role) VALUES (NEW.user_id, 'User');
END $$

DELIMITER ;

-- Drop the trigger logNewEmployee.
DROP TRIGGER IF EXISTS logNewEmployee;

-- Test a complex trigger that prevents deletion if an employee is assigned to active projects.
DELIMITER $$

CREATE TRIGGER before_employee_delete
BEFORE DELETE ON Employees
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Projects WHERE emp_id = OLD.emp_id AND status = 'Active') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete employee assigned to active projects';
    END IF;
END $$

DELIMITER ;























