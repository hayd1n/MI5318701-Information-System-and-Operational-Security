Get-Process | Sort-Object -Descending CPU | Select-Object -First 10 Name, Id, WorkingSet64
