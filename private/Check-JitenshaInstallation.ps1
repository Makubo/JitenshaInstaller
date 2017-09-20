# Workaround for Powershell 2.0
#if ($PSScriptRoot -eq $null) {
#    Write-Host Setting $`PSScriptRoot variable
#    $PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path
#}

#Import-module $PSScriptRoot\Check-RegistryInstallation.ps1

Function Check-JitenshaInstallation() {
    param([System.Collections.Hashtable]$Package)

    if ($Package.RegistryMatch) {
        Write-Debug "$($Package.Name): Installation Registry Check"
        $Package = Check-JitenshaRegistryInstallation $Package
    }
    
    if ($Package.ProductID -and $Package.ProductID -match "KB.*") {
        Write-Debug "$($Package.Name): Installation KB Check"
        if ( ( Get-HotFix | Where-Object {$_.HotFixID -eq "$($Package.ProductID)"} ) ) {
            $Package.Add( "Installed" , $true )
        }
    }
    
    if ($Package.ChocoPackage -and !$Package.Installed){
            $Package = Get-JitenshaChocolateyPackageVersion $Package -Local
    }

    if ($Package.NativeInstalledCheck) {
        Write-Debug "$($Package.Name): Installation Native Check"
        $Version = Invoke-Expression $Package.NativeInstalledCheck
        if ($Version) {
            $Package.Add( "Installed" , $true )
            $Package.Add( "InstalledVersion", $Version )
        }
    }
    return $Package
}

#TEST

#$inst = New-Object System.Collections.Hashtable
#$inst.Add("NativeInstalledCheck","${$PSVersionTable.PSversion}")
#$inst.Add("PackageFile","\\server\Software\Skype\SkypeSetup-7.37.103.msi")
#$inst.Add("NativeCheck","Get-ChocolateyVersion")
#$inst.Add("RegistryMatch","^Google Chrome")


#Check-Installation $inst