# Trigger Examples

## Contents

1. Baseline boundary cases
2. Stage prompts
3. Combined requests
4. Specialist routing
5. Non-triggers

## Baseline Boundary Cases

| Prompt | Stage | Primary tool | Must do | Must not do | Stop point |
|---|---|---|---|---|---|
| `搜索纤维素2022年后的论文，先返回20篇供我筛选，不要下载` | discovery | InstSci | Return stable candidates | Download/import/analyze | candidate list |
| `把下载好的导入Zotero` | import | InstSci sync + Zotero verification | Use verified absolute linked files | Create notes or analyze | verified import report |
| `Zotero读不到附件；若本地缺失就重新下载并绑定原条目` | maintenance -> conditional acquisition/rebind | Zotero + local artifacts + InstSci if missing | Reuse valid local PDF; otherwise reacquire and rebind the existing item | Duplicate item or unnecessary download | verified diagnosis or repaired attachment |
| `总结Zotero纤维素目录下这5篇` | ordinary analysis | Zotero entrypoint + local fallback | Resolve exact items and evidence levels | Redownload/reimport/write notes | summary |
| `继续上次纤维素流程` | continuation | artifacts, then stage executor | Reconstruct state | Repeat completed stages | next requested gate |
| `继续上次项目，把剩下的做完`，但没有保存终点阶段 | continuation clarification | artifacts only | Reconstruct facts and ask the terminal stage | Infer import/analysis/note permission from existing artifacts | authorization clarification |
| `临时用已停用的nature-literature-pipeline` | prohibited | none | Explain prohibition | Invoke disabled workflow | prohibition report |
| `只根据摘要总结，不读PDF` | ordinary analysis | Zotero metadata/abstract | Label abstract evidence | Read full text | abstract summary |
| `总结Zotero这5篇，不要下载，不写笔记` | ordinary analysis | Zotero + existing local evidence | Summarize exact items with evidence labels | Download, compare, or write notes | per-paper summaries |

## Stage Prompts

| Prompt | Expected result |
|---|---|
| `Zotero里有没有这篇？` | Exact DOI/title preflight only |
| `搜索近五年再生纤维素高韧纤维论文` | Discovery only unless more stages are named |
| `从这20篇筛出最相关5篇` | Screening with reasons, no acquisition |
| `保留2、4、7` | Stable selection mapping, no acquisition |
| `下载1-5，只要正文，不要SI` | Acquisition and verification only |
| `导入纤维素集合，不要分析` | Import and verify, then stop |
| `分析这篇的工艺、强度、韧性和局限` | Ordinary full-text analysis |
| `全文中英对照并把图表放回对应位置` | Route to `nature-reader` |
| `比较这5篇并找研究空白` | Multi-paper synthesis |
| `把刚才总结写入对应文献笔记` | Note write plus readback |
| `检查断链附件` | Maintenance diagnosis only |
| `继续未完成的检索阶段` | Resume discovery only; do not infer acquisition or later stages |

## Combined Requests

| Prompt | Expected stage sequence |
|---|---|
| `搜索并下载最相关5篇` | Discover -> apply explicit ranking -> acquire |
| `搜索20篇，先返回供我筛选，然后下载前5篇` | Discover -> stop for manual selection |
| `下载1-5并导入Zotero，不分析` | Acquire -> import -> stop |
| `分析并添加到对应笔记` | Analyze -> write note -> verify note |
| `搜索、下载、导入并分析` | Execute named stages sequentially; stop on authentication or failure |
| `走完整流程` | Ask which stages and whether manual screening is required |

## Specialist Routing

| Prompt | Route |
|---|---|
| `用PubMed和MeSH构建检索式` | `nature-academic-search` |
| `统计严格他引并分析引用者` | `nature-academic-search` |
| `给这段话找Nature/CNS支撑文献` | `nature-citation` |
| `核对这些参考文献的作者、卷期和DOI` | `nature-ref-verifier` |
| `逐段全文翻译并建立原文锚点` | `nature-reader` |

## Non-Triggers

| Prompt | Lead workflow |
|---|---|
| `润色这个摘要` | `nature-polishing` |
| `根据已有结果写论文引言` | `nature-writing` unless literature evidence must first be gathered |
| `把这篇论文做成组会PPT` | `nature-paper2ppt` |
| `帮我回复审稿人` | `nature-response` |
| `写数据可用性声明` | `nature-data` |
| `查询今天的天气` | web/weather, not literature workflow |
