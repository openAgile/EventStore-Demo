param($accessToken)

. .\helpers.ps1

function Import-Commits {
    $url = "https://api.github.com/repos/kunzimariano/CommitService.DemoRepo/commits?per_page=100&page=1"
    $eventStore = 'http://127.0.0.1:2113/streams/github-events'

    if($accessToken -ne $null){
        $url += "&access_token=$accessToken"
    }

    do {
        $response = Invoke-WebRequest -Uri $url        

        $ghEvents = ConvertFrom-Json $response.Content
        $esEvents = Get-EStoreEvents $ghEvents

        $headers = @{
            "Accept" =  "application/json";
            "Content-Type" = "application/vnd.eventstore.events+json";
            "Content-Length" =  $esEvents.Length;
            "Authorization" = $auth
        }

        $auth = Get-AuthorizationHeader
        Invoke-WebRequest -Body $esEvents -Uri $eventStore -Method Post -Headers $headers

        $url = Get-NextLink $response.Headers

    } while($url -ne $null)
}

Import-Commits