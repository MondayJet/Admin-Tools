# Dictionary of subscription names and IDs
$subscriptions = @{
    "SubscriptionName1" = "SubscriptionId1"
    "SubscriptionName2" = "SubscriptionId2"
    "SubscriptionName3" = "SubscriptionId3"
    
}

# Loop through each subscription in the dictionary
foreach ($subscriptionName in $subscriptions.Keys) {
    $subscriptionID = $subscriptions[$subscriptionName]

    # Set the context to the current subscription
    Set-AzContext -Subscription $subscriptionID

    # Get the count of running VMs
    $RunningVms = (Get-AzVM -Status | Where-Object {$_.PowerState -eq 'VM running'} | Measure-Object).Count

    # Get the count of snapshots taken in the last day
    $Snapshots = (Get-AzSnapshot | Where-Object {$_.TimeCreated -gt (Get-Date).AddDays(-1)} | Measure-Object).Count

    # Output the results for the current subscription
    # Write-Output "Subscription Name: $subscriptionName"
    # Write-Output "Subscription ID: $subscriptionID"
    Write-Output "$subscriptionName running Azure VMs as at $(Get-Date) = $RunningVms"
    Write-Output "$subscriptionName Snapshots taken on $(Get-Date) = $Snapshots"
    Write-Output " "
} 
