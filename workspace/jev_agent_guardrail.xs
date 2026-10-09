// Jev + Xano: an agent tool-call guardrail. Jev decides; Xano is the harness.
workspace "Jev Agent Guardrail" {
  env = {JEV_API_URL: "https://api.typesafe.ai/v1/systemone", JEV_API_KEY: ""}
  acceptance = {ai_terms: false}
  preferences = {
    internal_docs    : false
    track_performance: true
    sql_names        : false
    sql_columns      : true
  }
}
