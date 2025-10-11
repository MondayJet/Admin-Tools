# Function to get domain and license SKU

function Get-DomainAndLicenseSku {
    param (
        [string]$Domain,
        [string]$LicenseSku
    )
    return @{
        Domain = $Domain
        LicenseSku = $LicenseSku
    }
}

# Function to import users from CSV
function Import-Users {
    param (
        [string]$FilePath
    )
    return Import-Csv -Path $FilePath
}

# Function to create user object
function Create-UserObject {
    param (
        [string]$FirstName,
        [string]$LastName,
        [string]$Domain
    )
    $UPN = "$FirstName.$LastName@$Domain".ToLower()
    return @{
        accountEnabled = $true
        displayName = "$FirstName $LastName"
        mailNickname = "$FirstName.$LastName"
        userPrincipalName = $UPN
        passwordProfile = @{
            forceChangePasswordNextSignIn = $true
            password = "Password@123"  # Set a temporary password
        }
        givenName = $FirstName
        surname = $LastName
        usageLocation = "NG"  # Set the correct country code
    }
}

# Function to assign license
function Assign-License {
    param (
        [string]$UserId,
        [string]$LicenseSku
    )
    $LicenseAssignment = @{
        addLicenses = @(@{skuId = (Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq $LicenseSku }).SkuId })
        removeLicenses = @()
    }
    Set-MgUserLicense -UserId $UserId -BodyParameter $LicenseAssignment
}

# Function to check if user exists
function User-Exists {
    param (
        [string]$UPN
    )
    try {
        $user = Get-MgUser -UserPrincipalName $UPN -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Main script
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All" -NoWelcome
# Define domain and license SKU
$Config = Get-DomainAndLicenseSku -Domain "advancly.com" -LicenseSku "cfd2bb3b966d:O365_BUSINESS_PREMIUM"

# Import users from CSV
$Users = Import-Users -FilePath "C:\SCRIPTS\Advancly-Standard-User.csv"

foreach ($User in $Users) {
    # Generate UPN
    $UPN = "$($User.FirstName).$($User.LastName)@$Config.Domain".ToLower()

    # Check if user exists
    if (User-Exists -UPN $UPN) {
        Write-Host "User $UPN already exists!" -ForegroundColor Yellow
    } else {
        # Create user object
        $newUser = Create-UserObject -FirstName $User.FirstName -LastName $User.LastName -Domain $Config.Domain -Manager $User.Manager`
         -Department $User.Department -Jobtitle $User.Role -PhoneNumber $User.Mobile -UserType $User.Usertype -CompanyName $User.Company`
          -EmployeeType $User.EmployeeType -OfficeLocation $user.OfficeLocation

        # Create the user
        $CreatedUser = New-MgUser @newUser

        # Get user ID
        $UserId = $CreatedUser.Id

        # Assign license
        Assign-License -UserId $UserId -LicenseSku $Config.LicenseSku

        Write-Host "User $UPN created and assigned license successfully!" -ForegroundColor Green
    }
}