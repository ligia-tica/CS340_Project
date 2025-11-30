-- Citation for the following code:
-- Date: 11/18/2025
-- Base code used from Exploration - - Implementing CUD operations in your app
-- URL: https://canvas.oregonstate.edu/courses/2017561/pages/exploration-implementing-cud-operations-in-your-app?module_item_id=25645149




-- CREATE Animal
DROP PROCEDURE IF EXISTS sp_CreateAnimal;

DELIMITER //
CREATE PROCEDURE sp_CreateAnimal(
    IN p_name VARCHAR(255), 
    IN p_type VARCHAR(255), 
    IN p_dateOfBirth date,
    IN p_idFood INT,
    OUT p_id INT)
BEGIN
    INSERT INTO Animals (name, type, dateOfBirth, idFood) 
    VALUES (p_name, p_type, p_dateOfBirth, p_idFood);

    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() into p_id;
    -- Display the ID of the last inserted animal.
    SELECT LAST_INSERT_ID() AS 'new_id';

    -- Example of how to get the ID of the newly created animal:
        -- CALL sp_CreateAnimal('Bessy', 'Cow', '2024-06-09', @new_id);
        -- SELECT @new_id AS 'New Animal ID';
END //
DELIMITER ;



-- UPDATE Animal

DROP PROCEDURE IF EXISTS sp_UpdateAnimal;

DELIMITER //
CREATE PROCEDURE sp_UpdateAnimal(IN p_idAnimal INT, IN p_idFood INT)

BEGIN
    UPDATE Animals SET idFood = p_idFood WHERE idAnimal = p_idAnimal; 
END //
DELIMITER ;


-- DELETE Animal

DROP PROCEDURE IF EXISTS sp_DeleteAnimal;

DELIMITER //
CREATE PROCEDURE sp_DeleteAnimal(IN p_idAnimal INT)
BEGIN
    DECLARE error_message VARCHAR(255);
 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Deleting corresponding rows from both Animals table and 
        --      intersection table to prevent a data anomaly
        -- This can also be accomplished by using an 'ON DELETE CASCADE' constraint
        --      inside the Employees_Animals table.
        DELETE FROM Employees_Animals WHERE idAnimal = p_idAnimal;
        DELETE FROM Animals WHERE idAnimal = p_idAnimal;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in Animals for id: ', p_idAnimal);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;


-- CREATE Food
DROP PROCEDURE IF EXISTS sp_CreateFood;

DELIMITER //
CREATE PROCEDURE sp_CreateFood(
    IN p_foodName VARCHAR(255), 
    IN p_quantity INT, 
    IN p_unit VARCHAR(255),
    OUT p_id INT)
BEGIN
    INSERT INTO Food (foodName, quantity, unit) 
    VALUES (p_foodName, p_quantity, p_unit);

    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() into p_id;
    -- Display the ID of the last inserted food.
    SELECT LAST_INSERT_ID() AS 'new_id';

END //
DELIMITER ;


-- UPDATE Food

DROP PROCEDURE IF EXISTS sp_UpdateFood;

DELIMITER //
CREATE PROCEDURE sp_UpdateFood(IN p_idFood INT, IN p_quantity INT, IN p_unit VARCHAR(255))

BEGIN
    UPDATE Food SET quantity = p_quantity, unit = p_unit WHERE idFood = p_idFood; 
END //
DELIMITER ;


-- DELETE Food

DROP PROCEDURE IF EXISTS sp_DeleteFood;

DELIMITER //
CREATE PROCEDURE sp_DeleteFood(IN p_idFood INT)
BEGIN
    DECLARE error_message VARCHAR(255);
 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Deleting corresponding rows from both Food table and 
        -- updating the Animals table to Null for Diet

        UPDATE Animals SET idFood = NULL WHERE idFood = p_idFood;
        DELETE FROM Food WHERE idFood = p_idFood;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in Food for id: ', p_idFood);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;


-- CREATE Employee

DROP PROCEDURE IF EXISTS sp_CreateEmployee;

DELIMITER //
CREATE PROCEDURE sp_CreateEmployee(
    IN p_lastName VARCHAR(20), 
    IN p_firstName VARCHAR(20), 
    IN p_email VARCHAR(45), 
    IN p_jobTitle VARCHAR (45),
    IN p_hourlyRate DECIMAL (10,2),
    OUT p_idEmployee INT
    )
BEGIN
    INSERT INTO Employees (lastName, firstName, email, jobTitle, hourlyRate) 
    VALUES (p_lastName, p_firstName, p_email, p_jobTitle, p_hourlyRate);

    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() into p_idEmployee;
    -- Display the ID of the last inserted person.
    SELECT LAST_INSERT_ID() AS 'new_employee_id';

    -- Example of how to get the ID of the newly created person:
        -- CALL sp_CreatePerson('Theresa', 'Evans', 2, 48, @new_id);
        -- SELECT @new_id AS 'New Person ID';
