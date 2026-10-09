// POST /guard/tool-call - An agent proposes a tool call. Jev decides, Xano enforces.
query "guard/tool-call" verb=POST {
  api_group = "AgentGuard"

  input {
    text agent filters=trim
    text user_request
    text tool filters=trim
    json arguments?
  }

  stack {
    function.run "guard/evaluate_tool_call" {
      input = {
        agent       : $input.agent
        user_request: $input.user_request
        tool        : $input.tool
        arguments   : $input.arguments
      }
    } as $result
  }

  response = $result
}
