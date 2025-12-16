# CherryPick Backend API

Backend API server for the CherryPick Malaysian Price Comparison App.

## Features

- 🔐 Firebase Authentication integration
- 📦 Product search and management
- 💰 Price comparison and tracking
- 🏪 Store location and management
- 🧾 Receipt OCR processing
- ❤️ Wishlist management
- 💵 Expense tracking and analytics

## Prerequisites

- Node.js 18+ 
- Firebase project with Firestore enabled
- Firebase Admin SDK service account key

## Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Configure Firebase:**
   - Go to Firebase Console > Project Settings > Service Accounts
   - Click "Generate New Private Key"
   - Save the JSON file as `serviceAccountKey.json` in the backend directory
   - **Important:** Add `serviceAccountKey.json` to `.gitignore` (already included)

3. **Configure environment variables:**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` and set your Firebase project ID:
   ```
   FIREBASE_PROJECT_ID=cherrypick-67246
   PORT=3000
   NODE_ENV=development
   ```

## Running the Server

**Development mode (with auto-reload):**
```bash
npm run dev
```

**Production mode:**
```bash
npm start
```

The server will start on `http://localhost:3000`

## API Endpoints

### Products
- `GET /api/products/search?q=query` - Search products
- `GET /api/products/:id` - Get product by ID
- `GET /api/products?category=food` - List products by category

### Prices
- `GET /api/prices/product/:productId` - Get prices for a product
- `GET /api/prices/compare/:productId` - Compare prices across stores
- `POST /api/prices` - Add a new price

### Stores
- `GET /api/stores` - List all stores
- `GET /api/stores?lat=3.123&lng=101.456&radius=10` - Get nearby stores
- `GET /api/stores/:id` - Get store by ID

### Receipts (Requires Authentication)
- `GET /api/receipts` - Get user's receipts
- `GET /api/receipts/:id` - Get receipt by ID
- `POST /api/receipts/upload` - Upload receipt image (multipart/form-data)
- `PUT /api/receipts/:id` - Update receipt
- `DELETE /api/receipts/:id` - Delete receipt

### Wishlist (Requires Authentication)
- `GET /api/wishlist` - Get user's wishlist
- `GET /api/wishlist/stats` - Get wishlist statistics
- `GET /api/wishlist/:id` - Get wishlist item with price info
- `POST /api/wishlist` - Add item to wishlist
- `PUT /api/wishlist/:id` - Update wishlist item
- `DELETE /api/wishlist/:id` - Remove from wishlist

### Expenses (Requires Authentication)
- `GET /api/expenses` - Get user's expenses
- `GET /api/expenses/summary?month=2024-01` - Get monthly summary
- `GET /api/expenses/trends?months=6` - Get spending trends
- `GET /api/expenses/categories` - Get expense categories
- `POST /api/expenses` - Add expense
- `PUT /api/expenses/:id` - Update expense
- `DELETE /api/expenses/:id` - Delete expense

## Authentication

For protected endpoints, include the Firebase ID token in the Authorization header:

```
Authorization: Bearer <firebase_id_token>
```

To get the token from your Flutter app:
```dart
String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
```

## Example Requests

### Search Products
```bash
curl http://localhost:3000/api/products/search?q=apple
```

### Compare Prices
```bash
curl http://localhost:3000/api/prices/compare/PRODUCT_ID
```

### Upload Receipt (with auth token)
```bash
curl -X POST http://localhost:3000/api/receipts/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "image=@receipt.jpg" \
  -F "storeName=Tesco"
```

## Project Structure

```
CherryPick_backend/
├── config/
│   └── firebase.js          # Firebase Admin SDK setup
├── middleware/
│   ├── auth.js              # Authentication middleware
│   └── errorHandler.js      # Error handling
├── routes/
│   ├── products.js          # Product routes
│   ├── prices.js            # Price routes
│   ├── stores.js            # Store routes
│   ├── receipts.js          # Receipt routes
│   ├── wishlist.js          # Wishlist routes
│   └── expenses.js          # Expense routes
├── .env.example             # Environment variables template
├── .gitignore               # Git ignore file
├── package.json             # Dependencies
└── server.js               # Main server file
```

## Notes

- The OCR functionality uses Tesseract.js for text extraction from receipt images
- Receipt processing happens asynchronously after upload
- All timestamps are stored as Firestore Timestamps and converted to ISO strings in responses
- Location-based queries use the Haversine formula for distance calculation

## Troubleshooting

**Firebase Admin SDK not initialized:**
- Make sure `serviceAccountKey.json` exists in the backend directory
- Verify the file contains valid JSON with proper credentials

**CORS errors:**
- The server is configured to allow all origins in development
- For production, configure CORS to allow only your app's domain

**Authentication errors:**
- Verify the Firebase ID token is valid and not expired
- Check that the token is being sent in the Authorization header



