param($accessToken)

function Get-AuthorizationHeader {
    $username = 'admin'
    $password = 'changeit'
    $auth = 'Basic ' + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($username+":"+$password ))
    $auth
}

function Get-JsonEvents {
    param($events)
    $result = @()
    $events | % {
        $e = [pscustomobject]@{
            eventId = $guid;
            eventType = 'github-event';
            data = $_
        }
        $result += $e
    }
    ConvertTo-Json $result -Depth 6
}

function Invoke-PushEvents {
    $eventStore = 'http://127.0.0.1:2113/streams/github-events'
    $auth = Get-AuthorizationHeader

    ls .\events | % {

        $guid = ([guid]::NewGuid()).ToString()
        $ghEvents = ConvertFrom-Json (gc $_.FullName -Raw)
        $esEvents = Get-JsonEvents $ghEvents

        $headers = @{
            "Accept" =  "application/json";
            "Content-Type" = "application/vnd.eventstore.events+json";
            "Content-Length" =  $esEvents.Length;
            "Authorization" = $auth
        }

        $r = Invoke-WebRequest -Body $esEvents -Uri $eventStore -Method Post -Headers $headers
        if($r.StatusCode -gt 201){ echo "$($r.StatusCode): $($r.Content)" }

    }
}

Invoke-PushEvents