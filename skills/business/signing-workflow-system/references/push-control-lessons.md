# Push Control Lessons from User Feedback

## Critical User Feedback
1. **"你又同时推送两张海报到群里，其实一张就够了"** (2026-05-28)
   - **Issue**: Agent was pushing multiple files when only one PNG was needed
   - **Solution**: Push only one clean PNG file, not multiple files or file paths

2. **"下次不要重复发这么多次"** (2026-05-29)
   - **Issue**: Agent was sending repetitive/redundant messages
   - **Solution**: Each action should result in exactly one concise push message

3. **"因为是测试工单，你能不能提前推送"** (2026-05-29)
   - **Issue**: Need to test reminder functionality without waiting for actual dates
   - **Solution**: Support temporary cronjob modifications with immediate restoration

## Key Lessons Learned

### 1. File Generation vs Client Push
**Internal files** (for record-keeping):
- Generate HTML, PNG, and markdown files
- Store in organized client directory structure
- Update client indices and summaries

**Client push** (via WeCom):
- Push only **one clean PNG file**
- Use `MEDIA:` syntax without technical details
- **Never** show file paths in push messages
- Simple completion message: "✅ [阶段] 已完成"

### 2. Test Mode Protocol
When user requests testing:
1. **Temporary modification**: Change cronjob schedule to trigger in 2 minutes
2. **Single execution**: Run cronjob once immediately
3. **Immediate verification**: Check if push was successful
4. **Immediate restoration**: Restore original schedule immediately
5. **Avoid repetition**: Ensure each reminder type is pushed only once

### 3. WeCom Platform Limitations
- **No edit_message**: Cannot update/stream progress, each push is permanent
- **Media attachments**: Must use `MEDIA:` syntax in response body
- **File size limits**: Images up to 10MB, documents up to 20MB
- **No progress bars**: Must complete action before pushing

### 4. User Communication Style
- **Preference**: Concise, non-repetitive communication
- **Expectation**: One clear message per completed action
- **Frustration**: Multiple/redundant messages, technical file paths
- **Guidance**: After completing a phase, immediately prompt for next steps

## Implementation Rules

### Rule 1: Single Push Per Action
```bash
# ❌ WRONG - Multiple pushes
[签单前] 行程安排已生成 → /path/to/itinerary.md
[签单前] 行程图片已生成 → /path/to/itinerary.png
[签单前] 提醒配置已设置 → /path/to/reminders.md

# ✅ CORRECT - Single concise push
[签单前] 已完成
客户：李女士、张小姐
推送内容：行程安排海报
MEDIA:/path/to/itinerary.png
```

### Rule 2: Test Mode Cleanup
```bash
# Test workflow
1. cronjob update --job_id R2 --schedule "*/2 * * * *"
2. cronjob run --job_id R2
3. Verify push success
4. cronjob update --job_id R2 --schedule "0 9 23 6 *"  # IMMEDIATE RESTORATION
```

### Rule 3: File Path Sanitization
```bash
# Multi-person client name handling
Display name: "李女士、张小姐"  # With commas for user-facing content
File path: "李女士-张小姐"      # With hyphens for file system
```

## Common Pitfalls to Avoid

### Pitfall 1: Technical Details in User Messages
**Wrong**: "文件已保存到 /home/anna/.hermes/data/active/李女士-张小姐/presign/itinerary.png"
**Right**: "行程安排海报已生成" + MEDIA: syntax

### Pitfall 2: Leaving Test Schedules Active
**Wrong**: Modifying cronjob for test and forgetting to restore
**Right**: Immediate restoration after test verification

### Pitfall 3: Multiple PNG Pushes
**Wrong**: Pushing both HTML and PNG files
**Right**: Pushing only PNG, HTML is for internal use only

### Pitfall 4: MEDIA Buried in Text（2026-06-15 测试暴露）
**Wrong**: 
```
[文字内容...] + MEDIA:/path/to/payment.png + [更多文字 + 索引更新操作]
```
→ 图片被后续文字淹没，顾问看不到。

**Right**: 
```
MEDIA:/path/to/payment.png

简短说明（一行）
```
→ MEDIA 必须独占或优先出现，后续文字不超过一行。

### Pitfall 5: Technical Details After Bug Fix（2026-06-15 测试暴露）
**Wrong**: "Bug 原因：img 标签缺少 class='bg-image'，CSS 定位失效..."
**Right**: "已修复，你看下" + MEDIA 推送新图
→ 技术原因一句话带过，不展开讨论。

## Future Improvements

### 1. Push Confirmation System
- Add user confirmation before pushing
- Preview push content before sending
- Option to cancel/modify before final push

### 2. Test Mode Automation
- Automated test schedule management
- Test result verification
- Automatic cleanup after test

### 3. Push Analytics
- Track push success/failure rates
- Monitor user response patterns
- Optimize push timing and content

## Summary
The key insight from user feedback is: **Less is more**. Users prefer clean, concise, non-repetitive communication. Technical details belong in system logs, not in user-facing messages. Each completed action should result in exactly one well-crafted push message that clearly communicates what was accomplished and what comes next.