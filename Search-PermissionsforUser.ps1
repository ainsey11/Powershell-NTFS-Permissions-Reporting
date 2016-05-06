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


$folders = "D:\Documents\github\"

foreach ($path in $paths){   
    gci $Paths | get-acl  | %{
    $Acl=$_
    $_.Access|?{$_.AccessControlType -eq "Allow"}|Select -Unique IdentityReference|%{
        [PSCustomObject]@{
        "Path"=$ACL.PSPath.substring(38,$Acl.PSPath.Length-38); 
        "Owner"=$ACL.Owner;
        "Group"=$ACL.Group;
        "Access"=$_.IdentityReference | Where-Object {$_ -like "*$Users*"} 
        }
    }
} 
}