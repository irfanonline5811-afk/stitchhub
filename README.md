# StitchHub - Tailor Marketplace App 👔

<div align="center">

![StitchHub Logo](assets/images/app_logo.png)

**A comprehensive tailor marketplace application connecting customers with local tailors for all their stitching needs.**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Enabled-3ECF8E?logo=supabase)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

## 📱 Overview

StitchHub is a full-featured mobile marketplace application that bridges the gap between customers seeking tailoring services and local tailors. Built with Flutter and Supabase, it provides a seamless experience for both customers and tailors to connect, communicate, and conduct business.

### Key Highlights
- ✅ **Dual User Mode**: Separate interfaces for customers and tailors

- ✅ **Real-Time Communication**: In-app chat between customers and tailors
- ✅ **Order Management**: Complete order lifecycle tracking
- ✅ **Measurement Management**: Tailors can add, edit, and manage customer measurements
- ✅ **Push Notifications**: Real-time updates for orders and messages

---

## ✨ Features

### 👤 For Customers

#### 🔐 Authentication & Profile
- User registration and login
- Profile management with photo upload
- Secure authentication via Supabase Auth

#### 🔍 Search & Discovery
- **Location-based search** - Find tailors near you using GPS
- **Advanced filters** - Filter by services, ratings, distance, and price
- **Tailor profiles** - View detailed profiles with work samples, ratings, and reviews
- **Favorites** - Save favorite tailors for quick access

#### 📦 Order Management
- **Place orders** - Submit stitching requests with detailed requirements
- **Order tracking** - Real-time order status updates
- **Order history** - View all past and current orders
- **Order details** - Track order progress with detailed information

#### 📏 Measurements
- **Request measurements** - Request tailor to take measurements
- **Measurement history** - View all measurement records
- **Appointment scheduling** - Schedule measurement appointments

#### 💬 Communication
- **In-app chat** - Direct messaging with tailors
- **Real-time notifications** - Get notified about order updates and messages via Supabase Realtime

#### ⭐ Reviews & Ratings
- **Rate tailors** - Leave ratings and reviews after service
- **View reviews** - See what others say about tailors



#### 📅 Appointments
- **Book appointments** - Schedule visits with tailors
- **Manage appointments** - View and manage all appointments

---

### 👔 For Tailors

#### 🔐 Registration & Setup
- **Tailor registration** - Create business account
- **Profile setup** - Complete business profile with:
  - Business name and address
  - Services offered
  - Pricing for each service
  - Working hours and availability
  - Work samples upload
  - Profile picture upload


#### 📊 Dashboard
- **Business overview** - View total orders, active orders, completed orders, and ratings
- **Quick actions** - Quick access to common tasks
- **Recent orders** - View latest customer orders

#### 📦 Order Management
- **View orders** - See all customer orders
- **Accept/Reject orders** - Manage incoming orders
- **Update order status** - Track order progress
- **Order details** - View complete order information

#### 📏 Measurement Management ⭐ NEW
- **Add customers** - Add new customers by name
- **Take measurements** - Record customer measurements
- **Search customers** - Search for existing customers
- **View all measurements** - See all customer measurements
- **Edit measurements** - Update existing measurements
- **Delete measurements** - Remove measurement records
- **CRUD operations** - Complete Create, Read, Update, Delete functionality

#### 💬 Communication
- **Customer chat** - Chat with customers
- **Message notifications** - Get notified about new messages

#### 📅 Appointments
- **View requests** - See measurement appointment requests
- **Schedule appointments** - Set appointment dates and times
- **Manage appointments** - Approve or decline appointment requests

#### ⭐ Reviews & Ratings
- **View reviews** - See customer feedback
- **Rating display** - Showcase average rating

#### 📸 Work Samples
- **Upload samples** - Showcase previous work
- **Manage portfolio** - Add and remove work samples

---

## 🛠️ Tech Stack

### Frontend
| Technology | Purpose | Version |
|------------|---------|---------|
| **Flutter** | Cross-platform mobile framework | 3.0+ |
| **Dart** | Programming language | 3.0+ |
| **Provider** | State management | ^6.1.1 |
| **Supabase Flutter** | Database & Auth integration | ^2.6.0 |
| **Flutter Stripe** | Payment processing | ^11.0.0 |
| **Geolocator** | Location services | ^10.1.0 |
| **Google Maps** | Maps integration | ^2.5.3 |
| **Image Picker** | Photo selection | ^1.0.4 |

### Backend
| Technology | Purpose |
|------------|---------|
| **Node.js** | Server runtime |
| **Express.js** | Web framework |
| **Supabase SDK** | Backend Supabase operations |
| **Twilio API** | SMS notifications |
| **Multer** | File upload handling |

### Database & Storage
- **Supabase Database (PostgreSQL)** - Relational database with Realtime support
- **Supabase Storage** - Cloud storage for images

---

## 📁 Project Structure

