############################
# Name : Get-NonGroupPermissions.ps1
# Function: Gets a list of folders within a share that have individual user permissions set, 
# rather than the approved role groups from within AD
#
# Author - Robert Ainsworth - https://ainsey11.com


# Setting variables
$EmailFrom = "#"
$EmailTo = "#"
$EmailServer = "#"
$EmailSubjectLine = "Files and Folders found with individual permissions assigned"
$EMailBody = " Individual Permissions have been detected, please see attached file and resolve as soon as possible. This is a security incident"
$Domain = "#"

$Output = "C:\Support\FoldersWithIndividualAccess.csv"
$Path =  "D:\Robert Public Share"

#this is where the magic happens!
# Note - this will only work for usernames that are in the format firstname.lastname
# this won't be a massive problem when we implement 0365 because all usernames will be the same format
# but none of our groups have a "." in the names, so perfect way of excluding groups from the results
# because groups and individual users are returned as the same property type in the powershell output

get-acl $Path | select -expand access | # Gets the ACL's for the path and expands the access property
where { $_.IdentityReference -like "$domain\*.*" } | #filters it to firstname.lastname users
select FileSystemRights,IdentityReference,Isinherited | # gets rid of the crap I don't care about 
export-CSV $Output #Dump this somewhere useful, because I'm lazy

# Send an e-mail into the relevant people, the little if statement won't e-mail you if the file contains no individual permissions,
# the acl loop will always create a 0KB file unless there are permissions, then it's larger. Hence why the below section works
# I'll make it better one day, I promise ;)

if( (get-item $Output).length -gt 0KB)
{
Send-MailMessage -From $EmailFrom -To $EmailTo -SmtpServer $EmailServer -Subject $EmailSubjectLine -Priority High -Body $EMailBody -Attachments $Output
}    

# Tidying it up now, nothing to see here, move along
Remove-Item $Output