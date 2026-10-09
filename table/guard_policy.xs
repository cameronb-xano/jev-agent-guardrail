// Confidence thresholds for the guardrail. Policy is data: edit a row, no redeploy.
table guard_policy {
  auth = false

  schema {
    int id
    timestamp created_at?=now
    text name filters=trim

    // Jev must say "safe" with at least this confidence to run without a human
    decimal allow_min_confidence?=0.9

    // Jev must say "dangerous" with at least this confidence to block outright
    decimal block_min_confidence?=0.9

    // Above this probability that the call is destructive, a human always looks
    decimal max_destructive?=0.5

    bool active?=true
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "active"}]}
  ]
}
