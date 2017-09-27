if ($PSScriptRoot -eq $null) {
    Write-Host Setting $`PSScriptRoot variable
    $PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path
}

$ErrorAction = $Global:ErrorActionPreference
$Global:ErrorActionPreference = "SilentlyContinue"
Update-TypeData -AppendPath ("$PSScriptRoot\types\comObject.types.ps1xml")
$Global:ErrorActionPreference = $ErrorAction

$EventLogSource = "Jitensha Installer"
Export-ModuleMember -Variable "EventLogSource"

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
$Icon = New-Object System.Drawing.Icon("$PSScriptRoot\icons\jitensha.ico")
Export-ModuleMember -Variable "Icon"

. (Join-Path -Path $PSScriptRoot -ChildPath "\private\Get-JitenshaMsiInstallerVersion.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath '\private\Get-JitenshaMsiProperties.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath '\private\Get-JitenshaPackageList.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath '\private\Install-JitenshaPackage.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath '\private\Update-JitenshaPackage.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath '\private\Check-JitenshaInstallation.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath '\private\Check-JitenshaRegistryInstallation.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath '\private\Get-JitenshaChocolateyInstallerVersion.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath '\private\Get-JitenshaDotNetVersion.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath '\private\Get-JitenshaExeInstallerVersion.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath '\private\Get-JitenshaMatchedInstallerVersion.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath '\private\Get-JitenshaInstallerVersion.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath '\private\Get-JitenshaMatchedUpdateVersion.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath '\private\Write-JitenshaEvent.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath '\public\Run-JitenshaInstaller.ps1')

Export-ModuleMember -Function 'Run-JitenshaInstaller'
