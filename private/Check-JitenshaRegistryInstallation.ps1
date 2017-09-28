Function Check-JitenshaRegistryInstallation() {
    param([System.Collections.Hashtable]$Package)

    $Regx86 = "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\"
    $Regx64 = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"

    $Installation = $null

    Write-Debug "$($Package.Name): Search installation information in $Regx64"
    $ErrorActionPreference = "SilentlyContinue"
    $Installation = Foreach ($i in (Get-ChildItem -path "Registry::$Regx64")) {
        Get-ItemProperty $i.PSPath | Select DisplayName, DisplayVersion, UninstallString | Where-Object {$_.DisplayName -match $($Package.RegistryMatch)}
    }
    $ErrorActionPreference = "Continue"

    if (!$Installation -and $Is64Bit){
        Write-Debug "$($Package.Name): Search installation information in $Regx86"
        $ErrorActionPreference = "SilentlyContinue"
        $Installation = Foreach ($i in (Get-ChildItem -path "Registry::$Regx86")) {
            Get-ItemProperty $i.PSPath | Select DisplayName, DisplayVersion, UninstallString | Where-Object {$_.DisplayName -match $($Package.RegistryMatch)}
        }
        $ErrorActionPreference = "Continue" 
    }

    if ( $Installation ) {
        Write-Debug "$($Package.Name): Installaton is matched"
            
        if ($Installation -is [System.Array]) {
            $Max = [System.Version] "0.0.0.0"
            $Condidate = $null
               
            foreach ($Element in $Installation) {
                if ([System.Version]$Element.DisplayVersion -gt $Max) {
                    $Max = [System.Version]$Element.DisplayVersion
                    $Condidate = $Element
                }
            }
            $Installation = $Condidate
        }

        $Version = [System.Version]$Installation.DisplayVersion
        if ($Version.Revision -eq -1) {
            $Version = [System.Version]"$($Version.ToString()).0"
        }
        $Package.Add( "Installed" , $true )
        $Package.Add( "InstalledVersion", $Version )
        if ($Installation.UninstallString -match '{.*}'){
            $Package.Add( "ProductID", [regex]::Match($Installation.UninstallString, '({.*})').Groups[1].Value)
        }
    }
    
    
    return $Package
}

# TEST

#$inst = New-Object System.Collections.Hashtable
#$inst.Add("ProductID","{1845470B-EB14-4ABC-835B-E36C693DC07D}")
#$inst.Add("RegistryMatch","^Microsoft Visual C\+\+ 2015 Redistributable.*")
#$inst.Add("PackageFile","\\server\Software\dotNet\NDP461-KB3102436-x86-x64-AllOS-ENU.exe")
#$inst.Add("RegistryMatch","^Skype")

#$inst.Add("RegistryMatch","^Mozilla Firefox")

#$inst.Add("RegistryMatch","^Google Chrome")

#Check-JitenshaRegistryInstallation $inst
#(Check-RegistryInstallation $inst).gettype()