END //
DELIMITER ;


-- CREATE Employees_Animals
DROP PROCEDURE IF EXISTS sp_CreateEmployeesAnimals;

DELIMITER //
CREATE PROCEDURE sp_CreateEmployeesAnimals(
    IN p_idEmployee INT, 
    IN p_idAnimal INT, 
    OUT p_id INT)
BEGIN
    DECLARE error_message VARCHAR(255);

    START TRANSACTION;
        -- Check if this relationship already exists to prevent duplicates. Used Claude AI for the code below using 
        -- prompt: How to check for duplicate relationships when adding a relationship?
        IF EXISTS (SELECT 1 FROM Employees_Animals 
                   WHERE idEmployee = p_idEmployee AND idAnimal = p_idAnimal) THEN
            SET error_message = 'This employee is already trained for this animal.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    INSERT INTO Employees_Animals (idEmployee, idAnimal)  
    VALUES (p_idEmployee, p_idAnimal);

    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() into p_id;
    -- Display the ID of the last inserted food.
    SELECT LAST_INSERT_ID() AS 'new_id';

END //
DELIMITER ;

-- UPDATE Employees_Animals

DROP PROCEDURE IF EXISTS sp_UpdateEmployeesAnimals;

DELIMITER //
CREATE PROCEDURE sp_UpdateEmployeesAnimals(IN p_idEmployee INT, IN p_oldIdAnimal INT, IN p_newIdAnimal INT)

BEGIN
    
    UPDATE Employees_Animals SET idAnimal = p_newIdAnimal WHERE idEmployee = p_idEmployee AND idAnimal = p_oldIdAnimal;
END //
DELIMITER ;


-- DELETE Employees_Animals

DROP PROCEDURE IF EXISTS sp_DeleteEmployeesAnimals;

DELIMITER //
CREATE PROCEDURE sp_DeleteEmployeesAnimals(IN p_idEmployeeAnimal INT)
BEGIN
    DECLARE error_message VARCHAR(255);
 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Deleting corresponding rows from both Employees_Animals table
        -- This can also be accomplished by using an 'ON DELETE CASCADE' constraint
        --      inside the Employees_Animals table.
        DELETE FROM Employees_Animals WHERE idEmployeeAnimal = p_idEmployeeAnimal;


        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in Employees_Animals for id: ', COALESCE(p_idEmployeeAnimal, 'NULL'));
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;






---------------------------------------
-- RESET procedure --
---------------------------------------


USE `cs340_tical`;

