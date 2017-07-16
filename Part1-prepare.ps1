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
#kopiert aus dem Blog von Christian Jäckle
#https://blog.christianjaeckle.de/powershell-skript-nochmal-mit-admin-rechten-ausfuehren/
# Identität und Eigentümer ermitteln
$objIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$objSecPrinc = New-Object System.Security.Principal.WindowsPrincipal($objIdentity)
 
# Auf Administrator-Rechte prüfen
if(!$objSecPrinc.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
{
	# Prozesse ermitteln
  $objProcesses = [System.Diagnostics.Process]::GetCurrentProcess()
	
	# Neuen Prozess-Intanz erzeugen
  $objProcInfos = New-Object System.Diagnostics.ProcessStartInfo $objProcesses.Path
	
	# Skript ermitteln
  $ThisScript = $MyInvocation.MyCommand.Path
	
	# Übergabeparamter ermitteln
  $strParameter = $ThisScript
	
  foreach($strArgument in $args) {
    $strParameter += ' ' + $strArgument
  }
	
	# Übergabeparamter dem neuen Prozess übergeben
  $objProcInfos.Arguments = $strParameter
	
	# Neuen Prozess ausführen
  $objProcInfos.Verb = "runas"
	[System.Diagnostics.Process]::Start($objProcInfos) | Out-Null
	
  return;
}
 . 
$whereami = $(Get-Location).Path

# Adminrechte sind vorhanden
Write-Host "Du hast Administratorenrechte. Der Computer muss mit dem Internet verbunden sein. Weiter mit Return. Bitte 1 -2 Minuten Geduld. Bitte kontrollieren ob in der Statuszeile ein blinkendes Icon zu sehen ist." -NoNewline

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

