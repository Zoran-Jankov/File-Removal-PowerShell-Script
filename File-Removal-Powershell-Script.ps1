<#
.SYNOPSIS
This script removes defined files from targeted folders.

.DESCRIPTION
This script removes defined files from targeted folders. It is meant to be used by System Administrators, because it has many
options and settings that can be configured to remove files in multiple and various ways. All data regarding file removal, target
folders, file names, optional number of days files must be older then to be removed, if files in subfolders should be removed,
and if files should be force removed, are written by user in `Data.csv` file. User can enter partial names of files in `FileName`
column with a wildcard character, for example `*.dat` or `Backup*`. Script generates detailed log file, and report that is sent
via email. In `Settings.cfg` file parameters are stored for email settings, and options to turn on or off console writing, loging,
and email report as the user requires them.

.NOTES
Version:        1.2
Author:         Zoran Jankov
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Loading script data and settings
$Data = Import-Csv -Path "$PSScriptRoot\Data.csv" -Delimiter ';'
$Settings = Get-Content -Path "$PSScriptRoot\Settings.cfg" | ConvertFrom-StringData

#File counters
$TotalSuccessfulRemovalsCounter = 0
$TotalFailedRemovalsCounter = 0
$TotalContentRemoved = 0

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Import-Module "$PSScriptRoot\Modules\Get-FormattedFileSize.psm1"
Import-Module "$PSScriptRoot\Modules\Remove-Files.psm1"
Import-Module "$PSScriptRoot\Modules\Send-EmailReport.psm1"
Import-Module "$PSScriptRoot\Modules\Write-Log.psm1"

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Log -Message $Settings.LogTitle -NoTimestamp
Write-Log -Message $Settings.LogSeparator -NoTimestamp

#Formating data to fit expected parameters in `Remove-Files` function
$Data | ForEach-Object -Process {
    if ($_.OlderThen -match "^\d+$") {
        $_.OlderThen = [int]$_.OlderThen
    }
    else {
        $_.OlderThen = [int]180
    }

    if ($_.Recurse -eq "true") {
        $_.Recurse = $true
    }
    else {
        $_.Recurse = $false
    }

    if ($_.Force -eq "true") {
        $_.Force = $true
    }
    else {
        $_.Force = $false
    }
}

$Data | Remove-Files | ForEach-Object {
    $TotalContentRemoved += $_.FolderSpaceFreed
    $TotalSuccessfulRemovalsCounter += $_.FilesRemoved
    $TotalFailedRemovalsCounter += $_.FailedRemovals
}

if ($TotalSuccessfulRemovalsCounter -gt 0) {
    $SpaceFreed = Get-FormattedFileSize -Size $TotalContentRemoved
    $Message = "Successfully removed " + $TotalSuccessfulRemovalsCounter + " files - removed " + $SpaceFreed
    Write-Log -Message $Message
}

if ($TotalFailedRemovalsCounter -gt 0) {
    $Message = "Failed to remove " + $TotalFailedRemovalsCounter + " files"
    Write-Log -Message $Message
}

if (($TotalSuccessfulRemovalsCounter -gt 0) -and ($TotalFailedRemovalsCounter -eq 0)) {
    $FinalMessage = "Successfully completed - File Removal PowerShell Script"
}
elseif (($TotalSuccessfulRemovalsCounter -gt 0) -and $TotalFailedRemovalsCounter -gt 0) {
    $FinalMessage = "Successfully completed with some failed delitions - File Removal PowerShell Script"
}
else {
    $FinalMessage = "Failed to remove any file - File Removal PowerShell Script"
}

Write-Log -Message $FinalMessage
Write-Log -Message $Settings.LogSeparator -NoTimestamp

#Sends email with detailed report and removes temporary "Report.log" file
Send-EmailReport -Settings $Settings -FinalMessage $FinalMessage