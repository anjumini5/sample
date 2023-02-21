# Set the variables
$serverName = "LAPTOP-5GHNVJD9\SQLEXPRESS"
$databaseName = "test"
$backupFolder = "D:\Backups"
$daysToKeep = 14

# Function to backup the SQL database
Function Backup-SQLDatabase

{
    $timestamp = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
    $backupFileName = "$databaseName" + "_" + "$timestamp" + ".bak"
    $backupFilePath = Join-Path $backupFolder $backupFileName

    $backupSql = "BACKUP DATABASE [$databaseName] TO DISK = '$backupFilePath'"

    $conn = New-Object System.Data.SqlClient.SqlConnection("Server=$serverName;Database=master;Integrated Security=True;")
    $cmd = New-Object System.Data.SqlClient.SqlCommand($backupSql, $conn)

    $conn.Open()
    $cmd.ExecuteNonQuery()
    $conn.Close()

    Write-Host "Backup of database $databaseName completed at $timestamp."
}

# Function to delete old backups
Function Delete-OldBackups
{
    $cutOffDate = (Get-Date).AddDays(-$daysToKeep)

    Get-ChildItem -Path $backupFolder -Filter *.bak | Where-Object { $_.LastWriteTime -lt $cutOffDate } | Remove-Item
}

# Main function to call the backup and deletion functions
Function Main
{
    # Check if today is Tuesday or Friday
    if ((Get-Date).DayOfWeek -eq "Tuesday" -or (Get-Date).DayOfWeek -eq "Friday")
    {
        # Call the backup function
        Backup-SQLDatabase

        # Call the delete function
        Delete-OldBackups
    }
}

# Call the main function
Main
