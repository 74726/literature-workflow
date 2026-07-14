# Literature Workflow 1.1.1 + InstSci 严格导入热修复设计

## 1. 目标

修复 `literature-workflow 1.1.0` 在真实 Zotero 导入中出现的两个问题：

1. InstSci 在完整元数据后端不可用时降级创建仅含 DOI/URL 的父条目，导致标题、作者和期刊缺失。
2. Zotero MCP 以 Web 模式运行时无法读取本地 `linked_file`，从而把读取接口限制误判为附件导入失败。

热修复后，对外由一次 InstSci 严格导入命令完成书目父条目和 `linked_file` 附件写入；`literature-workflow` 负责导入预览、用户确认、调用、状态解释和导入后的同步索引。

## 2. 适用仓库与版本

- 编排插件：`D:/Codex/1/literature-workflow-release`
  - 目标版本：`1.1.1`
  - GitHub：`74726/literature-workflow`
- 导入执行器：`D:/Codex/1/instsci-workflow`
  - 当前版本：`0.2.0a1`
  - GitHub：`deathcats4/instsci-workflow`

两个仓库必须配套验证。仅修改编排文档而不修复 InstSci 的最小元数据降级，不构成完成。

## 3. 已确认根因

当前 InstSci `PyzoteroSyncBackend` 尝试导入 Zotero MCP 的 `add_by_url`。导入失败时，它把 `_mcp_add_by_url` 设为 `None`，随后使用 Pyzotero 创建一个只含 URL、DOI、标签和集合的 `journalArticle`。该路径不会填充标题、作者、期刊或日期。

当前 Zotero MCP 运行在 Web 模式。Web 模式可以读写云端条目记录，但 `zotero_get_attachment_path` 只支持本地模式；`zotero_get_pdf_outline` 也不能读取仅存在于本机路径的 `linked_file`。这些返回值属于 `MCP_READER_UNAVAILABLE`，不能单独证明附件损坏。

## 4. 选定架构

### 4.1 对外接口

用户和 `literature-workflow` 只调用一次 InstSci 严格导入。对外不逐篇编排 Zotero MCP 工具调用。

```text
Import Preview
-> 用户确认 preview_id
-> InstSci 严格导入一个批次
-> 读取精简摘要和失败行
-> 全部正式行通过验证
-> zotero_update_search_database(force_rebuild=False) 一次
-> 用受影响 item key 核验语义检索
```

### 4.2 内部职责

- InstSci：批次选择、DOI 查重、完整元数据写入、集合写入、`linked_file` 创建、读回验证、报告和清单回写。
- Zotero MCP 组件：作为 InstSci 内部的强制完整元数据后端；不得由代理逐篇调用以完成导入。
- Pyzotero：创建 `linked_file`、读取云端条目和附件记录；不得用于创建最小书目父条目。
- `literature-workflow`：权限和预览门、执行一次严格导入、解释状态、同步索引。

“由 InstSci 完全负责文献导入”表示用户可见的导入执行器只有 InstSci；不表示重新实现一套 Crossref 到 Zotero 的字段映射。

## 5. InstSci 严格导入契约

### 5.0 正式 CLI 接口

正式写入使用现有 `zotero sync` 命令并把严格行为设为默认；不提供允许最小元数据降级的开关：

```powershell
instsci zotero sync MANIFEST `
  --preview IMPORT_PREVIEW_JSON `
  --confirm-preview-id PREVIEW_ID `
  --collections COLLECTION_KEY_LIST `
  --attach-mode required `
  --attachment-mode linked_file `
  --output ZOTERO_SYNC_REPORT_JSON
```

- `--preview`：`literature_workflow.import_preview.v1` 文件；正式写入必填。
- `--confirm-preview-id`：必须与 preview 文件中的 `preview_id` 完全一致；正式写入必填。
- `--collections`：严格模式只接受一个或多个已解析 collection key，不接受名称。
- `--attach-mode required`：没有现存、有效 PDF 的行不得进入正式写入。
- `--attachment-mode linked_file`：本次唯一支持的附件模式。
- `--dry-run`：允许省略确认值，且不得写入 Zotero、清单或索引。

