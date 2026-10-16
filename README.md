# uptime

Free, AI-free uptime monitor for Puya's sites. GitHub Actions checks every URL in `sites.txt` every 30 minutes.
A site counts as down only after 3 failed tries ~20s apart. When it's down, an issue titled `DOWN: <url>` is opened
and assigned to @purahmanian (GitHub mobile sends the push). It closes itself on recovery.

Add or remove a site: edit `sites.txt`. Run now: Actions tab -> uptime -> Run workflow.
Part of the Claude Ops portfolio (Notion: Claude Ops -> Task Registry -> "Uptime Monitor (free, no AI)").
