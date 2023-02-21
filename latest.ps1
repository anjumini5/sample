# Set the variables
$serverName = "YOUR_SQL_SERVER_NAME"
$databaseName = "YOUR_DATABASE_NAME"
$backupFolder = "C:\SQLBackups"
$daysToKeep = 14
$logFile = "C:\SQLBackupLog.txt"

# Function to write to the log file
Function Write-Log
{
    Param ([string]$logString)

    $timeStamp = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
    $logLine = "$timeStamp - $logString"
    Add-Content $logFile $logLine
}

# Function to backup the SQL database
Function Backup-SQLDatabase
{
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $backupFileName = "$databaseName" + "_" + "$timestamp" + ".bak"
    $backupFilePath = Join-Path $backupFolder $backupFileName

    $backupSql = "BACKUP DATABASE [$databaseName] TO DISK = '$backupFilePath'"

    $conn = New-Object System.Data.SqlClient.SqlConnection("Server=$serverName;Database=master;Integrated Security=True;")
    $cmd = New-Object System.Data.SqlClient.SqlCommand($backupSql, $conn)

    $conn.Open()
    $cmd.ExecuteNonQuery()
    $conn.Close()

    $logString = "Backup of database $databaseName completed at $timestamp."
    Write-Log $logString
}

# Function to delete old backups
Function Delete-OldBackups
{
    $cutOffDate = (Get-Date).AddDays(-$daysToKeep)

    $oldBackups = Get-ChildItem -Path $backupFolder -Filter *.bak | Where-Object { $_.LastWriteTime -lt $cutOffDate }

    if ($oldBackups.Count -gt 0)
    {
        $logString = "Deleting old backup files..."
        Write-Log $logString

        foreach ($oldBackup in $oldBackups)
        {
            $logString = "Deleting backup file: $($oldBackup.Name)"
            Write-Log $logString
            Remove-Item $oldBackup.FullName
        }

        $logString = "Old backup files deleted."
        Write-Log $logString
    }
    else
    {
        $logString = "No old backup files to delete."
        Write-Log $logString
    }
}

# Main function to call the backup and deletion functions
Function Main
{
    # Check if today is Tuesday or Friday
    if ((Get-Date).DayOfWeek -eq "Tuesday" -or (Get-Date).DayOfWeek -eq "Friday")
    {
        $logString = "Starting backup process..."
        Write-Log $logString

        # Call the backup function
        Backup-SQLDatabase

        # Call the delete function
        Delete-OldBackups

        $logString = "Backup process completed."
        Write-Log $logString
    }
    else
    {
        $logString = "Today is not Tuesday or Friday. Backup process skipped."
        Write-Log $logString
    }
}

# Call the main function
Main
