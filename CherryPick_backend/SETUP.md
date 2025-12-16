# Quick Setup Guide

## Step 1: Install Dependencies

```bash
cd CherryPick_backend
npm install
```

## Step 2: Set Up Firebase Admin SDK

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `cherrypick-67246`
3. Go to **Project Settings** (gear icon) > **Service Accounts**
4. Click **Generate New Private Key**
5. Save the downloaded JSON file as `serviceAccountKey.json` in the `CherryPick_backend` directory

**Important:** Never commit `serviceAccountKey.json` to git! It's already in `.gitignore`.

## Step 3: Configure Environment Variables

```bash
cp .env.example .env
```

Edit `.env` if needed (defaults should work for most cases).

## Step 4: Start the Server

**Development mode (with auto-reload):**
```bash
npm run dev
```

**Production mode:**
```bash
npm start
```

## Step 5: Test the API

Open your browser or use curl:

```bash
# Health check
curl http://localhost:3000/health

# Search products
curl http://localhost:3000/api/products/search?q=apple

# Get stores
curl http://localhost:3000/api/stores
```

## Troubleshooting

### "Firebase Admin SDK initialization failed"
- Make sure `serviceAccountKey.json` exists in the backend directory
- Verify the JSON file is valid and contains your Firebase credentials

### "Cannot find module"
- Run `npm install` again
- Make sure you're using Node.js 18 or higher

### Port already in use
- Change the PORT in `.env` file
- Or kill the process using port 3000: `lsof -ti:3000 | xargs kill`

## Next Steps

1. Test all endpoints using Postman or curl
2. Integrate with your Flutter app
3. Set up Firebase Storage rules for receipt images
4. Configure CORS for production if needed



