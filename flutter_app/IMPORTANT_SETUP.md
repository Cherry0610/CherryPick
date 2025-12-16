# ⚠️ IMPORTANT: Enable Firebase Authentication

## 🚨 The Error You're Seeing

**"An internal error has occurred, print and inspect the error details for more information"**

This happens because **Firebase Email/Password authentication is not enabled yet**.

## ✅ SOLUTION (Copy & Paste These Steps):

### Step 1: Open Firebase Console
🔗 https://console.firebase.google.com/

### Step 2: Click on Your Project
Click on: **cherrypick-67246**

### Step 3: Go to Authentication
Look for "Authentication" in the left sidebar and **click it**

### Step 4: Click "Get Started" (if shown)
If you see a blue "Get Started" button, click it

### Step 5: Enable Email/Password
1. Click on the **"Sign-in method"** tab
2. Click on **"Email/Password"** from the list
3. Toggle the **first switch** to **ENABLED** (for Email/Password)
4. Toggle the **second switch** to **ENABLED** (for Email link - optional but recommended)
5. Click **"SAVE"** at the bottom

### Step 6: Test the App
Now go back to your app and try creating an account again!

## 📱 What Should Happen After Enabling:

1. Fill in your details (Name: Cherry Wong, Email: jengman0708@gmail.com, Password: Aa06100610)
2. Click "Create Account"
3. See: **"Welcome to CherryPick, Cherry! You are now signed in."**
4. Automatically taken to the main app!

## 🔍 Why This Happens:

Firebase requires authentication providers to be manually enabled for security reasons. This is a one-time setup.

## 💡 Alternative Quick Test:

If you want to test the UI without Firebase, you can:
1. Check that the password requirements are visible ✅
2. Check that validation works ✅
3. The error message is now more helpful ✅

But to actually create accounts, you MUST enable Email/Password in Firebase Console!

---

## 📸 Visual Guide:

```
Firebase Console
  ├─ 📂 cherrypick-67246 (click this)
  │  ├─ 🔐 Authentication (click this)
  │  │  ├─ 📝 Get Started (if shown, click this)
  │  │  ├─ 🔑 Sign-in method (click this tab)
  │  │  │  ├─ 📧 Email/Password (click this)
  │  │  │  │  ├─ ✅ Enable (toggle ON)
  │  │  │  │  └─ 💾 Save (click this button)
```

**Time Required: 2 minutes max!**

---

Once you enable this, your account creation will work perfectly! 🎉









