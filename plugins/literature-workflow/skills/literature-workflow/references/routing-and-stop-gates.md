# Routing and Stop Gates

## Contents

1. Intent envelope
2. Trigger families
3. Precedence
4. Multi-stage requests
5. Specialist routing
6. Ambiguity and non-triggers

## Intent Envelope

Before acting, derive:

```yaml
project: stable project name or null
objects: collection, Zotero keys, DOI values, result indices, or PDF paths
stages: ordered explicit stages
constraints:
  allow_download: false
  allow_import: false
  allow_analysis: false
  allow_note_write: false
  allow_document_delivery: false
  include_supplementary_information: false
stop_gate: stage or null
evidence_requirement: metadata | abstract | full_text | bilingual_reader
```

Set an `allow_*` value to true only from explicit wording. An explicit ordered multi-stage request authorizes those named stages, but no unnamed stage.

## Trigger Families

| Wording family | Route |
|---|---|
| `Zotero里有没有`, `先查重`, `哪些已有PDF` | library preflight |
| `搜索`, `查找`, `检索`, `找论文`, `候选列表` | discovery |
| `筛选`, `排序`, `排除`, `选出最相关` | screening |
| `选1-5`, `保留2、4、7` | selection |
| `下载`, `获取原文`, `获取PDF`, `学校权限` | acquisition |
| `导入Zotero`, `添加到集合` | import |
| `分析`, `总结`, `概括`, `关键数据` | ordinary analysis |
| `全文翻译`, `中英对照`, `逐段`, `图表落位` | deep reader |
| `比较这些文献`, `横向对比`, `研究空白` | synthesis |
| `写入笔记`, `添加到对应笔记`, `更新阅读笔记` | note writing |
| `断链`, `重复条目`, `附件路径`, `语义索引` | maintenance |
| `继续`, `上次`, `剩下的`, `从停止位置` | continuation |

## Precedence

Apply:

```text
negative constraint > explicit action > object qualifier > specialist qualifier > inferred next step
```

Examples:

- `搜索20篇，但不要下载` authorizes discovery only.
- `下载1-5并导入Zotero，不分析` authorizes acquisition and import only.
- `分析并添加到对应笔记` authorizes analysis and note writing.
- `只根据摘要总结` sets `evidence_requirement=abstract` and forbids PDF reading.
- `不要文献传递` keeps document delivery forbidden even after access failure.

## Manual Stop Gates

When discovery or screening is requested, stop before acquisition when the request contains:

```text
先返回 | 供我筛选 | 只列出 | 不要下载 | 先看看 | 给我候选列表
```

Do not reinterpret a later phrase such as `然后下载前5篇` as permission to bypass `供我筛选`. Return the candidate list and wait for the user's selection.

In an analysis, synthesis, reading, note, or maintenance request, `不要下载` sets `allow_download=false` but does not stop work on already available Zotero text, abstracts, or permanent local PDFs.

## Multi-Stage Requests

- Proceed sequentially when every stage is explicit and no stop gate intervenes.
- Permit automatic selection when the user gives a rule such as `最相关5篇`.
- Preserve stable search-result indices; never rerun and silently remap `1-5`.
- Ask one concise question when `完整流程` omits the stopping point or authorized writes.
- Treat project artifacts as evidence of state, not evidence of permission. For `继续`, recover permission from the current explicit request, an explicit scope earlier in the current conversation, or a saved scope/stop report. `把剩下的做完` alone names no terminal stage. Read-only state inspection is allowed; if no scope exists, ask one concise question covering the applicable terminal stages before mutation or external acquisition.
- Pause for login, CAPTCHA, OTP, payment, entitlement, document delivery, or destructive Zotero operations.

## Specialist Routing

| Observable wording | Required route |
|---|---|
| PubMed, MeSH, Scopus, WoS, strict other-citation, influential citers | `nature-academic-search` |
| Give a paragraph supporting references, Nature/CNS citations | `nature-citation` |
| Verify author/title/year/volume/pages/DOI fields | `nature-ref-verifier` |
| Full translation, bilingual parallel reader, source anchors, figure placement | `nature-reader` |

`详细总结` or `深度分析` alone remains ordinary analysis. Do not invoke `nature-reader` without a reader-specific deliverable.

For a single clearly scoped specialist stage, let the specialist Skill lead directly. Use this Skill as orchestrator only when the request also has continuation, cross-stage work, a stop gate, or Zotero/InstSci/local-file coordination.

If the specialist is unavailable, state the missing capability. Do not silently substitute general web search for MeSH, strict citation audit, Zotero writes, or full bilingual-reader requirements.

## Continuation Rationalization

| Excuse | Reality |
|---|---|
| `把剩下的做完` clearly authorizes the whole historical workflow | It identifies unfinished work but not its terminal stage. Reconstruct facts, then ask the stage boundary. |

## Ambiguity and Non-Triggers

Resolve a named Zotero collection, result list, or project artifact before asking the user. Ask only when multiple plausible projects or item sets remain.

Do not lead with this Skill for pure polishing, manuscript drafting, slide creation, reviewer response, data-availability writing, figure creation, patent drafting, or unrelated web research. It may supply literature evidence to those workflows when the request explicitly includes discovery, acquisition, Zotero, or reference support.
