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

$isInstalled = Get-AppVersion "Sentinel Agent"
if(!$isInstalled) {
Copy-Item "\\10.251.0.107\Software\Installers\SentinelOneInstaller_windows_64bit_v24_1_4_257.exe" -Destination "$env:TEMP/SentinelOneInstaller_windows_64bit_v24_1_4_257.exe"
$TempDir = [System.IO.Path]::GetTempPath()
cd $TempDir
.\SentinelOneInstaller_windows_64bit_v24_1_4_257.exe -q -"token"
}