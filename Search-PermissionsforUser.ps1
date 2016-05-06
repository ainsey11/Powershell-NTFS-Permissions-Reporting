############################
# Name : Get-NonGroupPermissions.ps1
# Function: Gets a list of folders within a share that have individual user permissions set, 
# rather than the approved role groups from within AD
#
# Author - Robert Ainsworth - https://ainsey11.com


# Setting variables
$EmailFrom = "thq-man01@timico.co.uk"
$EmailTo = "rob@timico.co.uk"
$EmailServer = "mail.timicogroup.local"
$EmailSubjectLine = "Files and Folders found with individual permissions assigned"
$EMailBody
$Paths =  "D:\Documents\"
$Userlist = "D:\Documents\github\Poweshell-NTFS-Permissions-Reporting\Userlist.csv"

Import-Module ActiveDirectory #Imports AD module
Get-ADUser -Filter * | select Name | Export-Csv $Userlist # Gets a list of all users in Active Directory

$Users = Get-Content $userlist #Gets a list of users from the above step as a variable. Dirty, but it works


Remove-Item $Userlist