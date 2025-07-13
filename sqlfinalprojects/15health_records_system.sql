-- 15. Health Records System 
-- Objective: Store medical records and prescriptions. 
create database health;
use health;
-- Entities: 
-- • Patients 
-- • Prescriptions 
-- • Medications 

-- Tables: 
-- • prescriptions (id, patient_id, date) 
-- • medications (id, name) 
-- • prescription_details (prescription_id, medication_id, dosage) 


-- Create patients table
CREATE TABLE patients (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    dob DATE NOT NULL
);

-- Create medications table
CREATE TABLE medications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Create prescriptions table
CREATE TABLE prescriptions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT UNSIGNED NOT NULL,
    date DATE NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
);

-- Create prescription_details table
CREATE TABLE prescription_details (
    prescription_id BIGINT UNSIGNED NOT NULL,
    medication_id BIGINT UNSIGNED NOT NULL,
    dosage VARCHAR(50) NOT NULL,
    PRIMARY KEY (prescription_id, medication_id),
    FOREIGN KEY (prescription_id) REFERENCES prescriptions(id) ON DELETE CASCADE,
    FOREIGN KEY (medication_id) REFERENCES medications(id) ON DELETE CASCADE
);
-- Patients
INSERT INTO patients (name, dob) VALUES
('John Doe', '1990-01-15'),
('Jane Smith', '1985-06-25');

-- Medications
INSERT INTO medications (name) VALUES
('Paracetamol'),
('Amoxicillin'),
('Ibuprofen');

-- Prescriptions
INSERT INTO prescriptions (patient_id, date) VALUES
(1, '2025-07-10'),
(2, '2025-07-11'),
(1, '2025-07-13');  -- John gets another prescription

-- Prescription Details
INSERT INTO prescription_details (prescription_id, medication_id, dosage) VALUES
(1, 1, '500mg twice a day'),   -- John - Paracetamol
(1, 2, '250mg three times a day'), -- John - Amoxicillin
(2, 3, '400mg once a day'),    -- Jane - Ibuprofen
(3, 2, '250mg twice a day');   -- John - Amoxicillin (again)

-- SQL Skills: 
-- • Joins 
-- • Filter by patient/date 
SELECT 
    p.name AS patient_name,
    pr.date AS prescription_date,
    m.name AS medication_name,
    pd.dosage
FROM prescription_details pd
JOIN prescriptions pr ON pd.prescription_id = pr.id
JOIN patients p ON pr.patient_id = p.id
JOIN medications m ON pd.medication_id = m.id
ORDER BY pr.date DESC;
-- Get Prescriptions by Patient Name (e.g. 'John Doe')
SELECT 
    pr.date,
    m.name AS medication,
    pd.dosage
FROM prescriptions pr
JOIN patients p ON pr.patient_id = p.id
JOIN prescription_details pd ON pr.id = pd.prescription_id
JOIN medications m ON pd.medication_id = m.id
WHERE p.name = 'John Doe'
ORDER BY pr.date;
--  Filter Prescriptions by Date (e.g. after July 11, 2025)
SELECT 
    p.name AS patient_name,
    pr.date,
    m.name AS medication,
    pd.dosage
FROM prescription_details pd
JOIN prescriptions pr ON pd.prescription_id = pr.id
JOIN patients p ON pr.patient_id = p.id
JOIN medications m ON pd.medication_id = m.id
WHERE pr.date > '2025-07-11';





