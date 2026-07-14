# Changelog

## 1.1.1 - 2026-07-14

### Changed

- Kept `linked_file` as the default while allowing a verified Zotero `imported_file` after explicit cloud-upload authorization.
- Added attachment-policy and actual-mode fields to import previews and reports.

### Fixed

- Prevented valid cloud attachments from pausing the remaining batch solely because of storage mode.
- Prevented automatic deletion, conversion, or duplication of a valid attachment when its storage mode differs from the default.
- Required the attached PDF to open and match the intended paper; attachment metadata alone no longer proves import success.

## 1.1.0 - 2026-07-14

### Added

- Risk-based Zotero import preview with preview ID and source fingerprint.
- Verified 同步索引 after complete semantic mutations.
- Validated local marketplace reinstall workflow.

### Changed

- Zotero MCP is the sole bibliographic metadata writer.
- Non-ASCII collections are resolved and verified by collection key.
- Preview, import, and index-sync outcomes are reported separately.

### Fixed

- Prevented successful classification of empty or `Untitled` parent items.
- Prevented corrupted Chinese collection names from being used as mutation identifiers.
- Prevented verified imports from remaining absent from the semantic index.
