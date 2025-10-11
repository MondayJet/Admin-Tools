# Import Exchange Online module
Import-Module ExchangeOnlineManagement

# Connect to Exchange Online
Connect-ExchangeOnline -UserPrincipalName john.monday@splashers.tech
# Define Office 365 Group Name
$GroupName = "everyone@edutech.global"

# Import users from CSV
$Users = Import-Csv -Path "C:\SCRIPTS\EDUTECH_MEMBERS.csv"

# Get current members of the group
$ExistingMembers = Get-UnifiedGroupLinks -Identity $GroupName -LinkType Members | Select-Object -ExpandProperty PrimarySmtpAddress

# Loop through users and remove if they are in the group
foreach ($User in $Users) {
    $Email = $User.Exit

    if ($ExistingMembers -contains $Email) {
        Remove-UnifiedGroupLinks -Identity $GroupName -Links $Email -LinkType Members
        Write-Host "Removed $Email from $GroupName." -ForegroundColor Green
    } else {
        Write-Host "$Email is not a member of $GroupName. Skipping..." -ForegroundColor Yellow
    }
}

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false
