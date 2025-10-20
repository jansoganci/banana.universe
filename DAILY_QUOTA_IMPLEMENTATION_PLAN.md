# 🚀 Daily Quota System Implementation Plan

**Project:** BananaUniverse Credit System Refactor  
**Date:** 2025-01-27  
**Goal:** Implement daily quota system while preserving credit-based monetization  

## 📋 Overview

This plan implements a hybrid credit + daily quota system that:
- ✅ Maintains existing credit-based purchases
- ✅ Adds daily quota limits for non-premium users
- ✅ Provides unlimited access for premium users
- ✅ Preserves all existing functionality
- ✅ Includes backend validation to prevent abuse

---

## 🎯 Phase 1: HybridCreditManager Enhancement

### 1.1 Add Daily Quota Properties
- [x] Add `@Published var dailyQuotaUsed: Int = 0`
- [x] Add `@Published var dailyQuotaLimit: Int = 5`
- [x] Add `@Published var lastQuotaDate: String = ""`
- [x] Add `@Published var isPremiumUser: Bool = false`

### 1.2 Add Storage Keys
- [x] Add `private let dailyQuotaKey = "daily_quota_v1"`
- [x] Add `private let lastQuotaDateKey = "last_quota_date_v1"`
- [x] Add `private let premiumStatusKey = "premium_status_v1"`

### 1.3 Implement Daily Quota Management
- [x] Create `loadDailyQuota()` method
- [x] Create `saveDailyQuota()` method
- [x] Create `resetDailyQuotaIfNeeded()` method
- [x] Create `incrementDailyQuota()` method
- [x] Create `getLocalMidnightDate()` method
- [x] Create `isQuotaResetNeeded()` method

### 1.4 Enhance Credit Validation
- [x] Replace `hasCredits()` with `canProcessImage()`
- [x] Add premium user bypass logic
- [x] Add daily quota checking for non-premium users
- [x] Maintain backward compatibility with `hasCredits()`

### 1.5 Add Premium User Integration
- [x] Connect to `AdaptyService.shared.isProUser`
- [x] Update premium status on user state changes
- [x] Add premium status persistence
- [x] Handle premium status in credit validation

### 1.6 Add New Credit Consumption Method
- [x] Create `spendCreditWithQuota()` method
- [x] Combine credit spending with quota tracking
- [x] Handle premium user bypass
- [x] Maintain existing `spendCredit()` for compatibility

### 1.7 Add Computed Properties for UI
- [x] Add `var remainingQuota: Int`
- [x] Add `var hasQuotaLeft: Bool`
- [x] Add `var quotaDisplayText: String`
- [x] Add `var isQuotaUnlimited: Bool`

### 1.8 Update Initialization
- [x] Load daily quota on init
- [x] Check for quota reset on app launch
- [x] Update premium status on init
- [x] Add quota reset logging

---

## 🗄️ Phase 2: Database Schema Updates

### 2.1 Create Migration Script
- [x] Create `011_add_daily_quota_tracking.sql`
- [x] Add `daily_quota_used` column to `user_credits`
- [x] Add `daily_quota_limit` column to `user_credits`
- [x] Add `last_quota_reset` column to `user_credits`
- [x] Add same columns to `anonymous_credits` table

### 2.2 Add Indexes
- [x] Create index on `last_quota_reset` for performance
- [x] Add composite index for quota queries
- [x] Update existing indexes if needed

### 2.3 Create RPC Functions
- [x] Create `validate_daily_quota()` function
- [x] Add premium user bypass logic
- [x] Add timezone validation
- [x] Add quota reset functionality
- [x] Add audit logging

### 2.4 Update Edge Functions
- [x] Modify `process-image` function
- [x] Add daily quota validation
- [x] Add premium user bypass
- [x] Update credit consumption logic
- [x] Add quota tracking

---

## 🔧 Phase 3: SupabaseService Integration

### 3.1 Update Credit Validation
- [x] Replace `hasCredits()` calls with `canProcessImage()`
- [x] Update `processImageData()` method
- [x] Update `processImageDataV2()` method
- [x] Update `processImageSteveJobsStyle()` method

### 3.2 Update Credit Consumption
- [x] Replace `spendCredit()` with `spendCreditWithQuota()`
- [x] Update all processing methods
- [x] Add quota tracking to success paths
- [x] Update error handling

### 3.3 Add Quota Validation
- [x] Add backend quota validation calls
- [x] Handle quota exceeded errors
- [x] Add quota status to responses
- [x] Update error messages

---

## 🎨 Phase 4: UI Component Updates

### 4.1 Update UnifiedHeaderBar
- [x] Update quota badge display
- [x] Show different info for premium users
- [x] Add quota reset countdown
- [x] Update tap actions

### 4.2 Update ChatView
- [x] Replace quota logic with HybridCreditManager
- [x] Remove redundant quota properties
- [x] Update credit display
- [x] Add premium user indicators

### 4.3 Update ProfileView
- [x] Show quota usage for non-premium users
- [x] Show unlimited status for premium users
- [x] Add quota reset information
- [x] Update credit display

### 4.4 Update PaywallView
- [x] Add quota information to paywall
- [x] Show benefits of premium subscription
- [x] Update purchase flow
- [x] Add quota bypass messaging

