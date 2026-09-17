# hermes-default-agent

签单跟进助手 - Hermes default agent

本仓库是「小 ice / 小 code」这一套 **Hermes 默认 agent 的配置与技能定义仓库**：它不是可编译的应用程序，而是一份"给 Hermes 运行时读取"的声明式配置集合，包含 agent 人格与业务规则（`SOUL.md`）、运行时配置（`config.yaml`）、定时任务定义（`cron/jobs.json`）、客户归档索引（`data/ARCHIVE-INDEX.md`），以及两组 business 技能（Skills）：`git-backup` 与 `signing-workflow-system`。

---

## 项目简介与用途

### 这是什么

- **Hermes default agent 配置仓库**：仓库根目录的 `SOUL.md` + `config.yaml` 就是 Hermes 默认 agent 的"身份 + 运行时参数"。运行时目录约定为 `/home/anna/.hermes`（见 `profiles/code/skills/business/git-backup/SKILL.md` 与三个备份脚本），本仓库即该目录中**属于业务定义的那部分文件**的快照。
- **不含可编译代码**：仓库里没有 `package.json`、`pyproject.toml`、`Makefile`，全仓库共 44 个文件，主体是 Markdown 技能文档、YAML/JSON 配置、3 个 bash 备份脚本、1 个 bash 自测脚本，以及 HTML/PNG 模板与测试样本。

### 「签单跟进助手」的定位

依据 `SOUL.md`，该 agent 名为「小 ice」，是**香港经纪行保险顾问的专属签单跟进智能系统**：

- **立足场景**：香港保险经纪行业（受香港保险业监管局 IA 规管），服务对象是保险经纪 / 理财顾问（"顾问"），终端对象是投保人 / 受保人（"客户"）。
- **核心业务**：香港本地居民投保、内地客户赴港投保（跨境投保），以及续保、理赔协助、保单变更等售后维护。
- **签单类型**：储蓄分红险（整付 / 期付）、重疾险、医疗险、人寿险、投资连结险（ILAS）。
- **职责定位**：精准统筹客户**行程、资料审核、面谈对接、售后维护**全环节，以合规展业为前提、以高效成交为目标。
- **合规红线**（`SOUL.md` 明列）：跨境投保客户必须亲身赴港签署；FNA（财务需要分析）必须完成并存档；如实告知义务；冷静期内不得阻拦退保；不得承诺非保证收益；佣金及回扣披露需符合 IA 规定；销售文件须保留备查。
- **行为约束**：不代替顾问做商业决策（产品推荐、定价、折扣让步）、不修改已归档历史记录、不跨阶段执行（签单前未完不进签单中）、未经确认不发送客户通知；发送通知、修改客户关键信息、跳过步骤、涉及保费金额与缴费方式的操作，均须顾问确认。
- **沟通风格**：用中文（术语可中英混用），简洁、主动同步、每次输出都有信息增量；用固定格式汇报进度（`[阶段] 进度 n/m`、`✓/⏳/○/[!]`），异常用 `[!]` 开头一句话说清"异常 + 影响 + 建议"，一次最多追问 2 个问题。

### 它管理哪些能力

仓库管理两组 business 技能，分别由 `profiles/code/` 与 `skills/` 两个目录承载：

**1. `git-backup`（签单助手自身的版本备份）**

`profiles/code/skills/business/git-backup/SKILL.md` 定义的三条工作流，把本 agent 的全部业务文件备份到远程仓库：

| 工作流 | 场景 | 入口 |
|--------|------|------|
| A 首次初始化上传 | 首次将 default agent 上传到远程（远程已有 README/LICENSE 等初始化文件） | `scripts/git-init.sh` |
| B 日常迭代更新（最常用） | 每次修改 `SOUL.md`、`config.yaml`、skills 等文件后同步到远程 | `scripts/git-update.sh` |
| C 版本标签发布 | 完成一个重要版本迭代后打版本标签 | `scripts/git-tag.sh` |

技能内固定配置（写入脚本常量，不在仓库里保存令牌）：用户名 `annafby`、邮箱 `annafby@qq.com`、远程仓库 `https://git.uozi.com/annafby/hermes-default-agent.git`、本地目录 `/home/anna/.hermes`、默认分支 `main`。安全规则明确要求令牌只嵌入本地 git remote URL，不写入任何文件。

**2. `signing-workflow-system`（签单业务本体）**

`skills/business/signing-workflow-system/SKILL.md` 是一份伞形（umbrella）技能，把原先 6 个独立技能合并为一个：

- `signing-followup` —— 主协调器，监控事件、激活触发器、委派子 agent；
- `presign-agent` —— 签单前：解析工单、生成行程、创建客户目录、发送提醒、更新索引；
- `insign-agent` —— 签单中：解析签单结果、逐项确认、生成差异摘要、更新状态；
- `postsign-agent` —— 签单后：逐项收集缴费数据、生成缴费页面与海报、推送客户、归档；
- `image-designer` —— 出图工具：HTML 模板 → 浏览器截图 → PNG，供行程海报与缴费海报使用；
- `conversation-flow-optimization` —— 对话模板：阶段汇报、引导、确认、错误处理。

