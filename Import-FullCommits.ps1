param($accessToken)

. .\helpers.ps1

$repoUrl = "https://api.github.com/repos/kunzimariano/CommitService.DemoRepo"


function Import-FullCommits {
    $url = "$repoUrl/commits?per_page=100&page=1"

    if($accessToken -ne $null){
        $url += "&access_token=$accessToken"
    }

    do {
        $response = Invoke-WebRequest -Uri $url

        $eventStore = 'http://127.0.0.1:2113/streams/github-events'
        $guid = ([guid]::NewGuid()).ToString()
        $auth = Get-AuthorizationHeader

        $ghEvents = ConvertFrom-Json $response.Content
        $links Get-CommitsLinks $ghEvents
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

Import-FullCommits