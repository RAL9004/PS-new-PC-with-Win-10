
#system partition in eine VHDX Datei sichern
#Invoke-WebRequest "http://live.sysinternals.com/disk2vhd.exe" -Outfile c:\temp\theduke\Disk2vhd.exe
#start-process \\live.sysinternals.com\tools\disk2vhd.exe
#c:\temp\theduke\Disk2vhd.exe

net use x: "\\live.sysinternals.com\tools"
Start-Process "x:\disk2vhd.exe" ('*','-c:\temp\theduke\snapshot.vhd')

#USB Windows Creator Tool starten - Rettungsmedium auf USB Stick (min 16 GB) erstellen
C:\Windows\System32\RecoveryDrive.exe
 
#eventlog sichern
get-eventlog application | Export-CSV $quelle\el-app.csv
get-eventlog system | Export-CSV $quelle\el-sys.csv
Get-EventLog security | Export-CSV $quelle\el-sec.csv
Get-EventLog windows powershell | Export-CSV $quelle\el-wps.csv
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

