<#
.SYNOPSIS
模擬惡意程式安裝腳本 (Dropper)。
此腳本會:
1. 建立 C:\Scripts 目錄 (如果不存在)。
2. 將一個 PowerShell 酬載腳本 (fun_script.ps1) 寫入 C:\Scripts。
3. 設定 HKCU\...\Run 登錄檔機碼以在登入時執行 fun_script.ps1。
#>

# --- Configuration ---
$InstallDirectory = "C:\Scripts"
$ScriptName = "fun_script.ps1"
$ScriptToInstallPath = Join-Path -Path $InstallDirectory -ChildPath $ScriptName
$RegistryValueName = "MyFunAutoRunScript" # 登錄檔項目名稱
$RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"

# --- Payload Script Content (Embedded Here-String) ---
# 這部分是被植入的實際腳本內容
$PayloadScriptContent = @'
# Load Windows Forms Assembly for MessageBox
Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue

# Get User and Time Info
$UserName = $env:USERNAME
$CurrentTime = Get-Date -Format "HH:mm"
$LogFilePath = "$env:USERPROFILE\Desktop\fun_log.txt"

# Message Content
$PopupTitle = "🚀 每日登入檢查！"
$PopupMessage = "哈囉，$UserName！現在是 $CurrentTime 囉～ 今天也要充滿活力地開始！💪"
$LogMessage = "Popup displayed to $UserName at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')."

# Show Popup and Log
if ([System.Windows.Forms.MessageBox]) {
    [System.Windows.Forms.MessageBox]::Show($PopupMessage, $PopupTitle, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
} else {
    $LogMessage = "Failed to load System.Windows.Forms. Popup not displayed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')."
}
Add-Content -Path $LogFilePath -Value $LogMessage
'@

# --- Installation Logic ---
Write-Host "開始模擬惡意程式安裝過程..." -ForegroundColor Yellow

# 1. Ensure Installation Directory Exists
Write-Host "[+] 檢查/建立安裝目錄: $InstallDirectory"
if (-not (Test-Path $InstallDirectory -PathType Container)) {
    Write-Host "  目錄不存在，正在建立..."
    try {
        New-Item -Path $InstallDirectory -ItemType Directory -Force -ErrorAction Stop | Out-Null
        Write-Host "  成功建立目錄 '$InstallDirectory'" -ForegroundColor Green
    } catch {
        Write-Error "  無法建立目錄 '$InstallDirectory'。安裝中止。"
        exit 1 # 中止腳本
    }
} else {
    Write-Host "  目錄 '$InstallDirectory' 已存在。" -ForegroundColor Cyan
}

# 2. Write the Payload Script (植入酬載)
Write-Host "[+] 將酬載腳本寫入: $ScriptToInstallPath"
try {
    # 使用 UTF8 編碼以支援可能的特殊字元
    Set-Content -Path $ScriptToInstallPath -Value $PayloadScriptContent -Encoding UTF8 -Force -ErrorAction Stop
    Write-Host "  成功寫入酬載腳本 '$ScriptName'" -ForegroundColor Green
} catch {
    Write-Error "  無法寫入酬載腳本至 '$ScriptToInstallPath'。安裝中止。"
    Write-Error "  錯誤詳情: $($_.Exception.Message)"
    exit 1 # 中止腳本
}

# 3. Set the Registry Run Key for Persistence (建立持續性)
Write-Host "[+] 設定登錄檔 Run 機碼以實現持續性..."
$CommandToRun = "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptToInstallPath`""
Write-Host "  設定值名稱: $RegistryValueName"
Write-Host "  設定值內容: $CommandToRun"
try {
    # 使用 -Force 可以覆蓋同名現有項目
    Set-ItemProperty -Path $RegistryPath -Name $RegistryValueName -Value $CommandToRun -Force -ErrorAction Stop
    Write-Host "  成功設定登錄檔項目 '$RegistryValueName'" -ForegroundColor Green

    # 驗證寫入結果 (可選)
    # Write-Host "`n驗證登錄檔項目內容：" -ForegroundColor Cyan
    # Get-ItemProperty -Path $RegistryPath -Name $RegistryValueName
} catch {
    Write-Error "  無法設定登錄檔項目 '$RegistryValueName'。安裝中止。"
    Write-Error "  錯誤詳情: $($_.Exception.Message)"
    exit 1 # 中止腳本
}

Write-Host "`n[***] 模擬安裝完成！惡意行為腳本已植入並設定為自動執行。" -ForegroundColor Magenta
Write-Host "[***] 下次 '$env:USERNAME' 登入時，酬載腳本將會觸發。" -ForegroundColor Magenta