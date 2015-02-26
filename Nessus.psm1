Set-StrictMode -Version latest

function Send-NessusRequest() {
    [CmdletBinding()]
	param(
        [Parameter(Mandatory=$true, Position=0, valuefromPipeline=$true)]
		[string] $method,
        [Parameter(Mandatory=$true, Position=1, valuefromPipeline=$true)]
		[string] $resource,
        [Parameter(Mandatory=$false, Position=2, valuefromPipeline=$true)]
		[hashtable] $data = @{}
	)

	$header = @{"X-Cookie" = "token=$token"}
	$url = $base + $resource

	# Use an empty dictionary for the body on GET requests
	if ($method -eq "Get"){
		$body = @{}
	} else {
		$body = ConvertTo-Json $data
	}

	$resp = Invoke-RestMethod -Uri $url -ContentType "application/json" -Method $method -Headers $header -Body $body -verbose

	return $resp
}


function Connect-Nessus() {
    [CmdletBinding()]
	param(
        [Parameter(Mandatory=$true, Position=0, valuefromPipeline=$true)]
		[string] $username,
        [Parameter(Mandatory=$true, Position=1, valuefromPipeline=$true)]
		[string] $password
	)
	$data = @{"username" = $username; "password" = $password}
	$resp = Send-NessusRequest "Post" "/session" $data 

	return $resp.token
}


function Disconnect-Nessus{
	$resp = Send-NessusRequest "Delete" "/session"
}


function Get-NessusPolicies{
	$pols = @{}
	$resp = Send-NessusRequest "Get" "/editor/policy/templates"

	foreach ($pol in $resp.templates)
	{
		$pols.Add($pol.title, $pol.uuid)
	}

	return $pols
}


function Get-NessusHistoryIds() {
    [CmdletBinding()]
	param(
        [Parameter(Mandatory=$true, Position=0, valuefromPipeline=$true)]
		[string] $sid
	)
	$hids = @()
	$resp = Send-NessusRequest "Get" "/scans/$sid"

	foreach ($hist in $resp.history)
	{
		[pscustomobject]@{
            uuid = $hist.uuid
            history_id = $hist.history_id
            status = $hist.status
            creation_date = [TimeZone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($hist.creation_date))
            last_modification_date = [TimeZone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($hist.last_modification_date))
            }
	}
}


function Get-NessusScanHistory() {
    [CmdletBinding()]
	param(
        [Parameter(Mandatory=$true, Position=0, valuefromPipeline=$true)]
		[string] $sid,
        [Parameter(Mandatory=$true, Position=1, valuefromPipeline=$true)]
		[string] $hid
	)
	$data = @{"history_id" = $hid}
	$resp = Send-NessusRequest "GET" "/scans/$sid" $data

	return $resp.info
}


function Add() {
    [CmdletBinding()]
	param(
        [Parameter(Mandatory=$true, Position=0, valuefromPipeline=$true)]
		[string] $name,
        [Parameter(Mandatory=$true, Position=1, valuefromPipeline=$true)]
		[string] $desc,
        [Parameter(Mandatory=$true, Position=2, valuefromPipeline=$true)]
        [string] $targets,
        [Parameter(Mandatory=$true, Position=3, valuefromPipeline=$true)]
        [string] $policy
	)
	$settings = @{}
	$settings.Add("name", $name)
	$settings.Add("description", $desc)
	$settings.Add("text_targets", $targets)

	$data = @{}
	$data.Add("uuid", $policy)
	$data.Add("settings", $settings)

	$resp = Send-NessusRequest "Post" "/scans" $data

	return $resp.scan
}


function Start-NessusScan() {
    [CmdletBinding()]
	param(
        [Parameter(Mandatory=$true, Position=0, valuefromPipeline=$true)]
		[string] $sid
	)
	$resp = Send-NessusRequest "Post" "/scans/$sid/launch"

	return $resp.scan_uuid
}


function Get-NessusStatus() {
    [CmdletBinding()]
	param(
        [Parameter(Mandatory=$true, Position=0, valuefromPipeline=$true)]
		[string] $sid,
        [Parameter(Mandatory=$true, Position=0, valuefromPipeline=$true)]
		[string] $hid
	)

	$resp = Get-NessusScanHistory $sid $hid

	return $resp.status
}


function Export-NessusStatus() {
    [CmdletBinding()]
	param(
        [Parameter(Mandatory=$true, Position=0, valuefromPipeline=$true)]
		[string] $sid,
        [Parameter(Mandatory=$true, Position=1, valuefromPipeline=$true)]
		[string] $fid
	)

	$resp = Send-NessusRequest "Get" "/scans/$sid/export/$fid/status"

	return $resp.status
}


function Export-NessusHistory() {
    [CmdletBinding()]
	param(
        [Parameter(Mandatory=$true, Position=0, valuefromPipeline=$true)]
		[string] $sid,
        [Parameter(Mandatory=$true, Position=1, valuefromPipeline=$true)]
		[string] $hid
	)

	$data = @{}
	$data.Add("history_id", $hid)
	$data.Add("format", "nessus")

	$resp = Send-NessusRequest "Post" "/scans/$sid/export" $data
	$fid = $resp.file

	do {
		Start-Sleep -Seconds 5
		$status = Export-NessusStatus -sid $sid -fid $fid 
	} while ($status -ne "ready")

	return $fid
}


function Get-NessusExportFile() {
    [CmdletBinding()]
	param(
		[Parameter(Mandatory=$true, Position=0, valuefromPipeline=$true)]
        [string] $sid,
        [Parameter(Mandatory=$true, Position=1, valuefromPipeline=$true)]
		[string] $fid
	)

	$resp = Send-NessusRequest "Get" "/scans/$sid/export/$fid/download"

	$file = "nessus-$sid-$fid.nessus"
	Write-Verbose "Saving report to $file"
	$resp.OuterXml | Out-File $file -Encoding ascii

    Get-ChildItem $file
}


function Get-NessusScans {
	$scans = @()
	$resp = Send-NessusRequest "Get" "/scans"

	foreach ($scan in $resp.scans){
		$scans += [pscustomobject]@{
            id = $scan.id
            name = $scan.name
            starttime = $scan.starttime
        }
	}

	$scans
}

