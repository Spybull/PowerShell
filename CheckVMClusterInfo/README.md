cluster_check.ps1 
This script checks the status of virtual machines in the VMware cluster.
Reports on added virtual machines or deleted over the past day. 
To work, change the following parameters:

$path - set a path to your directory. eg $path = "C:\users\clusters"
$srv - set you vcenter address. eg $srv = "vcenter.example.org"
$usr - set you login to vcenter server. eg $usr = "admin"
$pas - set you password to vcenter server. eg $pas = "admin123"

If you need:
Send-MailMessage -To "admin@example.org" 
-From "boss@vcenter-bot.ws" 
-Subject "Lists VMs changes" -Attachments $m1 -SmtpServer "server.example.org" -Body "your message" -Encoding UTF8
