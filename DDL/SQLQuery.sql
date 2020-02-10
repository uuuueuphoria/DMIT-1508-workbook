/*
*
*SchoolTranscript_Data.sql
*Wanlun Xue
*/
USE SchoolTranscript
GO

INSERT INTO Students(GivenName, Surname, DateOfBirth) -- notice no Enrolled column
VALUES ('Wanlun', 'Xue', '19950731 22:40:22 PM'),
	   ('Charles', 'Kuhn',  '19990806 00:00:00 AM'),
	   ('Vickie', 'Hale', '19450507 00:00:00 AM'),
	   ('Melanie', 'Harvey', '19660906 00:00:00 AM'),
	   ('Ken', 'Dunn', '19521203 00:00:00 AM')
--control k control c, comment it
--control k control u, uncomment

SELECT * FROM Students

INSERT INTO Courses (Number, Name, Credits, Hours, Cost)
VALUES ('DMIT-1406', 'English', '3', '88', '500'),
	   ('DMIT-1508', 'DMIT', '4.5', '120', '750'),
	   ('COOM-1001', 'COOM', '3', '88', '500'),
	   ('CPSC-1012', 'CPSC', '4.5', '120', '750')

SELECT * FROM Courses

--SELECT - The data/columns to retrieve
--FROM - The table(s) to search
--WHERE -Filters to apply in the search
--GROUP BY -Reorganize results into groups
--HAVING -Filter for grouping
--ORER BY -Sorting results

SELECT	Number, Name, Credits, Hours
FROM	Courses
WHERE	Name LIKE '%English%'

SELECT	GivenName, SurName
FROM	Students
WHERE	GivenName Like 'K%'


--Removing all the data from the student tabke
--DELETE FROM Students
--DELETE FROM Courses