DELIMITER //
CREATE PROCEDURE ResetDatabase()
BEGIN

    SET FOREIGN_KEY_CHECKS = 0;

    -- Drop Tables
    DROP TABLE IF EXISTS Animals;
    DROP TABLE IF EXISTS Employees;
    DROP TABLE IF EXISTS Employees_Animals;
    DROP TABLE IF EXISTS Food;
    DROP TABLE IF EXISTS Passes;
    DROP TABLE IF EXISTS Sales;

    SET FOREIGN_KEY_CHECKS = 1;


    -- Creating the `Food` table

    CREATE TABLE `Food` (
    `idFood` int AUTO_INCREMENT NOT NULL,
    `foodName` varchar(45) NOT NULL,
    `quantity` int NOT NULL,
    `unit` varchar(45) NOT NULL,
    PRIMARY KEY (`idFood`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

    -- Creating the `Animal` table

    CREATE TABLE `Animals` (
    `idAnimal` int(11) AUTO_INCREMENT NOT NULL,
    `name` varchar(20) NOT NULL,
    `type` varchar(15) NOT NULL,
    `dateOfBirth` date NOT NULL,
    `idFood` int(11) NOT NULL,
    PRIMARY KEY (`idAnimal`),
    FOREIGN KEY (`idFood`) REFERENCES Food(`idFood`) ON DELETE RESTRICT ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


    -- Creating the `Employee` table

    CREATE TABLE `Employees` (
    `idEmployee` int(11) AUTO_INCREMENT NOT NULL,
    `lastName` varchar(20) NOT NULL,
    `firstName` varchar(20) NOT NULL,
    `email` varchar(45) NOT NULL,
    `jobTitle` varchar(45) NOT NULL,
    `hourlyRate` decimal(10,2) NOT NULL,
    PRIMARY KEY (`idEmployee`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


    -- Creating the `Employees_Animals` intersection table

    CREATE TABLE `Employees_Animals` (
    `idEmployeeAnimal` int(11) AUTO_INCREMENT NOT NULL,
    `idEmployee` int(11) DEFAULT NULL,
    `idAnimal` int(11) DEFAULT NULL,
    PRIMARY KEY (`idEmployeeAnimal`),
    FOREIGN KEY (`idEmployee`) REFERENCES Employees(`idEmployee`) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (`idAnimal`) REFERENCES Animals(`idAnimal`) ON DELETE RESTRICT ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



    -- Creating the `Passes` table

    CREATE TABLE `Passes` (
    `idPass` int AUTO_INCREMENT NOT NULL,
    `price` decimal(10,2) NOT NULL,
    `category` varchar(45) NOT NULL,
    PRIMARY KEY (`idPass`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


    -- Creating the `Sales` table

    CREATE TABLE `Sales` (
    `idSale` int AUTO_INCREMENT NOT NULL,
    `idPass` int NOT NULL,
    `idEmployee` int NOT NULL,
    `passesSold` int NOT NULL,
    `saleDate` date NOT NULL,
    PRIMARY KEY (`idSale`),
    FOREIGN KEY (`idPass`) REFERENCES Passes(`idPass`) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (`idEmployee`) REFERENCES Employees(`idEmployee`) ON DELETE RESTRICT ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


    -- Inserting data -----------------------------------------


    INSERT INTO `Food` (`foodName`, `quantity`, `unit`) VALUES
    ('Hay', 10, 'Bales'),
    ('Swine Feed', 1000, 'Pounds'),
    ('Barley Straw', 8, 'Bales');



    INSERT INTO `Animals` (`idAnimal`, `name`, `type`, `dateOfBirth`, `idFood`) VALUES
    (1, 'Cocoa', 'Cow', '2023-10-29', (SELECT `idFood` FROM `Food` WHERE `foodName` = 'Barley Straw')),
    (2, 'Hamlet', 'Pig', '2025-03-18', (SELECT `idFood` FROM `Food` WHERE `foodName` = 'Swine Feed')),
    (3, 'Maverick', 'Sheep', '2024-07-27', (SELECT `idFood` FROM `Food` WHERE `foodName` = 'Hay'));



    INSERT INTO `Employees` (`idEmployee`, `lastName`, `firstName`, `email`, `jobTitle`, `hourlyRate`) VALUES
    (1, 'Stuart', 'Abby', 'abbys@gmail.com', 'Animal Caretaker', 18.50),
    (2, 'Hoover', 'Mike', 'mikeh@gmail.com', 'Operations Manager', 21.50),
    (3, 'White', 'Zane', 'zanew@gmail.com', 'Animal Caretaker', 18.50);



    INSERT INTO `Employees_Animals` (`idEmployeeAnimal`, `idEmployee`, `idAnimal`) VALUES
    (1, 1, (SELECT `idAnimal` FROM `Animals` WHERE `name` = 'Cocoa')),
    (2, 1, (SELECT `idAnimal` FROM `Animals` WHERE `name` = 'Hamlet')),
    (3, 1, (SELECT `idAnimal` FROM `Animals` WHERE `name` = 'Maverick')),
    (4, 2, (SELECT `idAnimal` FROM `Animals` WHERE `name` = 'Cocoa')),
    (5, 2, (SELECT `idAnimal` FROM `Animals` WHERE `name` = 'Hamlet')),
    (6, 2, (SELECT `idAnimal` FROM `Animals` WHERE `name` = 'Maverick')),
    (7, 3, (SELECT `idAnimal` FROM `Animals` WHERE `name` = 'Cocoa')),
    (8, 3, (SELECT `idAnimal` FROM `Animals` WHERE `name` = 'Hamlet')),
    (9, 3, (SELECT `idAnimal` FROM `Animals` WHERE `name` = 'Maverick'));



    INSERT INTO `Passes` (`price`, `category`) VALUES
    (15.00, 'Weekday'),
    (20.00, 'Weekend'),
    (30.00, 'Holiday');



    INSERT INTO `Sales` (`idPass`, `idEmployee`, `passesSold`, `saleDate`) VALUES
    ((SELECT `idPass` FROM `Passes` WHERE `category` = 'Weekday'), (SELECT `idEmployee` FROM `Employees` WHERE `lastName` = 'Stuart' AND `firstName` = 'Abby'), 1, '2025-11-01'),
    ((SELECT `idPass` FROM `Passes` WHERE `category` = 'Weekend'), (SELECT `idEmployee` FROM `Employees` WHERE `lastName` = 'Hoover' AND `firstName` = 'Mike'), 3, '2025-11-02'),
    ((SELECT `idPass` FROM `Passes` WHERE `category` = 'Holiday'), (SELECT `idEmployee` FROM `Employees` WHERE `lastName` = 'White' AND `firstName` = 'Zane'), 4, '2025-11-03');


END //
DELIMITER ;