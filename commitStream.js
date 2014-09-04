function getCommits() {
    var url = 'http://localhost:2113/streams/github-events/head/backward/5?embed=content';
    var commits = [];
    $.getJSON(url, function(events) {
        $.each(events.entries, function(index, value) {
            var e = value.content.data;

            var c = {
                timeFormatted: "12 minutes ago",
                author: e.commit.committer.name,
                sha1Partial: e.commit.tree.sha,
                action: "committed",
                message: e.commit.message,
                commitHref: e.commit.url
            }

            commits.push(c);


        });
    }).done(function() {
      return commits;
    });
}
 