<#
Script to monitor AD domain group membership changes
Name: Jose Lavado <jlavado@recipeunlimited.com>
Date: Jan 30, 2023
#>

#Enter the settings to run the script
$group = 'Domain Admins' #domain group to monitor
$smtp_ip= '1.1.1.1' #email server
$subject='Domain Admins group change alert' #email parameters
$from_email='no-reply@cara.com'
$to_email1='jlavado@recipeunlimited.com' 
$to_email2='it_team-xxxx@recipe-unlimited.slack.com' #Slack channel email

#If file exists them import it to var $previousRunMemberships
if (Test-Path "C:\temp\monitorAD\$group.csv") {
    $previousRunMemberships = Import-Csv -Path "C:\temp\monitorAD\$group.csv"
   }
#Get current members of Domain group and assign to var $groupMember
$groupMembers = Get-ADGroupMember $group

#Check for each item in $groupMember if SID is found in imported file from previous run
$added = foreach ($user1 in $groupMembers) {
        if ($previousRunMemberships.SID -notcontains $user1.SID) {
            $user1
        }
    }

$removed = foreach ($user2 in $previousRunMemberships) {
        if ($groupMembers.SID -notcontains $user2.SID) {
            $user2
        }
    }

#Export the     
$groupMembers | Export-Csv -Path "C:\temp\monitorAD\$group.csv" -NoTypeInformation
$added | Export-Csv -Path "C:\temp\monitorAD\$group+added.csv" -NoTypeInformation
$removed | Export-Csv -Path "C:\temp\monitorAD\$group+removed.csv" -NoTypeInformation
$final_add = Import-Csv -Path "C:\temp\monitorAD\$group+added.csv"
$final_removed = Import-Csv -Path "C:\temp\monitorAD\$group+removed.csv"
$add_part = $final_add | select SamAccountName, objectClass, distinguishedName | Format-Table | Out-String
$removed_part = $final_removed | select SamAccountName, objectClass, distinguishedName | Format-Table | Out-String
$body = "Domain Administrators`n"+"Added:"+$add_part + "`nRemoved:"+$removed_part


if ($added -or $removed) {
Send-MailMessage -To $to_email1 -Subject $subject -Body $body -SmtpServer $smtp_ip -From 'netopswan@cara.com' -Port 25
Send-MailMessage -To $to_email2 -Subject $subject -Body $body -SmtpServer $smtp_ip -From $from_email -Port 25
}

