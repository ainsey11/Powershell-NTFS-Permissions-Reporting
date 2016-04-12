############################################################
# Searches Folder structure for files and folders that
# have individual permissions set, which is bad juju
#
# Author : Robert Ainsworth
# Web : https://ainsey11.com
###########################################################

# Defining my variables, because y'know - variables are handy


#Set the file server you want to scan. if using DFSR then select one of the nodes, ntf permissions are replicated.
$FileServer = "" 

#Put the top of the folder structure here, for example D:\Share the script will recursively scan anything beneath this.
$FolderLocation = ""

#Mail Information, self explanatory

$MailServer = ""
$MailRecipient = ""
$MailFrom = ""
$MailSubject = ""
$Mailpriority = ""
#

Get-Acl -Path "S:\Group\IT" | select -ExpandProperty Access