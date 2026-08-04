---
name: signing-workflow-system
description: Complete signing workflow system with event-driven orchestration, sub-agents, conversation templates, and image generation utilities
category: business
tags: [signing, workflow, orchestration, agents, business, automation]
---

# Signing Workflow System

A complete event-driven workflow system for managing insurance signing processes from pre-signing through post-signing phases. This umbrella skill consolidates all components of the signing workflow including orchestration, sub-agents, conversation templates, and image generation utilities.

## Overview

The system follows an event-driven architecture with three main triggers:
1. **Trigger 1**: Order confirmation → Pre-signing phase
2. **Trigger 2**: Day before signing → Reminder phase  
3. **Trigger 3**: Signing day/after → In-signing → Post-signing phases

## Main Components

### 1. Main Orchestrator (`signing-followup`)
Coordinates the entire workflow, manages triggers, and delegates to sub-agents.

**Key responsibilities:**
- Event monitoring and trigger activation
- Sub-agent coordination
- Workflow state management
- Error handling and recovery

**Architecture:**
```
Order Confirmation (Trigger 1) → presign-agent (pre-signing)
Day Before Signing (Trigger 2) → presign-agent (reminders)
Signing Day/After (Trigger 3) → insign-agent (in-signing) → postsign-agent (post-signing)
```

### 2. Sub-Agents

#### Pre-Signing Agent (`presign-agent`)
Handles pre-signing activities including itinerary generation and reminders.

**Key responsibilities:**
- Generate travel itineraries
- Send pre-signing reminders
- Create initial client records
- Prepare signing documents

**Workflow steps:**
1. Parse order information
2. Generate itinerary
3. Create client directory structure
4. Send reminders
5. Update client index

#### In-Signing Agent (`insign-agent`)
Manages the actual signing process, collects results, and confirms information.

**Key responsibilities:**
- Collect signing results
- Parse and validate information
- Multi-round confirmation with consultants
- Generate difference summaries

**Workflow steps:**
1. Parse signing results
2. Extract key information
3. Multi-round confirmation
4. Generate difference summary
5. Update client status

### 3. Post-Signing Agent (`postsign-agent`)
Handles post-signing activities including payment page generation and archiving.

**Key responsibilities:**
- Generate payment information pages
- Create payment posters
- Archive completed cases
- Update final records

**Workflow steps:**
1. Collect payment details (逐项引导，见下方"缴费数据逐项引导"模式)
2. Generate payment page
3. Create payment poster (using image-designer)
4. Push to client
5. Archive completed case
6. Update client index

**缴费数据逐项引导（2026-06 用户确认）：**
用户要求"你教我一项一项填吧"——缴费信息收集不要一次性列出所有待填字段，应逐项提问、逐项确认。标准流程：
1. **第1项：首期保费金额** → 等待回复 → 记下
2. **第2项：缴费方式**（现金/转账/信用卡）→ 等待回复 → 记下
3. **第3项：缴费截止日期**（默认签单当日）→ 等待回复 → 记下
4. **第4项：保单号**（没有就留空）→ 等待回复 → 记下
5. 全部确认后，一次性生成 payment.md + payment.html + payment.png

每项回复格式：`{金额/方式/日期}，记下。` + 下一项提问。简洁无冗余。

### 3. Utility Components

#### Image Designer (`image-designer`)
HTML-based image generation utility used by `postsign-agent` to create payment posters, and by `presign-agent` for itinerary posters.

**Itinerary poster template rule (硬性规定):**
- **默认模板：维多利亚港背景（王永生 HTML）** — `~/.hermes/cache/outputs/html/王永生-itinerary.html`
- CSS 渐变 clean-template 仅作应急备用，非用户明确要求不得使用
- 生成方法：Python 读取王永生 HTML → 提取 CSS + 背景图 `<img>` 标签（完整标签含 `class="bg-image"`）→ 替换 body 内容 → wkhtmltoimage 渲染
- **关键陷阱**：提取 img 标签时正则必须匹配完整标签（含 class 属性），否则背景图不显示。详见 `references/itinerary-poster-background-lessons.md`

