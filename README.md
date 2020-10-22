# File Removal Powershell Script

[![made-with-powershell](https://img.shields.io/badge/PowerShell-1f425f?logo=Powershell)](https://microsoft.com/PowerShell)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/2837928634484cfbb27413952c994687)](https://www.codacy.com/gh/Zoran-Jankov/File-Removal-Powershell-Script/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=Zoran-Jankov/File-Removal-Powershell-Script&amp;utm_campaign=Badge_Grade)
[![CodeFactor](https://www.codefactor.io/repository/github/zoran-jankov/file-removal-powershell-script/badge)](https://www.codefactor.io/repository/github/zoran-jankov/file-removal-powershell-script)

## Description

This script deletes defined files from targeted folders. File names are written by user in '.\File Names.txt' file, and target folders are written by user in '.\Target Folders.txt' file. User can enter partial names of files in '.\File Names.txt' for example "*.dat". Script generates detailed log file, '.\File Deletion Log.log', and report that is sent via email to system administrators. In '.\Settings.cfg' file are parameters for mail settings, and options to turn on and off output writing and mail report if you don't require them.

## Usage

### Execution

![](https://raw.githubusercontent.com/Zoran-Jankov/File-Deletion/master/Document%20Resources/PowerShell.png)

### Report Log

![](https://raw.githubusercontent.com/Zoran-Jankov/File-Deletion/master/Document%20Resources/Report%20Log.png)

## Credits

### Author

Script developer: [Zoran Jankov](https://www.linkedin.com/in/zoran-jankov-b1054b196/)

<a href="https://stackexchange.com/users/12947676"><img src="https://stackexchange.com/users/flair/12947676.png" width="208" height="58" alt="profile for Zoran Jankov on Stack Exchange, a network of free, community-driven Q&amp;A sites" title="profile for Zoran Jankov on Stack Exchange, a network of free, community-driven Q&amp;A sites"></a>
