Function Update-JitenshaPackage() {
    param([System.Collections.Hashtable]$Package)

    if ($Package.InstalledVersion -and $Package.InstallerVersion -and ($Package.InstallerVersion -gt $Package.InstalledVersion) ){
        switch ($Package.Type) {
            1 {
                Write-Verbose "$($Package.Name): Run update (EXE)"
                $Process = Start-Process $($Package.Installer) $($Package.InstallationKeys) -PassThru -Wait
                if ($process.ExitCode -gt 0) {
                    Write-Warning "$($Package.Name): EXE update trouble. Exit code $($process.ExitCode)"
                }
            }
            2 {
                Write-Verbose "$($Package.Name): Run update (MSI)"
                $Process = Start-Process "msiexec.exe" "/quiet /norestart /x `"$($Package.ProductID)`"" -PassThru -Wait
                if ($Process.ExitCode -gt 0) {
                    Write-Warning "$($Package.Name): MSI uninstall trouble. Exit code $($process.ExitCode)"
                }
                $Process = Start-Process "msiexec.exe" "/quiet /norestart /i `"$($Package.Installer)`"" -PassThru -Wait
                if ($process.ExitCode -gt 0) {
                    Write-Warning "$($Package.Name): MSI update trouble. Exit code $($process.ExitCode)"
                }
            }
            <#
            3 {
                Write-Debug "Update - MSP"
            }
            #>
            4 {
                Write-Verbose "$($Package.Name): Run update (MSU)"
                $Process = Start-Process "wusa.exe" "/quiet /norestart `"$($Package.Installer)`"" -PassThru -Wait
                if ($process.ExitCode -gt 0) {
                    Write-Warning "$($Package.Name): MSU update trouble. Exit code $($process.ExitCode)"
                }
            }
            5 {
                Write-Verbose "$($Package.Name): Run update (Native)"
                $Process = Start-Process $Package.NativeUpdate $Package.UpdateKeys -PassThru -Wait -WindowStyle Hidden
                if ($process.ExitCode -gt 0) {
                    Write-Warning "$($Package.Name): Native update trouble. Exit code $($process.ExitCode)"
                }
            }
        }
    }
    if ($Package.UpdateVersion -gt $Package.InstalledVersion -and $Package.Update) {
        Write-Verbose "$($Package.Name): Run update (MSP)"
        $Process = Start-Process "msiexec.exe" "/quiet /norestart /update `"$($Package.Update)`"" -PassThru -Wait
        if ($process.ExitCode -gt 0) {
            Write-Warning "$($Package.Name): MSP update trouble. Exit code $($process.ExitCode)"
        }
    }
}