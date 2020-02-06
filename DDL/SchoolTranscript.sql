/*
*File: SchoolTranscript.sql
*Author: Wanlun Xue
*
*   CREATE DATABASE SchoolTranscript
*/
USE SchoolTranscript
GO
/* === Drop Statements === */
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'StudentCourses')
    DROP TABLE StudentCourses
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Courses')
    DROP TABLE Courses
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Students')
    DROP TABLE Students

/* === Create Tables === */
CREATE TABLE Students
(
    StudentID       int   
        CONSTRAINT PK_Students_StudentID
            PRIMARY KEY
        IDENTITY(20200001, 1)           NOT NULL,
    GivenName       varchar(50)         NOT NULL,
	-- % is a wildcard for zero or more characters (letter, digit, or other character)
	-- _ is a wildcard for a single character 
	-- [] are used to represent a range or set of characters that are allowed
    Surname         varchar(50)
		CONSTRAINT CK_Students_Surname
			CHECK (Surname LIKE '__%')   -- LIKE is for pattern matching
		--  CHECK (Surname LIKE '[A-Z][A-Z]%') --2 LETTERS PLOUS ANY OTHER CHARS
		--                       \ 1 /\ 1 /
							            NOT NULL,
    DateOfBirth     datetime
		CONSTRAINT CK_Students_DateOfBirth
			CHECK (DateOfBirth < GETDATE())
							            NOT NULL,
    Enrolled        bit                 
        CONSTRAINT DF_Students_Enrolled
            DEFAULT (1)                 NOT NULL
)

CREATE TABLE Courses
(
    Number          varchar(10)
        CONSTRAINT PK_Courses_Number
            PRIMARY KEY                 NOT NULL,
    Name            varchar(50)         NOT NULL,
    Credits         decimal(3,1)
		CONSTRAINT CK_Courses_Credits
			CHECK (Credits > 0 AND Credits <= 6)
								        NOT NULL,
    Hours           tinyint
		CONSTRAINT CK_Courses_Hours
		CHECK (Hours BETWEEN 15 AND 180) --BETWEEN operator is inclusive
						                NOT NULL,
    Active          bit
        CONSTRAINT DF_Courses_Active
            DEFAULT (1)                 NOT NULL,
    Cost            money
		CONSTRAINT CK_Courses_Cost
		CHECK (Cost>=0)
						                NOT NULL
)

CREATE TABLE StudentCourses
(
    StudentID       int
        CONSTRAINT FK_StudentCourses_StudentID
            FOREIGN KEY REFERENCES Students(StudentID)
                                        NOT NULL,
    CourseNumber    varchar(10)
        CONSTRAINT FK_StudentCourses_CourseNumber
            FOREIGN KEY REFERENCES Courses(Number)
                                        NOT NULL,
    Year            tinyint             NOT NULL,
    Term            char(3)             NOT NULL,
    FinalMark       tinyint                 NULL,
    Status          char(1)
		CONSTRAINT CK_StudentCourses_Status
			CHECK (Status = 'E' OR
				   Status = 'C' OR
				   Status = 'W')
							             NOT NULL
			-- CHECK (Status IN ('E', 'C', 'W'))
    -- table-level constraint for composite keys
    CONSTRAINT PK_StudentCourses_StudentID_CourseNumber
        PRIMARY KEY (StudentID, CourseNumber),
	--table-level constraint involving more than one column
	CONSTRAINT CK_StudentCourses_FinalMark_Status
		CHECK ((Status='C' AND FinalMark IS NOT NULL)
				OR
			  (Status IN ('E', 'W') AND FinalMark IS NULL))

)
/*------------Index----------*/
-- for all foreign keys
CREATE NONCLUSTERED INDEX IX_StudentCourses_StudentID
	ON StudentCourses (StudentID)

CREATE NONCLUSTERED INDEX IX_StudentCourses_CourseNumber
	ON StudentCourses (CourseNumber)

--For other columns where searching/sorting might be important

CREATE NONCLUSTERED INDEX IX_Students_Surname
	ON Students (Surname)

/* -----------Alter table statements---------*/
-- 1) Add a PostalCode for Student table
ALTER TABLE Students
	ADD PostalCode char(6) NULL

GO
	--Adding this as a nullable column, because students already exist,
	--and we donot have postal coded for those students.

-- 2) make sure the postalcode follows the correct pattern A#A#A#
ALTER TABLE Students
	ADD CONSTRAINT CK_Students_PostalCode
		CHECK (PostalCode LIKE '[A-Z][0-9][A-Z][0-9][A-Z][0-9]')

GO
