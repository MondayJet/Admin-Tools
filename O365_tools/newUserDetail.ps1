# Define variables
$TenantId = "<tenantId>"
$ClientId = "<clientID>"
####$ClientSecret = " " client secret should go into the preceding space
$UserEmail = "<sender_mail>"  # Sender's email

# Read parameters from CSV
$Users = Import-Csv -Path "C:\SCRIPTS\Users.csv"

# Authentication
$Body = @{
    grant_type    = "client_credentials"
    client_id     = $ClientId
    client_secret = $ClientSecret
    scope         = "https://graph.microsoft.com/.default"
}
$TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Method Post -Body $Body
$AccessToken = $TokenResponse.access_token

foreach ($User in $Users) {
    # Prepare personalized email body
    $EmailContent = @"
Dear $($User.'Display name'),

You are welcome to the ecosystem.
Kindly find your login details below:

Display Name: $($User.'Display name')
Username: $($User.Username)
Password: $($User.Password)

To log in, load https://m365.cloud.microsoft/?auth=2 on any browser of your choice and follow the prompt

Do not hesitate to mail me if you have any difficulty with signing in.

Best regards
"@

    $EmailBody = @{
        message = @{
            subject = "Your Login Credentials"
            body    = @{
                contentType = "Text"
                content     = $EmailContent
            }
            toRecipients = @(
                @{
                    emailAddress = @{
                        address = $User.Email
                    }
                }
            )
        }
    } | ConvertTo-Json -Depth 10

    # Send Email via Graph API
    $GraphUri = "https://graph.microsoft.com/v1.0/users/$($UserEmail)/sendMail"
    Invoke-RestMethod -Uri $GraphUri -Headers @{
        Authorization = "Bearer $AccessToken"
        "Content-Type" = "application/json"
    } -Method Post -Body $EmailBody

    Write-Output "Email Sent Successfully to $($User.Email)!"
}
