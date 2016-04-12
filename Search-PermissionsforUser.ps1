#Prompt for input (username, root folder)
$User = Read-Host "Enter the username to check"
$RootDir = Read-Host "Enter the root directory to check"
#Get list of subdirectories. We just need the Fullname (Complete path).
$Dirs = @(gci $RootDir -recurse) | Where {$_.mode -match "d"} | Select Fullname
#Create array to store results
$Compiled = @()
forEach ($Dir in $dirs)
{
   #Get the ACL for the current subdirectory. Format it in a way we can work with.
    $ACL = Get-Acl $dir.fullname
    $List = @($ACL.access | Select IdentityReference,AccessControlType,FileSystemRights)
   #Filter for $user, remove List and ACL arrays
    $Filtered = $List | Where {$_.identityreference -match $user} 
    Remove-item variable:ACL
    Remove-item variable:List
    
   #Create an object for each line in the above $List.
    forEach ($line in $Filtered)
    {
        $Object = New-Object PSObject -property @{
            "Directory" = $dir.Fullname
            "User" = $line.IdentityReference
            "AccessControl" = $line.AccessControlType
            "Rights" = $line.FileSystemRights
            }
       #Add this object to the $Compiled array.    
        $Compiled += $Object
    }
}
#Save the report.  You could add a Read-Host statement here to prompt for a filename/location, if you want.
$Compiled | Select Directory,user,accesscontrol,rights | Sort Directory | Export-CSV -notypeinformation "$env:userprofile\desktop\Permissions_$user.csv"