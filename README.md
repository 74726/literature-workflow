# Literature Workflow

`literature-workflow` 是一个面向科研文献全流程的 Codex Skill。它负责确定当前授权阶段、选择主要工具、复用既有成果，并严格停在用户要求的位置，减少重复检索、重复下载、重复导入和无授权的下游操作。

它可以协调 InstSci、Zotero MCP、本地 PDF 和若干专业 `nature-*` Skills，但不捆绑这些第三方工具。

## 主要能力

- 文献发现、筛选和稳定编号；
- DOI/PDF 获取及学校订阅访问流程；
- Zotero 查重、`linked_file` 导入和附件状态核验；
- 单篇或多篇文献的证据分级总结；
- 明确授权后的横向综合、研究空白和 Zotero 笔记；
- 断链、重复条目和缺失附件的诊断；
- 从项目工件恢复进度，跳过已经完成的步骤；
- 遇到登录、验证码、权限、付费或破坏性操作时暂停。

## 安装

### 方式一：作为插件安装（推荐用于分享）

先添加本仓库 marketplace：

```powershell
codex plugin marketplace add 74726/literature-workflow
```

随后在 ChatGPT/Codex 的插件目录中安装 **Literature Workflow**。

### 方式二：只安装 Skill

可以让 Codex 执行：

```text
$skill-installer 安装 https://github.com/74726/literature-workflow/tree/main/plugins/literature-workflow/skills/literature-workflow
```

不要同时安装插件版和独立 Skill 版，否则可能出现两个同名 Skill。切换安装方式前，先移除旧副本。

## 基本用法

显式调用最稳定：

```text
$literature-workflow <你的任务>
```

系统也可根据任务内容自动触发。涉及多阶段、续作、人工筛选门、`不要下载` 等负面约束、Zotero/InstSci/本地文件协调、普通文献总结或多篇综合时，建议显式写出 `$literature-workflow`。

## 提示词速查

| 目标 | 推荐提示词 | 预期停止点 |
|---|---|---|
| 只检索候选 | `$literature-workflow 搜索2022年后的纤维素高韧纤维论文，先返回20篇供我筛选，不要下载` | 返回稳定编号候选表 |
| 根据标准筛选 | `$literature-workflow 从这20篇中筛出真正研究纤维、且报告强度或韧性数据的论文，保留原编号，不要下载` | 给出纳入、排除和待定理由 |
| 选择编号 | `$literature-workflow 保留结果2、4、7，生成稳定DOI清单，不要下载` | 选定集合和索引映射 |
| 只下载正文 | `$literature-workflow 下载结果1-5，只要正文，不要SI，不导入Zotero` | PDF状态和永久路径验证 |
| 下载并导入 | `$literature-workflow 下载结果1-5并导入Zotero的“纤维素”集合，使用linked_file，不分析` | Zotero导入验证完成 |
| 导入已有PDF | `$literature-workflow 把项目papers目录下已验证的3篇PDF导入Zotero“纤维素”集合，查重，使用完整绝对路径，不分析` | 返回item/attachment key |
| 总结单篇 | `$literature-workflow 总结Zotero中的“论文标题”，优先读取已有全文，不要下载，不写笔记` | 证据分级的结构化总结 |
| 逐篇总结多篇 | `$literature-workflow 总结Zotero“纤维素”集合下指定的5篇，逐篇报告方法、数据、机制和局限，不做横向比较，不写笔记` | 五篇逐篇总结 |
| 横向综合 | `$literature-workflow 比较这5篇文献的制备路线、强度、韧性和测试条件，建立矩阵并分析研究空白` | 对比矩阵与综合结论 |
| 写入Zotero笔记 | `$literature-workflow 把刚才完成的总结写入对应文献的子笔记，优先更新已有工作流笔记并回读验证` | 返回note key和验证结果 |
| 只检查断链 | `$literature-workflow 检查Zotero“纤维素”集合的附件断链，只诊断，不下载、不修改、不删除` | 附件诊断报告 |
| 缺失后重绑 | `$literature-workflow 检查这篇的附件；只有确认LOCAL_FILE_MISSING时才重新获取正文并绑定原条目，不要新建重复条目，不删除旧附件` | 诊断或授权范围内的修复 |
| 继续旧项目 | `$literature-workflow 继续纤维素项目，复用已有结果和PDF，最多做到Zotero导入，不分析、不写笔记` | 导入或更早的人工停止点 |
| 全文双语精读 | `$literature-workflow 对这篇做全文中英对照，保留原文锚点，并把图表放回对应位置` | 转交 `nature-reader` 完整读者产物 |

## 什么时候不用它

以下单一专业任务应直接使用对应 Skill：

| 任务 | 直接使用 |
|---|---|
| PubMed、MeSH、严格他引、引用者画像 | `nature-academic-search` |
| 给论文段落寻找支撑引用 | `nature-citation` |
| 核对作者、题名、卷期、页码和DOI | `nature-ref-verifier` |
| 全文翻译、中英对照、原文锚点、图表落位 | `nature-reader` |
| 论文润色、写作、PPT、审稿回复 | 相应的写作或演示 Skill |

`详细总结`、`深度分析`、`读懂这篇`本身仍属于普通分析；只有明确要求双语、翻译、原文锚点或图表落位时才使用 `nature-reader`。

## 关键规则

1. 当前请求和负面约束优先于旧计划；旧范围不能扩大当前任务。
2. `供我筛选`、`先返回`、`先看看`会在候选表处暂停，即使同一句后面写了下载。
3. 在分析任务中，`不要下载`不阻止读取已经存在的 Zotero 正文、摘要或永久本地 PDF。
4. Zotero MCP 读取失败不等于本地 PDF 丢失；先检查永久绝对路径。
5. `linked_file` 必须指向永久研究目录，拒绝相对路径、Temp、浏览器缓存和诊断目录。
6. Zotero 条目同步不会自动同步外部 linked file；文件同步由用户自行管理。
7. 普通多篇总结不会自动升级为比较或研究空白分析。
8. 缺少全文时必须标记 `[摘要]` 或 `[元数据]`，不得把推断写成全文结论。
9. 登录、SSO、OTP、CAPTCHA、付费和权限判断由用户在可见界面中完成。
10. 文献传递、馆际互借、联系作者、购买、删除和合并均需要明确授权。

## 依赖与兼容性

本仓库只提供工作流 Skill。以下组件均为可选且需单独安装：

- [Rimagination/instsci](https://github.com/Rimagination/instsci)
- [deathcats4/instsci-workflow](https://github.com/deathcats4/instsci-workflow)
- [54yyyu/zotero-mcp](https://github.com/54yyyu/zotero-mcp)
- 用户自行安装的 `nature-*` Skills

缺少某个组件时，Skill 应报告能力缺失；不得用证据质量更低的工具静默冒充专业结果。

## 版权与非隶属声明

本仓库不包含上述第三方项目的源码、二进制、模型、配置、凭据或数据。项目名称仅用于描述兼容性和互操作性。本项目不代表这些第三方项目，也未获得其官方背书。详见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。

## License

MIT。许可证只覆盖本仓库原创内容，不改变任何第三方组件各自的许可证。

## English summary

Literature Workflow is a skill-only Codex plugin that coordinates literature discovery, lawful full-text acquisition, Zotero linked-file management, evidence-aware analysis, notes, maintenance, and safe continuation. Third-party tools are optional and are not bundled.
