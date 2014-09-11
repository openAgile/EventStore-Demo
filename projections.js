// partitionates into mention-with and mention-without
// partitionate-with-or-without-mention
fromStream('github-events')
.whenAny(function(state, ev) {
    var re = new RegExp("[A-Z]{1,2}-[0-9]+", "");
    var matches = ev.data.commit.message.match(re);

    if(matches && 0 < matches.length){
        linkTo('mention-with', ev);
    }
    else {
        linkTo('mention-without', ev);
    }
});

//by-asset
fromStream('mention-with')
    .whenAny(function(state, ev) {
    var re = new RegExp("[A-Z]{1,2}-[0-9]+", "");
    var matches = ev.data.commit.message.match(re);
    linkTo('asset-' + matches[0], ev);
});

//by-committer
fromStream('github-events')
.whenAny(function(state, ev) {
    var committer = ev.data.commit.committer.name;
    linkTo('committer-' + committer , ev);
});

//count-commits-by-author
//http://127.0.0.1:2113/projection/count-commits-by-author/state?partition=someAuthor
fromCategory('committer')
  .foreachStream()
  .when({
    "$init": function(state, ev) {
      return { count: 0 };
    },
    "$any": function(state, ev) {
      state.count++;
    }
  });

//count-all-commits
fromStream('github-events')
.when({
"$init": function(state, ev) {
  return { count: 0 };
},
"$any": function(state, ev) {
  state.count++;
}
});

// this does by-committer and at the same time 
// keeps a list for the committers in the state
fromStream('github-events')
.whenAny(function(state, ev) {
    var committer = ev.data.commit.committer.name;
    linkTo('committer-' + committer , ev);

    if(!state.committers){
        state.committers = {};
    }

    if(!state.committers[committer]) {
        state.committers[committer] = committer;
    }
});

// by-filename
fromStream('github-events')
    .whenAny(function(state, ev) {
        var files = ev.data.files;
        files.forEach(function(file) {
            linkTo('filename-' + file.filename, ev);
        });
    });

// committers-per-file
fromCategory('filename')
    .foreachStream()
    .when({
        "$init": function(state, ev) {
            return { committers: {} };
        },
        "github-event": function(state, ev) {
            var committer = ev.data.commit.committer.name;
            if (!state.committers[committer]) {
                state.committers[committer] = committer;
            }
        }
    });