#### Check users status on AD
Get-ADUser -Filter {Enabled -eq $false} | Format- Name, SamAccountName, DistinguishedName
Get-ADUser -Filter * |Where-Object {$_.Enabled -eq $false} | ft
Get-ADUser -Filter {Enabled -eq $false} | Select-Object SamAccountName, Name, Enabled | Export-Csv -Path "DisabledUsers.csv" -NoTypeInformation
Get-ADUser -Filter {Enabled -eq $true}

#### Disable Use on AD
Get-ADuser -filter {SamAccountName -eq "ikeoluwa.kolawole"} | Disable-ADAccount

## Everything about SES status
aws ses get-identity-verification-attributes --identities "support@trips.ng" --profile Tranzitech #provides specific details on the specified email
aws ses list-identities --identity-type Domain --profile Tranzitech ## shows verified domains
aws ses list-identities --identity-type EmailAddress --profile Tranzitech # shows verified email addresses
##NB: These are bash script but runs on powershell provided it has been configured to work with aws cli

##Last server reboot
 Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object LastBootUpTime

 #################<<<< SHUTDOWN TROUBLESHOOTING >>>>#############################
#<< Open Event Viewer (eventvwr.msc).
#<< Go to Windows Logs → System.
#<< Click Filter Current Log (on the right pane).
#<< Set Event IDs: 6005, 6006, 6008, 1074, 1076
#<< 6005 = Event Log started (indicates a reboot).
#<< 6006 = Event Log stopped (shutdown).
#<< 6008 = Unexpected shutdown (crash).
#<< 1074 = Proper shutdown or restart.
#<< 1076 = System recovered from an improper shutdown.
#Click OK to filter and check timestamps 

####<<< NO BEFORE RESOLUTION STEPS >>>>>>
# 1. lOG-in AS Admin
   ## From your icon >> account settings >> Account Integration >> Authorize Naa-SSO for Graph API

Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object LastBootUpTime

####List member of a Group
Get-MgGroupMember -GroupId 76ebfe44-4860-4a4b-8d5e-9f31ccfa0442 | ForEach-Object {
Get-MgUser -UserId $_.Id | Select-Object -Property DisplayName -Autosize }

## select user with specific domain
Get-MgUser -All | where { $_.Mail -like "*@splashers.tech"}

### >>>>>>>>>>>>>>> All Disabled Users across the group <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
Get-MgUser -Filter "accountEnabled eq false" -All

### >>>>>>>>>>>> Active Users Across the group <<<<<<<<<<<<<<<<<<<<<<<<<<<<
Get-MgUser -Filter "accountEnabled eq tru" -All

### >>>>>>>>>>>> Active Users in a specific domain <<<<<<<<<<<<<<<<<<<<<<<<
Get-MgUser -Filter "accountEnabled eq true" -All | Where-Object { $_.UserPrincipalName -like "*#EXT#*"} 
Get-MgUser -Filter "accountEnabled eq true" -All | Where-Object { $_.UserPrincipalName -like "*@splashers.tech"}
Get-MgUser -Filter "accountEnabled eq true" -All | Where-Object { $_.UserPrincipalName -like "*@splashers.tech"} | Select -Property DisplayName, UserPrincipalName | clip

### >>>>> Disabled users under specific domain <<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Get-MgUser -Filter "accountEnabled eq false" -All | Where-Object { $_.UserPrincipalName -like "*@splashers.tech"}

##>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> RESET ADUSER PASSWORD <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Set-ADAccountPassword -Identity username -NewPassword (ConvertTo-SecureString "NewP@ssw0rd!" -AsPlainText -Force) -Reset




## >>>>>>>>>>>>>>>>>>>> GRANT ACCESS TO SHARED MAIL BOX <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
Add-MailboxPermission -Identity "SharedMailbox@yourdomain.com" -User "User@yourdomain.com" -AccessRights FullAccess -InheritanceType All
Add-RecipientPermission -Identity "SharedMailbox@yourdomain.com" -Trustee "User@yourdomain.com" -AccessRights SendAs

