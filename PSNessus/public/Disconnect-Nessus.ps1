function Disconnect-Nessus{
	$resp = Send-NessusRequest "Delete" "/session"
	$resp
}
