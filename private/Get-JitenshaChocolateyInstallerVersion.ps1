function Get-JitenshaChocolateyPackageVersion{
    param(
        [System.Collections.Hashtable]$Package,
        [switch]$Local
    )
    if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        
        if ($Local) {
            $l = "l"
            $VersionParameter = "InstalledVersion"
        } else {
            $VersionParameter = "InstallerVersion"
        }

        ## https://stackoverflow.com/questions/8761888/capturing-standard-out-and-error-with-start-process
        $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
        $ProcessInfo.FileName = "choco.exe"
        $ProcessInfo.RedirectStandardError = $true
        $ProcessInfo.RedirectStandardOutput = $true
        $ProcessInfo.UseShellExecute = $false
        $ProcessInfo.CreateNoWindow = $true
        $ProcessInfo.Arguments = "search $($Package.ChocoPackage) -${l}"
        $Process = New-Object System.Diagnostics.Process
        $Process.StartInfo = $ProcessInfo
        $Process.Start() | Out-Null
        #$Process.WaitForExit()
        
        $ChocoOutput = $Process.StandardOutput.ReadToEnd()

        if ($ChocoOutput -ne "") {
            $Match = [regex]::Match( $ChocoOutput, "(?i)(\n|^)$($Package.ChocoPackage)\s(\d+\.\d+\.\d+(\.\d+)?)" )
            
            if ($Match.Success) {
                $Version = [System.Version] $Match.Groups[2].Value
                
                if ($Version.Revision -eq -1) {
                    $Version = [System.Version]"$($Version.ToString()).0"
                }
                $Package.Add($VersionParameter,$Version)
                if ($Local) {
                    $Package.Add("Installed",$true)
                }
            }
        }
    }
    return $Package
}

#TEST

#$inst = New-Object System.Collections.Hashtable
#$inst.Add("ChocoPackage","chocolatey")

#Get-JitenshaChocolateyPackageVersion $inst -Local