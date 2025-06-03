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


--6. Create a procedure to log changes in employee salary: it should insert old and new salary into a separate table whenever an update happens.
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

--7. Create a procedure to retrieve employees hired within a certain date range.
create procedure spEmpInCertainDateRange
	@StartingDate date,
	@EndDate date
as
begin
	select * from Employee 
	where HireDate between @StartingDate and @EndDate
end

exec spEmpInCertainDateRange '2017-11-01','2019-11-01'

--8. Create a procedure that deletes employees who have not received a salary update for more than 2 years.
create procedure spDeleteEmpSalaryUpdate
as
begin
	delete from Employee 
	where LastSalaryUpdate < dateadd(year, -2, getdate());
end

exec spDeleteEmpSalaryUpdate 

--9. Create a procedure to insert a new department into a Department table, returning the newly created DepartmentID.
create procedure spInsertNewDepartment
	@DepartmentName NVARCHAR(100)
as 
begin
	insert into Department(DepartmentName)
	values (@DepartmentName);

	declare @NewDepartmentID int = Scope_Identity();

	print 'New Department was Inserted Successfully. And the Department ID is '+cast(@NewDepartmentID as varchar)
end;

exec spInsertNewDepartment 'Development';

select * from Department;

--10. Create a procedure to retrieve the department-wise average salary for all departments.
create procedure spDepartmentAvgSalary
as
begin
	select d.DepartmentName,avg(e.Salary)  from Employee e
	join Department d
	on e.DepartmentID = d.DepartmentID
	group by d.DepartmentName
end;

exec spDepartmentAvgSalary;



--11. Create a procedure that returns employees along with their manager's name (assume Employee table has ManagerID).
create procedure spManagers
as
begin
	select e.FirstName as Employee, m.FirstName as Manager from Employee e
	left join Employee m
	on e.ManagerID = m.EmployeeID
end

drop procedure spManagers;

exec spManagers;
select * from Employee;

--12.Create a procedure to transfer an employee from one department to another and log the transfer details in a separate TransferLog table using a transaction.
create procedure spDepartmentChange
	@EmployeeID int,
	@newDepartmentID int
as 
begin
	declare @oldDepartmentID int
	select @oldDepartmentID = DepartmentID from Employee where EmployeeID = @EmployeeID

	update Employee
	set DepartmentID = @newDepartmentID
	where EmployeeID = @EmployeeID

	insert into TransferLog(EmployeeID,OldDepartmentID,NewDepartmentID,TransferDate)
	values (@EmployeeID,@oldDepartmentID,@newDepartmentID,GETDATE());

	print 'Department has been Successfully changed';
end

exec spDepartmentChange 2, 4;


select * from TransferLog;
select * from Employee;
select * from Department;
