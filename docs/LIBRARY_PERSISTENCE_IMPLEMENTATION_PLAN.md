# 📚 Library Persistence Implementation Plan

> **Goal:** Enable users to view all their previously generated images in the Library screen by persisting image records to the database.

**Status:** 🔴 Not Started  
**Estimated Effort:** 1-2 days  
**Priority:** High  

---

## 📊 Current State Analysis

### ✅ What's Already Working
- [x] Images stored in Supabase Storage (`uploads/` and `processed/` directories)
- [x] `jobs` table schema is complete and supports both user types
- [x] RLS policies configured correctly
- [x] Library UI components built (empty state)
- [x] Hybrid auth system (anonymous + authenticated)

### ❌ What's Missing
- [ ] Database persistence - Edge Function doesn't save to `jobs` table
- [ ] Library data fetching - No query implementation
- [ ] Anonymous user images lost after session ends
- [ ] No way to retrieve historical images

---

## 🎯 Implementation Phases

### **Phase 1: Backend Database Persistence** ⚙️
**Estimated Time:** 2-3 hours

#### Task 1.1: Update Edge Function to Save Jobs
**File:** `/supabase/functions/process-image/index.ts`

- [ ] **Add job ID generation**
  - [ ] Import UUID library or use crypto.randomUUID()
  - [ ] Generate unique job ID before processing starts
  - Location: ~Line 175 (before FAL.AI call)

- [ ] **Track processing start time**
  - [ ] Add `const startTime = Date.now();` before FAL.AI call
  - Location: ~Line 176

- [ ] **Insert record into jobs table**
  - [ ] Add database insert after Storage upload succeeds
  - [ ] Location: After line 255 (after signed URL generation)
  - [ ] Include fields:
    ```javascript
    - id: generated UUID
    - user_id: userType === 'authenticated' ? userIdentifier : null
    - device_id: userType === 'anonymous' ? userIdentifier : null
    - model: 'nano-banana-edit'
    - status: 'completed'
    - input_url: image_url (from request)
    - output_url: storagePath
    - options: { prompt, timestamp }
    - created_at: new Date().toISOString()
    - completed_at: new Date().toISOString()
    - processing_time_seconds: Math.floor((Date.now() - startTime) / 1000)
    ```

- [ ] **Add error handling**
  - [ ] Wrap database insert in try-catch
  - [ ] Log errors but don't block user response
  - [ ] Consider retry logic for transient failures

- [ ] **Update response to include job_id** (optional)
  - [ ] Add `job_id` to ProcessImageResponse interface
  - [ ] Return job_id in success response

- [ ] **Test Edge Function**
  - [ ] Deploy updated function: `supabase functions deploy process-image`
  - [ ] Test with authenticated user
  - [ ] Test with anonymous user (device_id)
  - [ ] Verify records appear in jobs table
  - [ ] Check both user_id and device_id cases

---

### **Phase 2: iOS Query Layer** 📱
**Estimated Time:** 3-4 hours

#### Task 2.1: Add Database Query Service
**File:** `/noname_banana/Core/Services/SupabaseService.swift`

- [ ] **Create JobRecord model**
  - [ ] Add struct at bottom of file (~line 790)
  - [ ] Include all fields from jobs table
  - [ ] Add Codable conformance
  - [ ] Use snake_case to camelCase decoding
  ```swift
  struct JobRecord: Codable, Identifiable {
      let id: UUID
      let userId: UUID?
      let deviceId: String?
      let model: String
      let status: String
      let inputUrl: String?
      let outputUrl: String?
      let options: [String: Any]?
      let createdAt: Date
      let completedAt: Date?
      let updatedAt: Date
  }
  ```

