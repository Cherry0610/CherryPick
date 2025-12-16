# 🍒 CherryPick - Malaysian Price Comparison App

A comprehensive price comparison app for Malaysia, similar to Trolley.co.uk but focused on the Malaysian market. CherryPick helps users find the best deals on groceries and household items across different retailers in Malaysia.

## 🌟 Features

### 1. **Price Comparison**
- Compare prices across major Malaysian retailers (NSK, Tesco, Giant, AEON, etc.)
- Real-time price updates from multiple sources
- Price history tracking and trends

### 2. **Money Tracker**
- Track grocery expenses from uploaded receipts
- Categorize spending by product type
- Monthly/yearly expense reports
- Budget tracking and alerts

### 3. **Wishlist with Price Alerts**
- Add products to wishlist with target prices
- Receive push notifications when prices drop
- Track price trends for wishlist items
- Set preferred stores for notifications

### 4. **Receipt Upload & OCR**
- Scan receipts using camera
- Extract product information using OCR
- Automatically update price database
- Manual verification and correction

### 5. **Google Maps Integration**
- Calculate travel costs (toll, distance, time)
- Show store locations on map
- Route optimization for multiple stores
- Real-time traffic information

## 🏗️ Architecture

### Tech Stack
- **Frontend**: Flutter (iOS, Android, Web)
- **Backend**: Firebase (Firestore, Auth, Storage, Analytics)
- **Maps**: Google Maps API
- **OCR**: Google ML Kit
- **Notifications**: Firebase Cloud Messaging

### Data Models
- **Product**: Product information and metadata
- **Store**: Retailer information and locations
- **ProductPrice**: Price data with timestamps
- **Receipt**: Receipt data and OCR results
- **WishlistItem**: User wishlist with target prices
- **ExpenseTracking**: User expense records

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Firebase project setup
- Google Maps API key
- iOS/Android development environment

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd cherrypick_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project
   - Enable Firestore, Auth, Storage, and Analytics
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories

4. **Google Maps Setup**
   - Get Google Maps API key
   - Enable Maps SDK for Android/iOS
   - Add API key to platform-specific configurations

5. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screens

### 1. **Home Screen**
- Featured deals and promotions
- Quick search functionality
- Recent price comparisons
- Spending summary

### 2. **Compare Screen**
- Product search and comparison
- Price comparison table
- Store locations and travel costs
- Add to wishlist functionality

### 3. **Receipts Screen**
- Receipt upload interface
- Receipt history and management
- OCR processing status
- Manual price verification

### 4. **Tracker Screen**
- Expense tracking dashboard
- Category-wise spending breakdown
- Monthly/yearly reports
- Budget management

### 5. **Wishlist Screen**
- Wishlist items management
- Price alerts configuration
- Notification settings
- Price trend charts

### 6. **Profile Screen**
- User account management
- App settings and preferences
- Notification preferences
- Data export options

## 🔧 Development

### Project Structure
```
lib/
├── models/           # Data models
├── services/         # Business logic and API calls
├── screens/          # UI screens
├── widgets/          # Reusable UI components
├── utils/            # Utility functions
└── main.dart         # App entry point
```

### Key Services
- **FirestoreService**: Database operations
- **MapsService**: Google Maps integration
- **OCRService**: Receipt text recognition
- **NotificationService**: Push notifications
- **PriceComparisonService**: Price comparison logic

## 🎯 Roadmap

### Phase 1: Core Features (Current)
- [x] Basic app structure and navigation
- [x] Firebase integration
- [x] Data models and services
- [ ] Core screen implementations
- [ ] Basic price comparison

### Phase 2: Advanced Features
- [ ] Google Maps integration
- [ ] Receipt OCR functionality
- [ ] Push notifications
- [ ] Advanced search and filters

### Phase 3: Polish & Optimization
- [ ] UI/UX improvements
- [ ] Performance optimization
- [ ] Multi-language support
- [ ] Advanced analytics

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions, please contact the development team or create an issue in the repository.

---

**CherryPick** - Making grocery shopping smarter in Malaysia! 🍒