```
stitchhub2/
├── lib/                              # Flutter app source code
│   ├── models/                       # Data models (12 models)
│   │   ├── user_model.dart
│   │   ├── tailor_model.dart
│   │   ├── order_model.dart
│   │   ├── measurement_model.dart
│   │   └── ...
│   ├── providers/                    # State management (11 providers)
│   │   ├── auth_provider.dart
│   │   ├── order_provider.dart
│   │   ├── measurement_provider.dart
│   │   └── ...
│   ├── services/                     # Business logic (14 services)
│   │   ├── auth_service.dart
│   │   ├── order_service.dart
│   │   ├── measurement_service.dart
│   │   └── ...
│   ├── screens/                      # UI screens
│   │   ├── auth/                     # Authentication screens
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── customer/                 # Customer screens (17 screens)
│   │   │   ├── customer_home_screen.dart
│   │   │   ├── search_tailors_screen.dart
│   │   │   ├── place_order_screen.dart
│   │   │   └── ...
│   │   ├── tailor/                   # Tailor screens (13 screens)
│   │   │   ├── tailor_home_screen.dart
│   │   │   ├── tailor_setup_screen.dart
│   │   │   ├── add_customer_measurement_screen.dart ⭐ NEW
│   │   │   └── ...
│   │   └── splash_screen.dart
│   ├── theme/                        # App theming
│   │   └── app_theme.dart
│   ├── utils/                        # Utility classes
│   │   ├── error_handler.dart
│   │   └── network_utils.dart
│   └── main.dart                     # App entry point
├── backend/                          # Node.js backend
│   ├── routes/                       # API routes
│   │   ├── auth.js
│   │   ├── orders.js
│   │   ├── tailors.js
│   │   └── ...
│   ├── config/                       # Configuration
│   │   └── twilio.js
│   └── server.js                     # Server entry point
├── android/                          # Android configuration
├── docs/                             # Project documentation
│   ├── models/                       # Model documentation
│   ├── services/                     # Service documentation
│   └── ...
├── pubspec.yaml                      # Flutter dependencies
└── README.md                         # This file
```

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0.0 or higher)
  ```bash
  flutter --version
  ```
- **Dart SDK** (3.0.0 or higher) - Included with Flutter
- **Node.js** (16.0.0 or higher)
  ```bash
  node --version
  ```
- **Supabase Account** - For authentication, database, and storage
- **Google Cloud Account** - For Maps API (optional)
- **Twilio Account** - For SMS notifications (optional)

### Installation

#### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/stitchhub2.git
cd stitchhub2
```

#### 2. Frontend Setup (Flutter)

##### Install Dependencies

```bash
flutter pub get
```

1. **Create a Supabase Project**
   - Go to [Supabase Dashboard](https://supabase.com/dashboard)
   - Create a new project
   - Configure the following:
     - Authentication (Email/Password)
     - Database (Tables: users, tailors, orders, measurements, etc.)
     - Storage (Bucket: images)

2. **Configure App**
   - Get your `SUPABASE_URL` and `SUPABASE_ANON_KEY` from settings
   - Initialize in `lib/main.dart`

##### Configure Location Permissions

Location permissions are already configured in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

##### Run the App

```bash
# For Android
flutter run

# For iOS (Mac only)
flutter run -d ios

# For a specific device
flutter devices
flutter run -d <device-id>
```

#### 3. Backend Setup (Node.js)

##### Install Dependencies

```bash
cd backend
npm install
```

##### Configure Environment Variables

1. Copy the example environment file:
   ```bash
   cp env.example .env
   ```

2. Update `.env` with your configuration:
   ```env
   # Supabase Configuration
   SUPABASE_URL=your-supabase-url
   SUPABASE_ANON_KEY=your-anon-key
   SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

   # Twilio Configuration (Optional)
   TWILIO_ACCOUNT_SID=your-account-sid
   TWILIO_AUTH_TOKEN=your-auth-token
   TWILIO_PHONE_NUMBER=your-phone-number

   # Server Configuration
   PORT=3000
   NODE_ENV=development
   ```

3. **Set up Supabase Keys**
   - Go to Supabase Dashboard → Project Settings → API
   - Copy the Project URL and API Keys (Anon and Service Role)

##### Start the Backend Server

```bash
# Development mode
npm run dev

# Production mode
npm start
```

The server will run on `http://localhost:3000` (or your configured PORT)

---

## 📖 Usage Guide

### For Customers

1. **Registration**
   - Open the app and tap "Register"
   - Select "Customer" as user type
   - Fill in your details and create an account

2. **Finding Tailors**
   - Allow location access when prompted
   - Use the search screen to find nearby tailors
   - Apply filters to narrow down results
   - View tailor profiles and work samples

3. **Placing Orders**
   - Select a tailor
   - Choose service type and provide details
   - Add images if needed
   - Place the order

4. **Tracking Orders**
   - Go to "My Orders"
   - View order status and updates
   - Chat with tailor if needed

