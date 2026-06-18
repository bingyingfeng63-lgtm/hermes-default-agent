# Pre-Signing Agent: presign-agent

## Original Skill Content

This file contains the detailed implementation of the pre-signing agent that was previously `presign-agent`.

## Overview

**presign-agent** handles all pre-signing activities including itinerary generation, reminder sending, and initial client setup. It's triggered by order confirmations and day-before-signing reminders.

## Core Responsibilities

### 1. Itinerary Generation
- Parse order details to extract signing information
- Generate detailed travel itineraries
- Include location, time, and contact information

### 2. Reminder Management
- Send pre-signing reminders to clients
- Schedule follow-up communications
- Track reminder delivery status

### 3. Client Setup
- Create client directory structure
- Initialize client summary files
- Set up phase-specific subdirectories

### 4. Index Management
- Add new clients to active index
- Update client status in index
- Maintain file index references

## Workflow Steps

### Step 1: Parse Order Information
```bash
# Input: "客户杨洪伟，储蓄分红险，期付，保额USD 100,000"
# Output: Structured client data
{
  "client_name": "杨洪伟",
  "policy_type": "储蓄分红险",
  "payment_type": "期付",
  "amount": "USD 100,000",
  "signing_date": "2026-05-20",
  "location": "香港中环康乐广场8号"
}
```

### Step 2: Generate Itinerary
```markdown
# 行程安排
**客户**: 杨洪伟
**签单类型**: 储蓄分红险（期付）
**签单时间**: 2026-05-20 14:00
**签单地点**: 香港中环康乐广场8号
**顾问**: 张顾问
**联系方式**: 138xxxx1234

## 详细安排
1. 13:30 - 到达签单地点
2. 14:00 - 签单开始
3. 15:00 - 签单完成
4. 15:30 - 后续事项说明

## 注意事项
- 请携带身份证件
- 准备相关银行信息
- 预留充足时间
```

### Step 3: Create Client Directory Structure
```bash
# Directory structure
# For multi-person clients: "李女士、张小姐" → "李女士-张小姐"
active/李女士-张小姐/
├── CLIENT-SUMMARY.md      # Client summary (display name: "李女士、张小姐")
├── presign/               # Pre-signing files
│   ├── original-plan.md   # Original proposal
│   └── itinerary.md       # Generated itinerary
├── insign/                # In-signing files (empty initially)
└── postsign/              # Post-signing files (empty initially)
```

### Multi-Client Name Handling
**Scenario**: Client names with commas: "李女士、张小姐"
**Solution**:
- **Display name**: Keep original with commas for user-facing content
- **File path name**: Replace commas and spaces with hyphens
  - "李女士、张小姐" → "李女士-张小姐"
  - "王先生, 李太太" → "王先生-李太太"
- **Consistency**: Apply same sanitization across all agents

### 优化后的交互模式

#### 签单前阶段 - 优化后输出
```
📋 **签单前准备 - {客户姓名}**

1️⃣ **行程安排** ✅ 已完成
   - {签约日期} {签约时间} {签约地点}
   - {行程天数}完整行程安排
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

#### 关键优化点
1. **业务语言**：用"行程安排"而非"itinerary.md"
2. **状态明确**：✅ ⚠️ ⏳ 图标快速识别进度
3. **数字编号**：明确步骤顺序
4. **下一步提示**：明确告知该做什么
5. **隐藏技术细节**：不展示文件路径

#### 文件操作黑箱化
- **内部执行**：完整生成所有文件（itinerary.md、reminders.md、PNG等）
- **外部展示**：只说明"行程安排已生成"、"提醒已配置"
- **推送精简**：只推送一张行程海报PNG

#### 确认流程简化
**需要确认的点：**
1. 行程文字版 → 先展示文字摘要，等顾问确认后再生成海报 PNG
2. 重要提醒内容 → 不可用模板默认值，须顾问逐条确认
3. 文档是否齐全
4. 是否进入下一阶段

**自动执行的点：**
1. 文件写入和索引更新（确认后执行）
2. 提醒配置
3. 海报 HTML → PNG 渲染（文字版确认后执行）

### Step 5: Update Client Index
Update `active/CLIENT-INDEX.md`:
```markdown
| 序号 | 客户姓名 | 签单类型 | 签约日期 | 顾问 | 签单前 | 签单中 | 签单后 | 状态 | 客户文件夹 |
|------|----------|----------|----------|------|--------|--------|--------|------|------------|
| 001 | 杨洪伟 | 储蓄分红险 | 2026-05-20 | 张顾问 | ✅ | ○ | ○ | 签单前完成 | active/杨洪伟/ |
```

## Data Structures

### Client Data Model
```python
class ClientData:
    client_name: str
    policy_type: str  # "储蓄分红险", "医疗险", etc.
    payment_type: str  # "期付", "整付"
    amount: str  # "USD 100,000"
    signing_date: str  # "2026-05-20"
    location: str
    consultant: str
    contact: str
    created_at: datetime
