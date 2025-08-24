# probe_settings.ps1
$base = "https://api.anytask.com/settings"
$headers = @{
    "Authorization" = "Bearer "
    "Content-Type"  = "application/json"
}

Write-Host "=== Testing GET /settings ==="
$response = Invoke-WebRequest -Uri $base -Headers $headers -Method GET
$response.Content | Out-File "settings_get.json"
Write-Host "Saved original response to settings_get.json"

Write-Host "=== Testing PATCH /settings (toggle advance_search) ==="
$body = '{"advance_search":false}'
$response = Invoke-WebRequest -Uri $base -Headers $headers -Method PATCH -Body $body
$response.Content | Out-File "settings_patch.json"
Write-Host "Saved PATCH response to settings_patch.json"

Write-Host "=== Testing GET again to confirm change ==="
$response = Invoke-WebRequest -Uri $base -Headers $headers -Method GET
$response.Content | Out-File "settings_get_after.json"
Write-Host "Saved updated response to settings_get_after.json"

Write-Host "=== Testing POST /settings ==="
$body = '{"test":"injection"}'
$response = Invoke-WebRequest -Uri $base -Headers $headers -Method POST -Body $body
$response.Content | Out-File "settings_post.json"

Write-Host "=== Testing DELETE /settings ==="
$response = Invoke-WebRequest -Uri $base -Headers $headers -Method DELETE
$response.Content | Out-File "settings_delete.json"
