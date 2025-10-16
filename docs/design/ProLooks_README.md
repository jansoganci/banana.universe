# ProLooks Screen — Design Documentation

**Screen Name:** Pro Looks (Home > Pro Looks Category)  
**Type:** 2-column grid, card-based browsing  
**Theme:** Dark  
**iOS Target:** iOS 13.0+ (FINALIZED - LazyVGrid iOS 14+, fallback for iOS 13)

---

## Overview

The Pro Looks tab is dedicated to advanced, professional-grade AI image models. Users can generate studio-quality headshots, profile photos, and social media graphics with one tap. All 10 tools are presented as cards in a 2-column grid layout, consistent with Main Tools.

**Screen Structure:**
- **Header:** App logo/brand name + "Get PRO" button
- **Category Tabs:** Main Tools, **Pro Looks (active)**, Restoration
- **Tools Grid:** 2-column LazyVGrid with circular preview cards (10 tools total)
- **Bottom Tab Bar:** Home (active) | Chat | History

**Each Tool Card Features:**
- **Title** (below circular preview)
- **Circular preview image** (centered, 120pt diameter)
- **Optional PRO badge** (lock icon overlay for premium tools)
- **2-column grid layout** (8pt gutter, 16pt horizontal padding)

**User Flow:**
- User switches to "Pro Looks" tab from Main Tools or Restoration
- User sees all 10 professional photo tools as cards
- Tap free tool card → Navigate to EditorView (image picker → upload → AI processing)
- Tap PRO-locked card → Present Adapty PaywallView (modal sheet)
- Tap "Get PRO" (header) → Present Adapty PaywallView
- Bottom tab change → Switch root tab (Home / Chat / History)

---

## Component Breakdown

### 1. HeaderBar
**Purpose:** Brand identity + premium CTA

**Elements:**
- `brandLabel`: "noname_banana" (left-aligned)
- `getProButton`: Pill-shaped CTA (right-aligned)

**Props:**
```swift
struct HeaderBarProps {
    let brandTitle: String
    let showProButton: Bool
    let onProTap: () -> Void
}
```

---

### 2. CategoryTabs
**Purpose:** Horizontal scrollable filter for tool categories

**Elements:**
- Scrollable horizontal tab list (3 tabs total)
- Active state indicator (accent color background)
- **Categories (in order):**
  1. **"Main Tools"** (inactive, 7 tools) ✅
  2. **"Pro Looks"** (active by default when on this screen, 10 tools) ✅
  3. **"Restoration"** (inactive, 1 tool) ✅
- Active state highlight (accent color underline)
- Categories: "All", "Professional", "Creative", "Restoration", etc.

**Props:**
```swift
struct CategoryTab {
    let id: String
    let label: String
    let isActive: Bool
}

struct CategoryTabsProps {
    let tabs: [CategoryTab]
    let onSelect: (String) -> Void
}
```

---

### 3. ProLooksGrid (2-Column)
**Purpose:** Main content area displaying effect cards

**Layout:**
- 2 columns (equal width)
- 8pt gutter (horizontal + vertical)
- Horizontal padding: 16pt
- Responsive cell height: ~180–200pt

**Props:**
```swift
struct ProLooksGridProps {
    let items: [ProLook]
    let onCardTap: (ProLook) -> Void
}
```

---

### 4. ProLookCard (Cell)
**Purpose:** Individual effect card in grid

**Elements:**
- `titleLabel`: Effect name (top-left, 12pt top padding, 12pt left padding)
- `circularPreview`: Circular image (120pt diameter, centered)
- `proLockBadge`: Small lock icon overlay (if `requiresPro = true`)
- `cardBackground`: Rounded rectangle (12pt corner radius)
- Optional divider lines between cells (1px, subtle)

**Props:**
```swift
struct ProLook: Identifiable {
    let id: String
    let title: String
    let imageUrl: URL?
    let requiresPro: Bool
}

struct ProLookCardProps {
    let item: ProLook
    let onTap: (ProLook) -> Void
}
```

**States:**
- **Normal:** Tappable, full opacity
- **PRO-locked:** Shows lock badge, taps → paywall
- **Loading:** Spinner overlay on preview, disabled interaction
- **Error:** Red border + retry icon (if image load fails)

---

### 5. BottomTabBar
**Purpose:** Primary navigation (global component, reused from Restoration tab)

