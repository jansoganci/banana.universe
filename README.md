# PixelMage 🍌✨

**AI-Powered Image Processing for iOS**

PixelMage is a modern iOS app that transforms your photos using cutting-edge AI technology. Built with SwiftUI and powered by Supabase Edge Functions, it delivers professional-grade image enhancement with a simple, elegant interface.

## ✨ Features

- **AI Image Enhancement**: Transform photos with advanced AI models
- **Real-time Processing**: Fast, cloud-powered image processing
- **Dark Theme**: Beautiful dark UI optimized for iOS
- **Credit System**: Free tier with premium upgrades
- **Offline Support**: Local storage and sync capabilities

## 🏗️ Tech Stack

- **Frontend**: Swift 5.9+ + SwiftUI (iOS 15.0+)
- **Backend**: Supabase Edge Functions (Deno/TypeScript)
- **AI Processing**: fal.ai integration
- **Authentication**: Supabase Auth
- **Payments**: Adapty subscription management
- **Storage**: Supabase Storage with RLS policies

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 15.0+ target device/simulator
- Supabase account
- Adapty account (for subscriptions)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/jansoganci/PixelMage.git
cd PixelMage
```

2. Open `noname_banana.xcodeproj` in Xcode

3. Configure your Supabase credentials in the project

4. Build and run on your device or simulator

## 📱 App Structure

```
PixelMage/
├── App/                    # Main app entry point
├── Core/                   # Core components and services
│   ├── Components/         # Reusable UI components
│   ├── Design/            # Design system and tokens
│   ├── Models/            # Data models
│   ├── Services/          # Business logic services
│   └── Networking/        # API communication
├── Features/              # Feature-specific modules
│   ├── Authentication/    # User auth flows
│   ├── Chat/             # AI processing interface
│   ├── Home/             # Main dashboard
│   ├── Library/          # Image history
│   ├── Profile/          # User settings
│   └── Paywall/          # Subscription management
└── supabase/             # Backend functions and migrations
```

## 🔧 Configuration

### Supabase Setup

1. Create a new Supabase project
2. Run the migrations in `supabase/migrations/`
3. Deploy the Edge Function in `supabase/functions/process-image/`
4. Configure storage buckets and RLS policies

### Environment Variables

Set up your Supabase configuration in the iOS app:
- Project URL
- Anon key
- Service role key (for Edge Functions)

## 📄 License

This project is private and proprietary. All rights reserved.

## 🤝 Contributing

This is a private project. For questions or support, contact the development team.

---

**Built with ❤️ using the Steve Jobs philosophy: "Simplicity is the ultimate sophistication"**
