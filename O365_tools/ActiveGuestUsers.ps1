# Connect to Microsoft Graph without welcome message
Connect-MgGraph -Scopes "User.Read.All" -NoWelcome

# Fetch active guest users and sort by DisplayName
$GuestUser = Get-MgUser -Filter "accountEnabled eq true and userType eq 'Guest'" -All | 
    Select-Object DisplayName, UserPrincipalName | Sort-Object DisplayName

# Output guest user count with formatted date
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Output "The number of Guest Users as of $timestamp is $($GuestUser.Count)"

# Display guest user details
$GuestUser | Format-Table -AutoSize