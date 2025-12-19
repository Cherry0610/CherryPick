# 📱 App Flow - CherryPick

## ✅ Navigation Flow

### 1. **Splash Screen** (`screens/splash_screen.dart`)
- **Duration**: 2 seconds
- **Shows**: CherryPick logo, tagline, loading indicator
- **Next**: Checks onboarding status and navigates accordingly

### 2. **Onboarding Screen** (`screens/general/onboarding_screen.dart`)
- **When**: First time users (hasSeenOnboarding = false)
- **Shows**: 3 feature cards explaining the app
- **Actions**: 
  - Swipe through cards
  - Tap "Next" to advance
  - Tap "Get Started" on last card
- **Next**: Navigates to **Sign In Screen**
- **Saves**: Sets `hasSeenOnboarding = true` in SharedPreferences

### 3. **Sign In Screen** (`screens/auth/sign_in_screen.dart`)
- **When**: After onboarding OR user not logged in
- **Shows**: Email/password login form
- **Actions**:
  - Sign in with email/password
  - Sign up (navigates to Sign Up screen)
  - Forgot password
- **Next**: On successful login → Navigates to **Home Screen**

### 4. **Home Screen** (`screens/general/home_screen.dart`)
- **When**: User is authenticated
- **Shows**: Main app dashboard with:
  - Trending deals
  - For you section
  - Search bar
  - Bottom navigation
- **This is the main app entry point**

## 🔄 Flow Diagram

```
┌─────────────┐
│   Splash    │ (2 seconds)
└──────┬──────┘
       │
       ├─→ Has seen onboarding? ──No──→ ┌──────────────┐
       │                                  │  Onboarding  │
       │                                  └──────┬───────┘
       │                                         │
       │                                         │ (Get Started)
       │                                         ↓
       │                                  ┌──────────────┐
       │                                  │  Sign In     │
       └─→ Yes ──→ Is logged in? ──No──→ └──────┬───────┘
                                                 │
                                                 │ (Sign In Success)
                                                 ↓
                                          ┌──────────────┐
                                          │  Home Screen │
                                          └──────────────┘
```

## 📝 Key Points

1. **Splash Screen** is always the entry point
2. **Onboarding** only shows once (stored in SharedPreferences)
3. **Sign In** is required before accessing the app
4. **Home Screen** is the main authenticated app experience

## 🔐 Authentication State

- Uses Firebase Auth to check login status
- If user is logged in → Skip to Home Screen
- If user is not logged in → Show Sign In Screen

## 💾 Persistence

- **Onboarding status**: Stored in SharedPreferences (`kHasSeenOnboarding`)
- **Auth status**: Managed by Firebase Auth (persists across app restarts)

## 🎯 User Journey

### First Time User:
1. Splash Screen (2s)
2. Onboarding Screen (3 cards)
3. Sign In Screen
4. Home Screen

### Returning User (Not Logged In):
1. Splash Screen (2s)
2. Sign In Screen
3. Home Screen

### Returning User (Logged In):
1. Splash Screen (2s)
2. Home Screen (direct)


