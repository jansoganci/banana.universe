# FakePaywall Migration Technical Plan

## Overview

This document outlines the technical migration from Adapty-based paywall system to a mock paywall system for App Store submission compliance. Apple requires the first subscription to be submitted together with a new app version before any live in-app purchases can load, making this migration necessary for App Store approval.

### Why This Migration Is Happening

- **Apple Policy Compliance**: First subscription must be submitted with new app version
- **App Store Review Requirements**: Reviewers need working purchase flow, not broken Adapty errors
- **Development Safety**: Maintain working app functionality during review process
- **Reversible Design**: Easy rollback to live Adapty system post-approval

### Migration Goals

1. **Disable Adapty Dependencies**: Remove all live Adapty calls temporarily
2. **Enable Mock Paywall**: Show functional PreviewPaywallView instead of broken PaywallView
3. **Maintain Functionality**: Keep credit system and user experience working
4. **Ensure Build Success**: Compile without Adapty dependencies
5. **Prepare for Rollback**: Easy restoration to live system post-approval

---

## Phase Breakdown

### Phase 1: Safe Deprecation (Low Risk)
**Goal**: Move Adapty files to deprecated folder and comment out imports
**Risk Level**: Low
**Estimated Time**: 15 minutes

### Phase 2: Mock Fallbacks (Medium Risk)
**Goal**: Add mock implementations for critical Adapty dependencies
**Risk Level**: Medium
**Estimated Time**: 45 minutes

### Phase 3: Testing (Critical)
**Goal**: Verify build success and PreviewPaywallView functionality
**Risk Level**: High (if build fails)
**Estimated Time**: 30 minutes

---

## File-by-File Migration Plan

---

## 1. AdaptyService.swift
**Status**: ENTIRE FILE TO BE DEPRECATED
**Dependencies**: 15 Adapty calls
**Action**: Move to `/deprecated/` folder

### File Purpose
Core Adapty integration service handling paywall loading, purchases, and user identification.

### Lines / Functions Affected
- **Lines 9, 15-17**: Import and type declarations
- **Lines 26-48**: Initialization logic
- **Lines 51-73**: Paywall loading
- **Lines 76-98**: Purchase flow
- **Lines 100-121**: Restore purchases
- **Lines 124-148**: Subscription status
- **Lines 160-172**: Analytics tracking
- **Lines 175-201**: User identification

### Problem Description
Entire file depends on Adapty SDK and will cause compilation errors when Adapty is removed.

### Replacement Code Snippet
```swift
// FILE MOVED TO /deprecated/AdaptyService.swift
// This file is temporarily deprecated for App Store submission
// Will be restored post-approval
```

### Reason for Change
File contains all Adapty SDK dependencies and is not needed for mock paywall functionality.

---

## 2. HybridCreditManager.swift
**Status**: REQUIRES MOCK FALLBACKS
**Dependencies**: 6 AdaptyService calls
**Action**: Add mock implementations

### File Purpose
Manages user credits and premium status, integrates with Adapty for purchase processing.

### Lines / Functions Affected

#### Line 11: Import Statement
```swift
import Adapty
```
**Problem**: Compilation error when Adapty is removed
**Replacement**:
```swift
// import Adapty
```

#### Line 217: Premium Status Check
```swift
let newPremiumStatus = AdaptyService.shared.isProUser
```
**Problem**: AdaptyService.shared will not exist
**Replacement**:
```swift
private func updatePremiumStatus() {
    // Mock premium status - always false for App Review
    let newPremiumStatus = false // AdaptyService.shared.isProUser
    if isPremiumUser != newPremiumStatus {
        isPremiumUser = newPremiumStatus
        saveDailyQuota()
    }
}
```

#### Line 228: Restore Purchases
```swift
_ = try await AdaptyService.shared.restorePurchases()
```
**Problem**: AdaptyService.shared will not exist
**Replacement**:
```swift
private func refreshPremiumStatus() async {
    do {
        // Mock restore - always succeeds
        // _ = try await AdaptyService.shared.restorePurchases()
        updatePremiumStatus()
    } catch {
        updatePremiumStatus()
    }
}
```

