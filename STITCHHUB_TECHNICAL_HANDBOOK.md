# StitchHub - Complete Technical Implementation Handbook 📘

This document provides a comprehensive, deep-dive explanation of every module, service, and architectural decision implemented in the **StitchHub** project as of March 2026.

---

## 🏗️ 1. Core Architecture Pattern
StitchHub is built using the **MVVM (Model-View-ViewModel)** pattern coupled with the **Provider** state management system.

*   **Models**: Data structures that strictly define our entities (User, Order, measurement, etc.).
*   **Services**: Logic layers that communicate with Supabase Auth, Supabase Database, and external APIs (Stripe).
*   **Providers**: The "State" layer that holds data and notifies the UI when updates occur.
*   **Views (Screens)**: The UI layer that purely renders based on the state provided by the Providers.

---

## 📂 2. Data Models (The Brain)
Every piece of data in StitchHub is structured via Dart classes with `fromMap` and `toMap` methods for seamless Supabase integration.

### A. Authentication & User Management
*   **`UserModel`**: Base class containing common fields like `id`, `name`, `email`, `phone`, and `userType` (customer/tailor).
*   **`TailorModel`**: Extends `UserModel`. Contains business-specific fields: `businessName`, `specialties`, `pricing`, `rating`, `workSamples`, and `location (latitude/longitude)`.

### B. Transactional Data
*   **`OrderModel`**: Detailed structure for tailoring orders. Includes `productId`, `serviceType`, `fabricInstructions`, `totalPrice`, and `orderStatus` (pending, ready, completed).
*   **`AppointmentModel`**: Manages scheduling. Stores `startTime`, `endTime`, `status`, and `notes`.
*   **`MeasurementModel`**: The digital diary. Stores every body part measurement (chest, waist, hip, etc.) for a specific customer.

---

## 🛠️ 3. Service Layer (Logic & Integration)

### 🌊 Real-Time Supabase Engines
The app doesn't just "fetch" data; it listens to it using **Streams**.
*   **`ChatService`**: Uses Supabase Realtime channels for instant messaging. Messages are ordered by timestamp.
*   **`AppointmentService`**: 
    *   **Conflict Logic**: Before a booking is confirmed, it queries existing appointments to ensure no time overlap.
    *   **Real-time Lists**: Provides a stream of requests to the tailor's dashboard.
*   **`TailorService`**: Handles geographic queries using latitude and longitude to find nearby shops.

### 💳 Financial Modules
*   **`PaymentService`**: Integrated with **Flutter Stripe SDK**.
    *   Creates a `PaymentIntent` on our server.
    *   Handles the 3D Secure checkout flow.
    *   Confirms transaction completion before updating the order status in Supabase.

### 🛡️ Security & Auth
*   **`AuthService`**: Manages Supabase Email/Password login and registration.
    *   During signup, it creates a corresponding record in the `users` table.
    *   If the user type is 'tailor', it initializes empty shop settings.

---

## ⚡ 4. State Management (Providers)

### `AuthProvider`
The most critical provider. It globalizes the current user's state.
*   If `currentUser.userType == 'tailor'`, the app automatically loads the Tailor Dashboard.
*   If `currentUser.userType == 'customer'`, it loads the Discovery Screen.

### `MeasurementProvider`
Allows the tailor to update measurements. It supports:
*   Fetching the latest size record for any customer.
*   Updating specific values (e.g., only changing 'Neck' size while keeping others).
*   Notification triggers (Notifying customer that their profile has been updated).

---

## 📲 5. Key Feature Implementations (Deep Dive)

### 📍 The Tailor Discovery System
Customers can find tailors through two views:
1.  **List View**: Sorted by proximity or rating.
2.  **Map View**: Individual markers for each shop using `Google Maps Flutter`. Clicking a marker opens the **TailorDetailScreen**.

### 🗓️ Smart Booking Flow
When a customer clicks "Book Appointment":
1.  They select a date and 30-min time slot.
2.  The `AppointmentService` validates against the global database for that specific tailor.
3.  If successful, a `pending` request appears on the tailor's app.
4.  Tailors can **Approve** or **Decline**.
5.  All status changes are updated via Streams, so the customer sees the change instantly without refreshing.

### 📏 Digital Measurement Vault
Traditionally, tailors use notebooks. StitchHub replaces this with:
*   A form-based entry system for all standard body measurements.
*   History tracking (seeing how measurements changed over time).
*   Customer Access: Customers can view their own sizes but cannot edit them, ensuring accuracy.

---

## 🎨 6. Design System & UX
Implemented in `modern_ui_components.dart`:
*   **`ModernCard`**: Uses custom shadows and rounded corners (30px) for a premium feel.
*   **`ModernButton`**: Integrated loading animations (CircularProgressIndicator) inside the button itself.
*   **Color Palette**: 
    *   `Primary`: Deep Green (#008000) for trust.
    *   `Surface`: Soft White (#FBFBFB) for readability.
    *   `Alerts`: Vibrand Red/Orange for status updates.

---

## 📂 7. Project Directory Map
```text
lib/
├── models/      # Data schemas (UserModel, TailorModel, etc.)
├── services/    # External logic (Firebase, Stripe, Location)
├── providers/   # Global app state (Auth, Appointments, Orders)
├── theme/       # Color schemes & AppTheme class
├── widgets/     # Reusable UI (ModernCard, StatusBadge)
└── screens/     # Role-based UI
    ├── auth/    # Login/Signup/Reset Password
    ├── customer/# Discovery, Orders, Booking
    └── tailor/  # Dashboard, Measurements, Requests
```

---
**Document Status**: Final Technical Spec (v1.5)
**Last Updated**: March 1, 2026
**Implementation Coverage**: 100% of Current Core Features
