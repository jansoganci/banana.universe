# BananaUniverse Audit Fix Plan

**App Version:** 1.0.0  
**Bundle ID:** com.janstrade.bananauniverse  
**Audit Date:** October 17, 2025  
**Document Version:** 1.0

---

## Phase 1: TestFlight Blockers

**Objective:** Fix critical issues preventing TestFlight submission  
**Total Estimated Time:** 2-4 hours  
**Priority:** CRITICAL - Must complete before any testing

---

### C1: Missing Adapty API Key

**Description:** Hardcoded placeholder `"YOUR_ADAPTY_PUBLIC_KEY"` instead of actual API key  
**File:** `BananaUniverse/Core/Services/AdaptyService.swift:34`  
**Impact:** In-app purchases completely non-functional  
**Time Estimate:** 10 minutes

**What Needs to Be Fixed:**
```swift
// Current (Line 34)
try await Adapty.activate("YOUR_ADAPTY_PUBLIC_KEY")

// Fix to:
try await Adapty.activate("pub_live_xxxxxxxxxxxx")
```

**Expected Result:**
- Adapty SDK initializes successfully
- Paywall loads products from App Store Connect
- Purchase flow completes without errors

**Verification Steps:**
1. Launch app in debug mode
2. Navigate to Profile → "Upgrade to Pro"
3. Verify products load and display prices
4. Attempt test purchase (sandbox)
5. Confirm purchase completes and credits added

---

### C2: Missing NSPhotoLibraryUsageDescription

**Description:** No permission string for reading photos from library  
**File:** `BananaUniverse.xcodeproj/project.pbxproj`  
**Impact:** App crashes when user taps photo picker  
**Time Estimate:** 15 minutes

**What Needs to Be Fixed:**
Add to project build settings (Info.plist keys):
```
INFOPLIST_KEY_NSPhotoLibraryUsageDescription = "We need access to your photo library to select images for AI processing.";
```

**Expected Result:**
- Permission prompt appears when user taps photo picker
- No crashes when accessing photo library
- User can select photos successfully

**Verification Steps:**
1. Delete app from device/simulator
2. Reinstall and launch
3. Tap photo upload button in Chat or ImageUpscaler
4. Verify permission alert appears with correct message
5. Grant permission and verify photo picker opens
6. Select a photo and verify it loads

---

### C3: Production Debug Code - Unlimited Mode Toggle

**Description:** Testing feature "Unlimited Mode" visible in production Profile screen  
**Files:**
- `BananaUniverse/Features/Profile/Views/ProfileView.swift:213-243`
- `BananaUniverse/Core/Services/HybridCreditManager.swift:124-141`  
**Impact:** Users can bypass payment system entirely  
**Time Estimate:** 30 minutes

**What Needs to Be Fixed:**
Option 1 (Recommended for TestFlight):
```swift
// Wrap UI in ProfileView.swift (Lines 213-243)
#if DEBUG
HStack(spacing: 16) {
    Image(systemName: "crown.fill")
    // ... rest of Unlimited Mode UI
}
#endif
```

Option 2 (Safest for App Store):
- Delete lines 213-243 in ProfileView.swift entirely
- Keep backend logic in HybridCreditManager.swift for future admin tools

**Expected Result:**
- Unlimited Mode toggle not visible in production builds
- Still accessible in debug builds for testing
- Users cannot bypass credit system

**Verification Steps:**
1. Build in Release mode (Product → Scheme → Edit Scheme → Run → Release)
2. Launch app and navigate to Profile
3. Verify "Unlimited Mode" section is not visible
4. Switch back to Debug mode
5. Verify toggle appears only in debug builds

---

### C4: Incomplete Feature - Save/Share Button

**Description:** Button with `// TODO: Implement save/share` does nothing  
**File:** `BananaUniverse/Features/ImageUpscaler/ImageUpscalerView.swift:233-246`  
**Impact:** Users click button, nothing happens, poor UX  
**Time Estimate:** 45 minutes