#### Line 449: Purchase Function Signature
```swift
func purchaseCredits(product: AdaptyPaywallProduct) async throws
```
**Problem**: AdaptyPaywallProduct type will not exist
**Replacement**:
```swift
// Mock product type for compilation
struct MockAdaptyProduct {
    let vendorProductId: String
    let localizedPrice: String?
}

func purchaseCredits(product: MockAdaptyProduct) async throws {
    isLoading = true
    errorMessage = nil
    
    do {
        // Mock purchase - always succeeds
        let creditAmount = getCreditAmount(from: product)
        try await addCredits(creditAmount, source: .purchase)
        trackPurchase(product: product)
        isLoading = false
    } catch {
        errorMessage = "Purchase failed"
        isLoading = false
        throw error
    }
}
```

#### Line 515: Profile Calculation Function
```swift
private func calculateCreditsFromProfile(_ profile: AdaptyProfile) async throws -> Int
```
**Problem**: AdaptyProfile type will not exist
**Replacement**:
```swift
// Mock profile type
struct MockAdaptyProfile {
    let accessLevels: [String: MockAccessLevel]
}

struct MockAccessLevel {
    let isActive: Bool
}

private func calculateCreditsFromProfile(_ profile: MockAdaptyProfile) async throws -> Int {
    if profile.accessLevels["pro"]?.isActive == true {
        return 9999
    }
    return credits
}
```

#### Line 476: Restore Purchases Function
```swift
let profile = try await AdaptyService.shared.restorePurchases()
```
**Problem**: AdaptyService.shared will not exist
**Replacement**:
```swift
func restorePurchases() async throws {
    isLoading = true
    errorMessage = nil
    
    do {
        // Mock restore - always succeeds
        let restoredCredits = credits // Keep current credits
        credits = restoredCredits
        
        // Save credits
        switch userState {
        case .anonymous(let deviceId):
            saveAnonymousCredits(deviceId: deviceId)
        case .authenticated(let user):
            try await saveAuthenticatedCredits(userId: user.id)
        }
        
        isLoading = false
    } catch {
        errorMessage = "Restore failed"
        isLoading = false
        throw error
    }
}
```

### Reason for Change
Credit system must continue working without Adapty dependencies for App Store submission.

---

## 3. HybridAuthService.swift
**Status**: REQUIRES MOCK FALLBACKS
**Dependencies**: 2 AdaptyService calls
**Action**: Add mock implementations

### File Purpose
Handles user authentication and links authenticated users to Adapty for purchase tracking.

### Lines / Functions Affected

#### Line 93: User Identification
```swift
try await AdaptyService.shared.identify(userId: user.id.uuidString)
```
**Problem**: AdaptyService.shared will not exist
**Replacement**:
```swift
// Identify user in Adapty for purchase tracking
do {
    // Mock identify - always succeeds
    // try await AdaptyService.shared.identify(userId: user.id.uuidString)
    print("Mock: User identified in Adapty")
} catch {
    // Adapty identification failed, but don't block authentication
    print("Mock: Adapty identification skipped")
}
```

#### Line 104: User Logout
```swift
try await AdaptyService.shared.logout()
```
**Problem**: AdaptyService.shared will not exist
**Replacement**:
```swift
do {
    // Mock logout - always succeeds
    // try await AdaptyService.shared.logout()
    print("Mock: User logged out from Adapty")
} catch {
    // Adapty logout failed, but don't block sign out
    print("Mock: Adapty logout skipped")
}
```

### Reason for Change
Authentication flow must continue working without Adapty dependencies.

---

## 4. ChatViewModel.swift
**Status**: REQUIRES MOCK FALLBACK
**Dependencies**: 1 AdaptyService reference
**Action**: Comment out reference

### File Purpose
Manages chat functionality and references AdaptyService for potential use.

### Lines / Functions Affected

#### Line 95: AdaptyService Reference
```swift
private let adaptyService = AdaptyService.shared
```
**Problem**: AdaptyService.shared will not exist
**Replacement**:
```swift
// private let adaptyService = AdaptyService.shared
```

### Reason for Change
Chat functionality must continue working without Adapty dependencies.

---

## 5. ContentView.swift
**Status**: REQUIRES MOCK FALLBACK
**Dependencies**: 2 AdaptyService calls
**Action**: Comment out references

### File Purpose
Main app container that initializes AdaptyService on app launch.

### Lines / Functions Affected

#### Line 15: AdaptyService Initialization
```swift
@StateObject private var adaptyService = AdaptyService.shared
```
**Problem**: AdaptyService.shared will not exist
**Replacement**:
```swift
// @StateObject private var adaptyService = AdaptyService.shared
```

