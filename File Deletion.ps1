<#
.SYNOPSIS
This script deletes defined files from targeted folders.

.DESCRIPTION
This script deletes defined files from targeted folders. File names are written by user in '.\File Names.txt' file, and target
folders are written by user in '.\Target Folders.txt' file. User can enter partial names of files in '.\File Names.txt' for example
"*.dat". Script generates detailed log file, '.\File Deletion Log.log', and report that is sent via email to system administrators.

.NOTES
	Version:        1.2
	Author:         Zoran Jankov
	Creation Date:  07.07.2020.
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set error action to silently continue
$ErrorActionPreference = "SilentlyContinue"

#File counters
$global:totalSuccessfulDeletionsCounter = 0
$global:totalFailedDeletionsCounter = 0
$global:totalDeletedContent = 0

#Defining log files
$logfile = '.\File Deletion Log.log'
New-Item -Path '.\Report.log' -ItemType File
$report = '.\Report.log'

#Load script settings
$settings = Get-Content '.\Settings.cfg' | Select-Object | ConvertFrom-StringData

#Loading files for deletion
$fileNames = Get-Content -Path '.\File Names.txt'

#Loading target folders for file deletion
$folderPaths = Get-Content -Path '.\Target Folders.txt'

#Defining log title
$logTitle = "=============================== File Deletion PowerShell Script Log ================================"

#Defining log separator
$logSeparator = "===================================================================================================="

#-----------------------------------------------------------[Functions]------------------------------------------------------------

<#
.SYNOPSIS
Writes a log entry

.DESCRIPTION
Creates a log entry with timestamp and message passed thru a parameter $Message, and saves the log entry to log file
".\File Deletion Log.log". Timestamp is not written if $Message parameter is defined $logSeparator or a $logTitle.

.PARAMETER Message
String value to be writen in the log file alongside timestamp

.EXAMPLE
Write-Log -Message "Successfully deleted"

.NOTES
Format of the timestamp is "yyyy.MM.dd. HH:mm:ss:fff" and this function adds " - " after timestamp and before the main message.
#>
function Write-Log
{
    param([String]$Message)

	if(($Message -eq $logSeparator) -or ($Message -eq $logTitle))
	{
		Add-content -Path $logfile -Value $Message
        Add-content -Path $report -Value $Message
        if($settings.WRITE_OUTPUT -eq "true")
        {
            Write-Output - $Message
        }
		
	}
	else
	{
		$timestamp = Get-Date -Format "yyyy.MM.dd. HH:mm:ss:fff"
    	$logEntry = $timestamp + " - " + $Message
		Add-content -Path $logfile -Value $logEntry
		Add-content -Path $report -Value $logEntry
        if($settings.WRITE_OUTPUT -eq "true")
        {
            Write-Output - $Message
        }
	}
}

<#
.SYNOPSIS
Sends a Report.log file to defined email address

.DESCRIPTION
This function sends a Report.log file as an attachment to defined email address
#>
function Send-Report
{
    param([string]$FinalMessage)

    if($settings.SEND_REPORT -eq "true")
    {
        $body = $settings.BODY + "`n" + $FinalMessage
        Send-MailMessage -SmtpServer $settings.SMTP `
                         -Port $settings.PORT `
                         -To $settings.RECEIVER `
                         -From $settings.SENDER `
                         -Subject $settings.SUBJECT `
                         -Body $body `
                         -Attachments $report
    }

	Remove-Item -Path $report
}

function Format-FileSize
{
    param($Size)

    If($Size -gt 1TB)
    {
        $stringValue = [string]::Format("{0:0.00} TB", $Size / 1TB)
    }
    elseIf($Size -gt 1GB)
    {
        $stringValue = [string]::Format("{0:0.00} GB", $Size / 1GB)
    }
    elseIf($Size -gt 1MB)
    {
        $stringValue = [string]::Format("{0:0.00} MB", $Size / 1MB)
    }
    elseIf($Size -gt 1KB)
    {
        $stringValue = [string]::Format("{0:0.00} kB", $Size / 1KB)
    }
    elseIf($Size -gt 0)
    {
        $stringValue = [string]::Format("{0:0.00} B", $Size)
    }
    else
    {
        $stringValue = ""
    }

    return $stringValue
}