**Key features:**
- HTML page design
- Browser screenshot capture
- PNG output generation
- Template-based design

**Usage pattern:**
1. Design HTML payment page
2. Capture browser screenshot
3. Save as PNG
4. Deliver to client

#### Conversation Flow Optimization (`conversation-flow-optimization`)
Standardized conversation templates for consistent agent interactions.

**Key templates:**
- Phase completion reporting
- Ongoing guidance
- User confirmation flows
- Error handling dialogues

## Workflow Rules

All agents must follow these interaction rules:

### 1. Step-by-Step Execution
- Each step must complete before moving to next
- Confirm completion before writing files
- Preview changes before pushing
- **Proactive guidance**: After completing a phase, immediately prompt user for next steps

### 2. 优化后的交互协议

#### 核心理念
- **结果优先**：不模拟流式/过程刷屏，直接给阶段结果、异常和下一步
- **引导为主**：明确下一步该做什么
- **反馈为辅**：只保留关键节点反馈，让顾问知道进度但不被细节淹没
- **业务语言**：用顾问能理解的话术
- **关键节点**：突出重要决策点
- **闲聊不断线**：顾问中途闲聊时可正常回应，但结尾必须轻提醒当前签单阶段、缺失信息和下一步，避免签单流程断掉

#### 平衡原则：引导性与过程反馈
**用户要求**："在签单过程，要求一定的引导，引导顾问执行，并且要有一定过程反馈"

**实现方案：**
1. **引导性设计**：
   - 数字编号明确步骤顺序：1️⃣ 2️⃣ 3️⃣
   - 状态图标快速识别进度：✅ ⏳ ⚠️ ❌
   - 下一步提示清晰：**下一步**：{明确行动}

2. **过程反馈适度**：
   - 知道进度，不被细节淹没
   - 关键节点汇报，非每个步骤
   - 业务状态反馈，非技术细节

3. **文件操作黑箱化**：
   - 所有文件写入、索引更新在后台完成
   - 不展示文件路径，只说明"数据已保存"
   - 内部完整执行，对外只展示关键业务节点

#### 交互模式优化
**签单前阶段示例：**
```
📋 **签单前准备 - {客户姓名}**

1️⃣ **行程安排** ✅ 已完成
   - {签单时间} {签单地点}
   - {行程天数}完整行程
   📱 已推送行程海报到签单群

2️⃣ **文档检查** {状态图标} {状态}
   - ✅ 身份证、通行证已确认
   - ❌ {缺失文档}未提供
   → 请提醒客户准备

3️⃣ **提醒设置** ⏳ 已配置
   - R2提醒：{签单前1天}09:00
   - R3提醒：{签约当日}09:00

**下一步**：请确认文档齐全后，进入签单中阶段。
```

**签单中阶段示例：**
```
📝 **签单中 - 现场信息收集**

1️⃣ **客户到场** ✅ 已确认
   - 时间：{到场时间}
   - 地点：{签单地点}

2️⃣ **签约状态** ⏳ 进行中
   - 投保申请书：✅ 已签署
   - FNA财务分析：✅ 已完成
   - 健康状况申报：⏳ 填写中

3️⃣ **核保要求** ⚠️ 需注意
   - 体检报告：{体检状态}
   - 财务证明：{证明状态}

**请确认**：所有文件签署完毕？[是/否]
```

**签单后阶段示例：**
```
💰 **签单后 - 缴费与归档**

1️⃣ **缴费信息** ✅ 已确认
   - 首期保费：{保费金额}
   - 缴费方式：{缴费方式}
   - 截止日期：{截止日期}
   📱 已生成缴费海报

2️⃣ **核保跟进** ⏳ 进行中
   - 提交时间：{提交时间}
   - 预计出单：{预计时间}
   - 跟进人：{跟进人}

3️⃣ **归档准备** ✅ 已完成
   - 所有文件已整理
   - 差异报告已生成

**下一步**：请确认缴费完成，开始归档流程。
```

