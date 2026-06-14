# 🧤 StitchHub - Premier Tailor Marketplace

StitchHub is a high-end marketplace connecting customers with professional local tailors. It features a robust, real-time push notification system, secure authentication, and a modern premium UI.

## 🏗️ Architecture

- **Frontend:** Flutter (Mobile + Web)
- **Database/Auth:** Supabase (PostgreSQL)
- **Backend:** Node.js Express (for Firebase & Push Notifications)
- **Push Engine:** Firebase Cloud Messaging (FCM)

## 🌟 Key Features

### 👨‍👩‍👧 For Customers
- **Search Tailors:** Find local tailors based on geolocation (Google Maps integration).
- **Appointment Booking:** Real-time scheduling with professional tailors.
- **Custom Orders:** Place detailed tailoring orders with measurement uploads.
- **Real-time Updates:** Push notifications for order status (WhatsApp style).

### ✂️ For Tailors
- **Business Management:** Custom business profiles with specialty listings.
- **Order Tracking:** Dashboard for managing new and in-progress orders.
- **Appointment Management:** Accept/Decline requests with instant customer alerts.
- **Push Notifications:** Instant popups for new requests (even when the app is closed).

## 🚀 Setup & Installation

### 1. Backend Notification Server
The Node.js backend handles secure communication with Firebase Admin SDK.

**Setup:**
- Go to `backend/` directory.
- Place your `serviceAccountKey.json` from Firebase in `backend/config/`.
- Run `npm install`.
- Start server: `node server.js`.

**Base URL:**
Update `lib/services/notification_service.dart` with your server IP (Local or Cloud URL).

### 2. Flutter App
- Initialize Firebase in `main.dart`.
- Run `flutter pub get`.
- Launch on Android/iOS/Web.

## 🛡️ Security Measures

- **FCM Token Sync:** Tokens are refreshed on every login to ensure delivery.
- **Backend Protection:** Rate limiting, CORS, and Helmet security implemented.
- **Environment Support:** Secure deployment with `.gitignore` and Env Variables support.
- **Input Validation:** Strict `Joi` schemas for API safety.

## 📱 How to Test Real-time Flow
1. Run Backend: `node server.js`.
2. Login on Tailor Device & Customer Device.
3. Place an order from Customer.
4. Observe **Push Notification Popup** on Tailor device (even if screen is locked).

---
*StitchHub - Crafting Excellence in Every Stitch.*
