// GET /guard/review-queue - Tool calls waiting for a person, newest first.
query "guard/review-queue" verb=GET {
  api_group = "AgentGuard"

  input {
  }

  stack {
    db.query tool_call {
      where = $db.tool_call.status == "pending_review"
      sort = {created_at: "desc"}
      return = {type: "list", paging: {page: 1, per_page: 25}}
    } as $queue
  }

  response = $queue
}
