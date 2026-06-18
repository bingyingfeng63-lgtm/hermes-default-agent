# Test Mode Procedures

## Overview

This document outlines procedures for testing the signing workflow system without affecting production schedules. Test mode allows temporary modifications to cronjob schedules and immediate execution of scheduled tasks.

## Use Cases

### 1. Testing Reminder Functionality
When a new client is added for testing purposes, you may need to:
- Test R2 (day-before) reminders immediately
- Test R3 (signing-day) reminders immediately  
- Verify reminder content and delivery

### 2. Testing Workflow Integration
- Test end-to-end workflow from pre-signing to post-signing
- Verify agent coordination and handoffs
- Test error handling and recovery

### 3. Testing New Features
- Test new template designs
- Test updated notification formats
- Test performance optimizations

## Procedures

### Modifying Cronjobs for Testing

#### Step 1: List Current Cronjobs
```bash
cronjob list
```

#### Step 2: Identify Target Job
Find the job ID for the reminder you want to test:
- R2 reminders: "签单提醒-{客户姓名}-R2"
- R3 reminders: "签单提醒-{客户姓名}-R3"

#### Step 3: Modify Schedule for Testing
Change from production schedule to test schedule:
```bash
# From production schedule (e.g., 0 9 23 6 * for June 23 09:00)
# To test schedule (every 2 minutes)
cronjob update --job_id JOB_ID --schedule "*/2 * * * *"
```

#### Step 4: Run Immediately
```bash
cronjob run --job_id JOB_ID
```

#### Step 5: Verify Results
Check WeCom messages for:
- Correct reminder content
- Proper formatting
- Timely delivery

### Restoring Production Schedules

#### Step 1: Restore Original Schedule
```bash
# Restore to original production schedule
cronjob update --job_id JOB_ID --schedule "0 9 23 6 *"
```

#### Step 2: Verify Next Run Time
```bash
cronjob list  # Check next_run_at field
```

## Example: Testing Client Reminders

### Scenario
Testing reminders for client "李女士、张小姐" with signing date 2026-06-24

### Steps
```bash
# 1. List cronjobs
cronjob list | grep "李女士、张小姐"

# 2. Get job IDs
# R2: 44b9e673d60c
# R3: a05d9caa99c1

# 3. Modify both for testing
cronjob update --job_id 44b9e673d60c --schedule "*/2 * * * *"
cronjob update --job_id a05d9caa99c1 --schedule "*/2 * * * *"

# 4. Run both immediately
cronjob run --job_id 44b9e673d60c
cronjob run --job_id a05d9caa99c1

# 5. Verify WeCom messages arrive

# 6. Restore production schedules
cronjob update --job_id 44b9e673d60c --schedule "0 9 23 6 *"
cronjob update --job_id a05d9caa99c1 --schedule "0 9 24 6 *"
```

## Safety Considerations

### 1. Temporary Changes Only
- Always restore original schedules after testing
- Document test schedule changes
- Set reminders to restore schedules

### 2. Client Data Protection
- Use test clients with dummy data when possible
- Avoid exposing real client information in test messages
- Clear test data after completion

### 3. System Impact
- Test during off-peak hours when possible
- Monitor system performance during tests
- Have rollback procedures ready

## Best Practices

### 1. Test Environment
Consider setting up a dedicated test environment with:
- Separate client directories (`data/test/` instead of `data/active/`)
- Test-specific cronjob naming conventions
- Isolated notification channels

### 2. Test Data Management
```bash
# Create test client structure
mkdir -p ~/.hermes/data/test/测试客户/
cp ~/.hermes/data/active/_CLIENT-SUMMARY-TEMPLATE.md ~/.hermes/data/test/测试客户/CLIENT-SUMMARY.md
```

### 3. Test Documentation
Document each test:
- Date and time
- Purpose of test
- Changes made
- Results observed
- Issues found and resolved

## Troubleshooting

### Issue: Cronjob Not Running
```bash
# Check cronjob status
cronjob list --filter JOB_ID

# Check if enabled
cronjob enable --job_id JOB_ID

# Check last run status
cronjob list --verbose
```

### Issue: Wrong Schedule
```bash
# Verify current schedule
cronjob list | grep JOB_ID

# Update to correct schedule
cronjob update --job_id JOB_ID --schedule "CORRECT_SCHEDULE"
```

### Issue: No WeCom Messages
1. Check WeCom bot is properly configured
2. Verify notification channel is working
3. Check message content isn't being filtered
4. Test with simple message first

## Integration with Development Workflow

### 1. Feature Development
When developing new features:
- Create test cases first
- Implement test mode procedures
- Test in isolation before integration

### 2. Code Changes
When making code changes:
- Test affected components
- Verify backward compatibility
- Update test procedures if needed

### 3. Deployment
Before deployment to production:
- Run comprehensive test suite
- Verify all test procedures work
- Document any changes to test procedures

## Related Documents

- [presign-agent-details.md](presign-agent-details.md) - Pre-signing agent implementation
- [image-designer-details.md](image-designer-details.md) - Image generation requirements
- [main-orchestrator-details.md](main-orchestrator-details.md) - System orchestration