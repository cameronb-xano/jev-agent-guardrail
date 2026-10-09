// If Jev can't be reached, nothing runs unreviewed.
workflow_test guard_fails_closed_without_jev {
  stack {
    function.call "guard/route" {
      input = {jev_ok: false}
    } as $decision

    expect.to_equal ($decision.route) {
      value = "human_review"
    }
  }

  tags = ["guardrail", "critical"]
}
