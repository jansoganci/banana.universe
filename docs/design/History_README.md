# History Screen — Design Documentation

**Screen Name:** History (Bottom Tab Right)  
**Type:** List view of past editing jobs  
**Theme:** Dark  
**iOS Target:** iOS 13.0+ (FINALIZED)  
**Purpose:** View editing history, re-run jobs, share/delete results

---

## Overview

The History tab displays a chronological list of the user's past image edits. If there are no edits, show an "empty state" message: **"No editing history found"**.

**Layout & UI:**
- **Header:** Title "History" (center), Profile button (top-right, user icon, opens Profile screen)
- **Main Area:**
  - **Empty state:** Centered message if no edits exist
  - **List state:** Display each job with thumbnail, edit date, status (completed/failed), tap to view result
- **Bottom Tab Bar:** Home, Chat, **History (active)**

**User Flow:**
1. User lands on History tab
2. **If no jobs:** Show empty state message ("No editing history found")
3. **If jobs exist:** List them with thumbnails, tap to view details, swipe to delete
4. Tap Profile icon (top-right) → Opens Profile screen

**Data Retention:**
- Free users: 30 days retention
- PRO users: 365 days retention
- Jobs auto-deleted after retention period (S3 lifecycle + DB cleanup)

---

## Component Breakdown

### 1. HeaderBar
**Purpose:** Screen title + profile access

**Elements:**
- `titleLabel`: "History" (centered, 18pt semibold)
- `profileButton`: User icon (SF Symbol: "person.circle" or custom avatar, top-right)

**Behavior:**
- Tap profile icon → Navigate to Profile screen

**Props:**
```swift
struct HistoryHeaderBarProps {
    let title: String                // "History"
    let userAvatarUrl: URL?          // Optional avatar image
    let onProfileTap: () -> Void     // Navigate to ProfileView
}
```

**Visual:**
- Background: #1A1C1E (header background)
- Height: ~56pt (including safe area)
- Title: SF Pro Semibold, 18pt, centered
- Profile icon: 32×32pt circle (44×44pt tap target), 16pt trailing padding

---

### 2. Empty State
**Purpose:** Inform user when no history exists

**Elements:**
- Large icon (SF Symbol: "clock" or "photo.on.rectangle.angled", 64pt)
- Primary message: **"No editing history found"** (18pt, medium, centered)
- Secondary text (optional): "Your AI edits will appear here" (14pt, regular, muted)

**Visual:**
- Centered vertically and horizontally in main area
- Icon: #6A6C6E (muted gray), 64pt
- Primary text: SF Pro Medium, 18pt, #C8DAFF
- Secondary text: SF Pro Regular, 14pt, #A0A9B0
- Spacing: 16pt between icon and text

**Code Example:**
```swift
struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock")
                .font(.system(size: 64))
                .foregroundColor(Color(hex: "6A6C6E"))
            
            Text("No editing history found")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(hex: "C8DAFF"))
            
            Text("Your AI edits will appear here")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "A0A9B0"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

---

### 3. HistoryList
**Purpose:** Scrollable list of past editing jobs

**Layout:**
- Vertical list (SwiftUI List or ScrollView + LazyVStack)
- Divider lines between items (1px, #rgba(255,255,255,0.06))
- Pull-to-refresh (reload latest jobs from API)

---

### 4. HistoryItemRow
**Purpose:** Individual history entry with actions

**Elements:**
- **Left:** Thumbnail (80×80pt rounded square or circular)
- **Center:** 
  - Effect title (e.g., "Face Enhancement")
  - Job status badge (Completed, Processing, Failed)
  - Date/time (e.g., "2 hours ago" or "Oct 12, 2025")
- **Right:** Action buttons (Re-run, Share, Delete) or overflow menu (•••)

**Props:**
```swift
struct HistoryItem: Identifiable, Codable {
    let id: String                   // jobId
    let thumbnailUrl: URL?           // Result image (or original if failed)
    let effectTitle: String          // "Face Enhancement"
    let effectId: String             // For re-run
    let status: JobStatus            // .completed, .processing, .failed, .cancelled
    let createdAt: Date
    let resultUrl: URL?              // Full-resolution result
    let originalImageKey: String?    // For re-run
}

