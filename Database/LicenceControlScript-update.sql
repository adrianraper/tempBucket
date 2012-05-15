set @fromDate = '2011-10-01';
set @rootID=13516;
set @productCode=46;

--
-- This script will anonymise all session records for this product in this root
-- for users who have been deleted. It effectively clears out the licence.
--
UPDATE T_Session s
LEFT JOIN T_User u
ON s.F_UserID = u.F_UserID
SET s.F_UserID=-1
WHERE s.F_ProductCode=@productCode
AND u.F_UserID IS NULL
AND s.F_UserID > 0
AND s.F_RootID=@rootID;