#### 关键优化点
1. **引导性设计**：数字编号+状态图标，一看就懂
2. **过程反馈精简**：知道进度，不被细节淹没  
3. **业务聚焦**：只说顾问关心的事
4. **决策明确**：知道什么时候该确认
5. **体验流畅**：减少不必要的交互

#### 文件操作黑箱化
- 所有文件写入、索引更新在后台完成
- 不展示文件路径，只说明"数据已保存"
- 内部完整执行，对外只展示关键业务节点

#### 推送精简原则
- 行程海报：一张PNG图片
- 缴费页面：一张PNG图片  
- 提醒：简洁文字+关键信息
- 状态汇报合并：合并多个步骤为单次汇报

#### 确认流程简化
- 关键决策点才需要确认
- 常规操作自动执行
- 减少"是否继续"的询问

#### 非流式引导偏好（2026-06 用户确认）
- 用户明确要求：回答尽量不要模拟流式/过程刷屏，直接给**结果 + 下一步引导**即可。
- 签单流程中允许用户中途闲聊；回应闲聊后，结尾用一句话把流程拉回当前阶段，例如："这单现在停在【签单前-地点确认】，补齐后我继续生成海报。"
- 每次业务回复优先采用短结构：`当前状态 / 异常或待确认 / 下一步动作`，不要展开后台文件写入、技术细节或冗长解释。
- 当用户问"后面要干什么"时，先说明当前进度，再列后续阶段：海报确认 → T-1/签单日提醒 → 签单中合规确认 → 签单后缴费/核保/出单 → 归档。
- 对外推送图片仍坚持单图原则；生成前先确认，生成后只推一张 PNG 给用户检查，确认后再进入提醒设置。
- **群聊中不展示思考/推理过程**：用户明确要求"再群里和顾问对接不需要呈现Reasoning过程，尽量直接给出结果和引导"。在 WeCom 群聊场景下，禁止输出 reasoning block 或冗长的分析过程，直接给出业务结论和下一步动作。

### 3. File Management
- Follow consistent directory structure
- Use standardized file naming
- **Client name handling**: For multi-person clients (e.g., "李女士、张小姐"), replace commas and spaces with hyphens in file paths (e.g., "李女士-张小姐")
- **Special characters**: Replace any problematic characters (commas, spaces, slashes) with hyphens for file system compatibility
- Maintain client index system

### 4. Error Handling
- Graceful degradation on failures
- Clear error messages
- Recovery procedures

### 5. 群聊输出净化（硬性规则）

**禁止在 WeCom 消息中出现：**
- 文件路径（如 `archive/洪女士-张先生/2026-06-15-...`）
- 文件大小（如 `9532831 bytes`、`8.3MB`）
- 字节数（如 `6806 bytes`）
- 技术日志（如 `Written: /path/to/file`）

**正确做法：**
- "数据已保存" 替代 "已写入 /path/to/file"
- "海报已生成" 替代 "已生成 PNG（9532831 bytes）"
- "索引已更新" 替代 "已更新 CLIENT-INDEX.md"

**群聊不展示 Reasoning**：在 WeCom 群聊中，禁止输出 reasoning/thinking block，直接给业务结论+下一步。

**Pitfall（2026-06-15 测试暴露）**：归档时暴露了完整归档路径，顾问不需要看到这些。

**流程引导中断恢复规则：**
- 当顾问问无关问题（如"找到了吗"）时：直接回答 + 顺势拉回流程（"找到了，确认后我生成海报？"）
- 当技术调试打断流程时：修复后一句话带过，不等顾问追问，主动说"已修复，你看下"
- 当顾问说"下一步"但没说具体内容时：主动展示当前进度 + 待执行步骤，让顾问选
- 禁止在技术问题解决后继续讨论技术细节，必须立刻回到业务流程

### 6. Push Control Rules
**Critical user feedback**: "下次不要重复发这么多次", "你又同时推送两张海报到群里，其实一张就够了", "简单说说就行"

