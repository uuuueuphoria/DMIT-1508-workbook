-- Triggers Practice
USE [A01-School]
GO

-- A. Create a trigger to ensure that an instructor does not teach more than 3 courses in a given semester.


IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[Registration_ProtectPrimaryKey]'))
    DROP TRIGGER Registration_ProtectPrimaryKey
GO

CREATE TRIGGER Registration_ProtectPrimaryKey
ON Registration
FOR Update
AS
    IF UPDATE(StudentID) OR UPDATE(CourseID) OR UPDATE(Semester)
    BEGIN
        RAISERROR('Modifications to the composite primary key of Registration are not allowed', 16, 1)
        ROLLBACK TRANSACTION
    END
RETURN
GO





select * from Registration
update Registration
SET		Mark=81
WHERE	StudentID=199899200 AND
		Semester='2004J' AND CourseId='DMIT152'
INSERT INTO Registration(StudentID, CourseId, Semester, Mark, WithdrawYN, StaffID)
VALUES(199899200, 'DMIT101','2004J', 77.0, 'N',4)
INSERT INTO Registration(StudentID, CourseId, Semester, Mark, WithdrawYN, StaffID)
VALUES(199899200, 'DMIT103','2004J', 77.0, 'N',4)
INSERT INTO Registration(StudentID, CourseId, Semester, Mark, WithdrawYN, StaffID)
VALUES(199899200, 'DMIT101','2004J', 77.0, 'N',4)

-- B. Create a trigger to ensure that students cannot be added to a course if the course is already full.


IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[Registration_ClassSizeLimit]'))
    DROP TRIGGER Registration_ClassSizeLimit
GO

CREATE TRIGGER Registration_ClassSizeLimit
ON Registration
FOR Insert
AS
    IF  @@ROWCOUNT > 0 AND
        EXISTS( SELECT  COUNT(R.StudentID)
                FROM    Course AS C
                    INNER JOIN Registration AS R ON R.CourseId = C.CourseId
                    -- Note that the join below is only on the course and semester, because that's how
                    -- we're interested in grouping to solve this particular question.
                    INNER JOIN Inserted AS I ON I.CourseId = R.CourseId AND I.Semester = R.Semester
                WHERE   R.WithdrawYN <> 'Y' -- Don't count those students who have withdrawn                            
                GROUP BY R.CourseId, R.Semester, C.MaxStudents
                HAVING  COUNT(R.StudentID) > C.MaxStudents)
    BEGIN
        RAISERROR('Student registration cancelled - class is full', 16, 1)
        ROLLBACK TRANSACTION
    END
RETURN
GO


SELECT * FROM Waitlist
select * from Registration
select * from Course
INSERT INTO Registration(StudentID, CourseId, Semester, Mark, WithdrawYN, StaffID)
VALUES (200122100, 'DMIT259','2004M', 77.00, 'N',4)



-- C. Create a trigger that will add students to a wait list if the course is already full. You should design the WaitList table to accommodate the changes needed for adding a student to the course once space is freed up for the course. Students should be added on a first-come-first-served basis (i.e. - include a timestamp in your WaitList table)

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WaitList')
    DROP TABLE WaitList
GO
CREATE TABLE WaitList
(
    LogID           int  IDENTITY (1,1) NOT NULL CONSTRAINT PK_BalanceOwingLog PRIMARY KEY,
    StudentID       int                 NOT NULL,
    CourseID        char(7)             NOT NULL,
    Semester        char(5)             NOT NULL,
    AddedOn         datetime            NOT NULL
)
GO
	
ALTER TRIGGER Registration_ClassSizeLimit
ON Registration
FOR Insert
AS
    IF  @@ROWCOUNT > 0 AND
        EXISTS( SELECT  COUNT(R.StudentID)
                FROM    Course AS C
                    INNER JOIN Registration AS R ON R.CourseId = C.CourseId
                    -- Note that the join below is only on the course and semester, because that's how
                    -- we're interested in grouping to solve this particular question.
                    INNER JOIN Inserted AS I ON I.CourseId = R.CourseId AND I.Semester = R.Semester
                GROUP BY R.CourseId, R.Semester, C.MaxStudents
                HAVING  COUNT(R.StudentID) > C.MaxStudents)
    BEGIN
        RAISERROR('Student registration cancelled - class is full', 16, 1)
        INSERT INTO WaitList(StudentID, CourseID, Semester, AddedOn)
        SELECT StudentID, CourseID, Semester, GETDATE()
        FROM   inserted
        ROLLBACK TRANSACTION
    END
RETURN
GO


INSERT INTO Registration(StudentID, CourseId, Semester, Mark, WithdrawYN, StaffID)
VALUES (200688700, 'DMIT101','2000S', 77.00, 'N',1)
INSERT INTO Registration(StudentID, CourseId, Semester, Mark, WithdrawYN, StaffID)
VALUES (200688700, 'DMIT103','2000S', 77.00, 'N',2)
SELECT * FROM Waitlist



-- D. Create a trigger that will add students to a course whenever another student withdraws from that course. Pull your students from the WaitList table on a first-come-first-served basis.
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[ADD]'))
    DROP TRIGGER [ADD]
GO

CREATE TRIGGER [ADD]
ON Registration
FOR DELETE
AS	
	BEGIN
		INSERT INTO Registration(StudentID, CourseId, Semester, StaffID)
		SELECT StudentID, CourseID, Semester, (select StaffID from Registration R inner join WaitList W on W.CourseID=R.CourseId and w.Semester=r.Semester) FROM Waitlist W WHERE AddedOn= ALL (SELECT AddedOn FROM Waitlist)
		IF @@ERROR<>0
			BEGIN
				RAISERROR('Cannot register new student', 16, 1)
				ROLLBACK TRANSACTION
			END
	END
	RETURN
GO