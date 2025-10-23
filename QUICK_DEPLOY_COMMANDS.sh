#!/bin/bash

# ============================================
# ANONYMOUS CREDITS FIX - QUICK DEPLOY SCRIPT
# ============================================
# 
# This script helps deploy the anonymous credits bug fix
# Run each section manually and verify before proceeding
#

set -e  # Exit on error

echo "🚀 Anonymous Credits Bug Fix - Deployment Script"
echo "================================================"
echo ""

# ============================================
# PHASE 1: BACKEND DEPLOYMENT
# ============================================

echo "📋 PHASE 1: Backend Deployment (Supabase)"
echo "=========================================="
echo ""

# Check if in correct directory
if [ ! -d "supabase" ]; then
    echo "❌ Error: supabase/ directory not found"
    echo "Please run this script from project root: /Users/jans./Downloads/BananaUniverse"
    exit 1
fi

# Check if Supabase CLI is installed
if ! command -v npx &> /dev/null; then
    echo "❌ Error: npx not found. Please install Node.js and npm"
    exit 1
fi

echo "✅ Prerequisites check passed"
echo ""

# Prompt for project ref
read -p "Enter your Supabase project ref (or press Enter to skip linking): " PROJECT_REF

if [ ! -z "$PROJECT_REF" ]; then
    echo "🔗 Linking to Supabase project..."
    npx supabase link --project-ref $PROJECT_REF
    echo ""
fi

# Show migration status
echo "📊 Current migration status:"
npx supabase migration list
echo ""

# Apply migrations
read -p "Apply migration 016_add_self_healing_quota_validation.sql? (y/n): " APPLY_MIGRATION

if [ "$APPLY_MIGRATION" = "y" ]; then
    echo "🔄 Applying database migration..."
    npx supabase db push
    echo "✅ Migration applied successfully"
    echo ""
else
    echo "⚠️  Skipped migration. Deploy manually when ready."
    echo ""
fi

# Test database functions
read -p "Test database functions? (y/n): " TEST_DB

if [ "$TEST_DB" = "y" ]; then
    echo "🧪 Testing validate_anonymous_daily_quota()..."
    npx supabase db execute "SELECT validate_anonymous_daily_quota('test-deploy-check', false);"
    
    echo ""
    echo "🧹 Cleaning up test data..."
    npx supabase db execute "DELETE FROM anonymous_credits WHERE device_id = 'test-deploy-check';"
    echo "✅ Database functions working correctly"
    echo ""
fi

# Deploy Edge Function (optional)
read -p "Deploy process-image Edge Function? (y/n): " DEPLOY_EDGE

if [ "$DEPLOY_EDGE" = "y" ]; then
    echo "📤 Deploying Edge Function..."
    npx supabase functions deploy process-image
    echo "✅ Edge Function deployed"
    echo ""
else
    echo "⚠️  Skipped Edge Function deployment (optional - only logging changes)"
    echo ""
fi

echo "✅ Backend deployment complete!"
echo ""

# ============================================
# PHASE 2: IOS DEPLOYMENT CHECKLIST
# ============================================

echo "📋 PHASE 2: iOS Deployment"
echo "=========================="
echo ""
echo "Manual steps required:"
echo ""
echo "1. Open Xcode: BananaUniverse.xcodeproj"
echo "2. Delete app from simulator (test fresh install)"
echo "3. Build and Run (⌘R)"
echo "4. Check console for:"
echo "   ✅ New user - starting with 10 free credits"
echo "   ⚠️ Backend record will be auto-created on first Generate"
echo ""
echo "5. Archive build (Product → Archive)"
echo "6. Upload to TestFlight"
echo "7. Test on iPhone 16 (fresh install)"
echo ""

read -p "iOS deployment completed successfully? (y/n): " IOS_DONE

if [ "$IOS_DONE" = "y" ]; then
    echo "✅ iOS deployment complete!"
else
    echo "⚠️  Complete iOS deployment before testing"
fi

echo ""

# ============================================
# PHASE 3: TESTING
# ============================================

