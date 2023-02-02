$group = 'Administrators'
Write-Output "***************************************************************"
Write-Output "Script starts Here" 
Write-Output "Group being monitored is: $group"

if (Test-Path "C:\temp\monitorAD\$group.csv") {
    $previousRunMemberships = Import-Csv -Path "C:\temp\monitorAD\$group.csv"
    Write-Output "previous file exist"
    Write-Output "previuos members in $group"
    Write-Output $previousRunMemberships}

$groupMembers = Get-LocalGroupMember $group
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
$added | Export-Csv -Path "C:\temp\monitorAD\added.csv" -NoTypeInformation
$removed | Export-Csv -Path "C:\temp\monitorAD\removed.csv" -NoTypeInformation
$final_add = Import-Csv -Path "C:\temp\monitorAD\added.csv"
$final_removed = Import-Csv -Path "C:\temp\monitorAD\removed.csv"
$body = "Group Administrators`n"+"Added:"+$final_add + "`nRemoved:"+$final_removed

Write-Output ""
Write-Output "Changes:"
Write-Output "added:"
Write-Output $added
Write-Output "removed:"
Write-Output $removed
Write-Output "Body"
Write-Output $body

<#
$smtp_ip= Read-Host -Prompt "Enter SMTP IP"
Write-Host "The IP was: " $smtp_ip
$to_email='jlavado@recipeunlimited.com'
$subject='Domain Admins group change alert'
$from_email='no-reply@recipeunlimited.com'
#$to_email='aaaadqh5i5tbgm7xg2kkmuukau@recipe-unlimited.slack.com'
Send-MailMessage -To $to_email -Subject $subject -Body $body -SmtpServer $smtp_ip -From $from_email -Port 25

#>