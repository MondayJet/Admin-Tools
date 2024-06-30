# Define the tag to add
$tagName = "Backup"
$tagValue = "FES"

# Get all VMs in the subscription
$vms = Get-AzVM -Status

foreach ($vm in $vms) {
    # Get the tags of the VM
    $vmTags = $vm.Tags

    # Check if the VM has no tags or the specific tag is not set
    if ($vmTags -eq $null -or -not $vmTags.ContainsKey($tagName)) {
        Write-Output "Tagging VM: $($vm.Name) in resource group: $($vm.ResourceGroupName)"

        # Add the tag to the VM
        $vmTags[$tagName] = $tagValue
        Set-AzResource -ResourceId $vm.Id -Tag $vmTags -Force
    }
}
