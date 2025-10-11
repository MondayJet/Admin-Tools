# Path to CSV file containing a column named "UserPrincipalName"
$csvPath = "C:\SCRIPTS\UserLicenceAudit.csv"

# Import user list from CSV
$users = Import-Csv -Path $csvPath

# Get all available SKUs in the tenant for mapping
$allSkus = Get-MgSubscribedSku

# Loop through each user in CSV
$results = foreach ($u in $users) {
    try {
        # Get user from Microsoft Graph
        $mgUser = Get-MgUser -UserId $u.UserPrincipalName -Property AssignedLicenses

        # If no licenses assigned
        if (-not $mgUser.AssignedLicenses) {
            [PSCustomObject]@{
                UserPrincipalName = $u.UserPrincipalName
                LicenseName       = "No licenses assigned"
                SkuId             = $null
            }
            continue
        }

        # Map license SkuIds to friendly names
        foreach ($lic in $mgUser.AssignedLicenses) {
            $sku = $allSkus | Where-Object { $_.SkuId -eq $lic.SkuId }
            [PSCustomObject]@{
                UserPrincipalName = $u.UserPrincipalName
                LicenseName       = $sku.SkuPartNumber
                SkuId             = $lic.SkuId
            }
        }
    }
    catch {
        Write-Warning "Failed to get licenses for $($u.UserPrincipalName): $_"
    }
}

# Output to screen
#$results | Format-Table -AutoSize
$results | Export-Csv -Path "AuditResult.csv" -NoTypeInformation

