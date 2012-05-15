-- Run each query in MySQL workbench
-- Save the resulting grid as SQL INSERT statements
-- Open in an editor and replace all but the first INSERT statement and leave as a list of VALUES

select * from T_AccountRoot
where F_RootID=163;

select * from T_Accounts
where F_RootID=163;

select * from T_Groupstructure
where F_GroupID in 
(select distinct(F_GroupID) from T_Membership where F_RootID=163);

select * from T_Membership
where F_RootID=163 order by F_UserID;

select u.* from T_Membership m, T_User u
where m.F_RootID=163
and m.F_UserID = u.F_UserID
order by F_UserID;

-- Close the SQL and make a new INSERT every 5000 records to avoid packet size overload
select s.* from T_Score s, T_Membership m
where m.F_RootID=163
and m.F_UserID = s.F_UserID
order by s.F_UserID;

select * from T_AccountEmails
where F_RootID=163;

SELECT * FROM T_ExtraTeacherGroups
where F_GroupID in 
(select distinct(F_GroupID) from T_Membership where F_RootID=163);

SELECT * FROM T_LicenceAttributes
where F_RootID=163;

SELECT * FROM T_ScoreDetail
where F_RootID=163;

-- T_Session and T_Failsession do not get removed by AccountOps.deleteAccount