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
