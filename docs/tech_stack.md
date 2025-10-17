# Tech Stack — Banana Universe

**Version:** 3.0 (Supabase Architecture)  
**Last Updated:** January 2025  
**Status:** PRODUCTION STANDARD

---

## 🎯 **Summary**

**Modern iOS app using Supabase Edge Functions for AI processing.** SwiftUI + Supabase + fal.ai stack. Simple, fast, App Store compliant.

---

## 📊 **Stack Overview**

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| **iOS App** | Swift 5.9+ + SwiftUI | Native performance, Apple HIG compliance, modern declarative UI |
| **Min iOS Version** | iOS 15.0+ | Modern SwiftUI features, covers 95%+ of active devices |
| **Backend** | Supabase Edge Functions | Serverless, TypeScript/Deno, auto-scaling |
| **Auth** | Supabase Auth | Email, Google OAuth, Apple Sign-In built-in |
| **Database** | Supabase (PostgreSQL) | Managed Postgres, RLS policies, real-time subscriptions |
| **Payment** | Adapty | Subscription management, App Store IAP, analytics |
| **Storage** | Supabase Storage | Integrated with database, RLS policies, no AWS needed |
| **AI Provider** | fal.ai | Production-ready models, pay-per-use, clarity-upscaler |

---

## 📱 **iOS Frontend**

### **Core Technologies**
- **Language:** Swift 5.9+
- **UI:** SwiftUI (iOS 15.0+)
- **Architecture:** Feature-based MVVM
- **State:** Combine + @StateObject/@ObservedObject
- **Networking:** Supabase Swift SDK

### **Key Libraries**

| Library | Purpose | Integration |
|---------|---------|-------------|
| **Supabase-Swift** | Auth + database + storage client | SPM: `https://github.com/supabase/supabase-swift` |
| **Adapty-iOS** | Subscription management | SPM: `https://github.com/adaptyteam/AdaptySDK-iOS` |
| **Kingfisher** | Image loading/caching | SPM: `https://github.com/onevcat/Kingfisher` |

### **iOS 15 Compatibility**
- **SwiftUI:** Fully supported
- **async/await:** Native support
- **Combine:** Fully supported
- **PhotosUI:** PHPicker support

---

## 🖥️ **Backend**

### **Supabase Edge Functions**
- **Runtime:** Deno 1.x
- **Language:** TypeScript
- **Deployment:** `supabase functions deploy`
- **Scaling:** Automatic (Supabase managed)

### **Key Features**
- **Authentication:** JWT verification
- **Rate Limiting:** Database counters
- **AI Processing:** fal.ai API integration
- **File Storage:** Supabase Storage
- **Job Tracking:** PostgreSQL database

### **Edge Function Example**
```typescript
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

Deno.serve(async (req: Request) => {
  // 1. Authenticate JWT
  // 2. Check rate limits
  // 3. Call fal.ai API
  // 4. Update job status
  // 5. Return result
});
```

---

## 🗄️ **Database & Storage**

### **Supabase PostgreSQL**
- **Hosting:** Supabase managed
- **Features:** RLS policies, real-time subscriptions
- **Backup:** Automatic daily backups
- **Scaling:** Automatic

### **Database Schema**
```sql
-- User profiles
CREATE TABLE profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  email TEXT,
  subscription_tier TEXT DEFAULT 'free',
  requests_used_today INTEGER DEFAULT 0,
  requests_used_this_month INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- AI processing jobs
CREATE TABLE jobs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  model TEXT NOT NULL,
  status TEXT DEFAULT 'pending',
  input_url TEXT,
  output_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP
);
```

### **Supabase Storage**
- **Bucket:** `pixelmage-images-prod`
- **Access:** Private with RLS policies
- **Structure:** `uploads/{user_id}/{timestamp}-{filename}`
- **Features:** Automatic CDN, signed URLs

---

## 🔐 **Authentication & Security**

### **Supabase Auth**
- **Methods:** Email/password, Apple Sign-In
- **Tokens:** JWT (15min access, 30day refresh)
- **Storage:** iOS Keychain
- **Verification:** Edge Functions verify JWT

### **Row Level Security (RLS)**
```sql
-- Users can only access their own files
CREATE POLICY "Users can read own files" ON storage.objects
FOR SELECT USING (auth.uid()::text = (storage.foldername(name))[1]);

-- Users can only upload to their own folder
CREATE POLICY "Users can upload own files" ON storage.objects
FOR INSERT WITH CHECK (auth.uid()::text = (storage.foldername(name))[1]);
```

