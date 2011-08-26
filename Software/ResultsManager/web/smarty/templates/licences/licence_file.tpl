{* This templates expects an $account and $title variable. *}
[Clarity Language Consultants Ltd licence]
Product={$title->caption}
Branding=Clarity/AR
Product type=Demo
Serial number=1234
Institution name={$account->name}
Installation date=2006-06-14
Registration date={format_ansi_date ansiDate=$title->licenceStartDate}
Student expiry={format_ansi_date ansiDate=$title->expiryDate}
Student permission=0000000
Student language={$title->languageCode}
Maximum student={$title->maxStudents}
Licencing={get_dictionary_label name=licenceType data=$title->licenceType dictionary_source=AccountOps}
xxCourseIDxx=1189060123432
xxCourseIDxx=1189060123431,1195467488046,1190277377521
Registration server=www.AuthorPlus.com/register/register.asp
Verification server=www.clarity.com.hk/verify/verify.asp
Central root={$account->id}
Exit page=http://www.clarity.com.hk
CheckSum=d996f75f138588adacb1ba84761dfae3
{foreach from=$account->licenceAttributes item=licenceAttribute}
{$licenceAttribute.licenceKey}={$licenceAttribute.licenceValue}
{/foreach}