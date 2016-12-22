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
