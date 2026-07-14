---
name: literature-workflow
description: Use when a scholarly-literature request spans multiple stages, resumes prior work, contains a manual-review or negative downstream stop gate, requires Zotero/InstSci/local-file coordination or recovery, requests ordinary paper summary/analysis or multi-paper synthesis distinct from a bilingual reader, or combines an ordinary stage with a nature-* specialist deliverable.
---

# Literature Workflow

## Core Principle

Identify the authorized stage, select one primary tool, reuse completed artifacts, and stop where requested. Never infer downstream permission.

## HARD STOP — Continuation Scope

`继续上次`, `把剩下的做完`, `接着做`, or `完成这个项目` authorizes context recovery only. It does not by itself authorize a terminal stage.

Before any mutation or external acquisition, recover the authorization envelope from the current explicit request, an explicit scope earlier in the current conversation, or a saved `authorized_terminal_stage`/equivalent scope report. Read-only inspection of project and library state is allowed for this recovery. If no terminal stage can be recovered:

1. Do not infer permission from existing downloads, imports, analyses, or notes.
2. Do not search, download, authenticate, import, analyze, write notes, or repair files.
3. Set `authorized_terminal_stage=unknown`. Do not label, assume, or propose `full workflow completion`.
4. Ask one concise terminal-stage question covering the applicable stages from discovery through maintenance.
5. Do not perform work or add authentication/missing-file questions before the answer.

When authorization sources conflict, apply: current request and its negative constraints > explicit scope earlier in the current conversation > saved scope/report. Older or saved scope may fill omissions but never expand a narrower current request.

## Startup

1. Parse negative constraints first.
2. Resolve the project and objects: collection, item, DOI, result index, or PDF.
3. Detect the authorized stage sequence.
4. Check Zotero, InstSci artifacts, and permanent PDFs before external work.
5. State the stage, primary tool, and stop gate when ambiguity or external access matters.

Read [routing-and-stop-gates.md](references/routing-and-stop-gates.md) for combined requests, review gates, specialist routing, or unclear intent. Read [trigger-examples.md](references/trigger-examples.md) for boundary cases.

## Authorization Order

Apply this precedence:

```text
negative constraint > explicit action > object qualifier > specialist qualifier > inferred next step
```

In discovery or screening requests, treat `先返回`, `供我筛选`, `只列出`, `不要下载`, `先看看`, and `给我候选列表` as downstream stop gates. Outside those stages, `不要下载` only sets `allow_download=false`; it does not block analysis of existing evidence. Treat `完整流程` as ambiguous until scope and the manual-screening point are clear.

## Stage Routing

Read [stage-contracts.md](references/stage-contracts.md) for the selected stage. Run only its preflight, allowed actions, completion checks, and output contract.

Use this Skill as lead for multi-stage scope, explicit stop gates or negative constraints, continuation, and cross-system artifact coordination. For one clearly scoped specialist stage, use that stage owner directly.

Use InstSci for ordinary discovery, selection, acquisition, publisher access, and `instsci zotero sync`. Use Zotero MCP for library objects and notes. Route PubMed/MeSH/citation impact to `nature-academic-search`, claim support to `nature-citation`, bibliography fields to `nature-ref-verifier`, and explicit bilingual/translation/source-anchor/figure-table reading to `nature-reader`. `总结`, `详细总结`, `深度分析`, or `读懂这篇` alone remains ordinary analysis using Zotero text or permanent PDFs.

Check availability before routing. Use a fallback only if it preserves scope and evidence quality.

## Zotero and Files

Read [zotero-and-files.md](references/zotero-and-files.md) for Zotero, PDF, import, attachment, or note work. Keep `linked_file`, permanent absolute paths, and user-managed synchronization fixed.

Before Zotero mutation, build a read-only import preview using [import-preview-schema.md](references/import-preview-schema.md). Require confirmation for any deduplicated batch of two or more items or any duplicate, update, missing field/PDF, path warning, collection ambiguity, blocked row, or user-requested preview. Permit a single-item all-green fast path only when metadata, unique collection key, duplicate check, verified PDF, permanent path, and planned `create_item` plus `linked_file` attachment all pass without warnings.

For Zotero multi-paper summaries, resolve exact items through Zotero MCP. On linked-file read failure, use the permanent path or recover it from InstSci artifacts. A Zotero MCP 404 does not prove the PDF is missing.

## Continuation and Reporting

Read [project-state-and-reporting.md](references/project-state-and-reporting.md) for continuation or multi-stage projects. Apply the hard stop before resuming.

End with project, stages, tools, scope, counts, artifacts or keys, unperformed stages, stop reason, and safe next commands.

## Disabled Workflows

Never invoke `nature-downloader`, `nature-literature-pipeline`, or `researchwrite`. File presence does not grant invocation permission.
