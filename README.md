[![Build Status](https://ci.appveyor.com/api/projects/status/github/davidski/PSNessus?svg=true)](https://ci.appveyor.com/project/davidski/PSNessus)

# Introduction
PowerShell module for working with the [Tenable Nessus](https://www.tenable.com/products/nessus-vulnerability-scanner) API.

## Sample Use Cases
+ Retrieve the status of vulnerability scans
+ Retrieve the results of scans for processing in downstream systems
+ Launch individual scans as one-offs

# Installation

There's More Than One Way To Do It (TMTOWTDI), but one of the simplest is via 
the [PowerShell Gallery](https://www.powershellgallery.com):

```PowerShell
Install-Module -Name PSNessus
```

Alternatively you can manually install the module by:

1. Downloading a zip build from the release page.
2. Unblocking and extracting the zip.
3. From PowerShell in the extracted directory enter: `{PowerShell} Install-Module -Path .\PSNessus`


# Example

    Import-Module Nessus
    
    $base = "https://your_awesome_server:8834"
    $token = ""
    $username = "<your username>"
    $password = "<your password>"
    
    Write-Output "Logging in to ${base}"
    $token = Connect-Nessus $username $password
    
    #retrieve all current scans
    $scans = Get-NessusScans
    
    #fetch the most recently completed scan history for the most recently run scan
    $scanID = $scans | Sort-Object -Property starttime | select -Last 1 -ExpandProperty id
    $historyID = Get-NessusHistoryIds -sid $scanID |? status -eq "completed" | Sort-Object -property last_modification_date | select -last 1 -expand history_id
    
    #export it and download as a .Nessus file
    $exportID = Export-NessusHistory -sid $scanID -hid $historyID
    $downloadedFile = Get-NessusExportFile -sid $scanID -fid $exportID
    Write-Output "Requested file is at: $($downloadedFile.FullName)"
    
    #log off
    Disconnect-Nessus 

# Credits

Functions based off of community scripts posted on the [Nessus forums]([https://discussions.nessus.org/docs/DOC-1186).