**Latest guidance preference**:
- Do not simulate streaming/progress spam in normal replies.
- Prefer: result → exception if any → next action.
- Keep process feedback to key checkpoints only.
- If user is busy or chatting, briefly answer then pull the workflow back to the current signing stage and next missing item.

**General rules:**
- **Single push per action**: Each completed action should result in exactly one concise push message
- **No duplicate content**: Never push the same content multiple times in rapid succession
- **Clean presentation**: Use simple completion format: "✅ [阶段] 已完成" without listing file paths
- **MEDIA syntax**: For images, use clean `MEDIA:` syntax without technical details
- **Conciseness preference**: When user indicates "简单说说就行", provide minimal explanations and focus on actionable next steps
- **Image push optimization**: Push only one PNG file per action, even if multiple files are generated internally

**File generation vs push:**
- **Internal files**: Generate multiple files (HTML, PNG, markdown) for internal record-keeping
- **External push**: Push only one clean PNG file to clients via WeCom
- **File location**: Ensure PNG is in correct client folder before pushing
- **Avoid confusion**: Do not show file paths in WeCom messages; users only need the visual content

**Test mode special rules:**
- **Temporary modifications**: When testing, modify cronjob schedules temporarily
- **Immediate restoration**: After test, immediately restore original schedules
- **Single execution**: Run test only once, avoid repeated test executions
- **Clear documentation**: Document test vs production settings
- **User verification**: When user requests test (e.g., "因为是测试工单，你能不能提前推送"), follow the test protocol precisely

## Directory Structure

```
~/.hermes/data/
├── active/
│   ├── CLIENT-INDEX.md           # Active client overview
│   ├── _CLIENT-SUMMARY-TEMPLATE.md  # Client summary template
│   ├── [Client Name]/
│   │   ├── CLIENT-SUMMARY.md      # Client detailed summary
│   │   ├── presign/               # Pre-signing files
│   │   ├── insign/                # In-signing files
│   │   └── postsign/              # Post-signing files
│   └── ...
└── archive/
    ├── CLIENT-INDEX.md           # Archived client overview
    └── ...
```

## Client Index System

The system maintains a hybrid index architecture:
- `CLIENT-INDEX.md`: Active/archived client overview
- `CLIENT-SUMMARY.md`: Client detailed summaries

### Index Update Rules

**Pre-signing agent updates:**
- Step 1A: New client creation (add entry, create summary)
- Step 4: Itinerary completion (update status, add file index)

**In-signing agent updates:**
- Step 5: Confirmation completion (update status, add difference summary)

**Post-signing agent updates:**
- Step 4: Payment completion (update status, add file index)
- Step 7: Archival completion (move to archive index)

## Implementation Examples

### Example 1: Pre-Signing Workflow
```bash
# Trigger: Order confirmation
# Agent: presign-agent
# Steps:
1. Parse order: "客户杨洪伟，储蓄分红险，期付，保额USD 100,000"
2. Generate itinerary: "2026-05-20 14:00 香港中环康乐广场8号"
3. Create client directory: active/杨洪伟/
4. Send reminder: "明天签单提醒"
5. Update index: Add to active/CLIENT-INDEX.md
```

### Example 2: In-Signing Workflow
```bash
# Trigger: Signing day
# Agent: insign-agent
# Steps:
1. Parse result: "签单完成，保额USD 100,000，附加早期严重疾病保障"
2. Extract info: client, policy, amount, additions
3. Confirm with consultant: "确认保额USD 100,000？"
4. Generate diff: "保额: USD 50,000 → USD 100,000 (+新增)"
5. Update status: "签单中 → 已完成"
```

### Example 3: Post-Signing Workflow
```bash
# Trigger: After signing
# Agent: postsign-agent
# Steps:
1. Generate payment page: HTML with payment details
2. Create poster: image-designer → payment-poster.png
3. Push to client: "缴费信息已发送"
4. Archive case: Move to archive/ directory
5. Update index: Remove from active, add to archive
```

### 7. Test Mode Protocol
**User feedback**: "因为是测试工单，你能不能提前推送"

