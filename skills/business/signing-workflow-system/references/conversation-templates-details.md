# Conversation Flow Optimization: conversation-flow-optimization

## Original Skill Content

This file contains the detailed implementation of conversation flow optimization templates that was previously `conversation-flow-optimization`.

## Overview

**conversation-flow-optimization** provides standardized conversation templates for consistent agent interactions across the signing workflow system. These templates ensure professional communication, clear user guidance, and systematic confirmation protocols.

## Core Templates

### 1. Phase Completion Reporting
Templates for reporting completion of workflow phases with clear next steps.

### 2. Ongoing Guidance
Structured guidance for multi-step processes with progress tracking.

### 3. User Confirmation
Systematic confirmation dialogues with clear options and expectations.

### 4. Error Handling
Graceful error communication with recovery options.

## Template Categories

### A. Pre-Signing Phase Templates

#### Template PS-1: Order Confirmation Acknowledgment
```
【签单前阶段 - 订单确认】

✅ 订单已确认收到
客户: {{client_name}}
签单类型: {{policy_type}}
预计签单日期: {{estimated_date}}

📋 下一步安排:
1. 生成详细行程安排（预计 {{completion_time}} 完成）
2. 创建客户档案
3. 发送签单前提醒

⏰ 预计时间线:
- 行程安排: {{itinerary_eta}}
- 客户档案: {{profile_eta}}
- 首次提醒: {{first_reminder_eta}}

❓ 如有任何变更或疑问，请随时告知。
```

#### Template PS-2: Itinerary Generation Completion
```
【签单前阶段 - 行程安排完成】

✅ 行程安排已生成
客户: {{client_name}}
签单时间: {{signing_time}}
签单地点: {{signing_location}}

📄 行程详情已保存至:
{{itinerary_file_path}}

🔔 提醒安排:
- 签单前3天: 首次提醒
- 签单前1天: 最终确认
- 签单当天: 出发前提醒

📋 下一步: 等待签单日触发签单中流程

✅ 状态更新: 签单前阶段完成
```

### B. In-Signing Phase Templates

#### Template IS-1: Signing Result Received
```
【签单中阶段 - 签单结果接收】

📥 签单结果已接收
客户: {{client_name}}
接收时间: {{reception_time}}

🔍 解析内容:
- 保额: {{policy_amount}}
- 附加保障: {{additional_coverage}}
- 缴费方式: {{payment_method}}

🔄 开始信息确认流程:

第1轮确认 - 基本信息:
1. 确认保额 {{policy_amount}}？
2. 确认缴费方式 {{payment_method}}？
3. 确认附加保障 {{additional_coverage}}？

⏳ 预计确认时间: {{confirmation_eta}}
```

#### Template IS-2: Multi-Round Confirmation Summary
```
【签单中阶段 - 信息确认完成】

✅ 信息确认流程完成
客户: {{client_name}}
确认轮次: {{confirmation_rounds}}
确认状态: {{confirmation_status}}

📊 确认结果:
{{#each confirmation_items}}
{{index}}. {{item}}: {{status}} ({{consultant}} 确认于 {{timestamp}})
{{/each}}

📈 差异分析:
{{#each differences}}
- {{field}}: {{original}} → {{current}} ({{change_type}})
{{/each}}

📋 下一步: 生成差异摘要并更新客户状态

✅ 状态更新: 签单中信息确认完成
```

### D. 优化后交互模板

#### 模板 OPT-1: 签单前准备摘要
```
📋 **签单前准备 - {{client_name}}**

1️⃣ **行程安排** ✅ 已完成
   - {{signing_date}} {{signing_time}} {{signing_location}}
   - {{duration}}完整行程安排
   📱 已推送行程海报到签单群

2️⃣ **文档检查** {{doc_status_icon}} {{doc_status}}
   - ✅ 身份证、通行证已确认
   - {{missing_docs_status}} {{missing_docs}}未提供
   → 请提醒客户准备

3️⃣ **提醒设置** ⏳ 已配置
   - R2提醒：{{r2_date}} 09:00
   - R3提醒：{{r3_date}} 09:00

**下一步**：请确认文档齐全后，进入签单中阶段。
```

