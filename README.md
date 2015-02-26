# Nessus
Powershell module for working with Nessus 6

# Example

`
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
`

# Credits
Functions based off of community scripts posted on the (Nessus forums)[https://discussions.nessus.org/docs/DOC-1186].
