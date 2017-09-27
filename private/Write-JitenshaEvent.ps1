Function Write-JitenshaEvent() {
    param(
        [System.String]$Message,
        
        [ValidateSet('information','warning','error')]
        [System.String]$EntryType,

        [System.Int32]$EventId
    )

    if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        $SourceExist = [System.Diagnostics.EventLog]::SourceExists($EventLogSource)

        if (!$SourceExist) {
            New-EventLog -LogName Application -Source $EventLogSource
        }

        Write-EventLog -LogName Application -Source $EventLogSource -EntryType $EntryType -Category 0 -EventId $EventId -Message $Message
    } 


}

#TEST
#$EventLogSource = "Jitensha Installer"
#Write-JitenshaEvent -Message "JitenshaTest" -EntryType "Error" -EventId 0
