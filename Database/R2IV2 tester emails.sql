select F_UserName, F_Email, F_RegistrationDate from T_User u, T_Membership m
where m.F_GroupID=170
and m.F_UserID = u.F_UserID
and u.F_Password is not null
and u.F_Email not like '%britishcouncil%'
and u.F_Email not like '%clarity%'
order by u.F_UserID desc;

select * from T_Membership
where F_GroupID=170;