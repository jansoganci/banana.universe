# Library Feature Improvement Plan

## Overview
This document outlines the step-by-step plan to improve the Library feature in BananaUniverse app. The current Library implementation has several missing features and bugs that need to be addressed to provide a complete user experience.

## Current Issues Identified

### 1. Thumbnail Display Issue
- **Problem**: Left side of history items shows empty white square instead of processed image thumbnail
- **Impact**: Users cannot see what they processed without opening details
- **Root Cause**: `HistoryItemRow` component missing proper image loading implementation

### 2. URL Generation Problem
- **Problem**: `generateSignedURL()` function not working properly
- **Impact**: Images cannot be loaded from Supabase storage
- **Root Cause**: URL signing mechanism not implemented correctly

### 3. Missing Download Functionality
- **Problem**: No way for users to re-download their processed images
- **Impact**: Users lose access to their processed images
- **Solution**: Add download option to three-dot menu

### 4. Row Tap Navigation Missing
- **Problem**: Tapping on history items does nothing
- **Impact**: Users cannot view full-size processed images
- **Solution**: Implement navigation to detail view or direct download

## Implementation Plan

### Phase 1: Fix Core Issues (Priority: High)

#### Step 1.1: Fix URL Generation
- **File**: `LibraryViewModel.swift`
- **Function**: `generateSignedURL(from path: String)`
- **Action**: 
  - Implement proper Supabase signed URL generation
  - Use `supabaseService.getSignedURL()` method
  - Handle URL generation errors gracefully
- **Expected Result**: Images can be loaded from Supabase storage

#### Step 1.2: Fix Thumbnail Display
- **File**: `HistoryItemRow.swift`
- **Action**:
  - Add `AsyncImage` component for thumbnail display
  - Implement proper loading states (loading, error, success)
  - Add fallback image for failed loads
  - Ensure proper aspect ratio and sizing
- **Expected Result**: Thumbnails display correctly in history list

### Phase 2: Add Download Functionality (Priority: High)

#### Step 2.1: Add Download Option to Menu
- **File**: `HistoryItemRow.swift`
- **Action**:
  - Add "Download" option to three-dot menu
  - Implement download action handler
  - Add download icon and proper styling
- **Expected Result**: Users can access download option from menu

#### Step 2.2: Implement Download Logic
- **File**: `LibraryViewModel.swift`
- **Action**:
  - Add `downloadImage(_ item: HistoryItem)` function
  - Use `StorageService` to save image to Photos library
  - Handle download permissions and errors
  - Show success/error feedback to user
- **Expected Result**: Images can be downloaded to device

### Phase 3: Add Row Tap Navigation (Priority: Medium)

#### Step 3.1: Create Detail View
- **File**: `ImageDetailView.swift` (new file)
- **Action**:
  - Create full-screen image viewer
  - Add zoom and pan gestures
  - Include download and share buttons
  - Add close button and proper navigation
- **Expected Result**: Dedicated view for viewing processed images

#### Step 3.2: Implement Navigation
- **File**: `LibraryView.swift`
- **Action**:
  - Add navigation state management
  - Implement `navigateToResult()` function
  - Add sheet or navigation link to detail view
  - Pass image data to detail view
- **Expected Result**: Tapping row opens image detail view

### Phase 4: Enhance User Experience (Priority: Low)

#### Step 4.1: Add Loading States
- **Files**: `HistoryItemRow.swift`, `ImageDetailView.swift`
- **Action**:
  - Add skeleton loading for thumbnails
  - Add loading indicators for downloads
  - Implement proper error states
- **Expected Result**: Better visual feedback during operations

#### Step 4.2: Add Image Caching
- **File**: `LibraryViewModel.swift`
- **Action**:
  - Implement image caching mechanism
  - Cache thumbnails and full images
  - Clear cache when needed
- **Expected Result**: Faster loading and better performance

## Technical Requirements

### Dependencies
- `AsyncImage` for image loading
- `PhotosUI` for photo library access
- `StorageService` for file operations
- `SupabaseService` for signed URLs

### Error Handling
- Network errors for image loading
- Permission errors for photo library access
- Storage errors for downloads
- URL generation errors

### Performance Considerations
- Lazy loading for thumbnails
- Image compression for storage
- Memory management for large images
- Cache size limits

## Testing Checklist

### Phase 1 Testing
- [ ] URLs generate correctly for all image types
- [ ] Thumbnails display in history list
- [ ] Error states show appropriate messages
- [ ] Loading states work properly

### Phase 2 Testing
- [ ] Download option appears in menu
- [ ] Images download to Photos library
- [ ] Download permissions handled correctly
- [ ] Success/error feedback works

### Phase 3 Testing
- [ ] Row tap opens detail view
- [ ] Image displays correctly in detail view
- [ ] Zoom and pan gestures work
- [ ] Navigation back works properly

### Phase 4 Testing
- [ ] Loading states display correctly
- [ ] Images cache properly
- [ ] Performance is acceptable
- [ ] Memory usage is reasonable

## Success Criteria

### Must Have
- Thumbnails display correctly in history list
- Users can download processed images
- Row tap navigation works
- All error states handled gracefully

### Should Have
- Smooth loading animations
- Image caching for performance
- Proper accessibility support
- Consistent UI/UX with rest of app

### Could Have
- Batch download functionality
- Image editing in detail view
- Sharing options in detail view
- Image metadata display

## Notes

- All changes should maintain existing functionality
- Follow existing code patterns and architecture
- Ensure proper error handling and user feedback
- Test on both light and dark themes
- Consider different screen sizes and orientations

## Estimated Timeline

- **Phase 1**: 2-3 days
- **Phase 2**: 1-2 days  
- **Phase 3**: 2-3 days
- **Phase 4**: 1-2 days
- **Total**: 6-10 days

---

*This document should be updated as implementation progresses and new requirements are identified.*
