<#
.SYNOPSIS
This script deletes defined files from targeted folders.

.DESCRIPTION
This script deletes defined files from targeted folders. Target folders, file names and optional number of days files files must be
older then are written by user in '.\Data.csv' file. User can enter partial names of files in FileName column with a wildcard, for
example "*.dat". Script generates detailed log file, '.\Log.log', and report that is sent via email to system administrators.
In '.\Settings.cfg' file are parameters for mail settings, and options to turn on and off output writing, loging, and mail report
as the user requires them.

.NOTES
	Version:        2.0
	Author:         Zoran Jankov
    Creation Date:  07.07.2020.
    Last Update:    21.10.2020.
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Loading script settings
$Settings = Get-Content '.\Settings.cfg' | Select-Object | ConvertFrom-StringData

#File counters
$TotalSuccessfulRemovalsCounter = 0
$TotalFailedRemovalsCounter = 0
$TotalContentRemoved = 0

#-----------------------------------------------------------[Functions]------------------------------------------------------------

<#
.SYNOPSIS
Writes a log entry to console, log file and report file.

.DESCRIPTION
Creates a log entry with timestamp and message passed thru a parameter Message or thru pipeline, and saves the log entry to log
file, to report log file, and writes the same entry to console. In Configuration.cfg file paths to report log and permanent log
file are contained, and option to turn on or off whether a report log and permanent log should be written. If Configuration.cfg
file is absent it loads the default values. Depending on the OperationResult parameter, log entry can be written with or without
a timestamp. Format of the timestamp is "yyyy.MM.dd. HH:mm:ss:fff", and this function adds " - " after timestamp and before the
main message.

.PARAMETER OperationResult
Parameter description

.PARAMETER Message
Parameter description

.EXAMPLE
An example

.NOTES
Version:        1.5
Author:         Zoran Jankov
#>
function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Message
    )

    begin {
        if (Test-Path -Path '.\Configuration.cfg') {
            $Configuration = Get-Content '.\Configuration.cfg' | ConvertFrom-StringData
            $LogFile         = $Configuration.LogFile
            $ReportFile      = $Configuration.ReportFile
            $WriteTranscript = $Configuration.WriteTranscript -eq "true"
            $WriteLog        = $Configuration.WriteLog -eq "true"
            $SendReport      = $Configuration.SendReport -eq "true"
        }
        else {
            $LogFile         = '.\Log.log'
            $ReportFile      = '.\Report.log'
            $WriteTranscript = $true
            $WriteLog        = $true
            $SendReport      = $true
        }
        if (-not (Test-Path -Path $LogFile)) {
            New-Item -Path $LogFile -ItemType File
        }
        if (-not (Test-Path -Path $ReportFile)) {
            New-Item -Path $ReportFile -ItemType File
        }
    }

    process {
        $Timestamp = Get-Date -Format "yyyy.MM.dd. HH:mm:ss:fff"
        $LogEntry = $Timestamp + " - " + $Message
        if ($WriteTranscript) {
            Write-Verbose $LogEntry -Verbose
        }
        if ($WriteLog) {
            Add-content -Path $LogFile -Value $LogEntry
        }
        if ($SendReport) {
            Add-content -Path $ReportFile -Value $LogEntry
        }
    }
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Path
Parameter description

.PARAMETER FileNames
Parameter description

.EXAMPLE
An example

