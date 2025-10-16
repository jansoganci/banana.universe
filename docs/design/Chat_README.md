# Chat Screen — Design Documentation

**Screen Name:** Chat (Bottom Tab Center)  
**Type:** Image upload/selection + AI edit initiation  
**Theme:** Dark  
**iOS Target:** iOS 13.0+ (FINALIZED)  
**Purpose:** Start new AI editing session by uploading/selecting photo

---

## Overview

The Chat tab serves as the image upload and edit initiation screen. Users see their remaining free edit quota prominently displayed and can upload photos to start AI-powered editing workflows.

**Key UI Elements:**
- **Header bar** with back button, brand logo ("NanoBanana"), and quota counter ("X Free Edits Left")
- **Main upload area** (center) with "Upload your photo" prompt and large tappable card
- **Bottom input bar** with attachment icon (left) and "PRO Creation" button (right)
- **Real-time quota tracking** — Updates immediately after each edit, blocks at 0 remaining

**User Flow:**
1. User lands on Chat tab → Sees quota ("2 Free Edits Left" at top-right)
2. User taps upload area → Image picker opens (PHPicker/Camera)
3. User selects image → Image preview appears, bottom input bar becomes enabled
4. User taps "PRO Creation" button → App uploads image via presigned URL
5. App creates job via `POST /api/v1/jobs` → Receives `jobId`
6. Navigate to ResultView with `jobId` → Show processing progress
7. On completion → Quota decrements automatically, result shown in History

**Quota & Blocking Flow:**
- **Quota visible at all times** — Real-time display in header ("X Free Edits Left")
- **Check quota before upload** — If quota = 0, block upload and show paywall
- **Decrement after job creation** — Update quota counter immediately (optimistic UI)
- **PRO users** — No quota display, unlimited edits
- **Rollback on error** — If job creation fails, restore quota counter

---

## Component Breakdown

### 1. HeaderBar
**Purpose:** Navigation + brand identity + quota tracking

**Elements:**
- `backButton`: Chevron left icon (left-aligned) — returns to previous screen
- `brandLabel`: "NanoBanana" with logo icon (center)
- `quotaBadge`: Pill-shaped badge showing "X Free Edits Left" (right-aligned, top-right corner)

**Props:**
```swift
struct ChatHeaderBarProps {
    let onBackTap: () -> Void
    let brandTitle: String           // "NanoBanana"
    let remainingQuota: Int          // 0-20 for free users, nil for PRO
    let isPRO: Bool                  // Hide quota badge if PRO
    let onQuotaBadgeTap: () -> Void  // Optional: explain quota system
}
```

