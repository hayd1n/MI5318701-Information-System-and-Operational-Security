$startTime = (Get-Date).AddHours(-24)
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4624; StartTime=$startTime} |
Select-Object -First 10 TimeCreated, @{Name='LogonType'; Expression={$_.Properties[8].Value}}, @{Name='UserName'; Expression={$_.Properties[5].Value}}
