If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}

. "C:\Users\alex_media\Desktop\getip.ps1"

$ip_local = "//your public IP goes here"
$script:ip_previous = $null

Function SetPreviousIP {
	Param ([string]$ip_current)
	
	if ($ip_previous -eq $null) {
		$script:ip_previous = $ip_current
	}
	elseif ($ip_previous -ne $ip_current) {
		Log "*** IP changed from $ip_previous ***"
		$script:ip_previous = $ip_current
		Log "*** setting previous IP to $ip_previous ***"
	}
	else {}
}


While ($true) {
	$timestamp = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
	$ip_current = GetIP
	SetPreviousIP $ip_current
	
	Write-Host -NoNewline $timestamp $ip_current
	Write-Host -NoNewline " "

	LogFileOnly "$timestamp --- $ip_current"
	
	if ($ip_current -eq $ip_local) {
		LogProcessKillInfo $timestamp
		Log "*** VPN app is running: $(IsVPNRunning)"
		KillProcess 
		Log "*** attempting to start VPN"
		StartVPN
		$start_counter = 1
		Log "*** checking for VPN connection"
		while ($ip_current -eq $ip_local) {
		    Log "current ip:  $ip_current"
			if ($start_counter -eq 10) {
				Log "Tried 10 times, restarting VPN again"
				KillProcess
				StartVPN
				$start_counter = 1
			}
			$ip_current = GetIP
			LogFileOnly "attemp : $start_counter "
			Write-Host -NoNewline "attemp : $start_counter "
			Wait
			""
			$start_counter++
		}
		Log "*** starting BT"
		StartBT
	}
	else {
		Wait
		GetTotalBytesTransfered
	}
	Write-Host ""
}
