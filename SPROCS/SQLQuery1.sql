-- PRACTICE transactions
USE [A01-School]
GO


/*
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = N'PROCEDURE' AND ROUTINE_NAME = 'SprocName')
    DROP PROCEDURE SprocName
GO
CREATE PROCEDURE SprocName
    -- Parameters here
AS
    -- Body of procedure here
RETURN
GO
*/

--create a stored procedure called DissolveClub that will acceot a aclub id as its parameer. Emsure that the club exists before attemptin to dissolve the club. You are to dissolve the club by first removing all the members of the club and then removing the club itself. 
--delete of the rows in activity table
--deletet of rows in the club table

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = N'PROCEDURE' AND ROUTINE_NAME = 'DissolveClub')
    DROP PROCEDURE DissolveClub
GO
CREATE PROCEDURE DissolveClub

	@ClubID	varchar (10)
AS
	IF @ClubID IS NULL
		RAISERROR ('You must enter a clubID', 16, 1)
	ELSE
	IF NOT EXISTS (SELECT ClubID FROM Club WHERE ClubId=@ClubID)
		RAISERROR ('This club not exist', 16, 1)
	ELSE
	BEGIN
		BEGIN TRANSACTION
		DELETE FROM Activity 
		WHERE	ClubId=@ClubID
		IF	@@ERROR<>0 --NO NEED TO CHECK @@ROWCOUNT, MAYBE NO MEMBERS IN THAT CLUB
		BEGIN
			RAISERROR ('This club not exist', 16, 1)
			ROLLBACK TRANSACTION
		END
	ELSE
	DELETE	FROM Club
	WHERE	ClubId=@ClubID
	IF	@@ERROR<>0 OR @@ROWCOUNT=0
	BEGIN
		RAISERROR ('CANNOT COMPLETE', 16, 1)
		ROLLBACK TRANSACTION
	END
	ELSE
	COMMIT TRANSACTION
END
RETURN
GO

SELECT * FROM Activity
SELECT * FROM Club
EXEC DissolveClub 'CSS'