**What Needs to Be Fixed:**
Option 1 (Implement Save):
```swift
Button(action: {
    Task {
        await saveUpscaledImage()
    }
}) {
    // ... existing UI
}

private func saveUpscaledImage() async {
    guard let url = upscaledImageURL,
          let imageData = try? Data(contentsOf: url),
          let image = UIImage(data: imageData) else {
        errorMessage = "No image to save"
        return
    }
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    usageInfo = "✅ Saved to Photos!"
}
```

Option 2 (Remove Button):
- Delete lines 232-246 entirely if functionality not needed

**Expected Result:**
- Tapping "Save Result" saves image to Photos
- User sees confirmation message
- Image appears in Photos app

**Verification Steps:**
1. Upload and process an image in ImageUpscaler
2. Tap "Save Result" button
3. Verify Photos permission prompt (if first time)
4. Grant permission and verify success message
5. Open Photos app and confirm image saved
6. Verify correct filename and quality

---

### C5: Excessive Debug Print Statements

**Description:** 100+ print() statements logging sensitive data  
**Files:**
- `BananaUniverse/Core/Services/SupabaseService.swift` (29+ instances)
- `BananaUniverse/Core/Services/HybridCreditManager.swift` (15+ instances)
- `BananaUniverse/Features/Chat/ViewModels/ChatViewModel.swift` (10+ instances)  
**Impact:** Performance drain, potential privacy leak, unprofessional  
**Time Estimate:** 90 minutes

**What Needs to Be Fixed:**
Create debug logging wrapper:
```swift
// Add to Config.swift
extension Config {
    static func debugLog(_ message: String, file: String = #file, function: String = #function) {
        #if DEBUG
        print("[\(URL(fileURLWithPath: file).lastPathComponent):\(function)] \(message)")
        #endif
    }
}

// Replace all print() statements:
// Before:
print("🔍 [SupabaseService] JWT payload: \(json)")

// After:
Config.debugLog("JWT payload: \(json)")
```

**Expected Result:**
- No console logs in production builds
- Debug logs still available in debug builds
- Sensitive data (JWT, device IDs) not logged in production

**Verification Steps:**
1. Find all print() statements: `grep -r "print(" BananaUniverse/`
2. Replace with Config.debugLog()
3. Build in Release mode
4. Launch app and monitor Xcode console
5. Verify no logs appear during normal usage
6. Switch to Debug mode and verify logs appear

---

### Phase 1 Checklist

- [ ] **C1:** Adapty API key configured and tested
- [ ] **C2:** Photo library permission added to Info.plist
- [ ] **C3:** Unlimited Mode hidden in production builds
- [ ] **C4:** Save button implemented or removed
- [ ] **C5:** All debug prints wrapped in `#if DEBUG`
- [ ] **Verification:** Full app walkthrough in Release mode
- [ ] **Testing:** TestFlight build uploaded successfully
- [ ] **Sign-off:** QA approved for beta testing

---

## Phase 2: App Store Blockers

**Objective:** Fix major issues preventing App Store approval  
**Total Estimated Time:** 4-6 hours  
**Priority:** HIGH - Required for App Store submission

---

### M1: Force Unwraps Throughout Codebase

**Description:** 40+ instances of forced unwrapping that can cause crashes  
**Files:**
- `BananaUniverse/Core/Services/SupabaseService.swift` (15+ instances)
- `BananaUniverse/Features/Chat/ViewModels/ChatViewModel.swift` (10+ instances)
- `BananaUniverse/Features/Library/ViewModels/LibraryViewModel.swift` (5+ instances)  
**Impact:** App crashes if URLs are malformed or data is nil  
**Time Estimate:** 120 minutes

**What Needs to Be Fixed:**
Replace all force unwraps with safe unwrapping:

```swift
// SupabaseService.swift:19
// Before:
supabaseURL: URL(string: Config.supabaseURL)!,

// After:
guard let url = URL(string: Config.supabaseURL) else {
    fatalError("Invalid Supabase URL in configuration")
}
supabaseURL: url,
```

```swift
// ChatViewModel.swift:246
// Before:
let url = URL(string: processedImageURL)!

// After:
guard let url = URL(string: processedImageURL) else {
    throw ProcessingError.invalidResultURL
}
```

**Expected Result:**
- No force unwraps in production code
- Graceful error handling for invalid data
- No crashes from nil values

