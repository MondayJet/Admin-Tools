Connect-MgGraph -Scopes "User.Read.All" -NoWelcome

$ActiveUsers = Get-MgUser -Filter "accountEnabled eq true" -All
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Output "The number of Active Users as of $timestamp is $($ActiveUsers.Count)"
Write-Output " "
Write-Output " "
$ActiveUsers | sort DisplayName

