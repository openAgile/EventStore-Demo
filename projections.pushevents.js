// average commits per push
fromStream('github-events')
  .when({
    "$init": function(state, ev) {
      return {
        average: 0,
        commits: 0,
        pushes: 0
      };
    },
    "$any": function(state, ev) {

      state.pushes++;
      state.commits += ev.data.commits.length;
      state.average = state.commits / state.pushes;
    }
  });