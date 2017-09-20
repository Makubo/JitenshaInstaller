# Workaround for Powershell 2.0
#if ($PSScriptRoot -eq $null) {
#    Write-Host Setting $`PSScriptRoot variable
#    $PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path
#}

#Import-module $PSScriptRoot\Get-JitenshaMsiProperties.ps1

Function Get-JitenshaMsiInstallerVersion() {
    param([System.Collections.Hashtable]$Package)


    if ($Package.PackageFile -ne $null) {
        $Version = [System.Version] (Get-JitenshaMsiProperties $Package.PackageFile).ProductVersion
        if ($Version.Revision -eq -1) {
            $Version = [System.Version]"$($Version.ToString()).0"
        }
        $Installation = $Package.PackageFile
    } elseif ($Package.PackageLocation -ne $null) {
        $Installation = $null
        ForEach ($msi in Get-ChildItem -Path "$($Package.PackageLocation)*" -include *.msi){
            if ($Installation -eq $null) {
                $Installation = $msi
            } elseif ([System.Version](Get-JitenshaMsiProperties $msi).ProductVersion -gt [System.Version](Get-JitenshaMsiProperties $Installation).ProductVersion) {
                $Installation = $msi
            }
        }
        $Version = [System.Version](Get-JitenshaMsiProperties $Installation).ProductVersion
        if ($Version.Revision -eq -1) {
            $Version = [System.Version]"$($Version.ToString()).0"
        }
    }
    $Package.Add("InstallerVersion", $Version )
    $Package.Add("Installer", $Installation )
    return $Package
}

# TESTS

#$inst = New-Object System.Collections.Hashtable
#$inst.Add("PackageLocation","\\server\Software\Skype\")
#$inst.Add("PackageFile","\\server\Software\AdobeReader\AdbeRdr11000_ru_RU.msi")

#Get-JitenshaMsiInstallerVersion $inst
