# Literature Workflow 1.1.1 Cloud Attachment Policy Design

## Goal

Prevent a valid Zotero import from pausing only because Zotero stored its verified PDF as an `imported_file` cloud attachment instead of a `linked_file`, when the user has explicitly allowed cloud upload.

## Decision

Keep `linked_file` as the default attachment mode. Add an explicit cloud-upload authorization state. When cloud upload is authorized, accept either `linked_file` or `imported_file` as a valid attachment result. Storage mode alone must not stop the batch.

Do not treat authorization as a request to convert existing attachments. Preserve a valid attachment in its current mode and do not create a second equivalent PDF.

## Import Contract

A row succeeds only when all of the following pass:

1. The bibliographic parent has complete required metadata and the DOI matches.
2. The parent is the unique DOI-matched item or the preview explicitly reuses it.
3. The target collection membership is correct.
4. Exactly one intended PDF attachment is present, opens successfully, and contains the intended paper.
5. Its link mode is `linked_file`, or it is `imported_file` and cloud upload is explicitly authorized.
6. A `linked_file` opens from its verified permanent absolute path; an `imported_file` opens through Zotero or a retrieved stored file.
7. PDF content identity matches using DOI first, then normalized title plus author when DOI is not extractable. Metadata-only evidence is insufficient.

If these checks pass, continue the remaining rows and synchronize the semantic index once after the full batch verifies.

## Failure and Safety Rules

Pause the remaining batch for incomplete metadata, DOI/PDF mismatch, duplicate parent items, missing attachment, an equivalent duplicate attachment, unreadable PDF content, unverified attachment identity, or an attachment mode outside the authorized set.

Never delete, replace, convert, merge, or duplicate an attachment merely to change its storage mode. Those mutations require a separate explicit authorization.

Cloud authorization does not authorize extra searches, downloads, duplicate merges, attachment replacement, or Zotero Storage purchases. If storage upload fails or quota is unavailable, report the row failure without creating a degraded DOI-only parent.

## Preview and Reporting

The import preview records `attachment_policy` as `linked_file_only` or `cloud_allowed`. Per-row secondary actions distinguish `attach_linked_pdf` from `attach_imported_pdf` when the planned mode is known.

The import report records the actual `attachment_mode`, attachment key, and mode-specific verification evidence. A valid `imported_file` under `cloud_allowed` is `import_verified`, not `import_partial`.

## Tests

Add contract tests proving that:

- `linked_file` remains the default.
- `cloud_allowed` accepts a verified `imported_file` without a pause or conversion.
- `imported_file` remains blocked when cloud upload was not authorized.
- metadata, duplicate, PDF identity, and attachment-presence failures still fail closed.
- runtime documentation no longer defines every non-`linked_file` attachment as incomplete.

## Scope

This change updates the local `literature-workflow` 1.1.1 policy and tests. It does not change InstSci's strict metadata, DOI deduplication, batch-stop-on-formal-failure, or post-import index synchronization requirements. It remains local until the user reviews combined verification results and explicitly approves a GitHub push.
