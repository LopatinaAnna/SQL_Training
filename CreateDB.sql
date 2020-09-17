CREATE DATABASE COMPANY

GO
 
USE COMPANY

CREATE TABLE EMPLOYEES
(
    ID_Employee INT PRIMARY KEY IDENTITY,
    Employee_Name NVARCHAR(20) NOT NULL,
    Employee_Surname NVARCHAR(20) NOT NULL
);

CREATE TABLE PROJECTS
(
    ID_Project INT PRIMARY KEY IDENTITY,
    Project_Name NVARCHAR(30) NOT NULL,
    Create_At DATE NOT NULL,
	Finish_At DATE NOT NULL,
	Is_Open BIT NOT NULL, 
);

CREATE TABLE ROLES
(
	ID_Role  INT PRIMARY KEY IDENTITY,
	Role_Name NVARCHAR(20) NOT NULL
);

CREATE TABLE PROJECTS_ROLES
(
	ID_Employee INT NOT NULL,
	ID_Project INT NOT NULL,
	ID_Role INT NOT NULL,
	PRIMARY KEY(ID_Employee, ID_Project),
    CONSTRAINT FK1_ID_Employee FOREIGN KEY (ID_Employee) REFERENCES EMPLOYEES (ID_Employee),
	CONSTRAINT FK2_ID_Project FOREIGN KEY (ID_Project) REFERENCES PROJECTS (ID_Project),
	CONSTRAINT FK3_ID_Role FOREIGN KEY (ID_Role) REFERENCES ROLES (ID_Role)
);

CREATE TABLE TASKS
(
	ID_Task INT PRIMARY KEY IDENTITY,
    Task_Name NVARCHAR(30) NOT NULL,
    Deadline_At DATE NOT NULL,
	ID_Employee INT NULL,
	ID_Project INT NOT NULL,
    CONSTRAINT FK4_ID_Employee FOREIGN KEY (ID_Employee) REFERENCES EMPLOYEES (ID_Employee),
	CONSTRAINT FK5_ID_Project FOREIGN KEY (ID_Project) REFERENCES PROJECTS (ID_Project)
);

CREATE TABLE TASK_STATES
(
	ID_State INT PRIMARY KEY IDENTITY,
	ID_Task INT,
	State_Name NVARCHAR(20) NOT NULL,
	Set_At DATE NOT NULL,
	ID_EmployeeSetBy INT NOT NULL,
	CONSTRAINT FK6_ID_Employee FOREIGN KEY (ID_EmployeeSetBy) REFERENCES EMPLOYEES (ID_Employee),
	CONSTRAINT FK7_ID_Task FOREIGN KEY (ID_Task) REFERENCES TASKS (ID_Task),
	CONSTRAINT Check_State_Name CHECK (State_Name IN ('Opened', 'InProgress', 'Completed', 'Closed'))
);

INSERT EMPLOYEES (Employee_Name, Employee_Surname) VALUES 
	('Name1', 'Surname1'),
	('Name2', 'Surname2'),
	('Name3', 'Surname3'),
	('Name4', 'Surname4');

INSERT PROJECTS (Project_Name, Create_At, Finish_At, Is_Open) VALUES 
	('Project #1', '2020-01-01', '2020-04-01', 1),
	('Project #2', '2020-01-01', '2020-05-29', 1),
	('Project #3', '2020-07-02', '2020-09-15', 1),
	('Project #4', '2020-06-30', '2020-12-31', 1);

INSERT ROLES (Role_Name) VALUES 
	('Role 1'),
	('Role 2'),
	('Role 3'),
	('Role 4');

INSERT PROJECTS_ROLES (ID_Employee, ID_Project, ID_Role) VALUES 
	(1, 1, 1),
	(1, 2, 1),
	(1, 3, 2),
	(1, 4, 3),
	(2, 3, 3),
	(2, 4, 1),
	(3, 1, 3),
	(3, 3, 3),
	(4, 4, 1);

INSERT TASKS (Task_Name, Deadline_At, ID_Employee, ID_Project) VALUES 
	('Task 1', '2020-01-10', 1, 1),
	('Task 2', '2020-02-17', 2, 1),
	('Task 3', '2020-03-31', 4, 1),
	('Task 4', '2020-03-02', 2, 2),
	('Task 5', '2020-05-29', 1, 2),
	('Task 6', '2020-05-01', 2, 2),
	('Task 7', '2020-04-02', 1, 2),
	('Task 8', '2020-05-14', 3, 2),
	('Task 9', '2020-05-20', 4, 2),
	('Task 10', '2020-07-12', 4, 3),
	('Task 11', '2020-08-19', 4, 3),
	('Task 12', '2020-09-10', 2, 3),
	('Task 13', '2020-07-18', 1, 4),
	('Task 14', '2020-08-24', 2, 4),
	('Task 15', '2020-09-10', NULL, 4),
	('Task 16', '2020-10-01', NULL, 4);

INSERT TASK_STATES (ID_Task, State_Name, Set_At, ID_EmployeeSetBy) VALUES 
	(1, 'Closed', '2020-03-01', 1),
	(2, 'Closed', '2020-04-01', 1),
	(3, 'Closed', '2020-04-01', 2),
	(4, 'Completed', '2020-06-05', 3),
	(5, 'Closed', '2020-06-05', 1),
	(6, 'Closed', '2020-06-05', 3),
	(7, 'Completed', '2020-06-05', 4),
	(8, 'InProgress', '2020-06-05', 3),
	(9, 'Closed', '2020-03-02', 1),
	(10, 'Closed', '2020-06-05', 2),
	(11, 'Completed', '2020-06-05', 3),
	(12, 'InProgress', '2020-06-05', 1),
	(13, 'Opened', '2020-06-30', 3),
	(14, 'Opened', '2020-06-30', 4),
	(15, 'Opened', '2020-06-30', 3),
	(16, 'Opened', '2020-06-30', 3);