**Elements:**
- Home icon/label
- Chat icon (center, circular avatar)
- History icon/label

*(See main design README for full BottomTabBar specs)*

---

## Design Tokens

### Colors (Dark Theme)

| Token Name | Hex Value | Usage | SwiftUI Asset Name |
|------------|-----------|-------|--------------------|
| `background` | `#0E1012` | Screen background | `background` |
| `cardBackground` | `#2F3133` | Card surface | `cardBackground` |
| `cellDivider` | `rgba(255,255,255,0.06)` | Grid divider lines | `cellDivider` |
| `titleText` / `primary` | `#C8DAFF` | Card titles, brand text | `titleText` |
| `bodyText` / `secondary` | `#A0A9B0` | Captions, hints | `bodyText` |
| `accent` | `#4D7CFF` | Get PRO button, active states | `accent` |
| `activeTabAccent` | `#33C3A4` | Active tab indicator | `activeTabAccent` |
| `proLockOverlay` | `rgba(0,0,0,0.6)` | Lock badge background | `proLockOverlay` |

**Note:** These are approximations from screen capture. Confirm with design team or Figma export.

---

### Typography

| Style | Font | Size (pt) | Weight | Usage |
|-------|------|-----------|--------|-------|
| `brand-title` | SF Pro | 20 | Semibold | Header brand name |
| `card-title` | SF Pro | 16 | Semibold | Effect card titles |
| `body` | SF Pro | 13 | Regular | Captions, hints |
| `button-label` | SF Pro | 14 | Medium | CTA buttons |

---

### Spacing & Layout

| Token | Value (pt) | Usage |
|-------|------------|-------|
| `spacing-xs` | 8 | Grid gutter (between cells) |
| `spacing-sm` | 12 | Card internal padding (title to edge) |
| `spacing-md` | 16 | Screen horizontal padding |
| `spacing-lg` | 24 | Section gaps (header to tabs, tabs to grid) |

**Grid-Specific:**
- **Columns:** 2 (equal width via `GridItem(.flexible())`)
- **Gutter:** 8pt vertical + 8pt horizontal
- **Cell Corner Radius:** 12pt
- **Circular Preview Diameter:** 120pt
- **Cell Min Height:** 180pt (responsive, content-dependent)
- **Horizontal Screen Padding:** 16pt

---

## Grid Rules

### Layout Calculations
```swift
// SwiftUI LazyVGrid
let columns = [
    GridItem(.flexible(), spacing: 8),
    GridItem(.flexible(), spacing: 8)
]

LazyVGrid(columns: columns, spacing: 8) {
    // cells...
}
.padding(.horizontal, 16)
```

### Cell Sizing
- **Width:** `(screenWidth - 16*2 - 8) / 2` (minus padding and gutter)
- **Height:** Dynamic, min 180pt (title + preview + spacing)
- **Content:** Vertically centered circular preview + top-left title

### Divider Lines
- **Type:** Subtle 1px lines between cells
- **Color:** `rgba(255,255,255,0.06)`
- **Implementation:** Can use `Divider()` or border on cards (optional for MVP)

---

## States & UX Rules

### Default State
- Card fully visible, tappable
- Circular preview loaded (or placeholder if loading)
- Title visible, no truncation (max 2 lines)

### PRO-Locked State
- Small lock icon badge overlay on circular preview (top-right corner of circle)
- Badge: 24pt circle, black 60% opacity background, white lock icon
- Tap behavior: Open PaywallView (do not navigate to editor)

### Loading State
- Circular preview shows spinner (subtle, center of circle)
- Disable tap interaction (use `.disabled(true)`)
- Skeleton/placeholder gradient (optional enhancement)

### Error State
- If image fails to load: show placeholder icon (camera slash)
- Red border (1pt) around card
- Retry button (optional, or auto-retry after 2s)

### Accessibility
- VoiceOver label: `"{title}, button, {requiresPro ? 'requires PRO subscription' : ''}"`
- Tap target: entire card area (min 44×44pt per Apple HIG)
- Dynamic Type support: scale fonts with user preferences

---

## Navigation Mapping

| Action | From | To | Parameters | Notes |
|--------|------|----|-----------|----|
| Tap ProLookCard (free) | ProLooksView | EditorView | `effectId: String` | Start job queue, show progress UI |
| Tap ProLookCard (PRO) | ProLooksView | PaywallView | — | Present modal sheet |
| Tap "Get PRO" button | ProLooksView | PaywallView | — | Present modal sheet |
| Tap bottom tab | ProLooksView | Home/Chat/History | `selectedTab: String` | Root tab switch |
| Select category tab | ProLooksView | ProLooksView (filtered) | `categoryId: String` | Filter grid, scroll to top |

