// One row per Jev call: the typed answers, the confidence, the latency and the route Xano chose.
// Over time this is a labeled dataset of real agent decisions.
table jev_decision {
  auth = false

  schema {
    int id
    timestamp created_at?=now

    int tool_call_id? {
      table = "tool_call"
    }

    text model?

    // Jev's choice: safe | needs_review | dangerous
    text verdict?

    decimal confidence?
    json probabilities?

    // Noul: probability the call is destructive
    decimal destructive?

    // Noul: probability the call matches what the user asked for
    decimal matches_request?

    int latency_ms?
    int input_tokens?
    bool jev_ok?=true
    int http_status?

    // auto_allow | auto_block | human_review
    text route?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "tool_call_id"}]}
    {type: "btree", field: [{name: "route"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}
