function Get-JitenshaPackageList() {
    $PackageList = New-Object System.Collections.ArrayList
    ForEach ( $Package in Get-ChildItem -Path  "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Jitensha\Installer\Packages" ) {
        $Propertyes = (Get-JitenshaLevelPropertyes $Package)
        if ( ((Get-ChildItem -Path "Registry::$Package").count -eq 0) -or ((Get-ChildItem -Path "Registry::$Package").count -eq $null) ){
            [Void]$PackageList.Add($Propertyes)
        } else {
            foreach ( $WinVer in Get-ChildItem -Path "Registry::$Package") {
                $SecondLevelPropertyes = $Propertyes
                if ( $WinVer.Name -match "\d?\.\d" ) {
                    $SecondLevelPropertyes += (Get-JitenshaLevelPropertyes $WinVer)
                    [Void]$SecondLevelPropertyes.Add("WinVersion", (($WinVer | Select -ExpandProperty "Name").Split("\") | Select-Object -Last 1))
                    if ( (Get-ChildItem -Path "Registry::$WinVer").count -eq 0 ){
                        [Void]$PackageList.Add( $SecondLevelPropertyes )
                    } else {
                        foreach ( $Arch in Get-ChildItem -Path "Registry::$WinVer") {
                            $ThirdLevelPropertyes = $SecondLevelPropertyes
                            if ( $Arch.Name -match "x64|x86") {
                                $ThirdLevelPropertyes += (Get-JitenshaLevelPropertyes $Arch)
                                $ThirdLevelPropertyes.Add("Architecture", (($Arch | Select -ExpandProperty "Name").Split("\") | Select-Object -Last 1))
                            }
                            [Void]$PackageList.Add( $ThirdLevelPropertyes )
                        }
                    }
                } elseif ( $WinVer.Name -match "x64|x86") {
                    $SecondLevelPropertyes += (Get-JitenshaLevelPropertyes $WinVer)
                    $SecondLevelPropertyes.Add("Architecture", (($WinVer | Select -ExpandProperty "Name").Split("\") | Select-Object -Last 1))
                    [Void]$PackageList.Add( $SecondLevelPropertyes )
                }
            }
            
        }
    }
    return $PackageList
}

function Get-JitenshaLevelPropertyes {

    param([System.MarshalByRefObject]$Package)

    $Propertyes = New-Object System.Collections.Hashtable
            
    ForEach ( $Property in (Get-Item -Path "Registry::$Package" | Select-Object -ExpandProperty Property) ) {
    #ForEach ( $Property in $Package.Property ) {
        $Value = (Get-ItemProperty -Path "Registry::$Package").$Property
        if (($Property -eq "Autoinstallation") -or ($Property -eq "Autoupdate")) {
            $Propertyes.Add($Property, [System.Convert]::ToBoolean($Value))
        } else {
            $Propertyes.Add($Property, $Value)
        }
    }

    return $Propertyes

}

#Get-JitenshaPackageList
