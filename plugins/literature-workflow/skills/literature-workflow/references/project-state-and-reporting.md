# Project State and Reporting

## Contents

1. Sources of truth
2. Continuation algorithm
3. Conflict handling
4. Completion summary

## Sources of Truth

| Stage | Authoritative evidence |
|---|---|
| Discovery | InstSci search JSON/CSV and provider `source_status` |
| Screening | Reviewable result file with stable indices and decisions |
| Selection | InstSci selected DOI output and neighboring selection report |
| Acquisition | InstSci manifest plus verified permanent local PDF |
| Acquisition follow-up | `workflow_plan.json` |
| Zotero import | Updated InstSci manifest plus `zotero_sync_report.json` |
| Library state | Zotero item, collection, attachment, and note records |
| Analysis | Verified local analysis artifact or read-back Zotero note |

Do not treat conversational memory as authoritative factual project state. The user's explicit current request or explicit prior scope in the current conversation is authoritative for permission, while artifacts remain authoritative for what actually happened.

Artifacts establish what happened. They do not establish what the user still authorizes. Recover the authorization envelope from the current explicit request, an explicit scope earlier in the current conversation, or a saved scope/workflow plan/completion report; never infer it from the mere presence of imported items, analyses, or notes. Treat `把剩下的做完` alone as missing terminal-stage information.

Resolve conflicts in this order: current request and current negative constraints, then explicit scope earlier in the current conversation, then saved scope/report. A prior source may fill an omission but cannot widen a narrower current request.

## Continuation Algorithm

1. Resolve the project directory from the user's name, recent artifacts, or exact object.
2. Locate search results, selection reports, manifests, workflow plans, Zotero sync reports, and analysis outputs.
3. Normalize DOI values and map Zotero item/attachment keys where available.
4. Build per-paper stage state: discovered, selected, acquired, verified, imported, analyzed, noted.
5. Recover `authorized_terminal_stage` from the current explicit request, an explicit scope earlier in the current conversation, or a saved scope/stop report.
6. If it is absent, set `authorized_terminal_stage=unknown`. Read-only inspection may finish state reconstruction, but do no search, acquisition, import, analysis, note write, or repair. Ask no second question until the user selects the terminal stage.
7. If it is present, resume the first authorized incomplete stage, reuse successful artifacts, and skip completed operations.
8. Apply the next stop gate and return the updated state.

If multiple plausible projects remain, ask one concise disambiguation question. Do not ask the user to repeat factual state that artifacts already resolve, but do ask for missing authorization scope.

## Conflict Handling

- Prefer a verified permanent PDF over an unverified candidate file.
- Prefer the acquisition manifest that names the verified PDF and contains current Zotero keys.
- Confirm current library state through Zotero rather than assuming a historical sync report is still current.
- Preserve conflicting non-empty DOI values as separate candidates until verified.
- Report conflicting manifests or item mappings; do not silently merge them. Freeze only affected rows and continue unaffected rows within the authorized scope.
- If a file was moved, do not change the Zotero link until the user authorizes repair.

## Completion Summary

End every stage with:

```text
Project:
Detected stages:
Primary tools:
Requested scope:
Completed:
Skipped:
Unresolved:
Artifacts or Zotero keys:
Stages not performed:
Stop reason:
Safe next commands:
```

Use explicit counts where a batch is involved. State `not performed` rather than omitting downstream stages, so the user can distinguish an intentional stop from a forgotten action.

For acquisition, retain InstSci's file status, standard status, result evidence, route, path state, absolute path when successful, and next action. For import, retain item key, attachment key, collection, attachment mode, and verified path. For analysis, retain the evidence level for every paper.
