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

#Vorinstallierte Apps löschen
#3D Builder
Get-AppxPackage *3dbuilder* | Remove-AppxPackage
#Windowsphone
Get-AppxPackage *windowsphone* | Remove-AppxPackage
#Löschen von Erste Schritte (Tipps App):
Get-AppxPackage *getstarted* | Remove-AppxPackage
#Finanzen
Get-AppxPackage *bingfinance* | Remove-AppxPackage
#Groove-Musik
Get-AppxPackage *zunemusic* | Remove-AppxPackage
#Solitaire
Get-AppxPackage *solitairecollection* | Remove-AppxPackage
#Office holen
Get-AppxPackage *officehub* | Remove-AppxPackage
#sport
Get-AppxPackage *bingsports* | Remove-AppxPackage


#Installierte Programme anzeigen
$Textdatei = "c:\Temp\theduke\applikationen.htm"
Get-WmiObject -Class Win32_Product | Select-Object -Property Name | ConvertTo-CSV | Out-File c:\temp\theduke\applikationen.csv
Get-WmiObject -Class Win32_Product | Select-Object -Property Name | ConvertTo-HTML | Out-File $Textdatei

#Invoke-Expression $Textdatei
#csv datei auslesen
$progs =Import-Csv -Path 'c:\temp\theduke\applikationen.csv'
ForEach($prog in $progs) {
    $schritt = $schritt + 1
    # das Aktuelle Objekt befindet sich in der Variablen $prog
    $Result = [System.Windows.Forms.MessageBox]::Show("Jetzt " + $prog.name + " dieses Programm löschen?","Dieses Programm löschen?",3,[System.Windows.Forms.MessageBoxIcon]::Warning)
    If ($Result -eq "Yes")
    {
        $a = "Das Programm wird gelöscht"
        $a
        Get-WmiObject -Class Win32_Product | where {$_.Name -like $prog.name} | ForEach-Object {$_.uninstall()}
    }
    elseif ($Result -eq "No")
    {
        $a = "Schreibvorgang wurde abgebrochen. Antwort Nein."
        $a
    }
    else
    {
        $a = "Schreibvorgang wurde abgebrochen"
        $a
        exit 0
    }    
}

#online repository chocolatey installieren
write-host choco install
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation
#cinst C:\temp\theduke\packages.config
Install-Package C:\temp\theduke\packages.config
