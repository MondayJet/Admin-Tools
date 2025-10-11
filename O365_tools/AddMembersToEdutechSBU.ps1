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

# Loop through users and add if not already in group
foreach ($User in $Users) {
    $Email = $User.Email

    if ($ExistingMembers -contains $Email) {
        Write-Host "$Email is already a member of $GroupName. Skipping..." -ForegroundColor Yellow
    } else {
        Add-UnifiedGroupLinks -Identity $GroupName -Links $Email -LinkType Members
        Write-Host "Added $Email to $GroupName." -ForegroundColor Green
    }
    Get-UnifiedGroupLinks -Identity $GroupName -LinkType Members | Select-Object -ExpandProperty PrimarySmtpAddress
}

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false
