
-- set rootId to -1 for teachers
-- takes 2.5 seconds for 31 rows
-- takes 251 seconds for 67,329 rows
update T_Session as s
INNER JOIN T_User u
ON s.F_UserID=u.F_UserID
set s.F_RootID=-1
WHERE u.F_UserType!=0;

SELECT *
FROM T_Session s
INNER JOIN T_User u
ON s.F_UserID=u.F_UserID
WHERE u.F_UserType!=0
AND s.F_RootID>0;

-- This is all the people who have a licence
SELECT COUNT(DISTINCT(s.F_UserID)) AS licencesUsed 
FROM T_Session s
WHERE s.F_ProductCode = 9
AND s.F_Duration > 15
AND s.F_EndDateStamp >= '2011-09-08'
AND s.F_RootID = 11811;

-- This is the list of students that have a session but no score
SELECT * FROM T_User
WHERE F_UserID in 
(SELECT distinct(s.F_UserID)
FROM T_Session s, T_User u
WHERE NOT EXISTS (SELECT * FROM T_Score WHERE F_UserID = s.F_UserID AND F_DateStamp >= '2011-09-08' AND F_ProductCode = 9)
AND s.F_ProductCode = 9
AND s.F_EndDateStamp >= '2011-09-08'
AND s.F_RootID = 11811);

