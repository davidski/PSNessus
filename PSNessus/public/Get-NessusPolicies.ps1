function Get-NessusPolicies{
	$pols = @{}
	$resp = Send-NessusRequest "Get" "/editor/policy/templates"

	foreach ($pol in $resp.templates)
	{
		$pols.Add($pol.title, $pol.uuid)
	}

	return $pols
}
