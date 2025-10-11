# Connect to Exchange Online (if not already connected)
#Connect-ExchangeOnline -UserPrincipalName youradmin@yourdomain.com

# Import the CSV file
$csvPath = "C:\SCRIPTS\members.csv"
$entries = Import-Csv -Path $csvPath

# Group entries by GroupEmail
$groupedEntries = $entries | Group-Object GroupEmail

# Loop through each group and add its members
foreach ($group in $groupedEntries) {
    $groupName = $group.Name
    $members = $group.Group

    Write-Host "`n📌 Processing group: $groupName" -ForegroundColor Cyan

    foreach ($entry in $members) {
        $email = $entry.EmailAddress

        try {
            Add-DistributionGroupMember -Identity $groupName -Member $email -ErrorAction Stop
            Write-Host "✅ Added $email to $groupName"
        } catch {
            Write-Host "❌ Failed to add ${email} to ${groupName}: $_" -ForegroundColor Red
        }
    }
}