enum JobStatus: String, Codable {
    case completed
    case processing
    case failed
    case cancelled
}

struct HistoryItemRowProps {
    let item: HistoryItem
    let onTap: (HistoryItem) -> Void        // Navigate to ResultView
    let onRerun: (HistoryItem) -> Void      // Create new job
    let onShare: (HistoryItem) -> Void      // Share sheet
    let onDelete: (HistoryItem) -> Void     // Confirm + delete
}
```

**Visual:**
- Row height: ~100pt
- Thumbnail: 80×80pt, 8pt corner radius
- Spacing: 12pt between thumbnail and text
- Status badge: pill shape, 8pt horizontal padding, 4pt vertical
  - Completed: green (#33C3A4)
  - Processing: blue (#4D7CFF)
  - Failed: red (#FF4444)
- Action buttons: 32×32pt tap targets, icon-only

---

## Design Tokens

### Colors (Dark Theme)

| Token Name | Hex Value | Usage | SwiftUI Asset |
|------------|-----------|-------|---------------|
| `background` | `#0E1012` | Main screen background | `background` |
| `headerBackground` | `#1A1C1E` | Header bar background | `headerBackground` |
| `cardBackground` | `#2C2F32` | Row background (optional hover state) | `cardBackground` |
| `divider` | `rgba(255,255,255,0.06)` | Row divider lines | `divider` |
| `titleText` | `#C8DAFF` | Effect titles, primary text | `titleText` |
| `secondaryText` | `#A0A9B0` | Date/time, secondary info | `secondaryText` |
| `statusCompleted` | `#33C3A4` | Completed badge (mint green) | `statusCompleted` |
| `statusProcessing` | `#4D7CFF` | Processing badge (blue) | `statusProcessing` |
| `statusFailed` | `#FF4444` | Failed badge (red) | `statusFailed` |
| `emptyStateIcon` | `#6A6C6E` | Empty state icon (muted gray) | `emptyStateIcon` |

---

### Typography

| Style | Font | Size (pt) | Weight | Usage |
|-------|------|-----------|--------|-------|
| `header-title` | SF Pro | 18 | Semibold | Screen title "History" |
| `effect-title` | SF Pro | 16 | Semibold | Effect name in row |
| `status-badge` | SF Pro | 11 | Medium | Job status text |
| `date-time` | SF Pro | 13 | Regular | Relative date ("2 hours ago") |
| `empty-state-primary` | SF Pro | 18 | Medium | Empty state title |
| `empty-state-secondary` | SF Pro | 14 | Regular | Empty state subtitle |

---

### Spacing & Layout

| Token | Value (pt) | Usage |
|-------|------------|-------|
| `spacing-xs` | 8 | Thumbnail corner radius, badge padding |
| `spacing-sm` | 12 | Thumbnail-to-text gap |
| `spacing-md` | 16 | Row vertical padding, empty state spacing |
| `spacing-lg` | 24 | Section gaps |

**Component-Specific:**
- **Row Height:** ~100pt (dynamic, content-dependent)
- **Thumbnail Size:** 80×80pt
- **Thumbnail Corner Radius:** 8pt
- **Action Button Size:** 32×32pt (tap target)
- **Divider Thickness:** 1px
- **Header Height:** 56pt

---

## States & UX Rules

### 1. Empty State
**When:** User has no editing history (new user or cleared history)

**Visual:**
- Centered icon + text (as described above)
- No list, no pull-to-refresh indicator

**Behavior:**
- No interactive elements (except tab bar)
- Animate in with fade (optional)

---

### 2. Loading State
**When:** Initial fetch from API or pull-to-refresh

**Visual:**
- Show activity indicator (center or top of list)
- Dim existing rows slightly (opacity 0.7) during refresh

**Behavior:**
- Disable tap interactions on rows
- Pull-to-refresh indicator active

---

### 3. Loaded State (Normal)
**When:** History items successfully fetched

