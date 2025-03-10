# 下載 Sysmon
$sysmonZip = "$env:TEMP\Sysmon.zip"
$sysmonDir = "$env:TEMP\Sysmon"
$sysmonExe = "$sysmonDir\Sysmon64.exe"
$configFile = "$sysmonDir\sysmonconfig.xml"

Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip" -OutFile $sysmonZip

# 解壓縮 Sysmon.zip
Expand-Archive -Path $sysmonZip -DestinationPath $sysmonDir -Force

# 下載 Sysmon 設定檔
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -OutFile $configFile

# 安裝 Sysmon
Start-Process -FilePath $sysmonExe -ArgumentList "-accepteula -i" -Wait

# 載入設定
Start-Process -FilePath $sysmonExe -ArgumentList "-c $configFile" -NoNewWindow -Wait

# 清理安裝檔案
Remove-Item -Path $sysmonZip -Force
