# Path to CSV file
$csvPath = "C:\SCRIPTS\Roles.csv"

# Import CSV
$users = Import-Csv $csvPath

# Ensure you are connected to Microsoft Graph
# Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All"

foreach ($user in $users) {
    try {
        # Update the user's job title
        Update-MgUser -UserId $user.UserPrincipalName -JobTitle $user.JobTitle

        Write-Host "Updated job title for $($user.UserPrincipalName) to '$($user.JobTitle)'" -ForegroundColor Green

        # If Manager field exists and is not empty, update the manager
        if ($user.Manager) {
            # Get the manager's user object
            $manager = Get-MgUser -UserId $user.Manager -ErrorAction Stop

            # Set the manager relationship
            Set-MgUserManagerByRef -UserId $user.UserPrincipalName -BodyParameter @{
                "@odata.id" = "https://graph.microsoft.com/v1.0/users/$($manager.Id)"
            }

            Write-Host "Set manager for $($user.UserPrincipalName) to $($user.Manager)" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "Failed to update $($user.UserPrincipalName): $_" -ForegroundColor Red
    }
}
