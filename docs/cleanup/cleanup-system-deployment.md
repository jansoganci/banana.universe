# 🧹 Cleanup System Deployment Guide

## Overview

The BananaUniverse cleanup system provides automated image and database cleanup to:
- **Reduce storage costs** by deleting old images
- **Maintain privacy** by removing user data after retention periods
- **Improve performance** by cleaning up old database records
- **Ensure compliance** with data retention policies

## System Components

### 1. Edge Function: `cleanup-images`
- **Purpose:** Deletes images from Supabase Storage
- **Retention:** Free users (24h), PRO users (14 days)
- **Safety:** Only processes completed/failed jobs

### 2. SQL Functions & Cron Jobs
- **`cleanup_old_jobs()`:** Deletes job records (30 days)
- **`cleanup_rate_limiting_data()`:** Deletes rate limit data (30 days)
- **`cleanup_cleanup_logs()`:** Deletes old audit logs (180 days)

### 3. Audit & Monitoring
- **`cleanup_logs` table:** Tracks all cleanup operations
- **`cleanup_monitoring` view:** Real-time monitoring
- **`get_cleanup_stats()` function:** Historical statistics

## Deployment Steps

### Step 1: Configure Environment Variables

```bash
# Set the required API key for authentication
supabase secrets set CLEANUP_API_KEY=your-secure-api-key-here

# Set Telegram credentials (optional)
supabase secrets set TELEGRAM_BOT_TOKEN=your-bot-token
supabase secrets set TELEGRAM_CHAT_ID=your-chat-id

# Verify secrets are set
supabase secrets list
```

### Step 2: Deploy Edge Functions

```bash
# Deploy the cleanup-images Edge Function
supabase functions deploy cleanup-images

# Deploy the cleanup-db Edge Function
supabase functions deploy cleanup-db

# Verify deployment
supabase functions list
```

### Step 3: Run Database Migration

```bash
# Apply the cleanup migration
supabase db push

# Verify migration
supabase db diff
```

### Step 4: Test the System

```bash
# Run the test script
deno run --allow-net supabase/functions/cleanup-images/test-cleanup.ts

# Test image cleanup Edge Function (with API key)
curl -X POST https://your-project.supabase.co/functions/v1/cleanup-images \
  -H "x-api-key: your-secure-api-key-here" \
  -H "Content-Type: application/json"

# Test database cleanup Edge Function (with API key)
curl -X POST https://your-project.supabase.co/functions/v1/cleanup-db \
  -H "x-api-key: your-secure-api-key-here" \
  -H "Content-Type: application/json"
```

### Step 5: Set Up External Cron Jobs

Since Supabase doesn't support `pg_cron`, use external cron services:

#### Option A: GitHub Actions (Recommended)
```yaml
# .github/workflows/cleanup.yml
name: Database Cleanup
on:
  schedule:
    - cron: '0 3 * * *'  # Daily at 3 AM UTC
jobs:
  cleanup:
    runs-on: ubuntu-latest
    steps:
      - name: Cleanup Images
        run: |
          curl -X POST ${{ secrets.SUPABASE_URL }}/functions/v1/cleanup-images \
            -H "x-api-key: ${{ secrets.CLEANUP_API_KEY }}"
      
      - name: Cleanup Database
        run: |
          curl -X POST ${{ secrets.SUPABASE_URL }}/functions/v1/cleanup-db \
            -H "x-api-key: ${{ secrets.CLEANUP_API_KEY }}"
```

#### Option B: Vercel Cron
```javascript
// api/cleanup.js
export default async function handler(req, res) {
  const response = await fetch(`${process.env.SUPABASE_URL}/functions/v1/cleanup-images`, {
    method: 'POST',
    headers: {
      'x-api-key': process.env.CLEANUP_API_KEY,
      'Content-Type': 'application/json'
    }
  });
  
  res.status(200).json({ success: true });
}
```

### Step 6: Verify System

```sql
-- Check cleanup logs
SELECT * FROM cleanup_logs ORDER BY created_at DESC LIMIT 10;

-- Check monitoring view
SELECT * FROM cleanup_monitoring;
```

## Configuration

### Retention Periods

| Data Type | Free Users | PRO Users | Database Records |
|-----------|------------|-----------|------------------|
| Images | 24 hours | 14 days | 30 days |
| Rate Limiting | - | - | 30 days |
| Audit Logs | - | - | 180 days |

### Cron Schedule

| Job | Schedule | Description |
|-----|----------|-------------|
| `cleanup-old-jobs` | `0 3 * * *` | Daily at 3 AM UTC |
| `cleanup-rate-limiting` | `0 4 * * *` | Daily at 4 AM UTC |
| `cleanup-cleanup-logs` | `0 5 * * 0` | Weekly on Sunday at 5 AM UTC |

