function Get-NessusHistoryIds() {
    [CmdletBinding()]
	param(
        [Parameter(Mandatory=$true, Position=0, valuefromPipeline=$true)]
		[string] $sid
	)
	#$hids = @()
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