#### Lines 68-74: AdaptyService Initialization
```swift
// Initialize AdaptyService after Adapty SDK is activated
Task {
    do {
        try await adaptyService.initialize()
    } catch {
    }
}
```
**Problem**: adaptyService will not exist
**Replacement**:
```swift
// Initialize AdaptyService after Adapty SDK is activated
Task {
    do {
        // Mock initialization - always succeeds
        // try await adaptyService.initialize()
        print("Mock: AdaptyService initialized")
    } catch {
        print("Mock: AdaptyService initialization skipped")
    }
}
```

### Reason for Change
App initialization must continue working without Adapty dependencies.

---

## 6. PaywallView.swift
**Status**: ENTIRE FILE TO BE DEPRECATED
**Dependencies**: 8 Adapty references
**Action**: Move to `/deprecated/` folder

### File Purpose
Real Adapty-based paywall view that will be replaced by PreviewPaywallView.

### Lines / Functions Affected
- **Line 9**: `import Adapty`
- **Line 12**: `@StateObject private var adaptyService = AdaptyService.shared`
- **Lines 17, 295, 353, 366, 408, 417, 426**: `AdaptyPaywallProduct` type usage

### Problem Description
Entire file depends on Adapty SDK and will cause compilation errors.

### Replacement Code Snippet
```swift
// FILE MOVED TO /deprecated/PaywallView.swift
// This file is temporarily deprecated for App Store submission
// Will be restored post-approval
```

### Reason for Change
File will be replaced by PreviewPaywallView for App Store submission.

---

## 7. BananaUniverseApp.swift
**Status**: REQUIRES MOCK FALLBACK
**Dependencies**: 2 Adapty calls
**Action**: Add mock implementations

### File Purpose
App entry point that initializes Adapty SDK on app launch.

### Lines / Functions Affected

#### Line 9: Import Statement
```swift
import Adapty
```
**Problem**: Compilation error when Adapty is removed
**Replacement**:
```swift
// import Adapty
```

#### Lines 15-21: Adapty Activation
```swift
Task {
    do {
        try await Adapty.activate("public_live_q60OFUaR.i63zkyyKSFCAKR0vkB9B")
    } catch {
    }
}
```
**Problem**: Adapty.activate will not exist
**Replacement**:
```swift
Task {
    do {
        // Mock Adapty activation - always succeeds
        // try await Adapty.activate("public_live_q60OFUaR.i63zkyyKSFCAKR0vkB9B")
        print("Mock: Adapty activated successfully")
    } catch {
        print("Mock: Adapty activation skipped")
    }
}
```

### Reason for Change
App initialization must continue working without Adapty dependencies.

---

## 8. MockPaywallData.swift
**Status**: MINOR CLEANUP REQUIRED
**Dependencies**: 1 unused import
**Action**: Comment out unused import

### File Purpose
Provides mock data for PreviewPaywallView functionality.

### Lines / Functions Affected

#### Line 10: Unused Import
```swift
import Adapty
```
**Problem**: Unused import causing compilation warning
**Replacement**:
```swift
// import Adapty
```

### Reason for Change
Remove unused import to clean up compilation warnings.

---

## 9. PreviewPaywallView Integration
**Status**: NEW FILE CREATION
**Dependencies**: None (standalone)
**Action**: Rename and integrate

### File Purpose
Mock paywall view for App Store submission that replaces PaywallView.

### Required Changes

#### File Rename
- **From**: `FakePaywallView.swift`
- **To**: `PreviewPaywallView.swift`

#### Component Renames
- **From**: `FakePaywallView`
- **To**: `PreviewPaywallView`
- **From**: `FakePaywallBenefitRow`
- **To**: `PreviewPaywallBenefitRow`
- **From**: `FakePaywallProductCard`
- **To**: `PreviewPaywallProductCard`

#### Integration Points
Update all paywall trigger points to use conditional logic:
```swift
.sheet(isPresented: $showPaywall) {
    if Config.useFakePaywall {
        PreviewPaywallView()
    } else {
        PaywallView()
    }
}
```

### Files Requiring Integration Updates
1. **ChatView.swift** (line 35)
2. **ProfileView.swift** (line 50)
3. **HomeView.swift** (line 63)
4. **ImageUpscalerView.swift** (line 269)

---

## 10. Config.swift Updates
**Status**: CONFIGURATION CHANGE
**Dependencies**: None
**Action**: Update configuration flag

### File Purpose
Central configuration file for app settings.

### Lines / Functions Affected

