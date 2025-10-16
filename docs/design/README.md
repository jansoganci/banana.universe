# Design System — noname_banana

**Version:** 2.0  
**Last Updated:** 2025-10-12  
**iOS Target:** iOS 13.0+  
**Status:** PRODUCTION STANDARD

---

## Summary

Native SwiftUI design system following Apple HIG. Dark theme default, SF Pro typography, 8pt grid, 44pt minimum tap targets.

---

## Design Principles

1. **Apple HIG Compliance** — Follow iOS design patterns exactly
2. **Native Feel** — Use system fonts, colors, animations
3. **Accessibility First** — VoiceOver, Dynamic Type, High Contrast
4. **Dark Mode Default** — Optimized for dark environments

---

## Color System

### Dark Theme (Primary)

| Token | Hex | SwiftUI | Usage |
|-------|-----|---------|-------|
| `background` | `#0E1012` | `.black` | Screen background |
| `surface` | `#2C2F32` | `.gray.opacity(0.2)` | Card backgrounds |
| `primary` | `#4D7CFF` | `.blue` | Primary buttons, CTAs |
| `accent` | `#33C3A4` | `.green` | Active states, success |
| `textPrimary` | `#FFFFFF` | `.primary` | Main text |
| `textSecondary` | `#A0A9B0` | `.secondary` | Captions, hints |
| `error` | `#FF4444` | `.red` | Error states |

### SwiftUI Implementation

```swift
extension Color {
    static let appBackground = Color(hex: "0E1012")
    static let appSurface = Color(hex: "2C2F32")
    static let appPrimary = Color(hex: "4D7CFF")
    static let appAccent = Color(hex: "33C3A4")
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}
```

---

## Typography

### Font Scale (SF Pro)

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `title` | 28pt | Bold | Screen titles |
| `headline` | 22pt | Semibold | Section headers |
| `body` | 17pt | Regular | Body text (Apple HIG standard) |
| `callout` | 16pt | Regular | Secondary body |
| `subheadline` | 15pt | Regular | Captions |
| `footnote` | 13pt | Regular | Small text |
| `caption` | 12pt | Regular | Metadata |

### SwiftUI Implementation

```swift
Text("Screen Title")
    .font(.system(size: 28, weight: .bold))

Text("Body text")
    .font(.body) // Use system font for Dynamic Type support
```

### Dynamic Type Support

```swift
Text("Accessible text")
    .font(.body)
    .dynamicTypeSize(...DynamicTypeSize.accessibility3) // Cap at max size
```

---

## Spacing & Layout

### 8pt Grid System

| Token | Value | Usage |
|-------|-------|-------|
| `spacing-xs` | 4pt | Tight spacing (icon-to-text) |
| `spacing-sm` | 8pt | Small gaps |
| `spacing-md` | 16pt | Standard padding |
| `spacing-lg` | 24pt | Section gaps |
| `spacing-xl` | 32pt | Large gaps |
| `spacing-xxl` | 48pt | Screen margins |

### SwiftUI Implementation

```swift
VStack(spacing: 16) { // spacing-md
    Text("Title")
    Text("Body")
}
.padding(.horizontal, 16) // spacing-md
```

---

## Component Library

### Button Styles

#### Primary Button
```swift
Button("Continue") {
    // Action
}
.buttonStyle(PrimaryButtonStyle())

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.appPrimary)
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
```

#### Secondary Button
```swift
Button("Cancel") {
    // Action
}
.buttonStyle(SecondaryButtonStyle())

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(.appPrimary)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.appPrimary.opacity(0.1))
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}
```

---

### Card Component

```swift
struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(16)
            .background(Color.appSurface)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// Usage
CardView {
    VStack(alignment: .leading, spacing: 8) {
        Text("Card Title")
            .font(.headline)
        Text("Card content")
            .font(.body)
            .foregroundColor(.secondary)
    }
}
```

---

### Loading State

```swift
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Processing...")
                .font(.callout)
                .foregroundColor(.secondary)
        }
    }
}
```

---

## Navigation Patterns

### Tab Bar Navigation

```swift
struct RootTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                }
                .tag(1)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(2)
        }
        .accentColor(.appAccent)
    }
}
```

### Stack Navigation

```swift
NavigationView {
    MainToolsView()
        .navigationTitle("noname_banana")
        .navigationBarTitleDisplayMode(.inline)
}
```

---

## Accessibility

### Tap Targets

**Apple HIG Requirement:** Minimum 44×44pt for interactive elements.

```swift
Button("Tap me") {
    // Action
}
.frame(minWidth: 44, minHeight: 44)
```

### VoiceOver Labels

```swift
Image(systemName: "photo")
    .accessibilityLabel("Upload photo")
    .accessibilityHint("Opens photo picker")

Button("") {
    // Action
}
.accessibilityLabel("Delete item")
```

### Dynamic Type

```swift
Text("Body text")
    .font(.body) // Scales with user settings
```

### High Contrast

```swift
@Environment(\.colorSchemeContrast) var contrast

var borderColor: Color {
    contrast == .increased ? .white : .gray
}
```

---

## Animations

### Standard Durations

| Type | Duration | Usage |
|------|----------|-------|
| Quick | 0.2s | Button press |
| Standard | 0.3s | View transitions |
| Slow | 0.5s | Major screen changes |

### SwiftUI Implementation

```swift
// Button press
.animation(.easeInOut(duration: 0.2), value: isPressed)

// View transition
.transition(.opacity)
.animation(.easeInOut(duration: 0.3), value: showView)

// Sheet presentation
.sheet(isPresented: $showSheet) {
    // Content
}
```

---

## Screen Components

### Empty State

```swift
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let action = action {
                Button("Get Started") {
                    action()
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(maxWidth: 200)
            }
        }
        .padding(32)
    }
}
```

---

## Screen-Specific Docs

- [MainTools_README.md](MainTools_README.md) — Home/Tools screen
- [Chat_README.md](Chat_README.md) — Upload & job creation
- [History_README.md](History_README.md) — Past jobs list
- [Profile_README.md](Profile_README.md) — User settings
- [ProLooks_README.md](ProLooks_README.md) — Paywall/subscription

---

## Implementation Checklist

### Design Tokens
- [ ] Color palette defined in Assets.xcassets
- [ ] SF Pro font used (system default)
- [ ] 8pt grid spacing constants
- [ ] Dark mode colors configured

### Components
- [ ] Primary/Secondary button styles
- [ ] Card component
- [ ] Loading spinner
- [ ] Empty state view
- [ ] Error state view

### Accessibility
- [ ] All buttons ≥ 44×44pt
- [ ] VoiceOver labels on all interactive elements
- [ ] Dynamic Type support
- [ ] High contrast mode tested

### Navigation
- [ ] Tab bar navigation (3 tabs)
- [ ] NavigationView/NavigationStack
- [ ] Modal sheets (.sheet)
- [ ] Alerts (.alert)

---

## Related Docs

- [PROJECT_SPEC.md](/docs/PROJECT_SPEC.md) — Master specification
- [tech_stack.md](/docs/tech_stack.md) — Tech stack details

---

**Status:** ✅ Production-Ready Design System  
**Next Steps:** Implement components, test accessibility, deploy to TestFlight
