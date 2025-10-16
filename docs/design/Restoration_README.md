# Restoration Screen — Design Documentation

**Screen Name:** Restoration (Home > Restoration Category)  
**Type:** 2-column grid, card-based browsing  
**Theme:** Dark  
**iOS Target:** iOS 13.0+ (FINALIZED - LazyVGrid iOS 14+, fallback for iOS 13)  
**Pattern:** Reuses Main Tools grid pattern with restoration-specific content

---

## Overview

The Restoration tab provides dedicated tools for restoring old or damaged photos using AI. Users can enhance historical images, repair scratches, colorize black-and-white photos, and more. Currently displays 1 tool, expandable in future releases.

**Screen Structure:**
- **Header:** App logo/brand name + "Get PRO" button
- **Category Tabs:** Main Tools, Pro Looks, **Restoration (active)**
- **Tools Grid:** 2-column LazyVGrid with circular preview cards (1 tool currently)
- **Bottom Tab Bar:** Home (active) | Chat | History

**Each Tool Card Features:**
- **Title** (below circular preview)
- **Circular preview image** (centered, 120pt diameter)
- **Optional PRO badge** (lock icon overlay for premium tools)
- **2-column grid layout** (8pt gutter, 16pt horizontal padding)

**User Flow:**
- User switches to "Restoration" tab from Main Tools or Pro Looks
- User sees "Historical Photo Restore" card (single tool for now)
- Tap tool card → Navigate to EditorView (image picker → upload old/damaged photo → AI restoration → result preview/download)
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
  1. **"Main Tools"** (inactive)
  2. **"Pro Looks"** (inactive)
  3. **"Restoration"** (active by default when on this screen)

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

---

### 3. RestorationGrid (2-Column LazyVGrid)
**Purpose:** Main content area displaying restoration tool cards

**Layout:**
- 2 equal-width columns (for future scalability)
- 8pt gutter (horizontal and vertical spacing)
- 16pt horizontal screen padding
- Currently displays 1 card, but prepared for expansion

**Props:**
```swift
struct RestorationGridProps {
    let tools: [Tool]
    let onToolTap: (Tool) -> Void
}
```

---

### 4. ToolCard (Grid Cell)
**Purpose:** Individual restoration tool card

**Elements:**
- `titleLabel`: Tool name (below preview)
- `circularPreview`: Circular preview image (120pt diameter, centered)
- `proLockBadge`: Small lock icon overlay (if `requiresPro = true`)
- `cardBackground`: Rounded rectangle (12pt corner radius)

**Props:**
```swift
struct Tool: Identifiable {
    let id: String
    let title: String
    let imageUrl: URL?
    let category: String         // "restoration"
    let requiresPro: Bool
}

struct ToolCardProps {
    let tool: Tool
    let onTap: (Tool) -> Void
}
```

**States:**
- **Normal:** Fully visible, tappable, smooth transition
- **PRO-locked:** Lock badge visible, tap → paywall
- **Loading:** Circular progress spinner overlay
- **Selected:** Scale down slightly (0.95×) on press with haptic feedback

---

## Design Tokens

### Colors (Dark Theme)

| Token Name | Hex Value | Usage | SwiftUI Asset Name |
|------------|-----------|-------|--------------------|
| `background` | `#0E1012` | Main screen background | `background` |
| `cardBackground` | `#2F3133` | Card surface | `cardBackground` |
| `titleText` | `#C8DAFF` | Card titles | `titleText` |
| `secondaryText` | `#A0A9B0` | Captions | `secondaryText` |
| `accent` | `#4D7CFF` | Get PRO button | `accent` |
| `activeTabAccent` | `#33C3A4` | Active tab (Restoration) | `activeTabAccent` |

---

## Restoration Category – Complete Tool List

**Total Tools:** 1 (expandable in future)

### Tool:

**1. Historical Photo Restore**
   - Model: `codeformer` or `gfpgan`
   - Category: `restoration`
   - Requires PRO: TBD (configure per tool)
   - Purpose: Restore old, damaged, or low-quality photos using AI face restoration

**Future Tools (Placeholder):**
- Photo Colorization
- Scratch Removal
- Image Upscaling (4K/8K)
- Noise Reduction
- Blur Correction

