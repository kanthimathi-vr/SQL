-- 14. Hospital Patient Tracker 
-- Objective: Track patients, doctors, and visits. 
create database hospital;
use hospital;

-- Entities: 
-- • Patients 
-- • Doctors 
-- • Visits 

-- Tables: 
-- • patients (id, name, dob) 
-- • doctors (id, name, specialization) 
-- • visits (id, patient_id, doctor_id, visit_time)
-- Drop tables if they already exist (for reruns)


-- Create patients table
CREATE TABLE patients (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    dob DATE NOT NULL
);

-- Create doctors table
CREATE TABLE doctors (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100) NOT NULL
);

-- Create visits table
DROP TABLE IF EXISTS visits;

CREATE TABLE visits (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT UNSIGNED NOT NULL,
    doctor_id BIGINT UNSIGNED NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
    CHECK (start_time < end_time)
);

-- Insert doctors
INSERT INTO doctors (name, specialization) VALUES
('Dr. Alice Morgan', 'Cardiology'),
('Dr. Brian Stone', 'Pediatrics'),
('Dr. Clara Lee', 'Neurology');

-- Insert patients
INSERT INTO patients (name, dob) VALUES
('John Doe', '1990-01-15'),
('Jane Smith', '1985-06-25'),
('Emily Kim', '2000-09-10');

-- Insert visits
INSERT INTO visits (patient_id, doctor_id, visit_time) VALUES
(1, 1, '2025-07-01 09:00:00'),
(2, 2, '2025-07-01 10:00:00'),
(1, 3, '2025-07-03 14:30:00'),
(3, 1, '2025-07-03 15:00:00');

-- SQL Skills: 
-- • Query patients by doctor/date 
SELECT 
    v.id AS visit_id,
    p.name AS patient_name,
    d.name AS doctor_name,
    d.specialization,
    v.visit_time
FROM visits v
JOIN patients p ON v.patient_id = p.id
JOIN doctors d ON v.doctor_id = d.id
ORDER BY v.visit_time;
-- Visits by Specific Doctor (e.g., Dr. Alice Morgan)
SELECT 
    p.name AS patient_name,
    v.visit_time
FROM visits v
JOIN doctors d ON v.doctor_id = d.id
JOIN patients p ON v.patient_id = p.id
WHERE d.name = 'Dr. Alice Morgan'
ORDER BY v.visit_time;
-- Visits on Specific Date (e.g., 2025-07-01)
SELECT 
    d.name AS doctor_name,
    p.name AS patient_name,
    v.visit_time
FROM visits v
JOIN doctors d ON v.doctor_id = d.id
JOIN patients p ON v.patient_id = p.id
WHERE DATE(v.visit_time) = '2025-07-01'
ORDER BY v.visit_time;

-- • Constraints on overlapping visits 
DELIMITER //

CREATE TRIGGER prevent_overlapping_visits
BEFORE INSERT ON visits
FOR EACH ROW
BEGIN
    DECLARE overlap_count INT;

    SELECT COUNT(*) INTO overlap_count
    FROM visits
    WHERE 
        patient_id = NEW.patient_id
        AND (
            (NEW.start_time < end_time AND NEW.end_time > start_time)
        );

    IF overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Overlapping visit exists for this patient.';
    END IF;
END;
//

DELIMITER ;