为避免不必要的命令迁移，命令名保持 `sync`；其元数据失败行为从“最小降级”改为“失败关闭”。没有显式 `--dry-run` 时，缺少 preview 或 confirmation 的旧调用以 `preview_required`、退出码 2、零写入结束；不会静默改成 dry-run。

### 5.1 启动预检

InstSci 在首次 Zotero 写入前一次性验证：

1. Zotero API 身份、库类型和写权限有效。
2. 完整元数据后端可导入并可调用 DOI 路径。
3. 所有正式行具有规范化 DOI。
4. 每个集合均已解析为唯一的 8 字符 collection key；CLI 不接收未解析的中文集合名称作为写入参数。
5. 每个计划附件是存在、可读、非临时目录下的永久绝对 PDF 路径。
6. 源清单与已确认 Import Preview 的指纹、正式行集合和 collection key 一致。

任一全局预检失败时，状态为 `preflight_blocked`，Zotero 写入次数必须为零。

### 5.2 完整父条目

每行按规范化 DOI 精确查重：

- 已有唯一父条目：复用该 item key，并按计划补全元数据或集合。
- 没有父条目：通过完整 DOI 元数据路径创建，附件模式固定为 `none`。
- 多个 DOI 父条目：该行 `blocked_duplicate_parent`，不自动合并、删除或选择保留项。

父条目必须回读并验证：

- DOI 精确一致；
- title 非空且不是 `Untitled`；
- creators 非空；
- publication title 与 date 在来源提供时非空；
- collection key 与计划一致。

完整元数据后端不可用、返回无法识别的 item key 或回读失败时，该行失败。禁止 Pyzotero 最小父条目降级。

### 5.3 `linked_file` 附件

只有父条目通过完整回读后才进入附件阶段。

- 已有相同规范化绝对路径的 `linked_file`：复用附件 key，动作记为 `attachment_no_op`。
- 已有等价文件但路径或附件状态冲突：该行 `blocked_attachment_conflict`，不新增第二个附件。
- 没有等价附件：在已验证父 item key 下创建一个 `linked_file`。

附件回读必须验证：

- parent item key；
- attachment key；
- `linkMode=linked_file`；
- 规范化永久绝对路径；
- 本地文件仍存在且可读；
- 无等价重复附件。

Web 模式下，不使用 `zotero_get_attachment_path` 或 PDF outline 作为 `linked_file` 成败判据。使用 Pyzotero 附件记录、InstSci 报告和本地文件证据。MCP 404、`requires local mode` 或 `No PDF attachment found` 记为 `MCP_READER_UNAVAILABLE`，不覆盖已验证的本地附件状态。

### 5.4 批次失败规则

正式行按预览顺序执行。第一条正式行失败后：

- 保留此前已经验证的父条目和附件；
- 停止剩余正式行；
- 剩余行标记为 `not_attempted_after_failure`；
- 批次状态为 `import_partial`；
- 索引状态为 `sync_deferred`。

若父条目已完整创建但附件失败，保留完整父条目，不自动删除。任何父条目删除、附件删除、重复合并或附件替换仍需单独授权。

## 6. 报告接口与 Token 控制

详细报告写入 `zotero_sync_report.json`，schema 升级为 `instsci.zotero_sync_report.v2`。每行至少包含：

- DOI、计划动作和最终动作；
- metadata state、attachment state、verification state；
- item key、attachment key、collection keys；
- attachment mode、永久路径；
- duplicate state；
- error code 和安全下一步。

CLI 默认只输出精简摘要：

- requested、deduplicated、formal、blocked；
- created、reused、updated、no-op；
- attachment created/reused/conflict；
- verified、failed、not attempted；
- report path。

代理默认只读取摘要；仅在失败时读取报告中的失败行，不把全部条目元数据回灌到对话上下文。批量规模不改变代理工具调用数量：一次 InstSci 导入，加上满足条件时的一次同步索引。

## 7. Literature Workflow 1.1.1 变更

### 7.1 路由

- Import Preview 继续由 `literature-workflow` 生成并执行确认门。
- 正式写入只允许调用 InstSci 严格导入模式。
- 禁止代理回退到逐篇 Zotero MCP 导入、不支持 preview/confirmation 握手的旧版 InstSci、Pyzotero 最小条目或 Zotero Storage 附件。
- 严格能力不可用时停止并报告 `strict_import_unavailable`。

