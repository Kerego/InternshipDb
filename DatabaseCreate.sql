--CREATE DATABASE UniRev
--ON  
--(	NAME = UniRev_dat,  
--    FILENAME = 'C:\Internship\Database\UniRev.mdf',  
--    SIZE = 600MB,  
--    MAXSIZE = UNLIMITED,  
--    FILEGROWTH = 25MB )  
--LOG ON  
--(	NAME = UniRev_log,  
--    FILENAME = 'C:\Internship\Database\UniRev_log.mdf',  
--    SIZE = 600MB,  
--    MAXSIZE = UNLIMITED,  
--    FILEGROWTH = 25MB )    
--GO  
--use UniRev


--Drop tables

IF OBJECT_ID('dbo.Students') IS NOT NULL DROP TABLE Students
GO
IF OBJECT_ID('dbo.Schedules') IS NOT NULL DROP TABLE Schedules
GO
IF OBJECT_ID('dbo.LectorsCourses') IS NOT NULL DROP TABLE LectorsCourses
GO
IF OBJECT_ID('dbo.Reviews') IS NOT NULL DROP TABLE Reviews
GO
IF OBJECT_ID('dbo.LectorRecords') IS NOT NULL DROP TABLE LectorRecords
GO
IF OBJECT_ID('dbo.Lectors') IS NOT NULL DROP TABLE Lectors
GO
IF OBJECT_ID('dbo.Courses') IS NOT NULL DROP TABLE Courses
GO
IF OBJECT_ID('dbo.Reviewables') IS NOT NULL DROP TABLE Reviewables
GO
IF OBJECT_ID('dbo.Users') IS NOT NULL DROP TABLE Users
GO

--ReCreate tables

CREATE TABLE Reviewables(
	Id bigint Identity(0,1) CONSTRAINT [PK_Reviewables] PRIMARY KEY CLUSTERED
)

CREATE TABLE Courses(
	Id bigint 
	CONSTRAINT [PK_Courses] PRIMARY KEY CLUSTERED,
	CONSTRAINT [FK_Courses_Reviewables_Id] FOREIGN KEY(Id) REFERENCES Reviewables(Id) ON DELETE CASCADE,
	Name nvarchar(100) NOT NULL,
	Credits int CONSTRAINT [CreditsBetween1And12] CHECK (Credits between 1 and 12) NOT NULL,
	Description nvarchar(MAX) NULL,
)

CREATE TABLE Users(
	Id bigint Identity(0,1) CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED,
	[First Name] nvarchar(16) NOT NULL,
	[Second Name] nvarchar(16) NOT NULL,
	Age int CONSTRAINT [OlderThan16] CHECK (Age > 16) NOT NULL,
	Gender nchar(1) NOT NULL,
)

CREATE TABLE Lectors(
	Id bigint
	CONSTRAINT [PK_Lectors] PRIMARY KEY CLUSTERED 
	CONSTRAINT [FK_Lectors_Users_Id] FOREIGN KEY(Id) REFERENCES Users(Id) ON DELETE CASCADE,
	Organization nvarchar(100) NOT NULL
)

CREATE TABLE LectorRecords(
	Id bigint 
	CONSTRAINT [PK_LectorRecrods] PRIMARY KEY CLUSTERED,
	CONSTRAINT [FK_Lectors_Reviewables_Id] FOREIGN KEY(Id) REFERENCES Reviewables(Id) ON DELETE CASCADE,
	LectorId bigint CONSTRAINT [UQ_LectorId] UNIQUE NOT NULL
	CONSTRAINT [FK_LectorRecords_Lector_LectorId] FOREIGN KEY(LectorId) REFERENCES Lectors(Id)
)

CREATE TABLE LectorsCourses(
	Id bigint Identity(0,1) CONSTRAINT [PK_LectorsCourses] PRIMARY KEY CLUSTERED,
	CourseId bigint CONSTRAINT [FK_LectorsCourses_Courses_CourseId] FOREIGN KEY (CourseId) REFERENCES Courses(Id) NOT NULL,
	LectorId bigint CONSTRAINT [FK_LectorsCourses_Lectors_LectorId] FOREIGN KEY (LectorId) REFERENCES Lectors(Id) NOT NULL,
)

CREATE TABLE Schedules(
	Id bigint Identity(0,1) CONSTRAINT [PK_Schedules] PRIMARY KEY CLUSTERED,
	LectorCourseId bigint CONSTRAINT [FK_Schedules_LectorsCourses_LectorCourseId] FOREIGN KEY (LectorCourseId) REFERENCES LectorsCourses(Id) ON DELETE CASCADE NOT NULL,
	[Day] nvarchar(9) CONSTRAINT [DayNames] CHECK (Day in (N'Monday', N'Tuesday', N'Wednesday', N'Thursday', N'Friday', N'Saturday', N'Sunday')) NOT NULL,
	[Time] Time NOT NULL,
	Place nvarchar(100) NOT NULL
)

