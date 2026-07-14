# Stage Contracts

## Contents

1. Zotero library preflight
2. Discovery, screening, and selection
3. Acquisition, import preview, and Zotero import
4. Ordinary analysis, deep reading, and synthesis
5. Note writing, maintenance, and continuation

## Contract Shape

For every stage, identify the trigger, required input, primary tool, preflight, allowed actions, completion criteria, default stop, and output fields.

## 1. Zotero Library Preflight

- **Trigger:** Check whether items or PDFs already exist in Zotero.
- **Required input:** DOI, normalized title, collection, or topic.
- **Primary tool:** Zotero MCP.
- **Preflight:** Match exact DOI first, then normalized title plus author/year.
- **Allowed:** Read item, child attachment, collection, tag, and note metadata; perform the minimum full-text/local-path check needed to classify readability.
- **Complete when:** Existence, duplicate status, attachment type, path availability, and readability are known.
- **Default stop:** Do not search externally, download, repair, import, or analyze.
- **Output:** Item key, attachment key, collection, PDF state, path state, next safe action.

## 2. Discovery

- **Trigger:** Search, find, retrieve candidates, or build a literature list.
- **Required input:** Topic; infer reasonable synonyms, year, type, and limit when safe.
- **Primary tool:** InstSci for ordinary discovery; specialist route when explicitly requested.
- **Preflight:** Check Zotero exact matches when DOI/title candidates become available.
- **Allowed:** Search, normalize DOI, deduplicate, rank, and save reviewable JSON/CSV.
- **Complete when:** Stable numbered candidates and source status are available.
- **Default stop:** No download, import, full-text analysis, or notes.
- **Output:** Numbered table with title, year, journal, DOI, relevance, OA hint, Zotero state.

## 3. Screening

- **Trigger:** Screen, sort, exclude, classify, or select by criteria.
- **Required input:** Stable candidate set and screening criteria.
- **Primary tool:** InstSci results plus metadata/abstract evidence.
- **Preflight:** Preserve candidate numbering and distinguish reviews, fibers, films, membranes, and other forms.
- **Allowed:** Include, exclude, rank, and explain uncertainty.
- **Complete when:** Included, excluded, and unresolved sets have reasons.
- **Default stop:** No acquisition unless explicitly authorized.
- **Output:** Decision, reason, evidence level, and stable result index.

## 4. Selection

- **Trigger:** Select numbered results or apply an explicit ranking rule.
- **Required input:** Stable result file and indices or rule.
- **Primary tool:** InstSci selection workflow.
- **Preflight:** Map indices to DOI/title from the original result set; do not rerun discovery.
- **Allowed:** Deduplicate DOI values, skip or flag missing DOI, save selection report.
- **Complete when:** A stable DOI/item set exists.
- **Default stop:** Selection alone does not authorize download.
- **Output:** Index-to-DOI mapping, skipped rows, ambiguity.

## 5. Acquisition

- **Trigger:** Download, get full text/PDF, use institutional access.
- **Required input:** Stable DOI list or exact items and a permanent output directory. Reuse a unique established project papers directory; ask once if none or multiple plausible directories exist.
- **Primary tool:** InstSci.
- **Preflight:** Check Zotero, InstSci manifests, and permanent local PDFs. Reuse verified readable files.
- **Allowed:** OA first, then publisher/institutional route; use visible CloakBrowser for final closed-access evidence.
- **Complete when:** Every DOI has a terminal row. Successful rows require verified readable files and permanent absolute paths; unresolved rows require an explicit failure/access status, evidence, `path=null` or `missing`, and a next action.
- **Default stop:** No Zotero import or analysis unless named.
- **Output:** DOI, publisher, route, file status, standard status, evidence, path state, absolute path when successful or `null` when unresolved, next action.

Default to main article only. Require explicit authorization for SI, document delivery, interlibrary loan, author contact, account creation, or purchase. Pause for credentials, OTP, CAPTCHA, or entitlement decisions.

## 6. Import Preview

