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
<#
write-Output ""
write-Output "The following Users were Added:"
Write-Output $added
write-Output ""
write-Output "The following Useres were Removed:"
Write-Output $removed
#>
$body = "The following Users were Added:`n$added`nThe following Useres were Removed:`n$removed"

Write-Output $body
<#
Send-MailMessage -To 'jlavado@recipeunlimited.com' -Subject 'AD Group membership change alert' -Body $body -SmtpServer '1.1.1.1' -From 'no-reply@recipeunlimited.com' -Port 25
#>
Write-Host "Welcome to demo of powershell prompt input" -ForegroundColor Green
$name= Read-Host -Prompt "Enter your name"
$age= Read-Host -Prompt "Enter your age"
$city= Read-Host -Prompt "Enter your city"
Write-Host "The entered name is" $name -ForegroundColor Green
Write-Host "The entered age is" $age -ForegroundColor Green
Write-Host "The entered city is" $city -ForegroundColor Green
