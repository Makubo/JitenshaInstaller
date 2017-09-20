# GET FROM http://www.snowland.se/2010/02/21/read-msi-information-with-powershell/    
    
    # Load some TypeData
    #$SavedEA = $Global:ErrorActionPreference
    #$Global:ErrorActionPreference = "SilentlyContinue"
    #Update-TypeData -AppendPath ((Split-Path -Parent $MyInvocation.MyCommand.Path) + "\..\types\comObject.types.ps1xml")
        #Update-TypeData -AppendPath $PSScriptRoot + "\types\comObject.types.ps1xml"
    #$Global:ErrorActionPreference = $SavedEA

function Get-JitenshaMsiProperties {
    PARAM (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="MSI Database Filename",ValueFromPipeline=$true)]
        [Alias("Filename","Path","Database","Msi")]
        $msiDbName
    )

    # A quick check to see if the file exist
    if(!(Test-Path $msiDbName)){
        throw "Could not find " + $msiDbName
    }
 
    # Create an empty hashtable to store properties in
    $msiProps = New-Object System.Collections.Hashtable
     
    # Creating WI object and load MSI database
    $wiObject = New-Object -com WindowsInstaller.Installer
    $wiDatabase = $wiObject.InvokeMethod("OpenDatabase", (Resolve-Path $msiDbName).ProviderPath, 0)
     
    # Open the Property-view
    $view = $wiDatabase.InvokeMethod("OpenView", "SELECT * FROM Property")
    [Void]$view.InvokeMethod("Execute")
     
    # Loop thru the table
    $r = $view.InvokeMethod("Fetch")
    while($r -ne $null) {
        # Add property and value to hash table
        $msiProps.Add([String]($r.InvokeParamProperty("StringData",1)),[String]($r.InvokeParamProperty("StringData",2)))
        #$msiProps[$r.InvokeParamProperty("StringData",1)] = $r.InvokeParamProperty("StringData",2)
         
        # Fetch the next row
        $r = $view.InvokeMethod("Fetch")
    }

    [Void]$view.InvokeMethod("Close")
    
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$wiObject) | out-null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()

    # Return the hash table
    return $msiProps
}

#Get-JitenshaMsiProperties "\\server\Software\Skype\SkypeSetup-7.35.101.msi"
