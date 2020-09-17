-- 1. Получить список всех должностей компании с количеством сотрудников на каждой из них 

select ROLES.Role_Name, PROJECTS_ROLES.ID_Employee
from PROJECTS_ROLES join ROLES 
on PROJECTS_ROLES.ID_Role = ROLES.ID_Role
order by Role_Name

select ROLES.Role_Name, COUNT(*) AS Employee_Count 
from PROJECTS_ROLES join ROLES 
on PROJECTS_ROLES.ID_Role = ROLES.ID_Role 
group by ROLES.Role_Name 
order by ROLES.Role_Name

-- 2. Определить список должностей компании, на которых нет сотрудников

select ROLES.Role_Name, PROJECTS_ROLES.ID_Employee
from ROLES left join PROJECTS_ROLES
on ROLES.ID_Role = PROJECTS_ROLES.ID_Role
order by ROLES.Role_Name

select distinct ROLES.Role_Name
from ROLES left join PROJECTS_ROLES
on ROLES.ID_Role = PROJECTS_ROLES.ID_Role
where PROJECTS_ROLES.ID_Employee is null
order by ROLES.Role_Name

-- 3. Получить список проектов с указанием, сколько сотрудников каждой должности работает на проекте

select PROJECTS_ROLES.ID_Project, ROLES.Role_Name, PROJECTS_ROLES.ID_Employee
from PROJECTS_ROLES join ROLES
on PROJECTS_ROLES.ID_Role = ROLES.ID_Role
order by ID_Project 
 
select PROJECTS_ROLES.ID_Project, ROLES.Role_Name,  COUNT(*) AS Employee_Count  
from PROJECTS_ROLES  join ROLES
on PROJECTS_ROLES.ID_Role = ROLES.ID_Role 
group by PROJECTS_ROLES.ID_Project, ROLES.Role_Name  
order by PROJECTS_ROLES.ID_Project 

-- 4. Посчитать на каждом проекте, какое в среднем количество задач приходится на каждого сотрудника

select TASKS.ID_Project, TASKS.ID_Employee, TASKS.Task_Name
from TASKS
where TASKS.ID_Employee is not null
order by TASKS.ID_Project, TASKS.ID_Employee

select TASKS.ID_Project, TASKS.ID_Employee, COUNT(*) AS Task_Count  
from TASKS
where TASKS.ID_Employee is not null
group by TASKS.ID_Project, TASKS.ID_Employee
order by TASKS.ID_Project, TASKS.ID_Employee

select Emp_Task_Count.ID_Project, AVG(Emp_Task_Count.Task_Count) as Avg_Task_Count
from (
	select TASKS.ID_Project, TASKS.ID_Employee, COUNT(*) AS Task_Count  
	from TASKS
	where TASKS.ID_Employee is not null
	group by TASKS.ID_Project, TASKS.ID_Employee) as Emp_Task_Count
group by Emp_Task_Count.ID_Project
order by Emp_Task_Count.ID_Project

-- 5. Подсчитать длительность выполнения каждого проекта

select PROJECTS.ID_Project, PROJECTS.Project_Name, PROJECTS.Create_At, PROJECTS.Finish_At
from PROJECTS
order by PROJECTS.ID_Project

select PROJECTS.ID_Project, PROJECTS.Project_Name, DATEDIFF(day, PROJECTS.Create_At, PROJECTS.Finish_At) AS	Duration_In_Days
from PROJECTS
order by PROJECTS.ID_Project

-- 6. Определить сотрудников с минимальным количеством незакрытых задач

select EMPLOYEES.ID_Employee, EMPLOYEES.Employee_Name+' '+EMPLOYEES.Employee_Surname as EmployeeFullName, TASKS.Task_Name, TASK_STATES.State_Name
from TASKS join TASK_STATES
on TASKS.ID_Task = TASK_STATES.ID_Task
join EMPLOYEES 
on TASKS.ID_Employee = EMPLOYEES.ID_Employee 
order by ID_Employee

select  COUNT(*) as TaskCount, EMPLOYEES.ID_Employee, Employee_Name+' '+Employee_Surname as EmployeeFullName
from TASKS join TASK_STATES
on TASKS.ID_Task = TASK_STATES.ID_Task
join EMPLOYEES 
on TASKS.ID_Employee = EMPLOYEES.ID_Employee 
where State_Name != 'Closed'
group by EMPLOYEES.ID_Employee, Employee_Name+' '+Employee_Surname
order by TaskCount

