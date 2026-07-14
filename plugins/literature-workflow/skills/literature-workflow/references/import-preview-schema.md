# Import Preview Schema

Use this contract before every Zotero import. Dry-run is read-only: it must not create or update Zotero items, attachments, collections, notes, tags, or semantic-index records.

Required top-level fields: `schema`, `preview_id`, `created_at`, `source_manifest`, `source_fingerprint`, `preview_status`, `confirmation_required`, `attachment_policy`, `target_collections`, `rows`, `summary`, and `index_plan`.

Use schema `literature_workflow.import_preview.v1`. Build `preview_id` by concatenating `IMP-`, local time formatted as `yyyyMMdd-HHmmss`, `-`, and the first eight hexadecimal characters of the source fingerprint. Resolve every target collection to `{name, key}`.

Set `attachment_policy` to `linked_file_only` by default. Set it to `cloud_allowed` only when the user explicitly permits Zotero cloud upload. Each deduplicated row has one primary action: `create_item`, `update_existing`, `no_op`, or `blocked`. Secondary actions are `enrich_metadata`, `attach_linked_pdf`, `attach_imported_pdf`, `add_to_collection`, and an explicitly authorized `replace_broken_attachment`.

Primary-action counts must sum to the deduplicated row count. Report metadata completeness, PDF readability, attachment identity, mode-specific storage evidence, and collection distribution separately. A formal success row records `attachment_readable=true` and `attachment_identity=verified`.

Use `preview_ready`, `preview_ready_with_exclusions`, or `preview_blocked`. Blocked rows are excluded from formal execution by default. A changed source fingerprint, DOI duplicate state, collection key, or PDF path makes the preview `preview_stale`.

```json
{
  "schema": "literature_workflow.import_preview.v1",
  "preview_id": "IMP-20260714-142500-a1b2c3d4",
  "created_at": "2026-07-14T14:25:00+08:00",
  "source_manifest": "D:/Research/project/complete/manifest.json",
  "source_fingerprint": "a1b2c3d4a1b2c3d4a1b2c3d4a1b2c3d4a1b2c3d4a1b2c3d4a1b2c3d4a1b2c3d4",
  "preview_status": "preview_ready_with_exclusions",
  "confirmation_required": true,
  "attachment_policy": "linked_file_only",
  "target_collections": [{"name": "纤维素", "key": "AWMY388S"}],
  "rows": [
    {"doi": "10.5555/example-a", "primary_action": "create_item", "secondary_actions": ["attach_linked_pdf"], "collection_keys": ["AWMY388S"]},
    {"doi": "10.5555/example-b", "primary_action": "blocked", "secondary_actions": [], "reason": "missing_pdf"}
  ],
  "summary": {"requested": 2, "deduplicated": 2, "create_item": 1, "update_existing": 0, "no_op": 0, "blocked": 1},
  "index_plan": {"status": "sync_planned", "force_rebuild": false}
}
```

```text
Import preview: IMP-20260714-142500-a1b2c3d4
Requested: 20
Deduplicated: 20
Create new: 15
Update existing: 2
No change: 1
Blocked and excluded: 2
Attach linked PDF: 17
Enrich metadata: 2
Add to collection: 5
DOI: 20/20
Title: 20/20
Authors: 19/20
Journal/date: 18/20
Verified PDF: 18/20
Permanent linked path: 17/20
同步索引: Yes
重建全部索引: No
No Zotero changes have been made.
Confirm preview IMP-20260714-142500-a1b2c3d4?
```
