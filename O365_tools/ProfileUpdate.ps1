$csvPath = "C:\Scripts\JobTitles.csv"
$users = Import-Csv $csvPath

foreach ($user in $users) {
    try {
        Update-MgUser -UserId $user.UserPrincipalName -JobTitle $user.JobTitle
        Write-Host "Updated $($user.UserPrincipalName) to '$($user.JobTitle)'" -ForegroundColor Green
    } catch {
        Write-Host "Failed to update $($user.UserPrincipalName): $_" -ForegroundColor Red
    }
}