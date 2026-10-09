// Every tool call an AI agent proposes, and what happened to it.
table tool_call {
  auth = false

  schema {
    int id
    timestamp created_at?=now

    // Which agent proposed the call
    text agent filters=trim

    // What the user asked the agent for, in their words
    text user_request

    // Tool name, e.g. orders.lookup
    text tool filters=trim

    json arguments?

    // allowed | blocked | pending_review | approved | rejected
    text status?=pending_review

    // auto_allow | auto_block | human_review
    text route?

    text route_reason?
    text reviewed_by?
    text review_note?
    timestamp reviewed_at?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "status"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}
