Function Install-JitenshaPackage() {
    param([System.Collections.Hashtable]$Package)

    switch ($Package.Type) {
        1 {
            Write-Verbose "$($Package.Name): Run installation (EXE)"
            #try {
            $Process = Start-Process $($Package.Installer) $($Package.InstallationKeys) -PassThru -Wait
            if ($Process.ExitCode -gt 0) {
                Write-Warning "$($Package.Name): EXE installation trouble. Exit code $($process.ExitCode)"
            }
            #} catch {
                #Write-Error "Some problem with installation $($Package.Name)"
            #}
        }
        2 {
            Write-Verbose "$($Package.Name): Run installation (MSI)"
            $Process = Start-Process "msiexec.exe" "/quiet /norestart /i `"$($Package.Installer)`"" -PassThru -Wait
            if ($Process.ExitCode -gt 0) {
                Write-Warning "$($Package.Name): MSI installation trouble. Exit code $($process.ExitCode)"
            }
            
        } 
        <#
        3 {
            Write-Debug "Install - MSP"
        }
        #>
        4 {
            Write-Verbose "$($Package.Name): Run installation (MSU)"
            $Process = Start-Process "wusa.exe" "/quiet /norestart `"$($Package.Installer)`"" -PassThru -Wait
            if ($Process.ExitCode -gt 0) {
                Write-Warning "$($Package.Name): MSU installation trouble. Exit code $($process.ExitCode)"
            }
        }
        5 {
            Write-Verbose "$($Package.Name): Run installation (Native)"
            $Process = Start-Process $Package.NativeInstall $Package.InstallKeys -PassThru -Wait -WindowStyle Hidden
            if ($Process.ExitCode -gt 0) {
                Write-Warning "$($Package.Name): Native installation trouble. Exit code $($process.ExitCode)"
            }
        }

    }
    if ($Package.UpdateVersion -gt $Package.InstalledVersion -and $Package.Update) {
        Write-Verbose "$($Package.Name): Run installation (MSP)"
        $Process = Start-Process "msiexec.exe" "/quiet /norestart /update `"$($Package.Update)`"" -PassThru -Wait
        if ($Process.ExitCode -gt 0) {
            Write-Warning "$($Package.Name): MSP installation trouble. Exit code $($process.ExitCode)"
        }
    }

}