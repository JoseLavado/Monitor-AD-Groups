$groups = @(
    'Administrators'
)
$groupMembers = Get-LocalGroupMember $group

foreach ($member in $groupMembers) {
    Write-Output "Here are the SIDs"
    Write-Output $member.Name $member.SID.Value
}
  