# In-Signing Agent: insign-agent

## Original Skill Content

This file contains the detailed implementation of the in-signing agent that was previously `insign-agent`.

## Overview

**insign-agent** manages the actual signing process, collecting results, parsing information, and conducting multi-round confirmations with consultants. It's triggered on signing day or after signing completion.

## Core Responsibilities

### 1. Signing Result Collection
- Parse signing completion notifications
- Extract key information from signed documents
- Validate data completeness and accuracy

### 2. Information Parsing and Validation
- Parse policy details, amounts, and terms
- Validate against pre-signing information
- Identify discrepancies and changes

### 3. Multi-Round Confirmation
- Conduct structured confirmation dialogues with consultants
- Clarify ambiguous information
- Obtain explicit confirmation of key terms

### 4. Difference Summary Generation
- Compare signed terms with original proposal
- Generate clear difference summaries
- Highlight changes and additions

### 5. Status Update
- Update client status from "in-signing" to "completed"
- Trigger next phase (post-signing)
- Update client index and summaries
- **Proactive guidance**: After completing phase, immediately prompt user for next steps with clear description of what's needed

## Workflow Steps

### Step 1: Parse Signing Results
```bash
# Input: "签单完成，保额USD 100,000，附加早期严重疾病保障，缴费方式：期付"
# Output: Structured signing data
{
  "status": "completed",
  "policy_amount": "USD 100,000",
  "additional_coverage": ["早期严重疾病保障"],
  "payment_method": "期付",
  "signing_time": "2026-05-20 14:30:00",
  "notes": "客户对保障条款满意"
}
```

### Step 2: Extract Key Information
```python
# Information extraction categories
information_categories = [
    "policy_amount",
    "coverage_type",
    "payment_terms",
    "additional_riders",
    "effective_date",
    "premium_amount",
    "beneficiaries",
    "special_conditions"
]
```

### 签单中强制逐项确认清单（硬性规则）

**禁止**只问"签单是否完成？有无变更？"就结束。必须逐项追问以下字段，每次最多问 2 项：

| 序号 | 确认项 | 引导问法 |
|------|--------|----------|
| 1 | 保额 | "原方案保额 {原保额}，签单确认多少？" |
| 2 | 缴费方案 | "原方案 {原缴费方案}，签单确认什么方式？" |
| 3 | 附加保障 | "是否加了附加保障？如早期疾病、意外等？" |
| 4 | 特殊条款 | "有无特殊条款变更或备注？" |
| 5 | 客户需求 | "客户有无额外需求？（语言偏好、递送方式等）" |

**执行规则**：
- 顾问提供签单结果后，逐项引导确认，一项一项来
- 每轮最多 2 个问题，不给信息过载
- 所有字段确认完后，生成差异报告再问"确认生成差异报告？"
- 不得自行跳过任何字段，除非顾问明确说"没有"

**Pitfall（本次测试暴露）**：测试中顾问只给了"签单完成、无变更"，agent 没有追问保额、缴费方式等字段确认，直接结束。这是错误的。即使顾问说"无变更"，也必须逐项确认。

### 优化后的交互模式

#### 签单中阶段 - 优化后输出
```
📝 **签单中 - 现场信息收集**

1️⃣ **客户到场** ✅ 已确认
   - 时间：{到场时间}
   - 地点：{签单地点}
   - 陪同顾问：{陪同顾问}

2️⃣ **签约状态** {状态图标} {状态}
   - 投保申请书：{签署状态}
   - FNA财务分析：{分析状态}
   - 健康状况申报：{申报状态}
   - 核保材料：{材料状态}

3️⃣ **关键信息确认** ⚠️ 需确认
   - 保额：{保额金额}
   - 缴费方式：{缴费方式}
   - 附加保障：{附加保障}
   - 特殊条款：{特殊条款}

**请确认**：以上信息是否正确？[确认/修改]
```

#### 关键优化点
1. **现场感**：强调"现场信息收集"
2. **状态可视化**：用图标快速识别各项状态
3. **关键信息突出**：保额、缴费方式等核心信息单独列出
4. **确认简化**：合并多项确认为单次确认
5. **业务聚焦**：只说顾问关心的签约状态