- **Trigger:** Any request that would create or update Zotero items, attachments, collections, or related import state.
- **Required input:** Stable deduplicated DOI/item set, InstSci manifest, target collection, local PDF state, and Zotero duplicate reads.
- **Primary tool:** Zotero MCP and local/InstSci artifacts in read-only mode.
- **Preflight:** Resolve each collection to a unique name and collection key; verify metadata completeness, DOI/title duplicates, PDF validity, permanent absolute paths, and the source fingerprint.
- **Allowed:** Read Zotero and manifest state; calculate `create_item`, `update_existing`, `no_op`, and `blocked` actions; save `import_preview.json`; show action, completeness, path, and collection counts. Do not mutate Zotero or semantic-index records.
- **Complete when:** The preview is `preview_ready`, `preview_ready_with_exclusions`, or `preview_blocked`, and every deduplicated row has exactly one primary action. Blocked rows are excluded from execution by default.
- **Confirmation rule:** Require preview-ID confirmation for every deduplicated batch of two or more items and for any duplicate, update, missing field/PDF, path warning, collection ambiguity, blocked row, or user-requested preview. Bulk wording such as “direct execute” does not bypass confirmation.
- **Fast path:** Permit a `single-item all-green` plan without a second confirmation only when complete metadata, unique collection key, duplicate check, verified PDF, permanent path, planned `create_item`, and `linked_file` attachment all pass without warnings. Save the preview before writing.
- **Invalidation:** Before mutation, recompute and compare the source fingerprint, DOI duplicate state, collection key, and PDF path. Mark changed input as `preview_stale`, stop without writing, and regenerate the preview.
- **Default stop:** Stop for preview-ID confirmation whenever `confirmation_required=true`.
- **Output:** `import_preview.json`, preview ID/status, source fingerprint, target collection names/keys, per-row actions, completeness and path counts, `confirmation_required`, and index plan.

## 7. Zotero Import

- **Trigger:** Import or add acquired papers to Zotero/collection.
- **Required input:** Confirmed non-stale preview or a saved `single-item all-green` fast-path preview, verified successful InstSci rows, and resolved collection keys.
- **Primary tool:** Zotero MCP as the sole bibliographic metadata writer and verifier; InstSci supplies verified manifests and files.
- **Preflight:** Before the first mutation, recompute the source fingerprint and recheck DOI duplicates, every collection key, and every planned PDF path. Any difference marks the preview `preview_stale`, performs no writes, and returns to dry-run.
- **Resolution order:** Match normalized DOI exactly, then use normalized title plus author and year cautiously only when DOI is absent.
- **Allowed:** Resolve collection name to collection key, perform complete Zotero MCP create/update, add one `linked_file` attachment, add verified collection membership, and write verified Zotero keys back to the manifest.
- **Readback:** Verify DOI, a non-empty non-`Untitled` title, the creators/date/publication reported by the source, collection key, attachment key, `linked_file` mode, permanent absolute path and file existence, parent duplicate state, and equivalent attachment duplicate state.
- **Failure rule:** A formal row failure stops remaining mutations, preserves already verified rows, reports `import_partial`, and sets `sync_deferred`. Never count a created parent or attachment as successful before readback passes.
- **Complete when:** Report `import_verified` only when every formal row verifies, `no_mutation_required` when every row is `no_op`, or `import_partial` when a formal row fails.
- **Index sync:** After `import_verified`, call `zotero_update_search_database(force_rebuild=False)` once only when the preview reports a semantic change, then verify the affected item keys through semantic search. Use `sync_not_required` for a non-semantic plan, `sync_success` after verified retrieval, and `sync_failed` when the update or evidence check fails.
- **Default stop:** Do not analyze or create notes.
- **Output:** Preview ID/fingerprint, import state, sync state, item key, attachment key, collection key, `attachment_mode=linked_file`, absolute path, duplicate result, readback evidence, and item-key semantic-search evidence.

## 8. Ordinary Analysis

