### Define the cutoff date - 90 days ago from today
$cutoffDate = (Get-Date).AddDays(-90)

# Get all disabled users whose 'whenChanged' is on or before 90 days ago
Get-ADUser -Filter {Enabled -eq $false} -Properties whenChanged | Where-Object {
    $_.whenChanged -le $cutoffDate
} | Select-Object Name, SamAccountName, Enabled, whenChanged | Sort-Object whenChanged