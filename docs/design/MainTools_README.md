# Main Tools Screen — Design Documentation

**Screen Name:** Main Tools (Home > Main Tools Category)  
**Type:** 2-column grid, card-based browsing  
**Theme:** Dark  
**iOS Target:** iOS 13.0+ (FINALIZED - LazyVGrid iOS 14+, fallback for iOS 13)  
**Pattern:** Reuses ProLooks grid pattern with different content category

---

## Overview

The Main Tools screen is the primary feature selection hub of the app. It displays all AI-powered image editing tools as visual "cards" in a 2-column grid. Users access the latest generative and enhancement models with one tap.

**Screen Structure:**
- **Header:** App logo/brand name + "Get PRO" button
- **Category Tabs:** "Main Tools" (default/active), "Pro Looks", "Restoration"
- **Tools Grid:** 2-column LazyVGrid with circular preview cards
- **Bottom Tab Bar:** Home (active) | Chat | History

**Each Tool Card Features:**
- **Title** (top-left, below preview)
- **Circular preview image** (centered, 120pt diameter)
- **Optional PRO badge** (lock icon overlay for premium tools)
- **2-column grid layout** (8pt gutter, 16pt horizontal padding)

**User Flow:**
- User launches app → Lands on Main Tools tab by default
- User sees all 7 available tools as cards (Main Tools category)
- Tap free tool card → Navigate to EditorView (image picker → upload → processing)
- Tap PRO-locked card → Present Adapty PaywallView (modal sheet)
- Tap "Get PRO" (header) → Present Adapty PaywallView
- Switch tabs → Filter tools by category (Main Tools / Pro Looks / Restoration)
- Bottom tab change → Switch root tab (Home / Chat / History)

---

## Component Breakdown

### 1. HeaderBar
**Purpose:** Brand identity + premium upgrade CTA

**Elements:**
- `brandLabel`: "noname_banana" with icon/logo (left-aligned)
- `getProButton`: Pill-shaped CTA button (right-aligned)

**Props:**
```swift
struct HeaderBarProps {
    let brandTitle: String
    let brandIcon: String?        // Optional logo image
    let showProButton: Bool
    let onProTap: () -> Void
}
```

**Visual:**
- Background: semi-transparent or solid dark
- Height: ~50pt (including safe area padding)
- Horizontal padding: 16pt

---

### 2. CategoryTabs
**Purpose:** Horizontal scrollable filter for tool categories

**Elements:**
- Scrollable horizontal tab list (3 tabs total)
- Active state indicator (accent color background or underline)
- **Categories (in order):**
  1. **"Main Tools"** (default active, 7 tools) ✅
  2. **"Pro Looks"** (inactive by default, 10 tools) ✅
  3. **"Restoration"** (inactive by default, 1 tool) ✅

**Props:**
```swift
struct CategoryTab {
    let id: String
    let label: String
    let isActive: Bool
}

struct CategoryTabsProps {
    let tabs: [CategoryTab]
    let selectedTabId: String
    let onSelect: (String) -> Void
}
```

**Visual:**
- Tab pills: 12pt horizontal padding, 6pt vertical padding
- Active tab: solid background (accent color)
- Inactive tab: outlined or muted text
- Horizontal scroll: no indicators, edge fade effect (optional)

---

### 3. MainToolsGrid (2-Column LazyVGrid)
**Purpose:** Main content area displaying tool cards

**Layout:**
- 2 equal-width columns via `GridItem(.flexible())`
- 8pt gutter (horizontal and vertical spacing)
- 16pt horizontal screen padding
- Responsive cell height: min 180pt, content-dependent

**Props:**
```swift
struct MainToolsGridProps {
    let tools: [Tool]
    let onToolTap: (Tool) -> Void
}
```

---

### 4. ToolCard (Grid Cell)
**Purpose:** Individual tool card in the grid

**Elements:**
- `titleLabel`: Tool name (top-left, 12pt padding from edges)
- `circularPreview`: Circular preview image (120pt diameter, centered)
- `proLockBadge`: Small lock icon overlay (if `requiresPro = true`)
- `cardBackground`: Rounded rectangle (12pt corner radius)
- Optional divider lines between cells (1px, rgba(255,255,255,0.06))

