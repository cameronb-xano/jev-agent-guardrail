// GET /guard/decisions - Recent Jev decisions with the route Xano chose.
query "guard/decisions" verb=GET {
  api_group = "AgentGuard"

  input {
  }

  stack {
    db.query jev_decision {
      sort = {created_at: "desc"}
      return = {type: "list", paging: {page: 1, per_page: 25}}
    } as $rows
  }

  response = $rows
}
