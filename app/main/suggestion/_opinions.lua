local suggestion = param.get("suggestion", "table")

execute.view{
  module = "opinion",
  view = "_list",
  params = {
    opinions_selector = Opinion:new_selector()
      :add_field("direct_interest_snapshot.weight")
      :join("member", nil, "member.id = opinion.member_id")
      :join("initiative", nil, "initiative.id = opinion.initiative_id")
      :join("issue", nil, "issue.id = initiative.issue_id")
      :join("direct_interest_snapshot", nil, "direct_interest_snapshot.event = issue.latest_snapshot_event AND direct_interest_snapshot.issue_id = issue.id AND direct_interest_snapshot.member_id = member.id")
      :add_where{ "suggestion_id = ?", suggestion.id }
      :add_order_by("direct_interest_snapshot.weight DESC, member.id DESC"),
    initiative = suggestion.initiative
  }
}
