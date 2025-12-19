# SmartPrice Backend API

Simple Express.js backend for SmartPrice Flutter app.

## 🚀 Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Set Up Environment

Copy the example environment file:

```bash
cp .env.example .env
```

### 3. Configure Firebase (Optional but Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `cherrypick-67246`
3. Go to **Project Settings** → **Service Accounts**
4. Click **Generate new private key**
5. Save the file as `serviceAccountKey.json` in this folder
6. Update `server.js` to use the service account (uncomment the code)

### 4. Start the Server

**Development mode (auto-restart on changes):**
```bash
npm run dev
```

**Production mode:**
```bash
npm start
```

The server will start on `http://localhost:3000`

## 📚 API Endpoints

### Public Endpoints

- `GET /api/health` - Health check
- `GET /api/products/search?q=query` - Search products
- `GET /api/products/:id` - Get product details
- `GET /api/prices/product/:productId` - Get product prices
- `GET /api/prices/compare/:productId` - Get price comparison
- `GET /api/navigation/nearby?lat=0&lng=0&limit=10` - Get nearby stores

### Protected Endpoints (Require Authentication)

- `GET /api/wishlist` - Get user wishlist
- `POST /api/wishlist` - Update user wishlist
- `GET /api/expenses` - Get user expenses

## 🔐 Authentication

Protected endpoints require a Firebase ID token in the Authorization header:

```
Authorization: Bearer <firebase-id-token>
```

## 🧪 Testing

Test the health endpoint:

```bash
curl http://localhost:3000/api/health
```

## 📝 Notes

- The server uses Firebase Firestore as the database
- Make sure Firestore is enabled in Firebase Console
- Set up Firestore security rules (see BACKEND_SETUP_GUIDE.md)
- For production, use environment variables for sensitive data

## 🆘 Troubleshooting

**"Database not initialized"**
- Make sure Firebase Admin SDK is properly configured
- Check that service account key is in the correct location

**"CORS error"**
- The server already has CORS enabled
- Make sure your Flutter app is using the correct API URL

**"Port already in use"**
- Change the PORT in `.env` file
- Or kill the process using port 3000

## 📚 Next Steps

1. Add more endpoints as needed
2. Add input validation
3. Add error handling middleware
4. Add logging
5. Deploy to cloud (Heroku, Railway, etc.)

