-- Stored Procedures (Sprocs)
-- File: C - Stored Procedures.sql

USE [A01-School]
GO

-- Take the following queries and turn them into stored procedures.

-- 1.   Selects the studentID's, CourseID and mark where the Mark is between 70 and 80
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = N'PROCEDURE' AND ROUTINE_NAME = 'ListStudentMarksByRange')
    DROP PROCEDURE ListStudentMarksByRange
GO
CREATE PROCEDURE ListStudentMarksByRange
	@lower	DECIMAL,
	@upper	DECIMAL
AS
		SELECT  StudentID, CourseId, Mark
		FROM    Registration
		WHERE   Mark BETWEEN @lower AND @upper
RETURN
GO



		 -- BETWEEN is inclusive
--      Place this in a stored procedure that has two parameters,
--      one for the upper value and one for the lower value.
--      Call the stored procedure ListStudentMarksByRange


/* ----------------------------------------------------- */

-- 2.   Selects the Staff full names and the Course ID's they teach.

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = N'PROCEDURE' AND ROUTINE_NAME = 'CourseInstructors')
    DROP PROCEDURE CourseInstructors
GO
CREATE PROCEDURE CourseInstructors
AS
	SELECT  DISTINCT -- The DISTINCT keyword will remove duplate rows from the results
        FirstName + ' ' + LastName AS 'Staff Full Name',
        CourseId
	FROM    Staff S
		INNER JOIN Registration R
			ON S.StaffID = R.StaffID
	ORDER BY 'Staff Full Name', CourseId
RETURN
GO

EXECUTE CourseInstructors
GO

--      Place this in a stored procedure called CourseInstructors.


/* ----------------------------------------------------- */

-- 3.   Selects the students first and last names who have last names starting with S.
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = N'PROCEDURE' AND ROUTINE_NAME = 'FindStudentByLastName')
    DROP PROCEDURE FindStudentByLastName
GO
CREATE PROCEDURE FindStudentByLastName
	@PartialName	VARCHAR(35)
AS

	SELECT  FirstName, LastName
	FROM    Student
	WHERE   LastName LIKE @PartialName+'%'
RETURN
GO
EXECUTE FindStudentByLastName 's' 
GO

--      Place this in a stored procedure called FindStudentByLastName.
--      The parameter should be called @PartialName.
--      Do NOT assume that the '%' is part of the value in the parameter variable;
--      Your solution should concatenate the @PartialName with the wildcard.


/* ----------------------------------------------------- */

-- 4.   Selects the CourseID's and Coursenames where the CourseName contains the word 'programming'.
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = N'PROCEDURE' AND ROUTINE_NAME = 'FindCourse')
    DROP PROCEDURE FindCourse
GO
CREATE PROCEDURE FindCourse
	@PartialName	varchar(40)
AS

SELECT  CourseId, CourseName
FROM    Course
WHERE   CourseName LIKE '%'+@PartialName+'%'
RETURN
GO
EXECUTE FindCourse 'programming'
GO
--      Place this in a stored procedure called FindCourse.
--      The parameter should be called @PartialName.
--      Do NOT assume that the '%' is part of the value in the parameter variable.


/* ----------------------------------------------------- */

-- 5.   Selects the Payment Type Description(s) that have the highest number of Payments made.
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = N'PROCEDURE' AND ROUTINE_NAME = 'MostFrequentPaymentTypes')
    DROP PROCEDURE MostFrequentPaymentTypes

GO
CREATE PROCEDURE MostFrequentPaymentTypes
AS
SELECT PaymentTypeDescription
FROM   Payment 
    INNER JOIN PaymentType 
        ON Payment.PaymentTypeID = PaymentType.PaymentTypeID
GROUP BY PaymentType.PaymentTypeID, PaymentTypeDescription 
HAVING COUNT(PaymentType.PaymentTypeID) >= ALL (SELECT COUNT(PaymentTypeID)
                                                FROM Payment 
                                                GROUP BY PaymentTypeID)
RETURN
GO
EXECUTE MostFrequentPaymentTypes
GO
--      Place this in a stored procedure called MostFrequentPaymentTypes.

/* ----------------------------------------------------- */

-- 6.   Selects the current staff members that are in a particular job position.
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = N'PROCEDURE' AND ROUTINE_NAME = 'StaffByPosition')
    DROP PROCEDURE StaffByPosition

GO
CREATE PROCEDURE StaffByPosition
	@PositionDescription	varchar (50)
AS
SELECT  FirstName + ' ' + LastName AS 'StaffFullName'
FROM    Position P
    INNER JOIN Staff S ON S.PositionID = P.PositionID
WHERE   DateReleased IS NULL
  AND   PositionDescription = @PositionDescription
RETURN
GO
EXECUTE StaffByPosition 'instructor'
GO
--      Place this in a stored procedure called StaffByPosition

/* ----------------------------------------------------- */

-- 7.   Selects the staff members that have taught a particular course (e.g.: 'DMIT101').
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = N'PROCEDURE' AND ROUTINE_NAME = 'StaffByCourseExperience')
    DROP PROCEDURE StaffByCourseExperience

GO
CREATE PROCEDURE StaffByCourseExperience
	@CourseID	char(7)
AS
SELECT  DISTINCT FirstName + ' ' + LastName AS 'StaffFullName',
        CourseId
FROM    Registration R
    INNER JOIN Staff S ON S.StaffID = R.StaffID
WHERE   DateReleased IS NULL
  AND   CourseId LIKE '%'+@CourseID+'%'
RETURN
GO
EXECUTE StaffByCourseExperience 'DMIT101'
GO
--      This select should also accommodate inputs with wildcards. (Change = to LIKE)
--      Place this in a stored procedure called StaffByCourseExperience

