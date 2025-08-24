param(
    [string]$jwt1 = "",
    [string]$jwt2 = ""
)

function Get-Settings($jwt) {
    $url = ""
    $headers = @{ "Authorization" = "Bearer $jwt" }
    try {
        $resp = Invoke-WebRequest -Uri $url -Headers $headers -Method GET -UseBasicParsing
        return $resp.Content | ConvertFrom-Json
    } catch {
        Write-Host "Error calling /settings with token: $jwt"
        return $null
    }
}

function Decode-PublicKey($b64key) {
    if (-not $b64key) { return "" }
    $bytes = [System.Convert]::FromBase64String($b64key)
    return [System.Text.Encoding]::UTF8.GetString($bytes)
}

Write-Host "=== Testing Account 1 (rca63) ==="
$settings1 = Get-Settings $jwt1
$settings1 | ConvertTo-Json -Depth 5
$decoded1 = Decode-PublicKey $settings1.data.advance_search.public_key

Write-Host "`n=== Testing Account 2 (rca64) ==="
$settings2 = Get-Settings $jwt2
$settings2 | ConvertTo-Json -Depth 5
$decoded2 = Decode-PublicKey $settings2.data.advance_search.public_key

Write-Host "`n=== Comparison ==="
Write-Host "Account 1 public_key: $($settings1.data.advance_search.public_key)"
Write-Host "Decoded: $decoded1"
Write-Host ""
Write-Host "Account 2 public_key: $($settings2.data.advance_search.public_key)"
Write-Host "Decoded: $decoded2"

Read-Host -Prompt "Press Enter to exit"