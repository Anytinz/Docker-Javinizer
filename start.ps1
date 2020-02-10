if( Get-Module -ListAvailable PoshRSJob ){
    Install-Module -Force PoshRSJob
}

Import-Module /Javinizer/Javinizer.psm1
$env:PSModulePath

for( $i=1 ; $i -gt 0 ; $i++ )
{   
    if( $Enable_Emby_Actors ){
        Javinizer -SetEmbyActorThumbs
    }
    Javinizer -Apply -Multi -Path /jav -DestinationPath /jav
    Start-Sleep -s 300

}