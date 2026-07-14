import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PLUGIN = ROOT / "plugins" / "literature-workflow"
SKILL = PLUGIN / "skills" / "literature-workflow"
REFS = SKILL / "references"


class ReleaseContractTests(unittest.TestCase):
    def read(self, path: Path) -> str:
        return path.read_text(encoding="utf-8")

    def test_release_version_has_one_source(self):
        manifest = json.loads(self.read(PLUGIN / ".codex-plugin" / "plugin.json"))
        self.assertEqual(manifest["version"], "1.1.0")
        self.assertFalse((ROOT / "VERSION").exists())
        self.assertFalse((PLUGIN / "VERSION").exists())

    def test_release_artifacts_exist(self):
        for path in (
            ROOT / "CHANGELOG.md",
            ROOT / "scripts" / "install_local.ps1",
            ROOT / "tests" / "integration-matrix.md",
            REFS / "import-preview-schema.md",
        ):
            self.assertTrue(path.is_file(), str(path))

    def test_runtime_uses_index_sync_terminology(self):
        runtime = "\n".join(
            self.read(path)
            for path in (SKILL / "SKILL.md", *sorted(REFS.glob("*.md")))
        )
        self.assertIn("同步索引", runtime)
        self.assertNotIn("增量索引", runtime)
        self.assertIn("force_rebuild=False", runtime)

    def test_preview_schema_is_stable_and_countable(self):
        path = REFS / "import-preview-schema.md"
        self.assertTrue(path.is_file(), str(path))
        preview = self.read(path)
        for term in (
            "preview_id",
            "source_fingerprint",
            "confirmation_required",
            "create_item",
            "update_existing",
            "no_op",
            "blocked",
            "preview_stale",
        ):
            self.assertIn(term, preview)

    def test_stage_contract_has_risk_gate_and_fast_path(self):
        stages = self.read(REFS / "stage-contracts.md")
        for term in (
            "preview_ready",
            "preview_ready_with_exclusions",
            "preview_blocked",
            "single-item all-green",
            "import_verified",
            "import_partial",
            "sync_deferred",
        ):
            self.assertIn(term, stages)

    def test_zotero_policy_fails_closed(self):
        policy = self.read(REFS / "zotero-and-files.md")
        for term in (
            "Zotero MCP",
            "Do not silently fall back",
            "Untitled",
            "collection key",
            "linked_file",
            "note-only",
            "tag-only",
            "collection-only",
        ):
            self.assertIn(term, policy)

    def test_reporting_separates_state_dimensions(self):
        report = self.read(REFS / "project-state-and-reporting.md")
        for term in (
            "no_mutation_required",
            "sync_not_required",
            "sync_success",
            "sync_failed",
        ):
            self.assertIn(term, report)

    def test_runtime_has_no_authoring_markers(self):
        markers = ("T" + "BD", "TO" + "DO", "PLACE" + "HOLDER")
        for path in SKILL.rglob("*"):
            if path.is_file() and path.suffix in {".md", ".yaml", ".yml", ".json"}:
                text = self.read(path)
                for marker in markers:
                    self.assertNotIn(marker, text, f"{marker} in {path}")


if __name__ == "__main__":
    unittest.main()