-- 7. Определить сотрудников с максимальным количеством незакрытых задач, дедлайн которых уже истек

select EMPLOYEES.ID_Employee, EMPLOYEES.Employee_Name+' '+EMPLOYEES.Employee_Surname as EmployeeFullName, 
	TASKS.Task_Name, TASKS.Deadline_At, TASK_STATES.State_Name
from TASKS join TASK_STATES
on TASKS.ID_Task = TASK_STATES.ID_Task join EMPLOYEES 
on TASKS.ID_Employee = EMPLOYEES.ID_Employee 
order by ID_Employee

select COUNT(*) as TaskCount, EMPLOYEES.ID_Employee, EMPLOYEES.Employee_Name+' '+EMPLOYEES.Employee_Surname as EmployeeFullName
from TASKS join TASK_STATES
on TASKS.ID_Task = TASK_STATES.ID_Task join EMPLOYEES 
on TASKS.ID_Employee = EMPLOYEES.ID_Employee 
where TASK_STATES.State_Name != 'Closed' and TASKS.Deadline_At < CONVERT(date, GETDATE()) 
group by EMPLOYEES.ID_Employee, EMPLOYEES.Employee_Name+' '+EMPLOYEES.Employee_Surname 
order by TaskCount desc

-- 8. Продлить дедлайн незакрытых задач на 5 дней

select TASKS.Task_Name, TASK_STATES.State_Name, TASKS.Deadline_At 
from TASKS join TASK_STATES 
on TASKS.ID_Task = TASK_STATES.ID_Task 
where TASK_STATES.State_Name != 'Closed' 
 
UPDATE TASKS 
SET TASKS.Deadline_At = DATEADD(day, 5, TASKS.Deadline_At) 
FROM (select * from TASK_STATES where TASK_STATES.State_Name != 'Closed') as states 
where states.ID_Task = TASKS.ID_Task

select TASKS.Task_Name, TASK_STATES.State_Name, TASKS.Deadline_At 
from TASKS join TASK_STATES 
on TASKS.ID_Task = TASK_STATES.ID_Task 
where TASK_STATES.State_Name != 'Closed' 

-- 9. Посчитать на каждом проекте количество задач, к которым еще не приступили

select PROJECTS.ID_Project, PROJECTS.Project_Name, TASKS.Task_Name, TASKS.ID_Employee
from TASKS join PROJECTS
on TASKS.ID_Project = PROJECTS.ID_Project

select TASKS.ID_Project, PROJECTS.Project_Name, COUNT(*) as TaskCount
from TASKS join PROJECTS
on TASKS.ID_Project = PROJECTS.ID_Project
where TASKS.ID_Employee is null
group by TASKS.ID_Project, PROJECTS.Project_Name
-- 10. Перевести проекты в состояние закрыт, для которых все задачи закрыты и
-- задать время закрытия временем закрытия задачи проекта, принятой последней
select TASKS.ID_Project, Project_Name, TASKS.Task_Name, TASK_STATES.State_Name, Set_At, PROJECTS.Is_Open, PROJECTS.Finish_At
from TASKS join TASK_STATES on TASKS.ID_Task = TASK_STATES.ID_Task join PROJECTS on TASKS.ID_Project = PROJECTS.ID_Project
order by TASKS.ID_Project

create view v as (select TASKS.ID_Project, TASKS.ID_Task, TASK_STATES.State_Name, TASK_STATES.Set_At , PROJECTS.Finish_At
	from TASKS left join (select TASKS.ID_Project, Count(State_Name) as Not_Closed_Tasks_Count
	from TASKS join TASK_STATES 
	on TASKS.ID_Task = TASK_STATES.ID_Task 
	where TASK_STATES.State_Name != 'Closed'
	group by TASKS.ID_Project) as sel on TASKS.ID_Project = sel.ID_Project join TASK_STATES 
	on TASK_STATES.ID_Task = TASKS.ID_Task join PROJECTS
	on PROJECTS.ID_Project = TASKS.ID_Project
	where sel.ID_Project is null)

UPDATE PROJECTS
SET PROJECTS.Finish_At = (select max(Set_At) from v)
from PROJECTS join v on PROJECTS.ID_Project = v.ID_Project

UPDATE PROJECTS
SET PROJECTS.Is_Open = 0
from PROJECTS join v on PROJECTS.ID_Project = v.ID_Project