echo "📋 PHASE 3: Testing Checklist"
echo "============================="
echo ""
echo "Test the following scenarios:"
echo ""
echo "□ Test Case 1: Brand new anonymous user (iPhone 16)"
echo "  - Fresh TestFlight install"
echo "  - Launch app → See 10 credits"
echo "  - Generate image → ✅ Should succeed"
echo "  - Check Supabase logs for self-healing message"
echo ""
echo "□ Test Case 2: Existing anonymous user"
echo "  - User with existing credit record"
echo "  - Generate image → ✅ Should work as before"
echo "  - No self-healing messages (record exists)"
echo ""
echo "□ Test Case 3: New Apple Sign-In user"
echo "  - Fresh install + Apple authentication"
echo "  - Generate image → ✅ Should succeed"
echo "  - Backend auto-creates user_credits record"
echo ""
echo "□ Test Case 4: Offline → Online"
echo "  - Airplane mode ON → Launch app"
echo "  - See local credits (10)"
echo "  - Enable internet → Generate → ✅ Success"
echo ""

read -p "All test cases passed? (y/n): " TESTS_PASSED

echo ""

# ============================================
# PHASE 4: MONITORING
# ============================================

echo "📋 PHASE 4: Monitoring Setup"
echo "============================"
echo ""
echo "Monitor Supabase logs for:"
echo ""
echo "✅ Expected logs:"
echo "   [STEVE-JOBS] Quota validation passed"
echo "   🔧 [STEVE-JOBS] Self-healed missing record for..."
echo "   ✅ [STEVE-JOBS] Credit consumed successfully"
echo ""
echo "❌ Should NOT see:"
echo "   ❌ [STEVE-JOBS] Quota validation failed: record not found"
echo ""
echo "Run this SQL query to check for issues:"
echo ""
echo "SELECT * FROM postgres_logs"
echo "WHERE message LIKE '%record not found%'"
echo "AND created_at > NOW() - INTERVAL '24 hours';"
echo ""

# ============================================
# SUMMARY
# ============================================

echo ""
echo "================================================"
echo "🎉 DEPLOYMENT SUMMARY"
echo "================================================"
echo ""

if [ "$APPLY_MIGRATION" = "y" ] && [ "$IOS_DONE" = "y" ] && [ "$TESTS_PASSED" = "y" ]; then
    echo "✅ Backend migration applied"
    echo "✅ iOS app deployed to TestFlight"
    echo "✅ All test cases passed"
    echo ""
    echo "🎯 Deployment Status: SUCCESS ✅"
    echo ""
    echo "Next steps:"
    echo "1. Monitor Supabase logs for 24 hours"
    echo "2. Check for 'record not found' errors (should be zero)"
    echo "3. Verify self-healing events in logs"
    echo "4. Collect TestFlight feedback from users"
    echo ""
else
    echo "⚠️  Deployment Status: INCOMPLETE"
    echo ""
    echo "Completed:"
    [ "$APPLY_MIGRATION" = "y" ] && echo "  ✅ Backend migration" || echo "  ⏳ Backend migration"
    [ "$IOS_DONE" = "y" ] && echo "  ✅ iOS deployment" || echo "  ⏳ iOS deployment"
    [ "$TESTS_PASSED" = "y" ] && echo "  ✅ Testing" || echo "  ⏳ Testing"
    echo ""
    echo "Please complete remaining steps before production deployment."
fi

echo ""
echo "📚 Documentation:"
echo "  - ANONYMOUS_CREDITS_FIX_DEPLOYMENT.md - Full deployment guide"
echo "  - ANONYMOUS_CREDITS_BUG_FIX_SUMMARY.md - Technical details"
echo ""
echo "================================================"
echo ""

# Save deployment info
DEPLOY_DATE=$(date "+%Y-%m-%d %H:%M:%S")
echo "Deployment attempted at: $DEPLOY_DATE" >> deployment_log.txt
echo "Backend: $APPLY_MIGRATION, iOS: $IOS_DONE, Tests: $TESTS_PASSED" >> deployment_log.txt
echo ""

echo "✅ Deployment log saved to deployment_log.txt"
echo ""

