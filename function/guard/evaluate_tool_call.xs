// The harness: record the proposed call, ask Jev, apply the active policy,
// log the decision, and return what the agent is allowed to do.
function "guard/evaluate_tool_call" {
  input {
    text agent
    text user_request
    text tool
    json arguments?
  }

  stack {
    db.add tool_call {
      data = {
        agent       : $input.agent
        user_request: $input.user_request
        tool        : $input.tool
        arguments   : $input.arguments
        status      : "pending_review"
      }
    } as $call

    db.query guard_policy {
      where = $db.guard_policy.active == true
      return = {type: "single"}
    } as $policy

    function.run "jev/decide" {
      input = {
        agent       : $input.agent
        user_request: $input.user_request
        tool        : $input.tool
        arguments   : $input.arguments
      }
    } as $jev

    function.run "guard/route" {
      input = {
        jev_ok              : $jev.ok
        verdict             : $jev.verdict
        confidence          : $jev.confidence
        destructive         : $jev.destructive
        matches_request     : $jev.matches_request
        allow_min_confidence: $policy.allow_min_confidence ?? 0.9
        block_min_confidence: $policy.block_min_confidence ?? 0.9
        max_destructive     : $policy.max_destructive ?? 0.5
      }
    } as $decision

    db.add jev_decision {
      data = {
        tool_call_id   : $call.id
        model          : $jev.model
        verdict        : $jev.verdict
        confidence     : $jev.confidence
        probabilities  : $jev.probabilities
        destructive    : $jev.destructive
        matches_request: $jev.matches_request
        latency_ms     : $jev.latency_ms
        input_tokens   : $jev.input_tokens
        jev_ok         : $jev.ok
        http_status    : $jev.http_status
        route          : $decision.route
      }
    } as $logged

    var $status {
      value = "pending_review"
    }

    conditional {
      if ($decision.route == "auto_allow") {
        var.update $status {
          value = "allowed"
        }
      }

      elseif ($decision.route == "auto_block") {
        var.update $status {
          value = "blocked"
        }
      }
    }

    db.edit tool_call {
      field_name = "id"
      field_value = $call.id
      data = {
        status      : $status
        route       : $decision.route
        route_reason: $decision.reason
      }
    } as $updated
  }

  response = {
    tool_call_id   : $call.id
    status         : $status
    route          : $decision.route
    reason         : $decision.reason
    verdict        : $jev.verdict
    confidence     : $jev.confidence
    probabilities  : $jev.probabilities
    destructive    : $jev.destructive
    matches_request: $jev.matches_request
    latency_ms     : $jev.latency_ms
    jev_ok         : $jev.ok
  }
  history = 100
}