function Remove-FilesInFolder
{
    param([string]$Path)
    
    $currentSuccessfulDeletionsCounter = $global:totalSuccessfulDeletionsCounter
    $currentFailedDeletionsCounter = $global:totalFailedDeletionsCounter

    $message = "Attempting to delete files in " + $Path + " folder"
    Write-Log -Message $message

    foreach($fileName in $fileNames)
    {
        $fullPath = Join-Path -Path $Path -ChildPath $fileName
        $fileList = Get-ChildItem -Path $fullPath
        Remove-Files -FileList $fileList
    }

    $successfulDeletions = $global:totalSuccessfulDeletionsCounter - $currentSuccessfulDeletionsCounter
    $failedDeletions = $global:totalFailedDeletionsCounter - $currentFailedDeletionsCounter

    if($failedDeletions -gt 0)
    {
        $message = "Failed to delete " + $failedDeletions + " files in " + $Path + " folder"
        Write-Log -Message $message
    }

    if($successfulDeletions -gt 0)
    {
        $message = "Successfully deleted " + $successfulDeletions + " files in " + $Path + " folder"
        Write-Log -Message $message
    }
    else
    {
        $message = "Failed to delete any file in " + $Path + " folder"
        Write-Log -Message $message
    }
}

function Remove-Files
{
    param($FileList)
    foreach($file in $FileList)
    {       
        $fileSize  = (Get-Item -Path $file.FullName).Length
        $spaceFreed = Format-FileSize -Size $fileSize
        Remove-Item -Path $file.FullName

        if((Test-Path -Path $file.FullName) -eq $true)
        {
            $global:totalFailedDeletionsCounter ++
            $message = "Failed to delete " + $file.Name + " file"
			Write-Log -Message $message
        }
        else
        {
            $global:totalSuccessfulDeletionsCounter ++
            $global:totalDeletedContent += $fileSize
            
            $message = "Successfully deleted " + $file.Name + " file - removed " + $spaceFreed
		    Write-Log -Message $message
        }
    }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Log -Message $logTitle
Write-Log -Message $logSeparator
Write-Log -Message "Started file deletion"

foreach($folderPath in $folderPaths)
{
    $message = "Attempting to access " + $folderPath + " folder"
    Write-Log -Message $message

    if((Test-Path -Path $folderPath) -eq $true)
    {
        $message = "Successfully accessed " + $folderPath + " folder"
        Write-Log -Message $message
        Remove-FilesInFolder -Path $folderPath
    }
    else
    {
        $message = "Failed to access " + $folderPath + " folder - MISSING FOLDER ERROR"
        Write-Log -Message $message
    }
}

if($global:totalFailedDeletionsCounter -gt 0)
{
    $message = "Failed to delete " + $global:totalFailedDeletionsCounter + " files"
    Write-Log -Message $message
}

if($global:totalSuccessfulDeletionsCounter -gt 0)
{
    $spaceFreed = Format-FileSize -Size $global:totalDeletedContent

    $message = "Successfully deleted " + $global:totalSuccessfulDeletionsCounter + " files - removed " + $spaceFreed
    Write-Log -Message $message
}

if(($global:totalSuccessfulDeletionsCounter -gt 0) -and ($global:totalFailedDeletionsCounter -eq 0))
{
    $finalMessage = "Successfully completed - File Deletion PowerShell Script"
}
elseif(($global:totalSuccessfulDeletionsCounter -gt 0) -and $global:totalFailedDeletionsCounter -gt 0)
{
    $finalMessage = "Successfully completed with some failed delitions - File Deletion PowerShell Script"
}
else
{
    $finalMessage = "Failed to delete any file - File Deletion PowerShell Script"
}

Write-Log -Message $finalMessage

Write-Log -Message $logSeparator

#Sends email with detailed report and deletes temporary ".\Report.log" file
Send-Report -FinalMessage $finalMessage