**Verification Steps:**
1. Search codebase: `grep -r "!" BananaUniverse/ | grep -v "//"`
2. Replace all force unwraps with guard/if-let
3. Build and resolve all compiler errors
4. Run app and test all features
5. Verify no crashes during edge cases
6. Run static analysis (Xcode → Product → Analyze)

---

### M2: No Localization / Hardcoded Strings

**Description:** All user-facing text hardcoded in English  
**Files:** All View files (30+ files)  
**Impact:** Cannot expand to international markets  
**Time Estimate:** 90 minutes

**What Needs to Be Fixed:**
1. Create `Localizable.strings` file
2. Extract all user-facing strings
3. Wrap strings with NSLocalizedString

```swift
// Before:
Text("Start by uploading a photo")

// After:
Text(NSLocalizedString("chat.upload.prompt", comment: "Upload photo prompt"))

// In Localizable.strings (English):
"chat.upload.prompt" = "Start by uploading a photo";
"error.insufficient_credits" = "You don't have enough credits. Purchase more to continue!";
"settings.unlimited_mode" = "Unlimited Mode";
```

**Expected Result:**
- All user-facing strings use NSLocalizedString
- App ready for translation to other languages
- Localizable.strings file created with all keys

**Verification Steps:**
1. Create Localizable.strings file in Xcode
2. Extract all Text(), alert, and error messages
3. Replace with NSLocalizedString calls
4. Build and verify no compilation errors
5. Run app and verify all text displays correctly
6. Export strings for translation (future)

---

### M3: Missing Error State Handling

**Description:** Generic error messages, poor error handling  
**Files:**
- `BananaUniverse/Features/ImageUpscaler/ImageUpscalerView.swift:340`
- `BananaUniverse/Features/Chat/ViewModels/ChatViewModel.swift` (multiple)  
**Impact:** Users see unhelpful error messages  
**Time Estimate:** 60 minutes

**What Needs to Be Fixed:**
Create custom error types with user-friendly messages:

```swift
// Add to SupabaseService.swift
enum ProcessingError: LocalizedError {
    case networkTimeout
    case imageTooLarge
    case insufficientCredits
    case serviceUnavailable
    
    var errorDescription: String? {
        switch self {
        case .networkTimeout:
            return "The request took too long. Please check your internet connection and try again."
        case .imageTooLarge:
            return "This image is too large. Please select an image under 10MB."
        case .insufficientCredits:
            return "You don't have enough credits. Tap here to purchase more."
        case .serviceUnavailable:
            return "Our AI service is temporarily unavailable. Please try again in a few minutes."
        }
    }
}

// Update catch blocks:
} catch let error as ProcessingError {
    errorMessage = error.errorDescription ?? "An error occurred"
} catch {
    errorMessage = "An unexpected error occurred. Please try again."
}
```

**Expected Result:**
- User-friendly error messages for all error types
- Actionable guidance in error messages
- No technical jargon exposed to users

**Verification Steps:**
1. Test each error scenario:
   - Disconnect internet → network error
   - Upload 100MB image → size error
   - Deplete credits → insufficient credits error
2. Verify each error shows user-friendly message
3. Verify error messages provide clear next steps

---

### M4: App Store Privacy Labels Mismatch

**Description:** Privacy policy mentions AWS S3, not in PrivacyInfo.xcprivacy  
**Files:**
- `BananaUniverse/PrivacyInfo.xcprivacy`
- `docs/legal/privacy.md`  
**Impact:** Privacy disclosure mismatch, potential rejection  
**Time Estimate:** 30 minutes

**What Needs to Be Fixed:**
Update privacy.md to match actual data collection:

```markdown
## Service Providers

- **Supabase:** Authentication, database, and storage
- **Adapty:** Subscription management
- **fal.ai:** AI image processing
```

Remove AWS S3 mention if not directly used (Supabase handles storage).

**Expected Result:**
- Privacy policy matches PrivacyInfo.xcprivacy exactly
- All service providers accurately listed
- No discrepancies between code and documentation

