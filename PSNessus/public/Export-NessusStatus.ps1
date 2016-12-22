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
