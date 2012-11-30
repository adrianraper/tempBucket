-- sql to merge global_r2iv2 into rack80829

-- first create the accounts in rack
-- Root 14030 is a conflict - so need to update University of Sheffield to a new rootID in rack
-- use DMS to delete 14113 (Testing CLS account)
delete from T_Session where F_RootID=14113;
delete from T_Failsession where F_RootID=14113;
delete from T_Score where F_RootID=14113;

insert into rack80829.T_AccountRoot from
select * from global_r2iv2.T_AccountRoot where F_RootID=14030;

insert into rack80829.T_Accounts from
select * from global_r2iv2.T_Accounts where F_RootID=14030;

insert into rack80829.T_Membership from
select * from global_r2iv2.T_Membership where F_RootID=14030;

insert into rack80829.T_User from
select u.* from global_r2iv2.T_User u, global_r2iv2.T_Membership m 
where u.F_UserID = m.F_UserID and 
m.F_RootID=14030;

select * from T_Groupstructure where F_RootDominant=14030;
select * from T_Licences where F_RootID=14030;
select * from T_LicenceAttributes where F_RootID=14030;

select * from T_Session where F_RootID=14030;
select * from T_Failsession where F_RootID=14030;
select * from T_Score where F_RootID=14030;
