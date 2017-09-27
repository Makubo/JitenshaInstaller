Function Install-JitenshaPackage() {
    param([System.Collections.Hashtable]$Package)

    switch ($Package.Type) {
        1 {
            $Message = "$($Package.Name): Run installation (EXE)"
            Write-Verbose $Message
            Write-JitenshaEvent -Message $Message -EntryType "Information" -EventId 1
            $Process = Start-Process $($Package.Installer) $($Package.InstallationKeys) -PassThru -Wait
            if ($Process.ExitCode -gt 0) {
                $Warning = "$($Package.Name): EXE installation trouble. Exit code $($process.ExitCode)"
            }
            #} catch {
                #Write-Error "Some problem with installation $($Package.Name)"
            #}
        }
        2 {
            $Message = "$($Package.Name): Run installation (MSI)"
            Write-Verbose $Message
            Write-JitenshaEvent -Message $Message -EntryType "Information" -EventId 1
            $Process = Start-Process "msiexec.exe" "/quiet /norestart /i `"$($Package.Installer)`"" -PassThru -Wait
            if ($Process.ExitCode -gt 0) {
                $Warning = "$($Package.Name): MSI installation trouble. Exit code $($process.ExitCode)"
                
            }
            
        } 
        <#
        3 {
            Write-Debug "Install - MSP"
        }
        #>
        4 {
            $Message = "$($Package.Name): Run installation (MSU)"
            Write-Verbose $Message
            Write-JitenshaEvent -Message $Message -EntryType "Information" -EventId 1
            $Process = Start-Process "wusa.exe" "/quiet /norestart `"$($Package.Installer)`"" -PassThru -Wait
            if ($Process.ExitCode -gt 0) {
                $Warning = "$($Package.Name): MSU installation trouble. Exit code $($process.ExitCode)"
            }
        }
        5 {
            $Message = "$($Package.Name): Run installation (Native)"
            Write-Verbose $Message
            Write-JitenshaEvent -Message $Message -EntryType "Information" -EventId 1
            $Process = Start-Process $Package.NativeInstall $Package.InstallKeys -PassThru -Wait -WindowStyle Hidden
            if ($Process.ExitCode -gt 0) {
                $Warning = "$($Package.Name): Native installation trouble. Exit code $($process.ExitCode)"
            }
        }
    }
    
    Write-Warning $Warning
    Write-JitenshaEvent -Message $Warning -EntryType "Error" -EventId 3

    if ($Package.UpdateVersion -gt $Package.InstalledVersion -and $Package.Update) {
        $Message = "$($Package.Name): Run installation (MSP)"
        Write-Verbose $Message
        Write-JitenshaEvent -Message $Message -EntryType "Information" -EventId 2
        $Process = Start-Process "msiexec.exe" "/quiet /norestart /update `"$($Package.Update)`"" -PassThru -Wait
        if ($Process.ExitCode -gt 0) {
            $Warning = "$($Package.Name): MSP installation trouble. Exit code $($process.ExitCode)"
            Write-Warning $Warning
            Write-JitenshaEvent -Message $Warning -EntryType "Error" -EventId 4
        }
    }

}
