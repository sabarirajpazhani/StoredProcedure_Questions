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



-- 1. Create a procedure to get employees with salary greater than a given amount.
create procedure spEmpSalary
	@Amount decimal(10,2)
as
begin
	select * from Employee
	where Salary > @Amount
end;

exec spEmpSalary 50000


--2. Create a procedure to update the department of an employee by employee ID.
create Procedure spUpdateDepartment
	@EmployeeID int,
	@DepartmentID int
as
begin
	update Employee
	set DepartmentID = @DepartmentID 
	where EmployeeID = @EmployeeID
end

exec spUpdateDepartment 2, 3


--3. Create a procedure to return the total count of employees in a given department.
create procedure spEmpDepartment
	@DepartmentID int
as
begin
	select count(*) TotalCount from Employee 
	where DepartmentID = @DepartmentID
end;

exec spEmpDepartment 2


--4. Create a procedure that accepts a salary range (min, max) and returns employees within that range.
create procedure spEmpSalaryInRange 
	@MinSalary int,
	@MaxSalary int
as
begin
	Select * from Employee
	where Salary between @MinSalary AND @MaxSalary
end

exec spEmpSalaryInRange 40000, 70000


--5. Create a procedure to increase the salary of all employees in a specific department by a given percentage.
create procedure spUpdateSalary
	@DepartmentID int,
	@Percentage decimal(5,2)
as
begin
	update Employee
	set Salary = Salary + (Salary * @Percentage/100),
	LastSalaryUpdate = Getdate()
	where DepartmentID = @DepartmentID 
end

exec spUpdateSalary 3, 500


--Create a procedure to log changes in employee salary: it should insert old and new salary into a separate table whenever an update happens.
create procedure spInsertSalaryLog
	@EmployeeID int,
	@newSalary decimal (10,2)
as
begin
	declare @OldSalary int
	select @OldSalary = Salary from Employee where EmployeeID = @EmployeeID
	update Employee 
	set Salary = @newSalary
	where EmployeeID = @EmployeeID

	insert into SalaryChangeLog (EmployeeID,OldSalary,NewSalary,ChangeDate)
	values(@EmployeeID,@OldSalary,@newSalary,getdate());
end

exec spInsertSalaryLog 4,68000

select * from SalaryChangeLog;
select * from Employee;
