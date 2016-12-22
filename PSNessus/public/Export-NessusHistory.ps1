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
