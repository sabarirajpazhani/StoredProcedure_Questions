--creating Database
create database StoredProcedureQuestions;

--use database
use  StoredProcedureQuestions;

--create employee table
CREATE TABLE Employee (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    DepartmentID INT,
    Salary DECIMAL(10, 2),
    HireDate DATE,
    ManagerID INT NULL,
    LastSalaryUpdate DATE
);

--create Department Table
CREATE TABLE Department (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(100)
);

--create SalaryChangeLog Table
CREATE TABLE SalaryChangeLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT,
    OldSalary DECIMAL(10, 2),
    NewSalary DECIMAL(10, 2),
    ChangeDate DATETIME DEFAULT GETDATE()
);

--create TransferLog Table
CREATE TABLE TransferLog (
    TransferID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT,
    OldDepartmentID INT,
    NewDepartmentID INT,
    TransferDate DATETIME DEFAULT GETDATE()
);

-- Insert departments
INSERT INTO Department (DepartmentName) VALUES 
('Sales'), 
('Engineering'), 
('HR');

-- Insert employees
INSERT INTO Employee (FirstName, LastName, DepartmentID, Salary, HireDate, ManagerID, LastSalaryUpdate) VALUES
('John', 'Doe', 1, 50000, '2018-01-15', NULL, '2023-01-10'),
('Jane', 'Smith', 2, 70000, '2019-03-10', 1, '2022-05-05'),
('Alice', 'Johnson', 2, 65000, '2020-06-20', 1, '2023-06-01'),
('Bob', 'Brown', 3, 48000, '2017-11-12', NULL, '2020-03-15');



