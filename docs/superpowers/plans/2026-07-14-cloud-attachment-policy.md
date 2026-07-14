# Cloud Attachment Policy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Release Literature Workflow 1.1.1 with local or cloud Zotero attachments accepted only after the PDF opens and matches the intended paper.

**Architecture:** Keep `linked_file` as the default and express cloud permission as `attachment_policy=cloud_allowed`. Apply mode-specific storage readback plus content-identity verification using DOI first and normalized title plus author as fallback, while retaining strict metadata, duplicate, batch-stop, and index-sync gates.

**Tech Stack:** Markdown Codex skill contracts, JSON plugin manifest, Python `unittest`, PowerShell plugin validation.

## Global Constraints

- Require every successful attachment to open and match the intended paper; storage metadata alone is insufficient.
- Do not weaken complete-metadata, DOI-deduplication, PDF-identity, attachment-presence, or batch failure rules.
- Do not delete, replace, convert, merge, or duplicate a valid attachment solely to change storage mode.
- Keep all changes local until tests pass; then merge to `main` and push only because the user explicitly authorized publication.

---

### Task 1: Add the cloud-attachment release contract

**Files:**
- Modify: `tests/test_release_contract.py`
- Modify: `plugins/literature-workflow/.codex-plugin/plugin.json`
- Modify: `plugins/literature-workflow/skills/literature-workflow/SKILL.md`
- Modify: `plugins/literature-workflow/skills/literature-workflow/references/zotero-and-files.md`
- Modify: `plugins/literature-workflow/skills/literature-workflow/references/stage-contracts.md`
- Modify: `plugins/literature-workflow/skills/literature-workflow/references/import-preview-schema.md`
- Modify: `plugins/literature-workflow/skills/literature-workflow/references/project-state-and-reporting.md`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: explicit user authorization for Zotero cloud upload and verified Zotero attachment metadata.
- Produces: `attachment_policy` values `linked_file_only` and `cloud_allowed`, plus actual `attachment_mode` and mode-specific verification evidence.

- [x] **Step 1: Write the failing release-contract tests**

Add assertions that version `1.1.1` is the single release version, runtime text contains `cloud_allowed`, `imported_file`, mode-specific evidence, and no unconditional rule classifies every non-`linked_file` attachment as incomplete.

- [x] **Step 2: Run the focused tests and verify failure**

Run: `python -m unittest tests.test_release_contract.ReleaseContractTests.test_release_version_has_one_source tests.test_release_contract.ReleaseContractTests.test_cloud_attachment_policy_is_explicit_and_fail_closed -v`

Expected: FAIL because the manifest is `1.1.0` and the runtime has no cloud-authorization contract.

- [x] **Step 3: Implement the minimal runtime contract**

Update the manifest to `1.1.1`; document `linked_file_only` as default, `cloud_allowed` as explicit authorization, `imported_file` mode-specific verification, preservation of valid attachments, and unchanged strict failure gates. Update preview/report fields and release notes consistently.

- [x] **Step 4: Run focused and full validation**

Run: `python -m unittest tests.test_release_contract -v`

Expected: all release-contract tests pass.

Run: `powershell -ExecutionPolicy Bypass -File tests/test_install_local.ps1`

Expected: plugin validation and dry-run installation tests pass.

- [x] **Step 5: Commit the implementation**

Stage only the listed runtime, test, manifest, changelog, design, and plan files. Commit with `feat: allow verified Zotero cloud attachments`.
