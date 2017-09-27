Function Update-JitenshaPackage() {
    param([System.Collections.Hashtable]$Package)

    if ($Package.InstalledVersion -and $Package.InstallerVersion -and ($Package.InstallerVersion -gt $Package.InstalledVersion) ){
        switch ($Package.Type) {
            1 {
                $Message = "$($Package.Name): Run update (EXE)"
                Write-Verbose $Message
                Write-JitenshaEvent -Message $Message -EntryType "Information" -EventId 5
                $Process = Start-Process $($Package.Installer) $($Package.InstallationKeys) -PassThru -Wait
                if ($process.ExitCode -gt 0) {
                    $Warning = "$($Package.Name): EXE update trouble. Exit code $($process.ExitCode)"
                }
            }
            2 {
                $Message = "$($Package.Name): Run update (MSI)"
                Write-Verbose $Message
                Write-JitenshaEvent -Message $Message -EntryType "Information" -EventId 5
                $Process = Start-Process "msiexec.exe" "/quiet /norestart /x `"$($Package.ProductID)`"" -PassThru -Wait
                if ($Process.ExitCode -gt 0) {
                    $Warning = "$($Package.Name): MSI uninstall trouble. Exit code $($process.ExitCode)"
                    Write-Warning $Warning
                    Write-JitenshaEvent -Message $Warning -EntryType "Error" -EventId 6
                }
                $Process = Start-Process "msiexec.exe" "/quiet /norestart /i `"$($Package.Installer)`"" -PassThru -Wait
                if ($process.ExitCode -gt 0) {
                    $Warning = "$($Package.Name): MSI update trouble. Exit code $($process.ExitCode)"
                }
            }
            <#
            3 {
                Write-Debug "Update - MSP"
            }
            #>
            4 {
                $Message = "$($Package.Name): Run update (MSU)"
                Write-Verbose $Message
                Write-JitenshaEvent -Message $Message -EntryType "Information" -EventId 5
                $Process = Start-Process "wusa.exe" "/quiet /norestart `"$($Package.Installer)`"" -PassThru -Wait
                if ($process.ExitCode -gt 0) {
                    $Warning = "$($Package.Name): MSU update trouble. Exit code $($process.ExitCode)"
                }
            }
            5 {
                $Message = "$($Package.Name): Run update (Native)"
                Write-Verbose $Message
                Write-JitenshaEvent -Message $Message -EntryType "Information" -EventId 5
                $Process = Start-Process $Package.NativeUpdate $Package.UpdateKeys -PassThru -Wait -WindowStyle Hidden
                if ($process.ExitCode -gt 0) {
                    $Warning = "$($Package.Name): Native update trouble. Exit code $($process.ExitCode)"
                }
            }
        }
        Write-Warning $Warning
        Write-JitenshaEvent -Message $Warning -EntryType "Error" -EventId 7
    }
    if ($Package.UpdateVersion -gt $Package.InstalledVersion -and $Package.Update) {
        $Message = "$($Package.Name): Run update (MSP)"
        Write-Verbose $Message
        Write-JitenshaEvent -Message $Message -EntryType "Information" -EventId 8
        $Process = Start-Process "msiexec.exe" "/quiet /norestart /update `"$($Package.Update)`"" -PassThru -Wait
        if ($process.ExitCode -gt 0) {
            $Warning = "$($Package.Name): MSP update trouble. Exit code $($process.ExitCode)"
            Write-Warning $Warning
            Write-JitenshaEvent -Message $Warning -EntryType "Error" -EventId 9
        }
    }
}
