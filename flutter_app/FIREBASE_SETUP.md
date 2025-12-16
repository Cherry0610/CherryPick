# Firebase Setup Instructions for CherryPick

## 🔥 Current Status
✅ Firebase project is connected: `cherrypick-67246`
✅ iOS configuration file exists
✅ Android configuration file exists
⚠️ Firebase Authentication needs to be enabled

## 📋 Steps to Fix the "Internal Error"

### Step 1: Enable Firebase Authentication

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **cherrypick-67246**
3. Click on **Authentication** in the left menu
4. Click **Get Started**
5. Click the **Sign-in method** tab
6. Click on **Email/Password**
7. Toggle it to **Enabled**
8. Click **Save**

### Step 2: Create Sample Users (Optional)

To test immediately:

1. In Firebase Console → Authentication
2. Click **Add User**
3. Enter a test email and password
4. Click **Add User**
5. This user can now sign in to your app!

## 🧪 Test Your App

Once Email/Password is enabled:

1. Run the app: `flutter run`
2. Try creating an account
3. Use a valid email format
4. Follow password requirements:
   - At least 8 characters
   - One uppercase letter
   - One lowercase letter
   - One number

## 📱 What Happens After Account Creation

1. ✅ Account created in Firebase
2. ✅ User automatically signed in
3. ✅ Welcome message displayed
4. ✅ User goes to main app
5. ✅ Email verification sent (check inbox)

## 🐛 Troubleshooting

### "Internal error has occurred"
- Make sure Email/Password is enabled in Firebase Console
- Check your internet connection
- Verify Firebase project is active

### "Email already in use"
- Try a different email address
- Or sign in with existing email

### "Weak password"
- Use at least 8 characters
- Include uppercase, lowercase, and numbers
- Avoid common words

## ✨ Features Working

Once Firebase is set up, you'll have:
- ✅ User registration
- ✅ User authentication
- ✅ Email verification
- ✅ Password reset (coming soon)
- ✅ Secure data storage
- ✅ Receipt upload
- ✅ Price comparison
- ✅ Wishlist
- ✅ Expense tracking

## 🚀 Next Steps

After enabling authentication:
1. Test account creation
2. Test sign in
3. Try uploading receipts
4. Test price comparison features

---

**Note:** The Firebase configuration files are already in place. You just need to enable Email/Password authentication in the Firebase Console!









