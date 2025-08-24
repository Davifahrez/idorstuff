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

Invoke-WebRequest -Uri "" -Method PATCH -Headers $headers -Body $body -UseBasicParsing
$response = Invoke-WebRequest -Uri "" -Method PATCH -Headers $headers -Body $body -UseBasicParsing
$response.StatusCode
$response.Content
