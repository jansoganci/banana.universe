# 🎨 Home Screen Wireframes
## Visual Design Concepts

---

## Current State
```
┌─────────────────────────────────────────┐
│ 🍌 BananaUniverse    [Get Pro]         │
├─────────────────────────────────────────┤
│ [Main Tools] [Pro Looks] [Restoration] │
├─────────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐                │
│ │ Remove  │ │ Remove  │                │
│ │ Object  │ │ Bg      │                │
│ │    🔧   │ │   ✂️    │                │
│ └─────────┘ └─────────┘                │
│ ┌─────────┐ ┌─────────┐                │
│ │ Put on  │ │  Add    │                │
│ │ Models  │ │Objects  │                │
│ │   👤    │ │   ➕    │                │
│ └─────────┘ └─────────┘                │
│ ┌─────────┐ ┌─────────┐                │
│ │Change   │ │Generate │                │
│ │Perspect │ │Series   │                │
│ │   🔄    │ │   🔢    │                │
│ └─────────┘ └─────────┘                │
│ ┌─────────┐                            │
│ │ Style   │                            │
│ │Transfer │                            │
│ │   🎨    │                            │
│ └─────────┘                            │
└─────────────────────────────────────────┘
```

---

## Concept 1: Adaptive Grid System
```
┌─────────────────────────────────────────┐
│ 🍌 BananaUniverse    [Get Pro]         │
├─────────────────────────────────────────┤
│ [Main Tools] [Pro Looks] [Restoration] │
├─────────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐ ┌─────────┐    │
│ │ Remove  │ │ Remove  │ │ Put on  │    │
│ │ Object  │ │ Bg      │ │ Models  │    │
│ │    🔧   │ │   ✂️    │ │   👤    │    │
│ │  ⭐⭐⭐  │ │  ⭐⭐   │ │  ⭐⭐⭐  │    │
│ └─────────┘ └─────────┘ └─────────┘    │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐    │
│ │  Add    │ │Change   │ │Generate │    │
│ │Objects  │ │Perspect │ │Series   │    │
│ │   ➕    │ │   🔄    │ │   🔢    │    │
│ │  ⭐⭐   │ │  ⭐     │ │  ⭐⭐   │    │
│ └─────────┘ └─────────┘ └─────────┘    │
│ ┌─────────┐                            │
│ │ Style   │                            │
│ │Transfer │                            │
│ │   🎨    │                            │
│ │  ⭐     │                            │
│ └─────────┘                            │
└─────────────────────────────────────────┘
```

**Key Features:**
- 3-column adaptive grid
- Usage frequency stars (⭐⭐⭐)
- Consistent card sizing
- Smart spacing

---

## Concept 2: Card Stack with Featured Tools
```
┌─────────────────────────────────────────┐
│ 🍌 BananaUniverse    [Get Pro]         │
├─────────────────────────────────────────┤
│ [Main Tools] [Pro Looks] [Restoration] │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │        🏆 FEATURED TOOL             │ │
│ │        Remove Object                │ │
│ │    Most Popular This Week           │ │
│ │         🔧                         │ │
│ │    [Use Tool] [Learn More]         │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐    │
│ │ Remove  │ │ Put on  │ │  Add    │    │
│ │ Bg      │ │ Models  │ │Objects  │    │
│ │   ✂️    │ │   👤    │ │   ➕    │    │
│ └─────────┘ └─────────┘ └─────────┘    │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐    │
│ │Change   │ │Generate │ │ Style   │    │
│ │Perspect │ │Series   │ │Transfer │    │
│ │   🔄    │ │   🔢    │ │   🎨    │    │
│ └─────────┘ └─────────┘ └─────────┘    │
└─────────────────────────────────────────┘
```

**Key Features:**
- Hero featured tool card
- Contextual recommendations
- Action buttons on featured card
- Balanced visual hierarchy

---

