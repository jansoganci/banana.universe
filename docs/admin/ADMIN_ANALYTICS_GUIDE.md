# 📊 **ADMIN ANALYTICS QUICK REFERENCE GUIDE**

## 🎯 **Overview**
This guide provides quick access to all admin analytics queries for monitoring your BananaUniverse credits system.

---

## 📈 **DAILY ANALYTICS QUERIES**

### **1. Daily Usage Summary**
```sql
-- Monitor daily credit consumption patterns
SELECT * FROM admin_daily_usage_summary 
WHERE usage_date >= CURRENT_DATE - INTERVAL '7 days';
```

### **2. System Health Check**
```sql
-- Daily system health indicators
SELECT * FROM admin_daily_system_check();
```

### **3. System Alerts**
```sql
-- Check for potential issues
SELECT * FROM admin_system_alerts();
```

---

## 📊 **WEEKLY ANALYTICS QUERIES**

### **4. Weekly Growth Trends**
```sql
-- Track weekly growth and trends
SELECT * FROM admin_weekly_trends 
WHERE week_start >= CURRENT_DATE - INTERVAL '8 weeks';
```

### **5. Growth Analysis**
```sql
-- Compare this week vs last week
SELECT * FROM admin_weekly_growth_analysis();
```

---

## 👥 **USER ANALYTICS QUERIES**

### **6. Top Credit Spenders**
```sql
-- Find your most active users
SELECT * FROM admin_top_spenders LIMIT 20;
```

### **7. User Retention Analysis**
```sql
-- Track user activation and retention
SELECT * FROM admin_user_retention 
WHERE signup_month >= CURRENT_DATE - INTERVAL '12 months';
```

### **8. Spending by User Type**
```sql
-- Compare free vs pro user spending
SELECT * FROM admin_spending_by_tier;
```

---

## 💰 **REVENUE ANALYTICS QUERIES**

### **9. Credit Purchase Analysis**
```sql
-- Track credit purchase patterns
SELECT * FROM admin_credit_sources;
```

### **10. Revenue Trends**
```sql
-- Monthly revenue analytics
SELECT * FROM admin_revenue_analytics 
WHERE month >= CURRENT_DATE - INTERVAL '6 months';
```

---

## 🔄 **QUOTA ANALYTICS QUERIES**

### **11. Daily Quota Usage**
```sql
-- Monitor quota consumption
SELECT * FROM admin_quota_usage_analysis 
WHERE quota_date >= CURRENT_DATE - INTERVAL '7 days';
```

### **12. User Type Comparison**
```sql
-- Compare anonymous vs authenticated usage
SELECT * FROM admin_user_type_comparison;
```

---

## 🏥 **SYSTEM HEALTH QUERIES**

### **13. Overall System Health**
```sql
-- Key system metrics
SELECT * FROM admin_system_health;
```

### **14. Performance Metrics**
```sql
-- Database performance and size
SELECT * FROM admin_performance_metrics();
```

---

## 📋 **QUICK DASHBOARD QUERIES**

### **Today's Summary**
```sql
-- Everything you need to know about today
SELECT 
    'Today''s Activity' as section,
    COUNT(DISTINCT user_id) as active_users,
    SUM(CASE WHEN amount < 0 THEN ABS(amount) ELSE 0 END) as credits_spent,
    COUNT(*) as total_transactions
FROM credit_transactions
WHERE DATE(created_at) = CURRENT_DATE;
```

### **This Week's Summary**
```sql
-- This week's key metrics
SELECT 
    'This Week' as period,
    COUNT(DISTINCT user_id) as active_users,
    SUM(CASE WHEN amount < 0 THEN ABS(amount) ELSE 0 END) as credits_spent,
    COUNT(CASE WHEN source = 'purchase' THEN 1 END) as purchases
FROM credit_transactions
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days';
```

### **Top 5 Users This Week**
```sql
-- Most active users this week
SELECT 
    uc.user_id,
    p.email,
    SUM(ABS(ct.amount)) as credits_spent,
    COUNT(*) as transactions
FROM credit_transactions ct
JOIN user_credits uc ON ct.user_id = uc.user_id
LEFT JOIN profiles p ON uc.user_id = p.id
WHERE ct.amount < 0 AND ct.created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY uc.user_id, p.email
ORDER BY credits_spent DESC
LIMIT 5;
```

---

## 🚨 **ALERT THRESHOLDS**

### **High Usage Alert**
- **Daily spending > 1000 credits**: Consider monitoring for abuse
- **Quota utilization > 80%**: Consider increasing limits
- **Active users < 10**: Consider promotional campaigns

### **Performance Alerts**
- **Table size > 1GB**: Consider archiving old data
- **Query time > 5 seconds**: Consider adding indexes

---

## 📅 **RECOMMENDED MONITORING SCHEDULE**

### **Daily (5 minutes)**
1. Run `admin_daily_system_check()`
2. Check `admin_system_alerts()`
3. Review `admin_daily_usage_summary` for today

### **Weekly (15 minutes)**
1. Run `admin_weekly_growth_analysis()`
2. Review `admin_top_spenders` for top 20 users
3. Check `admin_user_retention` trends

### **Monthly (30 minutes)**
1. Review `admin_revenue_analytics` for trends
2. Analyze `admin_performance_metrics()` for optimization
3. Check `admin_user_retention` for long-term trends

---

## 🔧 **CUSTOMIZATION TIPS**

### **Adjusting Thresholds**
- **High spending threshold**: Modify the 1000 credit limit in alerts
- **Low activity threshold**: Change the 10 user minimum in alerts
- **High balance threshold**: Adjust the 1000 credit limit for balance alerts

### **Adding Custom Metrics**
- Create new views following the same pattern
- Use `public.is_admin_user()` for security
- Grant permissions to `authenticated` role

---

## 📞 **SUPPORT**

If you need help with any of these queries or want to add custom analytics, refer to the migration files:
- `013_add_admin_access.sql` - Basic admin setup
- `014_admin_analytics_queries.sql` - Analytics views
- `015_admin_monitoring_queries.sql` - Monitoring functions

---

**Remember**: All admin access is backend-only and never exposed in the iOS app, ensuring full Apple App Store compliance! 🍎✅
