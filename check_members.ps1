$groups = @(
    'Administrators'
    'Remote Desktop Users'
)
$groupMembers = foreach ($group in $groups) {
    Get-LocalGroupMember $group
}

Write-Output $groupMembers