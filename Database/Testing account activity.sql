select * from global_r2iv2.T_User
where F_StudentID like '1217-0566-7566%';
select * from global_r2iv2.T_Membership
where F_UserID=245127;

-- who has done something from Brazil?
select * from global_r2iv2.T_Session
where F_UserID in (
select F_UserID from global_r2iv2.T_Membership
where F_GroupID=170)
and F_StartDateStamp>'2012-04-20'
order by F_StartDateStamp desc;
