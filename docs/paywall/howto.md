# Fake Paywall Setup & Testing Guide

## Overview

This guide explains how to use the fake paywall system for TestFlight submissions and App Store review. The system provides a realistic mock paywall that complies with Apple's In-App Purchase guidelines.

## Quick Start

### 1. Enable Fake Paywall

The fake paywall is automatically enabled in DEBUG builds. To manually control it:

```swift
// In Config.swift
static let useFakePaywall = true  // Enable fake paywall
static let useFakePaywall = false // Use real Adapty integration
```

### 2. Preview in SwiftUI

1. Open `FakePaywallView.swift` in Xcode
2. Use the preview panel to see different device sizes
3. Test both light and dark modes
4. Screenshot for App Store submissions

### 3. TestFlight Testing

1. Set `Config.useFakePaywall = true`
2. Build and upload to TestFlight
3. Test the complete purchase flow
4. Verify localization (English + Turkish)

## Detailed Setup

### Configuration

The fake paywall system uses these configuration flags:

```swift
// MARK: - Paywall Configuration
static let useFakePaywall = isDebug // Toggle for TestFlight/App Review
static let fakePaywallPlacementId = "test_paywall_review"
```

### File Structure

```
/BananaUniverse
  /Core
    /Config
      - Config.swift (updated with fake paywall flag)
    /Models
      - MockPaywallData.swift (mock product data)
    /Extensions
      - String+Localization.swift (localization helper)
  /Features
    /Paywall
      /Views
        - PaywallView.swift (updated with toggle)
        - FakePaywallView.swift (new fake paywall UI)
      /ViewModels
        - MockPaywallViewModel.swift (mock purchase logic)
  /Resources
    /Localizations
      /en.lproj
        - Localizable.strings (English strings)
      /tr.lproj
        - Localizable.strings (Turkish strings)
```

## Testing Procedures

### 1. SwiftUI Preview Testing

#### iPhone 14 Pro Max (6.7")
```swift
#Preview("iPhone 14 Pro Max") {
    FakePaywallView()
        .environmentObject(ThemeManager())
        .previewDevice("iPhone 14 Pro Max")
}
```

#### iPhone SE (5.5")
```swift
#Preview("iPhone SE") {
    FakePaywallView()
        .environmentObject(ThemeManager())
        .previewDevice("iPhone SE (3rd generation)")
}
```

#### Dark Mode
```swift
#Preview("Dark Mode") {
    FakePaywallView()
        .environmentObject(ThemeManager())
        .preferredColorScheme(.dark)
}
```

### 2. TestFlight Testing Checklist

- [ ] Fake paywall displays correctly
- [ ] Product selection works
- [ ] Purchase flow completes (mock success)
- [ ] Error handling works (mock failure)
- [ ] Restore purchases works
- [ ] Localization switches correctly (English/Turkish)
- [ ] Accessibility labels work with VoiceOver
- [ ] All buttons are tappable (44pt minimum)
- [ ] Loading states display properly

### 3. App Store Screenshots

To generate App Store screenshots:

1. Open `FakePaywallView.swift` in Xcode
2. Select iPhone 14 Pro Max preview
3. Use Xcode's screenshot tool (⌘+S)
4. Save as PNG at 3x scale (1290×2796)

## Switching Between Modes

### Development Mode (Fake Paywall)
```swift
// In Config.swift
static let useFakePaywall = true
```

### Production Mode (Real Adapty)
```swift
// In Config.swift
static let useFakePaywall = false
```

## Mock Purchase Flow

The fake paywall simulates real purchase behavior:

1. **Product Selection**: User taps a subscription card
2. **Purchase Initiation**: User taps "Unlock Premium"
3. **Loading State**: Shows "Processing..." with spinner
4. **Result**: Shows success or error alert
5. **Completion**: Dismisses paywall on success

### Mock Success Rate
- Purchase success: 90% (10% failure rate)
- Restore success: 95% (5% failure rate)

## Localization Testing

### English (Default)
- All strings use English text
- Pricing in USD ($4.99/week, $79.99/year)

### Turkish
- Switch device language to Turkish
- All strings use Turkish text
- Pricing in TRY (₺49,99/hafta, ₺799,99/yıl)

### Adding New Languages

1. Create new `.lproj` folder (e.g., `fr.lproj`)
2. Copy `Localizable.strings` from `en.lproj`
3. Translate all strings
4. Update currency and pricing

## A/B Testing

The system supports two variants:

### Variant A: Equal Layout
- Both subscription cards same size
- No special highlighting

### Variant B: Annual Highlight
- Annual card is larger and highlighted
- Shows "3-Day Free Trial" badge
- "BEST VALUE" indicator

### Switching Variants
```swift
// In MockPaywallData.swift
func getVariant() -> PaywallVariant {
    return .equalLayout // or .annualHighlight
}
```

## Common Issues & Solutions

### Issue: Paywall Not Showing
**Solution**: Check `Config.useFakePaywall` is set to `true`

### Issue: Localization Not Working
**Solution**: 
1. Ensure `.strings` files are in correct `.lproj` folders
2. Check device language settings
3. Verify `String+Localization.swift` is imported

### Issue: Purchase Always Fails
**Solution**: This is expected behavior - the system has a 10% failure rate to simulate real conditions

### Issue: Preview Not Loading
**Solution**:
1. Check all dependencies are imported
2. Ensure `ThemeManager` is available
3. Verify `DesignTokens` are accessible

## Compliance Checklist

### Apple Guidelines
- [x] No external payment methods
- [x] Only Apple-approved links (Terms, Privacy, Restore)
- [x] All purchases mocked in DEBUG builds
- [x] Clear error messaging
- [x] Proper accessibility labels
- [x] WCAG AA contrast compliance

### TestFlight Requirements
- [x] Realistic UI that matches production
- [x] Complete purchase flow simulation
- [x] Error handling and edge cases
- [x] Localization support
- [x] Accessibility compliance

## Analytics & Tracking

The mock system includes analytics tracking:

```swift
// Track paywall views
viewModel.trackPaywallView()

// Track product selection
viewModel.trackProductSelected(product)

// Track purchase attempts
viewModel.trackPurchaseAttempt(product)

// Track purchase success/failure
viewModel.trackPurchaseSuccess(product)
viewModel.trackPurchaseFailure(product, error: error)
```

## Performance Considerations

- Mock data loads instantly
- Purchase simulation has 1.5s delay
- Restore simulation has 1.0s delay
- UI updates are smooth and responsive
- Memory usage is minimal

## Security Notes

- No real payment processing
- No sensitive data collection
- All purchases are simulated
- Error messages are generic
- No external API calls

## Next Steps

1. **TestFlight Submission**: Use fake paywall for review
2. **App Store Approval**: Switch to real Adapty integration
3. **A/B Testing**: Implement real A/B testing service
4. **Analytics**: Connect to real analytics platform
5. **Localization**: Add more languages as needed

## Support

For issues or questions:
1. Check this documentation
2. Review unit tests in `MockPaywallViewModelTests.swift`
3. Test in SwiftUI previews first
4. Verify configuration settings

