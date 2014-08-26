// splits into mention-with and mention-without
fromStream('github-event')
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
fromStream('github-event')
.whenAny(function(state, ev) {
    var commiter = ev.data.commit.committer.email;
    linkTo('commiter-' + commiter , ev);
});

//count-commits-by-author
//http://127.0.0.1:2113/projection/count-commits-by-author/state?partition=someAuthor
fromCategory('commiter')
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
fromStream('github-event')
.when({
"$init": function(state, ev) {
  return { count: 0 };
},
"$any": function(state, ev) {
  state.count++;
}
});

// this does by-commiter and at the same time keeps a list for the commiters in the state
fromStream('github-event')
.whenAny(function(state, ev) {
    var commiter = ev.data.commit.committer.email;
    linkTo('commiter-' + commiter , ev);

    if(!state.commiters){
        state.commiters = {};
    }

    if(!state.commiters[commiter]) {
        state.commiters[commiter] = commiter;
    }
});