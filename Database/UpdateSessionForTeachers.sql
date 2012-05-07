SELECT * FROM `rack80829`.`T_Session`
where F_RootID<=0
order by F_StartDateStamp desc;

select * from T_User where F_UserName = 'Mrs White';
select * from T_Accounts where F_RootID=163;
select * from T_Product;

delete from T_Session
where F_StartDateStamp>'2012-04-15';

SELECT * FROM `rack80829`.`T_Score`
where F_SessionID >2227400;

-- set rootId to -1 for teachers
-- takes 2.5 seconds for 31 rows
-- takes 251 seconds for 67,329 rows
update T_Session as s
INNER JOIN T_User u
ON s.F_UserID=u.F_UserID
set s.F_RootID=-1
WHERE u.F_UserType!=0;
-- AND u.F_UserID=19304;

SELECT count(s.F_SessionID) 
FROM T_Session s
INNER JOIN T_User u
ON s.F_UserID=u.F_UserID
WHERE u.F_UserType!=0
AND s.F_StartDateStamp>'2011-01-01';

