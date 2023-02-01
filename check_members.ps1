<#
$groupMembers = foreach ($group in $groups) {
    Get-LocalGroupMember $group
}
Write-Output $groupMembers
#>
<# Write-Output 'Hello, World!' #>
$groups = @(
    'Administrators'
    'Remote Desktop Users'
)

foreach ($group in $groups) {
    $previousRunMemberships = $null
    if (Test-Path "C:\temp\MonitorAD\$group.csv") {
        Write-Output "File was there"
        Write-Output "$group.csv"
        $previousRunMemberships = Import-Csv -Path "C:\temp\MonitorAD\$group.csv"
    }
    $groupMembers = Get-LocalGroupMember $group
    $added = foreach ($member in $groupMembers) {
        if ($previousRunMemberships.SID -notcontains $member.SID) {
            $member
            Write-Output $member
            Write-Output 'Hello, World! - something was added'
        }
    }
    $removed = foreach ($member in $previousRunMemberships) {
        if ($groupMembers.SID -notcontains $member.SID) {
            $member
            Write-Output 'Hello, World! - something was removed'
        }
    }
   $groupMembers | Export-Csv -Path "C:\temp\monitorAD\$group.csv" -NoTypeInformation
}