### 7.2 状态

保留 1.1.0 的 preview/import/sync 三维状态，并增加：

- `preflight_blocked`
- `strict_import_unavailable`
- `blocked_duplicate_parent`
- `blocked_attachment_conflict`
- `not_attempted_after_failure`
- `MCP_READER_UNAVAILABLE`

`MCP_READER_UNAVAILABLE` 是读取能力状态，不是 import state。

### 7.3 同步索引

只有 `import_verified` 且预览含语义变化时，调用一次：

```text
zotero_update_search_database(force_rebuild=False)
```

同步完成后，用本批受影响 item key 做语义检索核验。索引失败不回滚已验证的 Zotero 导入，状态为 `import_verified, sync_failed`。

## 8. 测试设计

### 8.1 InstSci 单元测试

必须先增加失败测试，再修改实现：

1. 完整元数据后端不可用时零写入并 `preflight_blocked`。
2. 不存在最小 Pyzotero 父条目降级路径。
3. DOI 已存在时复用唯一父 item key。
4. 多个 DOI 父条目时阻塞该行。
5. 父条目缺标题、作者、期刊或日期时不创建附件。
6. 已有相同路径附件时 no-op。
7. 附件冲突时不创建第二附件。
8. 第一行正式失败后不执行剩余行。
9. Web 模式 reader 错误不会把已验证 `linked_file` 改判为失败。
10. v2 报告计数与逐行状态一致。

### 8.2 Literature Workflow 契约测试

1. 版本唯一来源为 `1.1.1`。
2. 运行时明确要求 InstSci 严格模式。
3. 运行时禁止最小元数据降级和普通宽松同步。
4. Import Preview ID、指纹和 collection key 传递一致。
5. `import_partial` 必须得到 `sync_deferred`。
6. `MCP_READER_UNAVAILABLE` 不等于附件缺失。
7. 全绿后只执行一次 `force_rebuild=False`。
8. CLI 摘要契约限制默认输出规模。

### 8.3 集成验证

- 先运行两个仓库的全部自动化测试和验证器。
- 使用现有已验证条目执行只读或 no-op 路径验证，不新增重复条目。
- 验证 InstSci 严格模式能识别完整父条目与现有 `linked_file`。
- 不在自动测试中删除 Zotero 条目、附件或回收站内容。
- 新建真实 Zotero 条目的端到端测试另设用户确认点。

## 9. 发布与兼容性

- InstSci 代码修复和 `literature-workflow 1.1.1` 分别使用独立分支和提交。
- 本机先安装配套 InstSci 版本，再安装 `literature-workflow 1.1.1`。
- 新任务验证插件实际加载 1.1.1，并验证 InstSci 严格能力可用。
- GitHub push、PR、merge、tag 和上游 InstSci 发布不由本设计自动授权，分别在本地验证通过后报告并等待确认。
- 若 InstSci 严格能力缺失，1.1.1 必须失败关闭，不得使用旧导入路径。

## 10. 非目标

- 不重写 Crossref 到 Zotero 的完整字段映射。
- 不切换为 Zotero Storage 或 `stored_file`。
- 不改变 `linked_file`、永久绝对路径和用户自行同步文件的政策。
- 不自动删除、合并或替换 Zotero 条目和附件。
- 不自动重建全部语义索引。
- 不在本次热修复中处理一般性的 Zotero 翻译、WebDAV 或 PDF 阅读器问题。

## 11. 完成标准

只有同时满足以下条件才可声明热修复完成：

1. InstSci 不再包含可到达的最小父条目降级路径。
2. 严格导入的预检、完整元数据、附件、失败停止和 v2 报告测试全部通过。
3. `literature-workflow` 版本为 1.1.1，全部契约测试和插件验证通过。
4. 现有条目的 no-op 集成验证不产生重复父条目或附件。
5. 新 Codex 任务加载正式安装的 1.1.1，并正确选择 InstSci 严格导入。
6. 临时测试工件、授权和工作区按批准范围清理完成。
