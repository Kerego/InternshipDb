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
	Organization nvarchar(100) NOT NULL,
	DefaultRoom nvarchar(100) NULL
)

CREATE TABLE LectorRecords(
	Id bigint 
	CONSTRAINT [PK_LectorRecrods] PRIMARY KEY CLUSTERED,
	CONSTRAINT [FK_Lectors_Reviewables_Id] FOREIGN KEY(Id) REFERENCES Reviewables(Id) ON DELETE CASCADE,
	LectorId bigint CONSTRAINT [UQ_LectorId] UNIQUE NOT NULL
	CONSTRAINT [FK_LectorRecords_Lector_LectorId] FOREIGN KEY(LectorId) REFERENCES Lectors(Id) ON DELETE CASCADE
)

CREATE TABLE LectorsCourses(
	Id bigint Identity(0,1) CONSTRAINT [PK_LectorsCourses] PRIMARY KEY CLUSTERED,
	CourseId bigint CONSTRAINT [FK_LectorsCourses_Courses_CourseId] FOREIGN KEY (CourseId) REFERENCES Courses(Id) ON DELETE CASCADE NOT NULL,
	LectorId bigint CONSTRAINT [FK_LectorsCourses_Lectors_LectorId] FOREIGN KEY (LectorId) REFERENCES Lectors(Id) ON DELETE CASCADE NOT NULL,
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

DECLARE @IDs TABLE (Id bigint)
--Insert students
INSERT INTO Users ([First Name], [Second Name], Age , Gender)
output inserted.Id into @IDs
VALUES 
(N'Marian', N'Bejenari', 21, 1),
(N'Dorin', N'Balan', 21, 1),
(N'Alina', N'Mocanas', 21, 0)

INSERT INTO Students(Id, [Group], StudyStartDate) SELECT Id, N'FAF', '2013-09-01' FROM @IDs

delete from @IDs

INSERT INTO Users ([First Name], [Second Name], Age , Gender)
output inserted.Id into @IDs
VALUES 
(N'Viorel', N'Budeci', 21, 1),
(N'Florin', N'Rusu', 21, 1),
(N'Felicia', N'Starinschi', 21, 1)

INSERT INTO Students(Id, [Group], StudyStartDate) SELECT Id, N'TI', '2013-09-01' FROM  @IDs

--Insert Courses
INSERT INTO Reviewables DEFAULT VALUES
INSERT INTO Courses(Id, Name, Credits) VALUES
(SCOPE_IDENTITY(), N'MS',  5) 

INSERT INTO Reviewables DEFAULT VALUES
INSERT INTO Courses(Id, Name, Credits) VALUES
(SCOPE_IDENTITY(), N'BDC',  6)

INSERT INTO Reviewables DEFAULT VALUES
INSERT INTO Courses(Id, Name, Credits) VALUES
(SCOPE_IDENTITY(), N'MIDPS', 4)

INSERT INTO Reviewables DEFAULT VALUES
INSERT INTO Courses(Id, Name, Credits) VALUES
(SCOPE_IDENTITY(), N'PW', 6)

INSERT INTO Reviewables DEFAULT VALUES
INSERT INTO Courses(Id, Name, Credits) VALUES
(SCOPE_IDENTITY(), N'TS', 4)

INSERT INTO Reviewables DEFAULT VALUES
INSERT INTO Courses(Id, Name, Credits) VALUES
(SCOPE_IDENTITY(), N'LFPC', 4)

INSERT INTO Reviewables DEFAULT VALUES
INSERT INTO Courses(Id, Name, Credits) VALUES
(SCOPE_IDENTITY(), N'AMSI', 5)


--Insert Lectors
--Irina
INSERT INTO Users ([First Name], [Second Name], Age , Gender)
VALUES 
(N'Irina', N'Cojanu', 23, 0)

INSERT INTO Lectors(Id, Organization) VALUES (SCOPE_IDENTITY(), N'UTM')
INSERT INTO Reviewables DEFAULT VALUES
INSERT INTO LectorRecords SELECT SCOPE_IDENTITY(), Id FROM Users WHERE [Second Name] = N'Cojanu'

--Irina
INSERT INTO Users ([First Name], [Second Name], Age , Gender)
VALUES 
(N'Irina', N'Cojuhari', 27, 0)

INSERT INTO Lectors(Id, Organization) VALUES (SCOPE_IDENTITY(), N'UTM')
INSERT INTO Reviewables DEFAULT VALUES
INSERT INTO LectorRecords SELECT SCOPE_IDENTITY(), Id FROM Users WHERE [Second Name] = N'Cojuhari'

--Nina
INSERT INTO Users ([First Name], [Second Name], Age , Gender)
VALUES 
(N'Nina', N'Sava', 30, 0)

INSERT INTO Lectors(Id, Organization) VALUES (SCOPE_IDENTITY(), N'Oratorica')
INSERT INTO Reviewables DEFAULT VALUES
INSERT INTO LectorRecords SELECT SCOPE_IDENTITY(), Id FROM Users WHERE [Second Name] = N'Sava'

--Mihaela
INSERT INTO Users ([First Name], [Second Name], Age , Gender)
VALUES 
(N'Mihaela', N'Balan', 30, 0)

INSERT INTO Lectors(Id, Organization) VALUES (SCOPE_IDENTITY(), N'UTM')
INSERT INTO Reviewables DEFAULT VALUES
INSERT INTO LectorRecords SELECT SCOPE_IDENTITY(), Id FROM Users WHERE [Second Name] = N'Balan' AND [First Name] = N'Mihaela'

--Generate LectorCourses
INSERT INTO LectorsCourses SELECT c.Id, u.Id FROM Users u ,Courses c 
WHERE u.[Second Name] = N'Sava' AND c.Name in (N'MS', N'AMSI')

INSERT INTO LectorsCourses SELECT c.Id, u.Id FROM Users u ,Courses c 
WHERE u.[Second Name] = N'Cojanu' AND c.Name in (N'BDC', N'MIDPS', N'PW')

INSERT INTO LectorsCourses SELECT c.Id, u.Id FROM Users u ,Courses c 
WHERE u.[Second Name] = N'Cojuhari' AND c.Name in (N'TS', N'LFPC')

--Create Schedules
INSERT INTO Schedules 
SELECT lc.Id, N'Saturday', dateadd(millisecond, cast((28800000 + 36000000 * RAND(CHECKSUM(newid()))) as int), convert(time, '00:00')), N'Olimpia - 505' FROM LectorsCourses lc, Users 
WHERE LectorId = Users.Id AND [Second Name] = N'Sava'

INSERT INTO Schedules 
SELECT lc.Id, N'Tuesday', dateadd(millisecond, cast((28800000 + 36000000 * RAND(CHECKSUM(newid()))) as int), convert(time, '00:00')), '3-405' FROM LectorsCourses lc, Users 
WHERE LectorId = Users.Id and [Second Name] = N'Sava'

INSERT INTO Schedules 
SELECT lc.Id, N'Monday', dateadd(millisecond, cast((28800000 + 36000000 * RAND(CHECKSUM(newid()))) as int), convert(time, '00:00')), 'UTM 3-405' FROM LectorsCourses lc, Users 
WHERE LectorId = Users.Id and [Second Name] = N'Sava'

INSERT INTO Schedules 
SELECT lc.Id, N'Monday', dateadd(millisecond, cast((28800000 + 36000000 * RAND(CHECKSUM(newid()))) as int), convert(time, '00:00')), 'UTM 3-3' FROM LectorsCourses lc, Users 
WHERE LectorId = Users.Id and [Second Name] = N'Cojanu'

INSERT INTO Schedules 
SELECT lc.Id, N'Tuesday', dateadd(millisecond, cast((28800000 + 36000000 * RAND(CHECKSUM(newid()))) as int), convert(time, '00:00')), 'UTM 3-505' FROM LectorsCourses lc, Users 
WHERE LectorId = Users.Id and [Second Name] = N'Cojuhari'

INSERT INTO Schedules 
SELECT lc.Id, N'Thursday', dateadd(millisecond, cast((28800000 + 36000000 * RAND(CHECKSUM(newid()))) as int), convert(time, '00:00')), 'UTM 3-405' FROM LectorsCourses lc, Users 
WHERE LectorId = Users.Id and [Second Name] = N'Cojuhari'

INSERT INTO Schedules 
SELECT lc.Id, N'Wednesday', dateadd(millisecond, cast((28800000 + 36000000 * RAND(CHECKSUM(newid()))) as int), convert(time, '00:00')), 'UTM 3-505' FROM LectorsCourses lc, Users 
WHERE LectorId = Users.Id and [Second Name] = N'Cojuhari'

--Create reviews
INSERT INTO Reviews(UserId, ReviewableId, Rating, IsAnonymous, Comment, DateCreated) 
VALUES
(0, 0, 5, 0, N'Nice', GETDATE()),
(5, 2, 4, 0, N'Ok', '2015-09-01'),
(1, 3, 4, 1, N'Cool', '2014-05-01'),
(2, 5, 4, 1, N'Merge', '2016-02-01'),
(4, 7, 4, 1, N'Mmm', '2016-02-01'),
(0, 8, 3, 1, N'Comne-ci Comme-ca', '2016-02-01'),
(6, 5, 3, 1, N'Norm', '2016-02-01'),
(7, 8, 3, 1, N'mda', '2016-02-01'),
(7, 3, 4, 1, N'Tema', '2016-02-01'),
(2, 4, 3, 0, NULL, GETDATE())

--DELETE FROM Users
--DELETE FROM Lectors 