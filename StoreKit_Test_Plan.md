# StoreKit Test Plan for BananaUniverse

## Test Environment Setup
- Xcode 15.0+
- iOS Simulator with StoreKit Testing enabled
- StoreKit Configuration file: `BananaUniverse.storekit`
- Test products: `banana_weekly`, `banana_yearly`

## Test Scenarios

### 1. Success Scenario - Weekly Subscription
**Objective**: Verify successful purchase and proper success message display

**Steps**:
1. Launch app in iOS Simulator
2. Navigate to paywall (if not premium user)
3. Select "Weekly Pro" product
4. Tap "Unlock Premium" button
5. In StoreKit Testing, approve the purchase
6. Verify success alert appears: "Success! Welcome to Premium! You now have unlimited access to all features."
7. Verify paywall dismisses automatically
8. Verify premium status is updated in UI

**Expected Results**:
- ✅ Success alert only shows after transaction verification
- ✅ Paywall dismisses after successful purchase
- ✅ Premium status updates correctly
- ✅ User can access premium features

### 2. Success Scenario - Yearly Subscription
**Objective**: Verify successful yearly purchase

**Steps**:
1. Launch app in iOS Simulator
2. Navigate to paywall (if not premium user)
3. Select "Yearly Pro" product
4. Tap "Unlock Premium" button
5. In StoreKit Testing, approve the purchase
6. Verify success alert appears
7. Verify paywall dismisses automatically
8. Verify premium status is updated

**Expected Results**:
- ✅ Success alert only shows after transaction verification
- ✅ Yearly subscription properly recognized
- ✅ Premium status updates correctly

### 3. Cancel Scenario
**Objective**: Verify no success message when user cancels

**Steps**:
1. Launch app in iOS Simulator
2. Navigate to paywall
3. Select any product
4. Tap "Unlock Premium" button
5. In StoreKit Testing, cancel the purchase
6. Verify NO success alert appears
7. Verify paywall remains open
8. Verify user can try again

**Expected Results**:
- ❌ No success alert should appear
- ✅ Paywall remains open
- ✅ User can select different product and try again
- ✅ Loading state properly resets

### 4. Pending Scenario
**Objective**: Verify no success message for pending transactions

**Steps**:
1. Launch app in iOS Simulator
2. Navigate to paywall
3. Select any product
4. Tap "Unlock Premium" button
5. In StoreKit Testing, set transaction to "Pending" state
6. Verify NO success alert appears
7. Verify appropriate pending state handling

**Expected Results**:
- ❌ No success alert should appear
- ✅ Appropriate pending state handling
- ✅ User informed about pending status

### 5. Failure Scenario - Network Error
**Objective**: Verify proper error handling for network issues

**Steps**:
1. Launch app in iOS Simulator
2. Disable network connection
3. Navigate to paywall
4. Select any product
5. Tap "Unlock Premium" button
6. Verify error alert appears with retry option
7. Re-enable network and retry
8. Verify purchase succeeds

**Expected Results**:
- ❌ No success alert for failed purchase
- ✅ Clear error message about network issue
- ✅ Retry functionality works
- ✅ Success after retry

### 6. Failure Scenario - Payment Issue
**Objective**: Verify proper error handling for payment failures

**Steps**:
1. Launch app in iOS Simulator
2. Navigate to paywall
3. Select any product
4. Tap "Unlock Premium" button
5. In StoreKit Testing, simulate payment failure
6. Verify error alert appears with retry option
7. Verify retry functionality works

**Expected Results**:
- ❌ No success alert for failed purchase
- ✅ Clear error message about payment issue
- ✅ Retry functionality works

### 7. Restore Purchases Scenario
**Objective**: Verify restore purchases functionality

**Steps**:
1. Complete a successful purchase first
2. Delete and reinstall app (or reset simulator)
3. Launch app
4. Navigate to paywall
5. Tap "Restore Purchases"
6. Verify success alert appears
7. Verify premium status restored

**Expected Results**:
- ✅ Restore purchases works correctly
- ✅ Success alert only after verification
- ✅ Premium status properly restored

## StoreKit Testing Configuration

### Enable StoreKit Testing in Simulator:
1. Open Settings app in Simulator
2. Go to StoreKit Testing
3. Select "BananaUniverse.storekit" configuration
4. Enable "StoreKit Testing" toggle

### Test Transaction States:
- **Approved**: Transaction succeeds immediately
- **Pending**: Transaction requires approval
- **Failed**: Transaction fails with error
- **Cancelled**: User cancels the purchase

## Verification Points

### Success Message Criteria:
- ✅ Only shown after `transaction != nil` (verified and finished)
- ✅ Not shown for cancelled purchases
- ✅ Not shown for pending purchases
- ✅ Not shown for failed purchases
- ✅ Only shown after StoreKit verification

### Error Handling Criteria:
- ✅ Clear, user-friendly error messages
- ✅ Retry functionality for recoverable errors
- ✅ Proper loading states
- ✅ No false success messages

### Premium Status Updates:
- ✅ Updated immediately after successful purchase
- ✅ Persists across app launches
- ✅ Properly integrated with credit system
- ✅ UI reflects premium status correctly

## Test Results Summary

| Scenario | Success Alert | Error Handling | Premium Status | Notes |
|----------|---------------|----------------|----------------|-------|
| Weekly Success | ✅ Correct | N/A | ✅ Updated | |
| Yearly Success | ✅ Correct | N/A | ✅ Updated | |
| User Cancel | ❌ None | N/A | ❌ No change | |
| Pending | ❌ None | ✅ Handled | ❌ No change | |
| Network Error | ❌ None | ✅ Retry | ❌ No change | |
| Payment Error | ❌ None | ✅ Retry | ❌ No change | |
| Restore | ✅ Correct | N/A | ✅ Restored | |

## Notes
- All tests should be run in Debug mode with StoreKit Testing enabled
- Verify console logs for proper transaction verification messages
- Test both light and dark mode appearances
- Verify accessibility labels and hints work correctly
