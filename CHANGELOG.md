# Changelog

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
