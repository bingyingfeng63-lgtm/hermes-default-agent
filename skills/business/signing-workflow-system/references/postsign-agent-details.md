# Post-Signing Agent: postsign-agent

## Original Skill Content

This file contains the detailed implementation of the post-signing agent that was previously `postsign-agent`.

## Overview

**postsign-agent** handles all post-signing activities including payment page generation, payment poster creation, client archiving, and final record updates. It's triggered after signing completion and confirmation.

## Core Responsibilities

### 1. Payment Information Generation
- Generate detailed payment information pages
- Include payment amounts, methods, and deadlines
- Provide payment instructions and references

### 2. Payment Poster Creation
- Create visual payment posters using image-designer
- Include key payment information in visual format
- Generate both HTML and PNG versions

### 3. Client Communication
- Push payment information to clients
- Send payment reminders if needed
- Handle client payment queries

### 4. Archival Management
- Archive completed client cases
- Move from active to archive directory
- Update archive indices

### 5. Final Record Updates
- Update client status to "completed"
- Finalize all documentation
- Ensure data consistency

## Workflow Steps

### 缴费数据逐项引导（硬性规则）

**禁止**一次性列出所有待填字段让顾问填。必须逐项提问、逐项确认。标准流程：

| 序号 | 字段 | 引导问法 | 默认值 |
|------|------|----------|--------|
| 1 | 首期保费金额 | "首期保费是多少？" | — |
| 2 | 缴费方式 | "现金 / 转账 / 信用卡？" | — |
| 3 | 缴费截止日期 | "哪天前需完成？" | 签单当日 |
| 4 | 保单号 | "有吗？" | 留空待补 |

**回复格式**：`{值}，记下。` + 下一项提问。全部确认后一次性生成 payment.md + HTML + PNG。

**Pitfall（2026-06-15 测试暴露）**：顾问说"默认签单即可"时，不应再追问，直接记下默认值并进入下一项。

### Step 1: Generate Payment Page
```html
<!-- Payment page HTML template -->
<!DOCTYPE html>
<html>
<head>
    <title>缴费信息 - {{client_name}}</title>
    <style>
        .payment-info { font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; }
        .header { background: #4CAF50; color: white; padding: 20px; text-align: center; }
        .details { padding: 20px; border: 1px solid #ddd; margin: 20px 0; }
        .amount { font-size: 24px; color: #f44336; font-weight: bold; }
        .deadline { color: #ff9800; font-weight: bold; }
        .instructions { background: #f9f9f9; padding: 15px; border-left: 4px solid #2196F3; }
    </style>
</head>
<body>
    <div class="payment-info">
        <div class="header">
            <h1>保单缴费信息</h1>
            <p>客户: {{client_name}} | 保单号: {{policy_number}}</p>
        </div>
        
        <div class="details">
            <h2>缴费详情</h2>
            <p class="amount">应缴金额: {{payment_amount}}</p>
            <p class="deadline">缴费截止: {{payment_deadline}}</p>
            
            <h3>缴费方式</h3>
            <ul>
                <li>银行转账: {{bank_account}}</li>
                <li>在线支付: {{online_payment_link}}</li>
                <li>支票支付: {{mailing_address}}</li>
            </ul>
            
            <div class="instructions">
                <h3>重要说明</h3>
                <p>请在缴费时备注: {{reference_number}}</p>
                <p>缴费后请保留凭证，如需帮助请联系: {{contact_info}}</p>
            </div>
        </div>
    </div>
</body>
</html>
```

### Step 2: Create Payment Poster
```bash
# Use image-designer to create PNG poster
# Input: HTML payment page
# Output: payment-poster.png
image-designer \
    --html payment-page.html \
    --output payment-poster.png \
    --width 800 \
    --height 1200 \
    --format png
```

### 优化后的交互模式

#### 签单后阶段 - 优化后输出
```
💰 **签单后 - 缴费与归档**

1️⃣ **缴费信息** ✅ 已确认
   - 首期保费：{保费金额}
   - 缴费方式：{缴费方式}
   - 截止日期：{截止日期}
   - 收款账户：{收款账户}
   📱 已生成缴费海报

2️⃣ **核保跟进** ⏳ 进行中
   - 提交时间：{提交时间}
   - 预计出单：{预计时间}
   - 跟进人：{跟进人}
   - 状态：{核保状态}

3️⃣ **后续安排** 📅 已规划
   - 保单递送：{递送方式}
   - 周年服务：{服务安排}
   - 续保提醒：{提醒设置}

**下一步**：请确认缴费完成，开始归档流程。
```

#### 归档完成 - 优化后输出
```
📁 **归档完成 - {客户姓名}**

✅ **签单全流程完成**
📊 处理时间：{总时长}
📈 阶段完成：3/3
📁 文件总数：{文件数量}

📋 **归档摘要**
- 归档日期：{归档日期}
- 归档位置：{归档路径}
- 保单状态：{保单状态}
- 顾问：{顾问姓名}

🏁 **状态更新**：客户 {客户姓名} 已成功归档
可在归档索引中随时查阅历史记录。
```