## Concept 3: Progressive Disclosure Grid
```
┌─────────────────────────────────────────┐
│ 🍌 BananaUniverse    [Get Pro]         │
├─────────────────────────────────────────┤
│ [Main Tools] [Pro Looks] [Restoration] │
├─────────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐ ┌─────────┐    │
│ │ Remove  │ │ Remove  │ │ Put on  │    │
│ │ Object  │ │ Bg      │ │ Models  │    │
│ │    🔧   │ │   ✂️    │ │   👤    │    │
│ │  ⭐⭐⭐  │ │  ⭐⭐   │ │  ⭐⭐⭐  │    │
│ └─────────┘ └─────────┘ └─────────┘    │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐    │
│ │  Add    │ │Change   │ │Generate │    │
│ │Objects  │ │Perspect │ │Series   │    │
│ │   ➕    │ │   🔄    │ │   🔢    │    │
│ │  ⭐⭐   │ │  ⭐     │ │  ⭐⭐   │    │
│ └─────────┘ └─────────┘ └─────────┘    │
│ ┌─────────────────────────────────────┐ │
│ │        Show More Tools (3)          │ │
│ │         [Expand ▼]                  │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

**Key Features:**
- Initial 6 tools shown
- Collapsible additional tools
- Clear expansion indicator
- Reduced cognitive load

---

## Enhanced Category Tabs
```
┌─────────────────────────────────────────┐
│ [Main Tools 7] [Pro Looks 10] [Restore 2] │
│     ⭐⭐⭐      ⭐⭐        ⭐⭐⭐    │
└─────────────────────────────────────────┘
```

**Features:**
- Tool count badges
- Usage frequency indicators
- Smooth animated transitions
- Smart ordering based on usage

---

## Tool Card Variations

### Standard Card
```
┌─────────┐
│ Remove  │
│ Object  │
│    🔧   │
│  ⭐⭐⭐  │
└─────────┘
```

### Featured Card
```
┌─────────────────┐
│   🏆 FEATURED   │
│   Remove Object │
│      🔧         │
│  Most Popular   │
│ [Use] [Learn]   │
└─────────────────┘
```

### Compact Card
```
┌─────┐
│ 🔧  │
│Remove│
│ ⭐⭐⭐│
└─────┘
```

---

## Animation States

### Card Hover
```
Normal:  ┌─────────┐
         │ Remove  │
         │ Object  │
         │    🔧   │
         └─────────┘

Hover:   ┌─────────┐
         │ Remove  │  ← Scale 1.02
         │ Object  │  ← Shadow +2px
         │    🔧   │
         └─────────┘
```

### Category Transition
```
From: [Main Tools] [Pro Looks] [Restoration]
To:   [Main Tools] [Pro Looks] [Restoration]
      ← Slide animation (0.3s spring)
```

---

## Responsive Breakpoints

### iPhone SE (375px)
```
┌─────────┐ ┌─────────┐
│ Tool 1  │ │ Tool 2  │
└─────────┘ └─────────┘
┌─────────┐ ┌─────────┐
│ Tool 3  │ │ Tool 4  │
└─────────┘ └─────────┘
```

### iPhone 14 (390px)
```
┌─────────┐ ┌─────────┐ ┌─────────┐
│ Tool 1  │ │ Tool 2  │ │ Tool 3  │
└─────────┘ └─────────┘ └─────────┘
┌─────────┐ ┌─────────┐
│ Tool 4  │ │ Tool 5  │
└─────────┘ └─────────┘
```

### iPhone 14 Plus (428px)
```
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│ Tool 1  │ │ Tool 2  │ │ Tool 3  │ │ Tool 4  │
└─────────┘ └─────────┘ └─────────┘ └─────────┘
┌─────────┐ ┌─────────┐ ┌─────────┐
│ Tool 5  │ │ Tool 6  │ │ Tool 7  │
└─────────┘ └─────────┘ └─────────┘
```

---

*These wireframes illustrate the three main concepts while maintaining the existing header, navigation, and design system. Each concept offers different benefits for user experience and scalability.*