**Note:** Tool list is static for MVP. More restoration models can be added to the array in the future.

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
    static let restorationTools: [Tool] = [
        Tool(
            id: "historical_photo_restore",
            title: "Historical Photo Restore",
            imageUrl: URL(string: "preview_historical_restore"),
            category: "restoration",
            requiresPro: false,
            modelName: "codeformer",
            defaultParams: [
                "fidelity": 0.8,
                "upscale": 2
            ]
        )
    ]
    
    // Future expansion ready
    static func addRestorationTool(_ tool: Tool) -> [Tool] {
        var tools = restorationTools
        tools.append(tool)
        return tools
    }
}
```

**Usage in View:**
```swift
struct RestorationView: View {
    let tools = Tool.restorationTools
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(tools) { tool in
                ToolCard(tool: tool, onTap: handleToolTap)
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func handleToolTap(_ tool: Tool) {
        // Navigate to restoration workflow
        navigationPath.append(tool)
    }
}
```

---

## States & UX Rules

### Default State
- Single card displayed (centered in 2-column grid for now)
- Card fully visible with preview image
- Title displayed below preview
- Tap area: entire card (min 44×44pt per Apple HIG)

### PRO-Locked State
- Lock badge visible if tool requires PRO
- Badge position: top-right corner of circular preview
- Tap behavior: Present PaywallView (modal sheet)

### Loading State
- Circular progress spinner overlay on preview
- Disable tap interaction
- Dim card slightly (opacity 0.7)

### Selected/Pressed State
- Scale effect: 0.95× on press
- Haptic feedback: medium impact
- Animation duration: 0.15s

---

## Navigation Mapping

| Action | From Screen | To Screen | Parameters | Notes |
|--------|-------------|-----------|------------|-------|
| Tap ToolCard (free) | RestorationView | EditorView | `toolId: String, category: String` | Start restoration job |
| Tap ToolCard (PRO) | RestorationView | PaywallView | — | Present as modal sheet |
| Tap "Get PRO" | RestorationView | PaywallView | — | Present as modal sheet |
| Select category tab | RestorationView | MainToolsView/ProLooksView | `categoryId: String` | Switch tab content |
| Tap bottom tab | RestorationView | ChatView/HistoryView | — | Root tab switch |

---

## API Integration

### Fetch Restoration Tools (Future Enhancement)
**Endpoint:** `GET /api/v1/tools?category=restoration`

**Response:**
```json
{
  "tools": [
    {
      "id": "historical_photo_restore",
      "title": "Historical Photo Restore",
      "imageUrl": "https://cdn.example.com/previews/historical_restore.jpg",
      "category": "restoration",
      "requiresPro": false,
      "modelName": "codeformer",
      "defaultParams": {
        "fidelity": 0.8,
        "upscale": 2
      }
    }
  ],
  "totalCount": 1,
  "hasMore": false
}
```

**For MVP:** Use static array in Swift. See MODELS_CATALOG.md for complete model mappings.

---

## Implementation Checklist

### Design Compliance
- [ ] Confirm exact colors match Main Tools/Pro Looks tabs
- [ ] Verify typography scales on all device sizes
- [ ] Test dark mode contrast ratios (WCAG AA)
- [ ] Ensure tap target ≥44×44pt (card meets this naturally)

### Functionality
- [ ] Integrate AsyncImage or Kingfisher for preview loading
- [ ] Implement PRO lock logic (check `Adapty.getProfile()`)
- [ ] Handle card tap navigation (free → EditorView, PRO → PaywallView)
- [ ] Add haptic feedback on tap
- [ ] Implement category tab switching

### Performance
- [ ] Use `LazyVGrid` for lazy loading (scalable for future tools)
- [ ] Cache preview images with Kingfisher
- [ ] Profile scrolling FPS (target: 60fps)

### Accessibility
- [ ] VoiceOver labels for card and buttons
- [ ] Dynamic Type support (scale fonts)
- [ ] High contrast mode support
- [ ] Test with VoiceOver enabled

---

## Next Actions

1. **Implement SwiftUI Scaffold:**  
   Use `RestorationView.swift` scaffold. Reuse ToolCard component from Main Tools/Pro Looks.

2. **Test Historical Photo Restore Model:**  
   Verify CodeFormer or GFPGAN integration with backend. See MODELS_CATALOG.md for API specs.

3. **Plan Future Restoration Tools:**  
   - Photo Colorization (research models: DeOldify, Colorful Image Colorization)
   - Scratch Removal (inpainting models)
   - Image Upscaling (Real-ESRGAN, Topaz Labs)

4. **Update Backend:**  
   Ensure `/api/v1/jobs` endpoint supports `restoration` category and CodeFormer/GFPGAN models.

---

**Document Status:** ✅ Production-Ready  
**iOS Target:** ✅ iOS 13+ (SwiftUI)  
**Pattern Consistency:** ✅ Matches Main Tools/Pro Looks grid pattern  
**Scalability:** ✅ Prepared for multiple tools (2-column grid maintained)

