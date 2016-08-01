--SELECT * FROM Users
--SELECT * FROM Lectors
--SELECT * FROM Students

--SELECT * FROM Reviewables
--SELECT * FROM Courses
--SELECT * FROM LectorRecords

--SELECT * FROM LectorsCourses
--SELECT * FROM Schedules

--Reviews without comments 
SELECT * 
FROM Reviews 
WHERE Comment is null

--Users with an R in name and name ends with N
SELECT * 
FROM Users 
WHERE [First Name] LIKE ('%r%n')

--Reviews created after 2015, with rating more than 2 and reviewer is a student
SELECT * 
FROM Reviews 
WHERE	YEAR(DateCreated) >= 2015 AND 
		Rating >= 3 AND 
		UserId in (SELECT Id From Students)

--Lectors, Courses, and schedule for those courses
SELECT u.[First Name], u.[Second Name], c.Name, c.Credits, sch.Day, sch.Time, sch.Place 
FROM Users u
INNER JOIN LectorsCourses lc on lc.LectorId = u.Id
INNER JOIN Courses c on lc.CourseId = c.Id
INNER JOIN Schedules sch on sch.LectorCourseId = lc.Id
ORDER BY sch.Place, sch.Time

--Users and number of reviews they written
SELECT u.[First Name], u.[Second Name], COUNT(r.Id) as Reviews 
FROM Users u
LEFT JOIN Reviews r on r.UserId = u.Id AND Comment IS NOT NULL

GROUP BY u.[First Name], u.[Second Name]
ORDER BY Reviews DESC

--Lectors and all the reviews for them
SELECT u.[First Name] + ' ' + u.[Second Name] Reviewer, l.[First Name] + ' ' + l.[Second Name] Lector, c.Name Course, r.Rating ReviewRating, r.Comment ReviewComment
FROM Users u
INNER JOIN Reviews r on r.UserId = u.Id
INNER JOIN Courses c on c.Id = r.ReviewableId
INNER JOIN LectorsCourses lc on lc.CourseId = c.Id
INNER JOIN Users l on l.Id = lc.LectorId
WHERE r.IsAnonymous = 1

--Select organizations and average year of the lectors
SELECT Organization, COUNT(*) [Number of Lectors], AVG(u.Age) [Average Age]
FROM Lectors l1
INNER JOIN Users u on u.Id = l1.Id
GROUP BY Organization
HAVING 40 > AVG(u.Age)