#### 关键优化点
1. **阶段清晰**：缴费、核保、归档分步展示
2. **信息分层**：关键信息突出，细节适当隐藏
3. **可视化输出**：缴费海报作为主要交付物
4. **归档摘要**：简洁明了的完成报告
5. **业务导向**：强调后续服务和客户价值

#### 文件操作黑箱化
- **内部执行**：完整生成payment.md、payment.html、payment.png、归档文件
- **外部展示**：只说明"缴费信息已生成"、"归档已完成"
- **推送精简**：只推送缴费海报PNG，不展示文件路径

#### 确认流程优化
**需要确认的点：**
1. 缴费信息是否正确
2. 是否开始归档流程
3. 归档摘要是否需要调整

**自动执行的点：**
1. 缴费页面生成和海报制作
2. 文件归档和索引更新
3. 状态同步和记录保存

#### 缴费海报推送原则
```
📱 **缴费信息已发送**
客户：{客户姓名}
金额：{保费金额}
截止：{截止日期}

💡 **温馨提示**：请按时缴费以确保保单生效
如有疑问请联系：{顾问联系方式}
```

#### 归档推送原则
```
📁 **客户归档完成**
✅ {客户姓名} 签单流程已全部完成
📅 归档日期：{归档日期}
📊 文件已安全保存

🔍 **查阅方式**：归档索引 → {归档路径}
```

### Step 4: Archive Completed Case
```bash
# Archive workflow
1. Move client from active/ to archive/
2. Update archive/CLIENT-INDEX.md
3. Remove from active/CLIENT-INDEX.md
4. Create archive summary
5. Verify archive completeness
```

### Step 5: Update Final Records
```markdown
# Update CLIENT-SUMMARY.md
## 签单状态
| 阶段 | 状态 | 完成时间 | 说明 |
|------|------|----------|------|
| 签单前 | ✅ 已完成 | 2026-05-17 10:30:00 | 行程安排已推送 |
| 签单中 | ✅ 已完成 | 2026-05-20 14:45:00 | 签单信息已确认 |
| 签单后 | ✅ 已完成 | 2026-05-20 16:30:00 | 缴费页面已生成 |

# Update archive/CLIENT-INDEX.md
| 序号 | 客户姓名 | 签单类型 | 签约日期 | 归档日期 | 顾问 | 保单号 | 归档文件 |
|------|----------|----------|----------|----------|------|--------|----------|
| 001 | 杨洪伟 | 储蓄分红险 | 2026-05-20 | 2026-05-20 | 张顾问 | POL-2026-001 | archive/杨洪伟/CLIENT-SUMMARY.md |
```

## Data Structures

### Payment Information Model
```python
class PaymentInfo:
    client_id: str
    policy_number: str
    payment_amount: str  # "USD 10,000"
    payment_deadline: datetime
    payment_methods: List[PaymentMethod]
    reference_number: str
    contact_info: str
    generated_at: datetime
```

### Archive Record Model
```python
class ArchiveRecord:
    client_id: str
    original_sign_date: datetime
    archive_date: datetime
    policy_type: str
    consultant: str
    policy_number: str
    archive_path: str
    summary_file: str
    completeness_check: bool
```

## Template Files

### Payment Page Template
```html
<!-- templates/payment-page.html -->
<!DOCTYPE html>
<html>
<head>
    <title>缴费信息 - {{client_name}}</title>
    {{> styles}}
</head>
<body>
    <div class="payment-info">
        {{> header}}
        {{> payment_details}}
        {{> payment_methods}}
        {{> instructions}}
        {{> footer}}
    </div>
</body>
</html>
```

### Archive Summary Template
```markdown
<!-- templates/archive-summary.md -->
# 归档摘要
**客户**: {{client_name}}
**保单号**: {{policy_number}}
**签单类型**: {{policy_type}}
**签约日期**: {{signing_date}}
**归档日期**: {{archive_date}}
**顾问**: {{consultant}}

## 文件清单
{{#each files}}
- {{path}} ({{size}}, {{modified_date}})
{{/each}}

## 完整性检查
✅ 所有必需文件已归档
✅ 索引已更新
✅ 权限设置正确
✅ 备份已完成

## 归档说明
{{archive_notes}}
```

## Pitfalls and User Corrections

### 1. Payment Poster Push Control
**Problem**: Agent may generate multiple files but should push only one clean PNG
**User Feedback**: "你又同时推送两张海报到群里，其实一张就够了"
**Solution**:
- Generate HTML, PNG, and markdown files for internal use
- **Push only PNG**: Use `MEDIA:` syntax to push single payment poster PNG
- **Clean presentation**: Don't show file paths or technical details in push message
- **File location**: Ensure PNG is in client folder `data/active/{client_name}/postsign/payment.png`