**Visual:**
- List of rows with thumbnails, titles, dates, action buttons
- Smooth scrolling, lazy loading

**Behavior:**
- Tap row → Navigate to ResultView (full-screen preview + export)
- Tap Re-run → Create new job with same effect + parameters
- Tap Share → Present system share sheet (UIActivityViewController)
- Tap Delete → Show confirmation alert → Delete via API

---

### 4. Item-Loading State (Re-run in Progress)
**When:** User taps Re-run, job is queued

**Visual:**
- Show spinner overlay on that specific row
- Disable action buttons on that row
- Optional: optimistically add new row at top (status: processing)

**Behavior:**
- Poll job status or use WebSocket for updates
- Navigate to EditorView or show success toast

---

### 5. Error State
**When:** API fetch fails (network error, 500, etc.)

**Visual:**
- Show error message in center or at top of list
- Retry button or automatic retry after 3s

**Behavior:**
- Preserve cached data if available (offline mode)
- Show toast: "Failed to load history. Tap to retry."

---

## Data Model

### HistoryItem (Swift)
```swift
struct HistoryItem: Identifiable, Codable {
    let id: String                   // jobId (e.g., "job_abc123")
    let thumbnailUrl: URL?           // Thumbnail (200×200 optimized)
    let effectTitle: String          // "Face Enhancement", "Background Removal"
    let effectId: String             // For re-run API call
    let status: JobStatus            // .completed, .processing, .failed, .cancelled
    let createdAt: Date              // ISO 8601 timestamp
    let resultUrl: URL?              // Full-resolution result (if completed)
    let originalImageKey: String?    // S3 key for re-run
    let parameters: [String: AnyCodable]? // Model parameters (optional)
}

enum JobStatus: String, Codable {
    case completed
    case processing
    case failed
    case cancelled
}
```

---

## API Integration

### 1. Fetch History
**Endpoint:** `GET /api/v1/history`

**Query Params:**
- `limit`: 50 (default)
- `offset`: 0 (pagination)
- `status`: "completed" | "processing" | "failed" (optional filter)

**Response:**
```json
{
  "items": [
    {
      "id": "job_abc123",
      "thumbnailUrl": "https://cdn.example.com/thumbs/abc123.jpg",
      "effectTitle": "Face Enhancement",
      "effectId": "effect_face_001",
      "status": "completed",
      "createdAt": "2025-10-12T10:30:00Z",
      "resultUrl": "https://cdn.example.com/results/abc123.jpg",
      "originalImageKey": "uuid-original-key"
    }
  ],
  "totalCount": 120,
  "hasMore": true
}
```

---

### 2. Delete History Item
**Endpoint:** `DELETE /api/v1/history/{jobId}`

**Response:**
```json
{
  "success": true,
  "deletedItemId": "job_abc123"
}
```

**Client Behavior:**
- Optimistically remove row from UI
- Rollback if API fails (show toast, re-insert row)

---

### 3. Re-run Job
**Endpoint:** `POST /api/v1/jobs`

**Request:**
```json
{
  "imageKey": "uuid-original-key",
  "effectId": "effect_face_001",
  "parameters": {
    "fidelity": 0.8,
    "upscale": 2
  }
}
```

**Response:**
```json
{
  "jobId": "job_new_456",
  "status": "queued"
}
```

**Client Behavior:**
- Decrement free credits (if applicable)
- Navigate to EditorView with new jobId
- Or: optimistically add new row at top of list (status: processing)

---

## Navigation Mapping

| Action | From | To | Parameters | Notes |
|--------|------|----|-----------|----|
| Tap row | HistoryView | ResultView | `jobId: String` | Full-screen preview + export |
| Tap Re-run | HistoryView | EditorView (or stay) | `jobId: String` | Create new job, navigate or toast |
| Tap Share | HistoryView | Share Sheet | `resultUrl: URL` | UIActivityViewController |
| Tap Delete | HistoryView | Confirmation Alert → API | `jobId: String` | Remove from list on success |
| Tap Profile | HistoryView | ProfileView | — | Top-right avatar/icon |

---

## Accessibility

