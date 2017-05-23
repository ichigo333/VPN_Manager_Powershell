$logFile = "E:\ip_output.txt"

Function GetIP {
	$ip = (Invoke-WebRequest -Uri https://api.ipify.org -DisableKeepAlive).Content	
	return $ip
}

Function KillProcess {
	Stop-Process -processname qbittorrent* -force
	Stop-Process -processname pia_nw* -force
	Stop-Process -processname rubyw* -force
	Stop-Process -processname pia_manager* -force
}

Function StartVPN {
	$vpn = "C:\Program Files\pia_manager\pia_manager.exe"
	start-process $vpn
	do {
		Log "Waiting for VPN to start..."
		Start-Sleep -s 5
	} while ($(IsVPNRunning) -ne $true)
}

Function StartBT {
	$bt = "C:\Program Files (x86)\qBittorrent\qbittorrent.exe"
	start-process $bt
}

Function Wait {
	for ($a=0; $a -lt 20; $a++) {
			Write-Host -NoNewline "."
			Start-Sleep -s 1
		}
}

Function IsVPNRunning {
	$vpn_process = Get-Process pia_manager -ErrorAction SilentlyContinue
	if ($vpn_process) {
		return $true
	}
	return $false
}

Function Log {
   Param ([string]$logstring)
   Add-content $Logfile -value $logstring
   Write-Host $logstring
}

Function LogFileOnly {
   Param ([string]$logstring)
   Add-content $Logfile -value $logstring -NoNewline
}

Function LogProcessKillInfo {
	Param ([string]$timestamp)

	Log ""
	Log "-------------------------"
	Log " *** IP changed to local"
	Log " current time: $timestamp"
	Log "-------------------------"
}

Function GetTotalBytesTransfered {
	$sent_bytes = Get-NetAdapterStatistics | Select-Object Name, SentBytes | Where-Object {$_.Name -Match "Ethernet 2"} | select -ExpandProperty "SentBytes"
	$received_bytes = Get-NetAdapterStatistics | Select-Object Name, ReceivedBytes | Where-Object {$_.Name -Match "Ethernet 2"} | select -ExpandProperty "ReceivedBytes"
 
	$total_bytes = $sent_bytes + $received_bytes
	$formated_string = "{0:N0}" -f $total_bytes
	Log " transfer: $formated_string"

}