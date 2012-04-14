SELECT * FROM `rack80829`.`T_Session`
where F_RootID=0
order by F_StartDateStamp desc;
select * from T_User where F_UserName = 'Mrs White';
select * from T_Accounts where F_RootID=163;
select * from T_Product;
delete from T_Session
where F_StartDateStamp>'2012-04-15';
SELECT * FROM `rack80829`.`T_Score`
where F_SessionID >2227400;

-- set rootId to 0 for teachers
update T_Session s
set s.F_RootID=-1
WHERE 
FROM T_Session si
INNER JOIN T_User u
ON si.F_UserID=u.F_UserID
WHERE u.F_UserType!=0
AND u.F_UserID=19304;

SELECT si.* 
FROM T_Session si
INNER JOIN T_User u
ON si.F_UserID=u.F_UserID
WHERE u.F_UserType!=0
AND u.F_UserID=19304;

