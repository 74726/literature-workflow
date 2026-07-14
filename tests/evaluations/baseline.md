# Baseline Evidence: literature-workflow 1.0.0

## Complete metadata writer fallback

- Acquisition manifest contained correct titles for three papers.
- The InstSci runtime could not import `zotero_mcp` and used its minimal PyZotero fallback.
- Parent items were created with DOI and URL but empty title and creators.
- The sync report counted all three rows as metadata imports and successes.

## Non-ASCII collection handling

- Passing the collection name `纤维素` through the CLI produced a corrupted collection value.
- The first sync attempt failed until the collection key `AWMY388S` was used.

## Semantic index behavior

- Zotero contained the three imported items, but the semantic database remained at six documents.
- A later manual `force_rebuild=False` update processed and added the three items.
- All three item keys were retrievable after that update.

## Required corrections

- Refuse minimal parent creation when the complete writer is unavailable.
- Verify title, creators, DOI, collection key, attachment, and path before success.
- Preview batch mutations before writing.
- Synchronize the index after a fully verified semantic change.