#### 信息收集流程优化
**第一轮：基本信息确认**
```
📋 **基本信息确认**
✅ 客户：{客户姓名}
✅ 签单类型：{签单类型}
✅ 签约时间：{签约时间}

⏳ **待确认项目**
1. 保额 {保额金额} 是否正确？
2. 缴费方式 {缴费方式} 是否正确？
3. 是否有附加保障？

**请逐一确认**：[1是/2是/3否]
```

**第二轮：差异确认（如有变更）**
```
⚠️ **发现变更项**
1. 保额：原方案 {原保额} → 签单 {新保额}
2. 缴费方式：原 {原方式} → 签单 {新方式}
3. 新增：{新增保障}

**请说明变更原因**：[原因说明]
```

**最终确认**
```
✅ **所有信息已确认**
📊 签单结果：成功
📈 变更项：{变更数量}项
📁 文件已保存

**下一步**：进入签单后阶段，生成缴费信息。
```

#### 文件操作黑箱化
- **内部执行**：完整生成signing-result.md、difference-summary.md
- **外部展示**：只说明"签单信息已确认"、"差异报告已生成"
- **确认简化**：关键信息确认后自动处理后续文件

### Step 4: Generate Difference Summary
```markdown
# 差异摘要
**客户**: 杨洪伟
**签单类型**: 储蓄分红险
**签约日期**: 2026-05-20

## 主要变更
| 项目 | 原方案 | 签单结果 | 变更类型 |
|------|--------|----------|----------|
| 保额 | USD 50,000 | USD 100,000 | ▲ 增加 |
| 附加保障 | 无 | 早期严重疾病保障 | + 新增 |
| 缴费方式 | 期付 | 整付 | ▲ 变更 |

## 变更说明
1. **保额增加**: 从USD 50,000增加到USD 100,000
2. **新增保障**: 添加了早期严重疾病保障
3. **缴费方式变更**: 从期付变更为整付

## 影响分析
- 总保费增加: +100%
- 保障范围扩大: +早期严重疾病
- 支付方式简化: 一次性付清
```

### Step 5: Update Client Status
```bash
# Update CLIENT-SUMMARY.md
## 签单状态
| 阶段 | 状态 | 完成时间 | 说明 |
|------|------|----------|------|
| 签单前 | ✅ 已完成 | 2026-05-17 10:30:00 | 行程安排已推送 |
| 签单中 | ✅ 已完成 | 2026-05-20 14:45:00 | 签单信息已确认 |
| 签单后 | ○ 未开始 | - | - |

# Update active/CLIENT-INDEX.md
| ... | 签单前 | 签单中 | 签单后 | 状态 |
|-----|--------|--------|--------|------|
| ... | ✅ | ✅ | ○ | 签单中完成 |
```

## Data Structures

### Signing Result Model
```python
class SigningResult:
    client_id: str
    signing_date: datetime
    status: str  # "completed", "partial", "cancelled"
    policy_details: PolicyDetails
    changes_from_original: List[Change]
    consultant_notes: str
    confirmation_rounds: List[ConfirmationRound]
```

### Change Model
```python
class Change:
    field: str  # "policy_amount", "coverage", "payment_terms"
    original_value: Any
    new_value: Any
    change_type: str  # "increase", "decrease", "add", "remove", "change"
    impact: str  # "minor", "moderate", "major"
```

### Confirmation Round Model
```python
class ConfirmationRound:
    question: str
    expected_answer: str
    actual_answer: str
    confirmed: bool
    timestamp: datetime
    consultant_id: str
```

## Template Files

### Confirmation Dialogue Template
```markdown
## 第{{round_number}}轮确认

**确认项**: {{field}}
**原值**: {{original_value}}
**签单值**: {{new_value}}

**问题**: {{question}}
**预期回答**: {{expected_answer}}

**实际回答**: {{actual_answer}}
**确认状态**: {{confirmed_status}}
**确认时间**: {{timestamp}}
**顾问**: {{consultant}}
```