CREATE TABLE Students(
	Id bigint
	CONSTRAINT [PK_Students] PRIMARY KEY CLUSTERED
	CONSTRAINT [FK_Students_Users_Id] FOREIGN KEY(Id) REFERENCES Users(Id) ON DELETE CASCADE NOT NULL,
	[Group] nvarchar(10) NOT NULL,
	StudyStartDate Datetime NOT NULL,
	StudyEndDate Datetime NULL,
)

CREATE TABLE Reviews(
	Id bigint Identity(0,1) CONSTRAINT [PK_Reviews] PRIMARY KEY CLUSTERED,
	UserId bigint CONSTRAINT[FK_Reviews_Users_UserId] FOREIGN KEY(UserId) REFERENCES Users(Id) ON DELETE CASCADE NOT NULL,
	ReviewableId bigint CONSTRAINT[FK_Reviews_Reviewables_ReviewableId] FOREIGN KEY(ReviewableId) REFERENCES Reviewables(Id) ON DELETE CASCADE NOT NULL,
	CONSTRAINT [UQ_UserId_ReviewableId] UNIQUE(UserId, ReviewableId),
	Rating int CONSTRAINT [RatingBetween1And5] CHECK (Rating between 1 and 5) NOT NULL,
	DateCreated DatetimeOffset DEFAULT GETDATE() NOT NULL,
	DateModified DatetimeOffset DEFAULT GETDATE() NOT NULL,
	Comment nvarchar(255) NULL,
	IsAnonymous bit DEFAULT 0 NOT NULL 
)

--Seed Data

--Insert students
INSERT INTO Users ([First Name], [Second Name], Age , Gender)
VALUES 
('Marian', 'Bejenari', 21, 1),
('Dorin', 'Balan', 21, 1),
('Alina', 'Mocanas', 21, 0)

INSERT INTO Students(Id, [Group], StudyStartDate) SELECT Id, 'FAF', '2013-09-01' FROM Users

INSERT INTO Users ([First Name], [Second Name], Age , Gender)
VALUES 
('Viorel', 'Celpan', 21, 1),
('Florin', 'Rusu', 21, 1),
('Felicia', 'Starinschi', 21, 1)

INSERT INTO Students(Id, [Group], StudyStartDate) SELECT Id, 'TI', '2013-09-01' FROM Users WHERE Id > SCOPE_IDENTITY() - 3

--Insert Courses
INSERT INTO Reviewables DEFAULT VALUES
INSERT INTO Courses(Id, Name, Credits) VALUES
(SCOPE_IDENTITY(),'MS',  5) 

INSERT INTO Reviewables DEFAULT VALUES
INSERT INTO Courses(Id, Name, Credits) VALUES
(SCOPE_IDENTITY(),'BDC',  4)

INSERT INTO Reviewables DEFAULT VALUES
INSERT INTO Courses(Id, Name, Credits) VALUES
(SCOPE_IDENTITY(),'MIDPS', 6)

--Insert Lectors
--Irina
INSERT INTO Users ([First Name], [Second Name], Age , Gender)
VALUES 
('Irina', 'Cojanu', 18, 0)

INSERT INTO Lectors VALUES (SCOPE_IDENTITY(), 'UTM')
INSERT INTO Reviewables DEFAULT VALUES
INSERT INTO LectorRecords SELECT SCOPE_IDENTITY(), Id FROM Users where [First Name] = 'Irina'

--Nina
INSERT INTO Users ([First Name], [Second Name], Age , Gender)
VALUES 
('Nina', 'Sava', 30, 0)

INSERT INTO Lectors VALUES (SCOPE_IDENTITY(), 'Oratorica')
INSERT INTO Reviewables DEFAULT VALUES
INSERT INTO LectorRecords SELECT SCOPE_IDENTITY(), Id FROM Users where [First Name] = 'Nina'

--Generate LectorCourses
INSERT INTO LectorsCourses SELECT c.Id, l.Id FROM Lectors l ,Courses c

--Create Schedules
INSERT INTO Schedules SELECT lc.Id, 'Saturday', '12:00', 'Olimpia' from LectorsCourses lc, Users where LectorId = Users.Id and [First Name] = N'Nina'
INSERT INTO Schedules SELECT lc.Id, 'Monday', '12:40', 'UTM 3-3' from LectorsCourses lc, Users where LectorId = Users.Id and [First Name] = N'Irina'

--Create reviews
INSERT INTO Reviews(UserId, ReviewableId, Rating, Comment) 
VALUES
(0, 0, 5, 'Nice'),
(0, 2, 3, 'Boring'),
(1, 2, 4, 'Cool')


--DELETE FROM Users
--DELETE FROM Lectors 