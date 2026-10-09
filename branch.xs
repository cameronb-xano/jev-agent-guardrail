branch "v1" {
  color = "#6f5cff"
  middleware = {
    function: {pre: [], post: []}
    query: {pre: [], post: []}
    task: {pre: [], post: []}
    tool: {pre: [], post: []}
  }
  history = {function: 100, query: 100, task: 100, tool: 100, trigger: 100, middleware: 10}
}