### For Tailors

1. **Registration & Setup**
   - Register as "Tailor"
   - Complete profile setup:
     - Enter business name and address
     - Enable location (required)
     - Select services you offer
     - Set pricing for each service
     - Upload profile picture
     - Upload work samples
   - Click "Complete Setup"

2. **Managing Customers & Measurements** ⭐ NEW
   - Go to Dashboard → "Add Customer"
   - Search for existing customers or add new ones
   - Add/Edit/Delete customer measurements
   - View all customer measurement records

3. **Managing Orders**
   - View incoming orders in "Orders" tab
   - Accept or reject orders
   - Update order status as work progresses

4. **Communication**
   - Chat with customers
   - Respond to measurement requests
   - Schedule appointments

---

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `GET /api/auth/profile/:userId` - Get user profile
- `PUT /api/auth/profile/:userId` - Update user profile
- `PUT /api/auth/tailor/:userId` - Update tailor profile

### Tailors
- `GET /api/tailors` - Get all tailors
- `POST /api/tailors/search` - Search tailors by location
- `GET /api/tailors/:tailorId` - Get tailor by ID
- `PUT /api/tailors/:tailorId/availability` - Update availability

### Orders
- `POST /api/orders` - Create new order
- `GET /api/orders/customer/:customerId` - Get customer orders
- `GET /api/orders/tailor/:tailorId` - Get tailor orders
- `PUT /api/orders/:orderId/status` - Update order status

### Measurements
- `POST /api/measurements` - Create measurement
- `GET /api/measurements/tailor/:tailorId` - Get tailor measurements
- `PUT /api/measurements/:measurementId` - Update measurement
- `DELETE /api/measurements/:measurementId` - Delete measurement

### Notifications
- `POST /api/notifications/sms` - Send SMS
- `POST /api/notifications/order-confirmation` - Send order confirmation

### File Upload
- `POST /api/upload/profile-image/:userId` - Upload profile image
- `POST /api/upload/work-sample/:tailorId` - Upload work sample

---

## 🎨 Key Features Implementation

### Location-Based Search
- Uses GPS coordinates to find tailors within specified radius
- Calculates distance using Geolocator
- Sorts results by proximity
- Progressive accuracy fallback for faster location retrieval

### Measurement Management
- **Search functionality** - Search customers by name or notes
- **CRUD operations** - Complete Create, Read, Update, Delete
- **List view** - View all customers with their measurements
- **Detail view** - Tap to see full measurement details
- **Form validation** - Ensures data integrity

### Order Management
- Real-time order status updates via Supabase Realtime
- Push notifications for status changes via Supabase Edge Functions
- Order tracking with detailed history
- SMS notifications (via Twilio)

### Real-Time Chat
- Supabase Database for real-time messaging
- Real-time listeners for new messages
- Message history persistence

### Payment Integration
- Stripe integration for secure payments
- Multiple payment methods support
- Payment history tracking

---

## 🔒 Security Features

- ✅ Input validation using form validators
- ✅ Supabase Authentication for secure login
- ✅ Supabase RLS (Row Level Security) rules
- ✅ File type validation for uploads
- ✅ Location permission handling
- ✅ Error handling and user feedback

---

## 📱 Screenshots

> **Note:** Add screenshots of your app here

- Customer Home Screen
- Tailor Dashboard
- Search Screen
- Order Details
- Measurement Management
- Chat Screen

---

## 🧪 Testing

```bash
# Run Flutter tests
flutter test

# Run with coverage
flutter test --coverage
```

---

## 📦 Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS

```bash
# Build for iOS (Mac only)
flutter build ios --release
```

---

## 🚢 Deployment

### Frontend (Flutter)

1. **Android**
   - Build release APK or App Bundle
   - Upload to Google Play Console
   - Configure app signing

2. **iOS**
   - Build release IPA
   - Upload to App Store Connect
   - Submit for review

### Backend (Node.js)

Deploy to cloud platforms:
- **Heroku**: `git push heroku main`
- **AWS**: Use Elastic Beanstalk or EC2
- **Google Cloud**: Use App Engine or Cloud Run
- **Vercel/Netlify**: For serverless deployment

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Team

- **Development Team** - StitchHub Development

---

## 📞 Support

For support, email support@stitchhub.com or create an issue in the repository.

---

## 🗺️ Roadmap

- [x] User authentication
- [x] Location-based search
- [x] Order management
- [x] Measurement management
- [x] Real-time chat
- [x] Push notifications
- [ ] Advanced analytics dashboard
- [ ] Multi-language support
- [ ] Admin panel
- [ ] Video call integration
- [ ] Advanced payment methods
- [ ] Order scheduling calendar

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for backend services (Auth, Database, Storage)
- All contributors and testers

---

<div align="center">

**Made with ❤️ using Flutter**

⭐ Star this repo if you find it helpful!

</div>