### VoiceOver Labels
- **Row:** "{Effect title}, {status}, created {relative date}. Double-tap to view details."
- **Re-run button:** "Re-run job, button. Double-tap to create a new edit with the same settings."
- **Share button:** "Share result, button."
- **Delete button:** "Delete from history, button."
- **Empty state:** "No editing history found. Your AI edits will appear here."

### Tap Targets
- Row: entire row (100pt height, full width)
- Action buttons: 32×32pt minimum (meets 44pt guideline with padding)

### Dynamic Type
- Scale all text with user settings
- Test with XXXL (accessibility size 7)

### High Contrast Mode
- Increase divider opacity (0.06 → 0.15)
- Increase status badge contrast

---

## iOS Compatibility

### SwiftUI (iOS 13+)
```swift
List {
    ForEach(historyItems) { item in
        HistoryItemRow(item: item, ...)
    }
}
.refreshable {
    await refreshHistory()
}
```

### Pull-to-Refresh
- iOS 15+: `.refreshable { }` modifier
- iOS 13-14: Use custom `UIViewRepresentable` with `UIRefreshControl`

### iOS 12 Requirement (Not Supported)
- SwiftUI unavailable on iOS 12
- **UIKit Fallback:** Use `UITableView` or `UICollectionView`
- Custom `HistoryItemCell` subclass
- `UIRefreshControl` for pull-to-refresh
- Request UIKit scaffold if iOS 12 support is critical

---

## Implementation Checklist

### Design
- [ ] Confirm thumbnail size (80×80 vs 100×100)
- [ ] Verify status badge colors (contrast ratios)
- [ ] Test row height on small devices (iPhone SE)
- [ ] Validate divider visibility (subtle but visible)

### Functionality
- [ ] Integrate `GET /api/v1/history` endpoint
- [ ] Implement pull-to-refresh (iOS 15+ `.refreshable` or custom)
- [ ] Add delete confirmation alert ("Are you sure?")
- [ ] Implement share sheet (UIActivityViewController)
- [ ] Add re-run logic (POST /api/v1/jobs with cached params)
- [ ] Handle pagination (load more on scroll to bottom)

### Performance
- [ ] Use LazyVStack or List for efficient rendering
- [ ] Cache thumbnails with Kingfisher
- [ ] Limit initial fetch to 50 items (paginate remaining)
- [ ] Profile scrolling FPS (target: 60fps)

### Accessibility
- [ ] VoiceOver labels for all interactive elements
- [ ] Dynamic Type support
- [ ] High contrast mode adjustments
- [ ] Test with VoiceOver + keyboard navigation

### Error Handling
- [ ] Handle network errors (toast + retry)
- [ ] Handle empty results (show empty state)
- [ ] Handle delete failures (rollback + toast)
- [ ] Handle re-run failures (show alert, rollback credits)

---

## Next Actions

1. **Upload Editor + Result Screenshots:**  
   Send screenshots of EditorView (job progress, result preview) and ResultView (full-screen preview + export options).

2. **Confirm History Retention Policy:**  
   - How long to keep history? (30 days, 90 days, forever for PRO?)
   - Auto-delete oldest entries for free users? (max 50 entries)
   - Soft delete vs hard delete? (keep metadata for analytics)

3. **Provide API Documentation:**  
   Confirm endpoints for:
   - `GET /api/v1/history` (query params, response format)
   - `DELETE /api/v1/history/{jobId}` (soft delete or hard delete)
   - Re-run logic (use cached params or ask user to re-select?)

4. **Analytics Events:**  
   - Track: screen view (History)
   - Track: row tapped (navigate to result)
   - Track: re-run tapped (jobId, effectId)
   - Track: share tapped (platform: Instagram, Twitter, etc.)
   - Track: delete tapped (jobId)

---

**Document Status:** ✅ Production-Ready  
**iOS Target:** ✅ iOS 13+ (SwiftUI + List)  
**Key Features:**
- Empty state: "No editing history found"
- Job list with thumbnails (if history exists)
- Profile button (top-right header) → Opens Profile screen
- Swipe to delete jobs
- Tap job → View full result

