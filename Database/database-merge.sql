-- sql to merge global_r2iv3 into rack80830
-- fromDB = 'global_r2iv3';
-- toDB = 'rack80830';

-- first tidy up a bit
-- what we do need to do here is to archive sessions, memberships and scores that do not have 
-- a F_UserID in T_User. Are there any other tables too?
-- I am just going to leave the expiry tables where they are.
insert into global_r2iv3.T_Membership_Expiry
select * from global_r2iv3.T_Membership m
where not exists (select * from global_r2iv3.T_User u where u.F_UserID=m.F_UserID);
delete from global_r2iv3.T_Membership
where F_UserID NOT IN (select F_UserID from global_r2iv3.T_User);

insert into global_r2iv3.T_Session_Expiry
select * from global_r2iv3.T_Session s
where not exists (select * from global_r2iv3.T_User u where u.F_UserID=s.F_UserID);
delete from global_r2iv3.T_Session
where F_UserID NOT IN (select F_UserID from global_r2iv3.T_User);

insert into global_r2iv3.T_Score_Expiry
select * from global_r2iv3.T_Score s
where not exists (select * from global_r2iv3.T_User u where u.F_UserID=s.F_UserID);
delete from global_r2iv3.T_Score
where F_UserID NOT IN (select F_UserID from global_r2iv3.T_User);

