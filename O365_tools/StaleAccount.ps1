connect-MgGraph -Scopes "AuditLog.Read.All", "User.Read.All" -NoWelcome

# Define the cutoff date (30 days ago)
$cutoffDate = (Get-Date).AddDays(-30)

# Retrieve all users with sign-in activity
$users = Get-MgUser -Property "displayName,userPrincipalName,signInActivity,accountEnabled" -All | 
         Where-Object { 
            $_.AccountEnabled -eq $true -and 
            $_.SignInActivity.LastSignInDateTime -ne $null -and 
            $_.SignInActivity.LastSignInDateTime -lt $cutoffDate 
         }

# Output results
$users | Select-Object displayName, userPrincipalName, @{Name="LastSignIn"; Expression={$_.SignInActivity.LastSignInDateTime}} |
        Sort-Object -Property displayName | Export-Csv login_older_than_30days.csv -NoTypeInformation

Write-Output "`n`n" >> login_older_than_30days.csv
Write-Output "The number of users who haven't logged in for 30 days is: $($users.Count)" >> login_older_than_30days.csv