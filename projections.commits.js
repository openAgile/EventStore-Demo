// github-events-partitioner
fromStream('github-events')
  .whenAny(function(state, ev) {
    var re = new RegExp("[A-Z]{1,2}-[0-9]+", "");
    var matches = ev.data.commit.message.match(re);

    if (matches && 0 < matches.length) {
      linkTo('mention-with', ev);
      linkTo('asset-' + matches[0], ev);
    } else {
      linkTo('mention-without', ev);
    }
    var commiter = ev.data.commit.committer.email;
    linkTo('commiter-' + commiter, ev);
  });

//keeps state of github-events
fromStream('github-events')
  .when({
    "$init": function(state, ev) {
      return {
        count: 0,
        commiters: {},
        commitersCount: 0
      };
    },
    "$any": function(state, ev) {
      state.count++;

      var commiter = ev.data.commit.committer.email;
      if (!state.commiters[commiter]) {
        state.commiters[commiter] = commiter;
        state.commitersCount++;
      }
    }
  });

// keeps state per commiter
// http://127.0.0.1:2113/projection/count-commits-by-commiter/state?partition=commiter-someone
fromCategory('commiter')
  .foreachStream()
  .when({
    "$init": function(state, ev) {
      return {
        count: 0
      };
    },
    "$any": function(state, ev) {
      state.count++;
    }
  });

// keeps state per asset
fromCategory('asset')
  .when({
    "$init": function(state, ev) {
      return {
        count: 0,
        commiters: {},
        commitersCount: 0
      };
    },
    "$any": function(state, ev) {
      state.count++;

      var commiter = ev.data.commit.committer.email;
      if (!state.commiters[commiter]) {
        state.commiters[commiter] = commiter;
        state.commitersCount++;
      }
    }
  });