### Difference Summary Template
```markdown
# 差异摘要
**客户**: {{client_name}}
**签单类型**: {{policy_type}}
**签约日期**: {{signing_date}}

## 主要变更
{{#each changes}}
| {{field}} | {{original_value}} | {{new_value}} | {{change_type}} |
{{/each}}

## 变更说明
{{#each change_explanations}}
{{index}}. **{{title}}**: {{description}}
{{/each}}

## 影响分析
{{impact_analysis}}
```

## Error Handling

### Common Errors

1. **Incomplete signing information**: Request additional details
2. **Contradictory information**: Escalate to manual review
3. **Consultant unavailable**: Schedule follow-up confirmation
4. **Data validation failure**: Flag for manual verification

### Recovery Procedures

```python
def handle_incomplete_data(signing_data):
    missing_fields = identify_missing_fields(signing_data)
    
    if missing_fields:
        # Request missing information
        request_additional_info(missing_fields)
        
        # If still missing after retry, escalate
        if still_missing(missing_fields):
            escalate_to_manual_review(signing_data, missing_fields)
```

## Confirmation Strategies

### Single-Pass Confirmation
For simple, clear cases with no discrepancies:
- Confirm all key fields in one round
- Require explicit "yes" for each field
- Record confirmation timestamp

### Multi-Round Clarification
For complex cases with discrepancies:
- Round 1: Confirm basic facts
- Round 2: Clarify discrepancies
- Round 3: Final confirmation of changes
- Document reasoning for each change

### Escalation Protocol
When confirmation fails:
1. Retry with different phrasing
2. Escalate to senior consultant
3. Flag for manual review
4. Document escalation path

## Integration Points

### With Previous Phase (Pre-signing)
- Compare with original proposal
- Validate consistency
- Calculate differences

### With Next Phase (Post-signing)
- Pass confirmed signing data
- Trigger payment page generation
- Update workflow status

### With Client Index System
- Update signing status
- Add difference summaries
- Maintain audit trail

## Performance Optimization

### Batch Confirmation
For multiple signings on same day:
- Batch confirmation requests
- Parallel processing where possible
- Consolidated difference summaries

### Caching
Cache frequently accessed:
- Client original proposals
- Consultant contact information
- Confirmation templates

## Testing

### Unit Tests
```python
def test_signing_parsing():
    raw_result = "签单完成，保额USD 100,000"
    parsed = parse_signing_result(raw_result)
    assert parsed.policy_amount == "USD 100,000"
    assert parsed.status == "completed"
    
def test_difference_calculation():
    original = {"amount": "USD 50,000"}
    signed = {"amount": "USD 100,000"}
    differences = calculate_differences(original, signed)
    assert differences[0].change_type == "increase"
```

### Integration Tests
```bash
# Test full in-signing workflow
./test-insign-workflow.sh \
    --signing-result "签单完成，保额USD 100,000，附加早期严重疾病保障" \
    --original-proposal "保额USD 50,000，无附加保障" \
    --consultant "张顾问"
```

## Monitoring

### Key Metrics
- Signings processed per day
- Average confirmation rounds per signing
- Discrepancy rate
- Confirmation success rate
- Processing time by complexity

### Logging
```bash
# Sample log entries
[INFO] Signing result received: 杨洪伟, USD 100,000
[INFO] Parsing completed: 3 fields extracted
[INFO] Confirmation round 1 started
[INFO] Confirmation completed: all fields confirmed
[INFO] Difference summary generated: 3 changes identified
[INFO] Client status updated: in-signing → completed
```

## Quality Assurance

### Validation Checks
1. **Data completeness**: All required fields present
2. **Logical consistency**: No contradictory information
3. **Change justification**: All changes have documented reasoning
4. **Confirmation audit**: All confirmations properly recorded

### Review Procedures
1. **Automated review**: Run validation checks
2. **Peer review**: Complex cases reviewed by second agent
3. **Supervisor review**: Major changes require supervisor approval

## Migration Notes

This content was migrated from the standalone `insign-agent` skill as part of the umbrella consolidation. All functionality remains intact, now organized under the comprehensive `signing-workflow-system` umbrella.