$endpoints = @(
    "/admin",
    "/config",
    "/management",
    "/roles",
    "/settings",
    "/system",
    "/internal"
)

$methods = @("GET","POST","PATCH","DELETE","OPTIONS")

$token = ""

# Output file
$outfile = "probe_results.txt"
if (Test-Path $outfile) { Remove-Item $outfile }

foreach ($endpoint in $endpoints) {
    foreach ($method in $methods) {
        Write-Host "Testing $method $endpoint"

        try {
            $response = Invoke-WebRequest -Uri "$endpoint" `
                -Method $method `
                -Headers @{
                    "Authorization" = "Bearer $token"
                    "Content-Type"  = "application/json"
                }

            "### $method $endpoint" | Out-File -Append $outfile
            $response.StatusCode | Out-File -Append $outfile
            $response.RawContent | Out-File -Append $outfile
            "`n" | Out-File -Append $outfile
        }
        catch {
            "### $method $endpoint" | Out-File -Append $outfile
            $_.Exception.Message | Out-File -Append $outfile
            "`n" | Out-File -Append $outfile
        }
    }
}