- [ ] **Add fetchUserJobs() function**
  - [ ] Location: After `upscaleImage()` function (~line 647)
  - [ ] Accept parameters: `userState: UserState`, `limit: Int = 50`, `offset: Int = 0`
  - [ ] Build query based on user type:
    - Authenticated: `.eq("user_id", value: userState.identifier)`
    - Anonymous: `.eq("device_id", value: userState.identifier)`
  - [ ] Filter: `.eq("status", value: "completed")`
  - [ ] Order: `.order("completed_at", ascending: false)`
  - [ ] Limit: `.limit(limit)`
  - [ ] Return: `async throws -> [JobRecord]`

- [ ] **Test query function**
  - [ ] Create test in Xcode playground or unit test
  - [ ] Test with authenticated user
  - [ ] Test with anonymous user
  - [ ] Verify RLS policies allow access
  - [ ] Handle empty results gracefully

#### Task 2.2: Add Storage URL Helper
**File:** `/noname_banana/Core/Services/SupabaseService.swift`

- [ ] **Add getSignedURL() function**
  - [ ] Accept storage path as parameter
  - [ ] Generate signed URL with 30-day expiration
  - [ ] Handle errors (invalid path, expired bucket, etc.)
  - [ ] Return: `async throws -> String`

- [ ] **Add batch URL generation** (optional, for performance)
  - [ ] Accept array of paths
  - [ ] Return array of signed URLs
  - [ ] Useful for loading multiple Library images

---

### **Phase 3: Library ViewModel Integration** 🎨
**Estimated Time:** 2-3 hours

#### Task 3.1: Update LibraryViewModel
**File:** `/noname_banana/Features/Library/ViewModels/LibraryViewModel.swift`

- [ ] **Add service dependencies**
  - [ ] Import SupabaseService
  - [ ] Import HybridAuthService
  - [ ] Add private properties for services

- [ ] **Update loadHistory() function**
  - [ ] Remove mock implementation (lines 259-268)
  - [ ] Set `isLoading = true`
  - [ ] Get current userState from HybridAuthService
  - [ ] Call `SupabaseService.fetchUserJobs()`
  - [ ] Transform JobRecord → HistoryItem
  - [ ] Update `historyItems` array
  - [ ] Set `isLoading = false`
  - [ ] Handle errors with `errorMessage`

- [ ] **Implement data transformation**
  - [ ] Map `outputUrl` → `thumbnailUrl`
  - [ ] Extract `prompt` from `options` JSONB
  - [ ] Map `model` → `effectTitle` (e.g., "nano-banana-edit" → "AI Enhancement")
  - [ ] Convert timestamps to Date objects
  - [ ] Determine status from database status field

- [ ] **Implement refreshHistory()**
  - [ ] Call `loadHistory()` with pull-to-refresh indicator

- [ ] **Implement deleteJob()**
  - [ ] Delete from database: call Supabase delete
  - [ ] Delete from Storage: remove both input and output files
  - [ ] Update local `historyItems` array
  - [ ] Handle errors gracefully

- [ ] **Implement navigateToResult()**
  - [ ] Navigate to detail view (or expand inline)
  - [ ] Load full-resolution image
  - [ ] Show metadata (prompt, date, etc.)

#### Task 3.2: Update HistoryItem Model
**File:** `/noname_banana/Features/Library/Views/LibraryView.swift`

- [ ] **Update HistoryItem struct** (line 209-224)
  - [ ] Add initializer from JobRecord
  - [ ] Map database fields to UI properties:
    - `id` ← JobRecord.id
    - `thumbnailUrl` ← Generate signed URL from outputUrl
    - `effectTitle` ← Parse from model or options
    - `effectId` ← JobRecord.model
    - `status` ← Map JobRecord.status to JobStatus enum
    - `createdAt` ← JobRecord.completedAt ?? createdAt
    - `resultUrl` ← Generate signed URL from outputUrl
    - `originalImageKey` ← JobRecord.inputUrl

- [ ] **Handle optional fields**
  - [ ] Provide defaults for missing data
  - [ ] Show "Unknown" for missing prompts
  - [ ] Use placeholder image for missing thumbnails

