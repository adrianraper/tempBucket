-- sql to merge global_r2iv2 into rack80829

-- first create the accounts in rack
-- Root 14030 is a conflict - so need to update University of Sheffield to a new rootID in rack
-- delete 14113 (a testing CLS account)
set @rootID = 14113;
delete from T_AccountRoot where F_RootID=@rootID;
delete from T_Accounts where F_RootID=@rootID;
delete from T_AccountEmails where F_RootID=@rootID;
delete from T_LicenceAttributes where F_RootID=@rootID;
delete from T_LicenceControl where F_RootID=@rootID;
delete from T_Licences where F_RootID=@rootID;
delete from T_Membership where F_RootID=@rootID;
delete from T_Session where F_RootID=@rootID;
delete from T_Failsession where F_RootID=@rootID;

update rack80829.T_AccountRoot 
set F_RootID=14113 where F_RootID=14030;
update rack80829.T_Accounts
set F_RootID=14113 where F_RootID=14030;
update rack80829.T_AccountEmails
set F_RootID=14113 where F_RootID=14030;
update rack80829.T_LicenceAttributes
set F_RootID=14113 where F_RootID=14030;
update rack80829.T_LicenceControl
set F_RootID=14113 where F_RootID=14030;
update rack80829.T_Licences
set F_RootID=14113 where F_RootID=14030;
update rack80829.T_Membership
set F_RootID=14113 where F_RootID=14030;
update rack80829.T_Session 
set F_RootID=14113 where F_RootID=14030;
update rack80829.T_Failsession 
set F_RootID=14113 where F_RootID=14030;

-- clear accounts that are the same on both
set @rootID = 101;
delete from T_AccountRoot where F_RootID=@rootID;
delete from T_Accounts where F_RootID=@rootID;
delete from T_AccountEmails where F_RootID=@rootID;
delete from T_LicenceAttributes where F_RootID=@rootID;
delete from T_LicenceControl where F_RootID=@rootID;
delete from T_Licences where F_RootID=@rootID;
delete from T_Membership where F_RootID=@rootID;
delete from T_Session where F_RootID=@rootID;
delete from T_Failsession where F_RootID=@rootID;
set @rootID = 171;
delete from T_AccountRoot where F_RootID=@rootID;
delete from T_Accounts where F_RootID=@rootID;
delete from T_AccountEmails where F_RootID=@rootID;
delete from T_LicenceAttributes where F_RootID=@rootID;
delete from T_LicenceControl where F_RootID=@rootID;
delete from T_Licences where F_RootID=@rootID;
delete from T_Membership where F_RootID=@rootID;
delete from T_Session where F_RootID=@rootID;
delete from T_Failsession where F_RootID=@rootID;
set @groupID = 102;
delete from T_Groupstructure where F_GroupID=@groupID;
set @groupID = 170;
delete from T_Groupstructure where F_GroupID=@groupID;
set @groupID = 171;
delete from T_Groupstructure where F_GroupID=@groupID;

-- bring all accounts and groups from r2i into rack
insert into rack80829.T_AccountRoot from
select * from global_r2iv2.T_AccountRoot;

insert into rack80829.T_Accounts from
select * from global_r2iv2.T_Accounts;

insert into rack80829.T_AccountEmails from
select * from global_r2iv2.T_AccountEmails;

insert into rack80829.T_LicenceAttributes from
select * from global_r2iv2.T_LicenceAttributes;

insert into rack80829.T_Failsession from
select * from global_r2iv2.T_Failsession;

insert into rack80829.T_Groupstructure from
select * from global_r2iv2.T_Groupstructure;

-- For all user related information you have to insert the user and get a new id, then
-- update all the F_UserID data in session, score, membership. Then move those.
-- That will need a program. InternalQueryGateway.php

-- Then finally shift the session, score and membership records with the updated userID over to rack
insert into rack80829.T_Session from
select * from global_r2iv2.T_Session;
insert into rack80829.T_Score from
select * from global_r2iv2.T_Score;
insert into rack80829.T_Membership from
select * from global_r2iv2.T_Membership;

-- what we do need to do here is to archive sessions, memberships and scores that do not have 
-- a F_UserID in T_User. Are there any other tables too?
-- I am just going to leave the expiry tables where they are.
insert into global_r2iv2.T_Membership_Expiry from
select * from global_r2iv2.T_Membership m
where not exists (select * from global_r2iv2.T_User u where u.F_UserID=m.F_UserID);
delete from global_r2iv2.T_Membership
where F_UserID NOT IN (select F_UserID from global_r2iv2.T_User);

insert into global_r2iv2.T_Session_Expiry from
select * from global_r2iv2.T_Session s
where not exists (select * from global_r2iv2.T_User u where u.F_UserID=s.F_UserID);
delete from global_r2iv2.T_Session
where F_UserID NOT IN (select F_UserID from global_r2iv2.T_User);

insert into global_r2iv2.T_Score_Expiry from
select * from global_r2iv2.T_Score s
where not exists (select * from global_r2iv2.T_User u where u.F_UserID=s.F_UserID);
delete from global_r2iv2.T_Score
where F_UserID NOT IN (select F_UserID from global_r2iv2.T_User);
