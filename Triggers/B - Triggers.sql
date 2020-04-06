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
       EXISTS (SELECT StaffID FROM Registration
               GROUP BY StaffID HAVING COUNT(CourseId) > 3)
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
WHERE	StudentID=199899200
-- B. Create a trigger to ensure that students cannot be added to a course if the course is already full.

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[Registration_InsertUpdate]'))
    DROP TRIGGER Registration_Insert
GO

CREATE TRIGGER Registration_Insert
ON Registration
FOR Insert
AS 
	IF @@ROWCOUNT>0
		AND
		EXISTS (SELECT C.CourseId FROM Registration R inner join Course C ON R.CourseId=C.CourseId  
				GROUP BY MaxStudents,C.CourseId, Semester
				HAVING COUNT(R.StudentID)>=MaxStudents
				)
	BEGIN
		RAISERROR('That class is full', 16, 1)
		ROLLBACK TRANSACTION
	END
RETURN
GO

select * from Registration
select * from Course
INSERT INTO Registration(StudentID, CourseId, Semester, Mark, WithdrawYN, StaffID)
VALUES (200495500, 'DMIT259','2000S', 77.00, 'N',4)

-- C. Create a trigger that will add students to a wait list if the course is already full. You should design the WaitList table to accommodate the changes needed for adding a student to the course once space is freed up for the course. Students should be added on a first-come-first-served basis (i.e. - include a timestamp in your WaitList table)

CREATE TABLE Waitlist
(	StudentID		int				Constraint PK_StudentID PRIMARY KEY not null,
	CourseId		char (7)			not null,
	Semester		char (5)				not null
								,
	Mark			decimal(5,2)						null
								,
	WithdrawYN		char (1)			null
								Constraint DF_GRD		default 'N'
								,
	StaffID			smallint				null
							,
	DateAdded		datetime
)
	
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[OH]'))
    DROP TRIGGER OH
GO

CREATE TRIGGER OH
ON Registration
FOR INSERT -- Choose only the DML statement(s) that apply
AS
	IF EXISTS (SELECT C.CourseId FROM Registration R inner join Course C ON R.CourseId=C.CourseId  LEFT OUTER JOIN inserted I ON I.CourseId=C.CourseId 
	WHERE C.CourseId=I.CourseId
				GROUP BY MaxStudents,C.CourseId, R.Semester
				HAVING COUNT(R.StudentID)>=MaxStudents)
	-- Body of Trigger
    IF @@ROWCOUNT > 0 
	BEGIN
	    INSERT INTO Waitlist(StudentID, CourseId, Semester, Mark, WithdrawYN, StaffID, DateAdded)
	    SELECT I.StudentID, I.CourseId, I.Semester, I.Mark, I.WithdrawYN, I.StaffID, GETDATE()
        FROM inserted I
	    IF @@ERROR<>0
	    BEGIN
		    RAISERROR('Cannot add to waitlist',16,1)
            ROLLBACK TRANSACTION
		END	
	END
RETURN
GO



-- D. Create a trigger that will add students to a course whenever another student withdraws from that course. Pull your students from the WaitList table on a first-come-first-served basis.
