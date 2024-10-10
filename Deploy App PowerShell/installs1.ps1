$TempDir = [System.IO.Path]::GetTempPath()
$LogPathName = Join-Path -Path $TempDir -ChildPath "S1-Install-Script-$(Get-Date -Format 'MM-dd-yyyy').log"
$isInstalled = Get-AppVersion "Sentinel Agent"

function Get-AppVersion {

    param (
        [Parameter(Position = 0)]
        [string]$filter = '*', 
        [string[]]$properties = @("DisplayName", "DisplayVersion", "InstallDate"), 
        [string[]]$ComputerName
    )

    $regpath = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    $sb = { 
        param ( $regpath, $filter, $properties )
        $regpath | ForEach-Object { Get-ItemProperty $_ } | 
            Where-Object { $_.DisplayName -ne $null -and $_.DisplayName -like $filter } | 
                Select-Object $properties 
    }

    $splat = @{}
    if ($ComputerName) { $splat['ComputerName'] = $ComputerName }

    Invoke-Command -ScriptBlock $sb -ArgumentList $regpath, $filter, $properties @splat

}
Start-Transcript $LogPathName -Append

Write-Host "Checking for App"

if(!$isInstalled) {
    Write-Host "App not installed"
    Write-Host "Copy installer to temp dir"
    Copy-Item "\\10.251.0.107\Software\Installers\SentinelOneInstaller_windows_64bit_v24_1_4_257.exe" -Destination "$TempDir/SentinelOneInstaller_windows_64bit_v24_1_4_257.exe"
    cd $TempDir
    Write-Host "Installing App"
    .\SentinelOneInstaller_windows_64bit_v24_1_4_257.exe -q -"token"
    Write-Host "Deleting Installer"
    cd c:\
    Remove-Item "$TempDir/SentinelOneInstaller_windows_64bit_v24_1_4_257.exe" -Force
}else{
    Write-Host "App is installed already, ending"
}

Stop-Transcript