**Visual:**
- Background: semi-transparent or solid dark (#1A1C1E)
- Height: ~56pt (including safe area padding)
- Quota badge: mint green background (#33C3A4), white text, "X Free Edits Left", 8pt horizontal padding, 4pt vertical padding
- Badge position: Top-right corner, right-aligned with 16pt trailing padding

---

### 2. UploadArea (Center, Large)
**Purpose:** Primary image selection and preview

**Elements:**
- **Empty state:** Large rounded rectangle card with prompt + subtitle
  - Title: "Upload your photo" (centered, 20pt, semibold)
  - Subtitle: "Share your best photos and memos" (centered, 14pt, regular, muted gray)
  - Placeholder icon: Large upload icon (SF Symbol: "arrow.up.doc" or "photo", 64pt)
  - Card is fully tappable (entire area triggers image picker)
- **Image selected state:** Thumbnail preview (fills area, aspect-fit or aspect-fill)
- **Uploading state:** Spinner overlay + progress text ("Uploading 45%...")
- **Error state:** Red border + retry button

**Props:**
```swift
struct UploadAreaProps {
    let selectedImage: UIImage?      // nil = empty state, non-nil = preview
    let isUploading: Bool
    let uploadProgress: Double?      // 0.0-1.0, optional for progress bar
    let errorMessage: String?
    let quotaRemaining: Int          // Block tap if 0
    let onTap: () -> Void            // Open image picker (blocked if quota = 0)
}
```

**Visual:**
- Size: ~300×400pt (responsive to screen size, portrait)
- Corner radius: 16pt
- Border: 2pt dashed gray (empty state), solid (selected/error)
- Background: #2C2F32 (card surface)
- Icon size (empty): 64pt
- Text (empty): SF Pro Regular, 16pt, #A0A9B0

---

### 3. BottomInputBar
**Purpose:** Image picker trigger + PRO action CTA

**Elements:**
- **Left:** Attachment icon button (photo icon, SF Symbol: "photo" or "paperclip")
- **Center:** Instruction text (disabled state: "Select an image first…", enabled: "Ready to create!")
- **Right:** "PRO Creation" pill button (blue, enabled only when image selected)

**Behavior:**
- **Default state:** Entire bar disabled (grayed out), instruction shows "Select an image first…"
- **After image selection:** Bar enabled, attachment icon active, "PRO Creation" button blue and tappable
- **On quota = 0:** "PRO Creation" button label changes to "Upgrade to PRO", triggers paywall

**Props:**
```swift
struct BottomInputBarProps {
    let hasImageSelected: Bool       // Enables/disables entire bar
    let quotaRemaining: Int          // Changes button label if 0
    let instructionText: String      // "Select an image first…" or "Ready to create!"
    let onAttachmentTap: () -> Void  // Open image picker
    let onProCreationTap: () -> Void // Start job creation or show paywall
}
```

**Visual:**
- Background: #1A1C1E (slightly elevated)
- Height: ~70pt
- Horizontal padding: 16pt
- Attachment icon: 44×44pt tap target, left-aligned
- Instruction text: center-aligned, 14pt, muted when disabled
- PRO Creation button: blue (#4D7CFF), 16pt horizontal padding, 10pt vertical, corner radius 20pt (pill shape)
- Disabled state: All elements gray (#5A5C5E), opacity 0.5, not tappable
- Zero quota state: "PRO Creation" → "Upgrade to PRO" (same button, different label)

---

### 4. BottomTabBar (Global)
**Purpose:** Primary navigation (Chat tab is active)

**Elements:**
- Home, Chat (center, active), History

*(See global BottomTabBar docs for full spec)*

---

## Design Tokens

### Colors (Dark Theme)

| Token Name | Hex Value | Usage | SwiftUI Asset |
|------------|-----------|-------|---------------|
| `background` | `#0E1012` | Main screen background | `background` |
| `cardBackground` / `surface` | `#2C2F32` | Upload area background | `cardBackground` |
| `headerBackground` | `#1A1C1E` | Header + bottom bar background | `headerBackground` |
| `titleText` / `primary` | `#C8DAFF` | Brand title, primary text | `titleText` |
| `secondaryText` / `body` | `#A0A9B0` | Instructions, hints | `secondaryText` |
| `accent` / `actionPrimary` | `#4D7CFF` | PRO Creation button | `accent` |
| `creditBadgeBackground` | `#33C3A4` | Free edits badge (mint green) | `creditBadgeBackground` |
| `creditBadgeText` | `#FFFFFF` | Badge text (white) | `creditBadgeText` |
| `errorBorder` | `#FF4444` | Upload error state | `errorBorder` |
| `uploadPlaceholderIcon` | `#6A6C6E` | Empty state icon (muted gray) | `uploadPlaceholderIcon` |

---

### Typography

| Style | Font | Size (pt) | Weight | Usage |
|-------|------|-----------|--------|-------|
| `brand-title` | SF Pro | 18 | Semibold | Header brand name |
| `body` | SF Pro | 16 | Regular | Upload placeholder text |
| `instruction` | SF Pro | 14 | Regular | Bottom action bar instructions |
| `badge-text` | SF Pro | 12 | Medium | Credit badge ("2 Free Edits Left") |
| `button-label` | SF Pro | 16 | Semibold | PRO Creation button |

---

### Spacing & Layout

| Token | Value (pt) | Usage |
|-------|------------|-------|
| `spacing-xs` | 8 | Icon-to-text gaps |
| `spacing-sm` | 12 | Badge internal padding |
| `spacing-md` | 16 | Screen horizontal padding, section gaps |
| `spacing-lg` | 24 | Large gaps (header to content) |
| `spacing-xl` | 32 | Extra spacing (upload area to bottom bar) |

**Component-Specific:**
- **Upload Area Size:** ~300×400pt (portrait), responsive
- **Upload Area Corner Radius:** 16pt
- **Upload Area Border (empty):** 2pt dashed, #6A6C6E
- **Credit Badge Corner Radius:** 12pt (pill shape)
- **PRO Button Corner Radius:** 20pt (pill shape)
- **Header Height:** 56pt
- **Bottom Action Bar Height:** 70pt
- **Bottom Tab Bar Height:** 80pt

---

## States & UX Rules

### 1. Empty State (No Image Selected)
**Visual:**
- Large rounded card with solid background (#2C2F32)
- Title: "Upload your photo" (20pt, semibold, centered)
- Subtitle: "Share your best photos and memos" (14pt, regular, muted gray, centered)
- Upload icon (64pt) centered below text
- Entire card is tappable (no separate upload button)

**Behavior:**
- Tap upload card → Open image picker (PHPickerViewController iOS 14+ or UIImagePickerController iOS 13)
- **If quota = 0:** Block tap, show alert "Daily limit reached. Upgrade to PRO for unlimited edits."
- Bottom input bar → Fully disabled (gray, opacity 0.5)
- Attachment icon → Disabled (gray)
- PRO Creation button → Disabled (gray, opacity 0.5)
- Instruction text: "Select an image first…"

---

### 2. Image Selected State
**Visual:**
- Selected image fills upload card (aspect-fit, rounded corners maintained)
- Subtle border (1pt solid, #6A6C6E)
- Small edit/change icon overlay (top-right corner, optional: "pencil.circle.fill")
- Image slightly dimmed (opacity 0.9) to show it's ready for editing

**Behavior:**
- Tap upload card → Re-open image picker (change selection, confirm with alert)
- Bottom input bar → Fully enabled (normal colors, full opacity)
- Attachment icon → Enabled (tappable, opens image picker)
- PRO Creation button → Enabled (blue #4D7CFF, full opacity, tappable)
- Instruction text: "Ready to create!" or "Tap PRO Creation to begin"
- **If quota = 0:** PRO Creation button shows "Upgrade to PRO" label instead

---

### 3. Uploading State
**Visual:**
- Selected image visible (dimmed, opacity 0.7)
- Spinner overlay (center) with progress text
- Progress bar (optional, bottom of upload area)
- Text: "Uploading 45%..." or "Processing..."

**Behavior:**
- Disable all interactions (upload area, PRO button, attachment)
- Show activity indicator (UIActivityIndicatorView or ProgressView)
- Update progress text in real-time if available

---

### 4. Error State
**Visual:**
- Red border (2pt solid, #FF4444) around upload area
- Error icon (exclamation triangle, red)
- Error message: "Upload failed. Tap to retry."

**Behavior:**
- Tap upload area → Retry upload
- Show toast/alert with detailed error (network error, file too large, etc.)
- Rollback credit counter if job creation failed

---

### 5. Quota Exceeded State (0/20 Remaining)
**Visual:**
- Quota badge shows "0/20 remaining" (red background)
- Create button label changes to "Upgrade to PRO"
- Instruction text: "Upgrade to continue editing"

**Behavior:**
- Tap "Upgrade to PRO" → Present Adapty paywall (modal sheet)
- Block job creation until user subscribes

---

## Interaction Flow (Detailed)

### Happy Path: Free User with Quota
1. **User lands on Chat screen**
   - Header shows "2 Free Edits Left" (top-right badge)
   - Upload card shows "Upload your photo" prompt + subtitle
   - Bottom input bar fully disabled (gray)

2. **User taps upload card**
   - **Quota check:** If remaining > 0, proceed; if = 0, show paywall alert
   - PHPickerViewController presents (iOS 14+) or UIImagePickerController (iOS 13)
   - User selects image from Photos or Camera

3. **Image selected**
   - Image preview appears in upload card (replaces placeholder)
   - Bottom input bar becomes enabled (normal colors)
   - Attachment icon enabled (blue)
   - PRO Creation button enabled (blue #4D7CFF)
   - Instruction text: "Ready to create!"

4. **User taps "PRO Creation"**
   - App requests presigned upload URL: `POST /api/v1/uploads/presigned`
   - Response: `{ "uploadUrl": "...", "imageKey": "..." }`
   - App uploads image directly to S3 (background URLSession)
   - Show uploading state (spinner + progress % in upload card)

5. **Upload completes**
   - App creates job: `POST /api/v1/jobs { "imageKey": "...", "model": "...", ... }`
   - Response: `{ "jobId": "job_abc123", "status": "queued" }`
   - **Optimistic UI:** Update quota badge immediately: "1 Free Edits Left"
   - Navigate to ResultView with `jobId`

6. **ResultView shows processing progress**
   - Poll `GET /api/v1/jobs/{jobId}/status` every 2s
   - Show progress bar or spinner
   - On completion, show result image + save/share options

---

### Unhappy Path: Quota Exceeded (0 Free Edits Left)
1. **User lands on Chat screen with quota = 0**
   - Header shows "0 Free Edits Left" (red background badge)
   - Upload card still visible but shows warning overlay

2. **User taps upload card**
   - Alert appears: "Daily limit reached. Upgrade to PRO for unlimited edits."
   - Two buttons: "Upgrade to PRO" | "Cancel"

3. **User taps "Upgrade to PRO"**
   - App presents Adapty paywall (modal sheet)
   - Shows subscription tiers (Weekly/Monthly/Annual)

4. **User subscribes or cancels**
   - **If subscribed:** Paywall dismisses, quota badge hidden, upload card enabled, PRO Creation button shows normal label
   - **If canceled:** Return to Chat screen, upload still blocked

---

### Unhappy Path: Upload Failure
1. User selects image
2. User taps PRO Creation
3. Upload fails (network error, 413 Payload Too Large, etc.)
4. Show error state: red border + toast message
5. Quota not affected (only decremented on successful job creation)
6. User taps upload area to retry

---

## API Integration

### 1. Request Presigned Upload URL
**Endpoint:** `POST /api/v1/uploads/presigned`

**Request:**
```json
{
  "filename": "user_photo.jpg",
  "contentType": "image/jpeg"
}
```

**Response:**
```json
{
  "uploadUrl": "https://s3.amazonaws.com/bucket/uuid-key?signature=...",
  "imageKey": "uuid-v4-key",
  "expiresIn": 900
}
```

---

### 2. Create AI Editing Job
**Endpoint:** `POST /api/v1/jobs`

**Request:**
```json
{
  "imageKey": "uuid-v4-key",
  "model": "default",       // or specific model from tool selection
  "parameters": {
    "fidelity": 0.8,
    "upscale": 2
  }
}
```

**Response:**
```json
{
  "jobId": "job_abc123",
  "status": "queued",
  "createdAt": "2025-10-12T10:30:00Z"
}
```

---

### 3. Get User Quota
**Endpoint:** `GET /api/v1/users/me`

**Response:**
```json
{
  "id": "user_123",
  "email": "user@example.com",
  "isPro": false,
  "quota": {
    "dailyRemaining": 15,
    "dailyLimit": 20,
    "monthlyRemaining": 585,
    "monthlyLimit": 600
  }
}
```

**Client-side caching:**
- Fetch on app launch / tab switch
- Cache in @AppStorage
- Refresh after job creation
- Update optimistically, rollback on error

---

## Accessibility

### VoiceOver Labels
- **Upload card (empty):** "Upload photo card, button. Upload your photo. Share your best photos and memos. Double-tap to select from gallery or camera."
- **Upload card (selected):** "Selected image preview. Double-tap to change image."
- **Attachment icon:** "Attach image, button. Opens photo picker."
- **PRO Creation button (disabled):** "PRO Creation, button, disabled. Select an image first."
- **PRO Creation button (enabled):** "PRO Creation, button. Double-tap to start AI editing."
- **PRO Creation button (quota = 0):** "Upgrade to PRO, button. Double-tap to view subscription options."
- **Quota badge:** "2 free edits left."

### Tap Targets
- Upload card: ~300×400pt (large target, entire card tappable, exceeds 44×44pt minimum)
- Attachment icon: 44×44pt minimum (left side of bottom bar)
- PRO Creation button: 48pt height × 120pt width minimum (generous touch area)
- Back button: 44×44pt minimum
- Quota badge: 44×44pt minimum tap target (optional tap for quota explanation)

### Dynamic Type
- Scale all text with user's accessibility settings
- Test with "Larger Accessibility Sizes" (up to XXXL)

### High Contrast Mode
- Increase border opacity (dashed border → solid, opacity 0.8)
- Increase text contrast (secondary text → brighter gray)

---

## iOS Compatibility

### SwiftUI + PHPicker (iOS 14+)
```swift
import PhotosUI

@State private var selectedItem: PhotosPickerItem?

PhotosPicker(selection: $selectedItem, matching: .images) {
    // Upload area view
}
.onChange(of: selectedItem) { newItem in
    // Load image from newItem
}
```

### UIImagePickerController Fallback (iOS 13)
```swift
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    // ... coordinator implementation
}
```

### iOS 12 Requirement (Not Supported)
- SwiftUI unavailable on iOS 12
- If iOS 12 is critical: use UIKit UIViewController with UIImagePickerController
- Request UIKit scaffold if needed

---

## Privacy & Legal

### Photo Library Access
- **Info.plist key:** `NSPhotoLibraryUsageDescription`
- **Description:** "noname_banana needs access to your photos to edit and enhance them with AI."

### Camera Access (If Supported)
- **Info.plist key:** `NSCameraUsageDescription`
- **Description:** "noname_banana needs camera access to take photos for AI editing."

### User Consent (Face Editing)
- Before first job creation: show consent modal
- Text: "By uploading, you confirm you have rights to edit this image and consent to AI processing."
- Checkbox: "I agree to Terms of Service and Privacy Policy"
- Store consent timestamp in UserDefaults

---

## Implementation Checklist

### Design
- [ ] Confirm exact colors from design system (hex values)
- [ ] Verify upload area size on all devices (SE to Pro Max)
- [ ] Test dark mode contrast ratios (WCAG AA)
- [ ] Validate credit badge visibility (mint green on dark background)

### Functionality
- [ ] Integrate PHPickerViewController (iOS 14+) or UIImagePickerController (iOS 13)
- [ ] Implement presigned upload flow (S3 direct upload)
- [ ] Handle upload progress tracking (URLSession upload task with progress callback)
- [ ] Implement job creation API call (POST /api/v1/jobs)
- [ ] **Quota management:**
  - [ ] Fetch quota on screen load (`GET /api/v1/users/me`)
  - [ ] Display quota badge in real-time (top-right header)
  - [ ] Block upload card tap if quota = 0
  - [ ] Decrement quota optimistically after job creation
  - [ ] Rollback quota on job creation failure
- [ ] Integrate Adapty paywall (show when quota = 0)
- [ ] Add haptic feedback on button taps (medium impact)
- [ ] Disable all controls until image selected (bottom input bar gray/disabled)

### Performance
- [ ] Compress images before upload (max 2048×2048, 85% JPEG quality)
- [ ] Use background URLSession for uploads (continue in background)
- [ ] **Cache quota count** (avoid redundant API calls, @AppStorage or UserDefaults)
- [ ] Optimize image loading (use downsized thumbnails for preview, 512×512 max)
- [ ] Update quota in real-time (fetch on screen appear, update on job creation)

### Accessibility
- [ ] Add VoiceOver labels to all interactive elements
- [ ] Test with VoiceOver + keyboard navigation
- [ ] Support Dynamic Type (scale fonts)
- [ ] High contrast mode adjustments

### Error Handling
- [ ] Handle network errors (show toast, retry button)
- [ ] Handle large file errors (413 Payload Too Large → show size limit)
- [ ] Handle auth errors (401 → force re-login)
- [ ] Handle rate limiting (429 → show cooldown timer)
- [ ] Rollback quota counter on job creation failure

### Analytics
- [ ] Track: screen view (Chat)
- [ ] Track: image selected (source: gallery/camera)
- [ ] Track: PRO Creation tapped
- [ ] Track: upload started, succeeded, failed
- [ ] Track: job created (jobId, model)
- [ ] Track: paywall shown (trigger: quota exceeded)

---

## Next Actions

1. **Upload Editor Screenshot:**  
   Send `editor.png` showing EditorView with job progress, result preview, and export options.

2. **Confirm Rate Limit Logic:**  
   - Daily limit: 20 requests/day (confirmed)
   - Monthly limit: 600 requests/month (confirmed)
   - PRO: Unlimited (soft cap 500/day)

3. **Provide Privacy/Cookies Text:**  
   Share Privacy Policy URL or draft text for consent modal (face editing, data retention).

4. **Backend Endpoint Confirmation:**  
   Verify endpoints `/uploads/presigned`, `/jobs`, `/users/me/credits` match backend implementation.

---

**Document Status:** ✅ Production-Ready  
**iOS Target:** ✅ iOS 13+ (SwiftUI + PHPicker/UIImagePicker)  
**Key Features:** 
- Real-time quota tracking ("X Free Edits Left" badge)
- Quota-based blocking (upload disabled at 0 remaining)
- Adapty paywall integration (triggered on quota = 0)
- Presigned S3 uploads (direct from iOS)
- Bottom input bar disabled until image selected
- All controls meet Apple HIG (44pt tap targets, Dynamic Type)