select TASKS.ID_Project, Project_Name, TASKS.Task_Name, TASK_STATES.State_Name, Set_At, PROJECTS.Is_Open, PROJECTS.Finish_At
from TASKS join TASK_STATES on TASKS.ID_Task = TASK_STATES.ID_Task join PROJECTS on TASKS.ID_Project = PROJECTS.ID_Project
order by TASKS.ID_Project

drop view v

-- 11.Выяснить по всем проектам, какие сотрудники на проекте не имеют незакрытых задач

select PROJECTS.ID_Project, TASKS.ID_Employee, TASKS.Task_Name, TASK_STATES.State_Name  
from PROJECTS join TASKS
on PROJECTS.ID_Project = TASKS.ID_Project join TASK_STATES
on TASKS.ID_Task = TASK_STATES.ID_Task
order by PROJECTS.ID_Project, TASKS.ID_Employee

select distinct sel1.ID_Project, sel1.ID_Employee, sel1.All_Task_Count, sel2.Closed_Task_Count 
from(
	(select PROJECTS.ID_Project, TASKS.ID_Employee, Count(*) as All_Task_Count
	from PROJECTS join TASKS
	on PROJECTS.ID_Project = TASKS.ID_Project join TASK_STATES
	on TASKS.ID_Task = TASK_STATES.ID_Task
	group by PROJECTS.ID_Project, TASKS.ID_Employee) as sel1
	 join
	(select PROJECTS.ID_Project, TASKS.ID_Employee, Count(*) as Closed_Task_Count
	from PROJECTS join TASKS
	on PROJECTS.ID_Project = TASKS.ID_Project join TASK_STATES
	on TASKS.ID_Task = TASK_STATES.ID_Task
	where TASK_STATES.State_Name = 'Closed'
	group by PROJECTS.ID_Project, TASKS.ID_Employee) as sel2 
	on sel1.ID_Employee = sel2.ID_Employee
	)
order by sel1.ID_Project, sel1.ID_Employee

select distinct sel1.ID_Project, sel1.ID_Employee
from(
	(select PROJECTS.ID_Project, TASKS.ID_Employee, Count(*) as All_Task_Count
	from PROJECTS join TASKS
	on PROJECTS.ID_Project = TASKS.ID_Project join TASK_STATES
	on TASKS.ID_Task = TASK_STATES.ID_Task
	group by PROJECTS.ID_Project, TASKS.ID_Employee) as sel1
	 join
	(select PROJECTS.ID_Project, TASKS.ID_Employee, Count(*) as Closed_Task_Count
	from PROJECTS join TASKS
	on PROJECTS.ID_Project = TASKS.ID_Project join TASK_STATES
	on TASKS.ID_Task = TASK_STATES.ID_Task
	where TASK_STATES.State_Name = 'Closed'
	group by PROJECTS.ID_Project, TASKS.ID_Employee) as sel2 
	on sel1.ID_Employee = sel2.ID_Employee
	)
where sel1.All_Task_Count = sel2.Closed_Task_Count
order by sel1.ID_Project, sel1.ID_Employee

-- 12.Заданную задачу (по названию) проекта перевести на сотрудника с
-- минимальным количеством выполняемых им задач

select TASKS.ID_Employee, TASKS.Task_Name 
from TASKS
where TASKS.ID_Employee is not null
order by TASKS.ID_Employee

declare @task_name nvarchar(30) = 'Task 4'

update TASKS
set ID_Employee = (select TOP 1 ID_Employee from(
select min(sel1.TaskCount) as Min_Count
from 
(select  COUNT(*) as TaskCount, ID_Employee 
from TASKS join TASK_STATES
on TASKS.ID_Task = TASK_STATES.ID_Task
where State_Name != 'Closed' and ID_Employee is not null
group by TASKS.ID_Employee) as sel1 ) as sel2 join (select  COUNT(*) as TaskCount, ID_Employee 
from TASKS join TASK_STATES
on TASKS.ID_Task = TASK_STATES.ID_Task
where State_Name != 'Closed' and ID_Employee is not null
group by TASKS.ID_Employee) as sel3  on sel2.Min_Count = sel3.TaskCount)
where Task_Name = @task_name

select TASKS.ID_Employee, TASKS.Task_Name 
from TASKS
where TASKS.ID_Employee is not null
order by TASKS.ID_Employee