**Props:**
```swift
struct Tool: Identifiable {
    let id: String
    let title: String
    let imageUrl: URL?           // Preview image
    let category: String         // "main", "pro", "restoration", etc.
    let requiresPro: Bool
}

struct ToolCardProps {
    let tool: Tool
    let onTap: (Tool) -> Void
}
```

**States:**
- **Normal:** Fully visible, tappable, smooth transition
- **PRO-locked:** Lock badge visible (24pt circle, top-right of preview), tap → paywall
- **Loading:** Circular progress spinner overlay on preview, disabled interaction
- **Error:** Red border (1pt), retry icon or toast message
- **Selected:** Scale down slightly (0.95×) on press (haptic feedback)

---

### 5. BottomTabBar (Global Component)
**Purpose:** Primary app navigation (reused across all screens)

**Elements:**
- Home icon + label
- Chat icon (center, circular avatar style)
- History icon + label

**Props:**
```swift
struct BottomTabBarProps {
    let currentTab: String       // "home", "chat", "history"
    let onTabChange: (String) -> Void
}
```

**Visual:**
- Height: 80pt (including safe area)
- Background: #1A1C1E (slightly elevated from screen background)
- Active tab: accent color (#33C3A4)
- Inactive tabs: muted gray (#A0A9B0)

---

## Design Tokens

### Colors (Dark Theme)

| Token Name | Hex Value | Usage | SwiftUI Asset Name |
|------------|-----------|-------|--------------------|
| `background` | `#0E1012` | Main screen background (very dark gray) | `background` |
| `cardBackground` | `#2F3133` | Card surface (elevated dark gray) | `cardBackground` |
| `divider` | `rgba(255,255,255,0.06)` | Grid divider lines (subtle) | `divider` |
| `titleText` / `primary` | `#C8DAFF` | Card titles, brand text (pale blue) | `titleText` |
| `secondaryText` / `body` | `#A0A9B0` | Captions, inactive tabs (muted gray) | `secondaryText` |
| `accent` | `#4D7CFF` | Get PRO button, active elements (blue) | `accent` |
| `activeTabAccent` | `#33C3A4` | Active tab indicator (mint green) | `activeTabAccent` |
| `proLockOverlay` | `rgba(0,0,0,0.6)` | Lock badge background (semi-transparent black) | `proLockOverlay` |
| `errorBorder` | `#FF4444` | Error state border (red) | `errorBorder` |

**Note:** Approximate values from screen capture. Finalize with design system or Figma export.

---

### Typography

| Style | Font | Size (pt) | Weight | Line Height | Usage |
|-------|------|-----------|--------|-------------|-------|
| `brand-title` | SF Pro | 20 | Semibold | 1.2× | Header brand name |
| `card-title` | SF Pro | 16 | Semibold | 1.3× | Tool card titles |
| `body` | SF Pro | 13 | Regular | 1.4× | Captions, hints |
| `button-label` | SF Pro | 14 | Medium | 1.0× | CTA buttons |
| `tab-label` | SF Pro | 10 | Medium | 1.0× | Bottom tab labels |

**Dynamic Type Support:**
- Scale all fonts with user's accessibility settings
- Test with "Larger Accessibility Sizes" enabled
- Minimum: Support up to XXXL (accessibility size 7)

---

### Spacing & Layout

| Token | Value (pt) | Usage |
|-------|------------|-------|
| `spacing-xs` | 8 | Grid gutter (between cells) |
| `spacing-sm` | 12 | Card internal padding (title to edge, preview margin) |
| `spacing-md` | 16 | Screen horizontal padding, section gaps |
| `spacing-lg` | 24 | Large gaps (header to tabs, tabs to grid) |
| `spacing-xl` | 32 | Extra spacing (top safe area to header) |

**Component-Specific:**
- **Card Corner Radius:** 12pt
- **Button Corner Radius (pill):** 20pt (height / 2)
- **Circular Preview Diameter:** 120pt
- **Cell Min Height:** 180pt (responsive to content)
- **Grid Gutter:** 8pt (vertical + horizontal)
- **Horizontal Screen Padding:** 16pt
- **Tab Bar Height:** 80pt (including safe area inset)

---

## Grid Rules & Layout

### LazyVGrid Configuration (SwiftUI)
```swift
let columns = [
    GridItem(.flexible(), spacing: 8),
    GridItem(.flexible(), spacing: 8)
]

LazyVGrid(columns: columns, spacing: 8) {
    ForEach(tools) { tool in
        ToolCard(tool: tool, onTap: handleToolTap)
    }
}
.padding(.horizontal, 16)
```

### Cell Sizing Math
- **Screen Width (iPhone 13):** 390pt
- **Horizontal Padding:** 16pt × 2 = 32pt
- **Gutter:** 8pt
- **Cell Width:** `(390 - 32 - 8) / 2 = 175pt`
- **Cell Height:** Min 180pt (dynamic based on content)

### Circular Preview Positioning
- **Diameter:** 120pt
- **Centering:** `HStack { Spacer(); circularView; Spacer() }`
- **Vertical Centering:** `VStack { title; Spacer(); preview; Spacer() }`

### Divider Lines (Optional for MVP)
- **Thickness:** 1px (use `.divider()` or `.border()`)
- **Color:** `rgba(255,255,255,0.06)` (very subtle)
- **Placement:** Between cells, or as card border

---

## States & UX Rules

### Default State
- Card fully visible, crisp preview image
- Title displayed (max 2 lines, truncate with `...`)
- Tap area: entire card (min 44×44pt per Apple HIG)
- Smooth transitions (0.15s ease-in-out)

### PRO-Locked State
- Lock badge visible (24pt circle, white lock icon, black 60% opacity background)
- Badge position: top-right corner of circular preview (offset x: 40pt, y: -40pt)
- Tap behavior: Present PaywallView (modal sheet)
- No navigation to editor

### Loading State
- Circular progress spinner overlay on preview (center)
- Disable tap interaction (`.disabled(true)`)
- Dim card slightly (opacity 0.7)
- Skeleton/shimmer effect (optional enhancement)

### Error State
- Preview shows error icon (red exclamation triangle)
- Red border (1pt) around entire card
- Retry button or auto-retry after 2s (optional)
- Toast message: "Failed to load. Tap to retry."

### Selected/Pressed State
- Scale effect: 0.95× on press (`.scaleEffect()`)
- Haptic feedback: medium impact (`.sensoryFeedback(.impact(.medium))`)
- Animation duration: 0.15s

### Accessibility
- VoiceOver label: `"{title}, button{requiresPro ? ', requires PRO subscription' : ''}"`
- Trait: `.isButton`
- Hint: "Double-tap to {requiresPro ? 'view subscription options' : 'start editing'}"
- High contrast mode: increase divider opacity to 0.15

---

## Navigation Mapping

| Action | From Screen | To Screen | Parameters | Notes |
|--------|-------------|-----------|------------|-------|
| Tap ToolCard (free) | MainToolsView | EditorView | `toolId: String, category: String` | Start job, show progress UI |
| Tap ToolCard (PRO) | MainToolsView | PaywallView | — | Present as modal sheet |
| Tap "Get PRO" | MainToolsView | PaywallView | — | Present as modal sheet |
| Tap bottom tab (Home) | Any | HomeView | — | Root tab switch |
| Tap bottom tab (Chat) | Any | ChatView | — | Root tab switch |
| Tap bottom tab (History) | Any | HistoryView | — | Root tab switch |
| Select category tab | MainToolsView | MainToolsView (filtered) | `categoryId: String` | Filter grid, scroll to top |

### Navigation Implementation (SwiftUI)
```swift
// Programmatic navigation (iOS 16+)
@State private var path = NavigationPath()

// For iOS 13-15, use NavigationLink or .sheet()
.sheet(isPresented: $showPaywall) {
    PaywallView()
}
```

---

## iOS Compatibility

### SwiftUI Requirement
- **Minimum:** iOS 13+ (SwiftUI baseline)
- **LazyVGrid:** iOS 14+ (optimal performance)
- **Fallback for iOS 13:** Manual `VStack + HStack` layout (less efficient)

### iOS 12 Support (Deprecated)
- **Original target:** iOS 12 (from initial spec)
- **Issue:** SwiftUI unavailable on iOS 12
- **Decision:** Updated to iOS 13+ for SwiftUI benefits
- **Market impact:** iOS 12 = ~0.5% users, iOS 13+ = ~99.5%

### UIKit Fallback Option (If iOS 12 Required)
If business requirements demand iOS 12 support:
- Use `UICollectionView` + `UICollectionViewFlowLayout`
- 2-column grid via `itemSize` calculation
- Custom `UICollectionViewCell` subclass for ToolCard
- Similar performance, but 3× more boilerplate code

**Recommendation:** Proceed with iOS 13+ SwiftUI for MVP speed. Revisit only if analytics show significant iOS 12 user demand.

---

## Implementation Checklist

### Design Compliance
- [ ] Confirm exact hex colors from design system (use ColorSync Utility or Figma)
- [ ] Verify typography scales on all device sizes (SE to Pro Max)
- [ ] Test dark mode contrast ratios (WCAG AA: 4.5:1 for text, 3:1 for UI elements)
- [ ] Ensure all tap targets ≥44×44pt (cards naturally meet this)
- [ ] Validate spacing consistency across all screens

### Functionality
- [ ] Integrate AsyncImage or Kingfisher for image loading + caching
- [ ] Implement PRO lock logic (check `Adapty.getProfile()`)
- [ ] Handle card tap navigation (free → EditorView, PRO → PaywallView)
- [ ] Add haptic feedback on tap (`.sensoryFeedback(.impact(.medium))`)
- [ ] Implement category filtering (update grid data source on tab selection)

### Performance
- [ ] Use `LazyVGrid` for lazy loading (only render visible cells)
- [ ] Cache images with Kingfisher (avoid redundant downloads)
- [ ] Limit preloaded rows to visible + 5 extra (memory optimization)
- [ ] Profile scrolling FPS (target: 60fps on iPhone 11+)
- [ ] Optimize image sizes (serve 2× resolution max, compress to ~100KB per image)

### Accessibility
- [ ] VoiceOver labels for all cards and buttons
- [ ] Dynamic Type support (scale fonts with user settings)
- [ ] High contrast mode support (increase divider/border opacity)
- [ ] Test with VoiceOver + keyboard navigation (external keyboard support)
- [ ] Reduce motion support (disable scale animations if enabled)

### Privacy & Legal
- [ ] Display consent prompt before first tool usage (face editing tools)
- [ ] Show brief TOS/Privacy Policy link in settings
- [ ] Log user actions (analytics) with opt-in consent only

---

## API Integration

## Main Tools Category – Complete Tool List

**Total Tools:** 7 (all displayed on "Main Tools" tab)

### Tools (in display order):

1. **Remove Object from Image**
   - Model: `remove-object` or `lama-cleaner`
   - Category: `main_tools`
   - Requires PRO: TBD (configure per tool)

2. **Remove Background**
   - Model: `rembg` or `background-removal`
   - Category: `main_tools`
   - Requires PRO: TBD

3. **Put Items on Models**
   - Model: `virtual-try-on` or custom model
   - Category: `main_tools`
   - Requires PRO: TBD

4. **Add Objects to Images**
   - Model: `stable-diffusion-inpainting` or `dall-e-inpainting`
   - Category: `main_tools`
   - Requires PRO: TBD

5. **Change Image Perspectives**
   - Model: `perspective-transform` or custom model
   - Category: `main_tools`
   - Requires PRO: TBD

6. **Generate Image Series**
   - Model: `stable-diffusion` or `midjourney-api`
   - Category: `main_tools`
   - Requires PRO: TBD

7. **Style Transfers on Images**
   - Model: `style-transfer` or `neural-style`
   - Category: `main_tools`
   - Requires PRO: TBD

**Note:** Tool list is static for MVP. Future: Add backend-driven tool configuration for easy updates without app release.

---

## API Integration

### Fetch Tools List (Future Enhancement)
**Endpoint:** `GET /api/v1/tools`

**Query Params:**
- `category`: "main_tools" | "pro_looks" | "restoration"
- `limit`: 50 (default)
- `offset`: 0 (pagination)

**Response:**
```json
{
  "tools": [
    {
      "id": "tool_remove_object",
      "title": "Remove Object from Image",
      "imageUrl": "https://cdn.example.com/previews/remove_object.jpg",
      "category": "main_tools",
      "requiresPro": false,
      "modelName": "lama-cleaner",
      "defaultParams": {}
    },
    {
      "id": "tool_remove_bg",
      "title": "Remove Background",
      "imageUrl": "https://cdn.example.com/previews/remove_bg.jpg",
      "category": "main_tools",
      "requiresPro": false,
      "modelName": "rembg"
    }
  ],
  "totalCount": 7,
  "hasMore": false
}
```

**For MVP:** Use static array in Swift. See MODELS_CATALOG.md for complete model mappings.

### Swift Model & Static Data Source (MVP)
```swift
struct Tool: Identifiable, Codable {
    let id: String
    let title: String
    let imageUrl: URL?
    let category: String // "main_tools", "pro_looks", "restoration"
    let requiresPro: Bool
    let modelName: String
    let defaultParams: [String: AnyCodable]?
}

// Static tool list for MVP
extension Tool {
    static let mainTools: [Tool] = [
        Tool(
            id: "remove_object",
            title: "Remove Object from Image",
            imageUrl: URL(string: "preview_remove_object"), // Asset name
            category: "main_tools",
            requiresPro: false,
            modelName: "lama-cleaner",
            defaultParams: nil
        ),
        Tool(
            id: "remove_background",
            title: "Remove Background",
            imageUrl: URL(string: "preview_remove_bg"),
            category: "main_tools",
            requiresPro: false,
            modelName: "rembg",
            defaultParams: nil
        ),
        Tool(
            id: "put_items_on_models",
            title: "Put Items on Models",
            imageUrl: URL(string: "preview_virtual_tryon"),
            category: "main_tools",
            requiresPro: false,
            modelName: "virtual-try-on",
            defaultParams: nil
        ),
        Tool(
            id: "add_objects",
            title: "Add Objects to Images",
            imageUrl: URL(string: "preview_add_objects"),
            category: "main_tools",
            requiresPro: false,
            modelName: "stable-diffusion-inpainting",
            defaultParams: nil
        ),
        Tool(
            id: "change_perspective",
            title: "Change Image Perspectives",
            imageUrl: URL(string: "preview_perspective"),
            category: "main_tools",
            requiresPro: false,
            modelName: "perspective-transform",
            defaultParams: nil
        ),
        Tool(
            id: "generate_series",
            title: "Generate Image Series",
            imageUrl: URL(string: "preview_generate_series"),
            category: "main_tools",
            requiresPro: false,
            modelName: "stable-diffusion",
            defaultParams: nil
        ),
        Tool(
            id: "style_transfer",
            title: "Style Transfers on Images",
            imageUrl: URL(string: "preview_style_transfer"),
            category: "main_tools",
            requiresPro: false,
            modelName: "neural-style",
            defaultParams: nil
        )
    ]
}
```

**Usage in View:**
```swift
struct MainToolsView: View {
    let tools = Tool.mainTools
    
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
   Use `/src/features/mainTools/MainToolsView.swift` as starting point. Connect to real API endpoint.

2. **Upload Remaining Screenshots:**  
   Continue with:
   - `03_editor.png` (Image editor + job progress UI)
   - `04_paywall.png` (Subscription tiers + pricing)
   - `05_profile.png` (User profile + settings)

3. **Finalize Design Tokens:**  
   Export exact colors/fonts from Figma. Update Xcode Color/Font assets.

4. **Global Component Extraction:**  
   After all screens analyzed, extract shared components:
   - `BottomTabBar.swift` (reused globally)
   - `CategoryTabs.swift` (reused in MainTools, ProLooks, Restoration)
   - `HeaderBar.swift` (reused globally with variations)

5. **Backend Integration:**  
   Update `/docs/tech_stack.md` with specific tool parameters for each AI model (CodeFormer, GFPGAN, Real-ESRGAN, etc.).

---

**Document Status:** 🟢 Complete (Screen 3 of ~5 analyzed)  
**Next Screen:** Editor View (awaiting screenshot)  
**iOS Target:** ✅ iOS 13+ confirmed (SwiftUI)  
**Pattern Consistency:** ✅ Reuses ProLooks grid pattern (2-column, circular previews)

