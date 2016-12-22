function Start-NessusScan() {
    [CmdletBinding()]
	param(
        [Parameter(Mandatory=$true, Position=0, valuefromPipeline=$true)]
		[string] $sid
	)
	$resp = Send-NessusRequest "Post" "/scans/$sid/launch"

	return $resp.scan_uuid
}
