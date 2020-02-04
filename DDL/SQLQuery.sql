/*
*
*SchoolTranscript_Data.sql
*Wanlun Xue
*/
USE SchoolTranscript
GO

INSERT INTO Students(GivenName, Surname, DateOfBirth) -- notice no Enrolled column
VALUES ('Wanlun', 'Xue', '19950731 22:40:22 PM')

SELECT * FROM Students