**Verification Steps:**
1. Review PrivacyInfo.xcprivacy data collection types
2. Review actual network calls in code
3. Update privacy.md to match exactly
4. Remove any outdated service references
5. Cross-reference with Apple's privacy requirements

---

### M5: Missing "Sign in with Apple" (SIWA)

**Description:** Only email/password auth, no Apple SIWA  
**Files:**
- `BananaUniverse/Features/Authentication/Views/LoginView.swift`
- `BananaUniverse/Core/Services/HybridAuthService.swift:118-160`  
**Impact:** Violates Apple guideline 4.8, will be rejected  
**Time Estimate:** 60 minutes

**What Needs to Be Fixed:**
Add Sign in with Apple button to LoginView:

```swift
// In LoginView.swift, add after password field:
Button(action: {
    Task {
        try await authService.signInWithApple()
    }
}) {
    HStack {
        Image(systemName: "applelogo")
        Text("Sign in with Apple")
    }
    .frame(maxWidth: .infinity)
    .frame(height: 50)
    .background(Color.black)
    .foregroundColor(.white)
    .cornerRadius(10)
}
```

**Expected Result:**
- "Sign in with Apple" button appears in LoginView
- Tapping button triggers Apple authentication flow
- Successful auth creates user account and signs in
- Credits migrate from anonymous to authenticated

**Verification Steps:**
1. Add Sign in with Apple capability in Xcode
2. Configure App ID in Apple Developer portal
3. Build and launch app
4. Tap "Sign in with Apple" button
5. Complete Apple authentication
6. Verify user signed in successfully
7. Verify credits migrated if previously anonymous

---

### M6: Incomplete Documentation URLs

**Description:** Email domain "pixelmage.com" doesn't match app branding  
**Files:**
- `docs/legal/privacy.md:40`
- `docs/legal/terms.md:77`  
**Impact:** Confusing branding, unprofessional appearance  
**Time Estimate:** 15 minutes

**What Needs to Be Fixed:**
Update all contact emails to match app branding:

```markdown
// Before:
Email: privacy@pixelmage.com
Email: support@pixelmage.com

// After:
Email: privacy@bananauniverse.com
Email: support@bananauniverse.com
```

**Expected Result:**
- All email addresses use consistent domain
- Domain matches app name and branding
- Professional, cohesive appearance

**Verification Steps:**
1. Search all docs for "pixelmage.com"
2. Replace with "bananauniverse.com"
3. Verify email addresses are valid
4. Test email links (if embedded in app)

---

### M7: Terms & Privacy Not Linked in App

**Description:** "Terms & Privacy" settings button does nothing  
**File:** `BananaUniverse/Features/Profile/Views/ProfileView.swift:283-285`  
**Impact:** Users cannot access legal documents  
**Time Estimate:** 30 minutes

**What Needs to Be Fixed:**
1. Host privacy.md and terms.md on web server
2. Link buttons to hosted URLs

```swift
// Before:
SettingsRow(icon: "doc.text", title: "Terms & Privacy") {
    // Handle terms  // TODO
}

// After:
SettingsRow(icon: "doc.text", title: "Terms & Privacy") {
    if let url = URL(string: "https://bananauniverse.com/legal/privacy") {
        openURL(url)
    }
}
```

**Expected Result:**
- Tapping "Terms & Privacy" opens Safari with legal docs
- Privacy policy and terms hosted on web
- URLs functional and accessible

**Verification Steps:**
1. Host privacy.md and terms.md on web server
2. Add URLs to Config.swift
3. Update ProfileView button action
4. Build and launch app
5. Tap "Terms & Privacy" button
6. Verify Safari opens with correct page
7. Test on iOS 15, 16, 17, 18

---

### Phase 2 Checklist

- [ ] **M1:** All force unwraps replaced with safe unwrapping
- [ ] **M2:** Localization implemented with Localizable.strings
- [ ] **M3:** User-friendly error messages for all error types
- [ ] **M4:** Privacy policy matches PrivacyInfo.xcprivacy
- [ ] **M5:** Sign in with Apple implemented and tested
- [ ] **M6:** Contact emails updated to consistent branding
- [ ] **M7:** Terms & Privacy links functional
- [ ] **Verification:** App Store Connect metadata prepared
- [ ] **Testing:** Beta testers confirm all features work
- [ ] **Sign-off:** Legal review of privacy/terms completed

