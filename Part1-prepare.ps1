<#
.SYNOPSIS
    Erstes Skript zur Installation eines neuen Windows Computer
.DESCRIPTION
    Dieses Modul sichert die Installation des Computers. 
    Punkte
    1. Mit dem Tool disk2vhd wird die Systempartition in eine VHD Datei gespeichert.
    https://technet.microsoft.com/en-us/sysinternals/ee656415.aspx
    2. Windows Wiederherstellungslaufwerk erstellen (RecoveryDrive.exe)
    http://www.winfaq.de/faq_html/Content/tip2500/onlinefaq.php?h=tip2788.htm
    3. Eventlog sichern und leeren
    4. Eigen Benutzer erstellen
    5. Systemwiederherstellungspunkt setzen
.NOTES
    File Name  : Part - prepare.ps1
    Author     : Peter Gyger - 
#>

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

net use x: "\\live.sysinternals.com\tools"
Start-Process "x:\disk2vhd.exe" ('*','-c:\temp\theduke\snapshot.vhd')

#USB Windows Creator Tool starten - Rettungsmedium auf USB Stick (min 16 GB) erstellen
C:\Windows\System32\RecoveryDrive.exe
 
#eventlog und Computerinfos sichern
get-eventlog application | Export-CSV $quelle\el-app.csv
get-eventlog system | Export-CSV $quelle\el-sys.csv
Get-EventLog security | Export-CSV $quelle\el-sec.csv
Get-EventLog windows powershell | Export-CSV $quelle\el-wps.csv
#eventlog löschen
#wevtutil el | Foreach-Object {wevtutil cl "$_"}
Clear-EventLog "application"
Clear-EventLog "system"
Clear-EventLog "security"
Clear-EventLog "Windows PowerShell"
#Computerinfos speichern
Get-ComputerInfo | Export-CSV $quelle\computerinfo.csv
Get-Disk | Export-CSV $quelle\disk.csv
Get-WinSystemLocale | Export-CSV $quelle\winsystemlocal.csv
Get-NetAdapter | Export-CSV $quelle\net-adapter.csv
Get-NetIPAddress | Export-CSV $quelle\net-ipadress.csv

#create user
$pw = ConvertTo-SecureString -String "freeSince1291" -AsPlainText -Force
New-LocalUser -Name theduke -AccountExpires "31.12.2017" -Password $pw

#Wiederherstellungspunke aktivieren und den ersten erstellen
Enable-ComputerRestore -Drive "c:"
Checkpoint-Computer -Description "Sicherung vor der De-Installation"


#$pfad = $env:USERPROFILE + "\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt"
#del $pfad

