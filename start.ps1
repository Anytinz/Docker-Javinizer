Import-Module /Javinizer/Javinizer.psm1
$env:PSModulePath

for( $i=1 ; $i -gt 0 ; $i++ )
{
    Javinizer -Apply -Multi
    Start-Sleep -s 300
}