### >>>>>>>>>>>>>>>>>>>>>>>>>>>> USERS CREATED WITH CERTAIN TIME INTERVAL <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
Get-MgUser -Filter "createdDateTime ge 2024-10-01T00:00:00Z" | where {$_.UserPrincipalName -like "*@advancly.com"}

### >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ACCOUNT DEACTIVATED IN THE LAST 30 DAYS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$DaysBack = (Get-Date).AddDays(-30)  ## NB: Default Retention perion is 30 days
 
Get-MgAuditLogDirectoryAudit | 
    Where-Object { 
        $_.ActivityDisplayName -eq "Disable account" -and 
        $_.ActivityDateTime -ge $DaysBack
    } | 
    Select-Object ActivityDateTime, @{Name="UserPrincipalName"; Expression={ $_.TargetResources[0].UserPrincipalName }}


###>>>>>>>>>>>>>>>>>>>>> Number of Members in a Group <<<<<<<<<<<<<<<<<<<<<<<<<<<<
import-Module exchangeonlineManagement
connect-exchangeOnline -UserPrincipalName john.monday@splashers.tech
Get-UnifiedGroupLinks -Identity "GroupName" -LinkType Members | Select-Object -ExpandProperty primarySmtpAddress | Measure-Object



$subscriptions = Get-AzSubscription

foreach ($subscription in $subscriptions) {
    Set-AzContext -SubscriptionId $subscription.SubscriptionId

    Write-Output $subscription

    Get-AzRoleAssignment |
        Select-Object -Property DisplayName, RoleDefinitionName, Scope, ObjectType |
        Export-Csv -Path "User_roles.csv" -NoTypeInformation -Append

        Write-Output " "
        Write-Output " "

}

################### SPOOL ROLES AND MEMBERS ###########################
$roleList = @()
$allRoles = Get-MgDirectoryRole

foreach ($role in $allRoles) {
    $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id

    foreach ($member in $members) {
        $roleList += [PSCustomObject]@{
            RoleName     = $role.DisplayName
            RoleId       = $role.Id
            MemberId     = $member.Id
            MemberName   = $member.AdditionalProperties.displayName
            MemberType   = $member.AdditionalProperties.'@odata.type'
        }
    }
}

$roleList | Export-Csv -Path "RoleMembers.csv" -NoTypeInformation



###### Add members to respective Group ####################################
# Connect to Exchange Online (if not already connected)
#Connect-ExchangeOnline -UserPrincipalName youradmin@yourdomain.com

# Import the CSV file
$csvPath = "C:\SCRIPTS\members.csv"
$entries = Import-Csv -Path $csvPath

# Group entries by GroupEmail
$groupedEntries = $entries | Group-Object GroupEmail

# Loop through each group and add its members
foreach ($group in $groupedEntries) {
    $groupName = $group.Name
    $members = $group.Group

    Write-Host "`n📌 Processing group: $groupName" -ForegroundColor Cyan

    foreach ($entry in $members) {
        $email = $entry.EmailAddress

        try {
            Add-DistributionGroupMember -Identity $groupName -Member $email -ErrorAction Stop
            Write-Host "✅ Added $email to $groupName"
        } catch {
            Write-Host "❌ Failed to add ${email} to ${groupName}: $_" -ForegroundColor Red
        }
    }
}


######## MICROSOFT 365 GROUP PERMISSIONS ##############
#1  SET RESTRICTION ON WHO CAN SEND MAIL TO A MICROSOFT 365 GROUP ######
Set-UnifiedGroup -Identity "AllStaff" -RequireSenderAuthenticationEnabled $true
#2 GRANTING PERMISSION TO USER #########
Set-UnifiedGroup -Identity "AllStaff" -AcceptMessagesOnlyFrom @{Add="user@domain.com"}
#LIST ACCOUNTS WITH PERMISION TO SEND MAIL TO A 365 GROUP ###########
(Get-UnifiedGroup -Identity "AllStaff").AcceptMessagesOnlyFrom
 (Get-UnifiedGroup -Identity "AllStaff").AcceptMessagesOnlyFromSendersOrMembers

 ######## Mail-enabled/Distribution List GROUP PERMISSIONS ############## 

 (Get-DistributionGroup -Identity "Human Resource Internship").AcceptMessagesOnlyFrom
 (Get-DistributionGroup -Identity "Human Resource Internship").cceptMessagesOnlyFromSendersOrMembers
 Set-DistributionGroup -Identity "Human Resource Internship" -RequireSenderAuthenticationEnabled $true
 Set-DistributionGroup -Identity "Human Resource Internship" -AcceptMessagesOnlyFrom @{Add="user@domain.com"}

 ##############MAILBOX ARCHIVING AND AUTOEXPANDING ARCHIVE #############################
 Get-Mailbox -Identity support@trips.ng | Format-List ArchiveStatus,ArchiveState,AutoExpandingArchiveEnabled
 Get-Mailbox support@trips.ng | FL Archive*Quota, AutoExpandingArchiveEnabled
 Get-Mailbox support@trips.ng | FL RetentionPolicy
 ##### Enable ARchiving ########
 Enable-Mailbox -Identity "user@domain.com" -Archive

