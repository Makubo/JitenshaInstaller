if ($PSVersionTable.PSVersion.Major -gt 2) {
    Import-Module "..\JitenshaInstaller" -DisableNameChecking
} else {
    Import-Module "..\JitenshaInstaller-ps2.0" -DisableNameChecking
}
# for start files downloaded from internet
$env:SEE_MASK_NOZONECHECKS = 1
Run-JitenshaInstaller
#| Start-Transcript -Path "..\logs\transcript.txt"