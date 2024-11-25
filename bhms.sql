-- --------------------------------------------------------
-- Schema for Hospital Management System
-- --------------------------------------------------------

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

-- --------------------------------------------------------
-- Table structure for table doctors
-- --------------------------------------------------------

CREATE TABLE doctors (
    did INT(11) NOT NULL AUTO_INCREMENT,
    email VARCHAR(50) NOT NULL,
    doctorname VARCHAR(50) NOT NULL,
    dept VARCHAR(100) NOT NULL,
    PRIMARY KEY (did)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table for doctor specializations (4NF normalization)
CREATE TABLE doctor_specializations (
    did INT NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    PRIMARY KEY (did, specialization),
    FOREIGN KEY (did) REFERENCES doctors(did) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Table structure for table patients
-- --------------------------------------------------------

CREATE TABLE patients (
    pid INT(11) NOT NULL AUTO_INCREMENT,
    email VARCHAR(50) NOT NULL,
    name VARCHAR(50) NOT NULL,
    gender VARCHAR(50) NOT NULL,
    slot VARCHAR(50) NOT NULL,
    time TIME NOT NULL,
    date DATE NOT NULL,
    dept VARCHAR(50) NOT NULL,
    number VARCHAR(10) NOT NULL CHECK (CHAR_LENGTH(number) = 10),
    PRIMARY KEY (pid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table for patient diseases (4NF normalization)
CREATE TABLE patient_diseases (
    pid INT NOT NULL,
    disease VARCHAR(50) NOT NULL,
    PRIMARY KEY (pid, disease),
    FOREIGN KEY (pid) REFERENCES patients(pid) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Table structure for patient_doctors (Many-to-Many relationship)
-- --------------------------------------------------------

CREATE TABLE patient_doctors (
    pid INT(11) NOT NULL,
    did INT(11) NOT NULL,
    PRIMARY KEY (pid, did),
    FOREIGN KEY (pid) REFERENCES patients(pid) ON DELETE CASCADE,
    FOREIGN KEY (did) REFERENCES doctors(did) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Table structure for table tests
-- --------------------------------------------------------

CREATE TABLE test (
    id INT(11) NOT NULL AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL,
    email VARCHAR(20) NOT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table for patient tests (4NF normalization)
CREATE TABLE patient_tests (
    test_id INT NOT NULL AUTO_INCREMENT, -- Auto-incremented unique identifier for each test
    pid INT NOT NULL,                    -- Patient ID (references patients table)
    test_name VARCHAR(50) NOT NULL,      -- Name of the test
    result VARCHAR(50),                  -- Result of the test
    PRIMARY KEY (test_id),               -- Primary key on test_id
    FOREIGN KEY (pid) REFERENCES patients(pid) ON DELETE CASCADE -- Foreign key linking to patients table
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- --------------------------------------------------------
-- Table structure for table user (System Users)
-- --------------------------------------------------------

CREATE TABLE user (
    id INT(11) NOT NULL AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    usertype VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    password VARCHAR(1000) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Table structure for table triggers (Audit Logs)
-- --------------------------------------------------------

CREATE TABLE trigr (
    tid INT(11) NOT NULL AUTO_INCREMENT,
    pid INT(11) NOT NULL,
    email VARCHAR(50) NOT NULL,
    name VARCHAR(50) NOT NULL,
    action VARCHAR(50) NOT NULL,
    timestamp DATETIME NOT NULL,
    PRIMARY KEY (tid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Triggers for patients table
-- --------------------------------------------------------

DELIMITER $$

-- Trigger for patient insertion
CREATE TRIGGER patient_insertion AFTER INSERT ON patients
FOR EACH ROW
BEGIN
    INSERT INTO trigr VALUES(NULL, NEW.pid, NEW.email, NEW.name, 'PATIENT INSERTED', NOW());
END;
$$

-- Trigger for patient update
CREATE TRIGGER patient_update AFTER UPDATE ON patients
FOR EACH ROW
BEGIN
    INSERT INTO trigr VALUES(NULL, NEW.pid, NEW.email, NEW.name, 'PATIENT UPDATED', NOW());
END;
$$

-- Trigger for patient deletion
CREATE TRIGGER patient_deletion BEFORE DELETE ON patients
FOR EACH ROW
BEGIN
    INSERT INTO trigr VALUES(NULL, OLD.pid, OLD.email, OLD.name, 'PATIENT DELETED', NOW());
END;
$$

DELIMITER ;

-- --------------------------------------------------------
-- Validation Triggers for Date
-- --------------------------------------------------------

DELIMITER $$

-- Trigger to validate patient date on insert
CREATE TRIGGER validate_patient_date BEFORE INSERT ON patients
FOR EACH ROW
BEGIN
    IF NEW.date < CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Date cannot be in the past';
    END IF;
END;
$$

-- Trigger to validate patient date on update
CREATE TRIGGER validate_patient_update_date BEFORE UPDATE ON patients
FOR EACH ROW
BEGIN
    IF NEW.date < CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Date cannot be in the past';
    END IF;
END;
$$

DELIMITER ;

-- --------------------------------------------------------
-- AUTO_INCREMENT Adjustments
-- --------------------------------------------------------

ALTER TABLE doctors MODIFY did INT(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
ALTER TABLE patients MODIFY pid INT(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

ALTER TABLE patients ADD disease VARCHAR(100);

ALTER TABLE test MODIFY id INT(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;
ALTER TABLE trigr MODIFY tid INT(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;
ALTER TABLE user MODIFY id INT(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

COMMIT;