-- delete root 1 in global using DMS (which gets rid of it's groups too - specifically 22150 and 22151)
-- now copy the global accounts to rack
-- Root 14030 is a conflict - so need to update University of Sheffield to a new rootID in rack
-- delete 14113 (a testing CLS account)
set @rootID = 14113;
delete from rack80830.T_AccountRoot where F_RootID=@rootID;
delete from rack80830.T_Accounts where F_RootID=@rootID;
delete from rack80830.T_AccountEmails where F_RootID=@rootID;
delete from rack80830.T_LicenceAttributes where F_RootID=@rootID;
delete from rack80830.T_LicenceControl where F_RootID=@rootID;
delete from rack80830.T_Licences where F_RootID=@rootID;
delete from rack80830.T_Session where F_RootID=@rootID;
delete from rack80830.T_Failsession where F_RootID=@rootID;
delete from rack80830.T_Membership where F_RootID=@rootID;

set @oldrootID = 14030;
update rack80830.T_AccountRoot 
set F_RootID=@rootID where F_RootID=@oldrootID;
update rack80830.T_Accounts
set F_RootID=@rootID where F_RootID=@oldrootID;
update rack80830.T_AccountEmails
set F_RootID=@rootID where F_RootID=@oldrootID;
update rack80830.T_LicenceAttributes
set F_RootID=@rootID where F_RootID=@oldrootID;
update rack80830.T_LicenceControl
set F_RootID=@rootID where F_RootID=@oldrootID;
update rack80830.T_Licences
set F_RootID=@rootID where F_RootID=@oldrootID;
update rack80830.T_Membership
set F_RootID=@rootID where F_RootID=@oldrootID;
update rack80830.T_Session 
set F_RootID=@rootID where F_RootID=@oldrootID;
update rack80830.T_Failsession 
set F_RootID=@rootID where F_RootID=@oldrootID;

-- clear accounts that are the same on both, or rubbish in global
set @rootID = 1;
delete from global_r2iv3.T_AccountRoot where F_RootID=@rootID;
delete from global_r2iv3.T_Accounts where F_RootID=@rootID;
delete from global_r2iv3.T_AccountEmails where F_RootID=@rootID;
delete from global_r2iv3.T_LicenceAttributes where F_RootID=@rootID;
delete from global_r2iv3.T_LicenceControl where F_RootID=@rootID;
delete from global_r2iv3.T_Licences where F_RootID=@rootID;
delete from global_r2iv3.T_Membership where F_RootID=@rootID;
delete from global_r2iv3.T_Session where F_RootID=@rootID;
delete from global_r2iv3.T_Failsession where F_RootID=@rootID;
set @rootID = 101;
delete from global_r2iv3.T_AccountRoot where F_RootID=@rootID;
delete from global_r2iv3.T_Accounts where F_RootID=@rootID;
delete from global_r2iv3.T_AccountEmails where F_RootID=@rootID;
delete from global_r2iv3.T_LicenceAttributes where F_RootID=@rootID;
delete from global_r2iv3.T_LicenceControl where F_RootID=@rootID;
delete from global_r2iv3.T_Licences where F_RootID=@rootID;
delete from global_r2iv3.T_Membership where F_RootID=@rootID;
delete from global_r2iv3.T_Session where F_RootID=@rootID;
delete from global_r2iv3.T_Failsession where F_RootID=@rootID;
set @rootID = 171;
delete from global_r2iv3.T_AccountRoot where F_RootID=@rootID;
delete from global_r2iv3.T_Accounts where F_RootID=@rootID;
delete from global_r2iv3.T_AccountEmails where F_RootID=@rootID;
delete from global_r2iv3.T_LicenceAttributes where F_RootID=@rootID;
delete from global_r2iv3.T_LicenceControl where F_RootID=@rootID;
delete from global_r2iv3.T_Licences where F_RootID=@rootID;
delete from global_r2iv3.T_Membership where F_RootID=@rootID;
delete from global_r2iv3.T_Session where F_RootID=@rootID;
delete from global_r2iv3.T_Failsession where F_RootID=@rootID;
set @groupID = 102;
delete from global_r2iv3.T_Groupstructure where F_GroupID=@groupID;
set @groupID = 170;
delete from global_r2iv3.T_Groupstructure where F_GroupID=@groupID;
set @groupID = 171;
delete from global_r2iv3.T_Groupstructure where F_GroupID=@groupID;
set @groupID = 22150;
delete from global_r2iv3.T_Groupstructure where F_GroupID=@groupID;
set @groupID = 22151;
delete from global_r2iv3.T_Groupstructure where F_GroupID=@groupID;

-- bring all accounts and groups from r2i into rack
insert into rack80830.T_AccountRoot 
select * from global_r2iv3.T_AccountRoot;

insert into rack80830.T_Accounts 
select * from global_r2iv3.T_Accounts;

insert into rack80830.T_AccountEmails 
select * from global_r2iv3.T_AccountEmails;

insert into rack80830.T_LicenceAttributes 
select * from global_r2iv3.T_LicenceAttributes;

insert into rack80830.T_Failsession 
select * from global_r2iv3.T_Failsession;

insert into rack80830.T_Groupstructure 
select * from global_r2iv3.T_Groupstructure;

-- For all user related information you have to insert the user and get that new id, then
-- update all the F_UserID data in session, score, membership.
-- That will need a program. InternalQueryGateway.php

-- Then finally shift all the session, score and membership records with the updated userID over to rack
insert into rack80830.T_Session 
select * from global_r2iv3.T_Session;
insert into rack80830.T_Score 
select * from global_r2iv3.T_Score;
insert into rack80830.T_Membership 
select * from global_r2iv3.T_Membership;

-- Give HCT students an 'email' equivalent to their id
UPDATE T_User u
LEFT JOIN T_Membership m
ON u.F_UserID = m.F_UserID
SET u.F_Email = u.F_StudentID
WHERE m.F_RootID in (14276,14277,14278,14279,14280,14281,14282,14283,14284,14285,14286,14287,14288,14289,14290,14291,14292)
AND u.F_UserType = 0;

-- For testing
select * from global_r2iv3.T_User where F_Email = 'Magdamostkova@hotmail.com'; 

select s.* from global_r2iv3.T_Session s, global_r2iv3.T_User u
where u.F_Email = 'Magdamostkova@hotmail.com'
and s.F_UserID = u.F_UserID; 

select sum(s.F_Duration) from global_r2iv3.T_Session s, global_r2iv3.T_User u
where u.F_Email = 'Magdamostkova@hotmail.com'
and s.F_UserID = u.F_UserID; 

select s.* from global_r2iv3.T_Score s, global_r2iv3.T_User u
where u.F_Email = 'Magdamostkova@hotmail.com'
and s.F_UserID = u.F_UserID; 

select sum(s.F_Duration) from global_r2iv3.T_Score s, global_r2iv3.T_User u
where u.F_Email = 'Magdamostkova@hotmail.com'
and s.F_UserID = u.F_UserID; 

select * from rack80830.T_User where F_Email = 'Magdamostkova@hotmail.com'; 

select s.* from rack80830.T_Session s, rack80830.T_User u
where u.F_Email = 'Magdamostkova@hotmail.com'
and s.F_UserID = u.F_UserID; 

select sum(s.F_Duration) from rack80830.T_Session s, rack80830.T_User u
where u.F_Email = 'Magdamostkova@hotmail.com'
and s.F_UserID = u.F_UserID; 

select s.* from rack80830.T_Score s, rack80830.T_User u
where u.F_Email = 'Magdamostkova@hotmail.com'
and s.F_UserID = u.F_UserID; 

select sum(s.F_Duration) from rack80830.T_Score s, rack80830.T_User u
where u.F_Email = 'Magdamostkova@hotmail.com'
and s.F_UserID = u.F_UserID; 