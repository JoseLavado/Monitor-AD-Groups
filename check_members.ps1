$groups = @(
    'Administrators'
)
Write-Output ""
Write-Output ""
Write-Output "Recipe User monitoring report *************************************"
foreach ($group in $groups) {
    $previousRunMemberships = $null
    if (Test-Path "C:\temp\monitorAD\$group.csv") {
        $previousRunMemberships = Import-Csv -Path "C:\temp\monitorAD\$group.csv"
    }
    $groupMembers = Get-LocalGroupMember $group
    $added = foreach ($member in $groupMembers) {
        if ($previousRunMemberships.SID -notcontains $member.SID) {
            $member
        }
    }
    $removed = foreach ($member in $previousRunMemberships) {
        if ($groupMembers.SID -notcontains $member.SID) {
            $member
        }
    }
   $groupMembers | Export-Csv -Path "C:\temp\monitorAD\$group.csv" -NoTypeInformation
}

$body = "The following Users were Added:`n$added`nThe following Useres were Removed:`n$removed"
Write-Output $body

$smtp_ip= Read-Host -Prompt "Enter SMTP IP"
Write-Host "The IP was: " $smtp_ip
$to_email='jlavado@recipeunlimited.com'
$subject='AD Group membership change alert'
$from_email='no-reply@recipeunlimited.com'
#$to_email='aaaadqh5i5tbgm7xg2kkmuukau@recipe-unlimited.slack.com'
Send-MailMessage -To $to_email -Subject $subject -Body $body -SmtpServer $smtp_ip -From $from_email -Port 25

