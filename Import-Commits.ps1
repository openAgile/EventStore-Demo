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

function Get-LinkHeader {
    param($headers)

    if($headers.ContainsKey('Link')) {
        $headers['Link']
    }
    else {
        $null
    }
}

function Get-NextLink {
    param($headers)

    $link = Get-LinkHeader $headers

    if($link -eq $null) {
        return $null
    }

    $result = $null
    $link.Split(',') | % {
        $parts = $_.Split(';')
        if ($parts[1].Trim() -eq 'rel="next"') {
            $result = $parts[0].Replace('<','').Replace('>','')
        }
    }
    $result
}

function Invoke-PullAndPushEvents {
    $url = "https://api.github.com/repos/kunzimariano/CommitService.DemoRepo/commits?per_page=100&page=1"

    if($accessToken -ne $null){
        $url += "&access_token=$accessToken"
    }

    do {
        $response = Invoke-WebRequest -Uri $url

        $eventStore = 'http://127.0.0.1:2113/streams/github-events'
        $guid = ([guid]::NewGuid()).ToString()
        $auth = Get-AuthorizationHeader

        $ghEvents = ConvertFrom-Json $response.Content
        $esEvents = Get-JsonEvents $ghEvents

        $headers = @{
            "Accept" =  "application/json";
            "Content-Type" = "application/vnd.eventstore.events+json";
            "Content-Length" =  $esEvents.Length;
            "Authorization" = $auth
        }

        Invoke-WebRequest -Body $esEvents -Uri $eventStore -Method Post -Headers $headers

        $url = Get-NextLink $response.Headers

    } while($url -ne $null)
}

Invoke-PullAndPushEvents