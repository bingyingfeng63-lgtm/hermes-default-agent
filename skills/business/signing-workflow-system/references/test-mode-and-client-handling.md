# Test Mode Procedures & Client Name Handling

## Test Mode for Cronjob Reminders

### When to Use Test Mode
- User requests to test reminder functionality
- Debugging cronjob scheduling issues
- Verifying reminder content and formatting

### Test Mode Protocol
1. **Temporary Modification**: Change cronjob schedule to immediate/rapid execution
   ```bash
   # Original: 0 9 23 6 * (June 23, 9:00 AM)
   # Test: */2 * * * * (every 2 minutes)
   cronjob update --job_id R2_JOB_ID --schedule "*/2 * * * *"
   ```

2. **Immediate Execution**: Run the cronjob once for testing
   ```bash
   cronjob run --job_id R2_JOB_ID
   ```

3. **Restore Original Schedule**: Immediately after test, restore original timing
   ```bash
   cronjob update --job_id R2_JOB_ID --schedule "0 9 23 6 *"
   ```

4. **Avoid Repetition**: Run each test only once, do not let modified schedule persist

### Key Considerations
- **User Expectation**: Users may ask "能不能提前推送" for testing
- **Single Execution**: Test should run once, not repeatedly
- **Clean Restoration**: Always restore original schedule after test
- **Documentation**: Clearly indicate test vs production in logs

## Multi-Person Client Name Handling

### Problem Scenario
Client names containing commas and spaces: "李女士、张小姐"
- File systems don't support commas in directory names
- Need consistent path handling across all agents

### Solution: Hyphen Replacement
1. **Display Name**: Keep original with commas for user-facing display
2. **File Path Name**: Replace commas and spaces with hyphens
   - "李女士、张小姐" → "李女士-张小姐"
3. **Consistent Application**: Apply to all directory and file paths

### Implementation Pattern
```python
def sanitize_client_name_for_path(display_name):
    """
    Convert display name to file system safe name.
    
    Example:
    "李女士、张小姐" → "李女士-张小姐"
    "王先生, 李太太" → "王先生-李太太"
    """
    # Replace Chinese comma 、 with hyphen
    name = display_name.replace('、', '-')
    # Replace Chinese comma ， with hyphen  
    name = name.replace('，', '-')
    # Replace English comma , with hyphen
    name = name.replace(',', '-')
    # Replace spaces with hyphens
    name = name.replace(' ', '-')
    # Remove any double hyphens
    name = name.replace('--', '-')
    return name
```

### File Structure Example
```
~/.hermes/data/active/李女士-张小姐/
├── CLIENT-SUMMARY.md          # Display name: "李女士、张小姐"
├── presign/
│   ├── original-plan.md
│   └── itinerary.md          # References "李女士、张小姐" in content
└── insign/
    └── signing-result.md     # References "李女士、张小姐" in content
```

### Index File Handling
- **CLIENT-INDEX.md**: Use display name with commas in table
- **Path column**: Use sanitized name for folder path
- **Consistency**: Ensure all agents use same sanitization logic

## Proactive Phase Transition Guidance

### User Expectation
After completing a phase, users expect:
1. **Summary of completed work**
2. **Clear indication of next phase**
3. **Prompt for next steps**
4. **Required information for next phase**

### Implementation Pattern
```markdown
[签单中] 进度 5/5 已完成

✅ **签单结果收集** → `active/李女士-张小姐/insign/signing-result.md`
✅ **差异摘要生成** → `active/李女士-张小姐/insign/difference-summary.md`
✅ **客户摘要更新** → 签单中状态已改为"✅ 已完成"
✅ **客户索引更新** → 签单中状态从"○"改为"✅"
✅ **统计信息更新** → 签单中阶段数量从0改为1

---

**签单中阶段已完成，现在进入签单后阶段。**

**签单后阶段** - 缴费页面生成与归档管理

这个阶段需要生成缴费信息页面，并准备归档。根据您提供的信息，客户已通过银行转账完成首期保费支付。

**请问：**
是否需要我为李女士、张小姐生成缴费信息页面？这包括：
1. 缴费金额明细
2. 银行账户信息
3. 缴费截止日期
4. 缴费凭证上传指引

请确认是否开始签单后阶段的流程。
```

### Key Elements
1. **Phase completion marker**: Clear "[签单中] 进度 5/5 已完成"
2. **Checklist of completed items**: ✅ with file paths
3. **Phase transition separator**: `---` line
4. **Next phase announcement**: "现在进入签单后阶段"
5. **Next phase description**: Brief overview of what's involved
6. **Specific question**: What information is needed to proceed
7. **Call to action**: Request confirmation to start next phase

## Push Frequency Control

### User Preference
"下次不要重复发这么多次" - User wants to avoid repeated pushes

### Implementation Guidelines
1. **Single Push per Action**: Each completed action should result in exactly one push
2. **Consolidated Updates**: Group related updates into single messages when possible
3. **Avoid Redundancy**: Don't push the same information multiple times
4. **Clear Completion**: Use ✅ emoji to indicate completion without additional explanation

### Example: Correct vs Incorrect
**Incorrect (repetitive):**
```
已推送行程图片
文件路径: /path/to/itinerary.png
已推送行程图片到签单群
```

**Correct (single push):**
```
✅ 行程图片已推送至签单群
```

## Session Learnings Summary

### Key User Preferences Identified
1. **Proactive guidance**: Don't wait for user to ask "what's next"
2. **Single pushes**: Avoid repetitive messages
3. **Test mode support**: Allow temporary cronjob modifications for testing
4. **Client name handling**: Support multi-person clients with commas

### Implementation Requirements
1. All agents must implement phase transition guidance
2. File path sanitization for multi-person clients
3. Test mode protocol for cronjob testing
4. Push frequency control to avoid repetition