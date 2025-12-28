-- Initialize the database schema and seed data for Docker deployment
-- This file runs before plsql.sql to create the base tables

SET FOREIGN_KEY_CHECKS = 0;

-- Drop Tables if they exist
DROP TABLE IF EXISTS Sales;
DROP TABLE IF EXISTS Employees_Animals;
DROP TABLE IF EXISTS Animals;
DROP TABLE IF EXISTS Food;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Passes;

SET FOREIGN_KEY_CHECKS = 1;

-- Creating the `Food` table
CREATE TABLE `Food` (
    `idFood` int AUTO_INCREMENT NOT NULL,
    `foodName` varchar(45) NOT NULL,
    `quantity` int NOT NULL,
    `unit` varchar(45) NOT NULL,
    PRIMARY KEY (`idFood`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Creating the `Animals` table
CREATE TABLE `Animals` (
    `idAnimal` int(11) AUTO_INCREMENT NOT NULL,
    `name` varchar(20) NOT NULL,
    `type` varchar(15) NOT NULL,
    `dateOfBirth` date NOT NULL,
    `idFood` int(11) DEFAULT NULL,
    PRIMARY KEY (`idAnimal`),
    FOREIGN KEY (`idFood`) REFERENCES Food(`idFood`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Creating the `Employees` table
CREATE TABLE `Employees` (
    `idEmployee` int(11) AUTO_INCREMENT NOT NULL,
    `lastName` varchar(20) NOT NULL,
    `firstName` varchar(20) NOT NULL,
    `email` varchar(45) NOT NULL,
    `jobTitle` varchar(45) NOT NULL,
    `hourlyRate` decimal(10,2) NOT NULL,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
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

-- Inserting seed data

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
