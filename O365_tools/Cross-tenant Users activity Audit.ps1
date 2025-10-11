# ============================
# Export Unified Audit Logs to a User-Friendly CSV
# ============================

# 1. Run Search-UnifiedAuditLog to pull audit records from the last 24 hours.
#    -StartDate: Current time minus 1 day (24 hours ago).
#    -EndDate: Current time (now).
#    -ResultSize: Limits the number of results (max 5000 in one call).
$logs = Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-1) -EndDate (Get-Date) -ResultSize 5000

# 2. Process each audit log entry.
#    - $_ represents each record in $logs.
#    - AuditData is JSON; ConvertFrom-Json makes it structured so fields can be extracted.
$parsed = $logs | ForEach-Object {
    # Parse the AuditData JSON field into a PowerShell object.
    $data = $_.AuditData | ConvertFrom-Json

    # Build a custom object with only the fields we care about.
    [PSCustomObject]@{
        # Date/time of the event (converted from UTC to local time).
        Date       = $_.CreationDate.ToLocalTime()

        # The user who performed the action.
        User       = $data.UserId

        # The workload/service where the action occurred (e.g., SharePoint, Exchange, Teams).
        Workload   = $data.Workload
        
        # The numeric record type for the event (e.g., 2 = ExchangeMailbox, 6 = SharePointFileOperation).
        RecordType = $_.RecordType

        # The action that was performed (e.g., FileAccessed, UserLoggedIn).
        Action     = $data.Operation

        # Whether the action succeeded or failed.
        Status     = $data.ResultStatus

        # The file, folder, or object affected by the action (if applicable).
        File       = $data.ObjectId

        # The IP address from which the action originated.
        IPAddress  = $data.ClientIP

        
    }
}

# 3. Export the parsed/cleaned data to a CSV file.
#    -NoTypeInformation: Removes unnecessary type info from the CSV header.
#    -Encoding UTF8: Ensures compatibility with Excel and other tools.
$parsed | Export-Csv "C:\AuditLogs\CleanAudit.csv" -NoTypeInformation -Encoding UTF8

# ============================
# End of Script
# ============================

### Pagination to return output in batches

$session = [guid]::NewGuid().ToString()

# First batch (up to 5000)
Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-1) -EndDate (Get-Date) -ResultSize 5000 -SessionId $session -SessionCommand ReturnLargeSet

# Next batch
Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-1) -EndDate (Get-Date) -ResultSize 5000 -SessionId $session -SessionCommand ReturnLargeSet


####### You can also limit output bu specifying the following
