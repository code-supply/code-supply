"
-----------------------------------
    Time: \(.time | tonumber | . / 1000000 | floor | strftime("%B %d %Y %I:%M%p %Z"))
    Site: \(.name)
 Domains: \(.domains | join("\n          "))
  Action: \(.action)
 Message: \(.message)
" +
(
if .upgraded
then
    "Upgrades:

\(.upgraded
    | map (to_entries | sort_by(.key | startswith("name") | not)
            | map("\(.key): \(.value)") | join("\n"))
    | join("\n\n")
    )"
else
    empty
end
)
