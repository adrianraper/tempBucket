-- who is new today ? --
SELECT m.F_RootID, u.* FROM `global_r2iv2`.`T_User` u, global_r2iv2.T_Membership m
where u.F_UserID >= 245255
and u.F_UserID = m.F_UserID
and F_Country='Hong Kong'
order by u.F_UserID desc;

-- who has used the new system today ? --
select * from global_r2iv2.T_Session 
where F_RootID=14030
order by F_SessionID desc;

select * from global_r2iv2.T_Score
where F_UserID in (select F_UserID from global_r2iv2.T_Session 
where F_RootID=14030);

-- who has used the old system today ? --
select * from GlobalRoadToIELTS.T_Session
where F_RootID=14030
and F_SessionID>3054495
order by F_SessionID desc;

SELECT * FROM `global_r2iv2`.`T_Membership`  order by F_UserID desc;
SELECT * FROM `global_r2iv2`.`T_User` order by F_UserID desc;

select * from GlobalRoadToIELTS.T_Session s, GlobalRoadToIELTS.T_User u
where u.F_UserName in ('47528','47256','48105','47504')
and u.F_UserID = s.F_UserID;

select * from GlobalRoadToIELTS.T_User u
where u.F_UserName in ('47528','Plaisir__Cheung_','Manzil_Ajay__Chullani_','Ka_Yin__Chiu_');

select avg(F_Duration) from GlobalRoadToIELTS.T_Session s 
where F_StartDateStamp>'2012'
and F_Duration<24000
order by F_SessionID desc;

set @thisUser = 245260;
select * from global_r2iv2.T_User
where F_UserID=@thisUser;
select * from global_r2iv2.T_Score
where F_UserID=@thisUser;
select SUM(F_Duration) from global_r2iv2.T_Score
where F_UserID=@thisUser;
select * from global_r2iv2.T_Session
where F_UserID=@thisUser;