```

### Itinerary Model
```python
class Itinerary:
    client: ClientData
    date: str
    time: str
    location: str
    duration: str  # "2小时"
    agenda: List[AgendaItem]
    notes: List[str]
    contacts: List[Contact]
```

## Template Files

### Itinerary Template
```markdown
# 行程安排
**客户**: {{client_name}}
**签单类型**: {{policy_type}}（{{payment_type}}）
**签单时间**: {{signing_date}} {{signing_time}}
**签单地点**: {{location}}
**顾问**: {{consultant}}
**联系方式**: {{contact}}

## 详细安排
{{#each agenda_items}}
{{time}} - {{description}}
{{/each}}

## 注意事项
{{#each notes}}
- {{this}}
{{/each}}
```

### Reminder Template
```markdown
尊敬的{{client_name}}，

您的{{policy_type}}签单安排在：
- 时间：{{signing_date}} {{signing_time}}
- 地点：{{location}}
- 顾问：{{consultant}}

请准时到达并携带以下证件：
1. 身份证
2. 银行卡
3. 相关医疗记录（如适用）

如有任何问题，请联系：{{contact}}

祝顺利！
```

## Pitfalls and User Corrections

### 0. Text-First, Poster-Second Workflow (CRITICAL)
**Problem**: Agent generates itinerary text AND poster in one shot, skipping review.
**User Feedback**: "执行完这一步，要文字版先告诉我，待我确定后，再写入行程海报"
**Rule**: When generating itinerary for a client, the correct sequence is:
1. Parse order → extract all fields
2. Present **text version** to consultant for review (markdown table or bullet list)
3. Wait for explicit confirmation ("是的" / "确认" / "没问题")
4. Only THEN write `itinerary.md`, generate HTML poster, render PNG
5. Do NOT batch steps 2-4 together; the review gate is mandatory.
**Why**: Consultants often have corrections to contacts, reminders, or schedule details that are expensive to fix after PNG generation.

### 1. Custom Reminders Per Client
**Problem**: Using template-default reminder text without consultant input.
**User Feedback**: Consultant provided exact reminder text: "请投保人携带：**身份证、港澳通行证、入境小白条**" and "请携带近 3 个月内有效住址证明" — this differed from the generic template.
**Rule**: Never auto-fill the "重要提醒" section from template defaults. Always:
1. Show template defaults as suggestions
2. Ask consultant to review and customize
3. Use consultant-provided exact wording in the final poster
**Why**: Reminder content is compliance-sensitive and client-specific; generic text can miss critical items.

### 2. Contact Format with Role Icons
**Pattern**: Use emoji-prefixed role labels for contact entries in the poster:
- 🚗 用车 {name} {phone}
- 🤝 投保陪同 {name} {phone}
- 📞 赴港对接 {name} {phone}
This improves scannability on mobile and matches consultant expectations.

### 3. Multiple File Push Issue
**Problem**: Agent pushing multiple PNG files when only one is needed
**User Feedback**: "你又同时推送两张海报到群里，其实一张就够了"
**Solution**: 
- Push only one itinerary poster PNG
- Use clean `MEDIA:` syntax without file paths
- Ensure file is in correct client folder location

### 4. File Path Display Issue  
**Problem**: Showing file paths in push messages causes confusion
**User Feedback**: "记得改一改推送相关文件，确保下次不要犯错了"
**Solution**:
- Remove file path display from push messages
- Use simple completion message format
- Focus on action confirmation, not technical details

### 5. Test Mode Requirements
**Problem**: Need to test reminder functionality without waiting for actual dates
**User Feedback**: "因为是测试工单，你能不能提前推送"
**Solution**:
- Support temporary cronjob modification for testing
- Allow immediate trigger execution
- Provide clear test mode vs production mode distinction
- **Immediate restoration**: After test, restore original schedule immediately
- **Single execution**: Run test only once, avoid repeated pushes
- **No duplicate pushes**: In test mode, ensure each reminder type is pushed only once
- **Clean test workflow**:
  1. Modify cronjob schedule to immediate future (e.g., 2 minutes)
  2. Run cronjob once immediately
  3. Verify push success
  4. Immediately restore original schedule
  5. Avoid leaving test schedules in place

### 6. Push Frequency Control
**Problem**: Agent sends multiple/repetitive pushes
**User Feedback**: "下次不要重复发这么多次"
**Solution**:
- Each action should result in exactly one push message
- Consolidate related updates into single messages
- Avoid showing file paths in push messages
- Use clean completion format: "✅ [action] 已完成"
- **Critical rule**: Never push the same content multiple times in rapid succession
- **Test mode caution**: When testing reminders, ensure each reminder type (R2, R3) is pushed only once
- **WeCom limitations**: Remember WeCom does not support edit_message, so each push is permanent
- **User expectation**: Users expect concise, non-repetitive communication

### Recovery Procedures

```python
def handle_order_parsing_error(raw_order):
    # Try multiple parsing strategies
    strategies = [
        parse_with_regex,
        parse_with_llm,
        manual_parsing_fallback
    ]
    
    for strategy in strategies:
        try:
            return strategy(raw_order)
        except ParseError:
            continue
    
    raise CriticalError("无法解析订单信息")
```

## Integration Points

### With Main Orchestrator
- Receive trigger events
- Report completion status
- Pass client data to next phase

### With Client Index System
- Add new client entries
- Update client status
- Maintain file references

### With Notification Systems
- Send SMS/email reminders
- Track delivery status
- Handle bouncebacks

## Performance Optimization

### Batch Processing
For multiple new orders, process in batches:
- Batch directory creation
- Batch index updates
- Batch reminder sending

### Caching
Cache frequently accessed templates and configurations.

## Testing

### Unit Tests
```python
def test_itinerary_generation():
    client_data = ClientData(...)
    itinerary = generate_itinerary(client_data)
    assert itinerary.date == "2026-05-20"
    assert "香港中环" in itinerary.location
    
def test_reminder_generation():
    client_data = ClientData(...)
    reminder = generate_reminder(client_data)
    assert client_data.client_name in reminder
    assert client_data.signing_date in reminder
```

### Integration Tests
```bash
# Test full pre-signing workflow
./test-presign-workflow.sh \
    --order "客户测试，储蓄分红险，整付，保额USD 50,000" \
    --date "2026-05-21" \
    --location "测试地点"
```

## Monitoring

### Key Metrics
- Orders processed per hour
- Itinerary generation time
- Reminder delivery success rate
- Error rate by error type

### Logging
```bash
# Sample log entries
[INFO] Order parsed: 杨洪伟, 储蓄分红险, USD 100,000
[INFO] Itinerary generated: 2026-05-20 14:00 香港中环康乐广场8号
[INFO] Client directory created: active/杨洪伟/
[INFO] Reminder sent to: 138xxxx1234
[INFO] Index updated: added 杨洪伟 to active clients
```

## Maintenance

### Daily Checks
1. Verify reminder delivery logs
2. Check for failed order processing
3. Monitor directory creation errors

### Weekly Tasks
1. Clean up temporary files
2. Update templates if needed
3. Review error patterns

### Monthly Tasks
1. Performance review
2. Template optimization
3. Process improvement

## Migration Notes

This content was migrated from the standalone `presign-agent` skill as part of the umbrella consolidation. All functionality remains intact, now organized under the comprehensive `signing-workflow-system` umbrella.