# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All, Group.ReadWrite.All"

# Connect to Exchange Online
Connect-ExchangeOnline -UserPrincipalName john.monday@splashers.tech

# Path to the CSV file
$csvPath = "C:\SCRIPTS\DEACTIVATED_USERS.csv"

# Import the CSV file and process each user
Import-Csv -Path $csvPath | ForEach-Object {
    $userPrincipalName = $_.UserPrincipalName

    # Get the user object using the Filter parameter
    $user = Get-MgUser -Filter "userPrincipalName eq '$userPrincipalName'"

    if ($user -ne $null) {
        # Block user sign-in
        Update-MgUser -UserId $user.Id -AccountEnabled:$false

        # Remove user from all groups
        $groups = Get-MgUserMemberOf -UserId $user.Id | Where-Object { $_.ODataType -eq "#microsoft.graph.group" }
        foreach ($group in $groups) {
            Remove-MgGroupMember -GroupId $group.Id -UserId $user.Id
        }

        # List and remove all licenses
        $assignedLicenses = $user.AssignedLicenses
        if ($assignedLicenses) {
            $assignedLicenses | ForEach-Object {
                $licenseDetails = Get-MgSubscribedSku -Filter "skuId eq '$($_.SkuId)'"
                Write-Output "Removing license: $($licenseDetails.SkuPartNumber) for user $userPrincipalName"
            }
            $licenseSkuIds = $assignedLicenses | ForEach-Object { $_.SkuId }
            Set-MgUserLicense -UserId $user.Id -RemoveLicenses $licenseSkuIds
        }

        # Check if the mailbox is already a shared mailbox
        $mailbox = Get-Mailbox -Identity $userPrincipalName
        if ($mailbox.RecipientTypeDetails -ne "SharedMailbox") {
            # Convert user mailbox to shared mailbox
            Set-Mailbox -Identity $userPrincipalName -Type Shared
        } else {
            Write-Output "Mailbox is already a shared mailbox: $userPrincipalName"
        }
    } else {
        Write-Output "User not found: $userPrincipalName"
    }
}