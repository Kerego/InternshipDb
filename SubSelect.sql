--Select lectors and number of courses they teach
SELECT	u.[First Name],
		u.[Second Name],
		(SELECT COUNT(*) 
			FROM LectorsCourses lc 
			WHERE lc.LectorId = u.Id) 
		[Number of Courses] 
FROM Users u
INNER JOIN Lectors l on l.Id = u.Id
ORDER BY [Number of Courses] DESC


--Select organizations that have average age less than 28
SELECT DISTINCT Organization
FROM Lectors ol
WHERE 28 > (SELECT AVG(u.Age) 
			FROM Users u, Lectors il 
			WHERE u.Id = il.Id AND ol.Organization = il.Organization)


--Select reviewers and the average rating of their reviews
SELECT	u.[First Name],
		u.[Second Name], 
		(SELECT AVG(CAST(Rating as float)) 
		FROM Reviews r 
		WHERE r.UserId = u.Id)  [Average Rating]
FROM Users u

--Select Lectors that have average rating lower that average rating of their reviews
SELECT u.[First Name], u.[Second Name], AVG(CAST(Rating as float)) as [Average Rating]
FROM Users u
INNER JOIN LectorRecords lr on lr.LectorId = u.Id
INNER JOIN Reviews r on r.ReviewableId = lr.Id
GROUP BY u.Id, u.[First Name], u.[Second Name]
HAVING AVG(CAST(Rating as float)) < (SELECT AVG(CAST(Rating as float)) FROM Reviews rev WHERE rev.UserId = u.Id)


--Select youngest Lectors of each organization
SELECT	u.[First Name],
		u.[Second Name],
		u.Age,
		l.Organization
FROM Users u
INNER JOIN Lectors l on l.Id = u.Id
WHERE Age <= ALL(SELECT iu.Age 
				FROM Users iu, Lectors il
				WHERE iu.Id = il.Id AND l.Organization = il.Organization)



--Select Users that have reviews with rating greater than 3
SELECT	u.[First Name],
		u.[Second Name],
		u.Age
FROM Users u
WHERE EXISTS(SELECT * 
			FROM Reviews r 
			WHERE r.UserId = u.id AND r.Rating >= 4)


--Select courses that can be visited on saturday or sunday
SELECT c.Id, c.Name, c.Credits
FROM Courses c
INNER JOIN LectorsCourses lc on lc.CourseId = c.Id
INNER JOIN Schedules sch on sch.LectorCourseId = lc.Id
WHERE sch.[Day] IN ('Saturday', 'Sunday')


--Select Courses that are taught by lectors from Oratorica Organization
SELECT c.Id, c.Name, c.Credits
FROM Courses c
INNER JOIN LectorsCourses lc on lc.CourseId = c.Id
WHERE lc.LectorId = ANY(SELECT Id 
						FROM Lectors 
						WHERE Organization = 'Oratorica')

--Select Name,Surname of all users and their roles
SELECT	u.[First Name], 
		u.[Second Name],	
		(CASE	WHEN u.Id IN (SELECT Id FROM Lectors) 
					THEN 'Lector' 
				WHEN u.Id IN (SELECT Id FROM Students) 
					THEN 'Student'
				END) [Role]
FROM Users u

--Select lectors that teach only TS and LFPC
SELECT u.Id, u.[First Name], u.[Second Name]
FROM Users u
INNER JOIN LectorsCourses lc on lc.LectorId = u.Id
INNER JOIN Courses c on c.Id = lc.CourseId
GROUP BY u.Id, u.[First Name], u.[Second Name]
HAVING SUM(CASE WHEN c.Name IN('TS', 'LFPC')
					THEN 1
				ELSE
					0
				END ) = 2