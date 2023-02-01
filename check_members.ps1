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
write-Output ""
write-Output "The following Users were Added:"
Write-Output $added
write-Output ""
write-Output "The following Useres were Removed:"
Write-Output $removed
