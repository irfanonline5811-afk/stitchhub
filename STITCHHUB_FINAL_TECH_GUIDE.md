# StitchHub - Ultimate Technical Blueprint & Project Log 🚀

This document is the definitive source of truth for the **StitchHub** project implementation. It reflects the exact current state of the codebase, including all custom modifications, feature additions, and recent UI/UX optimizations.

---

## 🏗️ 1. Project Foundation: MVVM + Provider
The project follows a robust **MVVM (Model-View-ViewModel)** architecture to ensure high scalability and a bug-free experience. 

*   **Models**: Pure data classes using Supabase's relational format.
*   **Services**: Backend connectors (Supabase, Stripe, Geolocator).
*   **Providers**: Centralized state management utilizing `ChangeNotifier` to drive UI updates globally.
*   **Theming**: Managed in `lib/theme/app_theme.dart` and `lib/widgets/modern_ui_components.dart`, ensuring a premium "Apple-like" aesthetic.

---

## 📏 2. Custom Measurement Ecosystem (Updated)
Based on recent system audits, the measurement module has been tightened for accuracy and specific tailoring needs.

### Field Deletions & Optmizations
*   **Hip Deletion**: The 'Hip' measurement field has been intentionally removed from both Customer and Tailor interfaces to simplify the profile and focus on core tailoring metrics (Chest, Waist, Shoulder, etc.).
*   **Dynamic UI**: The measurement display systems (e.g., `MeasurementDetailScreen`) now utilize dynamic entry loops, meaning they only render the fields that contain valid data from Supabase.

### Current Valid Measurement Fields
The system now primarily tracks:
1.  **Chest / Bust**
2.  **Waist**
3.  **Shoulder Width**
4.  **Sleeve Length**
5.  **Pant / Shirt Length**
6.  **Neck**
7.  **Inseam** (Optional)

---

## 🗓️ 3. Smart Appointment & Booking System
This is the heart of the StitchHub user lifecycle, recently upgraded for real-time responsiveness.

### Real-Time Flux (Streams)
Unlike traditional "static" apps, StitchHub uses **Supabase Realtime**.
*   **Instant Visibility**: When a customer books an appointment, it appears on the Tailor's screen **instantly** without requiring a page refresh.
*   **Automated Sync**: Any status change (Approve/Decline) is reflected on the customer's device in milliseconds.

### Conflict Prevention Logic
*   The `AppointmentService` contains built-in validation to prevent double-bookings.
*   If a tailor is busy, users receive a modern, friendly alert: *"This time slot is already booked. Please choose another time."* 

---

## 💳 4. Financial & Transactional Engine
*   **Stripe Integration**: Secure payment processing for deposits and full payments.
*   **Role-Based Dashboards**: 
    *   **Tailors**: See earnings, pending orders, and payout status.
    *   **Customers**: See transaction history and digital receipts.

---

## 📂 5. Exhaustive Module Breakdown

### 🧥 Tailor Module Features
*   **Add Customer System**: Tailors can manually add customers and their measurements via `AddCustomerMeasurementScreen`.
*   **Order Tracking**: Real-time progress bar from "Cutting" to "Stitched" to "Ready".
*   **Portfolio Management**: High-res work samples stored in Supabase Storage.

### 👤 Customer Module Features
*   **Map Discovery**: Geographic search for local tailors using `Google Maps Flutter`.
*   **Order Wizard**: Upload design photos and instructions easily.
*   **Notification Center**: Alerts for appointment approvals and order completion.

---

## 🎨 6. Premium UI Component Library
The app's distinctive look is powered by `modern_ui_components.dart`:
*   **ModernCard**: 30px border radius with "Glassmorphism" shadow effects.
*   **ModernStatusBadge**: Dynamically coloring status text (Orange for Pending, Green for Approved, Red for Cancelled).
*   **ModernEmptyState**: Custom Lottie/Icon based placeholders that guide users when no data exists.

---

## 🗺️ 7. File Mapping & Architecture Log
```text
lib/
├── models/      # Data structures (AppointmentModel, MeasurementModel - Hip Removed)
├── services/    # Logic (AppointmentService with Streams, PaymentService)
├── providers/   # State (AppointmentProvider, AuthProvider)
├── utils/       # Error handling and Date formatting
└── screens/     # UI layer (Optimized for role-specific flows)
```

---
**Build Status**: Production-Ready / Optimized
**Last Audit**: March 1, 2026 (Reflecting Measurement Field Changes)
**Author**: Antigravity AI Engine (on behalf of StitchHub Team)
