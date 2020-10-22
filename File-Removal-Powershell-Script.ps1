<#
.SYNOPSIS
This script deletes defined files from targeted folders.

.DESCRIPTION
This script deletes defined files from targeted folders. Target folders, file names and optional number of days files files must be
older then are written by user in "Data.csv" file. User can enter partial names of files in FileName column with a wildcard, for
example "*.dat". Script generates detailed log file, "Log.log", and report that is sent via email to system administrators.
In '.\Settings.cfg' file are parameters for mail settings, and options to turn on and off output writing, loging, and mail report
as the user requires them.

.NOTES
	Version:        2.1
	Author:         Zoran Jankov
    Creation Date:  07.07.2020.
    Last Update:    22.10.2020.
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Loading script settings and data
$Settings = Get-Content '.\Settings.cfg' | ConvertFrom-StringData
$Data = Import-Csv -Path '.\Data.csv' -Delimiter ';'

#File counters
$TotalSuccessfulRemovalsCounter = 0
$TotalFailedRemovalsCounter = 0
$TotalContentRemoved = 0

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Import-Module '.\Modules\Get-FormattedFileSize.psm1'
Import-Module '.\Modules\Remove-Files.psm1'
Import-Module '.\Modules\Send-EmailReport.psm1'
Import-Module '.\Modules\Write-Log.psm1'

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Log -Message $Settings.LogTitle
Write-Log -Message $Settings.LogSeparator

$Data | Remove-Files | ForEach-Object {
    $TotalContentRemoved += $_.FolderSpaceFreed
    $TotalSuccessfulRemovalsCounter += $_.FilesRemoved
    $TotalFailedRemovalsCounter += $_.FailedRemovals
}

if ($TotalFailedRemovalsCounter -gt 0) {
    $message = "Failed to delete " + $TotalFailedRemovalsCounter + " files"
    Write-Log -Message $message
}

if ($TotalSuccessfulRemovalsCounter -gt 0) {
    $SpaceFreed = Get-FormattedFileSize -Size $TotalContentRemoved

    $Message = "Successfully deleted " + $TotalSuccessfulRemovalsCounter + " files - removed " + $SpaceFreed
    Write-Log -Message $Message
}

if (($TotalSuccessfulRemovalsCounter -gt 0) -and ($TotalFailedRemovalsCounter -eq 0)) {
    $FinalMessage = "Successfully completed - File Deletion PowerShell Script"
}
elseif (($TotalSuccessfulRemovalsCounter -gt 0) -and $TotalFailedRemovalsCounter -gt 0) {
    $FinalMessage = "Successfully completed with some failed delitions - File Deletion PowerShell Script"
}
else {
    $FinalMessage = "Failed to delete any file - File Deletion PowerShell Script"
}

Write-Log -Message $Message
Write-Log -Message $Settings.LogSeparator

#Sends email with detailed report and deletes temporary "Report.log" file
Send-EmailReport -FinalMessage $FinalMessage