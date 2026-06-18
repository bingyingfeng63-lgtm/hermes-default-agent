# Main Orchestrator: signing-followup

## Original Skill Content

This file contains the detailed implementation of the main orchestrator skill that was previously `signing-followup`.

## Overview

**signing-followup** is the main controller that orchestrates the signing follow-up workflow. It monitors events, activates triggers, and delegates tasks to sub-agents (presign-agent, insign-agent, postsign-agent).

## Event-Driven Architecture

### Three Trigger Points

| Trigger | Condition | Action |
|---------|-----------|--------|
| **Trigger 1** | Order confirmation received | → presign-agent (pre-signing) |
| **Trigger 2** | Day before signing | → presign-agent (reminders) |
| **Trigger 3** | Signing day or after signing | → insign-agent (in-signing) → postsign-agent (post-signing) |

### Event Monitoring

The orchestrator continuously monitors for:
1. New order confirmations in the system
2. Date-based triggers (day before signing)
3. Signing completion events

## Workflow Coordination

### State Management

The orchestrator maintains workflow state including:
- Client identification
- Current phase (pre-signing, in-signing, post-signing)
- Sub-agent execution status
- Error states and recovery points

### Agent Delegation

```python
# Pseudo-code for agent delegation
def handle_trigger(trigger_type, client_data):
    if trigger_type == "order_confirmation":
        delegate_to(presign_agent, client_data, phase="pre-signing")
    elif trigger_type == "day_before_signing":
        delegate_to(presign_agent, client_data, phase="reminders")
    elif trigger_type == "signing_day":
        result = delegate_to(insign_agent, client_data)
        if result.success:
            delegate_to(postsign_agent, result.data)
```

## Error Handling and Recovery

### Common Error Scenarios

1. **Sub-agent failure**: Retry with exponential backoff
2. **Missing client data**: Fall back to manual data entry
3. **Network issues**: Queue tasks for later execution
4. **File system errors**: Verify permissions and retry

### Recovery Procedures

```bash
# Recovery workflow
1. Identify failed component
2. Check error logs
3. Determine retry strategy
4. Execute recovery
5. Verify recovery success
6. Resume normal operation
```

## Configuration

### Environment Variables

```bash
# Required configuration
export SIGNING_DATA_DIR="$HOME/.hermes/data"
export ACTIVE_CLIENTS_DIR="$SIGNING_DATA_DIR/active"
export ARCHIVE_CLIENTS_DIR="$SIGNING_DATA_DIR/archive"
export LOG_DIR="$HOME/.hermes/logs/signing"
```

### File Paths

```bash
# Key file paths
CLIENT_INDEX="$ACTIVE_CLIENTS_DIR/CLIENT-INDEX.md"
ARCHIVE_INDEX="$ARCHIVE_CLIENTS_DIR/CLIENT-INDEX.md"
SUMMARY_TEMPLATE="$ACTIVE_CLIENTS_DIR/_CLIENT-SUMMARY-TEMPLATE.md"
```

## Monitoring and Logging

### Log Structure

```
[YYYY-MM-DD HH:MM:SS] [TRIGGER] [CLIENT] [AGENT] [STATUS] [DETAILS]
```

### Example Log Entry

```
[2026-05-20 14:30:00] [ORDER_CONFIRMATION] [杨洪伟] [presign-agent] [STARTED] [Parsing order details]
[2026-05-20 14:31:00] [ORDER_CONFIRMATION] [杨洪伟] [presign-agent] [COMPLETED] [Itinerary generated: 2026-05-20 14:00 香港中环康乐广场8号]
```

## Integration Points

### With Sub-agents

1. **Data passing**: Client data, phase information, previous results
2. **Status reporting**: Completion status, errors, warnings
3. **Result validation**: Verify sub-agent outputs before proceeding

### With External Systems

1. **Order systems**: Receive order confirmations
2. **Calendar systems**: Date-based trigger monitoring
3. **Notification systems**: Send alerts and reminders

## Performance Optimization

### Caching Strategy

```python
# Cache frequently accessed data
client_cache = {}
index_cache = {}

def get_client_data(client_id):
    if client_id in client_cache:
        return client_cache[client_id]
    else:
        data = load_from_disk(client_id)
        client_cache[client_id] = data
        return data
```

### Batch Processing

For multiple clients, batch operations where possible:
- Batch index updates
- Batch file operations
- Batch notifications

## Testing

### Unit Tests

```python
def test_trigger_handling():
    # Test order confirmation trigger
    result = handle_trigger("order_confirmation", test_client_data)
    assert result.agent == "presign-agent"
    assert result.phase == "pre-signing"
    
def test_error_recovery():
    # Test recovery from sub-agent failure
    simulate_agent_failure()
    result = handle_trigger("order_confirmation", test_client_data)
    assert result.status == "recovered"
```

### Integration Tests

```bash
# Full workflow test
./test-signing-workflow.sh \
    --client "测试客户" \
    --policy "储蓄分红险" \
    --amount "USD 50,000" \
    --date "2026-05-20"
```

## Maintenance

### Daily Tasks

1. Check error logs
2. Verify index consistency
3. Monitor trigger queues
4. Review performance metrics

### Weekly Tasks

1. Clean up old logs
2. Update configuration if needed
3. Review and update templates
4. Backup critical data

### Monthly Tasks

1. Performance review
2. Security audit
3. Update dependencies
4. Archive old data

## Troubleshooting

### Common Issues

**Issue**: Triggers not firing
**Solution**: Check event monitoring configuration, verify date/time settings

**Issue**: Sub-agents not responding
**Solution**: Verify agent availability, check network connectivity

**Issue**: Index inconsistencies
**Solution**: Run index validation script, manual repair if needed

### Debug Commands

```bash
# Check orchestrator status
hermes status signing-workflow

# View recent logs
tail -f $LOG_DIR/orchestrator.log

# Test trigger manually
hermes trigger order-confirmation --client "测试客户"
```

## Migration Notes

This content was migrated from the standalone `signing-followup` skill as part of the umbrella consolidation. All functionality remains intact, now organized under the comprehensive `signing-workflow-system` umbrella.