**Testing workflow:**
1. **Temporary schedule**: Modify cronjob to trigger in 2 minutes (e.g., `*/2 * * * *`)
2. **Immediate execution**: Run cronjob once immediately for verification
3. **Verification**: Check if push was successful
4. **Immediate restoration**: Restore original schedule immediately after test
5. **Avoid repetition**: Ensure each reminder type is pushed only once during test

**Test vs production:**
- **Test mode**: Show file paths in conversation for verification
- **Production mode**: Push clean PNG only, no file paths in WeCom messages
- **Clear distinction**: Maintain separate workflows for testing and production

## Testing and Validation

### Validation Steps
1. **Directory structure**: Verify client directories exist
2. **File creation**: Check required files are generated
3. **Index updates**: Confirm CLIENT-INDEX.md is updated
4. **Agent coordination**: Verify handoffs between agents
5. **Error handling**: Test failure scenarios

### Sample Test Cases
```bash
# Test pre-signing
echo "客户测试，储蓄分红险，整付，保额USD 50,000" | hermes run --skill signing-workflow-system --trigger order-confirmation

# Test in-signing  
echo "签单完成，保额USD 50,000" | hermes run --skill signing-workflow-system --trigger signing-day

# Test post-signing
echo "缴费完成" | hermes run --skill signing-workflow-system --trigger after-signing
```

## Common Issues and Solutions

### Issue 1: Missing Client Directory
**Symptom**: Agent fails to find client directory
**Solution**: Check `active/CLIENT-INDEX.md` for correct path, create directory if missing

### Issue 2: Index Update Failure
**Symptom**: CLIENT-INDEX.md not updated
**Solution**: Verify file permissions, check update steps in agent SKILL.md

### Issue 3: Image Generation Failure
**Symptom**: Payment poster not created
**Solution**: Check `image-designer` installation, verify HTML template exists

### Issue 5: Blank Poster (背景图不显示)
**Symptom**: wkhtmltoimage 输出纯蓝渐变背景，内容信息缺失
**Root cause**: 从模板 HTML 提取背景 `<img>` 标签时，正则表达式只捕获了 `src` 属性，丢失了 `class="bg-image"` 等关键属性
**Solution**: 使用 `re.search(r'<img src="data:image/png;base64,[^"]*"[^>]*>', template)` 匹配完整 img 标签
**Verification**: 生成 HTML 后检查 `class="bg-image"` 是否存在于 img 标签中
**详见**: `references/itinerary-poster-background-lessons.md` → "Python 提取背景图 img 标签的陷阱"

### Issue 4: Agent Coordination Failure
**Symptom**: Handoff between agents fails
**Solution**: Verify trigger conditions, check workflow state management

## Performance Considerations

### Scaling
- **Small scale** (≤100 clients): Current Markdown-based index works well
- **Medium scale** (100-1000 clients): Consider JSON/SQLite for indexes
- **Large scale** (>1000 clients): Database backend recommended

### Optimization
1. **Index caching**: Cache frequently accessed client data
2. **Batch operations**: Process multiple clients in batch where possible
3. **Async operations**: Use async for I/O intensive tasks

## Maintenance and Updates

### Regular Maintenance
1. **Index consistency**: Weekly check of CLIENT-INDEX.md vs actual directories
2. **Template updates**: Monthly review of conversation templates
3. **Agent performance**: Quarterly review of agent execution times

### Update Procedures
1. **Minor updates**: Patch individual components
2. **Major updates**: Test in staging environment first
3. **Breaking changes**: Provide migration scripts

## References