#### Line 28: Paywall Configuration
```swift
static let useTestPaywall = false // Always use Adapty now
```
**Problem**: Flag name doesn't match usage
**Replacement**:
```swift
static let useFakePaywall = true // Enable PreviewPaywall for App Review
```

### Reason for Change
Provide centralized toggle for switching between mock and real paywall.

---

## Rollback Plan

If any issues arise during migration, follow this rollback sequence:

### Immediate Rollback (If Build Fails)
1. **Restore AdaptyService.swift**
   ```bash
   mv BananaUniverse/Core/Services/deprecated/AdaptyService.swift BananaUniverse/Core/Services/
   ```

2. **Restore BananaUniverseApp.swift**
   ```bash
   mv BananaUniverse/App/deprecated/BananaUniverseApp.swift BananaUniverse/App/
   ```

3. **Restore PaywallView.swift**
   ```bash
   mv BananaUniverse/Features/Paywall/Views/deprecated/PaywallView.swift BananaUniverse/Features/Paywall/Views/
   ```

4. **Uncomment Adapty Imports**
   - Uncomment `import Adapty` in all files
   - Uncomment `AdaptyService.shared` references
   - Restore original function signatures

5. **Revert Config Change**
   ```swift
   static let useFakePaywall = false // Use real Adapty
   ```

### Partial Rollback (If PreviewPaywallView Issues)
1. **Revert Conditional Logic**
   ```swift
   .sheet(isPresented: $showPaywall) {
       PaywallView() // Always use real paywall
   }
   ```

2. **Rename Back to FakePaywallView**
   ```bash
   mv PreviewPaywallView.swift FakePaywallView.swift
   ```

### Complete Rollback (If Full Migration Issues)
1. **Delete deprecated folder**
   ```bash
   rm -rf BananaUniverse/Core/Services/deprecated/
   rm -rf BananaUniverse/App/deprecated/
   rm -rf BananaUniverse/Features/Paywall/Views/deprecated/
   ```

2. **Restore all original files**
3. **Revert all code changes**
4. **Remove PreviewPaywallView.swift**
5. **Restore original Config.swift**

### Verification After Rollback
1. **Build Success**: `xcodebuild -project BananaUniverse.xcodeproj -scheme BananaUniverse build`
2. **App Launch**: Verify app launches without crashes
3. **Paywall Access**: Test that PaywallView shows (even if broken)
4. **No Mock References**: Ensure no PreviewPaywallView references remain

---

## Success Criteria

### Phase 1 Success
- [ ] AdaptyService.swift moved to `/deprecated/`
- [ ] BananaUniverseApp.swift moved to `/deprecated/`
- [ ] PaywallView.swift moved to `/deprecated/`
- [ ] All Adapty imports commented out
- [ ] App builds successfully

### Phase 2 Success
- [ ] Mock types added to HybridCreditManager.swift
- [ ] Mock functions added to HybridAuthService.swift
- [ ] All AdaptyService references commented out
- [ ] PreviewPaywallView renamed and integrated
- [ ] Config.useFakePaywall = true
- [ ] App builds successfully

### Phase 3 Success
- [ ] PreviewPaywallView shows correctly
- [ ] Mock purchases work
- [ ] Credit system functions
- [ ] No Adapty dependencies in build
- [ ] App ready for App Store submission

---

## Risk Assessment

### Low Risk
- Moving files to `/deprecated/`
- Commenting out imports
- Renaming FakePaywallView

### Medium Risk
- Adding mock implementations
- Updating function signatures
- Conditional logic integration

### High Risk
- Build compilation failures
- Runtime crashes
- Functionality loss

### Mitigation Strategies
- **Incremental Changes**: Make one change at a time
- **Build Testing**: Build after each major change
- **Rollback Ready**: Keep original files accessible
- **Documentation**: Document every change made

---

## Post-Migration Actions

### After App Store Approval
1. **Restore Adapty Files**: Move files back from `/deprecated/`
2. **Uncomment Imports**: Restore all Adapty imports
3. **Update Config**: Set `useFakePaywall = false`
4. **Test Integration**: Verify Adapty works correctly
5. **Remove PreviewPaywallView**: Delete mock paywall files
6. **Clean Up**: Remove deprecated folder

### Long-term Maintenance
- Keep migration documentation for future reference
- Consider keeping PreviewPaywallView for testing purposes
- Maintain rollback procedures for future migrations

---

*This document serves as the technical blueprint for the FakePaywall migration. All changes should be implemented incrementally with build testing after each phase.*
