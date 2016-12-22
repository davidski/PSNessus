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