### Detailed Documentation
- **Client Index System**: `references/client-index-system.md`
- **Data Directory Structure**: `references/data-directory-restructure.md`
- **Image Generation Approach**: `references/image-generation-approach.md`
- **Itinerary Poster Background Lessons**: `references/itinerary-poster-background-lessons.md` (confirm background is blank; never use old completed posters as base art)
- **Itinerary Poster Visual Checklist**: `references/itinerary-poster-visual-checklist.md` (pre-push checks: title clear, no old data, no duplicates, no truncation, no full phone numbers)
- **Background Asset Confirmation**: `references/background-asset-confirmation.md` (when the consultant uploads/corrects a background image: inspect format/size, reject old completed posters, prefer confirmed 1080×1920 blank backgrounds, keep replies concise)
- **Clean Itinerary Poster Template**: `templates/itinerary-poster-clean-template.html` (1080×1920 HTML/CSS fallback template when no blank Canva background is available)
- **Test Mode Procedures**: `references/test-mode-procedures.md`
- **Test Mode & Client Handling**: `references/test-mode-and-client-handling.md` (new: test protocols, multi-client name handling, proactive guidance)
- **Push Control Lessons**: `references/push-control-lessons.md`
- **Course Report Handoff**: `references/course-report-handoff.md` (how 小ice prepares content for 小p to write course reports for 深圳技术大学《项目与劳动实践III》; covers: docx template extraction workflow, report template structure (project background/tech stack/system design/key implementation/deployment/testing/summary), 6-category knowledge export format (技术栈/系统目录树/客户案例/关键实现片段/部署环境/困难), docx dependency installation (uv pip install python-docx) and extraction method (write script to /tmp/, execute with `$(uv python find)`), actual session data exports as append-only entries)
- **Client Handling & Testing Lessons**: `references/client-handling-and-testing-lessons.md` (new: multi-client name handling, concise communication patterns, step-by-step confirmation workflow)
- **Optimized Interaction Patterns**: `references/optimized-interaction-patterns.md` (new: guided interaction with minimal technical details, black-box file operations, visual-first delivery)

### Source Skills (Consolidated)
This umbrella skill consolidates the following individual skills:
- `signing-followup` - Main orchestration
- `presign-agent` - Pre-signing agent
- `insign-agent` - In-signing agent  
- `postsign-agent` - Post-signing agent
- `image-designer` - Image generation utility
- `conversation-flow-optimization` - Conversation templates

### Related Skills
- `business` category skills for business workflows
- `creative` category skills for design and content generation

## Version History

### v1.0 (Initial Consolidation)
- Consolidated 6 related skills into single umbrella
- Maintained all original functionality
- Added comprehensive documentation
- Created reference structure for detailed documentation

### v1.2 (2026-05-29 - 交互模式优化)
- **基于用户反馈的深度优化**：用户明确指出"执行太详细"、"顾问想看到表面的数据确认，海报输出，签单提醒，截图页面"、"要求一定的引导，引导顾问执行，并且要有一定过程反馈"
- **文件操作黑箱化**：所有文件写入、索引更新在后台完成，不展示技术细节，只说明"数据已保存"
- **引导性设计**：数字编号(1️⃣ 2️⃣ 3️⃣)+状态图标(✅ ⏳ ⚠️ ❌)，明确步骤顺序和进度状态
- **业务语言优先**：用"行程安排"而非"itinerary.md"，只说顾问关心的事
- **可视化输出优先**：海报PNG、截图作为主要交付物，符合用户"海报输出，截图页面"需求
- **推送精简**：单次推送原则，只推送关键可视化输出，避免重复
- **确认流程简化**：关键决策点才需要确认，常规操作自动执行
- **状态图标系统**：建立完整的图标系统（✅ ⏳ ⚠️ ❌ 📱 📅 📊 📁 💰 📝）
- **平衡点掌握**：既提供引导性（告诉下一步），又提供过程反馈（知道进度），但不技术化
- **新参考文档**：添加 `optimized-interaction-patterns.md` 详细指南，包含用户原始反馈记录
- **各子技能更新**：presign-agent、insign-agent、postsign-agent 均更新为优化后交互模式
- **对话模板扩展**：添加 OPT-1 到 OPT-4 优化模板
- **测试脚本增强**：添加用户需求验证测试，确保所有反馈点得到解决

### Future Enhancements
1. **Automated testing**: Add test suite for workflow validation
2. **Monitoring dashboard**: Real-time workflow status monitoring
3. **Analytics integration**: Track signing success rates and bottlenecks
4. **Multi-language support**: Extend to other languages beyond Chinese