事件驱动的三个触发点（`SKILL.md`）：

```
工单确认（Trigger 1）      → presign-agent（签单前）
签单前一天（Trigger 2）    → presign-agent（提醒）
签单日/签单后（Trigger 3） → insign-agent（签单中） → postsign-agent（签单后）
```

### 适用场景

- 顾问把一个工单（客户姓名、签单类型、缴费方式、保额、签约日期与地点）交给 agent，由 agent 完成签单前 → 签单中 → 签单后 → 归档的全流程跟进。
- 需要把行程 / 缴费信息做成**手机竖屏 1080×1920 的 PNG 海报**推送到企业微信群；推送遵循"每次动作只推一张干净 PNG、不显示文件路径、`MEDIA:` 独占首行"的铁律。
- 用 T-1 / 签单日定时任务自动生成并推送提醒（见 `cron/jobs.json`）。
- 每次修改 agent 配置后，一键备份到 Gitea 远程仓库并打版本标签。

---

## 环境依赖与安装步骤

### 重要前提：本仓库不含可编译代码

本仓库是**配置 / 技能定义仓库**，没有任何需要 `build`、`compile`、`install` 的产物。它的"运行"完全依赖 Hermes 运行时来读取 `SOUL.md`、`config.yaml`、`cron/jobs.json` 与 `skills/` 下的技能定义。

### 运行时依赖（依据仓库内实际内容推断）

| 依赖 | 依据 | 说明 |
|------|------|------|
| Hermes 运行时 | `config.yaml`（`agent.max_turns`、`toolsets`、`mcp_servers` 等）、`cron/jobs.json` | 本仓库是它的默认 agent 配置；`config.yaml` 中 `_config_version: 23` 表明配置由 Hermes 自行维护/迁移 |
| Bash | 3 个备份脚本与 1 个测试脚本的 shebang 均为 `#!/bin/bash` | 用于 `git-backup` 工作流与交互模式自测 |
| Git + 可访问的 Gitea | `git-backup/SKILL.md` 与脚本中的 `REMOTE_URL` | 远程仓库为 `https://git.uozi.com/annafby/hermes-default-agent.git` |
| 企业微信（WeCom）推送通道 | `cron/jobs.json` 中 5 个任务的 `"deliver": "wecom"`、`config.yaml` 的 `WECOM_HOME_CHANNEL` | 定时提醒与海报的投递目标 |
| Node.js（MCP 服务） | `config.yaml` 的 `mcp_servers.hermes-studio`（`command: /usr/bin/node`） | 用于 hermes-web-ui 的 MCP 集成 |
| 浏览器 / 截图能力 | `SOUL.md` 图片生成能力一节（`browser_navigate` + `browser_vision`） | 用于 HTML → PNG；`SOUL.md` 亦写明截图失败会自动降级为文字推送 |
| `python-docx` + `uv`（可选） | `references/course-report-handoff.md` | 仅在解析 docx 课程报告模板时需要（`uv pip install python-docx`） |

`config.yaml` 中的模型相关项（供参考，非安装步骤）：

- 默认模型：`model.default: claude-haiku-4-5-20251001`，`model.provider: custom:ai-api.uozi.org-claude2`（对应 `custom_providers` 中 `base_url: https://ai-api.uozi.org/v1`）。
- `auxiliary.vision` 单独配置了一个视觉模型（`base_url: https://ark.cn-beijing.volces.com/api/coding/v3`）。
- `toolsets: [hermes-cli]`；`agent.max_turns: 90`；`cron.wrap_response: true`；`approvals.mode: manual`、`approvals.cron_mode: deny`。

> **安全提示（重要）**：`config.yaml` 内联了 provider 的 `api_key`（`custom_providers` 与模型 provider 两处），`mcp_servers` 与 `custom_providers` 中还包含具体的服务地址、频道标识与本机绝对路径。本仓库已在 GitHub 上公开，**请尽快到对应平台作废并重新签发这些密钥**——已经公开过的凭据，改写历史或转为私有都无法撤回暴露。之后请把配置中的密钥字段改为占位符或环境变量注入，详见文末「注意事项：切勿提交凭据」。

### 如何获取

```bash
git clone https://github.com/bingyingfeng63-lgtm/hermes-default-agent.git
```

