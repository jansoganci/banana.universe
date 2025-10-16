# Profile Screen — Design Documentation

**Screen Name:** Profile / Settings  
**Type:** User profile + subscription + settings  
**Theme:** Dark  
**iOS Target:** iOS 13.0+ (FINALIZED)  
**Purpose:** View subscription status, manage settings, access support

---

## Overview

The Profile screen consolidates subscription management, legal docs, and support/contact options.

**Layout & UI:**
- **Header:** Back button (left), Title "Profile" (center)
- **Pro Card:** Gradient card with:
  - Title: "NanoBanana Pro"
  - Feature list: "Unlimited edits", "Fast processing", "No watermark" (✓ checkmarks)
  - Button: "Upgrade to Pro" (opens paywall modal — Adapty integration)
- **Settings Section:**
  - Privacy Policy (navigates to legal doc/view)
  - Terms of Use (navigates to legal doc/view)
- **Support Section:**
  - Feedback (opens in-app or mail)
  - Message to Developer (opens in-app chat or mail)

**User Flow:**
1. Accessed by tapping profile icon in History screen header
2. View PRO status and features
3. Tap "Upgrade to Pro" → Open Adapty paywall (modal sheet)
4. Tap legal/support links → Open relevant views/screens (WebView or Mail)

---

## Component Breakdown

### 1. ProfileHeaderBar
**Purpose:** Navigation + screen title

**Elements:**
- `backButton`: Chevron left (left-aligned)
- `titleLabel`: "Profile" (centered or left-aligned after back button)

**Props:**
```swift
struct ProfileHeaderBarProps {
    let title: String            // "Profile"
    let onBackTap: () -> Void
}
```

**Visual:**
- Background: #1A1C1E (header background)
- Height: ~56pt
- Title: SF Pro Semibold, 18pt

---

### 2. ProCard (Gradient Card)
**Purpose:** Display PRO subscription status + upgrade CTA

**Elements:**
- **Background:** Gradient (purple to blue or brand colors)
- **Icon:** Crown or sparkle icon (top-left, optional)
- **Title:** **"NanoBanana Pro"** (22pt, bold, white)
- **Feature List with Checkmarks (✓):**
  - ✓ Unlimited edits
  - ✓ Fast processing
  - ✓ No watermark
- **CTA Button:** **"Upgrade to Pro"** (white background, dark text, 48pt height, rounded)

**Props:**
```swift
struct ProCardProps {
    let isProActive: Bool                // Show "Active" badge or upgrade CTA
    let features: [String]               // Feature list with checkmarks
    let onUpgradeTap: () -> Void         // Present Adapty PaywallView
}
```

