Function Get-JitenshaMatchedUpdateVersion() {
    param([System.Collections.Hashtable]$Package)
    Write-Debug "$($Package.Name): Updates matching"
    if ($Package.UpdateLocation -and $Package.UpdateVersionFileMatch) {
        $Update = $null
        ForEach ($Updater in Get-ChildItem -Path "$($Package.UpdateLocation)*" -include *.msp){
            if ($Update -eq $null) {
                $Update = $Updater
            } elseif ([System.Version]([regex]::Match($Updater, $Package.UpdateVersionFileMatch).Groups[1].Value) -gt [System.Version]([regex]::Match($Update, $Package.UpdateVersionFileMatch).Groups[1].Value)) {
                $Update = $Updater
            }
        }
        $Version = [System.Version][regex]::Match($Update, $Package.UpdateVersionFileMatch).Groups[1].Value
        if ($Version.Revision -eq -1) {
            $Version = [System.Version]"$($Version.ToString()).0"
        }
    }
    if ($Version) {
        Write-Debug "$($Package.Name): Update is matched"
        $Package.Add("UpdateVersion", $Version )
    }
    $Package.Add("Update", $Update )
    
    return $Package
}

# TESTS

#$inst = New-Object System.Collections.Hashtable
#$inst.Add("UpdateLocation","\\server\Software\AdobeReader\Updates-new\")
#$inst.Add("UpdateVersionFileMatch","^.*-(\d+\.\d+\.\d+)\.msp")
#Get-JitenshaMatchedUpdateVersion $inst