---

## iOS Compatibility Note

### SwiftUI Requirement
- **Minimum:** iOS 13+ (SwiftUI baseline)
- **Recommended:** iOS 14+ for `LazyVGrid` (optimal performance)
- **Fallback:** iOS 13 can use `VStack` + `HStack` manual layout (less efficient)

### Previous iOS 12 Target
- **Original spec:** iOS 12 minimum (from tech_stack.md v1.0)
- **Issue:** SwiftUI unavailable on iOS 12
- **Decision:** Updated to iOS 13+ for SwiftUI benefits (faster dev, modern patterns)
- **Market impact:** iOS 12 = ~0.5% users (2025), iOS 13+ = ~99.5%

### UIKit Fallback (If Needed)
If iOS 12 support becomes critical:
- Use `UICollectionView` + `UICollectionViewFlowLayout`
- 2-column grid via `itemSize` calculation
- Custom `UICollectionViewCell` subclass for ProLookCard
- Performance: similar to SwiftUI, but more boilerplate code

**Recommendation:** Proceed with iOS 13+ SwiftUI for MVP. Revisit if App Store analytics show iOS 12 user demand.

---

## Implementation Checklist

### Design Compliance
- [ ] Confirm exact hex colors from Figma/design system
- [ ] Verify font sizes on iPhone SE (small screen) + iPhone 14 Pro Max (large)
- [ ] Test dark mode contrast (WCAG AA: 4.5:1 for text)
- [ ] Ensure tap targets ≥44×44pt (cards meet this naturally)

### Functionality
- [ ] Integrate AsyncImage or Kingfisher for circular previews
- [ ] Add PRO lock badge logic (check user subscription status via Adapty)
- [ ] Implement card tap → EditorView navigation with `effectId` parameter
- [ ] Implement PRO tap → PaywallView presentation
- [ ] Add haptic feedback on card tap (`.sensoryFeedback(.impact)`)

### Performance
- [ ] Use `LazyVGrid` (lazy loading, efficient scrolling)
- [ ] Cache images with Kingfisher (avoid redundant network calls)
- [ ] Limit grid to visible rows + ~5 preload (avoid memory spikes)
- [ ] Profile scrolling FPS (target: 60fps on iPhone 11+)

### Accessibility
- [ ] VoiceOver labels for all cards
- [ ] Dynamic Type support (scale fonts)
- [ ] High contrast mode support (increase divider opacity)
- [ ] Test with VoiceOver enabled (realistic navigation)

---

## Pro Looks Category – Complete Tool List

**Total Tools:** 10 (all displayed on "Pro Looks" tab)

### Tools (in display order):

1. **LinkedIn Headshot**
   - Model: `professional-headshot`
   - Category: `pro_looks`
   - Requires PRO: TBD

2. **Passport Photo**
   - Model: `passport-photo-generator`
   - Category: `pro_looks`
   - Requires PRO: TBD

3. **Twitter/X Avatar**
   - Model: `social-media-avatar`
   - Category: `pro_looks`
   - Requires PRO: TBD

4. **Gradient Headshot**
   - Model: `gradient-background-portrait`
   - Category: `pro_looks`
   - Requires PRO: TBD

5. **Resume Photo**
   - Model: `professional-resume-photo`
   - Category: `pro_looks`
   - Requires PRO: TBD

6. **Slide Background Maker**
   - Model: `presentation-background-generator`
   - Category: `pro_looks`
   - Requires PRO: TBD

7. **Thumbnail Generator**
   - Model: `youtube-thumbnail-generator`
   - Category: `pro_looks`
   - Requires PRO: TBD

8. **CV/Portfolio Portrait**
   - Model: `portfolio-portrait`
   - Category: `pro_looks`
   - Requires PRO: TBD

9. **Profile Banner Generator**
   - Model: `banner-generator`
   - Category: `pro_looks`
   - Requires PRO: TBD

10. **Designer-Style ID Photo**
    - Model: `designer-id-photo`
    - Category: `pro_looks`
    - Requires PRO: TBD

**Note:** All tools require portrait/photo input. See MODELS_CATALOG.md for detailed model specs and API parameters.

