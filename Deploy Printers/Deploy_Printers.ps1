<# 
    .DESCRIPTION 
        Basic Script to Deploy Drivers and Printers
#> 

#Variables
#Generic
$tempFolderPath = Join-Path $Env:Temp $(New-Guid)
$DataStamp = get-date -Format yyyyMMddTHHmmss
$file = "Installer.exe"
#URL to ZIP file containing drivers
$Url = "https://f001.backblazeb2.com/file/cwdistro/clients/EXAMPLE/EXAMPLExerox.zip"
#MD5 Hash of zip file
$mdhash = '0EC80B43F95DB9F52BDEE83DA0BF9148'
#Printer Variables
$printDriverName = "Xerox AltaLink C8155 V4 PS"
$printerIP = "192.168.1.206"
$printerName = "EXAMPLE Scanner NYC 1"
$prinnterPort = "EXAMPLEScannerNYC1Port"
$printerInfPath = "C:\Windows\System32\DriverStore\FileRepository\xeroxaltalinkc81xx_ps.inf_amd64_69b758e957de487a\xeroxaltalinkc81xx_ps.inf"
$printerfoldername = "AltaLinkC81xx_7.146.0.0_PS_x64"

#Create Temp Dir

New-Item -Type Directory -Path $tempFolderPath | Out-Null

#Change to Temp Dir

cd $tempFolderPath

#Download Zip

Invoke-WebRequest -Uri "$Url" -OutFile "$tempFolderPath\printer.zip"

#Verify Hash

if (( Get-FileHash -Algorithm MD5 $tempFolderPath\printer.zip ).Hash -eq $mdhash )
{

#Extract Zip
Expand-Archive -Path printer.zip -DestinationPath $tempFolderPath\printerdrivers

#Check for printer driver and install if not available
$printDriverExists = Get-PrinterDriver -name $printDriverName -ErrorAction SilentlyContinue
if ($printDriverExists) {
    Write-Host "Printer Driver already present"
}else{
    pnputil.exe /a "$tempFolderPath\printerdrivers\$printerfoldername\*.inf"
    Add-PrinterDriver -Name $printDriverName -InfPath $printerInfPath
}

#Check for Printer port and install if they don't exist
$portExists1 = Get-Printerport -Name $prinnterPort -ErrorAction SilentlyContinue
if (-not $portExists1) {
  Add-printerport -name $prinnterPort -printerhostaddress $printerIP
}else{
    Write-Host "Printer Port already present"
}


#Check for printers and install if not available
$printerExists1 = Get-Printer -name $printerName -ErrorAction SilentlyContinue
if (-not $printerExists1) {
    Add-Printer -Name $printerName -drivername $printDriverName -port $prinnterPort
}else{
    Write-Host "Printer already present"
}

<#Below is specific to Xerox Driver Defaults
#Copy XML File if not present
if (!(Test-Path "C:\Program Files\Xerox\Configuration\CommonConfiguration.xml"))
{
New-Item -Path "C:\Program Files\Xerox" -Name "Configuration" -ItemType "directory" -ErrorAction SilentlyContinue
Copy-Item "$tempFolderPath\printerdrivers\CommonConfiguration.xml" -Destination "C:\Program Files\Xerox\Configuration" -Force -ErrorAction SilentlyContinue
}else{
Write-Host "File Xerox Configuration already exists"
}
#Create Registry Key if not present
if (!(Test-Path "HKLM:\SOFTWARE\Xerox\PrinterDriver\V5.0\Configuration"))
{
New-Item –Path HKLM:\SOFTWARE\Xerox\PrinterDriver\V5.0 -Name Configuration -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path HKLM:\SOFTWARE\Xerox\PrinterDriver\V5.0\Configuration -Name "RepositoryUNCPath" -Value "C:\Program Files\Xerox\Configuration" -Force -ErrorAction SilentlyContinue
}else{
Write-Host "Registry key already present"
}#>
}else {
    Write-Host "MD5 Verification Failed"
    }

#Clean up
cd c:\
Remove-Item -Recurse -Path $tempFolderPath -Force