## Monitoring

### Real-time Monitoring

```sql
-- View current cleanup status
SELECT * FROM cleanup_monitoring;

-- Get detailed statistics
SELECT * FROM get_cleanup_stats(7); -- Last 7 days

-- Check recent cleanup operations
SELECT * FROM cleanup_logs 
WHERE created_at > NOW() - INTERVAL '24 hours'
ORDER BY created_at DESC;
```

### Alerts & Notifications

Set up monitoring for:
- **Cleanup failures** (error_count > 0)
- **Storage usage spikes** (unexpected growth)
- **Long execution times** (> 5 minutes)
- **Missing cron jobs** (no runs in 25+ hours)

## Safety Features

### 1. Exclusion Logic
- Only processes `completed` and `failed` jobs
- Skips jobs with `pending` or `processing` status
- Requires 24-hour safety buffer before deletion

### 2. Error Handling
- Comprehensive error logging
- Retry logic for failed operations
- Graceful degradation on errors

### 3. Audit Trail
- All operations logged to `cleanup_logs`
- Detailed execution metrics
- Error tracking and reporting

## Troubleshooting

### Common Issues

#### 1. Edge Function Not Deploying
```bash
# Check function logs
supabase functions logs cleanup-images

# Verify environment variables
supabase secrets list
```

#### 2. Cron Jobs Not Running
```sql
-- Check if pg_cron is enabled
SELECT * FROM pg_extension WHERE extname = 'pg_cron';

-- Manually trigger cleanup
SELECT cleanup_old_jobs();
```

#### 3. Permission Errors
```sql
-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION cleanup_old_jobs() TO service_role;
GRANT EXECUTE ON FUNCTION cleanup_rate_limiting_data() TO service_role;
GRANT EXECUTE ON FUNCTION cleanup_cleanup_logs() TO service_role;
```

### Debug Commands

```sql
-- Check job distribution
SELECT 
  CASE 
    WHEN device_id IS NOT NULL THEN 'anonymous'
    WHEN user_id IS NOT NULL THEN 'authenticated'
    ELSE 'unknown'
  END as user_type,
  status,
  COUNT(*) as count
FROM jobs 
GROUP BY user_type, status;

-- Check storage usage
SELECT 
  bucket_id,
  COUNT(*) as file_count,
  SUM(metadata->>'size')::bigint as total_size
FROM storage.objects 
GROUP BY bucket_id;

-- Check cleanup effectiveness
SELECT 
  operation,
  COUNT(*) as runs,
  AVG((details->>'deleted_count')::int) as avg_deleted
FROM cleanup_logs 
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY operation;
```

## Performance Optimization

### 1. Database Indexes
Ensure these indexes exist for optimal performance:
```sql
-- Jobs table indexes
CREATE INDEX IF NOT EXISTS idx_jobs_status_created ON jobs(status, created_at);
CREATE INDEX IF NOT EXISTS idx_jobs_user_created ON jobs(user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_jobs_device_created ON jobs(device_id, created_at);

-- Cleanup logs indexes
CREATE INDEX IF NOT EXISTS idx_cleanup_logs_operation ON cleanup_logs(operation);
CREATE INDEX IF NOT EXISTS idx_cleanup_logs_created ON cleanup_logs(created_at);
```

### 2. Batch Processing
The Edge Function processes jobs in batches to avoid timeouts:
- Processes up to 100 jobs per batch
- Implements retry logic for failed deletions
- Logs progress for monitoring

### 3. Storage Optimization
- Uses efficient path extraction from URLs
- Implements parallel deletion where possible
- Tracks storage freed for monitoring

## Security Considerations

### 1. Access Control
- Edge Function requires service role key
- Database functions use `SECURITY DEFINER`
- RLS policies protect audit logs

### 2. Data Privacy
- Respects user subscription tiers
- Implements proper retention periods
- Logs sanitized for privacy

### 3. Audit Compliance
- Complete audit trail of all operations
- Detailed error logging
- Retention policy compliance

## Maintenance

### Weekly Tasks
- Review cleanup statistics
- Check for failed operations
- Monitor storage usage trends

### Monthly Tasks
- Analyze cleanup effectiveness
- Adjust retention periods if needed
- Review audit log retention

### Quarterly Tasks
- Full system health check
- Performance optimization review
- Security audit of cleanup processes

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review cleanup logs for error details
3. Contact the development team with specific error messages

## Changelog

### Version 1.0.0 (Initial Release)
- Basic image cleanup for free and PRO users
- Database cleanup functions
- Cron job scheduling
- Audit logging and monitoring
- Comprehensive error handling
- Safety mechanisms and exclusions