#### 模板 OPT-2: 签单中信息收集
```
📝 **签单中 - 现场信息收集**

1️⃣ **客户到场** ✅ 已确认
   - 时间：{{arrival_time}}
   - 地点：{{signing_location}}
   - 陪同顾问：{{accompanying_consultant}}

2️⃣ **签约状态** {{signing_status_icon}} {{signing_status}}
   - 投保申请书：{{application_status}}
   - FNA财务分析：{{fna_status}}
   - 健康状况申报：{{health_status}}
   - 核保材料：{{underwriting_status}}

3️⃣ **关键信息确认** ⚠️ 需确认
   - 保额：{{policy_amount}}
   - 缴费方式：{{payment_method}}
   - 附加保障：{{additional_coverage}}
   - 特殊条款：{{special_terms}}

**请确认**：以上信息是否正确？[确认/修改]
```

#### 模板 OPT-3: 签单后缴费归档
```
💰 **签单后 - 缴费与归档**

1️⃣ **缴费信息** ✅ 已确认
   - 首期保费：{{premium_amount}}
   - 缴费方式：{{payment_method}}
   - 截止日期：{{deadline}}
   - 收款账户：{{receiving_account}}
   📱 已生成缴费海报

2️⃣ **核保跟进** ⏳ 进行中
   - 提交时间：{{submission_time}}
   - 预计出单：{{estimated_issue_date}}
   - 跟进人：{{follow_up_person}}
   - 状态：{{underwriting_status}}

3️⃣ **后续安排** 📅 已规划
   - 保单递送：{{delivery_method}}
   - 周年服务：{{annual_service}}
   - 续保提醒：{{renewal_reminder}}

**下一步**：请确认缴费完成，开始归档流程。
```

#### 模板 OPT-4: 归档完成报告
```
📁 **归档完成 - {{client_name}}**

✅ **签单全流程完成**
📊 处理时间：{{total_duration}}
📈 阶段完成：3/3
📁 文件总数：{{total_files}}

📋 **归档摘要**
- 归档日期：{{archive_date}}
- 归档位置：{{archive_path}}
- 保单状态：{{policy_status}}
- 顾问：{{consultant_name}}

🏁 **状态更新**：客户 {{client_name}} 已成功归档
可在归档索引中随时查阅历史记录。
```

### E. 优化后交互规则

#### 规则 OPT-1: 结构化引导
```
📋 **阶段标题 - {客户姓名}**

{数字}️⃣ **项目名称** {状态图标} {状态描述}
   - {关键信息1}
   - {关键信息2}
   {推送图标} {推送说明}

**下一步**：{明确下一步行动}
```

#### 规则 OPT-2: 状态图标系统
- ✅ 已完成
- ⏳ 进行中  
- ⚠️ 需注意/待确认
- ❌ 缺失/异常
- 📱 已推送
- 📅 已安排
- 📊 统计信息
- 📁 文件操作

#### 规则 OPT-3: 确认流程简化
```
**请确认**：{确认问题}？[选项1/选项2]

**自动执行**：确认后自动完成{操作说明}
```

#### 规则 OPT-4: 文件操作黑箱化
- **内部执行**：{文件类型}已生成并保存
- **外部展示**：{业务描述}已完成
- **推送内容**：只推送{可视化输出}，不展示文件路径
【签单后阶段 - 缴费信息生成】

✅ 缴费信息已生成
客户: {{client_name}}
保单号: {{policy_number}}
应缴金额: {{payment_amount}}
缴费截止: {{payment_deadline}}

📄 生成文件:
1. 缴费信息页面: {{payment_page_path}}
2. 缴费海报: {{poster_image_path}}

📱 推送安排:
- 即时推送: 缴费信息页面
- {{reminder_schedule}}: 缴费提醒

💳 缴费方式:
1. 银行转账: {{bank_account}}
2. 在线支付: {{online_payment_link}}
3. 支票支付: {{mailing_address}}

📋 下一步: 等待缴费完成触发归档流程
```

#### Template PO-2: Archival Completion
```
【签单后阶段 - 客户归档完成】

✅ 客户归档完成
客户: {{client_name}}
归档日期: {{archive_date}}
归档位置: {{archive_path}}

📊 归档内容:
- 客户摘要文件: {{summary_file}}
- 签单前文件: {{presign_files_count}} 个
- 签单中文件: {{insign_files_count}} 个  
- 签单后文件: {{postsign_files_count}} 个

📈 签单统计:
- 总处理时间: {{total_duration}}
- 阶段完成时间: {{phase_timeline}}
- 文件总数: {{total_files}}

🏁 状态更新: 签单流程全部完成
客户 {{client_name}} 已成功归档
```

## Conversation Flow Rules

### Rule 1: Structured Reporting
```
【阶段标识】 - 【操作名称】

