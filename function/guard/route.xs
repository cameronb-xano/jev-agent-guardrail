// The harness rule. Pure logic, no I/O: given Jev's typed answers and the active
// policy, decide whether the tool call runs, is blocked, or waits for a human.
// Anything uncertain, destructive or off-request goes to a person. If Jev is
// unreachable, the guardrail fails closed.
function "guard/route" {
  input {
    bool jev_ok
    text verdict?
    decimal confidence?
    decimal destructive?
    decimal matches_request?
    decimal allow_min_confidence?=0.9
    decimal block_min_confidence?=0.9
    decimal max_destructive?=0.5
  }

  stack {
    var $route {
      value = "human_review"
    }

    var $reason {
      value = "Jev was not confident enough"
    }

    conditional {
      if ($input.jev_ok == false) {
        var.update $reason {
          value = "Jev unavailable, failing closed"
        }
      }

      elseif ($input.verdict == "dangerous" && $input.confidence >= $input.block_min_confidence) {
        var.update $route {
          value = "auto_block"
        }

        var.update $reason {
          value = "Jev: dangerous"
        }
      }

      elseif ($input.verdict == "safe" && $input.confidence >= $input.allow_min_confidence && $input.destructive < $input.max_destructive && $input.matches_request >= 0.5) {
        var.update $route {
          value = "auto_allow"
        }

        var.update $reason {
          value = "Jev: safe"
        }
      }

      elseif ($input.verdict == "safe" && $input.confidence >= $input.allow_min_confidence) {
        var.update $reason {
          value = "Jev says safe, but it looks destructive or off-request"
        }
      }

      elseif ($input.verdict == "needs_review") {
        var.update $reason {
          value = "Jev: needs review"
        }
      }
    }
  }

  response = {route: $route, reason: $reason}

  test "confident safe call runs" {
    input = {
      jev_ok         : true
      verdict        : "safe"
      confidence     : 0.97
      destructive    : 0.02
      matches_request: 0.98
    }

    expect.to_equal ($response.route) {
      value = "auto_allow"
    }
  }

  test "confident dangerous call is blocked" {
    input = {
      jev_ok         : true
      verdict        : "dangerous"
      confidence     : 0.95
      destructive    : 0.9
      matches_request: 0.05
    }

    expect.to_equal ($response.route) {
      value = "auto_block"
    }
  }

  test "uncertain call goes to a human" {
    input = {
      jev_ok         : true
      verdict        : "safe"
      confidence     : 0.71
      destructive    : 0.1
      matches_request: 0.9
    }

    expect.to_equal ($response.route) {
      value = "human_review"
    }
  }

  test "safe but destructive still goes to a human" {
    input = {
      jev_ok         : true
      verdict        : "safe"
      confidence     : 0.96
      destructive    : 0.8
      matches_request: 0.9
    }

    expect.to_equal ($response.route) {
      value = "human_review"
    }
  }

  test "fails closed when Jev is down" {
    input = {jev_ok: false}
    expect.to_equal ($response.route) {
      value = "human_review"
    }
  }
  history = 100
}