---

### **Phase 4: Testing & Validation** ✅
**Estimated Time:** 3-4 hours

#### Task 4.1: Anonymous User Testing
- [ ] **Generate images as anonymous user**
  - [ ] Open app without signing in
  - [ ] Generate 3-5 images via Chat
  - [ ] Verify device_id stored in UserDefaults

- [ ] **Verify database persistence**
  - [ ] Check Supabase dashboard → jobs table
  - [ ] Confirm records have device_id (not user_id)
  - [ ] Verify output_url matches Storage path

- [ ] **Test Library screen**
  - [ ] Open Library tab
  - [ ] Verify all generated images appear
  - [ ] Check thumbnails load correctly
  - [ ] Verify timestamps display properly

- [ ] **Test persistence across app restarts**
  - [ ] Close app completely
  - [ ] Reopen app (should use same device_id)
  - [ ] Verify Library still shows images

- [ ] **Test image deletion**
  - [ ] Delete image from Library
  - [ ] Verify removed from database
  - [ ] Verify removed from Storage
  - [ ] Verify UI updates correctly

#### Task 4.2: Authenticated User Testing
- [ ] **Sign in and generate images**
  - [ ] Sign in with email/password or Apple
  - [ ] Generate 3-5 images via Chat
  - [ ] Verify user_id stored correctly

- [ ] **Verify database persistence**
  - [ ] Check jobs table for user_id records
  - [ ] Verify device_id is NULL
  - [ ] Confirm RLS policies allow access

- [ ] **Test cross-device persistence**
  - [ ] Sign out
  - [ ] Sign in on different device (or simulator)
  - [ ] Verify same images appear in Library

- [ ] **Test offline behavior**
  - [ ] Enable airplane mode
  - [ ] Open Library (should show cached data or error)
  - [ ] Disable airplane mode
  - [ ] Verify data refreshes

#### Task 4.3: Edge Case Testing
- [ ] **Empty Library state**
  - [ ] New user with 0 images
  - [ ] Verify empty state UI shows

- [ ] **Large dataset (100+ images)**
  - [ ] Generate or seed many images
  - [ ] Test scroll performance
  - [ ] Verify pagination (if implemented)

- [ ] **Corrupted data**
  - [ ] Manually corrupt a job record in database
  - [ ] Verify app handles gracefully
  - [ ] Show error or skip broken record

- [ ] **Expired signed URLs**
  - [ ] Manually expire URLs in database
  - [ ] Verify app regenerates URLs on load
  - [ ] Or shows appropriate error

- [ ] **Network failures**
  - [ ] Simulate timeout during fetch
  - [ ] Verify error message displays
  - [ ] Test retry mechanism

---

### **Phase 5: Performance Optimization** 🚀
**Estimated Time:** 2-3 hours (Optional for MVP)

#### Task 5.1: Implement Pagination
- [ ] **Add pagination to query**
  - [ ] Use `limit` and `offset` parameters
  - [ ] Load 20-50 items at a time
  - [ ] Implement "load more" button or infinite scroll

- [ ] **Add local caching**
  - [ ] Cache JobRecords in memory
  - [ ] Avoid re-fetching on navigation
  - [ ] Invalidate cache on new image generation

#### Task 5.2: Thumbnail Generation (Future)
- [ ] **Generate thumbnails on backend**
  - [ ] Resize processed image to 300x300px
  - [ ] Store in `thumbnails/` directory
  - [ ] Add `thumbnail_url` to options JSONB

- [ ] **Update UI to use thumbnails**
  - [ ] Load thumbnail for grid view
  - [ ] Load full image for detail view
  - [ ] Implement progressive loading

#### Task 5.3: Search & Filter (Future)
- [ ] **Add search bar**
  - [ ] Filter by prompt text
  - [ ] Filter by date range
  - [ ] Filter by tool/effect type

- [ ] **Add sorting options**
  - [ ] Date (newest/oldest)
  - [ ] Alphabetical
  - [ ] Most used tool

