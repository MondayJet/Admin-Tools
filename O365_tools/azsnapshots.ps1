$filepath = "C:\SCRIPTS\subscriptions.csv"

Import-Csv -Path $filepath | ForEach-Object {
$SubscriptionId = $_.SubscriptionId
set-Azcontext -subscriptionId $SubscriptionId 
Get-azsnapshot | select -Property Name, Timecreated,  DiskSizeGB
}
