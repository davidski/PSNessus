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
