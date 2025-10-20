# HybridCreditManager Legacy Backup

This directory stores the original implementation of the credit-only version of the HybridCreditManager system.

## Overview

This is a frozen snapshot of the original `HybridCreditManager` class before the daily quota refactor was implemented. It preserves the pure credit-based monetization model for future reference and potential rollback scenarios.

## Archive Details

- **Archive Date:** 2025-01-27
- **Original File:** `BananaUniverse/Core/Services/HybridCreditManager.swift`
- **Legacy Class Name:** `HybridCreditManagerLegacy`
- **Purpose:** Preserve credit-only logic for future reference

## What's Preserved

### Core Functionality
- ✅ Anonymous user credit management
- ✅ Authenticated user credit management
- ✅ Credit consumption and addition
- ✅ Supabase backend synchronization
- ✅ Local storage fallback
- ✅ Adapty purchase integration
- ✅ User state migration (anonymous → authenticated)

### Key Features
- **Credit Storage:** Single `credits: Int` property
- **Validation:** Simple `hasCredits() -> Bool` method
- **Consumption:** `spendCredit()` method
- **Addition:** `addCredits()` method
- **Migration:** Seamless anonymous to authenticated transition

### Dependencies
- `SupabaseService` - Backend integration
- `AdaptyService` - Purchase handling
- `UserState` - User state management
- `Config` - Debug logging

## Usage

This legacy version can be used if you need to:

1. **Revert to credit-only model** - Remove daily quota restrictions
2. **Reference original implementation** - Understand the pure credit system
3. **Debug credit issues** - Compare with current implementation
4. **A/B testing** - Test different monetization models

## Integration Notes

To use this legacy version:

1. Replace `HybridCreditManager` with `HybridCreditManagerLegacy` in your code
2. Update all references to use the legacy class
3. Ensure all dependencies are available
4. Test thoroughly before deployment

## File Structure

```
Archive/LegacySystems/HybridCreditManager_v1/
├── HybridCreditManager_Legacy.swift    # Main legacy implementation
└── README.md                          # This documentation
```

## Technical Details

### Class Signature
```swift
@MainActor
class HybridCreditManagerLegacy: ObservableObject {
    static let shared = HybridCreditManagerLegacy()
    // ... rest of implementation
}
```

### Key Methods
- `hasCredits() -> Bool` - Check if user has credits
- `spendCredit() async throws -> Bool` - Consume one credit
- `addCredits(_:source:) async throws` - Add credits
- `migrateToAuthenticated(user:) async throws` - Migrate credits

### Storage Keys
- `hybrid_credits_v1` - Credit storage
- `device_uuid_v1` - Device identification
- `user_state_v1` - User state persistence

## Migration Path

If you need to restore this system:

1. **Backup current implementation** (if needed)
2. **Replace current HybridCreditManager** with this legacy version
3. **Update class name** from `HybridCreditManagerLegacy` to `HybridCreditManager`
4. **Test all credit flows** thoroughly
5. **Update UI components** to remove quota displays

## Support

This legacy implementation is preserved as-is and should work with the existing codebase. However, it does not include any daily quota functionality that may have been added in later versions.

For questions about this legacy system, refer to the original implementation or contact the development team.
