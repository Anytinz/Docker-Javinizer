param(
    [String]$Interval ,
    [String]$SetEmbyThumbs
)

$config_folder = "/Javinizer/config"

echo "\n" | cp -i /Javinizer/jvSettings.json $config_folder >/dev/null 2>&1
echo "\n" | cp -i /Javinizer/jvThumbs.csv $config_folder >/dev/null 2>&1
echo "\n" | cp -i /Javinizer/jvGenres.csv $config_folder >/dev/null 2>&1
echo "\n" | cp -i /Javinizer/jvUncensor.csv $config_folder >/dev/null 2>&1

cp $config_folder/jvSettings.json /Javinizer/jvSettings-Docker.json

sed -i 's#.*\"location.input\".*#\    \"location.input\": \"/jav\",#' /Javinizer/jvSettings-Docker.json
sed -i 's#.*\"location.output\".*#\    \"location.output\": \"/jav\",#' /Javinizer/jvSettings-Docker.json
sed -i 's#.*\"location.thumbcsv\".*#\    \"location.thumbcsv\": \"/Javinizer/config/jvThumbs.csv\",#' /Javinizer/jvSettings-Docker.json
sed -i 's#.*\"location.genrecsv\".*#\    \"location.genrecsv\": \"/Javinizer/config/jvGenres.csv\",#' /Javinizer/jvSettings-Docker.json
sed -i 's#.*\"location.uncensorcsv\".*#\    \"location.uncensorcsv\": \"/Javinizer/config/jvUncensor.csv\",#' /Javinizer/jvSettings-Docker.json
sed -i 's#.*\"location.log\".*#\    \"location.log\": \"/Javinizer/jvLog.log\",#' /Javinizer/jvSettings-Docker.json
sed -i 's#.*\"admin.log\".*#\    \"admin.log\": 0,#' /Javinizer/jvSettings-Docker.json

rm /Javinizer/jvLog.log >/dev/null 2>&1
rm /Javinizer/admin.log >/dev/null 2>&1

Import-Module /Javinizer/Javinizer.psm1
$env:PSModulePath >/dev/null 2>&1

for( $i=1 ; $i -gt 0 ; $i++ ) {   
    if( $SetEmbyThumbs -eq "Enable" ) {
        Write-Host "Start setting Emby/Jellyfin actress thumbnails using the thumbnail csv."
        Javinizer -SetEmbyThumbs -Debug
        Write-Host "End of Set Emby/Jellyfin actress thumbnails."
    }
    Write-Host "Start using Javinizer to scrape and sort."
    Javinizer -SettingsPath /Javinizer/jvSettings-Docker.json -HideProgress -Debug
    Write-Host "End of the scrape. $Interval seconds to the next scrape."
    Start-Sleep -s $Interval
} 