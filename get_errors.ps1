$lines = Get-Content "temp_analyze.txt"
$lines | ForEach-Object { [System.Console]::WriteLine($_) }