✅/⚠️/❌ 【状态图标】 【状态描述】

📋/🔍/📊 【内容类型】 【详细内容】

⏰/⏳/📅 【时间信息】 【时间详情】

❓/💡/⚠️ 【提示类型】 【提示内容】

📋 下一步: 【明确下一步行动】

✅ 状态更新: 【状态变更描述】
```

### Rule 2: Confirmation Protocol
```
确认项目: 【确认内容】
当前值: 【当前数值/状态】
预期值: 【预期数值/状态】
差异: 【差异描述】

请确认:
1. 【确认问题1】？
2. 【确认问题2】？
3. 【确认问题3】？

确认选项:
✅ 确认无误
🔄 需要修改
❌ 信息有误

确认后操作: 【确认后的下一步】
```

### Rule 3: Error Handling
```
❌ 操作失败: 【失败操作名称】

🔍 失败原因: 【具体原因】
📄 相关文件: 【涉及文件路径】
⏰ 发生时间: 【失败时间】

🔄 恢复选项:
1. 【恢复选项1】
2. 【恢复选项2】  
3. 【恢复选项3】

⚠️ 影响范围: 【影响描述】
📋 建议操作: 【建议处理方式】

需要人工介入: 【是/否】
预计恢复时间: 【恢复时间估计】
```

## Template Variables System

### Standard Variable Set
```yaml
client_variables:
  - client_name: "客户姓名"
  - client_id: "客户ID"
  - contact_info: "联系方式"
  
policy_variables:
  - policy_type: "签单类型"
  - policy_number: "保单号"
  - policy_amount: "保额"
  - coverage_details: "保障详情"
  
time_variables:
  - signing_date: "签单日期"
  - signing_time: "签单时间"
  - completion_time: "完成时间"
  - estimated_time: "预计时间"
  
file_variables:
  - file_path: "文件路径"
  - file_count: "文件数量"
  - file_size: "文件大小"
  
status_variables:
  - current_status: "当前状态"
  - previous_status: "之前状态"
  - next_status: "下一状态"
  - completion_percentage: "完成百分比"
```

### Variable Substitution Rules
```python
def substitute_variables(template, variables):
    """
    Substitute variables in template with validation
    """
    result = template
    
    for key, value in variables.items():
        placeholder = f"{{{{{key}}}}}"
        
        # Validate required variables
        if key in required_variables and not value:
            raise MissingVariableError(f"Required variable '{key}' is empty")
        
        # Apply formatting based on variable type
        if key.endswith("_time") or key.endswith("_date"):
            value = format_datetime(value)
        elif key.endswith("_amount"):
            value = format_currency(value)
        elif key.endswith("_path"):
            value = format_file_path(value)
        
        result = result.replace(placeholder, value)
    
    # Check for unmatched placeholders
    unmatched = re.findall(r"\{\{([^}]+)\}\}", result)
    if unmatched:
        warnings.warn(f"Unmatched variables: {unmatched}")
    
    return result
```

## Integration with Agents

### Pre-Signing Agent Integration
```python
class PresignAgent:
    def report_order_confirmation(self, client_data):
        template = load_template("PS-1")
        variables = {
            "client_name": client_data.name,
            "policy_type": client_data.policy_type,
            "estimated_date": client_data.signing_date,
            "completion_time": "30分钟内",
            "itinerary_eta": "15分钟",
            "profile_eta": "5分钟",
            "first_reminder_eta": "签单前3天"
        }
        return substitute_variables(template, variables)
```

### In-Signing Agent Integration
```python
class InsignAgent:
    def report_confirmation_summary(self, confirmation_data):
        template = load_template("IS-2")
        variables = {
            "client_name": confirmation_data.client_name,
            "confirmation_rounds": len(confirmation_data.rounds),
            "confirmation_status": "全部确认",
            "confirmation_items": format_confirmation_items(confirmation_data.items),
            "differences": format_differences(confirmation_data.differences)
        }
        return substitute_variables(template, variables)
```

### Post-Signing Agent Integration
```python
class PostsignAgent:
    def report_archival_completion(self, archive_data):
        template = load_template("PO-2")
        variables = {
            "client_name": archive_data.client_name,
            "archive_date": archive_data.archive_date,
            "archive_path": archive_data.archive_path,
            "summary_file": archive_data.summary_file,
            "presign_files_count": len(archive_data.presign_files),
            "insign_files_count": len(archive_data.insign_files),
            "postsign_files_count": len(archive_data.postsign_files),
            "total_duration": archive_data.total_duration,
            "phase_timeline": format_timeline(archive_data.timeline),
            "total_files": archive_data.total_files
        }
        return substitute_variables(template, variables)