### 2. Push Frequency Management
**Problem**: Unnecessary repetition in communication
**User Feedback**: "下次不要重复发这么多次"
**Solution**:
- Each phase completion should result in exactly one concise push
- Consolidate file generation updates into single completion message
- Use format: "✅ [阶段] 已完成" without listing all file paths
- Remember WeCom limitations: No edit_message, each push is permanent

### 3. Test Mode Considerations
**Problem**: Testing payment poster generation without actual client delivery
**Solution**:
- Generate all files locally for verification
- Only push to actual client after confirmation
- For testing, show file paths in conversation but not in WeCom push
- Maintain clear distinction between test mode and production delivery

### HTML to PNG Conversion
```python
def create_payment_poster(html_content, output_path):
    # Save HTML to temporary file
    temp_html = save_temp_html(html_content)
    
    # Use image-designer to convert
    result = run_image_designer(
        input_html=temp_html,
        output_path=output_path,
        width=800,
        height=1200,
        format="png"
    )
    
    # Verify output
    if result.success and file_exists(output_path):
        return output_path
    else:
        raise ImageGenerationError(f"Failed to create poster: {result.error}")
```

### Image-Designer Configuration
```yaml
# image-designer config for payment posters
defaults:
  width: 800
  height: 1200
  format: png
  quality: 90
  timeout: 30

templates:
  payment-poster:
    css: |
      body { font-family: 'Helvetica Neue', Arial, sans-serif; }
      .amount { color: #e74c3c; font-size: 32px; }
      .deadline { color: #e67e22; }
    scripts: |
      // Add any JavaScript for dynamic content
```

## Error Handling

### Common Errors

1. **Payment page generation failure**: Check template syntax, retry
2. **Image generation failure**: Verify image-designer installation, check HTML
3. **Archive permission issues**: Check directory permissions, retry with sudo
4. **Index update conflicts**: Manual reconciliation, verify consistency

### Recovery Procedures

```python
def handle_payment_generation_failure(client_data):
    # Try alternative template
    try:
        return generate_with_primary_template(client_data)
    except TemplateError:
        # Fall back to simple template
        return generate_with_simple_template(client_data)
        
def handle_archive_failure(client_path):
    # Check what failed
    failures = diagnose_archive_failure(client_path)
    
    for failure in failures:
        if failure.type == "permission":
            fix_permissions(failure.path)
        elif failure.type == "missing_file":
            locate_or_regenerate(failure.file)
        elif failure.type == "index_conflict":
            reconcile_index_conflict(failure.conflict)
    
    # Retry archive
    return retry_archive(client_path)
```

## Archival Strategy

### Archive Structure
```
archive/
├── CLIENT-INDEX.md                    # Archive index
├── by_year/
│   ├── 2026/
│   │   ├── Q1/
│   │   ├── Q2/
│   │   └── ...
│   └── 2025/
└── by_consultant/
    ├── 张顾问/
    ├── 李顾问/
    └── ...
```

### Retention Policy
- **Active clients**: Keep in active/ directory
- **Recent archives** (<1 year): Quick access location
- **Old archives** (1-3 years): Compressed storage
- **Very old archives** (>3 years): Cold storage/backup

## Performance Optimization

### Batch Processing
For multiple completed signings:
- Batch payment page generation
- Batch image creation
- Batch archival operations

### Incremental Updates
- Only update changed files
- Cache generated payment pages
- Reuse templates where possible

## Testing

### Unit Tests
```python
def test_payment_page_generation():
    payment_info = PaymentInfo(...)
    html = generate_payment_page(payment_info)
    assert "USD 10,000" in html
    assert payment_info.client_name in html
    
def test_archive_creation():
    client_data = ClientData(...)
    archive_path = archive_client(client_data)
    assert os.path.exists(archive_path)
    assert os.path.exists(os.path.join(archive_path, "CLIENT-SUMMARY.md"))
```

### Integration Tests
```bash
# Test full post-signing workflow
./test-postsign-workflow.sh \
    --client "测试客户" \
    --amount "USD 10,000" \
    --deadline "2026-06-20" \
    --policy "POL-2026-001"
```

## Monitoring

### Key Metrics
- Payment pages generated per day
- Archive completion rate
- Image generation success rate
- Processing time per client
- Storage usage growth

### Logging
```bash
# Sample log entries
[INFO] Payment page generated: 测试客户, USD 10,000
[INFO] Payment poster created: payment-poster.png (800x1200)
[INFO] Payment info pushed to client: 测试客户
[INFO] Client archived: 测试客户 → archive/2026/Q2/
[INFO] Index updated: removed from active, added to archive
```

## Security Considerations

### Payment Information Security
- Never store full payment details in logs
- Encrypt sensitive payment information
- Secure transmission to clients
- Access control for archived data

### Archive Security
- Regular backup verification
- Access logging for archive operations
- Encryption for long-term storage
- Disaster recovery procedures

## Migration Notes

This content was migrated from the standalone `postsign-agent` skill as part of the umbrella consolidation. All functionality remains intact, now organized under the comprehensive `signing-workflow-system` umbrella.