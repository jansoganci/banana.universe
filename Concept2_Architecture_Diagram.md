# 🏗️ Concept 2: Architecture Diagram
## Card Stack with Featured Tools

---

## 📊 **Current vs. New Architecture**

### **Current Architecture (Before)**
```
HomeView
├── UnifiedHeaderBar
├── CategoryTabs
└── ScrollView
    └── LazyVGrid
        └── ForEach(currentTools)
            └── ToolCard
```

### **New Architecture (After)**
```
HomeView
├── UnifiedHeaderBar (unchanged)
├── CategoryTabs (unchanged)
└── ScrollView
    ├── FeaturedToolCard (new)
    └── ToolGridSection (new)
        └── LazyVGrid
            └── ForEach(remainingTools)
                └── ToolCard (reused)
```

---

## 🧩 **Component Hierarchy**

```
┌─────────────────────────────────────────┐
│              HomeView                   │
│  ┌─────────────────────────────────────┐ │
│  │        UnifiedHeaderBar             │ │ ← Unchanged
│  └─────────────────────────────────────┘ │
│  ┌─────────────────────────────────────┐ │
│  │          CategoryTabs               │ │ ← Unchanged
│  └─────────────────────────────────────┘ │
│  ┌─────────────────────────────────────┐ │
│  │            ScrollView               │ │
│  │  ┌─────────────────────────────────┐ │ │
│  │  │      FeaturedToolCard           │ │ │ ← New Component
│  │  │  ┌─────────────────────────────┐ │ │ │
│  │  │  │     Featured Badge          │ │ │ │
│  │  │  │     Tool Title              │ │ │ │
│  │  │  │     Tool Icon (Large)       │ │ │ │
│  │  │  │     Description             │ │ │ │
│  │  │  │  [Use Tool] [Learn More]    │ │ │ │
│  │  │  └─────────────────────────────┘ │ │ │
│  │  └─────────────────────────────────┘ │ │
│  │  ┌─────────────────────────────────┐ │ │
│  │  │      ToolGridSection            │ │ │ ← New Wrapper
│  │  │  ┌─────────────────────────────┐ │ │ │
│  │  │  │        LazyVGrid            │ │ │ │
│  │  │  │  ┌─────┐ ┌─────┐ ┌─────┐    │ │ │ │
│  │  │  │  │Tool1│ │Tool2│ │Tool3│    │ │ │ │
│  │  │  │  └─────┘ └─────┘ └─────┘    │ │ │ │
│  │  │  │  ┌─────┐ ┌─────┐ ┌─────┐    │ │ │ │
│  │  │  │  │Tool4│ │Tool5│ │Tool6│    │ │ │ │
│  │  │  │  └─────┘ └─────┘ └─────┘    │ │ │ │
│  │  │  └─────────────────────────────┘ │ │ │
│  │  └─────────────────────────────────┘ │ │
│  └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

---

## 🔄 **Data Flow Diagram**

```
┌─────────────────┐    ┌──────────────────────┐
│ selectedCategory│───▶│CategoryFeaturedMapping│
└─────────────────┘    └──────────────────────┘
                                │
                                ▼
                    ┌──────────────────────┐
                    │    featuredTool      │
                    └──────────────────────┘
                                │
                                ▼
                    ┌──────────────────────┐
                    │  FeaturedToolCard    │
                    └──────────────────────┘

┌─────────────────┐    ┌──────────────────────┐
│ selectedCategory│───▶│CategoryFeaturedMapping│
└─────────────────┘    └──────────────────────┘
                                │
                                ▼
                    ┌──────────────────────┐
                    │   remainingTools     │
                    └──────────────────────┘
                                │
                                ▼
                    ┌──────────────────────┐
                    │   ToolGridSection    │
                    │        │             │
                    │        ▼             │
                    │    LazyVGrid         │
                    │        │             │
                    │        ▼             │
                    │   ForEach(tools)     │
                    │        │             │
                    │        ▼             │
                    │    ToolCard[]        │
                    └──────────────────────┘
