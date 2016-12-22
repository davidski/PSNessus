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
