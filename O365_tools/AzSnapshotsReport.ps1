# Get all subscriptions available to your account
$subscriptions = Get-AzSubscription

# Loop through each subscription
foreach ($sub in $subscriptions) {
    Write-Host "Processing subscription: $($sub.Name) [$($sub.Id)]" -ForegroundColor Cyan
    
    # Set context to the current subscription
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    # Get snapshots for this subscription
    $snapshots = Get-AzSnapshot | Select-Object Name, DiskSizeGB, TimeCreated

    if ($snapshots) {
        Write-Host "Snapshots in $($sub.Name):" -ForegroundColor Green
        $snapshots | Format-Table -AutoSize
    } else {
        Write-Host "No snapshots found in $($sub.Name)" -ForegroundColor Yellow
    }
}