---

## 🔧 Technical Details

### Database Query Examples

**Anonymous User Query:**
```sql
SELECT * FROM jobs
WHERE device_id = 'ABC-123-DEF-456'
  AND status = 'completed'
ORDER BY completed_at DESC
LIMIT 50;
```

**Authenticated User Query:**
```sql
SELECT * FROM jobs
WHERE user_id = '550e8400-e29b-41d4-a716-446655440000'
  AND status = 'completed'
ORDER BY completed_at DESC
LIMIT 50;
```

### RLS Policies to Verify

```sql
-- Existing policies should allow:
1. "Users can view own jobs" - USING (auth.uid() = user_id)
2. "Service role can update jobs" - USING (auth.jwt()->>'role' = 'service_role')
```

### Error Handling Strategy

| Error Type | User Impact | Mitigation |
|------------|-------------|------------|
| DB insert fails | Image processed but not in Library | Log error, return success, add retry |
| RLS blocks query | Can't see Library images | Test policies, add service role fallback |
| Signed URL expired | Image won't load | Regenerate URLs on-demand |
| Network timeout | Library empty | Show error + retry button |

---

## 📂 Files to Modify

### Backend
- [ ] `/supabase/functions/process-image/index.ts` (~30 lines)

### iOS Client
- [ ] `/noname_banana/Core/Services/SupabaseService.swift` (~60 lines)
- [ ] `/noname_banana/Features/Library/ViewModels/LibraryViewModel.swift` (~100 lines)
- [ ] `/noname_banana/Features/Library/Views/LibraryView.swift` (~20 lines)

### Optional
- [ ] `/supabase/migrations/006_add_library_indexes.sql` (performance optimization)

---

## ⚠️ Known Limitations

- [ ] **Anonymous user data loss:** Images lost on device change/app delete (acceptable per requirements)
- [ ] **No image migration:** When anonymous→authenticated, images stay under device_id
- [ ] **7-day signed URLs:** Old images may need URL regeneration
- [ ] **No thumbnails:** Loading full images may be slow with many items

---

## 🎉 Success Criteria

### MVP Complete When:
- [x] Edge Function saves all processed images to jobs table
- [x] Anonymous users can view their images in Library
- [x] Authenticated users can view their images in Library
- [x] Images persist across app restarts (same device for anonymous)
- [x] Images persist across devices (for authenticated users)
- [x] Delete functionality works (DB + Storage)
- [x] Error states handled gracefully
- [x] All tests pass

### Future Enhancements:
- [ ] Thumbnail generation for faster loading
- [ ] Pagination for 100+ images
- [ ] Search and filter functionality
- [ ] Anonymous→Authenticated migration
- [ ] Share/export functionality
- [ ] Bulk delete/download

---

## 📋 Pre-Implementation Checklist

Before starting implementation:
- [ ] Review this plan with team
- [ ] Confirm anonymous data loss is acceptable
- [ ] Verify Supabase project has sufficient storage quota
- [ ] Backup current database (safety)
- [ ] Set up development environment
- [ ] Create feature branch: `feature/library-persistence`

---

## 🚀 Deployment Checklist

Before deploying to production:
- [ ] All unit tests pass
- [ ] Manual testing complete (all user scenarios)
- [ ] Edge Function deployed: `supabase functions deploy process-image`
- [ ] Database migrations applied (if any)
- [ ] RLS policies verified in production
- [ ] Error logging/monitoring configured
- [ ] App Store release notes updated
- [ ] User documentation updated (if needed)

---

## 📞 Support & Questions

**Issue Tracking:** Use GitHub Issues or project management tool  
**Documentation:** See `/docs/tech_stack.md` for architecture details  
**Code Review:** Required before merging to main branch  

---

**Last Updated:** [Current Date]  
**Plan Version:** 1.0  
**Status:** Ready for Implementation 🚀

