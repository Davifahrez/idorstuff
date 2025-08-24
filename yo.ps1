$envPath = ".\.env"
if (Test-Path $envPath) {
    Get-Content $envPath | ForEach-Object {
        if ($_ -match "^\s*([^#][^=]+)=(.+)$") {
            Set-Variable -Name $matches[1].Trim() -Value $matches[2].Trim()
        }
    }
} else {
    Write-Host "No .env file found at $envPath"
    exit
}

if (-not $START_ID) { $START_ID = 1 }
if (-not $END_ID) { $END_ID = 20 }
if (-not $BASE_DOMAIN) { $BASE_DOMAIN = "https://api.anytask.com" }
$endpoints = @(
    "/settings",
    "/profile",
    "/account",
    "/wallet",
    "/orders",
    "/orders/<id>",
    "/invoices",
    "/invoices/<id>",
    "/payments",
    "/subscriptions",
    "/tasks",
    "/tasks/<id>",
    "/projects",
    "/projects/<id>",
    "/jobs",
    "/jobs/<id>",
    "/files",
    "/files/<id>",
    "/attachments/<id>",
    "/admin/settings",
    "/admin/users/<id>",
    "/admin/reports",
    "/admin/logs",
    "/notifications/<id>",
    "/messages/<id>",
    "/comments/<id>",
    "/reviews/<id>"
)

function Get-Resource($url, $jwt) {
    $headers = @{ "Authorization" = "Bearer $jwt" }
    try {
        $resp = Invoke-WebRequest -Uri $url -Headers $headers -Method GET
        return $resp.Content
    } catch {
        return $null
    }
}

function Decode-Base64Fields($content) {
    if (-not $content) { return $null }
    try {
        $json = $content | ConvertFrom-Json
        $json | ForEach-Object {
            $_ | Get-Member -MemberType NoteProperty | ForEach-Object {
                $val = $_.Name
                if ($json.$val -match '^[A-Za-z0-9+/=]{20,}$') {
                    try { $json.$val = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($json.$val)) } catch {}
                }
            }
        }
        return $json | ConvertTo-Json -Depth 5
    } catch { 
        Write-Host "Failed to parse json from content"
        return $content
    }
}

function Test-CrossAccount($url, $jwtOwn, $jwtOther) {
    $ownResp = Get-Resource $url $jwtOwn
    if (-not $ownResp) { Write-Host "[$url] Own account access failed."; return }

    $crossResp = Get-Resource $url $jwtOther
    if (-not $crossResp) { Write-Host "[$url] Cross-account access failed (probs secure)."; return }

    $decodedOwn = Decode-Base64Fields $ownResp
    $decodedCross = Decode-Base64Fields $crossResp

    if ($decodedOwn -ne $decodedCross) {
        Write-Host "[$url] Own vs Cross-account responses differ (probs secure)."
    } else {
        Write-Host "[$url] Cross-account data exposure detected!"
        "$url`n$decodedCross`n--------------------------------" | Out-File -Append "idor_bac_results.txt"
    }
}

foreach ($ep in $endpoints) {
    if ($ep -match "<id>") {
        for ($i = [int]$START_ID; $i -le [int]$END_ID; $i++) {
            $url = $BASE_DOMAIN + ($ep -replace "<id>", $i)
            Test-CrossAccount -url $url -jwtOwn $JWT1 -jwtOther $JWT2
            Test-CrossAccount -url $url -jwtOwn $JWT2 -jwtOther $JWT1
        }
    } else {
        $url = $BASE_DOMAIN + $ep
        Test-CrossAccount -url $url -jwtOwn $JWT1 -jwtOther $JWT2
        Test-CrossAccount -url $url -jwtOwn $JWT2 -jwtOther $JWT1
    }
}

Read-Host -Prompt "Press Enter to exit"
