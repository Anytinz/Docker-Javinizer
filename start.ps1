$config_folder = '/Javinizer/config'

if(!(Test-Path $config_folder/jvSettings.json))
{
    Copy-Item /Javinizer/jvSettings.json $config_folder
}

if(!(Test-Path $config_folder/jvThumbs.csv))
{
    Copy-Item /Javinizer/jvThumbs.csv $config_folder
}

if(!(Test-Path $config_folder/jvGenres.csv))
{
    Copy-Item /Javinizer/jvGenres.csv $config_folder
}
if(!(Test-Path $config_folder/jvUncensor.csv))
{
    Copy-Item /Javinizer/jvUncensor.csv $config_folder
}

Copy-Item $config_folder/jvSettings.json /Javinizer

sed -i 's#.*\"location.input\".*#\    \"location.input\": \"/jav\",#' /Javinizer/jvSettings.json
sed -i 's#.*\"location.output\".*#\    \"location.output\": \"/jav\",#' /Javinizer/jvSettings.json
sed -i 's#.*\"location.thumbcsv\".*#\    \"location.thumbcsv\": \"/Javinizer/config/jvThumbs.csv\",#' /Javinizer/jvSettings.json
sed -i 's#.*\"location.genrecsv\".*#\    \"location.genrecsv\": \"/Javinizer/config/jvGenres.csv\",#' /Javinizer/jvSettings.json
sed -i 's#.*\"location.uncensorcsv\".*#\    \"location.uncensorcsv\": \"/Javinizer/config/jvUncensor.csv\",#' /Javinizer/jvSettings.json
sed -i 's#.*\"location.log\".*#\    \"location.log\": \"/Javinizer/jvLog.log\",#' /Javinizer/jvSettings.json
sed -i 's#.*\"admin.log\".*#\    \"admin.log\": 0,#' /Javinizer/jvSettings.json

Remove-Item /Javinizer/jvLog.log
Remove-Item /Javinizer/admin.log

$jav_folder = '/jav'
$timeout = 1000

Import-Module /Javinizer/Javinizer.psm1
$null = $env:PSModulePath

Write-Host "Javinizer Start"

if((Test-Path $jav_folder/*.*))
{
    Javinizer -HideProgress -Verbose
}

$FileSystemWatcher = New-Object System.IO.FileSystemWatcher $jav_folder

while ($true) {
    $result = $FileSystemWatcher.WaitForChanged('Created', $timeout)

    if ($result.TimedOut -eq $false) {
        Javinizer -HideProgress -Verbose
    }
}