Get-RetentionPolicy | Select Name #### RETENTION POLICIES ACROSS THE TENANT
Get-RetentionPolicy -Identity "Archive for Larger Mailbox Users (1 year archive)" | Select-Object -ExpandProperty RetentionPolicyTagLinks ### PROPERTIES
#### ATTACH POLICY
Set-Mailbox -Identity support@trips.ng -RetentionPolicy "Archive for Larger Mailbox Users (1 year archive)" 
get-Mailbox support@trips.ng | FL RetentionPolicy ###cONFIRM SUCCESS OF OPERATION

#### IMMediate processing of Policy #########
Start-ManagedFolderAssistant -Identity "user@domain.com"




################### PURGE MAIL FROM MAILBOX ########################################################
Connect-ExchangeOnline -UserPrincipalName john.monday@splashers.tech
Connect-IPPSSession
#### search a particular time window
New-ComplianceSearch -Name "PurgeInbox" `
  -ExchangeLocation "advancers@advancly.com" `
  -ContentMatchQuery '(Subject:"Public Holiday Notification")'

Start-ComplianceSearch -Identity "PurgeInbox"

###### Purge Multiple usermail boxes ##########
# Create the compliance search across multiple mailboxes
New-ComplianceSearch -Name "PurgeInbox" `
  -ExchangeLocation "bukola.olokesusi@advancly.com","charles.okpokwu@advancly.com","ayotomiwa.idowu@advancly.com" `
  -ContentMatchQuery '(Subject:"Rate Approval Request- DLM")'

# Start the compliance search
Start-ComplianceSearch -Identity "PurgeInbox"

# Create a purge action for the search
New-ComplianceSearchAction -SearchName "PurgeInbox" -Purge -PurgeType HardDelete


### get-search status
Get-ComplianceSearch -Identity "PurgeInbox" | Format-List Name,Status,Items,Errors
#### Purge #######

New-ComplianceSearchAction -SearchName "PurgeInbox" -Purge -PurgeType HardDelete

############## List mails in a mailbox ###############################
## NB: You need the following permissions ################################

### User.ReadWrite.All, email, Mail.ReadWrite; Mail.ReadWrite.Shared ####################
### get it by running  ...Connect-MgGraph -Scopes "Mail.ReadWrite Mail.ReadWrite.Shared"
$user = "<target mailbox>"
PS C:\> Get-MgUserMailFolderMessage -UserId $user -MailFolderId Inbox -Top 5 |
>>     Select-Object Subject, ReceivedDateTime, Id
### the id returned is always truncated, so you solve that by piping into == out-GridView as below
 Get-MgUserMailFolderMessage -UserId $user -MailFolderId Inbox -Top 5 |
>>     Select-Object Subject, ReceivedDateTime, Id | Out-GridView



##### Azure snapshot Reporting #######

# Get all subscriptions you have access to
$subscriptions = Get-AzSubscription

# Collect all snapshots across subscriptions
$allSnapshots = foreach ($sub in $subscriptions) {
    Set-AzContext -SubscriptionId $sub.Id | Out-Null
    Get-AzSnapshot | Select-Object @{Name="SubscriptionName";Expression={$sub.Name}},
                                      Name,
                                      DiskSizeGB,
                                      TimeCreated
}

# Display all snapshots
$allSnapshots


