# Ainsey11's Powershell NTFS Individual User Permissions Report
This bit of code scans over a folder set in a variable, then e-mails a set address if there are permissions for individual users. 

### Installation Instructions :
Place in any dir, then execute with the relevant arguments.

### Example :
.\Get-NonGroupPermissions.ps1 -Path '\\server\share\path' -Domain acmecorp -OutputFilepath C:\Temp\Test.csv -Email -To reciever@acme.com -From sender@acme.com -SmtpServer smtp.acme.com -Subject 'Test email' -Verbose -Recurse

##### Improvement Plan:
 - Look into making a seperate script that writes to a database for logging and a scaled solutuion for large file servers.