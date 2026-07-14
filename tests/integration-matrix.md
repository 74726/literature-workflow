# Literature Workflow 1.1.0 Integration Matrix

| Case | Setup | Expected preview | Expected import | Expected sync | Evidence |
|---|---|---|---|---|---|
| 20-item mixed batch | duplicates, missing PDFs, two collections | confirmation required; blocked rows excluded | execute only confirmed planned rows | sync after all planned mutations verify | preview ID, action counts, collection keys |
| Single-item all-green | complete metadata, unique collection, valid PDF | saved preview; no second confirmation | create complete item and linked PDF | sync once | preview file, item key, attachment key |
| Complete writer unavailable | Zotero MCP writer disabled | plan identifies unavailable writer | no minimal parent creation | deferred | Zotero readback and stopped status |
| Chinese collection | target `纤维素` | name resolved to key | key used and read back | according to semantic change | collection key and item metadata |
| Stale preview | manifest or PDF path changes after preview | `preview_stale` | no write | no sync | old/new fingerprints and path check |
| Formal row failure | two planned writes pass, one fails | confirmed plan | `import_partial`; remaining rows stop | `sync_deferred` | row statuses and absence of update call |
| Verified semantic batch | all planned writes pass | `sync_planned` | `import_verified` | `sync_success` | update counts, timestamp, item-key searches |
| Search verification failure | update call succeeds but item key is absent | `sync_planned` | `import_verified` | `sync_failed` | update result and failed search evidence |
| Non-semantic changes | note-only, tag-only, collection-only, or all no-op | `sync_not_required` | requested metadata action only | no sync call | mutation summary and index status |
| Local plugin pickup | validated feature branch installed | not applicable | no Zotero mutation | not applicable | plugin version and new-task behavior |
