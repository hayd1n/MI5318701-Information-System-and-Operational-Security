# 查詢系統中任何一個「進程創建」事件 (Event ID: 1)
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational'; Id=1} |
    Select-Object -Property TimeCreated, @{Name='Process'; Expression={($_.Properties[3].Value)}}, @{Name='ParentProcess'; Expression={($_.Properties[19].Value)}} |
    Select-Object -First 1 | Format-Table -AutoSize

# 查詢系統中任何一個「網路連線」事件 (Event ID: 3)
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational'; Id=3} |
    Select-Object -Property @{Name='SourceIP'; Expression={($_.Properties[9].Value)}}, 
                          @{Name='DestinationIP'; Expression={($_.Properties[14].Value)}}, 
                          @{Name='Process'; Expression={($_.Properties[3].Value)}},
                          @{Name='Image'; Expression={($_.Properties[4].Value)}} |
    Select-Object -First 1 | Format-Table -AutoSize


# 查詢系統中任何一個「檔案建立」事件 (Event ID: 11)
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational'; Id=11} |
    Select-Object -Property TimeCreated, @{Name='TargetFilename'; Expression={($_.Properties[5].Value)}}, @{Name='Process'; Expression={($_.Properties[3].Value)}}, @{Name='Image'; Expression={($_.Properties[5].Value)}} |
    Select-Object -First 1 | Format-Table -AutoSize