### 4.5 Update Other Views
- [ ] Update ImageUpscalerView
- [ ] Update LibraryView
- [ ] Update any other credit displays
- [ ] Ensure consistent UI across app

---

## 🧪 Phase 5: Testing & Validation

### 5.1 Unit Tests
- [ ] Test daily quota management methods
- [ ] Test premium user integration
- [ ] Test quota reset logic
- [ ] Test credit validation changes
- [ ] Test timezone handling

### 5.2 Integration Tests
- [ ] Test HybridCreditManager with quota
- [ ] Test SupabaseService integration
- [ ] Test backend validation
- [ ] Test edge function updates

### 5.3 End-to-End Tests
- [ ] Test complete credit flow with quota
- [ ] Test premium user bypass
- [ ] Test quota reset at midnight
- [ ] Test quota exceeded scenarios
- [ ] Test migration from old system

### 5.4 Security Tests
- [ ] Test timezone manipulation attempts
- [ ] Test quota bypass attempts
- [ ] Test backend validation
- [ ] Test premium status manipulation

### 5.5 Performance Tests
- [ ] Test quota validation performance
- [ ] Test backend sync performance
- [ ] Test UI update performance
- [ ] Test memory usage

---

## 🚀 Phase 6: Deployment & Rollout

### 6.1 Pre-deployment
- [ ] Run full test suite
- [ ] Performance validation
- [ ] Security audit
- [ ] Code review
- [ ] Documentation update

### 6.2 Database Migration
- [ ] Run migration scripts
- [ ] Validate schema changes
- [ ] Test RPC functions
- [ ] Update edge functions

### 6.3 App Update
- [ ] Deploy new HybridCreditManager
- [ ] Update SupabaseService
- [ ] Update UI components
- [ ] Test in staging environment

### 6.4 Gradual Rollout
- [ ] Deploy to small user group
- [ ] Monitor quota usage
- [ ] Monitor performance
- [ ] Monitor error rates
- [ ] Full rollout after validation

---

## 📊 Success Metrics

### Functional Metrics
- [ ] Daily quota resets correctly at local midnight
- [ ] Premium users bypass quota restrictions
- [ ] Backend validation prevents quota manipulation
- [ ] Credit consumption works with quota tracking
- [ ] All existing functionality preserved

### Performance Metrics
- [ ] Quota validation adds <50ms to processing time
- [ ] Backend sync completes within 5 seconds
- [ ] UI updates reflect quota changes immediately
- [ ] No memory leaks or performance regressions

### Security Metrics
- [ ] Timezone manipulation attempts are blocked
- [ ] Backend validation catches all quota bypasses
- [ ] Premium status changes are secure
- [ ] No data corruption or loss

### User Experience Metrics
- [ ] UI clearly shows quota status
- [ ] Premium benefits are obvious
- [ ] Quota reset is transparent
- [ ] Error messages are helpful

---

## ⚠️ Risk Mitigation

### High Risk Items
- [ ] **Timezone Manipulation**: Implement server-side validation
- [ ] **Data Migration**: Preserve existing credit balances
- [ ] **Backend Sync**: Use eventual consistency model

### Medium Risk Items
- [ ] **Premium Status Sync**: Add real-time monitoring
- [ ] **Quota Reset Timing**: Use device local time consistently
- [ ] **UI Updates**: Comprehensive testing

### Low Risk Items
- [ ] **Display Inconsistencies**: Fallback display states
- [ ] **Performance Impact**: Monitor and optimize

---

## 📚 Documentation Updates

### Code Documentation
- [ ] Update HybridCreditManager documentation
- [ ] Add quota system documentation
- [ ] Update API documentation
- [ ] Add migration guide

### User Documentation
- [ ] Update app store description
- [ ] Update in-app help
- [ ] Update FAQ
- [ ] Update support documentation

---

## 🔄 Rollback Plan

### If Issues Arise
1. [ ] **Immediate**: Disable quota checking (keep credits only)
2. [ ] **Short-term**: Revert to legacy HybridCreditManager
3. [ ] **Long-term**: Fix issues and re-deploy

### Rollback Steps
- [ ] Restore legacy HybridCreditManager
- [ ] Update SupabaseService calls
- [ ] Revert UI changes
- [ ] Test rollback functionality

---

## 📝 Notes

### Implementation Order
1. **Phase 1** must be completed before Phase 2
2. **Phase 2** can be done in parallel with Phase 3
3. **Phase 4** depends on Phase 1 completion
4. **Phase 5** should run throughout all phases
6. **Phase 6** only after all previous phases pass

### Dependencies
- HybridCreditManager changes affect all other phases
- Database changes must be deployed before app updates
- UI changes depend on HybridCreditManager completion
- Testing should be continuous throughout

### Timeline Estimate
- **Phase 1**: 2-3 days
- **Phase 2**: 1-2 days  
- **Phase 3**: 1 day
- **Phase 4**: 2-3 days
- **Phase 5**: 2-3 days (parallel)
- **Phase 6**: 1-2 days
- **Total**: 7-10 days

---

**Status**: 🟡 Ready to Start  
**Next Action**: Begin Phase 1.1 - Add Daily Quota Properties  
**Last Updated**: 2025-01-27
