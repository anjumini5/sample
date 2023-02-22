# Set variables for the SQL server, databases to backup, backup path, retention period, and log path
$SqlServer = "LAPTOP-5GHNVJD9\SQLEXPRESS"
$BackupPath = "D:\Backups"
$Databases = "test"
$RetentionPeriod = 14
$LogPath = "D:\Backups\Backuplogs"

# Get the current date and time
$Now = Get-Date

# Create the log directory if it doesn't exist
if (!(Test-Path $LogPath)) {
    New-Item -ItemType Directory -Path $LogPath | Out-Null
}

# Set the log file name and path
$LogFileName = "BackupLog-$($Now.ToString('yyyyMMdd')).txt"
$LogFilePath = Join-Path $LogPath $LogFileName

# Create the log file if it doesn't exist
if (!(Test-Path $LogFilePath)) {
    New-Item -ItemType File -Path $LogFilePath | Out-Null
}

# Loop through the databases and create a backup for each one
foreach ($Database in $Databases) {
    # Set the backup file name
    $BackupFileName = "$Database-$($Now.ToString('yyyyMMdd')).bak"
    $BackupFilePath = Join-Path $BackupPath $BackupFileName
    
    # Log the start of the backup
    Write-Output "Starting backup of $Database on $($Now.ToString('yyyy-MM-dd HH:mm:ss'))" | Out-File -FilePath $LogFilePath -Append
    
    # Backup the database
    Backup-SqlDatabase -ServerInstance $SqlServer -Database $Database -BackupFile $BackupFilePath
    
    # Get the date from two weeks ago
    $OldDate = $Now.AddDays(-$RetentionPeriod)
    
    # Delete any backup files older than the retention period
    Get-ChildItem $BackupPath -Filter "$Database-*.bak" | Where-Object {$_.LastWriteTime -lt $OldDate} | Remove-Item


# Delete any log files older than the retention period
Get-ChildItem $LogPath -Filter "BackupLog-*.txt" | Where-Object {$_.LastWriteTime -lt $OldDate} | Remove-Item

    
    # Log the end of the backup
    Write-Output "Backup of $Database complete on $($Now.ToString('yyyy-MM-dd HH:mm:ss'))" | Out-File -FilePath $LogFilePath -Append
}