---

## Phase 3: Quality & UX Polish

**Objective:** Enhance user experience and app quality  
**Total Estimated Time:** 8-12 hours  
**Priority:** MEDIUM - Improves ratings and user retention

---

### m1: App Name Length Concern

**Description:** Consider shorter name for ASO  
**Current:** "Banana Universe" (14 chars)  
**Files:** `BananaUniverse.xcodeproj/project.pbxproj`  
**Impact:** ASO optimization opportunity  
**Time Estimate:** N/A (decision only)

**What Needs to Be Fixed:**
Consider alternatives for A/B testing:
- "Banana Universe" (current)
- "Banana AI"
- "Banana Studio"
- "Universe AI"

**Expected Result:**
- App name chosen and locked for launch
- Consistent branding across all assets

**Verification Steps:**
1. Research competitor app names
2. Test readability on various screen sizes
3. Check App Store search rankings for keywords
4. Make final decision before submission

---

### m2: iPad Support Not Tested

**Description:** App only targets iPhone, iPad runs in compatibility mode  
**File:** `BananaUniverse.xcodeproj/project.pbxproj` (TARGETED_DEVICE_FAMILY = 1)  
**Impact:** Poor iPad user experience  
**Time Estimate:** 120 minutes (if adding full support)

**What Needs to Be Fixed:**
Option 1 (Test Compatibility Mode):
- Run app on iPad simulator
- Verify all UI elements functional
- Test in both orientations
- Document any issues

Option 2 (Add Native iPad Support):
- Change TARGETED_DEVICE_FAMILY to "1,2"
- Create iPad-specific layouts for large screens
- Test extensively on all iPad sizes

**Expected Result:**
- App functional on iPad (compatibility or native)
- No UI glitches or layout issues
- All features work on iPad

**Verification Steps:**
1. Launch app on iPad Pro 12.9" simulator
2. Test all features in portrait and landscape
3. Verify UI scales appropriately
4. Test image upload and processing
5. Verify paywall displays correctly

---

### m3: No Haptic Feedback Consistency

**Description:** Inconsistent haptic feedback across UI  
**Files:**
- `BananaUniverse/Features/Chat/Views/ChatView.swift:160` (has haptics)
- `BananaUniverse/Features/ImageUpscaler/ImageUpscalerView.swift` (missing)
- `BananaUniverse/Features/Profile/Views/ProfileView.swift` (missing)  
**Impact:** Inconsistent user experience  
**Time Estimate:** 45 minutes

**What Needs to Be Fixed:**
Add haptics to all interactive elements:

```swift
// Add to all buttons:
Button(action: {
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
    // ... action code
}) {
    // ... button content
}

// Add to successful actions:
let generator = UINotificationFeedbackGenerator()
generator.notificationOccurred(.success)
```

**Expected Result:**
- Light haptic on all button taps
- Medium haptic on image selection
- Success haptic on completed actions
- Consistent feedback across all screens

