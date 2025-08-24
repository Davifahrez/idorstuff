$headers = @{
  "Authorization" = "Bearer"
  "Content-Type"  = "application/json"
}

$body = @"
{
  "purchase_limit": 9999,
  "marketing": false
}
"@

Invoke-WebRequest -Uri "https://api.anytask.com/settings" -Method PATCH -Headers $headers -Body $body -UseBasicParsing
$response = Invoke-WebRequest -Uri "https://api.anytask.com/settings" -Method PATCH -Headers $headers -Body $body -UseBasicParsing
$response.StatusCode
$response.Content
