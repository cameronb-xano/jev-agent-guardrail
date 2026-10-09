// POST /guard/review/{tool_call_id} - A person approves or rejects a held tool call.
query "guard/review/{tool_call_id}" verb=POST {
  api_group = "AgentGuard"

  input {
    int tool_call_id {
      table = "tool_call"
    }

    // approve | reject
    text decision filters=trim|lower
    text reviewer filters=trim
    text note?
  }

  stack {
    db.get tool_call {
      field_name = "id"
      field_value = $input.tool_call_id
    } as $call

    precondition ($call != null) {
      error_type = "notfound"
      error = "Tool call not found"
    }

    precondition ($call.status == "pending_review") {
      error_type = "inputerror"
      error = "Only held tool calls can be reviewed"
    }

    precondition ($input.decision == "approve" || $input.decision == "reject") {
      error_type = "inputerror"
      error = "decision must be approve or reject"
    }

    var $status {
      value = "rejected"
    }

    conditional {
      if ($input.decision == "approve") {
        var.update $status {
          value = "approved"
        }
      }
    }

    db.edit tool_call {
      field_name = "id"
      field_value = $input.tool_call_id
      data = {
        status     : $status
        reviewed_by: $input.reviewer
        review_note: $input.note
        reviewed_at: now
      }
    } as $updated
  }

  response = $updated
}
