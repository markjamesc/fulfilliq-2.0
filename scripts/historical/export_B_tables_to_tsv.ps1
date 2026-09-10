# FulfillIQ 2.0 - recovered B-table TSV export command
# Owner reports this export command was used on 2026-09-09.
# Transcribed from chat: line breaks restored and Markdown escapes removed.
# Public-copy change: original local destination replaced by -DataDirectory.
# The mysql SELECT/pipeline is preserved; this copy has not been executed.
# Prerequisite: B_orders/B_items/B_sellers exist with verified snapshot metadata.
# See docs/EXPORT_HISTORY.md before use.
param(
    [Parameter(Mandatory = $true)]
    [string]$DataDirectory
)

$data = $DataDirectory
New-Item -ItemType Directory -Force -Path $data | Out-Null
$mysql = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"

foreach ($t in @('B_orders', 'B_items', 'B_sellers')) {
    $out = Join-Path $data "$t.tsv"
    Write-Host "Exporting $t -> $out"
    & $mysql --login-path=fulfilliq fulfilliq --batch --raw -e "SELECT * FROM $t" | Set-Content -Encoding utf8 $out
    Write-Host "  bytes=$((Get-Item $out).Length)"
}

Get-Content (Join-Path $data 'B_sellers.tsv') -TotalCount 2
