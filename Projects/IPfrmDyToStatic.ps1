Set-AzContext -Subscription <SubscriptionName>

$IPs = Get-Get-AzPublicIpAddress

$IPs | foreach {$publicIP = Get-AzPublicIpAddress -ResourceGroupName $PSItem.ResourceGroupName -Name $PSItem.Name

### Modify the resourcegroupname to specific, if you are only concerned with one resource group

$publicIP.PublicIPAllocationMethod = "Static"
Set-AzPublicIpAddress -PublicIpAddress $publicIP

}

