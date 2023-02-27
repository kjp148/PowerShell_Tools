# Credit for Format-Size function: https://stackoverflow.com/questions/57530347/how-to-convert-value-to-kb-mb-or-gb-depending-on-digit-placeholders
function Format-Size() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [double]$SizeInBytes
    )
    switch ([math]::Max($SizeInBytes, 0)) {
        {$_ -ge 1PB} {"{0:N2} PB" -f ($SizeInBytes / 1PB); break}
        {$_ -ge 1TB} {"{0:N2} TB" -f ($SizeInBytes / 1TB); break}
        {$_ -ge 1GB} {"{0:N2} GB" -f ($SizeInBytes / 1GB); break}
        {$_ -ge 1MB} {"{0:N2} MB" -f ($SizeInBytes / 1MB); break}
        {$_ -ge 1KB} {"{0:N2} KB" -f ($SizeInBytes / 1KB); break}
        default {"$SizeInBytes Bytes"}
    }
}

function Get-MemoryUsage()
{
    $Entry = ""
    while (@("q", "quit") -notcontains $Entry.ToLower())
    {
        $TotalMemory = 0
        $Programs = Get-Process
        foreach ($Program in $Programs)
        {
            $TotalMemory += $Program.WorkingSet
        }

        $FormattedPrograms = @()
        $MemoryTotal = 0
        ($Programs | Sort-Object -Descending -Property WorkingSet) | ForEach-Object {
            $MemoryTotal += $_.WorkingSet
            $FormattedPrograms += New-Object psobject -Property @{
                Name = $_.ProcessName
                Memory = (Format-Size $_.WorkingSet)
                MemTotal = (Format-Size $MemoryTotal)
                Title = $_.MainWindowTitle
                Path = $_.Path
            }
        }

        $FormattedPrograms | Format-Table -Property Name, Memory, MemTotal, Title, Path

        Write-Host "Total usage: " -NoNewline -ForegroundColor Yellow
        Write-Host (Format-Size $TotalMemory) -ForegroundColor White
        Write-Host "Press enter to run again or type Q to quit."
        Write-Host "> " -NoNewline
        $Entry = Read-Host
    }
}

Get-MemoryUsage