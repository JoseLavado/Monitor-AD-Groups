$group = 'Domain Admins'
Write-Output "***************************************************************"
Write-Output "Script starts Here" 
Write-Output "Group being monitored is: $group"

if (Test-Path "C:\temp\monitorAD\$group.csv") {
    $previousRunMemberships = Import-Csv -Path "C:\temp\monitorAD\$group.csv"
    Write-Output "previous file exist"
    Write-Output "previuos members in $group"
    Write-Output $previousRunMemberships}

$groupMembers = Get-ADGroupMember $group
Write-Output "*******************************************************************"
Write-Output "Current Group memebers in $group"
Write-Output $groupMembers

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

$groupMembers | Export-Csv -Path "C:\temp\monitorAD\$group.csv" -NoTypeInformation
$added | Export-Csv -Path "C:\temp\monitorAD\$group+added.csv" -NoTypeInformation
$removed | Export-Csv -Path "C:\temp\monitorAD\$group+removed.csv" -NoTypeInformation
$final_add = Import-Csv -Path "C:\temp\monitorAD\$group+added.csv"
$final_removed = Import-Csv -Path "C:\temp\monitorAD\$group+removed.csv"
$add_part = $final_add | select SamAccountName, objectClass, distinguishedName | Format-Table | Out-String
$removed_part = $final_removed | select SamAccountName, objectClass, distinguishedName | Format-Table | Out-String
$body = "Domain Administrators`n"+"Added:"+$add_part + "`nRemoved:"+$removed_part

Write-Output ""
Write-Output "Changes:"
Write-Output "added:"
Write-Output $added
Write-Output "removed:"
Write-Output $removed
Write-Output "Body"
Write-Output $body


#$smtp_ip= Read-Host -Prompt "Enter SMTP IP"
#Write-Host "The IP was: " $smtp_ip
$smtp_ip= '1.1.1.1'
$subject='Domain Admins group change alert'
$from_email='no-reply@recipeunlimited.com'
$to_email1='jlavado@recipeunlimited.com'
$to_email2='it_team-xxxx@recipe-unlimited.slack.com'
if ($added -or $removed) {
Send-MailMessage -To $to_email1 -Subject $subject -Body $body -SmtpServer $smtp_ip -From 'netopswan@cara.com' -Port 25
Send-MailMessage -To $to_email2 -Subject $subject -Body $body -SmtpServer $smtp_ip -From $from_email -Port 25
}

