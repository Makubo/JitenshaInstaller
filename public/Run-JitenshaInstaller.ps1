function Run-JitenshaInstaller{

#DEBUG
    $DebugPreference = "Continue"
    $VerbosePreference = "Continue"

    Write-JitenshaEvent -Message "Jitensha Installer is started`nWindows version: $([System.Environment]::OSVersion.Version)`nPowershell version: $($PSVersionTable.PSVersion.ToString())" -EntryType "Information" -EventId 0

    # Workaround for Powershell 2.0
    #if ($PSScriptRoot -eq $null) {
    #    Write-Host Setting $`PSScriptRoot variable
    #    $PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path
    #}

    #Import-module $PSScriptRoot\..\private\Get-JitenshaChocolateyVersion.ps1
    #Import-module $PSScriptRoot\..\private\Get-JitenshaDotNetVersion.ps1
    #Import-module $PSScriptRoot\..\private\Get-JitenshaPackageList.ps1
    #Import-module $PSScriptRoot\..\private\Get-JitenshaInstallerVersion.ps1
    #Import-module $PSScriptRoot\..\private\Check-JitenshaInstallation.ps1
    #Import-module $PSScriptRoot\..\private\Install-JitenshaPackage.ps1
    #Import-module $PSScriptRoot\..\private\Update-JitenshaPackage.ps1
    #Import-module $PSScriptRoot\..\private\Get-JitenshaChocolateyInstallerVersion.ps1
    #Import-module $PSScriptRoot\..\private\Get-JitenshaMatchedUpdateVersion.ps1
    #Import-module $PSScriptRoot\..\private\Get-JitenshaMatchedInstallerVersion.ps1
    
# Create tray icon
# https://bytecookie.wordpress.com/2011/12/28/gui-creation-with-powershell-part-2-the-notify-icon-or-how-to-make-your-own-hdd-health-monitor/
#    
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
    
    $NotifyIcon = New-Object System.Windows.Forms.NotifyIcon
    $NotifyIcon.Icon = $Icon
    #= New-Object System.Drawing.Icon("$PSScriptRoot\icons\jitensha.ico")
    $NotifyIcon.BalloonTipTitle = "Software installation"
    $NotifyIcon.Text = "Software installation script"
    $NotifyIcon.Visible = $True
#
# End of creation tray icon

    $WindowsVersion = [System.Environment]::OSVersion.Version
    $Is64Bit = [System.Environment]::Is64BitOperatingSystem

    $PackageList = New-Object System.Collections.ArrayList
    $PackageList = Get-JitenshaPackageList

    ForEach ($Package in $PackageList) {
        if ($package.Name) {
            Write-Verbose "$($Package.Name): Load package information"
        }

        $Package = Check-JitenshaInstallation $Package
       
        $Package = Get-JitenshaInstallerVersion $Package
   
    }
    
    ForEach ($Package in $PackageList) {
        $Package | Format-Table
    }

    ForEach ($Package in $PackageList) {
    
        if ($Package.Architecture -and $Package.Architecture -eq "x86" -and $Is64Bit) {
            Continue
        }

        if ($Package.Architecture -and $Package.Architecture -eq "x64" -and !$Is64Bit) {
            Continue
        }

        if ($Package.WinVersion -and $Package.WinVersion -ne ("$($WindowsVersion.Major).$($WindowsVersion.Minor)")) {
            Continue
        }

        if ($Package.Installed) {
            if ($Package.Autoupdate) {
                $NotifyIcon.BalloonTipText = "Update $($Package.Name)"
                $NotifyIcon.ShowBalloonTip(2)
                Update-JitenshaPackage $Package
            }
        } else {
            $Conflict = $false
            if ($Package.Conflict) {
                foreach ($ConflictPackageName in $Package.Conflict) {
                    foreach ($ConflictPackage in $PackageList) {
                        if ($ConflictPackage.Name -eq $ConflictPackageName -and $ConflictPackage.Installed) {
                            $Warning = "$($Package.Name): installation is conflict with installed $ConflictPackageName"
                            Write-Warning $Warning
                            Write-JitenshaEvent -Message $Warning -EntryType "Warning" -EventId 0
                            $Conflict = $true
                        }
                    }
                }
            }
            if ($Package.Autoinstallation -and !$Conflict) {
                $NotifyIcon.BalloonTipText = "Installation $($Package.Name)"
                $NotifyIcon.ShowBalloonTip(2)
                Install-JitenshaPackage $Package
            }
        }
    }
    $NotifyIcon.Visible = $False

    Write-JitenshaEvent -Message "Jitensha Installer's job is done" -EntryType "Information" -EventId 0
}

#Run-JitenshaInstaller