---

## Swift Model & Static Data Source (MVP)

```swift
struct Tool: Identifiable, Codable {
    let id: String
    let title: String
    let imageUrl: URL?
    let category: String
    let requiresPro: Bool
    let modelName: String
    let defaultParams: [String: AnyCodable]?
}

extension Tool {
    static let proLooksTools: [Tool] = [
        Tool(
            id: "linkedin_headshot",
            title: "LinkedIn Headshot",
            imageUrl: URL(string: "preview_linkedin_headshot"),
            category: "pro_looks",
            requiresPro: false,
            modelName: "professional-headshot",
            defaultParams: nil
        ),
        Tool(
            id: "passport_photo",
            title: "Passport Photo",
            imageUrl: URL(string: "preview_passport_photo"),
            category: "pro_looks",
            requiresPro: false,
            modelName: "passport-photo-generator",
            defaultParams: nil
        ),
        Tool(
            id: "twitter_avatar",
            title: "Twitter/X Avatar",
            imageUrl: URL(string: "preview_twitter_avatar"),
            category: "pro_looks",
            requiresPro: false,
            modelName: "social-media-avatar",
            defaultParams: nil
        ),
        Tool(
            id: "gradient_headshot",
            title: "Gradient Headshot",
            imageUrl: URL(string: "preview_gradient_headshot"),
            category: "pro_looks",
            requiresPro: false,
            modelName: "gradient-background-portrait",
            defaultParams: nil
        ),
        Tool(
            id: "resume_photo",
            title: "Resume Photo",
            imageUrl: URL(string: "preview_resume_photo"),
            category: "pro_looks",
            requiresPro: false,
            modelName: "professional-resume-photo",
            defaultParams: nil
        ),
        Tool(
            id: "slide_background",
            title: "Slide Background Maker",
            imageUrl: URL(string: "preview_slide_background"),
            category: "pro_looks",
            requiresPro: false,
            modelName: "presentation-background-generator",
            defaultParams: nil
        ),
        Tool(
            id: "thumbnail_generator",
            title: "Thumbnail Generator",
            imageUrl: URL(string: "preview_thumbnail"),
            category: "pro_looks",
            requiresPro: false,
            modelName: "youtube-thumbnail-generator",
            defaultParams: nil
        ),
        Tool(
            id: "cv_portrait",
            title: "CV/Portfolio Portrait",
            imageUrl: URL(string: "preview_cv_portrait"),
            category: "pro_looks",
            requiresPro: false,
            modelName: "portfolio-portrait",
            defaultParams: nil
        ),
        Tool(
            id: "profile_banner",
            title: "Profile Banner Generator",
            imageUrl: URL(string: "preview_profile_banner"),
            category: "pro_looks",
            requiresPro: false,
            modelName: "banner-generator",
            defaultParams: nil
        ),
        Tool(
            id: "designer_id_photo",
            title: "Designer-Style ID Photo",
            imageUrl: URL(string: "preview_designer_id"),
            category: "pro_looks",
            requiresPro: false,
            modelName: "designer-id-photo",
            defaultParams: nil
        )
    ]
}
```

**Usage in View:**
```swift
struct ProLooksView: View {
    let tools = Tool.proLooksTools
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(tools) { tool in
                ToolCard(tool: tool, onTap: handleToolTap)
            }
        }
    }
}
```

---

## Next Actions

1. **Implement SwiftUI Scaffold:**  
   Use the provided `ProLooksView.swift` scaffold. Reuse ToolCard component from Main Tools.

2. **Upload Remaining Screenshots:**  
   Continue with:
   - `02_editor.png` (Image editor + job progress UI)
   - `03_paywall.png` (Subscription tiers + pricing)
   - `04_home.png` (Main gallery/home view)
   - `05_profile.png` (User profile + settings)

3. **Finalize Design Tokens:**  
   Export exact colors/typography from Figma (if available). Update Color assets in Xcode.

4. **API Integration:**  
   Connect grid to backend `GET /api/v1/effects` endpoint (return list of ProLook items with `id`, `title`, `imageUrl`, `requiresPro`).

---

**Document Status:** 🟢 Complete (Screen 2 of ~5 analyzed)  
**Next Screen:** Editor View (awaiting screenshot)  
**iOS Target Decision:** ✅ Confirmed iOS 13+ (SwiftUI)