---

## 🤖 **AI Processing**

### **fal.ai Integration**
- **Model:** `fal-ai/clarity-upscaler`
- **API:** Direct calls from Edge Functions
- **Processing:** 2-10 seconds per image
- **Cost:** ~$0.01-0.05 per image

### **Processing Flow**
1. **Upload:** iOS → Supabase Storage
2. **Process:** iOS → Edge Function → fal.ai
3. **Store:** Edge Function → Supabase Storage
4. **Download:** iOS ← Supabase Storage

---

## 💰 **Monetization**

### **Adapty Subscriptions**
- **Weekly:** $4.99
- **Monthly:** $9.99
- **Annual:** $79.99
- **Integration:** Native iOS SDK

### **Rate Limiting**
| Tier | Daily Limit | Monthly Limit |
|------|-------------|---------------|
| **Free** | 20 | 600 |
| **PRO** | 1000 | 30,000 |

---

## 📊 **Performance**

### **Latency**
- **Edge Functions:** < 200ms cold start
- **fal.ai Processing:** 2-10 seconds
- **File Upload:** 1-5 seconds
- **Database Queries:** < 100ms

### **Scalability**
- **Concurrent Users:** Unlimited
- **File Storage:** Unlimited
- **Database:** Unlimited
- **Edge Functions:** Auto-scaling

---

## 💵 **Cost Structure**

### **Monthly Costs (Estimated)**
| Service | Free Tier | Pro Tier |
|---------|-----------|----------|
| **Supabase** | $0 | $25 |
| **fal.ai** | $0 | $50-500 |
| **App Store** | 30% revenue | 30% revenue |

### **Cost per User**
- **Free User:** $0 (20 requests/month)
- **PRO User:** ~$0.50/month (1000 requests)

---

## 🚀 **Deployment**

### **iOS App**
- **Platform:** App Store
- **Distribution:** TestFlight → App Store
- **Updates:** App Store automatic updates

### **Backend**
- **Platform:** Supabase Edge Functions
- **Deployment:** `supabase functions deploy`
- **Monitoring:** Supabase Dashboard
- **Scaling:** Automatic

### **Database**
- **Platform:** Supabase PostgreSQL
- **Migrations:** Supabase CLI
- **Backup:** Automatic daily

---

## 🔧 **Development Tools**

### **Local Development**
- **iOS:** Xcode + iOS Simulator
- **Backend:** `supabase functions serve`
- **Database:** Supabase Dashboard

### **Testing**
- **Unit Tests:** iOS app logic
- **Integration Tests:** Supabase services
- **E2E Tests:** Complete user flows

### **CI/CD**
- **iOS:** Xcode Cloud or GitHub Actions
- **Backend:** GitHub Actions + Supabase CLI
- **Database:** Supabase Dashboard

---

## 📈 **Monitoring & Analytics**

### **Supabase Dashboard**
- **Database:** Query performance, usage stats
- **Auth:** User sign-ups, active sessions
- **Storage:** File uploads, storage usage
- **Edge Functions:** Invocations, errors, latency

### **iOS Analytics**
- **Crash Reporting:** Built-in iOS crash reports
- **Usage Analytics:** Adapty analytics
- **Performance:** Xcode Instruments

---

## 🔄 **Migration Path**

### **From Legacy Backend**
1. **Remove:** Node.js, Express, Redis, S3
2. **Add:** Supabase Edge Functions, Supabase Storage
3. **Update:** API calls to use Supabase SDK
4. **Deploy:** Edge Functions instead of servers

### **Benefits of Migration**
- **Simpler:** No servers to manage
- **Cheaper:** Pay-per-use pricing
- **Faster:** Global CDN, edge functions
- **Secure:** Built-in auth and RLS

---

## 📚 **References**

- [Supabase Docs](https://supabase.com/docs)
- [Supabase Swift SDK](https://github.com/supabase/supabase-swift)
- [Adapty Docs](https://docs.adapty.io)
- [fal.ai Docs](https://fal.ai/docs)
- [Apple HIG](https://developer.apple.com/design/human-interface-guidelines/)

---

**Tech Stack Status:** ✅ **PRODUCTION READY**