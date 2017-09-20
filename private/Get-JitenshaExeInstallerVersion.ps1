Function Get-JitenshaExeInstallerVersion() {
    param([System.Collections.Hashtable]$Package)

    if ($Package.PackageFile -ne $null) {
        $Version = [System.Version][System.Diagnostics.FileVersionInfo]::GetVersionInfo($Package.PackageFile).FileVersion
        if ($Version.Revision -eq -1) {
            $Version = [System.Version]"$($Version.ToString()).0"
        }
    } elseif ($Package.PackageLocation -ne $null) {
        $Installation = $null
        ForEach ($exe in Get-ChildItem -Path "$($Package.PackageLocation)*" -include *.exe){
            if ($Installation -eq $null) {
                $Installation = $exe
            } elseif ([System.Version][System.Diagnostics.FileVersionInfo]::GetVersionInfo($exe).FileVersion -gt [System.Version][System.Diagnostics.FileVersionInfo]::GetVersionInfo($Installation).FileVersion) {
                $Installation = $exe
            }
        }
        $Version = [System.Version][System.Diagnostics.FileVersionInfo]::GetVersionInfo($Installation).FileVersion
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
#$inst.Add("PackageLocation","\\server\Software\dotNet\")
#$inst.Add("PackageFile","\\server\Software\dotNet\NDP461-KB3102436-x86-x64-AllOS-ENU.exe")

#Get-ExeInstallerVersion $inst