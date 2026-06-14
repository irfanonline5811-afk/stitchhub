# StitchHub API & Integration Documentation 📚

This document provides a comprehensive technical overview of all APIs, Services, and Integrations implemented in the **StitchHub** application.

---

## 🏗️ Architecture Overview

StitchHub utilizes a **Hybrid Architecture** combining:
1.  **Serverless (Supabase):** For direct frontend-to-database operations, authentication, and file storage.
2.  **Custom Backend (Node.js/Express):** For complex business logic, third-party integrations (Twilio, Stripe), and secure administrative tasks.

---

## 1. Supabase Suite (Core Infrastructure) 
**Implementation:** `lib/services/` (Frontend)

The backbone of the application depends on Supabase.

### A. Authentication (`supabase_auth`)
*   **Purpose:** Manages user identity, sessions, and security.
*   **Features Used:**
    *   Email/Password Registration & Login.
    *   Session persistence.
*   **Code Reference (`AuthService`):**
    ```dart
    final AuthResponse res = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    ```

### B. Supabase Database (PostgreSQL)
*   **Purpose:** Relational Database with Real-time support.
*   **Data Structure (Tables):**
    *   `users`: Customer profiles.
    *   `tailors`: Professional profiles mixed with location data.
    *   `orders`: Transactional data linked to users and tailors.
    *   `reviews`: Ratings and text feedback.
    *   `payments`: Payment records and status.
*   **Real-time Usage:** The app listens to realtime channels (e.g., `orders` table) to update the UI instantly when a status changes.

### C. Supabase Storage
*   **Purpose:** Object storage for binary files.
*   **Usage:**
    *   User Profile Pictures (`profile_images/`).
    *   Tailor Work Samples/Portfolio (`work_samples/`).
    *   Order Design References (`order_images/`).

---

## 2. Custom Node.js Backend API
**Implementation:** `backend/server.js` & `backend/routes/`

A RESTful API built with **Express.js** to handle secure operations.

### Base URL: `/api`

### A. Order Management (`/api/orders`)
Handles the lifecycle of a tailoring order.
*   **POST** `/` - Create a new order.
    *   *Logic:* Validates input -> Saves to Supabase -> Triggers SMS to Tailor.
*   **GET** `/customer/:customerId` - Fetch orders for a specific customer.
*   **PUT** `/:orderId/status` - Update order status (e.g., 'Pending' -> 'InProgress').
    *   *Logic:* Updates Supabase -> Triggers SMS to Customer.
*   **PUT** `/:orderId/cancel` - Cancel an existing order.

### B. Notifications (`/api/notifications`)
Endpoints to manually trigger system notifications.
*   **POST** `/sms` - Send a generic SMS.
*   **POST** `/payment-reminder` - Send a payment due reminder.

### C. Authorization (`/api/auth`)
*   **POST** `/register` - Server-side registration logic.
*   **POST** `/login` - Server-side login verification.

---

## 3. Twilio API (SMS Service) 📱
**Implementation:** `backend/config/twilio.js` & `backend/routes/notifications.js`

Integrated into the Node.js backend to provide offline updates via SMS.

### Key Features:
*   **Automated Triggers:**
    *   **New Order:** "You have a new order request from [Name]." (Sent to Tailor)
    *   **Status Update:** "Your appt is confirmed." (Sent to Customer)
    *   **OTP/Verification:** (Implemented for phone verification).

### Code Snippet (Backend):
```javascript
const client = require('twilio')(accountSid, authToken);

exports.sendSMS = async (to, body) => {
  return await client.messages.create({
    body: body,
    from: process.env.TWILIO_PHONE_NUMBER,
    to: to
  });
};
```

---

## 4. Stripe API (Payments) 💳
**Implementation:** `lib/services/payment_service.dart` (Frontend) & Stripe Node SDK (Backend)

Follows a secure **Payment Intent** flow.

### Workflow:
1.  **Frontend:** User clicks "Pay Now".
2.  **API Call:** App requests `backend_url/api/payments/create-intent` with amount and currency.
3.  **Backend:** Communicates with Stripe to generate a `client_secret`.
4.  **Frontend:** Uses `flutter_stripe` to present the native card sheet and confirm payment using the `client_secret`.
5.  **Confirmation:** On success, Supabase `payments` table is updated.

---

## 5. Location & Maps APIs 📍
**Implementation:** `lib/providers/location_provider.dart`

To connect customers with nearby tailors.

### A. Geolocator (`geolocator`)
*   **Function:** Accesses device GPS hardware.
*   **Usage:** Determines user's current Coordinates (Lat/Long).

### B. Geocoding (`geocoding`)
*   **Function:** Address <-> Coordinates conversion.
*   **Usage:** "Human-readable" address display on the dashboard.

### C. Logic (Distance Calculation)
*   The app filters tailors using the **Haversine Formula** implementation to find tailors within a specific radius (e.g., 10KM) of the user.

---

## 🛠️ Configuration & Setup

### Environment Variables (.env)
To run the backend, the following keys are required:

```env
PORT=3000
SUPABASE_URL=your_url
SUPABASE_ANON_KEY=your_key
TWILIO_ACCOUNT_SID=your_sid
TWILIO_AUTH_TOKEN=your_token
TWILIO_PHONE_NUMBER=your_number
STRIPE_SECRET_KEY=your_stripe_key
```

### Flutter `pubspec.yaml` Dependencies
Ensure these packages are installed:
*   `supabase_flutter`
*   `flutter_stripe`
*   `http`
*   `geolocator`
