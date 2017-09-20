function Get-JitenshaDotNetVersion {
    $MaxVersion=$null
    
    foreach ( $i in Get-ChildItem -Path  "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\" | Where-Object {$_.Name -notmatch 'CDF$|v4.0$'} ){
        $Version = [System.Version](Get-ItemProperty -Path ("Registry::{0}" -f $i)).Version

        if ($Version -eq $null){
            $Version = [System.Version](Get-ItemProperty -Path ("Registry::{0}\Full\" -f $i)).Version
        } 
    
        if ( $MaxVersion -lt $Version) {
            $MaxVersion = $Version
        }
    }

    if ($MaxVersion.Revision -eq -1) {
            $MaxVersion = [System.Version]"$($MaxVersion.ToString()).0"
    }

    return $MaxVersion
}

# TEST
# Get-JitenshaDotNetVersion