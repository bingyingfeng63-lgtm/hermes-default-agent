# Client Handling and Testing Lessons

## Session Summary
Date: 2026-05-29  
Client: 李女士、张小姐 (VIP)  
Key learnings from handling a multi-client VIP case with testing requirements.

## Key Learnings

### 1. Multi-Client Name Handling
**Problem**: Client names with commas and spaces cause file system issues  
**Solution**: Replace all problematic characters with hyphens  
**Example**: "李女士、张小姐" → "李女士-张小姐"  
**Rule**: Always sanitize client names before creating directories or files

### 2. User Communication Preferences
**User feedback**: "简单说说就行" (just say it simply)  
**Implication**: User prefers concise, actionable communication over verbose explanations  
**Action**: 
- Provide minimal explanations
- Focus on next steps
- Avoid technical details in user-facing messages
- Use simple completion formats

### 3. Step-by-Step Confirmation Pattern
**User pattern**: "先让我检查，检查完，再写入" (let me check first, after checking, then write)  
**Workflow**: 
1. Generate content
2. Show to user for review
3. Get confirmation
4. Write files
**Benefit**: Prevents errors and ensures user approval before committing changes

### 4. Push Notification Optimization
**User complaint**: "你又同时推送两张海报到群里，其实一张就够了" (you're pushing two posters to the group, actually one is enough)  
**Root cause**: Showing file paths in messages created confusion  
**Solution**: 
- Push only one clean PNG per action
- Use `MEDIA:` syntax without technical details
- Do not show file paths in WeCom messages
- Users only need visual content, not file locations

### 5. Test Mode Protocol
**User request**: "因为是测试工单，你能不能提前推送" (because it's a test order, can you push early)  
**Procedure**: 
1. Temporarily modify cronjob schedules (e.g., to `*/2 * * * *`)
2. Run cronjob immediately for verification
3. Check if push was successful
4. Immediately restore original schedules
5. Ensure each reminder type is pushed only once

### 6. Proactive Guidance
**Pattern observed**: After completing a phase, immediately prompt user for next steps  
**Benefit**: Keeps workflow moving without user having to ask "what's next"  
**Example**: After sign-in phase, say "签单中已完成，准备进入签单后阶段-缴费页面生成"

## Implementation Examples

### Example 1: Multi-Client Directory Creation
```bash
# Original client name: "李女士、张小姐"
# Sanitized name: "李女士-张小姐"
mkdir -p /home/anna/.hermes/data/active/李女士-张小姐/
```

### Example 2: Concise Phase Completion
**Before (verbose)**: 
```
[签单前] 进度 3/3
✓ 行程方案 → data/active/李女士-张小姐/presign/itinerary.md
✓ 提醒配置 → data/active/李女士-张小姐/presign/reminders.md
✓ 文档清单 → data/active/李女士-张小姐/presign/documents.md
```

**After (concise)**: 
```
✅ [签单前] 已完成
```

### Example 3: Test Mode Cronjob Handling
```bash
# Original schedule: 0 9 23 6 * (June 23, 9:00 AM)
# Test schedule: */2 * * * * (every 2 minutes)

# Modify for test
cronjob update --id abc123 --schedule "*/2 * * * *"

# Run test
cronjob run --id abc123

# Restore original
cronjob update --id abc123 --schedule "0 9 23 6 *"
```

## Best Practices

### File Management
1. **Sanitize names early**: Process client names at the beginning
2. **Consistent paths**: Use sanitized names throughout the workflow
3. **Clear separation**: Keep internal file management separate from user communication

### Communication
1. **Be concise**: "简单说说就行" means minimal explanations
2. **Show before write**: Follow the check-confirm-write pattern
3. **One push per action**: Avoid duplicate or multiple pushes
4. **Clean visuals**: Push PNGs without technical details

### Testing
1. **Temporary modifications**: Only modify schedules temporarily
2. **Immediate cleanup**: Restore original settings immediately after test
3. **Single execution**: Run test once, not repeatedly
4. **Clear documentation**: Note test vs production differences

## Common Pitfalls to Avoid

1. **Showing file paths in WeCom**: Users don't need to see file paths
2. **Multiple PNG pushes**: Push only one image per action
3. **Forgetting to restore schedules**: Always clean up after testing
4. **Verbose explanations**: Keep messages short and actionable
5. **Not sanitizing names**: Always process client names for file system compatibility

## Verification Checklist

After handling a multi-client case:
- [ ] Client name sanitized correctly
- [ ] Directory structure created with sanitized name
- [ ] All files use consistent naming
- [ ] Push notifications are clean and single
- [ ] Test schedules restored if modified
- [ ] User communication is concise
- [ ] Step-by-step confirmation followed
- [ ] Proactive guidance provided for next steps