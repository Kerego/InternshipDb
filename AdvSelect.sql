--Select courses and count number of teachers for each course
SELECT c.Name, c.Credits, COUNT(*) as AvailableTeachers
FROM Lectors l
INNER JOIN LectorsCourses lc on lc.LectorId = l.Id
INNER JOIN Courses c on lc.CourseId = c.Id
GROUP BY c.Name, c.Credits
HAVING COUNT(*) > 1

--Select users and number of comments they have and how many of them are anonymous
SELECT u.[First Name], COUNT(*) NrOfComments, SUM(IsAnonymous + 0) as AnonymousComments
FROM Users u
INNER JOIN Reviews r on r.UserId = u.Id
GROUP BY u.[First Name]
HAVING SUM(IsAnonymous + 0) > 0

--Delete all lectors that does not have courses
DELETE u FROM Users u
INNER JOIN Lectors l on l.Id = u.Id
LEFT JOIN LectorsCourses lc on u.id = lc.LectorId
WHERE lc.Id is null

--Clear
--TRUNCATE TABLE Schedules

--Select lector name, surname, organization and default room
SELECT u.[First Name], u.[Second Name], l.Organization, l.DefaultRoom FROM Users u
INNER JOIN Lectors l on l.Id = u.Id

--Set default room for teacher based their schedule
UPDATE Lectors SET Lectors.DefaultRoom = sch.Place
OUTPUT inserted.*
FROM Lectors l
INNER JOIN LectorsCourses lc on l.Id = lc.LectorId
INNER JOIN Schedules sch on sch.LectorCourseId = lc.Id

--Set default room for teacher based on their schedule using merge
MERGE INTO Lectors l
USING (	
		SELECT	u.Id, u.[Second Name], sch.Place,
				Rank() OVER (PARTITION BY u.Id ORDER BY COUNT(sch.Place) DESC ) as [Rank]

		FROM LectorsCourses lc
		INNER JOIN Users u on u.Id = lc.LectorId
		INNER JOIN Schedules sch on sch.LectorCourseId = lc.Id
		GROUP BY u.Id, sch.Place,u.[Second Name]) as tr on tr.Id = l.Id
WHEN MATCHED AND tr.[Rank] = 1 THEN UPDATE
	SET l.DefaultRoom = tr.Place
WHEN NOT MATCHED BY SOURCE THEN UPDATE
	SET l.DefaultRoom = 'unset';

	--CASE l.Organization WHEN N'UTM' THEN '3-207' 
	--										WHEN N'Oratorica' THEn 'Olimpia-501' END
	--	OUTPUT inserted.*



