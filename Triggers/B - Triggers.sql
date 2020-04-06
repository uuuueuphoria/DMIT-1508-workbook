-- Triggers Practice
USE [A01-School]
GO

-- A. Create a trigger to ensure that an instructor does not teach more than 3 courses in a given semester.

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[Registration_InsertUpdate]'))
    DROP TRIGGER Registration_InsertUpdate
GO

CREATE TRIGGER Registration_InsertUpdate
ON Registration

FOR Insert, Update -- Choose only the DML statement(s) that apply
AS

    -- Body of Trigger
    IF @@ROWCOUNT > 0 -- It's a good idea to see if any rows were affected first
       AND
       EXISTS (SELECT R.StaffID FROM Registration R INNER JOIN inserted I ON R.Semester=I.Semester
				WHERE R.Semester=I.Semester AND R.StaffID=I.StaffID
               GROUP BY R.StaffID HAVING COUNT(R.CourseId) > 3)
    BEGIN
        -- State why I'm going to abort the changes
        RAISERROR('Max of 3 classes that a staff can teach', 16, 1)
        -- "Undo" the changes
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

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[Registration_Insert]'))
    DROP TRIGGER Registration_Insert
GO


CREATE TRIGGER Registration_Insert
ON Registration
FOR Insert
AS 
	IF EXISTS (SELECT C.CourseId FROM Registration R inner join Course C ON R.CourseId=C.CourseId INNER JOIN inserted I ON R.CourseId=I.CourseId
				WHERE R.CourseId=I.CourseId AND R.Semester=I.Semester
				GROUP BY MaxStudents, C.CourseId
				HAVING COUNT(R.StudentID)>=MaxStudents)
	BEGIN
		RAISERROR('That class is full', 16, 1)
		ROLLBACK TRANSACTION
	END
	
	INSERT INTO Waitlist(StudentID, CourseId, Semester, Mark, WithdrawYN, StaffID, DateAdded)
	SELECT I.StudentID, I.CourseId, I.Semester, I.Mark, I.WithdrawYN, I.StaffID, GETDATE()
    FROM inserted I
	
RETURN
GO

SELECT * FROM Waitlist
select * from Registration
select * from Course
INSERT INTO Registration(StudentID, CourseId, Semester, Mark, WithdrawYN, StaffID)
VALUES (200122100, 'DMIT259','2004M', 77.00, 'N',4)



-- C. Create a trigger that will add students to a wait list if the course is already full. You should design the WaitList table to accommodate the changes needed for adding a student to the course once space is freed up for the course. Students should be added on a first-come-first-served basis (i.e. - include a timestamp in your WaitList table)

CREATE TABLE Waitlist
(	StudentID		int				 not null,
	CourseId		char (7)			not null,
	Semester		char (5)				not null,
	Mark			decimal(5,2)		null,
	WithdrawYN		char (1)			null Constraint DF_GRD		default 'N',
	StaffID			smallint				null,
	DateAdded		datetime
)
GO
	
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[OH]'))
    DROP TRIGGER OH
GO

CREATE TRIGGER OH
ON Registration
FOR INSERT -- Choose only the DML statement(s) that apply
AS
	BEGIN
	    INSERT INTO Waitlist(StudentID, CourseId, Semester, Mark, WithdrawYN, StaffID, DateAdded)
	    SELECT I.StudentID, I.CourseId, I.Semester, I.Mark, I.WithdrawYN, I.StaffID, GETDATE()
        FROM inserted I
	END	
	    IF NOT EXISTS (SELECT C.CourseId FROM Registration R inner join Course C ON R.CourseId=C.CourseId INNER JOIN inserted I ON R.CourseId=I.CourseId
				WHERE R.CourseId=I.CourseId AND R.Semester=I.Semester
				GROUP BY MaxStudents, C.CourseId
				HAVING COUNT(R.StudentID)>=MaxStudents)
		BEGIN
		 RAISERROR('CANNOT ADD TO WAITLIST', 16,1)
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
		INSERT INTO Registration(StudentID, CourseId, Semester, Mark, WithdrawYN, StaffID)
		SELECT W.StudentID, W.CourseId, W.Semester, W.Mark, W.Mark, W.StaffID FROM Waitlist W WHERE DateAdded<= ALL (SELECT DateAdded FROM Waitlist)
		IF @@ERROR<>0
			BEGIN
				RAISERROR('Cannot register new student', 16, 1)
				ROLLBACK TRANSACTION
			END
	END
	RETURN
GO