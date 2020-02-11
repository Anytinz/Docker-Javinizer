if( Get-Module -ListAvailable PoshRSJob ) {
    break
}
else {
    Install-Module -Force PoshRSJob
}

Import-Module /Javinizer/Javinizer.psm1
$env:PSModulePath

for( $i=1 ; $i -gt 0 ; $i++ ) {   
    if( $SET_EMBY_ACTOR_THUMBS ) {
        Javinizer -SetEmbyActorThumbs
    }
    Javinizer -Apply -Multi -Path /jav -DestinationPath /jav
    Start-Sleep -s 300
}