- **Trigger:** Analyze, summarize, explain, extract methods/results/limitations.
- **Required input:** Exact Zotero items, DOI values, or local PDFs.
- **Primary tool:** Zotero MCP for item resolution; Zotero-accessible text or local PDF for content.
- **Preflight:** Resolve items and classify source as full text, abstract, metadata, or inference.
- **Allowed:** Structured per-paper summary; cross-paper comparison only when explicitly requested.
- **Complete when:** Research question, methods, quantitative results, mechanism, innovation, limitations, relevance, and evidence levels are reported, using `not reported`, `not applicable`, or `insufficient evidence` where the source cannot support a field.
- **Default stop:** Do not create Zotero notes or invoke `nature-reader`.
- **Output:** Structured summary plus source limitations.

## 9. Deep Bilingual Reading

- **Trigger:** Full translation, bilingual parallel text, paragraph anchors, figure/table placement, complete reader artifact.
- **Required input:** Resolvable source and output location.
- **Primary tool:** `nature-reader`.
- **Preflight:** Detect source format and load its required reader fragments.
- **Allowed:** Produce the full figure-aware reader contract.
- **Complete when:** Required reader artifacts pass that Skill's verification.
- **Default stop:** Do not reduce to a summary-only output.
- **Output:** Reader artifact paths and limitations.

## 10. Multi-Paper Synthesis

- **Trigger:** Compare papers, summarize common routes, build a matrix, identify gaps.
- **Required input:** Exact paper set and comparison dimensions.
- **Primary tool:** Zotero/local full text; reuse existing analysis artifacts.
- **Preflight:** Normalize units and separate non-comparable material forms/test conditions.
- **Allowed:** Per-paper evidence table, cross-paper synthesis, research-gap inference.
- **Complete when:** Commonalities, differences, non-comparability, gaps, and implications are explicit.
- **Default stop:** Do not draft a formal review manuscript unless requested.
- **Output:** Comparison matrix and synthesis with evidence labels.

## 11. Zotero Note Writing

- **Trigger:** Add, save, create, or update a Zotero note.
- **Required input:** Exact parent item and finished analysis content.
- **Primary tool:** Zotero MCP.
- **Preflight:** Find an existing workflow note to update before creating another.
- **Allowed:** Create/update one child note and explicitly requested tags.
- **Complete when:** Note key exists and readback matches the intended content.
- **Default stop:** Do not modify bibliographic metadata.
- **Output:** Item key, note key, create/update action, readback verification.

## 12. Library Maintenance

- **Trigger:** Broken links, missing PDFs, duplicate items, path repair, semantic index.
- **Required input:** Target library scope and requested maintenance action.
- **Primary tool:** Zotero MCP plus local path checks and InstSci artifacts.
- **Preflight:** Distinguish MCP read failure, missing file, wrong path, and duplicate metadata.
- **Allowed:** Diagnose; repair paths or merge/delete only with explicit authorization.
- **Complete when:** Each affected item has a diagnosis and safe action.
- **Default stop:** No external search/download unless requested.
- **Output:** Item/attachment keys, diagnosis, path evidence, proposed or completed action.

## 13. Project Continuation

- **Trigger:** Continue, resume, remaining items, previous stop.
- **Required input:** Project identity, discoverable project artifacts, and a terminal stage from the current explicit request, an explicit scope earlier in the current conversation, or a saved scope/stop report.
- **Primary tool:** Local artifact inspection, then the executor for the requested incomplete stage.
- **Preflight:** Reconstruct discovery, selection, acquisition, import, and analysis states separately from the authorization envelope.
- **Allowed:** Resume the first authorized incomplete stage without repeating complete stages.
- **Complete when:** Requested continuation reaches its next stop gate.
- **Default stop:** Read-only inspection may resolve project identity and state. Ask one concise question if multiple projects remain plausible or the intended terminal stage is not authorized; offer the applicable stages among discovery, screening, selection, acquisition, import, analysis, synthesis, deep bilingual reading, note writing, and maintenance. Existing artifacts do not by themselves authorize downstream work.
- **Output:** Reconstructed state, resumed stage, reused artifacts, new results, next stop.