```

## Quality Standards

### Readability Requirements
1. **Clear section headers**: Use 【】for phase identification
2. **Consistent icons**: ✅ for success, ⚠️ for warning, ❌ for error
3. **Structured content**: Use 📋 for steps, 🔍 for details, 📊 for summaries
4. **Time indications**: Use ⏰ for schedules, ⏳ for estimates, 📅 for dates
5. **Action prompts**: Use ❓ for questions, 💡 for suggestions, ⚠️ for warnings

### Content Guidelines
1. **Be specific**: Include exact values, paths, and times
2. **Be actionable**: Clearly state next steps
3. **Be concise**: Keep messages focused and to the point
4. **Be consistent**: Use same terminology across all templates
5. **Be helpful**: Include relevant context and explanations

### Validation Rules
```python
def validate_conversation_message(message):
    rules = [
        ("必须包含阶段标识", lambda m: "【" in m and "】" in m),
        ("必须包含状态图标", lambda m: any(icon in m for icon in ["✅", "⚠️", "❌"])),
        ("必须包含下一步指示", lambda m: "📋 下一步:" in m),
        ("必须包含状态更新", lambda m: "✅ 状态更新:" in m),
        ("变量必须被替换", lambda m: "{{" not in m and "}}" not in m)
    ]
    
    violations = []
    for rule_name, rule_check in rules:
        if not rule_check(message):
            violations.append(rule_name)
    
    return violations
```

## Template Customization

### Style Customization
```yaml
styles:
  formal:
    greeting: "尊敬的客户"
    closing: "此致 敬礼"
    tone: "专业、正式"
    
  friendly:
    greeting: "您好"
    closing: "祝好"
    tone: "亲切、友好"
    
  concise:
    greeting: ""
    closing: ""
    tone: "简洁、直接"
```

### Language Support
```yaml
languages:
  zh_CN:
    templates_dir: "templates/zh_CN/"
    date_format: "YYYY年MM月DD日"
    time_format: "HH:mm"
    currency_format: "¥{amount}"
    
  en_US:
    templates_dir: "templates/en_US/"
    date_format: "MM/DD/YYYY"
    time_format: "hh:mm A"
    currency_format: "${amount}"
```

## Testing and Validation

### Template Testing
```python
def test_template_substitution():
    template = "客户: {{client_name}}，金额: {{amount}}"
    variables = {"client_name": "测试", "amount": "100"}
    result = substitute_variables(template, variables)
    assert result == "客户: 测试，金额: 100"
    assert "{{" not in result
    assert "}}" not in result
    
def test_template_validation():
    message = "【测试】✅ 完成 📋 下一步: 测试 ✅ 状态更新: 完成"
    violations = validate_conversation_message(message)
    assert len(violations) == 0
```

### Integration Testing
```bash
# Test template generation
./test-templates.sh \
    --template PS-1 \
    --variables client_name=测试policy_type=储蓄分红险date=2026-05-20 \
    --validate
```

## Performance Optimization

### Template Caching
```python
class TemplateCache:
    def __init__(self):
        self.cache = {}
        self.hits = 0
        self.misses = 0
    
    def get_template(self, template_name):
        if template_name in self.cache:
            self.hits += 1
            return self.cache[template_name]
        
        self.misses += 1
        template = load_template_from_disk(template_name)
        self.cache[template_name] = template
        return template
```

### Batch Processing
For multiple messages:
- Batch template loading
- Batch variable substitution
- Batch validation

## Monitoring and Analytics

### Usage Metrics
```yaml
metrics:
  templates_used:
    - template_name: "PS-1"
      usage_count: 150
      avg_response_time: "2.3s"
      error_rate: "0.5%"
    
  user_engagement:
    - avg_message_length: "245 chars"
    - avg_response_time: "15.2s"
    - completion_rate: "92.3%"
```

### Quality Metrics
```yaml
quality:
  validation_passed: "98.7%"
  variable_completeness: "99.2%"
  template_consistency: "97.8%"
  user_satisfaction: "4.8/5.0"
```

## Migration Notes

This content was migrated from the standalone `conversation-flow-optimization` skill as part of the umbrella consolidation. All functionality remains intact, now organized under the comprehensive `signing-workflow-system` umbrella.