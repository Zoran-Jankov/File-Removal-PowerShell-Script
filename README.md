# File Removal Powershell Script

[![made-with-powershell](https://img.shields.io/badge/PowerShell-1f425f?logo=Powershell)](https://microsoft.com/PowerShell)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/2837928634484cfbb27413952c994687)](https://www.codacy.com/gh/Zoran-Jankov/File-Removal-PowerShell-Script/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=Zoran-Jankov/File-Removal-PowerShell-Script&amp;utm_campaign=Badge_Grade)
[![CodeFactor](https://www.codefactor.io/repository/github/zoran-jankov/file-removal-powershell-script/badge)](https://www.codefactor.io/repository/github/zoran-jankov/file-removal-powershell-script)

## Description

This script removes defined files from targeted folders. It is meant to be used by System Administrators, because it has many options and settings that can be configured to remove files in multiple and various ways. All data regarding file removal, target folders, file names, optional number of days files must be older then to be removed, if files in subfolders should be removed, and if files should be force removed, are written by user in [`Data.csv`](https://github.com/Zoran-Jankov/File-Removal-PowerShell-Script/blob/master/Data.csv) file. User can enter partial names of files in `FileName` column with a wildcard character, for example `*.dat` or `Backup*`. Script generates detailed log file, and report that is sent via email. In [`Settings.cfg`](https://github.com/Zoran-Jankov/File-Removal-PowerShell-Script/blob/master/Settings.cfg) file parameters are stored for email settings, and options to turn on or off console writing, loging, and email report as the user requires them.

## Usage

Before running *File Removal Powershell Script* user must configure the script settings in [`Settings.cfg`](https://github.com/Zoran-Jankov/File-Removal-PowerShell-Script/blob/master/Settings.cfg) file, and the data feeding the script must be entered in [`Data.csv`](https://github.com/Zoran-Jankov/File-Removal-PowerShell-Script/blob/master/Data.csv) file.

### Settings

*File Removal Powershell Script* can be configured in [`Settings.cfg`](https://github.com/Zoran-Jankov/File-Removal-PowerShell-Script/blob/master/Settings.cfg) file to write output to console, write permanent log and to send email when it is finished running. Email settings, log title and log separator are also configured in [`Settings.cfg`](https://github.com/Zoran-Jankov/File-Removal-PowerShell-Script/blob/master/Settings.cfg) file.

#### Settings parameters

-   **`LogTitle`** - Define a string to be a title in logs
-   **`LogSeparator`** - Define a string to be a separator in logs for clearer visibility
-   **`WriteTranscript`** - Set to ***true*** if writing transcript to console is wanted
-   **`WriteLog`** - Set to ***true*** if writing a permanent log is wanted
-   **`SendReport`** - Set to ***true*** if sending a report via email log is wanted
-   **`LogFile`** - Relative path to permanent log file
-   **`ReportFile`** - Relative path to report log file
-   **`SmtpServer`** - SMPT server name
-   **`Port`** - SMPT port (*25/465/587*)
-   **`To`** - Email address to send report log to
-   **`From`** - Email address to send report log form
-   **`Subject`** - Subject of the report log email
-   **`Body`** - Body of the report log email

### Data

In [`Data.csv`](https://github.com/Zoran-Jankov/File-Removal-PowerShell-Script/blob/master/Data.csv) user enters target folders, target files and optinaly number of days to remove files older than that.

#### Data parameters

|FolderPath|FileName|OlderThen|Recurse|Force|
|----------|:------:|--------:|------:|----:|

-   **`FolderPath`** - In this column write the full path of the folder in which files are to be removed.
    -   ***Example:*** *C:\Folder\Folder\Folder*

-   **`FileName`** - In this column write the name of the file which is to be removed. It can include a wild card character **`*`** so multiple files can be affected.
    -   ***Example:*** * (Remove all files in target folder)
    -   ***Example:*** *Cache.bat* (Remove only the file named "Cache.bat")
    -   ***Example:*** **.bmp* (Remove all files with ".bmp" extension)
    -   ***Example:*** *Backup** (Remove all files with name starting with "Backup")

-   **`OlderThen`** - In this column write the number of days to remove files older than that in integer format
    -   ***Example:*** *180* (Remove all files older than six months)
    -   ***Example:*** *0* (Remove all files regardless of last write time)

-   **`Recurse`** - In this column enter ***true*** if file removal in subfolders is required.
    -   ***Example:*** *true* (Remove all files even in subfolders of the target folder)
    -   ***Example:*** *false* (No files in subfolders of the target folder will be removed)

-   **`Force`** - In this column enter ***true*** if force removal of files is required.
    -   ***Example:*** *true* (Force remove all selected files)
    -   ***Example:*** *false* (Selected files will not be removed by force)

All of the data parameters are taken in account while script is calculating which files will be removed. This is very convenient because it is possible to target multiple folders with different rulers for file removal with a single script.

### Execution

*File Removal Powershell Script* can be run manually or with *Task Scheduler*.

![Execution](https://raw.githubusercontent.com/Zoran-Jankov/File-Deletion/master/Images/PowerShell.png)

### Report Log

*File Removal Powershell Script* generates detailed log file and report, with timestamped log entry of every action and error, with files names which have been removed and disk space freed.

![Report Log](https://raw.githubusercontent.com/Zoran-Jankov/File-Deletion/master/Images/Report%20Log.png)

## Credits

### Author

PowerShell script developer: [Zoran Jankov](https://www.linkedin.com/in/zoran-jankov-b1054b196/)

<a href="https://stackexchange.com/users/12947676"><img src="https://stackexchange.com/users/flair/12947676.png" width="208" height="58" alt="profile for Zoran Jankov on Stack Exchange, a network of free, community-driven Q&amp;A sites" title="profile for Zoran Jankov on Stack Exchange, a network of free, community-driven Q&amp;A sites"></a>

### Mentor

PowerShell learning mentor and manager: [Bojan Maksimović](https://www.linkedin.com/in/bojan-maksimovic-44749a3a/)