**Visual:**
- Size: Full-width minus 16pt horizontal padding, ~220pt height
- Corner radius: 16pt
- Gradient: Linear gradient from #6A4CFF (top) to #4D7CFF (bottom)
- Text color: White (#FFFFFF)
- Checkmarks: ✓ (SF Symbol: "checkmark.circle.fill", white, 16pt)
- Button: White background, dark text (#1A1C1E), 48pt height, 12pt corner radius
- Padding: 20pt internal padding

**States:**
- **Free User:** Show "Upgrade to Pro" button + feature list
- **PRO Active:** Show "PRO Active" badge + "Manage Subscription" button (opens App Store)

---

### 3. Settings Section
**Purpose:** Links to legal documents

**Section Header:** "Settings" (14pt, medium, muted)

**Rows:**
1. **Privacy Policy** → Tap opens WebView or Safari
2. **Terms of Use** → Tap opens WebView or Safari

**Props:**
```swift
struct SettingsRow {
    let id: String
    let title: String
    let iconName: String         // SF Symbol
    let onTap: () -> Void
}
```

**Visual:**
- Row height: ~50pt
- Icon: 20pt, left-aligned, 16pt leading padding
- Title: SF Pro Regular, 16pt, #C8DAFF
- Chevron: right-aligned, 16pt trailing padding
- Divider: 1px, rgba(255,255,255,0.06)

---

### 4. Support Section
**Purpose:** User feedback and developer communication

**Section Header:** "Support" (14pt, medium, muted)

**Rows:**
1. **Feedback** → Opens in-app feedback form or mail composer (`mailto:feedback@pixelmage.com`)
2. **Message to Developer** → Opens in-app chat or mail composer (`mailto:support@pixelmage.com`)

**Visual:**
- Same row style as Settings section
- Icons: SF Symbol "paperplane" (feedback), "envelope" (message)
- Row height: 48pt minimum
- Chevron right indicator on each row

---

### 5. Optional: User Profile Header
**Purpose:** Display user avatar + name (if authenticated)

**Elements:**
- Circular avatar (80pt diameter)
- User name / email (below avatar)
- "Edit Profile" button (optional)

**Visual:**
- Centered at top of screen (above ProCard)
- Avatar: 80pt circle, placeholder if no image
- Name: SF Pro Semibold, 18pt, #C8DAFF
- Email: SF Pro Regular, 14pt, #A0A9B0

---

## Design Tokens

### Colors (Dark Theme)

| Token Name | Hex Value | Usage | SwiftUI Asset |
|------------|-----------|-------|---------------|
| `background` | `#0E1012` | Main screen background | `background` |
| `headerBackground` | `#1A1C1E` | Header bar background | `headerBackground` |
| `cardBackground` | `#2C2F32` | Settings row background (optional) | `cardBackground` |
| `divider` | `rgba(255,255,255,0.06)` | Row dividers | `divider` |
| `titleText` | `#C8DAFF` | Titles, primary text | `titleText` |
| `secondaryText` | `#A0A9B0` | Email, hints | `secondaryText` |
| `proGradientStart` | `#6A4CFF` | ProCard gradient (top) | `proGradientStart` |
| `proGradientEnd` | `#4D7CFF` | ProCard gradient (bottom) | `proGradientEnd` |
| `proButtonBackground` | `#FFFFFF` | ProCard CTA button (white) | `proButtonBackground` |
| `proButtonText` | `#6A4CFF` | ProCard CTA text (purple) | `proButtonText` |

---

### Typography

| Style | Font | Size (pt) | Weight | Usage |
|-------|------|-----------|--------|-------|
| `header-title` | SF Pro | 18 | Semibold | Screen title "Profile" |
| `user-name` | SF Pro | 18 | Semibold | User display name |
| `user-email` | SF Pro | 14 | Regular | User email |
| `pro-card-title` | SF Pro | 22 | Bold | "noname_banana Pro" |
| `pro-card-bullet` | SF Pro | 14 | Regular | Benefit bullet points |
| `button-label` | SF Pro | 16 | Semibold | CTA buttons |
| `settings-row` | SF Pro | 16 | Regular | Row titles |

---

### Spacing & Layout

| Token | Value (pt) | Usage |
|-------|------------|-------|
| `spacing-xs` | 8 | Icon-to-text gap |
| `spacing-sm` | 12 | Internal padding (rows, cards) |
| `spacing-md` | 16 | Screen horizontal padding, section gaps |
| `spacing-lg` | 24 | ProCard top margin, section headers |

**Component-Specific:**
- **ProCard Height:** ~200pt (responsive to content)
- **ProCard Corner Radius:** 16pt
- **Row Height:** 50pt
- **Avatar Diameter:** 80pt (if used)
- **Button Height:** 48pt
- **Button Corner Radius:** 24pt (pill shape)

---

## States & UX Rules

### 1. Free User (Not Subscribed)
**ProCard State:**
- Title: "Upgrade to Pro"
- Bullet points: benefits of PRO
- CTA button: "Upgrade to Pro" (prominent)

**Behavior:**
- Tap CTA → Present PaywallView (Adapty)
- Track analytics: "profile_upgrade_tapped"

---

### 2. PRO Active (Subscribed)
**ProCard State:**
- Title: "noname_banana Pro"
- Badge: "✓ Active" (green checkmark + text)
- Expiration: "Renews on Oct 19, 2025" (if applicable)
- CTA button: "Manage Subscription" (secondary style)

**Behavior:**
- Tap CTA → Open App Store subscription management
- iOS 15+: `openURL(URL(string: "https://apps.apple.com/account/subscriptions")!)`
- Track analytics: "profile_manage_subscription_tapped"

---

### 3. PRO Expired (Subscription Lapsed)
**ProCard State:**
- Title: "Your PRO subscription has expired"
- CTA button: "Renew Subscription" (prominent)

**Behavior:**
- Tap CTA → Present PaywallView
- Highlight same plan user had before

---

### 4. Settings Rows
**Behavior:**
- **Privacy Policy:** Open URL in Safari or in-app WebView
- **Terms of Use:** Open URL in Safari or in-app WebView
- Accessibility: VoiceOver reads title + "link, button"

---

### 5. Support Rows
**Behavior:**
- **Send Feedback:**
  - Option A: Open `mailto:support@picturelab.ai?subject=Feedback`
  - Option B: Present in-app feedback form (SwiftUI sheet)
- **Message to Developer:**
  - Same as feedback, or open dedicated support chat
- Track analytics: "profile_feedback_tapped", "profile_message_tapped"

---

## Data & API Integration

### 1. Get User Profile
**Endpoint:** `GET /api/v1/profile`

**Response:**
```json
{
  "userId": "user_abc123",
  "email": "user@example.com",
  "displayName": "John Doe",
  "avatarUrl": "https://cdn.example.com/avatars/abc123.jpg",
  "createdAt": "2025-01-01T00:00:00Z"
}
```

---

### 2. Get Subscription Status
**Endpoint:** `GET /api/v1/subscription/status`

**Response:**
```json
{
  "isPro": true,
  "planName": "Monthly Pro",
  "expiresAt": "2025-11-12T00:00:00Z",
  "autoRenew": true,
  "provider": "app_store"
}
```

**Alternative:** Use Adapty SDK
```swift
let customerInfo = try await Purchases.shared.customerInfo()
let isPro = customerInfo.entitlements["pro"]?.isActive == true
```

---

### 3. Send Feedback
**Endpoint:** `POST /api/v1/feedback`

**Request:**
```json
{
  "subject": "Feature Request",
  "message": "I would like to see...",
  "category": "feedback",
  "deviceInfo": {
    "model": "iPhone 13",
    "osVersion": "iOS 17.0"
  }
}
```

**Response:**
```json
{
  "success": true,
  "feedbackId": "feedback_xyz789"
}
```

---

## Navigation Mapping

| Action | From | To | Parameters | Notes |
|--------|------|----|-----------|----|
| Tap Back | ProfileView | Previous Screen | — | Pop navigation |
| Tap Upgrade to Pro | ProfileView | PaywallView | — | Present modal sheet (Adapty) |
| Tap Manage Subscription | ProfileView | App Store | — | Open subscription management URL |
| Tap Privacy Policy | ProfileView | Safari / WebView | `url: URL` | Open legal doc |
| Tap Terms of Use | ProfileView | Safari / WebView | `url: URL` | Open legal doc |
| Tap Send Feedback | ProfileView | Feedback Form / Email | — | Present sheet or mailto: |
| Tap Message Developer | ProfileView | Email / Chat | — | mailto: or in-app chat |

---

## Accessibility

### VoiceOver Labels
- **ProCard CTA:** "Upgrade to Pro, button. Unlock unlimited AI edits and all PRO tools."
- **Settings row:** "{Title}, link, button. Opens in Safari."
- **Support row:** "{Title}, button. Opens email composer."
- **Back button:** "Back, button."

### Tap Targets
- All rows: 50pt height (full-width tappable)
- ProCard button: 48pt height (full-width or centered)
- Back button: 44×44pt

### Dynamic Type
- Scale all text with user settings
- Test with XXXL (accessibility size 7)

---

## iOS Compatibility

### SwiftUI (iOS 13+)
- Standard `List` or `ScrollView + VStack` for settings rows
- `LinearGradient` for ProCard background
- `openURL` environment variable (iOS 14+) for opening links
- For iOS 13: Use `UIApplication.shared.open(url)` fallback

### Adapty Integration
```swift
import Adapty

// Initialize in AppDelegate or App init
Adapty.activate("your_public_sdk_key")

// Check subscription status
let customerInfo = try await Purchases.shared.customerInfo()
let isPro = customerInfo.entitlements["pro"]?.isActive == true

// Present paywall
Purchases.shared.presentPaywall { result in
    // Handle purchase or dismissal
}
```

### iOS 12 Requirement (Not Supported)
- SwiftUI unavailable on iOS 12
- **UIKit Fallback:** Use `UITableViewController` with custom cells
- Group rows into sections (Profile, Settings, Support)
- Use `CAGradientLayer` for ProCard gradient
- Request UIKit scaffold if iOS 12 support is critical

---

## Implementation Checklist

### Design
- [ ] Confirm ProCard gradient colors (match brand)
- [ ] Verify row heights on small devices (iPhone SE)
- [ ] Test dark mode contrast ratios (WCAG AA)
- [ ] Validate button sizes (48pt height minimum)

### Functionality
- [ ] Integrate Adapty SDK (subscription status check)
- [ ] Implement paywall presentation (modal sheet)
- [ ] Add Privacy Policy URL (open in Safari or WebView)
- [ ] Add Terms of Use URL
- [ ] Implement feedback submission (email or API)
- [ ] Handle "Manage Subscription" link (App Store URL)

### Adapty Setup
- [ ] Create app in Adapty dashboard
- [ ] Configure entitlements ("pro" entitlement)
- [ ] Set up products (weekly, monthly, annual)
- [ ] Test subscription flow (sandbox environment)
- [ ] Handle purchase restoration
- [ ] Add webhook for backend sync (optional)

### Accessibility
- [ ] VoiceOver labels for all interactive elements
- [ ] Dynamic Type support
- [ ] High contrast mode adjustments
- [ ] Test with VoiceOver + keyboard navigation

### Error Handling
- [ ] Handle network errors (subscription status fetch)
- [ ] Handle Adapty errors (purchase failed, cancelled)
- [ ] Handle URL opening errors (no browser installed)
- [ ] Show user-friendly error messages

### Analytics
- [ ] Track: screen view (Profile)
- [ ] Track: upgrade tapped (free → paywall)
- [ ] Track: manage subscription tapped
- [ ] Track: privacy policy / terms opened
- [ ] Track: feedback submitted

---

## Technical Implementation

### State Management
```swift
struct ProfileView: View {
    @State private var isPRO: Bool = false
    @State private var showPaywall: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Pro Card (Gradient)
                ProCard(
                    isProActive: isPRO,
                    features: [
                        "Unlimited edits",
                        "Fast processing",
                        "No watermark"
                    ],
                    onUpgradeTap: {
                        showPaywall = true
                    }
                )
                
                // Settings Section
                VStack(spacing: 0) {
                    Text("Settings")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                    
                    SettingsRow(title: "Privacy Policy", onTap: openPrivacyPolicy)
                    SettingsRow(title: "Terms of Use", onTap: openTerms)
                }
                
                // Support Section
                VStack(spacing: 0) {
                    Text("Support")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                    
                    SupportRow(title: "Feedback", onTap: openFeedback)
                    SupportRow(title: "Message to Developer", onTap: openSupport)
                }
            }
            .padding(.horizontal, 16)
        }
        .sheet(isPresented: $showPaywall) {
            AdaptyPaywallView() // Adapty integration
        }
    }
}
```

---

## Future Implementation Notes

### Paywall Integration (Adapty)
- **SDK:** Install via SPM: `https://github.com/adaptyteam/AdaptySDK-iOS`
- **Activation:** `Adapty.activate("YOUR_PUBLIC_SDK_KEY")`
- **Products:** Weekly ($4.99), Monthly ($9.99), Annual ($79.99)
- **Custom Modal:** Implement custom paywall UI (not default Adapty template)
- **Testing:** Use Adapty sandbox for development/testing

### Legal Documents (Placeholder for MVP)
- **Privacy Policy:** Host on GitHub Pages, Notion, or custom domain
- **Terms of Use:** Same hosting as Privacy Policy
- **URLs:** Update before App Store submission
- **WebView:** Use `SafariServices.SFSafariViewController` for in-app display

### Support Integration
- **Feedback:**
  - Option 1: `mailto:feedback@pixelmage.com` (simple, native)
  - Option 2: In-app form with API endpoint (POST /api/v1/feedback)
- **Message Developer:**
  - Option 1: `mailto:support@pixelmage.com` (simple, native)
  - Option 2: In-app chat (Intercom, Crisp, or custom)
- **Auto-Include:** Device model, iOS version, app version in email body

---

**Document Status:** ✅ Production-Ready  
**iOS Target:** ✅ iOS 13+ (SwiftUI + Adapty)  
**Key Features:**
- Gradient PRO card with feature list (✓ checkmarks)
- "Upgrade to Pro" button → Adapty paywall modal (custom UI to be implemented)
- Settings: Privacy Policy, Terms of Use (placeholder URLs OK for MVP)
- Support: Feedback, Message to Developer (mailto: or in-app form)
- All navigation flows documented

