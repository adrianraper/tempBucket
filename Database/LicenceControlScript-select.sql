-- Add in a toDate
set @fromDate = '2011-07-01';
set @toDate = '2011-12-31';
set @rootID=10212;
set @productCode=1;

SELECT COUNT(DISTINCT s.F_UserID) AS activeStudentCount
FROM T_Session s, T_User u
WHERE s.F_ProductCode=@productCode
AND s.F_RootID=@rootID
AND s.F_UserID = u.F_UserID
AND u.F_UserType=0
AND s.F_StartDateStamp>=@fromDate
AND s.F_StartDateStamp<=@toDate
AND EXISTS (SELECT * FROM T_Score c WHERE c.F_SessionID=s.F_SessionID);

SELECT COUNT(DISTINCT s.F_UserID) AS allDeletedCount
FROM T_Session s
left join T_User u
on s.F_UserID = u.F_UserID
WHERE s.F_ProductCode=@productCode
AND s.F_RootID=@rootID
AND s.F_StartDateStamp>=@fromDate
AND s.F_StartDateStamp<=@toDate
AND u.F_UserID IS NULL
AND s.F_UserID > 0;
