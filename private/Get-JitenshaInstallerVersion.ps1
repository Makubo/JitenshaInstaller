# Workaround for Powershell 2.0
#if ($PSScriptRoot -eq $null) {
#    Write-Host Setting $`PSScriptRoot variable
#    $PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path
#}

#Import-module $PSScriptRoot\Get-JitenshaExeInstallerVersion.ps1
#Import-module $PSScriptRoot\Get-JitenshaMsiInstallerVersion.ps1
#Import-module $PSScriptRoot\Get-JitenshaChocolateyInstallerVersion.ps1
#Import-module $PSScriptRoot\Get-JitenshaMatchedInstallerVersion.ps1

Function Get-JitenshaInstallerVersion() {
    param([System.Collections.Hashtable]$Package)

    if ($Package.Type -eq 1) {
        Write-Debug "$($Package.Name): Installer type - EXE"
        $Package = Get-JitenshaExeInstallerVersion $Package
    } elseif ($Package.Type -eq 2) {
        Write-Debug "$($Package.Name): Installer type - MSI"
        $Package = Get-JitenshaMsiInstallerVersion $Package
    } elseif ($Package.Type -eq 3) {
        Write-Debug "$($Package.Name): Installer type - MSP"
    } elseif ($Package.Type -eq 4) {
        Write-Debug "$($Package.Name): Installer type - MSU"
    } elseif ($Package.Type -eq 5) {
        Write-Debug "$($Package.Name): Installer type - Native"
        if ($Package.NativeInstallerCheck) {
            $Version = Invoke-Expression $Package.NativeInstallerCheck
        }
        if ($Version) {
            $Package.Add( "InstallerVersion", $Version )

        }
        if ($Package.ChocoPackage){
            Write-Debug "$($Package.Name): Check chocolatey installer"
            $Package = Get-JitenshaChocolateyPackageVersion $Package
        }
    }

    if ( ($Package.PackageLocation -or $Package.PackageFile) -and $Package.VersionFileMatch) {
        Write-Debug "$($Package.Name): Try to match installer version"
        $Package = Get-JitenshaMatchedInstallerVersion $Package
    }

    if ($Package.UpdateLocation -and $Package.UpdateVersionFileMatch){
        Write-Debug "$($Package.Name): Try to match update version"
        $Package = Get-JitenshaMatchedUpdateVersion $Package
    }
    return $Package
}

# TESTS

#$inst = New-Object System.Collections.Hashtable
#$inst.Add("Type",3)
#$inst.Add("PackageFile","\\server\Software\Windows Fix\Windows Update\Windows Management Framework 5.1\Win7AndW2K8R2-KB3191566-x64-5.1.14409.1005.msu")
#$inst.Add("VersionFileMatch","^.*-(\d+\.\d+\.\d+\.\d+)\.msu")
#Get-JitenshaInstallerVersion $inst
