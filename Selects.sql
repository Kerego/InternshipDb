SELECT * FROM Users
SELECT * FROM Lectors
SELECT * FROM Students

SELECT * FROM Reviewables
SELECT * FROM Courses
SELECT * FROM LectorRecords

SELECT * FROM Reviews

SELECT * FROM LectorsCourses
SELECT * FROM Schedules

SELECT [First Name], Courses.Name FROM LectorsCourses, Users, Courses where LectorsCourses.LectorId = Users.Id and LectorsCourses.CourseId = Courses.Id

SELECT u.Id, u.[First Name], u.[Second Name], l.Organization FROM Users u, Lectors l WHERE u.Id = l.Id
SELECT u.Id, u.[First Name], u.[Second Name], s.[Group] FROM Users u, Students s WHERE u.Id = s.Id