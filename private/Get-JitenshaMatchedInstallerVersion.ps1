# Workaround for Powershell 2.0
#if ($PSScriptRoot -eq $null) {
#    Write-Host Setting $`PSScriptRoot variable
#    $PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path
#}

Function Get-JitenshaMatchedInstallerVersion() {
    param([System.Collections.Hashtable]$Package)


    if ($Package.PackageFile -ne $null) {
        $Version = [regex]::Match($Package.PackageFile, $Package.VersionFileMatch).Groups[1].Value
        if ($Version.Revision -eq -1) {
            $Version = [System.Version]"$($Version.ToString()).0"
        }
        $Installation = $Package.PackageFile
    } elseif ($Package.PackageLocation -ne $null) {
        $Installation = $null
        ForEach ($installer in Get-ChildItem -Path "$($($Package.PackageLocation))*" ){
            if ($Installation -eq $null) {
                $Installation = $installer
            } elseif ([System.Version]([regex]::Match($installer, $Package.VersionFileMatch).Groups[1].Value) -gt [System.Version]([regex]::Match($installation, $Package.VersionFileMatch).Groups[1].Value)) {
                $Installation = $installer
            }
        }
        $Version = [System.Version][regex]::Match($installation, $Package.VersionFileMatch).Groups[1].Value
        if ($Version.Revision -eq -1) {
            $Version = [System.Version]"$($Version.ToString()).0"
        }
    }
    if ($Version) {
        $Package.Add("InstallerVersion", $Version )
    }
    $Package.Add("Installer", $Installation)
    
    return $Package
}

# TESTS

#$inst = New-Object System.Collections.Hashtable
#$inst.Add("PackageLocation","\\server\Software\AdobeReader\Updates-new\")
#$inst.Add("PackageFile","\\server\Software\Skype\SkypeSetup-7.37.103.msi")
#$inst.Add("VersionFileMatch","^.*-(\d+\.\d+\.\d+)\.msp")

#$inst.Add("Type",3)
#$inst.Add("PackageFile","\\server\Software\Windows Fix\Windows Update\Windows Management Framework 5.1\Win7AndW2K8R2-KB3191566-x64-5.1.14409.1005.msu")
#$inst.Add("VersionFileMatch","^.*-(\d+\.\d+\.\d+\.\d+)\.msu")

#Get-JitenshaMatchedInstallerVersion $inst