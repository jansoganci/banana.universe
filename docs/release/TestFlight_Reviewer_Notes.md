# 🍌 BananaUniverse - TestFlight Reviewer Notes

**App Version:** 1.0.0  
**Build:** TestFlight Beta  
**Platform:** iOS 16.0+  
**Device:** iPhone Only  

---

## 🔐 Test Account Information

### Primary Test Account
- **Email:** `reviewer@bananauniverse.com`
- **Password:** `TestAccount2024!`
- **Credits:** 100 credits pre-loaded
- **Status:** Premium account with full access

### Alternative Test Account (Anonymous)
- **Usage:** Start app without signing in
- **Credits:** 10 free credits
- **Limitations:** Basic features only

---

## 📱 App Overview

**BananaUniverse** is an AI-powered image enhancement app that uses advanced machine learning to improve, upscale, and transform photos. The app features a credit-based system where users can process images using AI models.

### Key Features:
1. **AI Image Processing** - Enhance and upscale images using fal.ai models
2. **Credit System** - Free users get 10 credits, premium users can purchase more
3. **Authentication** - Sign in with Apple for account sync
4. **Image Library** - Save and manage processed images
5. **Real-time Processing** - Live preview of AI enhancements

---

## 💳 Credit System Explained

### Free Users (Anonymous)
- **Starting Credits:** 10 credits
- **Cost per Process:** 1 credit per image
- **Features:** Basic image processing and upscaling
- **Data:** Credits stored locally on device

### Premium Users (Authenticated)
- **Starting Credits:** 10 credits
- **Credit Packs:** 10, 50, 100, 500 credits available
- **Features:** All features + credit sync across devices
- **Data:** Credits synced to cloud account

### Credit Usage:
- **Image Enhancement:** 1 credit per image
- **Image Upscaling:** 1 credit per image
- **Processing Time:** 20-30 seconds per image (AI processing)

---

## 🧪 Testing Instructions

### 1. Initial Setup
1. **Install app** from TestFlight
2. **Launch app** - you'll start as anonymous user
3. **Check credits** - should show "10 Credits" in top-right
4. **Navigate tabs** - Home, Library, Profile

### 2. Test Anonymous User Flow
1. **Go to Home tab**
2. **Tap "Select Image"** - choose any photo from library
3. **Add prompt** (optional) - e.g., "Make this image more vibrant"
4. **Tap "Process Image"** - wait 20-30 seconds
5. **Verify result** - enhanced image should appear
6. **Check credits** - should now show "9 Credits"

### 3. Test Authentication
1. **Go to Profile tab**
2. **Tap "Sign In with Apple"**
3. **Complete authentication** - use test account if needed
4. **Verify credits** - should show "10 Credits" (synced)
5. **Check sync** - credits should be the same across devices

### 4. Test Premium Features
1. **Use test account** (`reviewer@bananauniverse.com`)
2. **Go to Paywall** - tap "Get More Credits" when credits low
3. **Test purchase flow** - use Sandbox environment
4. **Verify credit addition** - credits should increase

### 5. Test Image Upscaler
1. **Go to Home tab**
2. **Tap "Image Upscaler"** button
3. **Select image** - choose a photo
4. **Select upscale factor** - 2x, 3x, or 4x
5. **Tap "Upscale Image"** - wait for processing
6. **Verify result** - upscaled image should appear
7. **Check credits** - should decrease by 1

### 6. Test Library Features
1. **Go to Library tab**
2. **View processed images** - should show all previous results
3. **Tap on image** - should open detail view
4. **Test save/share** - verify functionality
5. **Test delete** - remove images from library

---

## ⚠️ Important Testing Notes

### AI Processing
- **Processing Time:** 20-30 seconds per image (this is normal)
- **Network Required:** App needs internet for AI processing
- **Quality:** Results depend on input image quality
- **Model:** Uses fal.ai nano-banana/edit model

### Credit System
- **No Refunds:** Credits are consumed immediately when processing starts
- **Sync Delay:** Credit sync may take 1-2 seconds
- **Offline Mode:** Credits work offline, but processing requires internet

### Known Behaviors
- **Large Images:** Images over 10MB are rejected with clear error message
- **Network Issues:** App shows "No internet connection" if offline
- **Memory Management:** App automatically handles large images
- **Background Processing:** App can process images in background

---

## 🔒 Privacy & Data Handling

### Data Collection
- **Email:** Only collected for authentication (Sign in with Apple)
- **Photos:** Processed via encrypted fal.ai API
- **Usage Data:** Basic analytics for app improvement

### Data Storage
- **Free Users:** Photos stored for 24 hours
- **Premium Users:** Photos stored for 30 days
- **Local Storage:** Processed images cached locally
- **Cloud Storage:** Supabase (encrypted, GDPR compliant)

### AI Processing
- **No Training:** We do NOT train AI models on user photos
- **Third-party:** Uses fal.ai for processing (trusted provider)
- **Encryption:** All data transmitted over HTTPS
- **Deletion:** Photos automatically deleted after retention period

---

## 🆘 Support & Contact

### During Review
- **Email:** `support@bananauniverse.com`
- **Response Time:** < 24 hours
- **Priority:** High for review issues

### Technical Issues
- **App Crashes:** Check memory usage, try smaller images
- **Processing Fails:** Check internet connection, try again
- **Credit Issues:** Sign out/in to refresh credit sync
- **Authentication:** Use test account if Sign in with Apple fails

### Test Account Reset
If test account runs out of credits:
1. Contact support for credit reset
2. Or create new anonymous account
3. Or purchase credits in Sandbox environment

---

## 📋 Review Checklist

### ✅ Core Functionality
- [ ] App launches without crashes
- [ ] Image selection works
- [ ] AI processing completes successfully
- [ ] Results display correctly
- [ ] Credits system functions properly

### ✅ Authentication
- [ ] Sign in with Apple works
- [ ] Anonymous mode works
- [ ] Credit sync functions
- [ ] Account switching works

### ✅ Purchases
- [ ] Paywall displays correctly
- [ ] Purchase flow works in Sandbox
- [ ] Credits are added after purchase
- [ ] Restore purchases works

### ✅ Privacy
- [ ] Privacy policy accessible
- [ ] Terms of service accessible
- [ ] Data handling is transparent
- [ ] No unexpected data collection

### ✅ Performance
- [ ] App handles large images gracefully
- [ ] Memory usage is reasonable
- [ ] Network errors are handled
- [ ] Background processing works

---

## 🎯 Expected Review Outcome

**App should be approved for App Store release** based on:
- ✅ Clear value proposition (AI image enhancement)
- ✅ Fair pricing model (credit-based)
- ✅ Proper authentication (Sign in with Apple)
- ✅ Transparent privacy practices
- ✅ No policy violations
- ✅ Good user experience

---

**Thank you for reviewing BananaUniverse! 🍌**

For any questions during review, please contact: `support@bananauniverse.com`