本仓库的公开主页是 GitHub 上的 [`bingyingfeng63-lgtm/hermes-default-agent`](https://github.com/bingyingfeng63-lgtm/hermes-default-agent)。原始上游是项目小组的 Gitea 仓库 `git.uozi.com/annafby/hermes-default-agent`（私有）。注意 `git-backup` 技能内部固定的 `REMOTE_URL` 仍指向该 Gitea 地址——那是该技能自身的备份目标，与「从哪里 clone 本仓库」是两件事（见下文「技能清单」）。

### 如何部署到 Hermes

**本仓库未包含部署脚本，需按 Hermes 运行时约定挂载。** 仓库内没有任何 install / deploy 脚本，没有 systemd 单元，没有 Dockerfile，也没有 `hermes skills install` 之类的安装命令说明，因此本文不给出（也不会编造）具体的部署步骤。

仓库中能作为部署线索的、真实存在的信息只有两条：

1. `git-backup/SKILL.md` 与脚本把运行目录固定为 `/home/anna/.hermes`，其中技能脚本的调用路径写作 `~/.hermes/skills/business/git-backup/scripts/git-update.sh`；`SOUL.md` 也规定产出文件只存放在 `~/.hermes/data/` 下。也就是说，**仓库根目录的内容对应运行时目录 `~/.hermes/`**。
2. `references/git-upload-audit.md` 明确把本仓库内容分为"业务核心"（需要上传：`SOUL.md`、`config.yaml`、`skills/business/signing-workflow-system/`、`profiles/code/skills/business/git-backup/`、`cron/jobs.json`、`data/ARCHIVE-INDEX.md`）与"框架运行时"（不上传：`node/`、`hermes-agent/`、`bin/`、`images/`、`cache/` 等）。

一个需要注意的路径差异：`git-backup` 技能位于 `profiles/code/skills/business/git-backup/`，而其 `SKILL.md` 中的一键脚本示例写作 `~/.hermes/skills/business/git-backup/scripts/...`。实际部署时请以你所使用的 Hermes 版本对 `profiles/` 的加载约定为准。

---

## 快速开始 / 使用示例

### 1. 触发一个签单流程（在对话中）

`SOUL.md` 规定了模糊输入的默认处理方式，可以直接照做：

| 你输入 | agent 的处理 |
|--------|--------------|
| 「跟进一下」 | 追问：哪个客户？从哪个阶段开始？ |
| 「看看进度」 | 默认展示当前阶段进度 |
| 「继续」 | 从上次中断处继续，先展示断点位置 |
| 「安排签单」 | 确认客户信息后，从签单前第一步开始 |

`signing-workflow-system/SKILL.md` 给出的示例工单：

```
客户杨洪伟，储蓄分红险，期付，保额USD 100,000
```

之后 agent 会按「签单前准备 → 签单中现场信息收集 → 签单后缴费与归档」推进，并在每个阶段给出 `1️⃣ / 2️⃣ / 3️⃣` 分步状态与「下一步」提示。

### 2. 业务流程中的关键硬性规则（照做即可）

- **先文字、后海报**：行程内容先生成文字版给顾问确认，收到明确确认后才写 `itinerary.md`、生成 HTML 并渲染 PNG（`references/presign-agent-details.md`，标注为 CRITICAL）。
- **重要提醒不得用模板默认值**：必须请顾问逐条确认（合规敏感）。
- **签单中逐项确认**：即使顾问说"无变更"，也必须逐项确认保额、缴费方案、附加保障、特殊条款、客户需求，每轮最多问 2 项（`references/insign-agent-details.md`）。
- **缴费数据逐项引导**：按顺序问 4 项 —— ① 首期保费金额 → ② 缴费方式（现金 / 转账 / 信用卡）→ ③ 缴费截止日期（默认签单当日）→ ④ 保单号（没有就留空）；每项以 `{值}，记下。` + 下一项提问回复；全部确认后一次性生成 `payment.md` + `payment.html` + `payment.png`（`SKILL.md` 与 `references/postsign-agent-details.md`）。
- **多客户姓名**：显示名保留顿号（如 `李女士、张小姐`），文件路径用连字符（如 `李女士-张小姐`）。

### 3. Git 备份：三个脚本的实际用法

三个脚本都使用 `bash <脚本路径>` 调用，**不接受任何命令行参数**，全部通过交互式提问获取输入；脚本内硬编码 `REPO_DIR="/home/anna/.hermes"`，因此必须在 `/home/anna/.hermes` 这个位置（或先调整脚本顶部的常量）才能正常执行。

#### `scripts/git-init.sh` —— 工作流 A：首次初始化上传

```bash
bash ~/.hermes/skills/business/git-backup/scripts/git-init.sh
```

脚本共 9 步：进入 `/home/anna/.hermes` → 检查/执行 `git init` → 移除旧 `origin` 并绑定远程地址 → 设置 `user.name` / `user.email` → `git config credential.helper store` → `git pull origin main --allow-unrelated-histories`（失败仅告警，继续）→ `git add .` 并打印 `git status --short` → 交互读取提交信息（回车则使用默认 `项目初始化完整代码上传 — <日期时间>`）→ `git push -u origin main`。
脚本开头有 `set -e`，任何一步失败即停止。

#### `scripts/git-update.sh` —— 工作流 B：日常迭代更新（最常用）

```bash
bash ~/.hermes/skills/business/git-backup/scripts/git-update.sh
```

脚本共 7 步：进入工作目录 → 校验 `origin` 是否等于预期远程地址（不匹配则重新绑定）→ 配置提交身份并设置凭证缓存 → `git pull origin main`（失败仅告警）→ 打印变更清单（按 `M` / `A` / `D` / `??` 分类显示"修改 / 新增 / 删除 / 未追踪"）→ 交互读取提交信息（回车则使用默认 `日常迭代更新 — <日期时间>`）→ **再问一次 `✅ 确认推送？[Y/n]`**，输入 `n` 或 `N` 则取消退出 → 执行 `git add .`、`git commit -m`、`git push origin main`。
若 `git status --short` 为空，脚本会提示"没有需要提交的变更"并以退出码 0 结束。

也可以用对话方式触发（`git-backup/SKILL.md` 方式二），对 agent 说：「帮我备份」/「上传到 git」/「git 更新」/「推送代码」，agent 会展示变更 → 询问改了什么 → 确认后执行 `add → commit → push`。

#### `scripts/git-tag.sh` —— 工作流 C：版本标签发布

```bash
bash ~/.hermes/skills/business/git-backup/scripts/git-tag.sh
```

脚本共 5 步：进入工作目录 → 列出已有标签（无标签则提示）→ 显示最近 5 次提交（`git log --oneline -5`）→ 交互读取版本号与版本说明 → 创建并推送注释标签（`git tag -a` + `git push origin <版本号>`）。
版本号校验规则：必须匹配 `^v[0-9]+\.[0-9]+\.[0-9]+$`（如 `v1.0.0`），**为空或格式错误都会直接报错退出**；版本说明为空时默认使用 `版本 <版本号>`。

对应手动等价操作（`SKILL.md` 工作流 C）：

```bash
cd /home/anna/.hermes
git tag -a v1.0.0 -m "第一个正式版本"
git push origin v1.0.0
```

#### 上传完整性审计（工作流 D）

`profiles/code/skills/business/git-backup/references/upload-audit-checklist.md` 定义了"工作流 D"：当用户问「还有什么没传」「全面检查」时执行。它提供了一整套命令（用 `find` 列出磁盘文件、用 `git ls-files` 列出已追踪文件再 `diff`、用 `git check-ignore -v` 检查排除规则、交叉引用 `SKILL.md` 中的路径引用），并记录了三个已确认的处理模式：把 `cache/` 中的关键模板复制到 skill 的 `templates/`、把测试案例从 `cache/outputs/` 复制到 `test-fixtures/`、清理指向不存在文件的过时引用。

### 4. 定时任务（T-1 / 签单日提醒）

`cron/jobs.json` 当前定义了 5 个任务：

| 任务 | cron 表达式 | 技能 | 投递 |
|------|-------------|------|------|
| 签单日志月度清理提醒 | `0 9 1 * *` | 无（仅 `terminal` toolset） | wecom |
| 签单提醒-杨洪伟-R2 | `0 9 23 6 *` | `presign-agent` | wecom |
| 签单提醒-杨洪伟-R3 | `0 9 24 6 *` | `presign-agent` | wecom |
| 签单提醒-李女士-张小姐-R2 | `0 9 23 6 *` | `presign-agent` | wecom |
| 签单提醒-李女士-张小姐-R3 | `0 9 24 6 *` | `presign-agent` | wecom |

任务提示词要求：读取 `~/.hermes/data/active/{客户}/presign/itinerary.md` 生成提醒，完成后把 `reminders.md` 中对应 R2 / R3 状态更新为 `✅ 已触发`。测试模式的操作方式见 `references/test-mode-procedures.md`：临时把 schedule 改为 `*/2 * * * *` → 立即运行一次 → 验证推送 → **立刻恢复原 schedule**。该文档使用的命令是 `cronjob list` / `cronjob update --job_id ... --schedule ...` / `cronjob run --job_id ...` / `cronjob enable --job_id ...`。

### 5. 技能自测脚本

```bash
bash skills/business/signing-workflow-system/scripts/test-optimized-interaction.sh
```

该脚本不接收参数，只向标准输出打印 4 个交互模板用例（签单前准备 / 签单中信息收集 / 签单后缴费归档 / 归档完成报告），外加状态图标系统、文件操作黑箱化、推送精简原则、用户需求验证 4 组检查，用于人工核对交互文案格式。

### 6. 测试样本（`test-fixtures/`）

`test-fixtures/` 是**测试专用**的样例集，用于在不接触真实客户目录的情况下验证海报渲染与缴费页面效果：

- `test-fixtures/html/` —— 5 个 HTML 样本（`GUO_JIAQI-integration.html`、`王永生-integration.html`、`陈太-integration.html`、`REMINDER测试-itinerary.html`、`测试客户-itinerary.html`）；
- `test-fixtures/png/` —— 与上述 HTML 一一对应的 5 张 PNG 渲染结果；
- `test-fixtures/test-payment-data.json` —— 缴费页面字段样例（客户姓名、单据日期、保单号、产品名称、应付总额、已缴金额、剩余金额、收款银行、银行地址、收款人、美元账户、港元账户、SWIFT 代码、注意事项等）。

---

## 目录结构说明

```
hermes-default-agent/
├── .gitignore
├── LICENSE
├── README.md
├── SOUL.md
├── config.yaml
├── cron/
│   └── jobs.json
├── data/
│   └── ARCHIVE-INDEX.md
├── profiles/
│   └── code/
│       └── skills/
│           └── business/
│               └── git-backup/
│                   ├── SKILL.md
│                   ├── references/
│                   │   ├── git-knowledge-base.md
│                   │   └── upload-audit-checklist.md
│                   └── scripts/
│                       ├── git-init.sh
│                       ├── git-tag.sh
│                       └── git-update.sh
└── skills/
    └── business/
        └── signing-workflow-system/
            ├── SKILL.md
            ├── references/          （16 个 .md）
            ├── scripts/
            │   └── test-optimized-interaction.sh
            ├── templates/
            │   ├── itinerary-poster-clean-template.html
            │   └── backgrounds/
            │       └── 王永生-itinerary.html
            └── test-fixtures/
                ├── test-payment-data.json
                ├── html/            （5 个 HTML）
                └── png/             （5 个 PNG）
```

### 逐项说明

| 路径 | 说明 |
|------|------|
| `SOUL.md` | **agent 人格与业务规则总纲**（269 行）。包含：身份设定（小 ice）、业务上下文与关键术语表、合规红线、沟通规则（进度同步格式、异常预警、追问上限、阶段切换、闭环收尾）、决策规则（模糊输入、信息缺失、异常分级 P0/P1/P2、阶段准入）、禁忌与红线、图片生成能力、客户索引系统（活跃 / 归档索引与更新时机）。 |
| `config.yaml` | **Hermes 运行时配置**（473 行，`_config_version: 23`）。关键项：`model`（默认模型与 provider）、`toolsets: [hermes-cli]`、`agent`（`max_turns`、`gateway_timeout`、`reasoning_effort` 等）、`terminal`、`browser`、`memory`、`delegation`、`cron`、`approvals`、`skills: [claw3d]`、`custom_providers`、`WECOM_HOME_CHANNEL`、`mcp_servers.hermes-studio`。 |
| `cron/` | **定时任务目录**，当前只有 `jobs.json`（220 行，5 个 job）。每项含 `id`、`name`、`prompt`、`skill`、`schedule.expr`、`enabled`、`state`、`next_run_at`、`last_run_at`、`last_status`、`deliver: wecom`、`origin.chat_id`、`enabled_toolsets` 等字段；文件末尾有 `updated_at`。 |
| `data/` | **业务数据根目录**。仓库内当前只追踪 `data/ARCHIVE-INDEX.md`（签单归档总目录，含"序号 / 归档日期 / 客户姓名 / 保单号 / 签单类型 / 顾问 / 归档文件"表格，目前 2 条记录）。`data/active/` 与 `data/archive/` 被 `.gitignore` 排除，**不在仓库中**——它们存放真实客户隐私数据（客户目录、`CLIENT-SUMMARY.md`、`CLIENT-INDEX.md`、行程 / 缴费产出、海报 PNG）。 |
| `profiles/` | **按 profile 分组的技能目录**。当前只有 `profiles/code/skills/business/git-backup/`（6 个文件），即 code profile 下的 Git 备份技能。 |
| `skills/` | **主技能目录**。当前只有 `skills/business/signing-workflow-system/`（22 个文件），即签单业务伞形技能。 |
| `LICENSE` | **MIT No Attribution**（MIT-0）。文件中的版权行为占位符 `Copyright <YEAR> <COPYRIGHT HOLDER>`，尚未填写实际的年份与著作权人。 |
| `.gitignore` | 排除四类内容：敏感文件（`.env`、`auth.json`、`auth.lock`）、**客户隐私数据（`data/active/`、`data/archive/`）**、个人运行时数据（`sessions/`、`memories/`、`logs/`、`cache/`、`checkpoints/`、`gateway.pid`、`gateway.lock`）、数据库与临时文件（`*.db`、`*.db-shm`、`*.db-wal`、`*.bak`、`*.log`、`__pycache__/`）。 |

---

## 技能清单

| 技能 | 位置 | 触发方式 | 职责 | 包含的文件类型 |
|------|------|----------|------|----------------|
| `git-backup` | `profiles/code/skills/business/git-backup/` | 手动 `bash` 调用脚本，或对话中说「帮我备份」「上传到 git」「git 更新」「推送代码」 | 把 default agent 的全部业务文件备份到 Gitea（`git.uozi.com/annafby/hermes-default-agent`）：首次初始化上传、日常迭代更新、版本标签发布，并提供 Git 知识库与上传完整性审计流程 | `SKILL.md`（1）+ `references/`（2：`git-knowledge-base.md`、`upload-audit-checklist.md`）+ `scripts/`（3：`git-init.sh`、`git-update.sh`、`git-tag.sh`） |
| `signing-workflow-system` | `skills/business/signing-workflow-system/` | 工单确认 / 签单前一天 / 签单日三类事件，或定时任务指定 `presign-agent` 技能 | 签单全流程事件驱动编排：主协调器（`signing-followup`）+ 三个子 agent（`presign-agent` / `insign-agent` / `postsign-agent`）+ 出图工具（`image-designer`）+ 对话模板（`conversation-flow-optimization`） | `SKILL.md`（1）+ `references/`（16）+ `scripts/`（1：`test-optimized-interaction.sh`）+ `templates/`（1 个 1080×1920 HTML、`backgrounds/` 1 个 HTML）+ `test-fixtures/`（5 HTML + 5 PNG + 1 JSON） |

### `signing-workflow-system/references/` 逐份说明

| 文件 | 内容 |
|------|------|
| `main-orchestrator-details.md` | 主协调器 `signing-followup`：三个触发点、状态管理、子 agent 委派、错误恢复、日志格式。 |
| `presign-agent-details.md` | `presign-agent`：工单解析、行程生成、客户目录创建（多客户姓名转连字符）、索引更新；含"先文字后海报"强制评审门、提醒文案不得用模板默认值、推送频率控制。 |
| `insign-agent-details.md` | `insign-agent`：签单结果解析、**签单中强制逐项确认清单**（保额 / 缴费方案 / 附加保障 / 特殊条款 / 客户需求）、差异摘要模板、状态更新。 |
| `postsign-agent-details.md` | `postsign-agent`：**缴费数据逐项引导**（4 项一问一答）、缴费页面与海报、归档流程与归档结构、推送与归档话术。 |
| `image-designer-details.md` | 出图工具：1080×1920 手机竖屏、华文行楷书法字体、Base64 内嵌资源、单张推送；含配置与模板示例。 |
| `conversation-templates-details.md` | 对话模板全集（PS / IS / POST / OPT 系列）：阶段汇报、引导、确认、错误处理。 |
| `optimized-interaction-patterns.md` | 交互优化指南：文件操作黑箱化、可视化输出优先、引导为主反馈为辅，附用户原始反馈记录。 |
| `push-control-lessons.md` | 推送控制经验：一次动作一次推送、不显示文件路径、`MEDIA:` 独占首行、WeCom 平台限制（无 `edit_message`、图片上限 10MB、文档上限 20MB）。 |
| `test-mode-procedures.md` | 测试模式：临时修改 cronjob → 立即运行 → 验证 → 立刻恢复；含 `cronjob list / update / run / enable` 命令示例。 |
| `test-mode-and-client-handling.md` | 测试协议 + 多客户姓名处理 + 主动引导。 |
| `client-handling-and-testing-lessons.md` | 2026-05-29 李女士、张小姐 VIP 多客户案例复盘：姓名清洗、简洁沟通、先检查后写入、单张推送。 |
| `itinerary-poster-background-lessons.md` | 行程海报背景板经验：优先维多利亚港统一风格、禁止用带旧资料的成品图当底图、顶部标题净空硬性要求；含"Python 提取背景图 `img` 标签必须匹配完整标签（含 `class`）否则海报空白"的陷阱记录。 |
| `itinerary-poster-visual-checklist.md` | 推送前视觉检查清单：标题净空、背景来源、旧资料残留、重复重贴、内容完整（四段齐全）、敏感信息（不展示完整电话）、进度条样式。 |
| `background-asset-confirmation.md` | 顾问上传 / 纠正背景板时的确认流程：先验图再生成、顾问说"发错了"立即改用最新图、优先 1080×1920 无水印空白背景、必须拦截旧成品图。 |
| `git-upload-audit.md` | 2026-08-04 图片生成资产完整性审计：业务 vs 框架文件分类清单、`image-designer` 已并入本技能、`SOUL.md` 旧路径已修正、审计命令与提交纪律（只 add 明确清单，不用 `git add .`）。 |
| `course-report-handoff.md` | 向"小 p"交接课程报告素材的流程：深圳技术大学《项目与劳动实践III》docx 模板结构、6 类知识导出格式（技术栈 / 系统目录树 / 客户案例 / 关键实现片段 / 部署环境 / 困难）、`uv pip install python-docx` + `$(uv python find)` 提取方法，以及追加式的实际会话语料记录。 |

---

## 常见问题 / 注意事项（FAQ）

**Q1：为什么仓库里看不到任何客户数据？**
这是设计使然。`.gitignore` 明确排除 `data/active/` 与 `data/archive/`（注释写着"客户隐私数据"），`upload-audit-checklist.md` 也把这两个目录标为"❌ 不追踪 — 客户隐私"。仓库中只保留 `data/ARCHIVE-INDEX.md` 这份归档总目录。真正的客户目录、`CLIENT-SUMMARY.md`、`CLIENT-INDEX.md`、行程与缴费产出、海报 PNG 都只存在于运行时的 `~/.hermes/data/` 下。

**Q2：`test-fixtures/` 里的客户姓名是真实客户吗？**
是**测试样本**，不是生产客户记录。目录名与文件名都体现测试性质：`测试客户-itinerary.html`、`REMINDER测试-itinerary.html`，以及集成测试样本 `GUO_JIAQI-integration.html` / `王永生-integration.html` / `陈太-integration.html`；配套 `test-payment-data.json` 也是一份字段齐全的缴费样例数据。它们的作用是让海报渲染、缴费页面排版在改动后可以被快速回归验证，`SKILL.md` 的 References 把 `test-fixtures/` 明确标注为"测试案例"。请注意这些样本中仍包含示例保单号、银行账户、SWIFT 代码等格式完整的字段，属于**脱敏前的格式示例**，演示或对外分享时仍需按敏感信息处理。

**Q3：三个备份脚本为什么必须放在 `/home/anna/.hermes`？**
因为脚本把 `REPO_DIR="/home/anna/.hermes"`、`REMOTE_URL`、`USER_NAME`、`USER_EMAIL`、`BRANCH` 写死在文件头部，运行时第一步就是 `cd "$REPO_DIR"`。在别的路径克隆后直接执行，脚本会去操作 `/home/anna/.hermes`（若该目录不存在则直接失败退出）。要在其他环境使用，需要先修改脚本顶部的这些常量。

**Q4：备份脚本需要什么网络与账号环境？**
需要能访问 Gitea `https://git.uozi.com`，并具备该仓库的推送权限。脚本通过 `git config credential.helper store` 做凭证缓存，且要求把令牌嵌入本地 git remote URL（`SKILL.md` 明确规定"令牌已嵌入本地 git remote URL，不写入文件"）。因此**首次推送仍需有效凭证**，令牌过期会报 401（`git-knowledge-base.md` 板块 ④ 给出了用 `git remote set-url origin https://annafby:新令牌@git.uozi.com/annafby/hermes-default-agent.git` 更新的处理方式）。另外 `git-init.sh` / `git-update.sh` 中的 `git pull` 失败只打印告警并继续，不会中断——远程不可达时脚本仍会继续走 `add → commit → push`，最终在 push 步骤失败。

**Q5：修改了配置或技能文档后，怎么让它生效？**
分两件事：
1. **备份**：改完 `SOUL.md`、`config.yaml`、skills 后跑 `git-update.sh`（或对 agent 说「帮我备份」）同步到远程。`config.yaml` 的 `curator.backup` 配置为 `enabled: true`、`keep: 5`，而 `updates.pre_update_backup: false`。
2. **Hermes 运行时读取**：本仓库不包含任何热重载 / 重载命令说明，也没有部署或重启脚本，因此**本文不给出重载步骤**——请按你所使用的 Hermes 版本对 `SOUL.md` / `config.yaml` / skills 的加载与生效约定操作。仓库内唯一有明确命令依据的是定时任务：`cron/jobs.json` 的改动对应 `references/test-mode-procedures.md` 中的 `cronjob list / update / run / enable` 命令族。

**Q6：定时提醒为什么投递到企业微信？**
`cron/jobs.json` 里 5 个任务全部是 `"deliver": "wecom"`，其中带 `origin` 的任务记录了具体的 `chat_id`；`config.yaml` 中另有 `WECOM_HOME_CHANNEL` 指定默认群。这意味着运行环境需要配置好 WeCom 通道，否则提醒无法送达。同时注意 WeCom 的平台限制（`push-control-lessons.md`）：不支持 `edit_message`（每条推送都是永久消息、无法修改）、图片上限 10MB、文档上限 20MB；`SKILL.md` 还硬性规定群聊消息中不得出现文件路径、文件大小、字节数和技术日志。

**Q7：cron 任务里的内容是某几个具体客户的提醒，会一直跑下去吗？**
这些任务把客户姓名与日期直接写死在 `name` / `prompt` / `schedule.expr` 中（如 `0 9 23 6 *`），且 `repeat.times` 为 `null`（不限次数）、`enabled: true`。例如"签单提醒-杨洪伟-R2"的 `next_run_at` 已排到下一年（`2027-06-23T09:00:00+08:00`），说明这类一次性业务提醒需要人工在完成后停用或删除，否则会在次年同一日期再次触发。另注意 `config.yaml` 设置了 `approvals.cron_mode: deny`。

**Q8：为什么 `config.yaml` 里的 `display.personality` 是 `kawaii`，而 `SOUL.md` 定义的是沉稳严谨的保险顾问？**
两者作用层级不同：`config.yaml` 的 `display.personality` 与 `agent.personalities` 是 Hermes 的通用显示人格预设（`helpful`、`concise`、`kawaii`、`catgirl`、`pirate` 等一堆内置项都原样保留在配置里），而 `SOUL.md` 才是本 agent 的实际身份与业务规则来源。此外 `config.yaml` 的 `display.language: en`、`logging.level: DEBUG`、`privacy.redact_pii: false` 等通用项是否需要按业务调整，建议结合实际运行确认。

**Q9：行程海报为什么反复强调"背景必须是空白模板"？**
因为这是踩过坑的。`itinerary-poster-background-lessons.md` 记录：曾把"带旧客户资料的成品海报"当底图，带来隐私与专业风险；因此规定背景图只要含旧客户名、旧日期、旧行程、旧二维码或完整电话就一律不得复用，改用干净模板复刻。另一类坑是技术性的——用正则从模板 HTML 提取背景 `<img>` 时必须匹配完整标签（含 `class="bg-image"`），否则 CSS 定位失效，会渲染出**空白海报**（`SKILL.md` 的 Issue 5 也复述了这一点）。同类硬性要求还有：主标题区必须保持净空（海报模板中标注"标题净空：0-330px 禁止放置卡片/标签"）、海报尺寸必须是 1080×1920 而不是 A4、群发海报默认不展示完整电话号码。

**Q10：出图到底用什么工具？**
以仓库现有内容为准：`SOUL.md` 写的是"通过 Hermes 内置 browser 工具截图输出 PNG"，截图工具为 `browser_navigate` + `browser_vision`，并注明**截图失败自动降级为文字推送**；`git-upload-audit.md` 也确认"实际出图方式：HTML 模板 + Hermes 内置 `browser_navigate` / `browser_vision` 截图，**无独立 Python 渲染脚本**"。仓库中另有两处提到其他渲染途径：`SKILL.md` 与 `itinerary-poster-background-lessons.md` 提到过 `wkhtmltoimage`，`image-designer-details.md` 中则有 `image-designer --input/--output/--width/--height/--format` 形式的命令行示例——后者是历史上独立技能 `image-designer` 的文档，该技能已并入本伞形技能，仓库中**不存在对应的可执行脚本**。实际使用时以 `SOUL.md` 的 browser 截图方案为准。

**Q11：`profiles/` 和 `skills/` 为什么分两处放技能？**
`profiles/code/` 是 code profile 的技能目录，`skills/` 是主技能目录，两者由不同的 Hermes 加载路径管理。`upload-audit-checklist.md` 在"审计自身的递归陷阱"里特别提醒：只检查 `skills/business/signing-workflow-system/` 会遗漏 `profiles/code/skills/business/git-backup/` 自身的未追踪文件。做上传审计时请把两个目录都纳入范围。

**Q12：这个仓库能直接跑起来吗？**
不能"开箱即用"。它是配置与技能定义，需要运行中的 Hermes 运行时、可用的模型 provider、WeCom 通道以及（备份用途的）Gitea 访问权限。仓库内没有部署脚本，具体挂载与启动方式请参照 Hermes 运行时的约定。

**Q13：仓库里有已知的不一致之处吗？**
有几处，使用时请以实际文件为准：
- `signing-workflow-system/SKILL.md` 的 References 与 `SOUL.md` 把 `templates/backgrounds/王永生-itinerary.html`（维多利亚港背景）称为**默认**行程海报模板，而把 `templates/itinerary-poster-clean-template.html`（CSS 渐变版）定位为"仅作应急备用，非用户明确要求不得使用"；仓库内两个模板文件实际都存在。
- `itinerary-poster-background-lessons.md` 中模板路径写作 `~/.hermes/cache/outputs/html/王永生-itinerary.html`，而仓库内实际位置是 `skills/business/signing-workflow-system/templates/backgrounds/`（`master` 审计记录显示该文件已从 `cache/` 复制到 `templates/backgrounds/`）。
- `git-backup/SKILL.md` 的脚本路径示例（`~/.hermes/skills/business/git-backup/scripts/`）与仓库内实际位置（`profiles/code/skills/business/git-backup/scripts/`）不一致。
- `SKILL.md` 中"测试用例"段给出的 `hermes run --skill ... --trigger ...` 命令、以及部分 reference 文档中的 `image-designer`、`./test-*-workflow.sh` 调用，属于历史文档内容，仓库中并不存在对应的可执行脚本。

---

## 注意事项：切勿提交凭据

本仓库是**公开仓库**，任何被提交的内容都会永久留在 Git 历史中并可被公开检索——即使事后删掉文件，旧提交里依然存在。本仓库的 `config.yaml` 正是这类问题的实例，因此特别提醒：

- **不要提交真实凭据**：API key、访问令牌、密码、私钥、`.env`、`auth.json`、数据库连接串等一律不要入库。
- **`config.yaml` 的密钥字段留空或写成占位符**（如 `YOUR_API_KEY_HERE`），改由环境变量或运行时的本地配置文件注入；`git-backup/SKILL.md` 也已约定令牌只嵌入本地 `git remote` URL、不写入任何文件。
- **不要提交客户数据**：`.gitignore` 已排除 `data/active/`、`data/archive/`、`sessions/`、`memories/`、`logs/`、`cache/`，请勿用 `git add -f` 绕过；`test-fixtures/` 中的保单号、银行账户、SWIFT 代码等虽为示例，对外分享时仍需按敏感信息处理。
- **提交前自查**：用 `git diff --cached` 逐项复核改动，并可用 `git grep -nE "(api[_-]?key|secret|token|password)"` 做一次粗筛。
- **一旦误提交**：立刻到对应平台**作废并重新签发**该凭据——改写历史无法撤回已经发生的公开暴露，之后再决定是否清理历史。

## 许可

本仓库以 **MIT No Attribution（MIT-0）** 授权，见 `LICENSE`。请注意该文件中的版权信息仍是占位符（`Copyright <YEAR> <COPYRIGHT HOLDER>`），正式分发前建议补全。
