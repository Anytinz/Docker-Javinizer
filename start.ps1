param(
    [String]$Interval ,
    [String]$SetEmbyActorThumbs
)

Import-Module /Javinizer/Javinizer.psm1
$env:PSModulePath

if( Get-Module -ListAvailable PoshRSJob ) {
}
else {
    Install-Module -Force PoshRSJob
}

for( $i=1 ; $i -gt 0 ; $i++ ) {   
    if( $SetEmbyActorThumbs -eq "Enable" ) {
        Javinizer -SetEmbyActorThumbs
    }
    Javinizer -Apply -Multi -Path /jav -DestinationPath /jav
    Start-Sleep -s $Interval
}