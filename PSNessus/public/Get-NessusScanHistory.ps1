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
