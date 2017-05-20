#settings over registry
#Powershell nimmt die Registry als Dateisystem a la NTFS wahr

#Modul zum restarten des Skriptes mit Admin Berechtigungen
$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$princ = New-Object System.Security.Principal.WindowsPrincipal($identity)
if(!$princ.IsInRole( `
  [System.Security.Principal.WindowsBuiltInRole]::Administrator))
  {
  $powershell = [System.Diagnostics.Process]::GetCurrentProcess()
  $psi = New-Object System.Diagnostics.ProcessStartInfo $powerShell.Path
  $script = $MyInvocation.MyCommand.Path
  $prm = $script
 foreach($a in $args) {
    $prm += ' ' + $a
 }
 $psi.Arguments = $prm
 $psi.Verb = "runas"
 [System.Diagnostics.Process]::Start($psi) | Out-Null
 return;
 }


exit 0

#App Vorschläge verhindern
if (Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent) {
    write-host cloud-content existiert
    #New-ItemProperty -Type DWord -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent\ -Name DisableWindowsConsumerFeatures -value "1"
}
else{
    write-host cloud-content existiert nicht
    New-Item HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent
    New-ItemProperty -Type DWord -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent\ -Name DisableWindowsConsumerFeatures -value "1"
    New-ItemProperty -Type DWord -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\ -Name SystemPaneSuggestionsEnabled -value "0"
}

#cortana deaktivieren
if (-not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
    write-host Windows Search existiert nicht
    New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    #New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\"
}

Set-ItemProperty -Type DWord -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name AllowCortana -value "0"
Set-ItemProperty -Type DWord -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name AllowSearchToUseLocation -value "0"
Set-ItemProperty -Type DWord -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name ConnectedSearchUseWeb -value "0"
Set-ItemProperty -Type DWord -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name DisableWebSearch -value "1"

#Standarddrucker nicht von Windows ändern lassen (Win setzt sonst den zuletzt genutzten Drucker als Standard)
Set-ItemProperty -Type DWord -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" -Name LegacyDefaultPrinterMode -value "1"

#Infocenter deaktivieren
New-ItemProperty -Type DWord -Path "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name DisableNotificationCenter -value "1"

#Onedrive deaktivieren
if (-not (Test-Path "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\OneDrive")) {
    write-host Reg Schlüssel OneDrive existiert nicht
    New-Item "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\OneDrive"
 }
New-ItemProperty -Type DWord -Path "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\OneDrive" -Name DisableFileSyncNGSC -value "1"

#Windows Explorer - Kontextmenu - neu reduzieren
if (Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent) {
    write-host cloud-content existiert
    #New-ItemProperty -Type DWord -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent\ -Name DisableWindowsConsumerFeatures -value "1"
}




