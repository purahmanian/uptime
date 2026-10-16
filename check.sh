#!/usr/bin/env bash
# Free uptime monitor. Opens one GitHub issue (assigned to the owner -> GitHub mobile push)
# when a site is down, closes it automatically when the site recovers.
set -uo pipefail
OWNER="${OWNER:-purahmanian}"
gh label create down --color B60205 --description "Site is down" >/dev/null 2>&1 || true
open_json=$(gh issue list --state open --label down --limit 200 --json number,title)
fails=0
while IFS= read -r url; do
  [[ -z "$url" || "$url" == \#* ]] && continue
  ok=0; code=000
  for i in 1 2 3; do
    code=$(curl -sS -o /dev/null -w '%{http_code}' -L --max-time 20 -A 'uptime-check (github-actions)' "$url" 2>/dev/null) || code=000
    if [[ "$code" =~ ^[23][0-9][0-9]$ ]]; then ok=1; break; fi
    [[ $i -lt 3 ]] && sleep 20
  done
  title="DOWN: $url"
  existing=$(jq -r --arg t "$title" '.[] | select(.title==$t) | .number' <<<"$open_json" | head -1)
  now=$(date -u +'%Y-%m-%d %H:%M UTC')
  if [[ $ok -eq 0 ]]; then
    fails=$((fails+1))
    echo "DOWN  $code  $url"
    if [[ -z "$existing" ]]; then
      gh issue create --title "$title" --label down --assignee "$OWNER" \
        --body "$url failed 3 checks in a row (~20s apart). Last HTTP code: $code. First seen $now. This issue closes itself when the site is back." >/dev/null
    fi
  else
    echo "UP    $code  $url"
    if [[ -n "$existing" ]]; then
      gh issue close "$existing" --comment "Recovered at $now (HTTP $code)." >/dev/null
    fi
  fi
done < sites.txt
echo "$fails site(s) down"
exit 0