```

---

## 📱 **Responsive Layout Behavior**

### **iPhone SE (375px)**
```
┌─────────────────────────────────────────┐
│ 🍌 BananaUniverse    [Get Pro]         │
├─────────────────────────────────────────┤
│ [Main Tools] [Pro Looks] [Restoration] │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │        🏆 FEATURED TOOL             │ │ ← Featured Card
│ │        Remove Object                │ │   (Full width)
│ │    Most Popular This Week           │ │
│ │         🔧                         │ │
│ │    [Use Tool] [Learn More]         │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────┐ ┌─────────┐                │
│ │ Remove  │ │ Put on  │                │ ← 2-Column Grid
│ │ Bg      │ │ Models  │                │
│ │   ✂️    │ │   👤    │                │
│ └─────────┘ └─────────┘                │
└─────────────────────────────────────────┘
```

### **iPhone 14 (390px)**
```
┌─────────────────────────────────────────┐
│ 🍌 BananaUniverse    [Get Pro]         │
├─────────────────────────────────────────┤
│ [Main Tools] [Pro Looks] [Restoration] │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │        🏆 FEATURED TOOL             │ │ ← Featured Card
│ │        Remove Object                │ │   (Full width)
│ │    Most Popular This Week           │ │
│ │         🔧                         │ │
│ │    [Use Tool] [Learn More]         │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐    │
│ │ Remove  │ │ Put on  │ │  Add    │    │ ← 3-Column Grid
│ │ Bg      │ │ Models  │ │Objects  │    │
│ │   ✂️    │ │   👤    │ │   ➕    │    │
│ └─────────┘ └─────────┘ └─────────┘    │
└─────────────────────────────────────────┘
```

### **iPhone 14 Plus (428px)**
```
┌─────────────────────────────────────────┐
│ 🍌 BananaUniverse    [Get Pro]         │
├─────────────────────────────────────────┤
│ [Main Tools] [Pro Looks] [Restoration] │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │        🏆 FEATURED TOOL             │ │ ← Featured Card
│ │        Remove Object                │ │   (Full width)
│ │    Most Popular This Week           │ │
│ │         🔧                         │ │
│ │    [Use Tool] [Learn More]         │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌───┐│
│ │ Remove  │ │ Put on  │ │  Add    │ │Chg││ ← 4-Column Grid
│ │ Bg      │ │ Models  │ │Objects  │ │Per││
│ │   ✂️    │ │   👤    │ │   ➕    │ │ 🔄││
│ └─────────┘ └─────────┘ └─────────┘ └───┘│
└─────────────────────────────────────────┘
```

---

## 🎭 **Animation Flow**

### **Category Switch Animation**
```
┌─────────────────────────────────────────┐
│              Before                     │
│ ┌─────────────────────────────────────┐ │
│ │      Featured Tool A                │ │ ← Fade out + scale down
│ └─────────────────────────────────────┘ │
│ ┌─────┐ ┌─────┐ ┌─────┐                │
│ │Tool1│ │Tool2│ │Tool3│                │ ← Fade out
│ └─────┘ └─────┘ └─────┘                │
└─────────────────────────────────────────┘
                │
                ▼ (0.3s spring animation)
┌─────────────────────────────────────────┐
│              After                      │
│ ┌─────────────────────────────────────┐ │
│ │      Featured Tool B                │ │ ← Fade in + scale up
│ └─────────────────────────────────────┘ │
│ ┌─────┐ ┌─────┐ ┌─────┐                │
│ │Tool4│ │Tool5│ │Tool6│                │ ← Fade in
│ └─────┘ └─────┘ └─────┘                │
└─────────────────────────────────────────┘
```

### **Featured Card Hover Animation**
```
┌─────────────────────────────────────────┐
│              Normal State               │
│ ┌─────────────────────────────────────┐ │
│ │      Featured Tool                  │ │ ← Scale: 1.0
│ │         🔧                         │ │   Shadow: 2px
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
                │
                ▼ (0.2s easeOut)
┌─────────────────────────────────────────┐
│              Hover State                │
│ ┌─────────────────────────────────────┐ │
│ │      Featured Tool                  │ │ ← Scale: 1.02
│ │         🔧                         │ │   Shadow: 4px
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

---

## 🔧 **Component Dependencies**

### **FeaturedToolCard Dependencies**
```
FeaturedToolCard
├── Tool (data model)
├── DesignTokens (styling)
├── PrimaryButton (CTA buttons)
├── AppCard (base card component)
└── ThemeManager (theme support)
```

### **ToolGridSection Dependencies**
```
ToolGridSection
├── [Tool] (data array)
├── ToolCard (individual cards)
├── DesignTokens (spacing, layout)
└── ThemeManager (theme support)
```

### **CategoryFeaturedMapping Dependencies**
```
CategoryFeaturedMapping
├── Tool (data model)
└── Tool.mainTools/proLooksTools/restorationTools
```

---

## 📋 **File Structure After Implementation**

```
BananaUniverse/
├── Features/
│   └── Home/
│       └── Views/
│           └── HomeView.swift (refactored)
├── Core/
│   ├── Components/
│   │   ├── FeaturedToolCard/
│   │   │   └── FeaturedToolCard.swift (new)
│   │   ├── ToolGridSection/
│   │   │   └── ToolGridSection.swift (new)
│   │   ├── ToolCard/
│   │   │   └── ToolCard.swift (unchanged)
│   │   └── UnifiedHeaderBar.swift (unchanged)
│   ├── Models/
│   │   └── Tool.swift (add utility methods)
│   └── Utils/
│       └── CategoryFeaturedMapping.swift (new)
```

---

## 🎯 **Key Implementation Points**

### **1. Featured Tool Selection Logic**
- **Main Tools**: "Remove Object" (most popular, free)
- **Pro Looks**: "LinkedIn Headshot" (most valuable, premium)
- **Restoration**: "Image Upscaler" (most useful, free)

### **2. Responsive Grid Calculation**
```swift
func calculateColumns(for width: CGFloat) -> Int {
    switch width {
    case 0..<390: return 2
    case 390..<428: return 3
    case 428..<768: return 4
    default: return 5
    }
}
```

### **3. Animation Timing**
- **Featured card transition**: 0.4s spring
- **Grid update**: 0.3s easeInOut
- **Category switch**: 0.3s spring
- **Card hover**: 0.2s easeOut

### **4. State Management**
- Keep existing `@State` variables
- Add computed properties for featured/remaining tools
- Maintain existing callback patterns

---

*This architecture diagram provides a clear visual representation of the new component structure and data flow for Concept 2 implementation.*
