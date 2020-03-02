--Union Exercise (using the IQSchool database)
USE [A01-School]
GO

--a union allows us to combine the result set of two or more individual SELECT statements.
-- for the union to work, however, the number, order and data type of the columns in the SELECT statements must match. 
--unions are rarely used, but are helpful for certain situations. 

--1.	Write a script that will produce the 'It Happened in October' display.
--The output of the display is shown below
/*
    It Happened in October
 
    ID          Event:Name
    ----------- -----------------------------------
    200645320   Student Born:Thomas Brown
    200322620   Student Born:Flying Nun
    7           Staff Hired:Hugh Guy
    6           Staff Hired:Sia Latter
*/
--Additional Info:

---	if the event is an staff  being hired:
---	the id column contains the employee id
---	the name is in the format 'FirstName LastName'
---	if the event is a Student birthdate:
---	the id column contains the Student id
---	the name is in the format 'FirstName LastName'
---	the data is sorted in descending order of id (Student or staff)
---	the display is limited to the hiring of staff or the birthdates of students in the month of October

SELECT  StudentID AS 'ID',
        'Student Born:' + FirstName + ' ' +  LastName AS 'Event:Name'
--        , MONTH(Birthdate)
FROM    Student
WHERE   MONTH(Birthdate) = 10

UNION

SELECT  StaffID AS 'ID',
        'Staff Hired:' + FirstName + ' ' + LastName AS 'Event:Name'
FROM    Staff
WHERE   MONTH(DateHired) = 10

ORDER BY 'ID' DESC
GO

-- Create a view called RollCall that has the full name of each staff and student as well as identifying their role in to school.
IF OBJECT_ID('RollCall', 'V') IS NOT NULL
    DROP VIEW RollCall
GO
CREATE VIEW RollCall
AS
    -- Get all the students
    SELECT  FirstName + ' ' + LastName AS 'FullName',
            'Student' AS 'Role' -- 'Student' is just a hard-coded value
    FROM    Student

    UNION
    -- Get all the staff
    SELECT  FirstName + ' ' + LastName AS 'FullName',
            PositionDescription AS 'Role'
    FROM    Staff S
        INNER JOIN Position P ON S.PositionID = P.PositionID
GO

select * FROM RollCall


--2.  Create a list of course IDs and the number of students in the course and
--    UNION that with a list of the course IDs and the MaxStudents of the course.
--    The columns should be 'Course', 'Count', and 'Type', with the type for the
--    first list being 'Actual-' + Semester and the type for the second list being 'Planned'.

SELECT	c.CourseId, COUNT(StudentID) AS 'Count', 'Actual' AS 'Type'
FROM	Course as c
	left outer join Registration as r on c.CourseId=r.CourseId
GROUP BY c.CourseId

UNION

SELECT	CourseId, MaxStudents AS 'Count', 'Planned' AS 'Type'
FROM	Course