**Verification Steps:**
1. Test on physical device (haptics don't work in simulator)
2. Tap every button in app
3. Verify consistent haptic feedback
4. Test image upload flow
5. Test purchase flow
6. Verify success haptics after processing

---

### m4: Accessibility Labels Missing

**Description:** No VoiceOver labels on images and buttons  
**Files:** All View files  
**Impact:** App unusable for visually impaired users  
**Time Estimate:** 90 minutes

**What Needs to Be Fixed:**
Add accessibility labels to all interactive elements:

```swift
// Before:
Image(systemName: "photo.fill")

// After:
Image(systemName: "photo.fill")
    .accessibilityLabel("Select photo from library")
    .accessibilityHint("Opens photo picker")

// Before:
Button(action: { ... }) { Image(systemName: "arrow.up.circle.fill") }

// After:
Button(action: { ... }) {
    Image(systemName: "arrow.up.circle.fill")
}
.accessibilityLabel("Send message")
.accessibilityHint("Processes selected image with your prompt")
```

**Expected Result:**
- All UI elements have descriptive labels
- VoiceOver can navigate entire app
- All actions clearly described
- WCAG 2.1 Level AA compliance

**Verification Steps:**
1. Enable VoiceOver on device (Settings → Accessibility)
2. Navigate through all screens with VoiceOver
3. Verify all elements are announced clearly
4. Test all interactive elements
5. Verify images have descriptive labels
6. Test form inputs for proper labels

---

### m5: No Network Reachability Check

**Description:** App doesn't check network before making requests  
**Files:** All ViewModel files  
**Impact:** Confusing error messages on poor connections  
**Time Estimate:** 60 minutes

**What Needs to Be Fixed:**
Add network monitoring:

```swift
// Create NetworkMonitor.swift
import Network

@MainActor
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    @Published var isConnected = true
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: DispatchQueue.global())
    }
}

// In ViewModels, check before API calls:
guard NetworkMonitor.shared.isConnected else {
    errorMessage = "No internet connection. Please check your network settings."
    return
}
```

**Expected Result:**
- App checks network status before API calls
- User sees clear "no connection" message
- Offline state handled gracefully

**Verification Steps:**
1. Enable Airplane Mode
2. Try to upload image
3. Verify "no connection" message appears
4. Disable Airplane Mode
5. Verify app resumes normal operation
6. Test with slow network (Network Link Conditioner)

---

### m6: Memory Management - Large Images

**Description:** No image size validation or compression  
**Files:**
- `BananaUniverse/Features/Chat/ViewModels/ChatViewModel.swift`
- `BananaUniverse/Features/ImageUpscaler/ImageUpscalerView.swift`  
**Impact:** Memory issues with large images  
**Time Estimate:** 60 minutes

**What Needs to Be Fixed:**
Add image validation and compression:

```swift
// Add to ImageProcessing helper:
func validateAndCompressImage(_ image: UIImage) throws -> Data {
    // Check original size
    guard let originalData = image.jpegData(compressionQuality: 1.0) else {
        throw ImageError.invalidImage
    }
    
    // Max 10MB
    let maxSize = 10_000_000
    guard originalData.count <= maxSize else {
        throw ImageError.tooLarge(size: originalData.count)
    }
    
    // Compress if over 5MB
    if originalData.count > 5_000_000 {
        guard let compressed = image.jpegData(compressionQuality: 0.7) else {
            throw ImageError.compressionFailed
        }
        return compressed
    }
    
    return originalData
}
```

**Expected Result:**
- Images validated before upload
- Large images automatically compressed
- User notified if image too large
- No memory crashes

**Verification Steps:**
1. Select 50MB+ image
2. Verify error message appears
3. Select 8MB image
4. Verify automatic compression works
5. Verify processed result maintains quality
6. Test on older devices (iPhone SE 2)

---

### m7: No App Icon for Dark Mode Variant

**Description:** App icon may not look good on dark home screen  
**Files:** `BananaUniverse/Assets.xcassets/AppIcon.appiconset/`  
**Impact:** Poor visibility on dark backgrounds  
**Time Estimate:** 30 minutes

**What Needs to Be Fixed:**
Test icon on various backgrounds:
1. Light home screen
2. Dark home screen
3. Colored wallpapers
4. iOS 18 tinted icons

Consider adding dark mode variant if needed.

**Expected Result:**
- Icon clearly visible on all backgrounds
- Icon matches app branding
- Icon stands out on home screen

**Verification Steps:**
1. Install app on device
2. Test with light mode wallpaper
3. Test with dark mode wallpaper
4. Test with various colored wallpapers
5. Compare to competitor app icons
6. Get feedback from design team

---

### m8: Build Warnings / Dead Code

**Description:** Preview code has incorrect nil casting  
**File:** `BananaUniverse/Features/ImageUpscaler/ImageUpscalerView.swift:392`  
**Impact:** Build warning, code smell  
**Time Estimate:** 5 minutes

**What Needs to Be Fixed:**
```swift
// Before (Line 389-398):
ImageUpscalerView(tool: Tool(
    id: "image_upscaler",
    title: "Image Upscaler",
    imageURL: nil as URL?,  // ❌ Incorrect
    category: "restoration",
    requiresPro: false,
    modelName: "upscale",
    placeholderIcon: "arrow.up.backward.and.arrow.down.forward",
    prompt: "Upscale this image by 2x while maintaining quality"
))

// After:
ImageUpscalerView(tool: Tool(
    id: "image_upscaler",
    title: "Image Upscaler",
    imageURL: nil,  // ✅ Correct
    category: "restoration",
    requiresPro: false,
    modelName: "upscale",
    placeholderIcon: "arrow.up.backward.and.arrow.down.forward",
    prompt: "Upscale this image by 2x while maintaining quality"
))
```

**Expected Result:**
- No build warnings
- Preview compiles correctly
- Clean build output

**Verification Steps:**
1. Build app (Cmd+B)
2. Check for warnings in Issue Navigator
3. Verify no warnings related to nil casting
4. Preview ImageUpscalerView in Canvas
5. Verify preview renders correctly

---

### m9: Settings Buttons Don't Work

**Description:** All settings buttons have empty handlers  
**File:** `BananaUniverse/Features/Profile/Views/ProfileView.swift:259-278`  
**Impact:** Dead-end navigation, poor UX  
**Time Estimate:** 90 minutes

**What Needs to Be Fixed:**
Implement all settings screens:

```swift
// Account Settings
SettingsRow(icon: "person.circle", title: "Account Settings") {
    showAccountSettings = true
}
.sheet(isPresented: $showAccountSettings) {
    AccountSettingsView()
}

// Notifications
SettingsRow(icon: "bell", title: "Notifications") {
    showNotificationSettings = true
}
.sheet(isPresented: $showNotificationSettings) {
    NotificationSettingsView()
}

// Help & Support
SettingsRow(icon: "questionmark.circle", title: "Help & Support") {
    if let url = URL(string: "https://bananauniverse.com/support") {
        openURL(url)
    }
}
```

**Expected Result:**
- All settings buttons open appropriate screens
- Account settings shows user info and logout
- Notification settings shows toggle preferences
- Help & Support opens web page

**Verification Steps:**
1. Tap "Account Settings" → verify screen opens
2. Verify user email displayed
3. Test logout functionality
4. Tap "Notifications" → verify settings screen
5. Test notification toggles
6. Tap "Help & Support" → verify Safari opens
7. Tap "Terms & Privacy" → verify Safari opens

---

### m10: TestFlight / Reviewer Notes Missing

**Description:** No instructions for Apple reviewers  
**Files:** App Store Connect metadata  
**Impact:** Reviewers may miss features, causing delays  
**Time Estimate:** 30 minutes

**What Needs to Be Fixed:**
Prepare reviewer notes for App Store Connect:

```
REVIEWER NOTES:

Test Account:
Email: reviewer@bananauniverse.com
Password: TestAccount2024!
(Account pre-loaded with 100 credits)

Testing Instructions:
1. App uses AI image processing (fal.ai) - results may take 20-30 seconds
2. Free users get 10 credits, each process costs 1 credit
3. To test premium features, use Sign in with Apple or test account
4. "Pro Looks" tab requires premium subscription
5. Test subscription in Sandbox environment

Known Issues:
- None

Contact:
For urgent issues during review: support@bananauniverse.com
Response time: < 24 hours

Privacy:
- We collect email only for authentication
- Photos are processed via fal.ai API (encrypted)
- We do not train AI models on user photos
- Photos stored for 24 hours for free, 30 days for premium
```

**Expected Result:**
- Reviewer notes prepared in text file
- Test account created with credits
- Clear testing instructions provided
- Contact information included

**Verification Steps:**
1. Create test reviewer account in Supabase
2. Add 100 credits to account
3. Test login with reviewer credentials
4. Verify all features accessible
5. Copy notes to App Store Connect
6. Save draft before submission

---

### Phase 3 Checklist

- [ ] **m1:** App name finalized for launch
- [ ] **m2:** iPad compatibility tested (or native support added)
- [ ] **m3:** Haptic feedback consistent across all interactions
- [ ] **m4:** VoiceOver labels added to all UI elements
- [ ] **m5:** Network reachability check implemented
- [ ] **m6:** Image size validation and compression added
- [ ] **m7:** App icon tested on various backgrounds
- [ ] **m8:** Build warnings resolved
- [ ] **m9:** All settings screens implemented
- [ ] **m10:** Reviewer notes prepared
- [ ] **Verification:** Full app QA pass completed
- [ ] **Testing:** Beta testers report positive feedback
- [ ] **Screenshots:** App Store screenshots captured
- [ ] **Sign-off:** Ready for App Store submission

---

## Progress Tracker

| Phase | Issue ID | Title | Status | Assigned To | Verified |
|-------|----------|-------|--------|-------------|----------|
| **Phase 1** | C1 | Missing Adapty API Key | ⬜ Not Started | | |
| Phase 1 | C2 | Missing NSPhotoLibraryUsageDescription | ⬜ Not Started | | |
| Phase 1 | C3 | Unlimited Mode Toggle Visible | ⬜ Not Started | | |
| Phase 1 | C4 | Incomplete Save/Share Button | ⬜ Not Started | | |
| Phase 1 | C5 | Excessive Debug Print Statements | ⬜ Not Started | | |
| **Phase 2** | M1 | Force Unwraps Throughout Codebase | ⬜ Not Started | | |
| Phase 2 | M2 | No Localization / Hardcoded Strings | ⬜ Not Started | | |
| Phase 2 | M3 | Missing Error State Handling | ⬜ Not Started | | |
| Phase 2 | M4 | Privacy Labels Mismatch | ⬜ Not Started | | |
| Phase 2 | M5 | Missing Sign in with Apple | ⬜ Not Started | | |
| Phase 2 | M6 | Incomplete Documentation URLs | ⬜ Not Started | | |
| Phase 2 | M7 | Terms & Privacy Not Linked | ⬜ Not Started | | |
| **Phase 3** | m1 | App Name Length Concern | ⬜ Not Started | | |
| Phase 3 | m2 | iPad Support Not Tested | ⬜ Not Started | | |
| Phase 3 | m3 | No Haptic Feedback Consistency | ⬜ Not Started | | |
| Phase 3 | m4 | Accessibility Labels Missing | ⬜ Not Started | | |
| Phase 3 | m5 | No Network Reachability Check | ⬜ Not Started | | |
| Phase 3 | m6 | Memory Management - Large Images | ⬜ Not Started | | |
| Phase 3 | m7 | App Icon Dark Mode Variant | ⬜ Not Started | | |
| Phase 3 | m8 | Build Warnings / Dead Code | ⬜ Not Started | | |
| Phase 3 | m9 | Settings Buttons Don't Work | ⬜ Not Started | | |
| Phase 3 | m10 | TestFlight Reviewer Notes Missing | ⬜ Not Started | | |

---

## Status Legend

- ⬜ Not Started
- 🔄 In Progress
- ✅ Completed
- ⚠️ Blocked
- ❌ Failed Verification

---

## Timeline Estimates

| Phase | Estimated Time | Target Completion |
|-------|----------------|-------------------|
| Phase 1: TestFlight Blockers | 2-4 hours | Day 1 |
| Phase 2: App Store Blockers | 4-6 hours | Day 2-3 |
| Phase 3: Quality & UX Polish | 8-12 hours | Day 4-7 |
| **Total** | **14-22 hours** | **1 week** |

---

## Sign-off Requirements

### Phase 1 (TestFlight Ready)
- [ ] Development lead review
- [ ] QA testing pass
- [ ] TestFlight build uploaded
- [ ] Beta invitation sent

### Phase 2 (App Store Ready)
- [ ] Development lead review
- [ ] QA comprehensive testing
- [ ] Legal review of privacy/terms
- [ ] Marketing review of metadata
- [ ] App Store submission approved

### Phase 3 (Production Quality)
- [ ] Full regression testing
- [ ] Beta tester feedback incorporated
- [ ] Performance benchmarks met
- [ ] Accessibility audit passed
- [ ] Final stakeholder approval

---

**Document Status:** ACTIVE  
**Last Updated:** October 17, 2025  
**Next Review:** After Phase 1 completion