.NOTES
Version:        1.1
Author:         Zoran Jankov
#>
function Remove-Files {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $FolderPath,

        [Parameter(Position = 1, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $FileName,

        [Parameter(Position = 2, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int]
        $OlderThen = 0
    )

    begin {
        if ($OlderThen -gt 0) {
            $DatetoDelete = (Get-Date).AddDays(- $OlderThen)
        }
    }

    process {
        [long] $FolderSpaceFreed = 0
        [short] $FilesRemoved = 0
        [short] $FailedRemovals = 0

        $FullPath = Join-Path -Path $FolderPath -ChildPath $FileName
        $FileList = Get-ChildItem -Path $FullPath

        foreach($File in $FileList) {
            $FileSize  = (Get-Item -Path $File.FullName).Length
            $SpaceFreed = Get-FormattedFileSize -Size $FileSize
            if ($OlderThen -gt 0) {
                Get-Item -Path $File.FullName | Where-Object {$_.LastWriteTime -lt $DatetoDelete} | Remove-Item
            }
            else {
                Remove-Item -Path $File.FullName
            }
            if((Test-Path -Path $File.FullName) -eq $true) {
                $Message = "Failed to delete " + $File.Name + " file"
                $FailedRemovals ++
            }
            else {
                $Message = "Successfully deleted " + $File.Name + " file - removed " + $SpaceFreed
                $FolderSpaceFreed += $FileSize
                $FilesRemoved ++
            }
        }

        $SpaceFree = Get-FormattedFileSize -Size $FolderSpaceFreed

        if($FilesRemoved -eq 0) {
            $Message = "Successfully deleted " + $FilesRemoved + " files in " + $FolderPath + " folder, and " + $SpaceFree + " of space was freed"
        }
        else {
            $Message = "No files for delition were found in " + $FolderPath + " folder"
        }
        Write-Log -Message $Message
        New-Object -TypeName psobject -Property @{
            FolderSpaceFreed =  $FolderSpaceFreed
            FilesRemoved = $FilesRemoved
            FailedRemovals = $FailedRemovals
		}
    }
}

<#
.SYNOPSIS
Returns string value from long integer value representing bytes in [12.45 MB] format.

.DESCRIPTION
The function takes in a long integer value representing bytes, and Returns string value in [12.45 MB] format.

.PARAMETER Size
Long integer representing bytes

.EXAMPLE
Get-FormattedFileSize "1234567890"

.EXAMPLE
"1234567890" | Get-FormattedFileSize

.NOTES
General notes
#>
function Get-FormattedFileSize {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [long]
        $Size
    )

    If ($Size -gt 1TB) {
        $StringValue = [string]::Format('{0:0.00} TB', $Size / 1TB)
    }
    elseIf ($Size -gt 1GB) {
        $StringValue = [string]::Format('{0:0.00} GB', $Size / 1GB)
    }
    elseIf ($Size -gt 1MB) {
        $StringValue = [string]::Format('{0:0.00} MB', $Size / 1MB)
    }
    elseIf ($Size -gt 1KB) {
        $StringValue = [string]::Format('{0:0.00} kB', $Size / 1KB)
    }
    else {
        $StringValue = [string]::Format('{0:0.00} B', $Size)
    }
    return $StringValue
}

<#
.SYNOPSIS
Sends a Report.log file to defined email address

.DESCRIPTION
This function sends a report log file as an attachment to defined email address. In configuration hashtable parameter email
settings are defined.

.PARAMETER configuration
A hashtable that contains information about report log file location, mail settings and weather report should be sent at all.

.PARAMETER FinalMessage
Additional variable information to be sent in the mail body.

.EXAMPLE
Send-Report -FinalMessage "Successful script execution"

.NOTES
Version:        1.4
Author:         Zoran Jankov
#>
function Send-EmailReport {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $FinalMessage
    )

    begin {
        $Configuration = Get-Content '.\Configuration.cfg' | ConvertFrom-StringData
    }

    process {
        if ($Configuration.SendReport -eq 'true') {
            $Body = $Configuration.Body + "`n" + $FinalMessage
            Send-MailMessage -SmtpServer $Configuration.SmtpServer `
                             -Port $Configuration.Port `
                             -To $Configuration.To `
                             -From $Configuration.From `
                             -Subject $Configuration.Subject `
                             -Body $Body `
                             -Attachments $Configuration.ReportFile
            Remove-Item -Path $Configuration.ReportFile
        }
    }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Log -Message $Settings.LogTitle
Write-Log -Message $Settings.LogSeparator

if($TotalFailedRemovalsCounter -gt 0)
{
    $message = "Failed to delete " + $TotalFailedRemovalsCounter + " files"
    Write-Log -Message $message
}

if($TotalSuccessfulRemovalsCounter -gt 0)
{
    $SpaceFreed = Format-FileSize -Size $TotalContentRemoved

    $Message = "Successfully deleted " + $TotalSuccessfulRemovalsCounter + " files - removed " + $SpaceFreed
    Write-Log -Message $Message
}

if(($TotalSuccessfulRemovalsCounter -gt 0) -and ($TotalFailedRemovalsCounter -eq 0))
{
    $FinalMessage = "Successfully completed - File Deletion PowerShell Script"
}
elseif(($TotalSuccessfulRemovalsCounter -gt 0) -and $TotalFailedRemovalsCounter -gt 0)
{
    $FinalMessage = "Successfully completed with some failed delitions - File Deletion PowerShell Script"
}
else
{
    $FinalMessage = "Failed to delete any file - File Deletion PowerShell Script"
}

Write-Log -Message $Message
Write-Log -Message $Settings.LogSeparator

#Sends email with detailed report and deletes temporary ".\Report.log" file
Send-Report -FinalMessage $FinalMessage