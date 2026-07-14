# Zotero and File Policy

## Contents

1. Fixed attachment policy
2. Duplicate and import policy
3. Reading fallback
4. Multi-paper summaries
5. Notes and maintenance
6. Credentials and identity

## Fixed Attachment Policy

Use these invariants:

```text
attachment_mode = linked_file
path_policy = permanent_complete_absolute_path
sync_policy = user_managed_manual_sync
```

Accept a linked PDF only when its absolute path exists in a permanent research-project directory. Reject relative paths and paths under temporary directories, browser caches, CloakBrowser diagnostic folders, or disposable download staging.

Never move, rename, delete, or relocate a linked PDF without explicit authorization. Warn that Zotero's item synchronization does not automatically synchronize an externally linked file; the user manages file synchronization separately.

## Duplicate and Import Policy

1. Match normalized DOI exactly.
2. If DOI is absent, match normalized title plus author and year cautiously.
3. Inspect the existing item's child attachments before creating anything.
4. Use one import path for one paper. Do not run InstSci sync and a second Zotero creation path for the same item.
5. Import only verified successful PDF rows.
6. Verify item key, attachment key, collection, `linked_file` mode, full absolute path, and file existence.
7. Write Zotero keys back to the InstSci manifest when supported.

Import creates a clean item plus PDF attachment only unless the user explicitly requests tags. Do not create acquisition logs, evidence notes, or analysis notes during import.

## Reading Fallback

For Zotero-based reading, use:

```text
exact Zotero item resolution
-> Zotero-accessible full text/page/outline
-> linked_file complete absolute path
-> DOI/item/attachment lookup in InstSci manifest or zotero_sync_report.json
-> abstract-level summary with an evidence warning
```

Treat a Zotero MCP 404, page error, or outline error as a reader-interface failure until the local path is checked. If the local PDF exists and verifies, read it locally. Do not redownload or reimport. If the diagnosis is `LOCAL_FILE_MISSING` and the user explicitly authorized acquisition plus rebind/import repair, reacquire one verified PDF and attach or rebind it to the existing item without creating a duplicate.

Prefer repairing an existing child attachment in place. If that is impossible, do not silently leave two active PDF attachments or delete the broken record; report the conflict and obtain explicit replacement/deletion authorization.

If no PDF is available, label the output `[摘要]` or `[元数据]`. Never present it as a full-text summary.

## Multi-Paper Summaries

For `总结Zotero某集合下的5篇`:

1. Use Zotero MCP to resolve the collection and exact five items.
2. Capture title, DOI, item key, attachment key, link mode, path, tags, and existing notes.
3. Read full text using the fallback above.
4. Report a per-paper evidence level: `[全文]`, `[摘要]`, `[元数据]`, or `[推断]`.
5. Produce per-paper research question, materials/methods, process, quantitative results, mechanism, innovation, limitations, and relevance.
6. Only when comparison or synthesis is explicitly requested, add a matrix, common routes, differences, non-comparable conditions, research gaps, and implications.

Do not redownload, reimport, create notes, move files, or invoke `nature-reader` unless the user explicitly requests that additional stage or deliverable.

## Notes and Maintenance

Require explicit note-write language before creating or updating a child note. Reuse an existing workflow note when identifiable. Read the note back and report its key after writing.

Diagnose broken attachments as one of:

```text
MCP_READER_UNAVAILABLE
LOCAL_FILE_MISSING
LINK_PATH_INVALID
ATTACHMENT_RECORD_MISSING
DUPLICATE_ITEM
```

Path repair, duplicate merge, and deletion require explicit authorization. Update a semantic index once after a relevant batch, not once per item, and never use semantic search as authoritative DOI duplicate detection.

## Credentials and Identity

Load institution identity and service configuration from the relevant tool at runtime. Do not hard-code a university when InstSci already has configured identity. Never place email addresses, API keys, passwords, cookies, OTPs, or entitlement details in this Skill, manifests intended for sharing, notes, or reports.
