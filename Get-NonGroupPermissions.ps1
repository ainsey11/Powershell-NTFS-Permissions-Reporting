<#
.Synopsis
   Gets a list of folders within a share that have individual user permissions set, rather than the approved role groups from within AD
.EXAMPLE
    .\Get-NonGroupPermissions.ps1 -Path '\\server\share\path' -Domain acmecorp -OutputFilepath C:\Temp\Test.csv -Email -To reciever@acme.com -From sender@acme.com -SmtpServer smtp.acme.com -Subject 'Test email' -Verbose -Recurse
.NOTES
    Author - Robert Ainsworth - https://ainsey11.com
    Contributor - Shawn Esterman - https://github.com/ShawnEsterman
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true,
               ValueFromPipeline = $true,
               ValueFromPipelineByPropertyName = $true)]
    [ValidateScript({ $_ | ForEach-Object -Process { Test-Path -Path $_ } })]
    [String[]]
    $Path,
    [Parameter(Mandatory = $true)]
    [String]
    $Domain = "acme.com",
    [switch]
    $Recurse,
    [String]
    $OutputFilepath = "C:\Support\FoldersWithIndividualAccess.csv",
    [Parameter(Mandatory = $true, 
               ParameterSetName = 'Email')]
    [Switch]
    $Email,
    [Parameter(ParameterSetName = 'Email')]
    [ValidateScript({ $_ | ForEach-Object -Process { try { New-Object System.Net.Mail.MailAddress($_) } catch { return $false } }; return $true })]
    [String[]]
    $To = 'defaultto@acme.com',
    [Parameter(ParameterSetName = 'Email')]
    [ValidateScript({ try { New-Object System.Net.Mail.MailAddress($_); return $true } catch { return $false } })]
    [String]
    $From = 'defaultfrom@acme.com',
    [Parameter(ParameterSetName = 'Email')]
    $SmtpServer = 'defaultsmtp.acme.com',
    [Parameter(ParameterSetName = 'Email')]
    $Subject = "Files and Folders found with individual permissions assigned"
)

$PreContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
<style>
body {
    color: #373a3c;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto", "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue", Helvetica, Arial, sans-serif;
    font-size: 16px;
}
a {
    color: #d9534f;
}
table {
	border-width: 1px;
	border-color: #eceeef;
	border-collapse: collapse;
}
th,
td {
    border-color: #eceeef;
    border-style: solid;
    border-width: 1px;
    padding: 8px;
}
th {
	background-color: #337ab7;
}
td {
	background-color: transparent;
}
</style>
</head>
<body>
"@

$PostContent = @"
</body>
</html>
"@

$Body = $PreContent
$Body += "<h1>$Subject</h1>"

$Data = @()

if ($Recurse)
   {
   $Folderlist = get-ChildItem $Path -recurse | ?{ $_.PSIsContainer }
foreach ( $p in $Folderlist ) {
    Write-Verbose "Checking path $P"
    $Data += (Get-ChildItem $Path -Recurse |Get-Acl).Access.Where{ $_.IdentityReference -like "$domain\*.*" } |
                Select-Object -Property FileSystemRights,IdentityReference,Isinherited |
                ForEach-Object -Process {
                    Write-Verbose "Found $($_.FileSystemRights) on path $("$path\$Folderlist") for $($_.IdentityReference)"
                    [pscustomobject] @{
                        Path = "$path\$p"
                        FileSystemRights = $_.FileSystemRights
                        IdentityReference = $_.IdentityReference
                        IsInherited = $_.IsInherited
                    }
                }
}
}

else {

    foreach ( $P in $Path ) {
    Write-Verbose "Checking path $P"
    $Data += (Get-Acl -LiteralPath $Path).Access.Where{ $_.IdentityReference -like "$domain\*.*" } |
                Select-Object -Property FileSystemRights,IdentityReference,Isinherited |
                ForEach-Object -Process {
                    Write-Verbose "Found $($_.FileSystemRights) on path $($P) for $($_.IdentityReference)"
                    [pscustomobject] @{
                        Path = $P
                        FileSystemRights = $_.FileSystemRights
                        IdentityReference = $_.IdentityReference
                        IsInherited = $_.IsInherited
                    }
                }
}

}

if ( $Data ) {
    
    if ( $OutputFilepath ) {
        Write-Verbose "Outputting data to $OutputFilePath"
        $Data | Export-Csv -LiteralPath $OutputFilepath -NoTypeInformation
    }

    if ( $Email ) {
        
        $Body += $Data | ConvertTo-Html -Fragment
        $Body += $PostContent

        $Params = @{
            To = $To
            From = $From
            SmtpServer = $SmtpServer
            Subject = $Subject
            Priority = 'High'
            Body = $Body
            BodyAsHtml = $true
        }
        Send-MailMessage @Params
    }

}
